/*
 * Name			:	SuccessEngagementUnitService
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2023
 * Description	:	Engagement Unit Service class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2023		N/A				Initial version.			N/A
 */
public without sharing class SuccessEngagementUnitService {

	//Public variables.
	public static globalApexManager GAM = new globalApexManager();

    /*
	 Method Name : validateEngagementUnits
	 Description : This method validates the Engagement Units.
	 Parameters	 : Object, called from validateEngagementUnits, objRequest Request.
	 Return Type : EngagementUnitServiceWrapper
	 */
    @AuraEnabled(cacheable = true)
    public static EngagementUnitServiceWrapper validateEngagementUnits(EngagementUnitServiceWrapper objRequest) {
		Decimal decTotal;
		EngagementUnitServiceWrapper objResult = new EngagementUnitServiceWrapper();

		//We set the defaults.
		objResult.boolResult = false;

		//If we received data.
		if(objRequest != null) {

			//If is internal user, we return TRUE directly.
			if(objRequest.boolIsInternalUser != null && objRequest.boolIsInternalUser) {
				objResult.boolResult = true;
			} else {

				//We look for EU records.
				for(List<AggregateResult> lstAggregatedResult : [SELECT SUM(Entitled_Units__c) entitled, SUM(Consumed_Units__c) consumed 
																	FROM Engagement_Unit__c WHERE (Type__c = 'Success' OR Type__c = 'All') 
																	AND Account__c = :objRequest.idAccount AND Status__c = 'Approved' 
																	AND Start_Date__c <= TODAY AND Expiry_Date__c >= TODAY]) {
					for(AggregateResult objRecord : lstAggregatedResult) {
						if(objRecord.get('entitled') != null && objRecord.get('consumed') != null) {
							decTotal = ((Decimal) objRecord.get('entitled')) - ((Decimal) objRecord.get('consumed'));
							if(decTotal >= objRequest.intUnits) {
								objResult.boolResult = true;
							}
						}
					}
				}
			}
		}
		return objResult;
    }

    /*
	 Method Name : consumeEngagementUnits
	 Description : This method consumes Engagement Units.
	 Parameters	 : Object, called from consumeEngagementUnits, objRequest Request.
	 Return Type : EngagementUnitServiceWrapper
	 */
    @AuraEnabled(cacheable = false)
    public static EngagementUnitServiceWrapper consumeEngagementUnits(EngagementUnitServiceWrapper objRequest) {
		Engagement_Unit__c objNewRecord = new Engagement_Unit__c();
		EngagementUnitServiceWrapper objResult = new EngagementUnitServiceWrapper();

		//We set the defaults.
		objResult.boolResult = false;

		//If we received data.
		if(objRequest != null) {

			//We insert the new EU record, if the user is internal.
			if(objRequest.boolIsInternalUser != null && objRequest.boolIsInternalUser) {
				objNewRecord.Account__c = objRequest.idAccount;
				objNewRecord.Awarded_By__c = 'CSM';
				objNewRecord.Entitled_Units__c = objRequest.intUnits;
				objNewRecord.Consumed_Units__c = 0;
				objNewRecord.Expiry_Date__c = System.today();
				objNewRecord.Start_Date__c = System.today();
				objNewRecord.Type__c = 'Success';
				objNewRecord.Status__c = 'Approved';
				try {
					insert objNewRecord;
				} catch(Exception objException) {
					GAM.CreateLogs('SuccessEngagementUnitService-->consumeEngagementUnits-->Engagement unit DML failure', objException.getMessage());
					throw objException;
				}
			}

			//Now we call the framework method.
			objResult = EngagementUnitService.consumeEngagementUnits(objRequest);
		}
		return objResult;
    }

    /*
	 Method Name : updateEngagementUnitConsumptionStatus
	 Description : This method updates the Engagement Unit Consumption status.
	 Parameters	 : Object, called from updateEngagementUnitConsumptionStatus, objRequest Request.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static void updateEngagementUnitConsumptionStatus(EngagementUnitServiceWrapper objRequest) {
		Engagement_Unit__c objNewRecord;
		EngagementUnitServiceWrapper objInnerRequest = objRequest;
		Set<String> setAcceptedStatuses = new Set<String> {
			'Completed',
			'Cancelled'
		};
		List<Engagement_Unit__c> lstNewRecords = new List<Engagement_Unit__c>();

		//If we received data.
		if(objInnerRequest != null && String.isNotBlank(objInnerRequest.strStatus) && setAcceptedStatuses.contains(objInnerRequest.strStatus)) {

			//If we received a single context id, we include it in the request list.
			if(String.isNotBlank(objInnerRequest.strContextId)) {
				if(objInnerRequest.lstContextIds == null) {
					objInnerRequest.lstContextIds = new List<String>();
				}
				objInnerRequest.lstContextIds.add(objInnerRequest.strContextId);
			}

			//We proceed only if we received a list of Context Ids.
			if(objInnerRequest.lstContextIds != null && !objInnerRequest.lstContextIds.isEmpty()) {

				//We insert the new EU record, if the user is not internal.
				if(objInnerRequest.boolIsInternalUser != null && !objInnerRequest.boolIsInternalUser) {
                    

					//First we query al the Consumption records.
					for(Engagement_Unit_Consumption__c objRecord : [SELECT Engagement_Unit__r.Account__c, Engagement_Unit__r.Awarded_By__c, Engagement_Unit__r.Type__c, Number_of_Units__c FROM 
							Engagement_Unit_Consumption__c WHERE Context_Id__c IN :objInnerRequest.lstContextIds AND Status__c = 'Consumed' LIMIT 50000]) {

						//Now we prepare the EU record.
						objNewRecord = new Engagement_Unit__c();
						objNewRecord.Account__c = objRecord.Engagement_Unit__r.Account__c;
						objNewRecord.Awarded_By__c = objRecord.Engagement_Unit__r.Awarded_By__c;
						objNewRecord.Entitled_Units__c = objRecord.Number_of_Units__c;
						objNewRecord.Consumed_Units__c = 0;
						objNewRecord.Expiry_Date__c = System.today().addYears(1);
						objNewRecord.Start_Date__c = System.today();
						objNewRecord.Type__c = objRecord.Engagement_Unit__r.Type__c;
						objNewRecord.Status__c = 'Approved';
						lstNewRecords.add(objNewRecord);
					}

					//If we have records to insert.
					if(!lstNewRecords.isEmpty()) {
						try {
							insert lstNewRecords;
						} catch(Exception objException) {
							GAM.CreateLogs('SuccessEngagementUnitService-->updateEngagementUnitConsumptionStatus-->Engagement unit DML failure', objException.getMessage());
							throw objException;
						}
					}
				}

				//Now we call the framework method.
				EngagementUnitService.updateEngagementUnitConsumptionStatus(objInnerRequest);
			}
		}
    }
}