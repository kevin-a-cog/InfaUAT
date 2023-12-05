/*
@created by       : balajip
@created on       : 01/06/2020
@Purpose          : Test class for psa_ResourceRequestControllerTest

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class  psa_ResourceRequestControllerTest {
    private static List<Schema.SObjectType> sObjects = 
        new Schema.SObjectType[]{
            Bypass_Trigger_Settings__c.SobjectType,
            User_Exemptions__c.SobjectType,
            Account.SobjectType,
            pse__Region__c.SobjectType,
            pse__Work_Calendar__c.SobjectType,
            Contact.SobjectType,
            Product2.SobjectType,
            Pricebook2.SobjectType,
            pricebookEntry.SobjectType,
            Opportunity.SobjectType,
            pse__Proj__c.SobjectType,
            pse__Time_Period__c.SobjectType,
            pse__Schedule__c.SobjectType,
            pse__Permission_Control__c.SobjectType,
            PSA_MSA_Code_Mapping__c.SobjectType,
            pse__Resource_Request__c.SobjectType,
            pse__Assignment__c.SobjectType,
            pse__Expense_Report__c.SobjectType,
            pse__Expense__c.SobjectType
        };
    
    @testSetup
    static void setupObjectTestData() {
        
        UnitOfWork uow = new UnitOfWork(sObjects);
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_ResourceRequest_Trigger__c = true;
        uow.registerNew(trigSetting);

        //Skip Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        uow.registerUpsert(settings);
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        System.debug('AccRecType'+ AccRecType.Id);
        
        Account acc = new Account(Name='Test Account',RecordTypeId=accRecType.Id);

        
        pse__Region__c reg1 = new pse__Region__c(Name='Test Region-1',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-1->Informatica',psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg1);
        
        pse__Region__c reg2 = new pse__Region__c(Name='Test Region-2',
                                                 pse__Action_Update_Current_Time_Period__c=false,
                                                 pse__Region_Name_Chain__c='Test Region-2->Informatica',
                                                 psa_pm_Allow_Customer_Project__c=true);
        uow.registerNew(reg2,pse__Region__c.pse__Parent_Region__c,reg1);
        
        Profile prof = [select Name from Profile where Name = 'Employee'];
        User user1 = new User(CommunityNickname='communityuser',
                                ProfileId=prof.Id,
                                LastName='Testing1',
                                Alias='userTep1',
                                timezonesidkey='America/New_York',
                                LocaleSidKey='en_US',
                                LanguageLocaleKey='en_US',
                                EmailEncodingKey='UTF-8',
                                Email='usr_temp1@testorg.com',
                                UserName='usr_temp1@testorg.com');
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            uow.registerNew(defaultWorkCalendar);
        

            Contact con1 = new Contact(LastName = 'Test Contact',
                                       pse__Resource_Role__c='Regional Manager',
                                       pse__Is_Resource__c=true,
                                       Is_Primary__c=false,
                                       pse__Is_Resource_Active__c=true,
                                       pse__Default_Cost_Rate__c=10.00,
                                       pse__Salesforce_User__c=userObj.Id,
                                       RecordTypeId=rt.Id);
            uow.registerRelationship(con1, Contact.AccountId,acc);
            uow.registerRelationship(con1, Contact.pse__Region__c, reg1);
            uow.registerNew(con1, Contact.pse__Work_Calendar__c,defaultWorkCalendar);
            

             //Create Product2
            Product2 prodRec1 = new Product2(Name='Test Product 1',
            Offering_Type__c='Professional Services',
            Product_Family__c='DI',
            Family = 'On-Premise Subscription',
            Forecast_Product__c ='Active VOS',
            Pricing_Business_Model__c ='Perpetual',
            Processing_Engine__c ='NA',
            Delivery_Method__c = 'On Premise');
            uow.registerNew(prodRec1);

        
            Id pricebookId = Test.getStandardPricebookId(); 
            
            Pricebook2 priceBookRec = new Pricebook2(Id = pricebookId,IsActive = True);
            uow.registerDirty(priceBookRec);
            
            // Create Pricebook Entry
            pricebookEntry pbEntry1 = new pricebookEntry(
                UnitPrice=100,
                CurrencyIsoCode='USD',
                IsActive=true
            );
            uow.registerRelationship(pbEntry1, pricebookEntry.Product2Id, prodRec1);
            uow.registerNew(pbEntry1,pricebookEntry.Pricebook2Id,priceBookRec);
            
            Opportunity opty = new Opportunity(Type='Direct',
                                                CurrencyIsoCode='USD',
                                                StageName='Validate',
                                                Name = 'Test opportunity 1',
                                                psa_om_Start_Date__c=System.today(),
                                                CloseDate = System.today().addDays(2),
                                                psa_om_End_Date__c=System.today()+10,
                                                psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                PSA_OM_Project_Type__c='JumpStart'
            );                                 
            uow.registerRelationship(opty,Opportunity.Pricebook2Id,priceBookRec);
            uow.registerNew(opty, Opportunity.AccountId, acc);

            pse__Proj__c projRec1 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Start_Date__c=System.today().addDays(1),
                                                     pse__End_Date__c=System.today().addDays(10),
                                                     pse__Is_Active__c=true,
                                                     psa_pm_Require_Product_On_Timecards__c=false,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Account__c, acc);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Project_Manager__c,con1);
            uow.registerRelationship(projRec1, pse__Proj__c.pse__Opportunity__c,opty);
            uow.registerNew(projRec1,pse__Proj__c.pse__Region__c ,reg1);

            pse__Proj__c projRec2 = new pse__Proj__c(psa_pm_Project_Sub_Type__c='JumpStart',
                                                     pse__Start_Date__c=System.today().addDays(1),
                                                     pse__End_Date__c=System.today().addDays(15),
                                                     pse__Is_Active__c=true,
                                                     psa_om_IPS_Package__c='JumpStart: Cloud Adoption Hybrid MDM',
                                                     pse__Allow_Self_Staffing__c=true,
                                                     psa_pm_Source__c='Interlock',
                                                     PSA_OM_ERP_Billing_Site_ID__c='Interlock');
            uow.registerRelationship(projRec2, pse__Proj__c.pse__Account__c, acc);
            uow.registerNew(projRec2, pse__Proj__c.pse__Opportunity__c,opty);
            
            pse__Time_Period__c tpRec = new pse__Time_Period__c(pse__Start_Date__c=System.today(),
                                                                pse__End_Date__c=System.today().addDays(10),
                                                                pse__Type__c='Quarter');
            uow.registerNew(tpRec);
            
            pse__Schedule__c schRec = new pse__Schedule__c(pse__Start_Date__c=System.today().addDays(1),
                                                           pse__End_Date__c=System.today().addDays(10),
                                                           pse__Monday_Hours__c=8,
                                                           pse__Tuesday_Hours__c=8,
                                                           pse__Wednesday_Hours__c=8,
                                                           pse__Thursday_Hours__c=8,
                                                           pse__Friday_Hours__c=8,
                                                           pse__Sunday_Hours__c=8,
                                                           pse__Saturday_Hours__c=8);
            uow.registerNew(schRec);

            pse__Permission_Control__c pc = new pse__Permission_Control__c( pse__User__c = userObj.Id, 
                                                                            pse__Expense_Ops_Edit__c = true, 
                                                                            pse__Timecard_Ops_Edit__c = true,
                                                                            pse__Cascading_Permission__c = true, 
                                                                            pse__Resource_Request_Entry__c = true, 
                                                                            pse__Staffing__c = true);
            uow.registerNew(pc, pse__Permission_Control__c.pse__Project__c, projRec1);
            
            PSA_MSA_Code_Mapping__c msaCodeMapping1 = new PSA_MSA_Code_Mapping__c(Name='Test Name 1');
            uow.registerNew(msaCodeMapping1);
            
            pse__Resource_Request__c rrRec = new pse__Resource_Request__c(pse__Start_Date__c=System.today().addDays(1),
                                                                          pse__End_Date__c=System.today().addDays(10),
                                                                          pse__SOW_Hours__c=8.00,
                                                                          pse__Resource_Role__c='Consultant',
                                                                          psa_rm_Billable__c=true,
                                                                          pse__Status__c='Draft');
            uow.registerRelationship(rrRec,pse__Resource_Request__c.pse__Staffer_Resource__c, con1);
            // uow.registerRelationShip(rrRec,pse__Resource_Request__c.PSA_OM_Opportunity_Product_Id__c,opptyLineItem1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Resource__c,con1);    
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Region__c,reg1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Project__c,projRec1);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.pse__Opportunity__c,opty);
            uow.registerRelationship(rrRec, pse__Resource_Request__c.psa_rm_MSA_Code_Mapping__c,msaCodeMapping1);
            uow.registerNew(rrRec, pse__Resource_Request__c.psa_rm_Original_Opportunity__c,opty);
            
            pse__Assignment__c asgmt1 = new pse__Assignment__c(Name = 'Test Assignment',
                                                               pse__Cost_Rate_Amount__c = 10,
                                                               pse__Planned_Hours__c = 8,
                                                               pse__Bill_Rate__c = 0,
                                                               pse__Is_Billable__c = true,
                                                               pse__Role__c = 'Senior Consultant');
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Project__c, projRec1);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Schedule__c,schRec);
            uow.registerRelationship(asgmt1, pse__Assignment__c.pse__Resource_Request__c, rrRec);
            uow.registerNew(asgmt1, pse__Assignment__c.pse__Resource__c, con1);

            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }
    }
    @isTest
    public static void test1() {
        
        Test.startTest();
        
        PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1]; 

        //Update Pricebook on Opportunity
        oppty.Pricebook2Id = pbe.Pricebook2Id;
        update oppty;

        //Create Opportunity Product
        OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityId = oppty.Id);
        insert oppLine;

        List<pse__Proj__c> lProject = [SELECT Id,Name FROM pse__Proj__c];
        System.assert(lProject.size()>0, 'Project not created');
        
        List<pse__Time_Period__c> lTimePeriod = [Select Id from pse__Time_Period__c ];
        System.assert(lTimePeriod.size()>0, 'Time Period not created');
        
        List<Contact> lContact = [SELECT Id,Name,ReportsTo.pse__Salesforce_User__r.Id FROM Contact];
        System.assert(lContact.size()>0, 'Contact not created');
        
        List<pse__Work_Calendar__c> lWorkCalendar = [SELECT Id FROM pse__Work_Calendar__c];
        System.assert(lWorkCalendar.size()>0, 'WorkCalendar not created');
        
        List<pse__Resource_Request__c> lResourceRequest = [Select Id,pse__Project__c,pse__Project__r.pse__Opportunity__c from pse__Resource_Request__c];
        System.assert(lResourceRequest.size()>0, 'Resource Request not created');
        
        if(lContact.size()>1){
            lResourceRequest[0].pse__Staffer_Resource__c = lContact[1].Id;
            lContact[1].pse__Work_Calendar__c = lWorkCalendar[0].Id;
        }
        lResourceRequest[0].pse__Project__c = lProject[1].Id;
        
        Update lContact;
        update lResourceRequest;      

        psa_ResourceRequestController.getOpptyProductSelectionFields();
        psa_ResourceRequestController.getOpptyProducts(lResourceRequest[0].Id);
        List<OpportunityLineItem> lstOpptyLineItem = [Select Id From OpportunityLineItem Where OpportunityId = :lResourceRequest[0].pse__Project__r.pse__Opportunity__c];
        psa_ResourceRequestController.setOpptyProduct(lResourceRequest[0].Id, lstOpptyLineItem[0].Id);
        
        Test.stopTest();
    }
    
}