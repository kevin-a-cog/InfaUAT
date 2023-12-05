//ErpSiteExemptStatusUpdateBatchTest
@isTest
private class ErpSiteExemptStatusUpdateBatchTest {
    @testSetup
    static void setupObjectTestData() {
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        system.runAs(adminUser){

            Id ProspectAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            
            sObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name','Test Account 1');
            UtilityTestData.mAccountData.put('RecordTypeId', ProspectAccountRecType);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData); 
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
    }


    @isTest static void testErpSiteExemptStatusBatch(){

        List<Account> lAccount = [SELECT Id FROM Account];
        sObject sObj = new Account(Id = lAccount [0].Id,Peoplesoft_External_ID__c = 'TestErpId');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        lAccount = (List<Account>) UtilityTest.makeUpdate(new List<sObject>{sObj});

        List<ERP_Company__c> lstErpCustomer = [SELECT Id FROM ERP_Company__c];
        System.assertEquals(lstErpCustomer.size(),1);  
        Test.startTest();
        ERP_Site__c erpSite = new ERP_Site__c(ERP_Company__c = lstErpCustomer[0].Id);
        erpSite.Exempt_Status__c = 'Exempt';
        erpSite.Exemption_On_File__c = false;
        Insert erpSite; 

        erpSite = [SELECT Id,Exempt_Status__c FROM ERP_Site__c LIMIT 1];
        erpSite.Exempt_Status_Date_Stamp__c = System.TODAY();
        update erpSite;
		
        ErpSiteExemptStatusUpdateBatch exemptStatus = new ErpSiteExemptStatusUpdateBatch();
        Id batchId = Database.executeBatch(exemptStatus);         
        Test.stopTest();

        erpSite = [SELECT Id,Exempt_Status__c FROM ERP_Site__c LIMIT 1]; 
        System.assertEquals(erpSite.Exempt_Status__c,'Override');      
    } 
    
    // this method is to test ContractSubsStatusUpdate_Schedule class
    @isTest static void testErpSiteExemptStatusBatch_Schedule(){
        ErpSiteExemptStatusUpdateBatch exemptStatus = new ErpSiteExemptStatusUpdateBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Sched', sch, exemptStatus);         
    }
}