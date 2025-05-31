@RestResource(urlMapping='/Case_Request__c/*')
global with sharing class CaseRequestManager {
    
    @HttpGet
    global static String getCaseRequest() {
        RestRequest request = RestContext.request;
        
        if (request == null || String.isBlank(request.requestURI)) {
            return formatErrorResponse(400, 'Bad Request', 'Invalid request URI.');
        }
        
        String caseRequestId = extractCaseRequestId(request.requestURI);
        
        if (String.isBlank(caseRequestId)) {
            return formatErrorResponse(400, 'Bad Request', 'Case request id can\'t be null.');
        }
        
        try {
            Case_Request__c result = findCaseRequest(caseRequestId);
            
            return formatSuccessResponse(result);
        } catch (Exception e) {
            return formatErrorResponse(404, 'Not Found', 'Case Request ID not found or invalid.');
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
    
    private static String formatErrorResponse(Integer statusCode, String errorMessage, String message) {
        return JSON.serializePretty(new Map<String, Object>{
            'status' => statusCode,
            'error' => errorMessage,
            'message' => message
        });
    }
}