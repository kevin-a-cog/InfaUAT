/*
 * Name			:	GlobalNestedDataViewerController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/18/2021
 * Description	:	Global nested data viewer controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/18/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalNestedDataViewerController {

	/*
	 Method Name : getRecords
	 Description : This method returns the records related to the provided Record Id
	 Parameters	 : Object, called from getRecords, objRequest Request.
	 Return Type : Columns and records.
	 */
	@AuraEnabled(cacheable = false)
	public static GlobalDataTableWrapperClass getRecords(GlobalDataTableWrapperClass objRequest) {
		String strCleanRecordId = String.escapeSingleQuotes(objRequest.strRecordId);
		String strObjectName;
		String strMainFilterFieldAPIName;
		String strSpecificIds = '';
		String strAdditionalFilters = '';
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		Set<String> setUniqueFieldNames = new Set<String>();
		List<String> lstUniqueFieldNames = new List<String>();
		List<String> lstRecordIds = new List<String>();

		//If we received the Object Name.
		if(String.isNotBlank(objRequest.strObjectName)) {
			strObjectName = objRequest.strObjectName;
		} else {

			//As we didn't received the object name, we try to figure it out.
			strObjectName = ((Id) objRequest.strRecordId).getSObjectType().getDescribe().getName();
		}

		//If we received the Filter Field API Name.
		if(String.isNotBlank(objRequest.strMainFilterFieldAPIName)) {
			strMainFilterFieldAPIName = objRequest.strMainFilterFieldAPIName;
		} else {

			//If we didn't received it, we use Id.
			strMainFilterFieldAPIName = 'Id';
		}

		//We extract unique values of Field Names.
		if(objRequest.lstFieldNames != null && !objRequest.lstFieldNames.isEmpty()) {
			setUniqueFieldNames.addAll(objRequest.lstFieldNames);
			lstUniqueFieldNames.addAll(setUniqueFieldNames);
		}

		//If we received specific Ids, we create the filter.
		if(objRequest.lstRecordIds != null && !objRequest.lstRecordIds.isEmpty()) {
			lstRecordIds.addAll(objRequest.lstRecordIds);
			strSpecificIds = ' AND Id IN :lstRecordIds ';
		}

		//If we received additional filters, we create them.
		if(objRequest.lstAdditionalFilters != null && !objRequest.lstAdditionalFilters.isEmpty()) {
			strAdditionalFilters = ' AND ' + String.join(objRequest.lstAdditionalFilters, ' AND ') + ' ';
		}

		//Now we prepare the data.
		objDataTable.strObjectName = strObjectName;
		objDataTable.lstFieldNames = lstUniqueFieldNames;
		objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

		//Now we prepare the response.
		objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
				' WHERE ' + strMainFilterFieldAPIName + ' = :strCleanRecordId ' + strSpecificIds + strAdditionalFilters + ' WITH SECURITY_ENFORCED LIMIT 1000');
		return objDataTable;
	}
}