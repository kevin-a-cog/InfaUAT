/*
Class:          ManageSupportAccountAssetsController 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Controller Class for ManageSupportAccountAssets LWC
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


public with sharing class ManageSupportAccountAssetsController {

    
    @AuraEnabled
    public static List<Asset> getAssignedAssets(Id AccountId){

        System.debug('AccountId'+AccountId);
        List<Asset> lstAssignedAssets = new List<Asset>();
        try {
            lstAssignedAssets = [Select Id,Name,AccountId,Account.Name,Support_Account__c,Support_Account__r.Name,Product2Id,Product2.Name,Quantity,Org__c,SBQQ__OrderProduct__c,
                                SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.ContractNumber,
                                SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Entitled_Product__c,Entitled_Product__r.Name,Status
                                from Asset where Support_Account__c =:AccountId ];

                                System.debug('lstAssignedAssets'+lstAssignedAssets);

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return lstAssignedAssets;
    }

    @AuraEnabled
    public static List<Asset> getAllAssets(Id AccountId, Id ParentAccountId){
        List<Asset> lstAllAssets = new List<Asset>();
        try {
            lstAllAssets = [Select Id,Name,AccountId,Account.Name,Support_Account__c,Support_Account__r.Name,Product2Id,Product2.Name,Quantity,Org__c,SBQQ__OrderProduct__c,
                            SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.ContractNumber,
                            SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Entitled_Product__c,Entitled_Product__r.Name,Status
                            from Asset where Support_Account__c !=:AccountId and AccountId =:ParentAccountId and  (SBQQ__SubscriptionEndDate__c >=Today Or SBQQ__SubscriptionEndDate__c = null)];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return lstAllAssets;
    }

    @AuraEnabled
    public static void shareAssets(List<Asset> Assets, Id AccountId){

        List<Asset> lstInsertShareAssets = new List<Asset>();
        List<AssetRelationship> lstInsertAssetRelationship = new List<AssetRelationship>();
        List<Entitlement> lstInsertShareEntitlements = new List<Entitlement>();
        set<id> setNewAssetIds = new set<Id>();
        map<Id,Id> mapAssetToSharedAsset = new map<Id,Id>();
        globalApexManager GAM = new globalApexManager();
        set<Id> setSupportAccountIds = new set<Id>();
        setSupportAccountIds.add(AccountId);
        Id idNull = null;

        for(Asset a :Assets ){
            Asset newAsset = a.clone(false);
            newAsset.Support_Account__c = AccountId;
            newAsset.ParentId= a.id;
            newAsset.Entitled_Product__c = idNull; //KG
            system.debug('newAsset-->'+newAsset);
            lstInsertShareAssets.add(newAsset);
            setSupportAccountIds.add(a.Support_Account__c);
        }
        try {
            if(lstInsertShareAssets?.size()>0){
                Database.SaveResult[] srList = Database.insert(lstInsertShareAssets);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()){
                        setNewAssetIds.add(sr.getId());
                    }
                    if (!sr.isSuccess()){
                        // Operation failed, so get all errors  
                        for(Database.Error err : sr.getErrors()) {          
                            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of Assets Failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }catch (Exception e) {
            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of Assets Failed', e.getMessage(),null);
        }

        for(Asset a: [Select Id,ParentId,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Support_Account__c from asset where id in :setNewAssetIds]){
            AssetRelationship ar = new AssetRelationship();
            ar.AssetId = a.Id;
            ar.FromDate= System.now();
            ar.ToDate= a.SBQQ__SubscriptionEndDate__c;
            ar.RelatedAssetId =a.ParentId;
            ar.RelationshipType ='Shared';
            system.debug('ar-->'+ar);
            lstInsertAssetRelationship.add(ar);
            mapAssetToSharedAsset.put(a.ParentId,a.id);
        }

        try {
            if(lstInsertAssetRelationship?.size()>0){
                Database.SaveResult[] srList = Database.insert(lstInsertAssetRelationship);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {          
                            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of Assets Relationship Failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }catch (Exception e) {
            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of Assets Relationship Failed', e.getMessage(),null);
        }
        system.debug('mapAssetToSharedAsset-->'+mapAssetToSharedAsset);


        for(Entitlement ent : [Select Id,Name,AssetId,startdate,enddate,AccountId,Status,Type,Support_Level__c,
                                //Order_Product__c,Subscription__c
                                BusinessHoursId,CasesPerEntitlement,ContractLineItemId,CurrencyIsoCode,RemainingCases,ServiceContractId,SlaProcessId
                                from Entitlement where AssetId in :mapAssetToSharedAsset.keyset()]){
            Entitlement newEnt = ent.clone(false);
            newEnt.AssetId = mapAssetToSharedAsset?.get(ent.AssetId);
            system.debug('newEnt-->'+newEnt);
            lstInsertShareEntitlements.add(newEnt);                             
        }
        system.debug('lstInsertShareEntitlements-->'+lstInsertShareEntitlements);
        try {
            if(lstInsertShareEntitlements?.size()>0){
                Database.SaveResult[] srList = Database.insert(lstInsertShareEntitlements);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {          
                            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of shared asset Entitlements  Failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }catch (Exception e) {
            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->shareAssets-->insert of shared  Asset entitlements Failed', e.getMessage(),null);
        }

        //Call Future Method to Create/Update EPs on Assets
        if(setNewAssetIds?.size()>0){
        EntitledProductService.createEntitledProductsFuture(setNewAssetIds,null);
        }


    }

    @AuraEnabled
    public static void transferAssets(List<Asset> Assets, Id NewAccountId, Id OldAccountId){
        Set<id> setUpdatedAssets = new set<id>();
        Set<id> setOldAccount = new set<id>();
        List<Asset> lstUpdateTransferAssets = new List<Asset>();
        globalApexManager GAM = new globalApexManager();

        if(OldAccountId!= null){
            setOldAccount.add(OldAccountId);
        }

        for(Asset a :Assets ){
            Asset updateAsset = new Asset(Id= a.Id);
            updateAsset.Support_Account__c = NewAccountId;
            lstUpdateTransferAssets.add(updateAsset);
        }
        try {
            if(lstUpdateTransferAssets?.size()>0){
                Database.SaveResult[] srList = Database.update(lstUpdateTransferAssets);
                for (Database.SaveResult sr : srList) {
                    if(sr.issuccess()){
                        setUpdatedAssets.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors  
                        for(Database.Error err : sr.getErrors()) {          
                            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->transferAssets-->update of Assets Failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }catch (Exception e) {
            GAM.CreateExceptionRecords('ManageSupportAccountAssetsController-->transferAssets-->update of Assets Failed', e.getMessage(),null);
        }

        //Call Future Method to Create/Update EP on Assets
        if(setUpdatedAssets?.size()>0){
            EntitledProductService.createEntitledProductsFuture(setUpdatedAssets,setOldAccount);
        }

    }
}