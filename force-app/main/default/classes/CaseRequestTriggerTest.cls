@isTest
private class CaseRequestTriggerTest {
    
    @isTest
    static void shouldCreateCaseHistoryWhenCaseRequestClosed() {
        Case_Request__c caseRequest = new Case_Request__c();
        caseRequest.Subject__c = 'Test Case';
        caseRequest.Description__c = 'Testing case closed';
        caseRequest.Priority__c = 'Medium';
        
        insert caseRequest;
        
        Test.startTest();
        
        Case_Request__c caseToUpdate = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        caseToUpdate.Status__c = 'Closed';
        caseToUpdate.Resolution_Notes__c = 'Notes';
        
        update caseToUpdate;
        
        Case_History__c caseHistory = [SELECT Id FROM Case_History__c WHERE Case_Request__c = :caseToUpdate.Id LIMIT 1];
        Test.stopTest();
        
        System.assertNotEquals(null, caseHistory, 'Case history should be created.');
    }
    
    @isTest
    static void shouldNotCreateCaseHistoryWhenCaseRequestIsNotClosed() {
        
        List<Case_Request__c> caseRequests = new List<Case_Request__c>
        {
            new Case_Request__c(Subject__c = 'Test Case 1', Description__c = 'Testing case closed 1', Priority__c = 'Medium'),
            new Case_Request__c(Subject__c = 'Test Case 2', Description__c = 'Testing case closed 2', Priority__c = 'Medium'),
            new Case_Request__c(Subject__c = 'Test Case 3', Description__c = 'Testing case closed 3', Priority__c = 'Medium')
        };
        
        
        insert caseRequests;
        
        List<Case_Request__c> casesToUpdate = [SELECT Id, Status__c FROM Case_Request__c LIMIT 3];
        
        Test.startTest();
        casesToUpdate.get(0).Status__c = 'New';
        casesToUpdate.get(1).Status__c = 'In Progress';
        casesToUpdate.get(2).Status__c = 'Escalated';
        
        update casesToUpdate;
        
        List<Case_History__c> caseHistories = [SELECT Id FROM Case_History__c LIMIT 1];
        
        Test.stopTest();
        
        System.assertEquals(true, caseHistories.isEmpty(), 'Case history should not be created.');
    }
}