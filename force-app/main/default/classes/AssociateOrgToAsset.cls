/*
Class:          AssociateOrgToAsset 
@Author:        Vignesh D
@Created Date:  26 August 2020
@Description:   Batch class for associating org with the asset.
*/

/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                         Tag
    ********************************************************************************************************************************************
   Ambica Pyati     16-01-2021      I2RT                            Associate Org to Entitled Products                                  T01
   Pavithra V       12-05-2021      F2A-368                         Create Org Contracts                                                T02
   Pavithra V       29-06-2021      F2A-402                         Add Manual Fulfillment Lines                                        T03
   Vignesh D        12-02-2023      F2A-494                         Updated query and logic to populate org on Flex IPU                 T04
                                                                    assets/products
   Vignesh D        28-02-2023      F2A-476                         Updated logic for IPU 1.0 metering                                  T05
   Vignesh D        28-04-2023      I2RT-6895                       Updated logic to create org entitled product junction records       T06
                                                                    instead of entitled product lookup on org
   Vignesh D        10-05-2023      I2RT-6895                       Populate org details from IPU wrapper to child products which does  T07
                                                                    not have a linkage to fulfillment line.
   Vignesh D        23-06-2023      F2A-594                         Moved org contract creation logic onto the service class            T08
*/

global class AssociateOrgToAsset implements Database.Batchable<sObject>{

    public static globalApexManager GAM = new globalApexManager();
    public static Set<String> CONSUMPTION_MODEL = new Set<String>{System.Label.IPU_Product_GTM_Value, System.Label.IPU}; //<T04> //<T05>
    public static Set<String> DELIVERY_METHODS = new Set<String>{'Hosted Single Tenant','Hosted Multi Tenant'}; //<T07>

    global Database.QueryLocator start(Database.BatchableContext BC){   
        String query = 'Select Id,SBQQ__OrderProduct__c,Fulfillment_Id__c,Product2.License_Screen_Type__c,Product2.License_Generation__c,Org__c,Entitled_Product__c,Org__r.Entitled_Product__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,Product2.GTM_Model__c,SBQQ__OrderProduct__r.SBQQ__RequiredBy__c,SBQQ__OrderProduct__r.SBQQ__RequiredBy__r.Product2.GTM_Model__c from Asset where (Org__c = null or (Org_UUID_Timestamp__c = LAST_N_DAYS:1) or (SBQQ__CurrentSubscription__r.CreatedDate = LAST_N_DAYS:1)) and ((Product2.License_Screen_Type__c != null and Product2.License_Generation__c IN (\'Production\',\'Options\',\'Sandbox\')) or Product2.GTM_Model__c IN :CONSUMPTION_MODEL or (SBQQ__OrderProduct__r.SBQQ__RequiredBy__r.Product2.GTM_Model__c IN :CONSUMPTION_MODEL and SBQQ__OrderProduct__r.Product2.Delivery_Method__c IN :DELIVERY_METHODS))'; //<T04> //<T05> //<T06> //<T07>
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id, Asset> assets = new Map<Id, Asset>((List<Asset>) scope);
        Set<Id> orderProductIds = new Set<Id>();
        Map<Id, String> orderProductOrgUUIDMap = new Map<Id, String>();
        List<Asset> assetsToUpdate = new List<Asset>();
        // List<Org__c> orgstoUpdate = new List<Org__c>(); //<T08>
        // Map<Id,List<Id>> orgToContractsMap = new Map<Id,List<Id>>(); /**<T02>**/ //<T08>
        // Set<Id> orgIdSet = new Set<Id>();/**<T02>**/ //<T08>
        // Map<String,Org_Contract__c> orgContractMap = new Map<String,Org_Contract__c>(); /**<T02>**/ //<T08>
        
        Map<Id,String> ffLineOrgIdMap = new Map<Id, String>();
        Map<String, String> uuidToOrgMap = new Map<String, String>();
        Set<Id> setAssetIds = new Set<Id>(); //<T06>
        
        for(Asset a: assets.values()){
            if(a.org__c != null && a.Entitled_Product__c != null /*&& (a.Org__r?.Entitled_Product__c == null  || a.Org__r?.Entitled_Product__c != a.Entitled_Product__c)*/){ //<T06>
                setAssetIds.add(a.Id); //<T06>
            }
            if(a.SBQQ__OrderProduct__c != null){
                orderProductIds.add(a.SBQQ__OrderProduct__c);
            }
            if(CONSUMPTION_MODEL.contains(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__r.Product2.GTM_Model__c)){ //<T07>
                orderProductIds.add(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c);
            }          
        }

        List<OrderItem> orderProducts = [Select Id, Product2.License_Screen_Type__c, Product2.License_Generation__c,SBQQ__RequiredBy__r.Product2.License_Screen_Type__c,SBQQ__RequiredBy__r.Product2.License_Generation__c,Product2.GTM_Model__c, //<T04>
                                            (Select Id,Fullfillment_Line__r.Parent_ID__c,Fullfillment_Line__r.License_Screen_Type2__c,Fullfillment_Line__r.License_Generation__c,Fullfillment_Line__r.Org_UUID__c,Fullfillment_Line__r.Org__c
                                            from Related_Fullfillment_Lines__r where Fullfillment_Line__r.Fullfillment__r.Active__c = true) 
                                            from OrderItem where Id IN :orderProductIds];
        for(OrderItem op: orderProducts){

            for(Related_Fulfillment_Line__c relatedFFline : op.Related_Fullfillment_Lines__r){
                if(CONSUMPTION_MODEL.contains(op.Product2?.GTM_Model__c)){ //<T04> //<T05>
                    if(!orderProductOrgUUIDMap.containsKey(op.Id) && relatedFFline.Fullfillment_Line__r.Org__c != null){
                        orderProductOrgUUIDMap.put(op.Id, relatedFFline.Fullfillment_Line__r.Org__c);
                    }
                }
                else if(op.Product2.License_Generation__c == 'Production' || op.Product2.License_Generation__c == 'Sandbox'){
                    if(relatedFFline.Fullfillment_Line__r.Parent_ID__c <> null){
                        ffLineOrgIdMap.put(relatedFFline.Fullfillment_Line__c, relatedFFline.Fullfillment_Line__r.Org__c);
                    }else{
                        if(!orderProductOrgUUIDMap.containsKey(op.Id) && relatedFFline.Fullfillment_Line__r.Org__c != null){
                            orderProductOrgUUIDMap.put(op.Id, relatedFFline.Fullfillment_Line__r.Org__c);
                        }
                    }
                }
                else if(op.Product2.License_Generation__c == 'Options' && (((op.SBQQ__RequiredBy__r.Product2.License_Generation__c == 'Production' && relatedFFline.Fullfillment_Line__r.License_Generation__c == 'Production') ||
                        (op.SBQQ__RequiredBy__r.Product2.License_Generation__c == 'Sandbox' && relatedFFline.Fullfillment_Line__r.License_Generation__c == 'Sandbox') || op.SBQQ__RequiredBy__r.Product2.License_Generation__c == 'Options') || op.SBQQ__RequiredBy__c == null)){
                    if(!orderProductOrgUUIDMap.containsKey(op.Id) && relatedFFline.Fullfillment_Line__r.Org__c != null){
                        orderProductOrgUUIDMap.put(op.Id, relatedFFline.Fullfillment_Line__r.Org__c);
                    }
                }
            }
        }
        
        List<String> totalOrgIdList = new List<String>();
        totalOrgIdList.addAll(orderProductOrgUUIDMap.values());
        totalOrgIdList.addAll(ffLineOrgIdMap.values());
        
        List<Org__c> orgs = [Select Id,OrgID__c from Org__c where Id IN :totalOrgIdList order by CreatedDate DESC];
        for(Org__c org: orgs){
            if(!uuidToOrgMap.containsKey(org.Id)){
                uuidToOrgMap.put(org.Id, org.OrgID__c);
            }
        }
        
        for(Asset a: assets.values()){
            
            if(a.SBQQ__OrderProduct__c != null && a.Product2.License_Screen_Type__c != null && (a.Product2.License_Generation__c == 'Production' || a.Product2.License_Generation__c == 'Sandbox' || a.Product2.License_Generation__c == 'Options' || CONSUMPTION_MODEL.contains(a.Product2?.GTM_Model__c))){ //<T04> //<T05>
               
                if((a.Fulfillment_Id__c <> null || a.Fulfillment_Id__c <> '') && ffLineOrgIdMap.containsKey(a.Fulfillment_Id__c)){
                    if(a.Org__c <> ffLineOrgIdMap.get(a.Fulfillment_Id__c)) {
                       a.Org__c =  ffLineOrgIdMap.get(a.Fulfillment_Id__c);
                       a.Asset_Identifier__c = uuidToOrgMap.get(ffLineOrgIdMap.get(a.Fulfillment_Id__c)); 
                       assetsToUpdate.add(a);
                    }
                }else if(orderProductOrgUUIDMap.containsKey(a.SBQQ__OrderProduct__c)){
                    if(a.Org__c <> orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__c)){
                        a.Org__c =  orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__c);
                        a.Asset_Identifier__c = uuidToOrgMap.get(orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__c)); 
                        assetsToUpdate.add(a);
                    }
                }
                
                if(a.org__c != null && a.Entitled_Product__c != null && orderProductOrgUUIDMap.containsKey(a.SBQQ__OrderProduct__c)){
                    setAssetIds.add(a.Id); //<T06>
                }

            }
            else if(a.SBQQ__OrderProduct__c != null && CONSUMPTION_MODEL.contains(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__r.Product2.GTM_Model__c) && orderProductOrgUUIDMap.containsKey(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c)){ //<T07>
                if(a.Org__c <> orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c)){
                    a.Org__c =  orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c);
                    a.Asset_Identifier__c = uuidToOrgMap.get(orderProductOrgUUIDMap.get(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c)); 
                    assetsToUpdate.add(a);
                }

                if(a.org__c != null && a.Entitled_Product__c != null && orderProductOrgUUIDMap.containsKey(a.SBQQ__OrderProduct__r.SBQQ__RequiredBy__c)){
                    setAssetIds.add(a.Id);
                }
            }
        }

        if(assetsToUpdate != null && assetsToUpdate.size()>0){
            Database.SaveResult[] srList = Database.update(assetsToUpdate, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){               
                    for(Database.Error err : sr.getErrors()) {                  
                        GAM.CreateExceptionRecords('AssociateOrgToAsset--> Update of Assets failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        /**<T02>**/
        OrgContractService.createOrgContracts(assets.keySet()); //<T08>       
        /**<T02>**/
        
        /**<T01>**/
        //---------------------------------------<T06>------------------------------
        EntitledProductService.createOrgEntitledProduct(setAssetIds);
        //---------------------------------------</T06>------------------------------
        
        /**<T01>**/
    }

    global void finish(Database.BatchableContext BC){
        System.debug('Batch completed');
    }
}