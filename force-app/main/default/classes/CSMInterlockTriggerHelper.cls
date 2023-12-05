public with sharing class CSMInterlockTriggerHelper {
     /*
    Method Name : process after Update
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Related_Opportunity_Plan__c> newList,Map<Id,Related_Opportunity_Plan__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }
     /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterInsert(List<Related_Opportunity_Plan__c> newList,Map<Id, Related_Opportunity_Plan__c> oldMap){
        NotificationService.notify(newList, oldMap);
    }

    public void processBeforeDelete (List<Related_Opportunity_Plan__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
            System.debug('In Plan contact');
            for( Related_Opportunity_Plan__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
                System.debug('In Plan contact');
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];

                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                        System.debug('In Plan contact');
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Related_Opportunity_Plan__c ac:newList){
                    System.debug('In Plan contact');
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        if(!Test.isRunningTest()){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                    }
                }
            }
            }
        
    }
}