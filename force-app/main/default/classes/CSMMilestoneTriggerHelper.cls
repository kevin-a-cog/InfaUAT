/*
* Name			:	CSMMilestoneTriggerHelper
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Helper class which implements the logic on Milestone Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
public with sharing class CSMMilestoneTriggerHelper {

    public void processAfterUpdate(List<Milestone__c> newList,Map<Id,Milestone__c> oldMap){
        List<Milestone__c> refinedList =new List<Milestone__c>();
        Set<Id> objectiveIdSet = new Set<Id>();
        for(Milestone__c  mileStone : newList) {
            if(mileStone.Status__c <> oldMap.get(mileStone.Id).Status__c){
                objectiveIdSet.add(mileStone.Objective__c);
            }
            if(oldMap.get(mileStone.Id)!=null && mileStone.Key_Milestone__c && 
               (oldMap.get(mileStone.Id).Key_Milestone__c != mileStone.Key_Milestone__c || oldMap.get(mileStone.Id).Objective__c != mileStone.Objective__c) ){
                refinedList.add(mileStone);
            }
        }
        if(objectiveIdSet?.size()>0){
            updateObjectiveStatus(objectiveIdSet);
        }
        
        resetKeyMilestone(refinedList);
    }
    
    public void processAfterInsert(List<Milestone__c> newList){
        Set<Id> objectiveIdSet = new Set<Id>();
        for(Milestone__c  mileStone : newList) {
                objectiveIdSet.add(mileStone.Objective__c);
        }
        if(objectiveIdSet?.size()>0){
            updateObjectiveStatus(objectiveIdSet);
        }
        
        resetKeyMilestone(newList);
    }
    
    public void processBeforeInsert(List<Milestone__c> newList){
        Set<Id> objectiveIdSet = new Set<Id>();
        for(Milestone__c milestone : newList){
            if(milestone.Objective__c <> null){
                objectiveIdSet.add(milestone.Objective__c);
            }
        }
        
        Map<Id,Objective__c> objMap = new Map<Id,Objective__c>([Select Id,Is_Internal__c from Objective__c where Id in:objectiveIdSet]);
        
        for(Milestone__c milestone : newList){
            if(objMap.get(milestone.Objective__c).Is_Internal__c == true){
                milestone.Is_Internal__c = true;
            }
        }
    }
    
     public void processBeforeUpdate(List<Milestone__c> newList,Map<Id,Milestone__c> oldMap){
     //  updatePlanId(newList, oldMap);
    }
    
    public void processAfterDelete(List<Milestone__c> newList,Map<Id,Milestone__c> oldMap){
        
        Set<Id> objectiveIdSet = new Set<Id>();
        for(Milestone__c  mileStone : oldMap.values()) {
            objectiveIdSet.add(mileStone.Objective__c);
        }
        if(objectiveIdSet?.size()>0){
            updateObjectiveStatus(objectiveIdSet);
        }
        
    }
    
    
    /** BUSINESS LOGIC **/
    public static void updateObjectiveStatus(Set<Id> objectiveIdSet){
        
        Map<Id,List<Milestone__c>> objToMilestonesMap = new Map<Id,List<Milestone__c>>();
        List<Objective__c> updateObjectivesList = new List<Objective__c>();
        
        /** Get the Objective to Milestone Map **/
        for(Milestone__c ms : [Select Id, Status__c,Objective__c from Milestone__c where Objective__c in:objectiveIdSet]){
            if(objToMilestonesMap.containsKey(ms.Objective__c)){
                List<Milestone__c> tempList = objToMilestonesMap.get(ms.Objective__c);
                tempList.add(ms);
                 objToMilestonesMap.put(ms.Objective__c, tempList);
            }else{
                objToMilestonesMap.put(ms.Objective__c, new List<Milestone__c>{ms});
            }
        } 
        
       /** Iterate the milestones and count based on Status **/
        for(Id objId : objToMilestonesMap.keySet()){
            
            Integer totalCount = objToMilestonesMap.get(objId).size();
            Integer yetToStartCount = 0;
            Integer inProgressCount = 0;
            Integer onHoldCount = 0;
            Integer completeCount = 0;
            Integer closedIncompleteCount = 0;
            Integer delayedcount=0;
            String objectiveStatus = '';
           
            
            for(Milestone__c ms : objToMilestonesMap.get(objId)){
                System.debug(ms);
                if(ms.Status__c == 'Yet to Start'){
                    yetToStartCount = yetToStartCount + 1;
                }else if(ms.Status__c == 'In Progress'){
                    inProgressCount = inProgressCount + 1;
                }else if(ms.Status__c == 'Delayed'){
                    delayedcount = delayedcount + 1;
                }else if(ms.Status__c == 'On-hold'){
                    onHoldCount = onHoldCount + 1;
                }else if(ms.Status__c == 'Complete'){
                    completeCount = completeCount + 1;
                }else if(ms.Status__c == 'Canceled'){
                    closedIncompleteCount = closedIncompleteCount + 1;
                }
            }
            
            /** Identify the respective Objective Status **/
            if(inProgressCount >0){
                objectiveStatus = 'In Progress';
            }else if(totalCount == yetToStartCount){
                objectiveStatus = 'Yet to Start';
            }else if(totalCount == onHoldCount){
                objectiveStatus = 'On-hold';
            }else if(totalCount == delayedcount){
                objectiveStatus = 'Delayed';
            }else if(totalCount == completeCount){
                objectiveStatus = 'Complete';
            }else if(totalCount == closedIncompleteCount){
                objectiveStatus = 'Canceled';
            }else if(yetToStartCount == 0 && inProgressCount == 0){
                objectiveStatus = 'Complete';
            }else{
                objectiveStatus = 'In Progress';
            }
			
			Objective__c obj = new Objective__c();
            obj.Id = objId;
            obj.Status__c = objectiveStatus;
            updateObjectivesList.add(obj);
        }
        System.debug('updateObjectivesList >>'+ updateObjectivesList);
        /** Update the Objective Status **/
        if(updateObjectivesList?.size()>0){
            update updateObjectivesList;
        }
    }
    
    public static void resetKeyMilestone(List<Milestone__c> newList) {
        Set<Id> keyMilestoneIdSet = new Set<Id>();
        Set<Id> objectiveIdSet = new Set<Id>();
        
        for(Milestone__c ms :newList) {
            if(ms.Key_Milestone__c && ms.Objective__c!=null) {
                objectiveIdSet.add(ms.Objective__c);
                keyMilestoneIdSet.add(ms.Id);
            }
        }
        if(keyMilestoneIdSet.size()>0){
            List<Milestone__c> milestoneUpdateList = new List<Milestone__c>();    
            for(Milestone__c ms : [SELECT Id FROM Milestone__c WHERE Key_Milestone__c = true AND Objective__c IN :objectiveIdSet AND Id NOT IN :keyMilestoneIdSet]) {
                ms.Key_Milestone__c = false;
                milestoneUpdateList.add(ms);
            }
            if(milestoneUpdateList.size()>0){
                update milestoneUpdateList;
            }
        }
    }
   

   /* public static void updatePlanId(List<Milestone__c> newList, Map<Id, Milestone__c> oldMap) {
        Set<Id> objectiveIdSet = new Set<Id>(); 

        for(Milestone__c mi : newList) {
            if(oldMap == null || mi.Objective__c != oldMap.get(mi.Id).Objective__c) {
                objectiveIdSet.add(mi.Objective__c);
            }
        }

        if(objectiveIdSet.isEmpty()) {
            return;
        }   

        Map<Id, Objective__c> objectiveMap = new Map<Id, Objective__c>([SELECT Id, Plan__c FROM Objective__c WHERE Id = :objectiveIdSet]);
        
        for(Milestone__c mi : newList) {
            if(objectiveMap.containsKey(mi.Objective__c)) {
                mi.Plan__c = objectiveMap.get(mi.Objective__c).Plan__c;
            }
        }
    }*/
    
}