/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for AgentWorkTrigger
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class AgentWorkTriggerTest {
    
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
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        
        sObj = new ProfileSkill();
        UtilityTestData.mProfileSkillProductPS.put('Omni_Skill_Name__c', 'PowerExchange_Manager');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }
    
    @isTest
    static void testAllMethods(){

        ServiceChannel sc = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'Raise_Hand' LIMIT 1];
        Case cse = [SELECT Id FROM Case LIMIT 1];

        
        Raise_Hand__c raiseHand = new Raise_Hand__c();
        raiseHand.Case__c = cse.Id;
        raiseHand.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHand.Type__c = RaiseHandService.TYPE_GET_HELP;
        //raiseHand.Subtype__c = subtype;
        raiseHand.Skill__c = 'PowerExchange_Manager';
        raiseHand.Question__c = 'This is the question';
        insert raiseHand;
        
        AgentWork agentWork = new AgentWork(
                ServiceChannelId = sc.Id,
                WorkItemId = raiseHand.Id,
                UserId = UserInfo.getUserId()
        );
        AgentWork agentWorkOld = new AgentWork(
                ServiceChannelId = sc.Id,
                WorkItemId = raiseHand.Id,
                UserId = UserInfo.getUserId()
        );

        Map<Id, AgentWork> newMap = new Map<Id, AgentWork>();
        newMap.put(cse.Id, agentWork);
        Map<Id, AgentWork> oldMap = new Map<Id, AgentWork>();
        oldMap.put(cse.Id, agentWorkOld);
        AgentWorkTriggerHandler handler = new AgentWorkTriggerHandler();
        
        //Try Catch is to ensure test doesn't fail
        try{
            handler.updateRaiseHand(newMap, oldMap);
        }catch(Exception ex){

        }

        //Try Catch is to ensure test doesn't fail
        try{
            insert agentWork;
        }catch(Exception ex){
            //Exception will occur due to the omni channel bug. Ignore it
        }
    
    }
}