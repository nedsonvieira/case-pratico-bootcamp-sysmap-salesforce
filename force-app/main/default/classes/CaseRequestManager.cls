@RestResource(urlMapping='/Case_Request__c/*')
global with sharing class CaseRequestManager {
    
    @HttpGet
    global static void getCaseRequest() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        if (request == null || String.isBlank(request.requestURI)) {
            
            response.responseBody = Blob.valueOf(formatErrorResponse('Bad Request', 'Invalid request URI.'));
            response.statusCode = 400;
            return;
        }
        
        String caseRequestId = extractCaseRequestId(request.requestURI);
        
        if (String.isBlank(caseRequestId)) {
            
            response.responseBody = Blob.valueOf(formatErrorResponse('Bad Request', 'Case request id can\'t be null.'));
            response.statusCode = 400;
            return;
        }
        
        try {
            Case_Request__c result = findCaseRequest(caseRequestId);
            
            response.responseBody = Blob.valueOf(formatSuccessResponse(result));
            response.statusCode = 200;
            
        } catch (Exception e) {
            
            response.responseBody = Blob.valueOf(formatErrorResponse('Not Found', 'Case Request ID not found or invalid.'));
            response.statusCode = 404;
        }
    }
    
    private static String extractCaseRequestId(String requestURI) {
        return requestURI.substring(requestURI.lastIndexOf('/') + 1);
    }
    
    private static Case_Request__c findCaseRequest(String caseRequestId) {
        return [SELECT CreatedDate, Status__c, SLA_Deadline__c,  
            (SELECT SLA_Met__c, Time_Closed__c  
                FROM Case_Histories__r  
                ORDER BY CreatedDate DESC LIMIT 1)  
        FROM Case_Request__c 
        WHERE Id = :caseRequestId WITH SECURITY_ENFORCED];
    }
    
    private static String formatSuccessResponse(Case_Request__c result) {
        
        ResponseDto dto = new ResponseDto(
            result.createdDate,
        result.SLA_Deadline__c,
        result.Status__c,
        result.Case_Histories__r.isEmpty() ? null : result.Case_Histories__r[0].SLA_Met__c,
        result.Case_Histories__r.isEmpty() ? null : result.Case_Histories__r[0].Time_Closed__c
            );
        
        return JSON.serializePretty(dto);
    }
    
    private static String formatErrorResponse(String errorMessage, String message) {
        return JSON.serializePretty(new Map<String, Object>{
            'error' => errorMessage,
            'message' => message
        });
    }
}