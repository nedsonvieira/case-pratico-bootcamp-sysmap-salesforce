public with sharing class CaseRequestActions {
    
    public static void createCaseHistory(List<Case_Request__c> updatedCases, Map<Id, Case_Request__c> oldCasesMap) {
        
        List<Case_History__c> lstCaseHistory = new List<Case_History__c>();
        
        for (Case_Request__c caseRequest : updatedCases) {
            Case_Request__c oldCase = oldCasesMap.get(caseRequest.Id);
            
            if (caseRequest.Status__c == 'Closed' && oldCase.Status__c != 'Closed') {
                Boolean slaMet = caseRequest.SLA_Deadline__c >= caseRequest.LastModifiedDate;
                
                Case_History__c caseHistory = new Case_History__c();
                caseHistory.Case_Request__c = caseRequest.Id;
                caseHistory.Time_Closed__c = caseRequest.LastModifiedDate;
                caseHistory.SLA_Met__c = slaMet;
                
                lstCaseHistory.add(caseHistory);
            }
        }
        
        if (!lstCaseHistory.isEmpty()) {
            insert as user lstCaseHistory;
        }
    }
}