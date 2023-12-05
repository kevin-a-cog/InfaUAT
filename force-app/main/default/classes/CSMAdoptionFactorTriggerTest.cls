/*
 * Name         :   CSMAdoptionFactorTriggerTest
 * Author       :   Deva M
 * Created Date :   22-Apr-2022
 * Description  :   Test class for Adoption Trigger

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Deva M                 22-Apr-2022       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public class CSMAdoptionFactorTriggerTest {
      /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');               
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
          sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  

         Adoption_Factor__c objPaf = new Adoption_Factor__c(Plan__c=lPlan[0].Id,Status__c='Waiting for CSM Input');
         objPaf.Product__c = 'Good';
         objPaf.Project__c = 'Good';
         objPaf.Engagement__c = 'Good';
         objPaf.Impact__c = 'Low';
         insert objPaf;
    }

    
    /*
     Method Name : testCreatePAF
     Description : Testing fetching records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatePAF() {      
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
             //Create PAf record on creating of plan record
        List<Adoption_Factor__c> adoptionRecordsToInsert =  new List<Adoption_Factor__c>();
       
        Adoption_Factor__c objPaf;
      
        for(Plan__c obj:[SELECT Id FROM Plan__c]){
            objPaf = new Adoption_Factor__c(Plan__c=objPlan.Id,Status__c='Waiting for CSM Input');
            objPaf.Product__c = 'Good';
            objPaf.Project__c = 'Good';
            objPaf.Engagement__c = 'Good';
            objPaf.Impact__c = 'Good';
            adoptionRecordsToInsert.add(objPaf);
        }
        try{
        if(adoptionRecordsToInsert.size()>0){
            insert adoptionRecordsToInsert;
            //delete adoptionRecordsToInsert;
        }
        }catch(Exception e){
            system.debug('Exception in test class');
        }
        
        
    }

     /*
     Method Name : testUpdatePAF
     Description : Testing fetching records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testUpdatePAF() {     
        List<Adoption_Factor__c> adoptionRecordsToUpdate =  new List<Adoption_Factor__c>(); 
        for(Adoption_Factor__c obj:[SELECT Id,CSM_Comments__c, CSM_Manager_Comments__c, Status__c from Adoption_Factor__c ]){
            obj.CSM_Comments__c='Test';
            obj.CSM_Manager_Comments__c='Test';
            obj.Status__c='Final';
            adoptionRecordsToUpdate.add(obj);
        }
        if(adoptionRecordsToUpdate.size()>0){
            update adoptionRecordsToUpdate;
        }

    }
}