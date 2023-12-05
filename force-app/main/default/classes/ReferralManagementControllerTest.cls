/*
* Name      :  ReferralManagementControllerTest
* Author    :  
* Created Date  :
* Description  :  Test class for ReferralManagementController

Change History
**********************************************************************************************************
Modified By         Date        Jira No.    Description                                         Tag
**********************************************************************************************************
ChaitanyaT       20-Sept-2023   AR-3383     Expansion Lead File upload and chatter post update  <T01>
*/
@isTest
public class ReferralManagementControllerTest {
    static Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();

    @testSetup
    static void setupObjectTestData() {
        Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);

       //Customer Account
        sObject Account = new Account();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
        
        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        //Support Account
        sObject Account2 = new Account();
        Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();        
        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId2);
        UtilityTestData.mAccountData.put('Name','Support Account Test');
        UtilityTestData.mAccountData.put('BillingPostalCode','72201');
        Account2 = UtilityTest.putFieldRecord(Account2, UtilityTestData.mAccountData);
        List<Account> lsupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account2});

        sObject sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','123423');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        insert defaultWorkCalendar; 
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
        UtilityTestData.mContactData.put('Name','Test Contact');
        UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
        UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');
        UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
        UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
        UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
        //UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //Plan
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        System.runAs(userByRole.get('Admin')){
            List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Identify');
        UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
        UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');//Territory2Id
        //UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: CDQ');
        UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
        UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRecTypeId);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Project
        sObj = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Manager__c',contactList[0].Id);
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','Baseline/Std Pkg');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
        UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','JumpStart: Cloud');
        UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');  
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProj = new List<pse__Proj__c>();
        lProj = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Contact
        sObject Contactrec = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        Contactrec = UtilityTest.putFieldRecord(Contactrec, UtilityTestData.mContactData);      
        List<Contact> lContact = new List<Contact>();
        System.runAs(userByRole.get('Admin')){
            lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contactrec});
        }
        Test.startTest();
        //Case
        sObject Caserec = new Case();
        UtilityTestData.mCase.put('AccountId',lsupportAccount[0].Id);
        UtilityTestData.mCase.put('ContactId',lContact[0].Id);  
        Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
        List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec});  
        
        //Case Contact
        sObject Casecon = new Case_Contact__c();
        UtilityTestData.mCaseContact.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseContact.put('Contact__c',lContact[0].Id);  
        Casecon = UtilityTest.putFieldRecord(Casecon, UtilityTestData.mCaseContact);
        System.debug('Casecon-rec before insert->'+Casecon);
        List<Case_Contact__c> lcasecon = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{Casecon});   
         System.debug('Casecon-rec after insert->'+lcasecon);
        
        iCare_Referral__c referral = new iCare_Referral__c();
        referral.Subject__c = 'Test Referral';
        referral.Source__c = 'Plan';
        referral.Customer_Account__c = lAccount[0].Id;
        insert referral;
        Test.stopTest();
    }


    @isTest
    public static void getAccountDetailsTest(){
        Test.startTest();
        Id supportAccountRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id customerContactRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        List<Account> lAccount = [Select Id From Account where RecordTypeId = :supportAccountRecId Limit 1];
        System.assertNotEquals(0, lAccount.size());
        List<Case> lCase = [Select Id From Case where AccountId= :lAccount[0].Id Limit 1];
        System.assertNotEquals(0, lCase.size());
        List<Plan__c> lPlan = [Select Id From Plan__c Limit 1];
        List<pse__Proj__c> lProj = [Select Id From pse__Proj__c Limit 1];
       
        ReferralManagementController.getAccountDetails(lAccount[0].Id, 'Account');
        ReferralManagementController.getAccountDetails(lCase[0].Id, 'Case');
        ReferralManagementController.getAccountDetails(lPlan[0].Id, 'Plan__c');
        ReferralManagementController.getAccountDetails(lProj[0].Id, 'pse__Proj__c');
        Test.stopTest();
    }
    
    @isTest
    public static void getReferralOwnerTest(){
        Test.startTest();
        List<Referral_Owner_Queues__mdt> metadata = [SELECT Id,Label,DeveloperName,Queue_Name__c FROM Referral_Owner_Queues__mdt];
        List<iCare_Referral__c> lstReferral = [Select Id from iCare_Referral__c];
        List<Account> lAccount = [Select Id from Account];
        List<Contact> lContact = new List<Contact>();
        List<Plan__c> lPlan = [Select Id From Plan__c Limit 1];
        List<String> selectedIds = new List<String>();
        Set<Id> refrallIds= new Set<Id>();
        refrallIds.add(lstReferral[0].id);
        ReferralManagementController.getReferralOwner('Case','');
        ReferralManagementController.getReferralOwner('Project','');
        ReferralManagementController.getReferralOwner('Plan','');
        ReferralManagementController.getReferralOwner('Other','Professional Services');
        ReferralManagementController.getReferralOwner('Other','Education Services');
        ReferralManagementController.getReferralOwner('Other','');
        
        ReferralManagementController.lookupSearch('Test',selectedIds,String.valueOf(lAccount[0].Id));
        ReferralManagementController.lookupSearchPlan('Test',selectedIds,String.valueOf(lAccount[0].Id),lPlan[0].id);
        ReferralManagementController.getReferralDetails(lstReferral[0].Id);
        //<T01> start
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        Id systemAdminId = UserInfo.getUserId();
        system.runAs(adminUser){
            ReferralManagementController.getDefaultRecords(lPlan[0].Id);            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob;
            content.origin = 'H';
            insert content;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :content.Id];
            List<Id> fileIdList = new List<Id>();
            fileIdList.add(documents[0].Id);
            

            Plan_Team__c csm =  new Plan_Team__c(User__c=systemAdminId, Primary__c=true,Plan__c=lPlan[0].Id,Role__c=CSMUtilities.ROLE_CSM);
            Plan_Team__c csmManager =  new Plan_Team__c(User__c=sogUser.Id, Primary__c=true,Plan__c=lPlan[0].Id,Role__c=CSMUtilities.ROLE_CSM_MANAGER);
            insert new List<Plan_Team__c>{csm,csmManager};
            
            List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
            List<iCare_Referral__c> lstReferral1 = [Select Id,Status__c,Source__c,Opportunity__c,Plan__c from iCare_Referral__c];
            lstReferral1[0].Status__c = 'New';
            lstReferral1[0].Source__c = 'Plan';
            lstReferral1[0].Plan__c = lPlan[0].Id;
            lstReferral1[0].Opportunity__c = lOpportunity[0].Id;
            update lstReferral1[0];
            lstReferral1[0].Status__c = 'Converted';
            update lstReferral1[0];
            ReferralManagementController.linkFiles(lstReferral1[0].Id,fileIdList);
            List<Id> refIdList = new List<Id>();
            refrallIds.add(lstReferral1[0].Id);
            refIdList.add(lstReferral1[0].Id);
            Set<Id> accIds= new Set<Id>();
            accIds.add(lAccount[0].Id);
            ReferralManagementController.isSMGGrpMember('Plan');
            ReferralManagementTriggerHelper.notifyOwnerOnReferralCreation(refIdList);
            ReferralManagementTriggerHelper.notifyReferrerOnStatusChange(refrallIds);
            ReferralManagementTriggerHelper.chatterOnPlanConvertedCancelledStatus(refrallIds,accIds);
        }
        //</T01> end
        Test.stopTest();
    }
}