/*
* Name          :   CSMManagePlanPartnersControllerTest
* Author        :   Deva M
* Created Date  :   15/09/2021
* Description   :   Test class for CSMManagePlanPartnersController

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M                  15/09/2021      N/A             Initial version.            N/A
*/
@isTest
public class CSMManagePlanPartnersControllerTest {
    
    static Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
    static Id OpptyRec1TypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();   
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    @testSetup
    static void setupObjectTestData() {
        
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        
        List<lead> leadList;
        //Assign CSM permissions
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList.size()>0){
            insert psAssignList;
        }
        system.runAs(adminUser){
            Account accRecord=[Select Id from Account where RecordTypeId=:AccRecTypeId_PrtnrAccnt limit 1];
            /*------------------------------------------------Test Opportunity---------------------------------------------------------------*/
            //Create Opportunity record
            UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
            UtilityTestData.mOpportunityData.put('Name','TestOppty');
            UtilityTestData.mOpportunityData.put('AccountId',accRecord.id);
            UtilityTestData.mOpportunityData.put('Sales_Play__c','Data Quality');
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');        
            UtilityTestData.mOpportunityData.put('CloseDate','2018-02-05');
            
            //Create Opportunity sObject
            sObject channeloppty = new Opportunity();
            channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
            
            //Create Opportunity record
            UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRecTypeId);
            UtilityTestData.mOpportunityData.put('Name','TestOppty1');
            
            //Add all opportunity to list
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty});
            
            sObject sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId', accRecord.Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',opptyList[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Test.startTest();
            /*------------------------------------------------Test Partner Relationship---------------------------------------------------------*/
            //Create partner relationship record
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',opptyList[0].id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accRecord.id);
            UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','false');
            //Create Partner_Relationship__c sObject
            sObject partreln = new Partner_Relationship__c();
            partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);       
            List<SObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});
            //Now we create a Plan.
            Plan__c objPlan = new Plan__c();
            objPlan.Name = 'Test';
            objPlan.Account__c=accRecord.Id;
            insert objPlan;
            
            Plan_Contract__c plancon = new Plan_Contract__c();
            plancon.Plan__c =objPlan.id;
            plancon.Contract__c= lContract[0].id;
            plancon.Opportunity__c=opptyList[0].Id;
            insert plancon;
            Test.stopTest();
        }        
    }
    
    @isTest
    public static void getUnassignedRecordsTest() {
        Test.startTest();
        System.runAs(createTestUser('System Administrator', true)) {
        Plan__c plan=[select Id,Account__c from Plan__c limit 1];   
        DataTableWrapperClass obj=new DataTableWrapperClass();
        obj = CSMManagePlanPartnersController.getUnassignedRecords(plan.Id);
        system.assert( obj.lstRecords.size()>0);        
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getAssingedRecordsTest() {
        Test.startTest();
        System.runAs(createTestUser('System Administrator', true)) {
            
        Plan__c plan=[select Id,Account__c from Plan__c limit 1]; 
            List<Partner_Relationship__c> part=[SELECT Id,Plan__c,Partner_Account__c FROM Partner_Relationship__c];
        GlobalDataTableWrapperClass obj=new GlobalDataTableWrapperClass();
        CSMManagePlanPartnersController.getRecordsRelated(plan.Id,part);
        obj = CSMManagePlanPartnersController.getAssingedRecords(plan.Id);
        CSMManagePlanPartnersController.getPlanPartnerRecordType();
        system.assert( obj.lstRecords.size()>0); 
        List<Partner_Relationship__c> afterAssinged=[SELECT Id,Plan__c FROM Partner_Relationship__c];
        CSMManagePlanPartnersController.getRecordsDeleted(afterAssinged);
            //List<Partner_Relationship__c> afterUnAssinged=[SELECT Id,Plan__c FROM Partner_Relationship__c];
            //system.assert(afterUnAssinged[0].Plan__c==null); 
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getRecordsRelatedTest() {
        Test.startTest();
        System.runAs(createTestUser('System Administrator', true)) {
        Plan__c plan=[select Id,Account__c from Plan__c limit 1]; 
        List<Partner_Relationship__c> part=[SELECT Id,Plan__c,Partner_Account__c FROM Partner_Relationship__c];
        GlobalDataTableWrapperClass obj=new GlobalDataTableWrapperClass();
        try{            
            CSMManagePlanPartnersController.getRecordsRelated(plan.Id,part);
        }catch(Exception e){
            //Check for duplciate error
            system.assert(String.isNotBlank(e.getMessage()));       
        }             
        }
        Test.stopTest();
    }
    
    /*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
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
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}