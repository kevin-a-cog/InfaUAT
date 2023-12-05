/*
Class:          EntitledProductService 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Service Class for Entitled Product
****************************************************************************************************
MODIFIED BY      JIRA               DESCRIPTION                                             TAG
****************************************************************************************************
Vignesh D       I2RT-4361           Forecast Product Alias mapping                          T01
Vignesh D       I2RT-1815           Fix for Duplicate EP creation for ELA assets            T02
Vignesh D       I2RT-5185           Project Booster                                         T03 
Sandeep D       I2RT-6845           Clean up Technical Product Line                         T04
Vignesh D       I2RT-7447           Removed Forecast_Product__c reference from query        T05
Vignesh D       I2RT-6895           Updated logic to create & delete org entitled products  T06
Vignesh D       I2RT-8398           Added logic to archive EP with no assets but is         T07
                                    associated with a case
Vignesh D       I2RT-8398           Added filter to exclude Archived EPs                    T08
Vignesh D       I2RT-8628           Fixed duplicate id in list to update					T09
Vignesh D       I2RT-9462           Limit no of records in sub query    					T10
*/

public class EntitledProductService {

    public static final String SIGNATURE_SUCCESS = 'Signature Success';
    public static final String ELA_BASKET = 'ELA Basket';
    public static final String BCSP_PRODUCT = 'Business Critical';
    public static final String XS_SUB_PRODUCT = 'Extended Version';
    public static final String XS_PRODUCT = 'Extended Support';
    public static final String CASEPACK_PRODUCT = 'Case Pack';

    public static globalApexManager GAM = new globalApexManager(); //<T06>

    @Future
    public static void createEntitledProductsFuture(Set<Id> setAssetIds, Set<Id> setOldAccountIds){
        createEntitledProducts(setAssetIds,setOldAccountIds);
    }
   
    //Associate Assets to new /existing entitled products
    public static void createEntitledProducts( Set<Id> setAssetIds, Set<Id> setOldAccountIds) {
        
        system.debug('Enter Method createEntitledProducts');

        List<Asset> LstAssetDeatils = new List<Asset>();
        Set<Asset> setELAAssets = new set<Asset>();
        Set<id> setELAProductIds = new Set<id>();
        map<id,Asset> mapUpdateEPonAssets = new map<id,Asset>();
        List<Entitlement> lstUpdateEPonEnt = new List<Entitlement>();

        Map<String,String> mapForecastProductAlias = new Map<String,String>();
        Map<String,List<Asset>> mapUniqueProuductAssets = new map<String,List<Asset>>();
        Map<String,Entitled_Product__c> mapUniqueProductEP = new map<String,Entitled_Product__c>();
        Map<String,Entitled_Product__c> mapUniqueProductNewEP = new  Map<String,Entitled_Product__c>();
        Map<Id,List<Service_BOM__c>>  mapProdSBOM = new Map<Id,List<Service_BOM__c>>();
        Map<Id, List<id>>  mapAssetToClonedAssets = new Map<id,List<id>>();
        Map<Id,String> mapUniqueELAProductEP = new Map<Id,String>();
        Map<Asset,Id> mapELAAssetEP = new Map<Asset,Id>();

        List<Entitled_Product__c> lstUpsertEntitledProducts = new List<Entitled_Product__c>();
        List<Entitled_Product__c> lstInsertEntitledProducts= new  List<Entitled_Product__c>();
        List<Entitled_Product__c> lstDeletEntitledProducts = new List<Entitled_Product__c>();
        List<Entitled_Product__c> lstEntitledProductsToArchive = new List<Entitled_Product__c>(); //<T07>
        List<Asset> lstInsertClonedAssets = new List<Asset>();
        List<AssetRelationship> lstInsertAssetRelationship = new List<AssetRelationship>();
        List<Entitlement> lstInsertClonedEntitlements = new List<Entitlement>();

        set<Id> setNewSupportAccountIds = new Set<Id>();
        set<Id> setNewEntitledProductIds = new set<Id>();
        set<id> setOldSupportAccountIds = new set<Id>();
        set<id> setOldEntitledProducts = new Set<id>();
        set<id> setEntitledProductToRecalculate = new set<id>();
        set<id> setSupportAccountsToRecalculate = new set<id>();
        set<String> setCreateEP = new set<String>();
        set<Id> setNewAssetIds = new set<Id>();
        set<id> setAssetsUpdated = new set<Id>();
        set<String> setRootIds = new Set<String>();
        set<String> setBCSPBundle = new set<String>();
        set<String> setXSBundle = new set<String>();
        // GlobalApexManager GAM = new GlobalApexManager(); <T06>
        
        //Id ServiceBOMRecType = Schema.SObjectType.Entitled_Product__c.getRecordTypeInfosByName().get('Service BOM').getRecordTypeId();

        //Get Product Details from Asset
        LstAssetDeatils= [Select id,Name,Quantity, SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__RootId__c,SBQQ__CurrentSubscription__r.SBQQ__RequiredById__c,AccountId,Support_Account__c,Product2Id,Product2.Option_Scale__c,Product2.Forecast_Product__c,Product2.Pricing_Business_Model__c,Product2.Delivery_Method__c,Product2.Edition__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Entitled_Product__c,Entitled_Product__r.Manual_Creation_Override__c,Org__c //<T06>
                          from Asset where id in :setAssetIds AND Product2.Edition__c != 'Case Pack' ];
        
        //<T01>
        //Get Forecast Product Alias from Technical Product
        /*for(Technical_Product_Line__c tp :[select Id,Name,Forecast_Product__c,Delivery_method__c from Technical_Product_Line__c where Forecast_Product__c != null]){
            if(!String.isEmpty( tp.Forecast_Product__c)){
                if(tp.Forecast_Product__c.contains(';')){ 
                    List<string> lstFP = tp.Forecast_Product__c.split(';');
                    if(lstFP != null && lstFP.size()>0){
                        for(String fp: lstFP){
                            mapForecastProductAlias.put(fp,tp.Name);
                        }
                    }
                }
                else{
                    mapForecastProductAlias.put(tp.Forecast_Product__c,tp.Name);
                }
            }
        }*/

        /*for(Technical_Product_Line__c tp :[select Id,Name,Forecast_Product__c,Delivery_method__c,Alias__c from Technical_Product_Line__c where Forecast_Product__c != null]){
            if(!String.isEmpty( tp.Alias__c)){
                if(tp.Alias__c.contains(';')){ 
                    List<string> lstFP = tp.Alias__c.split(';');
                    if(lstFP != null && lstFP.size()>0){
                        for(String fp: lstFP){
                            mapForecastProductAlias.put(fp,tp.Name);
                        }
                    }
                }
                else{
                    mapForecastProductAlias.put(tp.Alias__c,tp.Name);
                }
            }
            else{
                mapForecastProductAlias.put(tp.Name,tp.Name);
            }
        } */
        // T4 start 
        String AliasDLKey ;
        for(Technical_Product_Line__c tp :[select Id,Name,Delivery_method__c,Alias__c from Technical_Product_Line__c where status__c = 'Active']){ //<T05>
           
            if(!String.isEmpty( tp.Alias__c)){
                if(tp.Alias__c.contains(';')){ 
                    List<string> lstFP = tp.Alias__c.split(';');
                    if(lstFP != null && lstFP.size()>0){
                        for(String fp: lstFP){
                              if(tp.Delivery_method__c.Contains(';')){
                                  // multiple alias and multiple dl 
                               List<string> lstDL = tp.Delivery_method__c.split(';');
                                     if(lstDL != null && lstDL.size()>0){
                                            for(String dl : lstDL){
                                                    AliasDLKey = fp +';'+ dl ;
                                                   mapForecastProductAlias.put(AliasDLKey, tp.Name);
                                       }
                                 }
                              }
                                 else{
                                      // alias is multiple and single dl 
                                        AliasDLKey = fp +';'+ tp.Delivery_method__c ;
                                        mapForecastProductAlias.put(AliasDLKey, tp.Name);
                                 }
                        }
                    }
                }
                else{ 
                     
                     if(tp.Delivery_method__c.contains(';')){
                         // alias is single and multiple delivery methods 
                            List<string> lstDL = tp.Delivery_method__c.split(';');
                                     if(lstDL != null && lstDL.size()>0){
                                            for(String dl : lstDL){
                                                   AliasDLKey = tp.Alias__c +';'+ dl ;
                                                   mapForecastProductAlias.put(AliasDLKey, tp.Name);
                                       }
                                 }
                                }
                   else{ 
                          //  alias is single and single delivery method 
                                  AliasDLKey = tp.Alias__c +';'+ tp.Delivery_method__c ;
                                  mapForecastProductAlias.put(AliasDLKey,tp.Name);
                                 }
                }
            }
            else{
                
                if(tp.Delivery_method__c.contains(';')){
                         // alias is blank  and multiple delivery methods 
                            List<string> lstDL = tp.Delivery_method__c.split(';');
                                     if(lstDL != null && lstDL.size()>0){
                                            for(String dl : lstDL){
                                                   AliasDLKey =  tp.Name+';'+dl ;
                                                   mapForecastProductAlias.put(AliasDLKey, tp.Name);
                                       }
                                 }
                            }
                            else{ 
                                    //  alias is blank  and single delivery method 
                                             AliasDLKey = tp.Name +';'+ tp.Delivery_method__c ;
                                            mapForecastProductAlias.put(AliasDLKey,tp.Name);
                                            }
                
            }
           
        }
        // T04 End 
        //</T01>

        System.debug('mapForecastProductAlias'+mapForecastProductAlias);
        
        if(setOldAccountIds != null) //<T06>
            deleteOrgEntitledProduct(LstAssetDeatils, setOldAccountIds);

        //Group unique set of Assets per Support Account
        for (Asset a :LstAssetDeatils ){
            if( a.Support_Account__c != null ){
                setNewSupportAccountIds.add(a.Support_Account__c); //<T02>
                //get ELA Assets
                if(a.Product2 != null && a.Product2.Option_Scale__c != null && a.Product2?.Option_Scale__c.contains(ELA_BASKET)){
                    if(a.Entitled_Product__c != null){
                        mapELAAssetEP.Put(a,a.Entitled_Product__c);
                    }
                    else{
                        setELAAssets.add(a);
                        setELAProductIds.add(a.product2Id);
                    }
                }
                else{
                     //get Subscription for the Asset  
                     if(a.SBQQ__CurrentSubscription__r.SBQQ__RootId__c != null){               
                        setRootIds.add(a.SBQQ__CurrentSubscription__r.SBQQ__RootId__c);
                     }

                    //get supportAccountIds
                    //setNewSupportAccountIds.add(a.Support_Account__c); Commented as part of <T02>
                    system.debug('Product Alias' + mapForecastProductAlias?.get(a.product2.Forecast_Product__c ));
                    system.debug('a.Product2.Forecast_Product__c' +a.Product2.Forecast_Product__c);
                    system.debug('a.Product2.Delivery_Method__c' +a.Product2.Delivery_Method__c);
                    String assetkey = a.Product2.Forecast_Product__c+';'+a.Product2.Delivery_Method__c;
                    //get assets grouped by uniuqe product combination
                    if(a.Product2?.Forecast_Product__c != null && a.Product2?.Delivery_Method__c!= null){                 
                        String uniqueProduct= (mapForecastProductAlias?.get(assetkey)!= null?mapForecastProductAlias?.get(assetkey) : a.product2.Forecast_Product__c)+';'+ a.product2.Delivery_Method__c +';'+ a.Support_Account__c ;
                        system.debug('uniqueProduct'+uniqueProduct);
                        if(mapUniqueProuductAssets.containskey(uniqueProduct)){
                            mapUniqueProuductAssets.get(uniqueProduct).add(a);
                        }
                        else{
                            List<Asset> lstAsset = new List<Asset>();
                            lstAsset.add(a);
                            mapUniqueProuductAssets.put(uniqueProduct,lstAsset);
                        }  
                    }
                }
            }  
        }
        System.debug('setRootIds'+setRootIds);
        System.debug('setRootIds Size'+setRootIds.size());
        System.debug('setRootIds Empty'+setRootIds.isEmpty());
        System.debug('setNewSupportAccountIds'+setNewSupportAccountIds);
        system.debug('mapUniqueProuductAssets' + mapUniqueProuductAssets );
        system.debug('setELAAssets' + setELAAssets );

        //Get the BCSP,XS products from Bundles 
        if(setRootIds != null && setRootIds.size()>0){
            for(SBQQ__Subscription__c sub: [Select Id,SBQQ__Product__r.Edition__c,SBQQ__RequiredById__c,SBQQ__RootId__c,SBQQ__Product__c from SBQQ__Subscription__c 
                where SBQQ__RootId__c in:setRootIds and (SBQQ__Product__r.Edition__c =: BCSP_PRODUCT OR SBQQ__Product__r.Edition__c =: XS_PRODUCT OR SBQQ__Product__r.Edition__c =: XS_SUB_PRODUCT)]){
                if(sub.SBQQ__Product__r?.Edition__c == BCSP_PRODUCT){
                    setBCSPBundle.add(sub.SBQQ__RootId__c);
                }
                else if(sub.SBQQ__Product__r?.Edition__c == XS_PRODUCT || sub.SBQQ__Product__r?.Edition__c == XS_SUB_PRODUCT){
                    setXSBundle.add(sub.SBQQ__RootId__c);
                }
            }
        }
        
        //Get existing EPs under support account
        for(Entitled_Product__c EP : [Select id,Forecast_Product__c,Pricing_Model__c,Delivery_Method__c,Support_Account__c,Account__c from Entitled_Product__c where Support_Account__c in :setNewSupportAccountIds AND Archived__c = false]){ //<T08>
            if(EP.Support_Account__c != null && setNewSupportAccountIds.contains(EP.Support_Account__c) &&EP.Forecast_Product__c!= null && +EP.Delivery_Method__c != null ){
                String uniqueProduct = EP.Forecast_Product__c+ ';'+EP.Delivery_Method__c +';'+ EP.Support_Account__c ;
                mapUniqueProductEP.put(uniqueProduct,EP);
            }
        }
        system.debug('mapUniqueProductEP'+mapUniqueProductEP);

    //-------------------START ELA PRODUCTS--------------------------------------
        
        //for share and transfer
        for(Entitled_Product__c EP: [Select id,Forecast_Product__c,Delivery_Method__c ,Support_Account__c from Entitled_Product__c where Id in : mapELAAssetEP.values() and Support_Account__c != null and Forecast_Product__c!= null and Delivery_Method__c != null AND Archived__c = false]){ //<T08>
            String uniqueProduct = EP.Forecast_Product__c+ ';'+EP.Delivery_Method__c +';'+ EP.Support_Account__c ;
            mapUniqueELAProductEP.put(EP.Id,uniqueProduct);
        }
        
        for(Asset a : mapELAAssetEP.keyset()){
            if(a.Entitled_Product__c!= null && mapUniqueELAProductEP.containskey(a.Entitled_Product__c)){
                String uniqueProduct= mapUniqueELAProductEP.get(a.Entitled_Product__c);
                system.debug('uniqueProduct'+uniqueProduct);
                if(mapUniqueProuductAssets.containskey(uniqueProduct)){
                    mapUniqueProuductAssets.get(uniqueProduct).add(a);
                }
                else{
                    List<Asset> lstAsset = new List<Asset>();
                    lstAsset.add(a);
                    mapUniqueProuductAssets.put(uniqueProduct,lstAsset);
                }  
            }
        }



        //get SBOM for ELA Products
        for(Service_BOM__c SBOM : [Select id , Product__c,Forecast_Product__c , Delivery_Method__C from Service_BOM__c where Product__c in : setELAProductIds and Forecast_Product__c != null and Delivery_Method__C != null]){
            if(mapProdSBOM.containskey(SBOM.Product__c)){
                mapProdSBOM.get(SBOM.Product__c).add(SBOM);
            }else{
                List<Service_BOM__c> lstSBOM = new List<Service_BOM__c>();
                lstSBOM.add(SBOM);
                mapProdSBOM.put(SBOM.Product__c, lstSBOM);
            }
        }
        system.debug('mapProdSBOM'+mapProdSBOM);

        //Create EP for ELA Products
        for(Asset a : setELAAssets){
            //if Product Has more than one ServiceBom Clone Asset and Entitlements to tag to the EP
            if(mapProdSBOM?.containskey(a.Product2Id)  ) {
                Integer countSBOM =  mapProdSBOM.get (a.Product2Id).size();
                Integer i = 1;
                for(Service_BOM__c SBOM : mapProdSBOM?.get(a.Product2Id)){
                    if(SBOM.Forecast_Product__c != null && SBOM.Delivery_Method__c!= null){

                        System.debug('SBOM.Forecast_Product__c'+SBOM.Forecast_Product__c);
                        System.debug('SBOM.Delivery_Method__c'+SBOM.Delivery_Method__c);
                        System.debug('a.Support_Account__c'+a.Support_Account__c);
                        system.debug('mapForecastProductAlias?.get(SBOM.Forecast_Product__c)'+mapForecastProductAlias?.get(SBOM.Forecast_Product__c));
                        //Create new EP 
                        String uniqueProduct = (mapForecastProductAlias?.get(SBOM.Forecast_Product__c) != null ? mapForecastProductAlias?.get(SBOM.Forecast_Product__c): SBOM.Forecast_Product__c) + ';'+SBOM.Delivery_Method__c +';'+ a.Support_Account__c ;
                        System.debug('uniqueProduct'+uniqueProduct);

                         if(!mapUniqueProductEP.containskey(uniqueProduct) && !mapUniqueProuductAssets.containskey(uniqueProduct)){
                            setCreateEP.add(uniqueProduct); // capture EP being created to avoid duplicates
                            Entitled_Product__c newEP = new Entitled_Product__c();
                            newEP.Forecast_Product__c= mapForecastProductAlias?.get(SBOM.Forecast_Product__c)!= null?mapForecastProductAlias?.get(SBOM.Forecast_Product__c): SBOM.Forecast_Product__c;
                            newEP.Delivery_Method__c =SBOM.Delivery_Method__c;
                            newEP.Support_Account__c = a.Support_Account__c;
                            newEP.Account__c =a.AccountId;
                            newEP.Pricing_Model__c=a.product2?.Pricing_Business_Model__c ;
                            newEP.Name = newEP.Forecast_Product__c+'('+newEP.Delivery_Method__c +')';
                            lstUpsertEntitledProducts.add(newEP);
                        }
                        //Clone ELA Asset for each ServiceBOM
                        if(i<countSBOM){
                            Asset cloneasset = a.clone();
                            cloneasset.ParentId = a.id;
                            lstInsertClonedAssets.add(CloneAsset);
                            i++;
                        }
                    }
                }
            }
        }
        system.debug('lstInsertClonedAssets'+lstInsertClonedAssets);
        system.debug('lstUpsertEntitledProducts.size()'+lstUpsertEntitledProducts.size());
        system.debug('lstUpsertEntitledProducts'+lstUpsertEntitledProducts);
        system.debug('setCreateEP'+setCreateEP);


        if(lstInsertClonedAssets!=null && lstInsertClonedAssets.size()>0){
            Database.SaveResult[] srList = Database.Insert(lstInsertClonedAssets);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewAssetIds.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitledProductService-->createEntitlementProducts-->Insert of cloned assets failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        system.debug('setNewAssetIds-->'+setNewAssetIds);

        //Link Cloned Assets to ELA asset
        for(Asset a: [Select Id,ParentId,Product2Id, SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c from asset where id in :setNewAssetIds and ParentId != null]){
            AssetRelationship ar = new AssetRelationship();
            ar.AssetId = a.Id;
            ar.FromDate= System.now();
            ar.ToDate= a.SBQQ__SubscriptionEndDate__c;
            ar.RelatedAssetId =a.ParentId;
            ar.RelationshipType ='Shadow';
            lstInsertAssetRelationship.add(ar);
            if(mapAssetToClonedAssets.containskey(a.ParentId)){
                mapAssetToClonedAssets.get(a.ParentId).add(a.id);
            }else{
                List<id> clonedAssets = new List<id>();
                clonedAssets.add(a.id);
                mapAssetToClonedAssets.put(a.ParentId,clonedAssets);
            }
        }
        system.debug('mapAssetToClonedAssets-->'+mapAssetToClonedAssets);
        system.debug('lstInsertAssetRelationship-->'+lstInsertAssetRelationship);

        if(lstInsertAssetRelationship?.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertAssetRelationship);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitledProductService-->createEntitlementProducts-->Insert of Asset Realtion failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        //Create Entitlements for Cloned Assets
        for(Entitlement ent : [Select Id,Name,AssetId,startdate,enddate,AccountId,Status,Type,Support_Level__c,
                                BusinessHoursId,CasesPerEntitlement,ContractLineItemId,CurrencyIsoCode,RemainingCases,ServiceContractId,SlaProcessId
                                from Entitlement where AssetId in :mapAssetToClonedAssets.keyset()]){
            for (Id clonedAsset : mapAssetToClonedAssets.get(ent.AssetId) ){
                Entitlement newEnt = ent.clone(false);
                newEnt.AssetId = clonedAsset;
                lstInsertClonedEntitlements.add(newEnt);   
            }                          
        }

        system.debug('lstInsertClonedEntitlements-->'+lstInsertClonedEntitlements);
        if(lstInsertClonedEntitlements?.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertClonedEntitlements);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitledProductService-->createEntitlementProducts-->Insert of cloned Entitlements failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        //Map cloned assets with EP
        for(Asset a : setELAAssets){
            if(mapAssetToClonedAssets.containskey(a.id)){
                Integer i=0;
                Integer clonedAssetcount = mapAssetToClonedAssets?.get(a.Id)?.size();
                for(Service_BOM__C SBOM : mapProdSBOM?.get(a.Product2Id) ){

                    System.debug('SBOM.Forecast_Product__c'+SBOM.Forecast_Product__c);
                    System.debug('SBOM.Delivery_Method__c'+SBOM.Delivery_Method__c);
                    System.debug('a.Support_Account__c'+a.Support_Account__c);
                    system.debug('mapForecastProductAlias?.get(SBOM.Forecast_Product__c)'+mapForecastProductAlias?.get(SBOM.Forecast_Product__c));
                    

                    String uniqueProduct = (mapForecastProductAlias?.get(SBOM.Forecast_Product__c)!= null ? mapForecastProductAlias?.get(SBOM.Forecast_Product__c) : SBOM.Forecast_Product__c )+ ';'+SBOM.Delivery_Method__c +';'+ a.Support_Account__c ;
                    System.debug(' setELAAssets uniqueProduct'+uniqueProduct);
                    //get the cloned asset if there are more else get maprent asset
                    Asset mapAsset = new Asset(Id = (i<clonedAssetcount? mapAssetToClonedAssets?.get(a.id)[i] : a.id));
                    System.debug('mapAsset'+mapAsset);
                    if(mapUniqueProuductAssets.containskey(uniqueProduct)){
                        mapUniqueProuductAssets.get(uniqueProduct).add(mapAsset);
                    }else{
                        List<Asset> lstAsset = new List<Asset>();
                        lstAsset.add(mapAsset);
                        mapUniqueProuductAssets.put(uniqueProduct,lstAsset);
                    }
                    i++;
                }
            }
        }
        system.debug('mapUniqueProuductAssets'+mapUniqueProuductAssets);

    //-------------END ELA PRODUCTS -------------------------------------------------------


        for(string uniqueProd : mapUniqueProuductAssets?.keyset() ){
            //if EP exists with same combination activate the same and associate assets
            if(mapUniqueProductEP?.containskey(uniqueProd)){
                for(Asset a : mapUniqueProuductAssets?.get(uniqueProd)){
                    //update EP on Asset
                    Asset assetUpdate = new Asset (Id= a.Id);
                    assetUpdate.Entitled_Product__c = mapUniqueProductEP?.get(uniqueProd).Id;
                    mapUpdateEPonAssets.put(a.id,assetUpdate);
                    //BCSP,XS 
                    if( setBCSPBundle.contains(a.SBQQ__CurrentSubscription__r?.SBQQ__RootId__c)|| setXSBundle.contains(a.SBQQ__CurrentSubscription__r?.SBQQ__RootId__c)){
                        Entitled_Product__c updateEP = new Entitled_Product__c(Id = mapUniqueProductEP?.get(uniqueProd).Id);
                        if(setBCSPBundle.contains(a.SBQQ__CurrentSubscription__r?.SBQQ__RootId__c))
                            updateEP.Business_Critical_Success_Plan__C = true;
                        if(setXSBundle.contains(a.SBQQ__CurrentSubscription__r?.SBQQ__RootId__c))
                            updateEP.Extended_Support__C = true;
                        lstUpsertEntitledProducts.add(updateEP);
                    }
                    //Entitled Products Updated/Created
                    setEntitledProductToRecalculate.add(mapUniqueProductEP?.get(uniqueProd).Id);
                }
            }
            //Create new EP 
            else if(!setCreateEP.contains(uniqueProd)) {
                System.debug('uniqueProd +create new ep'+uniqueProd);
                List<String> EPValues = uniqueProd.split(';');
                if(EPValues != null && EPValues.size()>0){
                    Entitled_Product__c EP = new Entitled_Product__c();
                    EP.Forecast_Product__c= EPValues[0];
                    EP.Delivery_Method__c =EPValues[1];
                    EP.Support_Account__c =EPValues[2];
                    EP.Account__c =mapUniqueProuductAssets?.get(uniqueProd)[0]?.AccountId;
                    Ep.Pricing_Model__c=mapUniqueProuductAssets?.get(uniqueProd)[0]?.product2?.Pricing_Business_Model__c ;
                    EP.Name = EPValues[0] +'('+ EPValues[1]+')';
                    for(Asset a: mapUniqueProuductAssets.get(uniqueProd))
                    {
                        if(setBCSPBundle.contains(a.SBQQ__CurrentSubscription__r.SBQQ__RootId__c))
                            EP.Business_Critical_Success_Plan__c= true;
                        if(setXSBundle.contains(a.SBQQ__CurrentSubscription__r.SBQQ__RootId__c))
                            EP.Extended_Support__c =true;
                    }
                    lstUpsertEntitledProducts.add(EP);
                }
            }
        }
        
        //Fix for Duplicate Id in list KG
        Set<Entitled_Product__c> setUpsertEP = new Set<Entitled_Product__c>();
        List<Entitled_Product__c> lstUpsertEPs= new List<Entitled_Product__c>();
        setUpsertEP.addAll(lstUpsertEntitledProducts);
        lstUpsertEPs.addAll(setUpsertEP);
        
        system.debug('mapUpdateEPonAssets'+mapUpdateEPonAssets);
        system.debug('setEntitledProductToRecalculate'+setEntitledProductToRecalculate);
        system.debug('lstUpsertEntitledProducts.size()'+lstUpsertEntitledProducts.size());
        system.debug('lstUpsertEntitledProducts'+lstUpsertEntitledProducts);

        if(lstUpsertEPs!=null && lstUpsertEPs.size()>0){
            Database.UpsertResult[] srList = Database.upsert(lstUpsertEPs);
            for (Database.UpsertResult sr : srList) {
                if (sr.isCreated()){
                    setNewEntitledProductIds.add(sr.getId());
                }
                else if(!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitledProductService-->createEntitlementProducts-->Insert of entitled Product failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }


        //query newly created Entitled Products
        for(Entitled_Product__c EP : [Select id, Forecast_Product__c,Delivery_Method__c,Account__c,Support_Account__c from Entitled_Product__c where Id in :setNewEntitledProductIds  ]){
            if(EP.Forecast_Product__c!= null && +EP.Delivery_Method__c != null && EP.Support_Account__c != null){
            String uniqueProduct = EP.Forecast_Product__c+ ';'+EP.Delivery_Method__c +';'+ EP.Support_Account__c ;
            mapUniqueProductNewEP.put(uniqueProduct,EP);
            }
        }
        system.debug('mapUniqueProductNewEP'+mapUniqueProductNewEP);

        //Associate Assets to newly created Entitled Products
        for(string uniqueProd : mapUniqueProductNewEP?.keyset() ){
            system.debug('uniqueProd'+uniqueProd);
            if(mapUniqueProuductAssets?.containskey(uniqueProd)){
                system.debug('uniqueProd Assets'+mapUniqueProuductAssets?.get(uniqueProd));
                for(Asset a : mapUniqueProuductAssets?.get(uniqueProd)){
                    Asset updateAsset = new Asset (Id= a.Id);
                    updateAsset.Entitled_Product__c  = mapUniqueProductNewEP?.get(uniqueProd).Id;
                    mapUpdateEPonAssets.put(a.id,updateAsset);
                    setEntitledProductToRecalculate.add(mapUniqueProductNewEP?.get(uniqueProd).Id);
                }
            }
        }
         
        system.debug('mapUpdateEPonAssets'+mapUpdateEPonAssets);
        system.debug('setEntitledProductToRecalculate'+setEntitledProductToRecalculate);
        if(mapUpdateEPonAssets!=null &&mapUpdateEPonAssets.values().size()>0){
            Database.SaveResult[] srList = Database.update(mapUpdateEPonAssets.values());
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setAssetsUpdated.add(sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitledroductHandler-->createEntitledProducts-->update of Asset with entitled Product failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        createOrgEntitledProduct(setAssetsUpdated); //<T06>
        
        //check for Entitled Products without Asset and delete them from old Account in case of transfer
        if(setOldAccountIds!= null ){
            for( Entitled_Product__c EP : [Select id, Forecast_Product__c,Delivery_Method__c,Pricing_Model__c,Support_Account__c,Account__c,(SELECT id from Assets__r LIMIT 1),(SELECT Id FROM Cases__r LIMIT 1) from Entitled_Product__c where Support_Account__c  =:setOldAccountIds AND Archived__c = false]){ //<T07> <T08> //<T10>
                if(EP.Assets__r.size() <=0){
                    if(EP.Cases__r.size() > 0){ //<T07>
                        Entitled_Product__c objEntitledProduct = new Entitled_Product__c(Id = EP.Id);
                        objEntitledProduct.Archived__c = true;
                        lstEntitledProductsToArchive.add(objEntitledProduct);
                    }
                    else
                        lstDeletEntitledProducts.add(EP);
                }
                else{
                    setOldEntitledProducts.add(EP.Id);
                }
            }
            system.debug('lstDeletEntitledProducts'+lstDeletEntitledProducts);
            if(lstDeletEntitledProducts!=null &&lstDeletEntitledProducts.size()>0){
                Database.DeleteResult [] drList = Database.delete(lstDeletEntitledProducts);
                for (Database.DeleteResult  dr : drList) {
                    if (!dr.isSuccess()){
                        // Operation failed, so get all errors  
                        for(Database.Error err : dr.getErrors()) {          
                            GAM.CreateExceptionRecords('EntitledProductHandler-->createEntitledProducts-->delete of EP without Asses failed', err.getMessage(), dr.getId());
                        }
                    }
                }
            }

            if(!lstEntitledProductsToArchive.isEmpty()){ //<T07>
                Database.SaveResult[] srList = Database.update(lstEntitledProductsToArchive);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {          
                            GAM.CreateExceptionRecords('EntitledProductService-->createEntitledProducts-->archive of entitled products failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }
        }


        //Recalculate EP support level
        system.debug('setEntitledProductToRecalculate'+setEntitledProductToRecalculate);

        if(setOldEntitledProducts?.size()>0)
        setEntitledProductToRecalculate.addall(setOldEntitledProducts);

        if(setEntitledProductToRecalculate?.size()>0){
            updateEntitledProducts(setEntitledProductToRecalculate);
        }


        //Recalculate Support Account Support Level 
        if(setNewSupportAccountIds?.size()>0)
        setSupportAccountsToRecalculate.addall(setNewSupportAccountIds);

        if(setOldSupportAccountIds?.size()>0)
        setSupportAccountsToRecalculate.addall(setOldSupportAccountIds);

        system.debug('setSupportAccountsToRecalculate'+setSupportAccountsToRecalculate);

        if(!System.isBatch() && !System.isFuture()&& !Test.isRunningTest() && setSupportAccountsToRecalculate?.size()>0){
            SupportAccountService.updateSupportAccountsFuture(setSupportAccountsToRecalculate);
        }
        else if(setSupportAccountsToRecalculate?.size()>0){
            SupportAccountService.updateSupportAccounts(setSupportAccountsToRecalculate);
        }
        
        system.debug('Exit Method createEntitledProducts');
        
    }

    //---------------------------------------<T06>-----------------------------
    /*
	 Method Name : deleteOrgEntitledProduct
	 Description : This method deletes org entitled product junction records between org & entitled product based on assets.
	 Parameters	 : List<Asset>, called from createEntitledProducts, lstAssets asset records.
                   Set<Id>, called from createEntitledProducts, setOldSupportAccountIds support account record Ids.
	 Return Type : None.
	*/
    public static void deleteOrgEntitledProduct(List<Asset> lstAssets, Set<Id> setOldSupportAccountIds){
        
        Set<Id> setOrgIds = new Set<Id>();
        Set<Id> setEntitledProductIds = new Set<Id>();
        Set<Org_Entitled_Product__c> setOrgEntitledProductsToDelete = new Set<Org_Entitled_Product__c>(); //<T09>
        Map<String, Org_Entitled_Product__c> orgEntitledProductMap = new Map<String, Org_Entitled_Product__c>();

        for(Asset objAsset : lstAssets){
            if(objAsset.Org__c != null && objAsset.Entitled_Product__c != null){
                setOrgIds.add(objAsset.Org__c);
                setEntitledProductIds.add(objAsset.Entitled_Product__c);
            }
        }

        for(Org_Entitled_Product__c objOrgEntitledProduct : [SELECT Id,Org__c,Entitled_Product__c FROM Org_Entitled_Product__c WHERE Entitled_Product__r.Support_Account__c IN :setOldSupportAccountIds AND (Org__c IN :setOrgIds AND Entitled_Product__c IN :setEntitledProductIds) LIMIT 50000]){
            String strUniqueIdentifier = objOrgEntitledProduct.Org__c +'##'+ objOrgEntitledProduct.Entitled_Product__c;
            orgEntitledProductMap.put(strUniqueIdentifier, objOrgEntitledProduct);
        }

        for(Asset objAsset : lstAssets){
            String strUniqueIdentifier = objAsset.Org__c +'##'+ objAsset.Entitled_Product__c;
            if(orgEntitledProductMap.containsKey(strUniqueIdentifier)){
                setOrgEntitledProductsToDelete.add(orgEntitledProductMap.get(strUniqueIdentifier)); //<T09>
            }
        }

        if(!setOrgEntitledProductsToDelete.isEmpty()){ //<T09>
            List<Org_Entitled_Product__c> lstOrgEntitledProductsToDelete = new List<Org_Entitled_Product__c>(setOrgEntitledProductsToDelete); //<T09>
            Database.DeleteResult[] srList = Database.delete(lstOrgEntitledProductsToDelete, false);
            for (Database.DeleteResult sr : srList) {
                if (!sr.isSuccess()){               
                    for(Database.Error err : sr.getErrors()) {                  
                        GAM.CreateExceptionRecords('EntitledProductServive --> Delete of org entitled products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }

    /*
	 Method Name : createOrgEntitledProduct
	 Description : This method creates org entitled product junction records between newly created entitled product and org based on assets.
	 Parameters	 : Set<Id>, called from createEntitledProducts, setUpdatedAssetIds updated asset record Ids.
	 Return Type : None.
	*/
    public static void createOrgEntitledProduct(Set<Id> setUpdatedAssetIds){

        List<Asset> lstAssets = [SELECT Id,Org__c,Entitled_Product__c FROM Asset WHERE Id IN :setUpdatedAssetIds AND Org__c != null AND Entitled_Product__c != null LIMIT 50000]; 
        Set<Org_Entitled_Product__c> setOrgEntitledProductsToCreate = new Set<Org_Entitled_Product__c>();
        Map<String, Asset> orgEntitledProductMap = new Map<String, Asset>();
        Map<Id, List<Id>> entitledProductToOrgsMap = new Map<Id, List<Id>>();
        Set<Id> setOrgIds = new Set<Id>();
        Set<Id> setEntitledProductIds = new Set<Id>(); 

        for(Asset objAsset : lstAssets){
            String strUniqueIdentifier = objAsset.Org__c +'##'+ objAsset.Entitled_Product__c;
            orgEntitledProductMap.put(strUniqueIdentifier, objAsset);
            setOrgIds.add(objAsset.Org__c);
            setEntitledProductIds.add(objAsset.Entitled_Product__c);
        }

        for(Org_Entitled_Product__c objOrgEntitledProduct : [SELECT Id,Entitled_Product__c,Org__c FROM Org_Entitled_Product__c WHERE Entitled_Product__c IN :setEntitledProductIds OR Org__c IN :setOrgIds LIMIT 50000]){
            List<Id> lstOrgIds = entitledProductToOrgsMap.containsKey(objOrgEntitledProduct.Entitled_Product__c) ? entitledProductToOrgsMap.get(objOrgEntitledProduct.Entitled_Product__c) : new List<Id>();
            lstOrgIds.add(objOrgEntitledProduct.Org__c);
            entitledProductToOrgsMap.put(objOrgEntitledProduct.Entitled_Product__c, lstOrgIds);
        }

        for(String strUniqueIdentifier : orgEntitledProductMap.keyset()){
            Id orgId = orgEntitledProductMap.get(strUniqueIdentifier).Org__c;
            Id entitledProductId = orgEntitledProductMap.get(strUniqueIdentifier).Entitled_Product__c;
            Boolean boolSkip = false;

            if(entitledProductToOrgsMap.containsKey(entitledProductId)){
                if(entitledProductToOrgsMap.get(entitledProductId).contains(orgId)){
                    boolSkip = true;
                }
            }

            if(!boolSkip){
                Org_Entitled_Product__c objOrgEntitledProduct = new Org_Entitled_Product__c();
                objOrgEntitledProduct.Org__c = orgId;
                objOrgEntitledProduct.Entitled_Product__c = entitledProductId;
                setOrgEntitledProductsToCreate.add(objOrgEntitledProduct);
            }
        }

        if(!setOrgEntitledProductsToCreate.isEmpty()){
            List<Org_Entitled_Product__c> lstOrgEntitledProductsToCreate = new List<Org_Entitled_Product__c>(setOrgEntitledProductsToCreate);
            Database.SaveResult[] srList = Database.insert(lstOrgEntitledProductsToCreate, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){               
                    for(Database.Error err : sr.getErrors()) {                  
                        GAM.CreateExceptionRecords('EntitledProductServive --> Insert of org entitled products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
    //---------------------------------------</T06>-----------------------------

    //Rollup Entitled Product
    public static void updateEntitledProducts(Set<Id> setEntitledProductIds){


        system.debug('Enter Method updateEntitledProducts');

        // GlobalApexManager GAM = new GlobalApexManager(); //<T06>
        List<Entitled_Product__c> lstUpdateEntitledProduct = new List<Entitled_Product__c>();
        Map<Id,Entitlement> mapEPEntitlement = new map<id,Entitlement>();


        //Entitlement with highest support level and max end date
        /* Commented as part of <T03>
        for(Entitlement ent :[Select Id,Name,AssetId,Asset.Entitled_Product__c,Support_level__c,Enddate from Entitlement where Asset.Entitled_Product__c in :setEntitledProductIds and EndDate >= Today and Support_Level__c != null  order by Asset.Entitled_Product__c ,Support_Level__c desc ,Enddate desc]){
            if(!mapEPEntitlement.containskey(ent.Asset.Entitled_Product__c))
                mapEPEntitlement.put(ent.Asset.Entitled_Product__c,Ent);
        }
        system.debug('mapEPEntitlement'+mapEPEntitlement);
        //max end date
        AggregateResult[] agresDate = [Select max(EndDate) maxEndDate,Asset.Entitled_Product__c EP from Entitlement where Asset.Entitled_Product__c in :setEntitledProductIds  and EndDate >= Today group by Asset.Entitled_Product__c];
        for(AggregateResult ar :agresDate){
            system.debug('ar  ->'+ (Id)ar.get('EP'));
            Entitled_Product__c updateEP = new Entitled_Product__c (Id = (Id)ar.get('EP'));
            updateEP.Entitlement__c = mapEPEntitlement?.get((Id)ar.get('EP'))?.Id;
            updateEP.Support_Level__C =mapEPEntitlement?.get((Id)ar.get('EP'))?.Support_Level__c;
            updateEP.End_Date__c =(Date) ar.get('maxEndDate') ;
            lstUpdateEntitledProduct.add(updateEP);
        }
        */

        //---------------------------------------<T03>-------------------------------
        Set<String> setSupportLevels = new Set<String>();
        Map<String, Success_Offering__mdt> mapSuccessOfferingMDT = new Map<String, Success_Offering__mdt>();

        //Get success offering custom metadata records
        for(Success_Offering__mdt objSuccessOffering : Success_Offering__mdt.getAll().values()){

            //Check if the record is active and add it to the success offering map
            if(objSuccessOffering.Active__c){
                if(objSuccessOffering.Label != SIGNATURE_SUCCESS){
                    setSupportLevels.add(objSuccessOffering.Label);
                }
                mapSuccessOfferingMDT.put(objSuccessOffering.Label, objSuccessOffering);
            }
        }

        for(Entitlement objEntitlement : [Select Id,Name,AssetId,Asset.Entitled_Product__c,Support_Level__c,EndDate from Entitlement where Asset.Entitled_Product__c IN :setEntitledProductIds AND Support_Level__c IN :setSupportLevels order by Asset.Entitled_Product__c, EndDate DESC LIMIT 50000]){
            if(mapEPEntitlement.containsKey(objEntitlement.Asset.Entitled_Product__c)){

                //Check if the current entitlement's EndDate >= today and support level is higher in precedence, than that of existing entitlement
                Entitlement objEntitlementExisting = mapEPEntitlement.get(objEntitlement.Asset.Entitled_Product__c);
                if(objEntitlement.EndDate >= System.today() 
                    && (mapSuccessOfferingMDT.containsKey(objEntitlement.Support_Level__c) 
                    && (mapSuccessOfferingMDT.get(objEntitlement.Support_Level__c).Order_of_Precedence__c < mapSuccessOfferingMDT.get(objEntitlementExisting.Support_Level__c).Order_of_Precedence__c))){

                    mapEPEntitlement.put(objEntitlement.Asset.Entitled_Product__c, objEntitlement);
                }
            }
            else{
                mapEPEntitlement.put(objEntitlement.Asset.Entitled_Product__c, objEntitlement);
            }
        }

        for(Id entitledProductId : mapEPEntitlement.keySet()){
            Entitled_Product__c objEntitledProduct = new Entitled_Product__c(Id = entitledProductId);
            objEntitledProduct.Entitlement__c = mapEPEntitlement.get(entitledProductId).Id;
            objEntitledProduct.Support_Level__c = mapEPEntitlement.get(entitledProductId).Support_Level__c;
            objEntitledProduct.End_Date__c = mapEPEntitlement.get(entitledProductId).EndDate;
            lstUpdateEntitledProduct.add(objEntitledProduct);
        }
        //---------------------------------------</T03>------------------------------

        system.debug('lstUpdateEntitledProduct'+lstUpdateEntitledProduct);

        if(lstUpdateEntitledProduct!=null &&lstUpdateEntitledProduct.size()>0){
            
            Database.SaveResult[] srList = Database.update(lstUpdateEntitledProduct);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('EntitlementProductHandler-->updateEntitledProduct-->rollup entitled Product failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        system.debug('Exit Method updateEntitledProducts');


    }


}