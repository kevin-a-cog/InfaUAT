@isTest
public class WeekendHolidayCloseFSMCollabsTest {
@testSetup
    static void setupObjectTestData() {
        String SupportAccount  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        
        //create an Account record
        sObject sObj = new Account();
        sObj.put('RecordTypeId',SupportAccount);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj.put('Support_Account__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        System.debug('lstSObj >> '+ lstSObj);
        UtilityTest.makeInsert(lstSObj);

        //create collaboration
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name='PowerCenter-PS'; // Define group name here
        chatterGroup.CollaborationType='Public'; //It can be 'Public' or 'Private'                   
        insert chatterGroup;
    }

    @isTest
    static void testcollabClosure(){

        List<Case> lCase = [Select Id From Case Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];
        
        Raise_Hand__c raiseHandEsc = new Raise_Hand__c();
        raiseHandEsc.Case__c = lCase[0].Id;
        raiseHandEsc.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandEsc.Type__c = 'Handoff';
        raiseHandEsc.Skill__c = 'PowerCenter - SME';
        raiseHandEsc.Name = 'Follow the Sun';

        Test.startTest();
            RaiseHandController controller = new RaiseHandController();
            RaiseHandService service = new RaiseHandService();

            RaiseHandController.getSkills(RaiseHandService.TYPE_GET_HELP,'','');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_PSREVIEW, '');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_MULTIPRODUCT, 'PowerCenter');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CO_OWN, RaiseHandService.SUBTYPE_OPERATIONS, 'Operations');
            RaiseHandController.getSkills(RaiseHandService.TYPE_CUSTOMER_MEETING,'','');
            RaiseHandController.getSkills(RaiseHandService.TYPE_REPRO_ENV_SETUP,'','');
        	RaiseHandController.createRaiseHand(raiseHandEsc);
        
        	WeekendHoliday_Support_CloseFSMCollabs.collabClosureHandler_FSM(lCase);
        Test.stopTest();
    }
}