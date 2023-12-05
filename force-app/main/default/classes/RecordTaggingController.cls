/*
 * Name			:	RecordTaggingController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/15/2021
 * Description	:	Manage Plan Products controller.

 Change History
 ***********************************************************************************************************************
 Modified By			Date			Jira No.		Description													Tag
 ***********************************************************************************************************************
 Monserrat Pedroza		6/15/2021		N/A				Initial version.											N/A
 Vignesh Divakaran		10/24/2023		I2RT-8841		Added new method to show P0 topic based on whether 			T01
 														P0 is enabled on the case.
 */
public without sharing class RecordTaggingController {

	/*
	 Method Name : getRecords
	 Description : This method returns the tags related to the given record id and child relationship.
	 Parameters	 : String, called from getRecords, idRecord Record Id.
	 			   String, called from getRecords, strChildRelationship Account Id.
	 Return Type : List of Tags.
	 */
    @AuraEnabled(cacheable = false)
    public static List<Topic> getRecords(Id idRecord, String strChildRelationship) {
		String strObject;
		String strLookupField;
		Set<Id> setParentIds = new Set<Id> {
			idRecord
		};
		Set<String> setTerms = new Set<String>();
		List<Topic> lstResults = new List<Topic>(); //<T01>
		List<Record_Tagging__mdt> lstRecordTaggings = [SELECT Term__c, Display_Text__c, Field__c, DeveloperName FROM Record_Tagging__mdt LIMIT 50000]; //<T01>
		strChildRelationship = GlobalUtility.escapeSingleQuotes(strChildRelationship); //<T01>

		//Now query all the child records, if required.
		if(String.isNotBlank(strChildRelationship)) {
			strObject = strChildRelationship.split('\\.')[0];
			strLookupField = strChildRelationship.split('\\.')[1];
			for(SObject objRecord : Database.query('SELECT Id FROM ' + strObject + ' WHERE ' + strLookupField + ' = :idRecord LIMIT 50000')) {
				setParentIds.add((Id) objRecord.get('Id'));
			}
		}

		//We get all the available topics.
		for(Record_Tagging__mdt objRecord : lstRecordTaggings) { //<T01>
			setTerms.add(objRecord.Term__c);
			if(String.isNotBlank(objRecord.Display_Text__c)) {
				setTerms.add(objRecord.Display_Text__c);
			}
		}

		//Now we query the Topics.
		for(AggregateResult objRecord : [SELECT TopicId Id, Topic.Name Name FROM TopicAssignment WHERE EntityId IN :setParentIds AND Topic.Name IN :setTerms GROUP BY TopicId, Topic.Name LIMIT 50000]){
			lstResults.add(new Topic(Id = (Id) objRecord.get('Id'), Name = (String) objRecord.get('Name'))); //<T01>
		}

		if(idRecord.getSObjectType().getDescribe().getName() == 'Case'){ //<T01>
			setP0Topic(idRecord, lstResults, lstRecordTaggings);
		}

		//We return the results.
		return lstResults;
	}

	/*
	 Method Name : setP0Topic
	 Description : This method adds P0 topic based on whether P0 is enabled on the case.
	 Parameters	 : String, called from getRecords, idRecord Record Id.
	 			   List of Topics, called from getRecords, lstTopics.
	 			   List of Record Taggings, called from getRecords, lstRecordTaggings.
	 Return Type : None.
	 */
	private static void setP0Topic(Id idRecord, List<Topic> lstTopics, List<Record_Tagging__mdt> lstRecordTaggings){ //<T01>
		String strTerm = '';
		Boolean boolIsTopicFound = false;
		Boolean boolIsP0Enabled = [SELECT P0_Enabled_By__c FROM Case WHERE Id = :idRecord AND P0_Enabled_By__c != null WITH SECURITY_ENFORCED LIMIT 1]?.P0_Enabled_By__c != null;

		//Now, we get the P0 topic from the metadata
		for(Record_Tagging__mdt objRecord : lstRecordTaggings) {
			if(objRecord.DeveloperName == System.Label.get('', 'Record_Tagging_P0_Metadata_Name', '')){
				strTerm = objRecord?.Term__c;
				break;
			}
		}

		//Now, we check the list of topics to see it contains the P0 topic
		for(Topic objTopic : lstTopics) {
			if(objTopic.Name == strTerm && String.isNotBlank(strTerm)) {

				//We remove the P0 topic
				if(!boolIsP0Enabled){
					lstTopics.remove(lstTopics.indexOf(objTopic));
				}
				boolIsTopicFound = true;
				break;
			}
		}

		//Now, we add the P0 topic
		if(boolIsP0Enabled && !boolIsTopicFound){
			lstTopics.add(new Topic(Id = null, Name = strTerm));
		}
	}
}