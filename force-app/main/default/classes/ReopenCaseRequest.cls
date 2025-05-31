public with sharing class ReopenCaseRequest {
    
    @AuraEnabled
    public static void reopenCase(String caseId, String status) {
        
        if (status == 'Closed') {
            
            Case_Request__c caseToReopen = [SELECT Id, Status__c from Case_Request__c WHERE Id = :caseId WITH SECURITY_ENFORCED];
            caseToReopen.Status__c = 'In Progress';
            update as user caseToReopen;
            
            // Auto-Launched Flow
            Map<String, Object> flowParams = new Map<String, Object>();
            flowParams.put('caseId', caseId);
            
            Flow.Interview autoFlow = Flow.Interview.createInterview('New_SLA_for_reopened_Case', flowParams);
            autoFlow.start();
            
        } else {
            AuraHandledException ae = new AuraHandledException('This Case Request is not closed. You can only reopen closed cases.');
            ae.setMessage('This Case Request is not closed. You can only reopen closed cases.');
            throw ae;
        }
    }
}