/*
 * Name         :   helpUserRelatedListTest
 * Author       :   Utkarsh Jain
 * Created Date :   14-FEB-2022
 * Description  :   Test class for helpUserRelatedList class.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-FEB-2022     Utopia-ph-3         Initial version.                                          NA
 */

@isTest
public with sharing class helpUserRelatedListTest {
    
    @isTest
    static void getGroupListTest() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       
        system.runAs(thisUser){

            Test.startTest();
            helpUserRelatedList.getGroupList(thisUser.Id);
            Test.stopTest();
        } 
    }
   
    @isTest
    static void getCommunityListTest() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser){

            Test.startTest();
            helpUserRelatedList.getCommunityList(thisUser.Id);
            Test.stopTest();
        } 
    }
    
    @isTest
    static void getCommunityNameTest() {
        Topic tp = new Topic();
        tp.Name = 'test topic';
        insert tp;
        Test.startTest();
        helpUserRelatedList.getCommunityName(tp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCommunityNameTestNull() {
        Topic tp = new Topic();
        tp.Name = 'test topic';
        insert tp;
        Test.startTest();
        helpUserRelatedList.getCommunityName('');
        Test.stopTest();
    }
    
    @isTest
    static void getSubCommunityListTest() {     
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
      
        Topic tp =new Topic();
        tp.Name = 'XYZ';
        tp.NetworkId = networkId;
        insert tp;
       
        Test.startTest();
        try{
            helpUserRelatedList.getSubCommunityList(networkId, 'Data Integration');  
        }
        Catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
    
    @isTest
    static void getSubCommunityListTest2() {     
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
      
        Topic tp =new Topic();
        tp.Name = 'XYZ';
        tp.NetworkId = networkId;
        insert tp;
       
        Test.startTest();
        try{
            helpUserRelatedList.getSubCommunityList(networkId, 'B2B Data Exchange');  
        }
        Catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
    
    
    @isTest
    static void getEventListTest() {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        system.runAs(thisUser){

            Test.startTest();
            helpUserRelatedList.getEventList(thisUser.Id);
            Test.stopTest();
        } 
    }
    
    
    @isTest
    static void getTopParticipantsByCommunityTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = '1234test536';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
           
            
            Topic tp = new Topic(Name='Cloud INtegratuud');
            tp.NetworkId = networkId;
            insert tp;
            
            
            EntitySubscription entiti = new EntitySubscription();
            entiti.NetworkId = networkId;
            entiti.ParentId = tp.Id;
            entiti.SubscriberId = user2.Id;
            insert entiti;
            
            Test.startTest();
            try{
                helpUserRelatedList.getTopParticipantsByCommunity(networkId, tp.Id);
            }
            Catch(Exception ex){}
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void getTopIdeasTest() {      
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        List<Idea> aclist = new List<Idea>();
        for(Integer i =0 ; i< 10; i++){
            Idea id1 = new Idea();
            id1.title = 'Test Idea';
            id1.Status = 'New';
            id1.Categories = 'XYZ';
            id1.Upvote_Count__c = 5;
            id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;
            aclist.add(id1);
        }
        insert aclist;
        
        Topic tp1 = new Topic();
        tp1.Name = 'XYZ';
        insert tp1;
        
        Community_Interactions__c cin = new Community_Interactions__c();
        cin.Id__c = aclist[0].Id;
        cin.Follow__c = true;
        cin.Vote__c = 'Upvote';
        cin.IsLiked__c = true;
        cin.User__c = userinfo.getUserId();
        insert cin;
        
        Test.startTest();
        try{
            helpUserRelatedList.getTopIdeas(networkId,tp1.Id);
        }
        Catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
    @isTest(SeeAllData=True)
    static void getHighlightsTest() {

        Topic tp1 = new Topic();
        tp1.Name = 'XYZ';
        insert tp1;
        Topic tp = new Topic();
        tp.Name = 'topic';
        insert tp;
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'topic';
            ac.Community__c='Cloud Integration;Data Integration';
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        helpUserRelatedList.getHighlights(tp.Id);
        Test.stopTest();
    }
    
    @isTest(SeeAllData=True)
    static void getHighlightsTest2() {

        Topic tp = new Topic();
        tp.Name = 'topic';
        insert tp;
        Topic tp1 = new Topic();
        tp1.Name = 'XYZ';
        insert tp1;
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'topic';
            ac.Community__c='Cloud Integration';
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        helpUserRelatedList.getHighlights(tp.Id);
        Test.stopTest();
    }

    @isTest
    static void getTopParticipantsByGroupTest() {

        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
      
        CollaborationGroup grp=new CollaborationGroup();
        grp.Name='Test Group 321';
        grp.Description = 'Test Group';
        grp.CollaborationType = 'Public';
        grp.NetworkId = networkId;
        insert grp;        
                
        Test.startTest();
        try{
             helpUserRelatedList.getTopParticipantsByGroup(networkId, grp.Id);
        }
        Catch(Exception ex){}
       
        Test.stopTest();
        
    }
    
    @isTest
    static void getCurrentUserDetailsTest() { 
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;        
        
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId =[Select Id From UserRole Where DeveloperName = 'WW_Sales_EVP' Limit 1].Id;     
        insert adminUser;
        
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        
        User user2;
        System.runAs(adminUser) {
            
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.BillingCountry='USA';
            insert acct;
            
            Contact contact = new Contact();
            contact.LastName = 'Test';
            contact.FirstName = 'Test';
            contact.accountId = acct.Id;
            insert contact;
            
            user2 = new User();
            user2.FirstName = 'Test2';
            user2.LastName = 'Test2';
            user2.Alias = 'Test2';
            user2.Email = 'someotheremail@blabla.com';
            user2.UserName = 'someotheremail@blabla.com';
            user2.EmailEncodingKey = 'UTF-8';
            user2.LanguageLocaleKey = 'en_US';
            user2.LocaleSidKey = 'en_US';
            user2.TimezoneSidKey = 'America/Los_Angeles';
            user2.ContactId = contact.Id;
            user2.ProfileId = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Customer Community Plus User'
            ].Id;
            //user2.UserRoleId = userRole.Id;
            insert user2;
            
           
        }
        //String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
      	//User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Test.startTest();
        helpUserRelatedList.getCurrentUserDetails(networkId, user2.Id);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void getMetadataRecordFromCustomLabelTest() {  
        Test.startTest();
        helpUserRelatedList.getMetadataRecordFromCustomLabel('custom label');
        Test.stopTest();
        
    }
    
    @isTest
    static void getMetadataRecordFromCustomLabelTest1() {  
        Test.startTest();
        helpUserRelatedList.getMetadataRecordFromCustomLabel('');
        Test.stopTest();
        
    }
    
    static testmethod void testIncrement() {
        helpUserRelatedList.justIncrement();
    }
    
    
}