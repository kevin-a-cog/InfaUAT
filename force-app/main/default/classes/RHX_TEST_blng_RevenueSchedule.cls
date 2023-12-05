@isTest(SeeAllData=true)
public class RHX_TEST_blng_RevenueSchedule {
   static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id , Revenue_Agreement__r.Stage__c 
                                    FROM blng__RevenueSchedule__c 
                                    WHERE Revenue_Agreement__r.Stage__c = 'Draft' 
                                    ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new blng__RevenueSchedule__c()
            );
        }
      rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}