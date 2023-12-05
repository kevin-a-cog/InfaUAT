/*
Class:          AssetCreationBatchHandler 
@Author:        Vignesh D
@Created Date:  25 September 2020
@Description:   Handler class to process Contracts for Assets & Entitlements

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                      Tag
********************************************************************************************************************************************
Pavithra V       13-11-2020     F2A-316                         Error in Migrated contracts									     <T01>
Vignesh D        03-05-2022     I2RT-5898                       Error handling to check and allow DML processing before asset &  <T03>
                                                                entitlements create/update                                       
*/

public with sharing class AssetCreationBatchHandler {

    // <T03> Extend Exception class to throw custom exception
    public virtual class BaseException extends Exception {}
    public class CustomException extends BaseException {}
    
    /** <T01> Pavithra - To assign the prior subscriptions and its related assets */
    public static Map<Id, List<Asset>> priorSubscriptionAssetsMap = new Map<Id, List<Asset>>();
    
    //To identify whether a Product is Perpetual/Subscription based on the Offering Type
    private final static Set<String> perpetualOfferingTypes = new Set<String>{'On-Premise One Time Term License','On-Premise Perpetual License'};

    //Map to store debooked assets and their current subscription to cancel the entitlements
    private static Map<Id, SBQQ__Subscription__c> MapOfSubAsset = new Map<Id, SBQQ__Subscription__c>();
    
    public static void handleAssets(Contract c){

        String ContractId = c.Id; //Contract Id
        String OrderId = c.SBQQ__Order__c; //Order associated with the Contract
        Map<Id, SBQQ__Subscription__c> newSubLines = new Map<Id, SBQQ__Subscription__c>(); //Map of new subscription lines and migrated contract's subscription lines
        Map<Id, SBQQ__Subscription__c> renewedSubLines = new Map<Id, SBQQ__Subscription__c>(); //Map of renewed subscription lines
        Map<Id, SBQQ__Subscription__c> amendedSubLines = new Map<Id, SBQQ__Subscription__c>(); //Map of amended subscription lines
        Map<Id, List<SBQQ__Subscription__c>> originalToAmendedSubLines = new Map<Id, List<SBQQ__Subscription__c>>(); //Map of orginal and amended subscription lines
        Set<Id> priorSubscriptionIds = new Set<Id>(); //Set of prior subscription Ids to query the prior assets
        List<Asset> lstAssets = new List<Asset>(); //List of Assets to create
        List<Asset> debookedAssets = new List<Asset>(); //List of Assets to debook
        Set<Id> orderIds = new Set<Id>(); //Set of OrderIds to update the Asset_Creation_Status__c to Completed for all the Orders associated to the Contract/Subscription Lines


        Map<Id, SBQQ__Subscription__c> MapSubscriptions = new Map<Id, SBQQ__Subscription__c> ([Select Id,
                                                                                            SBQQ__Contract__c,
                                                                                            SBQQ__Quantity__c,
                                                                                            SBQQ__QuoteLine__c,
                                                                                            SBQQ__StartDate__c,
                                                                                            SBQQ__EndDate__c,
                                                                                            SBQQ__Product__r.Id,
                                                                                            SBQQ__Account__r.Id,
                                                                                            SBQQ__Product__r.Name,
                                                                                            SBQQ__Product__r.Offering_Type__c,
                                                                                            SBQQ__Product__r.SBQQ__AssetConversion__c,
                                                                                            SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, 
                                                                                            SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,
                                                                                            SBQQ__OrderProduct__c,
                                                                                            SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c,
                                                                                            SBQQ__OrderProduct__r.Product2.Offering_Type__c,
                                                                                            SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,
                                                                                            SBQQ__OrderProduct__r.Product2Id,
                                                                                            SBQQ__OrderProduct__r.SBQQ__OrderedQuantity__c,
                                                                                            SBQQ__OrderProduct__r.Order.accountId,
                                                                                            SBQQ__OrderProduct__r.Id,
                                                                                            SBQQ__OrderProduct__r.Product2.Name,
                                                                                            SBQQ__OrderProduct__r.Ship_Date__c,
                                                                                            SBQQ__OrderProduct__r.ServiceDate,
                                                                                            SBQQ__OrderProduct__r.EndDate,
                                                                                            SBQQ__OrderProduct__r.Order.Generate_Date__c,
                                                                                            (Select id,
                                                                                            InstallDate,
                                                                                            SBQQ__CurrentSubscription__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__Contract__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionStartDate__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionEndDate__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                            SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,
                                                                                            SBQQ__SubscriptionStartDate__c
                                                                                            from SBQQ__CoveredAssets__r 
                                                                                            where Status != 'Cancelled' order by Id DESC) 
                                                                                            from SBQQ__Subscription__c 
                                                                                            where SBQQ__Contract__c =: ContractId]);

        for(SBQQ__Subscription__c sub: MapSubscriptions.values()){

            if(sub.SBQQ__OrderProduct__c != null){
                orderIds.add(sub.SBQQ__OrderProduct__r.OrderId);
            }
    
            //New Subscription Lines or Migrated Contract Subscription Lines
            if((sub.SBQQ__QuoteLine__c != null && sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == null) || (sub.SBQQ__QuoteLine__c == null && sub.SBQQ__OrderProduct__c == null)){
                newSubLines.put(sub.Id, sub);
            }
    
            //Renewed Subscription Lines
            else if(sub.SBQQ__QuoteLine__c != null && sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null && sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == null){
                renewedSubLines.put(sub.Id, sub);
                priorSubscriptionIds.add(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
            }

            //Amended Subscrption Lines
            else if(sub.SBQQ__QuoteLine__c != null && sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null){
                amendedSubLines.put(sub.Id, sub);
                if(!originalToAmendedSubLines.containsKey(sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c)){
                    originalToAmendedSubLines.put(sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c, new List<SBQQ__Subscription__c>{sub});
                }
                else{
                    List<SBQQ__Subscription__c> tempLst = originalToAmendedSubLines.get(sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);
                    tempLst.add(sub);
                    originalToAmendedSubLines.put(sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c, tempLst);
                }
            }

        }


        //New Subscripton Lines
        for(SBQQ__Subscription__c newSub: newSubLines.values()){
                
            //New Subscription Line without any Amend subscription line
            if(!originalToAmendedSubLines.containsKey(newSub.Id)){
                //Create Assets only when the sub line doesn't have assets
                if(newSub.SBQQ__CoveredAssets__r.size() == 0){
                    
                    if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit || 
                        (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit)){

                        lstAssets.addAll(burstAsset(newSub, (Integer)newSub.SBQQ__Quantity__c, newSub.Id));
                            
                    }
                    else if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line' || 
                            (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == 'One per quote line')){
                            
                        lstAssets.add(nonBurstAsset(newSub, (Integer)newSub.SBQQ__Quantity__c, newSub.Id));
                        
                    }

                }
            }

            //New Subscription Line with Amend subscription lines
            else if(originalToAmendedSubLines.containsKey(newSub.Id)){

                Integer originalQty = (Integer)newSub.SBQQ__Quantity__c;
                Integer amendedQty = 0;
                Integer noOfAssets = newSub.SBQQ__CoveredAssets__r.size();

                for(SBQQ__Subscription__c amendSub: originalToAmendedSubLines.get(newSub.Id)){
                    amendedQty = amendedQty + (Integer)amendSub.SBQQ__Quantity__c;
                }
                Integer currentQty = originalQty + amendedQty;

                SBQQ__Subscription__c lastAmendedSubLine = new SBQQ__Subscription__c();
                if(originalToAmendedSubLines.get(newSub.Id).size() != null && originalToAmendedSubLines.get(newSub.Id).size() > 0){
                    lastAmendedSubLine = originalToAmendedSubLines.get(newSub.Id)[originalToAmendedSubLines.get(newSub.Id).size() - 1];
                }

                System.debug('**************************************************************');
                System.debug('newSub --> Name='+newSub.SBQQ__OrderProduct__r.Product2.Name);
                System.debug('newSub --> Quantity='+newSub.SBQQ__Quantity__c);
                System.debug('originalQty='+originalQty+'  amendedQty='+amendedQty+'  currentQty='+currentQty);
                System.debug('lastAmendedSubLine --> '+lastAmendedSubLine);
                System.debug('newSub.SBQQ__CoveredAssets__r.size = '+newSub.SBQQ__CoveredAssets__r.size());
                System.debug('**************************************************************');
                
                if(newSub.SBQQ__CoveredAssets__r.size() == 0){

                    if(currentQty > 0){
                        if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit ||
                            (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit)){

                            lstAssets.addAll(burstAsset(lastAmendedSubLine, currentQty, newSub.Id));

                        } 
                        else if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line' || 
                                (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == 'One per quote line')){

                            lstAssets.add(nonBurstAsset(lastAmendedSubLine, currentQty, newSub.Id));

                        }                   
                    }

                }
                else if(newSub.SBQQ__CoveredAssets__r.size() > 0){ 

                    if(currentQty <= 0){
                        
                        for(Asset a: newSub.SBQQ__CoveredAssets__r){
                            a.Status = 'Cancelled';
                            a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.Generate_Date__c;
                            a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__c;
                            a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__QuoteLine__c;
                            MapOfSubAsset.put(a.Id, newSub);
                            debookedAssets.add(a);
                        }

                    }
                    
                    if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit || 
                        (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit)){

                        if(currentQty > 0 && currentQty > noOfAssets){

                            Integer burstQty = currentQty - noOfAssets;
                            lstAssets.addAll(burstAsset(lastAmendedSubLine, currentQty, newSub.Id));
        
                        }
                        else if(currentQty > 0 && currentQty < noOfAssets){
                            Integer decreasedQty = noOfAssets - currentQty;

                            Integer count = 0;
                            for(Asset a: newSub.SBQQ__CoveredAssets__r){
                                if(count < decreasedQty){
                                    count++;
                                    a.Status = 'Cancelled';
                                    a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.Generate_Date__c;
                                    a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__c;
                                    a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__QuoteLine__c;
                                    MapOfSubAsset.put(a.Id, newSub); 
                                    debookedAssets.add(a);
                                }
                                else{
                                    break;
                                }
                            }
                        
                        }
                        
                    }
                    else if(newSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line' || 
                            (newSub.SBQQ__OrderProduct__c == null && newSub.SBQQ__Product__r.SBQQ__AssetConversion__c == 'One per quote line')){

                        if(currentQty > 0){

                            for(Asset a: newSub.SBQQ__CoveredAssets__r){
                                        a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                                        a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Id;
                                        //a.Original_Order_Product__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Id;
                                        a.SBQQ__CurrentSubscription__c = newSub.Id;
                                        a.Quantity = currentQty;
                                        a.Product2Id = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2Id;
                                        a.Name = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Name;
                                        a.accountId = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                        a.AssetServicedById = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                        a.Status ='Provisioning Complete' ;
                                        //a.SBQQ__SubscriptionStartDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.ServiceDate;
                            
                                        if(lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c != null && a.InstallDate == null){
                                            a.InstallDate = lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c;
                                        }
                            
                                        if(perpetualOfferingTypes.contains(lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                                            a.SBQQ__SubscriptionEndDate__c = null;
                                        }
                                        else{
                                            a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.EndDate;
                                        }
                                
                                lstAssets.add(a);
                            }
                        }

                    }

                }
            }
        }


        //Query all the Prior Subscription Assets and Create a Map of PriorSubscription and Assets
        //Map<Id, List<Asset>> priorSubscriptionAssetsMap = new Map<Id, List<Asset>>(); /** Commented this line <T01>**/
        
        List<Asset> priorSubscriptionAssets = [Select Id,
                                                Quantity,
                                                Status,
                                                InstallDate,
                                                SBQQ__QuoteLine__c,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionStartDate__c,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionEndDate__c,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,
                                                SBQQ__OrderProduct__c,
                                                Original_Order_Product__c,
                                                SBQQ__CurrentSubscription__c,
                                                SBQQ__SubscriptionStartDate__c,
                                                SBQQ__SubscriptionEndDate__c
                                                from Asset 
                                                where SBQQ__CurrentSubscription__c IN :priorSubscriptionIds
                                                and Status != 'Cancelled'];
                                            
        for(Asset a: priorSubscriptionAssets){
            if(!priorSubscriptionAssetsMap.containsKey(a.SBQQ__CurrentSubscription__c)){
                priorSubscriptionAssetsMap.put(a.SBQQ__CurrentSubscription__c, new List<Asset>{a});
            }
            else{
                List<Asset> tempLst = priorSubscriptionAssetsMap.get(a.SBQQ__CurrentSubscription__c);
                tempLst.add(a);
                priorSubscriptionAssetsMap.put(a.SBQQ__CurrentSubscription__c, tempLst);
            }
        }

        //Renewed Subscription Lines
        for(SBQQ__Subscription__c renewedSub: renewedSubLines.values()){

            if(!originalToAmendedSubLines.containsKey(renewedSub.Id)){

                if(renewedSub.SBQQ__CoveredAssets__r.size() == 0){
                    
                    if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit){

                        if(!priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            
                            lstAssets.addAll(burstAsset(renewedSub, (Integer)renewedSub.SBQQ__Quantity__c, renewedSub.Id));

                        }
                        else if(priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            Integer quantity = (Integer)renewedSub.SBQQ__Quantity__c;
                            Integer noOfAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).size();
                            List<Asset> priorAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);

                            if(quantity == noOfAssets){
                                lstAssets.addAll(updateAllPriorAssets(renewedSub, priorAssets, renewedSub.Id));
                            }
                            else if(quantity > noOfAssets){
                                Integer burstQty = quantity - noOfAssets;

                                lstAssets.addAll(updateAllPriorAssets(renewedSub, priorAssets, renewedSub.Id));
                                lstAssets.addAll(burstAsset(renewedSub, burstQty, renewedSub.Id));
 
                            }
                            else if(quantity < noOfAssets){

                                lstAssets.addAll(updateSelectivePriorAssets(renewedSub, priorAssets, renewedSub.Id, quantity));
                                
                            }
                        }

                    }
                    else if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line'){

                        if(!priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){

                            lstAssets.add(nonBurstAsset(renewedSub, (Integer)renewedSub.SBQQ__Quantity__c, renewedSub.Id));

                        }
                        else if(priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            List<Asset> priorAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
                            //lstAssets.addAll(updateActiveAssets(renewedSub, priorAssets, 1));

                            Integer count = 1;
                            for(Asset a: priorAssets){
                                if(count <= 1){
                                    count = count + 1;
                                    a.SBQQ__QuoteLine__c = renewedSub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                                    a.SBQQ__OrderProduct__c = renewedSub.SBQQ__OrderProduct__r.Id;
                                    a.SBQQ__CurrentSubscription__c = renewedSub.Id;
                                    a.Quantity = renewedSub.SBQQ__Quantity__c;
                                    a.Product2Id = renewedSub.SBQQ__OrderProduct__r.Product2Id;
                                    a.Name = renewedSub.SBQQ__OrderProduct__r.Product2.Name;
                                    a.accountId = renewedSub.SBQQ__OrderProduct__r.Order.accountId;
                                    a.AssetServicedById = renewedSub.SBQQ__OrderProduct__r.Order.accountId;
                                    a.Status ='Provisioning Complete' ;
                                    //a.SBQQ__SubscriptionStartDate__c = renewedSub.SBQQ__OrderProduct__r.ServiceDate;

                                    if(renewedSub.SBQQ__OrderProduct__r.Ship_Date__c != null && a.InstallDate == null){
                                        a.InstallDate = renewedSub.SBQQ__OrderProduct__r.Ship_Date__c;
                                    }

                                    if(perpetualOfferingTypes.contains(renewedSub.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                                        a.SBQQ__SubscriptionEndDate__c = null;
                                    }
                                    else{
                                        a.SBQQ__SubscriptionEndDate__c = renewedSub.SBQQ__OrderProduct__r.EndDate;
                                    }
                                    lstAssets.add(a);
                                    removeAssignedAssets(renewedSub,lstAssets);/**<T01>**/
                                    
                                }
                                else{
                                    break;
                                }
                            }
                        }

                    }

                }

            }
            else if(originalToAmendedSubLines.containsKey(renewedSub.Id)){

                Integer originalQty = (Integer)renewedSub.SBQQ__Quantity__c;
                Integer amendedQty = 0;
                Integer noOfAssets = renewedSub.SBQQ__CoveredAssets__r.size();

                for(SBQQ__Subscription__c amendSub: originalToAmendedSubLines.get(renewedSub.Id)){
                    amendedQty = amendedQty + (Integer)amendSub.SBQQ__Quantity__c;
                }
                Integer currentQty = originalQty + amendedQty;

                SBQQ__Subscription__c lastAmendedSubLine = new SBQQ__Subscription__c();
                if(originalToAmendedSubLines.get(renewedSub.Id).size() != null && originalToAmendedSubLines.get(renewedSub.Id).size() > 0){
                    lastAmendedSubLine = originalToAmendedSubLines.get(renewedSub.Id)[originalToAmendedSubLines.get(renewedSub.Id).size() - 1];
                }

                System.debug('**************************************************************');
                System.debug('renewedSub --> Name='+renewedSub.SBQQ__OrderProduct__r.Product2.Name);
                System.debug('renewedSub --> Quantity='+renewedSub.SBQQ__Quantity__c);
                System.debug('originalQty='+originalQty+'  amendedQty='+amendedQty+'  currentQty='+currentQty);
                System.debug('lastAmendedSubLine --> '+lastAmendedSubLine);
                System.debug('renewedSub.SBQQ__CoveredAssets__r.size = '+renewedSub.SBQQ__CoveredAssets__r.size());
                System.debug('**************************************************************');

                if(renewedSub.SBQQ__CoveredAssets__r.size() == 0){

                    if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit){

                        if(!priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            if(currentQty > 0){
                                lstAssets.addAll(burstAsset(lastAmendedSubLine, currentQty, renewedSub.Id));
                            }
                        }
                        else if(priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            noOfAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).size();
                            List<Asset> priorAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);

                            if(currentQty == noOfAssets){
                                lstAssets.addAll(updateAllPriorAssets(lastAmendedSubLine, priorAssets, renewedSub.Id));
                            }
                            else if(currentQty > noOfAssets){
                                Integer burstQty = currentQty - noOfAssets;
                                lstAssets.addAll(updateAllPriorAssets(lastAmendedSubLine, priorAssets, renewedSub.Id));
                                lstAssets.addAll(burstAsset(lastAmendedSubLine, burstQty, renewedSub.Id));
                            }
                            else if(currentQty < noOfAssets){
                                lstAssets.addAll(updateSelectivePriorAssets(lastAmendedSubLine, priorAssets, renewedSub.Id, currentQty));
                            }

                        }

                    }
                    else if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line'){
                        if(!priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            if(currentQty > 0){
                                lstAssets.add(nonBurstAsset(lastAmendedSubLine, currentQty, renewedSub.Id));
                            }
                        }
                        else if(priorSubscriptionAssetsMap.containsKey(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)){
                            List<Asset> priorAssets = priorSubscriptionAssetsMap.get(renewedSub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);

                            Integer count = 1;
                            for(Asset a: priorAssets){
                                if(count <= 1){
                                    count = count + 1;
                                    a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                                    a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Id;
                                    a.SBQQ__CurrentSubscription__c = renewedSub.Id;
                                    a.Quantity = currentQty;
                                    a.Product2Id = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2Id;
                                    a.Name = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Name;
                                    a.accountId = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                    a.AssetServicedById = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                    a.Status ='Provisioning Complete' ;
                                    //a.SBQQ__SubscriptionStartDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.ServiceDate;

                                    if(lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c != null && a.InstallDate == null){
                                        a.InstallDate = lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c;
                                    }

                                    if(perpetualOfferingTypes.contains(lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                                        a.SBQQ__SubscriptionEndDate__c = null;
                                    }
                                    else{
                                        a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.EndDate;
                                    }
                                    //a.One_Per_Unit_Total_Assets__c = sub.SBQQ__OrderProduct__r.SBQQ__OrderedQuantity__c;
                                    lstAssets.add(a);
                                    removeAssignedAssets(renewedSub, lstAssets); /**<T01>**/
                                }
                                else{
                                    break;
                                }
                            }
                        }
                    }

                }
                else if(renewedSub.SBQQ__CoveredAssets__r.size() > 0){

                    if(currentQty <= 0){
                        debookedAssets.addAll(debookRenewalAsset(renewedSub, lastAmendedSubLine));
                    }

                    if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == Label.Product2_SBQQ_AssetConversion_One_Per_Unit){

                        if(currentQty > 0 && currentQty > noOfAssets){

                            Integer burstQty = currentQty - noOfAssets;
                            lstAssets.addAll(burstAsset(lastAmendedSubLine, currentQty, renewedSub.Id));
        
                        }
                        else if(currentQty > 0 && currentQty < noOfAssets){
                            Integer decreasedQty = noOfAssets - currentQty;

                            Integer count = 0;
                            for(Asset a: renewedSub.SBQQ__CoveredAssets__r){
                                if(count < decreasedQty){
                                    count++;
                                    /*
                                    a.Status = 'Cancelled';
                                    a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.Generate_Date__c;
                                    a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__c;
                                    a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__QuoteLine__c;
                                    MapOfSubAsset.put(a.Id, renewedSub); 
                                    debookedAssets.add(a);
                                    */

                                    if(a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionStartDate__c == a.SBQQ__SubscriptionStartDate__c){
    
                                        if(perpetualOfferingTypes.contains(renewedSub.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                                            a.SBQQ__SubscriptionEndDate__c = null;
                                        }
                                        else{
                                            a.SBQQ__SubscriptionEndDate__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate;
                                        }                    
                    
                                        a.SBQQ__QuoteLine__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c;
                                        a.SBQQ__OrderProduct__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c;
                                        a.SBQQ__CurrentSubscription__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c;
                                        MapOfSubAsset.put(a.Id, lastAmendedSubLine); 
                                        
                                        debookedAssets.add(a);
                        
                                    }
                                    else{
                        
                                        a.Status = 'Cancelled';
                                        a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.Generate_Date__c;
                                        a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__c;
                                        a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__QuoteLine__c;
                                        MapOfSubAsset.put(a.Id, lastAmendedSubLine);
                                        debookedAssets.add(a);
                        
                                    }
                                }
                                else{
                                    break;
                                }
                            }
                        
                        }

                    }
                    else if(renewedSub.SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c == 'One per quote line'){

                        if(currentQty > 0){

                            for(Asset a: renewedSub.SBQQ__CoveredAssets__r){
                                        a.SBQQ__QuoteLine__c = lastAmendedSubLine.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                                        a.SBQQ__OrderProduct__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Id;
                                        //a.Original_Order_Product__c = lastAmendedSubLine.SBQQ__OrderProduct__r.Id;
                                        a.SBQQ__CurrentSubscription__c = renewedSub.Id;
                                        a.Quantity = currentQty;
                                        a.Product2Id = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2Id;
                                        a.Name = lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Name;
                                        a.accountId = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                        a.AssetServicedById = lastAmendedSubLine.SBQQ__OrderProduct__r.Order.accountId;
                                        a.Status ='Provisioning Complete' ;
                                        //a.SBQQ__SubscriptionStartDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.ServiceDate;
                            
                                        if(lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c != null){
                                            a.InstallDate = lastAmendedSubLine.SBQQ__OrderProduct__r.Ship_Date__c;
                                        }
                            
                                        if(perpetualOfferingTypes.contains(lastAmendedSubLine.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                                            a.SBQQ__SubscriptionEndDate__c = null;
                                        }
                                        else{
                                            a.SBQQ__SubscriptionEndDate__c = lastAmendedSubLine.SBQQ__OrderProduct__r.EndDate;
                                        }
                                
                                lstAssets.add(a);
                            }
                        }

                    }

                }

            }

        }


        if(debookedAssets.size() != null && debookedAssets.size() > 0){
            lstAssets.addAll(debookedAssets);
        }
		
        Set<Id> upsertedAssetIdSet = new Set<Id>();
        //Creating a save point
        Savepoint sp = Database.setSavepoint();
		
        try{
            if(lstAssets.size() != null && lstAssets.size() > 0){
                //upsert lstAssets;
                /**<T02>**/
                //---------------------------------------<T03>-----------------------------
                if(allowDMLProcessing(lstAssets.size())){
                    List<Database.UpsertResult> srList = Database.upsert(lstAssets);                    
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess()) {
                            upsertedAssetIdSet.add(sr.getId());                            
                        }
					}
                }
                else{
                    throw new CustomException('Total DML records to process exceeded available governor limit.');
                }
                //---------------------------------------</T03>-----------------------------
                
                 /**<T02>**/
            }
            
            //---------------------------------------<T03>-----------------------------
            List<Entitlement> lstEntitlements = CreateEntitlementPerAsset.getEntitlement(new List<Contract>{c}, MapOfSubAsset);
            if(lstEntitlements.size() > 0){
                if(allowDMLProcessing(lstEntitlements.size())){
                    upsert lstEntitlements;
                }
                else{
                    throw new CustomException('Total DML records to process exceeded available governor limit.');
                }
            }
            //---------------------------------------<T03>-----------------------------
            
            if(upsertedAssetIdSet <> null && upsertedAssetIdSet.size() >0){
                CreateShadowAssets.handleShadowAssets(upsertedAssetIdSet);
            }
            
            List<Order> orderToUpdate = new List<Order>();
            for(Order o: [Select Id, Status, Asset_Creation_Status__c, Asset_Creation_Error_Message__c from Order where Id IN :orderIds]){
                if(o.Asset_Creation_Status__c != 'Completed'){
                    o.Asset_Creation_Status__c = 'Completed';
                    o.Asset_Creation_Error_Message__c = null;
                    orderToUpdate.add(o);
                }
            }
            
            if(orderToUpdate.size() != null && orderToUpdate.size() > 0){
                update orderToUpdate;
            }
            
        }
        catch(Exception e){

            //roll back to the previous savepoint in case of any error
            Database.rollback(sp);

            Integer intFieldLength = Schema.SObjectType.Order.fields.Asset_Creation_Error_Message__c.getLength(); // <T03>

            Order o = new Order();
            o.Id = OrderId;
            o.Asset_Creation_Status__c = 'Failed';
            o.Asset_Creation_Error_Message__c = e.getMessage().length() > intFieldLength ? e.getMessage().substring(0,intFieldLength) : e.getMessage(); // <T03>
            update o;

        }

    }


/*Method to burst assets based on subscription line and quantity 
* @param Name - sub, qty, originalSubId
* @throws exception -n/a
* @return Boolean---Response will be List<Asset> 
*/
    
    public static List<Asset> burstAsset(SBQQ__Subscription__c sub, Integer qty, Id originalSubId){

        List<Asset> assets = new List<Asset>();
        
        for(Integer i = 0; i<qty; i++){
    
            Asset a = new Asset();
                a.SBQQ__QuoteLine__c = sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                a.SBQQ__OrderProduct__c = sub.SBQQ__OrderProduct__r.Id;
                a.Original_Order_Product__c = sub.SBQQ__OrderProduct__r.Id;
                a.SBQQ__CurrentSubscription__c = originalSubId;
                a.Quantity = 1;
                a.Product2Id = sub.SBQQ__OrderProduct__r.Product2Id != null ? sub.SBQQ__OrderProduct__r.Product2Id : sub.SBQQ__Product__r.Id;
                a.Name = sub.SBQQ__OrderProduct__r.Product2.Name != null ? sub.SBQQ__OrderProduct__r.Product2.Name : sub.SBQQ__Product__r.Name;
                a.accountId = sub.SBQQ__OrderProduct__r.Order.accountId != null ? sub.SBQQ__OrderProduct__r.Order.accountId : sub.SBQQ__Account__r.Id;
                a.AssetServicedById = sub.SBQQ__OrderProduct__r.Order.accountId != null ? sub.SBQQ__OrderProduct__r.Order.accountId : sub.SBQQ__Account__r.Id;
                a.Status ='Provisioning Complete' ;
                a.SBQQ__SubscriptionStartDate__c = sub.SBQQ__OrderProduct__r.ServiceDate != null ? sub.SBQQ__OrderProduct__r.ServiceDate : sub.SBQQ__StartDate__c;
    
                if(sub.SBQQ__OrderProduct__r.Ship_Date__c != null){
                    a.InstallDate = sub.SBQQ__OrderProduct__r.Ship_Date__c;
                }
                else if(sub.SBQQ__OrderProduct__c == null){
                    a.InstallDate = sub.SBQQ__EndDate__c;
                }
    
                if(perpetualOfferingTypes.contains(sub.SBQQ__OrderProduct__r.Product2.Offering_Type__c) || (sub.SBQQ__OrderProduct__c == null && perpetualOfferingTypes.contains(sub.SBQQ__Product__r.Offering_Type__c))){
                    a.SBQQ__SubscriptionEndDate__c = null;
                }
                else{
                    a.SBQQ__SubscriptionEndDate__c = sub.SBQQ__OrderProduct__r.EndDate != null ? sub.SBQQ__OrderProduct__r.EndDate : sub.SBQQ__EndDate__c;
                }
                //a.One_Per_Unit_Total_Assets__c = sub.SBQQ__OrderProduct__r.SBQQ__OrderedQuantity__c;
                assets.add(a);
    
        }
    
        return assets;
    }


/*Method to create an asset based on subscription line 
* @param Name - sub, qty, originalSubId
* @throws exception -n/a
* @return Boolean---Response will be an Asset object
*/

    public static Asset nonBurstAsset(SBQQ__Subscription__c sub, Integer qty, Id originalSubId){

        Asset a = new Asset();
                a.SBQQ__QuoteLine__c = sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                a.SBQQ__OrderProduct__c = sub.SBQQ__OrderProduct__r.Id;
                a.Original_Order_Product__c = sub.SBQQ__OrderProduct__r.Id;
                a.SBQQ__CurrentSubscription__c = originalSubId;
                a.Quantity = qty;
                a.Product2Id = sub.SBQQ__OrderProduct__r.Product2Id != null ? sub.SBQQ__OrderProduct__r.Product2Id : sub.SBQQ__Product__r.Id;
                a.Name = sub.SBQQ__OrderProduct__r.Product2.Name != null ? sub.SBQQ__OrderProduct__r.Product2.Name : sub.SBQQ__Product__r.Name;
                a.accountId = sub.SBQQ__OrderProduct__r.Order.accountId != null ? sub.SBQQ__OrderProduct__r.Order.accountId : sub.SBQQ__Account__r.Id;
                a.AssetServicedById = sub.SBQQ__OrderProduct__r.Order.accountId != null ? sub.SBQQ__OrderProduct__r.Order.accountId : sub.SBQQ__Account__r.Id;
                a.Status ='Provisioning Complete' ;
                a.SBQQ__SubscriptionStartDate__c = sub.SBQQ__OrderProduct__r.ServiceDate != null ? sub.SBQQ__OrderProduct__r.ServiceDate : sub.SBQQ__StartDate__c;
    
                if(sub.SBQQ__OrderProduct__r.Ship_Date__c != null){
                    a.InstallDate = sub.SBQQ__OrderProduct__r.Ship_Date__c;
                }
                else if(sub.SBQQ__OrderProduct__c == null){
                    a.InstallDate = sub.SBQQ__EndDate__c;
                }
    
                if(perpetualOfferingTypes.contains(sub.SBQQ__OrderProduct__r.Product2.Offering_Type__c) || (sub.SBQQ__OrderProduct__c == null && perpetualOfferingTypes.contains(sub.SBQQ__Product__r.Offering_Type__c))){
                    a.SBQQ__SubscriptionEndDate__c = null;
                }
                else{
                    a.SBQQ__SubscriptionEndDate__c = sub.SBQQ__OrderProduct__r.EndDate != null ? sub.SBQQ__OrderProduct__r.EndDate : sub.SBQQ__EndDate__c;
                }
    
        return a;
    
    }


/*Method to update prior assets on renewal with the current information 
* @param Name - sub, activeAssets, originalSubId
* @throws exception -n/a
* @return Boolean---Response will be List<Asset>
*/

    public static List<Asset> updateAllPriorAssets(SBQQ__Subscription__c sub, List<Asset> activeAssets, Id originalSubId){
        List<Asset> assets = new List<Asset>();
    
        for(Asset a: activeAssets){
            a.SBQQ__QuoteLine__c = sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
            a.SBQQ__OrderProduct__c = sub.SBQQ__OrderProduct__r.Id;
            a.SBQQ__CurrentSubscription__c = originalSubId;
            a.Quantity = 1;
            a.Product2Id = sub.SBQQ__OrderProduct__r.Product2Id;
            a.Name = sub.SBQQ__OrderProduct__r.Product2.Name;
            a.accountId = sub.SBQQ__OrderProduct__r.Order.accountId;
            a.AssetServicedById = sub.SBQQ__OrderProduct__r.Order.accountId;
            a.Status ='Provisioning Complete' ;
            //a.SBQQ__SubscriptionStartDate__c = sub.SBQQ__OrderProduct__r.ServiceDate;
    
            if(a.InstallDate == null && sub.SBQQ__OrderProduct__r.Ship_Date__c != null){
                a.InstallDate = sub.SBQQ__OrderProduct__r.Ship_Date__c;
            }
    
            if(perpetualOfferingTypes.contains(sub.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                a.SBQQ__SubscriptionEndDate__c = null;
            }
            else{
                a.SBQQ__SubscriptionEndDate__c = sub.SBQQ__OrderProduct__r.EndDate;
            }
    
            assets.add(a);
        }
    	removeAssignedAssets(sub, assets);/**<T01>*/
        return assets;
    }


/*Method to update prior assets on renewal with the current information 
* @param Name - sub, activeAssets, originalSubId
* @throws exception -n/a
* @return Boolean---Response will be List<Asset>
*/

    public static List<Asset> updateSelectivePriorAssets(SBQQ__Subscription__c sub, List<Asset> activeAssets, Id originalSubId, Integer qty){
        List<Asset> assets = new List<Asset>();
    
        Integer count = 0;
    
        for(Asset a: activeAssets){
            if(count != qty){
                count = count + 1;
                a.SBQQ__QuoteLine__c = sub.SBQQ__OrderProduct__r.SBQQ__QuoteLine__c;
                a.SBQQ__OrderProduct__c = sub.SBQQ__OrderProduct__r.Id;
                a.SBQQ__CurrentSubscription__c = originalSubId;
                a.Quantity = 1;
                a.Product2Id = sub.SBQQ__OrderProduct__r.Product2Id;
                a.Name = sub.SBQQ__OrderProduct__r.Product2.Name;
                a.accountId = sub.SBQQ__OrderProduct__r.Order.accountId;
                a.AssetServicedById = sub.SBQQ__OrderProduct__r.Order.accountId;
                a.Status ='Provisioning Complete' ;
                //a.SBQQ__SubscriptionStartDate__c = sub.SBQQ__OrderProduct__r.ServiceDate;
    
                if(a.InstallDate == null && sub.SBQQ__OrderProduct__r.Ship_Date__c != null){
                    a.InstallDate = sub.SBQQ__OrderProduct__r.Ship_Date__c;
                }
    
                if(perpetualOfferingTypes.contains(sub.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                    a.SBQQ__SubscriptionEndDate__c = null;
                }
                else{
                    a.SBQQ__SubscriptionEndDate__c = sub.SBQQ__OrderProduct__r.EndDate;
                }
                assets.add(a);
            }
            else{
                break;
            }
        }
    	removeAssignedAssets(sub, assets); /**<T01>**/
        return assets;
    }


/*Method to debook renewed assets and roll them back to their previous values/Linkage
* @param Name - sub,  lastAmendSub
* @throws exception -n/a
* @return Boolean---Response will be List<Asset>
*/

    public static List<Asset> debookRenewalAsset(SBQQ__Subscription__c sub, SBQQ__Subscription__c lastAmendSub){
        List<Asset> assets = new List<Asset>();
    
        for(Asset a: sub.SBQQ__CoveredAssets__r){
                if(a.SBQQ__SubscriptionStartDate__c != lastAmendSub.SBQQ__OrderProduct__r.ServiceDate){
    
                    if(perpetualOfferingTypes.contains(sub.SBQQ__OrderProduct__r.Product2.Offering_Type__c)){
                        a.SBQQ__SubscriptionEndDate__c = null;
                    }
                    else{
                        a.SBQQ__SubscriptionEndDate__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate;
                    }                    

                    a.SBQQ__QuoteLine__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c;
                    a.SBQQ__OrderProduct__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c;
                    a.SBQQ__CurrentSubscription__c = a.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c;
                    MapOfSubAsset.put(a.Id, lastAmendSub); 
                    
                    assets.add(a);
    
                }
                else{
    
                    a.Status = 'Cancelled';
                    a.SBQQ__SubscriptionEndDate__c = lastAmendSub.SBQQ__OrderProduct__r.Order.Generate_Date__c;
                    a.SBQQ__OrderProduct__c = lastAmendSub.SBQQ__OrderProduct__c;
                    a.SBQQ__QuoteLine__c = lastAmendSub.SBQQ__QuoteLine__c;
                    MapOfSubAsset.put(a.Id, lastAmendSub);
                    assets.add(a);
    
                }
            }
    
        return assets;
    }

    /** <T01> STARTS */
    public static void removeAssignedAssets(SBQQ__Subscription__c sub, List<Asset> AssetsList){
      
        Set<Id> subscriptionIdSet = new Set<Id>();
        subscriptionIdSet.add(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
        
        System.debug('priorSubscriptionAssetsMap BEFORE ==>'+ priorSubscriptionAssetsMap);
        
        if(priorSubscriptionAssetsMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c) != null){
        
        for(integer i=0;i<priorSubscriptionAssetsMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).size();i++){    
            for(integer j=0;j<AssetsList.size();j++){
                if(priorSubscriptionAssetsMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c)[i]==AssetsList[j]){
                    priorSubscriptionAssetsMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).remove(i);
                }
            }
        }
        System.debug('priorSubscriptionAssetsMap AFTER ==>'+ priorSubscriptionAssetsMap);
        
        if(priorSubscriptionAssetsMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c).size()== 0){
            priorSubscriptionAssetsMap.keySet().removeAll(subscriptionIdSet);
        }
        
        System.debug('priorSubscriptionAssetsMap.keySet() ===>'+ priorSubscriptionAssetsMap.keySet());
            
        }
        
    }
    /** <T01> ENDS */

    //---------------------------------------<T03>-----------------------------
    /*
	 Method Name : getAvailableDMLRows
	 Description : This method returns the available number of records that can be processed at the time of function call.
	 Parameters	 : None
	 Return Type : Integer
	 */
	public static Integer getAvailableDMLRows() {
        return Limits.getLimitDMLRows() - Limits.getDMLRows();
    }

     /*
	 Method Name : allowDMLProcessing
	 Description : This method compares the number of records to process in DML against the available DMLRows limit.
	 Parameters	 : Integer, called from allowDMLProcessing, intNumberOfRecords Integer.
	 Return Type : Boolean
	 */
    public static Boolean allowDMLProcessing(Integer intNumberOfRecords) {
        Integer intAvailableLimit = getAvailableDMLRows();
        return intAvailableLimit - intNumberOfRecords > 1 ? true : false;
    }
    //---------------------------------------</T03>-----------------------------
}