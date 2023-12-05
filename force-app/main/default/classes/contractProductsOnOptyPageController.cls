/*
Class:          contractProductsOnOptyPageController
@Author:        Chandana Gowda
@Created Date:  09-Oct-2019
@Description:   Class to fetch Consolidated Prior contract Products in Renewal Opty

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                             Tag
**********************************************************************************************************************************************************
**********************************************************************************************************************************************************
*/
public with sharing class contractProductsOnOptyPageController {

    @AuraEnabled()
    public static List<SBQQ__Subscription__c> getSubscriptionRecs(String oppId){
        List<SBQQ__Subscription__c> lstSubscription = new List<SBQQ__Subscription__c>();
        Map<Id,Contract> mapContractwithQuotes = new Map<Id,Contract>();
        Map<Id,Contract> mapContractwithoutQuotes = new Map<Id,Contract>();
        List<Id> lstQuoteId = new List<Id>();
        Map<Id,SBQQ__Subscription__c> mapSubscription = new Map<Id,SBQQ__Subscription__c>();
        
        //Getting all the related contracts
        Map<Id,Contract> mapContract= new Map<Id,Contract>([SELECT Id,SBQQ__Order__c,SBQQ__Order__r.SBQQ__Quote__c from Contract WHERE SBQQ__RenewalOpportunity__c =:oppId]);
        if(!mapContract.isEmpty()){
            for(Contract contractRec:mapContract.values()){
                //Getting all the associated contracts with Quote
                if(contractRec.SBQQ__Order__c != null  && contractRec.SBQQ__Order__r.SBQQ__Quote__c != null){ //to get from the latest amendment
                    mapContractwithQuotes.put(contractRec.Id, contractRec);
                    lstQuoteId.add(contractRec.SBQQ__Order__r.SBQQ__Quote__c);
                }
                //Getting all the associated contracts without quotes, migrated contracts
                else {
                    mapContractwithoutQuotes.put(contractRec.Id,contractRec);
                }
            }        

            //Getting all the associated quote lines
            Map<Id,SBQQ__QuoteLine__c> mapQuoteLine = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__ProductName__c,SBQQ__Number__c,SBQQ__Quantity__c,SBQQ__UpgradedSubscription__c,SBQQ__UpgradedSubscription__r.SBQQ__Contract__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.Id IN :lstQuoteId AND SBQQ__Quantity__c != 0 ORDER BY SBQQ__Quote__r.Related_Contract__r.ContractNumber,SBQQ__Quote__r.SBQQ__MasterContract__r.ContractNumber,SBQQ__Number__c]);
            //Getting all the associated Subscriptions
            Map<Id,SBQQ__Subscription__c> mapSubscriptionWithoutQuote = new Map<Id,SBQQ__Subscription__c> ([SELECT Id,SBQQ__Number__c,SBQQ__RequiredByProduct__c,SBQQ__Contract__c,SBQQ__RevisedSubscription__c,SBQQ__ContractNumber__c,SBQQ__RequiredById__c,SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,sbqq__product__r.Product_Family__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :mapContractwithoutQuotes.keySet()]);
            Map<Id,SBQQ__Subscription__c> mapSubscriptionWithQuote = new Map<Id,SBQQ__Subscription__c> ([SELECT Id,SBQQ__Number__c,SBQQ__RequiredByProduct__c,SBQQ__Contract__c,SBQQ__RevisedSubscription__c,SBQQ__ContractNumber__c,SBQQ__RequiredById__c,SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,sbqq__product__r.Product_Family__c,SBQQ__QuoteLine__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :mapContractwithQuotes.keySet()]);

            //Map of quoteLine to subscription Records
            Map<Id,SBQQ__Subscription__c> mapQuoteLineWithSubscription = new Map<Id,SBQQ__Subscription__c>();
            Map<Id,Integer> mapContractSubCount = new Map<Id,Integer>();
            

            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                subRec.SBQQ__Number__c = 0; //Updating the Number to 0
                mapSubscriptionWithQuote.put(subRec.Id, subRec);                
                mapQuoteLineWithSubscription.put(subRec.SBQQ__QuoteLine__c, subRec);
            }

            for(SBQQ__QuoteLine__c quoteLine:mapQuoteLine.values()){
                //Amending the existing line
                if(quoteLine.SBQQ__UpgradedSubscription__c != null){
                    SBQQ__Subscription__c subRec = mapSubscriptionWithQuote.get(quoteLine.SBQQ__UpgradedSubscription__c);
                    if(subRec != null){
                        subRec.SBQQ__Number__c = quoteLine.SBQQ__Number__c;
                        mapSubscriptionWithQuote.put(quoteLine.SBQQ__UpgradedSubscription__c, subRec);

                        if(!mapContractSubCount.keySet().contains(quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__Contract__c))
                            mapContractSubCount.put(quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__Contract__c,0);
                        else {
                            Integer count = mapContractSubCount.get(quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__Contract__c);
                            count +=1;
                            mapContractSubCount.put(quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__Contract__c,count);
                        }
                    }
                }
                //Adding new line via Amendment
                else{
                    SBQQ__Subscription__c subRec = mapQuoteLineWithSubscription.get(quoteLine.Id); 
                    if(subRec != null){                   
                    subRec.SBQQ__Number__c = quoteLine.SBQQ__Number__c;
                    mapSubscriptionWithQuote.put(subRec.Id,subRec); 
                    }   
                }                
            }

            List<Id> subBundleChanged = new List<Id>(); //List to hold the Ids of Subscription Lines added due to amendment

            //Adding all the subscription lines added due to amendement of existing Lines
            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                if(subRec.SBQQ__Number__c == 0 && subRec.SBQQ__RevisedSubscription__c != null && subRec.SBQQ__RequiredById__c == null){
                    subBundleChanged.add(subRec.SBQQ__RequiredById__c);
                }
            } 
            
            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                if(subRec.SBQQ__RevisedSubscription__c != null && mapSubscriptionWithQuote.get(subRec.SBQQ__RevisedSubscription__c).SBQQ__Number__c != 0){
                    if(subRec.SBQQ__RevisedSubscription__c != null && subRec.SBQQ__RequiredById__c != null && !subBundleChanged.contains(subRec.SBQQ__RequiredById__c) ){
                        subRec.SBQQ__Number__c = mapSubscriptionWithQuote.get(subRec.SBQQ__RevisedSubscription__c).SBQQ__Number__c;
                        mapSubscriptionWithoutQuote.put(subRec.Id, subRec);
                    }
                    else if(subRec.SBQQ__RevisedSubscription__c != null){
                        subRec.SBQQ__Number__c = mapSubscriptionWithQuote.get(subRec.SBQQ__RevisedSubscription__c).SBQQ__Number__c + mapContractSubCount.get(subRec.SBQQ__Contract__c);
                        mapSubscriptionWithoutQuote.put(subRec.Id, subRec);                    
                            Integer count = mapContractSubCount.get(subRec.SBQQ__Contract__c);
                            count +=1;
                            mapContractSubCount.put(subRec.SBQQ__Contract__c,count);
                    }
                }
            }            

            //Adding lines from the Contracts without Quote, i.e., migrated contracts if any
            mapSubscriptionWithQuote.putAll(mapSubscriptionWithoutQuote);

            Map<Id,Double> duplicateParentProductIds = new  Map<Id,Double>();
            Set<String> parentProductWithDate = new Set<String>();
            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                String mapProductDateKey = String.valueOf(subRec.SBQQ__Product__c) +String.valueOf(subRec.SBQQ__StartDate__c)+String.valueOf(subRec.SBQQ__EndDate__c);
                if(subRec.SBQQ__RequiredById__c == null){
                    if(parentProductWithDate.contains(mapProductDateKey)){
                        subRec.SBQQ__Number__c = duplicateParentProductIds.get(subRec.SBQQ__Product__c);
                    }
                    else {
                        parentProductWithDate.add(mapProductDateKey);
                        duplicateParentProductIds.put(subRec.SBQQ__Product__c,subRec.SBQQ__Number__c);
                    }
                }

                else{
                    SBQQ__Subscription__c parentLine = mapSubscriptionWithQuote.get(subRec.SBQQ__RequiredById__c);
                    while(parentLine.SBQQ__RequiredById__c != null){
                        parentLine = mapSubscriptionWithQuote.get(parentLine.SBQQ__RequiredById__c);
                    }
                    subRec.SBQQ__RequiredById__c = parentLine.Id;
                }
            } 
            
            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                if(subRec.SBQQ__RequiredById__c != null){
                    String num = String.valueOf(Integer.valueOf(mapSubscriptionWithQuote.get(subRec.SBQQ__RequiredById__c).SBQQ__Number__c)) + '.' +String.valueOf(subRec.SBQQ__Number__c);
                    subRec.SBQQ__Number__c = Double.valueOf(num);
                }
            }

            Map<String,Id> mapProductDateSub = new Map<String,Id>();
            for(SBQQ__Subscription__c subRec:mapSubscriptionWithQuote.values()){
                String mapProductDateSubKey = String.valueOf(subRec.SBQQ__Product__c) +String.valueOf(subRec.SBQQ__StartDate__c)+String.valueOf(subRec.SBQQ__EndDate__c)+String.valueOf(subRec.SBQQ__RequiredByProduct__c); 
                if(!mapProductDateSub.keySet().contains(mapProductDateSubKey)){
                    mapProductDateSub.put(mapProductDateSubKey, subRec.Id);
                }
                else{
                    if(subRec.sbqq__product__r.Product_Family__c != 'Support'){ //Quantity should not be consolidated for Support Products
                        SBQQ__Subscription__c subUpdate = mapSubscriptionWithQuote.get(mapProductDateSub.get(mapProductDateSubKey));
                        subUpdate.SBQQ__Quantity__c += subRec.SBQQ__Quantity__c;
                        mapSubscriptionWithQuote.put(subUpdate.Id, subUpdate);   
                    }                 
                    mapSubscriptionWithQuote.remove(subRec.Id);
                }
            }

            return mapSubscriptionWithQuote.values();
        }

        return lstSubscription;        
    }    
}