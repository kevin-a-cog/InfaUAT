/*
* Class :        RiskIssueTriggerHandler
* Author:        Ambica P
* Created Date:  15 Aug 2020
* Description:   Handler class for Risk Triggers
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
Deva M            01-Apr-2022   N/A                             Handler class which implements interface process methods
                                                                for Trigger events on Plan Object
Narpavi P         29-Aug-2022    AR-2771                        Trigger Notification Subscription for Risk                   T01                  
********************************************************************************************************************************************

*/
public class RiskIssueTriggerHandler extends TriggerHandler {
  
    /*Depricated
    public static void handleBeforeInsert( List<Risk_Issue__c> lstNewRisks){
        validateRiskType(lstNewRisks, null);
        
        
    }
    public static void handleBeforeUpdate ( List<Risk_Issue__c> lstNewRisks, Map<Id,Risk_Issue__c> mapOldRisks){
        validateRiskType(lstNewRisks, mapOldRisks);
        
    }
    
    public static void validateRiskType( List<Risk_Issue__c> lstNewRisks, Map<Id,Risk_Issue__c> mapOldRisks){
        
        map<Risk_Issue__c,Id> mapRiskPlan = new map<Risk_Issue__c,Id>();
        set<id> setAdoptionPlanIds = new set<Id>();
        set<id> setRenewalPlanIds = new set<Id>();
        
        for(Risk_Issue__c risk : lstNewRisks){
            
            if(  risk.Plan__c!=null && (mapOldRisks==null || risk.Type__c!= mapOldRisks.get(risk.id).Type__c )){
                mapRiskPlan.put(risk,risk.Plan__c);
            }
        }
        
        for(Risk_Issue__c risk : [select Id,Status__c,Type__c,Plan__c from Risk_Issue__c where Plan__c in :mapRiskPlan.values() and Status__c='Open']){
            
            if(risk.Type__c =='Adoption'){
                setAdoptionPlanIds.add(risk.Plan__c);
            }
            else if(risk.Type__c =='Renewal'){
                setRenewalPlanIds.add(risk.Plan__c);
            }
            
        }
        
        for(Risk_Issue__c risk : mapRiskPlan.keyset()){
            
            if( risk.Type__c=='Adoption' && setAdoptionPlanIds.contains(mapRiskPlan.get(risk))){
                risk.addError('Cannot have more than one Open Adoption Risks per Plan');
            }
            
            if(risk.Type__c== 'Renewal' &&  setRenewalPlanIds.contains(mapRiskPlan.get(risk))){
                risk.addError('Cannot have more than one Open Renewal Risks per Plan');
            }        
        }
 
    }
    
    */
    private CSMRiskTriggerHelper helper = new CSMRiskTriggerHelper();
    /*
    Method Name : afterUpdate
    Description : Methods related to the module to be called in after update context
    */
    public override void afterUpdate() {   
        helper.processAfterUpdate((List<Risk_Issue__c>) newList,(Map<Id,Risk_Issue__c>) oldMap);
    }

    public override void beforeDelete() {  
        helper.processBeforeDelete((List<Risk_Issue__c>) oldList);
    } 
    //< T01> - Added to trigger notification subscription
    public override void afterInsert() {
        helper.processAfterInsert((List<Risk_Issue__c>) newList,(Map<Id, Risk_Issue__c>) oldMap);
    } 
}