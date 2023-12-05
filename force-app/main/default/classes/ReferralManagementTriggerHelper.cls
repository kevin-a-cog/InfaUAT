/*
* Name      :  ReferralManagementTriggerHelper
* Author    :  Pavithra V
* Created Date  :   9/17/2021
* Description  :  Helper class which implements chatter functionality on creation/updation of chatter

Change History
**********************************************************************************************************
Modified By         Date      Jira No.    Description                                         Tag
**********************************************************************************************************
Harshita Joshi   20-06-2022   AR-2395     Replace Ref Name,Plan Name on chatter with link     <t1>
ChaitanyaT       14-09-2023   AR-3383     Expansion Lead File upload and chatter post update  T02
*/
public with sharing class ReferralManagementTriggerHelper {
    public  void processBeforeInsert(List<iCare_Referral__c> newList){
        
    }

    public  void processAfterInsert(List<iCare_Referral__c> newList){
        if(Global_Config__c.getInstance().Mute_Notifications__c != null && Global_Config__c.getInstance().Mute_Notifications__c != true){
            List<Id> refIdList = new List<Id>();//<T02> start
            for(iCare_Referral__c ref:newList){
                if(ref.Source__c!='Plan'){
                    refIdList.add(ref.Id);
                }
            }
            if(refIdList?.size()>0){
                notifyOwnerOnReferralCreation(refIdList);
            }//</T02> end
        }
    }

    public  void processBeforeUpdate(List<iCare_Referral__c> newList,Map<Id,iCare_Referral__c> oldMap){
        Group smgGrp = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'SMG'];//<T02> start
        List<GroupMember> smgGrpMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:smgGrp.Id AND UserOrGroupId=:UserInfo.getUserId()];
        Boolean isUserGrpMember = false;
        if(smgGrpMembers?.size()>0){
            isUserGrpMember = true;
        }
        for(iCare_Referral__c ref : newList){
            if(ref.Source__c == 'Plan' && ref.Status__c <> oldMap.get(ref.Id).Status__c){
                if(isUserGrpMember == false){
                    ref.addError(System.label.PlanReferralStatusErrorMsg);
                }
                if(oldMap.get(ref.Id).Status__c == 'New' && ref.Status__c <> 'Accepted'){
                    ref.addError(System.label.PlanReferralStatusIllegalPathErrMsg);
                }
                if(ref.Status__c == 'New'){
                    ref.addError(System.label.PlanReferralRestrictBackTrackToNew);
                }
                if(oldMap.get(ref.Id).Status__c == 'New' && ref.ownerId == smgGrp.Id){
                    ref.ownerId = UserInfo.getUserId();
                }
            }
        }
        //</T02> end
    }

    public  void processAfterUpdate(List<iCare_Referral__c> newList,Map<Id,iCare_Referral__c> oldMap){
        Set<Id> referralIdSet = new Set<Id>();
        Set<Id> refSetForChatter = new Set<Id>();//<T02>
        Set<Id> refAccountSet = new Set<Id>();//<T02>
        for(iCare_Referral__c ref : newList){
            if(ref.Status__c <> oldMap.get(ref.Id).Status__c){//<T02> start
                if(ref.Source__c == 'Plan' && (ref.Status__c != 'Cancelled' && ref.Status__c != 'Converted')){
                    referralIdSet.add(ref.Id);
                }
                if(ref.Source__c!='Plan'){
                    referralIdSet.add(ref.Id);
                }
            }
            if(ref.Source__c == 'Plan' && (ref.Status__c == 'Cancelled' || ref.Status__c == 'Converted')){
                refSetForChatter.add(ref.Id);
                refAccountSet.add(ref.Customer_Account__c);
            }
        }//</T02> end
        if(referralIdSet?.size()>0){
            notifyReferrerOnStatusChange(referralIdSet);
        }
        if(refSetForChatter?.size()>0){//<T02> start
            chatterOnPlanConvertedCancelledStatus(refSetForChatter,refAccountSet);
        }//</T02> end
        
    }

    public static void notifyOwnerOnReferralCreation(List<Id> refIdList){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        Map<Id,List<ContentDocumentLink>> refFileLinkMap = new Map<Id,List<ContentDocumentLink>>();//<T02> start
        List<ContentDocumentLink> contentDocList = [select Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId IN :refIdList];
        if(contentDocList?.size()>0){
            for(ContentDocumentLink conDocRec:contentDocList){
                if(refFileLinkMap.containsKey(conDocRec.LinkedEntityId)){
                    List<ContentDocumentLink> existingFileIds = refFileLinkMap.get(conDocRec.LinkedEntityId);
                    existingFileIds.add(conDocRec);
                    refFileLinkMap.put(conDocRec.LinkedEntityId,existingFileIds);
                }else{
                    List<ContentDocumentLink> newFileIds = new List<ContentDocumentLink>();
                    newFileIds.add(conDocRec);
                    refFileLinkMap.put(conDocRec.LinkedEntityId,newFileIds);
                }
            }
        }//</T02> end
        
        for(iCare_Referral__c ref : [SELECT Id,Name,OwnerId,Source__c,CreatedBy.Name,Customer_Contact__r.Name,Customer_Account__r.Name, Support_Account__r.Name,Support_Account__c,Customer_Account__c,Description__c,Product__c,Plan__c,Plan__r.Name,Customer_Account__r.New_Org_Account_Number__c FROM iCare_Referral__c WHERE Id IN:refIdList]){
           
            String message ='';            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            String recordLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/iCare_Referral__c/'+ ref.Id + '/view';
            String recordPlanLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Plan__c/'+ ref.Plan__c + '/view';
            String recordAccLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Account/'+ ref.Customer_Account__c + '/view';//<T02>
            //Get the Target ID
            input.subjectId = ref.Id; 
            
            //Get the chatter message
            message = 'A new referral ';
           //<t1> as part of AR-2395
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message;
            body.messageSegments.add(textSegment);
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
            ConnectApi.MarkupEndSegmentInput markupEndSegment;
            
            markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegment.url=recordLink;
            markupBeginSegment.altText=recordLink;//<T02>
            body.messageSegments.add(markupBeginSegment);
            
            ConnectApi.TextSegmentInput textSegmenthyperlink = new ConnectApi.TextSegmentInput();
            textSegmenthyperlink.text = ref.Name;
            body.messageSegments.add(textSegmenthyperlink );
            
            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegment);
            
            message = ' has been created.\n\n';
            
            ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
            textSegment2.text = message;
            body.messageSegments.add(textSegment2);
            
           
            message = 'Account Name : ';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph1;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph1;
            
            markupBeginSegmentParagraph1 = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph1);
            
            ConnectApi.TextSegmentInput textSegment3 = new ConnectApi.TextSegmentInput();
            textSegment3.text = message;
            body.messageSegments.add(textSegment3);

            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentAccLink;//<T02> start
            ConnectApi.MarkupEndSegmentInput markupEndSegmentAccLink;
            
            markupBeginSegmentAccLink= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegmentAccLink.url=recordAccLink;
            markupBeginSegmentAccLink.altText=recordAccLink;
            body.messageSegments.add(markupBeginSegmentAccLink);
            
            ConnectApi.TextSegmentInput textSegmenthyperlinkAccount = new ConnectApi.TextSegmentInput();
            textSegmenthyperlinkAccount.text = ref.Customer_Account__r.Name;
            body.messageSegments.add(textSegmenthyperlinkAccount);
            
            markupEndSegmentAccLink= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegmentAccLink);//</T02> end

            markupEndSegmentParagraph1 = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph1);

            message = 'Account Number : '+ ref.Customer_Account__r.New_Org_Account_Number__c +'\n';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentAccNumber;//<T02> start
            ConnectApi.MarkupEndSegmentInput markupEndSegmentAccNumber;
            
            markupBeginSegmentAccNumber= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentAccNumber.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentAccNumber);
            
            ConnectApi.TextSegmentInput textSegmentAccNumber = new ConnectApi.TextSegmentInput();
            textSegmentAccNumber.text = message;
            body.messageSegments.add(textSegmentAccNumber);
            
            markupEndSegmentAccNumber= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentAccNumber.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentAccNumber);

            message = 'Cassini consumption Trend : ';
            ConnectApi.TextSegmentInput textSegmentCassini = new ConnectApi.TextSegmentInput();
            textSegmentCassini.text = message;
            body.messageSegments.add(textSegmentCassini);

            if(ref.Source__c == 'Plan' && refFileLinkMap.size()>0 && refFileLinkMap.containsKey(ref.Id)){
                
                for(ContentDocumentLink conDoc:refFileLinkMap.get(ref.Id)){
                    String fileUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/ContentDocument/'+ conDoc.ContentDocumentId + '/view';
                    ConnectApi.MarkupBeginSegmentInput markupBeginSegmentCassini;
                    ConnectApi.MarkupEndSegmentInput markupEndSegmentHypCassini;
                    
                    markupBeginSegmentCassini= new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegmentCassini.markupType = ConnectApi.MarkupType.Hyperlink;
                    markupBeginSegmentCassini.altText = fileUrl;
                    markupBeginSegmentCassini.url = fileUrl;
                    body.messageSegments.add(markupBeginSegmentCassini);
                    
                    ConnectApi.TextSegmentInput textSegmenthyperlinkCassini = new ConnectApi.TextSegmentInput();
                    textSegmenthyperlinkCassini.text = conDoc.ContentDocument.Title;
                    body.messageSegments.add(textSegmenthyperlinkCassini);
                    
                    markupEndSegmentHypCassini= new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegmentHypCassini.markupType = ConnectApi.MarkupType.Hyperlink;
                    body.messageSegments.add(markupEndSegmentHypCassini);

                    message = ' ';
                    ConnectApi.TextSegmentInput textSegmentSpace = new ConnectApi.TextSegmentInput();
                    textSegmentSpace.text = message;
                    body.messageSegments.add(textSegmentSpace);
                }
            }//</T02> end
            
            message = 'Contact Name: '+ ref.Customer_Contact__r.Name +'\n';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph2;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph2;
            
            markupBeginSegmentParagraph2= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph2);
            
            ConnectApi.TextSegmentInput textSegment4 = new ConnectApi.TextSegmentInput();
            textSegment4.text = message;
            body.messageSegments.add(textSegment4);
            
            markupEndSegmentParagraph2= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph2);
            
            message = 'Referred By : '+ ref.CreatedBy.Name + '\n';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph3;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph3;
            
            markupBeginSegmentParagraph3= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph3.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph3);
            
            ConnectApi.TextSegmentInput textSegment5 = new ConnectApi.TextSegmentInput();
            textSegment5.text = message;
            body.messageSegments.add(textSegment5);
            
            markupEndSegmentParagraph3= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph3.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph3);
            
            if(ref.Source__c != 'Plan'){
            message = 'Source : '+ ref.Source__c + '\n';
            
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph4;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph4;
            
            markupBeginSegmentParagraph4= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph4.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph4);
            
            ConnectApi.TextSegmentInput textSegment6 = new ConnectApi.TextSegmentInput();
            textSegment6.text = message;
            body.messageSegments.add(textSegment6);
            
            markupEndSegmentParagraph4= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph4.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph4);
            }
            else{
             message = 'Source : ';
             
            ConnectApi.TextSegmentInput textSegment7 = new ConnectApi.TextSegmentInput();
            textSegment7.text = message;
            body.messageSegments.add(textSegment7);
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentHyp2;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentHyp2;
            
            markupBeginSegmentHyp2= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentHyp2.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegmentHyp2.url=recordPlanLink;
            markupBeginSegmentHyp2.altText=recordPlanLink;//<T02>
            body.messageSegments.add(markupBeginSegmentHyp2);
            
            ConnectApi.TextSegmentInput textSegmenthyperlink2 = new ConnectApi.TextSegmentInput();
            textSegmenthyperlink2.text = 'Plan';
            body.messageSegments.add(textSegmenthyperlink2);
            
            markupEndSegmentHyp2= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentHyp2.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegmentHyp2);
             
             
            }
             
            if(ref.Product__c!=null){
                message = 'Product : '+ ref.Product__c + '\n';
            }else{
                message = 'Product : ';
            }
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph5;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph5;
            
            markupBeginSegmentParagraph5= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph5.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph5);
            
            ConnectApi.TextSegmentInput textSegment8 = new ConnectApi.TextSegmentInput();
            textSegment8.text = message;
            body.messageSegments.add(textSegment8);
            
            markupEndSegmentParagraph5= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph5.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph5);
            //</t1> as part of AR-2395

            if(ref.Source__c == 'Plan'){//<T02> start
                message = 'CSM Comments : '+ ref.Description__c + '\n';
             
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentDescriptionPara;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentDescriptionPara;
                
                markupBeginSegmentDescriptionPara= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentDescriptionPara.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentDescriptionPara);
                
                ConnectApi.TextSegmentInput textSegmentDescription = new ConnectApi.TextSegmentInput();
                textSegmentDescription.text = message;
                body.messageSegments.add(textSegmentDescription);
                
                markupEndSegmentDescriptionPara= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentDescriptionPara.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentDescriptionPara);
            }//</T02> end
            
            //Get the mention Users
            for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =:ref.OwnerId]) {
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                mentionSegmentInput.id = gm.UserOrGroupId;
                body.messageSegments.add(mentionSegmentInput);
            }
            input.body = body;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input); 

            batchInputs.add(batchInput);
        }
        

        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
        }
    }

    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }

    public static void notifyReferrerOnStatusChange(Set<Id> referralIdSet){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();        

        for(iCare_Referral__c ref : [SELECT Id,Name,OwnerId,CreatedById,Status__c  from iCare_Referral__c WHERE Id in:referralIdSet]){
           
            String message ='';            
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

            //Get the Target ID
            input.subjectId = ref.Id; 
            String recordLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/iCare_Referral__c/'+ ref.Id + '/view';

            //<t1> as part of AR-2395 for update
            //Get the chatter message
            
            message = 'The referral ';
           
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message;
            body.messageSegments.add(textSegment);
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
            ConnectApi.MarkupEndSegmentInput markupEndSegment;
            
            markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegment.url=recordLink;
            body.messageSegments.add(markupBeginSegment);
            
            ConnectApi.TextSegmentInput textSegmenthyperlink = new ConnectApi.TextSegmentInput();
            textSegmenthyperlink.text = ref.Name;
            body.messageSegments.add(textSegmenthyperlink );
            
            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegment);
            
            message = ' has been updated with the Status - '+ ref.Status__c+'.\n';
            
            ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
            textSegment2.text = message;
            body.messageSegments.add(textSegment2);
            
            message = '';
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph;
            
            markupBeginSegmentParagraph = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph);
            
            ConnectApi.TextSegmentInput textSegment3 = new ConnectApi.TextSegmentInput();
            textSegment3.text = message;
            body.messageSegments.add(textSegment3);
            
            markupEndSegmentParagraph = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph);
            //</t1> as part of AR-2395 for update

            //Get the mention Users
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = ref.CreatedById;
            body.messageSegments.add(mentionSegmentInput);

            input.body = body;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input); 

            batchInputs.add(batchInput);
        }
        

        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
        }
    }

    //<T02> start
    /*
	 Method Name : 	chatterOnPlanConvertedCancelledStatus
	 Description :	Chatter post for the Plan referral
	 Parameters	 :  Set<Id> refIdSet
	 				Set<Id> refAccountSet
	 Return Type : 	n/a
	 */
    public static void chatterOnPlanConvertedCancelledStatus(Set<Id> refIdSet,Set<Id> refAccountSet){
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        Map<Id,List<ContentDocumentLink>> refFileLinkMap = new Map<Id,List<ContentDocumentLink>>();
        List<ContentDocumentLink> contentDocList = [select Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId IN :refIdSet];
        if(contentDocList?.size()>0){
            for(ContentDocumentLink conDocRec:contentDocList){
                if(refFileLinkMap.containsKey(conDocRec.LinkedEntityId)){
                    List<ContentDocumentLink> existingFileIds = refFileLinkMap.get(conDocRec.LinkedEntityId);
                    existingFileIds.add(conDocRec);
                    refFileLinkMap.put(conDocRec.LinkedEntityId,existingFileIds);
                }else{
                    List<ContentDocumentLink> newFileIds = new List<ContentDocumentLink>();
                    newFileIds.add(conDocRec);
                    refFileLinkMap.put(conDocRec.LinkedEntityId,newFileIds);
                }
            }
        }
        Map<Id,Double> accFlexMap = new Map<Id,Double>();
        CSM_Static_Value__mdt existingIpuQuery = [SELECT Id,Value_Long_text__c FROM CSM_Static_Value__mdt WHERE DeveloperName ='IPU_ExistingIPUReferral'];
        List<SBQQ__Subscription__c> subList = Database.query(existingIpuQuery.Value_Long_text__c);
        if(subList?.size()>0){
            for(SBQQ__Subscription__c subscription:subList){
                if(accFlexMap.containsKey(subscription.SBQQ__Contract__r.AccountId)){
                    Double count = accFlexMap.get(subscription.SBQQ__Contract__r.AccountId);
                    count = count + subscription.SBQQ__Quantity__c;
                    accFlexMap.put(subscription.SBQQ__Contract__r.AccountId,count);
                }else{
                    accFlexMap.put(subscription.SBQQ__Contract__r.AccountId,subscription.SBQQ__Quantity__c);
                }
            }
        }

        /*Map<Id,AccountTeamMember> accTeamMap = new Map<Id,AccountTeamMember>();
        List<AccountTeamMember> accTeamList = [SELECT Id,UserId,User.Email,User.ManagerId,User.Manager.Email,AccountId FROM AccountTeamMember where TeamMemberRole = 'CSM' AND AccountId IN :refAccountSet ORDER BY CreatedDate DESC];
        for(AccountTeamMember accTeam:accTeamList){
            if(!accTeamMap.containsKey(accTeam.AccountId)){
                accTeamMap.put(accTeam.AccountId,accTeam);
            }
        }*/
        /*Set<Id> refOwnerSet = new Set<Id>();
        for(iCare_Referral__c ref : [SELECT Id,Plan__r.OwnerId  FROM iCare_Referral__c WHERE Id in:refIdSet]){
            refOwnerSet.add(ref.Plan__r.OwnerId);
        }
        Map<Id,User> userOwnerIdMap = new Map<Id,User>([SELECT Id,ManagerId FROM User WHERE Id IN:refOwnerSet]);*/
        
        Map<Id,Map<String,Id>> planCsmMap = new Map<Id,Map<String,Id>>();//<T02> start
        Set<Id> planIdSet = new Set<Id>();
        for(iCare_Referral__c ref : [SELECT Id,Plan__c FROM iCare_Referral__c WHERE Id in:refIdSet]){
            planIdSet.add(ref.Plan__c);
        }
        for(Plan_Team__c plTeamMembers : [SELECT Id, User__c, Plan__c, Role__c FROM Plan_Team__c WHERE Plan__c IN:planIdSet AND Primary__c = true AND Role__c IN ('CSM','CSM Manager') ORDER BY LastModifiedDate DESC]){
            if(planCsmMap.containsKey(plTeamMembers.Plan__c)){
                Map<String,Id> existingCsmIdMap = planCsmMap.get(plTeamMembers.Plan__c);
                if(existingCsmIdMap.containsKey('CSM') == false && plTeamMembers.Role__c == 'CSM'){
                    existingCsmIdMap.put(plTeamMembers.Role__c,plTeamMembers.User__c);
                    planCsmMap.put(plTeamMembers.Plan__c,existingCsmIdMap);
                }
                if(existingCsmIdMap.containsKey('CSM Manager') == false && plTeamMembers.Role__c == 'CSM Manager'){
                    existingCsmIdMap.put(plTeamMembers.Role__c,plTeamMembers.User__c);
                    planCsmMap.put(plTeamMembers.Plan__c,existingCsmIdMap);
                }
            }else{
                Map<String,Id> newCsmIdMap = new Map<String,Id>();
                if(plTeamMembers.Role__c == 'CSM'){
                    newCsmIdMap.put(plTeamMembers.Role__c,plTeamMembers.User__c);
                    planCsmMap.put(plTeamMembers.Plan__c,newCsmIdMap);
                }
                if(plTeamMembers.Role__c == 'CSM Manager'){
                    newCsmIdMap.put(plTeamMembers.Role__c,plTeamMembers.User__c);
                    planCsmMap.put(plTeamMembers.Plan__c,newCsmIdMap);
                }
            }
        }//</T02> end
        for(iCare_Referral__c ref : [SELECT Id,Plan__c,Name,Customer_Contact__c,Status__c,Customer_Account__c,Customer_Account__r.New_Org_Account_Number__c,Customer_Account__r.Name,CreatedBy.Name,Cancellation_Reason__c,Win_Reasons__c,Opportunity__c,Opportunity__r.Name,Referral_Dispositioning_Information__c,Opportunity__r.OwnerId,Opportunity__r.Owner.ManagerId,Plan__r.OwnerId  FROM iCare_Referral__c WHERE Id in:refIdSet]){
            String message ='';            
            String recordLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/iCare_Referral__c/'+ ref.Id + '/view';
            String recordAccLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Account/'+ ref.Customer_Account__c + '/view';
            String cassiniAccLink = System.Label.Cassini_Account+ref.Customer_Account__r.New_Org_Account_Number__c;
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = ref.Id;
            message = 'The referral ';
           
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message;
            body.messageSegments.add(textSegment);
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
            ConnectApi.MarkupEndSegmentInput markupEndSegment;
            
            markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegment.url=recordLink;
            markupBeginSegment.altText=recordLink;
            body.messageSegments.add(markupBeginSegment);
            
            ConnectApi.TextSegmentInput textSegmenthyperlink = new ConnectApi.TextSegmentInput();
            textSegmenthyperlink.text = ref.Name;
            body.messageSegments.add(textSegmenthyperlink );
            
            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegment.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegment);
            
            message = ' has been '+ref.Status__c+'.\n\n';
            
            ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
            textSegment2.text = message;
            body.messageSegments.add(textSegment2);

            message = 'Account Name : ';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph1;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph1;
            
            markupBeginSegmentParagraph1 = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph1);
            
            ConnectApi.TextSegmentInput textSegment3 = new ConnectApi.TextSegmentInput();
            textSegment3.text = message;
            body.messageSegments.add(textSegment3);

            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentAccLink;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentAccLink;
            
            markupBeginSegmentAccLink= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegmentAccLink.url=recordAccLink;
            markupBeginSegmentAccLink.altText=recordAccLink;
            body.messageSegments.add(markupBeginSegmentAccLink);
            
            ConnectApi.TextSegmentInput textSegmenthyperlinkAccount = new ConnectApi.TextSegmentInput();
            textSegmenthyperlinkAccount.text = ref.Customer_Account__r.Name;
            body.messageSegments.add(textSegmenthyperlinkAccount);
            
            markupEndSegmentAccLink= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegmentAccLink);

            markupEndSegmentParagraph1 = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph1);

            message = 'Account Number : '+ ref.Customer_Account__r.New_Org_Account_Number__c +'\n';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentAccNumber;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentAccNumber;
            
            markupBeginSegmentAccNumber= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentAccNumber.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentAccNumber);
            
            ConnectApi.TextSegmentInput textSegmentAccNumber = new ConnectApi.TextSegmentInput();
            textSegmentAccNumber.text = message;
            body.messageSegments.add(textSegmentAccNumber);
            
            markupEndSegmentAccNumber= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentAccNumber.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentAccNumber);

            message = 'Cassini Account Link : ';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph2;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph2;
            
            markupBeginSegmentParagraph2 = new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParagraph2);
            
            ConnectApi.TextSegmentInput textSegmentAcc = new ConnectApi.TextSegmentInput();
            textSegmentAcc.text = message;
            body.messageSegments.add(textSegmentAcc);

            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentCassiniAccLink;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentCassiniAccLink;
            
            markupBeginSegmentCassiniAccLink= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentCassiniAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            markupBeginSegmentCassiniAccLink.url=cassiniAccLink;
            markupBeginSegmentCassiniAccLink.altText=cassiniAccLink;
            body.messageSegments.add(markupBeginSegmentCassiniAccLink);
            
            ConnectApi.TextSegmentInput textSegmenthyperlinkCassiniAcc = new ConnectApi.TextSegmentInput();
            textSegmenthyperlinkCassiniAcc.text = ref.Customer_Account__r.Name;
            body.messageSegments.add(textSegmenthyperlinkCassiniAcc);
            
            markupEndSegmentCassiniAccLink= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentCassiniAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
            body.messageSegments.add(markupEndSegmentCassiniAccLink);

            markupEndSegmentParagraph2 = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParagraph2);

            message = 'Cassini consumption Trend : ';
            ConnectApi.TextSegmentInput textSegmentCassini = new ConnectApi.TextSegmentInput();
            textSegmentCassini.text = message;
            body.messageSegments.add(textSegmentCassini);

            if(refFileLinkMap.containsKey(ref.Id)){
                for(ContentDocumentLink conDoc:refFileLinkMap.get(ref.Id)){
                    String fileUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/ContentDocument/'+ conDoc.ContentDocumentId + '/view';
                    ConnectApi.MarkupBeginSegmentInput markupBeginSegmentCassini;
                    ConnectApi.MarkupEndSegmentInput markupEndSegmentHypCassini;
                    
                    markupBeginSegmentCassini= new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegmentCassini.markupType = ConnectApi.MarkupType.Hyperlink;
                    markupBeginSegmentCassini.altText = fileUrl;
                    markupBeginSegmentCassini.url = fileUrl;
                    body.messageSegments.add(markupBeginSegmentCassini);
                    
                    ConnectApi.TextSegmentInput textSegmenthyperlinkCassini = new ConnectApi.TextSegmentInput();
                    textSegmenthyperlinkCassini.text = conDoc.ContentDocument.Title;
                    body.messageSegments.add(textSegmenthyperlinkCassini);
                    
                    markupEndSegmentHypCassini= new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegmentHypCassini.markupType = ConnectApi.MarkupType.Hyperlink;
                    body.messageSegments.add(markupEndSegmentHypCassini);
                    
                    message = ' ';
                    ConnectApi.TextSegmentInput textSegmentSpace = new ConnectApi.TextSegmentInput();
                    textSegmentSpace.text = message;
                    body.messageSegments.add(textSegmentSpace);
                }
            }
            
            message = 'Referred By : '+ ref.CreatedBy.Name + '\n';
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParaReferredBy;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParaReferredBy;
            
            markupBeginSegmentParaReferredBy= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParaReferredBy.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParaReferredBy);
            
            ConnectApi.TextSegmentInput textReferredBy = new ConnectApi.TextSegmentInput();
            textReferredBy.text = message;
            body.messageSegments.add(textReferredBy);
            
            markupEndSegmentParaReferredBy= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParaReferredBy.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParaReferredBy);

            if(accFlexMap.get(ref.Customer_Account__c)==null){
                message = 'Existing IPU : 0';
            }else{
                message = 'Existing IPU : '+String.valueOf(accFlexMap.get(ref.Customer_Account__c));
            }
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParaExistingIPU;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParaExistingIPU;
            
            markupBeginSegmentParaExistingIPU= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParaExistingIPU.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParaExistingIPU);
            
            ConnectApi.TextSegmentInput textExistingIPU = new ConnectApi.TextSegmentInput();
            textExistingIPU.text = message;
            body.messageSegments.add(textExistingIPU);
            
            markupEndSegmentParaExistingIPU= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParaExistingIPU.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParaExistingIPU);

            if(ref.Status__c == 'Cancelled'){
                message = 'Lost reasons : '+ ref.Cancellation_Reason__c + '\n';
            }else{
                message = 'Win reasons : '+ ref.Win_Reasons__c + '\n';
            }
            
            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParaWinLoseReasons;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParaWinLoseReasons;
            
            markupBeginSegmentParaWinLoseReasons= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParaWinLoseReasons.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParaWinLoseReasons);
            
            ConnectApi.TextSegmentInput textWinLoseReasons = new ConnectApi.TextSegmentInput();
            textWinLoseReasons.text = message;
            body.messageSegments.add(textWinLoseReasons);
            
            markupEndSegmentParaWinLoseReasons= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParaWinLoseReasons.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParaWinLoseReasons);

            if(ref.Status__c=='Converted'){
                String recordOpptyLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Opportunity/'+ ref.Opportunity__c + '/view';
                message = 'New IPU : ';
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParaNewIPU;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParaNewIPU;
                
                markupBeginSegmentParaNewIPU= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParaNewIPU.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParaNewIPU);
                
                ConnectApi.TextSegmentInput textNewIPU = new ConnectApi.TextSegmentInput();
                textNewIPU.text = message;
                body.messageSegments.add(textNewIPU);

                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentOpptyLink;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentOpptyLink;
                
                markupBeginSegmentOpptyLink= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentOpptyLink.markupType = ConnectApi.MarkupType.Hyperlink;
                markupBeginSegmentOpptyLink.url=recordOpptyLink;
                markupBeginSegmentOpptyLink.altText=recordOpptyLink;
                body.messageSegments.add(markupBeginSegmentOpptyLink);
                
                ConnectApi.TextSegmentInput textSegmenthyperlinkOppty = new ConnectApi.TextSegmentInput();
                textSegmenthyperlinkOppty.text = ref.Opportunity__r.Name;
                body.messageSegments.add(textSegmenthyperlinkOppty);
                
                markupEndSegmentOpptyLink= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentOpptyLink.markupType = ConnectApi.MarkupType.Hyperlink;
                body.messageSegments.add(markupEndSegmentOpptyLink);
                
                markupEndSegmentParaNewIPU= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParaNewIPU.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParaNewIPU);
            }

            message = 'Closing notes : '+ ref.Referral_Dispositioning_Information__c + '\n';

            ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParaRefDisInfo;
            ConnectApi.MarkupEndSegmentInput markupEndSegmentParaRefDisInfo;
            
            markupBeginSegmentParaRefDisInfo= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentParaRefDisInfo.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupBeginSegmentParaRefDisInfo);
            
            ConnectApi.TextSegmentInput textRefDisInfo = new ConnectApi.TextSegmentInput();
            textRefDisInfo.text = message;
            body.messageSegments.add(textRefDisInfo);
            
            markupEndSegmentParaRefDisInfo= new ConnectApi.MarkupEndSegmentInput();
            markupEndSegmentParaRefDisInfo.markupType = ConnectApi.MarkupType.Paragraph;
            body.messageSegments.add(markupEndSegmentParaRefDisInfo);

            if(planCsmMap?.get(ref.Plan__c)?.get('CSM') != null){//
                ConnectApi.MentionSegmentInput mentionCSMUser = new ConnectApi.MentionSegmentInput();
                mentionCSMUser.id = planCsmMap.get(ref.Plan__c).get('CSM');
                body.messageSegments.add(mentionCSMUser);
            }
            
            if(planCsmMap?.get(ref.Plan__c)?.get('CSM Manager') != null){
                ConnectApi.MentionSegmentInput mentionCSMManagerUser = new ConnectApi.MentionSegmentInput();
                mentionCSMManagerUser.id = planCsmMap.get(ref.Plan__c).get('CSM Manager');
                body.messageSegments.add(mentionCSMManagerUser);
            }

            if(ref.Status__c == 'Converted'){
                ConnectApi.MentionSegmentInput mentionOpptyOwner = new ConnectApi.MentionSegmentInput();
                mentionOpptyOwner.id = ref.Opportunity__r.OwnerId;
                body.messageSegments.add(mentionOpptyOwner);
    
                ConnectApi.MentionSegmentInput mentionOpptyOwnerManager = new ConnectApi.MentionSegmentInput();
                mentionOpptyOwnerManager.id = ref.Opportunity__r.Owner.ManagerId;
                body.messageSegments.add(mentionOpptyOwnerManager);
            }
            
            input.body = body;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input); 

            batchInputs.add(batchInput);
        }

        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
        }
    }//</T02> end

}