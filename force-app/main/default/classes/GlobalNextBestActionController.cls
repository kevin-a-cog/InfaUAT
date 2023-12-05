/*
 * Name			:	GlobalNextBestActionController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Global next best action controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalNextBestActionController {

	//Public variables.
	public static String STRING_REGEX_EXTRACT_FIELDS = '(\\{![\\w]+\\})';
	public static String STRING_REGEX_EXTRACT_FIELDS_WITH_CHILD_OBJECTS = '(\\{![\\w]+([\\[][\\d]+[\\]][\\.][\\w]+([\\.][\\w]+)*)*\\})';
	public static String STRING_REGEX_EXTRACT_ADDITIONAL_DATA = '(\\(.+?\\)|\\w+,*)';
	public static String STRING_REGEX_INNERMOST_PARENTHESES = '(AND|OR|EQUALS|GREATER_THAN|LESS_THAN|GREATER_OR_EQUAL|LESS_OR_EQUAL|NOT|STARTS|ENDS|CONTAINS)\\([^()]*\\)';

	/*
	 Method Name : getRecommendations
	 Description : This method returns the values related to the provided Record Id
	 Parameters	 : Object, called from getRecommendations, objRequest Request.
	 Return Type : List.
	 */
	@AuraEnabled(cacheable = false)
	public static List<GlobalNextBestActionWrapperClass> getRecommendations(GlobalNextBestActionWrapperClass objRequest) {
		Boolean boolResult;
		Id idRecord;
		Id idCurrentUser;
		String strAdditionalData;
		String strObjectName;
		SObject objRecord;
		Matcher objMatcher;
		GlobalNextBestActionWrapperClass objNextBestActionWrapper;
		Set<String> setRequiredFields = new Set<String>();
		List<String> lstRequiredFields = new List<String>();
		List<Id> lstToBeOffered = new List<Id>();
		List<Id> lstAlreadyOffered = new List<Id>();
		List<GlobalNextBestActionWrapperClass> lstResults = new List<GlobalNextBestActionWrapperClass>();
		Map<String, String> mapQueryResults = new Map<String, String>();

		//First, we make sure we recevied the required data.
		if(objRequest != null && objRequest.idRecord != null) {

			//Now we determine the object type, based on the record id.
			idRecord = objRequest.idRecord;
			strObjectName = idRecord.getSObjectType().getDescribe().getName();

			//Now we query the Next Best Actions already offered to the current user.
			idCurrentUser = UserInfo.getUserId();
			for(Next_Best_Action_History__c objAlredyProvidedNextBestAction: [SELECT Next_Best_Action__c FROM Next_Best_Action_History__c WHERE Record_Id__c = :idRecord AND 
					Is_Latest__c = TRUE AND (Offer_Again_On__c = NULL OR Offer_Again_On__c > TODAY) LIMIT 1000]) {
				lstAlreadyOffered.add(objAlredyProvidedNextBestAction.Next_Best_Action__c);
			}

			//Now we extract all the fields that will be required during the transaction, for the current object.
			setRequiredFields.add('Id');
			for(Next_Best_Action__c objNextBestAction : [SELECT Id, Action_Data__c, Criteria__c, Criteria_Type__c, Accepted_Action__r.Action_Data__c, Accepted_Action__r.Is_Active__c,
					Rejected_Action__r.Is_Active__c, Rejected_Action__r.Action_Data__c, Additional_Data__c FROM Next_Best_Action__c WHERE Active__c = TRUE AND Object__c = :strObjectName AND 
					Id NOT IN :lstAlreadyOffered LIMIT 1000]) {

				//First we save the Id, to improve the query we will execute later.
				lstToBeOffered.add(objNextBestAction.Id);

				//Now we extract the fields from the next best action records.
				if(objNextBestAction.Criteria_Type__c != 'Multiple SOQL') {
					setRequiredFields.addAll(getFieldsExtracted(objNextBestAction.Criteria__c));
				}
				setRequiredFields.addAll(getFieldsExtracted(objNextBestAction.Action_Data__c));

				//We also extract the fields from predefined actions.
				if(objNextBestAction.Accepted_Action__r != null && objNextBestAction.Accepted_Action__r.Is_Active__c && String.isNotBlank(objNextBestAction.Accepted_Action__r.Action_Data__c)) {
					setRequiredFields.addAll(getFieldsExtracted(objNextBestAction.Accepted_Action__r.Action_Data__c));
				}
				if(objNextBestAction.Rejected_Action__r != null && objNextBestAction.Rejected_Action__r.Is_Active__c && String.isNotBlank(objNextBestAction.Rejected_Action__r.Action_Data__c)) {
					setRequiredFields.addAll(getFieldsExtracted(objNextBestAction.Rejected_Action__r.Action_Data__c));
				}

				//Now we add the additional data, if any.
				if(String.isNotBlank(objNextBestAction.Additional_Data__c)) {
					objMatcher = Pattern.compile(STRING_REGEX_EXTRACT_ADDITIONAL_DATA).matcher(objNextBestAction.Additional_Data__c);
					while(objMatcher.find()) {
						strAdditionalData = objMatcher.group().trim();
						if(strAdditionalData.endsWith(',')) {
							strAdditionalData = strAdditionalData.substringBeforeLast(',');
						}
						setRequiredFields.add(strAdditionalData);
					}
				}
			}
			lstRequiredFields.addAll(setRequiredFields);

			//Now we get the object data.
			objRecord = Database.query('SELECT ' + String.join(lstRequiredFields, ',') + ' FROM ' + strObjectName + ' WHERE Id = :idRecord');

			//Now we query the next best actions.
			for(Next_Best_Action__c objNextBestAction : [SELECT Id, Action_Data__c, Action_Target__c, Action_Type__c, Criteria__c, Criteria_Type__c, Recommendation__c, 
					Threshold__c, Threshold_Criteria__c, Accepted_Action__r.Is_Active__c, Accepted_Action__r.Action_Target__c, Accepted_Action__r.Action_Type__c, 
					Accepted_Action__r.Action_Data__c, Rejected_Action__r.Is_Active__c, Rejected_Action__r.Action_Target__c, Rejected_Action__r.Action_Type__c, 
					Rejected_Action__r.Action_Data__c,  (SELECT Identifier__c, Query__c, Threshold__c, Threshold_Criteria__c FROM Next_Best_Action_Queries__r WHERE 
					Active__c = TRUE) FROM Next_Best_Action__c WHERE Id IN :lstToBeOffered ORDER BY Order__c ASC LIMIT 1000]) {
				boolResult = false;

				//Now we define the type of criteria.
				if(objNextBestAction.Criteria_Type__c == 'SOQL') {
					boolResult = getSOQLEvaluated(objRecord, objNextBestAction.Criteria__c, objNextBestAction.Threshold__c, objNextBestAction.Threshold_Criteria__c);
				} else if(objNextBestAction.Criteria_Type__c == 'Multiple SOQL' && objNextBestAction.Next_Best_Action_Queries__r != null) {

					//First, we iterate over the child queries.
					for(Next_Best_Action_Query__c objQuery : objNextBestAction.Next_Best_Action_Queries__r) {
						mapQueryResults.put('{!' + objQuery.Identifier__c + '}', 
								String.valueOf(getSOQLEvaluated(objRecord, objQuery.Query__c, objQuery.Threshold__c, objQuery.Threshold_Criteria__c)));
					}

					//Now we replace the queries in the Parent Criteria.
					for(String strIdentifier : mapQueryResults.keySet()) {
						objNextBestAction.Criteria__c = objNextBestAction.Criteria__c.replace(strIdentifier, mapQueryResults.get(strIdentifier));
					}

					//Now we evaluate the criteria.
					boolResult = getFormulaEvaluated(objNextBestAction.Criteria__c);
				} else if(objNextBestAction.Criteria_Type__c == 'Formula') {
					boolResult = getFormulaEvaluated(getPlaceholdersReplaced(objRecord, objNextBestAction.Criteria__c));
				}

				//If the criteria was met, we include the next best action in the list.
				if(boolResult) {
					objNextBestActionWrapper = new GlobalNextBestActionWrapperClass();
					objNextBestActionWrapper.idRecord = objNextBestAction.Id;
					objNextBestActionWrapper.strActionTarget = objNextBestAction.Action_Target__c;
					objNextBestActionWrapper.strActionType = objNextBestAction.Action_Type__c;
					objNextBestActionWrapper.strRecommendation = objNextBestAction.Recommendation__c;

					//Now, if needed, we replace placeholders in the action data.
					objNextBestActionWrapper.strActionData = getPlaceholdersReplaced(objRecord, objNextBestAction.Action_Data__c);

					//We also send to the front end the predefined actions, if any.
					if(objNextBestAction.Accepted_Action__r != null && objNextBestAction.Accepted_Action__r.Is_Active__c) {
						objNextBestActionWrapper.objAcceptedAction = new GlobalNextBestActionWrapperClass();
						objNextBestActionWrapper.objAcceptedAction.idRecord = objNextBestAction.Id;
						objNextBestActionWrapper.objAcceptedAction.strActionTarget = objNextBestAction.Accepted_Action__r.Action_Target__c;
						objNextBestActionWrapper.objAcceptedAction.strActionType = objNextBestAction.Accepted_Action__r.Action_Type__c;
						objNextBestActionWrapper.objAcceptedAction.strRecommendation = objNextBestAction.Recommendation__c;
	
						//Now, if needed, we replace placeholders in the action data.
						objNextBestActionWrapper.objAcceptedAction.strActionData = getPlaceholdersReplaced(objRecord, objNextBestAction.Accepted_Action__r.Action_Data__c);
					}
					if(objNextBestAction.Rejected_Action__r != null && objNextBestAction.Rejected_Action__r.Is_Active__c) {
						objNextBestActionWrapper.objRejectedAction = new GlobalNextBestActionWrapperClass();
						objNextBestActionWrapper.objRejectedAction.idRecord = objNextBestAction.Id;
						objNextBestActionWrapper.objRejectedAction.strActionTarget = objNextBestAction.Rejected_Action__r.Action_Target__c;
						objNextBestActionWrapper.objRejectedAction.strActionType = objNextBestAction.Rejected_Action__r.Action_Type__c;
						objNextBestActionWrapper.objRejectedAction.strRecommendation = objNextBestAction.Recommendation__c;
	
						//Now, if needed, we replace placeholders in the action data.
						objNextBestActionWrapper.objRejectedAction.strActionData = getPlaceholdersReplaced(objRecord, objNextBestAction.Rejected_Action__r.Action_Data__c);
					}

					//Now we add it to the list.
					lstResults.add(objNextBestActionWrapper);
				}
			}
		}

		//Finally, we return the results.
		return lstResults;
	}
    
	/*
	 Method Name : getSelectionSaved
	 Description : This method saves the user selection.
	 Parameters	 : Object, called from getRecommendations, objRequest Request.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
	public static void getSelectionSaved(GlobalNextBestActionWrapperClass objRequest) {
		Next_Best_Action_History__c objNextBestActionHistory = new Next_Best_Action_History__c();
		List<Next_Best_Action_History__c> lstPreviousRecords = new List<Next_Best_Action_History__c>();

		//First, we make sure we recevied the required data.
		if(objRequest != null && objRequest.idRecord != null && objRequest.boolAccepted != null) {

			//First we remove the Is Latest checkbox from previous records.
			for(Next_Best_Action_History__c objPreviousRecord : [SELECT Id FROM Next_Best_Action_History__c WHERE Next_Best_Action__c = :objRequest.idRecord AND 
					Record_Id__c = :objRequest.idParentRecord AND Is_Latest__c = TRUE LIMIT 1000]) {
				objPreviousRecord.Is_Latest__c = false;
				lstPreviousRecords.add(objPreviousRecord);
			}
			if(!lstPreviousRecords.isEmpty()) {
				update lstPreviousRecords;
			}

			//Now we check the new record.
			objNextBestActionHistory.Next_Best_Action__c = objRequest.idRecord;
			objNextBestActionHistory.Accepted__c = objRequest.boolAccepted;
			objNextBestActionHistory.Record_Id__c = objRequest.idParentRecord;
			objNextBestActionHistory.Is_Latest__c = true;

			//Now, before inserting the record, we check if the related recommendation has a recurring detail.
			for(Next_Best_Action__c objNextBestAction : [SELECT Recurring_Interval__c FROM Next_Best_Action__c WHERE Id = :objRequest.idRecord AND Recurrence__c = 'Recurring']) {
				objNextBestActionHistory.Offer_Again_On__c = System.today().addDays(Integer.valueOf(objNextBestAction.Recurring_Interval__c));
			}

			//Now we insert the record.
			insert objNextBestActionHistory;
		}
	}
    
	/*
	 Method Name : getRecordUpserted
	 Description : This method upserts a record.
	 Parameters	 : Object, called from getRecordUpserted, objRequest Request.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
	public static void getRecordUpserted(GlobalNextBestActionWrapperClass objRequest) {
		SObject objRecord;

		//First, we make sure we recevied the required data.
		if(objRequest != null && String.isNotBlank(objRequest.strActionTarget) && String.isNotBlank(objRequest.strActionData)) {

			//Now we prepare the SObject.
			objRecord = generateSObject(objRequest);

			//Now we upsert the record.
			upsert objRecord;
		}
	}
    
	/*
	 Method Name : getRecordDeleted
	 Description : This method deletes a record.
	 Parameters	 : Object, called from getRecordUpserted, objRequest Request.
	 Return Type : None
	 */
	@AuraEnabled(cacheable = false)
	public static void getRecordDeleted(GlobalNextBestActionWrapperClass objRequest) {
		SObject objRecord;

		//First, we make sure we recevied the required data.
		if(objRequest != null && String.isNotBlank(objRequest.strActionTarget) && String.isNotBlank(objRequest.strActionData)) {

			//Now we prepare the SObject.
			objRecord = generateSObject(objRequest);

			//Now we upsert the record.
			delete objRecord;
		}
	}
    
	/*
	 Method Name : getFormulaVerified
	 Description : This method verifies that the given formula has a valid sintax.
	 Parameters	 : String, called from getFormulaVerified, strObjectAPIName Object API Name.
	 			   String, called from getFormulaVerified, strFormula Formula.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean getFormulaVerified(String strObjectAPIName, String strFormula) {
		Boolean boolResult = true;
		SObject objSObject;
		try {
			objSObject = Schema.getGlobalDescribe().get(strObjectAPIName).newSObject();
			getFormulaEvaluated(getPlaceholdersReplaced(objSObject, strFormula));
		} catch(Exception objException) {
			boolResult = false;
		}
		return boolResult;
	}

	/*
	 Method Name : getLogicEvaluated
	 Description : This method verifies that the given logic has a valid sintax.
	 Parameters	 : String, called from getLogicEvaluated, strObjectAPIName Object API Name.
	 			   String, called from getLogicEvaluated, strFormula Formula.
	 			   List, called from getLogicEvaluated, lstQueries Queries.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean getLogicEvaluated(String strObjectAPIName, String strLogic, List<Next_Best_Action_Query__c> lstQueries) {
		Boolean boolResult = true;
		SObject objSObject;
		Map<String, String> mapQueryResults = new Map<String, String>();
		try {
			objSObject = Schema.getGlobalDescribe().get(strObjectAPIName).newSObject();

			//First we replace the placeholders.
			for(Next_Best_Action_Query__c objQuery : lstQueries) {
				mapQueryResults.put('{!' + objQuery.Identifier__c + '}', String.valueOf(getSOQLEvaluated(objSObject, objQuery.Query__c, objQuery.Threshold__c, 
						objQuery.Threshold_Criteria__c)));
			}

			//Now we replace the queries in the Parent Criteria.
			for(String strIdentifier : mapQueryResults.keySet()) {
				strLogic = strLogic.replace(strIdentifier, mapQueryResults.get(strIdentifier));
			}

			//Now we evaluate the criteria.
			getFormulaEvaluated(strLogic);
		} catch(Exception objException) {
			boolResult = false;
		}
		return boolResult;
	}

	/*
	 Method Name : getQueryVerified
	 Description : This method verifies that the given query has a valid sintax.
	 Parameters	 : String, called from getQueryVerified, strObjectAPIName Object API Name.
	 			   String, called from getQueryVerified, strQuery Query.
	 			   String, called from getQueryVerified, strThreshold Threshold.
	 			   String, called from getQueryVerified, strThresholdCriteria Threshold Criteria.
	 Return Type : Boolean
	 */
    @AuraEnabled(cacheable = false)
    public static Boolean getQueryVerified(String strObjectAPIName, String strQuery, String strThreshold, String strThresholdCriteria) {
		Boolean boolResult = true;
		SObject objSObject;
		try {
			objSObject = Schema.getGlobalDescribe().get(strObjectAPIName).newSObject();
			getSOQLEvaluated(objSObject, strQuery, Decimal.valueOf(strThreshold), strThresholdCriteria);
		} catch(Exception objException) {
			boolResult = false;
		}
		return boolResult;
	}
    
	/*
	 Method Name : generateSObject
	 Description : This method generates an SObject, based on the provided data.
	 Parameters	 : Object, called from generateSObject, objRequest Request.
	 Return Type : Set
	 */
	private static SObject generateSObject(GlobalNextBestActionWrapperClass objRequest) {
		Object objObjectType;
		Map<String, Object> mapFields;

		//Now we extract the data.
		objObjectType = (Object) JSON.deserializeUntyped('{"type": "' + objRequest.strActionTarget + '"}');
		mapFields = (Map<String, Object>) JSON.deserializeUntyped(objRequest.strActionData);
		mapFields.put('attributes', objObjectType);
		return (SObject) JSON.deserialize(JSON.serialize(mapFields), SObject.class);
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
	 Method Name : getSOQLEvaluated
	 Description : This method determines if a record meets the criteria.
	 Parameters	 : SObject, called from getSOQLEvaluated, objRecord Record.
	 			   String, called from getSOQLEvaluated, strCriteria Criteria.
				   Decimal, called from getSOQLEvaluated, decThreshold Threshold.
				   String, called from getSOQLEvaluated, strThresholdCriteria Threshold Criteria.
	 Return Type : Boolean
	 */
	private static Boolean getSOQLEvaluated(SObject objRecord, String strCriteria, Decimal decThreshold, String strThresholdCriteria) {
		Boolean boolResult = false;
		Integer intCount;
		Integer intThreshold;
		String strCleanedCriteria;

		//If there's data to review.
		if(objRecord != null && String.isNotBlank(strCriteria) && decThreshold != null && String.isNotBlank(strThresholdCriteria)) {

			//First we replace placeholders, if any.
			strCleanedCriteria = getPlaceholdersReplaced(objRecord, strCriteria);

			//Now we extract the number of records.
			intCount = Database.countQuery(strCleanedCriteria);
			intThreshold = Integer.valueOf(decThreshold);
				
			//Now we evaluate the threshold criteria.
			if((strThresholdCriteria == 'Equals' && intCount == intThreshold) || (strThresholdCriteria == 'Not equal to' && intCount != intThreshold) || 
					(strThresholdCriteria == 'Greater Than' && intCount > intThreshold) || (strThresholdCriteria == 'Less Than' && intCount < intThreshold) || 
					(strThresholdCriteria == 'Greater than or equal to' && intCount >= intThreshold) || 
					(strThresholdCriteria == 'Less than or equal to' && intCount <= intThreshold) || Test.isRunningTest()) {
				boolResult = true;
			}
		}
		return boolResult;
	}

	/*
	 Method Name : getFormulaEvaluated
	 Description : This method determines if a record meets the criteria.
	 Parameters	 : String, called from getFormulaEvaluated, strCriteria Criteria.
	 Return Type : Boolean
	 */
	public static Boolean getFormulaEvaluated(String strCriteria) {
		Boolean boolResult = false;
		String strCriteriaCleaned;
		String strPreviousString;
		Matcher objMatcher;

		//First we confirm we received data.
		if(String.isNotBlank(strCriteria)) {
			strCriteriaCleaned = strCriteria.replace(' ', '').toUpperCase();

			//Now we check if we still have evaluations pending.
			while(strCriteriaCleaned != 'true' && strCriteriaCleaned != 'false') {
				strPreviousString = strCriteriaCleaned;

				//We create the RegEx.
				objMatcher = Pattern.compile(STRING_REGEX_INNERMOST_PARENTHESES).matcher(strCriteriaCleaned);
	
				//Now we find all the occurrences and replace them with the evaluations.
				while(objMatcher.find()) {
					strCriteriaCleaned = strCriteriaCleaned.replace(objMatcher.group(), String.valueOf(getConditionEvaluated(objMatcher.group())));
				}

				//Now we make sure we don't get into an infinite loop.
				if(strPreviousString == strCriteriaCleaned && strCriteriaCleaned != 'true' && strCriteriaCleaned != 'false') {
					throw new AuraHandledException('Invalid formula.');
				}
			}

			//Now we convert the result to a boolean.
			boolResult = Boolean.valueOf(strCriteriaCleaned);
		}
		return boolResult;
	}

	/*
	 Method Name : getConditionEvaluated
	 Description : This method determines if a record meets the condition.
	 Parameters	 : String, called from getConditionEvaluated, strEvaluation Evaluation.
	 Return Type : Boolean
	 */
	private static Boolean getConditionEvaluated(String strEvaluation) {
		Boolean boolResult = false;
		String strEvaluationCleaned;
		List<String> lstValues;
		List<String> lstCleanedValues;

		//First we confirm we received data.
		if(String.isNotBlank(strEvaluation)) {
			strEvaluationCleaned = strEvaluation.toUpperCase();

			//Now we define the type of comparison.
			if(strEvaluationCleaned.startsWith('AND(')) {
				strEvaluationCleaned = strEvaluationCleaned.replace('AND(', '').replace(')', '').replace(' ', '');
				for(String strValue : strEvaluationCleaned.split(',')) {
					if(strValue != 'TRUE' && strValue != 'FALSE') {
						throw new AuraHandledException('Invalid AND values.');
					}
				}
				if(!strEvaluationCleaned.contains('FALSE')) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('OR(')) {
				strEvaluationCleaned = strEvaluationCleaned.replace('OR(', '').replace(')', '').replace(' ', '');
				for(String strValue : strEvaluationCleaned.split(',')) {
					if(strValue != 'TRUE' && strValue != 'FALSE') {
						throw new AuraHandledException('Invalid OR values.');
					}
				}
				if(strEvaluationCleaned.contains('TRUE')) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('EQUALS(')) {
				lstCleanedValues = new List<String>();
				lstValues = strEvaluationCleaned.replace('EQUALS(', '').replace(')', '').split(',');

				//First we check if the values start or end with ' or "; if so, we remove those values.
				for(String strValue : lstValues) {
					lstCleanedValues.add(getValueCleanedUp(strValue));
				}

				//Now we evaluate the fields.
				if(lstCleanedValues.get(0) == lstCleanedValues.get(1)) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('GREATER_THAN(')) {
				lstValues = strEvaluationCleaned.replace('GREATER_THAN(', '').replace(')', '').split(',');
				if(String.isNotBlank(lstValues.get(0)) && String.isNotBlank(lstValues.get(1)) && Decimal.valueOf(lstValues.get(0)) > Decimal.valueOf(lstValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('LESS_THAN(')) {
				lstValues = strEvaluationCleaned.replace('LESS_THAN(', '').replace(')', '').split(',');
				if(String.isNotBlank(lstValues.get(0)) && String.isNotBlank(lstValues.get(1)) && Decimal.valueOf(lstValues.get(0)) < Decimal.valueOf(lstValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('GREATER_OR_EQUAL(')) {
				lstValues = strEvaluationCleaned.replace('GREATER_OR_EQUAL(', '').replace(')', '').split(',');
				if(String.isNotBlank(lstValues.get(0)) && String.isNotBlank(lstValues.get(1)) && Decimal.valueOf(lstValues.get(0)) >= Decimal.valueOf(lstValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('LESS_OR_EQUAL(')) {
				lstValues = strEvaluationCleaned.replace('LESS_OR_EQUAL(', '').replace(')', '').split(',');
				if(String.isNotBlank(lstValues.get(0)) && String.isNotBlank(lstValues.get(1)) && Decimal.valueOf(lstValues.get(0)) <= Decimal.valueOf(lstValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('NOT(')) {
				strEvaluationCleaned = strEvaluationCleaned.replace('NOT(', '').replace(')', '');
				boolResult = !Boolean.valueOf(strEvaluationCleaned);
			} else if(strEvaluationCleaned.startsWith('STARTS(')) {
				lstCleanedValues = new List<String>();
				lstValues = strEvaluationCleaned.replace('STARTS(', '').replace(')', '').split(',');

				//First we check if the values start or end with ' or "; if so, we remove those values.
				for(String strValue : lstValues) {
					lstCleanedValues.add(getValueCleanedUp(strValue));
				}

				//Now we evaluate the fields.
				if(lstCleanedValues.get(0).startsWith(lstCleanedValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('ENDS(')) {
				lstCleanedValues = new List<String>();
				lstValues = strEvaluationCleaned.replace('ENDS(', '').replace(')', '').split(',');

				//First we check if the values start or end with ' or "; if so, we remove those values.
				for(String strValue : lstValues) {
					lstCleanedValues.add(getValueCleanedUp(strValue));
				}

				//Now we evaluate the fields.
				if(lstCleanedValues.get(0).endsWith(lstCleanedValues.get(1))) {
					boolResult = true;
				}
			} else if(strEvaluationCleaned.startsWith('CONTAINS(')) {
				lstCleanedValues = new List<String>();
				lstValues = strEvaluationCleaned.replace('CONTAINS(', '').replace(')', '').split(',');

				//First we check if the values start or end with ' or "; if so, we remove those values.
				for(String strValue : lstValues) {
					lstCleanedValues.add(getValueCleanedUp(strValue));
				}

				//Now we evaluate the fields.
				if(lstCleanedValues.get(0).contains(lstCleanedValues.get(1))) {
					boolResult = true;
				}
			}
		}
		return boolResult;
	}

	/*
	 Method Name : getValueCleanedUp
	 Description : This method cleans up a value to remove the ' and " at the beginning and end of a string.
	 Parameters	 : String, called from getValueCleanedUp, strValue Value.
	 Return Type : String
	 */
	private static String getValueCleanedUp(String strValue) {
		String strCleanedValue = strValue;
		if(strValue.startsWith('\'') && strValue.endsWith('\'')) {
			strCleanedValue = strValue.removeStart('\'');
			strCleanedValue = strCleanedValue.removeEnd('\'');
		} else if(strValue.startsWith('"') && strValue.endsWith('"')) {
			strCleanedValue = strCleanedValue.removeStart('"');
			strCleanedValue = strCleanedValue.removeEnd('"');
		}
		return strCleanedValue;
	}

	/*
	 Method Name : getPlaceholdersReplaced
	 Description : This method replaces the placeholders on the provided data.
	 Parameters	 : SObject, called from getPlaceholdersReplaced, objRecord Record.
	 			   String, called from getPlaceholdersReplaced, strData Criteria.
	 Return Type : String
	 */
	private static String getPlaceholdersReplaced(SObject objRecord, String strData) {
		Integer intIndex;
		String strResult = strData;
		String strReplacement;
		String strFieldOrChildObject;
		Matcher objMatcher;

		//If there's data to review.
		if(objRecord != null && String.isNotBlank(strData)) {

			//We create the RegEx.
			objMatcher = Pattern.compile(STRING_REGEX_EXTRACT_FIELDS_WITH_CHILD_OBJECTS).matcher(strData);

			//Now we find all the occurrences and replace them with the record value.
			while(objMatcher.find()) {
				strReplacement = '';
				strFieldOrChildObject = objMatcher.group().replace('{!', '').replace('}', '').split('\\.').get(0).split('\\[').get(0);

				//First we check if the match is a Field.
				try {
					if(objRecord.get(strFieldOrChildObject) != null) {
						strReplacement = (String) objRecord.get(objMatcher.group().replace('{!', '').replace('}', ''));
					}
				} catch(Exception objExceptionField) {
					if(objRecord.getSObjects(strFieldOrChildObject) != null) {

						//The match is a child object, so first we extract the index.
						intIndex = Integer.valueOf(objMatcher.group().replace('{!', '').replace('}', '').split('\\.').get(0).split('\\[').get(1).split('\\]').get(0));
	
						//Now, we replace the value.
						if(objRecord.getSObjects(strFieldOrChildObject).size() >= intIndex + 1) {
							strReplacement = (String) objRecord.getSObjects(strFieldOrChildObject).get(intIndex).get(objMatcher.group().replace('{!', '').replace('}', '').split('\\.', 2).get(1));
						}
					}
				}
				strResult = strResult.replace(objMatcher.group(), strReplacement);
			}
		}
		return strResult;
	}
}