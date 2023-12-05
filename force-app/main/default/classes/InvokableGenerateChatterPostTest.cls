@isTest
public class InvokableGenerateChatterPostTest {
  @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        account.put('billingcountry','IN');
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Contact
        sObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);   
        sObject sObj2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj2});
        
        //Opportunity
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
        //plan
         Plan__c planRec = new Plan__c();
            planRec.Name = 'Test Plan ';
            planRec.Account__c = lAccount[0].Id;
            planRec.Status__c ='Active';
            insert planRec;
        //interlock
        String interlockRecTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();
         Related_Opportunity_Plan__c interlockRec = new Related_Opportunity_Plan__c();
            interlockRec.Opportunity__c = lOpty[0].Id;
            interlockRec.Account__c = lAccount[0].Id;
            interlockRec.Plan__c = planRec.Id;
            interlockRec.Key_customer_contact__c = lContact[0].Id;
            interlockRec.RecordTypeId = interlockRecTypeId;
            interlockRec.Implementation_Owner__c ='Customer';
            interlockRec.Partner_name_if_any__c ='IP TEST PARTNER NAME';
            interlockRec.Expected_Start_Date__c = system.today();
            interlockRec.IPS_Package__c = 'Renewal Rescue';
            interlockRec.Comments__c ='Sample Testing Interlock';
            interlockRec.Partner_name_if_any__c = 'partner Name ';
            interlockRec.Ignore_ABV__c=True;
            insert interlockRec;
        // engagement
          Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
          sObject engagement = new Engagement__c();
          UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
          UtilityTestData.mEngagementData.put('Name','Test Engagment');//
          UtilityTestData.mEngagementData.put('Plan__c',planRec.Id);
          UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
          UtilityTestData.mEngagementData.put('Opportunity__c',lOpty[0].Id);
          UtilityTestData.mEngagementData.put('Key_Customer_Contact__c',lContact[0].Id);
          UtilityTestData.mEngagementData.put('Primary_challenges__c',' Technical Issue');
          UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
          UtilityTestData.mEngagementData.put('Estimated_Start_Date__c',system.today()+'');
          UtilityTestData.mEngagementData.put('IPS_Package__c','JumpStart: Axon');
          UtilityTestData.mEngagementData.put('CSM_Closing_Comments__c','Testing 121');
          engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);
          List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
           
            
    }
    @isTest
    public static void testEngagementCtrl() {
        List<Account> lAccount = [Select Id from Account limit 1];
        List<Opportunity> lOpportunity = [Select Id from Opportunity limit 1];
        List<contact> lContact = [Select Id from contact limit 1];
        list<Engagement__c> eng = [select id from Engagement__c limit 1];
        Test.startTest();
        // Project
            pse__Proj__c projRec = new pse__Proj__c();
            projRec.Name = 'Test Project 1';
            projRec.pse__Project_Manager__c = lContact[0].Id;
            projRec.pse__Opportunity__c = lOpportunity[0].Id;
            projRec.pse__Account__c = lAccount[0].Id;  
            projRec.CurrencyIsoCode='USD';
            projRec.psa_pm_Engagement__c = eng[0].id;
            projRec.pse__Start_Date__c=system.today().addDays(-6);
            projRec.pse__End_Date__c = system.today().addDays(10);
            projRec.pse__Is_Active__c=false;
            projRec.pse__Billings__c=10;
            projRec.pse__Bookings__c=100;
            projRec.pse__Allow_Self_Staffing__c=true;
            projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
            projRec.psa_pm_Require_Product_On_Timecards__c =false;
            projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
            projRec.psa_pm_Require_Location_On_Timecards__c = false;
            insert projRec;
        
        InvokableGenerateChatterPost.invokeChatterPost(new List<Id>{projRec.Id});
        Test.stopTest();
    }
}