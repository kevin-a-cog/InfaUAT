/*
* Name			:	CSMPlanCommentTriggerHelper
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Helper Class for plan Comment Trigger

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				13/10/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMPlanCommentTriggerHelper {
    public final static String AUTOPILOT_SETTING = 'Remove_Autopilot_From_Cassini';
     /*
    Method Name : processAfterInsert
    Description : This method will trigger for after insert
    Parameters	: List of new Plan comment instance and old map                
    Return Type : n/a
    */  
    public void processAfterInsert(List<Plan_Comment__c> newList){
		NotificationService.notify(newList, null);
		CustomNotificationType objNotificationType;
		Messaging.CustomNotification objBellNotification;
		Set<String> setTaggedUsers;
		List<FeedItem> lstFeedItems = new List<FeedItem>();
		Map<Id, String> mapPlanNames = new Map<Id, String>();
        Plan_Comment_Setting__mdt autopilotSetting = CSMUtilities.getPlanCommentSetting(AUTOPILOT_SETTING);
        Set<Id> planRecordSet = new Set<Id>();    
        List<Plan__c> planList = new List<Plan__c>();    
        for(Plan_Comment__c pc : newList){
            if(pc.plan__c!=null && String.isNotBlank(autopilotSetting.Condition__c) && CSMUtilities.evaluateCondition(pc,autopilotSetting.Condition__c)){
                planRecordSet.add(pc.plan__c);
            }
        }
        if(planRecordSet.size()>0){
            //Query Plan record and iterate over plan to get the selected user queue field
            for(Plan__c planRecord:[SELECT Id, User_Queue_Id__c, CSM_isAutoPilot__c,OwnerId FROM Plan__c WHERE Id =: planRecordSet AND CSM_isAutoPilot__c=true]){
                Id recordOwner = String.isNotBlank(planRecord.User_Queue_Id__c) ? planRecord.User_Queue_Id__c: planRecord.OwnerId;
                //Autopilot = False, Autopilot status = NA. Update Owner based on the value selected prior - OwnerId =    User_Queue_Id__c
                planList.add(new Plan__c(Id=planRecord.Id, CSM_isAutoPilot__c = false, OwnerId=recordOwner,AutoPilot_Status__c='NA'));
            }
            if(planList.size()>0){
                update planList;
            }
        }

		//Now we send the bell notitications, if needed.
		if(newList != null && UserInfo.getUserType() != 'Guest') {

			//First we get the notification type.
			objNotificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Plan_Comment_Tagged_Users' LIMIT 1];

			//Now we collect the plan ids.
			for(Plan_Comment__c objPlanComment : newList) {
				mapPlanNames.put(objPlanComment.Plan__c, '');
			}
			for(Plan__c objPlan : [SELECT Id, Name FROM Plan__c WHERE Id IN :mapPlanNames.keySet() LIMIT 10000]) {
				mapPlanNames.put(objPlan.Id, objPlan.Name);
			}

			//Now we iterate over the records.
			for(Plan_Comment__c objPlanComment : newList) {
				if(objPlanComment.Status__c == 'Submitted' && objPlanComment.Plan__c != null && String.isNotBlank(objPlanComment.Comment__c) && 
						(objPlanComment.Tagged_User_1__c != null || objPlanComment.Tagged_User_2__c != null || objPlanComment.Tagged_User_3__c != null || 
						objPlanComment.Tagged_User_4__c != null || objPlanComment.Tagged_User_5__c != null)) {
					objBellNotification = new Messaging.CustomNotification();
					setTaggedUsers = new Set<String>();

					//We prepare the notification.
					objBellNotification.setTitle(mapPlanNames.get(objPlanComment.Plan__c));
					objBellNotification.setBody(Label.You_Have_Been_Tagged.replace('{!name}', mapPlanNames.get(objPlanComment.Plan__c)));
					objBellNotification.setTargetId(objPlanComment.Plan__c);
					objBellNotification.setNotificationTypeId(objNotificationType.Id);

					//We prepare the Feed Item.
					lstFeedItems.add(generateFeedItem(mapPlanNames.get(objPlanComment.Plan__c), objPlanComment));
					
					//We prepare the reciepents.
					if(objPlanComment.Tagged_User_1__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_1__c);
					}
					if(objPlanComment.Tagged_User_2__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_2__c);
					}
					if(objPlanComment.Tagged_User_3__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_3__c);
					}
					if(objPlanComment.Tagged_User_4__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_4__c);
					}
					if(objPlanComment.Tagged_User_5__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_5__c);
					}
					
					//Now we send the notification.
					if(!setTaggedUsers.isEmpty()) {
						objBellNotification.send(setTaggedUsers);
					}
				}
			}

			//Now we insert the Feed Items, if any.
			if(!lstFeedItems.isEmpty()) {
				insert lstFeedItems;
			}
		}
    }

	/*
	 Method Name : processAfterUpdate
	 Description : Method related to the module to be called in After Update context.
	 Parameters	 : Map, called from processAfterUpdate, mapOldRecords Old records.
	 			   List, called from processAfterUpdate, lstNewRecords New records.
	 Return Type : None
	 */
	public void processAfterUpdate(Map<Id, Plan_Comment__c> mapOldRecords, List<Plan_Comment__c> lstNewRecords) {
		NotificationService.notify(lstNewRecords, mapOldRecords);
		CustomNotificationType objNotificationType;
		Messaging.CustomNotification objBellNotification;
		Set<String> setTaggedUsers;
		List<FeedItem> lstFeedItems = new List<FeedItem>();
		Map<Id, String> mapPlanNames = new Map<Id, String>();
        
		//Now we check if we need to notify to the tagged users about the new record.
		if(lstNewRecords != null) {

			//First we get the notification type.
			objNotificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Plan_Comment_Tagged_Users' LIMIT 1];

			//Now we collect the plan ids.
			for(Plan_Comment__c objPlanComment : lstNewRecords) {
				mapPlanNames.put(objPlanComment.Plan__c, '');
			}
			for(Plan__c objPlan : [SELECT Id, Name FROM Plan__c WHERE Id IN :mapPlanNames.keySet() LIMIT 10000]) {
				mapPlanNames.put(objPlan.Id, objPlan.Name);
			}

			//Now we iterate over the records.
			for(Plan_Comment__c objPlanComment : lstNewRecords) {
				if(objPlanComment.Status__c == 'Submitted'  && objPlanComment.Status__c != mapOldRecords.get(objPlanComment.Id).Status__c && 
						objPlanComment.Plan__c != null && String.isNotBlank(objPlanComment.Comment__c) && 
						(objPlanComment.Tagged_User_1__c != null || objPlanComment.Tagged_User_2__c != null || objPlanComment.Tagged_User_3__c != null || 
						objPlanComment.Tagged_User_4__c != null || objPlanComment.Tagged_User_5__c != null)) {
					objBellNotification = new Messaging.CustomNotification();
					setTaggedUsers = new Set<String>();

					//We prepare the notification.
					objBellNotification.setTitle(mapPlanNames.get(objPlanComment.Plan__c));
					objBellNotification.setBody(Label.You_Have_Been_Tagged.replace('{!name}', mapPlanNames.get(objPlanComment.Plan__c)));
					objBellNotification.setTargetId(objPlanComment.Plan__c);
					objBellNotification.setNotificationTypeId(objNotificationType.Id);

					//We prepare the Feed Item.
					lstFeedItems.add(generateFeedItem(mapPlanNames.get(objPlanComment.Plan__c), objPlanComment));
					
					//We prepare the recipients.
					if(objPlanComment.Tagged_User_1__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_1__c);
					}
					if(objPlanComment.Tagged_User_2__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_2__c);
					}
					if(objPlanComment.Tagged_User_3__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_3__c);
					}
					if(objPlanComment.Tagged_User_4__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_4__c);
					}
					if(objPlanComment.Tagged_User_5__c != null) {
						setTaggedUsers.add(objPlanComment.Tagged_User_5__c);
					}
					
					//Now we send the notification.
					if(!setTaggedUsers.isEmpty()) {
						objBellNotification.send(setTaggedUsers);
					}
				}
			}

			//Now we insert the Feed Items, if any.
			if(!lstFeedItems.isEmpty()) {
				insert lstFeedItems;
			}
		}
    }

	/*
	 Method Name : generateFeedItem
	 Description : Prepares a Feed Item record.
	 Parameters	 : String, called from generateFeedItem, strTitle Feed item title.
	 			   Object, called from generateFeedItem, objPlanComment Plan Comment record.
	 Return Type : Object
	 */
	public FeedItem generateFeedItem(String strTitle, Plan_Comment__c objPlanComment) {
		FeedItem objFeedItem = new FeedItem();
		objFeedItem.Title = objPlanComment.Plan__r.Name;
		objFeedItem.Body = objPlanComment.Comment__c.escapeHtml4();
		objFeedItem.IsRichText = true;
		objFeedItem.ParentId = objPlanComment.Plan__c;
		return objFeedItem;
	}
}