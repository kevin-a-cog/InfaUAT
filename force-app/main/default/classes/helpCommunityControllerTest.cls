/*
 * Name         :   helpCommunityControllerTest
 * Author       :   Utkarsh Jain
 * Created Date :   14-FEB-2022
 * Description  :   Test class for helpCommunityController class.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2022     Utopia-ph-3         Initial version.                                          NA
 Utkarsh Jain           28-SEPT-2022    I2RT-7062           Salesforce application related to quick link              1
 Prashanth Bhat         23-JUN-2023     I2RT-8529           Introduce New sorting option in the Product community.    2
 */

@isTest
public with sharing class helpCommunityControllerTest {

    @IsTest(SeeAllData=true)
    static void getAllCommunity() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;
        
        EntitySubscription en = new EntitySubscription();
        en.NetworkId = networkId;
        en.SubscriberId = UserInfo.getUserId();
        en.ParentId = topics[0].Id;
        insert en;
        
        Test.startTest();
        helpCommunityController.getAllCommunity(networkId, UserInfo.getUserId(), 'ASC', '');
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void getMyCommunities() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
            Description='abcd');
            topics.add(a);
        }
        insert topics;

        EntitySubscription en = new EntitySubscription();
        en.NetworkId = networkId;
        en.SubscriberId = UserInfo.getUserId();
        en.ParentId = topics[0].Id;
        insert en;
            
        Test.startTest();
        helpCommunityController.getMyCommunities(networkId, UserInfo.getUserId(), 'ASC', '');
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void getRecommendedCommunity() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

        EntitySubscription en = new EntitySubscription();
        en.NetworkId = networkId;
        en.SubscriberId = UserInfo.getUserId();
        en.ParentId = topics[0].Id;
        insert en;
        
        Test.startTest();
        helpCommunityController.getRecommendedCommunity(networkId, UserInfo.getUserId(), 'ASC', '');
        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void getAllCommunityOptions() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

            Test.startTest();
            helpCommunityController.getAllCommunityOptions(networkId);
            Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void getFollowingCommunity() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

            Test.startTest();
            helpCommunityController.getFollowingCommunity(topics[0].Id, UserInfo.getUserId(), networkId);
            Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void followCommunity() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

            Test.startTest();
            try{
                helpCommunityController.followCommunity(topics[0].Id, UserInfo.getUserId(), networkId);
            }catch(Exception ex){

            }
            Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void unfollowCommunity() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

            Test.startTest();
            helpCommunityController.unfollowCommunity(topics[0].Id, UserInfo.getUserId(), networkId);
            Test.stopTest();
    }
    
    @isTest
    static void getAllCommunitiesTest() {  
          Help_Community__mdt mt = new Help_Community__mdt();
            mt.ParentCommunity__c = 'data test integration';
            mt.SubCommunities__c = 'data test integration;cloudtestintegratiom;vcbbdhdjd';
        Test.startTest();
        helpCommunityController.getAllCommunities();
        Test.stopTest();
        
    }
    
     @IsTest(SeeAllData=true)
    static void getAllCommunityListTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

        List<Topic> topics = new List<Topic>();
        for(Integer i =0 ; i< 10; i++){
            Topic a = new Topic(Name='test'+i,
            NetworkId=networkId,
                                Description='abcd');
            topics.add(a);
        }
        insert topics;

            Test.startTest();
            helpCommunityController.getAllCommunityList(networkId, 'ASC');
            Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void getAnalyticsDataTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

       helpCommunityAnalytics__mdt mt = new helpCommunityAnalytics__mdt();
            mt.analytics_data__c = '123;234;345;456';

            Test.startTest();
            helpCommunityController.getAnalyticsData();
            Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void getCommunityIdTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;

            Topic a = new Topic(Name='cloud test integration',NetworkId=networkId,Description='abcd');
        	insert a;

            Test.startTest();
            helpCommunityController.getCommunityId('cloud test integration',networkId);
            Test.stopTest();
    }
    
    // Tag 1 Start

    @IsTest(SeeAllData=true)
    static void getQuickLinksTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        helpQuickLink__mdt mt = new helpQuickLink__mdt();
        Test.startTest();
        helpCommunityController.getQuickLinks();
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void updateQuickLinksTest() {
        Alerts_Announcements__c ac = new Alerts_Announcements__c();
        ac.Name = 'name';
        ac.Community__c='ActiveVOS';
        ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
        ac.Active__c=true;
        ac.Start_Date__c = System.today() - 3;
        ac.End_Date__c = System.today() + 6;
        ac.Quick_Links__c = 'abc;def';
        ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Quick Links').getRecordTypeId();
		insert ac;
        
        String newQuickList = 'def;abc';
        
        Test.startTest();
        helpCommunityController.updateQuickLinks(ac.Id, newQuickList);
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void getQuickLinksForRecordTest() {
        Alerts_Announcements__c ac = new Alerts_Announcements__c();
        ac.Name = 'name';
        ac.Community__c='ActiveVOS';
        ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
        ac.Active__c=true;
        ac.Start_Date__c = System.today() - 3;
        ac.End_Date__c = System.today() + 6;
        ac.Quick_Links__c = 'abc;def';
        ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Quick Links').getRecordTypeId();
		insert ac;
        
        Test.startTest();
        helpCommunityController.getQuickLinksForRecord(ac.Id);
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void getQuickLinksForCommunityTest() {
        
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test',
                            NetworkId=networkId,
                            Description='abcd');
        insert a;

        Alerts_Announcements__c ac = new Alerts_Announcements__c();
        ac.Name = 'name';
        ac.Community__c='ActiveVOS';
        ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
        ac.Active__c=true;
        ac.Start_Date__c = System.today() - 3;
        ac.End_Date__c = System.today() + 6;
        ac.Quick_Links__c = 'abc;def';
        ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Quick Links').getRecordTypeId();
		insert ac;
        
        try{
            Test.startTest();
            helpCommunityController.getQuickLinksForCommunity(a.Id);
	        Test.stopTest(); 
        }catch(Exception e){
    		System.debug('Error occured'+ e);        
        }
    }

    // Tag 1 end
    // Tag 2 start
    
    @IsTest(SeeAllData=true)
    static void getMostPopularFollowedCommunityTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Test.startTest();
        helpCommunityController.getMostFollowedCommunity(networkId);
        helpCommunityController.getMostPopularCommunity(networkId);
        Test.stopTest();        
    }
    //Tag 2 END
}