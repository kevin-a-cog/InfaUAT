/*
 * Name			:	RecordTaggingTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/16/2022
 * Description	:	Test class for Record Tagging functionality.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description									Tag
 **********************************************************************************************************
 Monserrat Pedroza		2/16/2022		N/A				Initial version.							N/A
 Vignesh Divakaran		2/16/2022		I2RT-8841		Changed run as user to loggedin user		T01
 */
@isTest(seeAllData = false)
public with sharing class RecordTaggingTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Case_Comment__c objCaseComment;
		List<Case_Comment__c> lstCaseComments = new List<Case_Comment__c>();

		//Now we create a Case.
		Case objCase = new Case();
		objCase.Priority = 'P1';
		objCase.Status = 'Solution';
		insert objCase;
		
		//Now we create a Case Comment.
		for(Record_Tagging__mdt objRecord : [SELECT Object__c, Term__c, Field__c FROM Record_Tagging__mdt WHERE Active__c = TRUE LIMIT 50000]) {
			objCaseComment = new Case_Comment__c();
			objCaseComment.Comment__c = objRecord.Term__c;
			objCaseComment.Case__c = objCase.Id;
			lstCaseComments.add(objCaseComment);
		}
		for(Record_Tagging__mdt objRecord : [SELECT Object__c, Term__c, Field__c FROM Record_Tagging__mdt WHERE Active__c = TRUE LIMIT 50000]) {
			objCaseComment = new Case_Comment__c();
			objCaseComment.Comment__c = objRecord.Term__c;
			objCaseComment.Case__c = objCase.Id;
			lstCaseComments.add(objCaseComment);
		}
		insert lstCaseComments;
    }
	
	/*
	 Method Name : testRecordFetching
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetching() {
        System.runAs(new User(Id = UserInfo.getUserId())) { //<T01>
			Case objCase = [SELECT Id FROM Case LIMIT 1];
			Case_Comment__c objCaseComment;
			List<Case_Comment__c> lstCaseComments = new List<Case_Comment__c>();
			RecordTaggingSchedulableClass objScheduledClass = new RecordTaggingSchedulableClass();
			List<Id> lstIds = new List<Id>();

			//We look for Case Comment Ids.
			for(Case_Comment__c objRecord : [SELECT Id FROM Case_Comment__c]) {
				lstIds.add(objRecord.Id);
			}

			//Now we test the method.
			Test.startTest();
       		Test.setFixedSearchResults(lstIds);
			objScheduledClass.execute(null);
            System.assertNotEquals(RecordTaggingController.getRecords(objCase.Id, 'Case_Comment__c.Case__c') == null, true, 'Unable to get records.');
			for(Record_Tagging__mdt objRecord : [SELECT Object__c, Term__c, Field__c FROM Record_Tagging__mdt WHERE Active__c = TRUE LIMIT 50000]) {
				objCaseComment = new Case_Comment__c();
				objCaseComment.Comment__c = objRecord.Term__c;
				objCaseComment.Case__c = objCase.Id;
				lstCaseComments.add(objCaseComment);
			}
			insert lstCaseComments;
			objScheduledClass = new RecordTaggingSchedulableClass();
			objScheduledClass.execute(null);

			//Now we update the case.
			objCase.Priority = 'P2';
			Database.update(objCase, false);
			objScheduledClass = new RecordTaggingSchedulableClass();
			objScheduledClass.execute(null);
			Test.stopTest();
        }
    }
}