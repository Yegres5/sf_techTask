/**
 * Created by evgeny on 26.12.2022.
 */
@IsTest
private class SalaryChangeServiceTest {

    @TestSetup
    private static void setup() {
        Account acc = new Account(
                Name='TestAcc'
        );
        insert acc;
    }

    @IsTest
    private static void onAfterInsert_recalculateExpenses() {
        final Decimal SALARY = 100;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Contact cont = new Contact(
                LastName = 'Test',
                Salary__c = SALARY,
                AccountId = acc.Id
        );

        System.Test.startTest();
        insert cont;
        System.Test.stopTest();

        acc = [SELECT SalaryExpenses__c FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Assert.areEqual(SALARY, acc.SalaryExpenses__c);
    }

    @IsTest
    private static void onAfterUpdate_recalculateExpenses() {
        final Decimal SALARY = 100;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Contact cont = new Contact(
                LastName = 'Test',
                Salary__c = SALARY,
                AccountId = acc.Id
        );

        insert cont;
        cont.Salary__c = 2*SALARY;

        System.Test.startTest();
        update cont;
        System.Test.stopTest();

        acc = [SELECT SalaryExpenses__c FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Assert.areEqual(2*SALARY, acc.SalaryExpenses__c);
    }

    @IsTest
    private static void onAfterDelete_recalculateExpenses() {
        final Decimal SALARY = 100;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        List<Contact> contacts = new List<Contact>();

        contacts.add(new Contact(
                LastName = 'Test1',
                Salary__c = SALARY,
                AccountId = acc.Id
        ));

        contacts.add(new Contact(
                LastName = 'Test2',
                Salary__c = SALARY,
                AccountId = acc.Id
        ));

        insert contacts;

        System.Test.startTest();
        delete contacts[0];
        System.Test.stopTest();

        acc = [SELECT SalaryExpenses__c FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Assert.areEqual(SALARY, acc.SalaryExpenses__c);
    }

    @IsTest
    private static void multipleCurrencies() {
        final Decimal SALARY = 100;
        Decimal expectedSalary = 0;
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        List<Contact> contacts = new List<Contact>();
        List<CurrencyType> cTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType];

        for(CurrencyType cType: cTypes){
            System.debug('' + cType.IsoCode + cType.ConversionRate);
            expectedSalary += SALARY / cType.ConversionRate;
            contacts.add(new Contact(
                    LastName = 'Test' + cType.IsoCode,
                    Salary__c = SALARY,
                    AccountId = acc.Id,
                    CurrencyIsoCode = cType.IsoCode
            ));
        }

        System.Test.startTest();
        insert contacts;
        System.Test.stopTest();

        acc = [SELECT SalaryExpenses__c FROM Account WHERE Name = 'TestAcc' LIMIT 1];
        Assert.areEqual(expectedSalary, acc.SalaryExpenses__c);
    }
}