/*
 * Name			:	EngagementUnitConsumptionTriggerHandler
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Trigger handler for Engagement Unit Consumption trigger.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
public without sharing class EngagementUnitConsumptionTriggerHandler {

    /*
	 Method Name : afterInsert
	 Description : This method gets executed on After Insert.
	 Parameters	 : List, called from afterInsert, lstNewRecords New records.
	 Return Type : None
	 */
    public static void afterInsert(List<Engagement_Unit_Consumption__c> lstNewRecords) {

		//We update Consumed Units.
		EngagementUnitConsumptionTriggerHelper.updateConsumedUnits(lstNewRecords);
	}

    /*
	 Method Name : afterUpdate
	 Description : This method gets executed on After Update.
	 Parameters	 : List, called from afterUpdate, lstNewRecords New records.
	 			   Map, called from afterUpdate, mapOldRecords Old records.
	 Return Type : None
	 */
    public static void afterUpdate(List<Engagement_Unit_Consumption__c> lstNewRecords, Map<Id, Engagement_Unit_Consumption__c> mapOldRecords) {

		//We block changes to specific fields.
		EngagementUnitConsumptionTriggerHelper.allowChanges(lstNewRecords, mapOldRecords);

		//We return completed / cancelled units.
		EngagementUnitConsumptionTriggerHelper.returnUnits(lstNewRecords, mapOldRecords);
	}
}