public class AssetTriggerHandler {
    
       public static void handleAssetAfterUpdate(List<Asset> lstNewAssets, Map<id,Asset> mapOldAssets){

        List<Asset> lstAssetsUpdated = new List<Asset>();

        for(Asset a: lstNewAssets){
            if(a.Support_Account__c != null && a.Support_Account__c != mapOldAssets.get(a.id).Support_Account__c){
                lstAssetsUpdated.add(a);
            }
        }

        if(lstAssetsUpdated?.size()>0){
          //  EntitledProductService.createEntitledProducts(lstAssetsUpdated,mapOldAssets);
        }
    }

}