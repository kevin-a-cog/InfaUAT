@isTest(SeeAllData=true)
public class RHX_TEST_Related_Risk_Product {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Related_Risk_Product__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Related_Risk_Product__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}