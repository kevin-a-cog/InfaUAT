@isTest
public class CreateDiscountApprovalTest{
      
    private static DiscountApproval__c DiscApproval;
    private static Discount_Approval_Matrix__c DiscApprovalMatrix;
    public static List<User>usrList= new List<User>();   
    
    static void NonsetupTestData(){
        List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
        //Territory2Model terrModel = lstTerritoryModel[0];
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
        //Territory2 terr = test_utilityClass.createTerritory('AP_AS_AS_MAM_TEST', terrModel.id, 'AP_AS_AS_MAM_TEST', true);

        sObject terr = new Territory2();
        UtilityTestData.mTerritoryData.put('DeveloperName', 'APJ_AS_AS_MAM_TEST'); 
        UtilityTestData.mTerritoryData.put('Territory2ModelId', lstTerritoryModel[0].Id);
        UtilityTestData.mTerritoryData.put('Name', 'APJ_AS_AS_MAM_TEST');
        UtilityTestData.mTerritoryData.put('Territory2TypeId', terriType[0].id);
        terr = (Territory2)UtilityTest.putFieldRecord(terr, UtilityTestData.mTerritoryData); 
        List<Territory2>  lUser = (List<Territory2>) UtilityTest.makeInsert(new List<sObject>{terr});
      
    }  
  
    /**
    * this method creates data required for testing purpose 
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    @testSetup static void setupData(){
      User adminUserObj = [select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
      
      system.runAs(adminUserObj)
      {
        NonsetupTestData();
      }
      
      Discount_Approver_Matrix__c disMatrix = new Discount_Approver_Matrix__c(Name= 'testMapping',
          																	 AVP__c = 'usr_temp1@testorg.com',
                                                                             Inside_Sales_AVP__c = 'usr_temp2@testorg.com');
      insert disMatrix;  
        
      List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];
      Territory2Model terrModel = lstTerritoryModel[0];
      Territory2  terr=[select Id from  Territory2 where DeveloperName ='APJ_AS_AS_MAM_TEST'];
      
       
      Id cometitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
      sObject sObjAccount    = new Account();
      UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
      sObjAccount  = UtilityTest.putFieldRecord(sObjAccount,UtilityTestData.mAccountData);
      
      
      sObject sObjAccount1  = new Account();
      UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
      UtilityTestData.mAccountData.put('Status__c','New');
      sObjAccount1 = UtilityTest.putFieldRecord(sObjAccount1,UtilityTestData.mAccountData);
           
      List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAccount,sObjAccount1});
      
       
      System.assertEquals(accountlst.size(),2);
       
      sObject sObjContact = new contact();
      UtilityTestData.mContactData.put('AccountId', accountlst[1].Id);
      sObjContact = UtilityTest.putFieldRecord(sObjContact,UtilityTestData.mContactData);
      
      sObject sObjContact1 = new contact();      
      UtilityTestData.mContactData.put('Account', accountlst[1].Id);
      sObjContact1 = UtilityTest.putFieldRecord(sObjContact1,UtilityTestData.mContactData);
      
      List<contact> contactlst = (List<contact>) UtilityTest.makeInsert(new List<sObject>{sObjContact,sObjContact1});
      System.assertEquals(contactlst.size(),2);

      Profile pr = [select ID,Name from Profile where name='System Administrator'];
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      sObject sObj = new User();
      User userObj = (User)UtilityTest.putFieldRecord(sObj, UtilityTestData.mUserData);
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA'); 
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing1');
      UtilityTestData.mUserData.put('Alias', 'usrTemp1');
      UtilityTestData.mUserData.put('Email', 'usr_temp1@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp1@testorgDA.com');
      sObject sObj1 = new User();
      User userObj1 = (User)UtilityTest.putFieldRecord(sObj1, UtilityTestData.mUserData); 

      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA1');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing2');
      UtilityTestData.mUserData.put('Alias', 'usrTemp2');
      UtilityTestData.mUserData.put('Email', 'usr_temp2@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp2@testorgDA.com');
      sObject sObj2 = new User();
      User userObj2 = (User)UtilityTest.putFieldRecord(sObj2, UtilityTestData.mUserData); 
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA2');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing3');
      UtilityTestData.mUserData.put('Alias', 'usrTemp3');
      UtilityTestData.mUserData.put('Email', 'usr_temp3@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp3@testorgDA.com');
      sObject sObj3 = new User();
      User userObj3 = (User)UtilityTest.putFieldRecord(sObj3, UtilityTestData.mUserData); 
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA3');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing4');
      UtilityTestData.mUserData.put('Alias', 'usrTemp4');
      UtilityTestData.mUserData.put('Email', 'usr_temp4@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp4@testorgDA.com');
      sObject sObj4 = new User();
      User userObj4 = (User)UtilityTest.putFieldRecord(sObj4, UtilityTestData.mUserData); 
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA4');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing5');
      UtilityTestData.mUserData.put('Alias', 'usrTemp5');
      UtilityTestData.mUserData.put('Email', 'usr_temp5@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp5@testorgDA.com');
      UtilityTestData.mUserData.put('UserType', 'Standard');
      sObject sObj5 = new User();
      User userObj5 = (User)UtilityTest.putFieldRecord(sObj5, UtilityTestData.mUserData);  
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA5');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing6');
      UtilityTestData.mUserData.put('Alias', 'usrTemp6');
      UtilityTestData.mUserData.put('Email', 'usr_temp6@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp6@testorgDA.com');
      sObject sObj6 = new User();
      User userObj6 = (User)UtilityTest.putFieldRecord(sObj6, UtilityTestData.mUserData); 
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA6');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing7');
      UtilityTestData.mUserData.put('Alias', 'usrTemp7');
      UtilityTestData.mUserData.put('Email', 'usr_temp7@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp7@testorgDA.com');
      sObject sObj7 = new User();
      User userObj7 = (User)UtilityTest.putFieldRecord(sObj7, UtilityTestData.mUserData); 
           
      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA7');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing8');
      UtilityTestData.mUserData.put('Alias', 'usrTemp8');
      UtilityTestData.mUserData.put('Email', 'usr_temp8@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp8@testorgDA.com');
      sObject sObj8 = new User();
      User userObj8 = (User)UtilityTest.putFieldRecord(sObj8,UtilityTestData.mUserData); 

      UtilityTestData.mUserData.put('CommunityNickname', 'communityuserDA8');
      UtilityTestData.mUserData.put('ProfileId', pr.Id);
      UtilityTestData.mUserData.put('LastName', 'Testing9');
      UtilityTestData.mUserData.put('Alias', 'usrTemp9');
      UtilityTestData.mUserData.put('Email', 'usr_temp9@testorg.com');
      UtilityTestData.mUserData.put('Username', 'usr_temp9@testorgDA.com');
      sObject sObj9 = new User();
      User userObj9 = (User)UtilityTest.putFieldRecord(sObj9, UtilityTestData.mUserData); 
       
      List<User>  lUser = (List<User>) UtilityTest.makeInsert(new List<sObject>{userObj,userObj1,userObj2,userObj3,userObj4,userObj5,userObj6,userObj7,userObj8,userObj9});
      System.assertEquals(lUser.size(),10);

      sObject sObjOpportunity = new opportunity();
      UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
      UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2020')+'');
      UtilityTestData.mOpportunityData.put('StageName','Validate');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
      //UtilityTestData.mOpportunityData.put('Territory2',terr.id);
      sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity,UtilityTestData.mOpportunityData);

      sObject sObjOpportunity1 = new opportunity();
      UtilityTestData.mOpportunityData.put('Name','Test opportunity1');
      UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
      UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2020')+'');
      UtilityTestData.mOpportunityData.put('StageName','Validate');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
      //UtilityTestData.mOpportunityData.put('Territory2',terr.id);
      sObjOpportunity1 = UtilityTest.putFieldRecord(sObjOpportunity1,UtilityTestData.mOpportunityData);
      
      sObject sObjOpportunity2 = new opportunity();
      UtilityTestData.mOpportunityData.put('Name','Test opportunity2');
      UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
      UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2021')+'');
      UtilityTestData.mOpportunityData.put('StageName','Validate');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
      //UtilityTestData.mOpportunityData.put('Territory2',terr.id);
      UtilityTestData.mOpportunityData.put('PT_INFA_License_Compliance__c','true');
      sObjOpportunity2 = UtilityTest.putFieldRecord(sObjOpportunity2,UtilityTestData.mOpportunityData);
      List<opportunity> opportunitylst = (List<opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity,sObjOpportunity1,sObjOpportunity2});
       
      sObject sObjDiscountApprovalSSDirector = new DiscountApproval_SS_Director__c  ();
      UtilityTestData.mDiscountApprovalSSDirector.put('Name','terrApproval');
      UtilityTestData.mDiscountApprovalSSDirector.put('Territory_Prefix__c','terrprefix');
      UtilityTestData.mDiscountApprovalSSDirector.put('SS_Director__c',userObj6.username);
      UtilityTestData.mDiscountApprovalSSDirector.put('Maintenance_Term_Exception_Approver__c',userObj6.username);
      sObjDiscountApprovalSSDirector = UtilityTest.putFieldRecord(sObjDiscountApprovalSSDirector,UtilityTestData.mDiscountApprovalSSDirector);
      List<DiscountApproval_SS_Director__c > discountApprovalSSDirectorlst  =  (List<DiscountApproval_SS_Director__c>) UtilityTest.makeInsert(new List<sObject>{sObjDiscountApprovalSSDirector});
      System.assertEquals(discountApprovalSSDirectorlst.size(),1);
       
      sObject sObjDiscountApprovalMatrix1 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','OppOwner');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix1 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix1,UtilityTestData.mDiscountApprovalMatrix);
         
      sObject sObjDiscountApprovalMatrix2 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','Owner1up');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix2 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix2,UtilityTestData.mDiscountApprovalMatrix);
      
      sObject sObjDiscountApprovalMatrix3 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','Owner2up');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix3 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix3,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix4 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','FR');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix4 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix4,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix5 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','FR2up');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix5 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix5,UtilityTestData.mDiscountApprovalMatrix);
  
      sObject sObjDiscountApprovalMatrix6 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','SSDirector');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix6 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix6,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix7 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','AVP');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix7 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix7,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix8 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','SVP');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix8 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix8,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix9 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','EVP');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix9 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix9,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix10 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','CEO');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix10 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix10,UtilityTestData.mDiscountApprovalMatrix);

      sObject sObjDiscountApprovalMatrix11 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','CEO');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','30');
      sObjDiscountApprovalMatrix11 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix11,UtilityTestData.mDiscountApprovalMatrix);
     
      sObject sObjDiscountApprovalMatrix12 = new Discount_Approval_Matrix__c  ();
      UtilityTestData.mDiscountApprovalMatrix.put('RecordApprover__c','FR1up');
      UtilityTestData.mDiscountApprovalMatrix.put('MinDiscount__c','10');
      sObjDiscountApprovalMatrix12 = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix12,UtilityTestData.mDiscountApprovalMatrix);

      List<Discount_Approval_Matrix__c> discountApprovalMatrixlst = (List<Discount_Approval_Matrix__c>) UtilityTest.makeInsert(new List<sObject>{sObjDiscountApprovalMatrix1,sObjDiscountApprovalMatrix2,sObjDiscountApprovalMatrix3,sObjDiscountApprovalMatrix4,sObjDiscountApprovalMatrix5,sObjDiscountApprovalMatrix6,sObjDiscountApprovalMatrix7,sObjDiscountApprovalMatrix8,sObjDiscountApprovalMatrix9,sObjDiscountApprovalMatrix10,sObjDiscountApprovalMatrix11,sObjDiscountApprovalMatrix12});
      System.assertEquals(discountApprovalMatrixlst.size(),12);
       
      sObject sObjDiscountApproval1 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','6000000');
      UtilityTestData.mDiscountApproval.put('Approver2__c',lUser[1].Id);
      UtilityTestData.mDiscountApproval.put('Approver3__c',lUser[2].Id);
      UtilityTestData.mDiscountApproval.put('Approver4__c',lUser[3].Id);
      UtilityTestData.mDiscountApproval.put('Approver5__c',lUser[4].Id);
      UtilityTestData.mDiscountApproval.put('Approver6__c',lUser[5].Id);
      UtilityTestData.mDiscountApproval.put('Approver7__c',lUser[6].Id);
      UtilityTestData.mDiscountApproval.put('Approver8__c',lUser[7].Id);
      UtilityTestData.mDiscountApproval.put('Approver9__c',lUser[8].Id);
      sObjDiscountApproval1 = UtilityTest.putFieldRecord(sObjDiscountApproval1,UtilityTestData.mDiscountApproval);
    
      sObject sObjDiscountApproval2 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','4000000');
      sObjDiscountApproval2 = UtilityTest.putFieldRecord(sObjDiscountApproval2,UtilityTestData.mDiscountApproval);

 
      sObject sObjDiscountApproval3 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','400000');
      UtilityTestData.mDiscountApproval.put('CurrencyIsoCode','INR');
      sObjDiscountApproval3 = UtilityTest.putFieldRecord(sObjDiscountApproval3,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval4 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','40000');
      sObjDiscountApproval4 = UtilityTest.putFieldRecord(sObjDiscountApproval4,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval5 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','200000');
      sObjDiscountApproval5 = UtilityTest.putFieldRecord(sObjDiscountApproval5,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval6 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','1000');
      sObjDiscountApproval6 = UtilityTest.putFieldRecord(sObjDiscountApproval6,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval7 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[1].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','25000');
      sObjDiscountApproval7 = UtilityTest.putFieldRecord(sObjDiscountApproval7,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval8 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[0].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','50000');
      sObjDiscountApproval8 = UtilityTest.putFieldRecord(sObjDiscountApproval8,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval9 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[2].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','200000');
      sObjDiscountApproval9 = UtilityTest.putFieldRecord(sObjDiscountApproval9,UtilityTestData.mDiscountApproval);

      sObject sObjDiscountApproval10 = new DiscountApproval__c  ();
      UtilityTestData.mDiscountApproval.put('FieldRep__c',lUser[2].Id);
      UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].id);
      UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','Subscription');
      UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','500000');
      sObjDiscountApproval10 = UtilityTest.putFieldRecord(sObjDiscountApproval10,UtilityTestData.mDiscountApproval);
      List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeInsert(new List<sObject>{sObjDiscountApproval1,sObjDiscountApproval2,sObjDiscountApproval3,sObjDiscountApproval4,sObjDiscountApproval5,sObjDiscountApproval6,sObjDiscountApproval7,sObjDiscountApproval8,sObjDiscountApproval9,sObjDiscountApproval10});
      System.assertEquals(discountApprovallst.size(),10);

	  
        
    }

  //method to test DiscountApproval records update
      @isTest
    public static void DiscountApproval_Test(){
      List<User> adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 10];
      system.runAs(adminUser[0]){
        Test.startTest();
          List<DiscountApproval__c> lstDiscApproval = [SELECT id,Discount__c FROM DiscountApproval__c LIMIT 1];
          
          //List<User> users = [Select Id,name from User];
          sObject sObjDiscountApproval10 = new DiscountApproval__c (Id = lstDiscApproval[0].Id,Approver1__c = adminUser[0].Id,Approver2__c = adminUser[0].Id,Approver3__c = adminUser[0].Id,Approver4__c = adminUser[0].Id,Approver5__c = adminUser[0].Id,Approver6__c = adminUser[0].Id,Approver7__c = adminUser[0].Id,Approver8__c = adminUser[0].Id,Approver9__c = adminUser[0].Id,Approver10__c = adminUser[0].Id);
          UtilityTestData.mDiscountApproval.put('Discount__c','25');
          UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','10000');
          UtilityTestData.mDiscountApproval.put('status__c','Approved');
          UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
          UtilityTestData.mDiscountApproval.put('Name','Test DA');
          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeUpdate(new List<sObject>{sObjDiscountApproval10});
          system.assertEquals(adminUser[0].Id, discountApprovallst[0].Approver1__c);
          
          
          
        Test.stopTest();
      }
    }
    //method to test DiscountApproval records update
      @isTest
    public static void DiscountApproval_TestEstimatedPrice(){
      List<User> adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 10];
      system.runAs(adminUser[0]){
        Test.startTest();
          List<DiscountApproval__c> lstDiscApproval = [SELECT id,Discount__c FROM DiscountApproval__c LIMIT 1];
          
          //List<User> users = [Select Id,name from User];
          sObject sObjDiscountApproval10 = new DiscountApproval__c (Id = lstDiscApproval[0].Id,Approver1__c = adminUser[0].Id,Approver2__c = adminUser[0].Id,Approver3__c = adminUser[0].Id,Approver4__c = adminUser[0].Id,Approver5__c = adminUser[0].Id,Approver6__c = adminUser[0].Id,Approver7__c = adminUser[0].Id,Approver8__c = adminUser[0].Id,Approver9__c = adminUser[0].Id,Approver10__c = adminUser[0].Id);
          UtilityTestData.mDiscountApproval.put('Discount__c','28');
          UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','12345');
          UtilityTestData.mDiscountApproval.put('status__c','Approved');
          UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
          UtilityTestData.mDiscountApproval.put('Name','Test DA');
          //globalApexManager.avoidRecursion('DiscountApprovalBeforeUpdate');
          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeUpdate(new List<sObject>{sObjDiscountApproval10});
         // system.assertEquals(adminUser[0].Id, discountApprovallst[0].Approver1__c);
            
        Test.stopTest();
      }
    }
     //method to test DiscountApproval records update
      @isTest
    public static void DiscountApproval_TestReturn(){
      List<User> adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 10];
      system.runAs(adminUser[0]){
        Test.startTest();
          List<DiscountApproval__c> lstDiscApproval = [SELECT id,Discount__c FROM DiscountApproval__c LIMIT 1];
          
          //List<User> users = [Select Id,name from User];
          sObject sObjDiscountApproval10 = new DiscountApproval__c (Id = lstDiscApproval[0].Id,Approver1__c = adminUser[0].Id,Approver2__c = adminUser[0].Id,Approver3__c = adminUser[0].Id,Approver4__c = adminUser[0].Id,Approver5__c = adminUser[0].Id,Approver6__c = adminUser[0].Id,Approver7__c = adminUser[0].Id,Approver8__c = adminUser[0].Id,Approver9__c = adminUser[0].Id,Approver10__c = adminUser[0].Id);
          UtilityTestData.mDiscountApproval.put('Discount__c','25');
          UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','10000');
          UtilityTestData.mDiscountApproval.put('status__c','Approved');
          UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
          UtilityTestData.mDiscountApproval.put('Name','Test DA');
          globalApexManager.avoidRecursion('DiscountApprovalBeforeUpdate');
          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeUpdate(new List<sObject>{sObjDiscountApproval10});
          //system.assertEquals(adminUser[0].Id, discountApprovallst[0].Approver1__c);
            
        Test.stopTest();
      }
    }
     //method to test refreshApprovals
      @isTest
    public static void DiscountApproval_refreshApprovals(){
      List<User> adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 10];
      /*ObjectTerritory2Association ota2 = new ObjectTerritory2Association(AssociationCause  = 'Territory2Manual', 
                                                                         ObjectId = sObjAccount.Id, 
                                                                         Territory2Id = terr.Id);
      insert ota2;*/ 
      system.runAs(adminUser[0]){
        Test.startTest();
          List<Opportunity>OppLst=[select Id,Name, AccountId from Opportunity];
          sObject sObjDiscountApproval = new DiscountApproval__c (Approver1__c = adminUser[0].Id,Approver2__c = adminUser[0].Id,Approver3__c = adminUser[0].Id,Approver4__c = adminUser[0].Id,Approver5__c = adminUser[0].Id,Approver6__c = adminUser[0].Id,Approver7__c = adminUser[0].Id,Approver8__c = adminUser[0].Id,Approver9__c = adminUser[0].Id,Approver10__c = adminUser[0].Id);
            UtilityTestData.mDiscountApproval.put('FieldRep__c',adminUser[0].Id);
            UtilityTestData.mDiscountApproval.put('Opportunity__c',OppLst[0].Id);
            UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
            UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','400000');
            UtilityTestData.mDiscountApproval.put('Discount__c','20');
            UtilityTestData.mDiscountApproval.put('DrivenBy__c','Field');
            UtilityTestData.mDiscountApproval.put('OpportunityLicense__c','Sub-M');
            UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
            UtilityTestData.mDiscountApproval.put('Name','Test DA2');
            UtilityTestData.mDiscountApproval.put('Status__c','New');

          sObjDiscountApproval = UtilityTest.putFieldRecord(sObjDiscountApproval,UtilityTestData.mDiscountApproval);

          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApproval});
          sObjDiscountApproval = new  DiscountApproval__c(Id = discountApprovallst[0].id,DrivenBy__c='Inside Sales', AVP__c = adminUser[0].Id,Discount__c =25,Discount_Approval_Type__c='Subscription');  

          List<DiscountApproval__c> discountApprovallstUpdate = (List<DiscountApproval__c>) UtilityTest.makeupdate(new List<sObject>{sObjDiscountApproval});
          System.assertEquals(discountApprovallstUpdate[0].DrivenBy__c,'Inside Sales');            
        Test.stopTest();
      }
    }
    
    //method to test approverAssignment logic 
        @isTest
    public static void approverAssignment_Test(){
        
      list<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
      Territory2Model terrModel = new Territory2Model();
      List<Territory2Model> lstTerritoryModel = [Select Id, Name, State FROM Territory2Model WHERE State = 'Active'];  
      terrModel = lstTerritoryModel[0]; 
      
      User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
      
      system.runAs(adminUser){
        Test.startTest();
          List<Account> accList =[select id,Name from Account where Name='Test Account'];
          List<Contact> conList =[select id,Name,Email from Contact where FirstName='Test'];
          
          Territory2 terri = [select id,DeveloperName from Territory2 where DeveloperName = 'APJ_AS_AS_MAM_TEST'];
          
          List<Opportunity>OppLst=[select Id,Name from Opportunity WHERE PT_INFA_License_Compliance__c = true];
          
          sObject sObjOpptyTeamMember = new OpportunityTeamMember(OpportunityId = OppLst[0].Id,UserId = adminUser.Id,TeamMemberRole = 'Account Manager' );
          List<OpportunityTeamMember> otmlst = (List<OpportunityTeamMember>) UtilityTest.makeinsert(new List<sObject>{sObjOpptyTeamMember});
       
          sObject sObjDiscountApprovalMatrix = new Discount_Approval_Matrix__c  (Name = 'AP_AS');
          UtilityTestData.mDiscountApprovalMatrix.put('SVP__c','cbarbaro1@infor.com');
          UtilityTestData.mDiscountApprovalMatrix.put('AVP__c','cbarbaro1@del.com');
          sObjDiscountApprovalMatrix = UtilityTest.putFieldRecord(sObjDiscountApprovalMatrix,UtilityTestData.mDiscountApprovalMatrix);
          List<Discount_Approval_Matrix__c> discountApprovalMatrixlst = (List<Discount_Approval_Matrix__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApprovalMatrix});
            
          List<User> userList = [Select id,Name from User where UserType in ('Standard') AND IsActive= TRUE];
          
          User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
          settings.Ignore_Validation_Rules__c = true;
          upsert settings User_Exemptions__c.Id;
          
          sObject sObjDiscountApproval = new DiscountApproval__c  (Approver2__c = userList[1].Id,Approver3__c = userList[2].Id,Approver4__c = userList[3].Id,Approver5__c = userList[4].Id,Approver6__c = userList[5].Id);
          UtilityTestData.mDiscountApproval.put('FieldRep__c',adminUser.Id);
          UtilityTestData.mDiscountApproval.put('Opportunity__c',OppLst[0].Id);
          UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
          UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','400000');
          UtilityTestData.mDiscountApproval.put('Discount__c','20');
          UtilityTestData.mDiscountApproval.put('DrivenBy__c','Inside Sales');
          UtilityTestData.mDiscountApproval.put('OpportunityLicense__c','Sub-M');
          UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
          UtilityTestData.mDiscountApproval.put('Name','Test DA2');
          UtilityTestData.mDiscountApproval.put('Status__c','New');
          
          sObjDiscountApproval = UtilityTest.putFieldRecord(sObjDiscountApproval,UtilityTestData.mDiscountApproval);
          
          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApproval});
          
          sObjDiscountApproval = new  DiscountApproval__c(Id = discountApprovallst[0].id,Status__c='Pending Approval',Approver1__c = adminUser.Id );  
          List<DiscountApproval__c> discountApprovallstUpdate = (List<DiscountApproval__c>) UtilityTest.makeupdate(new List<sObject>{sObjDiscountApproval});
          System.assertEquals(discountApprovallstUpdate[0].Status__c,'Pending Approval');
          System.assertEquals(discountApprovallstUpdate[0].Approver1__c, adminUser.Id);
      Test.stopTest();
      }
  }


      @isTest
    public static void deleteDiscountApproval(){
      
      User user1 = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
      
      system.runAs(user1){
            test.starttest();
       
                  List<Account> accountList =[select id,Name from Account where Name='Test Account'];
                  List<Contact> contactList =[select id,Name,Email from Contact where FirstName='Test'];
                  List<Opportunity>OppLst=[select Id,Name from Opportunity ];
          
                  sObject sObjOpportunity1 = new opportunity(AccountId = accountList[0].id,End_User__c = contactList[0].id );
                  sObject sObjOpportunity2 = new opportunity(AccountId = accountList[0].id,End_User__c = contactList[0].id );
                  UtilityTestData.mOpportunityData.put('Sales_Play__c','Analytics');
                  UtilityTestData.mOpportunityData.put('StageName','Identify');
                  UtilityTestData.mOpportunityData.put('Type','Upsell');
                  UtilityTestData.mOpportunityData.put('CloseDate',system.today()+'');
                  //UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
                  //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c','100');
                  //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c','100');
                  //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c','100');
                  //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c','100');
                  sObjOpportunity1 = UtilityTest.putFieldRecord(sObjOpportunity1,UtilityTestData.mOpportunityData);
                  sObjOpportunity2 = UtilityTest.putFieldRecord(sObjOpportunity2,UtilityTestData.mOpportunityData);
                  List<opportunity> opportunitylst = (List<opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity1,sObjOpportunity2});
                  
                  sObject sObjDiscountApproval1 = new DiscountApproval__c  (Opportunity__c = opportunitylst[0].Id);
                  sObject sObjDiscountApproval2 = new DiscountApproval__c(Opportunity__c = opportunitylst[1].Id);
                  UtilityTestData.mDiscountApproval.put('FieldRep__c',user1.Id);
                  //UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].Id);
                  UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','200');
                  UtilityTestData.mDiscountApproval.put('Discount__c','20');
                  UtilityTestData.mDiscountApproval.put('DrivenBy__c','Field Rep');
                  UtilityTestData.mDiscountApproval.put('OpportunityLicense__c','Sub-M');
                  UtilityTestData.mDiscountApproval.put('Name','Test DA1');
                  UtilityTestData.mDiscountApproval.put('Status__c','New');
                  sObjDiscountApproval1 = UtilityTest.putFieldRecord(sObjDiscountApproval1,UtilityTestData.mDiscountApproval);
                  sObjDiscountApproval2 = UtilityTest.putFieldRecord(sObjDiscountApproval2,UtilityTestData.mDiscountApproval);
                  List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApproval1,sObjDiscountApproval2});
                  
                  try{
                        delete discountApprovallst;
                                 
                  }catch(Exception e){
                  }
                  System.assertEquals(discountApprovallst.size(),2);
            test.stoptest();
      }
  }
      @isTest
    public static void deleteDiscountApprovalWithoutAccess(){
      List<DiscountApproval__c> discountApprovallst = new List<DiscountApproval__c>();
      User user1 = [SELECT id,ProfileId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
      User user2 = [SELECT id,ProfileId,Name,Email FROM User WHERE Profile.Name = 'Employee' AND IsActive=true AND Title Like'%Sales Operations%' LIMIT 1];
      test.starttest();
      system.runAs(user1){
       
          List<Account> accountList =[select id,Name from Account where Name='Test Account'];
          List<Contact> contactList =[select id,Name,Email from Contact where FirstName='Test'];
          List<Opportunity>OppLst=[select Id,Name from Opportunity ];
          
          sObject sObjOpportunity1 = new opportunity(AccountId = accountList[0].id,End_User__c = contactList[0].id );
          sObject sObjOpportunity2 = new opportunity(AccountId = accountList[0].id,End_User__c = contactList[0].id );
          UtilityTestData.mOpportunityData.put('Sales_Play__c','Analytics');
          UtilityTestData.mOpportunityData.put('StageName','Identify');
          UtilityTestData.mOpportunityData.put('Type','Upsell');
          UtilityTestData.mOpportunityData.put('CloseDate',system.today()+'');
          UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
          //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c','100');
          //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c','100');
          //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c','100');
          //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c','100');
          sObjOpportunity1 = UtilityTest.putFieldRecord(sObjOpportunity1,UtilityTestData.mOpportunityData);
          sObjOpportunity2 = UtilityTest.putFieldRecord(sObjOpportunity2,UtilityTestData.mOpportunityData);
          List<opportunity> opportunitylst = (List<opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity1,sObjOpportunity2});
                  
          sObject sObjDiscountApproval1 = new DiscountApproval__c  (Opportunity__c = opportunitylst[0].Id);
          sObject sObjDiscountApproval2 = new DiscountApproval__c(Opportunity__c = opportunitylst[1].Id);
          UtilityTestData.mDiscountApproval.put('FieldRep__c',user1.Id);
          //UtilityTestData.mDiscountApproval.put('Opportunity__c',opportunitylst[0].Id);
          UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','200');
          UtilityTestData.mDiscountApproval.put('Discount__c','20');
          UtilityTestData.mDiscountApproval.put('DrivenBy__c','Field Rep');
          UtilityTestData.mDiscountApproval.put('OpportunityLicense__c','Sub-M');
          UtilityTestData.mDiscountApproval.put('Name','Test DA1');
          UtilityTestData.mDiscountApproval.put('Status__c','New');
          sObjDiscountApproval1 = UtilityTest.putFieldRecord(sObjDiscountApproval1,UtilityTestData.mDiscountApproval);
          sObjDiscountApproval2 = UtilityTest.putFieldRecord(sObjDiscountApproval2,UtilityTestData.mDiscountApproval);
          discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApproval1,sObjDiscountApproval2});
      }
      system.runAs(user2){
      string errorMessage;
          try{
              delete discountApprovallst;
          }catch(Exception e){
              system.assertEquals(e.getMessage().contains('Insufficient Previleges to Delete Discount Approval Record') || e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY'),true);
          }
      }
      test.stoptest();
  }
    
    @isTest
    public static void addApproversTest(){
        
      List<DiscountApproval__c> discountApprovallst = new List<DiscountApproval__c>();
      User user1 = [SELECT id,ProfileId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 1];
      User user2 = [SELECT id,ProfileId,Name,Email FROM User WHERE Profile.Name = 'Employee' AND IsActive=true AND Title Like'%Sales Operations%' LIMIT 1];
      test.starttest();
      system.runAs(user1){
       
          List<Account> accountList =[select id,Name, Account_Hold_Reasons__c from Account where Name='Test Account'];
          accountList[0].Account_Hold_Reasons__c = 'Legal: Transaction Review Required;Credit&Collections: Credit status';
          update accountList;

          list<DiscountApproval__c> discountApprovalsList = [Select Id, Discount__c from DiscountApproval__c Limit 1];
          discountApprovalsList[0].Discount__c = 90;
          update discountApprovalsList;
          
          //CreateDiscountApproval.addApprovers(discountApprovallst,false);
      }
      system.runAs(user2){
      string errorMessage;
          try{
              delete discountApprovallst;
          }catch(Exception e){
              system.assertEquals(e.getMessage().contains('Insufficient Previleges to Delete Discount Approval Record') || e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY'),true);
          }
      }
      test.stoptest();
  }
    
    //method to test refreshApprovals
    @isTest
    public static void DiscountApproval_refreshApprovals_Two(){
      Test.startTest();
      List<User> adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true LIMIT 10];
      Account sObjAccount = [Select Id From Account LIMIT 1];
      Territory2  terr=[select Id from  Territory2 where DeveloperName ='APJ_AS_AS_MAM_TEST'];
	  ObjectTerritory2Association ota2 = new ObjectTerritory2Association(AssociationCause  = 'Territory2Manual', 
                                                                         ObjectId = sObjAccount.Id, 
                                                                         Territory2Id = terr.Id);
      insert ota2;
      
      sObject sObjOpportunity = new opportunity();
      UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
      UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2020')+'');
      UtilityTestData.mOpportunityData.put('StageName','Validate');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
      //UtilityTestData.mOpportunityData.put('Territory2',terr.id);
      sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity,UtilityTestData.mOpportunityData);
      insert sObjOpportunity; 
        
      system.runAs(adminUser[0]){
        
          //List<Opportunity>OppLst=[select Id,Name, AccountId from Opportunity];
          sObject sObjDiscountApproval = new DiscountApproval__c (Approver1__c = adminUser[0].Id,
                                                                  Approver2__c = adminUser[0].Id,
                                                                  Approver3__c = adminUser[0].Id,
                                                                  Approver4__c = adminUser[0].Id,Approver5__c = adminUser[0].Id,Approver6__c = adminUser[0].Id,Approver7__c = adminUser[0].Id,Approver8__c = adminUser[0].Id,Approver9__c = adminUser[0].Id,Approver10__c = adminUser[0].Id);
            UtilityTestData.mDiscountApproval.put('FieldRep__c',adminUser[0].Id);
            UtilityTestData.mDiscountApproval.put('Opportunity__c',sObjOpportunity.Id);
            UtilityTestData.mDiscountApproval.put('Discount_Approval_Type__c','License');
            UtilityTestData.mDiscountApproval.put('EstimateListPrice__c','400000');
            UtilityTestData.mDiscountApproval.put('Discount__c','20');
            UtilityTestData.mDiscountApproval.put('DrivenBy__c','Field');
            UtilityTestData.mDiscountApproval.put('OpportunityLicense__c','Sub-M');
            UtilityTestData.mDiscountApproval.put('currencyIsoCode','INR');
            UtilityTestData.mDiscountApproval.put('Name','Test DA2');
            UtilityTestData.mDiscountApproval.put('Status__c','New');

          sObjDiscountApproval = UtilityTest.putFieldRecord(sObjDiscountApproval,UtilityTestData.mDiscountApproval);

          List<DiscountApproval__c> discountApprovallst = (List<DiscountApproval__c>) UtilityTest.makeinsert(new List<sObject>{sObjDiscountApproval});
          sObjDiscountApproval = new  DiscountApproval__c(Id = discountApprovallst[0].id,DrivenBy__c='Inside Sales', AVP__c = adminUser[0].Id,Discount__c =25,Discount_Approval_Type__c='Subscription');  

          List<DiscountApproval__c> discountApprovallstUpdate = (List<DiscountApproval__c>) UtilityTest.makeupdate(new List<sObject>{sObjDiscountApproval});
          System.assertEquals(discountApprovallstUpdate[0].DrivenBy__c,'Inside Sales');            
        Test.stopTest();
      }
    }
     

}