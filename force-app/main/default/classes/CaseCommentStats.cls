public class CaseCommentStats {
/**Get the list of email tempates **/
@AuraEnabled
public static List<CaseCommentEmailStat__c> getCaseCommetEmailDetails(String commentId){

    System.debug('check1'+commentId);
    List<CaseCommentEmailStat__c> getAllStats=[Select id,Case_Comment__c,Email__c,Delivery__c,Email_Clicked__c,Email_Opened__c from 
                                                    CaseCommentEmailStat__c where Case_Comment__c=:commentId];
    System.debug('check'+getAllStats);
    
        return getAllStats;
	
    
    
}
}