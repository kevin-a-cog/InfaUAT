/*
@created by       : MAHESH GANTI
@created on       : 10/30/2020
@Purpose          : Helper Class to handle Event Trigger Logic related to PSA object.
@Testclass        : 
@JIRA             : 
*/
public class psa_pm_EventTriggerHelper {
    
    /**
    * Method to check if for Milestone record Events.
    *
    * @param List<events>
    * @return return-void
    * @throws exception - NA
    */
    public static void  checkForMilestoneRecsOnEventInsert(List<Event> eventRecList){
        
        system.debug('**ETH-eventRecList**'+eventRecList);
        Set<Id> mileIdSet = new Set<Id>();
        List<Event> evenRecsToProcess = new List<Event>();
        String milekeyPreFix = pse__Milestone__c.sobjecttype.getDescribe().getKeyPrefix();
        system.debug('*ETH-milekeyPreFix**________'+milekeyPreFix);
        if(milekeyPreFix <> null || milekeyPreFix <> ''){
            for(Event eveRec : eventRecList){  
                if(eveRec.whatId <> null){  
                    String parentIdString = eveRec.whatId;
                    system.debug('**ETH-parentIdString**'+parentIdString);
                    if(parentIdString.substring(0,3).equals(milekeyPreFix)){
                        mileIdSet.add(eveRec.whatId);
                        evenRecsToProcess.add(eveRec);
                    }
                }
            }
        }
        system.debug('**ETH-mileIdSet**'+mileIdSet);
        system.debug('**ETH-evenRecsToProcess**'+evenRecsToProcess);
        if(mileIdSet.size()>0){
            updatePSEMilestoneRecsOnEventInsert(mileIdSet,evenRecsToProcess);
        }

    }
    /**
    * Method to update milestone record based on related Event creation.
    *
    * @param Set<MilestoneIds>, List<events>
    * @return return-void
    * @throws exception - NA
    */
    
    public static void  updatePSEMilestoneRecsOnEventInsert(Set<Id> mileIdSet,List<Event> eventRecList){

        List<pse__Milestone__c> mileRecsToUpdate = new List<pse__Milestone__c>();
        Map<Id,pse__Milestone__c> milestoneMap = new Map<Id,pse__Milestone__c>([SELECT Id,Name,pse__Project__c,pse__Project__r.pse__Project_Manager__c, 
                                                                                psa_pm_Last_Event_Created_Date__c,psa_pm_Last_Event_URL__c, psa_pm_Last_Event_Start_Date__c,
                                                                                psa_pm_Last_Event_End_Date__c,psa_pm_Last_Event_Description__c,psa_pm_Project_manager_contact__c
                                                                                FROM pse__Milestone__c WHERE Id IN :mileIdSet]);

        system.debug('**ETH-milestoneMap**'+milestoneMap);
        if(milestoneMap.size()>0){
            for(Event eventRec : eventRecList){      
                if(milestoneMap.containsKey(eventRec.WhatId)){
                    pse__Milestone__c milRec = milestoneMap.get(eventRec.WhatId);
                    milRec.psa_pm_Last_Event_Created_Date__c = System.now();
                    milRec.psa_pm_Last_Event_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+eventRec.Id;
                    if(eventRec.StartDateTime <> null){
                        milRec.psa_pm_Last_Event_Start_Date__c = eventRec.StartDateTime;
                    }
                    if(eventRec.EndDateTime <> null){
                        milRec.psa_pm_Last_Event_End_Date__c = eventRec.EndDateTime;
                    }
                    if(eventRec.Description <> null){
                        milRec.psa_pm_Last_Event_Description__c= eventRec.Description;
                    }
                    if(milRec.pse__Project__r.pse__Project_Manager__c <> null){
                        milRec.psa_pm_Project_manager_contact__c = milRec.pse__Project__r.pse__Project_Manager__c;
                    } 
                    /** 
                    if(eventRec.Owner_Name__c <> null){
                    milRec.psa_pm_Last_Event_Assigned_to_Name__c= eventRec.Owner_Name__c;
                    }
                    */
                    mileRecsToUpdate.add(milRec);
                }         
            }
        }
        system.debug('**ETH-mileRecsToUpdate**'+mileRecsToUpdate);
        if(mileRecsToUpdate.size()>0){
            update mileRecsToUpdate;
        }


    }
}