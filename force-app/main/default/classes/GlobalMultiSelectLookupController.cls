/*
 * Name			:	GlobalMultiSelectLookupController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/3/2022
 * Description	:	Controller class for Multi Select Lookup feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/3/2022		N/A				Initial version.			N/A
 */
public with sharing class GlobalMultiSelectLookupController {
	
	/*
	 Method Name : loadRecords
	 Description : This method returns the records related to the given object and filters.
	 Parameters	 : Object, called from loadRecords, objRequest Request data.
	 Return Type : List
	 */
    @AuraEnabled (cacheable=true)
    public static List<GlobalMultiSelectLookupWrapperClass> loadRecords(GlobalMultiSelectLookupWrapperClass objRequest) {
		Integer intLimitResults = 50;
		String strFilter;
		Matcher objMatcher;
		GlobalMultiSelectLookupWrapperClass objWrappedRecord;
		Set<String> setUniqueFields = new Set<String>();
		List<String> lstFilters = new List<String>();
		List<String> lstUniqueFields = new List<String>();
        List<GlobalMultiSelectLookupWrapperClass> lstResults = new List<GlobalMultiSelectLookupWrapperClass>();

		//First we make sure we received a request.
		if(objRequest != null && String.isNotBlank(objRequest.strObjectName) && (String.isNotBlank(objRequest.strFilterFieldAPIName) || objRequest.mapFilterFieldAPINames != null)) {

			//We prepare the fields to be returned.
			setUniqueFields.add('Id');

			//Now we prepare the search term.
			if(objRequest.strKeyword == null || objRequest.strKeyword == '*') {
				objRequest.strKeyword = '';
			}

			//If we don't have additional fitlers, we clean the variable.
			if(objRequest.strAdditionalFilters == null) {
				objRequest.strAdditionalFilters = '';
			}

			//If we received a limit.
			if(objRequest.intLimitResults != null) {
				intLimitResults = objRequest.intLimitResults;
			}

			//If we received multiple filters.
			if(String.isNotBlank(objRequest.strFilterFieldAPIName)) {
				strFilter = objRequest.strFilterFieldAPIName + ' LIKE \'' + objRequest.strKeyword + '%\' ';
				setUniqueFields.add(objRequest.strFilterFieldAPIName);
			} else if(objRequest.mapFilterFieldAPINames != null && !objRequest.mapFilterFieldAPINames.isEmpty()) {
				for(String strFilterFieldAPIName : objRequest.mapFilterFieldAPINames.keySet()) {
					lstFilters.add(strFilterFieldAPIName + ' LIKE \'' + objRequest.mapFilterFieldAPINames.get(strFilterFieldAPIName) + '%\'');
					setUniqueFields.add(strFilterFieldAPIName);
					if(String.isBlank(objRequest.strFilterFieldAPIName)) {
						objRequest.strFilterFieldAPIName = strFilterFieldAPIName;
					}
				}
				strFilter = '(' + String.join(lstFilters, ' OR ') + ')';
			}

			//If we received an specific value format, we extract the fields.
			if(String.isNotBlank(objRequest.strValueFormat)) {
				objMatcher = Pattern.compile('(\\{![\\w]+\\})').matcher(objRequest.strValueFormat);
				while(objMatcher.find()) {
					setUniqueFields.add(objMatcher.group().replace('{!', '').replace('}', ''));
				}
			}

			//We extract unique fields to be returned.
			lstUniqueFields.addAll(setUniqueFields);

			//Now we execute the query.
			for(SObject objRecord : Database.query('SELECT ' + String.escapeSingleQuotes(String.join(lstUniqueFields, ',')) + ' FROM ' + String.escapeSingleQuotes(objRequest.strObjectName) + 
					' WHERE ' + strFilter + objRequest.strAdditionalFilters + ' ORDER BY ' + objRequest.strFilterFieldAPIName + 
					' ASC LIMIT :intLimitResults')) {
				objWrappedRecord = new GlobalMultiSelectLookupWrapperClass();
				objWrappedRecord.strKey = (String) objRecord.get('Id');

				//If we need to return an specific format.
				if(String.isNotBlank(objRequest.strValueFormat)) {
					objWrappedRecord.strValue = objRequest.strValueFormat;
					for(String strUniqueField : lstUniqueFields) {
						objWrappedRecord.strValue = objWrappedRecord.strValue.replaceAll('\\{!' + strUniqueField + '\\}', (String) objRecord.get(strUniqueField));
					}
				} else {

					//Otherwise, we return one value.
					objWrappedRecord.strValue = (String) objRecord.get(objRequest.strFilterFieldAPIName);
				}
				lstResults.add(objWrappedRecord);
			}
		}
        return lstResults;
    }
}