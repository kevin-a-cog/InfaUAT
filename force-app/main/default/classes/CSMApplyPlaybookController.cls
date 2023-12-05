/*
 * Name			:	CSMApplyPlaybookController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/17/2021
 * Description	:	Make Playbook controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/17/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMApplyPlaybookController {

	//Public variables.
	public static Map<String, Schema.SObjectField> objSchemaObjective = Schema.SObjectType.Objective__c.fields.getMap();
	public static Map<String, Schema.SObjectField> objSchemaMilestone = Schema.SObjectType.Milestone__c.fields.getMap();
	public static Map<String, Schema.SObjectField> objSchemaInterlock = Schema.SObjectType.Related_Opportunity_Plan__c.fields.getMap();
	public static Map<String, Schema.SObjectField> objSchemaEngagement = Schema.SObjectType.Engagement__c.fields.getMap();
	public static Map<String, Schema.SObjectField> objSchemaTask = Schema.SObjectType.Task.fields.getMap();

	/*
	 Method Name : getRecords
	 Description : This method returns the Plan records under the same Account.
	 Parameters	 : None
	 Return Type : Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords() {
		String strObjectName = Plan__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

		//Now we get the table details.
		objDataTable.strObjectName = strObjectName;
		objDataTable.strFielSetName = 'Create_Playbook_Table';
		objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

		//Now we prepare the response.
		objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
                ' WHERE Is_Template__c = true ORDER BY Status__c ASC LIMIT 1000');
		return objDataTable;
	}

	/*
	 Method Name : getFilterFields
	 Description : This method returns a list of API Names to be used as filters.
	 Parameters	 : None
	 Return Type : Map<String, String>
	 */
    @AuraEnabled(cacheable = false)
    public static Map<String, String> getFilterFields() {
		Map<String, String> mapResults = new Map<String, String>();
		for(Schema.FieldSetMember objField : Schema.getGlobalDescribe().get(Plan__c.class.getName()).getDescribe().FieldSets.getMap().get('Create_Playbook_Table_Filters').getFields()) {
			if(!objField.getSObjectField().getDescribe().isCalculated()) {
				mapResults.put(objField.getFieldPath(), objField.getLabel());
			}
		}
		return mapResults;
	}

	/*
	 Method Name : getSelectedRecordsCloned
	 Description : This method clones and saves the provided records.
	 Parameters	 : String, called from getSelectedRecordsCloned, strParentRecordId Parent Record Id.
	 			   List, called from getSelectedRecordsCloned, lstBuckets List of records.
	 Return Type : None
	 */
    @AuraEnabled(cacheable = false)
    public static void getSelectedRecordsCloned(String strParentRecordId, List<CSMBucketWrapper> lstBuckets) {
		Boolean boolHasPreSelectedObjectiveId = false;
		Boolean boolHasPreSelectedMilestoneId = false;
		sObject objClonedRecord;
		Objective__c objObjective;
		List<String> lstFields;
		List<String> lstRecordIds;
		List<String> lstObjects = new List<String>();
		List<Clone_Engine__c> lstCloneEngineRecords;
		List<Objective__c> lstObjectives = new List<Objective__c>();
		List<Milestone__c> lstMilestones = new List<Milestone__c>();
		List<Related_Opportunity_Plan__c> lstInterlocks = new List<Related_Opportunity_Plan__c>();
		List<Engagement__c> lstEngagements = new List<Engagement__c>();
		List<Task> lstTasks = new List<Task>();
		Map<String, Schema.SObjectField> mapSchema;
		Map<String, List<String>> mapFields = new Map<String, List<String>>();
		Map<String, List<Clone_Engine__c>> mapRules = new Map<String, List<Clone_Engine__c>>();

		//We set the default values.
		lstObjects.add('Objective__c');
		lstObjects.add('Milestone__c');
		lstObjects.add('Related_Opportunity_Plan__c');
		lstObjects.add('Engagement__c');
		lstObjects.add('Task');
		mapFields.put('Milestone__c', new List<String> {
			'Objective__c'
		});
		mapFields.put('Related_Opportunity_Plan__c', new List<String> {
			'Milestone__c'
		});
		mapFields.put('Engagement__c', new List<String> {
			'Milestone__c'
		});
		mapFields.put('Task', new List<String> {
			'WhatId'
		});

		//Now, we sort the list.
		lstBuckets.sort();

		//Now we fetch the rules.
		for(Clone_Engine__c objRecord : [SELECT Object__c, Field__c, Type__c, Subtype__c, Value__c FROM Clone_Engine__c WHERE Flows__c INCLUDES ('Apply Template') AND Active__c = TRUE AND 
                Object__c IN :lstObjects LIMIT 1000]) {
			
			//First we save the fields.
			if(mapFields.get(objRecord.Object__c) == null) {
				mapFields.put(objRecord.Object__c, new List<String>());
			}
			lstFields = mapFields.get(objRecord.Object__c);
			if(!lstFields.contains(objRecord.Field__c)) {
				lstFields.add(objRecord.Field__c);
			}

			//We check in case the rule requires an additional field.
			if(objRecord.Subtype__c == 'Field reference' && !lstFields.contains(objRecord.Value__c)) {
				lstFields.add(objRecord.Value__c);
			}

			//Now we save the field.
			mapFields.put(objRecord.Object__c, lstFields);

			//Now we save the rules.
			if(mapRules.get(objRecord.Object__c) == null) {
				mapRules.put(objRecord.Object__c, new List<Clone_Engine__c>());
			}
			lstCloneEngineRecords = mapRules.get(objRecord.Object__c);
			lstCloneEngineRecords.add(objRecord);
			mapRules.put(objRecord.Object__c, lstCloneEngineRecords);
		}

		//Now we fetch the data to be cloned.
		for(CSMBucketWrapper objBucket : lstBuckets) {
			lstRecordIds = objBucket.lstRecordIds;

			//We only query the data if we have a set of cloning rules.
			if(mapFields.get(objBucket.strObjectName) != null) {

				//If we received preselections, we replace the provided list of ids.
				if(String.isNotBlank(objBucket.strPreSelectedObjectiveId) && objBucket.strObjectName == 'Objective__c') {
					lstRecordIds = new List<String>();
					lstRecordIds.add(objBucket.strPreSelectedObjectiveId);
					boolHasPreSelectedObjectiveId = true;
				} else if(String.isNotBlank(objBucket.strPreSelectedMilestoneId) && objBucket.strObjectName == 'Milestone__c') {
					lstRecordIds = new List<String>();
					lstRecordIds.add(objBucket.strPreSelectedMilestoneId);
					boolHasPreSelectedMilestoneId = true;
				}

				//First we query the data.
				for(sObject objRecord : Database.query('SELECT ' + String.join(mapFields.get(objBucket.strObjectName), ', ') + ' FROM ' + objBucket.strObjectName + 
                        ' WHERE Id IN :lstRecordIds LIMIT 1000')) {
					mapSchema = null;
					objRecord.put('Cloned_From__c', objRecord.get('Id'));
					objRecord.put('Id', null);
					if(objBucket.strObjectName == 'Objective__c') {
						mapSchema = objSchemaObjective;
					} else if(objBucket.strObjectName == 'Milestone__c') {
						mapSchema = objSchemaMilestone;
					} else if(objBucket.strObjectName == 'Related_Opportunity_Plan__c') {
						mapSchema = objSchemaInterlock;
					} else if(objBucket.strObjectName == 'Engagement__c') {
						mapSchema = objSchemaEngagement;
					} else if(objBucket.strObjectName == 'Task') {
						mapSchema = objSchemaTask;
					}
					objClonedRecord = applyRule(mapSchema, mapRules.get(objBucket.strObjectName), objRecord);

					//Now we save it in the right list.
					if(objClonedRecord != null) {
						if(objBucket.strObjectName == 'Objective__c') {
							if(boolHasPreSelectedObjectiveId) {
								objClonedRecord.put('Id', objBucket.strPreSelectedObjectiveId);
							}
							lstObjectives.add((Objective__c) objClonedRecord);
						} else if(objBucket.strObjectName == 'Milestone__c') {
							if(String.isNotBlank(objBucket.strPreSelectedObjectiveId)) {
								objClonedRecord.put('Objective__c', objBucket.strPreSelectedObjectiveId);
							}
							if(boolHasPreSelectedMilestoneId) {
								objClonedRecord.put('Id', objBucket.strPreSelectedMilestoneId);
							}
							lstMilestones.add((Milestone__c) objClonedRecord);
						} else if(objBucket.strObjectName == 'Related_Opportunity_Plan__c') {
							if(String.isNotBlank(objBucket.strPreSelectedMilestoneId)) {
								objClonedRecord.put('Milestone__c', objBucket.strPreSelectedMilestoneId);
							}
							lstInterlocks.add((Related_Opportunity_Plan__c) objClonedRecord);
						} else if(objBucket.strObjectName == 'Engagement__c') {
							if(String.isNotBlank(objBucket.strPreSelectedMilestoneId)) {
								objClonedRecord.put('Milestone__c', objBucket.strPreSelectedMilestoneId);
							}
							lstEngagements.add((Engagement__c) objClonedRecord);
						} else if(objBucket.strObjectName == 'Task') {
							if(String.isNotBlank(objBucket.strPreSelectedMilestoneId)) {
								objClonedRecord.put('WhatId', objBucket.strPreSelectedMilestoneId);
							}
							lstTasks.add((Task) objClonedRecord);
						}
					}
				}
			}
		}

		//Now we insert the Objectives first.
		if(!lstObjectives.isEmpty() && !boolHasPreSelectedObjectiveId) {
			for(Objective__c objRecord : lstObjectives) {
				objRecord.Plan__c = strParentRecordId;
			}
			insert lstObjectives;
		}

		//Now, before inserting Milestones, we replace the Objective.
		if(!lstMilestones.isEmpty() && !boolHasPreSelectedMilestoneId) {
			for(Milestone__c objRecord : lstMilestones) {
				for(Objective__c objChildRecord : lstObjectives) {
					if(objRecord.Objective__c == objChildRecord.Cloned_From__c) {
						objRecord.Objective__c = objChildRecord.Id;
						objRecord.Plan__c = strParentRecordId;
						break;
					}
				}
			}
			insert lstMilestones;
		}

        //Now, before inserting Interlocks, we replace the Milestone. We removed the Insert operation, as it is not needed.
		if(!lstInterlocks.isEmpty()) {
			for(Related_Opportunity_Plan__c objRecord : lstInterlocks) {
				for(Milestone__c objChildRecord : lstMilestones) {
					if(objRecord.Milestone__c == objChildRecord.Cloned_From__c) {
						objRecord.Milestone__c = objChildRecord.Id;
						objRecord.Plan__c = strParentRecordId;
						break;
					}
				}
			}
		}

		//Now, before inserting Engagements, we replace the Milestone.
		if(!lstEngagements.isEmpty()) {
			for(Engagement__c objRecord : lstEngagements) {
				for(Milestone__c objChildRecord : lstMilestones) {
					if(objRecord.Milestone__c == objChildRecord.Cloned_From__c) {
						objRecord.Milestone__c = objChildRecord.Id;
						objRecord.Plan__c = strParentRecordId;
						break;
					}
				}
			}
			insert lstEngagements;
		}

		//Now, before inserting Tasks, we replace the Milestone.
		if(!lstTasks.isEmpty()) {
			for(Task objRecord : lstTasks) {
				for(Milestone__c objChildRecord : lstMilestones) {
					if(objRecord.WhatId == objChildRecord.Cloned_From__c) {
						objRecord.WhatId = objChildRecord.Id;
						break;
					}
				}
			}
			insert lstTasks;
		}
	}

	/*
	 Method Name : applyRule
	 Description : This method applies the provided rules to the provided record.
	 Parameters	 : Map, called from applyRule, mapSchema Schema.
				   List, called from applyRule, lstCloneEngineRecords Rules.
	 			   Object, called from applyRule, objRecord Record.
	 Return Type : Object
	 */
    public static sObject applyRule(Map<String, Schema.SObjectField> mapSchema, List<Clone_Engine__c> lstCloneEngineRecords, sObject objRecord) {
		String strValue;
		Object objValue;
		Schema.DisplayType objType;

		//If we received rules.
		if(lstCloneEngineRecords != null && !lstCloneEngineRecords.isEmpty()) {
			for(Clone_Engine__c objRule : lstCloneEngineRecords) {
				
				//If we need to clear the value.
				if(objRule.Type__c == 'Clear value') {
					objRecord.put(objRule.Field__c, null);
				} else if(objRule.Type__c == 'New value') {

					//If we want a formula.
					if(objRule.Subtype__c == 'Formula') {
						if(objRule.Value__c == 'TODAY()') {
							objRecord.put(objRule.Field__c, System.today());
						} else if(objRule.Value__c == 'NOW()') {
							objRecord.put(objRule.Field__c, DateTime.now());
						}
					} else {

						//If we want a new static value.
						if(objRule.Subtype__c == 'Static') {
							objValue = objRule.Value__c;
						} else if(objRule.Subtype__c == 'Field reference') {

							//If we want a field reference.
							objValue = extractValueRecursively(objRecord, objRule.Value__c);
						}
						strValue = String.valueOf(objValue);

						//Now, depending on the type of field, we set the value.
						objType = mapSchema.get(objRule.Field__c).getDescribe().getType();
						if(objType == Schema.DisplayType.Boolean) {
							objRecord.put(objRule.Field__c, Boolean.valueOf(strValue));
						} else if(objType == Schema.DisplayType.Date) {
							objRecord.put(objRule.Field__c, Date.valueOf(strValue));
						} else if(objType == Schema.DisplayType.DateTime) {
							objRecord.put(objRule.Field__c, DateTime.valueOf(strValue));
						} else if(objType == Schema.DisplayType.Double || objType == Schema.DisplayType.Long || objType == Schema.DisplayType.Percent) {
							objRecord.put(objRule.Field__c, Double.valueOf(strValue));
						} else {
							objRecord.put(objRule.Field__c, strValue);
						}
					}
				}
			}
		}
		return objRecord;
	}

	/*
	 Method Name : extractValueRecursively
	 Description : This method extracts a value recursively, from a parent-child relationship.
	 Parameters	 : Object, called from extractValueRecursively, objParent Parent sObject.
	 			   String, called from extractValueRecursively, strPath Relationship path.
	 Return Type : Object
	 */
    public static Object extractValueRecursively(sObject objParent, String strPath) {
		String strCurrentLevel;
		String strRestOfLevel;
		Object objValue;
		List<String> lstPaths = new List<String>();
		if(strPath.contains('.')) {
			for(String strLevel : strPath.split('\\.')) {
				if(String.isBlank(strCurrentLevel)) {
					strCurrentLevel = strLevel;
				} else {
					lstPaths.add(strLevel);
				}
			}
			strRestOfLevel = String.join(lstPaths, '.');
			objValue = extractValueRecursively(objParent.getSObject(strCurrentLevel), strRestOfLevel);
		} else {
			objValue = objParent.get(strPath);
		}
		return objValue;
	}
}