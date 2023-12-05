/*
Class:          ApexSharingUtilityTest
@Author:        Deloitte
@Created Date:  07/03/2018
@Description:   This class is a test class for Apex sharing utility class.

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest(SeeAllData=false)
private class ApexSharingUtilityTest 
{
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Product Request').getRecordTypeId();
    
    static Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='PRM - Partner Community Login'][0];
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
    
    /**************************************************************************************
* Function            : Create test data for this test class.                
*************************************************************************************/
    @testSetup
    static void setuptestdata()
    {
        List<Contact> contactList;
        //List<User> adminUserList = UtilityTest.createAdminUserforPRM();
        
        List<User> userList = UtilityTest.createUsersforPRM();
        List<Account> accList = UtilityTest.createAccountforPRM();
        User adminUser = userList[0];
        
        system.runas(adminUser)
        {
            Account distiAcc =  accList[2];
            Account resellerAcc = accList[1];
            Account siAcc = accList[3];
            
            UtilityTestData.mContactData.put('AccountId',distiAcc.id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName1');
            UtilityTestData.mContactData.put('LastName','test Con LastName1');
            UtilityTestData.mContactData.put('Email','tstconmail101@gmail.com');
            UtilityTestData.mContactData.put('Phone','9517536548');
            UtilityTestData.mContactData.put('MailingCountry','India');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            
            sObject ConDis = new Contact();
            ConDis = UtilityTest.putFieldRecord(ConDis, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('AccountId',resellerAcc.id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName11');
            UtilityTestData.mContactData.put('LastName','test Con LastName11');
            UtilityTestData.mContactData.put('Email','testconemail1@gmail.com');
            
            sObject ConRes = new Contact();
            ConRes = UtilityTest.putFieldRecord(ConRes, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('Email','testconemail2@gmail.com');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','false');
            
            sObject ConRes1 = new Contact();
            ConRes1 = UtilityTest.putFieldRecord(ConRes1, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('Email','testconemail3@gmail.com');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            
            sObject ConRes2 = new Contact();
            ConRes2 = UtilityTest.putFieldRecord(ConRes2, UtilityTestData.mContactData);
            Test.startTest();
            contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConDis,ConRes,ConRes1,ConRes2});
            System.assertEquals(contactList[1].AccountId,resellerAcc.id);
            System.assertEquals(contactList[0].Is_Active__c,true);
            
            
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
            for(UserRole role:[Select Id,PortalType,PortalAccountId From UserRole where PortalType =:'Partner'])
            {
                userRoleMap.put(role.PortalAccountId, role.Id);
            }
            
            List<user> lstUser = new List<user>();
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest@m.t');
            UtilityTestData.mUserData.put('Email','mtest@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',contactList[0].id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('IsActive','true');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(distiAcc.id));
            UtilityTestData.mUserData.put('UserType','PowerPartner');
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
            sObject userSobj = new User();
            userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('Email','mtest2@m.t');
            UtilityTestData.mUserData.put('Username','mtest2@m.t');
            UtilityTestData.mUserData.put('ContactId',contactList[1].id+'');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(distiAcc.id));
            UtilityTestData.mUserData.put('CommunityNickname','mtest2');
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
            sObject userSobj1 = new User();
            userSobj1 = UtilityTest.putFieldRecord(userSobj1, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('Email','mtest3@m.t');
            UtilityTestData.mUserData.put('Username','mtest3@m.t');
            UtilityTestData.mUserData.put('ContactId',contactList[2].id+'');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(distiAcc.id));
            UtilityTestData.mUserData.put('CommunityNickname','mtest3');
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
            sObject userSobj2 = new User();
            userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('Email','mtest5@m.t');
            UtilityTestData.mUserData.put('Username','mtest5@m.t');
            UtilityTestData.mUserData.put('ContactId',contactList[3].id+'');
            UtilityTestData.mUserData.put('UserRoleId',userRoleMap.get(distiAcc.id));
            UtilityTestData.mUserData.put('CommunityNickname','mtest5');
            UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
            
            
            sObject userSobj3 = new User();
            userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);
            
            lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj,userSobj1,userSobj2,userSobj3});   
            List<PermissionSetAssignment> permSetAssignList =  new List<PermissionSetAssignment>();
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'PRM_Partner_Access'];
            for(integer i=0;i<4;i++){
                
                permSetAssignList.add(new PermissionSetAssignment(AssigneeId = lstUser[i].id, PermissionSetId = ps.Id));
                
            }
            insert permSetAssignList;
            Test.stopTest();
        }
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class.    
test deactivate
*************************************************************************************/
    static testMethod void testPrtnrDistiShare(){
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [Select id From Account];
        List<User> newUserList;
        
        system.runas(adminUser){
            
            //create partner distributor
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','Afghanistan');
            sObject partnerdisti = new Partner_Distributor__c();
            partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);
            
            List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti});
            
            //fetch the share records
            list<Partner_Distributor__Share> pd_shareList = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share];
            system.assertEquals(pd_shareList.size(), 5);
            //fetch any user from reseller account that will have access to the partner distributor
            User partnerUser = [select id from User where Username = 'mtest2@m.t'];
            list<Partner_Distributor__Share> pd_shareListforPartnerUsr = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share where userorgroupid = :partnerUser.Id];
            system.assertEquals(pd_shareListforPartnerUsr.size(), 1);
            
            //insert oPartnerDistributor;   
            System.assertNotEquals(partnerdistiList[0].Id,null);  
            
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller');
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('billingCountry','India');
            
            sObject accResellerUpdate = new Account();
            accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
            List<Account> accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate});
            
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[0].id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName111');
            UtilityTestData.mContactData.put('LastName','test Con LastName111');
            UtilityTestData.mContactData.put('Email','testconemail11@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','false');
            
            sObject ConResUpdate = new Contact();
            ConResUpdate = UtilityTest.putFieldRecord(ConResUpdate, UtilityTestData.mContactData);
            List<Contact> ConResUpdateList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate});
            
            System.assertNotEquals(ConResUpdateList[0].Id,null);
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest22@m.t');
            UtilityTestData.mUserData.put('Email','mtest22@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[0].id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            
            sObject newUserSobj = new User();
            newUserSobj = UtilityTest.putFieldRecord(newUserSobj, UtilityTestData.mUserData);
            
            newUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj});
            
            globalApexManager.allowRun('PartnerDistributorAfterUpdate');
            partnerdistiList[0].Reseller_Account__c = accResellerUpdateList[0].Id;
            List<Partner_Distributor__c> upPartnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeUpdate(partnerdistiList);
           
            //fetch any user from reseller account that will have access to the partner distributor
            User partnerUser1 = [select id from User where Username = 'mtest22@m.t'];
            list<Partner_Distributor__Share> pd_shareListforPartnerUsrUpdated = [select id,userorgroupid,AccessLevel from Partner_Distributor__Share where userorgroupid = :partnerUser1.Id];
            system.assertEquals(pd_shareListforPartnerUsrUpdated.size(), 1);
        }
        Test.stopTest(); 
        system.runAs(adminUser){
            newUserList[0].IsActive = false;
            List<USer> upUserList1 = (List<USer>) UtilityTest.makeUpdate(new List<sObject>{newUserList[0]});
            System.assertEquals(upUserList1[0].IsActive,false);
            
            upUserList1[0].IsActive = True; 
            List<USer> upUserList2 = (List<USer>) UtilityTest.makeUpdate(new List<sObject>{newUserList[0]});
            System.assertNotEquals(upUserList2[0].IsActive,false);       
        }
        
        
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class. 
test activate
*************************************************************************************/
    static testMethod void testDealRegShare(){
        Test.startTest();
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [Select id From Account];
        
        system.runas(adminUser){
            
            //create partner distributor
            UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accList[1].id+'');
            UtilityTestData.mPartnerDistributorData.put('Distributor__c',accList[2].id+'');
            UtilityTestData.mPartnerDistributorData.put('Country__c','Afghanistan');
            sObject partnerdisti = new Partner_Distributor__c();
            partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);
            
            List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti});
            
            System.assertNotEquals(partnerdistiList[0].Id,null);  
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','test');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Approved');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[3].Id+'');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            //Create Opportunity sObject
            sObject channeloppty = new Opportunity();
            channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
            
            //Add all opportunity to list
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty});
            
            /*------------------------------------------------Test Partner Relationship---------------------------------------------------------*/
            //Create partner relationship record
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',channeloppty.id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accList[1].Id);
            
            //Create Partner_Relationship__c sObject
            sObject partreln = new Partner_Relationship__c();
            partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);
            
            List<SObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});
            test.stopTest();
        }
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class
to test: disableDRsharingForInactiveUsers
*************************************************************************************/
    static testMethod void testDealRegDisblShare(){
        Test.startTest();
        List<Contact> contactList = [Select id,View_All_Deal_Registrations__c  From Contact];
        List<Account> accList = [Select id From Account];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        
        UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
        sObject accResellerUpdate = new Account();
        accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
        List<Account> accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate});
        
        accResellerUpdateList[0].IsPartner = True;
        accResellerUpdateList[0].RecordTypeId = AccRecTypeId_PrtnrAccnt;
        accResellerUpdateList[0].Contract_Company_Group__c = 'Partners';
        update accResellerUpdateList;
        system.debug('accResellerUpdateList[0]'+accResellerUpdateList[0].Partner_Type__c);
        UtilityTestData.mPartnerDistributorData.put('Country__c','Afghanistan');
        UtilityTestData.mPartnerDistributorData.put('Reseller_Account__c',accResellerUpdateList[0].Id);
        sObject partnerdisti = new Partner_Distributor__c();
        partnerdisti = UtilityTest.putFieldRecord(partnerdisti, UtilityTestData.mPartnerDistributorData);            
        List<Partner_Distributor__c> partnerdistiList = (List<Partner_Distributor__c>) UtilityTest.makeInsert(new List<sObject>{partnerdisti});
        
        system.runas(adminUser){
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','test');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Approved');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Distributor__c',accList[2].Id);
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');                                    
            UtilityTestData.mLeadData.put('Partner_Distributor__c', partnerdistiList[0].Id);
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c', accResellerUpdateList[0].Id);
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData); 
            List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        }
        
        
        contactList[0].View_All_Deal_Registrations__c = false;
        List<Contact> toUpdateConList = (List<Contact>) UtilityTest.makeUpdate(contactList);
        Test.stopTest();
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class
to test: enableDRsharingForActiveUsers
*************************************************************************************/
    static testMethod void testDealRegEnblShare(){
        Test.startTest();
        List<Contact> contactList = [Select id,View_All_Deal_Registrations__c  From Contact];
        List<Account> accList = [Select id From Account];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        
        system.runas(adminUser){        
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','test');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Approved');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].Id);
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        }
        
        contactList[2].View_All_Deal_Registrations__c = true;
        List<Contact> toUpdateConList = (List<Contact>) UtilityTest.makeUpdate(contactList);
        //fetch user of contact who will have access to the lead
        List<user> userList = [select Id from user where contact.id = :toUpdateConList[2].id];
        set<id> userIds=new set<id>();
        for(user u: userList)
        {
            userIds.add(u.id);
        }
        //fetch the share records
        list<LeadShare> lead_shareListUpdated = [select userorgroupid from LeadShare where userorgroupid in :userIds];
        system.assertEquals(lead_shareListUpdated.size(), 0);
        Test.stopTest();
    }
    
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class
to test: disablesharingForPartnerUsers
*************************************************************************************/
    static testMethod void testDealRegDsblSharePrtnUsr(){        
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<Account> accList = [Select id From Account];
        system.runas(adminUser){
            
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','test');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr1.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].Id+'');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
            Test.startTest();
            sObject channeloppty = new Opportunity();
            channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
            //Add all opportunity to list
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty});
            
            /*------------------------------------------------Test Partner Relationship---------------------------------------------------------*/
            //Create partner relationship record
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',channeloppty.id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accList[1].Id+'');
            //Create Partner_Relationship__c sObject
            sObject partreln = new Partner_Relationship__c();
            partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);
            
            List<Partner_Relationship__c> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});
            
            
            
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller');
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('billingCountry','India');
            
            sObject accResellerUpdate = new Account();
            accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
            List<Account> accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate});
            
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[0].id + '');
            UtilityTestData.mContactData.put('FirstName','test Con FirstName112');
            UtilityTestData.mContactData.put('LastName','test Con LastName112');
            UtilityTestData.mContactData.put('Email','testconemail12@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            
            sObject ConResUpdate = new Contact();
            ConResUpdate = UtilityTest.putFieldRecord(ConResUpdate, UtilityTestData.mContactData);
            List<Contact> ConResUpdateList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate});
            
            System.assertNotEquals(ConResUpdateList[0].Id,null);
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest22@m.t');
            UtilityTestData.mUserData.put('Email','mtest22@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[0].id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            
            sObject newUserSobj = new User();
            newUserSobj = UtilityTest.putFieldRecord(newUserSobj, UtilityTestData.mUserData);
            
            List<User> newUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj});
            
            leadList[0].Reseller_SI_Partner__c = accResellerUpdateList[0].id;
            List<Lead> toUpdateLeadList = (List<Lead>) UtilityTest.makeUpdate(leadList);
             
            tempList[0].Status__c = 'Inactive - RFP Loss';
            List<Partner_Relationship__c> toUpdatePRList = (List<Partner_Relationship__c>) UtilityTest.makeUpdate(tempList);
            
            //fetch user of contact who will lose access to the opportunity
            User user = [select Id from user where contact.accountid = :accList[1].id limit 1];
            
            //fetch the share records
            list<OpportunityShare> opty_shareList = [select id,userorgroupid from OpportunityShare where Opportunityid = :channeloppty.id and userorgroupid = :user.id];
            //system.assertEquals(opty_shareList.size(), 0);
            
         Test.stopTest();          
        }
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class.    
test enablesharingForActiveUsers
*************************************************************************************/
    static testMethod void testDealRegEnblSharePrtnUsr(){
        Test.startTest();
        List<Account> accList = [Select id From Account];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<User> newUserList2;
        system.runas(adminUser){
            
            UtilityTestData.mContactData.put('AccountId',accList[3].id + '');
            UtilityTestData.mContactData.put('FirstName','test ConReslSI FirstName1');
            UtilityTestData.mContactData.put('LastName','test ConReslSI LastName1');
            UtilityTestData.mContactData.put('Email','tstConReslSIemail@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            
            sObject ConResUpdate1 = new Contact();
            ConResUpdate1 = UtilityTest.putFieldRecord(ConResUpdate1, UtilityTestData.mContactData);
            List<Contact> ConResUpdateList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate1});
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest22@m.t');
            UtilityTestData.mUserData.put('Email','mtest22@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[0].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            
            sObject newUserSobj1 = new User();
            newUserSobj1 = UtilityTest.putFieldRecord(newUserSobj1, UtilityTestData.mUserData);
            
            List<User> newUserList1 = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj1});
            
            //Create a Project Registration
            UtilityTestData.mProjectRegistrationData.put('Partner_Account__c',accList[3].id+'');
            sObject ProjRegObj = new Project_Registration__c();
            UtilityTestData.mProjectRegistrationData.put('Customer_Account_State_Province__c','California');
            ProjRegObj = UtilityTest.putFieldRecord(ProjRegObj, UtilityTestData.mProjectRegistrationData);
            
            //Add all Project Registrations to ProjRegList
            List<Project_Registration__c> ProjRegList = (List<Project_Registration__c>) UtilityTest.makeInsert(new List<sObject>{ProjRegObj});
            
            sObject channeloppty = new Opportunity();
            channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
            
            //Add all opportunity to list
            List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty});
            
            //Create Engagement
            
            UtilityTestData.mEngagementData.put('Name','Test Engagement 1');
            UtilityTestData.mEngagementData.put('RecordTypeId',EgmtRecTypeId);
            UtilityTestData.mEngagementData.put('Account__c',accList[1].id);
            sObject EngagementObj = new Engagement__c();
            EngagementObj = UtilityTest.putFieldRecord(EngagementObj, UtilityTestData.mProductRequestData);
            List<Engagement__c> EngList = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{EngagementObj});
            
            Test.stopTest(); 
            
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
            UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
            sObject accResellerUpdate = new Account();
            accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
            List<Account> accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate});
            
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[0].id + '');
            UtilityTestData.mContactData.put('FirstName','test PRM Con FirstName111');
            UtilityTestData.mContactData.put('LastName','test PRM Con LastName111');
            UtilityTestData.mContactData.put('Email','tstPRMCnRslSIeml@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            
            sObject ConResUpdate2 = new Contact();
            ConResUpdate2 = UtilityTest.putFieldRecord(ConResUpdate2, UtilityTestData.mContactData);
            List<Contact> ConResUpdateList1 = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate2});
            
            System.assertNotEquals(ConResUpdateList1[0].Id,null);
            
            UtilityTestData.mUserData.put('Username','mtest222@m.t');
            UtilityTestData.mUserData.put('Email','mtest222@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest222');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList1[0].Id+'');
            sObject newUserSobj2 = new User();
            newUserSobj2 = UtilityTest.putFieldRecord(newUserSobj2, UtilityTestData.mUserData);
            
            newUserList2 = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj2});
            
            ProjRegList[0].Partner_Account__c = accResellerUpdateList[0].id;
            List<Project_Registration__c> toUpdateProRegList = (List<Project_Registration__c>) UtilityTest.makeUpdate(ProjRegList);
            
            EngList[0].Account__c = accResellerUpdateList[0].id;
            List<Engagement__c> toUpdateEngList = (List<Engagement__c>) UtilityTest.makeUpdate(EngList);
            
            
            //create partner rel
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',channeloppty.id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accResellerUpdate.Id+'');
            //Create Partner_Relationship__c sObject
            sObject partreln = new Partner_Relationship__c();
            partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);
            
            List<Partner_Relationship__c> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});
        }
        system.runAs(adminUser){
            newUserList2[0].IsActive = false;
            
            List<User> toUpdateUserList = (List<User>) UtilityTest.makeUpdate(newUserList2);
            System.assertEquals(toUpdateUserList[0].IsActive,false);   
            toUpdateUserList[0].IsActive = True;
            
            List<User> toUpdateUserList1 = (List<User>) UtilityTest.makeUpdate(toUpdateUserList);
            System.assertNotEquals(toUpdateUserList1[0].IsActive,false);       
        }
        
        
    }
    
    /**************************************************************************************
* Function            : Test Method to provide code coverage for Apex sharing utility class.    
test enablesharingForActiveUsers
*************************************************************************************/
    static testMethod void testDealRegEnblDsblSharePrtnUsr(){
        Test.startTest(); 
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        List<Contact> contactList = [Select id,View_All_Deal_Registrations__c  From Contact];
        List<Account> accList = [Select id From Account];
        User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
        List<lead> leadList;
        List<User> newUserList;
        system.runas(adminUser){
            UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
            UtilityTestData.mLeadData.put('Deal_Registration_Name__c','test');
            UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
            UtilityTestData.mLeadData.put('Resell_working_with_Informatica_Sales__c','Yes');
            UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
            UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
            UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
            UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
            UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
            UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
            UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
            UtilityTestData.mLeadData.put('Status','Received');
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('LastName ','test');
            UtilityTestData.mLeadData.put('Email','test@testr.q');
            UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accList[1].Id);
            UtilityTestData.mLeadData.put('Company','test');
            UtilityTestData.mLeadData.put('Country','Australia');
            UtilityTestData.mLeadData.put('FirstName','test');
            
            //create lead
            sObject lead = new Lead();
            lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
            
            leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
            
            UtilityTestData.mAccountData.put('Name','TestAcc22');
            UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
            UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller & Systems Integrator');
            UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
            UtilityTestData.mAccountData.put('Contract_Signed__c','true');
            UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
            UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
            UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
            UtilityTestData.mAccountData.put('Year_Founded__c','2017');
            UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
            UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
            UtilityTestData.mAccountData.put('NumberOfEmployees','1');
            UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
            sObject accResellerUpdate = new Account();
            accResellerUpdate = UtilityTest.putFieldRecord(accResellerUpdate, UtilityTestData.mAccountData);
            List<Account> accResellerUpdateList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{accResellerUpdate});
            
            
            UtilityTestData.mContactData.put('AccountId',accResellerUpdateList[0].id + '');
            UtilityTestData.mContactData.put('FirstName','test ConReslSI FirstName1');
            UtilityTestData.mContactData.put('LastName','test ConReslSI LastName1');
            UtilityTestData.mContactData.put('Email','testconemail11@gmail.com');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
            
            sObject ConResUpdate1 = new Contact();
            ConResUpdate1 = UtilityTest.putFieldRecord(ConResUpdate1, UtilityTestData.mContactData);
            
            UtilityTestData.mContactData.put('Email','testconemail11@gmail.com');
            sObject ConResUpdate2 = new Contact();
            ConResUpdate2 = UtilityTest.putFieldRecord(ConResUpdate2, UtilityTestData.mContactData);
            
            List<Contact> ConResUpdateList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{ConResUpdate1,ConResUpdate2});
            
            System.assertNotEquals(ConResUpdateList[0].Id,null);
            System.assertNotEquals(ConResUpdateList[1].Id,null);
            
            UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
            UtilityTestData.mUserData.put('Username','mtest22a@m.t');
            UtilityTestData.mUserData.put('Email','mtest22a@m.t');
            UtilityTestData.mUserData.put('Alias','alias');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22a');
            UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
            UtilityTestData.mUserData.put('LocaleSidKey','en_US');
            UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
            UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[0].Id+'');
            UtilityTestData.mUserData.put('IsPortalEnabled','true');         
            UtilityTestData.mUserData.put('LastName','last');
            UtilityTestData.mUserData.put('CompanyName','TEST');
            UtilityTestData.mUserData.put('isactive','true');
            
            sObject newUserSobj1 = new User();
            newUserSobj1 = UtilityTest.putFieldRecord(newUserSobj1, UtilityTestData.mUserData);
            
            UtilityTestData.mUserData.put('ContactId',ConResUpdateList[1].Id+'');
            UtilityTestData.mUserData.put('Username','mtest22b@m.t');
            UtilityTestData.mUserData.put('Email','mtest22b@m.t');
            UtilityTestData.mUserData.put('CommunityNickname','mtest22b');
            sObject newUserSobj2 = new User();
            newUserSobj2 = UtilityTest.putFieldRecord(newUserSobj2, UtilityTestData.mUserData);
            
            newUserList = (List<USer>) UtilityTest.makeInsert(new List<sObject>{newUserSobj1,newUserSobj2});
            
            leadList[0].Reseller_SI_Partner__c = accResellerUpdateList[0].id;
            
            List<Lead> toUpdateLeadList = (List<Lead>) UtilityTest.makeUpdate(leadList);
            //fetch the share records
            list<LeadShare> lead_shareList = [select id,userorgroupid from LeadShare];
            system.assertEquals(lead_shareList.size()>0,true);
        }
       
        system.runAs(adminUser){
            
            newUserList[0].IsActive = false;
            newUserList[1].IsActive = false;
            List<User> userActiveList = (List<User>) UtilityTest.makeUpdate(newUserList);
            System.assertEquals(userActiveList[0].IsActive,false);
            System.assertEquals(userActiveList[1].IsActive,false);
            userActiveList[0].IsActive = True;
            userActiveList[1].IsActive = True;
            List<User> userActiveList1 = (List<User>) UtilityTest.makeUpdate(userActiveList);
            System.assertNotEquals(userActiveList1[0].IsActive,false);
            System.assertNotEquals(userActiveList1[1].IsActive,false);
        }
        Test.stopTest(); 
    }
}