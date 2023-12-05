@isTest
public class TestContractRenewalTypeBatch_Schedule {
    /**
* this method is testschedule to Test ContractRenewalTypeBatch_Schedule
*
* @param NA
* @return return-Void
* @throws exception - NA
*/
    static testMethod void testschedule() {
        Test.StartTest();
        ContractRenewalTypeBatch_Schedule activatePricebookBatch = new ContractRenewalTypeBatch_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Activate Pricebook Schedule', sch, activatePricebookBatch); 
        Test.stopTest();        
    }
}