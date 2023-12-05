/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : This Test class provides code coverages to the trigger PSA_MilestoneTrigger 
and its handler and helper classes.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
Pavithra        11/24/2021                       Update the Date of First Value on project when    PSA-1863         T01
												the related milestone has Actual date populated                                                  
*/
@isTest
public class PSA_MilestoneTriggerTest {
	private static List<Schema.SObjectType> MY_SOBJECTS =
        new Schema.SObjectType[] {
            pse__Region__c.SObjectType,
            pse__Work_Calendar__c.SObjectType,
            Contact.SObjectType,
            Product2.SObjectType,
            pricebookEntry.SObjectType,
			Opportunity.SObjectType,
			OpportunityLineItem.SObjectType,
			pse__Permission_Control__c.SObjectType,
            pse__Proj__c.SObjectType,
            pse__Milestone__c.SObjectType };
    @testSetup
    static void initializeData(){
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        SBQQ.TriggerControl.disable();
        
        Global_Config__c globalSettings = Global_Config__c.getOrgDefaults();
        globalSettings.Mute_Triggers__c = true;
        upsert globalSettings Global_Config__c.Id;
        
        // Turn on the Milestone Trigger via Custom Settings.
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.PSA_MilestoneTrigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        insert trigSetting;
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        // Create Account
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<1;i++){
            Account acc = new Account();
            acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            accList.add(acc);
            
        }
        insert accList;   
        
        // Create user/Resource 
        
        Profile prof = [select Name from Profile where Name = 'IPS Profile'];
        
        List<User> userList = new List<User>();
        for(integer i=0;i<2;i++){
            userList.add(new User(alias='testRes'+i,
                                  username='testResource'+i+'@abc123.com',
                                  lastname='User '+i,
                                  firstname='Test Resource',
                                  email='testResource'+i+'@abc123.com',
                                  timezonesidkey='America/New_York',
                                  LocaleSidKey='en_US',
                                  ProfileId=prof.Id,
                                  LanguageLocaleKey='en_US',
                                  EmailEncodingKey='UTF-8'));
        }
        
        insert userList;
        
        // Create Region
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
        
        //List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<1;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            regionRec.psa_pm_Allow_Customer_Project__c = true;
            uow.registerNew(regionRec);
            //regionList.add(regionRec);
        //}
        //insert regionList;
        
        // Create work calendar 
        pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
        defaultWorkCalendar.pse__Sunday_Hours__c= 8;
        defaultWorkCalendar.pse__Monday_Hours__c=8;
        defaultWorkCalendar.pse__Tuesday_Hours__c=8;
        defaultWorkCalendar.pse__Wednesday_Hours__c=8;
        defaultWorkCalendar.pse__Thursday_Hours__c=8;
        defaultWorkCalendar.pse__Friday_Hours__c=8;
        defaultWorkCalendar.pse__Saturday_Hours__c=8;   
        uow.registerNew(defaultWorkCalendar);
        //insert defaultWorkCalendar; 
        // Create Contact
        
        //List<Contact> conList = new List<Contact>();
        //for(integer i =0;i<1;i++){
            Contact con = new Contact();
            //con.AccountId = accList[i].Id;
            con.LastName ='Contact '+i;
            con.FirstName = 'Test';
            con.Email='test'+i+'email@gmail.com';
            con.pse__Is_Resource__c =true;
            con.pse__Is_Resource_Active__c=true;
            con.CurrencyIsoCode='USD';
            con.pse__Resource_Role__c='Regional Manager';
            //con.pse__Region__c = regionList[i].Id;
            con.pse__Default_Cost_Rate__c = 10;
            con.pse__Salesforce_User__c = userList[i].Id;
            //con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            uow.registerRelationship(con, Contact.pse__Region__c, regionRec);
            uow.registerRelationship(con, Contact.pse__Work_Calendar__c, defaultWorkCalendar);
            uow.registerNew(con,Contact.AccountId,accList[0]);
            //conList.add(con);
            
        //}
        //insert conList;
        
        // Create Product
        //List<Product2> prodList = new List<Product2>();
        //for(integer i=0;i<1;i++){
            Product2 prodRec = new Product2();
            prodRec.Name = 'Test Product '+i;
            prodRec.Offering_Type__c='Professional Services';
            uow.registerNew(prodRec);
            //prodList.add(prodRec);
        //}
        //insert prodList;
        
        // Get the Standard price book Id and create active pricebook.
            
            Id pricebookId = Test.getStandardPricebookId();            
            Pricebook2 priceBookRec = new Pricebook2(Id = pricebookId, IsActive = True);
            
            update priceBookRec;
			
           Pricebook_Assignment_Mapping__mdt pam = [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, 
                                                        Currency_ISO_Code__c 
                                                    FROM Pricebook_Assignment_Mapping__mdt
                                                    WHERE Pricebook_Name__c = 'Rest Asia Price Book' LIMIT 1];
            
            system.debug('@@@priceBookRec 1:'+priceBookRec.Id);
            
        // Create Pricebook Entry
        //List<pricebookEntry> priceBookEntryList = new List<pricebookEntry>();
        //for(integer i=0;i<1;i++){
            pricebookEntry pbEntry = new pricebookEntry();
            //pbEntry.Pricebook2Id = priceBookRec.Id;
            //pbEntry.Product2Id = prodList[i].Id;
            pbEntry.UnitPrice=100;
            pbEntry.CurrencyIsoCode='USD';
            pbEntry.IsActive=true;
            uow.registerRelationship(pbEntry,pricebookEntry.Pricebook2Id,priceBookRec);
            uow.registerNew(pbEntry,pricebookEntry.Product2Id,prodRec);
            system.debug('@@@priceBookRec 2:'+priceBookRec.Id);
            //priceBookEntryList.add(pbEntry);
        //}
        //insert priceBookEntryList; 
        
        // Create Opportuntiy
        
        //List<Opportunity> opptyList = new List<Opportunity>(); 
        //for(integer i=0;i<1;i++){
            Opportunity oppty = new Opportunity();
            oppty.RecordTypeId = opptyRecType;
            oppty.Name = 'Test opportunity '+i;
            //oppty.AccountId = accList[i].Id;
            oppty.CurrencyIsoCode='USD';
            oppty.Type='Direct';
            oppty.CloseDate =  currentDate.addDays(2);
            oppty.StageName='Identity';
            oppty.psa_om_Start_Date__c = currentDate;
            oppty.psa_om_End_Date__c = currentDate.addDays(10);
            oppty.PSA_OM_Project_Type__c = 'JumpStart';
            oppty.psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM';
            oppty.Sales_Play__c='Data Quality';
            uow.registerRelationship(oppty, Opportunity.Pricebook2Id, priceBookRec);            
            uow.registerNew(oppty, Opportunity.AccountId, accList[0]);
            system.debug('@@@priceBookRec 3:'+priceBookRec.Id);
            //opptyList.add(oppty);
            
        //}        
        
        //insert opptyList; 
        
        //opptyList[0].Pricebook2Id = priceBookEntryList[0].Pricebook2Id;
        //update  opptyList;
        
        // Create OpportunityLineItem 
        //List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>();
        //for(integer i=0;i<1;i++){
        /*
            OpportunityLineItem opptyLineItem = new OpportunityLineItem();
            //opptyLineItem.pricebookentryid = priceBookEntryList[i].Id;
            opptyLineItem.TotalPrice = 2000;
            opptyLineItem.Quantity =2;
            opptyLineItem.Purchase_Order_PO_Number__c='12345';
            //opptyLineItem.OpportunityId = opptyList[i].Id;
            //uow.registerRelationship(opptyLineItem,OpportunityLineItem.pricebookentryid,pbEntry);            
            uow.registerNew(opptyLineItem,OpportunityLineItem.OpportunityId,oppty);
            system.debug('@@@priceBookRec 4:'+pbEntry.PriceBook2Id);
            //opptyLineItemList.add(opptyLineItem);
        //}
        //insert opptyLineItemList;
        //Create Permission Control
        //List<pse__Permission_Control__c> permControlLst = new List<pse__Permission_Control__c>();
        */
        //for(integer i=0;i<1;i++){
            pse__Permission_Control__c permControl = new pse__Permission_Control__c();
            permControl.pse__User__c = userObj.Id;
            permControl.pse__Staffing__c = true;
            permControl.pse__Resource_Request_Entry__c=true;
            permControl.pse__Timecard_Ops_Edit__c = true;
            permControl.pse__Cascading_Permission__c = true;
            permControl.pse__Timecard_Entry__c = true;
            //permControl.pse__Region__c = regionList[i].Id;
            uow.registerNew(permControl,pse__Permission_Control__c.pse__Region__c,regionRec);
            //permControlLst.add(permControl);
        //}
        //insert permControlLst;
        //}
        system.runAs(userObj){            
            //List<pse__Proj__c> projList = new List<pse__Proj__c>();
            //for(integer i=0;i<1;i++){
                pse__Proj__c projRec = new pse__Proj__c();
                projRec.Name = 'Test Project '+i;
                projRec.pse__Stage__c='Completed';
                //projRec.pse__Project_Manager__c = con.Id;
                projRec.pse__Project_Type__c = 'Customer Project';
                projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
                //projRec.pse__Opportunity__c = oppty.Id;
                //projRec.pse__Account__c = accList[0].Id;  
                projRec.CurrencyIsoCode='USD';
                //projRec.pse__Region__c = regionRec.Id;
                projRec.pse__Start_Date__c=currentDate.addDays(-6);
                projRec.pse__End_Date__c = currentDate.addDays(10);
                projRec.pse__Is_Active__c=true;
            	projRec.psa_Service_Units__c=1000;
                projRec.pse__Allow_Self_Staffing__c=true;
                projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
                projRec.psa_pm_Require_Product_On_Timecards__c =false;
                projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
                projRec.psa_pm_Require_Location_On_Timecards__c = false; 
                uow.registerRelationship(projRec,pse__Proj__c.pse__Account__c,accList[0]); 
                uow.registerRelationship(projRec,pse__Proj__c.pse__Region__c,regionRec); 
                uow.registerRelationship(projRec,pse__Proj__c.pse__Project_Manager__c,con);            
				uow.registerNew(projRec,pse__Proj__c.pse__Opportunity__c,oppty); 
                //projList.add(projRec);                
           // }
            //insert projList;
             // Create a milestone record
            //List<pse__Milestone__c> milestoneList = new List<pse__Milestone__c>();
            //for(integer i=0;i<1;i++){
                pse__Milestone__c milestoneRec = new pse__Milestone__c();
                milestoneRec.Name = 'FTV - Test Milestone '+i;
                milestoneRec.psa_pm_Record_Type__c ='Billing';
                //milestoneRec.pse__Project__c=projList[i].Id;
                milestoneRec.pse__Milestone_Amount__c=10;
                milestoneRec.pse__Target_Date__c = currentDate.addDays(10);
                //milestoneRec.PSA_Opportunity_Product__c = opptyLineItemList[i].Id;
                //milestoneList.add(milestoneRec);
            	//uow.registerRelationship(milestoneRec,pse__Milestone__c.PSA_Opportunity_Product__c,opptyLineItem);
                uow.registerNew(milestoneRec,pse__Milestone__c.pse__Project__c,projRec);
            }    
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
           	//insert milestoneList;            
        }
            
    }
    @isTest
    Static void populateFieldsOnInsertTest(){        
        Test.startTest();        
        pse__Milestone__c milestoneRec = [Select Id,Name,pse__Admin_Global_Edit__c from pse__Milestone__c WHERE Name LIKE 'FTV%' LIMIT 1];
        milestoneRec.pse__Actual_Date__c = system.today(); //T01
        update milestoneRec;        
        Test.stopTest();
        system.assert(milestoneRec.pse__Admin_Global_Edit__c);
    }
     @isTest
    Static void ServiceUnitTest(){        
        Test.startTest();
        UnitOfWork unitOfWork = new UnitOfWork(MY_SOBJECTS);
        List<pse__Milestone__c> milestoneRecList = [Select Id FROM pse__Milestone__c WHERE Name LIKE 'FTV%' LIMIT 1];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 LIMIT 1];
        Opportunity oppty = [SELECT Id FROM Opportunity LIMIT 1];
        unitOfWork.registerDirty(oppty, Opportunity.Pricebook2Id, pb);
        milestoneRecList[0].pse__Include_In_Financials__c = TRUE;
        milestoneRecList[0].pse__Approved__c = TRUE;
        milestoneRecList[0].pse__Status__c = 'Approved';
        milestoneRecList[0].pse__Actual_Date__c = System.today();
        milestoneRecList[0].psa_Milestone_Service_Unit__c = 100;
        //update milestoneRec;
        unitOfWork.registerDirty(milestoneRecList);
        unitOfWork.commitWork();
        unitOfWork.registerDeleted(new List<SObject> { milestoneRecList[0] });
        unitOfWork.commitWork();
        Test.stopTest();
    }        
}