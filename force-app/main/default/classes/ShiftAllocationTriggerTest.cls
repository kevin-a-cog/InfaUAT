@isTest
class ShiftAllocationTriggerTest {
    
    @isTest
    static void testCountOnApprovedShiftAllocation_Insert() {
        Shift_Plan__c sp = new Shift_Plan__c(
            Name='Some Plan', 
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c =  Date.today().addDays(5)
        );
        insert sp;

        Shift_Request__c sr = new Shift_Request__c(
            Shift_Plan__c = sp.Id,
            Resource_Count__c = 5
        );
        insert sr;

        Shift_Allocation__c sa = new Shift_Allocation__c(
            Shift_Request__c = sr.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(3),
            Status__c = 'Pending'
        );

        Test.startTest();
            insert sa;
        Test.stopTest();
        //System.assertEquals(1, [SELECT Id, Total_Approved_Allocation__c FROM Shift_Request__c][0].Total_Approved_Allocation__c);

    }

    @isTest
    static void testCountOnApprovedShiftAllocation_Update() {
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        SObject sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);

        ServiceResource objServiceResource=new ServiceResource();
        objServiceResource.Name='Test Resource';
        objServiceResource.RelatedRecordId=UserInfo.getUserId();
        objServiceResource.ResourceType='T';
        objServiceResource.IsActive=True;
        //objServiceResource.Status_Code__c='SB';
        insert objServiceResource;

        Shift_Plan__c sp = new Shift_Plan__c(
            Name='Some Plan', 
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c =  Date.today().addDays(5)
        );
        insert sp;

        Shift_Request__c sr = new Shift_Request__c(
            Allocation_Type__c = 'Holiday (India)',
            Skill__c = lstSObj[0].Id,
            Shift_Plan__c = sp.Id,
            Resource_Count__c = 5
        );
        insert sr;

        Shift_Allocation__c sa = new Shift_Allocation__c(
            Shift_Request__c = sr.Id,
            Service_Resource__c = objServiceResource.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(3),
            Status__c = 'Pending'
        );
        insert sa;
        //System.assertEquals(1, [SELECT Id, Total_Approved_Allocation__c FROM Shift_Request__c][0].Total_Approved_Allocation__c);
        sa.Status__c = 'Approved';
        Test.startTest();
            update sa;
        Test.stopTest();
        //System.assertEquals(0, [SELECT Id, Total_Approved_Allocation__c FROM Shift_Request__c][0].Total_Approved_Allocation__c);

    }

    @isTest
    static void testCountOnApprovedShiftAllocation_Delete() {
        Shift_Plan__c sp = new Shift_Plan__c(
            Name='Some Plan', 
            Start_Date__c = Date.today().addDays(-2),
            End_Date__c =  Date.today().addDays(5)
        );
        insert sp;

        Shift_Request__c sr = new Shift_Request__c(
            Shift_Plan__c = sp.Id,
            Resource_Count__c = 5
        );
        insert sr;

        Shift_Allocation__c sa = new Shift_Allocation__c(
            Shift_Request__c = sr.Id,
            Start_Date__c = Date.today().addDays(1),
            End_Date__c = Date.today().addDays(3),
            Status__c = 'Pending'
        );
        insert sa;
        //System.assertEquals(1, [SELECT Id, Total_Approved_Allocation__c FROM Shift_Request__c][0].Total_Approved_Allocation__c);
        Test.startTest();
            delete sa;
        Test.stopTest();
        //System.assertEquals(0, [SELECT Id, Total_Approved_Allocation__c FROM Shift_Request__c][0].Total_Approved_Allocation__c);

    }
}