/*
 * Name			:	GlobalCustomPlatformEventsController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/1/2022
 * Description	:	Controller class for Custom Platform Events.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/1/2022		N/A				Initial version.			N/A
 */
global with sharing class GlobalCustomPlatformEventsController {

	/*
	 Method Name : getWatchFields
	 Description : This method returns fields to be watched.
	 Parameters	 : String, called from getWatchFields, strRecordName Record Name.
	 Return Type : List<String>
	 */
    @AuraEnabled(cacheable = false)
    public static List<String> getWatchFields(String strRecordName) {
		return Refresh_Details__mdt.getInstance(strRecordName).Fields__c.replace(' ', '').split(',');
	}

	/*
	 Method Name : getObjectAPIName
	 Description : This method returns the Object API Name of the given record id.
	 Parameters	 : Id, called from getObjectAPIName, idRecord Record Id.
	 Return Type : String
	 */
    @AuraEnabled(cacheable = false)
    public static String getObjectAPIName(Id idRecord) {
		return idRecord.getSObjectType().getDescribe().getName();
	}
	
	/*
	 Method Name : executeQuery
	 Description : This method executes the given query.
	 Parameters	 : String, called from executeQuery, strQuery Query.
	 Return Type : List<SObject>
	 */
	@RemoteAction
	global static List<SObject> executeQuery(String strQuery) {
		return Database.query(strQuery);
    }
}