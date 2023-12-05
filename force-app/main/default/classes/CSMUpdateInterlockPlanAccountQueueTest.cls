/*Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Narpavi Prabu      28/02/2023		AR-2866			Initial version.			N/A
*/
@isTest
public with sharing class CSMUpdateInterlockPlanAccountQueueTest {
    @testSetup
    static void setupObjectTestData() {

        Date currentDate = Date.today();

        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
		List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        //UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;
      
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
      
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Name', 'Test');
      
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('CloseDate', string.valueOf(System.today().addDays(1)));
        UtilityTestData.mOpportunityData.put('StageName', 'Lead');
     
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});


        // Create Interlock (Related opportunity Plan)
        String interlockRecTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Related Opportunity Plan').getRecordTypeId();  
        List<Related_Opportunity_Plan__c> interlockList = new List<Related_Opportunity_Plan__c>();
        for(integer i=0;i<3;i++){
            Related_Opportunity_Plan__c interlockRec = new Related_Opportunity_Plan__c();
            interlockRec.Opportunity__c = lOpportunity[0].Id;
            interlockRec.Account__c = lNewCustomerAccount[0].Id;
            interlockRec.Plan__c = lPlan[0].Id;
            //interlockRec.Contract__c=contractList[i].Id;
            //interlockRec.Key_customer_contact__c = conList[i].Id;
            interlockRec.RecordTypeId = interlockRecTypeId;
            interlockRec.Implementation_Owner__c ='Customer';
            interlockRec.Partner_name_if_any__c ='IP TEST PARTNER NAME';
            interlockRec.Expected_Start_Date__c = currentDate;
            interlockRec.IPS_Package__c = 'Renewal Rescue';
            interlockRec.Comments__c ='Sample Testing Interlock';
            interlockRec.Partner_name_if_any__c = 'partner Name '+i;
            interlockRec.Ignore_ABV__c=True;
            interlockList.add(interlockRec);
        }
        interlockList[0].Interlock_Type__c = 'JumpStart';
        interlockList[1].Interlock_Type__c = 'Renewal Rescue';
        interlockList[2].Interlock_Type__c = 'Checkup';
        
        insert interlockList;

    }

    @isTest
    public static void testmethod1() {

        Set<Id> opty = new set<Id>();
        for(Opportunity opp:[Select Id from Opportunity]){
            opty.add(opp.Id);
        }
         CSMUpdateInterlockPlanAccountQueueable apc = new CSMUpdateInterlockPlanAccountQueueable(opty);
        Test.startTest();
          System.enqueueJob(apc);
        Test.stopTest();
       
    }

}