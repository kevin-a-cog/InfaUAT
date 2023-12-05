/*
    @created by       : balajip
    @created on       : 01/19/2021
    @Purpose          : RaiseHand trigger handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ************************************************************************************************************
    ModifiedBy         Date        Jira No.      Tag      Description
    Isha Bansal        27/11/2023  I2RT-9464     T01      Added new method -setAcceptorRoleBasedOnType
 ************************************************************************************************************
 */

public class RaiseHandTriggerHandler {

    public void routeToOmni(Map<Id, Raise_Hand__c> newMap) {
        //I2RT-4537
        Integer omniPushTimout = 60;
        String omniPushTimoutLabelValue = System.Label.GCS_Collaboration_Omni_Request_Timout;
        if(omniPushTimoutLabelValue.isNumeric()){
            omniPushTimout = Integer.valueOf(System.Label.GCS_Collaboration_Omni_Request_Timout);
        }

        Map<Id, PendingServiceRouting> mapRaiseHandIdToPSR = new Map<Id, PendingServiceRouting>(); 
        List<PendingServiceRouting> lstPendingServRouting = new List<PendingServiceRouting>();

        for (Raise_Hand__c raiseHand : newMap.values()) {

            System.debug('Type = ' + raiseHand.Type__c);
            System.debug('case = ' + raiseHand.Case__c);
            System.debug('new owner = ' + raiseHand.OwnerId);
            System.debug('skill = ' + raiseHand.Skill__c);
            System.debug('product = ' + raiseHand.Product__c);

            //create pendingservicerouting record
            PendingServiceRouting pendingServRouting = new PendingServiceRouting();
            pendingServRouting.CapacityWeight = 1;
            pendingServRouting.RoutingType = 'SkillsBased';
            pendingServRouting.RoutingModel = 'MostAvailable';
            pendingServRouting.RoutingPriority = 1;
            pendingServRouting.IsReadyForRouting = false;
            pendingServRouting.PushTimeout = omniPushTimout; //I2RT-4537

            pendingServRouting.ServiceChannelId = SkillService.getServiceChannelId('Raise_Hand');//'0N9g0000000CaouCAC';
            pendingServRouting.WorkItemId = raiseHand.Id;
            //pendingServRouting.GroupId = raiseHand.OwnerId;
            
            lstPendingServRouting.add(pendingServRouting);

            mapRaiseHandIdToPSR.put(raiseHand.Id, pendingServRouting);
        }

        if(!lstPendingServRouting.isEmpty()){
            insert lstPendingServRouting;

            List<Skill> lstSkill = [Select Id, DeveloperName From Skill];
            Map<String, Id> mapSkillNameToId = new Map<String, Id>();
            for(Skill skl : lstSkill){
                mapSkillNameToId.put(skl.DeveloperName, skl.Id);
            }

            List<SkillRequirement> lstSkillReq = new List<SkillRequirement>();
            for (Raise_Hand__c raiseHand : newMap.values()) {
                PendingServiceRouting pendingServRouting = mapRaiseHandIdToPSR.get(raiseHand.Id);
                pendingServRouting.IsReadyForRouting = true;

                ProfileSkill profileSkill;

                try{
                    profileSkill = SkillService.getSkillByName(raiseHand.Skill__c);

                    SkillRequirement skillReq = new SkillRequirement();
                    skillReq.RelatedRecordId = pendingServRouting.Id;
                    skillReq.SkillId = mapSkillNameToId.get(profileSkill.Omni_Skill_Name__c);
                    skillReq.SkillLevel = 0;
                    //skillReq.SkillPriority = 0;
                    lstSkillReq.add(skillReq);
                }catch(Exception ex){
                    System.debug('exception in routeToOmni - ' + ex.getMessage());
                }
            }

            if(!lstSkillReq.isEmpty()){
                insert lstSkillReq;
                System.debug('lstSkillReq = ' + lstSkillReq);
                update lstPendingServRouting;    
            }

        }
    }

    //I2RT-4325
    public void onOwnerChange(Map<Id, Raise_Hand__c> newMap, Map<Id, Raise_Hand__c> oldMap) {
        Set<Id> setRaiseHandId = new Set<Id>();

        for (Raise_Hand__c raiseHand : newMap.values()) {
            Raise_Hand__c raiseHandOld = oldMap.get(raiseHand.Id);

            System.debug('Type = ' + raiseHand.Type__c);
            System.debug('case = ' + raiseHand.Case__c);
            System.debug('new owner = ' + raiseHand.OwnerId);
            System.debug('old owner = ' + raiseHandOld.OwnerId);

            if(RaiseHandService.STATUS_OPEN.equals(raiseHand.Status__c) && raiseHand.OwnerId != raiseHandOld.OwnerId){
                if (User.SobjectType == raiseHand.OwnerId.getSobjectType()) {
                    setRaiseHandId.add(raiseHand.Id);
                }
            }
        }
        if(!setRaiseHandId.isEmpty()){
            RaiseHandService.onAssignment(setRaiseHandId);
        }
    }

    public void onClose(Map<Id, Raise_Hand__c> newMap, Map<Id, Raise_Hand__c> oldMap) {
        Set<Id> setFeeditemId = new Set<Id>();

        for (Raise_Hand__c raiseHand : newMap.values()) {
            Raise_Hand__c raiseHandOld = oldMap.get(raiseHand.Id);

            System.debug('Type = ' + raiseHand.Type__c);
            System.debug('case = ' + raiseHand.Case__c);
            System.debug('new owner = ' + raiseHand.OwnerId);
            System.debug('old owner = ' + raiseHandOld.OwnerId);

            if(RaiseHandService.TYPE_GET_HELP.equals(raiseHand.Type__c) && !raiseHand.Is_Converted__c){
                if(RaiseHandService.STATUS_CLOSED.equals(raiseHand.Status__c) && raiseHand.Status__c != raiseHandOld.Status__c){
                    if(trigger.isBefore){
                        raiseHand.Closed_On__c = System.now();
                    }else if(trigger.isAfter){
                        setFeeditemId.add(raiseHand.Feed_Item_Id__c);
                        String chatterGroupName = SkillService.getSkillByName(raiseHand.Skill__c).Chatter_Group_Name__c;
                        Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get(chatterGroupName).Id;
                        
                        String remarks = 'Best Answer is selected and the Question is closed for further discussion!';
                        try{
                            RaiseHandService.chatterPostQuestion(raiseHand.Feed_Item_Id__c, raiseHand.Case__c, raiseHand.Id, chatterGroupId, null, null, 'Get Help Request (Closed):', raiseHand.Question__c, remarks);
                        }catch(Exception ex){
                            System.debug('error updating the chatter question, ' + ex.getMessage());
                        }
                    }
                }
            }
        }

        notifyBestAnswer(setFeeditemId);
    }

    public void notify(List<Raise_Hand__c> newList, Map<Id, Raise_Hand__c> oldMap){
        /*for (Raise_Hand__c raiseHand : newList){
            Raise_Hand__c raiseHandOld;
            if(oldMap != null){
                raiseHandOld = oldMap.get(raiseHand.Id);
            }
            NotificationService.notify(NotificationService.NotificationEvent.RAISE_HAND_NEW, raiseHand, raiseHandOld);
        }*/
        NotificationService.notify(newList, oldMap);
    }

    private void notifyBestAnswer(Set<Id> setFeeditemId){
        List<CustomNotificationType> lstNotifType = [Select Id, DeveloperName From CustomNotificationType
                                                        Where DeveloperName = 'Notification_Service_Desktop_Mobile'];

        List<FeedItem> lstFeedItem = new List<FeedItem>();
        if(!setFeeditemId.isEmpty()){
            lstFeedItem = [Select Id, BestCommentId, BestComment.InsertedById 
                                            From FeedItem 
                                            Where Id in :setFeeditemId And BestCommentId != null];
        }
        
        for(FeedItem feedItem : lstFeedItem){
            String title = 'Best Answer';
            String bodyText = 'Your answer is selected as Best Answer!';

            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setNotificationTypeId(lstNotifType.get(0).Id);
            notification.setTargetId(feedItem.Id);
            //notification.setSenderId(senderId);
            notification.setTitle(title);
            notification.setBody(bodyText);
    
            try {
                notification.send(new Set<String>{feedItem.BestComment.InsertedById});
            } catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }    
        }
    }

/* Method Name : setAcceptorRoleBasedOnType
	 Description : This method sets the Role field on  collab based on the type field . Invoked from trigger
	 Parameters	 : List of new/updated Raise Hands.	 			   
	 Return Type : void
 */
    public void setAcceptorRoleBasedOnType(List<Raise_Hand__c> newList){//T01
        for(Raise_Hand__c raiseHand : newList ){
            if(raiseHand.Type__c!=null && RaiseHandService.TYPE_CO_OWN.equals(raiseHand.Type__c)  ){
                raiseHand.AcceptorRole__c=CaseTeamService.TEAM_ROLE_CO_OWNER; 
            }else if(RaiseHandService.TYPE_REPRO_ENV_SETUP.equals(raiseHand.Type__c) || RaiseHandService.TYPE_CUSTOMER_MEETING.equals(raiseHand.Type__c) ){
                raiseHand.AcceptorRole__c=CaseTeamService.TEAM_ROLE_COLLABORATOR;   
            }else if(RaiseHandService.TYPE_MANAGE_ESCALATION.equals(raiseHand.Type__c)){
                raiseHand.AcceptorRole__c=CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER;   
            }
        }
    }
}