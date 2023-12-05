@isTest(SeeAllData=true)
public class RHX_TEST_AccountContactRelation {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM AccountContactRelation ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AccountContactRelation()
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}