@isTest
private class CaseRequestActionsTest {
    
    @isTest
    static void shouldCreateCaseHistoryWithSLAUnchecked() {
        Case_Request__c testCase = createCaseRequest();
        
        Test.startTest();
        
        Case_Request__c caseRequest = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        caseRequest.SLA_Deadline__c = Datetime.now().addDays(-2);
        caseRequest.Status__c = 'Closed';
        caseRequest.Resolution_Notes__c = 'Notes';
        
        update caseRequest;
        
        Case_History__c caseHistory = [SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = :caseRequest.Id LIMIT 1];
        
        Test.stopTest();
        
        System.debug(caseHistory);
        System.assertEquals(false, caseHistory.SLA_Met__c, 'SLA should not be met.');
    }
    
    @isTest
    static void shouldCreateCaseHistoryWithSLAChecked() {
        Case_Request__c testCase = createCaseRequest();
        
        Test.startTest();
        
        Case_Request__c caseRequest = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        caseRequest.SLA_Deadline__c = Datetime.now().addHours(2);
        caseRequest.Status__c = 'Closed';
        caseRequest.Resolution_Notes__c = 'Notes';
        
        update caseRequest;
        
        Case_History__c caseHistory = [SELECT Id, SLA_Met__c FROM Case_History__c WHERE Case_Request__c = :caseRequest.Id LIMIT 1];
        
        Test.stopTest();
        
        System.debug(caseHistory);
        System.assertEquals(true, caseHistory.SLA_Met__c, 'SLA should be met.');
    }
    
    @isTest
    static void shouldNotDuplicateHistory() {
        Case_Request__c testCase = createCaseRequest();
        
        Test.startTest();
        
        Case_Request__c caseRequest = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        caseRequest.Status__c = 'Closed';
        caseRequest.Resolution_Notes__c = 'Notes';
        
        update caseRequest;
        
        List<Case_History__c> caseHistory1 = [SELECT Id, Case_Request__c FROM Case_History__c WHERE Case_Request__c = :caseRequest.Id];
        
        caseRequest = [SELECT Id, Status__c FROM Case_Request__c LIMIT 1];
        caseRequest.Status__c = 'Closed';
        caseRequest.Resolution_Notes__c = 'New Notes';
        
        update caseRequest;
        
        List<Case_History__c> caseHistory2 = [SELECT Id, Case_Request__c FROM Case_History__c WHERE Case_Request__c = :caseRequest.Id];
        
        Test.stopTest();
        
        System.assertEquals(1, caseHistory1.size(), 'History should not be duplicated.');
        System.assertEquals(1, caseHistory2.size(), 'History should not be duplicated.');
        System.assertEquals(caseHistory1.get(0).Case_Request__c, caseHistory2.get(0).Case_Request__c, 'History should not be duplicated.');
        System.assertEquals('New Notes', caseRequest.Resolution_Notes__c, 'History should not be duplicated.');
    }
    
    private static Case_Request__c createCaseRequest() {
        Case_Request__c testCase = new Case_Request__c();
        testCase.Subject__c = 'Test Case';
        testCase.Description__c = 'Test Case Description';
        testCase.Priority__c = 'Low';
        testCase.Support_Level__c = 'Basic';
        testCase.RecordTypeId = Schema.SObjectType.Case_Request__c.getRecordTypeInfosByName().get('Premium Support').getRecordTypeId();
        
        insert testCase;
        
        return testCase;
    }
}