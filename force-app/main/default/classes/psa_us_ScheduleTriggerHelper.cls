/*
@created by       : MAHESH GANTI
@created on       : 10/19/2020
@Purpose          : PSE_Schedule Object Trigger Helper Class
@Testclass        : 
@JIRA             : 

Change History
******************************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                             Jira No.    Tag
Wasim Akram     20-Mar-2023     Neha Kumari         Sync changes on Scheduled hours (Assignment) to Requested hour (RR)     PSA-2924    <T1>   
Wasim Akram     04-Oct-2023      NA                 Tech debt-Separate PSG for Ops-Rev Ops and Sub-con                      PSA-2925    <T2>
******************************************************************************************************************************************************
*/
public class psa_us_ScheduleTriggerHelper {
    public static globalApexManager GAM = new globalApexManager();
    public class psa_us_ScheduleTriggerHelperException extends Exception {}
     /**
    * this method is invoked on After Insert of Schedule object
    *
    * @param List<New Schedule Recs>, Trigger.new
    * @return return-void
    * @throws exception - NA
    */
    public void afterInsertSchedule(List<pse__Schedule__c> newSchList){
    }
    
     /**
    * this method is invoked on Before Update of Schedule object
    *
    * @param List<New Schedule Recs>, Trigger.new
    * @return return-void
    * @throws exception - NA
    */
    public void beforeUpdateSchedule(List<pse__Schedule__c> newSchList){
        validateSchedulePermissions(newSchList);
    }
    /**
    * this method is invoked to update Permission control records when an Assignment record is updated.
    *
    * @param List<New Schedule Recs>, Trigger.new map and Trigger.old Map
    * @return return-void
    * @throws exception - NA
    */
    public void afterScheduleUpdate(List<pse__Schedule__c> newSchList, Map<Id, pse__Schedule__c> newSchdMap,Map<Id, pse__Schedule__c> oldSchdMap){
        Map<Id,pse__Schedule__c> schMapToProcess = new Map<Id,pse__Schedule__c>();

        for(pse__Schedule__c oldRec : oldSchdMap.values()){
            for(pse__Schedule__c newRec : newSchdMap.values()){
                if((oldRec.Id == newRec.Id) && 
                    ((oldRec.pse__Start_Date__c <> newRec.pse__Start_Date__c) || (oldRec.pse__End_Date__c <> newRec.pse__End_Date__c))){
                        schMapToProcess.put(newRec.Id,newRec);
                }
            }
        }

        if(schMapToProcess.size()>0){
            psa_us_PermissionControlHandler.updatePermControlRecs(null,null,schMapToProcess,'Schedule');
        }
    }
    /**
    * this method is invoked to check if the User has access to Create or Edit Schedules
    *
    * @param List<New Schedule Recs>, Trigger.new 
    * @return return-void
    * @throws exception - NA
    */
    public void validateSchedulePermissions(List<pse__Schedule__c> newSchList){
        Boolean hasPermissions = false;
        Boolean isProjectSelfAssigned = false;
        Map<Id,Boolean> mapSchProjectSelfAssigned = new Map<Id,Boolean>();
        
       
        List<pse__Assignment__c> asgmtList = [SELECT Id,pse__Schedule__c,pse__Project__r.pse__Allow_Self_Staffing__c,pse__Project__r.pse__Project_Type__c 
                                              FROM pse__Assignment__c 
                                              WHERE pse__Schedule__c IN :newSchList];
        //Only if the schedule field is already updated on the Assignment
        if(asgmtList.size() > 0){
            for(pse__Assignment__c asgmt: asgmtList){
                if(!mapSchProjectSelfAssigned.containsKey(asgmt.pse__Schedule__c) && asgmt.pse__Project__r.pse__Allow_Self_Staffing__c && 
                   asgmt.pse__Project__r.pse__Project_Type__c =='Internal'){
                    mapSchProjectSelfAssigned.put(asgmt.pse__Schedule__c,true);
                }
            }        
           
            //Check if all the Schedules in the trigger list are from Self-Assigned Projects
            if(mapSchProjectSelfAssigned.size() == newSchList.size()){
                isProjectSelfAssigned = true;
            }
            //Check if the Project is Self Assigned
            if(!(isPSOpsOrRMO() || isProjectSelfAssigned)){
                newSchList[0].addError(Label.SchedulePermissionErrorMsg);
            }
        }
    }
    public static Boolean isPSOpsOrRMO(){
        Boolean hasPermissions = false;
        //<T2> - Included the PSA Rev Ops condition in the below select query
        List<Permissionsetassignment> psaPSAssignment = [SELECT Id FROM Permissionsetassignment WHERE AssigneeId = :UserInfo.getUserId() 
                                                         AND (PermissionSet.label = 'PSA Operations' OR PermissionSet.label = 'PSA Rev Ops' OR PermissionSet.label = 'PSA Resource Manager')
                                                         LIMIT 1]; 
        //Check if the current logged in user belongs to PS Ops or RMO
        if(psaPSAssignment.size() > 0){
            hasPermissions = true;            
        }
        return hasPermissions;
    } 
    //<T1>
    /**
    * update Requested Hours in the RR for the associated Schedules (when the scheduled hours is changed)
    * @param List<pse__Schedule__c>,List<pse__Schedule__c>,Map<Id,pse__Schedule__c>,Map<Id,pse__Schedule__c>
    * @return return-void
    * @throws exception - NA
    */   
    public void updateRRHours(List<pse__Schedule__c> newList,Map<Id, pse__Schedule__c> newMap, Map<Id, pse__Schedule__c> oldMap){
        Set<Id> schIdSet = new Set<Id>(); //Store the Scheduled Ids for which the Scheduled hours is modified
        for(pse__Schedule__c sch : newList){
            //If the Scheduled hours is changed
            if(sch.pse__Scheduled_Hours__c != oldMap.get(sch.Id).pse__Scheduled_Hours__c){
                //get the scheduled Ids
                schIdSet.add(sch.Id);
            }
        }
        //Get all the related RRs
        List<pse__Resource_Request__c> rrList = [SELECT Id,pse__Assignment__r.pse__Schedule__c FROM pse__Resource_Request__c WHERE pse__Assignment__r.pse__Schedule__c IN :schIdSet];
        for(pse__Resource_Request__c rr : rrList){
            //Update the Requested Hours in the RR from the Scheduled Hours of Schedule
            rr.pse__SOW_Hours__c = newMap.get(rr.pse__Assignment__r.pse__Schedule__c).pse__Scheduled_Hours__c;
        }
        try{
            update rrList;
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('psa_us_ScheduleTriggerHelper', 'Error while updating Requested hours on Resource Request in updateRRHours method',e.getMessage());
        }
    } 
    //</T1>   
}