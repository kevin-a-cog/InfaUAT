/*
Class:          AssetService 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Service Class for Assets
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


public class AssetService {

    public static final String TEMP_SUPPORT = 'Temporary Support';
    
    public static void  upsertTemporaryAssets(List<Entitled_Product__c> lstEntitledProducts){

        globalApexManager GAM = new globalApexManager();

        Map<Id,Entitled_Product__c> mapEntitledProducts = new Map<Id,Entitled_Product__c>(lstEntitledProducts);
        map<id,id> mapTempEPAsset= new Map<Id,Id>();
        map<id,Entitlement> mapTempEPEntitlement= new Map<Id,Entitlement>();
        List<Asset> lstUpsertAssets = new List<Asset>();
        Set<Id> setNewAssets = new set<id>();
        List<Entitlement> lstUpsertEnt = new List<Entitlement>();

        
        //Get the Asset & Entitlement if present
        for(Entitlement ent : [Select id,AssetId,StartDate,EndDate, Asset.Entitled_Product__c,Asset.SBQQ__SubscriptionEndDate__c,Asset.SBQQ__SubscriptionStartDate__c from Entitlement  where Asset.Entitled_Product__c = :mapEntitledProducts.keyset() ]){
            mapTempEPEntitlement.put(ent.Asset.Entitled_Product__c, ent);
        }



         for(Entitled_Product__c EP : lstEntitledProducts){

            //Update existing temporary asset & entitlement
            if(mapTempEPEntitlement.containskey(EP.id)){
                Asset updateAsset= new Asset(id = mapTempEPEntitlement?.get(EP.id)?.AssetId);
                if(mapTempEPEntitlement?.get(EP.id)?.Asset?.SBQQ__SubscriptionStartDate__c > EP.End_Date__c){
                    updateAsset.SBQQ__SubscriptionStartDate__c= EP.End_Date__c;
                }
                updateAsset.SBQQ__SubscriptionEndDate__c= EP.End_Date__c ;
                lstUpsertAssets.add(updateAsset);
                

                Entitlement updateEnt = new Entitlement(id = mapTempEPEntitlement?.get(EP.id)?.id);
                if(mapTempEPEntitlement?.get(EP.id)?.Startdate >EP.End_Date__c){
                    updateEnt.Startdate = EP.End_Date__c;
                }
                updateEnt.EndDate = EP.End_Date__c;
                lstUpsertEnt.add(updateEnt);
            }
            //create new temporary asset
            else if (EP.End_Date__c>= System.today()){
                Asset newAsset= new Asset();
                newAsset.Name = EP.Name;
                newAsset.Entitled_Product__c = EP.Id;
                newAsset.Support_Account__c= EP.Support_Account__c;
                newAsset.AccountId= EP.Account__c;
                newAsset.SBQQ__SubscriptionStartDate__c= System.Today();
                newAsset.SBQQ__SubscriptionEndDate__c= EP.End_Date__c;
                lstUpsertAssets.add(newAsset);
            }
        }

        system.debug('lstUpsertAssets'+lstUpsertAssets);
        if(lstUpsertAssets!=null && lstUpsertAssets.size()>0){
            Database.UpsertResult[] srList = Database.upsert(lstUpsertAssets);
            for (Database.UpsertResult sr : srList) {
                if (sr.isCreated()){
                    setNewAssets.add(sr.getId());
                }
                else if(!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('AssetService-->createTemporaryAssets-->upsert of temporary assets failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        //create new temporary entitlement for newly created Assets
        System.debug('setNewAssets'+setNewAssets);
        for(Asset a : [Select Id, Name, Entitled_Product__c,Support_Account__r.Success_Offering__c, Entitled_Product__r.Support_Level__c,AccountId,Support_Account__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c from Asset where id in :setNewAssets]){

            Entitlement newEnt = new Entitlement();
            if(a.Entitled_Product__r?.Support_Level__c != null){
                newEnt.Name = a.Entitled_Product__r.Support_Level__c;
            } else if(a.Support_Account__r?.Success_Offering__c != null){
                newEnt.Name = a.Support_Account__r.Success_Offering__c;
            } else {
                newEnt.Name = a.Name;
            }
            newEnt.Support_Level__c = a.Entitled_Product__r.Support_Level__c;
            newEnt.AssetId= a.Id;
            newEnt.AccountId = a.AccountId;
            newEnt.StartDate = a.SBQQ__SubscriptionStartDate__c;
            newEnt.EndDate =a.SBQQ__SubscriptionEndDate__c;
            lstUpsertEnt.add(newEnt);
        }

        System.debug('lstUpsertEnt'+lstUpsertEnt);
        if(lstUpsertEnt!=null && lstUpsertEnt.size()>0){
            Database.UpsertResult[] srList = Database.upsert(lstUpsertEnt);
            for (Database.UpsertResult sr : srList) {
                if(!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('AssetService-->createTemporaryAssets-->upsert of temporary entitlements failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

    }

}