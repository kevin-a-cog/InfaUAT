/*
Class:          CaseTeamTriggerHandler
@Author:        Deva
@Created Date:  30-Jun-21
@Description:   Helper class for caseteam Triggers
*/
public class CaseTeamTriggerHandler { 
    //Method will handle after update event from trigger
    public static void handleAfterUpdate(List<Case_Team__c> listTriggerNew,Map<Id,Case_Team__c> mapTrigggerOld){
        Map<Id,Case_Team__c> caseTeamMap=  new Map<Id,Case_Team__c>();
        for(Case_Team__c ctnew:listTriggerNew){
            if(mapTrigggerOld!=null && mapTrigggerOld.size()>0 && mapTrigggerOld.containsKey(ctnew.Id)){
                Case_Team__c ctold = mapTrigggerOld.get(ctnew.Id);
                if(ctnew.Role__c!=null){
                    if(ctnew.Role__c != ctold.Role__c && ctnew.Role__c.equals('CoOwner') && ctold.Role__c.equals('Owner')){
                        caseTeamMap.put(ctnew.Id,ctnew);
                    }}
            }
        }
        if(caseTeamMap.size()>0){
            CaseTeamTriggerHelper.trackOnCaseTeamRoleChange(caseTeamMap); 
        }
    }
}