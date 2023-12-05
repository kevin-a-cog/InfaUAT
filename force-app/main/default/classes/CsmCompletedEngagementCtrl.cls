public class CsmCompletedEngagementCtrl {

    @AuraEnabled
    public static List<LookupSearchResult> lookupSearch(string searchTerm,string selectedIds,string objectName,string engagementId){
        string accId = null;        
        for(engagement__c objEng : [Select Id,Opportunity__c,Opportunity__r.AccountId From engagement__c WHERE Id =:engagementId]){
           if(objEng.Opportunity__c != null && objEng.Opportunity__r.AccountId != null){           
              accId = objEng.Opportunity__r.AccountId;
           }
        }

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if(accId != null){
 
            for(Plan__c oplan : [Select Id,Name,Account__c from Plan__c WHERE Account__c = :accId] ){
                results.add(new LookupSearchResult(oplan.Id, 'Plan__c', 'custom:custom55', oplan.Name, ''));
            }
            
        }

        return results;
    }
   

     @AuraEnabled
     public static void completeEngagement(string engagementId, boolean bEngagementhelpful, string sCSMSummaryVal, string selectedPlanId){
        
        engagement__c objEng = [Select Id,Engagement_Helpful__c,CSM_Summary__c,Status__c,Plan__c,ownerId From engagement__c WHERE Id = :engagementId];
        objEng.Status__c = 'Handoff Completed';
      
       // objEng.Id = engagementId; 
       objEng.Engagement_Helpful__c = bEngagementhelpful;
       //objEng.CSM_Summary__c = sCSMSummaryVal; 
       //objEng.CSM_Closing_Comments__c = sCSMSummaryVal; 
       objEng.CSM_Feedback__c = sCSMSummaryVal; 
       
       
       objEng.Plan__c = selectedPlanId;

        Update objEng;

        list<string> lstUserIds;
            if(engagementId != '' && engagementId != null){
               string accountId;
               Engagement__c objEngagement = [SELECT Id,Name,Status__c,OwnerId,Owner.Name,Engage_with_CSM__c,
               Opportunity__c, Opportunity__r.Accountid,Opportunity__r.Account.Name,
               Opportunity__r.Name,Opportunity__r.owner.Name,CreatedById
                                              FROM Engagement__c WHERE ID = :engagementId];
               if(objEngagement.Opportunity__c != null){
                  if(objEngagement.Opportunity__r.Accountid != null){
                     if(objEngagement.Engage_with_CSM__c){
                        accountId = objEngagement.Opportunity__r.Accountid;
                     }               
                  }
               }
      
               if(accountId != null){
                  lstUserIds = new list<string>();
      
                  for(AccountTeamMember atm : [SELECT Id,UserId,TeamMemberRole FROM AccountTeamMember 
                                               WHERE AccountId =:accountId  
                                               AND TeamMemberRole = 'CSM']){
                     lstUserIds.add(atm.UserId);                                         
                      
                  }
      
                  system.debug('lstUserIds====> ' + lstUserIds);
      
                          //  bell notification 

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'DealClosureHandoff_Notification'];

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('The following Deal Closure Engagement is updated on the Opportunity');         
        string sBody = '';  
        sBody += 'Opportunity: ' + objEngagement.Opportunity__r.Name + '\n'; 
        sBody += 'Opportunity Owner: ' + objEngagement.Opportunity__r.owner.Name + '\n'; 
        sBody += 'Engagement: ' + objEngagement.Name + '\n';        
        sBody += 'Engagement Status: ' + objEngagement.Status__c + '\n';
        sBody += 'Engagement Owner: ' + objEngagement.Owner.Name + '\n';
        sBody += 'Account: ' + objEngagement.Opportunity__r.Account.Name + '\n';

        notification.setBody(sBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(objEngagement.Id);
        try {
         Set<string> setUsers = new set<string>();
         for (string sUid: lstUserIds){         
            setUsers.add(sUid);
        }

        //Get the mention Users from 'INFA CSO'
           for(GroupMember gm : [Select UserOrGroupId From GroupMember where Group.Name = 'INFA CSO']) {
            setUsers.add(gm.UserOrGroupId);
        }
        //setUsers.add(objEngagement.OwnerId);
        //setUsers.add(userinfo.getUserId());
        setUsers.add(objEngagement.CreatedById);

            notification.send(setUsers);
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }

               // chatter post now
               
               
                /*   String message ='';            
         ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

         //Get the Target ID
         feedItemInput.subjectId = engagementId; 
       
                   //Get the chatter message
                   //message = 'A new Deal Closure handoff has been created, please review - ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + engagementId;
      
         message = 'The Deal clsoure engagement is now completed by ' + userinfo.getName() + '. ';
         
         ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
         messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
         textSegment.text = message;
         messageBodyInput.messageSegments.add(textSegment);
         system.debug('textSegment====> ' + textSegment);


         ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputContact = new ConnectApi.EntityLinkSegmentInput();
         entityLinkSegmentInputContact.entityId = engagementId;   
         messageBodyInput.messageSegments.add(entityLinkSegmentInputContact);

      
                 
      
      
                   if(objEngagement.Opportunity__c != null){
                     ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
                     textSegmentInput2.text = ' , ';     
                     messageBodyInput.messageSegments.add(textSegmentInput2);
                     
                  ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputContact2 = new ConnectApi.EntityLinkSegmentInput();
                  entityLinkSegmentInputContact2.entityId = objEngagement.Opportunity__c;   
                  messageBodyInput.messageSegments.add(entityLinkSegmentInputContact2);
      
                  if(objEngagement.Opportunity__r.Accountid != null){
                     ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
                     textSegmentInput3.text = ' , ';     
                     messageBodyInput.messageSegments.add(textSegmentInput3);
         
                     ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputContact3 = new ConnectApi.EntityLinkSegmentInput();
                     entityLinkSegmentInputContact3.entityId = objEngagement.Opportunity__r.Accountid;   
                     messageBodyInput.messageSegments.add(entityLinkSegmentInputContact3);
                  }
                 
      
                   }
                   
                   //Get the mention Users
                   for (string sUid: lstUserIds){
                       ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                       mentionSegmentInput.id = sUid;
                       messageBodyInput.messageSegments.add(mentionSegmentInput);
                   }
      
                    //Get the mention Users from 'INFA CSO'
                  for(GroupMember gm : [Select UserOrGroupId From GroupMember where Group.Name = 'INFA CSO']) {
                      ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
                      mentionSegmentInput1.id = gm.UserOrGroupId;
                      messageBodyInput.messageSegments.add(mentionSegmentInput1);
                  }
                  
                 // mention record owner
                 string sOwner =  string.valueOf(objEngagement.OwnerId);
       if(sOwner.startsWith('005')){
        ConnectApi.MentionSegmentInput mentionSegmentInput3 = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput3.id = sOwner;
        messageBodyInput.messageSegments.add(mentionSegmentInput3);
       }

       system.debug('body.messageSegments====> ' + messageBodyInput.messageSegments);

         feedItemInput.body = messageBodyInput;
                   ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);  
      
                   List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();  
         batchInputs.add(batchInput);
     
     if(!Test.isRunningTest()){
         ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
         system.debug('FINISH');  
               } */       
             }
            }
        
     }
}