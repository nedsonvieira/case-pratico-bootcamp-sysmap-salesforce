@isTest
private class ReopenCaseRequestTest {
    
    @isTest
    static void testReopenCaseSuccess() {
        
        createCaseRequest();
        
        Case_Request__c testCase = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        
        Test.startTest();
        
        testCase.Status__c = 'Closed';
        testCase.Resolution_Notes__c = 'Notes';
        update testCase;
        
        ReopenCaseRequest.reopenCase(testCase.Id, testCase.Status__c);
        Test.stopTest();
        
        Case_Request__c updatedCase = [SELECT Status__c FROM Case_Request__c WHERE Id = :testCase.Id];
        System.assertEquals('In Progress', updatedCase.Status__c, 'Case should be in progress');
    }
    
    @isTest
    static void testReopenCaseNotClosed() {
        
        createCaseRequest();
        
        Case_Request__c testCase = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        
        try {
            Test.startTest();
            
            testCase.Status__c = 'In Progress';
            update testCase;
            
            ReopenCaseRequest.reopenCase(testCase.Id, testCase.Status__c);
            
            Test.stopTest();
            
        } catch (AuraHandledException e) {
            System.assertEquals('This Case Request is not closed. You can only reopen closed cases.', e.getMessage(), 'The message was not expected.');
        }
    }
    
    private static void createCaseRequest() {
        
        Case_Request__c testCase = new Case_Request__c();
        testCase.Subject__c = 'Test Case';
        testCase.Description__c = 'Test Case Description';
        testCase.Priority__c = 'Low';
        testCase.Support_Level__c = 'Basic';
        testCase.RecordTypeId = Schema.SObjectType.Case_Request__c.getRecordTypeInfosByName().get('Premium Support').getRecordTypeId();
        
        insert testCase;
    }
}