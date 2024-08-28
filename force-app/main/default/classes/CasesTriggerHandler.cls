public inherited sharing class CasesTriggerHandler {
    public static void onAfterInsert() {
        updateCasesCountOnAccounts();
    }

    public static void onAfterUpdate() {
        updateCasesCountOnAccounts();
    }

    public static void onAfterDelete() {
        updateCasesCountOnAccounts();
    }

    private static void updateCasesCountOnAccounts() {
        List<Account> accounts = getAccounts();
        if (!accounts.isEmpty()) {
            update accounts;
        }
    } 

    private static List<Account> getAccounts() {
        if (Trigger.isInsert) {
            return getAccounts(Trigger.new);
        } else if (Trigger.isDelete) {
            return getAccounts(Trigger.old);
        } else if (Trigger.isUpdate) {
            return getAccounts(Trigger.new, Trigger.oldMap);
        }
        return new List<Account>();
    }

    private static List<Account> getAccounts(List<Case> records) {
        Set<Account> accounts = new Set<Account>();
        for (Case record : records) {
            if (record.AccountId == null) {
                continue;
            }
            accounts.add(new Account(Id = record.AccountId));
        }
        return new List<Account>(accounts);
    }

    private static List<Account> getAccounts(List<Case> records, Map<Id, SObject> oldRecordsMap) {
        Set<Account> accounts = new Set<Account>();
        for (Case record : records) {
            Case oldRecord = (Case)oldRecordsMap.get(record.Id);
            if (record.AccountId != oldRecord.AccountId) {
                if (record.AccountId != null) {
                    accounts.add(new Account(Id = record.AccountId));
                }
                if (oldRecord.AccountId != null) {
                    accounts.add(new Account(Id = oldRecord.AccountId));
                }
            } else if (record.isClosed != oldRecord.isClosed) {
                if (record.AccountId != null) {
                    accounts.add(new Account(Id = record.AccountId));
                }
            }
        }
        return new List<Account>(accounts);
    }
}