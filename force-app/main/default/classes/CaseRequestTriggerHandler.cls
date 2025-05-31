public with sharing class CaseRequestTriggerHandler {
    
    private List<Case_Request__c> updatedCases;
    private Map<Id, Case_Request__c> oldCasesMap;
    
    public CaseRequestTriggerHandler(List<Case_Request__c> updatedCases, Map<Id, Case_Request__c> oldCasesMap) {
        this.updatedCases = updatedCases;
        this.oldCasesMap = oldCasesMap;
    }
    
    public void onAfterUpdate() {
        CaseRequestActions.createCaseHistory(updatedCases, oldCasesMap);
    }
}