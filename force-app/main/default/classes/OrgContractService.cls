/*
 * Name         :   OrgContractService
 * Author       :   Vignesh Divakaran
 * Created Date :   6/23/2023
 * Description  :   Service class for Org Contract object.

 Change History
 ***********************************************************************************************************************
 Modified By            Date            Jira No.        Description                                                Tag
 ***********************************************************************************************************************
 Vignesh Divakaran      6/23/2023       F2A-594         Initial version.                                           N/A
*/

public with sharing class OrgContractService {
    
    public static String ASSET_QUERY_FIELDS = 'Id,Org__c,SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__CurrentSubscription__r.SBQQ__Quantity__c,SBQQ__CurrentSubscription__r.SBQQ__OrderProduct__c,SBQQ__CurrentSubscription__r.SBQQ__OrderProduct__r.OrderId';
    public static globalApexManager GAM = new globalApexManager();

    /*
     Method Name : createOrgContracts
     Description : This method creates or updates org contract records.
     Parameters  : Set<Id>, called from createOrgContracts, setAssetIds asset record ids.
     Return Type : None
     */
    public static void createOrgContracts(Set<Id> setAssetIds){
        createOrgContracts(getAssets(setAssetIds));
    }

    /*
     Method Name : createOrgContracts
     Description : This method creates or updates org contract records.
     Parameters  : List<Id>, called from createOrgContracts, lstContractIds contract record ids.
     Return Type : None
     */
    @InvocableMethod(label='Create or Update Org Contracts' description='This method creates or updates Org Contracts')
    public static void createOrgContracts(List<Id> lstContractIds){
        createOrgContracts(getAssets(lstContractIds));
    }

    /*
     Method Name : createOrgContracts
     Description : This method creates org contract records.
     Parameters  : List<Asset>, called from createOrgContracts, lstAssets asset records.
     Return Type : None
     */
    public static void createOrgContracts(List<Asset> lstAssets){

        Set<Id> setOrgIds = new Set<Id>();
        Set<Id> setContractIds = new Set<Id>();
        Set<Id> setOrderProductIds = new Set<Id>();
        Set<Id> setSubscriptionIds = new Set<Id>();
        Set<String> setOrgOrderKeys = new Set<String>();
        Set<Org_Contract__c> setOrgContracts = new Set<Org_Contract__c>();
        Map<Id, Contract> activeContractsMap = new Map<Id, Contract>();
        Map<Id, List<Id>> subscriptionToOrgsMap = new Map<Id, List<Id>>();
        Map<String, Integer> orgContractQuantityMap = new Map<String, Integer>();        
        Map<String, Org_Contract__c> orgContractsMap = new Map<String, Org_Contract__c>();

        for(Asset objAsset : lstAssets){
            if(objAsset.Org__c != null)
                setOrgIds.add(objAsset.Org__c);
            if(objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c != null)
                setContractIds.add(objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c);
            if(objAsset.SBQQ__CurrentSubscription__c != null)
                setSubscriptionIds.add(objAsset.SBQQ__CurrentSubscription__c);
            if(objAsset.SBQQ__CurrentSubscription__r.SBQQ__OrderProduct__c != null)
                setOrderProductIds.add(objAsset.SBQQ__CurrentSubscription__r.SBQQ__OrderProduct__c);
            if(objAsset.Org__c != null && objAsset.SBQQ__CurrentSubscription__c != null){
                List<Id> lstOrgIds = subscriptionToOrgsMap.containsKey(objAsset.SBQQ__CurrentSubscription__c) ? subscriptionToOrgsMap.get(objAsset.SBQQ__CurrentSubscription__c) : new List<Id>();
                if(!lstOrgIds.contains(objAsset.Org__c))
                    lstOrgIds.add(objAsset.Org__c);
                subscriptionToOrgsMap.put(objAsset.SBQQ__CurrentSubscription__c, lstOrgIds);
            }
        }

        //Now, we query the contracts which are still active.
        activeContractsMap = new Map<Id, Contract>([SELECT Id,SBQQ__ActiveContract__c FROM Contract WHERE Id IN :setContractIds AND SBQQ__ActiveContract__c = 1]);
        orgContractQuantityMap = getOrgContractQuantity(setSubscriptionIds, subscriptionToOrgsMap);

        //Now, we query and add the order product ids, which has an active fulfillment line for the list of orgs
        for(Related_Fulfillment_Line__c objRelatedFulfillmentLine : [SELECT Order_Product__c,Order_Product__r.OrderId,Fullfillment_Line__r.Org__c FROM Related_Fulfillment_Line__c WHERE Order_Product__c IN :setOrderProductIds AND Fullfillment_Line__r.Fullfillment__r.Active__c = TRUE AND Fullfillment_Line__r.Fullfillment__r.Order__r.Status != 'Cancelled' AND Fullfillment_Line__r.Ship_Status__c = 'Provisioning Complete']){
            String strKey = objRelatedFulfillmentLine.Fullfillment_Line__r.Org__c +'##'+ objRelatedFulfillmentLine.Order_Product__r.OrderId;
            setOrgOrderKeys.add(strKey);
        }

        for(Org_Contract__c objOrgContract : [SELECT Id,Contract__c,Active_Contract__c,Org__c,Status__c FROM Org_Contract__c WHERE Org__c IN :setOrgIds]){
            String strKey = objOrgContract.Org__c +'##'+ objOrgContract.Contract__c;
            orgContractsMap.put(strKey, objOrgContract);
        }

        for(Asset objAsset : lstAssets){
            String strKey = objAsset.Org__c +'##'+ objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c;
            String strOrgOrderKey = objAsset.Org__c +'##'+ objAsset.SBQQ__CurrentSubscription__r.SBQQ__OrderProduct__r.OrderId;
            Integer intCurrentQty = orgContractQuantityMap.containsKey(strKey) ? orgContractQuantityMap.get(strKey) : 0;

            if(!orgContractsMap.containsKey(strKey)){

                /*
                Now, we check all the below conditions and if it satisfied, we can an org contract with active status.
                    1. Contract is Active
                    2. Org with atleast one fulfillment line under an active fulfillment header
                    3. Org with an active subscription (currentQty = Original Qty + Amended Qty).
                */
                if(activeContractsMap.containsKey(objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c) && setOrgOrderKeys.contains(strOrgOrderKey) && intCurrentQty > 0){
                    Org_Contract__c objOrgContract = new Org_Contract__c();
                    objOrgContract.Org__c = objAsset.Org__c;
                    objOrgContract.Contract__c = objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c;
                    objOrgContract.Status__c = 'Active';
                    setOrgContracts.add(objOrgContract); 
                }
            }
            else if(orgContractsMap.containsKey(strKey)){

                Org_Contract__c objOrgContractOld = orgContractsMap.get(strKey);
                Org_Contract__c objOrgContract = new Org_Contract__c(Id = objOrgContractOld.Id);

                //we check the existing org contract and update the status to Active/Inactive based on the conditions.
                if(activeContractsMap.containsKey(objAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c) && setOrgOrderKeys.contains(strOrgOrderKey) && intCurrentQty > 0)
                    objOrgContract.Status__c = 'Active';
                else
                    objOrgContract.Status__c = 'Inactive';

                if(objOrgContractOld.Status__c != objOrgContract.Status__c)
                    setOrgContracts.add(objOrgContract);
            }
        }

        //Now, we upsert the org contract records
        upsertRecords(setOrgContracts);
    }

    /*
     Method Name : getAssets
     Description : This method returns list of assets based on the asset ids.
     Parameters  : Set<Id>, called from createOrgContracts, setAssetIds asset record ids.
     Return Type : List<Asset>
     */
    @TestVisible
    private static List<Asset> getAssets(Set<Id> setAssetIds){
        String strQuery = 'SELECT '+ASSET_QUERY_FIELDS+ ' FROM Asset WHERE Id IN :setAssetIds AND Org__c != null AND SBQQ__CurrentSubscription__r.SBQQ__Contract__c != null LIMIT 50000';
        return Database.query(strQuery);
    }

    /*
     Method Name : getAssets
     Description : This method returns list of assets with org associated under the contract ids.
     Parameters  : List<Id>, called from createOrgContracts, lstContractIds contract record ids.
     Return Type : List<Asset>
     */
    @TestVisible
    private static List<Asset> getAssets(List<Id> lstContractIds){
        String strQuery = 'SELECT ' +ASSET_QUERY_FIELDS+ ' FROM Asset WHERE Org__c != null AND SBQQ__CurrentSubscription__r.SBQQ__Contract__c IN :lstContractIds LIMIT 50000';
        return Database.query(strQuery); 
    }

    /*
     Method Name : getOrgContractQuantity
     Description : This method stores the total quantity for the orgcontract and returns the map.
     Parameters  : Set<Id>, called from createOrgContracts, setSubscriptionIds subscription record ids.
                   Map<Id, List<Id>>, called from createOrgContracts, subscriptionToOrgsMap.
     Return Type : Map<Id, Integer>
     */
    @TestVisible
    private static Map<String, Integer> getOrgContractQuantity(Set<Id> setSubscriptionIds, Map<Id, List<Id>> subscriptionToOrgsMap){
        Map<Id, Integer> subscriptionQuantityMap = new Map<Id, Integer>();
        Map<String, Integer> orgContractQuantityMap = new Map<String, Integer>();
        Map<Id, SBQQ__Subscription__c> subscriptionsMap = new Map<Id, SBQQ__Subscription__c>([SELECT Id,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__Quantity__c,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE Id IN :setSubscriptionIds OR SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c IN :setSubscriptionIds ORDER BY CreatedDate ASC LIMIT 50000]);

        //Now, we query the new and amended subscriptions
        for(SBQQ__Subscription__c objSubscription : subscriptionsMap.values()){
            Id subscriptionId;
            Integer intPreviousQuantity = 0;
            Integer intCurrentQuantity = 0;
            Integer intTotalQuantity;

            //New subscription
            if(objSubscription.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == null){
                intCurrentQuantity +=  (Integer) objSubscription.SBQQ__Quantity__c;
                subscriptionId = objSubscription.Id;
            }
            //Amended subscription
            else if(objSubscription.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null){
                intCurrentQuantity += (Integer) objSubscription.SBQQ__Quantity__c;
                subscriptionId = objSubscription.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c;
            }

            intPreviousQuantity = subscriptionQuantityMap.containsKey(subscriptionId) ? subscriptionQuantityMap.get(subscriptionId) : 0;
            intTotalQuantity = intPreviousQuantity + intCurrentQuantity;

            //we add subscription id and its total quantity
            subscriptionQuantityMap.put(subscriptionId, intTotalQuantity);
        }

        for(Id subscriptionRecId : subscriptionQuantityMap.keySet()){
            Id contractId = subscriptionsMap.get(subscriptionRecId)?.SBQQ__Contract__c;
            Integer intSubscriptionQty = subscriptionQuantityMap.get(subscriptionRecId);

            for(Id orgId : subscriptionToOrgsMap.get(subscriptionRecId)){
                String strKey = orgId +'##'+ contractId;
                Integer intQuantity = orgContractQuantityMap.containsKey(strKey) ? orgContractQuantityMap.get(strKey) : 0;
                intQuantity += intSubscriptionQty;

                orgContractQuantityMap.put(strKey, intQuantity);
            }
        }
        return orgContractQuantityMap;
    }

    /*
     Method Name : upsertRecords
     Description : This method upserts org contract records.
     Parameters  : Set<Org_Contract__c>, called from createOrgContracts, setOrgContracts org contract records to upsert.
     Return Type : None
     */
    @TestVisible
    private static void upsertRecords(Set<Org_Contract__c> setOrgContracts){
        if(!setOrgContracts.isEmpty()){
            Database.UpsertResult[] srList = Database.upsert(new List<Org_Contract__c>(setOrgContracts), false);
            for (Database.UpsertResult sr : srList) {
                if (!sr.isSuccess()){               
                    for(Database.Error err : sr.getErrors()) {                  
                        GAM.CreateExceptionRecords('OrgContractService --> Upsert of Org Contracts failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
}