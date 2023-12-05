/*
 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 N/A                    N/A             N/A             Initial version.                            N/A
 Vignesh Divakaran      2/2/2023        F2A-500         Flex IPU Org Entitlement creation           T01
*/

public with sharing class InvokableGenerateFulfillments{
    @InvocableMethod(label='Generate Fulfillment Data' description='Generate Fulfillment Data')
    public static void invokeFulfillmentCreation(List<Id> ids) {
      System.debug(LoggingLevel.ERROR, 'InvokableGenerateFulfillments: Process builders');
      
      if(ids.size()==1){
         OrgEntitlementService.createOrgEntitlements(ids[0]); //<T01>
         ManageFulfillmentCtrl.createFulfillments(ids[0]);
         OrgEntitlementService.updateFLOnOrgEntitlementLine(ids[0]); //<T01>         
      }
      else if(ids.size()>1){
       List<Id> onPremiseOrders = new List<Id>(); 
       for(AggregateResult AR: [Select Count(Id) ocount,OrderId orderId from orderItem 
                                where /*Product2.Delivery_Method__c ='On Premise'  and */ OrderId In :ids
                                group by OrderId ] ){
           Integer count = Integer.valueOf(AR.get('ocount'));
           if(count>0){
              String onPremiseOrderId = String.valueOf(AR.get('orderId'));
              onPremiseOrders.add(onPremiseOrderId);
           }

       }
       //Orders have been migrated with status Ready for Provisioning
       if(onPremiseOrders.size()>0){
          fulfillmentBatch  db = new fulfillmentBatch(getOrderSobjects(onPremiseOrders));
          database.executeBatch(db,1);
       }
       
      }
      
      
   }

   public static List<Order> getOrderSobjects(List<Id> Ids){
     List<Order> Orders = new List<Order>();
     for(Id id: Ids){
        Order order = new Order();
        order.Id = id;
        Orders.add(order);
     }
     return Orders;
   }
}