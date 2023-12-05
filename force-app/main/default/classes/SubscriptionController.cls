/*
    @created by       : balajip
    @created on       : 02/11/2020
    @Purpose          : Controller class for Subscription Lightning components
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
public with sharing class SubscriptionController {
    public SubscriptionController() {

    }

    //get the subscription for the given record and user
    @AuraEnabled
    public static Boolean getSubscriptionStatus(Id recordId, Id userId){
        Boolean subscribed=false;

        Subscription__c subscription = SubscriptionService.getSubscription(recordId, userId);

        if(subscription != null){
            subscribed = subscription.Subscribed__c;
        }else{
            //check if the user is part of Case Team and create subscription
            String objectName = recordId.getSobjectType().getDescribe().getName();
            if('Case'.equalsIgnoreCase(objectName)){
                Case cse = [Select Id, OwnerId From Case Where Id = :recordId];
                if(cse.OwnerId == userId || CaseTeamService.isUserPartOfTeam(recordId, userId)){
                    SubscriptionService.createSubscription(recordId, userId, true);
                    subscribed = true;
                }
            }
        }

        return subscribed;
    }

    //get the subscription for the given record and user
    @AuraEnabled
    public static void toggleSubscription(Id recordId, Id userId, Boolean subscribe){
        if(subscribe){
            SubscriptionService.subscribe(recordId, userId);
        }else{
            SubscriptionService.unsubscribe(recordId, userId);
        }
    }
}