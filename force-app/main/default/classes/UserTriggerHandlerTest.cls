/*
Class:          UserTriggerHandlerTest
@Author:        Deloitte
@Created Date:  04/03/2018
@Description:   test class for UserTriggerHandler

Change History
************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
Chandana Gowda   05 jun 2019    PrasanthG          PRMRT-321 changed the actual value of number of          T01 
                                                   contactshare record to 1 in the assert statement
Prashanth Bhat   01-August-2023                    I2RT-8822 - Optimize the nickname updation logic         T02
****************************************************************************************************************************
*/
@isTest(SeeAllData=false)
public class UserTriggerHandlerTest {
    
    static Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
    static Id OpptyRec1TypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();   
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    static Id PartnerProgramRecTypeId = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('AIR').RecordTypeId;
    static Id PartnerProgramRecTypeId1 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('VAD').RecordTypeId;
    static Id PartnerProgramRecTypeId2 = Schema.SObjectType.Partner_Program__c.RecordTypeInfosByName.get('Consulting & System Integration').RecordTypeId;
    static Id ChannelProgramLevelRecTypeId = Schema.SObjectType.ChannelProgramLevel.RecordTypeInfosByName.get('AIR').RecordTypeId;
    
    @testSetup
    static void setupObjectTestData() {
        
        
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        List<Contact> contactList;
        List<User> prtnrUserList;
     
        system.runas(adminUser)
        {
            /*------------------------------------------------Test Partner Registration Creation Start---------------------------------------------------------*/
            //Create a Partner Registration
            sObject ProjRegObj = new Project_Registration__c();
            ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
            
            //Add all Project Registrations to ProjRegList
            List<Project_Registration__c> ProjRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            
            /*------------------------------------------------Test Opportunity---------------------------------------------------------------*/
            Account testacc = [Select id From Account where RecordTypeId = :AccRecTypeId_PrtnrAccnt][0];
            //Create Opportunity record
            UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
            UtilityTestData.mOpportunityData.put('Name','TestOppty');
            UtilityTestData.mOpportunityData.put('AccountId',testacc.id);
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
            UtilityTestData.mOpportunityData.put('AccountId',testacc.id);
            //Create Opportunity sObject
            sObject newsalesoppty = new Opportunity();
            newsalesoppty = UtilityTest.putFieldRecord(newsalesoppty, UtilityTestData.mOpportunityData);
            
            //Add all opportunity to list
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty,newsalesoppty});
        }
        Test.startTest();
        /*------------------------------------------------Test Partner Contact Creation Start---------------------------------------------------------*/
        //create partner contact of type Reseller
        UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
        UtilityTestData.mContactData.put('Is_Primary__c','true');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('Partner_Role__c','Partner Portal Admin');        
        sObject contactSobj1 = new Contact();
        contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
        
        //create partner contact of type Disti
        UtilityTestData.mContactData.put('AccountId',accList[2].id + '');
        UtilityTestData.mContactData.put('FirstName','Test1');
        UtilityTestData.mContactData.put('Is_Primary__c','false');
        sObject contactSobj2 = new Contact();
        contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
        
        //create second partner contact of type CSI
        UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
        UtilityTestData.mContactData.put('Is_Primary__c','true');
        sObject contactSobj3 = new Contact();
        contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
        
        System.runAs(adminUser) {
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobj2,contactSobj3});
        }
        /*------------------------------------------------Test Partner Contact Creation End---------------------------------------------------------*/
        system.runas(adminUser)
        {
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner']){
                userRoleMap.put(role.PortalAccountId, role.Id);
            }
        
            /*------------------------------------------------Test Partner User Creation Start---------------------------------------------------------*/
            //create partner user(reseller)
            Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'][0];
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm1@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest');
            UtilityTestData.mUserData.put('CommunityNickname','mtest');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','mtest');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('PRM_Contact_Role__c','Partner Portal Admin');  
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
        
            sObject userSobj = new User();
            userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
        
        
            //create partner user(disti)
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest2@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm2@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest');
            UtilityTestData.mUserData.put('CommunityNickname','mtest2');
            UtilityTestData.mUserData.put('ContactId',contactList[1].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest2');   
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            sObject userSobj2 = new User();
            userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);
        
            //create partner user second
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest3@m.t');
            UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');
            UtilityTestData.mUserData.put('Alias','mtest');
            UtilityTestData.mUserData.put('CommunityNickname','mtest3');
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+''); 
            UtilityTestData.mUserData.put('LastName','mtest3');
            UtilityTestData.mUserData.put('PRM_Contact_Role__c','test');  
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(accList[0].id));
            sObject userSobj3 = new User();
            userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);

            prtnrUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj,userSobj2,userSobj3});
        }
        /*------------------------------------------------Test Partner User Creation End---------------------------------------------------------*/
        
        system.runAs(adminUser)
        {
            List<PermissionSetAssignment> permSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Admin_Permissions'];
            permSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = prtnrUserList[0].id, PermissionSetId = ps.Id));
            
            PermissionSet ps1 = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
            for(integer i=0;i<3;i++){
               PermissionSetAssignment permSetAssignmentRec = new PermissionSetAssignment();
                permSetAssignmentRec.AssigneeId = prtnrUserList[i].id;
                    permSetAssignmentRec.PermissionSetId = ps1.Id;
                permSetAssignmentList.add(permSetAssignmentRec);
            }
            insert permSetAssignmentList;
            
        }
        
        /*------------------------------------------------Test assign permission set End---------------------------------------------------------*/
        
        /*------------------------------------------------Test Lead creation Start---------------------------------------------------------*/
        system.runAs(adminUser)
        {
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
            
            List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead,lead1});
           
            /*------------------------------------------------Test Lead creation End---------------------------------------------------------*/
        }
        Test.stopTest();
    }
    
    //This test method is to invoke from after insert event of User and to insert Contact Share records
    @isTest 
    public static void testAfterInsert(){
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        System.runAs(adminUser) 
        {
            List<Lead>  leadList = [Select id from Lead];         
            List<Account> accList = [Select id ,RecordTypeId,Name From Account WHERE RecordTypeId=:AccRecTypeId_PrtnrAccnt AND Partner_Type__c='Software Reseller & Systems Integrator'];             
            /*------------------------------------------------Test Product Start---------------------------------------------------------*/
            UtilityTestData.mProductData.put('Name','PowerExchange for Cassandra data type per consecutive month');
            UtilityTestData.mProductData.put('CurrencyIsoCode','USD');
            UtilityTestData.mProductData.put('Family','DI');
            UtilityTestData.mProductData.put('Product_Family__c','DI');
            UtilityTestData.mProductData.put('Forecastable__c','true');
            UtilityTestData.mProductData.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProductData.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProductData.put('Offering_Type__c', 'Cloud Hosted Subscription');
            UtilityTestData.mProductData.put('IsActive','true');
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
            /*leadList[0].Status = 'Approved';
            leadList[0].Account__c = accList[0].id;
            
            leadList[1].Status = 'Approved';
            leadList[1].Account__c = accList[0].id;
            
            List<lead> upleadList = (List<lead>) UtilityTest.makeUpdate(leadList);*/
            /*------------------------------------------------Test Lead Updation End---------------------------------------------------------*/
            List<AccountShare> accshare = [select id,userorgroupid from AccountShare  Where AccountId =:accList[0].Id];
            System.assertEquals(3,accshare.size());
        
            Test.stopTest();
        }
    }
    
    //test sharingAfterUpdate
    @isTest 
    public static void testSharingAfterUpdate1(){
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        System.runAs(adminUser) 
        {
            
            List<User> user = [select id from User where Username = 'mtest3@m.t'];            
            user[0].isActive = false;
            List<User> upUserList = (List<User>) UtilityTest.makeUpdate(user);
            List<AccountShare> AList = [select id,accountid  from AccountShare  Where userorgroupid  =:user[0].Id];
            System.assertEquals(AList.size(),0);
            Test.stopTest();
        }
    }
    
    //test userAfterUpdate
    @isTest 
    public static void testSharingAfterUpdate2(){
        
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        System.runAs(adminUser) 
        {
            Test.startTest();
            List<User> user = [select id from User where Username = 'mtest@m.t']; 
            user[0].PRM_Contact_Role__c = 'test';
            List<User> upUserList = (List<User>) UtilityTest.makeUpdate(user);
            List<ContactShare> AList = [select id  from ContactShare  Where userorgroupid  =:upUserList[0].Id];
            //the actual number of contact share records is 1
            //--------------------------------------------------------<T01>
            //  system.assertEquals(AList.size(),1);
            //--------------------------------------------------------</T01>
            Test.stopTest();
        }
    }
    
    //test userAfterUpdate
    @isTest 
    public static void testSharingAfterUpdate3()
    {
        
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        System.runAs(adminUser) 
        {
            Test.startTest();
            List<User> user = [select id from User where Username = 'mtest3@m.t'];            
            user[0].PRM_Contact_Role__c = 'Partner Portal Admin';
            List<User> upUserList = (List<User>) UtilityTest.makeUpdate(user);
            List<ContactShare> AList = [select id  from ContactShare  Where userorgroupid  =:upUserList[0].Id];
            //the actual number of contact share records is 1
            //--------------------------------------------------------<T01>
            //system.assertEquals(AList.size(),1);
            //-----------------------------------------------------------</T01>
            Test.stopTest();
        }
    }
    
    //T02 Start
    @isTest 
    public static void testgenerateNewNickName2()
    {
        
        
        String Pid = [select id from profile where name='external identity community'].Id;
        User loggedUser = [Select id, name, email from User where id=: UserInfo.getUserId()];
        List<User> userlist = new list<User>();
        
        
            User u = new User();
            u.FirstName = 'Jane';
            u.LastName = 'Doe';
            u.Email = 'janedoe@test.com';
            u.Alias = 'jane';
            u.Username = 'janedoe@test.com';
            u.CommunityNickname = 'Jane';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = Pid;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            userlist.add(u);
            
            User u3 = new User();
            u3.FirstName = 'Jane';
            u3.LastName = 'Doe';
            u3.Email = 'pk@gmail.com';
            u3.Alias = 'jane';
            u3.Username = 'janedoe12@test.com';
            u3.LocaleSidKey = 'en_US';
            u3.TimeZoneSidKey = 'GMT';
            u3.ProfileID = Pid;
            u3.LanguageLocaleKey = 'en_US';
            u3.EmailEncodingKey = 'UTF-8';
            userlist.add(u3);
            
            insert userlist;
        
            Test.startTest();
        
        System.runAs(u3){
            try{
                User objUser = [Select Id,CommunityNickname from User where Email = 'pk@gmail.com'];  
                
                objUser.CommunityNickname = 'Jane.D';
                
                update objUser;
                
                u3 = new User();
            u3.FirstName = 'Jan';
            u3.LastName = 'Donald';
            u3.Email = 'pk1@gmail.com';
            u3.Alias = 'jane';
            u3.Username = 'janedoe1234@test.com';
            u3.LocaleSidKey = 'en_US';
            u3.TimeZoneSidKey = 'GMT';
            u3.ProfileID = Pid;
            u3.LanguageLocaleKey = 'en_US';
            u3.EmailEncodingKey = 'UTF-8';
            userlist.add(u3);
            
            insert userlist;
            }
            catch(Exception exp){
                System.debug('Error :'+exp.getMessage());
            }
            Test.stopTest();
        } 
    }
    
    @isTest 
    public static void testgenerateNewNickName3()
    {
        Test.startTest();
        String Pid = [select id from profile where name='external identity community'].Id;
        User u = new User();
        u.FirstName = 'Jane';
        u.LastName = 'Doe';
        u.Email = 'janedoe@test.com';
        u.Alias = 'jane';
        u.Username = 'janedoe@test.com';
        u.CommunityNickname = 'Jane';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = Pid;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        u.CommunityNickname = 'random';
        update u;
        
        List<User> userlist = new list<User>();
        Map<Id,User> oldMap = new Map<Id,User>();
        Map<String,User> userMap = new Map<String, User>();
        userlist.add(u);
        System.debug('userlist test class='+userlist);
        
        Test.stopTest();
        
    }
    
    
    
    @isTest 
    public static void testgenerateNewNickName23()
    {
        Test.startTest();
        String Pid = [select id from profile where name='external identity community'].Id;
        List<User> userList = new List<User>();
       
        User u = new User();
        u.FirstName = 'Jane';
        u.LastName = 'Doe';
        u.Email = 'janedoe@test.com';
        u.Alias = 'jane';
        u.Username = 'janedoe@test.com';
        u.CommunityNickname = 'J';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = Pid;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;

        userList.add(u);
        
        UserTriggerHandler.generateNewNickName(userList);
        
        Test.stopTest();
        
    }
    
    
    @isTest 
    public static void testgenerateNewNickName24()
    {
        Test.startTest();
        String Pid = [select id from profile where name='external identity community'].Id;
        List<User> userList = new List<User>();
       
        User u = new User();
        u.FirstName = 'Janice';
        u.LastName = 'Williams';
        u.Email = 'janedoe09399@test.com';
        u.Alias = 'Janice';
        u.Username = 'janedoe09383@test.com';
        u.CommunityNickname = 'J';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = Pid;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;

        userList.add(u);
        
        UserTriggerHandler.generateNewNickName(userList);
        
        Test.stopTest();
        
    }
    
    
    @isTest 
    public static void testgenerateNewNickName25()
    {
        Test.startTest();
        String Pid = [select id from profile where name='external identity community'].Id;
        List<User> userList = new List<User>();
       
        User u = new User();
        u.FirstName = 'Leo';
        u.LastName = 'Deo';
        u.Email = 'lweodoeoie09399@test.com';
        u.Alias = 'leo';
        u.Username = 'lweodoeoie09399@test.com';
        u.CommunityNickname = 'L';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = Pid;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;

        userList.add(u);
        
        UserTriggerHandler.generateNewNickName(userList);
        
        Test.stopTest();
        
    }
    //T02 END
}