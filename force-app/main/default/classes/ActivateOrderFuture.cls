/***************************************************************************
*        Name        :        ActivateOrderFuture
*        Author      :        Kendra Claiborne
*        Date        :        28 August 2017
*        Description :        Update Order record asynchronously using the @Future annotation
****************************************************************************
Change History
************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                 Tag    
Himanjan            18-Oct-17   Anil                Removed hard coded strings and used label                   #Labels             
and added null checks
Ambica Pyatu        11/27/2019  f2A-201             Added method to update order products                       <T01>
Ramya Ravi          09/06/2020      F2A             F2A-237 Ability to track provisioning/shipping
                                                    completed date                                               T02
Vignesh D           08/06/2020   F2A-244            Update Ship Date on order products with negative quantity   <T03>
Narpavi Prabu       28-SEP-2022   F2A-471           Replace the provisionable formula field ('Provisionable__c) with new checkbox 
                                                    field in Product ('Provisionable_New__c')                                                   
************************************************************************************************************************************
*/

public with sharing class ActivateOrderFuture {
    public static globalApexManager GAM = new globalApexManager();
    
    // #Labels
    static List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType =: Label.SOBJType_Order AND Name =: Label.Activated_Order_Name limit 1];
    
    /*
* Activate an Order by setting the Status to Activated
* 
* @param orderIds - Set of Order record Id(s)
* @return return - void
* @throws exception - NA
*/
    @Future
    public static void activateOrder(Set<Id> orderIds){
        List<Order> ordersToUpdate = new List<order>();
        
        //For all orders, change status to 'Activated'
        if(orderIds != null && orderIds.size() > 0) {
            for(Id orderId : orderIds) {
                ordersToUpdate.add(new Order(Id = orderId, RecordTypeId = rtList[0].Id, Status = 'Activated', StatusCode = 'A'));
            }
        }
        
        if(ordersToUpdate.size() > 0 && ordersToUpdate != null){
            try{
                Database.update(ordersToUpdate, false);
            } catch(Exception e){
                GAM.CreateLogs('ActivateOrderFuture.activateOrder() -> ' + e.getCause(), ordersToUpdate, 'ordersToUpdate');
            }
        }
        
        GAM.InsertDebugLogs();
    }
    
    /*
* Mark an Order "Review Completed" by setting the Status to Review Completed
* 
* @param orderids - Set of Order record Id(s)
* @return return - void
* @throws exception - NA
*/
    @Future
    public static void reviewCompletedOrder(Set<Id> orderIds){
        List<Order> ordersToUpdate = new List<order>();
        
        //For all orders, set status = 'Review Completed'
        if(orderIds != null && orderIds.size() > 0) {
            for(Id orderId : orderIds){
                ordersToUpdate.add(new Order(Id = orderId, Status = 'Review Completed'));
            }    
        }
        
        if(ordersToUpdate.size() > 0 && ordersToUpdate != null){
            try{
                Database.update(ordersToUpdate, false);
            } catch(Exception e){
                GAM.CreateLogs('ActivateOrderFuture.reviewCompletedOrder() -> ' + e.getCause(), ordersToUpdate, 'ordersToUpdate');
            }
        }
        
        GAM.InsertDebugLogs();
    }
    
    //--------------------------------------------<T01>
    /*
* Mark an OrderProduct "Provisioning Complete" Based on Provisionable flag
* 
* @param orderids - Set of Order record Id(s)
* @return return - void
* @throws exception - NA
*/
    @Future
    public static void OrderProductsProvisioningCompelete(Set<Id> orderIds){
        List<OrderItem> ordersProductsToUpdate = new List<orderItem>();
        
        system.debug('*********OrderProductsProvisioningCompelete');
        //For all orders, set status = 'Review Completed'
        if(orderIds != null && orderIds.size() > 0) {
            
            For(OrderItem oi : [Select id, Product2.Provisionable_New__c ,ServiceDate, SBQQ__Status__c, Order.EffectiveDate from orderitem where  (Product2.Provisionable_New__c=false 
                                or (TotalPrice < 0 and Quantity < 1)) // T03 added additional filters to include order products with negative quantity
                                and orderid in :orderIds]){
                                    //ordersProductsToUpdate.add (new OrderItem (Id= oi.id, SBQQ__Status__c= 'Provisioning Complete',Ship_Date__c = oi.ServiceDate)); //T02
                                    ordersProductsToUpdate.add (new OrderItem (Id= oi.id, Ship_Date__c = oi.ServiceDate));
                                }
            
        }   
        
        
        if(ordersProductsToUpdate.size() > 0 && ordersProductsToUpdate != null){
            try{
                Database.update(ordersProductsToUpdate, false);
            } catch(Exception e){
                GAM.CreateLogs('ActivateOrderFuture.OrderProductsProvisioningCompelete() -> ' + e.getCause(), ordersProductsToUpdate, 'ordersProductsToUpdate');
            }
        }
        
        GAM.InsertDebugLogs();
    }
    
    //--------------------------------------------</T01>
    
}