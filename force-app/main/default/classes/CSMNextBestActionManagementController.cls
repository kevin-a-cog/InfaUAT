/*
 * Name			:	CSMNextBestActionManagementController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/24/2021
 * Description	:	Next Best Action Management controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/24/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMNextBestActionManagementController {

	/*
	 Method Name : getSObjects
	 Description : This method returns the SObjects in the environment.
	 Parameters	 : None
	 Return Type : Map<String, String>
	 */
    @AuraEnabled(cacheable = false)
    public static Map<String, String> getSObjects() {
		Schema.DescribeSObjectResult objDescribeResult;
		Map<String, String> mapObjects = new Map<String, String>();
		for(Schema.SObjectType objObject : Schema.getGlobalDescribe().values()) {
			objDescribeResult = objObject.getDescribe();
			if(!objDescribeResult.isCustomSetting() && objDescribeResult.isAccessible() && objDescribeResult.isCreateable() && objDescribeResult.isDeletable() && 
					objDescribeResult.isQueryable() && objDescribeResult.isUpdateable()) {
				mapObjects.put(objDescribeResult.getName(), objDescribeResult.getLabel());
			}
		}
		return mapObjects;
	}

	/*
	 Method Name : getRelatedFields
	 Description : This method returns the fields related to the given object API name.
	 Parameters	 : String, called from getRelatedFields, strObjectAPIName Object API Name.
	 Return Type : Map<String, String>
	 */
    @AuraEnabled(cacheable = false)
    public static Map<String, String> getRelatedFields(String strObjectAPIName) {
		Map<String, String> mapFields = new Map<String, String>();
		Map<String, Schema.SObjectField> mapObjectFields;
		if(String.isNotBlank(strObjectAPIName)) {
			mapObjectFields = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe().fields.getMap();
			for(String strFieldAPIName : mapObjectFields.keySet()) {
				mapFields.put(mapObjectFields.get(strFieldAPIName).getDescribe().getName(), mapObjectFields.get(strFieldAPIName).getDescribe().getLabel());
			}
		}
		return mapFields;
	}

	/*
	 Method Name : getActions
	 Description : This method returns the actions predefined in the system.
	 Parameters	 : None
	 Return Type : List
	 */
    @AuraEnabled(cacheable = false)
    public static List<Next_Best_Action_Predefined__c> getActions() {
		return [SELECT Id, Title__c FROM Next_Best_Action_Predefined__c WHERE Is_Active__c = TRUE LIMIT 1000];
	}

	/*
	 Method Name : getRecordCreated
	 Description : This method creates a next best action record.
	 Parameters	 : Object, called from getRecordCreated, objNextBestAction Next Best Action record.
	 			   List, called from getRecordCreated, lstQueries Child queries.
	 Return Type : String
	 */
    @AuraEnabled(cacheable = false)
    public static String getRecordCreated(Next_Best_Action__c objNextBestAction, List<Next_Best_Action_Query__c> lstQueries) {
		Id idRecord;

		//First, we make sure we received the Next Best Action record.
		if(objNextBestAction != null) {

			//Now we insert the record.
			insert objNextBestAction;

			//Now we save the new record id.
			idRecord = objNextBestAction.Id;

			//Now we insert the child queries, if any.
			if(lstQueries != null && !lstQueries.isEmpty()) {
				for(Next_Best_Action_Query__c objQuery : lstQueries) {
					objQuery.Next_Best_Action__c = idRecord;
				}
				insert lstQueries;
			}
		}
		return idRecord;
	}
}