/*
 * Name         :   EngineerWorkspaceTestClass
 * Author       :   Monserrat Pedroza
 * Created Date :   9/30/2021
 * Description  :   Engineer Workspace test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      9/30/2021       N/A             Initial version.            N/A
 Vignesh D              11/29/2021      UTOPIA-FF2      Increase code coverage      T01
 Sandeep D              11/23/2022      I2RT-6980                                   T02
 balajip                01/09/2023      I2RT-7628       Fixed failures              T03
 */
@isTest(seeAllData = false)
public with sharing class EngineerWorkspaceTestClass {
    
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        //Now we create a Case.
        Case objCase = new Case();
        insert objCase; 
    }
    
    /*
     Method Name : testFlowOne
     Description : Testing flow one.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testFlowOne() {
        System.runAs(createTestUser('System Administrator', true)) {
            Case objCase;
            Case objLocalCase = new Case();
            Case_Comment__c objCaseComment;
            EmailMessage objEmail = new EmailMessage();
            Attachment objAttachment = new Attachment();
            Raise_Hand__c objRaiseHand = new Raise_Hand__c();
            RestCalloutUtilityTestClass objResponse;
            GCS_Subscription__c objSubscriptionRecord;
            Case_Team__c objCaseTeam;
            ProfileSkill objProfileSkill = new ProfileSkill();
            ProfileSkillUser objProfileSkillUser = new ProfileSkillUser();
            List<String> lstViews = new List<String>{ 'test' };
            List<String> lstCaseIds = new List<String>();
            List<Case> lstCases;
            List<CaseMilestone> lstCaseMilestones = [SELECT Id FROM CaseMilestone];
            list<ListView> lstListViews = [SELECT DeveloperName FROM ListView WHERE sObjectType = 'Case'];

            //Now we create teh Profile Skill User.
            objProfileSkill.Name = 'Test';
            objProfileSkill.Queue_Name__c = 'Data_as_a_Service';
            objProfileSkill.Type__c = 'Product Manager';
            objProfileSkill.Omni_Skill_Name__c = 'Data_as_a_Service_Manager';
            insert objProfileSkill;
            objProfileSkillUser.ProfileSkillId = objProfileSkill.Id;
            objProfileSkillUser.UserId = UserInfo.getUserId();
            objProfileSkillUser.Status__c = 'Approved';
            objProfileSkillUser.Priority__c = 'P1';
            objProfileSkillUser.Support_Level__c = 'Standard';
            objProfileSkillUser.Component__c = 'Accelerator';
            insert objProfileSkillUser;

            //We create an additional case.
            for(Group objGroup : [SELECT Id FROM Group WHERE Group.Type = 'Queue' AND DeveloperName = 'Data_as_a_Service' LIMIT 1]){
                objLocalCase.OwnerId = userinfo.getuserid();
                objLocalCase.Priority = 'P1';
                objLocalCase.Success_Offering__c = 'Standard';
                objLocalCase.Component__c = 'Accelerator';
                objLocalCase.Is_Internal_Or_External_Case__c = 'Internal';
                objLocalCase.IR_in_Mins__c = 0;
                objLocalCase.IsEscalated = true;
                objLocalCase.Next_Action__c = 'Case Owner';
                objLocalCase.Case_Last_Activity__c = Date.today().addDays(-30);
                insert objLocalCase;
                objCase = objLocalCase;
                 system.debug('@@ objLocalCase'+Json.SerializePretty(objLocalCase));
                //Now we create a Raise Hand record.
                objRaiseHand.Skill__c = 'Test';
                objRaiseHand.Status__c = 'Open';
                objRaiseHand.Type__c = 'Co-own';
                objRaiseHand.SubType__c = 'PS Review';
                objRaiseHand.Case__c = objLocalCase.Id;
                objRaiseHand.Accepted_By__c = UserInfo.getUserId();
                insert objRaiseHand;
                system.debug('@@ objRaiseHand'+Json.SerializePretty(objRaiseHand));
            }
            lstCases = [SELECT Id, IsEscalated, Priority, Case_Last_Activity__c, Next_Action__c, ParentId FROM Case];
             system.debug('@@ lstCases'+Json.SerializePretty(lstCases));
               // T02 starts
                 Raise_Hand__c objRaiseHandForCoOwn = new Raise_Hand__c();
                objRaiseHandForCoOwn.Skill__c = 'Test';
                objRaiseHandForCoOwn.Status__c = 'Open';
                objRaiseHandForCoOwn.Type__c = 'Co-own';
                objRaiseHandForCoOwn.SubType__c = 'Operations';
                objRaiseHandForCoOwn.Case__c = lstCases[0].Id;
                objRaiseHandForCoOwn.Accepted_By__c = UserInfo.getUserId();
                insert objRaiseHandForCoOwn;
             // T02 Ends
            //Now we prepare additional data for the test cases.
            for(Case objRecord : lstCases) {
                lstCaseIds.add(objRecord.Id);
                try {
                    objRecord.ParentId = objCase.Id;
                    update objRecord;
                } catch(Exception objException) {}

                //Now we create Case Team record.
                objCaseTeam = new Case_Team__c();
                objCaseTeam.User__c = UserInfo.getUserId();
                objCaseTeam.Case__c = objRecord.Id;
                insert objCaseTeam;

                //Now we insert some Case Comments.
                objCaseComment = new Case_Comment__c();
                objCaseComment.Case__c = objRecord.Id;
                objCaseComment.Type__c = 'Callback';
                objCaseComment.Is_Replied_To__c = false;
                insert objCaseComment;

                //Now we insert Emails.
                objEmail = new EmailMessage();
                objEmail.FromAddress = 'test@abc.org';
                objEmail.Incoming = false;
                objEmail.ToAddress= 'test@xyz.org';
                objEmail.Subject = 'Test email';
                objEmail.HtmlBody = 'Test email body';
                objEmail.ParentId = objRecord.Id; 
                insert objEmail;

                //Now we insert Attachments.
                objAttachment = new Attachment();
                objAttachment.Body = Blob.valueOf('test');
                objAttachment.Name = String.valueOf('test.txt');
                objAttachment.ParentId = objRecord.Id; 
                insert objAttachment;

                //Now we insert activity history records.
                insert new Task(WhatId = objRecord.Id, Subject = 'Test', ActivityDate = Date.today(), Type = 'WebEx', Status = 'Completed');
               // insert new Task(WhatId = objRecord.Id, Subject = 'Test', ActivityDate = Date.today(), Type = 'Call', Status = 'Completed');

                //Now we insert Feed Items.
               // insert new FeedItem (ParentId = objRecord.id, Type = 'LinkPost', Body = 'HelloHelloHelloHel', Title = 'test', LinkUrl = 'https://www.test.com');
            }
            
            //Now we create the Subscription records.
            objSubscriptionRecord = new GCS_Subscription__c();
            objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
            objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
            objSubscriptionRecord.Engineering_Workspace_List_View_Sort__c = 'AllOpenCases';
            objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
            objSubscriptionRecord.User__c = UserInfo.getUserId();
            insert objSubscriptionRecord;
            objSubscriptionRecord = new GCS_Subscription__c();
            objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
            objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
            objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
            objSubscriptionRecord.User__c = UserInfo.getUserId();
            insert objSubscriptionRecord;

            //We prepare the mock call.
            Test.setMock(HttpCalloutMock.class, objResponse);

            //Now we test the method.
            Test.startTest();
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.fetchListView() == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.Caseview(UserInfo.getUserId()) == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.calculateGradients(lstCases, lstCaseMilestones) == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.updateCaseOwner(lstCaseIds, UserInfo.getUserId()) == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.acceptRaiseHand(lstCaseIds, lstCaseIds, UserInfo.getUserId()) == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.acceptRaiseHand(objCase.Id) == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.buildTimeLine(objCase.Id, 'true') == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.insertWeightageRating('Test', null, 'Up', 'Test', objCase.Id) == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.isGCSManagerPermission() == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getColorLegend() == null, true, 'Unable to execute the test.'); // <T01>
            lstCases[0].Subject = 'test test';
            update lstCases[0];
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.Caseview(UserInfo.getUserId()) == null, true, 'Unable to execute the test.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testFlowTwo
     Description : Testing flow two.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testFlowTwo() {
        System.runAs(createTestUser('System Administrator', true)) {
            Case objCase;
            Case objLocalCase = new Case();
            Case_Comment__c objCaseComment;
            Case_Team__c objCaseTeam;
            EmailMessage objEmail = new EmailMessage();
            Attachment objAttachment = new Attachment();
            Raise_Hand__c objRaiseHand = new Raise_Hand__c();
            RestCalloutUtilityTestClass objResponse;
            ProfileSkill objProfileSkill = new ProfileSkill();
            ProfileSkillUser objProfileSkillUser = new ProfileSkillUser();
            GCS_Subscription__c objSubscriptionRecord;
            List<String> lstViews = new List<String>{ 'test' };
            List<String> lstCaseIds = new List<String>();
            List<Case> lstCases;
            List<CaseMilestone> lstCaseMilestones = [SELECT Id FROM CaseMilestone];
            list<ListView> lstListViews = [SELECT DeveloperName FROM ListView WHERE sObjectType = 'Case'];

            //Now we create teh Profile Skill User.
            objProfileSkill.Name = 'Test';
            objProfileSkill.Queue_Name__c = 'Data_as_a_Service';
            objProfileSkill.Type__c = 'Product Manager';
            objProfileSkill.Omni_Skill_Name__c = 'Data_as_a_Service_Manager';
            insert objProfileSkill;
            objProfileSkillUser.ProfileSkillId = objProfileSkill.Id;
            objProfileSkillUser.UserId = UserInfo.getUserId();
            objProfileSkillUser.Status__c = 'Approved';
            objProfileSkillUser.Priority__c = 'P1';
            objProfileSkillUser.Support_Level__c = 'Standard';
            objProfileSkillUser.Component__c = 'Accelerator';
            insert objProfileSkillUser;

            //We create an additional case.
            for(Group objGroup : [SELECT Id FROM Group WHERE Group.Type = 'Queue' AND DeveloperName = 'Data_as_a_Service' LIMIT 1]){
                objLocalCase.OwnerId = userInfo.GetuserId();   //objGroup.Id;
                objLocalCase.Priority = 'P1';
                objLocalCase.Success_Offering__c = 'Standard';
                objLocalCase.Component__c = 'Accelerator';
                objLocalCase.Is_Internal_Or_External_Case__c = 'Internal';
                objLocalCase.IR_in_Mins__c = 0;
                objLocalCase.IsEscalated = true;
                objLocalCase.Next_Action__c = 'Case Owner';
                objLocalCase.Case_Last_Activity__c = Date.today().addDays(-30);
                insert objLocalCase;
                objCase = objLocalCase;

                //Now we create a Raise Hand record.
                objRaiseHand.Skill__c = 'Test';
                objRaiseHand.Status__c = 'Open';
                objRaiseHand.Type__c = 'Co-own';
                objRaiseHand.SubType__c = 'PS';
                objRaiseHand.Case__c = objLocalCase.Id;
                insert objRaiseHand;
            }
            lstCases = [SELECT Id, IsEscalated, Priority, Case_Last_Activity__c, Next_Action__c, ParentId FROM Case];

            //Now we prepare additional data for the test cases.
            objResponse = new RestCalloutUtilityTestClass(null, '{  "count" : 1000,  "currentPageToken" : "0",  "currentPageUrl" : ' + 
                    '"/services/data/v52.0/ui-api/list-records/00B41000003kZZeEAM?pageSize=1000&pageToken=0",  "fields" : [ ],  "listInfoETag" : "9a5e68d9be07be7e09550dfcff8d7e42",  ' + 
                    '"listReference" : {    "id" : "00B41000003kZZeEAM",    "listViewApiName" : "AllOpenCases",    "objectApiName" : "Case",    "type" : "listView"  },  ' + 
                    '"nextPageToken" : "1000",  "nextPageUrl" : "/services/data/v52.0/ui-api/list-records/00B41000003kZZeEAM?pageSize=1000&pageToken=1000",  "optionalFields" : [ ],  ' + 
                    '"pageSize" : 1000,  "previousPageToken" : null,  "previousPageUrl" : null,  "records" : [ {    "apiName" : "Case",    "childRelationships" : { },    ' + 
                    '"eTag" : "78edae277f4749304dab0dd66d1add4d",    "fields" : {      "CaseNumber" : {        "displayValue" : null,        "value" : "00001008"      },      ' + 
                    '"CreatedDate" : {        "displayValue" : "1/25/2021 1:20 AM",        "value" : "2021-01-25T07:20:34.000Z"      },      "CurrencyIsoCode" : {        ' + 
                    '"displayValue" : null,        "value" : "USD"      },      "Delivery_Method__c" : {        "displayValue" : null,        "value" : null      },      ' + 
                    '"Forecast_Product__c" : {        "displayValue" : "Cloud Data Quality",        "value" : "Cloud Data Quality"      },      "Id" : {        ' + 
                    '"displayValue" : null,        "value" : "500g000000WbcLbAAJ"      },      "IsEscalated" : {        "displayValue" : null,        "value" : true      },      ' + 
                    '"LastModifiedById" : {        "displayValue" : null,        "value" : "0053f0000018YDmAAM"      },      "LastModifiedDate" : {        "displayValue" : null,        ' + 
                    '"value" : "2021-08-06T04:08:13.000Z"      },      "Owner" : {        "displayValue" : "GCS Admin Queue",        "value" : {          "apiName" : "Name",          ' + 
                    '"childRelationships" : { },          "eTag" : "6c3b1a38d99c7dd57d155c74517b86e2",          "fields" : {            "Id" : {              ' + 
                    '"displayValue" : null,              "value" : "00Gg0000006FXjdEAG"            },            "Name" : {              "displayValue" : null,              ' + 
                    '"value" : "GCS Admin Queue"            },            "NameOrAlias" : {              "displayValue" : null,              "value" : ' + 
                    '"GCS Admin Queue"            }          },          "id" : "00Gg0000006FXjdEAG",          "lastModifiedById" : null,          ' + 
                    '"lastModifiedDate" : null,          "recordTypeId" : null,          "recordTypeInfo" : null,          "systemModstamp" : null,          ' + 
                    '"weakEtag" : 0        }      },      "OwnerId" : {        "displayValue" : null,        "value" : "00Gg0000006FXjdEAG"      },      ' + 
                    '"Priority" : {        "displayValue" : "P3",        "value" : "P3"      },      "RecordTypeId" : {        "displayValue" : null,        ' + 
                    '"value" : "012g00000003Mk3AAE"      },      "Record_Type_Name__c" : {        "displayValue" : null,        "value" : "Technical"      },      ' + 
                    '"Status" : {        "displayValue" : "Assess",        "value" : "Assess"      },      "Subject" : {        "displayValue" : null,        ' + 
                    '"value" : "Installation Issue Carrier Project: 2-00151124 -"      },      "SystemModstamp" : {        "displayValue" : null,        ' + 
                    '"value" : "2021-08-06T04:08:13.000Z"      }    },    "id" : "500g000000WbcLbAAJ",    "lastModifiedById" : "0053f0000018YDmAAM",    ' + 
                    '"lastModifiedDate" : "2021-08-06T04:08:13.000Z",    "recordTypeId" : "012g00000003Mk3AAE",    "recordTypeInfo" : {      "available" : true,      ' + 
                    '"defaultRecordTypeMapping" : true,      "master" : false,      "name" : "Technical",      "recordTypeId" : "012g00000003Mk3AAE"    },    ' + 
                    '"systemModstamp" : "2021-08-06T04:08:13.000Z",    "weakEtag" : 1628222893000  }],  "sortBy" : "CaseNumber,Id"}', 200);
            for(Case objRecord : lstCases) {
                lstCaseIds.add(objRecord.Id);
                try {
                    objRecord.ParentId = objCase.Id;
                    update objRecord;
                } catch(Exception objException) {}

                //Now we create Case Team record.
                objCaseTeam = new Case_Team__c();
                objCaseTeam.User__c = UserInfo.getUserId();
                objCaseTeam.Case__c = objRecord.Id;
                insert objCaseTeam;

                //Now we insert some Case Comments.
                objCaseComment = new Case_Comment__c();
                objCaseComment.Case__c = objRecord.Id;
                objCaseComment.Type__c = 'Callback';
                objCaseComment.Is_Replied_To__c = false;
                insert objCaseComment;

                //Now we insert Emails.
                objEmail = new EmailMessage();
                objEmail.FromAddress = 'test@abc.org';
                objEmail.Incoming = false;
                objEmail.ToAddress= 'test@xyz.org';
                objEmail.Subject = 'Test email';
                objEmail.HtmlBody = 'Test email body';
                objEmail.ParentId = objRecord.Id; 
                insert objEmail;

                //Now we insert Attachments.
                objAttachment = new Attachment();
                objAttachment.Body = Blob.valueOf('test');
                objAttachment.Name = String.valueOf('test.txt');
                objAttachment.ParentId = objRecord.Id; 
                insert objAttachment;

                //Now we insert activity history records.
                insert new Task(WhatId = objRecord.Id, Subject = 'Test', ActivityDate = Date.today(), Type = 'WebEx', Status = 'Completed');
              //  insert new Task(WhatId = objRecord.Id, Subject = 'Test', ActivityDate = Date.today(), Type = 'Call', Status = 'Completed');

                //Now we insert Feed Items.
               // insert new FeedItem (ParentId = objRecord.id, Type = 'LinkPost', Body = 'HelloHelloHelloHel', Title = 'test', LinkUrl = 'https://www.test.com');
            }

            //Now we create the Subscription records.
            objSubscriptionRecord = new GCS_Subscription__c();
            objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
            objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
            objSubscriptionRecord.Engineering_Workspace_List_View_Sort__c = 'AllOpenCases';
            objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
            objSubscriptionRecord.User__c = UserInfo.getUserId();
            insert objSubscriptionRecord;
            objSubscriptionRecord = new GCS_Subscription__c();
            objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
            objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
            objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
            objSubscriptionRecord.User__c = UserInfo.getUserId();
            insert objSubscriptionRecord;

            //We prepare the mock call.
            Test.setMock(HttpCalloutMock.class, objResponse);
            objProfileSkill = new ProfileSkill();
            objProfileSkill.Name = 'Test1';
            objProfileSkill.Queue_Name__c = 'GCS_CRE_Queue';
            objProfileSkill.Type__c = 'Product Manager';
            objProfileSkill.Omni_Skill_Name__c = 'GCS_CRE';
            insert objProfileSkill;
            objProfileSkillUser = new ProfileSkillUser();
            objProfileSkillUser.ProfileSkillId = objProfileSkill.Id;
            objProfileSkillUser.UserId = UserInfo.getUserId();
            objProfileSkillUser.Status__c = 'Approved';
            objProfileSkillUser.Priority__c = null;
            objProfileSkillUser.Support_Level__c = null;
            objProfileSkillUser.Component__c = null;
            insert objProfileSkillUser;
            //Now we test the method.
            Test.startTest();
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.fetchCasesBasedOnListView(lstListViews.get(0).DeveloperName, 'CaseNumber,') == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getSessionIdForLWC() == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.SavePinnedView('Test') == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.SaveTheSelectedViews(lstViews) == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getAttentionRecords(UserInfo.getUserId()) == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getCurrentViewSaved('queues') == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getLatestViewSelected() == null, true, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getCurrentSplitterPositionSaved(1) == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getLatestSplitterPositionSelected() == null, true, 'Unable to execute the test.');
            group g = [select id,name from group where developerName = 'GCS_CRE_Queue' and group.type = 'Queue' limit 1];
            lstCases[0].ownerId = g?.id;
            update lstCases[0];
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.fetchCasesGroupByQueue(UserInfo.getUserId()) == null, true, 'Unable to execute the test.');
            delete [select id from GCS_Subscription__c];
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getCurrentSplitterPositionSaved(1) == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.getCurrentViewSaved('queues') == null, false, 'Unable to execute the test.');
            System.assertNotEquals(CasePrioritizationViewLwcV4Ctrl.SavePinnedView('Test') == null, true, 'Unable to execute the test.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testFlowThree
     Description : Testing flow three.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testFlowThree() {
        System.runAs(createTestUser('System Administrator', true)) {
            CasePrioritizationViewLwcV4Ctrl.QueueRecordsWrapper objWrapper = new CasePrioritizationViewLwcV4Ctrl.QueueRecordsWrapper();
            CasePrioritizationViewLwcV4Ctrl.fetchCasesGroupByQueueWrapperResult objWrapper2 = new CasePrioritizationViewLwcV4Ctrl.fetchCasesGroupByQueueWrapperResult();
            CasePrioritizationViewLwcV4Ctrl.CaseWrapper objWrapper3 = new CasePrioritizationViewLwcV4Ctrl.CaseWrapper();
            objWrapper2.hasManagerPermission = false;
            objWrapper2.strUserId = '';
            objWrapper2.mapGrpIdWiseRecordsData = new Map<Id, CasePrioritizationViewLwcV4Ctrl.QueueRecordsWrapper>();
            objWrapper3.firstGradientColor = '';
            objWrapper3.lastGradientColor = '';
            objWrapper3.lastGradientTitle = '';
            objWrapper3.lastGradientWidth = 0.0;
            objWrapper3.bandChangeWidth = 0.0;
            CasePrioritizationViewLwcV4Ctrl.DataResultWrapper data = new CasePrioritizationViewLwcV4Ctrl.DataResultWrapper();
            data.otherCasesWidth = 1.1;
            data.otherCasesTitle = 'test';
            data.caseOwnerWidth = 2;
            data.caseOwnerTitle = 'test owner';
            data.missedMilestonesWidth = 1.1;
            data.missedMilestonesTitle = 'test milestone';
            data.inactiveCasesWidth = 2;
            data.inactiveCasesTitle = 'test inactive';
            data.p1sCasesWidth = 2;
            data.p1sCasesTitle = 'test p1';
            data.escalationWidth = 3;
            data.escalationTitle = 'Test Escalation';
            data.ismanager = false;
            
            CasePrioritizationViewLwcV4Ctrl cp = new CasePrioritizationViewLwcV4Ctrl();
            string htmlCode = cp.strHTMLCode;
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
        return objTestUser;
    }
}