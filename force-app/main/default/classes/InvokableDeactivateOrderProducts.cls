public with sharing class InvokableDeactivateOrderProducts { 
     @InvocableMethod(label='Deactivate OrderProducts' description='Deactivate order products')
      public static void deactivateOrderProducts(List<Id> ids) {
           FulfillmentService.deactivateOrderProducts(ids);
      }
}