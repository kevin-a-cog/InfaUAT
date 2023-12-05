/*
Class:          OperationsSchedulerControllerTest
@Author:        Vignesh Divakaran
@Created Date:  01-Oct-2021
@Description:   Test class for OperationsSchedulerController class.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class OperationsSchedulerControllerTest {

    public static String PROD_ENVIRONMENT = 'Production';
    
    @TestSetup
    static void setupObjectTestData(){

        sObject sObj;       

        Id OperationsCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        Id CustomerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id SupportAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId();
        Id ServiceAppointmentOperationsRecordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Operations').getRecordTypeId();

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
        
        //Create Operating Hours
        OperatingHours OH = new OperatingHours();
        OH.Name = 'GCS Operations Case Operating hours';
        OH.Description = 'Operating hours for GCS Operations';
        OH.TimeZone = 'GMT';
        insert OH;

        //Create TimeSlots
        List<TimeSlot> TimeSlots = new List<TimeSlot>();
        List<String> dayofweek = new List<String>();
        dayOfWeek.add('Sunday');
        dayOfWeek.add('Monday');
        dayOfWeek.add('Tuesday');
        dayofweek.add('Wednesday');
        dayofweek.add('Thursday');
        dayofweek.add('Friday');
        dayOfWeek.add('Saturday');

        for(String day : dayOfWeek){
            TimeSlot TS = new TimeSlot();
            TS.DayOfWeek = day;
            TS.StartTime = Time.newInstance(0,0,0,0);
            TS.EndTime = Time.newInstance(23,45,0,0);
            TS.MaxAppointments = 1;
            TS.Type = 'Normal';
            TS.OperatingHoursId = OH.Id;
            TimeSlots.add(TS);
        }
        insert TimeSlots;

        Id userId;
        userId = [Select Id FROM User WHERE Profile.Name = 'Employee-Restricted' AND Name = 'GCS Service Account Operations' LIMIT 1]?.Id;
        if(String.isEmpty(userId)){
            userId = [Select Id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1]?.Id;
        }

        //Create Service Resource
        ServiceResource SR = new ServiceResource();
        SR.Name = 'GCS Operations';
        SR.IsActive = true;
        SR.Description = '';
        SR.ResourceType = 'T';
        SR.RelatedRecordId = userId;
        insert SR;

        //Create Service Territory
        ServiceTerritory ST = new ServiceTerritory();
        ST.Name = 'GCS Operations';
        ST.IsActive = true;
        ST.City = 'Redwood City';
        ST.Country = 'United States';
        ST.GeocodeAccuracy = 'Address';
        ST.Latitude = double.valueOf('37.511268');
        ST.Longitude = double.valueOf('-122.20475');
        ST.PostalCode = '94063';
        ST.State = 'CA';
        ST.Street = '2100 Seaport Boulevard';
        ST.OperatingHoursId = OH.Id;
        insert ST;

        //Create Service Territory Member
        ServiceTerritoryMember STM = new ServiceTerritoryMember();
        STM.TerritoryType = 'P';
        STM.ServiceResourceId = SR.Id;
        STM.ServiceTerritoryId =  ST.Id;
        STM.OperatingHoursId = OH.Id;
        STM.EffectiveStartDate = DateTime.newInstance(System.today(),Time.newInstance(0,0,0,0));
        insert STM;

        //Create Service Appointments
        List<ServiceAppointment> ServiceAppointments = new List<ServiceAppointment>();
        ServiceAppointment SA1 = new ServiceAppointment();       
        SA1.Environment_Type__c = PROD_ENVIRONMENT;
        SA1.AppointmentType = 'Operations';
        SA1.Subject = 'Operations Appointment';
        SA1.Description = 'Operations Appointment';
        SA1.ParentRecordId = lNewSupportAccount[0].Id;
        SA1.RecordTypeId = ServiceAppointmentOperationsRecordTypeId;
        SA1.SchedStartTime = DateTime.newInstance(System.today()+1, Time.newInstance(4,0,0,0));
        SA1.SchedEndTime = DateTime.newInstance(System.today()+1, Time.newInstance(5,0,0,0));
        ServiceAppointments.add(SA1);

        ServiceAppointment SA2 = new ServiceAppointment();        
        SA2.Environment_Type__c = PROD_ENVIRONMENT;
        SA2.AppointmentType = 'Operations';
        SA2.Subject = 'Operations Appointment';
        SA2.Description = 'Operations Appointment';
        SA2.ParentRecordId = lNewSupportAccount[0].Id;
        SA2.RecordTypeId = ServiceAppointmentOperationsRecordTypeId;
        SA2.SchedStartTime = DateTime.newInstanceGMT(System.today()+1, Time.newInstance(5,0,0,0));
        SA2.SchedEndTime = DateTime.newInstanceGMT(System.today()+1, Time.newInstance(6,0,0,0));
        ServiceAppointments.add(SA2);

        insert ServiceAppointments;

        //Create a TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //Create Contact record
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);
        UtilityTestData.mContactData.put('Email','test@test.com');
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
        sObj.put('Environment__c', PROD_ENVIRONMENT);
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',OperationsCaseRecordTypeId);
        sObj.put('AccountId', lNewCustomerAccount[0].Id);
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});  

    }

    public static testmethod void getAvailableSlots(){
        Test.startTest();
        OperationsSchedulerController.getAvailableSlots('P1', PROD_ENVIRONMENT);
        OperationsSchedulerController.getAvailableSlots('P2', PROD_ENVIRONMENT);
        OperationsSchedulerController.getAvailableSlots('P1', 'UAT');
        OperationsSchedulerController.getAvailableSlots('P3', 'UAT');
        Test.stopTest();
    }

    public static testmethod void createSession(){
        Test.startTest();
        Case c = [Select Id,AccountId,Support_Account__c,Priority,Environment__c,ContactId,Description FROM Case LIMIT 1];
        List<DateTime> slotSelected = new List<DateTime>();
        List<List<OperationsSchedulerController.OperationsSchedulerWrapper>> availableSlots = OperationsSchedulerController.getAvailableSlots(c.Priority, c.Environment__c).values();
        slotSelected.add(availableSlots[0][0].startDT);
        slotSelected.add(availableSlots[0][0].endDT);
        OperationsSchedulerController.createServiceAppointment(c, slotSelected, 'Create');
        Test.stopTest();
    }

    public static testmethod void rescheduleSession(){
        Test.startTest();
        Case c = [Select Id,AccountId,Support_Account__c,Priority,Environment__c,ContactId,Description FROM Case LIMIT 1];
        c.Priority = 'P3';
        update c;
        ServiceAppointment SA = [Select Id from ServiceAppointment LIMIT 1];
        SA.Case__c = c.Id;
        update SA;
        List<DateTime> slotSelected = new List<DateTime>();
        List<List<OperationsSchedulerController.OperationsSchedulerWrapper>> availableSlots = OperationsSchedulerController.getRescheduleSlots(c.Id).values();
        slotSelected.add(availableSlots[0][0].startDT);
        slotSelected.add(availableSlots[0][0].endDT);
        OperationsSchedulerController.rescheduleSession(c.Id, slotSelected, 'Reschedule');
        OperationsSchedulerController.rescheduleSession(c.Id, slotSelected, '');
        Test.stopTest();
    }

    public static testmethod void general(){
        Test.startTest();
        OperationsSchedulerController.offsetWeekendDayHour(DateTime.newInstanceGMT(2022,1,2,0,0,0));
        OperationsSchedulerController.offsetWeekendDayHour(DateTime.newInstanceGMT(2022,1,3,0,0,0));
        OperationsSchedulerController.offsetWeekendDayHour(DateTime.newInstanceGMT(2022,1,4,0,0,0));
        OperationsSchedulerController.offsetWeekendDayHour(DateTime.newInstanceGMT(2022,1,5,0,0,0));
        OperationsSchedulerController.calculateOffSetHours(System.now(), System.now().addHours(1));
        OperationsSchedulerController.calculateOffSetHours(System.now(), System.now().addHours(-1));
        Test.stopTest();
    }
}