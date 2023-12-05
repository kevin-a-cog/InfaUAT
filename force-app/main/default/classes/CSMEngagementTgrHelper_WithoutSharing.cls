/*Change History
 ****************************************************************************************************************************
 Modified By			Date			Jira No.		Description					                                    Tag
 *****************************************************************************************************************************
 Chaitanya T			10-Nov-2023	   AR-3549       Chatter post to tag CSM logic is now changed to get it from 
 													 Plan Teams if plan is present else get it from Account CSM			T01
 */
public without sharing class CSMEngagementTgrHelper_WithoutSharing {
    public static void createPlanCommentforApproval(Set<Id> engagementIdSet , String Comments){
		for(Engagement__c eng : [Select Id,CreatedBy.Name,Plan__c,RecordType.DeveloperName,RecType__c from Engagement__c where Id in:engagementIdSet]){
			Plan_Comment__c pComments = new Plan_Comment__c();
			pComments.Type__c = CSMUtilities.TYPE_INTERNAL;
			pComments.Status__c = 'Submitted';
			pComments.Sub_Type__c = 'Engagement';
			pComments.Is_Automated__c = true;
			pComments.Plan__c = eng.Plan__c;
			String updateComment=Comments;
			if(eng.RecordType.DeveloperName.equals('IPS_Jumpstart')){
				updateComment= Comments.replace('#EngType#', 'IPS');
			}
			if(eng.RecordType.DeveloperName.equals('CST')){
				if(eng.RecType__c == 'CSA'){
					updateComment = Comments.replace('#EngType#', 'CSA');
				}else if(eng.RecType__c == 'MFA'){
					updateComment = Comments.replace('#EngType#', 'MFA');
				}
			}
			pComments.Comment__c = updateComment.replace('#CSMNAME#', eng.CreatedBy.Name);
			insert pComments;
		}
	}

	public static void createCSAExternalComments(Set<Id> engList, Set<Id> engAccSet, Set<Id> engPlanSet){//<T01> added new parameter engPlanSet
		List<Plan_Comment__c> commentList= new List<Plan_Comment__c>();		
		List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();

		List<AccountTeamMember> accTeamList = [SELECT AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :engAccSet AND TeamMemberRole='CSM' ORDER BY CreatedDate DESC];
		Map<Id,Id> accUserIdMap = new Map<Id,Id>();
		if(!accTeamList.isEmpty()){
			for(AccountTeamMember accMem:accTeamList){
				if(!accUserIdMap.containsKey(accMem.AccountId) && accMem.UserId!=null){
					accUserIdMap.put(accMem.AccountId,accMem.UserId);
				}
			}
		}
		Map<Id,Id> engCsmMap = new Map<Id,Id>();//<T01> start
		if(engPlanSet !=null){
			for(Plan_Team__c plTeamMembers : [SELECT Id, User__c, Plan__c, Role__c FROM Plan_Team__c WHERE Plan__c IN:engPlanSet AND Primary__c = true AND Role__c ='CSM' ORDER BY LastModifiedDate DESC]){
				if(engCsmMap.containsKey(plTeamMembers.Plan__c) == false){
					engCsmMap.put(plTeamMembers.Plan__c,plTeamMembers.User__c);
				}
			}
		}//</T01> end
		
		for(Engagement__c eng : [Select Id, Catalog_URL__c, Closing_Notes__c, RecordTypeId, Status__c, Plan__c, CreatedDate, Name, OwnerID ,Plan__r.OwnerId,Plan__r.Owner.Type, Engagement_Id__c, title__c, Account__c from Engagement__c where Id in:engList]){//<T01> added Plan__r.Owner.Type in SOQL
			String comment ='';

			if(eng.Status__c == 'Accepted'){
				comment = 'Status has been updated on the below request. An Informatica representative will be in touch with you at the earliest possible. <br><br>Success Accelerator : <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a> <br>Engagement Status: '+eng.Status__c;
				if(eng.Plan__c==null){
					if(accUserIdMap.containsKey(eng.Account__c)){
						lstBatchInput.add(getCSAChatterPost(eng,false,accUserIdMap.get(eng.Account__c),null));//<T01> added null for engCsmMap parameter
					}else{
						lstBatchInput.add(getCSAChatterPost(eng,false,null,null));//<T01> added null for engCsmMap parameter
					}
				}else {
					lstBatchInput.add(getCSAChatterPost(eng,false,null,engCsmMap));//<T01> engCsmMap
				}
				
			}else if(eng.Status__c == 'Completed'){
				comment = 'Please note that the below request has been closed.<br><br>Success Accelerator: <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a> '+
							'<br>Closing Notes: '+eng.Closing_Notes__c+'<br><br>We greatly value your feedback and would like to invite you to participate in a brief survey to share your experience with our customer success team. Your feedback is essential in helping us improve our services and ensure we meet your expectations. The survey will be sent to you shortly, and we would greatly appreciate it if you could take a few moments to provide your valuable insights.';
				lstBatchInput.add(getCSAChatterPost(eng,false,null,engCsmMap));//<T01> engCsmMap
			}else if(eng.Status__c == 'Close without Engagement'){
				comment = 'Please note that the below request has been closed.<br><br>Success Accelerator: <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a> ';
				if(eng.Closing_Notes__c!=null){//adding this condition to avoid sending close notes null - happens during rejection of approval
					comment += '<br>Closing Notes: '+eng.Closing_Notes__c;
				}
				comment +='<br><br>If you have any further queries, contact your Customer Success Manager.';
				lstBatchInput.add(getCSAChatterPost(eng,false,null,engCsmMap));//<T01> engCsmMap
			}else if(eng.Status__c == 'In Progress'){
				comment = 'Status has been updated on the below request. An Informatica representative will be in touch with you at the earliest possible. <br><br>Success Accelerator : <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a> <br>Engagement Status: '+eng.Status__c;
				lstBatchInput.add(getCSAChatterPost(eng,false,null,engCsmMap));//<T01> engCsmMap
			}else if(eng.Status__c == 'OnHold'){
				comment = 'Status has been updated on the below request.<br><br>Success Accelerator : <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a> <br>Engagement Status: '+eng.Status__c;
				lstBatchInput.add(getCSAChatterPost(eng,false,null,engCsmMap));//<T01> engCsmMap
			}
			

			Plan_Comment__c pComments = new Plan_Comment__c();
			pComments.Type__c = CSMUtilities.TYPE_EXTERNAL;
			pComments.Status__c = 'Submitted';
			pComments.Sub_Type__c = 'Engagement';
			pComments.Is_Automated__c = true;
			pComments.Plan__c = eng.Plan__c;
			pComments.Visibility__c = 'External';
			pComments.Comment__c = comment;
			if(comment!=''){//adding this condition to avoid sending a blank comment to external when status moved back to Submit for approval.
				commentList.add(pComments);
			}
		}
		insert commentList;
		
		if(!lstBatchInput.isEmpty()){
			if(!Test.isRunningTest()){
				ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
			}
		}
	}

	@future
	public static void createCommentonCSACreate(Set<Id> setEngagement){
		Map<Id,List<Id>> contentMap = new Map<Id,List<Id>>();
		List<Plan_Comment__c> commentList= new List<Plan_Comment__c>();	

		for(ContentDocumentLink cd : [SELECT ContentDocumentId, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId IN :setEngagement]){
			if(contentMap.containsKey(cd.LinkedEntityId)){
				contentMap.get(cd.LinkedEntityId).add(cd.ContentDocumentId);
			}
			else{
				contentMap.put(cd.LinkedEntityId, new List<Id>{cd.ContentDocumentId});
			}
		}
		List<Engagement__c> engList =[Select Id,Name,RecordTypeId,Status__c,Plan__c, Account__c, OwnerId,Engagement_Id__c,Title__c,Primary_Contact__c,AEM_EC_Id__c,Requested_By_Group__c,Engagement_Units__c,CSM_Summary__c, Milestone__r.Name,Catalog_URL__c from Engagement__c where Id in:setEngagement];
		for(Engagement__c eng : engList){
			String comment = 'Your request has been created with the following details: <br>Success Accelerator Requested : <a href='+eng.Catalog_URL__c+'>'+eng.Title__c+'</a><br>Additional Details : '+eng.CSM_Summary__c+'<br>';
			if(eng.Milestone__r?.Name<>null){
				comment+='Related Milestone : '+eng.Milestone__r?.Name;
			}
			Plan_Comment__c pComments = new Plan_Comment__c();
			pComments.Type__c = CSMUtilities.TYPE_EXTERNAL;
			pComments.Status__c = 'Submitted';
			pComments.Sub_Type__c = 'Engagement';
			pComments.Is_Automated__c = true;
			pComments.Plan__c = eng.Plan__c;
			pComments.Visibility__c = 'External';
			pComments.Comment__c = comment;
			commentList.add(pComments);
		}

		Integer index=0;
		List<ContentDocumentLink> listCDinsert = new List<ContentDocumentLink>();
		for (Database.SaveResult sr :  Database.insert(commentList,true)) {
			if(contentMap.containsKey(engList[index]?.Id)){
				for(Id contentId : contentMap.get(engList[index]?.Id)){
					listCDinsert.add(new ContentDocumentLink(LinkedEntityId = sr.getId(), ContentDocumentId = contentId));
				}
			}
			
		}
		if(!listCDinsert.isEmpty()){
			insert listCDinsert;
		}
	}

	public static void chatterOnCreate(Set<Id> engSet){
		List<Plan_Comment__c> commentList= new List<Plan_Comment__c>();		
		List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
        List<Engagement__c> engList = [SELECT Id, Account__c, Plan__c, Plan__r.OwnerId,Plan__r.Owner.Type, Engagement_Id__c, title__c, Status__c,OwnerId FROM Engagement__c where Id IN : engSet];//<T01> added Plan__r.Owner.Type in SOQL
		Map<Id,ID> accCSMMap = new Map<Id,Id>();
        List<Engagement__Share> engShare = new List<Engagement__Share>();
		Set<Id> planIdSet = new Set<Id>();//<T01>
        
		for(Engagement__c eng : engList){
			accCSMMap.put(eng.Account__c,null);
			if(eng.Plan__c!=null){//<T01> start
				planIdSet.add(eng.Plan__c);
			}//</T01> end
            engShare.add(new Engagement__Share(ParentID=eng.Id, UserOrGroupId = UserInfo.getUserId(), RowCause ='Manual', AccessLevel = 'Edit'));
		}
        if(!Test.isRunningTest()){
         	insert engShare;
        }
		for(AccountTeamMember atm:[SELECT UserId,AccountId from AccountTeamMember where teamMemberRole='CSM' AND AccountId IN :accCSMMap.keyset() ORDER BY CreatedDate desc]){
			if(accCSMMap.get(atm.AccountId) == null){
				accCSMMap.put(atm.AccountId,atm.UserId);
			}
		}
		Map<Id,Id> engCsmMap = new Map<Id,Id>();//<T01> start
		for(Plan_Team__c plTeamMembers : [SELECT Id, User__c, Plan__c, Role__c FROM Plan_Team__c WHERE Plan__c IN:planIdSet AND Primary__c = true AND Role__c ='CSM' ORDER BY LastModifiedDate DESC]){
			if(engCsmMap.containsKey(plTeamMembers.Plan__c) == false){
				engCsmMap.put(plTeamMembers.Plan__c,plTeamMembers.User__c);
			}
		}//</T01> end
		for(Engagement__c eng : engList){
			if(eng.Plan__c <> null){
				lstBatchInput.add(getCSAChatterPost(eng,true,null,engCsmMap));//<T01> engCsmMap
			}
			else{
				lstBatchInput.add(getCSAChatterPost(eng,true,accCSMMap.get(eng.Account__c),null));//<T01> added null for engCsmMap parameter
			}
		}
		if(!lstBatchInput.isEmpty()){
			if(!Test.isRunningTest()){
				ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
			}
		}
        if(!Test.isRunningTest()){
        	delete engShare;
        }
	}

	/*
	 Method Name : 	getCSAChatterPost
	 Description :	helper method to get the chatter post text with the tagged persons
	 Parameters	 :  Engagement__c eng, Boolean isInsert, Id CSMId
	 				Map<Id,Id> engCsmMap-eng plan and csm Id map
	 Return Type : 	n/a
	 */
	public static ConnectApi.BatchInput getCSAChatterPost(Engagement__c eng, boolean isInsert,Id CSMId,Map<Id,Id> engCsmMap){//<T01> added new parameter engCsmMap
        
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			if(!isInsert){
				messageBodyInput.messageSegments.add(ChatterService.inputMention(eng.OwnerID));
				messageBodyInput.messageSegments.add(ChatterService.inputSpace());
			}
			
			if(eng.Plan__r?.OwnerId!=null && eng.Plan__r?.Owner?.Type == 'User'){//<T01> added new condition to check plan owner user type
				messageBodyInput.messageSegments.add(ChatterService.inputMention(eng.Plan__r.OwnerId));
			}
			else if(eng.Plan__r?.OwnerId!=null && (eng.Plan__r?.Owner?.Type == 'Group' || eng.Plan__r?.Owner?.Type == 'Queue') && engCsmMap?.containsKey(eng.Plan__c)){//<T01> start
				messageBodyInput.messageSegments.add(ChatterService.inputMention(engCsmMap.get(eng.Plan__c)));
			}//</T01> end
			else if(CSMId!=null){
				messageBodyInput.messageSegments.add(ChatterService.inputMention(CSMId));
			}
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
			String msg='';
			if(!isInsert){
				msg = 'There has been an update on your Engagement Request, Engagement Status : '+eng.Status__c;
			}
			else{
				msg = 'Customer Request has been requested from Engagement Catalog '+eng.Engagement_Id__c +' : '+eng.title__c;
				
			}
			messageBodyInput.messageSegments.add(ChatterService.inputText(msg));



			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			feedItemInput.subjectId = eng.Id;
			feedItemInput.body = messageBodyInput;
			feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
			
			return new ConnectApi.BatchInput(feedItemInput);

	}

    @future(callout=true)
	public static void invokeAEMFavourite(List<Id> engIdList){
		Map<Id,String> contactOktaMap = new Map<Id,String>();
		List<Engagement__c> engList = new List<Engagement__c>();
		for(Engagement__c eng : [SELECT Id,Primary_Contact__c,AEM_EC_Id__c from Engagement__c where id IN : engIdList]){
			engList.add(eng);
			contactOktaMap.put(eng.Primary_Contact__c,null);
		}
		for(User usr:[SELECT Id, FederationIdentifier,ContactId from User where ContactId IN :contactOktaMap.keyset()]){
			contactOktaMap.put(usr.ContactId,usr.FederationIdentifier);
		}
		for(Engagement__c eng: engList){
			HttpRequest req = new HttpRequest();
			req.setEndpoint('callout:AEM_Catalog_Favourite?engagementId='+eng.AEM_EC_Id__c+'&favoriteType=add&oktaUserId='+contactOktaMap.get(eng.Primary_Contact__c));
			req.setMethod('POST');
			Http http = new Http();
            if(!Test.isRunningTest()){
			HTTPResponse res = http.send(req);
            }
		}
	}
}