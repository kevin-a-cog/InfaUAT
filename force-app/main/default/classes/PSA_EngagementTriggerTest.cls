/*
@created by       : RANJAN KISHORE
@created on       : 06/22/2021
@Purpose          : This Test class provides code coverages to the trigger PSA_EngagementTrigger 
and its handler and helper classes.
Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |       Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/
@isTest
public class PSA_EngagementTriggerTest {
    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {Account.SObjectType,
        pse__Region__c.SobjectType,
        pse__Work_Calendar__c.SobjectType,
        Contact.SobjectType,
        Opportunity.SobjectType,
        PSA_Engagement_Approval_Matrix__c.SobjectType,
        Engagement__c.SobjectType
        };
            
            @testSetup
            static void initializeData(){
                
                User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
                Date currentDate = Date.today();
                String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
                Profile prof = [select Name from Profile where Name = 'Employee'];
                
                // Turn on the Assignment Trigger via Custom Settings.
                Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
                trigSetting.PSA_EngagementTrigger__c = true;
                trigSetting.SetupOwnerId = UserInfo.getUserId();
                insert trigSetting;
                
                UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
                
                //Create Account
                Account acc = new Account();
                acc.RecordTypeId = accRecType;
                acc.Name = 'Test Account ';
                acc.CSM_Segment__c='Digital Touch';
                acc.Contract_Company_Group__c='Prospect';
                acc.Payment_Terms__c='Net 30';
                acc.BillingCountry='India';
                uow.registerNew(acc);
                
                // Create Region        
                pse__Region__c regionRec = new pse__Region__c();
                regionRec.Name = 'Test Region ';
                regionRec.pse__Action_Update_Current_Time_Period__c = false;
                regionRec.psa_pm_Allow_Customer_Project__c = true;
                regionRec.pse__Region_Name_Chain__c = 'EMEA';
                uow.registerNew(regionRec);
                
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
                
                // Create Contact
                String conRecType  = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
                Contact con = new Contact();
                con.LastName ='Contact';
                con.FirstName = 'Test';
                con.Email='test123'+'email@gmail.com';
                con.pse__Is_Resource__c =true;
                con.pse__Is_Resource_Active__c=true;
                con.CurrencyIsoCode='USD';
                con.pse__Resource_Role__c='Regional Manager';
                con.pse__Default_Cost_Rate__c = 10;
                con.psa_Target_Bill_Rate__c=10;
                con.MailingCountry='India';
                uow.registerRelationship(con, Contact.pse__Region__c, regionRec);
                uow.registerRelationship(con, Contact.AccountId, acc);
                uow.registerRelationship(con, Contact.pse__Work_Calendar__c, defaultWorkCalendar);
                uow.registerNew(con, Contact.pse__Salesforce_User__c, userObj);
                
                // Create Opportuntiy
                String opptyRecType  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId(); 
                
                Opportunity oppty = new Opportunity();
                oppty.RecordTypeId = opptyRecType;
                oppty.Name = 'Test opportunity 1';
                oppty.CurrencyIsoCode='USD';
                oppty.Type='Direct';
                oppty.CloseDate =  currentDate.addDays(2);
                oppty.StageName='Identity';
                oppty.psa_om_Start_Date__c = currentDate;
                oppty.psa_om_End_Date__c = currentDate.addDays(10);
                oppty.PSA_OM_Project_Type__c = 'JumpStart';
                oppty.psa_om_IPS_Package__c = 'JumpStart: Cloud Adoption Hybrid MDM';
                oppty.Sales_Play__c='Data Quality';
                uow.registerNew(oppty, Opportunity.pse__Region__c, regionRec);
                
                //Create record for PSA Approval Matrix
                PSA_Engagement_Approval_Matrix__c matrix = new PSA_Engagement_Approval_Matrix__c( 
                    Commercial_Review__c = UserInfo.getUserId(),
                    Delivery_Review__c = UserInfo.getUserId(),
                    DM_Review__c = UserInfo.getUserId(),
                    Technical_Review__c = UserInfo.getUserId());
                uow.registerNew(matrix, PSA_Engagement_Approval_Matrix__c.Region__c, regionRec);
                
                for(integer i=0;i<4;i++){
                    Engagement__c engagementRec = new Engagement__c();
                    engagementRec.Name = 'Test Engagement '+ i;            
                    engagementRec.psa_Region_GEO__c = 'EMEA';
                    engagementRec.psa_Requires_VP_Approval__c = true;
                    engagementRec.PSA_Submit_for_Approval__c = true;
                    if(i==0){
                        engagementRec.psa_Status__c = 'Pending OPS Review';
                    }
                    else if(i==1){
                        engagementRec.psa_Status__c = 'Pending VP Review';
                    }
                    else if(i==2){
                        engagementRec.psa_Status__c = 'Pending Commercial Review';
                    }
                    else if(i==3){
                        engagementRec.psa_Status__c = 'Pending Customer Approval';
                    }
                    uow.registerRelationship(engagementRec, Engagement__c.psa_Eng_Region__c, regionRec);
                    uow.registerRelationship(engagementRec, Engagement__c.PSA_Engagement_Approval_Matrix__c, matrix);
                    uow.registerNew(engagementRec, Engagement__c.Opportunity__c, oppty);
                }                
                Test.startTest();
                uow.commitWork();
                Test.stopTest();                
            }  
   
   
    @isTest
    static void onApprovalRejectionReadyforDocusignTest(){
        Engagement__c engagementRec = [SELECT Id FROM Engagement__c LIMIT 1];        
        engagementRec.psa_Status__c = 'Ready for Docusign';
        engagementRec.PSA_Signatory_Name__c = 'test';
        engagementRec.PSA_Signatory_email_address__c = 'test@abc.com';
        engagementRec.PSA_Submit_for_Approval__c = false;
        update engagementRec;        
    }
    
    @isTest
    static void onApprovalRejectionOPSReviewTest(){
        Engagement__c engagementRec = [Select Id FROM Engagement__c 
                                       WHERE psa_Status__c = 'Pending OPS Review' LIMIT 1];
       
        //Rejecting the Engagement
        Test.startTest();
        engagementRec.PSA_Submit_for_Approval__c = false;
        update engagementRec;
        Test.stopTest();
    }
    
    @isTest
    static void onApprovalRejectionVPReviewTest(){
        Engagement__c engagementRec = [SELECT Id FROM Engagement__c 
                                       WHERE psa_Status__c = 'Pending VP Review' LIMIT 1];
        //Rejecting the Engagement
        Test.startTest();
        engagementRec.PSA_Submit_for_Approval__c = false;
        update engagementRec;
        Test.stopTest();
    }
    
    @isTest
    static void onApprovalRejectionCommercialReviewTest(){
        Engagement__c engagementRec = [SELECT Id FROM Engagement__c 
                                       WHERE psa_Status__c = 'Pending Commercial Review' LIMIT 1];
        //Rejecting the Engagement
        Test.startTest();
        engagementRec.PSA_Submit_for_Approval__c = false;
        update engagementRec;
        Test.stopTest();
    }
    @isTest
    static void onApprovalRejectionCustomerApprovalTest(){
        Engagement__c engagementRec = [SELECT Id FROM Engagement__c 
                                       WHERE psa_Status__c = 'Pending Customer Approval' LIMIT 1];
        //Rejecting the Engagement
        Test.startTest();
        engagementRec.PSA_Submit_for_Approval__c = false;
        update engagementRec;
        Test.stopTest();
    }
     @isTest
    static void testInvocableMethod(){
        Engagement__c engagementRec = [SELECT Id FROM Engagement__c LIMIT 1];
        List<PSA_EngagementTriggerHelper.flowDetailParams> params = new List<PSA_EngagementTriggerHelper.flowDetailParams>();
        PSA_EngagementTriggerHelper.flowDetailParams param = new PSA_EngagementTriggerHelper.flowDetailParams();
        param.engId = engagementRec.Id;
        param.signName = 'Test';
        param.signEmail = 'test@abc.com';
        params.add(param);
        PSA_EngagementTriggerHelper.unlockRecord(params);        
    }
}