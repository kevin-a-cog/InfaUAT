@isTest

public class EstimationSummaryTriggerHandlerTest {

    private Final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    static void setupObjectTestData() {
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive=true AND UserRoleId != null Limit 1];
        
        System.runAs(adminUser){
           
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account 1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('FirstName','Test');
        UtilityTestData.mContactData.put('LastName','Contact 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);


        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name','Test Opty');
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Estimation_Summary__c estimationSummary = IPUE_TestUtils.createEstimationSummary(true, lOpportunity[0].Id);
        //estimationSummary.Account__c = lAccount[0].Id;
        estimationSummary.Status__c = 'Initialized Agreement';
        update estimationSummary;
        
        Estimation_Summary__c estimationSummary1 = IPUE_TestUtils.createEstimationSummary(false, lOpportunity[0].Id);
        estimationSummary1.Primary__c = true;
		insert estimationSummary1;
        
        Test.startTest();

        estimationSummary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];
        
        List<Estimator_Collaborator__c> lstEstimatorCollaborator = IPUE_TestUtils.createEstimatorCollaborator(true,lContact,estimationSummary);

        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User' LIMIT 1];

		sObj = new User();
        UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest1a@m.t');
        UtilityTestData.mUserData.put('Email','mtest1a@m.t');
        UtilityTestData.mUserData.put('Alias','alias1');
        UtilityTestData.mUserData.put('CommunityNickname','mtest1');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('ContactId',lContact[0].Id+'');
        UtilityTestData.mUserData.put('IsPortalEnabled','true');
        UtilityTestData.mUserData.put('LastName','User 1');
        UtilityTestData.mUserData.put('CompanyName','TEST');
        UtilityTestData.mUserData.put('isactive','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        

        sObj1 = new User();
        UtilityTestData.mUserData.put('ProfileId',communityProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest2a@m.t');
        UtilityTestData.mUserData.put('Email','mtest2a@m.t');
        UtilityTestData.mUserData.put('Alias','alias2');
        UtilityTestData.mUserData.put('CommunityNickname','mtest2');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('ContactId',lContact[1].Id+'');
        UtilityTestData.mUserData.put('IsPortalEnabled','true');
        UtilityTestData.mUserData.put('LastName','User 2');
        UtilityTestData.mUserData.put('CompanyName','TEST');
        UtilityTestData.mUserData.put('isactive','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData);
  
        List<User> communityUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Estimator_Collaborator__c> lstEstimatorCollaborator1 = [SELECT Id,Contact__c,Estimation_Summary__c FROM Estimator_Collaborator__c];
        lstEstimatorCollaborator1[0].Dev_Community_User__c = communityUserList[0].id;
        Update lstEstimatorCollaborator1;
   
        Test.stopTest();
     }       
    }
    
	@isTest
    public static void testAfterUpdate(){
        
        List<Estimation_Summary__c> estimationSummary = [SELECT ID, Status__c,Opportunity__c from Estimation_Summary__c WHERE Status__c != 'Finalized Agreement' LIMIT 1];
        estimationSummary[0].Status__c = 'Finalized Agreement';
        update estimationSummary;
    }
    @isTest
    public static void testAfterUpdate1(){
        List<Estimation_Summary__c> estimationSummary = [SELECT ID, Status__c,Opportunity__c from Estimation_Summary__c WHERE Status__c != 'Cancelled' LIMIT 1];
        estimationSummary[0].Status__c = 'Cancelled';
        update estimationSummary;
    }
    @isTest 
    public static void testAfterUpdate3(){
      String minimumAS = 'Read Only';
      Id p = [SELECT Id, Name FROM   Profile WHERE  Name=:minimumAS].id;
   	 User usr = new User(LastName = 'lstnme',
                        FirstName='fname',
                        Alias = 'jias',
                        Email = 'hs@jjk.com',
                        Username = 'hs@mg.com',
                        ProfileId = p,
                        TimeZoneSidKey = 'GMT',
                        LanguageLocaleKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LocaleSidKey = 'en_US'
    );
    insert usr;
    system.runAs(usr) {
        try{
       List<Estimation_Summary__c> estimationSummary = [SELECT ID, Status__c,Opportunity__c from Estimation_Summary__c WHERE Status__c != 'Finalized Agreement' LIMIT 1];
        estimationSummary[0].Status__c = 'Finalized Agreement';
        update estimationSummary;
    }  
        catch(Exception e){
            System.debug('Error is: '+e.getMessage());
        }
    }
    System.assert(usr.Id != null,'User insertion is failed');
     }
}