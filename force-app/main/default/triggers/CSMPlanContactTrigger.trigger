/*
 * Name			:	CSM_PlanContactTrigger
 * Author		:	Deva M
 * Created Date	: 	08/07/2021
 * Description	:	Trigger on Plan Contact Object

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					08/07/2021		N/A				Initial version.			N/A
 */
trigger CSMPlanContactTrigger on Plan_Contact__c (after delete, after insert, after update, before delete, before insert, before update ,after undelete) {
    //new CSMPlanContactTriggerHandler().process();
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Plan_Contact__c)){
        new CSMPlanContactTriggerHandler().process();
    }
}