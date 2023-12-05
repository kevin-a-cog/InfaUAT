/*
 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 N/A                    N/A             N/A             Initial version.                            N/A
 Vignesh Divakaran      2/8/2023        F2A-519         Added GTM_Model__c field to the SOQL query  T01
*/

public with sharing class InvokableShipCompleteOrderProducts {   

    
    @InvocableMethod(label='Provisioning Complete Order Products' description='Provisioning Complete Order Products')
    public static void invokeFulfillmentCreation(List<ID> ids) {
      
      FulfillmentData.updateOrderProductsToShipComplete(ids);  
      rollUpOrderedProductsToFulfillment(ids);  
   }

   public static List<Fulfillment_Line__c> getFulfillmentLines(List<Id> fulfillmentLines){
		/** Pavithra -28/10/2020 - Added the Fullfillment's Order field in the Query **/
        List<Fulfillment_Line__c> fflines = [select id,name ,License_Screen_Type2__c,Fullfillment__r.Order__c,
                                             Ship_Date__c,Start_Date__c,Ship_Status__c,Ship_via__c,Tracking_Number__c,Fullfillment__c,License_Serial_Number__c,
                                             (select id,name,
                                                  Fullfillment_Line__c, Order_Product__c, 
                                                  Order_Product__r.Order.Status,Order_Product__r.Ship_Date__c,Order_Product__r.Order.Revenue_Agreement_Processed__c, //added additional fields
                                                  Order_Product__r.OrderItemNumber,Order_Product__r.Product2Id,Order_Product__r.Product2.Name,Fullfillment_Line__r.Parent_ID__c,Fullfillment_Line__r.GTM_Model__c //<T01>
                                                  from Related_Fullfillment_Lines__r)
                                             from Fulfillment_Line__c
                                             where Id IN :fulfillmentLines];      
       return fflines;
        
    }

    public static void rollUpOrderedProductsToFulfillment(List<Id> fulfillmentLines){
      Map<Id,Set<Id>> fulfillmentHeadersByOrderId = new Map<Id,Set<Id>>();
      Map<Id, List<String>> productsOrderedByOrderId = new Map<Id, List<String>>();
      For(Fulfillment_Line__c fl: [Select Id,name, Fullfillment__c, Fullfillment__r.Order__c from Fulfillment_Line__c where Id In :fulfillmentLines]){
          if(!fulfillmentHeadersByOrderId.containsKey(fl.Fullfillment__r.Order__c)){
               fulfillmentHeadersByOrderId.put(fl.Fullfillment__r.Order__c, new Set<Id>());
          }
          fulfillmentHeadersByOrderId.get(fl.Fullfillment__r.Order__c).add(fl.Fullfillment__c);
      }
      for(orderItem oItem: [ Select Id,Product2.Name, OrderId
                                              from orderItem
                                              where OrderId In :fulfillmentHeadersByOrderId.keyset()
                                                 ])
      {
        
           if(!productsOrderedByOrderId.containsKey(oItem.OrderId)){
                 productsOrderedByOrderId.put(oItem.OrderId, new List<String>());
            }
            productsOrderedByOrderId.get(oItem.OrderId).add(oItem.Product2.Name);
      }
      List<Fulfillment__c> fulfillmentHeaders = new  List<Fulfillment__c>();
      for(Id orderId : fulfillmentHeadersByOrderId.keyset()){
          List<Id> fulfillmentHeaderIds = new List<Id>(fulfillmentHeadersByOrderId.get(orderId));
          for(Id ffheaderId : fulfillmentHeaderIds) {
              List<String> productsOrdered = productsOrderedByOrderId.get(orderId);
              Fulfillment__c fulfillment = new Fulfillment__c(Products_Ordered__c=String.join(productsOrdered, '\n            ')); 
              fulfillment.Id = ffheaderId;
              fulfillmentHeaders.add(fulfillment);
          }
      }
      update fulfillmentHeaders;

    }
}
/*
        

if(!ProductsOrderedByFulfillmentId.containsKey(rf.Fullfillment_Line__r.Fullfillment__c)){
                   ProductsOrderedByFulfillmentId.put(rf.Fullfillment_Line__r.Fullfillment__c, new List<String>() ); 
                 }
*/