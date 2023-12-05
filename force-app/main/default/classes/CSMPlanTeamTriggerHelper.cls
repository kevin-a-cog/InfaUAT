/*
* Name      :  CSMPlanTeamTriggerHelper
* Author    :  Deva M
* Created Date  :   08/07/2021
* Description  :  Helper Class for Plan Team Trigger

Change History
**********************************************************************************************************
Modified By      Date      Jira No.    Description                                                  Tag
**********************************************************************************************************
Deva M          08/07/2021    N/A        Initial version.                                           N/A
**********************************************************************************************************
Harshita J      12/07/2022    AR-2822   Handled regression issue                                    t1
**********************************************************************************************************
Harshita J      12/07/2022    AR-2889   Handled Error Message Issue                                 t2
**********************************************************************************************************
Harshita J      12/07/2022    AR-2889   Handled Error Message Issue                                 t3
**********************************************************************************************************
Harshita J      08/12/2022    AR-3042   Handled new requirement: Only 1 unique 
                                        primary role should be there for a plan                     t4
**********************************************************************************************************
Karthi G        08/07/2023    AR-3092   Handled scenario where Primary CSM is
                                        not updated correctly                                       T5

*/
public with sharing class CSMPlanTeamTriggerHelper {
    private CSMDuplicatePlanTeamValidation validationHelper = new CSMDuplicatePlanTeamValidation();
    private Set<String> defaultRoleSet = new Set<String>{'CSM','CSA'};
    private Set<String> csmRoleSet = new Set<String>{CSMUtilities.ROLE_CSM,CSMUtilities.ROLE_CSM_MANAGER};
    String errorMessage = 'User email cannot be updated from plan team';
    String planTeamErrorMessage = 'Please set an alternate primary before updating the team member';
    String planTeamRolesErrorMessage = 'You cannot select more than one user per role as primary.'; //</t4>
    /*
    Method Name : processBeforeInsert
    Description : This method will trigger for before update and refine the records
    Parameters  : List of new Plan Team instance and old map                
    Return Type : n/a
    */  
    public void processBeforeInsert(List<Plan_Team__c> newList){
        //Default unsnooze for all roles except CSM and CST. CSM and CST will have notification default turned on.
       
        for(Plan_Team__c pTeam : newList ){
            //Check if user field updated on records
            if(String.isNotBlank(pTeam.Role__c) && defaultRoleSet.contains(pTeam.Role__c)){
               pTeam.CSM_Receive_Notifications__c=true;
            }
            
        }
        populateUserDetails(newList);
       
    }    
    /*
    Method Name : processBeforeUpdate
    Description : This method will trigger for before update and refine the records
    Parameters  : List of new Plan Team instance and old map                
    Return Type : n/a
    */  
    public void processBeforeUpdate(List<Plan_Team__c> newList,Map<Id,Plan_Team__c> oldMap){
        List<Plan_Team__c> refinedPlanTeamList = new List<Plan_Team__c>();
         Set<Plan_Team__c> refinedPrimaryPlanTeam = new Set<Plan_Team__c>();
         Boolean validate = true;
        
        for(Plan_Team__c pTeam : newList ){
            //Check if user field updated on records
            if(oldMap.containsKey(pTeam.Id) && (oldMap.get(pTeam.Id).User__c != pTeam.User__c || (pTeam.User__c==null && oldMap.get(pTeam.Id).User_Email__c != pTeam.User_Email__c)) ){
                refinedPlanTeamList.add(pTeam);
            }
            //Check if Role field updated on records and updatereceive notfications.
            if(oldMap.containsKey(pTeam.Id) && String.isNotBlank(pTeam.Role__c) && defaultRoleSet.contains(pTeam.Role__c) &&  oldMap.get(pTeam.Id).Role__c != pTeam.Role__c ){
                pTeam.CSM_Receive_Notifications__c=true;
            }
            if(pTeam.User__c!=null && pTeam.Primary__c && pTeam.Last_Read_TimeStamp__c ==oldMap.get(pTeam.Id).Last_Read_TimeStamp__c){//<t4>
                refinedPrimaryPlanTeam.add(pTeam);
            } //</t4>

            if(oldMap.containsKey(pTeam.Id) && String.isNotBlank(pTeam.Role__c) &&  oldMap.get(pTeam.Id).Role__c != pTeam.Role__c && pTeam.Role__c == CSMUtilities.ROLE_CSM && oldMap.get(pTeam.Id).Role__c == CSMUtilities.ROLE_CSM_MANAGER && pTeam.Primary__c){
                validate = false; // T5
            }

        }        

        if(validate && CSMPlanTeamTriggerCheckRecursive.bypassValidationForupsert){//t3

            validatePrimaryTeam(newList,oldMap);
        }//bypass for upsert
        
        if(refinedPlanTeamList.size()>0){
            //Preppupulate user records
            populateUserDetails(refinedPlanTeamList);
        }
         if(refinedPrimaryPlanTeam.size()>0){//<t4>
          validateMultipleRoles(refinedPrimaryPlanTeam);
        }//</t4>
    }
    /*
    Method Name : processafterInsert
    Description : This method will trigger for after update 
    Parameters  : List<Plan_Team__c> newList, new instance of trigger              
    Return Type : n/a
    */ 
    public void processafterInsert(List<Plan_Team__c> newList){ 
        handlePlanUpdate(newList);

        Map<Id,Plan_Team__c> mapPlanTeams = new Map<Id,Plan_Team__c>();
        Map<Id,Set<String>> mapPlanPrimaryRoles = new Map<Id,Set<String>>();
        for(Plan_Team__c pTeam:newList){
            if(pTeam.User__c != null && pTeam.Primary__c && (pTeam.Role__c == CSMUtilities.ROLE_CSM || pTeam.Role__c == CSMUtilities.ROLE_CSM_MANAGER)){
                mapPlanTeams.put(pTeam.Id,pTeam);
                if(mapPlanPrimaryRoles.containsKey(pTeam.Plan__c)){
                    mapPlanPrimaryRoles.get(pTeam.Plan__c).add(pTeam.Role__c);
                }
                else{
                    mapPlanPrimaryRoles.put(pTeam.Plan__c, new Set<String>{pTeam.Role__c});
                }
            }
        }

        if(mapPlanTeams.size()>0){
            uncheckIsPrimary(mapPlanTeams, mapPlanPrimaryRoles); //T5
        }
    }  
    /*
    Method Name : processafterUpdate
    Description : This method will trigger for after update 
    Parameters  : List<Plan_Team__c> newList, new instance of trigger
                    Map<Id,Plan_Team__c> oldMap,Old instance of trigger              
    Return Type : n/a
    */     
    public void processafterUpdate(List<Plan_Team__c> newList, Map<Id,Plan_Team__c> oldMap){
        handlePlanUpdate(newList);

        Map<Id,Plan_Team__c> mapPlanTeams = new Map<Id,Plan_Team__c>();
        Map<Id,Set<String>> mapPlanPrimaryRoles = new Map<Id,Set<String>>();
        for(Plan_Team__c pTeam:newList){
            if(pTeam.User__c!=null && oldMap.containsKey(pTeam.Id) &&  ((oldMap.get(pTeam.Id).Primary__c != pTeam.Primary__c)  || (oldMap.get(pTeam.Id).Role__c != pTeam.Role__c)) && pTeam.Primary__c && (pTeam.Role__c == CSMUtilities.ROLE_CSM || pTeam.Role__c == CSMUtilities.ROLE_CSM_MANAGER)){
                mapPlanTeams.put(pTeam.Id,pTeam);
                if(mapPlanPrimaryRoles.containsKey(pTeam.Plan__c)){
                    mapPlanPrimaryRoles.get(pTeam.Plan__c).add(pTeam.Role__c);
                }
                else{
                    mapPlanPrimaryRoles.put(pTeam.Plan__c, new Set<String>{pTeam.Role__c});
                }
            }
        }

        if(mapPlanTeams.size()>0){
            uncheckIsPrimary(mapPlanTeams, mapPlanPrimaryRoles); //T5
        }
    }
    
    /*
    Method Name : populateUserDetails
    Description : This method will trigger for before update and prepopulate user fields from user lookup
    Parameters  : List of new Plan Team records               
    Return Type : n/a
    */ 
    public void populateUserDetails(List<Plan_Team__c> newList){
        Set<Id> refinedPlanTeamSet = new Set<Id>();      
        for(Plan_Team__c pTeam : newList ){
            //Filter the user id's
            if(pTeam.User__c!=null){
                refinedPlanTeamSet.add(pTeam.User__c);
            }
        }
        if(!refinedPlanTeamSet.isEmpty()){
            Map<Id,User> userMap = new Map<Id,User>([SELECT Id,firstName,lastName,Email FROM User WHERE Id IN:refinedPlanTeamSet]);
            for(Plan_Team__c pTeam : newList ){
                //Check if the user record queries and map contains user id
                if(userMap.containsKey(pTeam.User__c)){
                    //Assign the user params
                    User getIndivUser=userMap.get(pTeam.User__c);
                    pTeam.First_Name__c=getIndivUser.firstName;
                    pTeam.Last_Name__c=getIndivUser.lastName;
                    pTeam.User_Email__c=getIndivUser.Email;
                }
            }             
        }
        if(!newList.isEmpty()){
            //valdiate records and trigger if the duplciate record found
            validationHelper.validate(newList);
        }        
    }
    //<t4>
    /* 
    Method Name : validateMultipleRoles
    Description : This method will check if more than one role is set to primary at time of updation
    Parameters  : set of new Plan Team records               
    Return Type : n/a
    */ 
    public void validateMultipleRoles(Set<Plan_Team__c> primaryPlanTeamIdSet){
        map<string,Integer> checkRolesCount = new map<string,Integer> ();
       for(Plan_Team__c pTeam :primaryPlanTeamIdSet){
          if(checkRolesCount.containskey(pTeam.Plan__c+'-'+pTeam.Role__c)){
           integer currentCount = checkRolesCount.get(pTeam.Plan__c+'-'+pTeam.Role__c);
           checkRolesCount.put(pTeam.Plan__c+'-'+pTeam.Role__c,currentCount+1);
           pteam.adderror(planTeamRolesErrorMessage);
          }
          else{
            checkRolesCount.put(pTeam.Plan__c+'-'+pTeam.Role__c,1);
          } 
         
       }

    }
    //</t4>

      /*
    Method Name : handlePlanUpdate
    Description : This method will call upon on create/uptate of primary CSM/CSManager 
    Parameters  : List of new Plan Team records               
    Return Type : n/a
    Tag : T5
    */
    
    public void handlePlanUpdate(List<Plan_Team__c> newList){
        Map<Id,Plan__c> mapPlanUpdate = new Map<Id,Plan__c>();
        for(Plan_Team__c pt:newList){
            Plan__c plan;
            if(mapPlanUpdate.containsKey(pt.Plan__c)){
                plan = mapPlanUpdate.get(pt.Plan__c);
            }
            else{
                plan = new Plan__c(Id=pt.Plan__c);
            }
            if(pt.User__c!=null && pt.Primary__c && pt.Role__c==CSMUtilities.ROLE_CSM){
                plan.OwnerId = pt.User__c;
                mapPlanUpdate.put(pt.Plan__c,plan);
            }
            else if(pt.User__c!=null && pt.Primary__c && pt.Role__c==CSMUtilities.ROLE_CSM_MANAGER){
                plan.Csm_Manager__c = pt.User__c;
                mapPlanUpdate.put(pt.Plan__c,plan);
            }
        }

        if(mapPlanUpdate.size()>0){
            Database.update(mapPlanUpdate.values(),false);
        }

    }
    /*
    Method Name : uncheckIsPrimary
    Description : Thsi method will call upon on create/uptate of primary CSM/CSManager 
    Parameters  : List of new Plan Team records               
    Return Type : n/a
    Tag : T5 // rewritten the logic to uncheck primary
    */ 
    public void uncheckIsPrimary(Map<Id,Plan_Team__c> mapPlanTeams,Map<Id,Set<String>> mapPlanPrimaryRoles){
        List<Plan_Team__c> lstPteamUpdate = new List<Plan_Team__c>();
        List<String> lstRoles = new List<String>{CSMUtilities.ROLE_CSM, CSMUtilities.ROLE_CSM_MANAGER};
        for(Plan_Team__c objPTeam : [SELECT Id, Plan__c, Primary__c, Role__c, User__c from Plan_Team__c WHERE Plan__c IN :mapPlanPrimaryRoles.keyset() AND Id NOT IN : mapPlanTeams.keyset() AND Primary__c=true AND Role__c IN :lstRoles]){
            if(mapPlanPrimaryRoles.containsKey(objPTeam.Plan__c) && mapPlanPrimaryRoles.get(objPTeam.Plan__c).contains(objPTeam.Role__c)){
                objPTeam.Primary__c =  false;
                lstPteamUpdate.add(objPTeam);
            }
        }
        if(lstPteamUpdate.size()>0){
            Database.update(lstPteamUpdate,false);
        }
    }
     /*
    Method Name : validatePrimary
    Description : Thsi method will call from before update to validate primary team
    Parameters  : List of new Plan Team records               
    Return Type : n/a
    */ 
    public void validatePrimaryTeam(List<Plan_Team__c> newList,Map<Id,Plan_Team__c> oldMap){

        Map<Id,Map<String,Id>> primaryRoleMap = new Map<Id,Map<String,Id>>();
        Set<Id> planIdSet = new Set<Id>();
        Map<Id,Plan_Team__c> newMap= new Map<Id,Plan_Team__c>();

        for(Plan_Team__c pTeam:newList){
            if(pTeam.Last_Read_TimeStamp__c == oldMap.get(pTeam.Id).Last_Read_TimeStamp__c){
                planIdSet.add(pTeam.Plan__c);
                newMap.put(pTeam.Id,pTeam);
                if(pTeam.Primary__c){
                    if(primaryRoleMap.containsKey(pTeam.Plan__c)){
                        if(primaryRoleMap.get(pTeam.Plan__c).containsKey(pTeam.Role__c)){
                            pteam.adderror(planTeamRolesErrorMessage);
                            //CSMPlanTeamTriggerCheckRecursive.runAfterUpdateOnce();
                        }else{
                            primaryRoleMap.get(pTeam.Plan__c).put(pTeam.Role__c,pTeam.Id);
                        }
                    }
                    else{
                        primaryRoleMap.put(pTeam.Plan__c,new Map<String,Id>{pTeam.Role__c=>pTeam.Id});
                    }
                }
            }
        }
        Set<Id> duperror=new Set<Id>();
        if(!planIdSet.isEmpty()){
            for(Plan_Team__c pTeam:[SELECT Id,User__c,Plan__c,Primary__c,User__r.ManagerId,Role__c FROM Plan_Team__c where Plan__c IN : planIdSet AND Primary__c=true AND Id NOT IN :oldMap.keyset()]){
                if(pTeam.Primary__c && (!newMap.containsKey(pTeam.Id) || (newMap.containsKey(pTeam.Id) && !newMap.get(pTeam.Id).Primary__c && pTeam.Role__c == newMap.get(pTeam.Id).Role__c))){
                    if(primaryRoleMap.containsKey(pTeam.Plan__c)){
                        if(primaryRoleMap.get(pTeam.Plan__c).containsKey(pTeam.Role__c) ){
                            duperror.add(pTeam.Id);
                        }else{
                            primaryRoleMap.get(pTeam.Plan__c).put(pTeam.Role__c,pTeam.Id);
                        }
                    }
                    else{
                        primaryRoleMap.put(pTeam.Plan__c,new Map<String,Id>{pTeam.Role__c=>pTeam.Id});
                    }
                }
            }

            for(Plan_Team__c pTeam:newList){
                
                if(duperror.contains(pTeam.Id) || (primaryRoleMap.containsKey(pTeam.Plan__c) && primaryRoleMap.get(pTeam.Plan__c).get(pTeam.Role__c)!=pTeam.Id && pTeam.Primary__c)){
                    pteam.adderror(planTeamRolesErrorMessage);
                    //CSMPlanTeamTriggerCheckRecursive.runAfterUpdateOnce();
                }
                if(!primaryRoleMap.containsKey(pTeam.Plan__c) || !primaryRoleMap.get(pTeam.Plan__c).containsKey(CSMUtilities.ROLE_CSM) || !primaryRoleMap.get(pTeam.Plan__c).containsKey(CSMUtilities.ROLE_CSM_MANAGER) || (primaryRoleMap.get(pTeam.Plan__c).get(pTeam.Role__c)==pTeam.Id && !pTeam.Primary__c)){
                    
                        pteam.adderror(planTeamErrorMessage);
                        //CSMPlanTeamTriggerCheckRecursive.runAfterUpdateOnce();
                    
                }
            }
        }

    }


    public void processBeforeDelete (List<Plan_Team__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
          
            for( Plan_Team__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
               
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];
                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                       
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Plan_Team__c ac:newList){
                    
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                    }
                }
            }
        
    }
}