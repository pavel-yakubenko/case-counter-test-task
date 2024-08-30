@isTest
private class CasesCountServiceTest {

    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 2; i++) {
            accounts.add(
                new Account(
                    Name = 'Test Account '+i
                )
            );
        }
        insert accounts;
    }

    static List<Case> getCases (List<Account> accountRecords, Integer casesCount, String status) {
        List<Case> caseRecords = new List<Case>();
        for (Account accountRecord : accountRecords) {
            for (Integer i = 0; i < casesCount; i++) {
                caseRecords.add(
                    new Case(AccountId = accountRecord.Id, Status = status)
                );
            }
        }
        return caseRecords;
    }

    @isTest
    static void countCasesOnInsert() {
        Integer newCasesCount = 100;
        Integer closedCasesCount = 50;
        List<Account> accountRecords = [SELECT Id FROM Account];
        List<Case> caseRecords = new List<Case>();
        caseRecords.addAll(getCases(accountRecords, newCasesCount, 'New'));
        caseRecords.addAll(getCases(accountRecords, closedCasesCount, 'Closed'));
        
        Test.startTest();
        insert caseRecords;
        Test.stopTest();

        List<Account> accountRecordsUpdated = [
            SELECT Id, TotalOpenCases__c, TotalClosedCases__c 
            FROM Account
            WHERE Id IN :accountRecords
            ORDER BY Id Desc
        ];
        for (Account acc : accountRecordsUpdated) {
            System.AssertEquals(newCasesCount, acc.TotalOpenCases__c, 'Incorrect total open cases count');
            System.AssertEquals(closedCasesCount, acc.TotalClosedCases__c, 'Incorrect total closed cases count');
        }
    }

    @isTest
    static void countCasesOnUpdate() {
        Integer newCasesCount = 1000;
        Integer closedCasesCount = 50;
        List<Account> accountRecords = [SELECT Id FROM Account];
        List<Case> caseRecords = new List<Case>();
        caseRecords.addAll(getCases(accountRecords, newCasesCount, 'New'));
        caseRecords.addAll(getCases(accountRecords, closedCasesCount, 'Closed'));
        insert caseRecords;
        
        for (Case caseRecord : caseRecords) {
            caseRecord.Status = 'Closed';
        }
        
        Test.startTest();
        update caseRecords;
        Test.stopTest();

        List<Account> accountRecordsUpdated = [
            SELECT Id, TotalOpenCases__c, TotalClosedCases__c 
            FROM Account
            WHERE Id IN :accountRecords
            ORDER BY Id Desc
        ];
        for (Account acc : accountRecordsUpdated) {
            System.AssertEquals(0, acc.TotalOpenCases__c, 'Incorrect total open cases count');
            System.AssertEquals(
                newCasesCount + closedCasesCount, 
                acc.TotalClosedCases__c, 
                'Incorrect total closed cases count'
            );
        }
    }

    @isTest
    static void countCasesOnDelete() {
        Integer newCasesCount = 100;
        Integer closedCasesCount = 50;
        List<Account> accountRecords = [SELECT Id FROM Account];
        List<Case> caseRecords = new List<Case>();
        caseRecords.addAll(getCases(accountRecords, newCasesCount, 'New'));
        caseRecords.addAll(getCases(accountRecords, closedCasesCount, 'Closed'));
        insert caseRecords;
        
        
        List<Case> caseRecordsToDelete = new List<Case>();
        for (Case caseRecord : caseRecords) {
            if (caseRecord.Status == 'Closed') {
                caseRecordsToDelete.add(caseRecord);
            }
        }
        
        Test.startTest();
        delete caseRecordsToDelete;
        Test.stopTest();

        List<Account> accountRecordsUpdated = [
            SELECT Id, TotalOpenCases__c, TotalClosedCases__c 
            FROM Account
            WHERE Id IN :accountRecords
            ORDER BY Id Desc
        ];
        for (Account acc : accountRecordsUpdated) {
            System.AssertEquals(newCasesCount, acc.TotalOpenCases__c, 'Incorrect total open cases count');
            System.AssertEquals(0, acc.TotalClosedCases__c, 'Incorrect total closed cases count');
        }
    }

    @isTest
    static void countCasesOnUndelete() {
        Integer newCasesCount = 100;
        Integer closedCasesCount = 50;
        List<Account> accountRecords = [SELECT Id FROM Account];
        List<Case> caseRecords = new List<Case>();
        caseRecords.addAll(getCases(accountRecords, newCasesCount, 'New'));
        caseRecords.addAll(getCases(accountRecords, closedCasesCount, 'Closed'));
        insert caseRecords;
        delete caseRecords;
        
        List<Case> casesToRestore = [SELECT Id FROM Case WHERE IsDeleted = true ALL ROWS];

        Test.startTest();
        undelete casesToRestore;
        Test.stopTest();

        List<Account> accountRecordsUpdated = [
            SELECT Id, TotalOpenCases__c, TotalClosedCases__c 
            FROM Account
            WHERE Id IN :accountRecords
            ORDER BY Id Desc
        ];
        for (Account acc : accountRecordsUpdated) {
            System.AssertEquals(newCasesCount, acc.TotalOpenCases__c, 'Incorrect total open cases count');
            System.AssertEquals(closedCasesCount, acc.TotalClosedCases__c, 'Incorrect total closed cases count');
        }
    }

    @isTest
    static void countCasesOnAccountChange() {
        Integer newCasesCount = 100;
        Integer closedCasesCount = 50;
        List<Account> accountRecords = [SELECT Id FROM Account];
        List<Case> caseRecords = new List<Case>();
        caseRecords.addAll(getCases(accountRecords, newCasesCount, 'New'));
        caseRecords.addAll(getCases(accountRecords, closedCasesCount, 'Closed'));
        insert caseRecords;
        
        Id accountId = accountRecords[0].Id;
        
        List<Case> caseRecordsToDelete = new List<Case>();
        for (Case caseRecord : caseRecords) {
            caseRecord.AccountId = accountId;
        }
        
        Test.startTest();
        update caseRecords;
        Test.stopTest();

        List<Account> accountRecordsUpdated = [
            SELECT Id, TotalOpenCases__c, TotalClosedCases__c 
            FROM Account
            WHERE Id = :accountRecords
            LIMIT 1
        ];
        for (Account acc : accountRecordsUpdated) {
            if (acc.Id == accountId) {
                System.AssertEquals(
                    newCasesCount*accountRecords.size(), 
                    accountRecordsUpdated[0].TotalOpenCases__c, 
                    'Incorrect total open cases count for new account'
                );
                System.AssertEquals(
                    closedCasesCount*accountRecords.size(), 
                    accountRecordsUpdated[0].TotalClosedCases__c, 
                    'Incorrect total closed cases count for new account'
                );
            } else {
                System.AssertEquals(
                    0, 
                    accountRecordsUpdated[0].TotalOpenCases__c, 
                    'Incorrect total open cases count for old account'
                );
                System.AssertEquals(
                    0,
                    accountRecordsUpdated[0].TotalClosedCases__c, 
                    'Incorrect total closed cases count for old account'
                );
            }
        }
    }
}