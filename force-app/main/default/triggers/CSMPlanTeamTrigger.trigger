/*
 * Name			:	CSM_PlanTeamTrigger
 * Author		:	Deva M
 * Created Date	: 	08/07/2021
 * Description	:	Trigger on Plan Team Object

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					08/07/2021		N/A				Initial version.			N/A
 Karthi G            08/07/2023    AR-3092           Handled scenario where Primary CSM is
                                                    not updated correctly                        T1
 */
trigger CSMPlanTeamTrigger on Plan_Team__c (after delete, after insert, after update, before delete, before insert, before update) {
 
    //new CSMPlanTeamTriggerHandler().process(); 
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Plan_Team__c)){
        new CSMPlanTeamTriggerHandler(false).process(); // T1
    }
}