/*
Class:          PartnerRelationshipTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for PartnerRelationshipTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest(SeeAllData=false)
private class PartnerRelationshipTriggerHandlerTest {
    
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
        //List<User> prtnrUserList = UtilityTest.createPartnerUsersforPRM();
        Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();    
            
         
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
            
        Profile employeeProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];
    
        UtilityTestData.mUserData.put('ProfileId',employeeProfile.id+'');
        UtilityTestData.mUserData.put('Username','testemailpatnerFSR@infa.com');
        UtilityTestData.mUserData.put('Email','testemailpatnerFSR@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest');
        UtilityTestData.mUserData.put('CommunityNickname','mtest');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        
        UtilityTestData.mUserData.put('LastName','mtest');
        UtilityTestData.mUserData.put('IsActive','true');
        
        sObject userSobj = new User();
        userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
        
        List<User> userListInsert = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj});
		List<User> prtnrUserList = new List<User>(); 
        List<lead> leadList;
    	List<Contact> contactList = new List<Contact>();
        Map<Id,Id> userRoleMap = new Map<Id,Id>();
        
        system.runAs(adminUser){
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');   
            sObject contactSobj1 = new Contact();   
            contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);  
                
            //create partner contact of type Disti  
            UtilityTestData.mContactData.put('AccountId',AccList[1].id + ''); 
            sObject contactSobj2 = new Contact();   
            contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);  
                
            //create partner contact of type Software Reseller and SI   
            UtilityTestData.mContactData.put('AccountId',AccList[2].id + '');   
            sObject contactSobj3 = new Contact();   
            contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);  
                
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobj2,contactSobj3});  
               
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){   
                userRoleMap.put(role.PortalAccountId, role.Id); 
            }   
            
        }
        
        Test.startTest();
        system.runAs(adminUser){
      /*------------------------------------------------Test Opportunity---------------------------------------------------------------*/
      //Create Opportunity record
      UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
      UtilityTestData.mOpportunityData.put('Name','TestOppty');
      UtilityTestData.mOpportunityData.put('AccountId',accList[0].id);
      UtilityTestData.mOpportunityData.put('Sales_Play__c','Data Quality');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');        
      UtilityTestData.mOpportunityData.put('CloseDate','2018-02-05');
      UtilityTestData.mOpportunityData.put('OwnerId',adminUser.Id);
      
      //Create Opportunity sObject
      sObject channeloppty = new Opportunity();
      channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
      
      //Create Opportunity record
      UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRecTypeId);
      UtilityTestData.mOpportunityData.put('Name','TestOppty1');
      
      //Create Opportunity sObject
      sObject newsalesoppty = new Opportunity();
      newsalesoppty = UtilityTest.putFieldRecord(newsalesoppty, UtilityTestData.mOpportunityData);
      
      //Add all opportunity to list
      List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty,newsalesoppty});
      
      /*------------------------------------------------Test Partner Relationship---------------------------------------------------------*/
      //Create partner relationship record
      UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',channeloppty.id);
      UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
      UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accList[1].id);
      UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','false');
      //Create Partner_Relationship__c sObject
      sObject partreln = new Partner_Relationship__c();
      partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);
      
      //Create partner relationship record
      UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
      //Create Partner_Relationship__c sObject
      sObject partreln1 = new Partner_Relationship__c();
      partreln1 = UtilityTest.putFieldRecord(partreln1, UtilityTestData.mPartnerRelationshipData);
      List<SObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln,partreln1});
      
      /*------------------------------------------------Test Channel Program Creation Start---------------------------------------------------------*/
      //create ChannelProgram  
      sObject channelProgramObj = new ChannelProgram();
      channelProgramObj = UtilityTest.putFieldRecord(channelProgramObj, UtilityTestData.mChannelProgramData);
      
      List<ChannelProgram> channelProgList = (List<ChannelProgram>) UtilityTest.makeInsert(new List<sObject>{channelProgramObj});
      
      /*------------------------------------------------Test Channel Program Creation End---------------------------------------------------------*/
      
        
      /*------------------------------------------------Test Channel Program Level Creation Start---------------------------------------------------------*/
      //create ChannelProgramLevel
      Id ChannelProgramLevelRecTypeId = [SELECT id FROM RecordType where SObjectType='ChannelProgramLevel' and DeveloperName='AIR'].id;
      
      UtilityTestData.mChannelProgramLevelData.put('RecordTypeId',ChannelProgramLevelRecTypeId);
      UtilityTestData.mChannelProgramLevelData.put('ProgramId',channelProgList[0].id + '');
      
      sObject channelProgramLevelObj = new ChannelProgramLevel();
      channelProgramLevelObj = UtilityTest.putFieldRecord(channelProgramLevelObj, UtilityTestData.mChannelProgramLevelData);
      
      List<ChannelProgramLevel> channelProgLevelList = (List<ChannelProgramLevel>) UtilityTest.makeInsert(new List<sObject>{channelProgramLevelObj});
      
      /*------------------------------------------------Test Channel Program Level Creation End---------------------------------------------------------*/
      
      
      /*------------------------------------------------Test Partner Program Creation Start---------------------------------------------------------*/
      //create partner program
      UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId);
      UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
      UtilityTestData.mPartnerProgramData.put('Program_Year__c',system.today().year()+'');
      UtilityTestData.mPartnerProgramData.put('Start_Date__c',system.today()-3+'');
      UtilityTestData.mPartnerProgramData.put('End_Date__c',system.today()+3+'');
      UtilityTestData.mPartnerProgramData.put('Channel_Program_Level__c',channelProgLevelList[0].id+'');
      UtilityTestData.mPartnerProgramData.put('Program_Type__c','1 Tier AIR');
      UtilityTestData.mPartnerProgramData.put('Program_Level__c','N/A');
      
      //Create partnerProgObj for accList[1].id
      sObject partnerProgObj = new Partner_Program__c();
      partnerProgObj = UtilityTest.putFieldRecord(partnerProgObj, UtilityTestData.mPartnerProgramData);
      
      //Create partnerProgObj1 for accList[2].id
      UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId1);
      UtilityTestData.mPartnerProgramData.put('Program_Type__c','VAD');
      UtilityTestData.mPartnerProgramData.put('Partner__c',accList[2].id + '');
      sObject partnerProgObj1 = new Partner_Program__c();
      partnerProgObj1 = UtilityTest.putFieldRecord(partnerProgObj1, UtilityTestData.mPartnerProgramData);
      
      //Create partnerProgObj1 for accList[2].id      
      UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
      UtilityTestData.mPartnerProgramData.put('Program_Type__c','CSI');
      UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
      sObject partnerProgObj2 = new Partner_Program__c();
      partnerProgObj2 = UtilityTest.putFieldRecord(partnerProgObj2, UtilityTestData.mPartnerProgramData);
      
      //Create partnerProgObj1 for accList[2].id      
      UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
      UtilityTestData.mPartnerProgramData.put('Program_Type__c','ISV');
      UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
      sObject partnerProgObj3 = new Partner_Program__c();
      partnerProgObj3 = UtilityTest.putFieldRecord(partnerProgObj3, UtilityTestData.mPartnerProgramData);
      
      //Create partnerProgObj1 for accList[2].id      
      UtilityTestData.mPartnerProgramData.put('RecordTypeId',PartnerProgramRecTypeId2);
      UtilityTestData.mPartnerProgramData.put('Program_Type__c',label.PRM_Prgrm_Type_OEM_Value);
      UtilityTestData.mPartnerProgramData.put('Partner__c',accList[1].id + '');
      sObject partnerProgObj4 = new Partner_Program__c();
      partnerProgObj4 = UtilityTest.putFieldRecord(partnerProgObj4, UtilityTestData.mPartnerProgramData);
      
      List<Partner_Program__c> partnerProgList = (List<Partner_Program__c>) UtilityTest.makeInsert(new List<sObject>{partnerProgObj,partnerProgObj1,partnerProgObj2,partnerProgObj3,partnerProgObj4});
      
      /*------------------------------------------------Test Partner Program Creation End---------------------------------------------------------*/
       
      /*------------------------------------------------Test Partner Distributor Creation Start---------------------------------------------------------*/
      //create partner distributor
      UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
      UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
      sObject partnerdisti = new Partner_Distributor__c();
      partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);
      List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti});
        }
        /*------------------------------------------------Test Partner Distributor Creation End---------------------------------------------------------*/
        /*------------------------------------------------Test Lead creation Start---------------------------------------------------------*/
        
        //create partner user(reseller) 
        
        
        system.runAs(adminUser){
            Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login']; 
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');    
        UtilityTestData.mUserData.put('Username','mtest46@m.t');  
        UtilityTestData.mUserData.put('Email','testemailforleadm1@infa.com');   
        UtilityTestData.mUserData.put('Alias','mtest'); 
        UtilityTestData.mUserData.put('CommunityNickname','mte46'); 
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');  
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');  
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1'); 
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US'); 
        UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');    
        UtilityTestData.mUserData.put('LastName','mtest');  
        UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id)); 
        UtilityTestData.mUserData.put('UserType','PowerPartner');   
        sObject userSobj10 = new User();  
        userSobj10 = UtilityTest.putFieldRecord(userSobj10, UtilityTestData.mUserData); 
        
        //create partner user(disti)    
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');    
        UtilityTestData.mUserData.put('Username','mtest47@m.t'); 
        UtilityTestData.mUserData.put('Email','testemailforleadm2@infa.com');   
        UtilityTestData.mUserData.put('Alias','mtest'); 
        UtilityTestData.mUserData.put('CommunityNickname','mtes47');    
        UtilityTestData.mUserData.put('ContactId',contactList[1].id+'');    
        UtilityTestData.mUserData.put('LastName','mtest2'); 
        UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[1].id)); 
        sObject userSobj2 = new User(); 
        userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);   
        
        //create partner user(software reseller and SI) 
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');    
        UtilityTestData.mUserData.put('Username','mtest48@m.t'); 
        UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');   
        UtilityTestData.mUserData.put('Alias','mtest3');    
        UtilityTestData.mUserData.put('CommunityNickname','mtes48');    
        UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');    
        UtilityTestData.mUserData.put('LastName','mtest3'); 
        UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[2].id)); 
        sObject userSobj3 = new User(); 
        userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);   
        
        prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj10,userSobj2,userSobj3});   
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Admin_Permissions']; 
        insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps.Id ); 
        
        PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];   
        insert new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps1.Id );    
        
        PermissionSet psa = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];   
        insert new PermissionSetAssignment(AssigneeId = prtnrUserList[1].id, PermissionSetId = psa.Id );    
        
        PermissionSet psb = [SELECT ID From PermissionSet WHERE Name = 'PRM_SI_Partner'];   
        insert new PermissionSetAssignment(AssigneeId = prtnrUserList[2].id, PermissionSetId = psb.Id );    
        
        }
        
        Test.stopTest();
        system.runAs(adminUser){
          UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
          UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert');
          UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
          UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
          UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
          UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
          UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
          UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','');
          UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
          UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
          UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
          UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
          UtilityTestData.mLeadData.put('Status','New');
          UtilityTestData.mLeadData.put('Company','test');
          UtilityTestData.mLeadData.put('LastName ','test');
          UtilityTestData.mLeadData.put('Email','test@testr.q');
          UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].id + '');
        
          UtilityTestData.mLeadData.put('Company','test');
          UtilityTestData.mLeadData.put('Country','United States');
          UtilityTestData.mLeadData.put('FirstName','test');
          
          //create lead
          sObject lead = new Lead();
          lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
          
          UtilityTestData.mLeadData.put('FirstName','test1');
          UtilityTestData.mLeadData.put('LastName ','test1');
          UtilityTestData.mLeadData.put('Email','test1@testr1.q');
        
          //create lead1
          sObject lead1 = new Lead();
          lead1 = UtilityTest.putFieldRecord(lead1, UtilityTestData.mLeadData);
          
          leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead1});
            
      /*------------------------------------------------Test Lead creation End---------------------------------------------------------*/
      
      
    }
    }
    
    // This method is used for creating data for trigger handler to check conditions before inserting and on update
    @isTest
    static void TestmethodPartnerRelationship()
    {
        Opportunity PRoppty = [Select id,Name From Opportunity where Name ='TestOppty'][0];
        Account PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
        //Query for Resseller Partner Program
        List<Partner_Program__c> PP = [Select id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId];
        List<Partner_Relationship__c> PR = [Select id,Partner_role__c from Partner_Relationship__c where Opportunity__c =:PRoppty.Id ]; 
        
        PR[0].Partner_Role__c = 'ISV';
        PR[0].DEV_PRM_IsConverted__c = false;
        PR[0].Program_Membership__c = PP[0].id;
        List<sObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeUpdate(new list<sObject>{PR[0]});
        Test.startTest();
        //Query for CSI Partner Program  
        PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0]; 
        List<Partner_Program__c> PP1 = [Select RecordType.Name , Name, id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId2];
        system.debug('partprog>>'+PP1);
        //Create partner relationship record  
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_Referral_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
        //Create Partner_Relationship__c sObject
        sObject partreln1 = new Partner_Relationship__c();
        partreln1 = UtilityTest.putFieldRecord(partreln1, UtilityTestData.mPartnerRelationshipData);
        
        List<SObject> tempList1 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln1});
       
        //Update Opportunity    
        PRoppty = [Select id,Name From Opportunity where Name ='TestOppty1'][0];
        Partner_Relationship__c TypeCastpartreln1 = (Partner_Relationship__c)partreln1;
        TypeCastpartreln1.Opportunity__c = PRoppty.id; 
        //UtilityTest.makeUpdate(new list<sObject>{TypeCastpartreln1});
        TypeCastpartreln1.Program_Membership__c = PP1[0].id;
        TypeCastpartreln1.Partner_Role__c = label.PRM_Partner_Role_Resell_Value; 
        UtilityTest.makeUpdate(new list<sObject>{TypeCastpartreln1});   
        //Query for Disti Partner Program
        List<Partner_Program__c> PP2 = [Select id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId1];
        PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt AND Partner_Type__c='Distributor'][0];
        
        //Create partner relationship record
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_One_Time_Disti_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP2[0].id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
        //Create Partner_Relationship__c sObject
        sObject partreln2 = new Partner_Relationship__c();
        partreln2 = UtilityTest.putFieldRecord(partreln2, UtilityTestData.mPartnerRelationshipData);
        List<SObject> tempList2 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln2});
    }
    
    @isTest
    static void TestmethodPartnerRelationship11(){
        Test.startTest();
        Opportunity PRoppty = [Select id,Name From Opportunity where Name ='TestOppty'][0];
        Account PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
        //Query for Resseller Partner Program
        List<Partner_Program__c> PP = [Select id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId];
        List<Partner_Relationship__c> PR = [Select id,Partner_role__c from Partner_Relationship__c where Opportunity__c =:PRoppty.Id ]; 
        
        PR[0].Partner_Role__c = 'ISV';
        PR[0].DEV_PRM_IsConverted__c = false;
        PR[0].Program_Membership__c = PP[0].id;
        List<sObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeUpdate(new list<sObject>{PR[0]});
        
        //Query for CSI Partner Program  
        PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0]; 
        List<Partner_Program__c> PP1 = [Select RecordType.Name , Name, id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId2];
        system.debug('partprog>>'+PP1);
        //Create ISV partner relationship record  
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_ISV_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        //UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
        //Create Partner_Relationship__c sObject
        sObject partreln3 = new Partner_Relationship__c();
        partreln3 = UtilityTest.putFieldRecord(partreln3, UtilityTestData.mPartnerRelationshipData);
        //Test.startTest();
        List<SObject> tempList3 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln3});
        
        PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt AND Partner_Type__c='Software Reseller'][0];
        //Create OEM partner relationship record  
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_OEM_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        //UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
        //Create Partner_Relationship__c sObject
        //Test.startTest();
        sObject partreln4 = new Partner_Relationship__c();
        partreln4 = UtilityTest.putFieldRecord(partreln4, UtilityTestData.mPartnerRelationshipData);
        List<Partner_Relationship__c> tempList4 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln4});
        UtilityTest.makeDelete(tempList4);
        Test.stopTest(); 
    }
    
    // This test method is used to create data for lead converion
    @isTest
    static void PRMLeadConversion1() {
          Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name from Lead];
        List<Account> accList = UtilityTest.createAccountforPRM();
      	User userListInsert = [select id from user where username = 'testemailpatnerFSR@infa.com' limit 1];
      
        Account acc = new Account(Name = 'Test Employee Onwer Account',
                                 RecordTypeId= AccRecTypeId_CustAccnt,
                                 OwnerId = userListInsert.Id,
                                 BillingCountry='United States');
        insert acc;
        //rus as sog user and emulate convert to new opportunity
        System.runAs(adminuser) {
        /*------------------------------------------------Test Product Start---------------------------------------------------------*/
          UtilityTestData.mProductData.put('Name','PowerExchange for Cassandra data type per consecutive month');
          UtilityTestData.mProductData.put('CurrencyIsoCode','USD');
          UtilityTestData.mProductData.put('Family','DI');
          UtilityTestData.mProductData.put('Product_Family__c','DI');
          UtilityTestData.mProductData.put('Forecastable__c','true');
          UtilityTestData.mProductData.put('Pricing_Business_Model__c','Subscription');
          UtilityTestData.mProductData.put('Delivery_Method__c','Hosted Multi Tenant');
          UtilityTestData.mProductData.put('IsActive','true');
          UtilityTestData.mProductData.put('Offering_Type__c','On-Premise Subscription');
          sObject prod1 = new Product2();
          prod1 = UtilityTest.putFieldRecord(prod1, UtilityTestData.mProductData);
          List<Product2> prodList = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{prod1});
          /*------------------------------------------------Test Product Start---------------------------------------------------------*/
          
          
          /*------------------------------------------------Test Lead Product Start---------------------------------------------------------*/
          UtilityTestData.mProductData.put('Lead__c',leadList[0].id+'');
          UtilityTestData.mProductData.put('Product__c',prodList[0].id+'');
          
          sObject leadProd1 = new Deal_Registration_Products__c();
          leadProd1 = UtilityTest.putFieldRecord(leadProd1, UtilityTestData.mProductData);
          
          sObject leadProd2 = new Deal_Registration_Products__c();
          UtilityTestData.mProductData.put('Lead__c',leadList[1].id+'');
          leadProd2 = UtilityTest.putFieldRecord(leadProd2, UtilityTestData.mProductData);
          
          List<Deal_Registration_Products__c> leadProdList = (List<Deal_Registration_Products__c>) UtilityTest.makeInsert(new List<sObject>{leadProd1,leadProd2});
          /*------------------------------------------------Test Lead Product Start---------------------------------------------------------*/
          
          /*------------------------------------------------Test Lead Updation Start---------------------------------------------------------*/
          leadList[0].Status = 'Approved';
          leadList[0].Account__c = [SELECT id from Account where Name = 'Test Employee Onwer Account'].Id;
          
          leadList[1].Status = 'Approved';
          leadList[1].Account__c = [SELECT id from Account where Name = 'Test Employee Onwer Account'].Id;
          
          system.debug('accList[0] >>' + accList[0]);
          
          List<lead> upleadList = (List<lead>) UtilityTest.makeUpdate(leadList);
          /*------------------------------------------------Test Lead Updation End---------------------------------------------------------*/
                
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[0].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[0].Primary_Role_in_Sale__c);
            UtilityTestData.mOpportunityData.put('Owner',adminUser.id+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[1].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[1].Primary_Role_in_Sale__c);
            sObject Oppty1 = new Opportunity();
            Oppty1 = UtilityTest.putFieldRecord(Oppty1, UtilityTestData.mOpportunityData);
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c',leadList[1].id+':Deal_Registration');
            UtilityTestData.mOpportunityData.put('sub_type__c',leadList[1].Primary_Role_in_Sale__c);
            sObject Oppty2 = new Opportunity();
            Oppty2 = UtilityTest.putFieldRecord(Oppty2, UtilityTestData.mOpportunityData);
            
            
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty,Oppty2});
            
        }
        Test.stopTest();
    }
    // This test method is used to create data for lead converion
    @isTest
    static void PRMLeadConversion2() {
        Test.startTest();
    User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Lead> leadList = [select id,Primary_Role_in_Sale__c,Name,PartnerAccountId from Lead];
        //rus as sog user and emulate convert to new opportunity
        
        System.runAs(adminUser) {
            
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c','');
            UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
            UtilityTestData.mOpportunityData.put('Owner',adminUser.id+'');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Type','Indirect');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);
            
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            
            opptyList[0].Dev_Lead_Identifier__c = leadList[0].id+':Deal_Registration';
            opptyList[0].sub_type__c = leadList[0].Primary_Role_in_Sale__c;
            opptyList[0].StageName = 'Validate';
            
            
            List<Opportunity> upOpptyList = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{opptyList[0]});
            list<Partner_Relationship__c> partnerRelCreated = [select id from Partner_Relationship__c where Opportunity__c = :upOpptyList[0].id];
      //system.assertEquals(partnerRelCreated.size(),1);
            
            
        }
        Test.stopTest();
    }
    // This test method is used to create data for lead converion
    @isTest
    static void PRMLeadConversion3(){
        Test.startTest();
        Opportunity PRoppty = [Select id,Name From Opportunity where Name ='TestOppty'][0];
        Account PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
        
        try{
            //Create OEM partner relationship record  
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_Referral_Value);//
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
            UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
            UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Sourced__c','Yes');
            UtilityTestData.mPartnerRelationshipData.put('Resell_Partner__c','true');
            //Create Partner_Relationship__c sObject
            sObject partreln4 = new Partner_Relationship__c();
            partreln4 = UtilityTest.putFieldRecord(partreln4, UtilityTestData.mPartnerRelationshipData);
            List<Partner_Relationship__c> tempList4= (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln4});
        }
        catch(Exception e){
   //   system.assertEquals(e.getMessage().contains('% Allocated should not be greater than 100%'),true);
    }
        
        
        try{
            //Create OEM partner relationship record  
            /*UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_Referral_Value);//
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
            UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
            //UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
            UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
            UtilityTestData.mPartnerRelationshipData.put('Allocated__c','101');
            UtilityTestData.mPartnerRelationshipData.put('Resell_Partner__c','true');
            //Create Partner_Relationship__c sObject
            sObject partreln5 = new Partner_Relationship__c();
            partreln5 = UtilityTest.putFieldRecord(partreln5, UtilityTestData.mPartnerRelationshipData);
            List<Partner_Relationship__c> tempList5 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln5});*/
            List<Partner_Relationship__c> partreln5 = [SELECT ID FROM Partner_Relationship__c LIMIT 1];
            sObject sObj21 = new Partner_Relationship__c(Id = partreln5[0].Id,Allocated__c = 101);  
            sObj21 = UtilityTest.putFieldRecord(sObj21, UtilityTestData.mPartnerRelationshipData);  
            List<Partner_Relationship__c> lpartreln2 = (List<Partner_Relationship__c>) UtilityTest.makeUpdate(new List<sObject>{sObj21}); 
        }
        catch(Exception e){
      system.assertEquals(e.getMessage().contains('% Allocated should not be greater than 100%'),false);
    }
        Test.stopTest();
    }
    
    // This test method is used to create data for lead converion
    @isTest
    static void PRMLeadConversion4(){
        Test.startTest();
        Opportunity PRoppty = [Select id,Name From Opportunity where Name ='TestOppty'][0];
        Account PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
        
        PRoppty.sub_type__c='Partner Sourced/Partner Driven';
        update PRoppty;
        
        //List<User> TestUser = [Select id from User where Username = 'mtestsog@m.t'];
    User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
        List<User> TestUser1 = [Select id from User where Username = 'prmTestAdmn@m.t'];
        //Create OEM partner relationship record  
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_Referral_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Pending Field Sales Approval');
        UtilityTestData.mPartnerRelationshipData.put('Owner',sogUser.id);
        UtilityTestData.mPartnerRelationshipData.put('Resell_Partner__c','true');
        //Create Partner_Relationship__c sObject
        sObject partreln6 = new Partner_Relationship__c();
        partreln6 = UtilityTest.putFieldRecord(partreln6, UtilityTestData.mPartnerRelationshipData);
        List<Partner_Relationship__c> tempList7 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln6});
        
        Partner_Relationship__c TypeCastpartreln1 = (Partner_Relationship__c)partreln6;
        TypeCastpartreln1.Status__c = 'Declined - Field Sales'; 
        UtilityTest.makeUpdate(new list<sObject>{TypeCastpartreln1});
        
        try{
            UtilityTestData.mOpportunityData.put('Dev_Lead_Identifier__c','');
            UtilityTestData.mOpportunityData.put('sub_type__c','Partner Sourced/Partner Driven');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Type','Indirect');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            
            
            sObject Oppty = new Opportunity();
            Oppty = UtilityTest.putFieldRecord(Oppty, UtilityTestData.mOpportunityData);        
            List<Opportunity> opptyList  = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Oppty});
            UtilityTestData.mOpportunityData.put('OwnerId',TestUser1[0].id);
            opptyList = (List<Opportunity>)UtilityTest.makeUpdate(new list<sObject>{Oppty});
            
        }
        catch(Exception e){}
        
        
        
        Test.stopTest();
    }
    
    // This method is used for creating data for trigger handler to check conditions for before inserting and on update
    @isTest
    static void TestmethodPartnerRelationship2()
    {
    Test.startTest();
    User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
    List<sObject> tempList;
    List<SObject> tempList1;
    
        Opportunity PRoppty = [Select id,Name From Opportunity where Name ='TestOppty'][0];
        Account PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
        Account PRacc1 = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt AND Partner_Type__c='Distributor'][0];
        //Query for Resseller Partner Program
        List<Partner_Program__c> PP = [Select id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId];
        List<Partner_Relationship__c> PR = [Select id,Partner_role__c from Partner_Relationship__c where Opportunity__c =:PRoppty.Id ]; 
        
        PR[0].Partner_Role__c = 'ISV';
        PR[0].DEV_PRM_IsConverted__c = false;
        PR[0].Program_Membership__c = PP[0].id;
    System.runAs(adminUser){
      tempList = (List<Partner_Relationship__c>)UtilityTest.makeUpdate(new list<sObject>{PR[0]});
        }
        //Query for CSI Partner Program  
        PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0]; 
        List<Partner_Program__c> PP1 = [Select RecordType.Name , Name, id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId2];
        
        //Create partner relationship record  
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_Referral_Value);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRAcc.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
        UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
        UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
        //Create Partner_Relationship__c sObject
        sObject partreln1 = new Partner_Relationship__c();
        partreln1 = UtilityTest.putFieldRecord(partreln1, UtilityTestData.mPartnerRelationshipData);
        System.runAs(adminUser){
      tempList1 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln1});
    }
        System.runAs(adminUser){
      //Update Opportunity    
      PRoppty = [Select id,Name From Opportunity where Name ='TestOppty1'][0];
      Partner_Relationship__c TypeCastpartreln1 = (Partner_Relationship__c)partreln1;
      TypeCastpartreln1.Opportunity__c = PRoppty.id; 
      UtilityTest.makeUpdate(new list<sObject>{TypeCastpartreln1});
      TypeCastpartreln1.Program_Membership__c = PP1[0].id;
      TypeCastpartreln1.Partner_Role__c = label.PRM_Partner_Role_Resell_Value; 
      UtilityTest.makeUpdate(new list<sObject>{TypeCastpartreln1});   
      
      //Query for Disti Partner Program
      List<Partner_Program__c> PP2 = [Select id from Partner_Program__c where RecordTypeId = :PartnerProgramRecTypeId1];
      PRacc = [Select id from Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt AND Partner_Type__c='Distributor'][0];
      
      //Create partner relationship record
      UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',PRoppty.id);
      UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_One_Time_Disti_Value);
      UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',PRacc1.id);
      UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP2[0].id);
      UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
      UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
      //Create Partner_Relationship__c sObject
      sObject partreln2 = new Partner_Relationship__c();
      partreln2 = UtilityTest.putFieldRecord(partreln2, UtilityTestData.mPartnerRelationshipData);
      List<SObject> tempList2 = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln2});
        }
        Test.stopTest(); 
    }
    
    // This method is used for creating data for trigger handler to check for different conditions before inserting and on update
    @isTest
    static void Testmethod1PartnerRelationship(){
        Test.startTest();
    User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
    User sogUser = [select id from user where username = 'prmTestSog@m.t' limit 1];
    List<Opportunity> opptyList3;
    List<Account> tempList5;
                //create distributor partner account
                UtilityTestData.mAccountData.put('Partner_Type__c','Distributor');
                UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
                UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
                UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
                UtilityTestData.mAccountData.put('Contract_Signed__c','true');
                UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
                UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
                UtilityTestData.mAccountData.put('Year_Founded__c','2017');
                UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
                UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
                UtilityTestData.mAccountData.put('NumberOfEmployees','1');
                UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
                sObject partnerDistiAcc1 = new Account();
                partnerDistiAcc1 = UtilityTest.putFieldRecord(partnerDistiAcc1, UtilityTestData.mAccountData);
                System.runAs(adminUser){
          tempList5 = (List<Account>)UtilityTest.makeInsert(new list<sObject>{partnerDistiAcc1});
                }
                
                //Create Opportunity record
                UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
                UtilityTestData.mOpportunityData.put('Name','TestOppty');
                UtilityTestData.mOpportunityData.put('AccountId',tempList5[0].id);
                UtilityTestData.mOpportunityData.put('Sales_Play__c','Data Quality');
                UtilityTestData.mOpportunityData.put('Type','Direct');
                UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');        
                UtilityTestData.mOpportunityData.put('CloseDate','2018-02-05');
                UtilityTestData.mOpportunityData.put('StageName','Validate');
                UtilityTestData.mOpportunityData.put('OwnerId',sogUser.id);
                
                
                //Create Opportunity sObject
                sObject channeloppty1 = new Opportunity();
                channeloppty1 = UtilityTest.putFieldRecord(channeloppty1, UtilityTestData.mOpportunityData); 
                Opportunity TypeCastoppty = (Opportunity)channeloppty1;
                TypeCastoppty.OwnerId = sogUser.id;//
                //UtilityTest.makeInsert(new list<sObject>{TypeCastoppty});
                System.runAs(adminUser){
          opptyList3 = (List<Opportunity>) UtilityTest.makeInsert(new list<sObject>{TypeCastoppty});
        }
        try{
            System.runAs(sogUser){
                //Create OEM partner relationship record  
                UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',opptyList3[0].id);
                UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_OEM_Value);
                UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',tempList5[0].id);
                UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','true');
                UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
                //Create Partner_Relationship__c sObject
                sObject partreln5 = new Partner_Relationship__c();
                partreln5 = UtilityTest.putFieldRecord(partreln5, UtilityTestData.mPartnerRelationshipData);
                Partner_Relationship__c TypeCastpartreln5 = (Partner_Relationship__c)partreln5;
                TypeCastpartreln5.Partner_Account__c = tempList5[0].id;//Opportunity__c
                List<Partner_Relationship__c> partnerRel = UtilityTest.makeInsert(new list<sObject>{TypeCastpartreln5}); 
        system.assertEquals(partnerRel.size(),1);
            }
        }
        catch(Exception e){}
        Test.stopTest();
        
    }
    // Test method to  throw validation error if internal user except SOG creates Partner Relationship for a Closed Opportunity
    @isTest
    static void TestCheckCreateonClosedOpty(){
        test.startTest();
    //List<User> adminUserList = [Select id,ManagerId from User where Username = 'mtestadmin@m.t'];
    User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
    List<Account> accList = [Select id from Account];
    List<Opportunity> opptyList3;
    //List<User> fsrUserList;
    User psmUser = [select id from user where username = 'mtestpsm@m.t' limit 1];
    
    system.runAs(adminUser){
      PermissionSet Intrnladmin1 = [SELECT ID From PermissionSet WHERE Name = 'Modify_All'];
             insert new PermissionSetAssignment(AssigneeId = psmUser.id, PermissionSetId = Intrnladmin1.Id );
    }
    
    
    system.runAs(adminUser){
      //Create Opportunity record
      UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
      UtilityTestData.mOpportunityData.put('Name','TestOppty');
      UtilityTestData.mOpportunityData.put('AccountId',accList[0].id);
      UtilityTestData.mOpportunityData.put('Sales_Play__c','Data Quality');
      UtilityTestData.mOpportunityData.put('Type','Direct');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');        
      UtilityTestData.mOpportunityData.put('CloseDate','2018-02-05');
      UtilityTestData.mOpportunityData.put('StageName','Validate');
      
      //Create Opportunity sObject
      sObject channeloppty1 = new Opportunity();
      channeloppty1 = UtilityTest.putFieldRecord(channeloppty1, UtilityTestData.mOpportunityData); 
      opptyList3 = (List<Opportunity>) UtilityTest.makeInsert(new list<sObject>{channeloppty1});
    }
        System.runAs(psmUser){
      //Create OEM partner relationship record  
      UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',opptyList3[0].id);
      UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c',label.PRM_Partner_Role_OEM_Value);
      UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accList[1].id);
      //UtilityTestData.mPartnerRelationshipData.put('Program_Membership__c',PP1[0].id);
      UtilityTestData.mPartnerRelationshipData.put('Status__c','Inactive - RFP Loss');
      //Create Partner_Relationship__c sObject
      sObject partreln5 = new Partner_Relationship__c();
      partreln5 = UtilityTest.putFieldRecord(partreln5, UtilityTestData.mPartnerRelationshipData);
    
      try{
        UtilityTest.makeInsert(new list<sObject>{partreln5});
      }
      catch(Exception e)
      {
        system.assertEquals(e.getMessage().contains('Partner Relationship cannot be created for Closed Opportunity'),true);
      }
      
        }
    test.stopTest();
  }
    
    // This Method is to test coverage for "updateOpptyPartner" upon insert and update.
    @isTest
    static void TestupdateOpptyPartner(){
    User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
    List<Account> accList = [Select id from Account];
    test.startTest();
    User psmUser = [select id from user where username = 'mtestpsm@m.t' limit 1];
    
    system.runAs(adminUser){
      PermissionSet Intrnladmin1 = [SELECT ID From PermissionSet WHERE Name = 'Modify_All'];
             insert new PermissionSetAssignment(AssigneeId = psmUser.id, PermissionSetId = Intrnladmin1.Id );
    }
      Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      List<Partner_Relationship__c>  partreln1 =  [SELECT Id FROM Partner_Relationship__c LIMIT 1];
      
  try{      
        sObject sObj2 = new Partner_Relationship__c(Id = partreln1[0].Id,Partner_Sourced__c = 'Yes');  
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPartnerRelationshipData);  
        List<Partner_Relationship__c> lpartreln2 = (List<Partner_Relationship__c>) UtilityTest.makeUpdate(new List<sObject>{sObj2}); 
    //UtilityTest.makeDelete(lpartreln2);
    //List<Partner_Relationship__c> lpartreln3 = [SELECT ID,Partner_Sourced__c,Partner_Role__c FROM Partner_Relationship__c WHERE Opportunity__c =:opp.Id];            
        } catch(Exception e){
      system.assertEquals(e.getMessage().contains('Record does not exist'),true); 
    }
    test.stopTest();
    }
    
    // This Method is to test coverage for "updateOpptyPartner" upon delete.
    @isTest
    static void deletePRRec(){
        test.startTest();
        List<Opportunity> opp = [SELECT ID FROM Opportunity];
        string oppId = opp[0].Id;
        List<Partner_Relationship__c> lpartrel = [Select Id,Opportunity__c FROM Partner_Relationship__c WHERE Opportunity__c =: oppId];
            try{
                delete lpartrel;
            } catch(Exception e){
                system.assertEquals(e.getMessage().contains('Record does not exist'),true);
            }
        test.stopTest();
        
    }
    
      @isTest
      static void deletePRRecAfterdel(){
        test.startTest();
        List<Opportunity> opp = [SELECT ID FROM Opportunity];
        string oppId = opp[0].Id;
        List<Partner_Relationship__c> lpartrel = [Select Id,Opportunity__c FROM Partner_Relationship__c WHERE Opportunity__c =: oppId];
            try{
                globalApexManager.avoidRecursion('PartnerRelationshipAfterDelete');
                delete lpartrel;
            } catch(Exception e){
                system.assertEquals(e.getMessage().contains('Record does not exist'),true);
            }
        test.stopTest();
        
    }
}