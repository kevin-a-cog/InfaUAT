/*
Class:          ReviewAssetsOrderController
@Authors:       Lien Ly
@Created Date:  
@Description:   Controller class for Review Assets page(on button click from Order Page)
*/

/*
Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                 Tag
                                     
*************************************************************************************************
*/

/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/
public class ReviewAssetsOrderController {
    
    public string orderId {get;set;}
    public static globalApexManager GAM = new globalApexManager();
    
    //this method is called from email template to return all assets of order to be reviewed
    public List<AssetsWrapper> listAssetWrapper {
        get { listAssetWrapper = new List<AssetsWrapper>();
             if(null!=orderID)
                 listAssetWrapper=getAssetsWrapper(orderID);
             
             return listAssetWrapper;
            }
        
        private set;
    }
    
    //fetch all assets details to be reviewd for Order
    @AuraEnabled
    public static List<AssetsWrapper> getAssetsWrapper (String orderID) {
        // This component is navigated from both Quote and Order page 
        // Hence @param orderID can either be orderID or quoteID 
        Id paramID = (Id)orderID; 
        
        String sObjectName = paramID.getSobjectType().getDescribe().getName(); 
        
        List<AssetsWrapper> assetsWrapperList = new List<AssetsWrapper>(); 
        Map<Id, OrderItem> orderItemMap = new Map<Id, OrderItem>(); 
        
        // Query Order Item
        if (sObjectName == 'Order') {
            orderItemMap = new Map<Id, OrderItem>([SELECT Id, OrderId FROM OrderItem WHERE OrderId = : orderID]); 
        }
        else {
            List<Order> ol = [SELECT Id, SBQQ__Quote__r.Id FROM Order WHERE SBQQ__Quote__r.Id = : paramID]; 
            
            Set<Id> orderIDSet = new Set<Id>(); 
            
            for (Order o : ol) {
                orderIDSet.add(o.Id); 
            }
            
            orderItemMap = new Map<Id, OrderItem>([SELECT Id, OrderId FROM OrderItem WHERE OrderId = : orderID]); 
        }
        
        // Query Assets & Create Asset Wrapper List
        List<Asset> assetList = [SELECT Id, InstallDate, Name, Asset_Type__c, Asset_Identifier__c, Primary_Asset__r.Id, Primary_Asset__r.Name, SBQQ__SubscriptionStartDate__c, 
                          SBQQ__SubscriptionEndDate__c, Product2.Id, Product2.Name, SBQQ__OrderProduct__r.Id, Quantity, Status, 
                          SBQQ__CurrentSubscription__r.Id, SBQQ__CurrentSubscription__r.Name,
                          Product2.Is_Parent_Asset__c, Associated_Asset__r.Id, Associated_Asset__r.Name,Project_Number__c 
                          FROM Asset WHERE SBQQ__OrderProduct__r.Id = :orderItemMap.keySet()]; 
        
        for (Asset asset : assetList) {                
            AssetsWrapper assetsWrapper = new AssetsWrapper(asset);
            assetsWrapper.OriginSObjectName = sObjectName; 
            assetsWrapperList.add(assetsWrapper);  
        }        
        
        return assetsWrapperList; 
    }
    
    //save functionality for any change in Asset fields
    @AuraEnabled
    public static List<Object> saveAssets (String localAssetsWrappers, String orderID) {
        List<AssetsWrapper> assetsWrapperList = (List<AssetsWrapper>)System.JSON.deserialize(localAssetsWrappers,List<AssetsWrapper>.class);
        List<Object> awlServer;
        
        try {
            Set<Id> assetIds = new Set<Id>(); 
            
            for (AssetsWrapper assetsWrapper : assetsWrapperList) {
                assetIds.add(assetsWrapper.ast.Id); 
            }
            
            List<Asset> assetList = [SELECT Id, InstallDate, Asset_Identifier__c, Primary_Asset__r.Id, Status, SBQQ__OrderProduct__r.Id FROM Asset WHERE Id IN : assetIds]; 
            
            for (Asset asset : assetList) {
                for (AssetsWrapper assetsWrapper : assetsWrapperList) {
                    if (assetsWrapper.ast.Id == asset.Id) {
                        // Update Asset_Identifier__c
                        if (assetsWrapper.AssetIdentifier != '') {
                            asset.Asset_Identifier__c = assetsWrapper.AssetIdentifier; 
                        }
                        
                        // Update Primary_Asset__c
                        if (assetsWrapper.ParentAssetID != '')
                            asset.Primary_Asset__c = assetsWrapper.ParentAssetID; 
                        
                        // Update Associated_Asset_c
                        if (assetsWrapper.AssociatedAssetID != '') 
                            asset.Associated_Asset__c = assetsWrapper.AssociatedAssetID; 
                        
                        // Update Status
                        if (assetsWrapper.Status != '--None--') {
                            asset.Status = assetsWrapper.Status; 
                        }
                        else {
                            asset.Status = ''; 
                        }
                        
                        //Update the Install Date
                        if(assetsWrapper.InstallDate != null){
                            asset.InstallDate = assetsWrapper.InstallDate;
                        }
                        
                        //Update the Subscription End Date
                        if(assetsWrapper.SubscriptionEndDate != null){
                            asset.SBQQ__SubscriptionEndDate__c = assetsWrapper.SubscriptionEndDate;
                        }
                    }
                }
            }
            
            update assetList; 
            awlServer = getAssetsWrapper(orderID); 
        }
        catch (DmlException e) {
            GAM.CreateExceptionRecords('ReviewAssetsOrderController', 'Exception from ReviewAssetsOrderController->saveAssets',e.getMessage());
            awlServer = new List<String>();
            String error = 'Error - ' + e.getDmlMessage(0);
            awlServer.add(error);
        }
        
        return awlServer; 
    }
    
    public class AssetsWrapper {
        
        @AuraEnabled public Asset ast {get; set;} 
        @AuraEnabled public String Status {get; set;} 
        @AuraEnabled public String AssetIdentifier {get; set;} 
        @AuraEnabled public String ParentAssetID {get; set;}
        @AuraEnabled public String ParentAssetName {get; set;}
        @AuraEnabled public String AssociatedAssetID {get; set;}
        @AuraEnabled public String AssociatedAssetName {get; set;}
        @AuraEnabled public String OriginSObjectName {get; set;}
        @AuraEnabled public Date InstallDate {get; set;}
        @AuraEnabled public Date SubscriptionEndDate {get; set;}
        
        public AssetsWrapper(Asset assetParam){
            ast = assetParam; 
            Status = assetParam.Status; 
            
            if(assetParam.InstallDate != null){
                InstallDate = assetParam.InstallDate;
            }
            
            if(assetParam.SBQQ__SubscriptionEndDate__c != null){
                SubscriptionEndDate = assetParam.SBQQ__SubscriptionEndDate__c;
            }
            
            if (assetParam.Asset_Identifier__c != null)
                AssetIdentifier = assetParam.Asset_Identifier__c; 
            else 
                AssetIdentifier = ''; 
            
            if (assetParam.Primary_Asset__c != null) {
                ParentAssetID = assetParam.Primary_Asset__r.Id; 
                ParentAssetName = assetParam.Primary_Asset__r.Name; 
            }
            else {
                ParentAssetID = ''; 
                ParentAssetName = ''; 
            }
            
            if (assetParam.Associated_Asset__c != null) {
                AssociatedAssetID = assetParam.Associated_Asset__r.Id; 
                AssociatedAssetName = assetParam.Associated_Asset__r.Name; 
            }   
            else {
                AssociatedAssetID = ''; 
                AssociatedAssetName = ''; 
            }
        }
    }
}