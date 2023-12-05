/*
@created by       : Sandeep Duggi
@created on       : 12/21/2021
@Purpose          : Trigger on CaseCommentEmailStat 
@Testclass        : 
@JIRA             : I2RT-5131



Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag

****************************************************************************************************

*/
trigger CaseCommentEmailStatTrigger on CaseCommentEmailStat__c (after Insert) {
    List < String > Emails = new List < String >();
    for (CaseCommentEmailStat__c cce: Trigger.new) {
        system.debug('cce'+json.serializePretty(cce));
        if (cce.Delivery__c == 'Bounced' || cce.Delivery__c == 'Dropped' && cce.Email__c != null) {
            system.debug('inside if ');
            Emails.add(cce.Email__c );
        }
    }
    system.debug('Emails'+Emails);
    // make a api call to delete bounce 
    CaseCommentEmailStatHandler.ApiCallToDeleteBounces(Emails);
    
}