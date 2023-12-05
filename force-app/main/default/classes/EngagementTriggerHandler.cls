/*********************************************************************************************************************************************
*  @Class Name: EngagementTriggerHandler
*  @Author: Deloitte
*  @Date: 2018-01-03 
*  @Description:This is a handler class which holds all the controller logics implemented for Engagement Object.
*********************************************************************************************************************************************
ChangeHistory      
Sandeep Duggi             3/21/2022           I2RT-5632                   Tag T02     
Venky K                   4/12/2022           AR-2590                     Tag T03     
Narpavi Prabu             9/8/2022 			  AR-2838					  Tag T04
balajip        			  1/17/2023           I2RT-7643    				  Tag T05 
balajip					  1/30/2023			  I2RT-7695					  Tah T06	updateCaseTeam - to account for moving GEMS from a User to a Queue
*********************************************************************************************************************************************/
public class EngagementTriggerHandler
{
    
	static Id GEMEngSRecTypeID = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId(); 
    static Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    static Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
    
	/**
    * this method is invoked from before insert event of Engagement
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementBeforeInsert(List<Engagement__c> newEngagementList)
    {
        engagementAccountPopulator(newEngagementList);
        populateDevActiveEngagedStartTime(newEngagementList,false,null);
		checkIfRussiaOrBelarus(newEngagementList);
        CsmEngagementTriggerHelper.engagementBeforeInsert(newEngagementList);
    }

	/**
    * this method is invoked from before update event of Engagement
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementBeforeUpdate(List<Engagement__c> newEngagementList, map<id,Engagement__c> oldMap){
		populateDevActiveEngagedStartTime(newEngagementList,true,oldMap);
        supportEscalation(newEngagementList, oldMap);
        CsmEngagementTriggerHelper.engagementBeforeUpdate(newEngagementList, oldMap);
    }

	
	
	/**
    * this method is invoked from after insert event of Engagement
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementAfterInsert(List<Engagement__c> newEngagementList){
        apexSharingAfterInsert(newEngagementList);
		CsmEngagementTriggerHelper.engagementAfterInsert(newEngagementList);
        NotificationService.notify(newEngagementList, null); 
		postChatterComment(newEngagementList, null);
		ProductRequestFlowController.sendEmailsEngg(newEngagementList,null);
		ProductRequestFlowController.updateEnagagementCompliance(newEngagementList);
	}
	
	/**
    * this method is invoked from after update event of Engagement
    *
    * @param newEngagementList - list of new Engagement
	* @param oldEngagementMap - Map of old Engagement record
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementAfterUpdate(List<Engagement__c> newEngagementList,Map<Id,Engagement__c> oldEngMap)
    {
        NotificationService.notify(newEngagementList, oldEngMap); //T03
        apexSharingAfterUpdate(newEngagementList,oldEngMap);
		CsmEngagementTriggerHelper.engagementAfterUpdate(newEngagementList, oldEngMap);
        //notify(newEngagementList, oldEngMap);  
		postChatterComment(newEngagementList, oldEngMap);
		validateengrecord(newEngagementList, oldEngMap); //T04
		updateCaseTeam(newEngagementList, oldEngMap); //T05
		ProductRequestFlowController.sendEmailsEngg(newEngagementList,oldEngMap);
		ProductRequestFlowController.productRequestUpdates(newEngagementList, oldEngMap);
    }
    
	//T05 update the Escalation Manager in the associated Case Teams when the Owner has changed or the Engagement is closed.
	public static void updateCaseTeam(List<Engagement__c> newEngagementList, Map<Id,Engagement__c> oldEngMap){
		List<String> lstClosedStatus = new List<String>{'Closed', 'Closed Duplicate'};
		
		Map<Id, Id> mapEngIdToOwnerIdToAdd = new Map<Id, Id>();
		Set<Id> setEngIdToRemove = new Set<Id>();
		for(Engagement__c eng : newEngagementList){
			Engagement__c engOld = oldEngMap.get(eng.Id);
			if(eng.RecordTypeId == GEMEngSRecTypeID){
				//if owner changed, add the owner to Case Team
				if(engOld.OwnerId != eng.OwnerId){
					if(eng.OwnerID.getSObjectType() == User.SObjectType){
						mapEngIdToOwnerIdToAdd.put(eng.Id, eng.OwnerId);
					//T06 if owner changed to queue, then remove the user from the Case team
					}else if(engOld.OwnerID.getSObjectType() == User.SObjectType){
						setEngIdToRemove.add(eng.Id);
					}
				}

				//if closed, remove the owner from Case Team
				if(lstClosedStatus.contains(eng.Status__c) && engOld.Status__c != eng.Status__c){
					setEngIdToRemove.add(eng.Id);
				}
			}
		}
		
		CaseTeamService.updateEscalationManager(mapEngIdToOwnerIdToAdd, setEngIdToRemove, new Set<Id>());
	}

    public static void notify(List<Engagement__c> newEngList,Map<Id,Engagement__c> oldEngMap){
        /*for (Engagement__c engagement : newEngList){
            Engagement__c engagementOld;
            if(oldEngMap != null){
                engagementOld = oldEngMap.get(engagement.Id);
            }
            NotificationService.notify(NotificationService.NotificationEvent.ENGAGEMENT_NEW, engagement, engagementOld);
        }*/
		List<Engagement__c> lstNewEng = new List<Engagement__c>();
		for(Engagement__c engagement : newEngList){
			if(engagement.RecordTypeId == GEMEngSRecTypeID){
				lstNewEng.add(engagement);
			}
		}
		if(lstNewEng.size() > 0){
			NotificationService.notify(lstNewEng, oldEngMap);
		}
    }
	
	/**
    * this method is invoked from after delete event of Engagement
    *
    * @param newEngagementList - list of new Engagement
	* @param oldEngagementMap - Map of old Engagement record
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementAfterDelete(Map<Id,Engagement__c> oldEngMap){	
		CsmEngagementTriggerHelper.engagementAfterDelete(oldEngMap);
    }
	

	
	/**
    * Method to populate account field from logged in user if not populated
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
    public static void engagementAccountPopulator(List<Engagement__c> newEngagementList){
        Id userId = UserInfo.getUserId();
        Id AccId;
        //  T02 Store the parent account field and store them in the map 
	    set<id> supportAccId = new set<id>();
		for(Engagement__c eng : newEngagementList){
			supportAccId.add(eng.Support_Account__c);
		}
		Map<id,Account> maplookupObject =  new Map<id,Account>([select Id,parentId  from Account WHERE Id in : supportAccId]);
		//Iterate Over the User to get the AccountId
        If(userId != null)
        {
            for(User u : [select Id,Contact.AccountId,Contact.Id from User where Id = :userId])
            {      
                AccId = u.Contact.AccountId;           
				      
            }
        }
		
		//Pre-populate the Partner Account for the Engagement
		// T02 This logic should be updated to ignore for Engagements where record type is Support Escalation and Account__c is populated
        for(Engagement__c eng : newEngagementList)
        {
           
			If(AccId != null && eng.RecordTypeId != GEMEngSRecTypeID ){
            eng.Account__c = AccId;
        } 
			If(AccId != null && eng.RecordTypeId == GEMEngSRecTypeID){
				// query parent account field from the support account and populate it on the Account__c
				eng.Account__c = maplookupObject.get(eng.Support_Account__c).parentId;
				
			}
    }
    }
   
   /**
    * Method to update Dev_Active_Engaged_Start_Time__c based on status
    *
    * @param newEngagementList - list of new Engagement
    * @return return-void
    * @throws exception - NA
    */
	public static void populateDevActiveEngagedStartTime(List<Engagement__c> newEngagementList,boolean isUpdate, map<id,Engagement__c> oldMap){
		for(Engagement__c eng : newEngagementList){
          if( (eng.Status__c == 'Active Engaged' && isUpdate == false ) ||  (isUpdate &&  oldMap.get(eng.id).Status__c != eng.Status__c && eng.Status__c == 'Active Engaged') ){
			eng.Dev_Active_Engaged_Start_Time__c = system.now();
		  }		
        } 
	}
    
	/**
    * Method to implement managed sharing of the Engagement record for all partner users of the account
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
	public static void apexSharingAfterInsert(List<Engagement__c> newEngmntList)
	{
		String AccType; 
        Id userId = UserInfo.getUserId();
		List<User> userList;
		//Map of Engmnt Id and Acc Id
		Map<Id,Id> engmntAccMap = new Map<Id,Id>();
		//Map of Account id and list of users
		map<id, List<User>> accIdWiseUserMap = new Map<id,List<User>>();
		//Map of Engmnt id and list of users
		map<id, List<User>> EngmntIdWiseUserMap = new Map<id,List<User>>();
		
		for(Engagement__c eng:newEngmntList)
		{
			if(null != eng.Account__c)
			{
				engmntAccMap.put(eng.Id,eng.Account__c);
			}
		}
		
		if(!engmntAccMap.isEmpty())
		{
			//Fetch all active users for the accounts
			for(User u : [select id, contact.accountid from user where contact.accountid IN :engmntAccMap.values() and contact.Is_Active__c = TRUE and IsActive  = True]){
				  //Ignore current user
				  if(userId != u.id)
				  {
					//populate accIdWiseUserMap
					if(null == accIdWiseUserMap.get(u.contact.accountid))
					  {
						userList = new List<User>();
						userList.add(u);
						accIdWiseUserMap.put(u.contact.accountid,userList);
					  }
					  else
					  {
						userList = accIdWiseUserMap.get(u.contact.accountid);
						userList.add(u);
						accIdWiseUserMap.put(u.contact.accountid,userList);
					  }
				  }
			}
			
			//Populate EngmntIdWiseUserMap with Engmnt Ids against the list of users
			for(Engagement__c eng:newEngmntList)
			{
				if(null != engmntAccMap.get(eng.id) && null != accIdWiseUserMap.get(engmntAccMap.get(eng.id)))
				{
					EngmntIdWiseUserMap.put(eng.Id,accIdWiseUserMap.get(engmntAccMap.get(eng.id)));
				}
			}
			if(!EngmntIdWiseUserMap.isEmpty())
			{
				ApexSharingUtility.enablesharingForPartnerUsers(EngmntIdWiseUserMap, label.PRM_Engagement_Share, 'Edit');
			}
		}
	}
	
	/**
    * Method to implement managed sharing of the Engagement record for all partner users of the account on after update
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void apexSharingAfterUpdate(List<Engagement__c> newEngList,Map<Id,Engagement__c> oldEngMap)
	{
		String AccType; 
        Id userId = UserInfo.getUserId();
		List<User> userList;
		//Map of Eng Id and Acc Id to activate
		Map<Id,Id> engWiseAccMapNew = new Map<Id,Id>();
		//Map of Eng Id and Acc Id to de-activate
		Map<Id,Id> engWiseAccMapOld = new Map<Id,Id>();
		//Map of Account id and list of users
		map<id, List<User>> accIdWiseUserMap = new Map<id,List<User>>();
		//Map of Eng id and list of users
		map<id, List<User>> engIdWiseUserMap = new Map<id,List<User>>();
        
		//Fetch logged in user Account Type
        for(User u : [select Id,Contact.Account.Partner_Type__c from User where Id = :userId])
        {
            AccType = (String)u.Contact.Account.Partner_Type__c;
        }
		
		//Fetch current partner account of the Engagement
		for(Engagement__c eng : newEngList){
			if(eng.Account__c != oldEngMap.get(eng.Id).Account__c){
				if(null != eng.Account__c)
				{
					engWiseAccMapNew.put(eng.Id,eng.Account__c);
				}
				if(null != oldEngMap.get(eng.Id).Account__c)
				{
					engWiseAccMapOld.put(eng.Id,oldEngMap.get(eng.Id).Account__c);
				}
			}
		}
		//enable sharing for new account
		if(!engWiseAccMapNew.isEmpty())
		{
			//Fetch all active users for the accounts
			for(User u : [select id, contact.accountid from user where contact.accountid IN : engWiseAccMapNew.values() and contact.Is_Active__c = TRUE and IsActive  = True]){
				//Ignore current user
				if(userId != u.id)
				{
					//populate accIdWiseUserMap
					if(null == accIdWiseUserMap.get(u.contact.accountid))
					  {
						userList = new List<User>();
						userList.add(u);
						accIdWiseUserMap.put(u.contact.accountid,userList);
					  }
					  else
					  {
						userList = accIdWiseUserMap.get(u.contact.accountid);
						userList.add(u);
						accIdWiseUserMap.put(u.contact.accountid,userList);
					  }
				}
			}
			
			//Populate engIdWiseUserMap with Engagement Ids against the list of users
			for(Engagement__c eng:newEngList)
			{
				if(null != engWiseAccMapNew.get(eng.id) && null != accIdWiseUserMap.get(engWiseAccMapNew.get(eng.id)))
				{
					engIdWiseUserMap.put(eng.Id,accIdWiseUserMap.get(engWiseAccMapNew.get(eng.id)));
				}
			}
			if(!engIdWiseUserMap.isEmpty())
			{
				ApexSharingUtility.enablesharingForPartnerUsers(engIdWiseUserMap, label.PRM_Engagement_Share, 'Edit');
			}
			
		}
		
		//disable sharing for old account
		if(!engWiseAccMapOld.isEmpty())
		{
			ApexSharingUtility.disablesharingForPartnerUsers(engWiseAccMapOld, label.PRM_Engagement_Share);
		}
	}
    
         
	/**
    * Method to set GCS Escalation analysis date
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void supportEscalation(List<Engagement__c> newEngList,Map<Id,Engagement__c> oldEngMap)
	{
        String objectName = 'Engagement__c';
        String strRecordTypeName = 'Support_Escalation';
		List<String> lstClosedStatus = new List<String>{'Closed', 'Closed Duplicate'}; //I2RT-4422
        
        Id recid =  Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
        for(Engagement__c eng : newEngList){            
			if(eng.recordtypeid == recid) {
                if(eng.Status__c == 'Analysis' && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    eng.Analysis_Date__c = date.today();
                }
                
				//I2RT-4422
                if(lstClosedStatus.contains(eng.Status__c) && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    eng.Closed_On__c = system.now();
                }

				if(eng.Status__c == 'Active Wait' && oldEngMap.get(eng.Id).Status__c != eng.Status__c){
                    Boolean validchange = false;
                    for(Task t : [Select Id from Task where WhatId = :eng.Id and Status = 'Open' LIMIT 1]){
                        validchange = true;
					}
                    if(!validchange){
                        eng.addError('Atleast one open Task should be created before moving to Active Wait');
                    }
                }
                
            }
        
        }
    }
    
    /**
    * Method to check either the country of account / contact is russia or belarus <SALESRT-13721> start
    * @param triggernew - 
    * @return return-void
    * @throws exception - NA
    */ 
    public static void checkIfRussiaOrBelarus(List<Engagement__c> newEngList){
		Id loggedInUserId = UserInfo.getUserId();
		String countryLabel = Label.SanctionCountries;
		List<String> countryList = new List<String>();
		for(String str : countryLabel.split(',')){
			countryList.add(str.toLowerCase());
		}
		Boolean checkPortal = false;
		Boolean updatePartner = false;
		Set<Id> accountIds = new Set<Id>();
		Id productRequestRecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('PRM_Engagement').getRecordTypeId();


		List<Engagement__c> engToProcess = new List<Engagement__c>();
		for(Engagement__c eng : newEngList){	
			if(eng.RecordTypeId == productRequestRecordTypeId){
				engToProcess.add(eng);
				if(eng.Account__c != null){
					accountIds.add(eng.Account__c);
				}
			}
		}

		Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,ShippingCountry,BillingCountry FROM Account WHERE Id IN :accountIds]);
		if(loggedInUserId != null){
			User u = [SELECT Id,ContactId,Contact.MailingCountry,Contact.OtherCountry,Contact.AccountId,Contact.Account.BillingCountry,Contact.Account.ShippingCountry,IsPortalEnabled 
							FROM User 
							WHERE Id = :loggedInUserId LIMIT 1];
			if(u != null && u.IsPortalEnabled){
				checkPortal = true;
			}
			if(u != null && checkPortal && u.ContactId != null && (((u.Contact.MailingCountry != null && countryList.contains(u.Contact.MailingCountry.toLowerCase())) || (u.Contact.OtherCountry != null && countryList.contains(u.Contact.OtherCountry.toLowerCase()))) || (u.Contact.AccountId != null && 
			((u.Contact.Account.BillingCountry != null && countryList.contains(u.Contact.Account.BillingCountry.toLowerCase())) || (u.Contact.Account.ShippingCountry != null && countryList.contains(u.Contact.Account.ShippingCountry.toLowerCase())))))){
				updatePartner = true;
			}
		} 
		for(Engagement__c eng : newEngList){
			if(eng.RecordTypeId == productRequestRecordTypeId){
				if(checkPortal){
					eng.Partner_in_Russia_or_Belarus__c = updatePartner;
				}
				else if(accountMap != null && eng.Account__c != null &&  accountMap.containsKey(eng.Account__c) && ((accountMap.get(eng.Account__c).ShippingCountry != null && countryList.contains(accountMap.get(eng.Account__c).ShippingCountry.toLowerCase())) || (accountMap.get(eng.Account__c).BillingCountry != null && countryList.contains(accountMap.get(eng.Account__c).BillingCountry.toLowerCase())))){
					eng.Partner_in_Russia_or_Belarus__c = true;
				}
			}	
		}
	}
	// <SALESRT-13721> end   

	/*
	 Method Name : postChatterComment
	 Description : This method creates a Chatter Feed Item for the engagements provided.
	 Parameters	 : List, called from postChatterComment, lstNewRecords New records.
	 			   Map, called from postChatterComment, mapOldRecords Old records.
	 Return Type : None
	 */
	@AuraEnabled
    public static void postChatterComment(List<Engagement__c> lstNewRecords, Map<Id, Engagement__c> mapOldRecords) {
		String strURL = URL.getSalesforceBaseUrl().toExternalForm();
		ConnectApi.FeedItemInput objFeedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MentionSegmentInput objMentionSegmentInput;
		ConnectApi.MessageBodyInput objMessageBodyInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput objTextSegmentInput = new ConnectApi.TextSegmentInput();
		ConnectApi.MarkupBeginSegmentInput objMarkupBeginSegment;
		ConnectApi.MarkupEndSegmentInput objMarkupEndSegment;
		Set<Id> setEngagements = new Set<Id>();
		List<ConnectApi.BatchInput> lstFeedItems = new List<ConnectApi.BatchInput>();

		//If we received data.
		if(lstNewRecords != null && !lstNewRecords.isEmpty()) {

			//Now we collect the engagements whoes plans have changed.
			for(Engagement__c objRecord : lstNewRecords) {
				if(objRecord.Plan__c != null && objRecord.RecordTypeId == GEMEngSRecTypeID && (mapOldRecords == null || objRecord.Plan__c != mapOldRecords.get(objRecord.Id).Plan__c)) {
					setEngagements.add(objRecord.Id);
				}
			}

			//Now we check each record.
			if(!setEngagements.isEmpty()) {
				for(Engagement__c objEngagement : [SELECT Id, Name, OwnerId, Plan__c, Plan__r.Name FROM Engagement__c WHERE Id IN :setEngagements LIMIT 50000]) {
		
					//We prepare the list of segments.
					objMessageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
		
					//We add the text of the item.
					objMarkupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
					objMarkupBeginSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupBeginSegment);
					objTextSegmentInput = new ConnectApi.TextSegmentInput();
					objTextSegmentInput.text = 'Plan: ' + objEngagement.Plan__r.Name + ' ' + strURL + '/' + objEngagement.Plan__c + ' is associated to the Engagement: ' + objEngagement.Name + 
							' ' + strURL + '/' + objEngagement.Id + ' ';
					objMessageBodyInput.messageSegments.add(objTextSegmentInput);
					objMarkupEndSegment = new ConnectApi.MarkupEndSegmentInput();
					objMarkupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
					objMessageBodyInput.messageSegments.add(objMarkupEndSegment);
		
					//We add a mention to the Engagement Owner.
					if(String.valueOf(objEngagement.OwnerId).startsWith('005')) {
						objMentionSegmentInput = new ConnectApi.MentionSegmentInput();
						objMentionSegmentInput.id = objEngagement.OwnerId;
						objMessageBodyInput.messageSegments.add(objMentionSegmentInput);
					} else {
						for(CollaborationGroup objGroup : [SELECT Id FROM CollaborationGroup WHERE Name = 'Escalation - Manager' LIMIT 1]) {
							objMentionSegmentInput = new ConnectApi.MentionSegmentInput();
							objMentionSegmentInput.id = objGroup.Id;
							objMessageBodyInput.messageSegments.add(objMentionSegmentInput);
						}
					}
		
					//Now we prepare the rest of the item.
					objFeedItemInput.body = objMessageBodyInput;
					objFeedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
					objFeedItemInput.subjectId = objEngagement.Id;
		
					//We add it to the list.
					lstFeedItems.add(new ConnectApi.BatchInput(objFeedItemInput));
				}
		
				//If we have feed items, we send them.
				if(!Test.isRunningTest() && !lstFeedItems.isEmpty()) {
					ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstFeedItems);
				}
			}
		}
    }
    
    /*
	 Method Name : validateengrecord
	 Description : This method to check whether the user is not escalation manager and prevent editing from fields in Gems engagment record
	 Parameters	 : List, called from postChatterComment, lstNewRecords New records.
	 			   Map, called from postChatterComment, mapOldRecords Old records.
	 Return Type : None
	 */
	//<T04>
	Public static void validateengrecord(List<Engagement__c> lstNewRecords, Map<Id, Engagement__c> mapOldRecords)
	{
		List<Engagement__c> lsteng=new List<Engagement__c> ();
		Boolean hasCustomPermission = FeatureManagement.checkPermission('CSMUser');

		//Check the user has CSM permission 
		if(hasCustomPermission)
		{
			//Quey to check the current user is in Escalation Manager queue
			List<GroupMember> lstGroupMember = [SELECT Id, GroupId, UserOrGroupId 
                                                FROM GroupMember 
                                                WHERE Group.Type = 'Queue' AND Group.DeveloperName = 'Escalation_Managers' AND UserOrGroupId =: UserInfo.getUserId()];
			for(Engagement__c eng : lstNewRecords)
			{
				//check for gems engagement record type
				if(eng.RecordTypeId == GEMEngSRecTypeID)
				{
					//check if the user is not in the queue and try edit the field validation error is thrown.
					if(lstGroupMember.size() ==0)
					{
							if(eng.Name != mapOldRecords.get(eng.Id).Name || eng.Account__c != mapOldRecords.get(eng.Id).Account__c||
							eng.OwnerId != mapOldRecords.get(eng.Id).OwnerId || eng.Status__c != mapOldRecords.get(eng.Id).Status__c ||
							eng.Engagement_Summary__c != mapOldRecords.get(eng.Id).Engagement_Summary__c ||  eng.Closing_Notes__c != mapOldRecords.get(eng.Id).Closing_Notes__c)
							{
								String errMsg = Label.Gems_Engagement_Error_Message;
								eng.addError(errMsg);
							}
					}
				}
			}
		}
	}
	//</T04>
}