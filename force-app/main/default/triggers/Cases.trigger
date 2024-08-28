trigger Cases on Case (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CasesTriggerHandler.onAfterInsert();
        } else if (Trigger.isUpdate) {
            CasesTriggerHandler.onAfterUpdate();
        } else if (Trigger.isDelete) {
            CasesTriggerHandler.onAfterDelete();
        }
    }    
}