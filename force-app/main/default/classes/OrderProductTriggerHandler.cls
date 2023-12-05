/**************************************************************************************************************************************************
*        Name        :        OrderProductTriggerHandler
*        Author      :        Krishna
*        Date        :        19 July 2017
*        Description :        Handler class for OrderProductTrigger
***************************************************************************************************************************************************
Change History
***************************************************************************************************************************************************
ModifiedBy                  Date    Requested By            Description                                                               Tag
Thejaswini Sattenapalli  16/08/2017                         worked on update opportunity product sales price base on SOP Amount
Rupanjana Mitra          14/09/2017                         added method: alignBillingDates to align billing dates for amendments
Rupanjana Mitra          15/09/2017                         added method: setUpdateOrderProduct to set and update OrderProduct
Kendra                   10/05/2017                         Updated Billing Alignment Date logic
Kendra Claiborne         10/06/2017                         Updated how OrderItem.blng__InvoiceGrouping__c and OrderItem.blng__LegalEntity__c 
                                                            get populated since the previous logic was not populating the fields
Kendra Claiborne         10/10/2017 Elena Merill            Moved setUpdateOrderProduct() to be initiated from Before Insert to After Insert.
                                                            This resolved the issue of  Billing GL Treatment and Billing Treatment 
                                                            not getting populated.                          
Kendra Claiborne        10/10/2017  Elena Merill            Added logic in After Update context to pouplate the Invoice Grouping Id 
                                                            with the value in Purchase Order Po Number if it is changed. This is needed
                                                            because Invoice Grouping now relies on "Invoice Group ID".     
Kendra Claiborne        10/11/2017  Anil Solanki            Updated logic that updates the Opportunity Statement of Position 
                                                            and Order Product fields based on the junction object, Quote Line, 
                                                            between Order Product and Opportunity Line Item.    
Rupanjana Mitra         10/18/2017  Anil Solanki            Update SOP and Order Product on Opp Line Item only when currency code of Order Product and Opp Line item match    
Sarah Beccari           10/18/2017                          Commented code for Asset handling. AssetSyncHandler.cls now holds the code for Asset creation and updates.  
Kendra Claiborne        12/13/2017  Shobhit Sharma          Updated code in setUpdateOrderProduct to populate the Override Next Billing Date with the Order Line Item's Created Date
Vidya Das - PRM           4/7/2018                          Created new method "updateCPQBillingRulesForPRM" to create dummy rules for Order Type ='Partner Fee' for PRM
Anil Solanki             7/29/2019  CPQ-Upgrade             Removed the AssetSyncHandler call from the handleAfterInsert Method and move the call to 'Order -Review and Orchestration' Process builder with a 6 minute delay<T01>
Venkata Sabbella         09/2019    Fulfillment Changes     Order Product to update Order to Provisioning Complete.<T02> 
Anil Solanki            10/28/2019  Salesrt-11207           Updated setUpdateOrderProduct method to update Bill through Override date based on Override Billing frequency on Quote<T03>
Ambica Pyati            11/20/2019  F2A-201                 Remove the exceptions while updating order status to provisioning complete  <T05>
RamEsh M S              12/27/2019  CPQ Upgrade             Moving the code pieces that updates Legal Entity as the logic is moved to Process Builder. <T006>
RamEsh M S              12/27/2019  CPQ Upgrade             Moving the "Order Product - Update" Process Builder of Version 12 to AfterInsert Trigger
RamEsh M S              03/02/2020  Eric Brown              Added logic to update Dated Conversion Rate of Opportunity to "Oppty Conv Rate" field for SALESRT-11593<T007>
Ambica P                04/15/2020  I2C-656                 Disable Invoice Creation for Admin Orders <T08>
RamEsh M S              05/05/2020  SALESRT-11986           Blank Bill Through Date Override for DaaS Early Renewals <T09>
Ramya Ravi              09/06/2020  F2A                     F2A-237 Ability to track provisioning/shipping completed date    <T10>
RamEsh M S              07/07/2020  I2C-659                 Update Revene Recognition Rule on Feature/Wrapper OP not to create RS on Order activation <T11>

Anil Solanki            04/08/2002  I2C-726                 Order Stages :Remove code to update Order Status <T12>
Kiran G                 08/07/2020  SALESRT-12040           Copy the Quantity to OrderedQuantity CPQ field for ES PS Orders   <T13>
RamEsh M S              10-AUG-2020                         Copy Ship Date and Provisioning Completed Date to Revenue Schedules     <T14>
RamEsh M S              11-AUG-2020  I2C-728                Added check for Revision Opportunity and Enable Downstream to create Revenue Schedule<T15>
RamEsh M S              28-AUG-2020                         populate Ship Date for Non-Provisionable products OR Full Debook Amendment OR Cancelled Products OR Revision Oppty Or Direct Orders  <T16>
Pavithra V              05-NOV-2020  F2A-309                To update the latest ship date (from Order products) to the Fulfillment completed date <T17>
RamEsh M S              10-NOV-2020  F2A-309                Sync Ship Date and Deferred Revenue Acc Date on RS from Order Product <T18>
Pavithra V              16-DEC-2020  F2A-329                To update the Ship date on the order product to be in line with order generation date for all the non-provisionable products <T19>
RamEsh M S              28-JAN-2021  SALESRT-12760          To exclude products whose End Date is in past on updating Override Next Billing Date on MR Renewal with One-Time Billing  <T20>
RamEsh M S              24-FEB-2021  SALESRT-12862          To exclude products whose End Date is in past on updating Override Next Billing Date  <T21>
Pavithra V              03-MAR-2021  F2A-327                Auto-populate the ship dates for the perpetual lines  <T22>
Chandana Gowda          09-Mar-21    TAX-18                 Twining Tax category from Quote Line <T23>
RamEsh M S              26-APR-2021  SALESRT-11716          Fix ONDB on cancellation of products having start date in Future <T24>
RamEsh M S              15-MAY-2021  I2C-1022               Amendment Order activation with Custom Billing, Billing Frequency = Invoice Plan of amended lines <T25>
RamEsh M S              29-JUL-2021  I2C-1331               Updating Bill Through Date Override on Original Product (mostly for POT Support) of Original Order when parnet is cancelled manually from Amend process <I2C-1331>
Chandana Gowda          26-Aug-2021  SALESRT-13192          Removing the partial update when SOP Writeback happens from orderProduct to optyLine <T13192>
Wasim                   27-OCT-2021   I2C-1395              Review of All items that flow into the RA with No Extended list price <I2C-1395>
RamEsh M S              07-DEC-2021   I2C-1448              Do not accelerate Invoice on Original Order or Lines when Early Terminated <I2C-1448>
RamEsh M S              02-FEB-2022   I2C-1489              Do not accelerate Invoice on Original Order or Lines when Early Terminated <I2C-1489>
Wasim                   28-FEB-2022   I2C-1506              CPQ Invoice Acceleration automation & Default Bill Feq='Invoice Plan' for Order with products having different dates <I2C-1506>
Puneet                  20-Sep-2022   SALESRT-14387         [Tech Debt] - Move Scheduled Jobs to Apex Trigger
Narpavi Prabu           28-SEP-2022   F2A-471               Replace the provisionable formula field ('Provisionable__c) with new checkbox field in Product ('Provisionable_New__c')  
Nishit                  10-JAN-2023   I2C-1804              Adding Status to the filter, to query only pending Billing Transactions <I2C-1804>
Nishit S                03-MAY-2023   I2C-1928              0$ invoice is getting generated for the daily for some of the orders where the bill through date override is populated      <I2C-1928>
Nishit S				17-OCT-2023	  TAX-376				Update Tax Category Logic for Order Products																				<TAX-376>
********************************************************************************************************************************************************************/
public without sharing class OrderProductTriggerHandler{ 
    
    public static globalApexManager GAM = new globalApexManager();
    
    
    
    /*
    * Handle AFTER UPDATE trigger
    * Creates Asset and entitlements reocrds when OrderItem is updated and quantitiy is increased
    */
    public static void afterUpdate(List<OrderItem> newList, Map<Id, OrderItem> newMap, Map<Id,OrderItem> oldMap){
        GAM.CreateLogs('OrderProductTriggerHandler --> afterUpdate',newList,'newList: ');
        set<id> setofOrderItemID = new set<id>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, OrderItem> quoteLineOrderItemMap = new Map<Id, OrderItem>();
        
        //for update start and end date
        set<Id> setOfOrderItem = new set<Id>();
        Set<Id> amendedOrderIds = new Set<Id>();
        Set<String> originalOrderNumberSet = new Set<String>();
        List<Order> ordersToUpdate = new List<Order>();
        OrderItem tempOrderItem;
        Map<Id, OrderItem> oiUpdateMap = new Map<Id, OrderItem>();
        Set<String> OrderIdsForProvisionComplete = new Set<String>();
        Set<String> OrderIdsForReadyForProvisioning = new Set<String>();
        Set<Id> orderIdsforRevAgr = new Set<Id> (); //<T14>
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem> ();
        for(OrderItem orderItem : [SELECT Id, Ship_Date__c, OrderId, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, SBQQ__Activated__c, blng__LegalEntity__c, Purchase_Order_PO_Number__c, ServiceDate, EndDate, SBQQ__OrderedQuantity__c, Statement_of_Position_SOP_Amount__c,CurrencyIsoCode,
                                    Order.Status, Product2.Forecast_Product__c,Order.Provisioning_Complete_Date__c,Order.Revenue_Agreement_Processed__c
                                    FROM OrderItem WHERE Id IN :newMap.keySet()]){
            
            if((orderItem.ServiceDate != oldMap.get(orderItem.Id).ServiceDate) || (orderItem.EndDate != oldMap.get(orderItem.Id).EndDate)){
                setOfOrderItem.add(orderItem.Id);
            }
                                       
            // check if Statement_of_Position_SOP_Amount__c field value is change then add the OrderItem Id to set
            if(orderItem.Statement_of_Position_SOP_Amount__c != oldMap.get(orderItem.Id).Statement_of_Position_SOP_Amount__c){
                setofOrderItemID.add(orderItem.Id);
                quoteLineOrderItemMap.put(orderItem.SBQQ__QuoteLine__c, orderItem);
            }
            
            // update Order status to provisioning Complete.
            Set<String> opStatusSet = new Set<String>{'Activated','Provisioning Complete'};
            String ORDERPRODUCT_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
            String ORDERPRODUCT_STATUS_DRAFT = 'Draft';
            String ORDER_STATUS_PROVISIONING_COMPLETED = 'Provisioning Completed';
            String ORDER_STATUS_REVIEW_AND_FULFILL = 'Activated';
            
            String PRODUCT2_FORECAST_PRODUCT_SUPPORT='Support';
            OrderItem tgrdoitem = newMap.get(orderItem.Id);
            Set<String> OrderStatuses = new Set<String>{   'Provisioning In Progress' ,'Ready for Provisioning' };//'Activated' 'Cancelled' 'Draft' 'Provisioning Completed' 'Review Completed'
            //Set Order Status To provisioning Complete if all the orders Providucts are Activated.
            //if(ORDERPRODUCT_STATUS_PROVISIONING_COMPLETE.equals(tgrdoitem.SBQQ__Status__c) &&  OrderStatuses.contains(orderItem.Order.Status) && !PRODUCT2_FORECAST_PRODUCT_SUPPORT.equals(orderItem.Product2.Forecast_Product__c)){ //<T10>
            //<T12> I2C-726 : Check for Review and Fulfill
            ///<T17> Commented this cond. as part of <T17> - && orderItem.Order.Provisioning_Complete_Date__c == null && oldMap.get(orderItem.Id).Ship_Date__c == null </T17>**/
                if( tgrdoitem.Ship_Date__c != null && ORDER_STATUS_REVIEW_AND_FULFILL.equals(orderItem.Order.Status)){ /**<T17/>**/
                    OrderIdsForProvisionComplete.add(orderItem.OrderId);
                    System.debug('Added Order to Provisioning Complete');
                }
            // Revert back order status if Atleast one of the Order product is reverted back to 'Draft'
            //if(ORDERPRODUCT_STATUS_DRAFT.equals(tgrdoitem.SBQQ__Status__c) && ORDER_STATUS_PROVISIONING_COMPLETED.equals(orderItem.Order.Status) //<T10>
                 //<T12> I2C-726 : Check for Review and Fulfill
                 if( tgrdoitem.Ship_Date__c == null && ORDER_STATUS_REVIEW_AND_FULFILL.equals(orderItem.Order.Status)){
               OrderIdsForReadyForProvisioning.add(orderItem.OrderId);
               System.debug('Added Order to NOT Provisioning Complete');
            }
            
            //<T18> if(orderItem.Ship_Date__c != null && oldMap.get(orderItem.Id).Ship_Date__c == null && oldMap.get(orderItem.Id).Ship_Date__c != orderItem.Ship_Date__c) //<T14>
             if(orderItem.Ship_Date__c != null && oldMap.get(orderItem.Id).Ship_Date__c != orderItem.Ship_Date__c && !orderItem.Order.Revenue_Agreement_Processed__c && orderItem.Order.Status != 'Draft') //<T18>
                 orderIdsforRevAgr.add(orderItem.OrderId);
        }
        
        //Query for Quote Lines captured in quoteLineOrderItemMap
        if(quoteLineOrderItemMap != null)
            quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Primary__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineOrderItemMap.keySet() AND SBQQ__Quote__c != null AND SBQQ__Quote__r.SBQQ__Primary__c = True]);
        
        //Query for Opportunity Line Items whose Quote Line was captured in quoteLineMap
        if(quoteLineMap != null)
            oliList = [select Id, CurrencyIsoCode,Statement_of_Position_SOP_Amount__c, Order_Product__c, SBQQ__QuoteLine__r.Id,SBQQ__QuoteLine__c FROM OpportunityLineItem WHERE SBQQ__QuoteLine__c in :quoteLineMap.keySet()];
        
        GAM.CreateLogs('OrderProductTriggerHandler --> afterUpdate', oliList, 'oliList: ');
        
        for(OpportunityLineItem oli :oliList){
            if(oli.SBQQ__QuoteLine__c != null){
                
                //check if Order Product currency code matches Opp Line Item currency code
                if(null != oli.CurrencyIsoCode && null != quoteLineOrderItemMap.get(oli.SBQQ__QuoteLine__r.Id).CurrencyIsoCode && oli.CurrencyIsoCode == quoteLineOrderItemMap.get(oli.SBQQ__QuoteLine__r.Id).CurrencyIsoCode){
                    oli.Order_Product__c = quoteLineOrderItemMap.get(oli.SBQQ__QuoteLine__r.Id).Id;
                
                    //Assign the Opportunity Line Item's SOP to the related Quote Line SOP value
                    if(quoteLineOrderItemMap.get(oli.SBQQ__QuoteLine__r.Id).Statement_of_Position_SOP_Amount__c != null){
                        oli.Statement_of_Position_SOP_Amount__c = quoteLineOrderItemMap.get(oli.SBQQ__QuoteLine__r.Id).Statement_of_Position_SOP_Amount__c;
                    }
                }
            }    
        }
        
        if(setOfOrderItem.size() > 0){        
            updateDate(setOfOrderItem); 
        }
        
        
        if(oliList != null && oliList.size() > 0){
            try{Database.SaveResult[] srList = Database.update(oliList,true); //Removed Partial Update <T13192>
            } catch(DmlException e){GAM.CreateExceptionRecords('OrderProductTriggerHandler --> afterUpdate', e.getMessage(), 'error from afterUpdate');
            }
        }
        //<T02>
        updateOrderStatus(OrderIdsForProvisionComplete);
        revertBackOrderToReadyForProvisioning(OrderIdsForReadyForProvisioning);
        if(orderIdsforRevAgr.size () > 0)  //<T14>
        {
            revenueAgreementCancelFulfillDate updateDateJob = new revenueAgreementCancelFulfillDate(orderIdsforRevAgr,'Ship_Prov_Date');
            ID jobID = System.enqueueJob(updateDateJob);
        }
        GAM.InsertDebugLogs();
    }
    /**
    //<T02>
    From the list of updated order Items, find orders that have all orderitems provisioning completed and update the order to provisioning completed.
    To find orders that have  all the order items as provisioning completed, we find and remove orders with Order items that have draft or other status values which are not 'Ready for Provisioning.'
     */
    Public static void updateOrderStatus(Set<String> OrderIds){
            System.debug(LoggingLevel.ERROR, 'OrderIds:before'+JSON.serialize(OrderIds)); 
            System.debug('BEFORE OrderIds' + OrderIds);
            if(OrderIds.size()>0){
                /*
               //Map<Id,Boolean> OrdersToProvisionComplete 
               /*Set<String> productCategoryExceptions = new Set<String>{'Feature','','Wrapper'};  
               Set<String> forecastProductExceptions = new Set<String>{'Subscription Support','Support','Professional Services'};*/
               String productCategoryExceptionStr = Label.Product_Category_Exceptions;
               //'Feature','','Wrapper'
               Set<String> productCategoryExceptions = new Set<String>(productCategoryExceptionStr.split(','));
               String forecastProductExceptionStr = Label.Forecast_Product_Exceptions;
               //'Subscription Support','Support','Professional Services'
               Set<String> forecastProductExceptions = new Set<String>(forecastProductExceptionStr.split(','));
               List<AggregateResult> aggresultList = [Select Count(Id) ocount, OrderId orderId,SBQQ__Status__c, Ship_date__c from OrderItem 
                                                      where (SBQQ__Status__c = 'Activated' AND Ship_date__c = null) and
                                                      OrderId In :OrderIds  
                                                      group by OrderId,SBQQ__Status__c,Ship_date__c];
            for(AggregateResult AR:aggresultList){
                Integer count = Integer.valueOf(AR.get('ocount'));
                if(count>0){
//-----------------------------------------------------------  <T05>
 /*                   //Exceptions
                    String prodCategory = AR.get('prodCategory')!=null?String.ValueOf(AR.get('prodCategory')):'';
                    String forecastProduct = AR.get('forecastProduct')!=null?String.ValueOf(AR.get('forecastProduct')):'';
                    if(productCategoryExceptions.contains(prodCategory) || forecastProductExceptions.contains(forecastProduct))
                    {
                        continue;
                  }
*/  
//--------------------------------------------------------------</T05>
                    //Donot update the Order with Provisioning Complete status.
                    String orderId = String.ValueOf(AR.get('orderId'));
                    OrderIds.remove(orderId);
                }
            }
            System.debug('AFTER OrderIds' + OrderIds);
            System.debug(LoggingLevel.ERROR, 'OrderIds:after'+JSON.serialize(OrderIds));
            if(OrderIds.size()>0){
                /**<T17> STARTS*//** Get the maximum fulfillment date from Fulfillment lines**/
                Map<Id,Date> maxShipDateMap = new Map<Id,Date>();
                Map<Id,Date> maxFulfillDateMap = new Map<Id,Date>();
                
                for(AggregateResult res : [SELECT max(Ship_Date__c) maxdate, Fullfillment__r.Order__c ffOrderId 
                                           FROM Fulfillment_Line__c 
                                           WHERE Fullfillment__r.Order__c IN:OrderIds 
                                           AND Fullfillment__r.Active__c = true
                                           GROUP BY Fullfillment__r.Order__c ]){
                                             
                   Date maxFulfillDate  = Date.valueOf(res.get('maxdate'));
                   String ffOrderId = String.ValueOf(res.get('ffOrderId'));
                   maxFulfillDateMap.put(ffOrderId,maxFulfillDate);                             
                }
                System.debug('maxFulfillDateMap==>'+ maxFulfillDateMap);
                
                /** Get the maximum ship date from Order products**/
                if(maxFulfillDateMap.keySet().size() != OrderIds.size()){
                    for(AggregateResult res : [SELECT max(Ship_Date__c) mdate, OrderId orderId 
                                               FROM OrderItem 
                                               WHERE OrderId IN:OrderIds
                                               GROUP BY OrderId]){
                                                   
                                               Date maxShipDate  = Date.valueOf(res.get('mdate'));
                                               String orderId = String.ValueOf(res.get('orderId'));                           
                                               maxShipDateMap.put(orderId,maxShipDate);                         
                                                   
                    }
                }
                System.debug('maxShipDateMap==>'+ maxShipDateMap);
                /**<T17> ENDS*/
                
               List<Order> Orders = new List<Order>();
               for(Id orderId: OrderIds){
                   //<T 12> START //Order order = new Order( Status = 'Provisioning Completed' ,Provisioning_Complete_Date__c = Date.Today());
                   /**<T17>*/ //Provisioning_Complete_Date__c = Date.Today()/** Commented as part of <T17>*/
                   //<T 12> END
                   
                   /*<T17> STARTS F2A-309
                    *If there is any fulfillment lines then the Fulfillment Completed date is the maximum of fulfillment date.
                    *If there are NO fulfillment lines then the Fulfillment Completed date is the maximum of Order product's ship date.
                    */
                   Date ffCompletedDate;
                   if(maxFulfillDateMap.containsKey(orderId)){
                       ffCompletedDate = maxFulfillDateMap.get(orderId);
                   }else{
                       ffCompletedDate = maxShipDateMap.get(orderId);
                   }
                   Order order = new Order(Provisioning_Complete_Date__c = ffCompletedDate); 
                   order.Id = orderId;
                   /**<T17/> ENDS**/
                  Orders.add(order);
                 }  
               Update Orders;
             }
           }
           return;
    }
    //OrderProductTriggerHandler.revertBackOrderToReadyForProvisioning
    public static void revertBackOrderToReadyForProvisioning(Set<String> OrderIds){
        if(OrderIds.size()>0){
            System.debug(LoggingLevel.ERROR, 'OrderIds:after'+JSON.serialize(OrderIds));
            System.debug(LoggingLevel.ERROR, 'OrderIds:after size'+ OrderIds.size());
            List<Order> Orders = new List<Order>();
               for(Id orderId: OrderIds){
                  //System.assert(false, 'Assert here..');
                    //<T 12> START
                 //Order order = new Order( Status = 'Provisioning In Progress'  ,Provisioning_Complete_Date__c = null);
                  Order order = new Order(Provisioning_Complete_Date__c = null);
                  //<T 12> END
                  order.Id = orderId;
                  Orders.add(order);
                 }
            Update Orders;
        }
    }
    /*
    method Name : updateDate,
    * @param PriceBookMap - set of Order Item Id's
    * @return return-NA
    * @throws exception - NA
    * for update start and end date on Quote Line ,Asset and Entitlements
    */   
    public static void updateDate(set<id> orderItemIds){
        // create a set of Asset Id  
        set<Id> setOfAssetIds = new set<id>();
        try{
            // Query Order Item alogn with there Assets  
            List<orderItem> lstOrderItemWithAsset = [select id,ServiceDate,EndDate,SBQQ__QuoteLine__c,
                                                     (select id,Status from SBQQ__Assets__r)
                                                     FROM OrderItem WHERE Id IN : orderItemIds];
            
            // play a for loop on lstOrderItemWithAsset and add Asset Id to the set    
            for(orderItem orderItem : lstOrderItemWithAsset){
                for(Asset oAsset : orderItem.SBQQ__Assets__r){
                    setOfAssetIds.add(oAsset.Id);
                } 
            }
            
            map<id,Asset> mapIdWiseAssetWithEntitelment = new map<id,Asset>();
            for(Asset oAsset :[SELECT id,Status,
                               (SELECT id FROM Entitlements)
                               FROM Asset WHERE Id IN: setOfAssetIds]){
                                   mapIdWiseAssetWithEntitelment.put(oAsset.Id, oAsset);                                           
                               }
            List<Asset> lstAssetForUpdate = new List<Asset>();
            List<Entitlement> lstEntitlementForUpdate = new List<Entitlement>();
            List<SBQQ__QuoteLine__c> lstQuoteLineItemForUpdate = new List<SBQQ__QuoteLine__c>();
            
            // play a for loop on lstOrderItemWithAsset 
            for(orderItem orderItem : lstOrderItemWithAsset){
                // create a QuoteLineItem object and set the start and end date  
                SBQQ__QuoteLine__c oQuoteLineItem = new SBQQ__QuoteLine__c();
                oQuoteLineItem.Id = orderItem.SBQQ__QuoteLine__c;
                oQuoteLineItem.SBQQ__StartDate__c = orderItem.ServiceDate;
                oQuoteLineItem.SBQQ__EndDate__c = orderItem.EndDate;
                lstQuoteLineItemForUpdate.add(oQuoteLineItem);
                
                // play a for loop on Asset    
                for(asset oAsset: orderItem.SBQQ__Assets__r){
                    if(mapIdWiseAssetWithEntitelment.containsKey(oAsset.Id)){
                        // get the asset(with Entitlements) from asset Id  
                        // set the asset InstallDate and UsageEndDate
                        asset oTempAsset = mapIdWiseAssetWithEntitelment.get(oAsset.Id);
                        oTempAsset.SBQQ__SubscriptionStartDate__c =  orderItem.ServiceDate;
                        oTempAsset.SBQQ__SubscriptionEndDate__c = orderItem.EndDate;
                        // check if status of Asset eequal to 'Provisioning Complete' then update it to Marked for Review  
                        if(oTempAsset.Status == Label.Provisioning_Complete_Status || oTempAsset.Status == Label.Provisioning_Incomplete_Status){
                            oTempAsset.Status = Label.Marked_for_Review_Status;   
                        } 
                        lstAssetForUpdate.add(oTempAsset);   
                        
                        // play a for loop on Entitlement and update the start and end date
                        for(Entitlement oEntitlement : oTempAsset.Entitlements){
                            oEntitlement.StartDate = orderItem.ServiceDate;
                            oEntitlement.EndDate = orderItem.EndDate;
                            lstEntitlementForUpdate.add(oEntitlement); 
                        }   
                    }
                }
            } 
            
            // update asset 
            if(lstAssetForUpdate.size() > 0){
                update lstAssetForUpdate;
            }
            
            // update SBQQ__QuoteLine__c 
            if(lstQuoteLineItemForUpdate.size() > 0){
                update lstQuoteLineItemForUpdate;
            }
            // update Entitlement 
            if(lstEntitlementForUpdate.size() > 0){
                update lstEntitlementForUpdate;
            }       
        }
        catch(Exception e){GAM.CreateExceptionRecords('OrderProductTriggerHandler --> updateDate', e.getMessage(), 'error from updateDate');
        } 
    }
    
    /*
    * Handle BEFORE INSERT  trigger
    */
    public static void beforeInsert(List<OrderItem> newList, Map<Id,OrderItem> newOrderMap, Map<Id,OrderItem> oldOrderMap){
        
        alignBillingDates(newList);
        assignExtendedListPrice(newList);//<I2C-1395>
    }
    
    //<I2C-1395>
    /*
    * To assign extended list price for Direct Orders
    */
    public static void assignExtendedListPrice(List<OrderItem> newList){  
        for(OrderItem oItem: newList){
            //Update Extended List Price for Direct Orders <I2C-1395>
            if(oItem.SBQQ__QuoteLine__c == null && oItem.PeopleSoft_Extended_List_Price__c == null){
                oItem.PeopleSoft_Extended_List_Price__c = oItem.ListPrice;
            }
        }
    }
    //</I2C-1395>
    
     /*
    * Handle BEFORE UPDATE trigger
    */
    public static void beforeUpdate(List<OrderItem> newList, Map<Id,OrderItem> newOrderMap, Map<Id,OrderItem> oldOrderMap){
        
        alignBillingDates(newList);
        Set<Id> recordIds = new Set<Id> ();
        
        Set<Id> orderIds = new Set<Id> ();
        Id orderId;
        
                DateTime newDateTime = DateTime.now().addMinutes(2);
                String hour = String.valueOf(newDateTime.hour());
                String min = String.valueOf(newDateTime.minute()); 
                String ss = String.valueOf(newDateTime.second());
                String month = String.valueOf(newDateTime.month());
                String day = String.valueOf(newDateTime.day());
                String year = String.valueOf(newDateTime.year());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        
            for(Id oiId : newOrderMap.keySet())
            {
                System.debug('OrderItemId -- ' + oiId + ' OrderId -- ' + newOrderMap.get(oiId).OrderId);
                system.debug('ONBD : ' + oldOrderMap.get(oiId).blng__OverrideNextBillingDate__c + '  ' + newOrderMap.get(oiId).blng__OverrideNextBillingDate__c);
                system.debug('BTDO : ' + oldOrderMap.get(oiId).blng__BillThroughDateOverride__c + '  ' + newOrderMap.get(oiId).blng__BillThroughDateOverride__c );
                system.debug('TerminatedDate : ' + oldOrderMap.get(oiId).SBQQ__TerminatedDate__c + '  ' + newOrderMap.get(oiId).SBQQ__TerminatedDate__c );
                
                
                if(newOrderMap.get(oiId).Invoice_Group__c != oldOrderMap.get(oiId).Invoice_Group__c)
                    newOrderMap.get(oiId).blng__InvoiceGroupId__c = newOrderMap.get(oiId).Invoice_Group__c;
                //<T24>  when a product is cancelled either thru Amend Process (partially) or Full Debook, fixing ONBD to populate Current Date on Amend and Original Order lines
                if((newOrderMap.get(oiId).SBQQ__ContractAction__c == 'Cancel' || (newOrderMap.get(oiId).blng__OverrideNextBillingDate__c == newOrderMap.get(oiId).ServiceDate-1 && newOrderMap.get(oiId).blng__BillThroughDateOverride__c == newOrderMap.get(oiId).EndDate)) && newOrderMap.get(oiId).blng__OverrideNextBillingDate__c != oldOrderMap.get(oiId).blng__OverrideNextBillingDate__c && newOrderMap.get(oiId).SBQQ__Contracted__c)
                {
                    if(newOrderMap.get(oiId).blng__OverrideNextBillingDate__c != null && newOrderMap.get(oiId).blng__OverrideNextBillingDate__c > System.now().Date())
                        newOrderMap.get(oiId).blng__OverrideNextBillingDate__c =  System.now().Date();  
                        
                }//</T24>
                //<T25>Changing Billing Frequency to Annual for amended lines
                if(newOrderMap.get(oiId).SBQQ__Activated__c != oldOrderMap.get(oiId).SBQQ__Activated__c && newOrderMap.get(oiId).SBQQ__Activated__c == TRUE && newOrderMap.get(oiId).SBQQ__BillingFrequency__c == 'Invoice Plan' && (newOrderMap.get(oiId).SBQQ__ContractAction__c == 'Quantity Increase' || newOrderMap.get(oiId).SBQQ__ContractAction__c == 'Quantity Decrease'))
                {
                    newOrderMap.get(oiId).SBQQ__BillingFrequency__c = 'Annual';
                    recordIds.add(oiId);
                    orderId = newOrderMap.get(oiId).OrderId;
                }
                //<I2C-1448> Collecting Original Order for which products are early terminated
                if(((newOrderMap.get(oiId).blng__BillThroughDateOverride__c == newOrderMap.get(oiId).EndDate && newOrderMap.get(oiId).blng__OverrideNextBillingDate__c != oldOrderMap.get(oiId).blng__OverrideNextBillingDate__c) || (newOrderMap.get(oiId).blng__NextBillingDate__c == newOrderMap.get(oiId).SBQQ__TerminatedDate__c && newOrderMap.get(oiId).blng__NextBillingDate__c != oldOrderMap.get(oiId).blng__NextBillingDate__c && newOrderMap.get(oiId).SBQQ__BillingFrequency__c == 'Invoice Plan')) && newOrderMap.get(oiId).SBQQ__TerminatedDate__c != null && newOrderMap.get(oiId).SBQQ__ContractAction__c != 'Cancel')
                {
                    orderIds.add(newOrderMap.get(oiId).OrderId);
                    
                }
                //<I2C-1489>
                //<I2C-1928> Updated condition to consider 0$ lines too 
                if((newOrderMap.get(oiId).TotalPrice == 0 || newOrderMap.get(oiId).blng__PendingBillings__c != oldOrderMap.get(oiId).blng__PendingBillings__c) && newOrderMap.get(oiId).blng__NextChargeDate__c != oldOrderMap.get(oiId).blng__NextChargeDate__c && newOrderMap.get(oiId).SBQQ__TerminatedDate__c != null && newOrderMap.get(oiId).SBQQ__ContractAction__c != 'Cancel' && (newOrderMap.get(oiId).blng__PendingBillings__c != 0 || newOrderMap.get(oiId).TotalPrice == 0) && newOrderMap.get(oiId).blng__NextChargeDate__c != null)
                        newOrderMap.get(oiId).blng__BillThroughDateOverride__c = calcBTOD(newOrderMap.get(oiId).blng__NextChargeDate__c,newOrderMap.get(oiId).EndDate,newOrderMap.get(oiId).SBQQ__BillingFrequency__c);
                
                
            }
            
            //<I2C-1448> Blanking out ONBD and BTDO on Early Terminated Products of Original Order which is not Full Debook
            if(orderIds.size() > 0)
            {
                Map<Id,Order> orderMap = new Map<Id,Order> ([Select Id,Sub_Type__c from Order where Id =: orderIds]);
                Set<Id> originalOIIds = new Set<Id> ();
                
                if(orderMap != null)
                {
                    for(Id oiId : newOrderMap.keySet())
                    {
                        if(orderMap.get(newOrderMap.get(oiId).OrderId) != null)
                        {
                            if(orderMap.get(newOrderMap.get(oiId).OrderId).Sub_Type__c != 'Full Debook')
                            {
                                newOrderMap.get(oiId).blng__OverrideNextBillingDate__c =  null;
                             
                                if(newOrderMap.get(oiId).blng__NextChargeDate__c != null)//<I2C-1489>
                                    newOrderMap.get(oiId).blng__BillThroughDateOverride__c = calcBTOD(newOrderMap.get(oiId).blng__NextChargeDate__c,newOrderMap.get(oiId).EndDate,newOrderMap.get(oiId).SBQQ__BillingFrequency__c);
                                
                                if(newOrderMap.get(oiId).SBQQ__BillingFrequency__c == 'Invoice Plan')
                                    originalOIIds.add(oiId);
                            }
                        }
                    }
                    
                    if(originalOIIds.size() > 0)
                        overrideDateBT(originalOIIds);
                }
            }//</I2C-1448>
            
            if(recordIds.size() > 0)
            {
                // schedule a job to revert the Billing Frequency to Invoice Plan to execute after two minutes as after order activation we have Revenue Schedule creation and other task
                primaryOrderedContRenewalSchedulable s = new primaryOrderedContRenewalSchedulable('CustomBillingAmendOrderAct', 'Order', recordIds); 
                
                try{
                System.schedule('CustomBilling_Amend_Order_Act__' + orderId + ' @: ' + String.valueOf(newDateTime), nextFireTime, s);  
                }
                catch(exception e)
                {
                    
                }     //<T01>
            }
    }
    
    public static void afterInsert(Map<Id,OrderItem> newOrderMap){
        
       List<OrderItem> oiListUpdate = new List<OrderItem> ();
       Decimal convrate;
       boolean runDCR = true;
       Map<Id,String> oppCurrMap = new Map<Id,String> ();
       Map<Id,Date> oppCDMap = new Map<Id,Date> ();
       Map<Id,List<OrderItem>> OrderOPMap = new Map<Id,List<OrderItem>> ();
       List<OrderItem> oiList = new List<OrderItem> ();
        
       for(OrderItem item : [Select Id,OrderId,Order.Source__c,Order.TotalAmount,Order.Generate_Date__c,CurrencyIsoCode,Order.EffectiveDate,Order.EndDate,Order.OpportunityId,Order.Opportunity.CloseDate,Order.Legal_Entity__c,ServiceDate,EndDate,ListPrice,PeopleSoft_Extended_List_Price__c,/**<T19>**/
                               SBQQ__OrderedQuantity__c,Quantity,blng__BillableUnitPrice__c,blng__LegalEntity__c,Product2Id,Product2.Tax_Classification__c,Tax_Category__c,Product2.Offering_Type__c,Product2.Product_Category__c,Original_Order_Product__c,SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c,
                               Product2.Fulfillment_Methods__c,Fulfillment_Method__c,Product2.Tax_Product_Type__c,Tax_Product_Type__c,SBQQ__RevisedOrderProduct__c,External_ID__c,OrderItemNumber,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__ContractAction__c,SBQQ__RevisedOrderProduct__r.EndDate,
                               Original_Order_Product_id__c,blng__NextChargeDate__c,blng__OverrideNextBillingDate__c,purchase_order_po_number__c,blng__InvoiceGroupId__c,blng__InvoiceGrouping__c,Product2.SBQQ__SubscriptionPricing__c,
                               Order.Override_Billing_Frequency__c,SBQQ__QuoteLine__c,SBQQ__ChargeType__c,blng__BillThroughDateOverride__c,SBQQ__BillingFrequency__c,Order.Type,UnitPriceForceOverride__c,TotalPrice,SBQQ__QuoteLine__r.Transaction_Type__c,/**<T22>**/
                               Order.Sub_Type__c, blng__InvoiceRunProcessingStatus__c,Order.Billing_Alignment_Date__c,Order.Opportunity.Enable_Downstream__c,Ship_Date__c,Product2.Provisionable_New__c,SBQQ__QuoteLine__r.Purchase_Order_PO_Number__c from OrderItem where Id IN :newOrderMap.keySet()])
       {
         
           String Enable_Downstream = 'TEST' + item.Order.Opportunity.Enable_Downstream__c;
          
           if(item.OrderId != null)
           {    
               //<I2C-1506> - Start - Accelerate the +ve lines for 0$ Amendment 
               if(math.round(math.abs(item.Order.TotalAmount)) <= 0.1 && item.Order.Type == 'Amendment' && item.TotalPrice >= 0 && item.SBQQ__ChargeType__c == 'Recurring' && item.SBQQ__BillingFrequency__c != 'Invoice Plan'){
                    item.blng__BillThroughDateOverride__c = item.EndDate;
               }
               //<I2C-1506> - End
               if(item.Order.Source__c != null && item.Order.Source__c == 'Fee')
               {
                   item.ServiceDate = item.Order.EffectiveDate;
                   item.EndDate = item.Order.EndDate;
                   item.SBQQ__OrderedQuantity__c = item.Quantity;
                   item.PeopleSoft_Extended_List_Price__c = item.ListPrice;
                   item.blng__BillableUnitPrice__c = item.ListPrice;
                   
               }
               //-------------------T13---------------------------------------------------------------------------
               if(item.Order.Source__c != null && (item.Order.Source__c == 'ES' || item.Order.Source__c == 'PS'))
               {
                    item.SBQQ__OrderedQuantity__c = item.Quantity;
                    item.blng__BillableUnitPrice__c = 0;
               }
               //-------------------T13---------------------------------------------------------------------------
               
           }
           
           if(item.Product2Id != null)
           {
               if(item.SBQQ__QuoteLine__c == null) //Added quote line check to allow twining from quote line <T23>
               {
                    if(String.isBlank(item.Product2.Tax_Classification__c)){
                        item.Tax_Category__c = 'C'; //<TAX-376> Update Tax Category Logic for Order Products from L to C
                    } else{
                        item.Tax_Category__c = item.Product2.Tax_Classification__c;    
                    }               
               }
               if(item.Product2.Tax_Product_Type__c != null)
               {
                   item.Tax_Product_Type__c = item.Product2.Tax_Product_Type__c;
                   
               }
               if(item.Product2.Fulfillment_Methods__c != null && item.Product2.Fulfillment_Methods__c == 'Service')
               {
                   item.Fulfillment_Method__c = 'Service';
                   
               }
               if(item.Product2.Fulfillment_Methods__c != null && item.Product2.Fulfillment_Methods__c == 'Courier')
               {
                   item.Fulfillment_Method__c = 'Courier';
                   
               }
               if(item.Product2.Fulfillment_Methods__c != null)
               {
                   if(item.Product2.Fulfillment_Methods__c.contains('Electronic'))
                   {
                       item.Fulfillment_Method__c = 'Electronic';
                       
                   }
               }
               //<T16>
               if(!item.Product2.Provisionable_New__c ||item.Order.Sub_Type__c == 'Direct Order'|| (item.Order.Sub_Type__c == 'Full Debook' && item.Order.Type == 'Amendment') || (item.TotalPrice <= 0 && item.Quantity < 0) || (Label.RevisionLabel.equals(item.Order.Sub_Type__c) && !Enable_Downstream.contains('Fulfillment')) || ((item.Product2.Offering_Type__c == 'On-Premise Perpetual License'|| item.Product2.Offering_Type__c == 'On-Premise One Time Term License') && item.SBQQ__QuoteLine__r.Transaction_Type__c == 'Renewal'))/**<T22>**/
               {
                    item.Ship_Date__c = item.Order.Generate_Date__c; /**<T19>**/
               }//<T16>
               
           }
           
           if(item.SBQQ__RevisedOrderProduct__c == null)
           {
                item.Original_Order_Product_id__c = item.Id;
                
           }
           else //SALESRT-14387
           {
               item.Original_Order_Product__c = item.SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c;
               item.Original_Order_Product_id__c = item.SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c;
           }
           if(item.SBQQ__QuoteLine__c != null && item.SBQQ__ChargeType__c != 'Usage')
           {
               if(item.Order.Override_Billing_Frequency__c != null && item.Order.Override_Billing_Frequency__c == 'One Time')
               {
                   item.blng__BillThroughDateOverride__c = item.EndDate;
                   
               }
           }
           
                 if(item.blng__NextChargeDate__c != null)
                 {
                     //if(item.blng__OverrideNextBillingDate__c == null && !(item.EndDate <= System.now().Date() && item.Order.Override_Billing_Frequency__c == 'One Time')) //<T20>
                     if(item.blng__OverrideNextBillingDate__c == null && item.EndDate > System.now().Date()) //<T21>
                     {
                         item.blng__OverrideNextBillingDate__c = System.now().Date();
                         
                     }
                 }
                
                if(item.SBQQ__QuoteLine__c != null)
                    item.Purchase_Order_PO_Number__c = item.SBQQ__QuoteLine__r.Purchase_Order_PO_Number__c;
                    
                item.blng__InvoiceGrouping__c = Label.Invoice_Group_Id;
                item.blng__InvoiceGroupId__c = item.Purchase_Order_PO_Number__c;
                 
                if(item.blng__LegalEntity__c == null && item.Order.Legal_Entity__c != null)
                
                    item.blng__LegalEntity__c = item.Order.Legal_Entity__c;
                    
                if(item.SBQQ__BillingFrequency__c == 'Invoice Plan' && item.SBQQ__ChargeType__c != 'Usage' && item.Quantity == 1 && item.Order.Type != 'Amendment' && item.TotalPrice > 0)
                {
                    item.UnitPriceForceOverride__c = item.TotalPrice.setScale(2,RoundingMode.HALF_UP);
                }
                //<T11>
                if((item.Product2.Product_Category__c == 'Feature' || item.Product2.Product_Category__c == 'Wrapper') && item.Product2.Offering_Type__c == 'Other' /*|| item.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__Bundled__c*/)
                    item.blng__RevenueRecognitionRule__c = Label.NoRevenueSchedule; //</T11>
                //<T15>
                if(Label.RevisionLabel.equals(item.Order.Sub_Type__c) && !Enable_Downstream.contains('Revenue Agreement')) //<T12>
                    item.blng__RevenueRecognitionRule__c = Label.NoRevenueSchedule; //</T15>
                   
           //<T007>
           if(item.Order.OpportunityId != null)
           {
               oppCurrMap.put(item.OrderId,item.CurrencyIsoCode);
               oppCDMap.put(item.OrderId,item.Order.Opportunity.CloseDate);
               
               if(OrderOPMap.get(item.OrderId) != null)
               {
                   oiList = OrderOPMap.get(item.OrderId);
                   oiList.add(item);
                   OrderOPMap.put(item.OrderId,oiList);
               }
               else
               {
                   oiList.add(item);
                   orderOPMap.put(item.OrderId,oiList);
               }
           }//</T007>

           //<T08>
           if( Label.RevisionLabel.equals(item.Order.Sub_Type__c)){
            item.blng__InvoiceRunProcessingStatus__c = 'Will Not Invoice';
           }
           //</T08>
           //<T09>
           if(item.blng__BillThroughDateOverride__c != null && item.Order.Type == 'Renewal' && item.Order.Override_Billing_Frequency__c == null && item.Order.Override_Billing_Frequency__c != 'One Time' && item.Order.Billing_Alignment_Date__c == null && item.EndDate > System.now().Date())
               item.blng__BillThroughDateOverride__c = null;
           //</T09>
           
           oiListUpdate.add(item);
          
       }
       
       //<T007>
       for(DatedConversionRate DCR : [SELECT Id,ConversionRate,IsoCode,NextStartDate,StartDate FROM DatedConversionRate WHERE IsoCode =: oppCurrMap.values() ORDER BY StartDate DESC ])
       {
           for(Id ordId : orderOPMap.keySet())
           {
               Date oppclosedate = oppCDMap.get(ordId);
               if(DCR.IsoCode == oppCurrMap.get(ordId) && DCR.StartDate <= oppclosedate && DCR.NextStartDate > oppclosedate)
               {
                   for(OrderItem oiUpdate : orderOPMap.get(ordId))
                   {
                       oiUpdate.Oppty_Conv_Rate__c = DCR.ConversionRate;
                   }
               }
           }
       } //</T007>



       
       if(oiListUpdate != null && oiListUpdate.size() > 0)
       {
       //try{
                //Database.SaveResult[] srList = Database.update(oiListUpdate,false);
                update oiListUpdate;
            //} catch(DmlException e){
               // GAM.CreateExceptionRecords('OrderProductTriggerHandler --> afterInsert', e.getMessage(), 'error from afterInsert');
            //}
       }
    }
    
    
    /*
    * To align billing dates for amendments
    * To align the Order Item's Billing Day of Month with the original Order Start Date on Order activation
    */
    public static void alignBillingDates(List<OrderItem> newList){  
        List<OrderItem> orderItemList = new List<OrderItem>();
        Set<String> orderIds = new Set<String>();
        Set<Id> orderIdsToUpdate = new Set<Id>();
        List<Order> ordersToUpdate = new List<Order>();
        
        try{
            for(OrderItem item : newList){
               
                  if(item.SBQQ__Activated__c == TRUE && item.Override_Billing_Alignment__c == FALSE)
                {
                    orderItemList.add(item);
                    orderIds.add(item.OrderId);
                }
            }
            
            //Fetch Order Object from OrderItem
            Map<String,Order> orderMap = new Map<String,Order>([select Id, Billing_Alignment_Date__c from order where Id in:orderIds]);
            
            //Compare Billing Alignment Date(Override_Billing_Alignment__c) with Today’s date then calculate the values for Override Next Billing Date (blng__OverrideNextBillingDate__c) and Bill Through Date Override (blng__BillThroughDateOverride__c)
            for(OrderItem item : orderItemList)
            {            
                if(item.SBQQ__BillingFrequency__c != null && orderMap.get(item.orderId).Billing_Alignment_Date__c != null)
                {
                    if(item.blng__NextChargeDate__c != null){
                        Date invoiceDate = item.blng__NextChargeDate__c;
                        Date Temp;
                        if(orderMap.get(item.orderId).Billing_Alignment_Date__c >= invoiceDate)
                        {                           
                            if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Annual))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addYears(1);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Semiannual))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(6);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Quarterly))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                 Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(3);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);   
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Monthly))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(1);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);
                            }
                        } else
                        {
                            if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Annual))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addYears(1);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Semiannual))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Integer Diff = orderMap.get(item.orderId).Billing_Alignment_Date__c.monthsBetween(invoiceDate);   
                                Decimal x = ((Decimal)Diff/6).round(System.RoundingMode.CEILING);   
                                Integer Period = ((Integer)x) * 6;                                   
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(Period); 
                                                   
                                if(invoiceDate >= Temp)
                                {
                                     Temp = Temp.addMonths(6);
                                }         
                                                                         
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);                            
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Quarterly))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Integer Diff = orderMap.get(item.orderId).Billing_Alignment_Date__c.monthsBetween(invoiceDate);      
                                Decimal x = ((Decimal)(Diff)/3).round(System.RoundingMode.CEILING); 
                                Integer Period = ((Integer)x) * 3;                                   
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(Period); 
                                                   
                                if(invoiceDate >= Temp)
                                {
                                    Temp = Temp.addMonths(3);  
                                }         
                                                                         
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1); 
                            } else if(item.SBQQ__BillingFrequency__c.equalsIgnoreCase(Label.BillingFrequency_Monthly))
                            {
                                item.blng__OverrideNextBillingDate__c = invoiceDate;
                                Integer Diff = orderMap.get(item.orderId).Billing_Alignment_Date__c.monthsbetween(invoiceDate) + 1;
                                Temp = orderMap.get(item.orderId).Billing_Alignment_Date__c.addMonths(Diff);
                                item.blng__BillThroughDateOverride__c = Temp.addDays(-1);
                            }
                        }
                    }
                    
                    if(item.blng__BillThroughDateOverride__c > item.EndDate)
                    {
                      item.blng__BillThroughDateOverride__c = item.EndDate;
                    }
                }
                
                if(item.blng__BillThroughDateOverride__c < item.ServiceDate && item.blng__BillThroughDateOverride__c != null) //<T09>
                {
                    item.blng__BillThroughDateOverride__c = null;
                }
            }
        }
        catch(Exception e){GAM.CreateExceptionRecords('OrderProductTriggerHandler --> alignBillingDates', e.getMessage(), 'error from alignBillingDates');
        }
    }  
    
     @future (callout=true)
    Public static void overrideDateBT(Set<Id> orderItemIds)
    {
        List<blng__BillingTransaction__c > BTListUpdate = new List<blng__BillingTransaction__c > ([Select Id,blng__OverrideBillingTargetDate__c from blng__BillingTransaction__c where Order_Product__c = : orderItemIds ANd blng__OverrideBillingTargetDate__c != NULL AND blng__OverrideStatus__c != 'Cancelled' AND blng__Status__c =: 'Pending']); //I2C-1804 -- Added Status to the filter to query only pending BT
        for(blng__BillingTransaction__c BT : BTListUpdate)
        {
            BT.blng__OverrideBillingTargetDate__c = null;
            
        }
        if(BTListUpdate.size() > 0)
            update BTListUpdate;
    }
    
    /*<I2C-1489>
    Created method to calculate Bill Through Date Override for Recurring products of Multi-Year Subscription
    */
    public static Date calcBTOD(Date NCD,Date EndDate,String BillFrequency)
    {
     Date BTOD = NCD;
     if(BillFrequency == 'Annual')
          BTOD = BTOD.addMonths(12);
     else if(BillFrequency == 'Semiannual')
         BTOD = BTOD.addMonths(6);
     else if(BillFrequency == 'Quarterly')
         BTOD = BTOD.addMonths(3);
     else if(BillFrequency == 'Monthly')
         BTOD = BTOD.addMonths(1);  
         
      BTOD = BTOD.addDays(-1);
      
      if(BTOD > EndDate) 
          BTOD = EndDate;
      
      if(BillFrequency == 'Invoice Plan')
          BTOD = null;
              
     return BTOD;   
    }

}