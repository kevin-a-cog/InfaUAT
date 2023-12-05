/*
* Class :        CSMAutomatePlanProducts
* Author:        Pavithra V
* Created Date:  15 Nov 2021
* Description:   Class for Automate Plan Products

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/
public class CSMAutomatePlanProducts {
    
    public static globalApexManager GAM = new globalApexManager();
    public static Id InterlockRecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();
    
    public static Map<Id,Related_Opportunity_Plan__c> getPlanIdFromInterlock(Set<Id> originalOpptyIdSet){
        Map<Id,Related_Opportunity_Plan__c> opptyToPlanMap = new Map<Id,Related_Opportunity_Plan__c>(); 
        
        for(Related_Opportunity_Plan__c interlock : [Select Id ,Original_Opportunity__c,Plan__c from Related_Opportunity_Plan__c where Original_Opportunity__c in :originalOpptyIdSet and Is_Automated__c = false and RecordTypeId =: InterlockRecordTypeId and Plan__c <> null order by CreatedDate asc]){
            opptyToPlanMap.put(interlock.Original_Opportunity__c ,interlock);
        }
        return opptyToPlanMap;
    }
    
    public static void associatePlanToPlanProducts(Set<Id> newPlanProductIdSet){
        
        Set<Id> originalOpptyIdSet = new Set<Id>();
        Map<Id,Related_Opportunity_Plan__c> opptyToPlanMap = new Map<Id,Related_Opportunity_Plan__c>();
        List <Related_Account_Plan__c> lstUpdatePlanProducts = new List<Related_Account_Plan__c>();
        List <Related_Opportunity_Plan__c> lstUpdateInterlocks = new List<Related_Opportunity_Plan__c>();
        
       Map<Id,Id> interlockToContractMap = new Map<Id,Id>();
        
        //List of offering types to automate Plan Products <T01>
        List<string> lAutomatePlanProdOfferingTypes = new List<String>();
        lAutomatePlanProdOfferingTypes= Label.CSMAutomatePlanProdOfferingTypes.split(';');
        
        for(Related_Account_Plan__c planproduct : [Select id,Account_plan__c,Unassigned_Contract__c,Account__c,Opportunity__c,Contract__c, Contract__r.SBQQ__Opportunity__c,Forecast_Product__c,Offering_Type__c,Delivery_Method__c,Pricing_Business_Model__c from Related_Account_Plan__c where Id in:newPlanProductIdSet]){
            if(planproduct.Contract__r.SBQQ__Opportunity__c <> null && lAutomatePlanProdOfferingTypes.contains(planproduct.Offering_Type__c)){
                originalOpptyIdSet.add(planproduct.Contract__r.SBQQ__Opportunity__c);
            }
        }
        
        if(originalOpptyIdSet?.size()>0){
            opptyToPlanMap = CSMAutomatePlanProducts.getPlanIdFromInterlock(originalOpptyIdSet);
        }
        
        if(opptyToPlanMap <> null){
            for(Related_Account_Plan__c planproduct : [Select id,Account_plan__c,Unassigned_Contract__c,Account__c,Opportunity__c,Contract__c, Contract__r.SBQQ__Opportunity__c,Forecast_Product__c,Offering_Type__c,Delivery_Method__c,Pricing_Business_Model__c from Related_Account_Plan__c where Id in:newPlanProductIdSet]){
                if(planproduct.Contract__r.SBQQ__Opportunity__c <> null && opptyToPlanMap.get(planproduct.Contract__r.SBQQ__Opportunity__c) <> null && opptyToPlanMap.get(planproduct.Contract__r.SBQQ__Opportunity__c).Plan__c <> null && lAutomatePlanProdOfferingTypes.contains(planproduct.Offering_Type__c)){
                    planproduct.Account_plan__c = opptyToPlanMap.get(planproduct.Contract__r.SBQQ__Opportunity__c).Plan__c;
                    lstUpdatePlanProducts.add(planproduct);
                    
                    interlockToContractMap.put(opptyToPlanMap.get(planproduct.Contract__r.SBQQ__Opportunity__c).Id,planproduct.Contract__c);
                }
            }
        }
        
        
        
        if(interlockToContractMap <> null){
            Map<Id,Contract> mapContracts= new Map<Id,Contract>([select id,AccountId,SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c from contract where id in :interlockToContractMap.values()]);
        
            for(Id interlockId :interlockToContractMap.keySet()){
                Related_Opportunity_Plan__c interlock = new Related_Opportunity_Plan__c();
                interlock.Id = interlockId;
                interlock.Contract__c = interlockToContractMap.get(interlockId);
                if(interlockToContractMap.get(interlockId) <> null){
                    interlock.Opportunity__c = mapContracts.get(interlockToContractMap.get(interlockId)).SBQQ__RenewalOpportunity__c;
                }
                lstUpdateInterlocks.add(interlock);                
            }
            
            if(lstUpdateInterlocks?.size()>0){
                Database.SaveResult[] srList = Database.update(lstUpdateInterlocks, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()){
                        // Operation failed, so get all errors  
                        system.debug('**Operation failed');              
                        for(Database.Error err : sr.getErrors()) {					
                            GAM.CreateExceptionRecords('CSMAutomatePlanProducts-->associatePlanToPlanProducts-->update of Interlcok failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }
        
        if(lstUpdatePlanProducts?.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdatePlanProducts, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    system.debug('**Operation failed');              
                    for(Database.Error err : sr.getErrors()) {					
                        GAM.CreateExceptionRecords('CSMAutomatePlanProducts-->associatePlanToPlanProducts-->update of Plan products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
    }
}