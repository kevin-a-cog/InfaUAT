@isTest(SeeAllData=true)
public class RHX_TEST_Related_Account_Plan {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Related_Account_Plan__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Related_Account_Plan__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}