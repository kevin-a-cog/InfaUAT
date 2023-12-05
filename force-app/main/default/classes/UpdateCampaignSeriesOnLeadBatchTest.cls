/*
Class:          UpdateCampaignSeriesOnLeadBatchTest
@Author:        Anil Solanki
@Created Date:  24- March -2021
@Description:   test class for UpdateCampaignSeriesOnLeadBatch and UpdateCampaignSeriesOnContactBatch

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
public class UpdateCampaignSeriesOnLeadBatchTest{
    
   @testSetup
    static void setupObjectTestData() {
    
        //Creating Marketing User to create Campaign Records
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        UtilityTestData.mUserData.put('ProfileId',adminProfile.id+'');
        UtilityTestData.mUserData.put('ContactId',NULL); 
        UtilityTestData.mUserData.put('Username','marketingTestUserAdmn@m.t');
        UtilityTestData.mUserData.put('Email','marketingTestUserAdmn@m.t');
        UtilityTestData.mUserData.put('Alias','mngr');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('LastName','Test');
        UtilityTestData.mUserData.put('FirstName','User');
        UtilityTestData.mUserData.put('UserPermissionsMarketingUser','true');
       
        sObject marketingUser= new User();
        marketingUser= UtilityTest.putFieldRecord(marketingUser, UtilityTestData.mUserData);        
        List<User> marketingUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{marketingUser});
      
        //Create Campaign records.   
        system.runAs(marketingUserList[0]){
            sObject sobjCampaign = new Campaign();
            sObject sobjCampaign1 = new Campaign();
                
            sobjCampaign = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 1 Series Camp');
            sobjCampaign = UtilityTest.putFieldRecord(sobjCampaign, UtilityTestData.mCampaignData);
            
            sobjCampaign1 = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 2 Series Camp');
            sobjCampaign1 = UtilityTest.putFieldRecord(sobjCampaign1, UtilityTestData.mCampaignData);
                
            sObject sobjCampaign2 = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 3 Series Camp');
            sobjCampaign2 = UtilityTest.putFieldRecord(sobjCampaign2, UtilityTestData.mCampaignData);
                
            sObject sobjCampaign3 = new Campaign();
            UtilityTestData.mCampaignData.put('Name','Test 4 Series Camp');
            UtilityTestData.mCampaignData.put('Campaign_Series__c','MDM');
            sobjCampaign3 = UtilityTest.putFieldRecord(sobjCampaign3, UtilityTestData.mCampaignData);
            List<Campaign> lCampaign = (List<Campaign>) UtilityTest.makeInsert(new List<sObject>{sobjCampaign,sobjCampaign1,sObjCampaign2,sobjCampaign3});
       }

        //Create Leads
        sObject lead = new Lead();
        UtilityTestData.mLeadData.put('FirstName','test Lead Campaign Series ');
        UtilityTestData.mLeadData.put('LastName ','test');
        UtilityTestData.mLeadData.put('Email','testLeadCampaignSeries@testr.q');
        UtilityTestData.mLeadData.put('MQL_Program_Name__c','Test 1 Series Camp');
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
        sObject lead1 = new Lead();
        UtilityTestData.mLeadData.put('FirstName','test Lead Campaign Series 1');
        UtilityTestData.mLeadData.put('LastName ','test1');
        UtilityTestData.mLeadData.put('Email','testLeadCampaignSeries1@testr.q');
        UtilityTestData.mLeadData.put('MQL_Program_Name__c','Test 2 Series Camp');
        lead1 = UtilityTest.putFieldRecord(lead1, UtilityTestData.mLeadData);
            
        sObject lead2 = new Lead();
        UtilityTestData.mLeadData.put('FirstName','test Lead Campaign Series 2');
        UtilityTestData.mLeadData.put('LastName ','test2');
        UtilityTestData.mLeadData.put('Email','testLeadCampaignSeries2@testr.q');
        UtilityTestData.mLeadData.put('MQL_Program_Name__c','Test 2 Series Camp');
        lead2 = UtilityTest.putFieldRecord(lead2, UtilityTestData.mLeadData);
            
        sObject lead3 = new Lead();
        UtilityTestData.mLeadData.put('FirstName','test Lead Campaign Series 3');
        UtilityTestData.mLeadData.put('LastName ','test3');
        UtilityTestData.mLeadData.put('Email','testLeadCampaignSeries3@testr.q');
        UtilityTestData.mLeadData.put('MQL_Program_Name__c','Test 4 Series Camp');
        lead3 = UtilityTest.putFieldRecord(lead3, UtilityTestData.mLeadData);
        List<Lead> lLeads = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead1,lead2,lead3});
            
        sObject contactSobj = new Contact();
        UtilityTestData.mContactData.put('MQL_Program_Name__c','Test 1 Series Camp');
        UtilityTestData.mContactData.put('Name','Test Campaign Series');
        contactSobj= UtilityTest.putFieldRecord(contactSobj, UtilityTestData.mContactData);
            
        sObject contactSobj1 = new Contact();
        UtilityTestData.mContactData.put('MQL_Program_Name__c','Test 2 Series Camp');
        UtilityTestData.mContactData.put('Name','Test Campaign Series1');
        contactSobj1= UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);

        sObject contactSobj2 = new Contact();
        UtilityTestData.mContactData.put('MQL_Program_Name__c','Test 2 Series Camp');
        UtilityTestData.mContactData.put('Name','Test Campaign Series2');
        contactSobj2= UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
        sObject contactSobj3 = new Contact();
        UtilityTestData.mContactData.put('MQL_Program_Name__c','Test 4 Series Camp');
        UtilityTestData.mContactData.put('Name','Test Campaign Series3');
        contactSobj3= UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
        List<Contact> lContact= (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj,contactSobj1,contactSobj2,contactSobj3});
            
        List<Campaign> lCampaigns = (List<Campaign>) UtilityTest.executeQuery('Select Id,Campaign_Series__c from Campaign');
                    
        sObject toUpdateCampaign = (Campaign) lCampaigns[0];
        UtilityTestData.mCampaignData.put('Name','Test 1 Series Camp');
        UtilityTestData.mCampaignData.put('Campaign_Series__c','Cloud');
        toUpdateCampaign = UtilityTest.putFieldRecord(toUpdateCampaign , UtilityTestData.mCampaignData);
            
        sObject toUpdateCampaign1 = (Campaign) lCampaigns[1];
        UtilityTestData.mCampaignData.put('Name','Test 2 Series Camp');
        UtilityTestData.mCampaignData.put('Campaign_Series__c','Big Data');
        toUpdateCampaign1 = UtilityTest.putFieldRecord(toUpdateCampaign1 , UtilityTestData.mCampaignData);
            
        sObject toUpdateCampaign2 = (Campaign) lCampaigns[2];
        UtilityTestData.mCampaignData.put('Name','Test 3 Series Camp');
        UtilityTestData.mCampaignData.put('Campaign_Series__c','Data Quality');
        toUpdateCampaign2 = UtilityTest.putFieldRecord(toUpdateCampaign2 , UtilityTestData.mCampaignData);
          
        List<Campaign> lCampaignsUpdated = UtilityTest.makeUpdate(new list<sObject>{toUpdateCampaign,toUpdateCampaign1,toUpdateCampaign2});
   }
    
   

    //Method to test batch to populate Campaign series on Lead and Contact
    @isTest
    static void myUnitTest_UpdateCampaignSeriesOnLeadBatch() {
        List<Campaign> lCampaign = (List<Campaign>) UtilityTest.executeQuery('Select Id,Campaign_Series__c from Campaign');
        List<Lead> lLead = (List<Lead>) UtilityTest.executeQuery('Select Id,MQL_Program_Name__c from Lead');
        List<Contact> lContact =  (List<Contact>) UtilityTest.executeQuery('Select Id,MQL_Program_Name__c from Contact');
       
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        System.runAs(userObj ) { 
            Test.StartTest();
           
                lLead[3].MQL_Program_Name__c = 'Test 3 Series Camp';
                lLead[3].MQL_Date__c= System.today();
                update lLead[3];
                
                lContact [3].MQL_Program_Name__c = 'Test 3 Series Camp';
                lContact [3].MQL_Date__c= System.today();
                update lContact [3];
                
                UpdateCampaignSeriesOnLeadBatch  cls  = new UpdateCampaignSeriesOnLeadBatch();
                Database.executeBatch(cls);
                
             
            Test.StopTest();
            
            List<Lead> lLeadUpdated = (List<Lead>) UtilityTest.executeQuery('Select Id,MQL_Program_Name__c,Campaign_Series__c from Lead');
            List<Contact> lContactUpdated = (List<Contact>) UtilityTest.executeQuery('Select Id,MQL_Program_Name__c,Campaign_Series__c from Contact');
            /*System.AssertEquals(lLeadUpdated[0].Campaign_Series__c,'Cloud');
            System.AssertEquals(lLeadUpdated[1].Campaign_Series__c,'Big Data');
            System.AssertEquals(lLeadUpdated[2].Campaign_Series__c,'Big Data');
            System.AssertEquals(lLeadUpdated[3].Campaign_Series__c,'Data Quality');
            System.AssertEquals(lContactUpdated[2].Campaign_Series__c,'Big Data');
            System.AssertEquals(lContactUpdated[3].Campaign_Series__c,'Data Quality');*/
        }
         
    }
}