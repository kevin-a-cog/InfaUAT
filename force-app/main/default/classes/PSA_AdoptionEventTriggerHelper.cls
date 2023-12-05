/*
@created by       : RANJAN KISHORE
@created on       : 02/12/2021
@Purpose          : Helper class for PSA_AdoptionEventTriggerHandler.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class PSA_AdoptionEventTriggerHelper {

    
    /**
     * this method is invoked on Before Insert to populate Adoption Event fields.
     *
     * @param lstNew - list of new Projects
     * @return return-void
     * @throws exception - NA
    */
    public void defaultAdoptionEvtFieldsValOnInsert(List<Adoption_Event__c> newList){
        
        Set<Id> projectIds = new Set<Id>();
        for(Adoption_Event__c adoptEvtRec : newList){
            projectIds.add(adoptEvtRec.PSA_PM_Project__c);
            
        }
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([Select Id,pse__Account__c,Name from pse__Proj__c where Id=:projectIds]);
    
        if(projMap!=null && !projMap.keySet().isEmpty()){
            
            for(Adoption_Event__c adoptEvtRec : newList){
                if(projMap.containsKey(adoptEvtRec.PSA_PM_Project__c)){
                    adoptEvtRec.PSA_PM_Customer__c = projMap.get(adoptEvtRec.PSA_PM_Project__c).pse__Account__c;
                    if(String.isBlank(adoptEvtRec.Adoption_Event_Name__c)){
                      adoptEvtRec.Adoption_Event_Name__c=projMap.get(adoptEvtRec.PSA_PM_Project__c).Name;  
                    }
                }
            } 
        }
   
    
    }
}