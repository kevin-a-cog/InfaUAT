/*
    @created by       : balajip
    @created on       : 02/11/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to Subscription Object
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
 public with sharing class SubscriptionService {
    public SubscriptionService() {

    }

    public static Subscription__c getSubscription(Id recordId, Id userId){

        List<Subscription__c> lstSubscription = [Select Id, Record_Id__c, Subscriber_Id__c, Subscribed__c 
                                                    From Subscription__c
                                                    Where Record_Id__c = :recordId And Subscriber_Id__c = :userId];

        Subscription__c subscription;
        if(!lstSubscription.isEmpty()){
            subscription = lstSubscription.get(0);
        }
        return subscription;
    }

    //create the subscription for the given record and user
    public static void createSubscription(Id recordId, Id userId, Boolean subscribe){
        Subscription__c subscription = new Subscription__c();
        subscription.Record_Id__c = recordId;
        subscription.Subscriber_Id__c = userId;
        subscription.Subscribed__c = subscribe;
        insert subscription;
    }

    //Set the subscription active for the given record and user
    public static void subscribe(Id recordId, Id userId){
        Subscription__c subscription = getSubscription(recordId, userId);

        if(subscription == null){
            createSubscription(recordId, userId, true);
        }else{
            if (!subscription.Subscribed__c){
                subscription.Subscribed__c = true;
                update subscription;
            }
        }
    }
    
    //remove the subscription for the given record and user
    public static void unsubscribe(Id recordId, Id userId){
        Subscription__c subscription = getSubscription(recordId, userId);

        if(subscription != null){
            subscription.Subscribed__c = false;
            update subscription;
        }
    }
}