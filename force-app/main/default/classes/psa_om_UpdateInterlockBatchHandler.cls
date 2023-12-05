/*
Class:          psa_om_UpdateInterlockBatchHandler
@Author:        MAHESH GANTI
@Created Date:  25 NOVEMBER 2020
@Description:   Batch Handler class to Handle InterlockBatch actions
*******************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                             Jira No.        Tag
*******************************************************************************************************************************
Pavithra V      09-Dec-2021     Cosmos     To sync the project details to IPS Jumpstart Engagement          AR-1584         T1
*/
public without sharing class psa_om_UpdateInterlockBatchHandler {
    
    /** <T1> - Commented the method updateInterLockRecs as part of AR-1584 - Start**/
    /**
    * Method to update PSA-Project data on the related Interlock records.
    * @param lstNew - list of new events
    * @return return-void
    * @throws exception - NA
    */
    /**
     public static void updateInterLockRecs(Set<Id> ilRecSet){
        system.debug('**UIBH-ilRecSet**________'+ilRecSet);

        List<Related_Opportunity_Plan__c> interLocksToUpdateList = new List<Related_Opportunity_Plan__c>();
        Map<Id,Related_Opportunity_Plan__c> baseInterlockMap = new Map<Id,Related_Opportunity_Plan__c>([SELECT Id,Name,Interlock_Type__c, Expected_Start_Date__c,Project_Name__c,Proposed_Engagement_Date__c,Project_End_Date__c,                                                                                                       
                                                                                                            Engagement_Stage__c,Engagement_Status__c,IPS_Package__c,Project_Manager_Owner__c,Proj_Engagement_Type__c,Date_of_First_Value__c
                                                                                                            FROM Related_Opportunity_Plan__c
                                                                                                            WHERE Id IN :ilRecSet]);
        
        system.debug('**UIBH-baseInterlockMap**________'+baseInterlockMap); 
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([SELECT Id,Name,psa_om_Interlock__c,pse__Stage__c,pse__Project_Status__c,psa_pm_Date_of_First_Value__c,psa_om_Estimated_Begin_Date__c,
                                                                pse__Project_Manager__c,pse__Project_Manager__r.Name,pse__Start_Date__c,pse__End_Date__c,psa_pm_Engagement_Type__c,psa_pm_Project_Sub_Type__c
                                                                FROM pse__Proj__c
                                                                WHERE psa_om_Interlock__c IN :ilRecSet]);
        
        system.debug('**UIBH-projMap**________'+projMap);

        if(projMap.size()>0 && baseInterlockMap.size()>0){
            for(pse__Proj__c projRec : projMap.values()){
                if(baseInterlockMap.containsKey(projRec.psa_om_Interlock__c)){
                    Related_Opportunity_Plan__c ilRec = baseInterlockMap.get(projRec.psa_om_Interlock__c);
                    ilRec.Project_Name__c = projRec.Name;
                    //ilRec.Expected_Start_Date__c = projRec.psa_om_Estimated_Begin_Date__c;Not needed confimed by Sarojini.
                    ilRec.Engagement_Stage__c = projRec.pse__Stage__c;
                    ilRec.Engagement_Status__c = projRec.pse__Project_Status__c;
                    //ilRec.IPS_Package__c = Not needed confimed by Sarojini.
                    ilRec.Project_Manager_Owner__c = projRec.pse__Project_Manager__r.Name;
                    ilRec.Proposed_Engagement_Date__c = projRec.pse__Start_Date__c;
                    //ilRec.Proj_Engagement_Type__c = projRec.psa_pm_Engagement_Type__c;
                    ilRec.Proj_Engagement_Type__c = projRec.psa_pm_Project_Sub_Type__c;
                    ilRec.Date_of_First_Value__c = projRec.psa_pm_Date_of_First_Value__c;
                    ilRec.Project_End_Date__c = projRec.pse__End_Date__c;
                    interLocksToUpdateList.add(ilRec);
                }    
            }
        }

        system.debug('**UIBH-interLocksToUpdateList**________'+interLocksToUpdateList);
        if(interLocksToUpdateList.size()>0){
            update interLocksToUpdateList;
        }
        
    }
	**/
    /** <T1> - Commented the method updateInterLockRecs as part of AR-1584 - Ends **/
    
    /** <T1> - To Update the Engagement Records as part of AR-1584 **/
    public static void updateEngagementRecs(Set<Id> engagementIdSet){
        system.debug('**EngagementId**________'+engagementIdSet);

        //List<Engagement__c> engagementsToUpdateList = new List<Engagement__c>();
        Map<Id,Engagement__c> engagementsToUpdateMap = new Map<Id,Engagement__c>();
        //Interlock_Type__c,Expected_Start_Date__c,Proposed_Engagement_Date__c,Engagement_Stage__c,Engagement_Status__c,IPS_Package__c,Proj_Engagement_Type__c
        Map<Id,Engagement__c> baseEngagementMap = new Map<Id,Engagement__c>([SELECT Id,Name,Project_Name__c,IPSProject_End_Date__c,IPS_Project_Manager__c,Date_of_First_Value__c,
                                                                            Project_Status__c,IPS_Package__c,Estimated_Start_Date__c,Project_Type__c,Stage__c,IPSProject_Start_Date__c,Project_Notes__c
                                                                            FROM Engagement__c WHERE Id IN :engagementIdSet]);
        system.debug('**UIBH-baseEngagementMap**________'+baseEngagementMap);
        
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([SELECT Id,Name,psa_pm_Engagement__c,pse__Stage__c,pse__Project_Status__c,psa_pm_Date_of_First_Value__c,psa_om_Estimated_Begin_Date__c,psa_pm_Portfolio_Manager__r.Name,
                                                                pse__Project_Manager__c,PSA_OM_IPS_Package__c,pse__Project_Manager__r.Name,pse__Start_Date__c,pse__End_Date__c,psa_pm_Engagement_Type__c,psa_pm_Project_Sub_Type__c,pse__Project_Type__c,psa_pm_Project_Notes__c
                                                                FROM pse__Proj__c
                                                                WHERE psa_pm_Engagement__c IN :engagementIdSet]);
        
        system.debug('**UIBH-projMap**________'+projMap);

        if(projMap.size()>0 && baseEngagementMap.size()>0){
            for(pse__Proj__c projRec : projMap.values()){
                if(baseEngagementMap.containsKey(projRec.psa_pm_Engagement__c)){
                    Engagement__c engRec = baseEngagementMap.get(projRec.psa_pm_Engagement__c);
                    engRec.Project_Name__c = projRec.Name;
                    engRec.IPS_Project__c = projRec.Id;
                    engRec.Stage__c = projRec.pse__Stage__c;
                    engRec.Project_Status__c = projRec.pse__Project_Status__c;
                    engRec.IPS_Project_Manager__c = projRec.pse__Project_Manager__r.Name;
                    engRec.Project_Manager__c = projRec.pse__Project_Manager__c;
                    engRec.Portfolio_Manager__c = projRec.psa_pm_Portfolio_Manager__r.Name;
                    engRec.Project_Notes__c = projRec.psa_pm_Project_Notes__c;
                    //engRec.Estimated_Start_Date__c = projRec.psa_om_Estimated_Begin_Date__c;
                    //engRec.IPS_Package__c = projRec.PSA_OM_IPS_Package__c;
                    engRec.Date_of_First_Value__c = projRec.psa_pm_Date_of_First_Value__c;
                    engRec.IPSProject_Start_Date__c = projRec.pse__Start_Date__c;
                    engRec.IPSProject_End_Date__c = projRec.pse__End_Date__c;
                    engRec.Project_Type__c = projRec.pse__Project_Type__c;
                    if( projRec.pse__Stage__c == 'Completed'){
                         engRec.Status__c = 'Completed';
                    }else if(projRec.pse__Stage__c == 'Canceled' || projRec.pse__Stage__c == 'Cancelled'){
                        engRec.Status__c = 'Cancelled';
                    }
                    
                    engagementsToUpdateMap.put(projRec.psa_pm_Engagement__c,engRec);                  
                }    
            }
        }

        system.debug('**UIBH-engagementsToUpdateList**________'+engagementsToUpdateMap.values());
        if(engagementsToUpdateMap.values().size()>0){
            update engagementsToUpdateMap.values();
        }
        
    }
}