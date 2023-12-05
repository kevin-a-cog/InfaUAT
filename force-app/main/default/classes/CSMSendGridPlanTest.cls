/*
 * Name         :   CSMSendGridPlanTest
 * Author       :   Monserrat Pedroza
 * Created Date :   12/22/2021
 * Description  :   SendGrid test class for Cosmos.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      12/22/2021      N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMSendGridPlanTest {

    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        //Inserting Account.
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.BillingCountry = 'Test';
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        insert objAccount;

        //Now we create a Contact.
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.Email = 'test@test.com';
        insert objContact;

        //Now we create a Plan.
        Plan__c objPlan = new Plan__c();
        objPlan.Name = 'TestNew';
        objPlan.Sub_Stage__c = 'On-board';
        objPlan.Is_Template__c = false;
        objPlan.Account__c = objAccount.Id;
        insert objPlan;

        //Now we create the Objective.
        Objective__c objObjective = new Objective__c();
        objObjective.Is_Template__c = true;
        objObjective.Plan__c = objPlan.Id;
        insert objObjective;

        //Now we create the Milestone.
        Milestone__c objMilestone = new Milestone__c();
        objMilestone.Objective__c = objObjective.Id;
        objMilestone.Plan__c = objPlan.Id;
        objMilestone.Planned_Completion_Date__c = System.today();
        insert objMilestone;

        //Inserting Plan Comment.
        Plan_Comment__c objPlanComment = new Plan_Comment__c();
        objPlanComment.Comment__c = 'test';
        objPlanComment.Visibility__c = 'External';
        objPlanComment.Status__c = 'Submitted';
        objPlanComment.Plan__c = objPlan.Id;
        insert objPlanComment;

        //Inserting Plan Contact.
        Plan_Contact__c objPlanContact = new Plan_Contact__c();
        objPlanContact.Plan__c = objPlan.Id;
        objPlanContact.Contact__c = objContact.Id;
        objPlanContact.Recieve_Email__c = true;
        objPlanComment.Visibility__c = 'External';
        objPlanComment.Status__c = 'Submitted';
        insert objPlanContact;

        //Inserting an attachment.
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.ContentLocation = 'S';
        objContentVersion.PathOnClient = 'testing.txt';
        objContentVersion.Title = 'Testing Files';
        objContentVersion.VersionData = EncodingUtil.base64Decode('test');
        insert objContentVersion;
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        objContentDocumentLink.LinkedEntityId = objPlanComment.Id;
        objContentDocumentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id].ContentDocumentId;
        objContentDocumentLink.shareType = 'V';
        insert objContentDocumentLink;
    }
    
    /*
     Method Name : testSendGridResponse
     Description : Testing SendGrid response
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testSendGridResponse() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan_Comment__c objPlanComment = [SELECT Id FROM Plan_Comment__c LIMIT 1];
            RestRequest objRequest = new RestRequest();
            RestContext.response = new RestResponse();

            //Setting the initial request.
            objRequest.requestURI = '/services/apexrest/SendgridResponse';
            objRequest.httpMethod = 'POST';
            objRequest.requestBody = Blob.valueof('[' + 
            '   {' + 
            '       "ccid": "' + objPlanComment.Id + '",' + 
            '       "sg_event_id": "Event Id 4",' + 
            '       "sg_message_id": "Message Id 3",' + 
            '       "timestamp": "Timestamp 3",' + 
            '       "email": "test@test.com3",' + 
            '       "event": "delivered"' + 
            '   }' + 
            ']');
            RestContext.request = objRequest;

            //Now we start the testing.
            Test.startTest();

            //We send the request.
            SendgridResponse.doPost();

            //We also test Open action.
            objRequest.requestBody = Blob.valueof('[' + 
            '   {' + 
            '       "ccid": "' + objPlanComment.Id + '",' + 
            '       "sg_event_id": "Event Id 4",' + 
            '       "sg_message_id": "Message Id 3",' + 
            '       "timestamp": "Timestamp 3",' + 
            '       "email": "test@test.com3",' + 
            '       "event": "open"' + 
            '   }' + 
            ']');
            RestContext.request = objRequest;
            SendgridResponse.doPost();

            //We also test Click action.
            objRequest.requestBody = Blob.valueof('[' + 
            '   {' + 
            '       "ccid": "' + objPlanComment.Id + '",' + 
            '       "sg_event_id": "Event Id 4",' + 
            '       "sg_message_id": "Message Id 3",' + 
            '       "timestamp": "Timestamp 3",' + 
            '       "email": "test@test.com3",' + 
            '       "event": "click"' + 
            '   }' + 
            ']');
            RestContext.request = objRequest;
            SendgridResponse.doPost();
            list<account> acc = [select id,name from account limit 1];
            //Now we test the inner wrapper class.
            SendGridWrapper.Dynamictemplate objWrapper = new SendGridWrapper.Dynamictemplate();
            objWrapper.name = 'test case';
            objWrapper.casenumber= 'CS123345';
            objWrapper.EngineerName= 'test Eng Name';
            objWrapper.todaydate = system.today();
            objWrapper.emailbody = 'test Email body';
            objWrapper.timezone = 'US';
            objWrapper.subject = 'test Sub';
            objWrapper.priority = 'p3';
            objWrapper.product = 'test grid';
            objWrapper.sendersignature = 'test grid';
            objWrapper.accname = acc[0].name;
            objWrapper.primaryname = 'test primary name';
            objWrapper.responsetime = 'test res time';
            objWrapper.viewcaseurl = 'test view url';
            objWrapper.esupporturl = 'test eurl';
            objWrapper.acceptsolution = 'no';
            objWrapper.declinesolution = 'yes';
            objWrapper.needmoretime = 'no';
            objWrapper.version = '57.0';
            objWrapper.successoffering = 'test offering';
            objWrapper.sessiondetails = 'test details';
            objWrapper.productarea = 'test area';
            objWrapper.isaae = true;
            objWrapper.casetype = 'Email';
            objWrapper.showprodversion = false;
            
            objWrapper.salutation = 'hi';
            objWrapper.primaryconname = 'test';
            objWrapper.alternatecontacts = 'test';
            objWrapper.showaccept = false;
            objWrapper.aaebooked = false;
            objWrapper.aaedelivered = false;
            objWrapper.aaecancelled = false;
            objWrapper.isnew = false;
            objWrapper.isassess = false;
            objWrapper.isclosed = false;
            objWrapper.isresearch = false;
            objWrapper.issolution = false;

            //Now we make sure we have created the Email Stats.
            System.assertNotEquals([SELECT Id FROM PlanCommentEmailStat__c LIMIT 1] == null, true, 'Unable to get created records.');

            //Finally we test the exception.
            objRequest.requestBody = Blob.valueof('[' + 
            '   {' + 
            '       "ccid": "123",' + 
            '       "sg_event_id": "Event Id 4",' + 
            '       "sg_message_id": "Message Id 3",' + 
            '       "timestamp": "Timestamp 3",' + 
            '       "email": "test@test.com3",' + 
            '       "event": "click"' + 
            '   }' + 
            ']');
            RestContext.request = objRequest;
            SendgridResponse.doPost();

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testSendGridResponse
     Description : Testing SendGrid response
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testSendGridRequest() {
        System.runAs(createTestUser('System Administrator', true)) {

            //Setting the initial request.
            Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());

            //Now we start the testing.
            Test.startTest();

            //We send the request.
            CSMSendGridPlanController.sendEmail(true, [SELECT Id FROM Plan_Comment__c LIMIT 1].Id, 'General Response');

            //Now we make sure we have created the Email Stats.
            System.assertNotEquals([SELECT Id FROM Plan_Comment__c LIMIT 1] == null, true, 'Unable to get created records.');

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testPlanStageImplement
     Description : Testing Implement stage.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testPlanStageImplement() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'TestNew';
            objPlan.Sub_Stage__c = 'Development';
            insert objPlan;
            Plan_Comment__c objPlanComment = new Plan_Comment__c();
            objPlanComment.Comment__c = 'test';
            objPlanComment.Visibility__c = 'External';
            objPlanComment.Status__c = 'Submitted';
            objPlanComment.Plan__c = objPlan.Id;
            insert objPlanComment;
            Plan_Contact__c objPlanContact = new Plan_Contact__c();
            objPlanContact.Plan__c = objPlan.Id;
            objPlanContact.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
            objPlanContact.Recieve_Email__c = true;
            insert objPlanContact;

            //Setting the initial request.
            Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());

            //Now we start the testing.
            Test.startTest();

            //We send the request.
            CSMSendGridPlanController.sendEmail(true, objPlanComment.Id, 'General Response');

            //Now we make sure we have created the Email Stats.
            System.assertNotEquals([SELECT Id FROM Plan_Comment__c LIMIT 1] == null, true, 'Unable to get created records.');

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testPlanStageValue
     Description : Testing Value stage.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testPlanStageValue() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'TestNew';
            objPlan.Sub_Stage__c = 'Technical Value';
            insert objPlan;
            Plan_Comment__c objPlanComment = new Plan_Comment__c();
            objPlanComment.Comment__c = 'test';
            objPlanComment.Visibility__c = 'External';
            objPlanComment.Status__c = 'Submitted';
            objPlanComment.Plan__c = objPlan.Id;
            insert objPlanComment;
            Plan_Contact__c objPlanContact = new Plan_Contact__c();
            objPlanContact.Plan__c = objPlan.Id;
            objPlanContact.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
            objPlanContact.Recieve_Email__c = true;
            insert objPlanContact;

            //Setting the initial request.
            Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());

            //Now we start the testing.
            Test.startTest();

            //We send the request.
            CSMSendGridPlanController.sendEmail(true, objPlanComment.Id, 'General Response');
            objPlan.Sub_Stage__c = 'Expansion';

            //Now we make sure we have created the Email Stats.
            System.assertNotEquals([SELECT Id FROM Plan_Comment__c LIMIT 1] == null, true, 'Unable to get created records.');

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testPlanStageScale
     Description : Testing Scale stage.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testPlanStageScale() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'TestNew';
            objPlan.Sub_Stage__c = 'Expansion';
            insert objPlan;
            Plan_Comment__c objPlanComment = new Plan_Comment__c();
            objPlanComment.Comment__c = 'test';
            objPlanComment.Visibility__c = 'External';
            objPlanComment.Status__c = 'Submitted';
            objPlanComment.Plan__c = objPlan.Id;
            insert objPlanComment;
            Plan_Contact__c objPlanContact = new Plan_Contact__c();
            objPlanContact.Plan__c = objPlan.Id;
            objPlanContact.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
            objPlanContact.Recieve_Email__c = true;
            insert objPlanContact;

            //Setting the initial request.
            Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());

            //Now we start the testing.
            Test.startTest();

            //We send the request.
            CSMSendGridPlanController.sendEmail(true, objPlanComment.Id, 'General Response');

            //Now we make sure we have created the Email Stats.
            System.assertNotEquals([SELECT Id FROM Plan_Comment__c LIMIT 1] == null, true, 'Unable to get created records.');

            //We stop the test.
            Test.stopTest();
        }
    }

    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;
        List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }

        //Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%' OR Name = 'SendGrid_Cosmos_Integrator']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

        //Now we return the result.
        return objTestUser;
    }
}