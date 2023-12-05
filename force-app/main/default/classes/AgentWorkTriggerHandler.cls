/*
    @created by       : balajip
    @created on       : 01/19/2021
    @Purpose          : AgentWork trigger handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description   Jira No.       Tag
 ****************************************************************************************************
 */

public class AgentWorkTriggerHandler extends TriggerHandler {

    public void updateRaiseHand(Map<Id, AgentWork> newMap, Map<Id, AgentWork> oldMap) {
        Set<Id> setRaiseHandId = new Set<Id>();
        for(AgentWork agentWorkNew : newMap.values()){
            if(Raise_Hand__c.SobjectType == agentWorkNew.WorkItemId.getSobjectType()){
                System.debug('this is a raise hand request');
                if('Opened'.equals(agentWorkNew.Status) && agentWorkNew.Status != oldMap.get(agentWorkNew.Id).Status){
                    setRaiseHandId.add(agentWorkNew.WorkItemId);
                }
            }
        }
        if(!setRaiseHandId.isEmpty()){
            RaiseHandService.onAssignment(setRaiseHandId);
        }
    }
}