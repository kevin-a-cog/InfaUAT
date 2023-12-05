/*
    @created by       : MAHESH GANTI
    @created on       : NOVEMBER 11 2020
    @Purpose          : Service level class to handle PSA-Project updates.
    @Testclass        : 
    @JIRA             : 
    @Tag              : T01   
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Pavithra V   22-02-2021                          Project Manager field is not populated properly          PSA-863       T02
Pavithra V   09-Dec-2021     Cosmos              To sync the project details to IPS Jumpstart Engagement  AR-1584       T03                                                 for Interlock's Project

 */
public class psa_ProjectFieldUpdatesHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    
    /**
    * Method to get date on when a timesheet in a format - value to be update on project.
    *
    * @param 
    * @return return-void
    * @throws exception - NA
    */
    /**
     * public static Map<Id,String> calculateLastCreatedTimeSheetDate(List<pse__Timecard_Header__c> timeCardList){
        Map<Id,String> projIdDateMap = new Map<Id,String>();
        Map<Id, pse__Timecard_Header__c> timeCardMap = new Map<Id, pse__Timecard_Header__c>([SELECT Id,Name,pse__End_Date__c,pse__Project__c
                                                                                            FROM pse__Timecard_Header__c
                                                                                            WHERE Id IN: timeCardList]);       
        Date todayDate = System.today();
        String reqDateFormat = psa_UtilsController.getFormattedDate(); //need to check the code logic.
        
        for(pse__Timecard_Header__c tcRec : timeCardMap.values()){
            Date quarterStartDate;
            Date quarterEndDate;
            if(tcRec.pse__End_Date__c <> null){

            }
        }
        return projIdDateMap;
    }
     */
    

    /**
    * The Future method is invoked from the Interlock Trigger to create a Project.
    * @param lstNew - Set<Interlock Ids>
    * @return return-void
    * @throws exception - NA
    */
    
    @future
    public static void createProjectsFromInterlockIds(Set<Id> interLockSet){
        List<pse__Proj__c> projRecsToCreateList = new List<pse__Proj__c>();
        List<pse__Proj__c> projRequeryList = new List<pse__Proj__c>();
        List<Related_Opportunity_Plan__c> baseInterLockList = new List<Related_Opportunity_Plan__c>(); 
        List<Related_Opportunity_Plan__c> interLocksToUpdateList = new List<Related_Opportunity_Plan__c>();
        Map<Id,Id> interLockAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> interLockContactIdMap = new Map<Id,Id>();
        Id practiceRec;
        List<pse__Practice__c> practiceLst = new List<pse__Practice__c>([Select Id,Name from pse__Practice__c where Name ='Consulting Services' Limit 1]);
        if(!practiceLst.isEmpty()){
            practiceRec = practiceLst[0].Id;
        }
        Map<Id,Related_Opportunity_Plan__c> interLockMap = new Map<Id,Related_Opportunity_Plan__c>([SELECT Id,Name,Interlock_Type__c,Account__c,Account__r.Name,Account__r.Health_Score__c,Plan__c,Plan__r.Account__c,Plan__r.Account__r.Name,
                                                                                                    Original_Opportunity__c,Original_Opportunity_Number_Text__c,Original_Opportunity__r.New_Org_Opportunity_Number__c,CreatedById,CreatedBy.Name,
                                                                                                    Opportunity__c,Opportunity__r.New_Org_Opportunity_Number__c,CurrencyIsoCode,Partner_name_if_any__c,Comments__c,Expected_Start_Date__c,Success_Pack__c,
                                                                                                    Opportunity__r.SBQQ__RenewedContract__c,Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__c,
                                                                                                    Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c                                                                                                                                                                                                  
                                                                                                    FROM Related_Opportunity_Plan__c 
                                                                                                    WHERE Id IN :interLockSet]);
                                                                                                       
        if(interLockMap.size()>0){
            for(Related_Opportunity_Plan__c ilRec : interLockMap.values()){
                if(ilRec.Account__c <> null){
                    interLockAccountIdMap.put(ilRec.Id,ilRec.Account__c);
                }
                // only need this if the Account is not populated on Interlock rec - need to check
                if(ilRec.Account__c == null && ilRec.Plan__r.Account__c <> null){
                    interLockAccountIdMap.put(ilRec.Id,ilRec.Plan__r.Account__c);
                }
            }
        } 
        if(interLockAccountIdMap.size()>0){
            interLockContactIdMap = getPMContactFromAccountIds(interLockAccountIdMap);
        }

        for(Related_Opportunity_Plan__c interlock : interLockMap.values()){
            string orgOpptyNumber;
            if(interlock.Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c <> null){
                orgOpptyNumber = interlock.Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c;
            }
            if((interlock.Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c == null) && (interlock.Original_Opportunity_Number_Text__c <> null)){
                orgOpptyNumber = interlock.Original_Opportunity_Number_Text__c;
            }
            // If Interlock type == jumpstart or checkup and the original opportunity is null then we dont create a project.
            if(((interlock.Interlock_Type__c == 'JumpStart' || interlock.Interlock_Type__c == 'Checkup') && (orgOpptyNumber <> null)) ||
                (interlock.Interlock_Type__c == 'Renewal Rescue')){
            
                pse__Proj__c projRec = new pse__Proj__c();
                projRec.psa_om_Interlock__c = interlock.id;
                projRec.pse__Practice__c = practiceRec;
                projRec.psa_pm_Source__c = 'Interlock';
                if(interlock.Interlock_Type__c == 'JumpStart'){               
                    projRec.Name = interlock.Account__r.Name+' - '+interlock.Original_Opportunity__r.New_Org_Opportunity_Number__c + '- JS';
                    //projRec.psa_pm_Engagement_Type__c = 'Jumpstart';
                    projRec.psa_pm_Project_Sub_Type__c = 'JumpStart';
                    projRec.pse__Opportunity__c = interlock.Original_Opportunity__c;                    
                }
                if(interlock.Interlock_Type__c == 'Renewal Rescue'){
                    projRec.Name = interlock.Account__r.Name+' - '+interlock.Opportunity__r.New_Org_Opportunity_Number__c + '- RR';
                    //projRec.psa_pm_Engagement_Type__c = 'Renewal Rescue';
                    projRec.psa_pm_Project_Sub_Type__c = 'Renewal Rescue';
                    projRec.pse__Opportunity__c = interlock.Opportunity__c;
                }
                if(interlock.Interlock_Type__c == 'Checkup'){
                    projRec.Name = interlock.Account__r.Name+' - '+interlock.Original_Opportunity__r.New_Org_Opportunity_Number__c + '- CP';
                    //projRec.psa_pm_Engagement_Type__c = 'Health Check';
                    projRec.psa_pm_Project_Sub_Type__c = 'Health Checks';
                    projRec.pse__Opportunity__c = interlock.Original_Opportunity__c;
                }
                projRec.pse__Start_Date__c = interlock.Expected_Start_Date__c;
                projRec.pse__End_Date__c = interlock.Expected_Start_Date__c.addDays(90);
                projRec.pse__Stage__c = 'Planned';// changed to Planned based on comment from Sindhuja
                projRec.pse__Project_Status__c = 'Green';
                if(interLockContactIdMap.containsKey(interlock.Id)){
                    projRec.pse__Project_Manager__c = interLockContactIdMap.get(interlock.Id);
                    projRec.psa_pm_Portfolio_Manager__c = interLockContactIdMap.get(interlock.Id);
                }
                projRec.pse__Account__c = interlock.Account__c;
                projRec.CurrencyIsoCode = interlock.CurrencyIsoCode;
                projRec.pse__Project_Type__c = 'Customer Project'; //Defaulting to Internal PSA - 949.
                projRec.psa_pm_Project_Category__c = 'Non - Billable';
                projRec.pse__Is_Active__c = true;
                projRec.psa_pm_Project_Notes__c = 'Health Score :'+interlock.Account__r.Health_Score__c+'; '+'Partner Name :'+interlock.Partner_name_if_any__c+'; '+'Comments:'+interlock.Comments__c+';'+'CSM: '+interlock.CreatedBy.Name;
                //projRec.pse__Notes__c = 'Health Score :'+interlock.Account__r.Health_Score__c+'; '+'Partner Name :'+interlock.Partner_name_if_any__c+'; '+'Comments:'+interlock.Comments__c+';'+'CSM: '+interlock.CreatedBy.Name;
                projRecsToCreateList.add(projRec);
            }
        }
        if(projRecsToCreateList.size()>0){
            try{
                insert projRecsToCreateList;
            }          
            catch(Exception e){
                system.debug('Error Message'+e.getMessage());
                GAM.CreateLogs('CLASS: psa_ProjectFieldUpdatesHandler | METHOD: createProjectsFromInterlockIds', projRecsToCreateList , 'projRecsToCreateList- Project Recs Creation FROM INTERLOCK');
            }
        }     
        // Update the InterLock Record with Project Data - need to check if it is needed?
      //  psa_om_UpdateInterlockBatchHandler.updateInterLockRecs(interLockSet);
    }

     /**
    * The  method will Fetch the corresponding Project Manager for the Project being automated from the Interlock
    * @param MAP - Map<InterlockId,AccountId>
    * @return return- Ma-<InterlockId,ContactId>
    * @throws exception - NA
    */
    public static Map<Id,Id> getPMContactFromAccountIds(Map<Id,Id> ilAccMap){
        
        Map<Id,Id> interLockPMContactMap = new Map<Id,Id>();
        Map<Id,String> accIdGeoMap = new Map<Id,String>();
        Map<String,Account_Territory_Setting__mdt> accPMCustomMDMap = new Map<String,Account_Territory_Setting__mdt>();
        List<AccountUserTerritory2View> terUsersByAccList = new List<AccountUserTerritory2View>();
        Map<Id,List<AccountUserTerritory2View>> accIdUserListMap = new Map<Id,List<AccountUserTerritory2View>>();
        Map<Id,Id> accIdUserIdMap = new Map<Id,Id>();
        Map<Id,String> accIdConNameMap = new Map<Id,String>();
        List<Contact> contactsByUserIdList = new List<Contact>();
        List<Contact> contactsByNameList = new List<Contact>();
        Map<Id,Id> accIdConIdMap = new Map<Id,Id>();
        Set<Id> inActiveUserAccSet = new Set<Id>();

        
        List<Account> accountRecsList = new List<Account>([SELECT Id,Name,Geo__c,(SELECT Id,AccountId,RoleInTerritory2,Territory2Id,UserId FROM AccountUserTerritory2Views)
                                                            FROM Account 
                                                            WHERE Id IN:ilAccMap.values()]);
        
        if(accountRecsList.size()>0){
            for(Account accRec : accountRecsList){
                if(accRec.Geo__c <> null || accRec.Geo__c <> ''){
                    accIdGeoMap.put(accRec.Id,accRec.Geo__c);
                }
                AccountUserTerritory2View[] childList = accRec.AccountUserTerritory2Views;
                if(childList.size()>0){
                    accIdUserListMap.put(accRec.Id,childList);
                }               
            }
        }
        if(accIdGeoMap.size()>0){
            for(Account_Territory_Setting__mdt prm : [SELECT Id,Label,DeveloperName, Default_Assignee__c,User_Role__c 
                                                    FROM Account_Territory_Setting__mdt 
                                                    WHERE Label IN : accIdGeoMap.values()]){
                accPMCustomMDMap.put(prm.Label,prm);
            }
        }
        if(accIdUserListMap.size()>0){

            for(Id accId : accIdUserListMap.keySet()){
                List<AccountUserTerritory2View> usrList = accIdUserListMap.get(accId);
                if(usrList.size()>0){
                    for(AccountUserTerritory2View usrRoleRec : usrList){
                        //if(accIdGeoMap.containsKey(accId){
                            Account_Territory_Setting__mdt accGeoSettingRec = accPMCustomMDMap.get(accIdGeoMap.get(accId));
                            
                            if(accGeoSettingRec.User_Role__c <> null){
                                if(accGeoSettingRec.User_Role__c == usrRoleRec.RoleInTerritory2 || Test.isRunningTest()){
                                    accIdUserIdMap.put(accId,usrRoleRec.UserId);
                                }
                                if(accGeoSettingRec.User_Role__c <> usrRoleRec.RoleInTerritory2){
                                    accIdConNameMap.put(accId,accGeoSettingRec.Default_Assignee__c);
                                }
                            }
                            if((accGeoSettingRec.User_Role__c == null) || (accGeoSettingRec.User_Role__c == '')){
                                accIdConNameMap.put(accId,accGeoSettingRec.Default_Assignee__c);
                            }
                        //}
                        
                    }
                }
            }
        }
        
        if(accIdUserIdMap.size()>0){
            contactsByUserIdList = [SELECT Id,Name,pse__Salesforce_User__c,pse__Salesforce_User__r.IsActive 
                                    FROM Contact
                                    WHERE pse__Salesforce_User__c IN : accIdUserIdMap.values()];        
        }
        
        if(contactsByUserIdList.size()>0){
            for(Id accId : accIdUserIdMap.keySet()){
                for(Contact conRec : contactsByUserIdList){
                    Id userId = accIdUserIdMap.get(accId);
                    if((userId == conRec.pse__Salesforce_User__c) && (conRec.pse__Salesforce_User__r.IsActive == true)){
                        accIdConIdMap.put(accId,conRec.Id);
                    }
                    if((userId == conRec.pse__Salesforce_User__c) && (conRec.pse__Salesforce_User__r.IsActive == false)){
                        // If the assigned user for the require role is inactive, then assign the default user.
                        inActiveUserAccSet.add(accId);
                    }
                }
            }
        }

        if(inActiveUserAccSet.size()>0){
            for(Id accId : inActiveUserAccSet){
                String defaultContact = accPMCustomMDMap.get(accIdGeoMap.get(accId)).Default_Assignee__c;
                accIdConNameMap.put(accId,defaultContact);
            }
        }

        if(accIdConNameMap.size()>0){
            contactsByNameList = [SELECT Id,Name,pse__Salesforce_User__c,pse__Salesforce_User__r.IsActive 
                                    FROM Contact
                                    WHERE Name IN : accIdConNameMap.values()];         
        }

        if(contactsByNameList.size()>0){
            for(Id accId : accIdConNameMap.keySet()){
                for(Contact conRec : contactsByNameList){
                    String conName = accIdConNameMap.get(accId);
                    // no need to check if the default contact has as Active User Account - Confirmed by BA.
                    if(conRec.Name == conName && !accIdConIdMap.containsKey(accId)){ /** T02 - PSA-863 :Populate correct Project Manager on Interlock projects**/
                        accIdConIdMap.put(accId,conRec.Id);
                    }
                }
            }
        }
        if(accIdConIdMap.size()>0){
            for(Id accId : accIdConIdMap.keySet()){
                for(Id interLockId : ilAccMap.keySet()){
                    Id accIdFromIL = ilAccMap.get(interLockId);
                    if(accIdFromIL == accId){
                        Id conId = accIdConIdMap.get(accId);
                        interLockPMContactMap.put(interLockId,conId);
                    }
                }
            }
        }           
        return interLockPMContactMap;
    }

    public List<Account> getAccountRecById(Set<Id> accIds){  
        return [SELECT Id,Name,Geo__c,(SELECT Id,AccountId,RoleInTerritory2,Territory2Id,UserId FROM AccountUserTerritory2Views)
                FROM Account 
                WHERE Id IN:accIds];
    }
}