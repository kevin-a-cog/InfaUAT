@isTest
public class psa_refreshAssignmentHoursJobTest {
    @testSetup
    static void setupObjectTestData() {
        User userObj =  [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        Date currentDate = Date.today();
        String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
        
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
            accList.add(acc);
            
        }
        insert accList;
         // Create user/Resource 
        
        Profile prof = [select Name from Profile where Name = 'Employee'];
        
        
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
        
        List<pse__Region__c> regionList = new List<pse__Region__c>();
        for(integer i=0;i<2;i++){
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
            con.pse__Salesforce_User__c = userList[i].Id;
            con.pse__Work_Calendar__c = defaultWorkCalendar.Id;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            
            conList.add(con);
            
        }
        insert conList;
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
            opptyList.add(oppty);
            
        }
        Test.startTest();
        insert opptyList; 
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
        
        system.runAs(userObj){
        // Create Project
        List<pse__Proj__c> projList = new List<pse__Proj__c>();
        for(integer i=0;i<2;i++){
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
        
        
        
        // create PSA MSA Code Mapping
        List<PSA_MSA_Code_Mapping__c> psaMSACodeMappingList = new List<PSA_MSA_Code_Mapping__c>();
        for(integer i=0;i<2;i++){
            PSA_MSA_Code_Mapping__c psaMSACodeMapping = new PSA_MSA_Code_Mapping__c();
            psaMSACodeMapping.Name = 'Test MSA Code Map '+i;
            psaMSACodeMapping.psa_pm_MSA_Code__c='11223'+i;
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
        
        // Create Schedule
        
        List<pse__Schedule__c> scheduleList = new List<pse__Schedule__c>();
        for(integer i=0;i<6;i++){
            pse__Schedule__c scheduleRec = new pse__Schedule__c();
            scheduleRec.pse__Start_Date__c = currentDate.addDays(1);
            scheduleRec.pse__End_Date__c = currentDate.addDays(10+i);
            scheduleRec.pse__Monday_Hours__c = 8;
            scheduleRec.pse__Tuesday_Hours__c = 8;
            scheduleRec.pse__Wednesday_Hours__c = 8;
            scheduleRec.pse__Thursday_Hours__c = 8;
            scheduleRec.pse__Friday_Hours__c = 8;
            scheduleRec.pse__Saturday_Hours__c = 8;
            scheduleRec.pse__Sunday_Hours__c = 8;
            scheduleList.add(scheduleRec);
        }
        insert scheduleList;
       
            // Create Resource Request
            List<pse__Resource_Request__c> resourceReqList = new List<pse__Resource_Request__c>();
            for(integer i=0;i<6;i++){
                pse__Resource_Request__c  resourceReq = new pse__Resource_Request__c();
                resourceReq.pse__Start_Date__c = currentDate.addDays(1);
                resourceReq.pse__End_Date__c = currentDate.addDays(10);
                if(i<3){
                    //resourceReq.pse__Staffer_Resource__c = conList[0].Id;
                    resourceReq.pse__Project__c = projList[0].Id;
                    resourceReq.pse__Opportunity__c = opptyList[0].Id;
                    resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMappingList[0].Id;
                    //resourceReq.PSA_OM_Opportunity_Product_Id__c =  opptyLineItemList[0].Id;
                    resourceReq.psa_rm_Original_Opportunity__c = opptyList[0].Id;
                    resourceReq.pse__Region__c = regionList[0].Id;
                }else{
                    //resourceReq.pse__Staffer_Resource__c = conList[1].Id;
                    resourceReq.pse__Project__c = projList[1].Id;
                    resourceReq.pse__Opportunity__c = opptyList[1].Id;
                    resourceReq.psa_rm_MSA_Code_Mapping__c = psaMSACodeMappingList[1].Id;
                    //resourceReq.PSA_OM_Opportunity_Product_Id__c =  opptyLineItemList[1].Id;
                    resourceReq.psa_rm_Original_Opportunity__c = opptyList[1].Id;
                    resourceReq.pse__Region__c = regionList[1].Id;
                }
                resourceReq.pse__SOW_Hours__c =8;
                resourceReq.pse__Resource_Role__c = 'Consultant';
                resourceReq.CurrencyIsoCode='USD';
                resourceReq.PSA_RM_Assignment_Type__c ='Customer Billable';
                resourceReq.psa_rm_Billable__c = true;
                resourceReqList.add(resourceReq);
            }
            insert resourceReqList;  
            
            // Create Assignment
            
            List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
            pse__Assignment__c assignRec = new pse__Assignment__c();
            assignRec.Name = 'Test Assignment';
            assignRec.pse__Planned_Hours__c = 7;
            assignRec.pse__Bill_Rate__c =0;
            assignRec.pse__Is_Billable__c = true;
            assignRec.pse__Role__c ='Senior Consultant';
            assignRec.pse__Cost_Rate_Amount__c =10;
            assignRec.CurrencyIsoCode='USD';
            assignRec.pse__Resource_Request__c = resourceReqList[0].Id;  
            assignRec.pse__Schedule__c = scheduleList[0].Id;
            assignRec.pse__Resource__c = conList[0].Id;
            assignRec.pse__Project__c = projList[0].Id;
            assignmentList.add(assignRec);
            assignmentList[0].pse__Role__c =null;
            insert assignmentList;            
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAssignmentSchedule(){
        Test.StartTest();        
        psa_refreshAssignmentHoursJob sch = new psa_refreshAssignmentHoursJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Assignment Job - Custom', cron , sch);         
        Test.StopTest();
    }
    @isTest
    static void testMilestoneSchedule(){
        List<pse__Proj__c> projList = [SELECT Id FROM pse__Proj__c LIMIT 1];
        Test.StartTest();        
        
            sObject sObj = new pse__Milestone__c();
            UtilityTestData.mMilestone.put('Name','Test Milestone');
            UtilityTestData.mMilestone.put('pse__Target_Date__c',System.today().addDays(1)+'');
            UtilityTestData.mMilestone.put('pse__Milestone_Amount__c','0.00');
            UtilityTestData.mMilestone.put('CurrencyIsoCode','USD');
            UtilityTestData.mMilestone.put('pse__Project__c',projList[0].Id);//
            UtilityTestData.mMilestone.put('psa_pm_Record_Type__c','Labor');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mMilestone); 
            List<pse__Milestone__c> lMilestone = (List<pse__Milestone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
        psa_refreshMilestoneHoursJob sch = new psa_refreshMilestoneHoursJob();
        String cron = '0 0 23 * * ?'; 
        system.schedule('PSA Refresh Milestone Job - Custom', cron , sch);         
        Test.StopTest();
    }
}