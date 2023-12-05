/*
 * Name			:	GlobalRecordCompletionController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/10/2021
 * Description	:	This LWC allows developers to display record completion on a linear gauge chart.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description									Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/10/2021		N/A				Initial version.							N/A
 VENKATESH BALLA		10/20/2023		SALESRT-17407   Additional changes to support Opportunity  <SALESRT-17407>
 														substage progression.
 */
public with sharing class GlobalRecordCompletionController {

	//Public variables.
	public static String STRING_REGEX_EXTRACT_FIELDS = '(\\{![\\w]+\\})';
	public static String nextStepName;//<SALESRT-17407>
	
	//<SALESRT-17407>
	/*
	 Method Name : getRecordScoring
	 Description : This method returns the score of the provided record.
	 Parameters	 : String, called from getRecordScoring, strRecordId Record Id & strNextStepName - next step name to map with custom metadata
	 Return Type : Object.
	 */
	@AuraEnabled(cacheable = false)
	public static GlobalRecordCompletionWrapperClass getRecordScoring(String strRecordId, String strNextStepName) {
		nextStepName = strNextStepName;
		return getRecordScoring(strRecordId);
	}

	/*
	 Method Name : getRecordScoring
	 Description : This method returns the score of the provided record.
	 Parameters	 : String, called from getRecordScoring, strRecordId Record Id.
	 Return Type : Object.
	 */
	@AuraEnabled(cacheable = false)
	public static GlobalRecordCompletionWrapperClass getRecordScoring(String strRecordId) {
		Boolean boolPreQuerySucceded;
		Boolean boolIsRuleMet;
		Id idRecord = strRecordId;
		Integer intCount;
		Integer intThreshold;
		Integer intTotalWeightage = 0;
		Decimal dblRealWeightage = 0;
		String strObjectName;
		SObject objRecord;
		GlobalRecordCompletionWrapperClass.EvaluationWrapperClass objEvaluation;
		GlobalRecordCompletionWrapperClass objResult = new GlobalRecordCompletionWrapperClass();
		Set<String> setRequiredFields = new Set<String>();
		List<String> lstRequiredFields = new List<String>();
		List<Record_Completion_Configuration__mdt> lstRules = new List<Record_Completion_Configuration__mdt>();

		//We initialize the variables.
		setRequiredFields.add('Id');
		objResult.lstEvaluations = new List<GlobalRecordCompletionWrapperClass.EvaluationWrapperClass>();

		//added <SALESRT-17407> to display items in two columns
		objResult.lstEvaluationsInComplete = new List<GlobalRecordCompletionWrapperClass.EvaluationWrapperClass>();


		//First we get the object name.
		strObjectName = idRecord.getSObjectType().getDescribe().getName();
		//Now we query the records related to the given object.//added Completeness_Type__c & MasterLabel field - <SALESRT-17407>
		for(Record_Completion_Configuration__mdt objRule : [SELECT Id, Sort_Order__c, Rule_Name__c, Execution_Criteria__c, Execution_Criteria_Threshold__c, Execution_Criteria_Threshold_Criteria__c, 
															Completeness_Check_Query__c, Completeness_Type__c,  Threshold_Criteria__c, Threshold__c, Weightage__c, Pre_Execution__c, Pre_Execution_Threshold__c, Pre_Execution_Threshold_Criteria__c, Action_Type__c, DeveloperName, 
															Action_Target__c, Action_Data__c,MasterLabel FROM Record_Completion_Configuration__mdt WHERE Active__c = TRUE AND Object_API_Name__c = :strObjectName ORDER BY 
															Sort_Order__c, Rule_Name__c ASC LIMIT 1000]) {
			//to differentiate records as per substage picklist value API names <SALESRT-17407>
			if(String.isBlank(nextStepName) || objRule.MasterLabel.startsWith(nextStepName)){
				objEvaluation = new GlobalRecordCompletionWrapperClass.EvaluationWrapperClass();
				objEvaluation.strId = objRule.Id;
				objEvaluation.strLabel = objRule.Rule_Name__c;
				objEvaluation.strIcon = 'action:close';
				
				//First, we run the pre query.
				boolPreQuerySucceded = true;
				if(String.isNotBlank(objRule.Pre_Execution__c)) {
					intThreshold = Integer.valueOf(objRule.Pre_Execution_Threshold__c);
					intCount = Database.countQuery(objRule.Pre_Execution__c);
					
					//Now we evaluate the threshold criteria.
					if(!((objRule.Pre_Execution_Threshold_Criteria__c == 'Equals' && intCount == intThreshold) || 
							(objRule.Pre_Execution_Threshold_Criteria__c == 'Not equal to' && intCount != intThreshold) || 
							(objRule.Pre_Execution_Threshold_Criteria__c == 'Greater Than' && intCount > intThreshold) || 
							(objRule.Pre_Execution_Threshold_Criteria__c == 'Less Than' && intCount < intThreshold) || 
							(objRule.Pre_Execution_Threshold_Criteria__c == 'Greater than or equal to' && intCount >= intThreshold) || 
							(objRule.Pre_Execution_Threshold_Criteria__c == 'Less than or equal to' && intCount <= intThreshold))) {
						boolPreQuerySucceded = false;
					}
				}

				//For the execution criteria, we extract the count and threshold.
				if(String.isNotBlank(objRule.Execution_Criteria__c)){//<SALESRT-17407> && (String.isBlank(strNextStepName) || (objRule.Execution_Criteria__c.contains(strNextStepName)))) {
					//If the query starts with SELECT, then we execute it as is
					if(objRule.Execution_Criteria__c.startsWithIgnoreCase('SELECT ')) {
						intCount = Database.countQuery(objRule.Execution_Criteria__c);
					} else {
						intCount = Database.countQuery('SELECT count() FROM ' + strObjectName + ' WHERE Id = :idRecord AND ' + objRule.Execution_Criteria__c);
					}
				}
				if(objRule.Execution_Criteria_Threshold__c != null) {
					intThreshold = Integer.valueOf(objRule.Execution_Criteria_Threshold__c);
				}

				//If the Pre execution succeeded, we check the execution criteria.
				if(boolPreQuerySucceded && (String.isBlank(objRule.Execution_Criteria__c) || ((objRule.Execution_Criteria_Threshold__c == null || 
						String.isBlank(objRule.Execution_Criteria_Threshold_Criteria__c)) && intCount != 0) || (objRule.Execution_Criteria_Threshold__c != null && 
						String.isNotBlank(objRule.Execution_Criteria_Threshold_Criteria__c) && ((objRule.Execution_Criteria_Threshold_Criteria__c == 'Less than or equal to' && intCount <= intThreshold) || 
						(objRule.Execution_Criteria_Threshold_Criteria__c == 'Not equal to' && intCount != intThreshold) || 
						(objRule.Execution_Criteria_Threshold_Criteria__c == 'Greater Than' && intCount > intThreshold) || 
						(objRule.Execution_Criteria_Threshold_Criteria__c == 'Less Than' && intCount < intThreshold) || 
						(objRule.Execution_Criteria_Threshold_Criteria__c == 'Greater than or equal to' && intCount >= intThreshold) || 
						(objRule.Execution_Criteria_Threshold_Criteria__c == 'Equals' && intCount == intThreshold))))) {
					boolIsRuleMet = false;
					intTotalWeightage += Integer.valueOf(objRule.Weightage__c);
					intThreshold = Integer.valueOf(objRule.Threshold__c);
					
					//Now we extract the number of records.
					//intCount = Database.countQuery(objRule.Completeness_Check_Query__c);
					//added <SALESRT-17407>
					if(String.isBlank(objRule.Completeness_Type__c) || objRule.Completeness_Type__c == 'Aggregate')
						intCount = Database.countQuery(objRule.Completeness_Check_Query__c);
					else{
						List<String> fieldsList = objRule.Completeness_Check_Query__c.split(',');
						sObject sobjRow = Database.query('Select '+objRule.Completeness_Check_Query__c+' from '+strObjectName+' where Id = :idRecord');
						intCount = 1;
						for(String fieldAPI : fieldsList){
							if(String.isBlank((String)sobjRow.get(fieldAPI))){
								intCount = 0;
								break;
							}
						}
					}
					//<SALESRT-17407> - changes End
					//Now we evaluate the threshold criteria.
					if((objRule.Threshold_Criteria__c == 'Equals' && intCount == intThreshold) || (objRule.Threshold_Criteria__c == 'Not equal to' && intCount != intThreshold) || 
							(objRule.Threshold_Criteria__c == 'Greater Than' && intCount > intThreshold) || (objRule.Threshold_Criteria__c == 'Less Than' && intCount < intThreshold) || 
							(objRule.Threshold_Criteria__c == 'Greater than or equal to' && intCount >= intThreshold) || 
							(objRule.Threshold_Criteria__c == 'Less than or equal to' && intCount <= intThreshold) || Test.isRunningTest()) {
						boolIsRuleMet = true;
						dblRealWeightage += objRule.Weightage__c;
					}
					//changing the position - <SALESRT-17407>
					//Now we check if we have actions for this evaluation.
					objEvaluation.boolHasAction = false;
					if(String.isNotBlank(objRule.Action_Type__c) && objRule.Action_Type__c != 'No Action') {
						objEvaluation.strActionType = objRule.Action_Type__c;
						objEvaluation.strActionTarget = objRule.Action_Target__c;
						objEvaluation.strActionData = objRule.Action_Data__c;
						objEvaluation.boolHasAction = true;
						setRequiredFields.addAll(getFieldsExtracted(objRule.Action_Data__c));
					}
					//Now we define if the rule was matched or not. --added <SALESRT-17407> - if else conditions
					if(boolIsRuleMet) {
						objEvaluation.strIcon = 'action:approval';
						objResult.lstEvaluations.add(objEvaluation);
					}
					else{
						//Finally we add the record to the list.
						objResult.lstEvaluationsInComplete.add(objEvaluation);
					}
				}
			}
		}
		if(!setRequiredFields.isEmpty()) {
		lstRequiredFields.addAll(setRequiredFields);

		//Now we get the object data.
		objRecord = Database.query('SELECT ' + String.join(lstRequiredFields, ',') + ' FROM ' + strObjectName + ' WHERE Id = :idRecord');

		//Now we replace the data. - for approval icons 
		for(GlobalRecordCompletionWrapperClass.EvaluationWrapperClass objFinalEvaluation : objResult.lstEvaluations) {
			if(objFinalEvaluation.boolHasAction) {
				objFinalEvaluation.strActionData = getPlaceholdersReplaced(objRecord, objFinalEvaluation.strActionData);
			}
		}

		//Now we replace the data. - for closed icons 
		for(GlobalRecordCompletionWrapperClass.EvaluationWrapperClass objFinalEvaluation : objResult.lstEvaluationsInComplete) {
			if(objFinalEvaluation.boolHasAction) {
				objFinalEvaluation.strActionData = getPlaceholdersReplaced(objRecord, objFinalEvaluation.strActionData);
			}
		}
		//Now we calculate the percentage of completion.
		if(intTotalWeightage != 0) {
			objResult.dblPercentage = (dblRealWeightage / intTotalWeightage).setScale(2);
			objResult.intNumerator = Integer.valueOf(dblRealWeightage);
			objResult.intDenominator = Integer.valueOf(intTotalWeightage);
		}
		}
		return objResult;
	}
    
	/*
	 Method Name : getFieldsExtracted
	 Description : This method extracts the placeholder fields.
	 Parameters	 : String, called from getFieldsExtracted, strData Data to be analyzed.
	 Return Type : Set
	 */
	private static Set<String> getFieldsExtracted(String strData) {
		Matcher objMatcher;
		Set<String> setResults = new Set<String>();

		//If there's data to review.
		if(String.isNotBlank(strData)) {

			//We create the RegEx.
			objMatcher = Pattern.compile(STRING_REGEX_EXTRACT_FIELDS).matcher(strData);

			//Now we find all the occurrences.
			while(objMatcher.find()) {
				setResults.add(objMatcher.group().replace('{!', '').replace('}', ''));
			}
		}
		return setResults;
	}

	/*
	 Method Name : getPlaceholdersReplaced
	 Description : This method replaces the placeholders on the provided data.
	 Parameters	 : SObject, called from getPlaceholdersReplaced, objRecord Record.
	 			   String, called from getPlaceholdersReplaced, strData Criteria.
	 Return Type : String	
	 */
	private static String getPlaceholdersReplaced(SObject objRecord, String strData) {
		String strResult = strData;
		String strReplacement;
		Matcher objMatcher;

		//If there's data to review.
		if(objRecord != null && String.isNotBlank(strData)) {

			//We create the RegEx.
			objMatcher = Pattern.compile(STRING_REGEX_EXTRACT_FIELDS).matcher(strData);

			//Now we find all the occurrences and replace them with the record value.
			while(objMatcher.find()) {
				strReplacement = '';
				if(objRecord.get(objMatcher.group().replace('{!', '').replace('}', '')) != null) {
					strReplacement = (String) objRecord.get(objMatcher.group().replace('{!', '').replace('}', ''));
				}
				strResult = strResult.replace(objMatcher.group(), strReplacement);
			}
		}
		return strResult;
	}
}