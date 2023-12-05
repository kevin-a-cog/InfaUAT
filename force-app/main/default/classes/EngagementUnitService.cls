/*
 * Name			:	EngagementUnitService
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Engagement Unit Service class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
public without sharing class EngagementUnitService {

	//Public variables.
	public static globalApexManager GAM = new globalApexManager();

    /*
	 Method Name : validateEngagementUnits
	 Description : This method validates the Engagement Units.
	 Parameters	 : Object, called from validateEngagementUnits, objRequest Request.
	 Return Type : EngagementUnitServiceWrapper
	 */
    @AuraEnabled(cacheable = false)
    public static EngagementUnitServiceWrapper validateEngagementUnits(EngagementUnitServiceWrapper objRequest) {
		Integer intUnits = 0;
		EngagementUnitServiceWrapper objResponse = new EngagementUnitServiceWrapper();

		//We set the defaults.
		objResponse.boolResult = false;
		objResponse.intUnits = 0;
		objResponse.lstEngagementUnits = new List<Engagement_Unit__c>();
		objResponse.lstEngagementUnitsTypeAll = new List<Engagement_Unit__c>();

		//We query the EU records, based on the provided data.
		if(objRequest != null && objRequest.intUnits != null) {
			for(Engagement_Unit__c objRecord : [SELECT Id, Type__c, Available_Units__c FROM Engagement_Unit__c WHERE Account__c = :objRequest.idAccount AND Start_Date__c <= TODAY AND 
					Expiry_Date__c >= TODAY AND Status__c = 'Approved' AND (Type__c = :objRequest.strType OR Type__c = 'All') AND Available_Units__c>0 ORDER BY Expiry_Date__c ASC LIMIT 50000]) {
				intUnits += Integer.valueOf(objRecord.Available_Units__c);
				if(objRecord.Type__c == 'All') {
					objResponse.lstEngagementUnitsTypeAll.add(objRecord);
				} else {
					objResponse.lstEngagementUnits.add(objRecord);
				}
			}

			//If we have enough units.
			objResponse.intUnits = intUnits;
			if(intUnits >= objRequest.intUnits) {
				objResponse.boolResult = true;
			}
		}
		return objResponse;
    }

    /*
	 Method Name : consumeEngagementUnits
	 Description : This method consumes Engagement Units.
	 Parameters	 : Object, called from consumeEngagementUnits, objRequest Request.
	 Return Type : EngagementUnitServiceWrapper
	 */
    @AuraEnabled(cacheable = false)
    public static EngagementUnitServiceWrapper consumeEngagementUnits(EngagementUnitServiceWrapper objRequest) {
		Integer intUnitsToConsume;
		EngagementUnitServiceWrapper objResponse = new EngagementUnitServiceWrapper();
		EngagementUnitServiceWrapper objConsumptionResponse = new EngagementUnitServiceWrapper();

		//We set the defaults.
		objResponse.boolResult = false;
		objResponse.lstEngagementUnitConsumptions = new List<Engagement_Unit_Consumption__c>();

		//Now we make sure we received data.
		if(objRequest != null) {

			//Now we validate the Engagement units.
			objResponse = validateEngagementUnits(objRequest);
	
			//If we have records, we insert the EUC records.
			if(objResponse.boolResult) {
				intUnitsToConsume = objRequest.intUnits;
				objResponse.lstEngagementUnitConsumptions = new List<Engagement_Unit_Consumption__c>();

				//Now we start consuming the units, preparing the EUC records.
				if(!objResponse.lstEngagementUnits.isEmpty()) {
					for(Engagement_Unit__c objRecord : objResponse.lstEngagementUnits) {
						
						//If we still have units to consume.
						if(intUnitsToConsume > 0) {
							objConsumptionResponse = setEngagementUnitConsumptionRecord(intUnitsToConsume, objRecord, objRequest);
							intUnitsToConsume = objConsumptionResponse.intUnits;
							objResponse.lstEngagementUnitConsumptions.add(objConsumptionResponse.objEngagementUnitConsumption);
						}
					}
				}
				if(intUnitsToConsume > 0 && !objResponse.lstEngagementUnitsTypeAll.isEmpty()) {
					for(Engagement_Unit__c objRecord : objResponse.lstEngagementUnitsTypeAll) {
						
						//If we still have units to consume.
						if(intUnitsToConsume > 0) {
							objConsumptionResponse = setEngagementUnitConsumptionRecord(intUnitsToConsume, objRecord, objRequest);
							intUnitsToConsume = objConsumptionResponse.intUnits;
							objResponse.lstEngagementUnitConsumptions.add(objConsumptionResponse.objEngagementUnitConsumption);
						}
					}
				}

				//Now we insert the records.
				try {
					insert objResponse.lstEngagementUnitConsumptions;
				} catch(Exception objException) {
					GAM.CreateLogs('EngagementUnitService-->consumeEngagementUnits-->Engagement unit DML failure', objException.getMessage());
					throw objException;
				}
			}
		}
		return objResponse;
    }

    /*
	 Method Name : updateEngagementUnitConsumptionStatus
	 Description : This method updates the Engagement Unit Consumption status.
	 Parameters	 : Object, called from updateEngagementUnitConsumptionStatus, objRequest Request.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static void updateEngagementUnitConsumptionStatus(EngagementUnitServiceWrapper objRequest) {
		List<Engagement_Unit_Consumption__c> lstRecordsToUpdate = new List<Engagement_Unit_Consumption__c>();

		//If we received a valid request.
		if(objRequest != null && String.isNotBlank(objRequest.strStatus) && objRequest.lstContextIds != null && !objRequest.lstContextIds.isEmpty()) {
			for(Engagement_Unit_Consumption__c objRecord : [SELECT Id FROM Engagement_Unit_Consumption__c WHERE Context_Id__c IN :objRequest.lstContextIds AND Status__c = 'Consumed' LIMIT 50000]) {
				objRecord.Status__c = objRequest.strStatus;
				lstRecordsToUpdate.add(objRecord);
			}

			//If we have records to update.
			if(!lstRecordsToUpdate.isEmpty()) {
				try {
					update lstRecordsToUpdate;
				} catch(Exception objException) {
					GAM.CreateLogs('EngagementUnitService-->updateEngagementUnitConsumptionStatus-->Engagement unit DML failure', objException.getMessage());
					throw objException;
				}
			}
		}
    }

    /*
	 Method Name : setEngagementUnitConsumptionRecord
	 Description : This method sets the values for new EUC records.
	 Parameters	 : Integer, called from setEngagementUnitConsumptionRecord, intUnitsToConsume Units to consume.
	 			   Object, called from setEngagementUnitConsumptionRecord, objRecord EU record.
	 			   Object, called from setEngagementUnitConsumptionRecord, objRequest Request.
	 Return Type : EngagementUnitServiceWrapper
	 */
    private static EngagementUnitServiceWrapper setEngagementUnitConsumptionRecord(Integer intUnitsToConsume, Engagement_Unit__c objRecord, EngagementUnitServiceWrapper objRequest) {
		Engagement_Unit_Consumption__c objNewRecord = new Engagement_Unit_Consumption__c();
		EngagementUnitServiceWrapper objResponse = new EngagementUnitServiceWrapper();

		//We set the default values.
		objNewRecord.Context_Id__c = objRequest.strContextId;
		objNewRecord.Customer_Contact__c = objRequest.idContact;
		objNewRecord.Engagement_Unit__c = objRecord.Id;
		objNewRecord.Initiated_By__c = 'CSM';
		objNewRecord.Initiated_by_User__c = objRequest.idUser;
		objNewRecord.Status__c = 'Consumed';
		objNewRecord.Type__c = objRequest.strType;

		//We set the conditional values.
		if(objRequest.idContact != null) {
			objNewRecord.Initiated_By__c = 'Customer';
		}

		//We check how many units we can extract from the current record.
		if(objRecord.Available_Units__c >= intUnitsToConsume) {
			objNewRecord.Number_of_Units__c = intUnitsToConsume;
			intUnitsToConsume = 0;
		} else {
			objNewRecord.Number_of_Units__c = objRecord.Available_Units__c;
			intUnitsToConsume -= Integer.valueOf(objRecord.Available_Units__c);
		}
		objResponse.intUnits = intUnitsToConsume;
		objResponse.objEngagementUnitConsumption = objNewRecord;
		return objResponse;
    }
}