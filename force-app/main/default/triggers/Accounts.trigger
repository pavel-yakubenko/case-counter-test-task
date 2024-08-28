trigger Accounts on Account (before update) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            AccountsTriggerHandler.onBeforeUpdate();
        }
    }
}