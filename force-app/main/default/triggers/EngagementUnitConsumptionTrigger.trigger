/*
 * Name			:	EngagementUnitConsumptionTrigger
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Trigger for Engagement Unit Consumption object.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
trigger EngagementUnitConsumptionTrigger on Engagement_Unit_Consumption__c(after insert, after update) {

	//We decide the operation.
	if(Trigger.isInsert) {
		EngagementUnitConsumptionTriggerHandler.afterInsert(Trigger.new);
	} else if(Trigger.isUpdate) {
		EngagementUnitConsumptionTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
	}
}