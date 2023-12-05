public class CSMObjectiveTriggerHelper {

     /*
    Method Name : processBefoprocessAfterUpdatereUpdate
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Objective__c> newList,Map<Id,Objective__c> oldMap){
        /** Mark all milestones to Internal while updating Objective from External to Internal**/
        Set<Id> internalObjectiveSet = new Set<Id>();
        List<Milestone__c> lMilestones = new List<Milestone__c>();
        Map<Id,Objective__c> mapObjectivies = new Map<Id,Objective__c>();
        
        for(Objective__c obj : newList){
            if(obj.Is_Internal__c && oldMap.get(obj.Id).Is_Internal__c <> obj.Is_Internal__c){
                internalObjectiveSet.add(obj.Id);
            }
            //AR-1734	
            if(String.isNotBlank(obj.Signed_Off_By__c) && obj.Signed_Off_By__c.equals('Customer') && obj.Sign_Off_Date__c!=null && obj.Customer_Sign_off_Contact__c!=null && 
                    oldMap.get(obj.Id).Customer_Sign_off_Contact__c != obj.Customer_Sign_off_Contact__c ){
                mapObjectivies.put(obj.id,obj);
            }
        }
        if(internalObjectiveSet.size()>0){
            for(Milestone__c milestone : [Select Id,Is_Internal__c from Milestone__c where Objective__c in :internalObjectiveSet and Is_Internal__c = false]){
                milestone.Is_Internal__c = true;
                lMilestones.add(milestone);
            }
        }
        //AR-1734
        if(mapObjectivies.size()>0){
            CSMPlanCommsInternalCommentHelper.createObjectiveInternalComment(mapObjectivies);
        }
        if(lMilestones?.size()>0){
            update lMilestones;
        }
        
    }
    
    public void processBeforeInsert(List<Objective__c> newList){
        Set<Id> planIdSet = new Set<Id>();
        for(Objective__c obj : newList){
            if(obj.Plan__c <> null){
                planIdSet.add(obj.Plan__c);
            }
        }
        
        Map<Id,Plan__c> planMap = new Map<Id,Plan__c>([Select Id,Is_Internal__c from Plan__c where Id in:planIdSet]);
        
        for(Objective__c obj : newList){
            if(planMap.get(obj.Plan__c).Is_Internal__c == true){
                obj.Is_Internal__c = true;
            }
        }
        
    }
}