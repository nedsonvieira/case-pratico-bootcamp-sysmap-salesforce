@isTest
private class CaseRequestManagerTest {
    
    @isTest
    static void testGetCaseRequest() {
        
        Case_Request__c testCase = createCaseRequest();
        String caseId = testCase.Id;
        RestRequest request = new RestRequest();
        
        Test.startTest();
        
        request.requestUri =
            'https://orgfarm-c3dcedbc2f-dev-ed.develop.my.salesforce.com/services/apexrest/Case_Request__c/'
            + caseId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        String response = CaseRequestManager.getCaseRequest();
        
        Test.stopTest();
        
        System.assertEquals(true, response != null, 'response should not be null');
        System.assertEquals(true, response.contains('"status" : "New"'), 'response should contain "status"');
        System.assertEquals(true, response.contains('"slaMet" : null'), 'response should contain "slaMet"');
    }
    
    @isTest
    static void testRequestNull() {
        
        Test.startTest();
        
        RestRequest request = null;
        
        String response = CaseRequestManager.getCaseRequest();
        
        Test.stopTest();
        
        System.AssertEquals(true, response.contains('"status" : 400'), 'response should contain status 400');
        System.assertEquals(true, response.contains('"error" : "Bad Request"'), 'response should contain error bad request');
        System.AssertEquals(true, response.contains('"message" : "Invalid request URI."'), 'response should contain message invalid request URI.');
    }
    
    @isTest
    static void testRequestWithIdNull() {
        
        RestRequest request = new RestRequest();
        
        Test.startTest();
        
        request.requestUri =
            'https://orgfarm-c3dcedbc2f-dev-ed.develop.my.salesforce.com/services/apexrest/Case_Request__c/';
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        String response = CaseRequestManager.getCaseRequest();
        
        Test.stopTest();
        
        System.debug(response);
        
        System.AssertEquals(true, response.contains('"status" : 400'), 'response should contain status 400');
        System.assertEquals(true, response.contains('"error" : "Bad Request"'), 'response should contain error bad request');
        System.AssertEquals(true, response.contains('"message" : "Case request id can\'t be null."'), 'response should contain message id can\'t be null');
    }
    
    @isTest
    static void testRequestWithIdNotFound() {
        
        RestRequest request = new RestRequest();
        String caseId = '12345';
        
        Test.startTest();
        
        request.requestUri =
            'https://orgfarm-c3dcedbc2f-dev-ed.develop.my.salesforce.com/services/apexrest/Case_Request__c/'
            + caseId;
        
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        String response = CaseRequestManager.getCaseRequest();
        
        Test.stopTest();
        
        System.debug(response);
        
        System.AssertEquals(true, response.contains('"status" : 404'), 'response should contain status 404');
        System.assertEquals(true, response.contains('"error" : "Not Found"'), 'response should contain error not found');
        System.AssertEquals(true, response.contains('"message" : "Case Request ID not found or invalid."'), 'response should contain message id not found');
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