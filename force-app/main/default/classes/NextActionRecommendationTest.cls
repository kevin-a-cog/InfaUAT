/*
Class:          NextActionRecommendation 

@Author:        Ambica P
@Created Date:  30 May 2020
@Description:   Test class for NextActionRecommendation
*/

@isTest (seeAllData=false)
public class NextActionRecommendationTest {
    
    @testSetup
    static void setupObjectTestData() {
        
            sObject sObj = new Next_Action_Recommendation__c();
        	UtilityTestData.mNextActionRecommendation.put('Risk_Type__c','Adoption');
            UtilityTestData.mNextActionRecommendation.put('Risk_Reason__c','Lack of Sponsor');
            UtilityTestData.mNextActionRecommendation.put('Next_Action_Summary__c','test action summary');  
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNextActionRecommendation);
			List<Next_Action_Recommendation__c> lNextActionRec = (List<Next_Action_Recommendation__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
    
            sObj = new Risk_Issue__c();
        	UtilityTestData.mRiskIssue.put('Type__c','Adoption');
            UtilityTestData.mRiskIssue.put('Risk_Reason__c','Lack of Sponsor');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRiskIssue);
			List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    public static testMethod void testNextActionRec (){
        
         Risk_Issue__c lstriskRecord = [Select id,Type__c,Risk_Reason__c,Risk_Reason_Secondary__c from Risk_Issue__c limit 1];

         List<Next_Action_Recommendation__c> lstRecommendation = NextActionRecommendation.getRecommendation(lstriskRecord.id);
        
      //  system.assertEquals(lstRecommendation.size(), 1);
        
    }
    
    
    

}