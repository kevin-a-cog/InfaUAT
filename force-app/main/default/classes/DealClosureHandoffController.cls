/*
Class:          DealClosureHandoffController
Test class -    DealClosureHandoffControllerTest
Change History
************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                    Tag
************************************************************************************************************************************
VENKATESH BALLA   11-09-2023        SALESRT-18187           Removing obsolete Team member roles                <T01>
*/
public without sharing class DealClosureHandoffController {
   @InvocableVariable(label='Opp Id' )
   public String oppId;   
   @AuraEnabled(cacheable=true)
     public static Engagement__c  fetchExistingSubAdopRecords(string oppId){        
        
        Engagement__c objEngagement = new Engagement__c();
        for(Engagement__c eng : [Select Id,Name,RecordType.Name,Status__c From Engagement__c WHERE Opportunity__c = :oppId AND RecordType.Name = 'Subscription Adoption' ORDER BY Createddate DESC LIMIT 1]){
          objEngagement = eng;
        }
        return objEngagement; 
     } 
    
    @AuraEnabled
     public static Engagement__c  fetchExistingSubAdopRecordswithoutsharing(string oppId2){              
        Engagement__c objEngagement = new Engagement__c();
        for(Engagement__c eng : [Select Id,Name,RecordType.Name,Status__c From Engagement__c WHERE Opportunity__c = :oppId2 AND RecordType.Name = 'Subscription Adoption' ORDER BY Createddate DESC LIMIT 1]){
          objEngagement = eng;
        }
        return objEngagement; 
     }

     @AuraEnabled
     public static Engagement__c  inserteng(string engrec){                
        Engagement__c objEngagement = new Engagement__c();
        objEngagement = (Engagement__c)JSON.deserialize(engrec, Engagement__c.class);
        insert objEngagement;
        return objEngagement;
     }

   @AuraEnabled(cacheable=true)
     public static Opportunity fetchOppotunityRecord(string oppId){        
        list<Opportunity> lstOpp = new list<Opportunity>();        
        for(Opportunity opp : [SELECT Id,Name,AccountId,CurrencyIsoCode,Type,Total_OARR__c,convertCurrency(Total_OARR__c) ConvertedTotalOARR,ARR__c,convertCurrency(ARR__c) ConvertedARR,New_Org_Opportunity_Number__c,RecordType.DeveloperName,BANT_Qualification__c,Competitors__c, Notes_to_Competitive_Team__c, Economic_Buyer__c, Champion__c, Delivery__c, Red_Flags__c, Sales_Journey__c,(Select id,userid,TeamMemberRole from OpportunityTeamMembers where TeammemberRole='Account Manager') 
                               FROM Opportunity 
                               WHERE Id =: oppId]){
            lstOpp.add(opp);
        }
        return lstOpp[0];
     }
 

     @AuraEnabled
     public static list<string> postChatterFeed(string engagementId){
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
        //  bell notification 
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'DealClosureHandoff_Notification'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('The following Deal Closure Engagement is created on the Opportunity');         
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
         
        /*     String message ='';            
             ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
 
             //Get the Target ID
             feedItemInput.subjectId = engagementId; 
 
             //Get the chatter message
             //message = 'A new Deal Closure handoff has been created, please review - ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + engagementId;

             message = 'The Deal clsoure engagement has been created by ' + userinfo.getName() + '. ';
             
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
         }  */      
       }
      }
      return lstUserIds;
     }

     @AuraEnabled
      public static map<string,string> getselectOptions(sObject objObject, string fld) {         
       system.debug('objObject --->' + objObject);
       system.debug('fld --->' + fld);
       objObject = new Opportunity();
       map<string,string> mapValueWiseLabel = new map<string,string>();

      Schema.sObjectType objType = objObject.getSObjectType();
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();      
      map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();      
      list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();      
      for (Schema.PicklistEntry a: values) {
         mapValueWiseLabel.put(a.getValue(), a.getLabel());
      }
      system.debug('allOpts ---->' + mapValueWiseLabel);
      //allOpts.sort();
      return mapValueWiseLabel; 
      }


      //Method to post chatter notification in Opportunity record when the deal closure is not created
      // Opportunity status is set to Final negotiation and Closed won
      @InvocableMethod(label='Chatter Post Notification Deal Closure') 
      public static void chatternotification(List<string> oppId ){
        system.debug('Invoked');
        system.debug('oppId'+oppId);
         try{
              if(oppId != null)
              {
                     system.debug('oppId'+oppId);
                     list<string> lstUserIds;
                     List<Engagement__c> objEngagement = new List<Engagement__c>();
                     for(Engagement__c eng : [SELECT Id FROM Engagement__c WHERE Opportunity__c = :oppId AND RecordType.Name = 'Subscription Adoption' ORDER BY Createddate DESC LIMIT 1]){
                        objEngagement.add(eng);
                     }
                     String oppname;
                     String accname;
                     String oppunityId;
                     String accountId;
                     String oppStage;
                     lstUserIds = new list<string>();
                        //<T-01>
                        /*for(OpportunityTeamMember opptm : [SELECT Id,UserId,TeamMemberRole FROM OpportunityTeamMember 
                                                      WHERE OpportunityId =:oppId  
                                                      AND (TeamMemberRole = 'Account Manager'  OR TeamMemberRole = 'Sales Consultant' 
                                                       OR TeamMemberRole = 'Solution Specialist' OR TeamMemberRole = 'Solution Architect' OR TeamMemberRole = 'Sales Specialist - Cloud'
                                                       OR TeamMemberRole = 'Sales Specialist - DaaS' OR TeamMemberRole = 'Sales Specialist - DG' OR TeamMemberRole = 'Sales Specialist - DSG'
                                                       OR TeamMemberRole = 'Sales Specialist - MDM' OR TeamMemberRole = 'Sales Specialist - NGA') ])
                        */
                        for(OpportunityTeamMember opptm : [SELECT Id,UserId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId =:oppId  AND
                                                      (TeamMemberRole = 'Account Manager'  OR TeamMemberRole = 'Solution Architect' OR TeamMemberRole = 'Sales Specialist - DG' OR TeamMemberRole = 'Sales Specialist - MDM') ])
                        {
                              lstUserIds.add(opptm.UserId);
                        }
                        for (Opportunity opp: [select id,OwnerId,Name,AccountId,Account.Name,StageName from Opportunity where Id=:oppId])
                        {
                           oppname= opp.Name;
                           accname = opp.Account.Name;
                           oppunityId = opp.Id;
                           accountId = opp.AccountId;
                           oppStage = opp.StageName;
                           lstUserIds.add(opp.OwnerId); 
                        }

                        for(GroupMember gm : [Select UserOrGroupId From GroupMember where Group.Name = 'INFA CSO']) {
                           lstUserIds.add(gm.UserOrGroupId);
                        }
                     if(objEngagement.size() ==0)
                     {
                                    
                           ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
               
                           //Get the Target ID
                           for (string targetid: oppId){
                           feedItemInput.subjectId = targetid; 
                           }
                           //Get the chatter message
                                             
                       
                           //ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                         ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();

                           // Text content of a chatter body
                           ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput5 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput6 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput7 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput8 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmentInput9 = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput textSegmenthello = new ConnectApi.TextSegmentInput();
                           ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

                           // To make the text bold
                           ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                           ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();

                           // To have sentences in next line
                           ConnectApi.MarkupBeginSegmentInput paragraphBegin1 = new ConnectApi.MarkupBeginSegmentInput();
                           ConnectApi.MarkupEndSegmentInput paragraphEnd1 = new ConnectApi.MarkupEndSegmentInput();

                           // To have the hyperlink of the Opprecord record
                           ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputOpportunity = new ConnectApi.EntityLinkSegmentInput();
                           entityLinkSegmentInputOpportunity.entityId =oppunityId;

                           ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputAccount = new ConnectApi.EntityLinkSegmentInput();
                           entityLinkSegmentInputAccount.entityId = accountId ;    

                           messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                           //Content for message to 
                           String content1 = 'You are receiving this notification, Since you are part of the Opportunity'+ ' ' ;

                           String Content2 = ' team in salesforce that has reached the'+ ' '+ oppStage + ' '+ 'Status.' +' ';

                           String content3 = 'This notification is a reminder to Initiate the Deal Closure Handoff to the CSM Team ';

                           String content4 = 'which can be done by clicking on the Quick Actions: ';

                           String content5 = 'Deal Closure Hand Off';

                           String content6= 'Additional Details about the Opportunity are provided below';

                           String content7= 'Account Name:  ';

                           String content8= 'Opportunity Name:  ';

                           String content9= 'Opportunity Status:  '+ oppStage ;

                           textSegmenthello.text = 'Hello,';
                           textSegmentInput1.text = content1;
                           textSegmentInput2.text = content2;
                           textSegmentInput3.text = content3;
                           textSegmentInput4.text = content4;
                           textSegmentInput5.text = content5;
                           textSegmentInput6.text = content6;
                           textSegmentInput7.text = content7;
                           textSegmentInput8.text = content8;
                           textSegmentInput9.text = content9;
                           nextLineTextSegment.text ='&nbsp;';

                           // Hello Text
                           messageBodyInput.messageSegments.add(textSegmenthello);

                           // First sentence start
                           paragraphBegin1.markupType = ConnectApi.MarkupType.paragraph;
                           paragraphEnd1.markupType = ConnectApi.MarkupType.paragraph;
                           markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
                           markupEndSegment.markupType = ConnectApi.MarkupType.bold;                                                 
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           messageBodyInput.messageSegments.add(textSegmentInput1);
                           messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);                        
                           messageBodyInput.messageSegments.add(textSegmentInput2);                      
                           messageBodyInput.messageSegments.add(markupBeginSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput3);
                           messageBodyInput.messageSegments.add(markupEndSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput4);
                           messageBodyInput.messageSegments.add(markupBeginSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput5);
                           messageBodyInput.messageSegments.add(markupEndSegment);
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           // First sentence end

                           // Second sentence start
                           paragraphBegin1.markupType = ConnectApi.MarkupType.paragraph;
                         paragraphEnd1.markupType = ConnectApi.MarkupType.paragraph;
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           messageBodyInput.messageSegments.add(textSegmentInput6);
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           // Second sentence end

                           // Third sentence end
                           paragraphBegin1.markupType = ConnectApi.MarkupType.paragraph;
                         paragraphEnd1.markupType = ConnectApi.MarkupType.paragraph;
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput7);
                           messageBodyInput.messageSegments.add(entityLinkSegmentInputAccount);
                           messageBodyInput.messageSegments.add(paragraphEnd1);                          
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput8);
                           messageBodyInput.messageSegments.add(entityLinkSegmentInputOpportunity);
                           messageBodyInput.messageSegments.add(paragraphEnd1);                         
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(textSegmentInput9);
                           messageBodyInput.messageSegments.add(paragraphEnd1);
                           messageBodyInput.messageSegments.add(paragraphBegin1);
                           messageBodyInput.messageSegments.add(nextLineTextSegment);
                           messageBodyInput.messageSegments.add(paragraphEnd1);                         
                           // Third sentence end

                           //Get the mention Users
                        for (string sUid: lstUserIds){
                           ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                           mentionSegmentInput.id = sUid;
                           messageBodyInput.messageSegments.add(mentionSegmentInput);
                           }
                           system.debug('body.messageSegments====> ' + messageBodyInput.messageSegments);
                           
                           feedItemInput.body = messageBodyInput; 
                           ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);  

                           List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();  
                           batchInputs.add(batchInput);

                              if(!Test.isRunningTest()){
                                 ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                                 system.debug('FINISH');  
                              } 
               }          
           } 

         }Catch(Exception e){
                system.debug('Send Notification Chatter from Deal clouser Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
               
            }              
        
    }   

   //Method to upload the file in Engagement record
    @AuraEnabled
    public static String uploadFile(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) 
            {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug('files-->'+files);
 
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion cv = new ContentVersion();
                    cv.Title = file.fileName;
                    cv.PathOnClient = file.fileName;
                    cv.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    cvList.add(cv);
                }
                Insert cvList;
 
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
 
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}