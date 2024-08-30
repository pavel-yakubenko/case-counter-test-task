public inherited sharing class CasesCountService {
    public static void count(List<Account> accounts) {
        // get accounts with cases calculated
        Map<Id,Account> accountsWithCasesById = getAccountsWithCasesMap(accounts);
        // update records
        for (Account accountRecord : accounts) {
            Account accountWithCases = accountsWithCasesById.get(accountRecord.Id);
            if (accountWithCases == null) {
                accountRecord.TotalOpenCases__c = 0;
                accountRecord.TotalClosedCases__c = 0;
            } else {
                accountRecord.TotalOpenCases__c = accountWithCases.TotalOpenCases__c;
                accountRecord.TotalClosedCases__c = accountWithCases.TotalClosedCases__c;
            }
        }
    }

    private static Map<Id, Account> getAccountsWithCasesMap(List<Account> accounts) {
        // get all cases related to accounts
        Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
        List<Case> cases = [
            SELECT Id, AccountId, IsClosed
            FROM Case
            WHERE AccountId IN :accountIds
        ];
        // calc total cases count for each account
        Map<Id,Account> accountsWithCasesById = new Map<Id,Account>();
        for (Case caseRecord : cases) {
            Account accountRecord = accountsWithCasesById.get(caseRecord.AccountId);
            if (accountRecord == null) {
                accountRecord = new Account(
                    Id = caseRecord.AccountId,
                    TotalOpenCases__c = 0,
                    TotalClosedCases__c = 0
                );
                accountsWithCasesById.put(accountRecord.Id, accountRecord);
            }
            if (caseRecord.IsClosed) {
                accountRecord.TotalClosedCases__c++;
            } else {
                accountRecord.TotalOpenCases__c++;
            }
        }
        return accountsWithCasesById;
    }
}