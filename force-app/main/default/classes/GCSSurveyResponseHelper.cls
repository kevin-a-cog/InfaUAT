/*
    @created by       : Pavithra V
    @created on       : 31-05-2021
    @Purpose          : I2RT-563 : Create Engagement on Negative Feedback
    @Testclass        : GCSSurveyResponseHelperTest
    @JIRA             : I2RT-563
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        03/22/2022  I2RT-5471   T01     To not link the Engagement to the Case
 balajip        04/18/2022  I2RT-5882   T02     To assign the Engagement to the EM Queue if the Case is assgined to a Queue
 balajip        10/17/2022  I2RT-7328   T03     To account for CES Survey
 Isha Bansal    07/03/2023  I2RT-7752   T04     Case Survey - Make CES survey default and retire CSAT
 */
public class GCSSurveyResponseHelper {
    
    public static final String RECORD_TYPE_NAME_SUPPORT_ESCALATION = 'Support Escalation';

    //T03
    public static final List<String> CES_SURVEY_NAMES = new List<String>{'GCS Operations Case CES (GetFeedback)'};

    @InvocableMethod(label='Create Engagement' description='Create an Engagement On Negative Feedback')
    public static void createEngagement(List<Id> surveyResponseList){
        
        List<Case> lstCaseToUpdate = new List<Case>();
        
        for(GCS_Survey_Response__c response : [Select Id, Name, Comments__c, Overall_Satisfaction_Score__c, Case__c, Survey_Name__c,
                                                Case__r.CaseNumber, Case__r.RecordType.DeveloperName, Case__r.AccountId, //T03
                                                Case__r.Support_Account__c, Case__r.Support_Account__r.Name,
                                                Case__r.Engagement__c, Case__r.Engagement__r.Status__c,
                                                Case__r.OwnerId, Case__r.Owner_Manager_Id__c //I2RT-4911
                                               From GCS_Survey_Response__c Where Id in:surveyResponseList]){
            //I2RT-4422 - exclude Cases of Record Type Ask An Expert
            if(response.Case__c != null && !'Ask_An_Expert'.equals(response.Case__r.RecordType.DeveloperName)){ //T03
                Id recordTypeId = getRecordTypeId(RECORD_TYPE_NAME_SUPPORT_ESCALATION);
                Id ownerId;
                //I2RT-4911
                //check if there is a Case Owner Manager
                if(String.isNotEmpty(response.Case__r.Owner_Manager_Id__c)){
                    //set the Case Owner's manager as the Owner of the Engagement.
                    ownerId = response.Case__r.Owner_Manager_Id__c;
                //T02 check if the Case is owned by a User
                }else if('User'.equals(response.Case__r.OwnerId.getSobjectType().getDescribe().getName())){
                    //T01 assign the engagement to the Case Owner
                    ownerId = response.Case__r.OwnerId;
                }else{
                    //T02 assign the engagement to the EM Queue if the Case is assigned to a Queue.
                    ownerId = SkillService.mapQueueNameToQueueId.get(SkillService.getSkillByName(SkillService.SKILL_ESCALATION_MANAGER).Queue_Name__c);
                }

                //T03 - find the type of the Survey
                String surveyType = 'CES'; //T04
                if(CES_SURVEY_NAMES.contains(response.Survey_Name__c)){
                    surveyType = 'CES';
                }

                String description  = 'This GEMS case was created because the customer gave a ' + surveyType + ' Satisfaction Score of ';//T03
                description += response.Overall_Satisfaction_Score__c +' for case <b>'+ response.Case__r.CaseNumber + '</b>.<br><br>';
                description += 'Below are the Survey comments provided: <br>';
                description += response.Comments__c;
                
                Engagement__c engagement = new Engagement__c();
                engagement.RecordTypeId = recordTypeId;
                engagement.OwnerId = ownerId;
                engagement.Name = 'ENG:' + response.Case__r.Support_Account__r.Name;
                //T01 - added Case Number to the Title
                engagement.Title__c = 'Low ' + surveyType + ' Customer Satisfaction - Case ' + response.Case__r.CaseNumber; //T03
                engagement.Support_Account__c = response.Case__r.Support_Account__c;
                engagement.Account__c = response.Case__r.AccountId;
                //engagement.Severity__c = '';
                engagemenT.Detail__c = description;
                engagement.Category__c = 'Survey';
                engagement.Priority__c = 'P2';
                engagement.Source__c = 'Customer';
                insert engagement;
                engagement = [Select Id, Engagement_Number__c From Engagement__c Where Id = :engagement.Id];

                //T01 - create an entry in the junction object.
                Case_Escalation__c caseEscalation = new Case_Escalation__c();
                caseEscalation.Case__c = response.Case__c;
                caseEscalation.Escalation__c = engagement.Id;
                insert caseEscalation;

                //T01 - create case comment
                String commentText = 'Due to low ' + surveyType + ', a new \'Survey\' GEMS engagement '; //T03
                commentText += '<a href=\'/' + engagement.Id + '\' target=\'_self\'>' + engagement.Engagement_Number__c + '</a>';
                commentText += ' has been created.';
                
                Case_Comment__c caseComment = new Case_Comment__c();
                caseComment.Case__c = response.Case__c;
                CaseComment.Type__c = CaseCommentService.TYPE_ESCALATION;
                caseComment.Status__c = CaseCommentService.STATUS_SUBMITTED;
                caseComment.Inbound__c = false;
                caseComment.Visibility__c =  CaseCommentService.VISIBILITY_INTERNAL;
                caseComment.Comment__c = commentText;

                insert caseComment;
            }
        }
    } 
    
    public static Id getRecordTypeId(String recordTypeName){
        Schema.DescribeSObjectResult engagementSchema = Schema.SObjectType.Engagement__c;
        return engagementSchema.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();       
    }
}