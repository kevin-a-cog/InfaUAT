/*
    @created by       : Pavithra V
    @created on       : 09/03/2021
    @Purpose          : Test class for 
    @Testclass        : CaseCommentTriggerHelperTest
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 
 */
@isTest
public class CaseCommentTriggerHelperTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        sObject sObj1;
        
        //create an TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
        
        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);//Email
        UtilityTestData.mContactData.put('Email','test@test.com');
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        //Create Entitlement
        Entitlement ent = new Entitlement(AccountId = lAccount[0].Id,Name = 'Signature Success',StartDate = System.today(), EndDate = system.today().addyears(3),Support_Level__c = 'Signature Success');
        insert ent;
        
        //create a Case record
        User u =[SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive = true LIMIT 1];

        sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        //bj.put('Success_Offering__c', 'Basic Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Active VOS');
        sObj.put('Version__c', '10.1');
        sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'New');
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',rt1.Id);
        sObj.put('AccountId', lAccount[0].Id);        
        sObj.put('SlaStartDate',System.now());
        sObj.put('EntitlementId',ent.Id);
        sObj.put('IsStopped',false);
        //sObj.put('Automatic_closure_Date__c',System.now().addDays(20));
        sObj.put('OwnerId',u.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
       
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Case_Contact__c();        
       	sObj.put('Case__c', lCase[0].Id);
        sObj.put('Contact__c', lContact[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseContact);
        UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    @isTest
    static void testCaseTriggerHelper(){        
        Test.startTest();
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c,OwnerId From Case Limit 1];
        
        sobject sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', false);
        sObj.put('Importance__c', false);
        sObj.put('Status__c','Submitted');
        sObj.put('Type__c','Predictive Escalation');
        sObj.put('Sub_Type__c','Initial Response');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Case_Comment__c cc = [Select Id From Case_Comment__c Limit 1]; 
        cc.Comment__c ='Updated Comment - Test';
        cc.Status__c = 'Submitted';
        update cc;
        
        List<CaseMilestone> lCaseMilestone = [select Id,MilestoneTypeId,milestonetype.name,CaseId from CaseMilestone where caseId =: lCase[0].Id];
        System.debug('lCaseMilestone >> '+ lCaseMilestone);
        cc.Comment__c ='';
        cc.Status__c = 'Submitted';
        update cc;
        
        lCase[0].Description ='Updated Desc';
        update lCase[0];
        
        lCase[0].Description ='Updated Description';
        update lCase[0];
        
        Test.stopTest();
    }
    
    @isTest
    static void testCaseinboundcomment(){        
        Test.startTest();
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c,OwnerId From Case Limit 1];
        
        sobject sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', true);
        sObj.put('Importance__c', false);
        sObj.put('Status__c','Submitted');
        sObj.put('Type__c','Predictive Escalation');
        sObj.put('Sub_Type__c','Initial Response');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Case_Comment__c cc = [Select Id From Case_Comment__c Limit 1]; 
        cc.Comment__c ='Updated Comment - Test';
        cc.Status__c = 'Submitted';
        update cc;        
      
        
        Test.stopTest();
    }
    
    
	@isTest
    static void testCaseInboundTrue(){ 
         Test.startTest();
        sobject sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        //bj.put('Success_Offering__c', 'Basic Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Active VOS');
        sObj.put('Version__c', '10.1');
        sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        //sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'New');
        sObj.put('CreatedDate', system.now());
        //sObj.put('RecordTypeId',rt1.Id);
        //sObj.put('AccountId', lAccount[0].Id);  
        sObj.put('Automatic_closure_Date__c',System.now().addDays(20));
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
       
        List<Case> listCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c From Case Limit 1];
        
        /*MilestoneType milestonetypeObj = new MilestoneType(Name='ongoing response',Description= 'INFA GCS Communication Targets throughout the Case Resolution Lifecycle',
                                                          RecurrenceType= 'recursIndependently');
        insert milestonetypeObj;
		*/
		List<CaseMilestone> lCaseMilestone = [select Id,MilestoneTypeId,milestonetype.name,CaseId from CaseMilestone where caseId =: lCase[0].Id];
        System.debug('lCaseMilestone1 >>> '+ lCaseMilestone);

        
        zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c(Name= 'test',zsfjira__IssueId__c= 123323, zsfjira__IssueKey__c= '123',zsfjira__Prioriy__c= 'P2/Normal');
        insert zissue;
        
        sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'Internal');
        sObj.put('ZIssue__c',zissue.id);
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', true);
        sObj.put('Importance__c', false);
        sObj.put('Status__c','Submitted');
        sObj.put('Type__c','Predictive Escalation');
        sObj.put('Sub_Type__c','Initial Response');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        List<Case_Comment__c> lcc= (List<Case_Comment__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
                
        sobject sObj1 = new Case_Comment__c();
        sObj1.put('ZIssue__c',zissue.id);
        //sObj1.put('Parent_Comment__c',lcc[0].Id);
        sObj1.put('Visibility__c', 'External');
        sObj1.put('Email_Sent__c', false);
        sObj1.put('Case__c', listCase[0].Id);
        sObj1.put('Inbound__c', true);
        sObj1.put('Importance__c', false);
        sObj1.put('Status__c','Submitted');
        sObj1.put('Type__c','Predictive Escalation');
        sObj1.put('Sub_Type__c','Initial Response');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCaseComment);
        List<Case_Comment__c> listcc= (List<Case_Comment__c>)UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        lcc[0].Parent_Comment__c = listcc[0].Id;
        lcc[0].Status__c = 'Submitted';
        update lcc;
        
        Map<Id,Id> caseParentCommentMap = new Map<Id,Id>();
        caseParentCommentMap.put( listcc[0].Id,lCase[0].Id);
        Casecommenttriggerhelper cchelper = new Casecommenttriggerhelper();
        cchelper.checkAndAddManagerToCaseTeam(caseParentCommentMap);
        Test.stopTest();
    }

    @isTest
    static void testCaseOutboundComment(){ 
        Test.startTest();

        Id timeZone = [SELECT Id FROM TimeZone__c LIMIT 1]?.Id;

        Entitlement entitlementDetails = [Select Id From Entitlement LIMIT 1];
        entitlementDetails.Support_Level__c = 'Basic Success';
        update entitlementDetails;

        Account account = [Select id From Account LIMIT 1];

        Id supportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        SObject sObjSuppAccount = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', account.Id);
        UtilityTestData.mAccountData.put('RecordTypeId', supportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        UtilityTestData.mAccountData.put('Success_Offering__c', 'Basic Success');
        UtilityTestData.mAccountData.put('TimeZone__c', timeZone);
        UtilityTestData.mAccountData.put('Entitlement__c', entitlementDetails.Id);
        UtilityTestData.mAccountData.put('Max_Number_of_Cases_Allowed__c', '10');
        sObjSuppAccount = UtilityTest.putFieldRecord(sObjSuppAccount, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjSuppAccount});

        Case lCase = [Select Id,IR_Completion_Date__c,Priority,Success_Offering__c,Case_Support_Add_On__c,OwnerId From Case Limit 1];

        lCase.Case_Timezone__c = timeZone;
        lCase.Priority = 'P2';
        lCase.Support_Account__c = lNewSupportAccount[0].Id;
        lCase.Success_Offering__c = 'Basic Success';
        lCase.EntitlementId = entitlementDetails.Id;
        Update lCase;

        SObject sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase.Id);
        sObj.put('Inbound__c', false);
        sObj.put('Importance__c', false);
        sObj.put('Status__c','Submitted');
        sObj.put('Type__c','');
        sObj.put('Sub_Type__c','Initial Response');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        List<Case_Comment__c> lcc= (List<Case_Comment__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
                
        sobject sObj1 = new Case_Comment__c();
        sObj1.put('Visibility__c', 'External');
        sObj1.put('Email_Sent__c', false);
        sObj1.put('Case__c', lCase.Id);
        sObj1.put('Inbound__c', false);
        sObj1.put('Importance__c', false);
        sObj1.put('Status__c','Submitted');
        sObj1.put('Type__c','');
        sObj1.put('Sub_Type__c','General Response');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCaseComment);
        List<Case_Comment__c> listcc= (List<Case_Comment__c>)UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        List<Case_Comment__c> savedComments = [SELECT Id, Visibility__c, Status__c FROM Case_Comment__c WHERE Case__c = :lCase.Id];

        for(Case_Comment__c commentItem : savedComments)
        {
            system.debug('CaseComment- Id: '+commentItem.Id+', Visibility__c: '+commentItem.Visibility__c+', Status__c: '+commentItem.Status__c);
            commentItem.Status__c = 'Submitted';
        }

        update savedComments;

    Test.stopTest();
    }
}