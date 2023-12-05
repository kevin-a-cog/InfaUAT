/*
@created by       : MAHESH GANTI
@created on       : 12/05/2020
@Purpose          : Test class for psa_om_UpdateInterlockBatch Controller

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_om_UpdateInterlockBatchTest {
    
    static void NonsetupTestData(){
        
        List<Territory2Model> lstTerritoryModel = 
            [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        sObject terr = new Territory2();
        UtilityTestData.mTerritoryData.put('DeveloperName', 'AP_AS_AS_MAM_TEST'); 
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lstTerritoryModel[0].Id);
        UtilityTestData.mTerritoryData.put('Name', 'AP_AS_AS_MAM_TEST');
        UtilityTestData.mTerritoryData.put('Territory2TypeId', terriType[0].id);
        terr = (Territory2)UtilityTest.putFieldRecord(terr, UtilityTestData.mTerritoryData); 
        List<Territory2>  lTerr = (List<Territory2>) UtilityTest.makeInsert(new List<sObject>{terr});
    }
    
    @testSetup
    static void setupObjectTestData() {
        
        //setupCustomSettings();
        User adminUserObj = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        system.runAs(adminUserObj){
            NonsetupTestData();
        }
        Territory2  terr=[select Id from  Territory2 where DeveloperName ='AP_AS_AS_MAM_TEST'];
        Profile pr = [select ID,Name from Profile where name='System Administrator'];
        
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser'); 
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing1');
        UtilityTestData.mUserData.put('Alias', 'usrTemp1');
        UtilityTestData.mUserData.put('Email', 'usr_temp1@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp1@testorg.com');
        sObject sObj1 = new User();
        User userObj1 = (User)UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData); 
        
        UtilityTestData.mUserData.put('CommunityNickname', 'communityuser1');
        UtilityTestData.mUserData.put('ProfileId', pr.Id);
        UtilityTestData.mUserData.put('LastName', 'Testing2');
        UtilityTestData.mUserData.put('Alias', 'usrTemp2');
        UtilityTestData.mUserData.put('Email', 'usr_temp2@testorg.com');
        UtilityTestData.mUserData.put('Username', 'usr_temp2@testorg.com');
        sObject sObj2 = new User();
        User userObj2 = (User)UtilityTest.putFieldRecord(sObj2, UtilityTestData.mUserData); 
        List<User> lUser = new List<User>();
        //system.runAs(adminUserObj){
        lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj1,userObj2});
        //}
        UtilityTestData.mUserTerritory2AssociationData.put('RoleInTerritory2','CFR');
        if(terr != null){
            UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id',terr.Id);
        }
        
        UtilityTestData.mUserTerritory2AssociationData.put('UserId',lUser[0].Id);
        UtilityTestData.mUserTerritory2AssociationData.put('IsActive ','true');
        sObject sObj4 = new UserTerritory2Association();
        UserTerritory2Association terrMem1 = (UserTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserTerritory2AssociationData);
        
        UtilityTestData.mUserTerritory2AssociationData.put('RoleInTerritory2','BDM');
        if(terr != null)
            UtilityTestData.mUserTerritory2AssociationData.put('Territory2Id',terr.Id);
        UtilityTestData.mUserTerritory2AssociationData.put('UserId',lUser[1].Id);
        UtilityTestData.mUserTerritory2AssociationData.put('IsActive ','true');
        sObj4 = new UserTerritory2Association();
        UserTerritory2Association terrMem2 = (UserTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserTerritory2AssociationData);
        
        system.runAs(adminUserObj){
            List<UserTerritory2Association>  lTerrMem = (List<UserTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{terrMem1,terrMem2});
            
            
            //create Account, Populate GEO Field
            sObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name','IL-PROJ INT TEST Account');
            UtilityTestData.mAccountData.put('Geo__c','Americas');
            UtilityTestData.mAccountData.put('Signature_Success__c','true');
            if(terr != null){
                UtilityTestData.mAccountData.put('Territory_Name__c',(String)terr.Id);
            } 
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);         
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            UtilityTestData.mObjectTerritory2AssociationData.put('AssociationCause','Territory2Manual');
            UtilityTestData.mObjectTerritory2AssociationData.put('ObjectId',lAccount[0].Id);
            UtilityTestData.mObjectTerritory2AssociationData.put('SobjectType','Account');
            if(terr != null){
                UtilityTestData.mObjectTerritory2AssociationData.put('Territory2Id',terr.Id);
            }
            sObj4 = new ObjectTerritory2Association();
            ObjectTerritory2Association objTerrAssoc = (ObjectTerritory2Association)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mObjectTerritory2AssociationData);
            //System.debug('$$$$'+objTerrAssoc);
            List<ObjectTerritory2Association>  lObjTerrAssoc = (List<ObjectTerritory2Association>) UtilityTest.makeInsert(new List<sObject>{objTerrAssoc});
            
            //Account LOB
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
            sObject AccLOB = new Account_LOB__c();
            AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
            List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
            
            //Contact 
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            sObj = new Contact();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Plan
            UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
            sObject Plan = new Plan__c();
            UtilityTestData.mPlan.put('Name','Test Plan');
            UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);        
            UtilityTestData.mPlan.put('Status__c','Active');
            UtilityTestData.mPlan.put('RecordTypeId', Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
            Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
            List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});    
            List<Plan__c> planList  = [Select Id,Account__c,Account__r.Name from Plan__c ];
            system.debug('planList'+planList.size());
            
            
            //Opportunity
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
            sObject Opty = new Opportunity();
            Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
            //List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
            
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
            sObject Opty2 = new Opportunity();
            Opty2 = UtilityTest.putFieldRecord(Opty2, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty,Opty2});
            
            //Related opportunity Plan(Interlock)
            UtilityTestData.mRelatedOpportunityPlan.put('Opportunity__c',lOpty[0].Id);
            UtilityTestData.mRelatedOpportunityPlan.put('Account__c',lAccount[0].Id);
            UtilityTestData.mRelatedOpportunityPlan.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mRelatedOpportunityPlan.put('RecordTypeId',Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Related Opportunity Plan').getRecordTypeId());        
            UtilityTestData.mRelatedOpportunityPlan.put('Interlock_Type__c','Renewal Rescue');
            UtilityTestData.mRelatedOpportunityPlan.put('Implementation_Owner__c','Customer');
            UtilityTestData.mRelatedOpportunityPlan.put('Key_customer_contact__c',lContact[0].Id);
            UtilityTestData.mRelatedOpportunityPlan.put('Partner_name_if_any__c','IP TEST PARTNER NAME');
            //UtilityTestData.mRelatedOpportunityPlan.put('Primary_challenge_s__c','Product Gap');
            UtilityTestData.mRelatedOpportunityPlan.put('Expected_Start_Date__c',System.Today() + '');
            UtilityTestData.mRelatedOpportunityPlan.put('IPS_Package__c','Renewal Rescue');
            
            sObject relOptyPlan = new Related_Opportunity_Plan__c();
            relOptyPlan = UtilityTest.putFieldRecord(relOptyPlan, UtilityTestData.mRelatedOpportunityPlan); 
            List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relOptyPlan});
            
            List<Related_Opportunity_Plan__c> relatedOpptyPlan = [Select Id,OwnerId from Related_Opportunity_Plan__c];
            system.debug('relatedOpptyPlan'+relatedOpptyPlan);
            
            Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
            sObject engagement = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', IPSJumpstart);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpty[0].Id);
            UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
            engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);        
            List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
            
            pse__Proj__c pseProject = new pse__Proj__c();
            pseProject.pse__Account__c = lAccount[0].Id;
            pseProject.pse__Project_Manager__c = lContact[0].Id;
            pseProject.pse__Project_Type__c = 'Customer Project';
            pseProject.psa_pm_Project_Sub_Type__c = 'JumpStart';
            pseProject.psa_pm_Engagement__c = lEngagement[0].Id;
            pseProject.pse__Opportunity__c = lOpty[0].Id;
            pseProject.pse__Start_Date__c = System.today().addDays(1);
            pseProject.pse__End_Date__c = System.today().addDays(10);
            pseProject.pse__Allow_Self_Staffing__c = true;  
            pseProject.psa_om_Interlock__c = lRelatedopportunityPlan[0].Id;
            pseProject.psa_om_InterlockFieldsUpdate_Date__c = System.now().addHours(-10);
            system.debug('pseProject'+pseProject); 
            insert pseProject;
            
        }
    }
    
    static testMethod void testInterlockBatch(){
        Test.startTest();
        pse__Proj__c projRec = [SELECT id,Name,psa_om_InterlockFieldsUpdate_Date__c,pse__Project_Type__c,psa_pm_Project_Sub_Type__c FROM pse__Proj__c Limit 1];
        system.debug('*****PROJREC***'+projRec);
     
        psa_om_UpdateInterlockBatch interlockBatch = new psa_om_UpdateInterlockBatch();
        Id batchId = Database.executeBatch(interlockBatch);
        Test.stopTest(); 
    }
}