@isTest
public class panoptaIncidentControllerTest {
	 @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        sObject sObj = new Account();//
        UtilityTestData.mAccountData.put('Name', 'HMDM Gordon Food Service, Inc.');//Panopta_Org_Record_1178
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
        sObject sObj2 = new Account();//
        UtilityTestData.mAccountData.put('Name', 'HMDM Gordon Food Service, Inc.');//Panopta_Org_Record_1178
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);
        List<Account> lAccount1 = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact(Email = 'testing1email@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
		
        //create an Incident record
        sObj = new Incident__c();
        sObj.put('Duration_of_the_Incident__c', 'Test');
        sObj.put('Incident_Id__c', 'Test');
        sObj.put('Instance_Name__c', 'Test');
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
		//create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('ContactId', lContact[0].Id);
        sObj.put('AccountId', lAccount[0].Id);
        sObj.put('Forecast_Product__c','Product 360 (Media Manager)');
         sObj.put('Environment__c','QA');
        sObj.put('Support_Account__c', lAccount1[0].Id);
        sObj.put('RecordTypeId', rt1.Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
        
    }
    @isTest
    static void testAllMethods(){
		
        Case cse = [Select Id,Support_Account__c,Support_Account__r.Name, Forecast_Product__c,Environment__c,Engagement__c, Engagement__r.Status__c From Case Limit 1];
		Account acc = [Select Id from Account Limit 1];
        Contact con = [Select Id from Contact Limit 1];
        Incident__c inci=[Select Id,Incident_Id__c from Incident__c limit 1];
        Engagement__c eng = [Select Id from Engagement__c Limit 1];
        
       	List<Panopta_Org__mdt> metadata = [Select Id from Panopta_Org__mdt];
            
        Test.startTest();
        List<Panopta_Org__mdt> panoptaOrgs = Panopta_Org__mdt.getAll().values();
        System.debug('asd'+panoptaOrgs);
        panoptaIncidentController pIc=new panoptaIncidentController();
        List<Incident__c> getAllI=panoptaIncidentController.getPanopataIncidents(cse.Id, '', 'searchTerm');
        List<Case_Incident__c> getCI=panoptaIncidentController.getCaseIncidents(cse.Id, '');
        Test.setMock(HTTPCalloutMock.class, new CalloutRestMock());
        String userid = String.valueof(UserInfo.getUserId());  
        String returnresponse = GetInfoPanoptaAPI.checkuser(userid); 
        List<Case_Incident__c> attach= panoptaIncidentController.attachIncidentToCase(cse.Id,inci.Id,returnresponse);
        
        String getS=panoptaIncidentController.detachIncidentFromCase(cse.id, inci.Id);
        Test.stopTest();
    }
}