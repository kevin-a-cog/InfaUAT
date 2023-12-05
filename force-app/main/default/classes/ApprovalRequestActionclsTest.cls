@isTest
public class ApprovalRequestActionclsTest {
    
    static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Deal Registration').getRecordTypeId();
    static Id AccRecTypeId_CustAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {
        
        Profile partnerProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];
        UtilityTestData.mAccountData.put('Name', 'Test Account Opprotunity');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecTypeId_CustAccnt);
        UtilityTestData.mAccountData.put('BillingCountry','United States');
		
        Account acc = new Account(Name = 'Test Account Opprotunity',
                                 RecordTypeId= AccRecTypeId_CustAccnt,
                                 BillingCountry='United States');
        insert acc;
		
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm1@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest');
        UtilityTestData.mUserData.put('CommunityNickname','mtest');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        
        UtilityTestData.mUserData.put('LastName','mtest');
        UtilityTestData.mUserData.put('IsActive','true');
        
        sObject userSobj = new User();
        userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);
        
        //create partner user(disti)
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest2Distii@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm2@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest');
        UtilityTestData.mUserData.put('CommunityNickname','mtest2');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        
        UtilityTestData.mUserData.put('LastName','mtest2');
        
        sObject userSobj2 = new User();
        userSobj2 = UtilityTest.putFieldRecord(userSobj2, UtilityTestData.mUserData);
        
        //create partner user(software reseller and SI)
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest3@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm3@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest3');
        UtilityTestData.mUserData.put('CommunityNickname','mtest3');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
       
        UtilityTestData.mUserData.put('LastName','mtest3');
        
        sObject userSobj3 = new User();
        userSobj3 = UtilityTest.putFieldRecord(userSobj3, UtilityTestData.mUserData);
        
        //create another partner user(reseller)
        UtilityTestData.mUserData.put('ProfileId',partnerProfile.id+'');
        UtilityTestData.mUserData.put('Username','mtest4@m.t');
        UtilityTestData.mUserData.put('Email','testemailforleadm4@infa.com');
        UtilityTestData.mUserData.put('Alias','mtest4');
        UtilityTestData.mUserData.put('CommunityNickname','mtest4');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        
        UtilityTestData.mUserData.put('LastName','mtest4');
        UtilityTestData.mUserData.put('IsActive','true');
        
        sObject userSobj4 = new User();
        userSobj4 = UtilityTest.putFieldRecord(userSobj4, UtilityTestData.mUserData);
            
        List<User> userListInsert = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj,userSobj2,userSobj3,userSobj4});
		userListInsert[0].ManagerId =  userListInsert[2].Id;
        userListInsert[2].ManagerId = userListInsert[3].Id;    

        List<User> userListUpdate = (List<USer>) UtilityTest.makeUpdate(new List<sObject>{userListInsert[0],userListInsert[2]});
        
        User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
        settings1.Ignore_Validation_Rules__c = true;
        settings1.SetupOwnerId = Userinfo.getUserId();
        upsert settings1 User_Exemptions__c.Id;
        
        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert111');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Resell');
        UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Fulfillment');
        UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c',null);
        UtilityTestData.mLeadData.put('Need_Describe_Customer_Issue__c','e;rle;lre;lr;elr;elr;elr;elre;lr;elr;le;rle;lre;lr;elr;l');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_or_Project_Budget__c','12');
        UtilityTestData.mLeadData.put('CurrencyIsoCode','USD');
        UtilityTestData.mLeadData.put('Estimated_Opportunity_Closing_Date__c',system.today() + 10 + '');
        UtilityTestData.mLeadData.put('Status','Expired');
        UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','testDRAPPROVALPROCESS');
        UtilityTestData.mLeadData.put('Email','test@testr.q');
        UtilityTestData.mLeadData.put('Solicitation_RFP_or_Public_Tender__c','True');
        UtilityTestData.mLeadData.put('Country','United States');
        UtilityTestData.mLeadData.put('FirstName','test resell');
        //UtilityTestData.mLeadData.put('Account__c',acc.Id);
        //create lead
        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        
        List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        leadList[0].Approver1__c = userListInsert[0].Id;
        leadList[0].Approver2__c = userListInsert[2].Id;
        leadList[0].PSM__c = userListInsert[0].Id;
        leadList[0].Field_Sales_Rep__c = userListInsert[2].Id;
        update leadList[0];
       
    }

    @isTest
    static void validateApprovalProcess(){
        
        test.startTest();
        Lead lds = [SELECT id,lastname, PSM__c,Account__c, Field_Sales_Rep__c, Approver1__c, Approver2__c, Status from Lead LIMIT 1];
		submitforapproval(lds.Id);
        List<ProcessInstanceWorkitem> pIWI = [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, 
                                        ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName, ActorId 
        								FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :lds.Id and ProcessInstance.Status= 'Pending'];
            ApprovalRequestActioncls.getCurrentStatus(pIWI[0].Id);
        test.stopTest();
    }
    
    @isTest
    static void approveApprovalProcessStageOne(){
        test.startTest();
                
        Lead lds = [SELECT id,lastname,PSM__c,Field_Sales_Rep__c, Approver1__c, Approver2__c, Status from Lead LIMIT 1];
        submitforapproval(lds.Id);
        List<ProcessInstanceWorkitem> pIWI = [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, 
                                              ProcessInstance.TargetObjectId,  ProcessInstance.ProcessDefinition.DeveloperName, 
                                              ActorId 
                                              FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :lds.Id and ProcessInstance.Status= 'Pending'];
        List<LeadShare> leadShrs = [select id from LeadShare where LeadId= :lds.Id and UserOrGroupId = :lds.Approver2__c];
        if(leadshrs.size() > 0)
            delete leadShrs;
        ApprovalRequestActioncls.updateRecord('Lead', new Map<String, Object>(), 'Testing Comment', lds.Id,pIWI[0].Id, 'Approve' );
        test.stopTest();
    }
    
    
    @isTest
    static void handleRecallTest(){
        test.startTest();
        Lead lds = [SELECT id,lastname,PSM__c,Field_Sales_Rep__c, Approver1__c, Approver2__c, Status from Lead LIMIT 1];
        submitforapproval(lds.Id);
        List<ProcessInstanceWorkitem> pIWI = [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, 
                                              ProcessInstance.TargetObjectId,ProcessInstance.ProcessDefinition.DeveloperName, ActorId 
                                              FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :lds.Id and ProcessInstance.Status= 'Pending'];
        ApprovalRequestActioncls.handleRecallAssignment(pIWI[0].Id);
        test.stopTest();
    }
    
    @isTest
    static void handleReassignmentTest(){
        test.startTest();
        Lead lds = [SELECT id,lastname,PSM__c,Field_Sales_Rep__c, Approver1__c, Approver2__c, Status from Lead LIMIT 1];
        submitforapproval(lds.Id);
        List<ProcessInstanceWorkitem> pIWI = [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, 
                                            ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName, ActorId 
                                            FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :lds.Id and ProcessInstance.Status= 'Pending'];
            ApprovalRequestActioncls.handleReassignment(pIWI[0].Id, UserInfo.getUserId(), lds.Id, 'Lead');
        test.stopTest();
    }
    
    static void submitforapproval(Id leadId){
        Lead lds = new Lead();
        lds.Id = leadId;
        lds.Status = 'Received';
        update lds;
        List<ProcessInstanceWorkitem> pIWI = [SELECT ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObject.Name, 
                                            ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName, ActorId 
                                            FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :lds.Id and ProcessInstance.Status= 'Pending'];
        if(pIWI.size() == 0)
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request using testclass');        
            req.setObjectId(leadId);
            Approval.ProcessResult result = Approval.process(req);
        }
    }
}