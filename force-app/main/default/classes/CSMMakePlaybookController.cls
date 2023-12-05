/*
 * Name			:	CSMMakePlaybookController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/17/2021
 * Description	:	Make Playbook controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/17/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMMakePlaybookController {

	/*
	 Method Name : getFieldsToUpdate
	 Description : This method returns a list of API Names to be used during update operation.
	 Parameters	 : String, called from getFieldsToUpdate, strRecordId Record Id.
	 Return Type : List of Field API names.
	 */
    @AuraEnabled(cacheable = false)
    public static Map<String, Object> getFieldsToUpdate(String strRecordId) {
		Set<String> setUniquePrepopulationFields = new Set<String>();
		List<String> lstUniquePrepopulationFields = new List<String>();
		Map<String, String> mapPrepopulation = new Map<String, String>();
		Map<String, Object> mapResults = new Map<String, Object>();

		//First we extract the fields to display.
		for(Schema.FieldSetMember objField : Schema.getGlobalDescribe().get(Plan__c.class.getName()).getDescribe().FieldSets.getMap().get('Make_Playbook_Update_Fields').getFields()) {
			if(!objField.getSObjectField().getDescribe().isCalculated()) {
				mapResults.put(objField.getFieldPath(), '');
			}
		}

		//Now we define the preopulation mapping.
		mapPrepopulation.put('Template_Description__c', 'Description__c');

		//Now we extract the unique prepopulation fields.
		for(String strField : mapPrepopulation.values()) {
			setUniquePrepopulationFields.add(strField);
		}
		lstUniquePrepopulationFields.addAll(setUniquePrepopulationFields);

		//Now we query the Plan values, to prepopulate those fields.
		for(Plan__c objPlan : Database.query('SELECT ' + String.join(lstUniquePrepopulationFields, ', ') + ' FROM Plan__c WHERE Id = :strRecordId WITH SECURITY_ENFORCED LIMIT 1')) {
			for(String strFieldName : mapResults.keySet()) {
				if(String.isNotBlank(mapPrepopulation.get(strFieldName)) && objPlan.get(mapPrepopulation.get(strFieldName)) != null) {
					mapResults.put(strFieldName, objPlan.get(mapPrepopulation.get(strFieldName)));
				}
			}
		}
		return mapResults;
	}

	/*
	 Method Name : getPlanUpdated
	 Description : This method updates the provided Plan record.
	 Parameters	 : Object, called from getPlanUpdated, objPlan Plan record to be updated.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getPlanUpdated(Plan__c objPlan) {
		objPlan.Is_Template__c = true;
		objPlan.Template_Creator__c = UserInfo.getUserId();
		update objPlan;
	}

	/*
	 Method Name : getRecordsUpdated
	 Description : This method updates the provided records, based on the object.
	 Parameters	 : List<String>, called from getRecordsUpdated, lstRecords Records to be updated.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getRecordsUpdated(List<String> lstRecords) {
		String strObject;
		List<String> lstCollection;
		Map<String, List<String>> mapObjectsAndRecords = new Map<String, List<String>>();

		//If we recieved records to process.
		if(lstRecords != null) {

			//We iterate over them.
			for(String strRecordId : lstRecords) {

				//First, we extract the object.
				strObject = ((Id) strRecordId).getSObjectType().getDescribe().getName();

				//Now we check if we already stored a record of the same object.
				if(mapObjectsAndRecords.get(strObject) == null) {
					mapObjectsAndRecords.put(strObject, new List<String>());
				}
				lstCollection = mapObjectsAndRecords.get(strObject);
				lstCollection.add(strRecordId);

				//Now we store the Id.
				mapObjectsAndRecords.put(strObject, lstCollection);
			}

			//Now we send the updates to a future method, to avoid hitting limits.
			for(String strObjectToSend : mapObjectsAndRecords.keySet()) {
				updateRecords(strObjectToSend, JSON.serialize(mapObjectsAndRecords.get(strObjectToSend)));
			}
		}
	}

	/*
	 Method Name : updateRecords
	 Description : This method updates the provided records.
	 Parameters	 : String, called from updateRecords, strJSONString JSON string of a List.
	 Return Type : None
	 */
    @future
    public static void updateRecords(String strObjectName, String strJSONString) {
		SObject objRecord;
		Schema.SObjectType objDynamicObject = Schema.getGlobalDescribe().get(strObjectName);
		List<String> lstRecordIds = (List<String>) JSON.deserialize(strJSONString, List<String>.class);
		List<SObject> lstRecordsToUpdate = new List<SObject>();
        
        //Now we prepare the records.
		for(String strRecordId : lstRecordIds) {
			objRecord = objDynamicObject.newSobject();
			objRecord.put('Id', strRecordId);
			objRecord.put('Is_Template__c', true);
			lstRecordsToUpdate.add(objRecord);
		}
		update lstRecordsToUpdate;
	}
}