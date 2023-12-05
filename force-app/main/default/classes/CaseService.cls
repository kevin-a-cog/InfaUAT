/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to Case Object
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
Amarender       6/10/2021   I2RT-4719   T01     Execute SOQL & DML operations for objects in "Without Sharing" 
Venky           12/16/2021              T02     SALT Weightage recalculation when engageemnt is created
balajip         07/13/2022  I2RT-6153   T03     To replace GCS_Segment__c field with Segment__c field in the notifications
 */
public with sharing class CaseService {

    public CaseService() {

    }

    //get the Id of the Support Queue corresponding to the given Product
    public static Id getProductQueue(String productName){
        Id queueId = System.label.Support_Default_Queue_Id;

        ProfileSkill profileSkill = SkillService.getSkillByName(productName);
        if(profileSkill != null){
            if(SkillService.mapQueueNameToQueueId.containsKey(profileSkill.Queue_Name__c)){
                queueId = SkillService.mapQueueNameToQueueId.get(profileSkill.Queue_Name__c);
            }
        }

        return queueId;
    }

    //get the Id of the Support Queue corresponding to the given Product
    public static Id getEscalationQueue(){
        Id queueId = System.label.Support_Default_Queue_Id;

        ProfileSkill profileSkill = SkillService.getSkillByName('Escalation Manager');
        if(profileSkill != null){
            if(SkillService.mapQueueNameToQueueId.containsKey(profileSkill.Queue_Name__c)){
                queueId = SkillService.mapQueueNameToQueueId.get(profileSkill.Queue_Name__c);
            }
        }

        return queueId;
    }

    public static void switchOwner(Id caseId, Id newOwnerId) {
        List<Case> lstCase = [Select Id, OwnerId From Case Where Id = :caseId];
        Id currentOwnerId;

        if(!lstCase.isEmpty()){
            Case cse = lstCase.get(0);
            currentOwnerId = cse.OwnerId;
            cse.OwnerId = newOwnerId;
            update cse;

            CaseTeamService.swapOwner(caseId, newOwnerId, currentOwnerId);
            //postToChatterOwnerChange(caseId, newOwnerId, currentOwnerId);
        }
    }

    //I2RT-4421
    public static void requestAttn(Id caseId, String requestType, String comment,String selectedImapact,Date estimateDate) {
        List<Case> lstCase = [Select Id, CaseNumber, Subject, IsEscalated, Forecast_Product__c, 
                                    AccountId, OwnerId, Owner_Name__c, Attention_Request__c,
                                    Priority, Support_Level__c, Version__c, Segment__c, Acc__c, //T03
                                    Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                                    Account.Name, Account.New_Org_Account_Number__c, Escalation_Attention__c,
                              		Business_Impact__c,Estimated_Date_for_Milestone__c 
                                From Case Where Id = :caseId];
        System.debug('lstCase-->'+lstCase);
        if(!lstCase.isEmpty()){
            Case cse = lstCase.get(0);
            //I2RT-4421
            if(String.isNotEmpty(selectedImapact) )
                cse.Business_Impact__c = selectedImapact;             
            
            if( estimateDate != null )
                   cse.Estimated_Date_for_Milestone__c = estimateDate;
            //I2RT-4421    
            if(String.isNotEmpty(requestType)){
                cse.Attention_Request__c = requestType;
                cse.Escalation_Attention__c = true;
                cse.Next_Action__c = 'Case Owner';
                update cse;
                
                Case_Comment__c caseComment = CaseCommentService.createAttnRequest(cse.Id, cse.Forecast_Product__c, requestType, comment);
                insert caseComment;

                //I2RT-3739 - exclude the chatter post for Live Assistance
                if(requestType != 'Live Assistance'){
                    ConnectApi.FeedItemInput feedItemInput = notifyCaseTeamAttnRequest(cse, 'Attention Request', requestType, comment);
                    if(!Test.isRunningTest()){
                        ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
                    }    
                }
            }
            //-------------------------------------------<T02>------------------
                List<Id> caseidlist = new List<Id>();
                caseidlist.add(cse.Id);
                        if(System.isFuture() || System.isScheduled() || System.isBatch()){
                            System.debug('calling weightage helper non future');
                            CaseWeightageHelper.updateWeightsNonFuture(caseidlist,new List<Id>(),new List<Id>(),'Case');
                        }else{
                             System.debug('calling weightage helper non future');
                            CaseWeightageHelper.updateWeights(caseidlist,new List<Id>(),new List<Id>(),'Case');
        }
                
            
            //-------------------------------------------<End of T02>------------------
        
        }
    }
    /**
    *————————————————————————————————————————————————————
    * @Description: escalates the given set of cases
    * 
    *————————————————————————————————————————————————————
    * @param    New and old map
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public static void escalate(Set<Id> setCaseId, String reason, String comment) {
        List<Case> lstCaseToUpdate = new List<Case>();

        //fetch the case details
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, CaseNumber, Subject, IsEscalated,  Forecast_Product__c, Support_Account__c,
                                                            AccountId, OwnerId, Owner_Name__c, Engagement__c, Engagement__r.Status__c, Attention_Request__c,
                                                            Priority, Support_Level__c, Version__c, Segment__c, Acc__c, //T03
                                                            Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                                                            Account.Name, Account.New_Org_Account_Number__c 
                                                            From Case Where Id in :setCaseId]);

        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();
        List<Id> caseidlist = new List<Id>();
        //update the case and set the escalation fields
        for(Case cse : mapCaseIdToCase.values()){
            Engagement__c engagement;
            caseidlist.add(cse.Id);
            if(cse.IsEscalated){
                if(cse.Engagement__c == null || EngagementService.STATUS_CLOSED.equals(cse.Engagement__r.Status__c)){
                    //I2RT-4422
                    //engagement = EngagementService.getSupportEngagement(cse.Support_Account__c);
                    String title = 'Case #' + cse.CaseNumber + ' was escalated by customer';
                    if(String.isNotEmpty(cse.Forecast_Product__c)){
                        title += ' for ' + cse.Forecast_Product__c;
                    }
                    String detail = reason + ' : ' + comment;
                    engagement = EngagementService.createSupportEscalation(cse.Support_Account__c, title, '', '', 'Customer', '', detail, '');
                    insert engagement;

                    RaiseHandService.raiseEscalation(cse.Id, engagement.Id);
                    cse.Engagement__c = engagement.Id;
                }
            }else{
                cse.IsEscalated = true;
                cse.Escalated__c = true;
            }
            cse.Escalate_Open__c = true;
            cse.Escalation_Attention__c = true;
            cse.Escalated_Date__c = System.today();
            cse.Escalation_Reason__c = reason;
            cse.Next_Action__c = 'Case Owner';
            lstCaseToUpdate.add(cse);

            //create a Case Comment 
            Case_Comment__c caseComment = CaseCommentService.createEscalationComment(cse.Id, reason, comment);
            lstCaseComment.add(caseComment);
        }

        //-------------------------------------------<T02>------------------
        if(caseidlist.size()>0){
         		if(System.isFuture() || System.isScheduled() || System.isBatch()){
                    System.debug('calling weightage helper non future');
                    CaseWeightageHelper.updateWeightsNonFuture(caseidlist,new List<Id>(),new List<Id>(),'Case');
                }else{
                     System.debug('calling weightage helper non future');
                    CaseWeightageHelper.updateWeights(caseidlist,new List<Id>(),new List<Id>(),'Case');
                }
        }
        
        //-------------------------------------------<End of T02>------------------
        

        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;

            if(!lstCaseComment.isEmpty()){
                CaseControllerWithoutSharing.insertCaseComments(lstCaseComment);
            }

            List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
            for(Case cse : lstCaseToUpdate){
                ConnectApi.FeedItemInput feedItemInput = notifyCaseTeamAttnRequest(cse, 'Escalation Request', reason, comment);
                lstBatchInput.add(new ConnectApi.BatchInput(feedItemInput));
            }
            if(!lstBatchInput.isEmpty()){
                if(!Test.isRunningTest()){
                   ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
                }
            }
        }
    }

    public static ConnectApi.FeedItemInput notifyCaseTeamCaseUpdate(Case cse, String activity){
        //I2RT-4916 - check if the Product is selected on the Case
        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }

        String content = 'Case Notification: ' + productContent + cse.Priority 
                                + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                + ', ' + cse.Support_Level__c;
                                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Activity', activity));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Owner / Team: '));
        messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.OwnerId));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Summary', cse.Subject));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.Segment__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
        messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        Set<Id> setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, false, false, false);
        
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
    
    public static ConnectApi.FeedItemInput notifyCaseTeamAttnRequest(Case cse, String keyword, String reason, String comment){
        if(String.isNotEmpty(comment)){
            comment = comment.stripHtmlTags();
        }

        //I2RT-4916 - check if the Product is selected on the Case
        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }

        String content = keyword + ': ' + productContent + cse.Priority 
                                + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                + ', ' + cse.Support_Level__c;
                                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Reason for ' + keyword, reason));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue(keyword + ' Comments', comment));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Owner / Team', cse.Owner_Name__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Summary', cse.Subject));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.Segment__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
        messageBodyInput.messageSegments.add(ChatterService.inputHyperlink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        Set<Id> setUserIdToPost = new Set<Id>();
        if(keyword == 'Attention Request'){
            setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, true, true, false);
        }else if(keyword == 'Escalation Request'){
            setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, true, true, true);
        }
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
    
    public static ConnectApi.FeedElement postToChatterOwnerChange(Id caseId, Id newOwnerId, Id oldOwnerId){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        
        ConnectApi.TextSegmentInput newLineInput = new ConnectApi.TextSegmentInput();    
        newLineInput.text = '\r\n';
        
        ConnectApi.MentionSegmentInput newOwnerMention = new ConnectApi.MentionSegmentInput();
        newOwnerMention.id = newOwnerId;
        
        ConnectApi.MentionSegmentInput oldOwnerMention = new ConnectApi.MentionSegmentInput();
        oldOwnerMention.Id = oldOwnerId;

        ConnectApi.TextSegmentInput contentInput = new ConnectApi.TextSegmentInput();
        contentInput.text = ' is the new Owner of this Case.';

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(newOwnerMention);
        messageBodyInput.messageSegments.add(contentInput);
        messageBodyInput.messageSegments.add(newLineInput);
        messageBodyInput.messageSegments.add(newLineInput);
        messageBodyInput.messageSegments.add(oldOwnerMention);

        feedItemInput.subjectId = caseId;
        feedItemInput.body = messageBodyInput;

        ConnectApi.FeedElement feedElement;
        if(!Test.isRunningTest()){
            feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        }

        return feedElement;
    }
}