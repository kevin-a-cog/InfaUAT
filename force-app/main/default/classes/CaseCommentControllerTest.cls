/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for CaseCommentController
    @Testclass        : 
    @JIRA             : 
    
Change History
*********************************************************************************************************
ModifiedBy     Date        Jira No.    Description                                                  Tag
*********************************************************************************************************
balajip        05/04/2022  I2RT-5459   Added feature to tag users in a Case Comment                 T01

 */
@isTest
public with sharing class CaseCommentControllerTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Subject', 'TestClass');
        
        List<Case> lcase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Case Team
        sObject CaseTeamrec = new Case_Team__c();
        UtilityTestData.mCaseTeam.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseTeam.put('User__c',UserInfo.getUserId());
        CaseTeamrec = UtilityTest.putFieldRecord(CaseTeamrec, UtilityTestData.mCaseTeam);
        List<Case_Team__c> lcaseTeam = (List<Case_Team__c>) UtilityTest.makeInsert(new List<sObject>{CaseTeamrec}); 
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }
    
    @isTest
    static void testAllMethods(){

        List<Case> cse = [Select Id From Case];
        List<Id> cseIds = new List<Id>();
        for(Case cseObj : cse){
            cseIds.add(cseObj.Id);
        }
        List<Case_Team__c> caseTeamList = [SELECT Id FROM Case_Team__c LIMIT 1];
            
        Case_Comment__c caseCommentParent = new Case_Comment__c();
        caseCommentParent.Case__c = cse[0].Id;
        caseCommentParent.Comment__c = 'aaaaaaaaa';
        caseCommentParent.Comment_to_Search__c = 'childtestservletComment';
        caseCommentParent.Visibility__c = 'External';
        insert caseCommentParent;

        Case_Comment__c caseComment = new Case_Comment__c();
        caseComment.Case__c = cse[0].Id;
        caseComment.Parent_Comment__c = caseCommentParent.Id;
        caseComment.Comment__c = 'child/servlet/rtaImage?refid=';
        caseComment.Status__c = 'Submitted';
        caseComment.Type__c = 'Delay Close';
        caseComment.Visibility__c = 'Internal';
        caseComment.Comment_Category__c = 'Manager Review';
        caseComment.Comment_to_Search__c = 'childtestservletComment';
        //insert caseComment;
        Case_Comment__c caseComment2 = caseComment.clone(false);
        caseComment2.Type__c = 'Close Case';
        caseComment2.Visibility__c = 'External';
        caseComment2.Comment_to_Search__c = 'childtestservletComment';
        caseComment2.Inbound__c = true;
        insert caseComment2;
        Case_Comment__c caseComment3 = caseComment.clone(false);
        caseComment3.Type__c = 'Request More Info';
        Case_Comment__c caseComment4 = caseComment.clone(false);
        caseComment4.Type__c = 'Provide Solution';

        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
        Task t = new Task(WhatId = cse[0].Id, Subject = 'Test Task', Status = 'Completed');
        insert t;
        Event e = new Event(WhatId = cse[0].Id, Subject = 'Test Event', ActivityDateTime = System.now(),DurationInMinutes = 90);
        insert e;
        
        Test.startTest();

        CaseCommentController ctrl = new CaseCommentController();
        CaseCommentController.getPermissionOnObject();
        CaseCommentController.updateCaseTeamMember(caseTeamList[0].Id);
        List<Case_Team__c> listCaseTeam = CaseCommentController.getCaseTeamMember(cse[0].Id);
        
        CaseCommentController.fetchMergedQuickText('Case_Comment', cse[0].Id);
        CaseCommentController.addCloseCaseComment(cseIds);
        cse[0].recordTypeId=SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operations').getRecordTypeId();
        update cse[0];
        CaseCommentController.getQuickActionConfiguration(cse[0].Id);
        
        try{
            CaseCommentController.saveComment(caseComment, new List<String>{});
            CaseCommentController.saveComment(caseComment2, new List<String>{});
            CaseCommentController.saveComment(caseComment3, new List<String>{});
            CaseCommentController.saveComment(caseComment4, new List<String>{documents[0].Id});
        }catch(Exception ex){}

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=caseComment.id;  
        contentlink.ShareType= 'I';               
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;

        CaseCommentFeedback__c ccfeedback = new CaseCommentFeedback__c(Case_Comment__c=caseComment.Id,disLike__c=false,Like__c=false,Feedback__c='');
        insert ccfeedback;
        
        CaseCommentController.saveComment(caseComment, new List<String>{contentlink.Id});
        CaseCommentController.updateCaseFeedBackRecord('ISINSERT',new CaseCommentFeedback__c(Case_Comment__c=caseComment.Id,disLike__c=false,Like__c=false,Feedback__c=''));
        CaseCommentController.updateCaseFeedBackRecord('ISUPDATE', ccfeedback);
                                                       
        CaseCommentController.getPreDraftComment(cse[0].Id);
        CaseCommentController.getCaseComments(cse[0].Id, 'External', 'General Comments', 'Submitted', 'Escalation',true, 'LastModifiedDate ASC', 'Test','AllMainTab',5,2,UserInfo.getUserId()); //T01
        CaseCommentController.getCaseComments(cse[0].Id, 'aaa', 'bbb', 'ccc','Tasks', true, 'CreatedDate', 'eeee','',5,2,UserInfo.getUserId()); //T01

        CaseCommentController.getDocuments(null, '', false);
        CaseCommentController.getDocuments(null, '', true);

        SendNotificationAction.sendNotificationToUser(new List<Id>{caseComment.Id});

        Service_Cloud_General_Setting__mdt metadataSetting = CaseCommentController.getServiceSettingMetadata;
        CaseCommentController.getCaseCommentsForEsupport(cse[0].Id, 'LastModifiedDate ASC', 'child');
        
        List<Case_Comment__c> listCaseComment = [SELECT Id FROM Case_Comment__c WHERE Case__c = :cse[0].Id AND Parent_Comment__c = null 
                                 AND Status__c != 'Pre Draft' AND Is_Deleted__c = false AND (Visibility__c != 'Private'
                                 OR CreatedById=:UserInfo.getUserId()) AND (Inbound__c = true OR Visibility__c = 'External')
                                 AND Comment_to_Search__c LIKE '%child%'
                                               ];
        system.debug('listCaseComment:'+listCaseComment);
        CaseCommentController.addCaseCommentsFromEsupport(cse[0].Id, 'Test comment body');
        Test.stopTest();
    }

    @isTest
    static void isCaseCommentAssociatedToCase(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;

        if(String.isNotEmpty(caseId)){
            Case_Comment__c cc = new Case_Comment__c();
            cc.Comment__c = 'Test case comment';
            cc.Inbound__c = false;
            cc.Status__c = 'Submitted';
            cc.Visibility__c = 'External';
            cc.Case__c = caseId;
            cc.Sub_Type__c = 'General Response';
            cc.Comment_Category__c = 'General Comments';
            insert cc;

            Boolean evaluatedCondition = CaseCommentController.isCaseCommentAssociatedToCase(new List<Id>{cc.Id}, caseId);

            System.assertEquals(true, evaluatedCondition, 'TEST ERROR: Case Comment is not associated with the case');
        }
    }

    @isTest
    static void saveComment(){
        Id caseId = [Select Id from Case LIMIT 1]?.Id;

        if(String.isNotEmpty(caseId)){
            Case_Comment__c cc = new Case_Comment__c();
            cc.Comment__c = 'Test case comment';
            cc.Inbound__c = false;
            cc.Status__c = 'Submitted';
            cc.Visibility__c = 'External';
            cc.Case__c = caseId;
            cc.Sub_Type__c = 'General Response';
            cc.Type__c = 'Request More Info';
            cc.Comment_Category__c = 'General Comments';
            CaseCommentController.saveComment(cc, new List<String>());

            cc = new Case_Comment__c();
            cc.Comment__c = 'Test case comment';
            cc.Inbound__c = false;
            cc.Status__c = 'Submitted';
            cc.Visibility__c = 'External';
            cc.Case__c = caseId;
            cc.Sub_Type__c = 'General Response';
            cc.Type__c = 'Provide Solution';
            cc.Comment_Category__c = 'General Comments';
            CaseCommentController.saveComment(cc, new List<String>());
            
            cc.Type__c = 'Send RCA';
            update cc;
             CaseCommentController.saveComment(cc, new List<String>());
        }
    }

    @isTest
    static void getCaseCommentsForEsupport(){
        Test.startTest();
        Id caseId = [Select Id from Case LIMIT 1]?.Id;

        if(String.isNotEmpty(caseId)){
            Case_Comment__c cc = new Case_Comment__c();
            cc.Comment__c = 'Test case comment';
            cc.Inbound__c = false;
            cc.Status__c = 'Submitted';
            cc.Visibility__c = 'External';
            cc.Case__c = caseId;
            cc.Sub_Type__c = 'General Response';
            cc.Comment_Category__c = 'General Comments';
            cc.Comment_to_Search__c = 'Test case comment';
            cc.Type__c = 'Escalation';
            insert cc;

            Case_Comment__c childComment = new Case_Comment__c();
            childComment.Comment__c = 'Test child case comment';
            childComment.Inbound__c = false;
            childComment.Status__c = 'Submitted';
            childComment.Visibility__c = 'External';
            childComment.Case__c = caseId;
            childComment.Sub_Type__c = 'General Response';
            childComment.Comment_Category__c = 'General Comments';
            childComment.Parent_Comment__c = cc.Id;
            childComment.Comment_to_Search__c = 'Test child case comment';
            insert childComment;

            CaseCommentController.getCaseCommentsForEsupport((String) caseId, 'LastModifiedDate ASC', '');
            CaseCommentController.getCaseCommentsForEsupport((String) caseId, 'LastModifiedDate ASC', 'Test');
            //CaseCommentController.getCaseComments(caseId, 'aaa', 'bbb', 'ccc','', true, 'CreatedDate', 'eeee','',5,2,''); //T01
            CaseCommentController.getCaseComments(caseId, 'External', 'General Comments', 'Submitted', '',true, 'LastModifiedDate ASC', 'Test','AllMainTab',5,2,'');
            CaseCommentController.getCaseComments(caseId, 'External', 'General Comments', 'Submitted', 'Attention Request',true, 'LastModifiedDate ASC', 'Test','AllMainTab',5,2,'');

            List<CaseHistory> lstCaseHistory = [Select Id, CaseId, Field, NewValue, OldValue, CreatedById, CreatedDate, CreatedBy.Name From CaseHistory];
            try{
                CaseCommentController.CaseCommentWrapper objCaseCommentWrapper = new CaseCommentController.CaseCommentWrapper(new Case_Comment__c(), 'Test Role', new List<CaseCommentController.CaseCommentWrapper>(), false);
                CaseCommentController.CaseCommentWrapper objCaseCommentWrapper1 = new CaseCommentController.CaseCommentWrapper(new Case_Comment__c(), 'Test Role', null, new List<ContentDocumentLink>());
            }catch(Exception ex){}

            try{
                CaseCommentController.CaseCommentWrapper objCaseCommentWrapper2 = new CaseCommentController.CaseCommentWrapper(null, 'Test URL', 'Test Role');
            }catch(Exception ex){}
            Test.stopTest();
        }
    }
    
   
}