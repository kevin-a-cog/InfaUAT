/*
@created by       : RANJAN KISHORE
@created on       : 04/05/2021
@Purpose          : This test class provides code coverage to the Trigger "psa_ProjectTrigger"
and its handler and helper Classes.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public class PSA_ProjectTriggerTest {
    
    @testSetup
    static void initializeData(){
        
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
        // Turn on the Project Trigger via Custom Settings.
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.psa_ProjectTrigger__c = true;
        trigSetting.SetupOwnerId = UserInfo.getUserId();
        insert trigSetting;
        
        
            Global_Config__c settings = Global_Config__c.getOrgDefaults();
            settings.Mute_Triggers__c = true;
            upsert settings Global_Config__c.Id;
        
        // Create Account
        List<Account> accList = new List<Account>(); 
        for(integer i=0;i<2;i++){
            Account acc = new Account();
            acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account '+i;
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            acc.Peoplesoft_External_ID__c='1234'+i;
            accList.add(acc);
            
        }
        insert accList;   
        
        // Create Region
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<2;i++){
            pse__Region__c regionRec = new pse__Region__c();
            regionRec.Name = 'Test Region '+i;
            regionRec.pse__Action_Update_Current_Time_Period__c = false;
            //regionRec.psa_pm_Territory_ID_Mapping__c = '1234'+i;
            regionRec.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec);
        }
        insert regionList;
        
        // Create user/Resource 
        
        Profile prof = [Select Name from Profile where Name = 'IPS Profile'];
        
        
        List<User> userList = new List<User>();
        for(integer i=0;i<3;i++){
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
        String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
        List<Contact> conList = new List<Contact>();
        for(integer i =0;i<2;i++){
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
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.Peoplesoft_External_ID__c='1234'+i;
            con.MailingCountry='India';
            con.pse__Salesforce_User__c = userList[i].Id;
            conList.add(con);
        }
        insert conList;
        
        
        // Create Legal Entity Record
        List<blng__LegalEntity__c> legalEntityList = new List<blng__LegalEntity__c>();
        
        for(integer i=0;i<2;i++){
            blng__LegalEntity__c legalEntityRec = new blng__LegalEntity__c();
            legalEntityRec.Name='Informatica LLC';
            legalEntityRec.Legal_Entity_Code__c='USA';
            legalEntityRec.CurrencyIsoCode='USD';
            legalEntityRec.blng__Active__c=true;
            legalEntityRec.blng__City__c='Redwood City';
            legalEntityRec.blng__Country__c='US';
            legalEntityRec.blng__State__c='CA';
            legalEntityRec.blng__Street1__c='2100 Seaport Boulevard';
            legalEntityRec.blng__ZipPostalCode__c='94063';
            legalEntityList.add(legalEntityRec);
        }
        legalEntityList[0].Business_Unit_Code__c = 'US001';
        legalEntityList[1].Business_Unit_Code__c = 'US007';
        
        insert legalEntityList;
        
        // Create Business units
        List<psa_pm_Business_Unit__c> busUnitList = new List<psa_pm_Business_Unit__c>();
        for(Integer i=0;i<2;i++){
            psa_pm_Business_Unit__c busUnitRec = new psa_pm_Business_Unit__c();
            busUnitRec.CurrencyIsoCode='USD';
            busUnitRec.psa_pm_Region__c=regionList[i].Id;
            busUnitRec.psa_pm_Work_Calendar__c=defaultWorkCalendar.Id;
            busUnitList.add(busUnitRec);
        }
        busUnitList[0].Name='US001';
        busUnitList[1].Name='US007';
        insert busUnitList;
        
        // Create Product
        List<Product2> prodList = new List<Product2>();
        for(integer i=0;i<6;i++){
            Product2 prodRec = new Product2();
            prodRec.Name = 'Test Product '+i;
            prodRec.Forecast_Product__c ='Professional Services';
            prodRec.Offering_Type__c='Professional Services';
            
            prodList.add(prodRec);
        }
        prodList[3].Forecast_Product__c ='Cloud B2B';
        prodList[3].Offering_Type__c ='Cloud Hosted Subscription';
        prodList[4].Forecast_Product__c ='Cloud B2B';
        prodList[4].Offering_Type__c ='Cloud Hosted Subscription';
        prodList[5].Forecast_Product__c ='Cloud B2B';
        prodList[5].Offering_Type__c ='Cloud Hosted Subscription';
        
        insert prodList;
        
        // Get the Standard price book Id and create active pricebook.
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 priceBookRec = new Pricebook2();
        priceBookRec.Id = pricebookId;
        priceBookRec.IsActive = True;
        
        update priceBookRec;
        
        // Create Pricebook Entry
        List<pricebookEntry> priceBookEntryList = new List<pricebookEntry>();
        for(integer i=0;i<6;i++){
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
        for(integer i=0;i<2;i++){
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
            oppty.Sales_Journey__c ='Data Governance and Privacy';
            opptyList.add(oppty);
            
        }
        
        insert opptyList; 
        
        opptyList[0].Pricebook2Id = priceBookRec.Id;
        opptyList[1].Pricebook2Id = priceBookRec.Id;
        update  opptyList;
        
        // Create OpportunityTeamMember
        List<OpportunityTeamMember> opptyTeamMemberList = new List<OpportunityTeamMember>();
        for(integer i=0;i<2;i++){
            OpportunityTeamMember opptyTeamMem = new OpportunityTeamMember();
            opptyTeamMem.UserId=userList[i].Id;
            opptyTeamMem.TeamMemberRole ='IPS Sales';
            opptyTeamMem.OpportunityId=opptyList[i].Id;
            opptyTeamMemberList.add(opptyTeamMem);
        }
        insert opptyTeamMemberList;
        
        // Create OpportunityLineItem 
        List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>();
        for(integer i=0;i<6;i++){
            OpportunityLineItem opptyLineItem = new OpportunityLineItem();
            opptyLineItem.pricebookentryid = priceBookEntryList[i].Id;
            opptyLineItem.Quantity =1;
            opptyLineItem.UnitPrice = 2000;
            if(i<3){
                opptyLineItem.OpportunityId = opptyList[0].Id;  
            }else{
                opptyLineItem.OpportunityId = opptyList[1].Id;   
            }
            
            opptyLineItemList.add(opptyLineItem);
        }
        
        insert opptyLineItemList;
        
        // Create Quotes
        
        Test.startTest();
        
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(integer i=0;i<2;i++){
            SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
            quoteRec.SBQQ__Opportunity2__c = opptyList[i].Id;
            quoteRec.Legal_Entity__c = legalEntityList[i].Id;
            quoteRec.SBQQ__Primary__c = true;
            quoteRec.ApprovalStatus__c ='Recalled';
            quoteRec.PSA_OM_Planned_Margin__c ='Sample planned margin '+i;
            quoteRec.SBQQ__PaymentTerms__c='Net 30';
            quoteRec.SBQQ__Type__c ='Quote';
            
            // Billing Details
            quoteRec.BillToAccount__c =accList[i].Id;
            quoteRec.BillToContact__c=conList[i].Id;
            quoteRec.SBQQ__BillingName__c ='Sample Billing Name '+i;
            quoteRec.SBQQ__BillingStreet__c='INFORMATICA BUSINESS SOLUTIONS  BAGAMANE TECH PARK CV RAMAN NAGAR';
            quoteRec.SBQQ__BillingCity__c = 'BANGALORE';
            quoteRec.SBQQ__BillingState__c='Karnataka';
            quoteRec.SBQQ__BillingCountry__c = 'United States';
            quoteRec.SBQQ__BillingPostalCode__c ='4567890';
            quoteRec.BillingName_PSFTID__c ='Sample ERP Bill To Name Id '+i;
            quoteRec.BillingAddress_PSFTID__c ='Sample ERP Billing Site Id '+i;
            // Shipping details
            quoteRec.ShiptToAccount__c=accList[i].Id;
            quoteRec.ShipToContact__c=conList[i].Id;
            quoteRec.SBQQ__ShippingName__c ='Sample Ship to Name '+i;
            quoteRec.SBQQ__ShippingStreet__c ='INFORMATICA BUSINESS SOLUTIONS  BAGAMANE TECH PARK CV RAMAN NAGAR';
            quoteRec.SBQQ__ShippingCity__c ='BANGALORE';
            quoteRec.SBQQ__ShippingState__c ='Karnataka';
            quoteRec.SBQQ__ShippingCountry__c ='SINGAPORE';
            quoteRec.SBQQ__ShippingPostalCode__c ='4567890';
            quoteRec.ShippingName_PSFTID__c ='Sample ERP Ship To Name Id '+i;
            quoteRec.ShippingAddress_PSFTID__c ='Sample ERP Shipping Site Id '+i;
            
            quoteList.add(quoteRec);
        }
        system.debug('quote acc'+quoteList[0].BillToAccount__c);
        system.debug('quote acc'+quoteList[1].BillToAccount__c);
        system.debug('quote acc'+quoteList[0].ShiptToAccount__c);
        system.debug('quote acc'+quoteList[1].ShiptToAccount__c);
        insert quoteList;
        
            Global_Config__c settings1 = Global_Config__c.getOrgDefaults();
            settings1.Mute_Triggers__c = false;
            upsert settings1 Global_Config__c.Id;
            
            
        //Create Permission Control
        List<pse__Permission_Control__c> permControlLst = new List<pse__Permission_Control__c>();
        for(integer i=0;i<2;i++){
            pse__Permission_Control__c permControl = new pse__Permission_Control__c();
            //permControl.pse__Project__c = projList[i].Id;
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
        
        // Create solution type
        List<psa_pm_Solution_Type__c> solnTypeList = new List<psa_pm_Solution_Type__c>();
        for(integer i=0;i<2;i++){
            psa_pm_Solution_Type__c solnRec = new psa_pm_Solution_Type__c();
            solnRec.Opportunity__c = opptyList[0].Id;
            solnRec.PSA_PM_Product_Split__c = 20;
            solnRec.PSA_PM_Product_Family__c = 'MDM';
            solnRec.PSA_PM_Forecast_Family__c ='On-Premise Perpetual';
            solnRec.PSA_PM_Pricing_Business_Model__c ='Perpetual';
            solnRec.PSA_PM_Processing_Engine__c='Big Data DB';
            solnRec.PSA_PM_Delivery_Method__c ='Hosted Other';
            solnTypeList.add(solnRec);
            
        }
        insert solnTypeList;
        
        // Create Project
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        for(integer i=0;i<2;i++){
            pse__Proj__c projRec = new pse__Proj__c();
            projRec.Name = 'Test Project '+i;
            projRec.pse__Project_Manager__c = conList[i].Id;
            //projRec.pse__Project_Type__c = 'Customer Project';
            //projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
            projRec.pse__Opportunity__c = opptyList[i].Id;
            projRec.pse__Account__c = accList[i].Id;  
            projRec.CurrencyIsoCode='USD';
            projRec.pse__Region__c = regionList[i].Id;
            projRec.pse__Start_Date__c=currentDate.addDays(-6);
            projRec.pse__End_Date__c = currentDate.addDays(10);
            projRec.pse__Is_Active__c=false;
            projRec.pse__Billings__c=10;
            projRec.pse__Bookings__c=100;
            projRec.pse__Allow_Self_Staffing__c=true;
            projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
            projRec.psa_pm_Require_Product_On_Timecards__c =false;
            projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
            projRec.psa_pm_Require_Location_On_Timecards__c = false;
            
            projList.add(projRec);
            
        }
        projList[0].pse__Is_Billable__c = true;
       // projList[0].psa_pm_Portfolio_Manager__c = conList[1].Id;
        //projList[1].psa_pm_Portfolio_Manager__c = conList[0].Id;
        
        insert projList;
        
        Test.stopTest();
        
        
        // create PSA MSA Code Mapping
        List<PSA_MSA_Code_Mapping__c> psaMSACodeMappingList = new List<PSA_MSA_Code_Mapping__c>();
        for(integer i=0;i<2;i++){
            PSA_MSA_Code_Mapping__c psaMSACodeMapping = new PSA_MSA_Code_Mapping__c();
            psaMSACodeMapping.Name = 'Test MSA Code Map '+i;
            psaMSACodeMappingList.add(psaMSACodeMapping);
        }
        insert psaMSACodeMappingList;
        
        List<pse__Project_Location__c> projLocList = new List<pse__Project_Location__c>();
        for(integer i=0;i<2;i++){
            pse__Project_Location__c projLoc = new pse__Project_Location__c();
            projLoc.pse__Project__c = projList[i].Id;
            projLoc.psa_pm_Primary__c =true;
            projLoc.psa_pm_MSA_Code_Mapping__c = psaMSACodeMappingList[i].Id;
            projLocList.add(projLoc);
        }
        insert projLocList;
        
        // Create Resource Request with project and opportunity
        List<pse__Resource_Request__c> resourceReqList = new List<pse__Resource_Request__c>();
        for(integer i=0;i<2;i++){
            pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
            resourceReq.pse__Start_Date__c = currentDate.addDays(1);
            resourceReq.pse__End_Date__c = currentDate.addDays(10);
            resourceReq.pse__SOW_Hours__c =8;
            resourceReq.pse__Resource_Role__c = 'Consultant';
            resourceReq.CurrencyIsoCode='USD';
            resourceReq.pse__Opportunity__c = opptyList[i].Id;
            resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMappingList[i].Id;
            resourceReq.pse__Region__c = regionList[i].Id;
            resourceReq.psa_rm_Original_Opportunity__c = opptyList[i].Id;
            resourceReq.PSA_OM_Opportunity_Product_Id__c =  opptyLineItemList[i].Id;
            //resourceReq.pse__Staffer_Resource__c = conList[i].Id;
            resourceReq.pse__Status__c = 'Draft';
            resourceReq.pse__Project__c = projList[i].Id;
            resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
            resourceReq.psa_rm_Billable__c = true;
            resourceReqList.add(resourceReq);
        }
        //resourceReqList[0].pse__Project__c = null;
        resourceReqList[0].pse__Resource_Role__c = 'Associate Consultant';
        insert resourceReqList;  
        
        
    }
    @isTest
    static void runValidationsOnInsertTest(){
        
        Test.startTest();
        Opportunity opptyRec = [Select Id,AccountId from Opportunity Limit 1];
        Contact conRec = [Select Id,pse__Region__c,AccountId from Contact where AccountId=:opptyRec.AccountId];
        Date currentDate = Date.today();
        pse__Proj__c projRec = new pse__Proj__c();
        projRec.Name = 'Test Project';
        projRec.pse__Project_Manager__c = conRec.Id;
        //projRec.pse__Project_Type__c = 'Customer Project';
        projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
        projRec.pse__Opportunity__c = opptyRec.Id;
        projRec.pse__Account__c = conRec.AccountId;  
        projRec.CurrencyIsoCode='USD';
        projRec.pse__Region__c = conRec.pse__Region__c;
        projRec.pse__Start_Date__c=currentDate.addDays(-6);
        projRec.pse__End_Date__c = currentDate.addDays(10);
        projRec.pse__Is_Active__c=false;
        projRec.pse__Allow_Self_Staffing__c=true;
        projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
        projRec.psa_pm_Require_Product_On_Timecards__c =false;
        projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
        projRec.psa_pm_Require_Location_On_Timecards__c = false;
        try{
            Insert projRec;
            Test.stopTest();
        }catch(Exception ex){
            String errorMsg ='A project is already associated with this Opportunity';
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
        }
        
    }
    @isTest
    static void runValidationsOnUpdateTest1(){
        Test.startTest();
        
        Opportunity opptyRec = [Select Id from Opportunity Limit 1];
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from pse__Proj__c where pse__Opportunity__c !=:opptyRec.Id Limit 1];
        projRec.pse__Opportunity__c = opptyRec.Id;
        try{
            
            update projRec;
            Test.stopTest();
        }catch(Exception ex){
            String errorMsg ='A project is already associated with this Opportunity';
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            //System.assertEquals(true,expectedExceptionThrown);
        }
    }
    
    @isTest
    static void runValidationsOnUpdateTest2(){
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,Name from pse__Proj__c Limit 1];
        projRec.Name='Updating the Name';
        
        try{
            update projRec;
            Test.stopTest();
        }catch(Exception ex){
            String errorMsg ='You can not edit Project Name';
            system.debug('value of ex'+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
            
        }
        
    }
    @isTest
    static void runValidationsOnUpdateTest3(){
        Test.startTest();
        User usrRec = [Select Id from User Limit 1];
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,psa_pm_Journey__c from pse__Proj__c
                                where pse__Project_Manager__r.pse__Salesforce_User__c!=:usrRec.Id Limit 1];
        
        projRec.psa_pm_Journey__c='Customer 360';
        
        try{
            system.runAs(usrRec){
                update projRec; 
            }
            
            Test.stopTest();
        }catch(Exception ex){
            String errorMsg ='Journey can not be changed by current user. Opportunity Owner or a member of the Operations team can assist.';
            system.debug('value of ex'+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
            
        }
        
    }
    @isTest
    static void runValidationsOnUpdateTest4(){
        Test.startTest();
        User usrRec = [Select Id from User Limit 1];
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,psa_pm_Project_Category__c from pse__Proj__c
                                where pse__Project_Manager__r.pse__Salesforce_User__c!=:usrRec.Id Limit 1];
        
        projRec.psa_pm_Project_Category__c='Billable';
        
        try{
            update projRec;
            Test.stopTest();
        }catch(Exception ex){
            String errorMsg ='Project Category cannot be changed by current user. Portfolio Manager, Opportunity Owner and Project Manager can change the Category.Operations team can also assist.';
            system.debug('value of ex'+ex.getMessage());
            Boolean expectedExceptionThrown =  ex.getMessage().contains(errorMsg) ? true : false;
            System.assertEquals(true,expectedExceptionThrown);
            
        }
        
    }
    @isTest
    static void defaultProjectFieldValOnInsertTest(){
        Test.startTest();       
        SBQQ__Quote__c quoteRec = [SELECT Id,ShipToContact__r.Peoplesoft_External_ID__c,BillToContact__r.Peoplesoft_External_ID__c,
                                   BillToAccount__r.Peoplesoft_External_ID__c,ShiptToAccount__r.Peoplesoft_External_ID__c,Name,
                                   SBQQ__Opportunity2__c,SBQQ__Primary__c,ShiptToAccount__c,ShipToContact__c,SBQQ__ShippingStreet__c,
                                   ShippingAddress_PSFTID__c,Shipping_Email__c,ShippingName_PSFTID__c,SBQQ__ShippingPostalCode__c,
                                   SBQQ__ShippingName__c,SBQQ__ShippingCity__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,
                                   Bill_to_Email__c,Bill_to_Phone__c,BillToAccount__c,BillToContact__c,SBQQ__BillingStreet__c,
                                   BillingName_PSFTID__c,SBQQ__BillingPostalCode__c,SBQQ__BillingName__c,SBQQ__BillingCity__c,
                                   SBQQ__BillingCountry__c,SBQQ__BillingState__c,BillingAddress_PSFTID__c,PSA_OM_Planned_Margin__c,
                                   PSA_OM_Customer_Signoff__c,PSA_OM_Budget_Hours__c,Business_Unit__c,SBQQ__PaymentTerms__c
                                   FROM SBQQ__Quote__c WHERE  SBQQ__Primary__c = true Limit 1];
        
        
        
        pse__Proj__c projRec = [Select Id ,pse__Opportunity__c,PSA_OM_Planned_Margin__c,PSA_OM_Customer_Signoff__c,PSA_OM_Budget_Hours__c,
                                psa_pm_Payment_Terms__c,    PSA_Primary_Quote__c,PSA_ERP_Bill_To_Customer_Id__c,
                                PSA_ERP_Bill_To_Contact_Id__c,PSA_ERP_Ship_To_Customer_Id__c,PSA_ERP_Ship_To_Contact_Id__c,
                                PSA_OM_Bill_to_Account__c,PSA_OM_Bill_To_Contact__c,PSA_OM_Bill_To_Name__c, 
                                PSA_OM_Bill_To_Street__c,PSA_OM_Bill_To_City__c,PSA_OM_Bill_To_State__c,
                                PSA_OM_Bill_To_Country__c,PSA_OM_Bill_To_Postal_Code__c,    PSA_OM_ERP_Bill_to_Name_ID__c,
                                PSA_OM_ERP_Billing_Site_ID__c,PSA_OM_Billing_Email__c,PSA_OM_Ship_to_Account__c,
                                PSA_OM_Ship_to_Contact__c,PSA_OM_Ship_To_Name__c,PSA_OM_Shipping_Email__c,
                                PSA_OM_Ship_To_Street__c,PSA_OM_Ship_To_City__c,PSA_OM_Ship_To_State__c,
                                PSA_OM_Ship_To_Country__c,PSA_OM_Ship_To_Postal_Code__c,PSA_OM_ERP_Ship_to_Name_ID__c,
                                PSA_OM_ERP_Shipping_Site_ID__c from pse__Proj__c where pse__Opportunity__c=:quoteRec.SBQQ__Opportunity2__c  limit 1];
        Test.stopTest();
        system.assertEquals(quoteRec.PSA_OM_Planned_Margin__c,projRec.PSA_OM_Planned_Margin__c );
        system.assertEquals(quoteRec.PSA_OM_Customer_Signoff__c,projRec.PSA_OM_Customer_Signoff__c );
        system.assertEquals(quoteRec.PSA_OM_Budget_Hours__c,projRec.PSA_OM_Budget_Hours__c );
        system.assertEquals(quoteRec.SBQQ__PaymentTerms__c,projRec.psa_pm_Payment_Terms__c );
        system.assertEquals(quoteRec.Id,projRec.PSA_Primary_Quote__c );
        system.assertEquals(quoteRec.BillToAccount__r.Peoplesoft_External_ID__c,projRec.PSA_ERP_Bill_To_Customer_Id__c );
        system.assertEquals(quoteRec.BillToContact__r.Peoplesoft_External_ID__c,projRec.PSA_ERP_Bill_To_Contact_Id__c );
        system.assertEquals(quoteRec.ShiptToAccount__r.Peoplesoft_External_ID__c,projRec.PSA_ERP_Ship_To_Customer_Id__c );
        system.assertEquals(quoteRec.ShipToContact__r.Peoplesoft_External_ID__c,projRec.PSA_ERP_Ship_To_Contact_Id__c );
        system.assertEquals(quoteRec.BillToAccount__c,projRec.PSA_OM_Bill_to_Account__c );
        system.assertEquals(quoteRec.BillToContact__c,projRec.PSA_OM_Bill_To_Contact__c );
        system.assertEquals(quoteRec.SBQQ__BillingName__c,projRec.PSA_OM_Bill_To_Name__c );
        system.assertEquals(quoteRec.SBQQ__BillingStreet__c,projRec.PSA_OM_Bill_To_Street__c );
        system.assertEquals(quoteRec.SBQQ__BillingCity__c,projRec.PSA_OM_Bill_To_City__c );
        system.assertEquals(quoteRec.SBQQ__BillingState__c,projRec.PSA_OM_Bill_To_State__c );
        system.assertEquals(quoteRec.SBQQ__BillingCountry__c,projRec.PSA_OM_Bill_To_Country__c );
        system.assertEquals(quoteRec.SBQQ__BillingPostalCode__c,projRec.PSA_OM_Bill_To_Postal_Code__c );
        system.assertEquals(quoteRec.BillingName_PSFTID__c,projRec.PSA_OM_ERP_Bill_to_Name_ID__c );
        system.assertEquals(quoteRec.BillingAddress_PSFTID__c,projRec.PSA_OM_ERP_Billing_Site_ID__c );
        system.assertEquals(quoteRec.Bill_to_Email__c,projRec.PSA_OM_Billing_Email__c );
        system.assertEquals(quoteRec.ShiptToAccount__c,projRec.PSA_OM_Ship_to_Account__c );
        system.assertEquals(quoteRec.ShipToContact__c,projRec.PSA_OM_Ship_to_Contact__c );
        system.assertEquals(quoteRec.SBQQ__ShippingName__c,projRec.PSA_OM_Ship_To_Name__c );
        system.assertEquals(quoteRec.Shipping_Email__c,projRec.PSA_OM_Shipping_Email__c );
        system.assertEquals(quoteRec.SBQQ__ShippingStreet__c,projRec.PSA_OM_Ship_To_Street__c );
        system.assertEquals(quoteRec.SBQQ__ShippingCity__c,projRec.PSA_OM_Ship_To_City__c );
        system.assertEquals(quoteRec.SBQQ__ShippingState__c,projRec.PSA_OM_Ship_To_State__c );
        system.assertEquals(quoteRec.SBQQ__ShippingCountry__c,projRec.PSA_OM_Ship_To_Country__c );
        system.assertEquals(quoteRec.SBQQ__ShippingPostalCode__c,projRec.PSA_OM_Ship_To_Postal_Code__c );
        system.assertEquals(quoteRec.ShippingName_PSFTID__c,projRec.PSA_OM_ERP_Ship_to_Name_ID__c );
        system.assertEquals(quoteRec.ShippingAddress_PSFTID__c,projRec.PSA_OM_ERP_Shipping_Site_ID__c );
        
    }
    @isTest
    static void defaultProjectFieldValOnInsertTest2(){
        
        Test.startTest();
        
        Opportunity opptyRec = [Select Id,psa_om_Start_Date__c,psa_om_End_Date__c,PSA_OM_Project_Type__c,
                                psa_om_IPS_Package__c,Sales_Journey__c from Opportunity Limit 1];
        
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,pse__Project_Manager__c,psa_pm_Portfolio_Manager__c,
                                pse__Is_Active__c,pse__Bookings__c,pse__Billings__c,pse__Project_Type__c,psa_om_Estimated_Begin_Date__c,
                                psa_om_Estimated_End_Date__c,psa_pm_Project_Sub_Type__c,PSA_OM_IPS_Package__c,psa_pm_Journey__c
                                from pse__Proj__c where pse__Opportunity__c=:opptyRec.Id];
        
        
        Test.stopTest();
        
        system.assertEquals(opptyRec.psa_om_Start_Date__c, projRec.psa_om_Estimated_Begin_Date__c);
        system.assertEquals(opptyRec.psa_om_End_Date__c, projRec.psa_om_Estimated_End_Date__c);
        system.assertEquals(opptyRec.PSA_OM_Project_Type__c, projRec.psa_pm_Project_Sub_Type__c);
        system.assertEquals(opptyRec.PSA_OM_IPS_Package__c, projRec.psa_om_IPS_Package__c);
        system.assertEquals(opptyRec.Sales_Journey__c, projRec.psa_pm_Journey__c);
        
    }
    @isTest
    static void defaultProjectFieldValOnUpdateTest(){
        Test.startTest();
        pse__Proj__c projRecBefore = [Select Id,pse__Is_Billable__c,pse__Project_Manager__c,pse__Project_Manager__r.pse__Salesforce_User__c,
                                      psa_pm_Previous_Project_Manager_User__c,pse__Exclude_From_Billing__c, pse__Billings__c,
                                      pse__Bookings__c, psa_pm_PercentComplete__c from pse__Proj__c
                                      where pse__Is_Billable__c=true Limit 1];
        
        Contact conRec = [Select Id,Name, pse__Salesforce_User__c from Contact where Id!=:projRecBefore.pse__Project_Manager__c limit 1];
        
        projRecBefore.pse__Is_Billable__c = false;
        projRecBefore.pse__Billings__c = 100;
        projRecBefore.pse__Project_Manager__c = conRec.Id;
        
        update projRecBefore;
        
        Test.stopTest();
        
        pse__Proj__c projRecAfter = [Select Id,pse__Is_Billable__c,pse__Project_Manager__c,pse__Project_Manager__r.pse__Salesforce_User__c,
                                     psa_pm_Previous_Project_Manager_User__c,pse__Exclude_From_Billing__c, pse__Billings__c, 
                                     pse__Bookings__c, psa_pm_PercentComplete__c from pse__Proj__c 
                                     where Id=:projRecBefore.Id Limit 1];
        
        
        system.assertEquals((projRecAfter.pse__Billings__c /projRecAfter.pse__Bookings__c),projRecAfter.psa_pm_PercentComplete__c);
        system.assertEquals(!projRecAfter.pse__Is_Billable__c,projRecAfter.pse__Exclude_From_Billing__c);
        system.assertEquals(projRecBefore.pse__Project_Manager__r.pse__Salesforce_User__c,projRecAfter.psa_pm_Previous_Project_Manager_User__c);
    }
    @isTest
    static void createBudgetRecsTest(){
        String budgetName;
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Start_Date__c,pse__Opportunity__r.AccountId,
                                pse__Opportunity__r.Name,pse__Opportunity__c,
                                pse__Opportunity__r.Professional_Services_Total__c 
                                from pse__Proj__c where pse__Is_Active__c = true Limit 1];
        
        pse__Budget__c  budgetRec = [Select Id,Name,pse__Account__c,pse__Project__c,pse__Opportunity__c,pse__Amount__c,
                                     pse__Type__c,pse__Status__c,pse__Approved__c,pse__Include_In_Financials__c,
                                     pse__Effective_Date__c from pse__Budget__c 
                                     where pse__Opportunity__c=:projRec.pse__Opportunity__c Limit 1];
        
        budgetName = projRec.pse__Opportunity__r.Name +' - '+'Budget';
        Test.stopTest();
        
        system.assertEquals(projRec.pse__Start_Date__c, budgetRec.pse__Effective_Date__c);
        system.assertEquals('Customer Purchase Order', budgetRec.pse__Type__c);
        system.assertEquals('Approved', budgetRec.pse__Status__c);
        system.assert(budgetRec.pse__Approved__c);
        system.assert(budgetRec.pse__Include_In_Financials__c);
        system.assertEquals(projRec.pse__Opportunity__r.Professional_Services_Total__c, budgetRec.pse__Amount__c);
        system.assertEquals(projRec.pse__Opportunity__c, budgetRec.pse__Opportunity__c);
        system.assertEquals(projRec.Id, budgetRec.pse__Project__c);
        system.assertEquals(projRec.pse__Opportunity__r.AccountId, budgetRec.pse__Account__c);
        system.assertEquals(budgetName, budgetRec.Name);
        
        
    }
    @isTest
    static void createProjShareRecsTest(){
        
        Test.startTest();
        pse__Proj__c projRec = [Select Id,pse__Project_Manager__r.pse__Salesforce_User__c
                                from pse__Proj__c where pse__Is_Active__c = true Limit 1];
        
        pse__Proj__Share projShareRec = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                         where ParentId=:projRec.Id and UserOrGroupId=:projRec.pse__Project_Manager__r.pse__Salesforce_User__c Limit 1];
        
        Test.stopTest();
        
        system.assertEquals(projRec.pse__Project_Manager__r.pse__Salesforce_User__c, projShareRec.UserOrGroupId);
        system.assertEquals('Edit', projShareRec.AccessLevel);
        
    }
    @isTest 
    Static void createProjectContactRecsTest(){
        
        Test.startTest();
        
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        
        OpportunityTeamMember opptyTeamMemberRec = [Select Id,OpportunityId,UserId from OpportunityTeamMember 
                                                    where OpportunityId=:projRec.pse__Opportunity__c ];
        
        Contact conRec=[Select Id,pse__Salesforce_User__c From Contact
                        Where pse__Salesforce_User__c =:opptyTeamMemberRec.UserId];
        
        psa_pm_Project_Contact__c projConRec = [Select Id,psa_pm_Project__c,psa_pm_Contact__c,psa_pm_Contact_Role__c
                                                from psa_pm_Project_Contact__c where psa_pm_Contact__c=:conRec.Id];
        
        Test.stopTest();
        
        system.assertEquals(projRec.Id, projConRec.psa_pm_Project__c);
        
    }
    @isTest
    static void checkForPMPermissionsOnUpdateTest1(){
        
        Test.startTest();
        String oldProjectManagerId;
        Contact conRec = [Select Id,pse__Salesforce_User__c from Contact Limit 1];
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c,pse__Project_Manager__r.pse__Salesforce_User__c from pse__Proj__c
                                where pse__Project_Manager__c!=:conRec.Id Limit 1];
        
        projRec.pse__Project_Manager__c = conRec.Id;
        projRec.psa_pm_Portfolio_Manager__c=null;
        oldProjectManagerId = projRec.pse__Project_Manager__r.pse__Salesforce_User__c;
        
        List<pse__Proj__Share> projShareRecBefore = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                     where UserOrGroupId=:oldProjectManagerId and ParentId=:projRec.Id];
        
        List<pse__Proj__Share> projShare = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share];
        system.debug('projShareRecBefore'+projShare);
        system.debug('projShareRecBefore'+projShareRecBefore);
        update projRec;
        
        List<pse__Proj__Share> oldProjShareRecAfter = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                       where UserOrGroupId=:oldProjectManagerId and ParentId=:projRec.Id];
        
        system.debug('oldProjShareRecAfter'+oldProjShareRecAfter);
        List<pse__Proj__Share> newProjShareRecAfter = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                       where UserOrGroupId=:conRec.pse__Salesforce_User__c and ParentId=:projRec.Id];
        system.debug('newProjShareRecAfter'+newProjShareRecAfter);
        
        system.assertEquals(1, projShareRecBefore.size());
        system.assertEquals(0, oldProjShareRecAfter.size());
        system.assertEquals(1, newProjShareRecAfter.size());
        
        
        Test.stopTest();
        
    }
    @isTest
    static void checkForPMPermissionsOnUpdateTest2(){
        
        Test.startTest();
        String oldPortfolioManagerId;
        Contact conRec = [Select Id,pse__Salesforce_User__c from Contact Limit 1];
        
        pse__Proj__c projRec = [Select Id,psa_pm_Portfolio_Manager__c,psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c,
                                pse__Opportunity__c,pse__Project_Manager__c,pse__Project_Manager__r.pse__Salesforce_User__c from pse__Proj__c
                                where pse__Project_Manager__c!=:conRec.Id Limit 1];
        oldPortfolioManagerId = projRec.psa_pm_Portfolio_Manager__r.pse__Salesforce_User__c;
        projRec.psa_pm_Portfolio_Manager__c = conRec.Id;
        projRec.pse__Project_Manager__c=null;
        List<pse__Proj__Share> projShareRecBefore = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                     where UserOrGroupId=:oldPortfolioManagerId and ParentId=:projRec.Id  Limit 1];
        
        update projRec;
        
        List<pse__Proj__Share> oldProjShareRecAfter = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                       where UserOrGroupId=:oldPortfolioManagerId and ParentId=:projRec.Id Limit 1];
        
        List<pse__Proj__Share> newProjShareRecAfter = [Select Id,ParentId,UserOrGroupId,AccessLevel from pse__Proj__Share 
                                                       where UserOrGroupId=:conRec.pse__Salesforce_User__c and ParentId=:projRec.Id Limit 1];
        
        system.assertEquals(1, projShareRecBefore.size());
        system.assertEquals(0, oldProjShareRecAfter.size());
        system.assertEquals(1, newProjShareRecAfter.size());
        
        Test.stopTest();
        
    }
    
    @isTest
    static void handleAfterProjInsertActionsTest(){
        
        Test.startTest();
        pse__Resource_Request__c resReqBefore =[Select Id,pse__Opportunity__c,pse__Project__c,pse__Opportunity__r.AccountId 
                                                from pse__Resource_Request__c Limit 1];
        
        pse__Proj__c delProjRec = [Select Id from pse__Proj__c where Id=:resReqBefore.pse__Project__c];  
        List<pse__Budget__c> budgetList = [Select Id from pse__Budget__c where pse__Project__c =:delProjRec.Id];
        
        delete budgetList;
        
        delete delProjRec;
        
        Contact conRec = [Select Id,pse__Region__c,AccountId from Contact where AccountId=:resReqBefore.pse__Opportunity__r.AccountId];
        Date currentDate = Date.today();
        pse__Proj__c projRec = new pse__Proj__c();
        projRec.Name = 'Test Project';
        projRec.pse__Project_Manager__c = conRec.Id;
        //projRec.pse__Project_Type__c = 'Customer Project';
        projRec.psa_pm_Project_Sub_Type__c ='JumpStart';
        projRec.pse__Opportunity__c = resReqBefore.pse__Opportunity__c;
        projRec.pse__Account__c = conRec.AccountId;  
        projRec.CurrencyIsoCode='USD';
        projRec.pse__Region__c = conRec.pse__Region__c;
        projRec.pse__Start_Date__c=currentDate.addDays(-6);
        projRec.pse__End_Date__c = currentDate.addDays(10);
        projRec.pse__Is_Active__c=false;
        projRec.pse__Allow_Self_Staffing__c=true;
        projRec.psa_pm_Time_Approval_Method__c = 'Auto-Approve';
        projRec.psa_pm_Require_Product_On_Timecards__c =false;
        projRec.psa_pm_Require_Milestone_on_Timecards__c = false;
        projRec.psa_pm_Require_Location_On_Timecards__c = false;
        
        insert projRec;
        
        pse__Resource_Request__c resReqAfter =[Select Id,pse__Opportunity__c,pse__Project__c,pse__Opportunity__r.AccountId 
                                               from pse__Resource_Request__c where Id=:resReqBefore.Id Limit 1];
        Test.stopTest();        
        system.assertEquals(projRec.Id, resReqAfter.pse__Project__c);
        
    }
    @isTest
    static void checkForResReqUpdatesOnProjUpdateTest(){
        Test.startTest();
        
        //Deleting a project record and updating another project with oppty from the deleted project record.
        String deletedProjOppty;
        pse__Proj__c delProjRec = [Select Id,pse__Opportunity__c from pse__Proj__c Limit 1];
        deletedProjOppty = delProjRec.pse__Opportunity__c;
        List<pse__Budget__c> budgetList = [Select Id from pse__Budget__c where pse__Project__c =:delProjRec.Id];
        
        delete budgetList;  
        
        pse__Proj__c projRec = [Select Id,pse__Opportunity__c from  pse__Proj__c where Id!=:delProjRec.Id];
        
        delete delProjRec;
        projRec.pse__Opportunity__c =deletedProjOppty;
        update projRec;
        
        pse__Resource_Request__c resReqRec =[Select Id,pse__Opportunity__c,pse__Project__c
                                                from pse__Resource_Request__c where pse__Project__c=:projRec.Id Limit 1];
        Test.stopTest();
        
        system.assertEquals(deletedProjOppty, resReqRec.pse__Opportunity__c);
           
    }
   
    @isTest
    Static void updateSolutionTypeRecsTest(){
        Test.startTest();
        List<pse__Proj__c> projRec = [Select Id,pse__Opportunity__c from  pse__Proj__c where Name ='Test Project 0' Limit 1];
        List<psa_pm_Solution_Type__c> solnRec = new List<psa_pm_Solution_Type__c>();
        if(projRec.size() > 0)
        solnRec = [Select Id,psa_pm_Project__c,Opportunity__c from psa_pm_Solution_Type__c
                                           where Opportunity__c=:projRec[0].pse__Opportunity__c Limit 1];
        Test.stopTest();
        if(projRec.size() > 0 && solnRec.size() > 0)
        system.assertEquals(projRec[0].Id, solnRec[0].psa_pm_Project__c);
    }
    
}