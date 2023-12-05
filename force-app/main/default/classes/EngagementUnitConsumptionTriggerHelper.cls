/*
 * Name			:	EngagementUnitConsumptionTriggerHelper
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Trigger helper for Engagement Unit Consumption trigger.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
public without sharing class EngagementUnitConsumptionTriggerHelper {

	//Public variables.
	public static globalApexManager GAM = new globalApexManager();

    /*
	 Method Name : updateConsumedUnits
	 Description : This method updates the consumed units on the EU record.
	 Parameters	 : List, called from updateConsumedUnits, lstRecords EUC records.
	 Return Type : None
	 */
    public static void updateConsumedUnits(List<Engagement_Unit_Consumption__c> lstRecords) {
		List<Engagement_Unit__c> lstRecordsToUpdate = new List<Engagement_Unit__c>();
		Map<Id, Decimal> mapEngagementUnits = new Map<Id, Decimal>();

		//If we received data.
		if(lstRecords != null && !lstRecords.isEmpty()) {

			//We collect the units per EU.
			for(Engagement_Unit_Consumption__c objRecord : lstRecords) {
				if(objRecord.Engagement_Unit__c != null && objRecord.Number_of_Units__c != null) {
					if(mapEngagementUnits.get(objRecord.Engagement_Unit__c) == null) {
						mapEngagementUnits.put(objRecord.Engagement_Unit__c, 0);
					}
					mapEngagementUnits.put(objRecord.Engagement_Unit__c, mapEngagementUnits.get(objRecord.Engagement_Unit__c) + objRecord.Number_of_Units__c);
				}
			}

			//If we have Units to update.
			if(!mapEngagementUnits.isEmpty()) {
				for(Engagement_Unit__c objRecord : [SELECT Id, Consumed_Units__c FROM Engagement_Unit__c WHERE Id IN :mapEngagementUnits.keySet() LIMIT 50000]) {
					objRecord.Consumed_Units__c = objRecord.Consumed_Units__c + mapEngagementUnits.get(objRecord.Id);
					lstRecordsToUpdate.add(objRecord);
				}

				//If we have records to update.
				if(!lstRecordsToUpdate.isEmpty()) {
					try {
						update lstRecordsToUpdate;
					} catch(Exception objException) {
						GAM.CreateLogs('EngagementUnitConsumptionTriggerHelper-->updateConsumedUnits-->Engagement unit DML failure', objException.getMessage());
						throw objException;
					}
				}
			}
		}
	}

    /*
	 Method Name : allowChanges
	 Description : This method blocks changes to specific fields on EUC records.
	 Parameters	 : List, called from afterUpdate, lstNewRecords New records.
	 			   Map, called from afterUpdate, mapOldRecords Old records.
	 Return Type : None
	 */
    public static void allowChanges(List<Engagement_Unit_Consumption__c> lstNewRecords, Map<Id, Engagement_Unit_Consumption__c> mapOldRecords) {
		Map<String, Boolean> mapFieldsAllowedToBeUpdated = new Map<String, Boolean> {
			'Context_Id__c' => false,
			'Customer_Contact__c' => false,
			'Engagement_Unit__c' => false,
			'Initiated_By__c' => false,
			'Initiated_by_User__c' => false,
			'Number_of_Units__c' => false,
			'Status__c' => true,
			'Type__c' => false
		};

		//If we received data.
		if(lstNewRecords != null && !lstNewRecords.isEmpty() && mapOldRecords != null && !mapOldRecords.isEmpty()) {
			for(Engagement_Unit_Consumption__c objRecord : lstNewRecords) {
				for(String strField : mapFieldsAllowedToBeUpdated.keySet()) {
					if(objRecord.get(strField) != mapOldRecords.get(objRecord.Id).get(strField) && !mapFieldsAllowedToBeUpdated.get(strField)) {
						objRecord.addError(strField + ' ' + Label.Field_Cannot_Be_Changed);
					}
				}
			}
		}
	}

    /*
	 Method Name : allowChanges
	 Description : This method blocks changes to specific fields on EUC records.
	 Parameters	 : List, called from afterUpdate, lstNewRecords New records.
	 			   Map, called from afterUpdate, mapOldRecords Old records.
	 Return Type : None
	 */
    public static void returnUnits(List<Engagement_Unit_Consumption__c> lstNewRecords, Map<Id, Engagement_Unit_Consumption__c> mapOldRecords) {
		List<Engagement_Unit__c> lstRecordsToUpdate = new List<Engagement_Unit__c>();
		List<Engagement_Unit_Configuration__mdt> lstCMTRecods = Engagement_Unit_Configuration__mdt.getall().values();
		Map<Id, Decimal> mapUnitsToDecrease = new Map<Id, Decimal>();

		//If we received data.
		if(lstNewRecords != null && !lstNewRecords.isEmpty() && mapOldRecords != null && !mapOldRecords.isEmpty()) {

			//Now we look for changes in the Status field.
			for(Engagement_Unit_Consumption__c objRecord : lstNewRecords) {
				if(objRecord.Engagement_Unit__c != null && objRecord.Number_of_Units__c != null && objRecord.Status__c != mapOldRecords.get(objRecord.Id).Status__c) {

					//Now we look for a match in the Custom Metadata Type.
					for(Engagement_Unit_Configuration__mdt objInnerRecord : lstCMTRecods) {
						if(objInnerRecord.Is_Active__c && objInnerRecord.Return_Units__c && objRecord.Status__c == objInnerRecord.Status__c && objRecord.Type__c == objInnerRecord.Type__c) {
							mapUnitsToDecrease.put(objRecord.Engagement_Unit__c, objRecord.Number_of_Units__c);
						}
					}
				}
			}

			//If we have units to decrease.
			if(!mapUnitsToDecrease.isEmpty()) {
				for(Engagement_Unit__c objRecord : [SELECT Id, Consumed_Units__c FROM Engagement_Unit__c WHERE Id IN :mapUnitsToDecrease.keySet() LIMIT 50000]) {
					objRecord.Consumed_Units__c = objRecord.Consumed_Units__c - mapUnitsToDecrease.get(objRecord.Id);
					lstRecordsToUpdate.add(objRecord);
				}

				//If we have records to update.
				if(!lstRecordsToUpdate.isEmpty()) {
					try {
						update lstRecordsToUpdate;
					} catch(Exception objException) {
						GAM.CreateLogs('EngagementUnitConsumptionTriggerHelper-->returnUnits-->Engagement unit DML failure', objException.getMessage());
						throw objException;
					}
				}
			}
		}
	}
}