/*
* Name			:	CSMPlanTeamTriggerHandler
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Handler class which implements interface process methods for Trigger events on Plan Team Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
Karthi G            08/07/2023    AR-3092           Handled scenario where Primary CSM is
                                                    not updated correctly                        T1
*/
public class CSMPlanTeamTriggerHandler extends TriggerHandler {
    private CSMPlanTeamTriggerHelper planTeamTriggerHelper = new CSMPlanTeamTriggerHelper();

    //Added constructor T1
    public CSMPlanTeamTriggerHandler(Boolean recursionCheckNeeded){
        super(recursionCheckNeeded);
    }

    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        if(CSMPlanTeamTriggerCheckRecursive.runBeforeInsertOnce()){
            //Call this below line first and call validation after that
            planTeamTriggerHelper.processBeforeInsert((List<Plan_Team__c>) newList);  
        }
    }
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        //if(CSMPlanTeamTriggerCheckRecursive.runAfterInsertOnce()){  //T1 - commented to allow recursion 
            planTeamTriggerHelper.processafterInsert((List<Plan_Team__c>) newList);
       // }
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in Before insert context
    */
    public override void beforeUpdate() {   
        if(CSMPlanTeamTriggerCheckRecursive.runBeforeUpdateOnce()){
            //Call this below line first and call validation after that
            planTeamTriggerHelper.processBeforeUpdate((List<Plan_Team__c>) newList,(Map<Id,Plan_Team__c>) oldMap);
        }
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after insert context
    */
    public override void afterUpdate() {  
        //if(CSMPlanTeamTriggerCheckRecursive.runAfterUpdateOnce()){  //T1 - commented to allow recursion
            planTeamTriggerHelper.processafterUpdate((List<Plan_Team__c>) newList,(Map<Id,Plan_Team__c>) oldMap);
        //}   
    }
     /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {    
    }    
    public override void beforeDelete() {  
        planTeamTriggerHelper.processBeforeDelete((List<Plan_Team__c>) oldList);
    } 
}