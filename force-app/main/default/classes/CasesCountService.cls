public inherited sharing class CasesCountService {
    public static void count(List<Account> accounts) {
        // get accounts with related cases
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        List<Account> accountsWithCases = [
            SELECT 
                Id,
                (SELECT Id, IsClosed FROM Cases)
            FROM Account
            WHERE Id IN :accountIds
        ];
        // calc total cases count for each account
        Map<Id,Account> accountsWithCasesById = new Map<Id,Account>(accountsWithCases);
        for (Account record : accounts) {
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