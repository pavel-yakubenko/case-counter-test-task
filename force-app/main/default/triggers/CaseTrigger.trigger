trigger CaseTrigger on Case (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CasesTriggerHandler.onAfterInsert();
        } else if (Trigger.isUpdate) {
            CasesTriggerHandler.onAfterUpdate();
        } else if (Trigger.isDelete) {
            CasesTriggerHandler.onAfterDelete();
        } else if (Trigger.isUndelete) {
            CasesTriggerHandler.onAfterUndelete();
        }
    }    
}