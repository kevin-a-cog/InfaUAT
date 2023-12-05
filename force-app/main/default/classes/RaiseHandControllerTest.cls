/**
 * @description       : Unit Test Class for Raise HandController
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-26-2021
 * @last modified by  : Tejasvi Royal
**/
@isTest
public class RaiseHandControllerTest{

        @testSetup
        static void setupObjectTestData() {

                Id CustomerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
                Id SupportAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
                Id CustomerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
                Id OperationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
                
                //create an Engagement record
                sObject sObj = new Engagement__c();
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
                UtilityTest.makeInsert(new List<sObject>{sObj});
        
                //create a Case record
                sObj = new Case();
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
                UtilityTest.makeInsert(new List<sObject>{sObj});
                
                //create Profile Skill records
                List<sObject> lstSObj = new List<sObject>();
                sObj = new ProfileSkill();
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
                sObj.put('Omni_Skill_Name__c', 'PowerCenter');
                lstSObj.add(sObj);
                
                sObj = new ProfileSkill();
                sObj.put('Omni_Skill_Name__c', 'PowerCenter');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
                lstSObj.add(sObj);
                
                sObj = new ProfileSkill();
                sObj.put('Omni_Skill_Name__c', 'PowerCenter');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
                
                sObj.put('Omni_Skill_Name__c', 'PowerCenter');
                lstSObj.add(sObj);
                UtilityTest.makeInsert(lstSObj);
        
                //create collaboration
                CollaborationGroup chatterGroup = new CollaborationGroup();
                chatterGroup.Name='PowerCenter-PS'; // Define group name here
                chatterGroup.CollaborationType='Public'; //It can be 'Public' or 'Private'                   
                insert chatterGroup;

                sObj = new Account();
                UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
                UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecordTypeId);
                UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
                
                sObj = new Account();
                UtilityTestData.mAccountData.put('Name', 'Test1 Support Account');
                UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
                UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecordTypeId);
                UtilityTestData.mAccountData.put('BillingCountry', 'USA');
                UtilityTestData.mAccountData.put('Active__c', 'true');
                UtilityTestData.mAccountData.put('End_Date__c', System.today()+110+'');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
                List<account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

                //Create a TimeZone record
                sObj = new TimeZone__c();
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
                List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

                //Create Contact record
                sObj = new Contact();
                UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
                UtilityTestData.mContactData.put('Email','test@testdevtestdev.com');
                UtilityTestData.mContactData.put('TimeZone_Lookup__c',lTimezone[0].Id);
                UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
                UtilityTestData.mContactData.put('RecordTypeId',CustomerContactRecordTypeId);
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
                List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

                //Create Case
                sObj = new Case();
                sObj.put('OwnerId', UserInfo.getUserId());
                sObj.put('Success_Offering__c', 'Premium Success');
                sObj.put('Priority', 'P1');
                sObj.put('Forecast_product__c', 'Axon Data Governance');
                sObj.put('Version__c', '4.3.4');
                //sObj.put('Component__c', 'Documentation');
                sObj.put('Case_Support_Add_On__c', 'XS');
                sObj.put('IR_Completion_Date__c', null); 
                sObj.put('ContactId', lContact[0].Id); 
                sObj.put('Status', 'New');
                sObj.put('Environment__c', 'PROD');
                sObj.put('CreatedDate', system.now());
                sObj.put('RecordTypeId',OperationsCaseRecordTypeId);
                sObj.put('AccountId', lNewCustomerAccount[0].Id);
                sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
                List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        }
    
	@isTest
	static void testLookupQueueSearch() {

                /*Group testGroup = new Group(Name='TestQueue', Type='Queue');
                insert testGroup;
                
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;*/
                
                List<QueuesObject> QueuesObjectList = [Select Id , QueueID from QueueSObject];
                List<Group> queueList = [Select Id, Name From Group WHERE Type = 'Queue'];
                
                Test.startTest();
                RaiseHandController.lookupQueueSearch(queueList[0].Name,new List<String>());
                RaiseHandController.lookupCombinedSearch(queueList[0].Name,new List<String>(),null,true);
                RaiseHandController.lookupCombinedSearch(queueList[0].Name,new List<String>(),null,false);
                Test.stopTest();
        }

        @isTest
        static void testMonitoring(){

                sObject sObj;
                List<Case> lCase = [Select Id,Support_Account__c,Support_Account__r.ParentId from Case];
                List<QueuesObject> QueuesObjectList = [Select Id, QueueID from QueueSObject WHERE SobjectType = 'Case' and  Queue.name!='Ask An Expert'];

                Raise_Hand__c raiseHandGetHelp = new Raise_Hand__c();
                raiseHandGetHelp.Case__c = lCase[0].Id;
                raiseHandGetHelp.Status__c = RaiseHandService.STATUS_OPEN;
                raiseHandGetHelp.Type__c = RaiseHandService.TYPE_GET_HELP;
                raiseHandGetHelp.Skill__c = 'PowerCenter - PS';
                raiseHandGetHelp.Question__c = 'This is the question';

                Raise_Hand__c raiseHandCustMeeting = new Raise_Hand__c();
                raiseHandCustMeeting.Case__c = lCase[0].Id;
                raiseHandCustMeeting.Status__c = RaiseHandService.STATUS_OPEN;
                raiseHandCustMeeting.Type__c = RaiseHandService.TYPE_CUSTOMER_MEETING;
                raiseHandCustMeeting.Skill__c = 'PowerCenter - PS';

                Raise_Hand__c raiseHandCoOwn = new Raise_Hand__c();
                raiseHandCoOwn.Case__c = lCase[0].Id;
                raiseHandCoOwn.Status__c = RaiseHandService.STATUS_OPEN;
                raiseHandCoOwn.Type__c = RaiseHandService.TYPE_CO_OWN;
                raiseHandCoOwn.Subtype__c = RaiseHandService.SUBTYPE_MULTIPRODUCT;
                raiseHandCoOwn.Skill__c = 'PowerCenter - PS';
                
                RaiseHandController.getSkills(RaiseHandService.TYPE_GET_HELP,'','');
                RaiseHandController.getSkills(RaiseHandService.TYPE_REPRO_ENV_SETUP,'','');
                RaiseHandController.getSkills(RaiseHandService.TYPE_CUSTOMER_MEETING,'','');
                RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_PSREVIEW, '');
                RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_OPERATIONS, 'Operations');
                RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_MULTIPRODUCT, 'PowerCenter');
                List<String> weekendHolidaySupportDateTimes = RaiseHandController.calculateWHSupportDateTimes('20');
                Test.startTest();
                RaiseHandController.createRaiseHand(raiseHandGetHelp);
                raiseHandGetHelp.OwnerId = UserInfo.getUserId();
                raiseHandGetHelp.Status__c = 'Closed';
                update raiseHandGetHelp;
                RaiseHandService.onAssignment(new Set<Id>{raiseHandGetHelp.Id});
                RaiseHandController.createRaiseHand(raiseHandCoOwn);
                RaiseHandController.closeRequest(raiseHandGetHelp.Id);
                RaiseHandController.createRaiseHand(raiseHandCustMeeting);
                RaiseHandController.raiseHandRequest(lCase[0].Id, RaiseHandService.TYPE_GET_HELP, '', 'PowerCenter - PS', '', 'Normal', 'Type 1', '', '');
                RaiseHandController.updateCase(lCase[0].Id,'Live/Queue Handoff', UserInfo.getUserId(), QueuesObjectList[0].QueueID, 'Test HandOff Comment', 'Test HandOff steps', weekendHolidaySupportDateTimes[0], weekendHolidaySupportDateTimes[1]);
                RaiseHandController.updateCase(lCase[0].Id,'Follow the Sun Monitoring', UserInfo.getUserId(), QueuesObjectList[0].QueueID, 'Test HandOff Comment', 'Test HandOff steps', weekendHolidaySupportDateTimes[0], weekendHolidaySupportDateTimes[1]);
                RaiseHandController.updateCase(lCase[0].Id,'Weekend/Holiday Monitoring', UserInfo.getUserId(), QueuesObjectList[0].QueueID, 'Test HandOff Comment', 'Test HandOff steps', weekendHolidaySupportDateTimes[0], weekendHolidaySupportDateTimes[1]);
                Test.stopTest();
        }
    
}