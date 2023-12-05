@IsTest 
public class TestEngagementAfterDelete {
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
    static Id EgmtRecTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Product Request').getRecordTypeId();
    static Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    static Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
    static Id GEMSEscalationRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('Support_Escalation').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() 
    {
        List<Account> accList = new List<Account>();
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        
        system.runAs(adminUser){        
            //create SI partner account
            UtilityTestData.mAccountData.put('Name','Software reseller and SI');
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
            UtilityTestData.mAccountData.put('Partner_Type__c','Systems Integrator');
            sObject partnerAcc1 = new Account();
            partnerAcc1 = UtilityTest.putFieldRecord(partnerAcc1, UtilityTestData.mAccountData); 
            
            //create SI partner account
            UtilityTestData.mAccountData.put('Name','Software reseller and SI 2');
            sObject partnerAcc2 = new Account();
            partnerAcc2 = UtilityTest.putFieldRecord(partnerAcc2, UtilityTestData.mAccountData);
            
            //Add all accounts to acclist
            accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc1,partnerAcc2});
            
        }
        List<User> prtnrUserList = new List<User>();
        List<Contact> contactList = new List<Contact>();        
        system.runAs(adminUser){
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Is_Primary__c','true');
            UtilityTestData.mContactData.put('Is_Active__c','true');
            UtilityTestData.mContactData.put('FirstName','Contact');
            UtilityTestData.mContactData.put('Email','Contact1@test.com');
            sObject contactSobj1 = new Contact();
            contactSobj1 = UtilityTest.putFieldRecord(contactSobj1, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Email','Contact2@test.com');
            sObject contactSobj2 = new Contact();
            contactSobj2 = UtilityTest.putFieldRecord(contactSobj2, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[0].id + '');
            UtilityTestData.mContactData.put('Email','Contact3@test.com');
            sObject contactSobj3 = new Contact();
            contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contacta@test.com');
            sObject contactSobja = new Contact();
            contactSobja = UtilityTest.putFieldRecord(contactSobja, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contactb@test.com');
            sObject contactSobjb = new Contact();
            contactSobjb = UtilityTest.putFieldRecord(contactSobjb, UtilityTestData.mContactData);
            
            //create partner contact
            UtilityTestData.mContactData.put('AccountId',accList[1].id + '');
            UtilityTestData.mContactData.put('Email','Contactc@test.com');
            sObject contactSobjc = new Contact();
            contactSobjc = UtilityTest.putFieldRecord(contactSobjc, UtilityTestData.mContactData);
            
            
            system.runAs(adminUser){
                contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{contactSobj1,contactSobjb,contactSobj2,contactSobj3,contactSobja,contactSobjc});
            }
            
            Map<Id,Id> userRoleMap = new Map<Id,Id>();
            List<Account> lAccount = [select id,Name from Account];
                    //Opportunity
        Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
        Id pbId = Test.getStandardPricebookId();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObject sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
            //Engagement
            sObject engagement = new Engagement__c();
            UtilityTestData.mEngagementData.put('Account__c',lAccount[0].Id);
            UtilityTestData.mEngagementData.put('Name','Test Engagment');//
            UtilityTestData.mEngagementData.put('Plan__c',lPlan[0].Id);
            UtilityTestData.mEngagementData.put('RecordTypeId', GEMSEscalationRT);
            UtilityTestData.mEngagementData.put('Opportunity__c',lOpportunity[0].Id);
            engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData); 
             List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
        }
    }
    static testMethod void testSupportEngagement(){
             
        Plan__c pln = [Select id from Plan__c limit 1];
        Adoption_Factor__c adf = new Adoption_Factor__c();
        adf.Impact__c='High';
        adf.Plan__c= pln.Id;
        adf.Engagement__c= 'Poor';
        adf.Product__c='Poor';
        adf.Project__c='Poor';
        Insert adf;

        Test.startTest();

        Engagement__c eng = [SELECT Id,Account__c,Name,Plan__c,RecordTypeId,opportunity__c FROM Engagement__c limit 1];

       // globalApexManager.avoidRecursion('engagementAfterDelete');
        delete eng ;
        Test.stopTest();
    }
    
    static testMethod void testSupportEngagement1(){
             
        Plan__c pln = [Select id from Plan__c limit 1];
        Adoption_Factor__c adf = new Adoption_Factor__c();
        adf.Impact__c='High';
        adf.Plan__c= pln.Id;
        adf.Engagement__c= 'Poor';
        adf.Product__c='Poor';
        adf.Project__c='Poor';
        Insert adf;

        Test.startTest();

        Engagement__c eng = [SELECT Id,Account__c,Name,Plan__c,RecordTypeId,opportunity__c FROM Engagement__c limit 1];

        globalApexManager.avoidRecursion('engagementAfterDelete');
        delete eng ;
        Test.stopTest();
    }
}