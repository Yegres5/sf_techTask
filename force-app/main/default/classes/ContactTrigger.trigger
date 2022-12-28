/**
 * Created by evgeny on 26.12.2022.
 */

trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    List<Contact> newContacts = (List<Contact>)Trigger.new;
    List<Contact> oldContacts = (List<Contact>)Trigger.old;

    if (Trigger.isAfter){
        if (Trigger.isUpdate){
            ContactTriggerHandler.onAfterUpdate(newContacts);
        }

        if (Trigger.isInsert){
            ContactTriggerHandler.onAfterInsert(newContacts);
        }

        if (Trigger.isDelete){
            ContactTriggerHandler.onAfterDelete(oldContacts);
        }
    }
}