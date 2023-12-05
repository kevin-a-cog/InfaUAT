/*
@created by       : Mahesh
@created on       : 02/17/2022
@Purpose          : Helper class for CSMAdoptionEventTriggerHandler.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class CSMAdoptionEventTriggerHelper {
    public void populateEngagement(List<Adoption_Event__c> newList){
        try{
            Set<Id> projectIds = new Set<Id>();
            for(Adoption_Event__c adoptEvtRec : newList){
                projectIds.add(adoptEvtRec.PSA_PM_Project__c);
            }
            if(!projectIds.isEmpty()){
                Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([Select Id,psa_pm_Engagement__c from pse__Proj__c where Id=:projectIds]);
                if(projMap!=null && !projMap.keySet().isEmpty()){
                    
                    for(Adoption_Event__c adoptEvtRec : newList){
                        if(projMap.containsKey(adoptEvtRec.PSA_PM_Project__c)){
                            if(projMap.get(adoptEvtRec.PSA_PM_Project__c).psa_pm_Engagement__c!=null){
                                adoptEvtRec.Engagement__c=projMap.get(adoptEvtRec.PSA_PM_Project__c).psa_pm_Engagement__c;
                            }
                            
                        }
                    } 
                }
            }
        }catch(Exception e){
            
        }
        
    }
}