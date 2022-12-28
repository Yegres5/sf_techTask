/**
 * Created by evgeny on 26.12.2022.
 */

public inherited sharing class SalaryChangeService {

    public static void recalculateSalaryChange(List<Contact> contacts) {
        Map<Id, Account> updateAccounts = new Map<Id, Account>();

        for (Contact contact: contacts) {
            Account acc = new Account(Id = contact.AccountId, SalaryExpenses__c = 0);

            updateAccounts.put(contact.AccountId, acc);
        }

        List<Contact> recalculationContacts = [
                SELECT
                        AccountId,
                        Salary__c,
                        CurrencyIsoCode
                From Contact
                WHERE AccountId IN :updateAccounts.keySet()
        ];

        Map<String, Decimal> mapExchangeRates = getExchangeRates();

        for (Contact result: recalculationContacts) {
            updateAccounts.get(result.AccountId).SalaryExpenses__c +=
                    result.Salary__c / mapExchangeRates.get(result.CurrencyIsoCode);
        }

        if (!updateAccounts.isEmpty()){
            update updateAccounts.values();
        }
    }

    private static Map<String, Decimal> getExchangeRates() {
        List<CurrencyType> exchangeRates = [
                Select
                        IsoCode,
                        ConversionRate
                FROM CurrencyType
        ];

        Map<String, Decimal> mapExchangeRates = new Map<String,Decimal>();

        for (CurrencyType cType: exchangeRates) {
            mapExchangeRates.put(cType.IsoCode, cType.ConversionRate);
        }
        return mapExchangeRates;
    }
}