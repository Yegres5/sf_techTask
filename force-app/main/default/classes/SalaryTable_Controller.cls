/**
 * Created by evgeny on 26.12.2022.
 */

public with sharing class SalaryTable_Controller {
    private static final String DEFAULT_CURRENCY = 'USD';

    @AuraEnabled
    public static List<CurrencyType> getExchangeRates() {
        List<CurrencyType> exchangeRates = [
                Select
                        IsoCode,
                        ConversionRate
                FROM CurrencyType
        ];
        return exchangeRates;
    }

    @AuraEnabled
    public static Decimal getCurrentUserSalary() {
        List<Contact> contactSalaries = [SELECT Salary__c, CurrencyIsoCode FROM Contact];
        Map<String, Decimal> exchangeRates = new Map<String,Decimal>();

        for (CurrencyType cType: SalaryTable_Controller.getExchangeRates()) {
            exchangeRates.put(cType.IsoCode, cType.ConversionRate);
        }

        Decimal sum = 0;
        for (Contact cont: contactSalaries){
            System.debug(cont.Salary__c + ' ' + exchangeRates.get(cont.CurrencyIsoCode));
            sum += cont.Salary__c/exchangeRates.get(cont.CurrencyIsoCode);
        }

        return sum;
    }

    @AuraEnabled
    public static String updateExchangeRates(String sessionId) {
        List<CurrencyType> currentRates = getExchangeRates();
        Map<String, Object> exchangeRates = getRates();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/services/data/v56.0/composite/tree/CurrencyType/'
        );
        req.setMethod('POST');
        req.setBody(generateRequestBody(currentRates, exchangeRates));
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    @AuraEnabled
    public static void updateAllAccountsExpenses() {
        List<Contact> contacts = [SELECT AccountId FROM Contact];
        SalaryChangeService.recalculateSalaryChange(contacts);
    }

    // TestMethod do not support getContent call
    @AuraEnabled
    public static String fetchUserSessionId() {
        String sessionId = '';
        PageReference reportPage = Page.GetSessionIdVF;
        String vfContent = reportPage.getContent().toString();
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);
        return sessionId;
    }

    private static String generateRequestBody(List<CurrencyType> currentRates, Map<String, Object> newRates) {
        JSONGenerator gen = JSON.createGenerator(false);
        List<CurrencyDTO> currencyList = new List<CurrencyDTO>();
        for (CurrencyType cType: currentRates) {
            if (cType.IsoCode == DEFAULT_CURRENCY){
                continue;
            }
            currencyList.add(new CurrencyDTO(
                    cType.IsoCode,
                    (Decimal)newRates.get(cType.IsoCode)
            ));
        }
        gen.writeStartObject();
        gen.writeObjectField('records', currencyList);
        gen.writeEndObject();

        return gen.getAsString();
    }

    private static Map<String, Object> getRates() {
        String Url = 'https://api.exchangerate.host/latest?base=USD';

        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);

        Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> exchangeRates = (Map<String, Object>) mapResponse.get('rates');
        return exchangeRates;
    }

    private class AttributeDTO {
        String type;
        String referenceId;

        public AttributeDTO(String refId) {
            type = 'CurrencyType';
            referenceId = refId;
        }
    }

    private class CurrencyDTO {
        String IsoCode;
        Decimal ConversionRate;
        Integer DecimalPlaces;
        Boolean IsActive;
        AttributeDTO attributes;

        public CurrencyDTO(String iso, Decimal conv) {
            IsoCode = iso;
            ConversionRate = conv;
            DecimalPlaces = 2;
            IsActive = true;
            attributes = new AttributeDTO(iso);
        }
    }

}