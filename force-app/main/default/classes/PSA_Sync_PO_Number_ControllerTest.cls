/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : This Test class provides code coverages to aura controller class PSA_Sync_PO_Number_Controller.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/
@isTest
public with sharing class PSA_Sync_PO_Number_ControllerTest {
    
    @testSetup
    static void initializeData(){
        
         //Bypass Validation Rules
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
                
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        RecordType accRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        // Create Account
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<1;i++){
            Account acc = new Account();
            acc.RecordTypeId = accRecType.Id;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            //acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            accList.add(acc);
            
        }
        insert accList;   
        
        // Create user/Resource 
        // Profile prof = [select Name from Profile where Name = 'IPS Profile'];
        
        // List<User> userList = new List<User>();
        // for(integer i=0;i<2;i++){
        //     userList.add(new User(alias='testRes'+i,
        //                           username='testResource'+i+'@abc123.com',
        //                           lastname='User '+i,
        //                           firstname='Test Resource',
        //                           email='testResource'+i+'@abc123.com',
        //                           timezonesidkey='America/New_York',
        //                           LocaleSidKey='en_US',
        //                           ProfileId=prof.Id,
        //                           LanguageLocaleKey='en_US',
        //                           EmailEncodingKey='UTF-8'));
        // }
        
        // insert userList;
        User userRec = [SELECT Id FROM User WHERE profile.name = 'IPS Profile' AND isActive = true AND UserRole.DeveloperName = 'PS_Operations' LIMIT 1];
        
        // Create Region
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<1;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            regionRec.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec);
        }
        insert regionList;
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        defaultWorkCalendar.pse__Sunday_Hours__c= 8;
        defaultWorkCalendar.pse__Monday_Hours__c=8;
        defaultWorkCalendar.pse__Tuesday_Hours__c=8;
        defaultWorkCalendar.pse__Wednesday_Hours__c=8;
        defaultWorkCalendar.pse__Thursday_Hours__c=8;
        defaultWorkCalendar.pse__Friday_Hours__c=8;
        defaultWorkCalendar.pse__Saturday_Hours__c=8;                
        insert defaultWorkCalendar; 
        
        // Create Contact
        List<Contact> conList = new List<Contact>();
        for(integer i =0;i<1;i++){
            Contact con = new Contact();
            con.AccountId = accList[i].Id;
            con.LastName ='Contact '+i;
            con.FirstName = 'Test';
            con.Email='test'+i+'email@gmail.com';
            con.pse__Is_Resource__c =true;
            con.pse__Is_Resource_Active__c=true;
            con.CurrencyIsoCode='USD';
            con.pse__Resource_Role__c='Regional Manager';
            con.pse__Region__c = regionList[i].Id;
            con.pse__Default_Cost_Rate__c = 10;
            con.pse__Salesforce_User__c = userRec.Id;
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            
            conList.add(con);
            
        }
        insert conList;
        
        // Create Product
        List<Product2> prodList = new List<Product2>();
        for(integer i=0;i<1;i++){
            Product2 prodRec = new Product2();
            prodRec.Name = 'Test Product '+i;
            prodRec.Offering_Type__c='Professional Services';
            prodList.add(prodRec);
        }
        insert prodList;
        
        // Get the Standard price book Id and create active pricebook.
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 priceBookRec = new Pricebook2();
        priceBookRec.Id = pricebookId;
        priceBookRec.IsActive = True;
        
        update priceBookRec;
        
        // Create Pricebook Entry
        List<pricebookEntry> priceBookEntryList = new List<pricebookEntry>();
        for(integer i=0;i<1;i++){
            pricebookEntry pbEntry = new pricebookEntry();
            pbEntry.Pricebook2Id = priceBookRec.Id;
            pbEntry.Product2Id = prodList[i].Id;
            pbEntry.UnitPrice=100;
            pbEntry.CurrencyIsoCode='USD';
            pbEntry.IsActive=true;
            priceBookEntryList.add(pbEntry);
        }
        insert priceBookEntryList; 
        
        // Create Opportuntiy
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        List<Opportunity> opptyList = new List<Opportunity>(); 
        for(integer i=0;i<1;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            oppty.AccountId = accList[i].Id;
            oppty.CurrencyIsoCode='USD';
            oppty.Type='Direct';
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identity';
            oppty.psa_om_Start_Date__c = currentDate;
            oppty.psa_om_End_Date__c = currentDate.addDays(10);
            oppty.PSA_OM_Project_Type__c = 'JumpStart';
            oppty.psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM';
            oppty.Sales_Play__c='Data Quality';
            opptyList.add(oppty);
            
        }
        
        Test.startTest();
        insert opptyList; 
        
        opptyList[0].Pricebook2Id = priceBookEntryList[0].Pricebook2Id;
        update  opptyList;
        
        // Create OpportunityLineItem 
        List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>();
        for(integer i=0;i<1;i++){
            OpportunityLineItem opptyLineItem = new OpportunityLineItem();
            opptyLineItem.pricebookentryid = priceBookEntryList[i].Id;
            opptyLineItem.TotalPrice = 2000;
            opptyLineItem.Quantity =2;
            opptyLineItem.Purchase_Order_PO_Number__c='12345';
            opptyLineItem.OpportunityId = opptyList[i].Id;
            opptyLineItemList.add(opptyLineItem);
        }
        insert opptyLineItemList;
        
         Test.stopTest();
        //Create Permission Control
        List<pse__Permission_Control__c> permControlLst = new List<pse__Permission_Control__c>();
        for(integer i=0;i<1;i++){
            pse__Permission_Control__c permControl = new pse__Permission_Control__c();
            permControl.pse__User__c = userObj.Id;
            permControl.pse__Staffing__c = true;
            permControl.pse__Resource_Request_Entry__c=true;
            permControl.pse__Timecard_Ops_Edit__c = true;
            permControl.pse__Cascading_Permission__c = true;
            permControl.pse__Timecard_Entry__c = true;
            permControl.pse__Region__c = regionList[i].Id;
            permControlLst.add(permControl);
        }
        insert permControlLst;
        
        system.runAs(userObj){
            
            // List<PermissionSetLicenseAssign> permSetLicenseAssignLst = new List<PermissionSetLicenseAssign>();
            // for(PermissionSetLicense license : [Select Id,DeveloperName, MasterLabel from PermissionSetLicense
            //                                     where DeveloperName IN ('SalesforceCPQ_CPQStandardPerm','SalesforceCPQ_CPQAAPerm') Limit 2])
            // {
            //     PermissionSetLicenseAssign permLicAssign =  new PermissionSetLicenseAssign();
            //     permLicAssign.PermissionSetLicenseId=license.Id;
            //     permLicAssign.AssigneeId =userList[0].Id;
            //     permSetLicenseAssignLst.add(permLicAssign); 
            // }
            // insert permSetLicenseAssignLst;
            
            // PermissionSetGroup permSetGrp = [Select Id,DeveloperName from PermissionSetGroup where DeveloperName ='PSA_Operations' Limit 1];
            // PermissionSetAssignment permAssignment = new PermissionSetAssignment(PermissionSetGroupId = permSetGrp.Id,AssigneeId = userList[0].Id);
            // insert permAssignment;
            
            
            // Create Project
            List<pse__Proj__c> projList = new List<pse__Proj__c>();
            for(integer i=0;i<1;i++){
                pse__Proj__c projRec = new pse__Proj__c();
                projRec.Name = 'Test Project '+i;
                projRec.pse__Stage__c='Completed';
                projRec.pse__Project_Manager__c = conList[i].Id;
                projRec.pse__Project_Type__c = 'Customer Project';
                projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
                projRec.pse__Opportunity__c = opptyList[i].Id;
                projRec.pse__Account__c = accList[i].Id;  
                projRec.CurrencyIsoCode='USD';
                projRec.pse__Region__c = regionList[i].Id;
                projRec.pse__Start_Date__c=currentDate.addDays(-6);
                projRec.pse__End_Date__c = currentDate.addDays(10);
                projRec.pse__Is_Active__c=true;
                projRec.pse__Allow_Self_Staffing__c=true;
                projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
                projRec.psa_pm_Require_Product_On_Timecards__c =false;
                projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
                projRec.psa_pm_Require_Location_On_Timecards__c = false;
                
                projList.add(projRec);
                
            }
            insert projList;
            
            // Create Resource Request
            List<pse__Resource_Request__c> resourceReqList = new List<pse__Resource_Request__c>();
            for(integer i=0;i<1;i++){
                pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
                resourceReq.pse__Start_Date__c = currentDate.addDays(1);
                resourceReq.pse__End_Date__c = currentDate.addDays(10);
                resourceReq.pse__Staffer_Resource__c = conList[i].Id;
                resourceReq.pse__Project__c = projList[i].Id;
                resourceReq.pse__Opportunity__c = opptyList[i].Id;
                resourceReq.PSA_Opportunity_Product__c =  opptyLineItemList[i].Id;
                resourceReq.psa_rm_Original_Opportunity__c = opptyList[i].Id;
                resourceReq.pse__Region__c = regionList[i].Id;
                resourceReq.pse__SOW_Hours__c =8;
                resourceReq.pse__Resource_Role__c = 'Consultant';
                resourceReq.CurrencyIsoCode='USD';
                resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
                resourceReq.psa_rm_Billable__c = true;
                resourceReqList.add(resourceReq);
            }
            insert resourceReqList; 
            
            // Create a milestone record
            List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
            for(integer i=0;i<1;i++){
                pse__Milestone__c milestoneRec = new pse__Milestone__c();
                milestoneRec.Name = 'Test Milestone '+i;
                milestoneRec.psa_pm_Record_Type__c ='Billing';
                milestoneRec.pse__Project__c=projList[i].Id;
                milestoneRec.pse__Milestone_Amount__c=10;
                milestoneRec.pse__Target_Date__c = currentDate.addDays(10);
                milestoneRec.PSA_Opportunity_Product__c = opptyLineItemList[i].Id;
                milestoneList.add(milestoneRec);
                
            }
           insert milestoneList;
        }
    }
    @isTest
    public static void syncPONumbersTest1(){
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        OpportunityLineItem opptyLineItem = [Select Id,Purchase_Order_PO_Number__c from OpportunityLineItem 
                                             where OpportunityId=:projRec.pse__Opportunity__c Limit 1];
        
        pse__Milestone__c milestoneRecBefore = [Select Id,PSA_OM_PO_Number__c from pse__Milestone__c where pse__Project__c=:projRec.Id Limit 1];
        pse__Resource_Request__c resReqBefore = [Select Id,PSA_OM_PO_Number__c from pse__Resource_Request__c where pse__Project__c=:projRec.Id Limit 1];
        User userRec = [SELECT Id FROM User WHERE profile.name = 'IPS Profile' AND isActive = true AND UserRole.DeveloperName = 'PS_Operations' LIMIT 1];
        
        system.runAs(userRec){
            String message = PSA_Sync_PO_Number_Controller.syncPONumbers(projRec.Id);
        }
        
        Test.stopTest();
        pse__Milestone__c milestoneRecAfter = [Select Id,PSA_OM_PO_Number__c from pse__Milestone__c where pse__Project__c=:projRec.Id Limit 1];
        pse__Resource_Request__c resReqAfter = [Select Id,PSA_OM_PO_Number__c from pse__Resource_Request__c where pse__Project__c=:projRec.Id Limit 1];
        
        Assert.areEqual(true, String.isBlank(milestoneRecBefore.PSA_OM_PO_Number__c),'Expected PO Number to be blank');
        Assert.areEqual(true, !String.isBlank(milestoneRecAfter.PSA_OM_PO_Number__c),'Expected PO Number to be not blank');
        Assert.areEqual(true, !String.isBlank(resReqAfter.PSA_OM_PO_Number__c),'Expected PO Number to be not blank');
        Assert.areEqual(opptyLineItem.Purchase_Order_PO_Number__c, milestoneRecAfter.PSA_OM_PO_Number__c, 'Expected PO Number to be equal to Purchase Order PO Number');
        Assert.areEqual(opptyLineItem.Purchase_Order_PO_Number__c, resReqAfter.PSA_OM_PO_Number__c,'Expected PO Number to be equal to Purchase Order PO Number');
      
    }
    @isTest
    public static void syncPONumbersTest2(){
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        pse__Milestone__c milestoneRecBefore = [Select Id,PSA_OM_PO_Number__c from pse__Milestone__c where pse__Project__c=:projRec.Id Limit 1];
        pse__Resource_Request__c resReqBefore = [Select Id,PSA_OM_PO_Number__c from pse__Resource_Request__c where pse__Project__c=:projRec.Id Limit 1];
        
        resReqBefore.PSA_Opportunity_Product__c=null;
        update resReqBefore;
        
        milestoneRecBefore.PSA_Opportunity_Product__c =null;
        update milestoneRecBefore;
        
        User userRec = [SELECT Id FROM User WHERE profile.name = 'IPS Profile' AND isActive = true AND UserRole.DeveloperName = 'PS_Operations' LIMIT 1];
        
        String message;
        system.runAs(userRec){
             message = PSA_Sync_PO_Number_Controller.syncPONumbers(projRec.Id);
        }
        
        Test.stopTest();
        String expectedMsg = 'Info:There are no Resource Requests/Milestones associated with an Opportunity product under this Project.';
        Assert.areEqual(expectedMsg,message,'Expected same validation message');
      
    }
    @isTest
    public static void syncPONumbersTest3(){
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        
        User userRec = [SELECT Id FROM User WHERE profile.name = 'IPS Profile' AND isActive = true AND UserRole.DeveloperName = 'PS_Regional_Manager' LIMIT 1];
        String message;
        system.runAs(userRec){
             message = PSA_Sync_PO_Number_Controller.syncPONumbers(projRec.Id);
        }
        
        Test.stopTest();
        String expectedMsg = 'Info:You do not have the ability to sync PO Numbers to Resource Requests/Milestones.';
        Assert.areEqual(expectedMsg,message,'Expected same validation message');
      
    }
}