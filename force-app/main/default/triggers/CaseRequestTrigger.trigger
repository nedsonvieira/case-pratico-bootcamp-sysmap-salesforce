trigger CaseRequestTrigger on Case_Request__c (after update) {
    
    CaseRequestTriggerHandler handler =
        new CaseRequestTriggerHandler(trigger.new, trigger.oldMap);
    
    switch on trigger.operationType {
        when AFTER_UPDATE{
            handler.onAfterUpdate();
        }
    }
}