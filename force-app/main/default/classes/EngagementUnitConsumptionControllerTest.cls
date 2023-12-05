@isTest
public class EngagementUnitConsumptionControllerTest {
    
    @isTest
    public static void fetchEngUnitConsumptions(){

        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Engagement__c();
        UtilityTestData.mEngagementData.put('Account__c', lNewCustomerAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementData);
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Engagement_Unit__c objNewRecord = new Engagement_Unit__c();
        objNewRecord.Account__c = lNewCustomerAccount[0].Id;
        objNewRecord.Awarded_By__c = 'Engagement';
        objNewRecord.Entitled_Units__c = 3;
        objNewRecord.Consumed_Units__c = 0;
        objNewRecord.Expiry_Date__c = System.today().addYears(1);
        objNewRecord.Start_Date__c = System.today();
        objNewRecord.Type__c = 'Success';
        objNewRecord.Status__c = 'Approved';
        insert objNewRecord;

        Engagement_Unit_Consumption__c engUnitCon = new Engagement_Unit_Consumption__c ();
        engUnitCon.Type__c = 'Success';
        engUnitCon.Engagement_Unit__c = objNewRecord.Id;
        engUnitCon.Initiated_By__c = 'Customer';
        engUnitCon.Number_of_Units__c = 1;
        engUnitCon.Status__c = 'Consumed';
        engUnitCon.Context_Id__c = lEngagement[0].Id;
        insert engUnitCon;

        EngagementUnitConsumptionController.getEngUnitConsumptionsType(objNewRecord.Id);
        EngagementUnitConsumptionController.getEngUnitConsumptionsRecordDetails(String.valueOf(objNewRecord.Id),'Engagement__c');
        List<String> engIdList = new List<String>();
        engIdList.add(String.valueOf(lEngagement[0].Id));
        EngagementUnitConsumptionController.updateEngUnitConsumptionStatus(engIdList, objNewRecord.Id, 'Completed');
        EngagementUnitConsumptionController.checkIsEngUnitUpdatable();
    }
}