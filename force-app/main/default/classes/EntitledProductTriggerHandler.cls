/*
Class:          EntitledProductTriggerHandler 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Handler Class for Entitled Product Triggers
****************************************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                                                     TAG
****************************************************************************************************
Vignesh D        I2RT-4972     Exclude creating temp assets when override entitlement is true  T01
*/


public class EntitledProductTriggerHandler {

    public static void handleEntitledProductAfterInsert( List<Entitled_Product__c> lstNew) {

        List<Entitled_Product__c> lstEPtoCreateAssets = new List<Entitled_Product__c>();
        set<Id> setEntitledProductToRecalculate = new set<Id>();
        set<Id> setSupportAccountsToRecalculate = new set<Id>();

        //New Temporary Proucts
        for(Entitled_Product__c ep : lstNew){

            if(ep.Manual_Creation_override__c && !ep.Override_Entitlement_Date__c){
                lstEPtoCreateAssets.add(ep);
                setEntitledProductToRecalculate.add(ep.Id);
                setSupportAccountsToRecalculate.add(ep.Support_Account__c);
            }
        }

        //create/update assets
        if(lstEPtoCreateAssets?.size()>0){
            AssetService.upsertTemporaryAssets(lstEPtoCreateAssets);
        }

         //Rollup Support Level on Entitled Products 
         if(setEntitledProductToRecalculate?.size()>0){
            EntitledProductService.updateEntitledProducts(setEntitledProductToRecalculate);
        }

        //Rollup Support Level on Account in future call
        if(setSupportAccountsToRecalculate?.size()>0){

            if(!System.isFuture() && !system.isBatch() && !Test.IsRunningTest()){
                SupportAccountService.updateSupportAccountsFuture(setSupportAccountsToRecalculate);
            }
            else{
                SupportAccountService.updateSupportAccounts(setSupportAccountsToRecalculate);
            }
        }
    }

    public static void handleEntitledProductAfterUpdate( List<Entitled_Product__c> lstNew, Map<id,Entitled_Product__c> oldMap) {

        List<Entitled_Product__c> lstEPtoUpdateAssets = new List<Entitled_Product__c>();
        set<Id> setEntitledProductToRecalculate = new set<Id>();
        set<Id> setSupportAccountsToRecalculate = new set<Id>();

        for(Entitled_Product__c ep : lstNew){
            //Override Entitled Products
            if( ep.Override_Entitlement_Date__c && ep.End_Date__c != oldMap.get(ep.id).End_Date__c){
                setSupportAccountsToRecalculate.add(ep.Support_Account__c);
            }
            //Override Temporary Products
            if( ep.Manual_Creation_override__c && !ep.Override_Entitlement_Date__c && ep.End_Date__c != oldMap.get(ep.id).End_Date__c){ // <T01>
                lstEPtoUpdateAssets.add(ep);
                setEntitledProductToRecalculate.add(ep.Id);
                setSupportAccountsToRecalculate.add(ep.Support_Account__c);
            }
        }

        //Create/Update Assets
        if(lstEPtoUpdateAssets?.size()>0){
            AssetService.upsertTemporaryAssets(lstEPtoUpdateAssets);
        }

        //Rollup Support Level on Entitled Products 
        if(setEntitledProductToRecalculate?.size()>0){
            EntitledProductService.updateEntitledProducts(setEntitledProductToRecalculate);
        }

        //Rollup Support Level on Account
        if(setSupportAccountsToRecalculate?.size()>0){

            if(!System.isFuture() && !system.isBatch() && !Test.IsRunningTest()){
                SupportAccountService.updateSupportAccountsFuture(setSupportAccountsToRecalculate);
            }
            else{
                SupportAccountService.updateSupportAccounts(setSupportAccountsToRecalculate);
            }
        }
        
    }


}