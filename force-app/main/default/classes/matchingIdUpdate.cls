/****************************************************************************************************************************
 *  @Class Name: updateMatchingId
 *  @Author: Nishit S
 *  @Date: 26 JAN 2022
 *  @Description: Invokable class for Contract Flow
 *****************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy          Date      Requested By    Description                                  Tag   
 
 Nishit S          1/11/2023    Finance        I2C-1777 Usages in Salesforce
 ****************************************************************************************************************************/
public class matchingIdUpdate {
    public static globalApexManager GAM = new globalApexManager();
    @TestVisible private static String fromTestClass;
    
    @InvocableMethod(label='Update Matching ID' description='Update Maching IDs on Usage Summary')
    public static void updateMatchingId(List<ID> ids){ 
        List<blng__UsageSummary__c> usUpdateList = new List<blng__UsageSummary__c>();
        Set<Id> paygAccountIdSet = new Set<Id>(); 
        Map<Id, String> orderIdContractNumMap = new Map<Id, String>();
        Set<Id> orderIdSet = new Set<Id>();  
        Set<Id> oldOrderIdSet = new Set<Id>();
        Map<Id, String> orgAccIdMap = new Map<Id, String>();
        Map<Id, String> orderOrgIdMap = new Map<Id, String>();
        Map<Id, String> orderItemOrgIdMap = new Map<Id, String>();
        Set<Id> paygOrderIdSet = new Set<Id>();
        
        for(Contract contract : [SELECT Id, SBQQ__Order__r.Source__c, AccountId, SBQQ__Order__c, ContractNumber
                                  FROM Contract WHERE Id IN :ids]){
            if(contract.SBQQ__Order__r.Source__c == 'Ecommerce - Paygo'){
                paygAccountIdSet.add(contract.AccountId);
                paygOrderIdSet.add(contract.SBQQ__Order__c);
            }
            orderIdContractNumMap.put(contract.SBQQ__Order__c, contract.ContractNumber);
            
                
            orderIdSet.add(contract.SBQQ__Order__c);
        }
        String GTM_Model = Label.IPU_Product_GTM_Value;
        for(OrderItem OrderItem : [SELECT SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.OrderId FROM OrderItem where OrderId IN :orderIdSet AND Order.type = 'Amendment' AND Product2.GTM_Model__c = :GTM_Model ]){
            oldOrderIdSet.add(OrderItem.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.OrderId);
        }
        system.debug('orderIdSet'+orderIdSet);
        //Get Org list
        for(Org__c org : [SELECT Id, Account__c, OrgID__c FROM Org__c WHERE Account__c IN :paygAccountIdSet]){
            orgAccIdMap.put(org.Account__c, org.OrgID__c);
        }
        /*for(Fulfillment_Line__c ffLine :[select Org_UUID__c, Org__c, Fullfillment__r.Order__c, Org__r.OrgType__c  FROM
                                         Fulfillment_Line__c where Org_UUID__c != null and Org__r.OrgType__c = 'Production' AND Fullfillment__r.Order__c IN :orderIdSet]){
                                             orderOrgIdMap.put(ffLine.Fullfillment__r.Order__c, ffLine.Org_UUID__c);
                                                                                          
                                         }*/
        
        for(Related_Fulfillment_Line__c relatedFfLine : [SELECT Order_Product__c, Fullfillment_Line__r.Org__c,  Fullfillment_Line__r.Org_UUID__c, 
                                                         Fullfillment_Line__r.Org__r.OrgType__c 
                                                         FROM Related_Fulfillment_Line__c 
                                                         WHERE (Order_Product__r.OrderId IN :orderIdSet OR  Order_Product__r.OrderId IN:oldOrderIdSet)//Order_Product__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__r.OrderId IN :orderIdSet) 
                                                         AND Fullfillment_Line__r.Org__r.OrgType__c = 'Production' AND Fullfillment_Line__r.Org_UUID__c != null 
                                                         AND Order_Product__r.Product2.GTM_Model__c = :GTM_Model AND Order_Product__r.Product2.Product_Category__c = 'Wrapper']){
                                                             orderItemOrgIdMap.put(relatedFfLine.Order_Product__c, relatedFfLine.Fullfillment_Line__r.Org_UUID__c);
                                                         }
        
        //Get Usage Summaries 
        
        for(blng__UsageSummary__c usageSummary : [SELECT Id, blng__MatchingId__c, blng__OrderProduct__c, blng__OrderProduct__r.SBQQ__RequiredBy__c, 
                                                  blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
                                                  blng__Account__c, blng__OrderItemConsumptionSchedule__c, blng__OrderProduct__r.Product2.GTM_Model__c,
                                                  blng__Order__c, blng__OrderProduct__r.Product2.Offering_ID__c, blng__OrderItemConsumptionSchedule__r.SBQQ__ConsumptionSchedule__r.IICS_Meter_ID__c,
                                                  blng__OrderProduct__r.Product2.Option_Scale__c, blng__OrderProduct__r.Product2.SBQQ__HasConsumptionSchedule__c,blng__OrderProduct__r.Order.type
                                                  FROM blng__UsageSummary__c WHERE blng__MatchingId__c = NULL AND blng__Order__c IN :orderIdSet]){
                                                      if((usageSummary.blng__OrderProduct__r.Product2.GTM_Model__c == GTM_Model && usageSummary.blng__OrderProduct__r.Product2.SBQQ__HasConsumptionSchedule__c) || fromTestClass == 'flexIPU'){
                                                          blng__UsageSummary__c newUS = new blng__UsageSummary__c(Id = usageSummary.Id);
                                                          if((usageSummary.blng__OrderProduct__r.Order.type == 'Amendment' && usageSummary.blng__OrderProduct__r.SBQQ__RequiredBy__c == NULL && usageSummary.blng__OrderProduct__r?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__r?.SBQQ__OrderProduct__c != null) || fromTestClass == 'flexIPU'){
                                                              newUS.blng__MatchingId__c = orderItemOrgIdMap.get(usageSummary.blng__OrderProduct__r?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__r?.SBQQ__OrderProduct__c);
                                                          }
                                                          else
                                                              newUS.blng__MatchingId__c = orderItemOrgIdMap.get(usageSummary.blng__OrderProduct__r.SBQQ__RequiredBy__c);
                                                          if(usageSummary.blng__OrderProduct__r.Product2.Option_Scale__c == 'Overage')
                                                              newUS.blng__MatchingId__c = newUS.blng__MatchingId__c + ':Overage';
                                                          usUpdateList.add(newUS);
                                                          
                                                          
                                                      }
                                                      else if(paygOrderIdSet?.contains(usageSummary.blng__Order__c)){
                                                          usUpdateList.add(new blng__UsageSummary__c(
                                                              Id = usageSummary.Id, 
                                                              blng__MatchingId__c = orgAccIdMap.get(usageSummary.blng__Account__c) + ':' + usageSummary.blng__OrderItemConsumptionSchedule__r.SBQQ__ConsumptionSchedule__r.IICS_Meter_ID__c,
                                                              Org_Id__c = orgAccIdMap.get(usageSummary.blng__Account__c)));
                                                      }
                                                      else{
                                                          usUpdateList.add(new blng__UsageSummary__c(
                                                              Id = usageSummary.Id, 
                                                              blng__MatchingId__c = orderIdContractNumMap.get(usageSummary.blng__Order__c) + ':'+ usageSummary.blng__OrderProduct__r.Product2.Offering_ID__c));
                                                      }
        }
        
        try{
            if(usUpdateList?.size() > 0){
                update usUpdateList;
            }
        }
        catch(System.Exception ex){
            GAM.CreateExceptionRecords('Error in Update Matching ID', ex.getMessage(), 'error from updateMatchingId');
        }
        //return null;
    }
    
}