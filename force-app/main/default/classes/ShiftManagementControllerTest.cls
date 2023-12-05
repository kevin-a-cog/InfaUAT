@isTest
class ShiftManagementControllerTest {
     @testSetup
    static void setupObjectTestData() {
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        
        
        
    }
    static testMethod void testMethods(){
         User adminUser = [select id from user where username = 'prmTestAdmn@m.t' limit 1];
         BusinessHours stdBusinessHours = [select id,TimeZoneSidKey  from BusinessHours where Name = 'Default'];
    System.debug('asd'+stdBusinessHours);
         ShiftManagementController shft=new ShiftManagementController();
        Boolean bm=ShiftManagementController.isShiftManager(adminUser.Id);
         Shift_Plan__c sp = new Shift_Plan__c(
            Name='Some Plan', 
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c =  Date.today().addDays(5),
            Type__c = 'Weekend Support (US)'
        );
        insert sp;

        Shift_Request__c sr = new Shift_Request__c(
            Shift_Plan__c = sp.Id,
            Resource_Count__c = 5,
            Allocation_Type__c = 'Weekend Support (US)',
            Business_Hours__c = stdBusinessHours.id
        );
        insert sr;

        Shift_Allocation__c sa = new Shift_Allocation__c(
            Shift_Request__c = sr.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(3),
            Status__c = 'Pending'
        );
     sObject sObj;
        
        sObj = new ServiceResource();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mServiceResouce);
        sObj.put('Name', 'Test Name');
        sObj.put('RelatedRecordId',adminUser.Id);
        Test.startTest();
            insert sa;
        List<ServiceResource> lServiceResources = (List<ServiceResource>)UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.stopTest();
        Datetime myDateTime = Datetime.now();
        datetime newDate = myDateTime.addDays(2);
        String iso8601 = Datetime.now().format('yyyy-MM-dd');
        String iso86011=newDate.format('yyyy-MM-dd');
        ShiftManagementController.getChartData(true,adminUser.Id,iso8601,iso86011,1);
        ShiftManagementController.getResourceData(adminUser.Id,iso8601,iso86011,1);
        List<Shift_Request__c> lstShiftRequestToUpsert=new List<Shift_Request__c>();
        lstShiftRequestToUpsert.add(sr);
        List<Id> lstid=new List<Id>();
        lstid.add(sr.id);
        Set<Id> gets=new Set<Id>();
        gets.add(sr.id);
        List<String> lstn=new List<String>();
        ShiftManagementController.createShiftPlanAndRequest(lstShiftRequestToUpsert,lstn);
        ShiftManagementController.getShiftRequestForShiftPlan(sp.id);
        ShiftManagementController.getUserDetails(adminUser.Id);
        ShiftManagementController.getMyTeam();
        ShiftManagementController.createShiftAllocation(iso8601,iso86011,adminUser.Id,sr.id,'78457878','WFO','General');
        ShiftManagementController.getShiftPlanWithRequests(sp.id);
        ShiftManagementController.canEditShiftPlan(sp.id);
        ShiftManagementController.getWorkItemId(lstid);
        ShiftManagementController.searchResource('Test',true);
        ShiftManagementController.getOOODates(adminUser.Id);
        ShiftManagementController.getProcessWorkitemRequest(adminUser.Id,'Approved');
        //ShiftManagementController.approveOrRejectRecord(adminUser.Id,'Approved');
        //ShiftManagementController.approveOrRejectRecord(gets,'Approved');
        //ShiftManagementController.deleteShiftPlan(String.valueOf(sp.id));
    }
}