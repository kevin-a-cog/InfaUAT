/*
Trigger:        GCSSurveyResponseTriggerHelper
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Handles the trigger logic for the object GCS_Survey_Response__c

Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
balajip        07/13/2022  I2RT-6153   T01     To replace GCS_Segment__c field with Segment__c field in the notifications
Isha Bansal    03/07/2023  I2RT-7752   T02     Case Survey - Make CES survey default and retire CSAT
balajip        04/24/2023  I2RT-8148   T03     To add more information in the chatter post.
balajip        04/27/2023  I2RT-8287   T04     added null check while adding Contact information in the feeditem.
*/

public without sharing class GCSSurveyResponseTriggerHelper {
    
    /**
    * Notifies the Case Team members on create/update
    * 
    * @param parameter- mapOld - map of old zIssue
    * @param parameter- mapNew - map of new zIssue
    * @return return-void
    * @throws exception - NA
    */
    public void notifyCaseTeam(Map<Id, GCS_Survey_Response__c> mapNew, Map<Id, GCS_Survey_Response__c> mapOld){               
        Set<Id> setCaseId = new Set<Id>();
        for(GCS_Survey_Response__c surveyResponse : mapNew.values()){
            if(surveyResponse.Case__c != null){
                setCaseId.add(surveyResponse.Case__c);
            }
        }
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, CaseNumber, Subject, Forecast_Product__c, Support_Account__c,
                                        AccountId, OwnerId, Owner_Name__c,
                                        Priority, Support_Level__c, Version__c, Segment__c, Acc__c, //T01
                                        Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                                        Account.Name, Account.New_Org_Account_Number__c 
                                        From Case Where Id in :setCaseId]);

        List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
        
        for(GCS_Survey_Response__c surveyResponse : mapNew.values()){
            if(surveyResponse.Case__c != null){
                ConnectApi.FeedItemInput feedItemInput = getFeedItem(surveyResponse, mapCaseIdToCase.get(surveyResponse.Case__c));
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                lstBatchInput.add(batchInput);    
            }
        }

        if(!Test.isRunningTest()){
            if(!lstBatchInput.isEmpty()){
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
            }
        }
    }

    private static ConnectApi.FeedItemInput getFeedItem(GCS_Survey_Response__c surveyResponse, Case cse){
        //I2RT-4916 - check if the Product is selected on the Case
        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }
        
        String content = 'CES Response: ' + productContent + cse.Priority 
                                + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                + ', ' + cse.Support_Level__c; //T02
                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputText('Contact: '));
        if(surveyResponse.Contact__c != null){//T04 added null check
            messageBodyInput.messageSegments.add(ChatterService.inputLink(surveyResponse.Contact__c));
        }else{
            messageBodyInput.messageSegments.add(ChatterService.inputText(surveyResponse.Respondent_email_ID__c));
        }
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Overall Satisfaction Score', String.valueOf(surveyResponse.Overall_Satisfaction_Score__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Satisfaction', surveyResponse.Satisfaction__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Interaction', surveyResponse.Interaction__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Feedback Influenced By', surveyResponse.Feedback_Influenced_By__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('What could have done better', surveyResponse.Comments__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Comments', surveyResponse.Optional_Comments__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Owner / Team', cse.Owner_Name__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.Segment__c)); //T01
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
        messageBodyInput.messageSegments.add(ChatterService.inputHyperlink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        Set<Id> setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, true, false, false);
        for(Id userId : setUserIdToPost){
            messageBodyInput.messageSegments.add(ChatterService.inputSpace());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(userId));    
        }
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = cse.Id;
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

        return feedItemInput;
    }
}