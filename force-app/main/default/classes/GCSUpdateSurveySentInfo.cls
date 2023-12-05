/*
    @created by       : Pavithra
    @created on       : 27/09/2021
    @Purpose          : Apex Class to get the template dynamically for updating case comment
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        10/17/2022  I2RT-7328   T01     To account for CES Survey
 balajip        11/23/2022  I2RT-7513   T02     to fix the exception that occurs when 
                                                    multiple Case Ids are passed to the method getTemplate.
Isha Bansal     07/02/2023  I2RT-7752   T03     Retire CSAT 
 */
public class GCSUpdateSurveySentInfo {
    
    public static globalApexManager GAM = new globalApexManager();     
    public static String CASE_COMMENT_FOR_SURVEY_TEMPLATE = 'SurveyAcknowledgmentTemplate';
    
    @InvocableMethod
    public static void getTemplate(List<String> caseId) {
        //T02
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, RecordType.DeveloperName, Delivery_Method__c 
                                                            From Case Where Id in :caseId]);

		List<Case_Comment__c> surveyCaseCommentList = new List<Case_Comment__c>();
        
        EmailTemplate template = [Select Id, Subject, Body, HtmlValue From EmailTemplate Where Name = :CASE_COMMENT_FOR_SURVEY_TEMPLATE LIMIT 1];
        
        if(template <> null){
            for(String recordId : caseId){
                //T02
                Case cse = mapCaseIdToCase.get(recordId);
                
                //Get the Case Comment Body from the Email Template
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id,null,recordId);
                String commentText = mail.gethtmlBody(); //T01

                //T01
                /* T03 ->commented this block
                if(cse.RecordType.DeveloperName == 'Operations' && cse.Delivery_Method__c == 'Hosted Single Tenant'){ //T03
                    commentText = commentText.replace('CSAT','CES');
                }
                */
                
                //Create Case comment for the Case
                Case_Comment__c caseComment = new Case_Comment__c();
                caseComment.Comment__c = commentText; //T01
                caseComment.Case__c = recordId;
                caseComment.Inbound__c = false;
                caseComment.Visibility__c = 'Internal';
                caseComment.Status__c = 'Submitted';
                
                surveyCaseCommentList.add(caseComment);
            }
            
            if(surveyCaseCommentList?.size()>0){
                try{
                    insert surveyCaseCommentList;
                }catch(Exception ex){
                    GAM.CreateExceptionRecords( 'GCSUpdateSurveySentInfo : getTemplate', 'Exception in Case Comment Creation after survey is sent.', ex.getMessage());
                }
            }
        }
    }
}