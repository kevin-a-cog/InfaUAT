/*
Class:          EngagementNotifyGCSadmins 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Chatter Post on engagement
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/



public without sharing class EngagementNotifyGCSadmins {


    public static globalApexManager GAM = new globalApexManager();

    @InvocableMethod(label='Notify GCS Admin queue On GCS admin engagement' description='Notify GCS Admin Engagement')
    public static void NotifyGCSAdmins(List<ID> Ids) {        postFeedElementWithMention(Ids);      }

    //
    public static void postFeedElementWithMention(List<Id> EngagementIds){  
             
        Set<id> GCSAdminIds = new Set<id>();
        Group GCSAdminQueue =  [Select Id from Group where type='Queue' and Name= :Label.GCSAdminQueue] ;
        for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =: GCSAdminQueue.id]){
            GCSAdminIds.add(gm.UserOrGroupId);
        }
        
        
        // Bulk post to the Engagements
        
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for (Engagement__c Eng : [Select id,Name,Account__c,Account__r.Name,Support_Account__c,Support_Account__r.Name, Order__c,Contract__c from Engagement__c where Id in :EngagementIds ]) {
            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

            input.subjectId = Eng.id;
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            String mentions ='';
       
                for( Id userid :GCSAdminIds){
                    mentions = mentions + returnMentionFormat(userid);
                }
                        
            String postContent = ', A new Support Account has been created . Please Review and Activate the Support Account.'+'\n\n'+
               ' Customer Account Name : ' + Eng.Account__r.Name +'\n'+
                'Customer Account Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ Eng.Account__c+'\n \n'+
                'Support Account Name : '+ Eng.Support_Account__r.Name+'\n'+
                'Suport Account Link : '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+ Eng.Support_Account__c+'\n \n';
            
            String fullbody = mentions +postContent;
            
            //format the textwith mentions 
            body.messageSegments = ConnectApiHelper.getMessageSegmentInputs(fullbody);
            
            input.body = body;
            
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
            
        }
        
        system.debug('**batchInputs'+batchInputs);
        
        if(!Test.isRunningTest() &&  batchInputs!=null && batchInputs.size()>0){
            Try{
                // API call to post in bulk mode
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
            Catch(Exception e){              GAM.CreateExceptionRecords('EngagementNotifyGCSadmins-->postFeedElementWithMention-->Chatterpost failed', e.getMessage(),null);            }
        }
        
        
        
    }
    
    // Format the id to string
    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }
}