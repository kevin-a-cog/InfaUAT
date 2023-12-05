@isTest(SeeAllData=true)
public class RHX_TEST_Org_Entitlement {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM Org_Entitlement__c ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Org_Entitlement__c()
            );
        }
        

       rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}