/**
 * Created by evgeny on 27.12.2022.
 */

@IsTest
private class SalaryTable_ControllerTest {
    private final static String CURRENCY_COUNT = 'currencyCount';
    private final static String CURRENCY_UPDATE_ERROR = 'Errors during currency rates update';
    private static String TEST_USER_NAME = 'testsuser@testorg.com';

    @TestSetup
    static private void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User usr = new User(Alias = 'tstU', Email='testsuser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName=TEST_USER_NAME);
        insert usr;
    }

    @IsTest
    static private void allExchangeRates() {
        final Integer expectedCurrencyCount = (Integer)[
                SELECT Count(Id)
                currencyCount
                FROM CurrencyType
        ][0].get(CURRENCY_COUNT);
        Test.startTest();
        List<CurrencyType> currencies = SalaryTable_Controller.getExchangeRates();
        Test.stopTest();
        Assert.areEqual(expectedCurrencyCount, currencies.size());
    }

    @IsTest
    static private void userSalary() {
        Decimal salaryIncrement = 100;
        User usr = [SELECT Id FROM User WHERE UserName = :TEST_USER_NAME];

        Account acc = new Account(
                Name='TestAccount'
        );
        insert acc;

        Contact cont = new Contact(
                AccountId = acc.Id,
                LastName = 'Test',
                OwnerId = usr.Id,
                Salary__c = 100
        );
        insert cont;

        Decimal salary;
        System.runAs(usr){
            Test.startTest();
            salary = SalaryTable_Controller.getCurrentUserSalary();
            Test.stopTest();
        }
        Assert.areEqual(salaryIncrement, salary);
    }

    @IsTest
    static private void updateRates() {
        final String salesforceURL = URL.getSalesforceBaseUrl().toExternalForm() +
                '/services/data/v56.0/composite/tree/CurrencyType/';
        final String exchangereateURL = 'https://api.exchangerate.host/latest?base=USD';

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(salesforceURL, 'salesforceResponse');
        multimock.setStaticResource(exchangereateURL, 'exchangerateResponse');

        Test.starttest();
        Test.setMock(HttpCalloutMock.class, multimock);
        String sessionId = '';
        String responseBody = SalaryTable_Controller.updateExchangeRates(sessionId);
        Test.stoptest();

        JSONParser parser = JSON.createParser(responseBody);
        parser.nextToken();
        parser.nextValue();
        Assert.isFalse(parser.getBooleanValue(), CURRENCY_UPDATE_ERROR);
    }
}