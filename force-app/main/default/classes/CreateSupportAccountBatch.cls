/*
Class:          CreateSupportAccountBatch 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Batch class for creating support account and entitlement product
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


global with sharing class CreateSupportAccountBatch implements Database.Batchable<sObject>{

    global static globalApexManager GAM = new globalApexManager();

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,AccountId,Product2.Edition__c,Support_Account__c,Account.Name,Account.BillingCountry,Account.BillingState,Account.BillingCity,Account.BillingStreet, Account.CurrencyIsoCode,AssetServicedById,Product2Id,SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.Business_Model__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.ShipToContactId,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.EndUserContact__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Entitled_Product__c from Asset where  Product2Id!=null and (SBQQ__SubscriptionEndDate__c >= TODAY OR SBQQ__SubscriptionEndDate__c = null) and '+Label.GCSSupportAccountBatchFilter+' order by SBQQ__CurrentSubscription__r.SBQQ__Contract__c ';
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Asset> scope)
    {
        List<Asset> lstCreateSupportAccount = new List<Asset>();
        Set<Id> SetCreateEntitledProduct = new Set<Id>();

        for (Asset a : scope){
            system.debug('Scope a'+a);
            if(String.isBlank( a.Support_Account__c)){
                lstCreateSupportAccount.add(a);
            }else{
                SetCreateEntitledProduct.add(a.id);
            }
        }
        System.debug('lstCreateSupportAccount'+lstCreateSupportAccount);
        System.debug('SetCreateEntitledProduct'+SetCreateEntitledProduct);
        
        //Update Support Account and EP
        if(lstCreateSupportAccount!= null && lstCreateSupportAccount.size()>0)
           CreateSupportAccountBatchHandler.CreateSupportAccounts(lstCreateSupportAccount);

        //Update EP
        if(SetCreateEntitledProduct != null && SetCreateEntitledProduct.size()>0)  
           EntitledProductService.createEntitledProducts(SetCreateEntitledProduct, null);

        
    }

    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('CreateSupportAccountBatch--> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }

}