@isTest
public class eventBeforeTriggerTest {
    
    @isTest
    private static void testUnit1(){ 
          String SupportAccount  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        sObject sObj = new Account();    
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
         sObj.put('RecordTypeId',SupportAccount);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create a Case record
        sObj = new Case();//Scheduled
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        sObj.put('Status', 'Booked');
        List<Case> lCase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Lead();
        UtilityTestData.mLeadData.put('LastName', 'Test LastName');
        UtilityTestData.mLeadData.put('Company', 'Test Company');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);     
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
          //Create ServiceAppointment
        sObj = new ServiceAppointment();//
        sObj.put('ParentRecordId', lAccount[0].Id);
        sObj.put('SchedStartTime', System.now().addDays(-1));
        sObj.put('SchedEndTime', System.now().addDays(1));
        sObj.put('AppointmentType', 'Ask_An_Expert');
        sObj.put('Case__c', lCase[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceAppointment);

        List<ServiceAppointment> lServiceAppointment = (List<ServiceAppointment>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        UtilityTestData.mEventData.put('WhoId', lLead[0].Id);
        
        sObj = new Event();
       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEventData);
       // sObj.put('ServiceAppointmentId', lServiceAppointment[0].Id);
        system.debug('sObj event --- > ' + sObj);
        List<Event> lEvent = (List<Event>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Lead l1 = [select id,email,No_of_Attempts__c from lead where id =:lLead[0].id limit 1];
        System.assertEquals(l1.No_of_Attempts__c,1);
        
        Test.stopTest();
        
    }

}