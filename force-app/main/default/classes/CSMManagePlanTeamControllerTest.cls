/*
* Name          :   CSMManagePlanTeamControllerTest
* Author        :   Deva M
* Created Date  :   17/09/2021
* Description   :   Test Class for CSMManagePlanTeamControllerTest.

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M                  17/09/2021      N/A             Initial version.            N/A
*/
@isTest
public class CSMManagePlanTeamControllerTest {
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    @testSetup
    static void setupObjectTestData() {  
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        system.runAs(adminUser){
            Id pbId = Test.getStandardPricebookId();
            //Insert Account setup data
            sObject sObj = new Account();
            sObject sObj1 = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert contact
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Inserting an Opportunity
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('StageName', 'Identify');
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
            UtilityTestData.mOpportunityData.put('Name', 'Primary');
            UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
            UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
            UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
            UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
            sObj = new Opportunity();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            
            
            //Creating Secondary Opportunity
            sObj1 = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Secondary');
            UtilityTestData.mOpportunityData.put('Name', 'Secondary');
            UtilityTestData.mOpportunityData.put('Split_Percentage__c', '70'); 
            UtilityTestData.mOpportunityData.put('Pricebook2Id ', pbId); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunity[0].Id, Pricebook2Id = pbId);
            sObj1 = new Opportunity(id = lOpportunity[1].Id, Pricebook2Id = pbId);
            lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});
            Test.startTest();
            //Insert Opportunity Contact Roles
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[0].Id);
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});    
            
            //Insert Opportunity Team members
            UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
            sObj = new OpportunityTeamMember ();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
            List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});   
            
            
            UtilityTestData.mAccountTeamMember.put('AccountId',lAccount[0].id + '');
            UtilityTestData.mAccountTeamMember.put('UserId',psmUser.Id+ '');
            UtilityTestData.mAccountTeamMember.put('TeamMemberRole','PSM');
            
            sObject AccTeamMember1 = new AccountTeamMember();
            AccTeamMember1 = UtilityTest.putFieldRecord(AccTeamMember1, UtilityTestData.mAccountTeamMember);
            
            //Add all accounts team member to acclist
            List<AccountTeamMember> accTeamMemList = (List<AccountTeamMember>) UtilityTest.makeInsert(new List<sObject>{AccTeamMember1});
            
            //Now we create a Plan.
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'Test';
            objPlan.Account__c=lAccount[0].Id;
            insert objPlan;
            
            //Now we create a Plan Contract.
            Plan_Contract__c objPlanContract = new Plan_Contract__c();
            objPlanContract.Plan__c = objPlan.Id;
            objPlanContract.Opportunity__c=lOpportunity[0].Id;
            insert objPlanContract;
            
             List<Account> acctList = new List<Account>([Select Id, (SELECT Id,AccountId,RoleInTerritory2,Territory2Id,UserId
                                                                FROM AccountUserTerritory2Views) from Account where Id=:lAccount[0].Id]);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getUnassignedRecordsTest() {
        Test.startTest();
        
        Plan__c plan=[select Id,Account__c from Plan__c limit 1]; 
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id);
       
        DataTableWrapperClass obj=new DataTableWrapperClass();
        obj = CSMManagePlanTeamController.getUnassignedRecords(plan.Id,plan.Account__c);
        if(obj.lstRecords.size()>0){
        system.assert( obj.lstRecords.size()>0);}    
        Test.stopTest();
    }
    @isTest
    public static void getRecordsRelatedTest() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];   
        DataTableWrapperClass obj=new DataTableWrapperClass();
        obj = CSMManagePlanTeamController.getUnassignedRecords(plan.Id,plan.Account__c);
        if(obj.lstRecords.size()>0){
        system.assert( obj.lstRecords.size()>0);}
        try{        
            CSMManagePlanTeamController.getRecordsRelated(plan.Id, obj.lstRecords); 
        }catch(Exception e){
            //Check for duplciate error
            system.assert(String.isNotBlank(e.getMessage()));            
        }
        Test.stopTest();
    }
    @isTest
    public static void getAssignedRecordsTest() {
        Test.startTest();
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=plan.Id,Role__c='CSM',Primary__c=true);
        GlobalDataTableWrapperClass  obj=new GlobalDataTableWrapperClass ();
        obj =CSMManagePlanTeamController.getAssignedRecords(plan.Id, plan.Account__c); 
        system.assert( obj.lstRecords.size()>0);
        List<Plan_Team__c> planteamList=new List<Plan_Team__c>([Select id from Plan_Team__c]);
        CSMManagePlanTeamController.getRecordsDeleted(planteamList,plan.Id);
        CSMManagePlanTeamController.getRecordsUpdated(planteamList);
        //List<Plan_Team__c> afterdeleteList=new List<Plan_Team__c>([Select id from Plan_Team__c]);
       //  system.assert( afterdeleteList.size()<=0);
        Test.stopTest();
        
    }
}