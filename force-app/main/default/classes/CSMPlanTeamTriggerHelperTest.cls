/*
* Name          :   CSMPlanTeamTriggerHelperTest
* Author        :   Deva M
* Created Date  :   17/09/2021
* Description   :   Test class for Plan Team trigger

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M                  17/09/2021      N/A             Initial version.            N/A
*/
@isTest
public class CSMPlanTeamTriggerHelperTest {
     /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        objTestUser.ManagerId = UserInfo.getUserId();
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        
        return objTestUser;
    }
    @testSetup
    static void setupObjectTestData() {  
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        
    
        
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
        
     
        
         //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
       // UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Active VOS');
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c',lOpportunity[0].Id);
                
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});
 
     
        
          //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
        
         //Now we create a Risk Product Alias.
         Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
         objRiskProductAlias.Opportunity__c = lOpportunity[0].Id;
         objRiskProductAlias.Risk__c = lRisk[0].Id;
         insert objRiskProductAlias;
         user adminuser=createTestUser('System Administrator', true);
         insert new Plan_Team__c(User__c=adminuser.Id, Plan__c=lPlan[0].Id,Role__c='Account Manager',Primary__c=false);
               
    }
    
    
    @isTest
    public static void validationHelperTest() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];   
        DataTableWrapperClass obj=new DataTableWrapperClass();
        obj = CSMManagePlanTeamController.getUnassignedRecords(plan.Id,plan.Account__c);
        //system.assert( obj.lstRecords.size()>0);
        try{        
            CSMManagePlanTeamController.getRecordsRelated(plan.Id, obj.lstRecords); 
        }catch(Exception e){
            //Check for duplciate error
            system.assert(String.isNotBlank(e.getMessage()));            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void processBeforeInsertTest() {
        Test.startTest();
            Plan__c plan=[select Id,Account__c from Plan__c limit 1];
            insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,Role__c='CSA');   
        Test.stopTest();     
    }
    
     @isTest
    public static void processBeforeUpdateTest() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];
        Id userRecordId=UserInfo.getUserId();
        user adminuser=createTestUser('System Administrator', true);
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        planTeamList.add(new Plan_Team__c(User__c=adminuser.Id, Plan__c=plan.Id,Role__c='Collaborator',Primary__c=true));   
        planTeamList.add(new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true)); 
        planTeamList.add(new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true)); 
        insert planTeamList;
        for(Plan_Team__c pTeam:planTeamList){
            if(!pTeam.Primary__c){
                pTeam.Primary__c=true;
                pTeam.User__c=adminuser.Id;
            }
        }
        try{
            update planTeamList;
        }catch(Exception e){

        }
        Test.stopTest(); 
    }
    
     @isTest
    public static void processBeforeUpdateTest2() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];
        Id userRecordId=UserInfo.getUserId();
        user adminuser=createTestUser('System Administrator', true);
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        planTeamList.add(new Plan_Team__c(User__c=adminuser.Id, Plan__c=plan.Id,Role__c='Collaborator',Primary__c=true));   
        planTeamList.add(new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,Role__c='CSA',Primary__c=false)); 
        insert planTeamList;
        for(Plan_Team__c pTeam:planTeamList){
            if(!pTeam.Primary__c){
                pTeam.Primary__c =true;
                pTeam.User__c=adminuser.Id;
            }
        }
        try{
            update planTeamList;
        }catch(Exception e){

        }
        Test.stopTest(); 
    }

    @isTest
    public static void makePlanTeamCsmPrimary() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.CSM_isAutoPilot__c = true;
        update plan;
        Id userRecordId=UserInfo.getUserId();
        String planTeamId;
        user adminuser=createTestUser('System Administrator', true);
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        try{
        delete [select Id from Plan_Team__c];
        }
        catch(Exception e){
        }
        planTeamList.add(new Plan_Team__c(User__c=adminuser.Id, Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true));
        planTeamList.add(new Plan_Team__c(User__c=adminuser.Id, Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true));
        
        try{
         insert planTeamList;
        }catch(Exception e){
         }
        
        Test.stopTest(); 
    }
    @isTest
    public static void makePlanTeamCsmPrimary2() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.CSM_isAutoPilot__c = true;
        update plan;
        Id userRecordId=UserInfo.getUserId();
        String planTeamId;
        user adminuser=createTestUser('System Administrator', true);
        List<Plan_Team__c> planTeamList = new List<Plan_Team__c>();
        try{
        delete [select Id from Plan_Team__c];
        }
        catch(Exception e){
        }
        planTeamList.add(new Plan_Team__c(User__c=adminuser.Id, Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM,Primary__c=true));
        
        try{
         insert planTeamList;
        }catch(Exception e){
         }
        
        Test.stopTest(); 
    }


    @isTest
    public static void updatePrimaryCSM() {
        Test.startTest();
        Plan_Team__c plan=[select Id,Role__c, Primary__c FROM Plan_Team__c Where Primary__c=false Limit 1];
        plan.Role__c=CSMUtilities.ROLE_CSM;
        plan.Primary__c = true; 
        try{
            update plan;
        }catch(Exception e){

        }
        Test.stopTest(); 
    }
    
    @isTest
    public static void CSMDataTableQueryUtilities() {
        Test.startTest();
        set <String> setplan = new Set<String> ();
        Set<String> planteam = new Set<String>();
        Plan_Team__c plan=[select Id from Plan_Team__c Limit 1];
        setplan.add(plan.id);       
        CSMDataTableQueryUtilities.getPlanTeamByPlanId(setplan);                
        Test.stopTest(); 
    }
}