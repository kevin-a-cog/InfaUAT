/* 
 Class:         CreateEntitlementPerAsset
@Author:        Anil  Solanki
@Created Date:  26 - DEC -2019
@Description:   SALESRT-11333 & F2A-223
This class is being used Creating Entitlements for Child Assets in a Bundle.This class will be called  15 minutes after contract creation.
*/
/*
Change History
**************************************************************************************************************************
ModifiedBy          Date          Requested By        Description                                               Tag
Ambica Pyati        1/15/2020     Sarojini        F2A-223  Create all enetitlements after Contarct 
Wasim Akram         2/12/2020     Keerthana       SALESRT-11618 Moving the Contract Process Builder assign              
                                                  BillingAdress Logic                                           <T01>
Vignesh D           10/5/2020                     F2A-224 Asset & Entitlement revamp                            <T02>
Ambica              1/23/2021     I2RT            Map Support Level and EntitlementProcess                      <T03>
Vignesh D           12/23/2021    I2RT-4972       Populate entitlement support level based on                   <T04>
                                                  Support Level Mapping metadata 
Vignesh D           05/03/2022    I2RT-5898       Return the list of entitlements to be created                 <T05>
Vignesh D           03/22/2023    I2RT-7869       For migrated subscriptions use the start & end date from      <T06>
                                                  subscription to populate start & end date on entitlement
**************************************************************************************************************************
*/
public class CreateEntitlementPerAsset {
    
    public static globalApexManager GAM = new globalApexManager();
    
    public static List<Entitlement> getEntitlement(List<Contract> contracts, Map<Id, SBQQ__Subscription__c> MapSubAsset){
        //<T01>
        assignContractBillingAddress(contracts);
        //</T01>
        //Get set of Contract Ids
        Set<Id> contractIds= new Set<Id>((new Map<Id,Contract>(contracts)).keyset());
        
        //Lis of Assets
        Set<Asset> setAssets = new Set<Asset>();
        
        //List of entitlements to be created
        List<Entitlement> lstNewEntitleMents = new List<Entitlement>();
        
        //Map of Asset grouped by root
        Map<Id,List<Asset>> MapParentSubIdAssets = new map<id,List<Asset>>();
        
        //Map of Support Subscription with Orginal parent Subscription
        Map<Id,Id> MapOriginalParentSubscriptions = new map<id,id>();
        
        //Map of EntitlementProcesses by Support level
        Map<String,Id> mapEntitlementProcess = new Map<String,Id>(); //<T03>

        //Map of Support Level
        Map<String, String> mapSupportLevel = new Map<String, String>(); //<T04>

        //Map of entitlement with Quote line
        //<T02> Map <Id,List<Entitlement>> MapQuoteEntitlement = new Map<Id,List<Entitlement>>();
        
        
        //update Assetslookup with subscription lines
       /* <T02>
       List<SBQQ__Subscription__c> lstSubscription = new List<SBQQ__Subscription__c>( [select id,SBQQ__Quantity__c,SBQQ__QuoteLine__c,SBQQ__Product__r.name from SBQQ__Subscription__c where SBQQ__Contract__c IN: contractIds]);
       SubscriptionTriggerHandler.updateAssetLookup(lstSubscription); 
       */ 
        
        
        
        //Map of subscriptions under contract
        Map<Id,SBQQ__Subscription__c> MapSubscriptions = new map <id,SBQQ__Subscription__c> ([Select Id,
                                                                                              SBQQ__StartDate__c,
                                                                                              SBQQ__EndDate__c,
                                                                                              SBQQ__Quantity__c,
                                                                                              SBQQ__Account__c,  
                                                                                              SBQQ__RootId__c,
                                                                                              SBQQ__RequiredById__c,
                                                                                              SBQQ__Product__r.Name,
                                                                                              SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.ServiceDate,
                                                                                              SBQQ__OrderProduct__r.EndDate,
                                                                                              SBQQ__OrderProduct__r.product2.Name,
                                                                                              SBQQ__OrderProduct__r.product2.Maintenance_Level__c,
                                                                                              SBQQ__OrderProduct__r.product2.Product_family__c,
                                                                                              SBQQ__OrderProduct__r.product2.Generates_Entitlement__c ,
                                                                                              SBQQ__Product__r.Generates_Entitlement__c, 
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,  
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,    
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,                                            
                                                                                              (Select id from SBQQ__CoveredAssets__r where Status != 'Cancelled' )
                                                                                              from SBQQ__Subscription__c  
                                                                                              where SBQQ__Contract__c IN: contractIds]);
        
      
        
        for(SBQQ__Subscription__c sub : MapSubscriptions.values()){            
            //Add all assets 
            if( sub.SBQQ__CoveredAssets__r.size()>0){
                setAssets.addall(sub.SBQQ__CoveredAssets__r);
            }            
            // Child products in bundle
            if( sub.SBQQ__RequiredById__c != null 
               && sub.SBQQ__CoveredAssets__r.size()>0){
                   
                   if( !MapParentSubIdAssets.containsKey(sub.SBQQ__RequiredById__c)){
                       MapParentSubIdAssets.put(sub.SBQQ__RequiredById__c, new List<Asset>(sub.SBQQ__CoveredAssets__r));
                   }
                   else{
                       MapParentSubIdAssets.get(sub.SBQQ__RequiredById__c).addall(sub.SBQQ__CoveredAssets__r);
                   }
                   
               }
            // Nested products in bundle
            if(sub.SBQQ__RequiredById__c != null 
               && sub.SBQQ__RootId__c != sub.SBQQ__RequiredById__c 
               &&  sub.SBQQ__CoveredAssets__r.size()>0){
                   if( !MapParentSubIdAssets.containsKey(sub.SBQQ__RootId__c)){
                       MapParentSubIdAssets.put(sub.SBQQ__RootId__c, new List<Asset>(sub.SBQQ__CoveredAssets__r));
                   }
                   else{
                       Set<Asset> tempset = new Set<Asset>();
                       tempset.addall(MapParentSubIdAssets.get(sub.SBQQ__RootId__c));
                       if( !tempset.containsall(sub.SBQQ__CoveredAssets__r))
                           MapParentSubIdAssets.get(sub.SBQQ__RootId__c).addall(sub.SBQQ__CoveredAssets__r);
                   }
               }
            //Support product in bundle
            else if(sub.SBQQ__RequiredById__c != null
                    && (sub.SBQQ__OrderProduct__r.product2.Generates_Entitlement__c || (sub.SBQQ__OrderProduct__c == null && sub.SBQQ__Product__r.Generates_Entitlement__c))
                    && sub.SBQQ__Quantity__c > 0
                   // && sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c == Label.Product2_Product_Family_Support
                    && MapSubscriptions.get(sub.SBQQ__RequiredById__c).SBQQ__CoveredAssets__r.size()>0 ){ 
                        if( !MapParentSubIdAssets.containsKey(sub.SBQQ__RequiredById__c)){
                            MapParentSubIdAssets.put(sub.SBQQ__RequiredById__c, new List<Asset>(MapSubscriptions.get(sub.SBQQ__RequiredById__c).SBQQ__CoveredAssets__r));
                        }
                        else{
                            MapParentSubIdAssets.get(sub.SBQQ__RequiredById__c).addall(MapSubscriptions.get(sub.SBQQ__RequiredById__c).SBQQ__CoveredAssets__r);
                        }
                        
                    }
            //Only support products
            //get original parent subscriptionids incase of ammend/ renewal of support products
            else if( sub.SBQQ__RequiredById__c==null
                    && sub.SBQQ__OrderProduct__r.product2.Generates_Entitlement__c
                    // && sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c == Label.Product2_Product_Family_Support
                    ){
                        //Ammend
                        if(sub.SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c != null){
                            MapOriginalParentSubscriptions.put(sub.id,sub.SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c);
                        }
                        //Renewal
                        else if (sub.SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__c != null){
                            MapOriginalParentSubscriptions.put(sub.id,sub.SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__c);
                        }   
                    }
        }        
        //Get Assets associated to Orginal Subscriptions
        Map<Id,SBQQ__Subscription__c> MapOriginalSubscriptionAssets = new map <id,SBQQ__Subscription__c> ([Select Id,
                                                                                                           SBQQ__RootId__c,
                                                                                                           SBQQ__Account__c,                                       
                                                                                                           SBQQ__RequiredById__c,
                                                                                                           SBQQ__OrderProduct__c,
                                                                                                           SBQQ__OrderProduct__r.ServiceDate,
                                                                                                           SBQQ__OrderProduct__r.EndDate,
                                                                                                           SBQQ__OrderProduct__r.product2.Name,
                                                                                                           SBQQ__OrderProduct__r.product2.Maintenance_Level__c,
                                                                                                           SBQQ__OrderProduct__r.product2.Product_family__c,
                                                                                                           SBQQ__OrderProduct__r.product2.Generates_Entitlement__c , 
                                                                                                           SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,     
                                                                                                           SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c,                                                              
                                                                                                           SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                                           SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c ,                                          
                                                                                                           (Select id from SBQQ__CoveredAssets__r where Status != 'Cancelled')
                                                                                                           from SBQQ__Subscription__c  
                                                                                                           where id in :MapOriginalParentSubscriptions.values()]);
        
        
        // Add all asset
        for (  SBQQ__Subscription__c sub : MapOriginalSubscriptionAssets.values()){
            if( sub.SBQQ__CoveredAssets__r.size()>0){
                setAssets.addall(sub.SBQQ__CoveredAssets__r);
            }    
        }        
        
        For( SlaProcess sp :[Select Id, Name from SlaProcess where isActive =true]){
            mapEntitlementProcess.put(sp.Name,sp.Id);
        }

        //---------------------------------------<T04>-----------------------------

        //Get support level picklist values
        Schema.DescribeFieldResult objFieldDescribe = Support_Level_Mapping__mdt.Support_Level__c.getDescribe();
        for (Schema.PicklistEntry objPickList : objFieldDescribe.getPickListValues()) {

            //Add an entry for each support level
            mapSupportLevel.put(objPickList.getValue(), objPickList.getValue());
        }

        //Get support level mapping custom metadata type records
        Map<String, Support_Level_Mapping__mdt> mapSupportLevelMapping = Support_Level_Mapping__mdt.getAll();
        for(String strSupportLevelMapping : mapSupportLevelMapping.keySet()){

            //Check if the record is active and add it to the support level map
            if(mapSupportLevelMapping.get(strSupportLevelMapping).Active__c){
                mapSupportLevel.put(mapSupportLevelMapping.get(strSupportLevelMapping).Label, mapSupportLevelMapping.get(strSupportLevelMapping).Support_Level__c);
            }
        }

        //---------------------------------------</T04>----------------------------

        // map<Id,Asset> allAssets = new Map<id,Asset>(new List<Asset>(setAssets));
        Map<Id,Asset>  MapAllAssets = new map <id,Asset> ( [Select id,(select id, name, AccountId,StartDate,EndDate,Order_Product__c,Subscription__c,Assetid from Entitlements) from Asset where id in : setAssets]);
        
        // create entitlements for each asset assocaited to parent subscription
        for(SBQQ__Subscription__c sub : MapSubscriptions.values()){
            if( (sub.SBQQ__OrderProduct__r.product2.Generates_Entitlement__c 
               // && sub.SBQQ__OrderProduct__r.product2.product_family__c == Label.Product2_Product_Family_Support 
               && sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c >0
               && sub.SBQQ__Quantity__c > 0) || (sub.SBQQ__OrderProduct__c == null && sub.SBQQ__Product__r.Generates_Entitlement__c && sub.SBQQ__Quantity__c >0)){ 
                   //Bundles     
                   if( sub.SBQQ__RequiredById__c!=null && MapParentSubIdAssets.containskey(sub.SBQQ__RequiredById__c)){
                       for( Asset a :MapParentSubIdAssets.get(sub.SBQQ__RequiredById__c)) {       
                           
                           //check if asset has entitlement    
                           Boolean EntitlementPresent = false; 

                            for(Entitlement en: MapAllAssets.get(a.Id).Entitlements ){
                                if(en.AccountId == sub.SBQQ__Account__c &&
                                    en.Subscription__c == sub.Id &&
                                    en.AssetId == a.Id){
                                        EntitlementPresent = true;

                                        if(sub.SBQQ__OrderProduct__c != null && (en.StartDate != sub.SBQQ__OrderProduct__r.ServiceDate || en.EndDate != sub.SBQQ__OrderProduct__r.EndDate)){ //<T06>
                                            en.StartDate = sub.SBQQ__OrderProduct__r.ServiceDate;
                                            en.EndDate = sub.SBQQ__OrderProduct__r.EndDate;
                                            lstNewEntitleMents.add(en);
                                            break;
                                        }
                                        else if(sub.SBQQ__OrderProduct__c == null && (en.StartDate != sub.SBQQ__StartDate__c || en.EndDate != sub.SBQQ__EndDate__c)){ //<T06>
                                            en.StartDate = sub.SBQQ__StartDate__c;
                                            en.EndDate = sub.SBQQ__EndDate__c;
                                            lstNewEntitleMents.add(en);
                                            break;
                                        }

                                    }
                            }

                            if(!EntitlementPresent){
                                Entitlement ent = new Entitlement();
                                ent.Name = sub.SBQQ__OrderProduct__r.product2.Name != null ? sub.SBQQ__OrderProduct__r.product2.Name : sub.SBQQ__Product__r.Name;
                                ent.Support_Level__c = mapSupportLevel.containsKey(sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c) ? mapSupportLevel.get(sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c) : sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c; //<T03> //<T04>
                                ent.SlaProcessId = mapEntitlementProcess?.get(ent.Support_Level__c);//<T03> //<T04>
                                ent.AccountId = sub.SBQQ__Account__c;
                                ent.StartDate = sub.SBQQ__OrderProduct__r.ServiceDate != null ? sub.SBQQ__OrderProduct__r.ServiceDate : sub.SBQQ__StartDate__c;
                                ent.EndDate= sub.SBQQ__OrderProduct__r.EndDate != null ? sub.SBQQ__OrderProduct__r.EndDate : sub.SBQQ__EndDate__c;
                                ent.Order_Product__c = sub.SBQQ__OrderProduct__c;
                                ent.Subscription__c= sub.id;
                                ent.Assetid = a.id;

                                lstNewEntitleMents.add(ent);
                            }
                       }
                       
                   }
                   //Renewals of Support only
                   else if(sub.SBQQ__RequiredById__c==null && MapOriginalParentSubscriptions.containskey(sub.id)){
                       for (Asset a: MapOriginalSubscriptionAssets.get(MapOriginalParentSubscriptions.get(sub.id)).SBQQ__CoveredAssets__r){
                           
                           //check if asset has entitlement    
                           Boolean EntitlementPresent = false; 

                           for(Entitlement en: MapAllAssets.get(a.Id).Entitlements ){
                               if(en.AccountId == sub.SBQQ__Account__c &&
                                   en.Subscription__c == sub.Id &&
                                   en.AssetId == a.Id){
                                       EntitlementPresent = true;

                                       if(en.StartDate != sub.SBQQ__OrderProduct__r.ServiceDate || en.EndDate != sub.SBQQ__OrderProduct__r.EndDate){
                                           en.StartDate = sub.SBQQ__OrderProduct__r.ServiceDate;
                                           en.EndDate = sub.SBQQ__OrderProduct__r.EndDate;
                                           lstNewEntitleMents.add(en);
                                           break;
                                       }

                                   }
                           }

                           if(!EntitlementPresent){
                               Entitlement ent = new Entitlement();
                               ent.Name = sub.SBQQ__OrderProduct__r.product2.Name != null ? sub.SBQQ__OrderProduct__r.product2.Name : sub.SBQQ__Product__r.Name;
                               ent.Support_Level__c = mapSupportLevel.containsKey(sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c) ? mapSupportLevel.get(sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c) : sub?.SBQQ__OrderProduct__r?.product2?.Maintenance_Level__c; //<T03> //<T04>
                               ent.SlaProcessId = mapEntitlementProcess?.get(ent.Support_Level__c);//<T03> //<T04>
                               ent.AccountId = sub.SBQQ__Account__c;
                               ent.StartDate = sub.SBQQ__OrderProduct__r.ServiceDate != null ? sub.SBQQ__OrderProduct__r.ServiceDate : sub.SBQQ__StartDate__c;
                               ent.EndDate= sub.SBQQ__OrderProduct__r.EndDate != null ? sub.SBQQ__OrderProduct__r.EndDate : sub.SBQQ__EndDate__c;
                               ent.Order_Product__c = sub.SBQQ__OrderProduct__c;
                               ent.Subscription__c= sub.id;
                               ent.Assetid = a.id;

                               lstNewEntitleMents.add(ent);
                           }  
                       }
                   }
               }
        }               
        
        
        GAM.CreateLogs('CreateEntitlementPerAsset.getEntitlement', 'Entitlements to be Created ' + lstNewEntitleMents);

        System.debug('MapSubAsset.key --> '+MapSubAsset.keySet());
        System.debug('MapSubAsset.values --> '+MapSubAsset.values());
        
        //<T02>
        for(Asset a: [Select Id,Status,SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__OrderProduct__r.Order.Generate_Date__c,(Select Id,Subscription__c,Subscription__r.SBQQ__Contract__c,StartDate from Entitlements) from Asset where Id IN :MapSubAsset.keySet()]){

            for(Entitlement en: a.Entitlements){
                if(a.Status == 'Cancelled' && en.Subscription__r.SBQQ__Contract__c == a.SBQQ__CurrentSubscription__r.SBQQ__Contract__c){
                    en.EndDate = en.StartDate <= System.today() ? System.today() : en.StartDate;
                    lstNewEntitleMents.add(en);
                }
                else if(a.Status != 'Cancelled'){
                    if(MapSubAsset.containsKey(a.Id)){
                        SBQQ__Subscription__c sub = MapSubAsset.get(a.Id);
                        if(en.Subscription__r.SBQQ__Contract__c == sub.SBQQ__Contract__c){
                            System.debug('sub -->'+sub);
                            en.EndDate = en.StartDate <= System.today() ? System.today() : en.StartDate;
                            lstNewEntitleMents.add(en);
                        }
                    }
                }
            }

        }
        //<T02>
        
        return lstNewEntitleMents; //<T05>
        //Upsert Entitlements
        //if(lstNewEntitleMents.size() > 0){
            
            //upsert lstNewEntitleMents;

            /* <T02>
            try {
                insert lstNewEntitleMents;  
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('CreateEntitlementPerAsset', 'Error while generating Entitlements for all Assets',e.getMessage());
            }
            GAM.InsertDebugLogs();
            */
        //}
        
        
         /*
        //Insert Entitlements
        if(lstNewEntitleMents.size() > 0){
            try {
                insert lstNewEntitleMents;  
                
                List<Contract> ContractsToUpdateWithSuccess = new List<Contract>();
                for(Contract con : contracts){
                    con.Entitlement_Creation_Status__c = 'Completed';
                    ContractsToUpdateWithSuccess.add(con);
                }
                
                if(ContractsToUpdateWithSuccess.size() > 0){
                    update ContractsToUpdateWithSuccess;
                }
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('CreateEntitlementPerAsset', 'Error while generating Entitlements for all Assets',e.getMessage());
                
                List<Contract> ContractsToUpdateWithError = new List<Contract>();
                for(Contract con : contracts){
                    con.Entitlement_Creation_Status__c = 'Failed';
                    con.Entitlement_Creation_Error_Message__c = e.getMessage();
                    ContractsToUpdateWithError.add(con);
                }
                
                if(ContractsToUpdateWithError.size() > 0){
                    update ContractsToUpdateWithError;
                }
            }
            GAM.InsertDebugLogs();
        }
        */
        
        
        
        
        
        // Update quotelines with entitlementId
        /* <T02>
        List<SBQQ__QuoteLine__c> updateQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        for(Id quoteLineId : MapQuoteEntitlement.keySet()){
            
            Entitlement ent = MapQuoteEntitlement.get(quoteLineId)[0];
            updateQuoteLines.add(new SBQQ__QuoteLine__c(
                Id = quoteLineId,
                Related_Entitlement__c = ent.Id
            ));  
        }
        
        if(updateQuoteLines.size() > 0){
            Database.update(updateQuoteLines, false);    
        }
        */
        
    }
    //<T01>
    public static void assignContractBillingAddress(List<Contract> listContract){
        Set<Contract> setContract = new Set<Contract>();
        List<Contract> listContractUpdate = new List<Contract>();
        for(Contract objCon : listContract)
        {
            setContract.add(objCon);
        }
        for(Contract objContract : [SELECT Id,BillingAddress,ShippingAddress,
                                    SBQQ__Order__r.BillingCity,SBQQ__Order__r.BillingCountry,SBQQ__Order__r.BillingPostalCode,SBQQ__Order__r.BillingState,
                                    SBQQ__Order__r.BillingStreet,SBQQ__Order__r.ShippingCity,SBQQ__Order__r.ShippingCountry,SBQQ__Order__r.ShippingPostalCode,
                                    SBQQ__Order__r.ShippingState,SBQQ__Order__r.ShippingStreet FROM Contract WHERE Id IN :setContract])
        {
            if(objContract.BillingAddress == null && objContract.ShippingAddress == null && objContract.SBQQ__Order__r != null){
            objContract.BillingCity = objContract.SBQQ__Order__r.BillingCity != null ? objContract.SBQQ__Order__r.BillingCity.left(40) : '';
            objContract.BillingCountry = objContract.SBQQ__Order__r.BillingCountry != null ? objContract.SBQQ__Order__r.BillingCountry.left(80) : '';
            objContract.BillingPostalCode = objContract.SBQQ__Order__r.BillingPostalCode != null ? objContract.SBQQ__Order__r.BillingPostalCode.left(20) : '';
            objContract.BillingState = objContract.SBQQ__Order__r.BillingState != null ? objContract.SBQQ__Order__r.BillingState.left(80) : '';
            objContract.BillingStreet = objContract.SBQQ__Order__r.BillingStreet != null ? objContract.SBQQ__Order__r.BillingStreet.left(255) : '';
            
            objContract.ShippingCity = objContract.SBQQ__Order__r.ShippingCity != null ? objContract.SBQQ__Order__r.ShippingCity.left(40) : '';
            objContract.ShippingCountry = objContract.SBQQ__Order__r.ShippingCountry != null ? objContract.SBQQ__Order__r.ShippingCountry.left(80) : '';
            objContract.ShippingPostalCode = objContract.SBQQ__Order__r.ShippingPostalCode != null ? objContract.SBQQ__Order__r.ShippingPostalCode.left(20) : '';
            objContract.ShippingState = objContract.SBQQ__Order__r.ShippingState != null ? objContract.SBQQ__Order__r.ShippingState.left(80) : '';
            objContract.ShippingStreet = objContract.SBQQ__Order__r.ShippingStreet != null  ? objContract.SBQQ__Order__r.ShippingStreet.left(255) : '';
            listContractUpdate.add(objContract);
            }
        }
        if(listContractUpdate.size() >0)
        update listContractUpdate;
    }
    //</T01>
}