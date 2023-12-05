/*
 * Name			:	GlobalIframeViewerController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/9/2021
 * Description	:	Global iframe viewer controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/9/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalIframeViewerController {

	/*
	 Method Name : getRecordValues
	 Description : This method returns the values related to the provided Record Id
	 Parameters	 : String, called from getRecordValues, strRecordId Record Id.
	 			   List<String>, called from getRecordValues, lstFields List of fields.
	 Return Type : sObject.
	 */
	@AuraEnabled(cacheable = false)
	public static GlobalIframeViewerWrapperClass getRecordValues(String strRecordId, List<String> lstFields) {
		Id idRecord = strRecordId;
		Id idCurrentUserId = UserInfo.getUserId();
		List<String> lstObjectFields = new List<String>();
		List<String> lstUserFields = new List<String>();
		GlobalIframeViewerWrapperClass objResult = new GlobalIframeViewerWrapperClass();

		//First we separate the User fields, if any.
		for(String strField : lstFields) {
			if(strField.toLowerCase().startsWith('user.')) {
				lstUserFields.add(strField.replace('user.', ''));
			} else {
				lstObjectFields.add(strField);
			}
		}

		//Now we execute the first query.
		if(!lstObjectFields.isEmpty()) {
			objResult.objRecord = Database.query('SELECT ' + String.join(lstObjectFields, ',') + ' FROM ' + idRecord.getSObjectType().getDescribe().getName() + 
					' WHERE Id = :idRecord WITH SECURITY_ENFORCED LIMIT 1');
		}
		
		//Now we get the User fields.
		if(!lstUserFields.isEmpty()) {
			objResult.objUser = Database.query('SELECT ' + String.join(lstUserFields, ',') + ' FROM User WHERE Id = :idCurrentUserId WITH SECURITY_ENFORCED LIMIT 1');
		}
		return objResult;
	}
}