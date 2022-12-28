/**
 * Created by evgeny on 26.12.2022.
 */

public with sharing class ContactTriggerHandler {
    public static void onAfterInsert(List<Contact> contacts) {
        SalaryChangeService.recalculateSalaryChange(contacts);
    }

    public static void onAfterUpdate(List<Contact> contacts) {
        SalaryChangeService.recalculateSalaryChange(contacts);
    }

    public static void onAfterDelete(List<Contact> contacts) {
        SalaryChangeService.recalculateSalaryChange(contacts);
    }
}