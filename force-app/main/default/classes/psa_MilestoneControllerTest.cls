/*
@created by       : balajip
@created on       : 01/06/2020
@Purpose          : Test class for psa_MilestoneControllerTest

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_MilestoneControllerTest {
    private static List<Schema.SObjectType> mySObjects = new Schema.SObjectType[] {
                                                            Account.SObjectType,
                                                            Opportunity.SObjectType,
                                                            pse__Region__c.SObjectType,
                                                            pse__Work_Calendar__c.SObjectType,
                                                            Contact.SObjectType,
                                                            Product2.SObjectType,
                                                            pricebookEntry.SObjectType,
                                                            pse__Proj__c.SObjectType,
                                                            pse__Milestone__c.SObjectType,
                                                            Event.SObjectType
                                                        };

    @testSetup
    static void setupObjectTestData() { 
        UnitOfWork uow = new UnitOfWork(mySObjects);
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        
        //Create Account
        Account acc = new Account(Name = 'Test Account', RecordTypeId = AccRecType.Id, BillingCountry = 'India');
        uow.registerNew(acc);

        //Create Region 
        pse__Region__c region1 = new pse__Region__c(Name = 'Test Region-1');
        uow.registerNew(region1); 

        pse__Region__c region2 = new pse__Region__c(Name = 'Test Region-2');
        uow.registerNew(region2); 
       
        System.runAs(userObj){            
            // Create work calendar 
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            uow.registerNew(defaultWorkCalendar);
            
            //Create Contact
            Contact con = new Contact(LastName = 'Test Contact' ,pse__Resource_Role__c = 'Regional Manager', pse__Is_Resource__c = true,RecordTypeId = rt.Id,
                            Is_Primary__c = false, pse__Is_Resource_Active__c = true, pse__Default_Cost_Rate__c = 10,psa_Employee_Type__c = 'Informatica-Non PS',
                            pse__Salesforce_User__c = userObj.Id);
            uow.registerRelationship(con, Contact.pse__Region__c, region1);
            uow.registerNew(con, Contact.AccountId, acc);
           
            //Create Product
            Product2 prodRec = new Product2();
            prodRec.Name = 'Test Product';
            prodRec.Offering_Type__c='Professional Services';
            uow.registerNew(prodRec);

            //Activate PriceBook
            Id pricebookId = Test.getStandardPricebookId();            
            Pricebook2 priceBookRec = new Pricebook2(Id = pricebookId, IsActive = True);
            update priceBookRec;
        
            //Create PriceBookEntry
            pricebookEntry pbEntry = new pricebookEntry();
            pbEntry.UnitPrice=100;
            pbEntry.CurrencyIsoCode='USD';
            pbEntry.IsActive=true;
            uow.registerRelationship(pbEntry,pricebookEntry.Pricebook2Id,priceBookRec);
            uow.registerNew(pbEntry,pricebookEntry.Product2Id,prodRec);
            
           //Create Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate = System.today().addDays(30), Type = 'Direct', StageName = 'Validate', CurrencyIsoCode = 'USD',
                                psa_om_Start_Date__c = System.today(), psa_om_End_Date__c = System.today().addDays(10),
                                psa_om_IPS_Package__c = 'JumpStart: Enterprise Data Preparation',
                                PSA_OM_Project_Type__c = 'JumpStart');
            uow.registerNew(opp, Opportunity.AccountId, acc);

            //Create Project
            pse__Proj__c proj = new pse__Proj__c(pse__Project_Type__c = 'Customer Project',psa_pm_Project_Sub_Type__c = 'JumpStart',
                pse__Is_Active__c = true, psa_pm_Require_Product_On_Timecards__c = false, pse__Start_Date__c = System.today().addDays(-6), 
                pse__End_Date__c = System.today().addDays(10), pse__Allow_Self_Staffing__c = true, psa_pm_Expense_Approval_Method__c = 'Auto-Approve');
            uow.registerRelationship(proj, pse__Proj__c.pse__Project_Manager__c, con);
            uow.registerRelationship(proj, pse__Proj__c.pse__Opportunity__c, opp);
            uow.registerNew(proj, pse__Proj__c.pse__Account__c, acc); 

            //Create Milestone
            pse__Milestone__c milestoneRec = new pse__Milestone__c(Name = 'FTV - Test Milestone 1',
                                                psa_pm_Record_Type__c ='Billing',pse__Milestone_Amount__c = 10,
                                                pse__Target_Date__c = System.today().addDays(10));
            uow.registerNew(milestoneRec,pse__Milestone__c.pse__Project__c,proj);

            //Create Event
            Event e = new Event(StartDateTime = System.today().addDays(1), EndDateTime = System.today().addDays(2));
            uow.registerNew(e, Event.WhatId, milestoneRec);
            
            //Commit to the database
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
        List<pse__Milestone__c> lMilestone = [Select Id, pse__Project__r.pse__Opportunity__c From pse__Milestone__c LIMIT 1];
        
        //Update Pricebook on Opportunity
        oppty.Pricebook2Id = pbe.Pricebook2Id;
        update oppty;

        //Create Opportunity Product
        OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid= pbe.Id,TotalPrice=2000,Quantity = 2,OpportunityId = oppty.Id);
        insert oppLine;
        
        //Call controller methods
        psa_MilestoneController.getOpptyProductSelectionFields();
        psa_MilestoneController.getOpptyProducts(lMilestone[0].Id);
        List<OpportunityLineItem> lstOpptyLineItem = [Select Id From OpportunityLineItem Where OpportunityId = :lMilestone[0].pse__Project__r.pse__Opportunity__c];
        psa_MilestoneController.setOpptyProduct(lMilestone[0].Id, lstOpptyLineItem[0].Id);
        Test.stopTest();
    }
    
}