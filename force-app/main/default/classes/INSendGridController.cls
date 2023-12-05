/*
* Name			:	INSendGridController
* Author		:	Deeksha Shetty
* Created Date	: 	21 Nov 2022
* Description	:	SendGrid Controller for IN.
* Test Class    :   INSendGridControllerTest

Change History
********************************************************************************************************************************
Modified By			Date			Jira No.		Description					                               Tag
********************************************************************************************************************************
Deeksha Shetty		21/11/2022		    N/A				Initial version.			                                N/A
Deeksha Shetty      18/04/2023         I2RT-7440        Product community: New discussion notification email         1
Deeksha Shetty      09/05/2023         I2RT-8345        Ask a Question - Email Notification - Attachment             2
Deeksha Shetty      15/04/2023         I2RT-8423        Provision to create poll in product community                3
Prashanth Bhat      09-08-2023         I2RT-9050        SendGrid Callout Wrapper changed to SendGridINWrapper        4
*/

public without sharing class INSendGridController {
    
    //Public variables.
    public static final String FROMADDRESS = 'no-reply@informatica.com';
    public static final String FROMNAME    = 'No-Reply at Informatica Support';
    
    /*
    * I2RT-7463 - Event: Notification email for cloud release events
    Method Name : sendEmailOnExternalEvents
    Description : This method sends the email using the SendGrid service when an External/Cloud Event is Updated.
    Parameters	 : Object, called from sendEmail, objParameters Email parameters.
    Return Type : None
    */
    @future(callout=true)
    public Static void sendEmailOnExternalEvents(String eventId){
        Boolean boolIsPriority = false;        
        
        SendGridWrapper.Dynamictemplate objDynamicVariables = new SendGridWrapper.Dynamictemplate();
        SendGridWrapper.EmailIdWrapper objSender = new SendGridWrapper.EmailIdWrapper();
        SendGridWrapper.EmailIdWrapper objReplyTo = new SendGridWrapper.EmailIdWrapper();
        SendGridWrapper.Uniqueargs objUniqueArguments = new SendGridWrapper.Uniqueargs();
        SendGridWrapper.Header objHeaders = new SendGridWrapper.Header();
        SendGridWrapper.Tracking_settings objTrackingSettings = new SendGridWrapper.Tracking_settings();
        SendGridWrapper.Enable_Mode objTrackingMode = new SendGridWrapper.Enable_Mode();
        SendGridWrapper.Enable_Mode objSandboxMode = new SendGridWrapper.Enable_Mode();
        SendGridWrapper.Mail_settings objMailSettings = new SendGridWrapper.Mail_settings();        
        SendGridWrapper.FileObject objFile = new SendGridWrapper.FileObject();
        List<SendGridWrapper.FileObject> lstAttachments = new List<SendGridWrapper.FileObject>();
        List<SendGridWrapper.Personalizations> lstRequests = new List<SendGridWrapper.Personalizations>();
        
        List<Id> allUserIds = new List<Id>();
        String sitelabel = System.Label.IN_CommunityName;
        
        //Fetch the members who are following the event.
        
        List<Community_Interactions__c> externalEventFollowers = [SELECT User__c FROM Community_Interactions__c 
                                                                  WHERE Id__c=:eventId AND Follow__c=true AND Type__c='Event'];
        if(externalEventFollowers.size()>0){
            for(Community_Interactions__c memb : externalEventFollowers ){
                allUserIds.add(memb.User__c);
            }            
        }
        
        //Fetch the members who have accepted the event.
        
        List<EventRelation> joinedEventMembers = [SELECT RelationId FROM EventRelation WHERE Status='Accepted' AND EventId=:eventId];
        if(joinedEventMembers.size()>0){
            for(EventRelation memb : joinedEventMembers ){
                if(!allUserIds.contains(memb.RelationId))
                    allUserIds.add(memb.RelationId);
            }
        }
        
        
        List<user> getEventFollowersEmails = [Select email,name from user where Id IN:allUserIds];
        System.debug('getEventFollowersEmails='+getEventFollowersEmails);
        
        List<Event> objEvent1 = [Select Id,Subject,Description,StartDateTime,
                                 EndDateTime,Location from Event where Id=:eventId];
        
        Event objEvent = objEvent1[0];
        
        //Set the dynamic template Data
        help_Infa_Custom_Label__mdt hc = help_Infa_Custom_Label__mdt.getInstance('helpEvents');      
        objDynamicVariables.EventTitle = objEvent.subject;
        objDynamicVariables.INURL = System.Label.IN_CommunityName;
        objDynamicVariables.EventDetailUrl = sitelabel+'eventdetails?id=' + objEvent.Id;
        objDynamicVariables.SuccessURL = hc.Success_Portal_URL__c ;
        objDynamicVariables.KBURL = hc.Knowledge_URL__c ;
        
        
        //Create Meeting Body
        String strMetadata = '';             
        strMetadata += 'BEGIN:VCALENDAR\n';
        strMetadata += 'VERSION:2.0 \n';
        strMetadata += 'PRODID:-//salesforce.com//Calendar//EN \n';
        strMetadata += 'BEGIN:VEVENT\n';
        strMetadata += 'UID:'+eventId+'\n';
        strMetadata += 'DTSTAMP;TZID=America/New_York:'+System.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
        strMetadata += 'SUMMARY:'+objEvent.Subject+'\n';
        strMetadata += 'X-ALT-DESC;FMTTYPE=text/html:'+objEvent.Description+'\n';
        strMetadata += 'CATEGORIES:salesforce.com'+'\n';
        strMetadata += 'CREATED;TZID=America/New_York:'+System.now().format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York')+'\n';
        strMetadata += 'LAST-MODIFIED;TZID=America/New_York:'+System.now().format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York')+'\n';
        strMetadata += 'STATUS:CONFIRMED'+'\n';
        strMetadata += 'LOCATION:'+objEvent.Location+'\n';            
        strMetadata += 'DTSTART;TZID=America/New_York:'+objEvent.StartDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
        strMetadata += 'DTEND;TZID=America/New_York:'+objEvent.EndDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
        strMetadata += 'END:VEVENT \n'+'END:VCALENDAR\n';
        
        //Prepare the attachment.
        objFile.filename = 'meeting.ics';
        objFile.content = EncodingUtil.base64Encode(Blob.valueOf(strMetadata));
        objFile.type = 'text/calendar';
        objFile.content_id = eventId;
        objFile.disposition = 'inline';
        lstAttachments.add(objFile);
        
        //We set the unique id of the related record.
        objUniqueArguments.ccid = eventId;                
        
        //Now we deactivate the click tracking.
        objTrackingMode.enable = false;
        objTrackingSettings.click_tracking = objTrackingMode;
        
        //We make sure the emails are sent, disabling the sandbox mode.
        objSandboxMode.enable = false;
        objMailSettings.sandbox_mode = objSandboxMode;
        
        //Now we set the email as high priority, if needed.
        if(boolIsPriority) {
            objHeaders.priority = 'Urgent';
            objHeaders.importance = 'High';
        }
        
        //Now we add the recipients in such a way that single email is sent to multiple recipients. Max Limit is 1000
        if(getEventFollowersEmails.size()>0){
            for(User u : getEventFollowersEmails) {
                SendGridWrapper.Personalizations objRequest = new SendGridWrapper.Personalizations();
                objRequest.to = new List<SendGridWrapper.EmailIdWrapper>();
                objRequest.dynamic_template_data = objDynamicVariables;
                objRequest.custom_args = objUniqueArguments;            
                SendGridWrapper.EmailIdWrapper objRecipient = new SendGridWrapper.EmailIdWrapper();
                objRecipient.email = u.Email;
                objRecipient.name = u.Name;
                objRequest.to.add(objRecipient); 			
                lstRequests.add(objRequest);			           
            }
            System.debug('lstRequests='+lstRequests);            
        }        
        
        //Now we determine the From and Reply To addresses.
        objSender.name = FROMNAME;        
        objReplyTo.name = FROMNAME;
        objSender.email = FROMADDRESS;
        objReplyTo.email = FROMADDRESS;        
        
        //Now we send the email.
        SendGrid_Templates__mdt mc = SendGrid_Templates__mdt.getInstance('IN_External_Events');
        SendGridEmailService.sendemail(mc.Template_Id__c,lstRequests, objSender, objReplyTo, objMailSettings, objTrackingSettings, objHeaders, lstAttachments);
    }
    
    
    /* Tag 1 starts
    * I2RT-7440 - Discussion: Notification email for Discussion Creation/Updation.
    Method Name : sendMailOnFeedCreationOrUpdation
    Description : This method sends the email to community Followers using the SendGrid service when a discussion is created/updated.
    Parameters	 : Object, called from helpGroupCommunityPostMail, objParameters Email parameters.
    Return Type : None
    */
    @future(callout=true)
    public Static void sendMailOnFeedCreationOrUpdation (String DiscussionId,String UGId,String TopicId,String ProductOrUGLink, String Subject,Boolean isDiscussionCreated,String TopicOrUsrGrpName,String DiscussionTitle,String DiscussionDesc,String DiscussionCreator,String DiscussionLink,String CreatorLink,Boolean isPoll){
        Boolean boolIsPriority = false;
        String sitelabel = System.Label.IN_CommunityName;
        Id networkId = System.label.IN_NetworkID;
        String uniqueId;
        List<CollaborationGroupMember>  grpMembList = new List<CollaborationGroupMember>();           
        List<EntitySubscription>  entityList = new List<EntitySubscription>();
        Set<String> userIdList = new Set<String>();
        
        SendGridINWrapper.Dynamictemplate objDynamicVariables = new SendGridINWrapper.Dynamictemplate(); //tag 4 start SendGridWrapper to SendGridINWrapper
        SendGridINWrapper.EmailIdWrapper objSender = new SendGridINWrapper.EmailIdWrapper();
        SendGridINWrapper.EmailIdWrapper objReplyTo = new SendGridINWrapper.EmailIdWrapper();
        SendGridINWrapper.Uniqueargs objUniqueArguments = new SendGridINWrapper.Uniqueargs();
        SendGridINWrapper.Header objHeaders = new SendGridINWrapper.Header();
        SendGridINWrapper.Tracking_settings objTrackingSettings = new SendGridINWrapper.Tracking_settings();
        SendGridINWrapper.Enable_Mode objTrackingMode = new SendGridINWrapper.Enable_Mode();
        SendGridINWrapper.Enable_Mode objSandboxMode = new SendGridINWrapper.Enable_Mode();
        SendGridINWrapper.Mail_settings objMailSettings = new SendGridINWrapper.Mail_settings();        
        
        List<SendGridINWrapper.FileObject> lstAttachments = new List<SendGridINWrapper.FileObject>();
        List<SendGridINWrapper.Personalizations> lstRequests = new List<SendGridINWrapper.Personalizations>();
        
        help_Infa_Custom_Label__mdt hc = help_Infa_Custom_Label__mdt.getInstance('helpEvents');
        SendGrid_Templates__mdt mc = SendGrid_Templates__mdt.getInstance('IN_Discussion');
        
         /* Tag 3 - get Poll Choices if FeedItem is a PollPost*/
        List<String> pollchoices = new List<String>();
        if(isPoll!=null && isPoll){
            List<FeedPollChoice> pollChoiceList =[SELECT ChoiceBody FROM FeedPollChoice where FeedItemId=:DiscussionId ORDER BY Position];
            if(pollChoiceList.size()>0){
                for(FeedPollChoice fc : pollChoiceList){
                    pollchoices.add(fc.ChoiceBody);
                }            
            }            
        }
        /*Tag 3 ends*/
        
               
        //Set the dynamic template Data        
        objDynamicVariables.TopicOrUsrGrpName = TopicOrUsrGrpName;
        objDynamicVariables.DiscussionTitle = DiscussionTitle;
        objDynamicVariables.DiscussionDesc = DiscussionDesc;
        objDynamicVariables.DiscussionCreator = DiscussionCreator;
        objDynamicVariables.DiscussionLink = DiscussionLink;
        objDynamicVariables.CreatorLink = CreatorLink;
        objDynamicVariables.DisSubject = Subject;
        objDynamicVariables.ProductOrUGLink = (TopicId!=null) ? System.Label.IN_CommunityName +'topiccatalog' : System.Label.IN_CommunityName +'group/CollaborationGroup/Default';
        objDynamicVariables.KBURL = hc.Knowledge_URL__c ;
        objDynamicVariables.SuccessURL = hc.Success_Portal_URL__c ;
        objDynamicVariables.isDiscussionCreated = (isDiscussionCreated) ? true : false;
        objDynamicVariables.currentYear = System.Today().year();
        if(pollchoices.size()>0) objDynamicVariables.PollchoiceList = pollchoices; //Tag 3
                
               
        //Tag 2 starts - Prepare the attachment. 
        List<FeedAttachment> attachList = [Select RecordId FROM FeedAttachment where FeedEntityId=:DiscussionId];
        set<Id> contentVersionIds = new set<Id>();
        
        if(attachList.size()>0){
            for(FeedAttachment att : attachList){
                contentVersionIds.add(att.RecordId);                       
            }            
        }
                
        List<ContentVersion> cvList = [SELECT Id,Title, VersionData FROM ContentVersion WHERE Id in: contentVersionIds];
        for(ContentVersion cv : cvList){
            SendGridINWrapper.FileObject objFile = new SendGridINWrapper.FileObject();
            objFile.filename = cv.Title;
            objFile.content = EncodingUtil.base64Encode(Cv.VersionData);
            objFile.type = 'CONTENT';
            objFile.content_id = cv.Id;
            objFile.disposition = 'inline';
            lstAttachments.add(objFile);
        }
        System.debug('lstAttachments='+lstAttachments);
        
        //Tag 2 ends
          
        //Now we deactivate the click tracking.
        objTrackingMode.enable = false;
        objTrackingSettings.click_tracking = objTrackingMode;
        
        //We make sure the emails are sent, disabling the sandbox mode.
        objSandboxMode.enable = false;
        objMailSettings.sandbox_mode = objSandboxMode;
        
        //Now we set the email as high priority, if needed.
        if(boolIsPriority) {
            objHeaders.priority = 'Urgent';
            objHeaders.importance = 'High';
        }
        
        if(UGId!=null){
            uniqueId = UGId;
            grpMembList = [SELECT MemberId from CollaborationGroupMember where 
                           CollaborationGroupId=:UGId AND NetworkId=:networkId];
            if(grpMembList.size()>0){
                for(CollaborationGroupMember cgm : grpMembList){
                    userIdList.add(cgm.MemberId);                       
                }
                
            }                                     
        }
        else if(TopicId!=null){
            uniqueId = TopicId;
            entityList = [SELECT SubscriberId FROM EntitySubscription 
                          where ParentId =:TopicId AND NetworkId=:networkId ORDER BY CreatedDate DESC];
            if(entityList.size()>0){
                for(EntitySubscription en : entityList){
                    userIdList.add(en.SubscriberId);                       
                }                        
            }          
        }
        System.debug('userIdList='+userIdList);
        List<user> getDiscussionFollowersEmails = [Select email,name from user where Id IN:userIdList];
        System.debug('getDiscussionFollowersEmails='+getDiscussionFollowersEmails);
        System.debug('getDiscussionFollowersEmails size='+getDiscussionFollowersEmails.size());
        
        //We set the unique id of the related record.
        objUniqueArguments.ccid = uniqueId;
        
        //Now we determine the From and Reply To addresses.
        objSender.name = FROMNAME;        
        objReplyTo.name = FROMNAME;
        objSender.email = FROMADDRESS;
        objReplyTo.email = FROMADDRESS;       
       
        
        //Now we add the recipients in such a way that single email is sent to multiple recipients. Max Limit is 1000
        if(getDiscussionFollowersEmails.size()>0){
            for(User u : getDiscussionFollowersEmails){
                SendGridINWrapper.Personalizations objRequest = new SendGridINWrapper.Personalizations();
                objRequest.to = new List<SendGridINWrapper.EmailIdWrapper>();
                objRequest.dynamic_template_data = objDynamicVariables;
                //objRequest.custom_args = objUniqueArguments;            
                SendGridINWrapper.EmailIdWrapper objRecipient = new SendGridINWrapper.EmailIdWrapper();
                objRecipient.email = u.Email;
                objRecipient.name = u.Name;
                objRequest.to.add(objRecipient);
                lstRequests.add(objRequest);
          }
            System.debug('lstRequests Data=>'+lstRequests);
            System.debug('lstRequests outside='+lstRequests.size());            
        }
        
        List<SendGridINWrapper.Personalizations> finalPersonlizationList = new List<SendGridINWrapper.Personalizations>();
        
        for(integer i=0; i < lstRequests.size(); i++){
            finalPersonlizationList.add(lstRequests[i]);            
            if(finalPersonlizationList.size()== hc.Email_Size__c ){         
                System.debug('finalPersonlizationList size is equal to 1000='+finalPersonlizationList.size());                
                System.debug('Processed Request ='+ String.valueOf(i));                
                //Now we send the email.                        
                SendGridINEmailService.sendemail(mc.Template_Id__c,finalPersonlizationList, objSender, objReplyTo, objMailSettings, objTrackingSettings, objHeaders,lstAttachments);                
                finalPersonlizationList = new List<SendGridINWrapper.Personalizations>();               
            }           
        }
        
        /*for(SendGridWrapper.Personalizations  personalizationItem: lstRequests){
            finalPersonlizationList.add(personalizationItem);
            if(finalPersonlizationList.size()==50){
                System.debug('finalPersonlizationList size is equal to 1000='+finalPersonlizationList.size());
                //Now we send the email.        
                SendGridEmailService.sendemail(mc.Template_Id__c,finalPersonlizationList, objSender, objReplyTo, objMailSettings, objTrackingSettings, objHeaders, lstAttachments);
                finalPersonlizationList = new List<SendGridWrapper.Personalizations>();
            }           
        }*/      
        if(finalPersonlizationList.size()< hc.Email_Size__c){
            System.debug('finalPersonlizationList size Less than 1000='+finalPersonlizationList.size());
            SendGridINEmailService.sendemail(mc.Template_Id__c,finalPersonlizationList, objSender, objReplyTo, objMailSettings, objTrackingSettings, objHeaders, lstAttachments);
        }        
    }  
    /* Tag 1 ends */
    
    
}