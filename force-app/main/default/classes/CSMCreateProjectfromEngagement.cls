/*
Class:          CSMCreateProjectfromEngagement 

****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                                              TAG
Narpavi Prabu    AR-2997       Fix the IPS project is not creating IPS engagement   <T01>
****************************************************************************
*/
public class CSMCreateProjectfromEngagement {
    public static globalApexManager GAM = new globalApexManager();
    
    @future
    public static void createIPSProject(Set<Id> engagementIdSet){
        System.debug('@Developer --> createIPSProject :' );    

        //Logic to create the Project 
        List<pse__Proj__c> projRecsToCreateList = new List<pse__Proj__c>();
        List<pse__Proj__c> projRequeryList = new List<pse__Proj__c>();
        List<Engagement__c> baseEngagementList = new List<Engagement__c>(); 
        List<Engagement__c> engagementsToUpdateList = new List<Engagement__c>();
        Map<Id,Id> EngagementAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> EngagementContactIdMap = new Map<Id,Id>();
        Id practiceRec;
        List<pse__Practice__c> practiceLst = new List<pse__Practice__c>([Select Id,Name from pse__Practice__c where Name ='Consulting Services' Limit 1]);
        if(!practiceLst.isEmpty()){
            practiceRec = practiceLst[0].Id;
        }
        System.debug('@Developer --> practiceRec :' + practiceRec);

        //Interlock_Type__c,Original_Opportunity__c,Original_Opportunity_Number_Text__c,Original_Opportunity__r.New_Org_Opportunity_Number__c
        //Partner_name_if_any__c,Comments__c,Expected_Start_Date__c,Success_Pack__c,
        Map<Id,Engagement__c> engagementMap = new Map<Id,Engagement__c>([SELECT Id,Name,Account__c,Account__r.Name,Account__r.Health_Score__c,Plan__c,Plan__r.Account__c,Plan__r.Account__r.Name,CSM_Summary__c,Plan__r.Owner.Name,
                                                                                                    CreatedById,CreatedBy.Name,IPSProject_Start_Date__c,CSM_Closing_Comments__c,Estimated_Start_Date__c,Description__c,
                                                                                                    Opportunity__c,Opportunity__r.New_Org_Opportunity_Number__c,CurrencyIsoCode,Description_of_request__c,
                                                                                                    Opportunity__r.SBQQ__RenewedContract__c,Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__c,
                                                                                                    Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c                                                                                                                                                                                                  
                                                                                                    FROM Engagement__c 
                                                                                                    WHERE Id IN :engagementIdSet]);
        
        System.debug('@Developer --> engagementMap.size :' + engagementMap.size());

        if(engagementMap.size()>0){
            for(Engagement__c objEngagement : engagementMap.values()){
                if(objEngagement.Account__c <> null){
                    EngagementAccountIdMap.put(objEngagement.Id,objEngagement.Account__c);
                }
                // only need this if the Account is not populated on Interlock rec - need to check
                if(objEngagement.Account__c == null && objEngagement.Plan__r.Account__c <> null){
                    EngagementAccountIdMap.put(objEngagement.Id,objEngagement.Plan__r.Account__c);
                }
            }
        } 
        
        if(EngagementAccountIdMap?.size()>0){
            EngagementContactIdMap = getPMContactFromAccountIds(EngagementAccountIdMap);
        }
        System.debug('@Developer --> EngagementContactIdMap :' + EngagementContactIdMap);

        System.debug('@Developer --> engagementMap :' + engagementMap);
        for(Engagement__c engagement : engagementMap.values()){
            string orgOpptyNumber;
          
            if(engagement?.Opportunity__r?.New_Org_Opportunity_Number__c <> null){
                orgOpptyNumber = engagement.Opportunity__r.New_Org_Opportunity_Number__c;
            }
            
            
            System.debug('@Developer --> orgOpptyNumber :' + orgOpptyNumber);
            // If Interlock type == jumpstart or checkup and the original opportunity is null then we dont create a project.
            if(orgOpptyNumber <> null){
                pse__Proj__c projRec = new pse__Proj__c();
                projRec.psa_pm_Engagement__c = engagement.id;
                projRec.pse__Practice__c = practiceRec;
                projRec.psa_pm_Source__c = 'Engagement';
                Integer maxiSize = 70;
                Integer accountnamesize= 55;
                //<T01> - Start - Trim the account name when the Name of project is more than 70 character
                projRec.Name = engagement.Account__r.Name+' - '+engagement.Opportunity__r.New_Org_Opportunity_Number__c + '- JS';
                if( projRec.Name.length()>maxiSize){
                    projRec.Name = engagement.Account__r.Name.substring(0,accountnamesize )+'-'+engagement.Opportunity__r.New_Org_Opportunity_Number__c + '- JS';
                }
                //</T01>- End
                projRec.psa_pm_Project_Sub_Type__c = 'JumpStart';
                projRec.pse__Opportunity__c = engagement.Opportunity__c;                    
                projRec.pse__Start_Date__c = engagement.Estimated_Start_Date__c;
                if(engagement.Estimated_Start_Date__c <> null){
                    projRec.pse__End_Date__c = engagement.Estimated_Start_Date__c.addDays(90);
                }
                projRec.pse__Stage__c = 'Planned';
                projRec.pse__Project_Status__c = 'Green';
                if(EngagementContactIdMap.containsKey(engagement.Id)){
                    projRec.pse__Project_Manager__c = EngagementContactIdMap.get(engagement.Id);
                    projRec.psa_pm_Portfolio_Manager__c = EngagementContactIdMap.get(engagement.Id);
                }
                projRec.pse__Account__c = engagement.Account__c;
                projRec.CurrencyIsoCode = engagement.CurrencyIsoCode;
                projRec.pse__Project_Type__c = 'Customer Project'; 
                projRec.psa_pm_Project_Category__c = 'Non - Billable';
                projRec.pse__Is_Active__c = true;
                projRec.psa_pm_Project_Notes__c = 'Health Score :'+engagement.Account__r.Health_Score__c+'; '+'Comments:'+engagement.Description__c+';'+'CSM: '+engagement.Plan__r.Owner.Name;
                projRecsToCreateList.add(projRec);
            }
        }
        
        System.debug('@Developer --> projRecsToCreateList.size() :' + projRecsToCreateList.size());
        if(projRecsToCreateList.size()>0){
            try{
                insert projRecsToCreateList;
            }          
            catch(Exception e){
                System.debug('@Developer --> Exception :' + e.getStackTraceString());
                system.debug('Error Message'+e.getMessage());
                GAM.CreateLogs('CLASS: CSMCreateProjectfromEngagement | METHOD: createIPSProject', projRecsToCreateList , 'projRecsToCreateList- Project Recs Creation FROM INTERLOCK');
            }
        }
        
        //Sync back the project to Engagement
        psa_om_UpdateInterlockBatchHandler.updateEngagementRecs(engagementIdSet);
    }
    
    /**
    * The  method will Fetch the corresponding Project Manager for the Project being automated from the Interlock
    * @param MAP - Map<InterlockId,AccountId>
    * @return return- Ma-<InterlockId,ContactId>
    * @throws exception - NA
    */
    public static Map<Id,Id> getPMContactFromAccountIds(Map<Id,Id> ilAccMap){
        
        Map<Id,Id> engagementPMContactMap = new Map<Id,Id>();
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

        
        List<Account> accountRecsList = new List<Account>([SELECT Id,Name,Geo__c,Area__c,(SELECT Id,AccountId,RoleInTerritory2,Territory2Id,UserId FROM AccountUserTerritory2Views)
                                                            FROM Account 
                                                            WHERE Id IN:ilAccMap.values()]);
        
        if(accountRecsList.size()>0){
            for(Account accRec : accountRecsList){
                if(accRec.Geo__c <> null || accRec.Geo__c <> '' ){
                    if(String.isNotBlank(accRec.Area__c) && accRec.Geo__c.equals('EMEA') && accRec.Area__c.equals('EMEA LATAM')){//added as part of AR-2676 ends here
                        accIdGeoMap.put(accRec.Id,accRec.Area__c);//added as part of AR-2676 ends here
                    }//added as part of AR-2676 ends here
                    else{
                        accIdGeoMap.put(accRec.Id,accRec.Geo__c);
                    }
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
                        //if(accIdGeoMap.get(accId)!=null && accPMCustomMDMap.get(accIdGeoMap.get(accId))!=null){
                            Account_Territory_Setting__mdt accGeoSettingRec = accPMCustomMDMap.get(accIdGeoMap.get(accId));                            
                            if(accGeoSettingRec!=null && accGeoSettingRec!=null &&accGeoSettingRec.User_Role__c <> null){
                                if(accGeoSettingRec.User_Role__c == usrRoleRec.RoleInTerritory2){
                                    accIdUserIdMap.put(accId,usrRoleRec.UserId);
                                }
                                if(accGeoSettingRec.User_Role__c <> usrRoleRec.RoleInTerritory2){
                                    accIdConNameMap.put(accId,accGeoSettingRec.Default_Assignee__c);
                                }
                            }
                            if(accGeoSettingRec!=null && String.isBlank(accGeoSettingRec.User_Role__c)){
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
                if(accIdGeoMap.get(accId)!=null && accPMCustomMDMap.get(accIdGeoMap.get(accId))!=null){
                    String defaultContact = accPMCustomMDMap.get(accIdGeoMap.get(accId)).Default_Assignee__c;
                    accIdConNameMap.put(accId,defaultContact);
                }
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
                for(Id engagementId : ilAccMap.keySet()){
                    Id accIdFromEng = ilAccMap.get(engagementId);
                    if(accIdFromEng == accId){
                        Id conId = accIdConIdMap.get(accId);
                        engagementPMContactMap.put(engagementId,conId);
                    }
                }
            }
        }           
        return engagementPMContactMap;
    }

}