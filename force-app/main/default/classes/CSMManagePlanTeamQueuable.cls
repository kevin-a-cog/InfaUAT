/*
Class:          CSMManagePlanTeamQueuable
@Author:        Karthi G
@Created Date:  09-Jan-2023
@Description:   CSM handler class for User triggers

    Change History
****************************************************************************************************************************************************
    ModifiedBy          Date        Requested By        Description                                         JIRA        Tag
****************************************************************************************************************************************************
    Karthi G         09-01-2023     Sarojini B       Update Plan team when user manager is changed          AR-3064    Initial Version
****************************************************************************************************************************************************
*/
public class CSMManagePlanTeamQueuable implements Queueable {
    public List<Id> userIdList; //list of user Id from trigger
    public static globalApexManager GAM = new globalApexManager();

    public CSMManagePlanTeamQueuable(List<Id> userIdList) {
        this.userIdList = userIdList;
    }

    public void execute(QueueableContext context) {
        List<Plan_Team__c> planteamtoUpsert = new List<Plan_Team__c>();
        List<Plan_Team__c> planteamtoudpate = new List<Plan_Team__c>();

        Map<Id,Plan_Team__c> existingMap = new Map<Id,Plan_team__c>();
        Map<Id,Id> planManagerMap = new Map<Id,Id>();
        Map<Id,String> planManagerEmailMap = new Map<Id,String>();
        
        try{
            // query all active plans where the current user is owner
            for(Plan__c pl:[Select id, OwnerId,  typeof Owner when User then Managerid,Manager.Email,isActive END from Plan__c where Status__c='Active' AND Is_Template__c=FALSE AND OwnerId IN :userIdList]){
                if(pl.Owner instanceof User){
                    User own = pl.Owner;
                    if(own.isActive){ //verify if owner is active
                    planManagerMap.put(pl.Id,own.Managerid); 
                    planManagerEmailMap.put(pl.Id,own.Manager.Email); 
                    }
                }
            }
            // query all plan team records related to plans
            for(Plan_Team__c pt:[Select User__c, Plan__c,Primary__c,Role__c from Plan_Team__c where Plan__c IN : planManagerMap.keyset() AND ((Role__c='CSM Manager' AND Primary__c=TRUE) OR User__c IN:planManagerMap.values())]){
                if(pt.User__c==planManagerMap.get(pt.Plan__c)){ // check if updated manager user already exists in plan team
                    existingMap.put(pt.Plan__c,pt);
                }
                else if(pt.User__c!=planManagerMap.get(pt.Plan__c) && pt.Primary__c){ // check if any other primary manager exists, other than updated one
                    planteamtoudpate.add(new Plan_Team__c(Id=pt.Id,Primary__c=false)); //set primary to false for old manager
                }
            }

            for(Id pId:planManagerMap.keyset()){
                if(existingMap.containskey(pId)){
                    if(!existingMap.get(pId).Primary__c || existingMap.get(pId).Role__c != 'CSM Manager'){ // check if the existing manager user is with 'CSM Manager' role and primary
                        planteamtoUpsert.add(new Plan_Team__c(Id=existingMap.get(pId).Id,Primary__c=true,Role__c='CSM Manager')); //update role and primary flag, if user exists with different role
                    }
                }
                else{ // if updated manager user is not part of plan team, define new plan team record to insert
                    Plan_Team__c ptnew= new Plan_Team__c();
                    ptnew.User__c=planManagerMap.get(pId);
                    ptnew.User_Email__c=planManagerEmailMap.get(pId);
                    ptnew.Plan__c=pId;
                    ptnew.Primary__c=true;
                    ptnew.Role__c='CSM Manager';
                    planteamtoUpsert.add(ptnew);
                }
            }
            
            if(planteamtoUpsert.size()>0){ //insert and update the New manager changes
                Database.UpsertResult[] srList = Database.upsert(planteamtoUpsert, false);
                for (Database.UpsertResult sr : srList) {
                    if (!sr.isSuccess()) { // handle error
                        for(Database.Error err : sr.getErrors()) {
                            GAM.CreateLogs('CSMManagePlanTeamQueuable -upsert planteamtoUpsert', sr.getId(), String.join(err.getFields(),','), err.getMessage());
                        }
                    }
                }
            }
            if(planteamtoudpate.size()>0){ // update the old manager primary flag to false
                Database.SaveResult[] srList = Database.update(planteamtoudpate, false);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) { //handle error
                        for(Database.Error err : sr.getErrors()) {
                            GAM.CreateLogs('CSMManagePlanTeamQueuable -Update planteamtoudpate', sr.getId(), String.join(err.getFields(),','), err.getMessage());
                        }
                    }
                }
            }
        } catch(Exception ex){                     
             GAM.CreateExceptionRecords('CSMManagePlanTeamQueuable', 'Exception in Plan team update on User Manager change',ex.getMessage());
        }
         GAM.InsertDebugLogs(); //store the errors in Exceptions_Log__c object
    }
}