/*
 * Name         :   InAnnouncementBannerTest
 * Author       :   Utkarsh Jain
 * Created Date :   7-March-2022
 * Description  :   Test class for InAnnouncementBanner class.

 Change History
 **********************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                    Tag
 *********************************************************************************************************************************
 Utkarsh Jain           7-March-2022     Utopia-ph-3         Initial version.                                              NA
 Utkarsh Jain           16-JUN-2022      I2RT-6422           Bringing Announcements on Community Page                      NA
 Deeksha Shetty         19-OCT-2023      I2RT-7150           User Group: Revolving Hero banner for User group detail page  T1
 */

@isTest
public with sharing class InAnnouncementBannerTest {
    
    @isTest
    static void getAnnouncementListTest() {

        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Alert').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        InAnnouncementBanner.getAnnouncementList();
        Test.stopTest();

    }
    
    @isTest
    static void getAnnouncementTileListTestHeroBanner() {
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = true;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        InAnnouncementBanner.getAnnouncementTileList('HeroBanner','');
        Test.stopTest();
    }
    
    @isTest
    static void getAnnouncementTileListTestHome() {
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = '';
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        InAnnouncementBanner.getAnnouncementTileList('Home','');
        Test.stopTest();
    }
    
    @isTest
    static void getAnnouncementTileListTestCommunities() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test1',
            NetworkId=networkId,
            Description='abcd');
        insert a;
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = '';
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        InAnnouncementBanner.getAnnouncementTileList('Communities', a.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getAnnouncementTileListTestGroups() {
        
		String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        CollaborationGroup grp=new CollaborationGroup();
        grp.Name='Test Group for test class';
        grp.Description = 'Test Group';
        grp.CollaborationType = 'Public';
        grp.NetworkId = networkId;
        insert grp; 
        
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = grp.Id;
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist; 

        Test.startTest();
        InAnnouncementBanner.getAnnouncementTileList('Groups', grp.Id);
        Test.stopTest();
    }
    
    //T1 -Test method to cover getHeroBannerForUserGroup()
    @isTest
    static void getHeroBannerForUserGroupTest() {
     
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        CollaborationGroup grp=new CollaborationGroup();
        grp.Name='Test Group for test class';
        grp.Description = 'Test Group';
        grp.CollaborationType = 'Public';
        grp.NetworkId = networkId;
        insert grp;
        
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = grp.Id;
            ac.User_Group_picklist__c = 'Arizona User Group';
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - User Group Banner').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist; 

        Test.startTest();
        InAnnouncementBanner.getHeroBannerForUserGroup(grp.Id); 
        Test.stopTest();
    }
    //T1 ends

    @isTest
    static void getCreateAnnouncementFromCommunityTest() {
        List<String> communities = new List<String>();
        communities.add('Data Engineering Integration');
        Test.startTest();
        try{
	        InAnnouncementBanner.createAnnouncementFromCommunity('title','description','2022-01-24','2022-03-24', communities);    
        }
        catch(Exception e){
            
        }    
        Test.stopTest();
    }
    
    @isTest
    static void getCreateAnnouncementFromCommunityTestForNull() {
        List<String> communities = new List<String>();
        communities.add('Data Engineering Integration');
        Test.startTest();
        try{
	        InAnnouncementBanner.createAnnouncementFromCommunity(null,null,'2022-01-24','2022-03-24', communities);            
        }
        catch(Exception e){
            
        }
	
        Test.stopTest();
    }
    
    @isTest
    static void getupdateAnnouncementFromCommunityTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test1',
            NetworkId=networkId,
            Description='abcd');
        insert a;
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = '';
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        List<String> communities = new List<String>();
        communities.add('Data Engineering Integration');
        Test.startTest();
        try{
	        InAnnouncementBanner.updateAnnouncementFromCommunity(aclist[0].Id, 'title','description','2022-01-24','2022-03-24', communities);            
        }
        catch(Exception e){
            
        }

        Test.stopTest();
    }
    
    @isTest
    static void getupdateAnnouncementFromCommunityForNull() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
        Topic a = new Topic(Name='test1',
            NetworkId=networkId,
            Description='abcd');
        insert a;
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Community__c='';
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c='<img alt="User-added image" src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif"></img>';
            ac.Active__c=true;
            ac.User_Group__c = '';
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        List<String> communities = new List<String>();
        communities.add('Data Engineering Integration');
        Test.startTest();
        try{
	        InAnnouncementBanner.updateAnnouncementFromCommunity(aclist[0].Id, null ,null,'2022-01-24','2022-03-24', communities);    
        }
        catch(Exception e){
            
        }
        
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void getHeroBannerForCommunityTest() {
        String networkId = [SELECT NetworkId FROM Community where Name='Informatica Network'].NetworkId;
		List<Topic> a = [Select Id, Name from Topic where Name = 'ActiveVOS'];
        List<Alerts_Announcements__c> aclist = new List<Alerts_Announcements__c>();
        for(Integer i =0 ; i< 10; i++){
            Alerts_Announcements__c ac = new Alerts_Announcements__c();
            ac.Name = 'name'+i;
            ac.Hero_Carousel__c = false;
            ac.Start_Date__c = System.today() - 3;
            ac.End_Date__c = System.today() + 6;
            ac.AnnouncementDescription__c = '<p>https://www.informatica.com</p><p><img src="http://www.diseno-art.com/images_2/for_gt_nav_ffffff-short.gif" alt="img2.jpeg"></img></p>';
            ac.Community__c='ActiveVOS';
            ac.Active__c=true;
            ac.Primary_Banner__c = false;
            ac.RecordTypeId=Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Community Banner').getRecordTypeId();
            aclist.add(ac);
        }
        insert aclist;
        Test.startTest();
        InAnnouncementBanner.getHeroBannerForCommunity(a[0].Id);
        Test.stopTest();
    }

}