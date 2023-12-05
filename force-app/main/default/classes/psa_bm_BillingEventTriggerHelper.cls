/*
@created by       : Vivek Warrier
@created on       : 18-Aug-2021
@Purpose          : Billing Event Trigger Helper
@Testclass        : 
@JIRA             : 

*/
/*
Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By             JIRA           Description                                                          Tag
**********************************************************************************************************************************************************

*/
public class psa_bm_BillingEventTriggerHelper{
    public void beforeInsertActions(List<pse__Billing_Event__c> newList){
        List<Id> listProjectIds = new List<Id>();
        Map<Id,Boolean> mapProjectIdtoFeesPrepaid = new Map<Id,Boolean>();
        List<pse__Billing_Event__c> listBillingEventUpdate = new List<pse__Billing_Event__c>();
        
        for(pse__Billing_Event__c be : newList){
            if(be.pse__Project__c != null){
                listProjectIds.add(be.pse__Project__c);
            }
        }
        
        for(pse__Proj__c p : [SELECT Id, psa_pm_Fees_Pre_Paid__c FROM pse__Proj__c WHERE Id IN :listProjectIds]){
            mapProjectIdtoFeesPrepaid.put(p.Id,p.psa_pm_Fees_Pre_Paid__c);
        }
        
        for(pse__Billing_Event__c be : newList){ 
            if(mapProjectIdtoFeesPrepaid.get(be.pse__Project__c) != null)
                be.psa_Fees_Prepaid__c = mapProjectIdtoFeesPrepaid.get(be.pse__Project__c);   
        }
    }
}