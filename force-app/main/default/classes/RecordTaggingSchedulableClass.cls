/*
 * Name			:	RecordTaggingSchedulableClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/16/2023
 * Description	:	Class that tags records.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		2/16/2023		N/A				Initial version.						N/A
 Vignesh Divakaran		11/13/2023		I2RT-9487		Create TopicAssignment for all records	T01
 */
global class RecordTaggingSchedulableClass implements Schedulable {

	//Private variables.
	private Set<String> setAlreadyTaggedRecordIds;
	private List<Record_Tagging__mdt> lstRules;
	private List<Tagged_Record__c> lstExistingTaggedRecords;
	private Map<String, String> mapTaggedRecordIds;
	private Map<String, Map<String, String>> mapQueries;

	/*
	 Method Name : execute
	 Description : This method starts the scheduled class.
	 Parameters	 : Object, called from execute, objContext Schedule context.
	 Return Type : None
	 */
    global void execute(SchedulableContext objContext) {
		String strBaseQuery = 'SELECT Id FROM {{Object}} WHERE Id IN :lstIds AND ({{filters}}) LIMIT 50000';
		String strQuery;

		//We initialize the variables.
		setAlreadyTaggedRecordIds = new Set<String>();
		mapQueries = new Map<String, Map<String, String>>();

		//We query the shared records.
		lstRules = [SELECT Id, Object__c, Term__c, Display_Text__c, Field__c, Tagging_Conditions__c, Removing_Conditions__c FROM Record_Tagging__mdt WHERE Active__c = TRUE LIMIT 50000];
		lstExistingTaggedRecords = [SELECT Id, Record_Id__c, Topic_Name__c, Tagging_Logic__c FROM Tagged_Record__c ORDER BY CreatedDate DESC LIMIT 50000];
		if(lstRules == null) {
			lstRules = new List<Record_Tagging__mdt>();
		}
		if(lstExistingTaggedRecords == null) {
			lstExistingTaggedRecords = new List<Tagged_Record__c>();
		}

		//Now we prepare the data for adding and removing.
		for(Tagged_Record__c objRecord : lstExistingTaggedRecords) {
			setAlreadyTaggedRecordIds.add(objRecord.Record_Id__c);

			//Now we save the queries.
			for(Record_Tagging__mdt objRuleRecord : lstRules) {
				if(objRecord.Tagging_Logic__c == objRuleRecord.Id && String.isNotBlank(objRuleRecord.Removing_Conditions__c)) {
					strQuery = strBaseQuery.replace('{{Object}}', objRuleRecord.Object__c).replace('{{filters}}', objRuleRecord.Removing_Conditions__c);
					if(mapQueries.get(strQuery) == null) {
						mapQueries.put(strQuery, new Map<String, String>());
					}
					mapTaggedRecordIds = mapQueries.get(strQuery);
					mapTaggedRecordIds.put(objRecord.Id, objRecord.Record_Id__c);
					mapQueries.put(strQuery, mapTaggedRecordIds);
				}
			}
		}

		//First we add the new tags.
		addTagging();

		//Now we remove existing tags.
		removeTagging();
    }

	/*
	 Method Name : addTagging
	 Description : This method adds the tags to the records.
	 Parameters	 : None
	 Return Type : None
	 */
    private void addTagging() {
		String strQuery;
		String strTaggingConditions;
		String strTag;
		String strFieldValue;
		String strTerms = '';
		Topic objTopic;
		Tagged_Record__c objTaggedRecord;
		Set<String> setObjects = new Set<String>();
		Set<String> setTerms = new Set<String>();
		List<String> lstObjects = new List<String>();
		List<String> lstTerms = new List<String>();
		List<Topic> lstTopics = new List<Topic>();
		List<TopicAssignment> lstTopicAssignments; //<T01>
		List<TopicAssignment> lstTopicAssignmentsToInsert = new List<TopicAssignment>(); //<T01>
		List<Tagged_Record__c> lstRecordsToInsert = new List<Tagged_Record__c>();
		Map<String, Id> mapTopics = new Map<String, Id>();
		Map<String, List<TopicAssignment>> mapTopicAssignments = new Map<String, List<TopicAssignment>>();
        
		//First we extract the existing active rules.
		if(!lstRules.isEmpty()) {

			//Now we get the rules.
			for(Record_Tagging__mdt objRecord : lstRules) {
				strTaggingConditions = '';

				//We create the base tagging conditions.
				strQuery = objRecord.Object__c + '(Id, ' + objRecord.Field__c + ' WHERE Id NOT IN :setAlreadyTaggedRecordIds{{filters}})';

				//If we have extra conditions, we add them.
				if(String.isNotBlank(objRecord.Tagging_Conditions__c)) {
					strTaggingConditions = ' AND (' + objRecord.Tagging_Conditions__c + ')';
				}

				//Now we prepare the queries.
				setObjects.add(strQuery.replace('{{filters}}', strTaggingConditions));
				setTerms.add(objRecord.Term__c);
			}

			//Now we collect the terms.
			lstObjects.addAll(setObjects);
			lstTerms.addAll(setTerms);
			strTerms = String.join(lstTerms, ' OR ');

			//Now we execute the search.
			for(List<SObject> lstGroups : Search.query('FIND :strTerms IN ALL FIELDS RETURNING ' + String.join(lstObjects, ',') + ' LIMIT 2000')) {
				for(SObject objRecord : lstGroups) {

					//Now we iterate over the rules to see if there are any matches.
					for(Record_Tagging__mdt objRule : lstRules) {
						if(objRecord.getSObjectType().getDescribe().getName() == objRule.Object__c && objRecord.get(objRule.Field__c) != null) {
							strFieldValue = (String) objRecord.get(objRule.Field__c);

							//If the field contains the term.
							if(strFieldValue.containsIgnoreCase(objRule.Term__c)) {

								//We generate the Topic and Assignment to upsert.
								TopicAssignment objTopicAssignment = new TopicAssignment();
								objTopicAssignment.EntityId = (Id) objRecord.get('Id');
								if(String.isNotBlank(objRule.Display_Text__c)) {
									strTag = objRule.Display_Text__c;
								} else {
									strTag = objRule.Term__c;
								}
								mapTopics.put(strTag, null);
								lstTopicAssignments = mapTopicAssignments.containsKey(strTag) ? mapTopicAssignments.get(strTag) : new List<TopicAssignment>(); //<T01>
								lstTopicAssignments.add(objTopicAssignment); //<T01>
								mapTopicAssignments.put(strTag, lstTopicAssignments); //<T01>

								//We save the tagged record.
								objTaggedRecord = new Tagged_Record__c();
								objTaggedRecord.Record_Id__c = (String) objRecord.get('Id');
								objTaggedRecord.Tagging_Logic__c = objRule.Id;
								objTaggedRecord.Topic_Name__c = strTag;
								lstRecordsToInsert.add(objTaggedRecord);
							}
						}
					}
				}
			}

			//If we have Items to insert, we do it.
			if(!mapTopics.isEmpty()) {

				//First we look for existing Topics.
				for(Topic objRecord : [SELECT Id, Name FROM Topic WHERE Name IN :mapTopics.keySet() LIMIT 50000]) {
					mapTopics.put(objRecord.Name, objRecord.Id);
				}
				for(String strTopicName : mapTopics.keySet()) {
					if(mapTopics.get(strTopicName) == null) {
						objTopic = new Topic();
						objTopic.Name = strTopicName;
						lstTopics.add(objTopic);
					}
				}

				//Now we insert them, if any.
				if(!lstTopics.isEmpty()) {
					Database.insert(lstTopics, false);
				}
				
				//Now we insert the topic assignments.
				for(String strTopicName : mapTopicAssignments.keySet()) {
					for(TopicAssignment objTopicAssignment : mapTopicAssignments.get(strTopicName)){ //<T01>
						objTopicAssignment.TopicId = mapTopics.get(strTopicName);
						if(objTopicAssignment.TopicId == null) {
							for(Topic objInsertedTopic : lstTopics) {
								if(objInsertedTopic.Name == strTopicName) {
									objTopicAssignment.TopicId = objInsertedTopic.Id;
								}
							}
						}
					}
					lstTopicAssignmentsToInsert.addAll(mapTopicAssignments.get(strTopicName)); //<T01>
				}
				Database.insert(lstTopicAssignmentsToInsert, false);

				//We also update the related records.
				Database.insert(lstRecordsToInsert, false);
			}
		}
    }

	/*
	 Method Name : addTagging
	 Description : This method removes the tags from the records.
	 Parameters	 : None
	 Return Type : None
	 */
    private void removeTagging() {
		Id idRecord;
		Tagged_Record__c objTaggedRecod;
		List<String> lstIds;
		List<TopicAssignment> lstTopicAssignmentsToDelete = new List<TopicAssignment>();
		List<Tagged_Record__c> lstRecordsToDelete = new List<Tagged_Record__c>();
		Map<String, String> mapRecords;
		Map<String, String> mapTopicsToRemove = new Map<String, String>();

		//We iterate the queries to check if the tags should be removed.
		if(!mapQueries.isEmpty()) {
			if(Limits.getQueries() <= Limits.getLimitQueries() - 1) {
				for(String strQuery : mapQueries.keySet()) {

					//We get the records to check.
					mapRecords = mapQueries.get(strQuery);
					lstIds = mapRecords.values();
	
					//Now we do the query, and if the record matches, we will remove the tag.
					for(SObject objRecord : Database.query(strQuery)) {
						for(String strTaggedRecordId : mapRecords.keySet()) {
							idRecord = (Id) objRecord.get('Id');
							if(mapRecords.get(strTaggedRecordId) == idRecord) {
								objTaggedRecod = new Tagged_Record__c();
								objTaggedRecod.Id = strTaggedRecordId;
								lstRecordsToDelete.add(objTaggedRecod);
	
								//We also prepare the topics to remove.
								for(Tagged_Record__c objExistingTaggedRecord : lstExistingTaggedRecords) {
									if(objExistingTaggedRecord.Id == strTaggedRecordId) {
										mapTopicsToRemove.put(idRecord, objExistingTaggedRecord.Topic_Name__c);
									}
								}
							}
						}
					}
				}
			}

			//If we have topics to remove.
			if(!mapTopicsToRemove.isEmpty()) {
				for(TopicAssignment objRecord : [SELECT Id, EntityId, Topic.Name FROM TopicAssignment WHERE EntityId IN :mapTopicsToRemove.keySet() AND 
						Topic.Name IN :mapTopicsToRemove.values() LIMIT 50000]) {
					for(String strRecordId : mapTopicsToRemove.keySet()) {
						if(objRecord.EntityId == strRecordId && objRecord.Topic.Name == mapTopicsToRemove.get(strRecordId)) {
							lstTopicAssignmentsToDelete.add(objRecord);
						}
					}
				}

				//If we have topic assignments to delete, we do it.
				if(!lstTopicAssignmentsToDelete.isEmpty()) {
					Database.delete(lstTopicAssignmentsToDelete, false);
				}
			}
		}
	}
}