/*
Trigger:        ZIssueTriggerHelper
@Author:        Pavithra V
@Created Date:  15 March 2021
@Description:   Handles the trigger logic on the object ZIssue

Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************
balajip     07/05/2022  I2RT-6655   T01     To prevent SOQL from the nested method getCaseSubscribers inside the loop
balajip     07/13/2022  I2RT-6153   T02     To replace GCS_Segment__c field with Segment__c field in the notifications
*/

public class ZIssueTriggerHelper {
    
    /**
    * Notifies the Case Team members on create/update
    * 
    * @param parameter- mapOld - map of old zIssue
    * @param parameter- mapNew - map of new zIssue
    * @return return-void
    * @throws exception - NA
    */
    public void notifyCaseTeam(Map<Id, zsfjira__ZIssue__c> mapNew, Map<Id, zsfjira__ZIssue__c> mapOld){               
        List<Schema.FieldSetMember> zIssueFieldList = Schema.SObjectType.zsfjira__ZIssue__c.fieldSets.getMap().get('Create_Case_Feed_On_Field_Update').getFields();

        Set<Id> setIssueIdToProcess = new Set<Id>();
        Map<Id, List<String>> mapIssueIdToFieldsUpdated = new Map<Id, List<String>>();
        for(zsfjira__ZIssue__c zIssueNew : mapNew.values()){
            if(mapOld != null){
                List<String> lstFieldsUpdated = new List<String>();
                zsfjira__ZIssue__c zIssueOld = mapOld.get(zIssueNew.Id);
                for(Schema.FieldSetMember fieldSetMember : zIssueFieldList){
                    String fieldName = fieldSetMember.getFieldPath();
                    if(zIssueNew.get(fieldName) != zIssueOld.get(fieldName)){
                        lstFieldsUpdated.add(fieldSetMember.getLabel());
                    }
                }
                if(!lstFieldsUpdated.isEmpty()){                    
                    mapIssueIdToFieldsUpdated.put(zIssueNew.Id, lstFieldsUpdated);
                    setIssueIdToProcess.add(zIssueNew.Id);    
                }
            }else{
                setIssueIdToProcess.add(zIssueNew.Id);
            }
        }
        System.debug('mapIssueIdToFieldsUpdated >> '+ mapIssueIdToFieldsUpdated);
		
        Map<Id, Set<Case>> mapIssueIdToCases = new Map<Id, Set<Case>>();
        List<zsfjira__ZIssue_Case__c> lstIssueCase = new List<zsfjira__ZIssue_Case__c>();

        if(!setIssueIdToProcess.isEmpty()){        
            lstIssueCase = [Select Id, zsfjira__CaseId__c, zsfjira__ZIssueId__c        
                                From zsfjira__ZIssue_Case__c                   
                                Where zsfjira__ZIssueId__c in :setIssueIdToProcess];
        }
        System.debug('lstIssueCase >> '+ lstIssueCase);

        Set<Id> setCaseId = new Set<Id>();
        for(zsfjira__ZIssue_Case__c issueCase : lstIssueCase){
            setCaseId.add(issueCase.zsfjira__CaseId__c);
        }
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>(
                                    [Select Id, OwnerId, CaseNumber, Priority, Forecast_Product__c, Support_Level__c,
                                            Version__c, Segment__c, Acc__c, //T02
                                            Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                                            Account.Name, Account.New_Org_Account_Number__c,
                                            Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c //T01
                                        From Case Where Id = :setCaseId And Status != 'Closed']); //T01
        
        for(zsfjira__ZIssue_Case__c issueCase : lstIssueCase){
            if(mapCaseIdToCase.containsKey(issueCase.zsfjira__CaseId__c)){
                Set<Case> setCase = new Set<Case>();
                if(mapIssueIdToCases.containsKey(issueCase.zsfjira__ZIssueId__c)){
                    setCase = mapIssueIdToCases.get(issueCase.zsfjira__ZIssueId__c);
                }else{
                    mapIssueIdToCases.put(issueCase.zsfjira__ZIssueId__c, setCase);
                }
                setCase.add(mapCaseIdToCase.get(issueCase.zsfjira__CaseId__c));    
            }
        }
        System.debug('mapIssueIdToCases >> '+ mapIssueIdToCases);
                    
        createNotifications(mapIssueIdToCases, mapNew, mapIssueIdToFieldsUpdated);
    }

    public static void createNotifications(Map<Id, Set<Case>> mapIssueIdToCases, Map<Id, zsfjira__ZIssue__c> mapIssueIdToIssue){
        createNotifications(mapIssueIdToCases, mapIssueIdToIssue, null);
    }
    
    public static void createNotifications(Map<Id, Set<Case>> mapIssueIdToCases, Map<Id, zsfjira__ZIssue__c> mapIssueIdToIssue, Map<Id, List<String>> mapIssueIdToFieldsUpdated){
        List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();

        //T01
        Map<Id, Set<Subscription__c>> mapCaseIdToSubscriptions = new Map<Id, Set<Subscription__c>>();

        Set<Id> setCaseId = new Set<Id>();
        for(Set<Case> setCase : mapIssueIdToCases.values()){
            for(Case cse : setCase){
                setCaseId.add(cse.Id);
                mapCaseIdToSubscriptions.put(cse.Id, new Set<Subscription__c>());
            }
        }
        for(Subscription__c sub : [Select Id, Record_Id__c, Subscriber_Id__c, Subscribed__c 
                                    From Subscription__c Where Record_Id__c = :setCaseId]){
            Set<Subscription__c> setSubscription = new Set<Subscription__c>();
            if(mapCaseIdToSubscriptions.containsKey(sub.Record_Id__c)){
                setSubscription = mapCaseIdToSubscriptions.get(sub.Record_Id__c);
            }else{
                mapCaseIdToSubscriptions.put(sub.Record_Id__c, setSubscription);
            }
            setSubscription.add(sub);
        }

        for(Id issueId : mapIssueIdToCases.keyset()){
            String fieldNames = '';
            zsfjira__ZIssue__c issue;
            if(mapIssueIdToFieldsUpdated != null && mapIssueIdToFieldsUpdated.containsKey(issueId)){
                fieldNames = String.join(mapIssueIdToFieldsUpdated.get(issueId), ',');                
            }
            issue = mapIssueIdToIssue.get(issueId);            

            for(Case cse : mapIssueIdToCases.get(issueId)){
                if(String.isNotEmpty(fieldNames)){
                    Case_Comment__c caseComment = new Case_Comment__c();          
                    caseComment.Case__c = cse.Id;caseComment.ZIssue__c = issueId;
                    caseComment.Status__c = 'Submitted';                  
                    caseComment.Visibility__c = 'Internal';
                    caseComment.Type__c = 'JIRA Request';       
                    caseComment.Comment__c = 'Jira ' + fieldNames + ' was updated. JIRA Link: <a href=\"' + '/' + issueId + '\">' + issue.Name + '</a>';
                    lstCaseComment.add(caseComment);    
                }
                
                //create chatter post
                ConnectApi.FeedItemInput feedItemInput = getFeedItem(issue, cse, fieldNames, mapCaseIdToSubscriptions.get(cse.Id));//T01
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                lstBatchInput.add(batchInput);
            }
        }

        if(!lstCaseComment.isEmpty()){            
            insert lstCaseComment;        
        }

        if(!Test.isRunningTest()){
            if(!lstBatchInput.isEmpty()){               
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);            
            }
        }
    }

    private static ConnectApi.FeedItemInput getFeedItem(zsfjira__ZIssue__c issue, Case cse, String fieldNames, Set<Subscription__c> setSubscription){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        try{
            String activity = 'New JIRA';
            if(String.isNotEmpty(fieldNames)){
                activity = 'JIRA Update';
            }

            //I2RT-4916 - check if the Product is selected on the Case
            String productContent = '';
            if(String.isNotEmpty(cse.Forecast_Product__c)){
                productContent = cse.Forecast_Product__c + ', ';
            }
            
            String content = 'JIRA Updates: ' + productContent + cse.Priority 
                                    + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                    + ', ' + cse.Support_Level__c;
                                                    
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            messageBodyInput.messageSegments.add(ChatterService.inputText(content));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            if(test.isrunningtest()){
                messageBodyInput.messageSegments.add(ChatterService.inputNameValue('JIRA Number', '1234'));
            } else {
                messageBodyInput.messageSegments.add(ChatterService.inputNameValue('JIRA Number', issue.zsfjira__IssueKey__c));
            }
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Activity', activity));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
            messageBodyInput.messageSegments.add(ChatterService.inputText('Case Owner / Team: '));
            messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.OwnerId));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            if(activity == 'JIRA Update'){
                //messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Comments', raiseHand.Name));
            }
                
            if(test.isrunningtest()){
                messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Title', 'test'));
            } else {
                messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Title', issue.zsfjira__Summary__c));
            }
                
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.Segment__c)); //T02
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
            messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
            messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
            messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.Id));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            
            Boolean includeManager = false;        
            if('EBF'.equalsIgnoreCase(issue.zsfjira__Project__c)){            
                includeManager = true;        
            }
            Set<Id> setUserIdToPost = CaseTeamService.getCaseSubscribers(cse, setSubscription, true, includeManager, true, true); //T01
            for(Id userId : setUserIdToPost){              
                messageBodyInput.messageSegments.add(ChatterService.inputSpace());            
                messageBodyInput.messageSegments.add(ChatterService.inputMention(userId));    
            }
            
            feedItemInput.subjectId = cse.Id;        
            feedItemInput.body = messageBodyInput;        
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        } catch(Exception e){
            system.debug('Exception occured:'+e.getmessage()+e.getlinenumber());
        } 
        return feedItemInput;
    }
}