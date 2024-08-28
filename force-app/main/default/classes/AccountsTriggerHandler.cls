public inherited sharing class AccountsTriggerHandler {
    public static void onBeforeUpdate() {
        countCases();
    }

    private static void countCases() {
        Set<Id> accountIds = Trigger.newMap.keySet();
        List<Account> accountsWithCases = [
            SELECT 
                Id,
                (SELECT Id, IsClosed FROM Cases)
            FROM Account
            WHERE Id IN :accountIds
        ];
        Map<Id,Account> accountsWithCasesById = new Map<Id,Account>(accountsWithCases);
        for (Account record : (List<Account>)Trigger.new) {
            Account accountWithCases = accountsWithCasesById.get(record.Id);
            Decimal totalOpenCases = 0;
            Decimal totalClosedCases = 0;
            for (Case caseRecord : accountWithCases.Cases) {
                if (caseRecord.isClosed) {
                    totalClosedCases++;
                } else {
                    totalOpenCases++;
                }
            }
            record.TotalOpenCases__c = totalOpenCases;
            record.TotalClosedCases__c = totalClosedCases;
        }
    }
}