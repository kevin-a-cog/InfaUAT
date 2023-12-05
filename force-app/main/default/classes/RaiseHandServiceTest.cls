/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for RaiseHandService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class RaiseHandServiceTest {
    public RaiseHandServiceTest() {

    }
    
    @testSetup
    static void setupObjectTestData() {
        
        //create an Engagement record
        sObject sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);

        //create collaboration
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name='PowerCenter-PS'; // Define group name here
        chatterGroup.CollaborationType='Public'; //It can be 'Public' or 'Private'                   
        insert chatterGroup;
    }

    @isTest
    static void testRaiseHandServiceMethods(){

        Case cse = [Select Id From Case Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];

        Raise_Hand__c raiseHandGetHelp = new Raise_Hand__c();
        raiseHandGetHelp.Case__c = cse.Id;
        raiseHandGetHelp.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandGetHelp.Type__c = RaiseHandService.TYPE_GET_HELP;
        //raiseHand.Subtype__c = subtype;
        raiseHandGetHelp.Skill__c = 'PowerCenter - PS';
        raiseHandGetHelp.Question__c = 'This is the question';

        Raise_Hand__c raiseHandCustMeeting = new Raise_Hand__c();
        raiseHandCustMeeting.Case__c = cse.Id;
        raiseHandCustMeeting.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandCustMeeting.Type__c = RaiseHandService.TYPE_CUSTOMER_MEETING;
        raiseHandCustMeeting.Skill__c = 'PowerCenter - PS';

        Raise_Hand__c raiseHandRepro = new Raise_Hand__c();
        raiseHandRepro.Case__c = cse.Id;
        raiseHandRepro.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandRepro.Type__c = RaiseHandService.TYPE_REPRO_ENV_SETUP;
        raiseHandRepro.Skill__c = 'PowerCenter - PS';

        Raise_Hand__c raiseHandCoOwn = new Raise_Hand__c();
        raiseHandCoOwn.Case__c = cse.Id;
        raiseHandCoOwn.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandCoOwn.Type__c = RaiseHandService.TYPE_CO_OWN;
        raiseHandCoOwn.Subtype__c = RaiseHandService.SUBTYPE_MULTIPRODUCT;
        raiseHandCoOwn.Skill__c = 'PowerCenter - PS';
        
        Raise_Hand__c raiseHandEsc = new Raise_Hand__c();
        raiseHandEsc.Case__c = cse.Id;
        raiseHandEsc.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandEsc.Type__c = RaiseHandService.TYPE_MANAGE_ESCALATION;
        //raiseHandEsc.Subtype__c = RaiseHandService.SUBTYPE_MULTIPRODUCT;
        raiseHandEsc.Skill__c = 'PowerCenter - PS';

        Test.startTest();
            RaiseHandController controller = new RaiseHandController();
            RaiseHandService service = new RaiseHandService();

            RaiseHandController.getSkills(RaiseHandService.TYPE_GET_HELP,'','');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_PSREVIEW, '');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_MULTIPRODUCT, 'PowerCenter');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_OPERATIONS, 'Operations');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CUSTOMER_MEETING,'','');
            RaiseHandController.getSkills(RaiseHandService.TYPE_REPRO_ENV_SETUP,'','');

            RaiseHandController.createRaiseHand(raiseHandGetHelp);
            globalApexManager.allowRun('RaiseHandTrigger', 'after', 'update');
            raiseHandGetHelp.OwnerId = UserInfo.getUserId();
            raiseHandGetHelp.Status__c = 'Closed';
            update raiseHandGetHelp;
            RaiseHandService.onAssignment(new Set<Id>{raiseHandGetHelp.Id});
            RaiseHandController.closeRequest(raiseHandGetHelp.Id);

            RaiseHandController.createRaiseHand(raiseHandCustMeeting);
            raiseHandCustMeeting.OwnerId = UserInfo.getUserId();
            update raiseHandCustMeeting;
            RaiseHandService.onAssignment(new Set<Id>{raiseHandCustMeeting.Id});
            
            RaiseHandController.createRaiseHand(raiseHandRepro);
            raiseHandRepro.OwnerId = UserInfo.getUserId();
            update raiseHandRepro;
            RaiseHandService.onAssignment(new Set<Id>{raiseHandRepro.Id});
            
            RaiseHandController.createRaiseHand(raiseHandCoOwn);
            raiseHandCoOwn.OwnerId = UserInfo.getUserId();
            update raiseHandCoOwn;
            RaiseHandService.onAssignment(new Set<Id>{raiseHandCoOwn.Id});
            //RaiseHandService.onAssignment(new Set<Id>{raiseHandCoOwn.Id});

            RaiseHandController.createRaiseHand(raiseHandEsc);
            raiseHandEsc.OwnerId = UserInfo.getUserId();
            raiseHandEsc.Engagement__c = engagement.Id;
            update raiseHandEsc;
            try{
                RaiseHandService.onAssignment(new Set<Id>{raiseHandEsc.Id});
            }catch(Exception ex){

            }

            RaiseHandService.raiseEscalation(engagement.Id);
        
            Id raiseHandEscId = RaiseHandService.raiseEscalation(cse.Id, engagement.Id);
            Raise_Hand__c raiseHand = [SELECT Id,OwnerId from Raise_Hand__c where Id =:raiseHandEscId];
            raiseHand.OwnerId = UserInfo.getUserId();
            update raiseHandEsc;
            //RaiseHandService.onAssignment(new Set<Id>{raiseHandEscId});

            RaiseHandController.raiseHandRequest(cse.Id, RaiseHandService.TYPE_GET_HELP, '', 'PowerCenter - PS', '', 'Normal', 'Type 1', '', '');
            RaiseHandService.getSkills('Co-own','','Cloud B2B');
            RaiseHandService.getSkills('Get Help','','Cloud B2B');
        
            //Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get('PowerCenter-PS').Id;
        // RaiseHandService.editQuestion(cse.Id, cse.Id, raiseHandGetHelp.Id, chatterGroupId, UserInfo.getUserId(), UserInfo.getUserId(), 'questionTitle', 'question');
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateStatus(){

        Test.startTest();

        Case cse = [Select Id From Case Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];
       
        //Create Related Feed Item Record
        FeedItem feedItem = new FeedItem(ParentId = engagement.Id, Body = 'Test Body');
        insert feedItem;
        FeedComment feedComment = new FeedComment(FeedItemId = feedItem.Id, CommentBody = 'Test Comment');
        insert feedComment;

        Raise_Hand__c raiseHandCoOwn = new Raise_Hand__c();
        raiseHandCoOwn.Case__c = cse.Id;
        raiseHandCoOwn.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandCoOwn.Type__c = RaiseHandService.TYPE_CO_OWN;
        raiseHandCoOwn.Subtype__c = RaiseHandService.SUBTYPE_MULTIPRODUCT;
        raiseHandCoOwn.Skill__c = 'PowerCenter - PS';
        raiseHandCoOwn.Feed_Item_Id__c = feedItem.Id;
        RaiseHandController.createRaiseHand(raiseHandCoOwn);
        raiseHandCoOwn.OwnerId = UserInfo.getUserId();
        update raiseHandCoOwn;

        List<FeedComment> feedComments = new  List<FeedComment>();
        feedComments.add(feedComment);

        RaiseHandService.updateStatus(feedComments);

        Test.stopTest();
    }
}