@isTest
public class AskAnExpertUpcomingBookingCtrlTest {
    //
    
    
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
        sObj = new Case();//Scheduled
	    sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        sObj.put('Status', 'Booked');
        List<Case> lCase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create ServiceAppointment
        sObj = new ServiceAppointment();//
        sObj.put('ParentRecordId', lAccount[0].Id);
        sObj.put('SchedStartTime', System.now().addDays(-1));
        sObj.put('SchedEndTime', System.now().addDays(1));
        sObj.put('AppointmentType', 'Ask_An_Expert');
        sObj.put('Case__c', lCase[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }
    
    @isTest
    static void testcollabClosure(){
		List<Account> lAccount = [Select Id from Account];
        List<Case> lCase = [Select Id From Case Limit 1];
        esAskAnExpertUpcomingBookingController.fetchSupportAccountAppoinmentBookings(lAccount[0].Id);
    }

}