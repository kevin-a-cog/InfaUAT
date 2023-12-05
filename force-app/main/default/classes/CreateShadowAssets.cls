/*
Class:          CreateShadowAssets 
@Author:        Pavithra V
@Created Date:  25 June 2021
@Description:   Batch class for Creating Shadow Assets

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
   
*/
public class CreateShadowAssets {

    public static void handleShadowAssets(Set<Id> assetIdSet){
        Map<Id,List<Asset>> orderItemAssetMap = new Map<Id,List<Asset>>();
        List<Asset> lstInsertClonedAssets = new List<Asset>();
        List<Entitlement> lstInsertClonedEntlments = new List<Entitlement>();
        List<AssetRelationship> lstInsertAssetRelationship = new List<AssetRelationship>();
        
        List<Asset> assetList = [Select Id, Name,Quantity, Status, InstallDate, SBQQ__QuoteLine__c, SBQQ__OrderProduct__c,Original_Order_Product__c,
                                 SBQQ__CurrentSubscription__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,
                                 Product2Id,AccountId,AssetServicedById
                                 from Asset where Id in:assetIdSet and SBQQ__OrderProduct__r.Product2.License_Generation__c = 'Production'];
        
        for(Asset a: assetList){           
            
            if(orderItemAssetMap.containsKey(a.SBQQ__OrderProduct__c)){
                List<Asset> tempList = orderItemAssetMap.get(a.SBQQ__OrderProduct__c);
                tempList.add(a);
                orderItemAssetMap.put(a.SBQQ__OrderProduct__c,tempList);
            }else{
                orderItemAssetMap.put(a.SBQQ__OrderProduct__c,new List<Asset>{a});
            }
        }
        
        List<OrderItem> orderProducts = [Select Id, Product2.License_Screen_Type__c, Product2.License_Generation__c,SBQQ__RequiredBy__r.Product2.License_Screen_Type__c,SBQQ__RequiredBy__r.Product2.License_Generation__c,
                                            (Select Id,Fullfillment_Line__r.License_Screen_Type2__c,Fullfillment_Line__c,Fullfillment_Line__r.License_Generation__c,Order_Product__c,Fullfillment_Line__r.Parent_ID__c
                                            from Related_Fullfillment_Lines__r where Fullfillment_Line__r.Fullfillment__r.Active__c = true) 
                                            from OrderItem where Id IN :orderItemAssetMap.keySet()];
        for(OrderItem op: orderProducts){
            for(Related_Fulfillment_Line__c relatedFFline : op.Related_Fullfillment_Lines__r){
                if(relatedFFline.Fullfillment_Line__r.Parent_ID__c <> null){
                    for(Asset asset : orderItemAssetMap.get(op.Id)){
                        Asset cloneasset = asset.clone();
                        cloneasset.ParentId = asset.id;
                        //cloneasset.SBQQ__CurrentSubscription__c = null;
                        cloneasset.Fulfillment_Id__c = relatedFFline.Fullfillment_Line__c;
                        lstInsertClonedAssets.add(CloneAsset);
                    }
                }                
            }
        }
        
        if(lstInsertClonedAssets<> null && lstInsertClonedAssets.size() >0){
            
            Set<Id> shadowAssetIdSet = new Set<Id>();
            Map<String,String> shadowAssetParentAssetMap = new Map<String,String>();
			Map<String,List<Entitlement>> AssetEntitlementMap = new Map<String,List<Entitlement>>();
            
			Database.SaveResult[] srList = Database.insert(lstInsertClonedAssets, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    shadowAssetIdSet.add(sr.getId());
                }
            }
			
            List<Asset> shadowAssetlist = [Select Id,Name,Quantity,Status,ParentId,SBQQ__SubscriptionEndDate__c from Asset where Id in:shadowAssetIdSet];
            for(Asset a : shadowAssetlist){
                
                AssetRelationship ar = new AssetRelationship();
                ar.AssetId = a.Id;
                ar.FromDate= System.now();
                ar.ToDate= a.SBQQ__SubscriptionEndDate__c;
                ar.RelatedAssetId =a.ParentId;
                ar.RelationshipType ='Shadow';
                lstInsertAssetRelationship.add(ar);
                
                shadowAssetParentAssetMap.put(a.Id,a.ParentId);
            }
			
			List<Entitlement> parentEntitlementList = [Select id, name, AccountId,StartDate,EndDate,Order_Product__c,Subscription__c,Assetid,SlaProcessId,Support_Level__c,BusinessHoursId,CasesPerEntitlement,ContractLineItemId,CurrencyIsoCode,RemainingCases,ServiceContractId from Entitlement where AssetId in:shadowAssetParentAssetMap.values()];    
            if(parentEntitlementList<> null && parentEntitlementList.size() >0){
                
                for(Entitlement en : parentEntitlementList){
                    if(!AssetEntitlementMap.containsKey(en.AssetId)){
                        AssetEntitlementMap.put(en.AssetId,new List<Entitlement>{en});
                    }else{
                        List<Entitlement> tempList = AssetEntitlementMap.get(en.AssetId);
                        tempList.add(en);
                        AssetEntitlementMap.put(en.AssetId,tempList);
                    }
                }
            }
            
            for(Asset a : shadowAssetlist){
                for(Entitlement ent : AssetEntitlementMap.get(shadowAssetParentAssetMap.get(a.Id))){
                    Entitlement cloneEntitlement = ent.clone();
                    //cloneEntitlement.Subscription__c = null;
					cloneEntitlement.AssetId = a.Id;
                    lstInsertClonedEntlments.add(cloneEntitlement);
                }
            }
            
            if(lstInsertClonedEntlments <> null && lstInsertClonedEntlments.size()>0){
                insert lstInsertClonedEntlments;
            }
            
            if(lstInsertAssetRelationship <> null && lstInsertAssetRelationship.size()>0){
                insert lstInsertAssetRelationship;
            }
			      
        }
        
        
    }
}