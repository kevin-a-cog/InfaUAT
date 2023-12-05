/****************************************************************************************************************************
 *  @Class Name: Cancel&DebookOrder
 *  @Author: Kiran/Anil
 *  @Date: 24 Sept 2019
 *  @Description: Class to process for Cancelling or Debugging the Order . 
 *****************************************************************************************************************************
 ChangeHistory   
 ModifiedBy          Date           Requested By        Description                                  Tag   
 
 Kiran G            30 Jan 2020    Prasanth G        Processing the Amend Quote through API and 
                                                     moved everything to Future method 
                                                     asynchronously to avoid CPU Time Limit error    T01
                                                     
 RamEsh M S         05 May 2020    BBOY              SALESRT-12053  To fix "too many queueable jobs added to the queue" error
                                                     when Order to debook has multiple contracts    <T02> 
 RamEsh M S         01 Jun 2020    Keerthana                  SALESRT-12099  To fix Start and End Date when moving SUbscription Lines
                                                     to master contract  <T03> 
 Anil Solanki        04 Aug 2020   I2C-726           Set Order Stage to Debook<T04>     
 Kiran G            17 Sept 2020   SALESRT-12436     Bypass the contracts where the Business MOdel is OEM,POC and Prod FUnd Eval   <T05> 
 Vignesh D          15 Oct 2020    F2A-287           Moving the asset handling to AssetCreationBatchHandler as part of revamp <T06>                             
RamEsh M S           02 NOV 2020   SALESRT-12533      Remove Opportunity lookup on Order if it is cancelled.    <T07>
RamEsh M S          05-JAN-2021    I2C-1109            Finance                      Update the logic to create/update Booking when RA is moved to Allocation Validated  <T08>
RamEsh M S          28-JAN-2021    SALESRT-12770      Delete records from Subscribed Quote Line object of Quote associated with the Order cancellation.  <T09>
RamEsh M S          05-FEB-2021    SALESRT-12631      Enabling Cancel/Debook option for Direct Orders. <T10>
RamEsh M S          18-MAR-2021    SALESRT-12659      Set Do_Not_Send_Invoices_to_Customer__c to TRUE if order is debooked. <T11>
Wasim        23-JUL-2021     SALESRT-13149    Debook an Amended Order display Message      <T12>
Nishit S      22-AUG-2021    I2C-1336    Allow a way for suppressing specific invoice from bursting to Customer        <I2C-1336>
Wasim               23-Feb-2022     SALESRT-13648       Add logic to bypass validation for ES and PS Product when Renewal Oppty is not created <SALESRT-13648>
Vignesh D           02-FEB-2023     F2A-500           On cancel order call the service class to delete OE & OELs        <T13>         
****************************************************************************************************************************/

public class CancelDebookOrder
{   
    public static String DraftQuoteRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId();
    
    public static String DraftAmendRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Amendment').getRecordTypeId();
    
    public static String DraftRenewRecordTypeID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Renewal').getRecordTypeId();
    public static globalApexManager GAM = new globalApexManager();
    
    // Get the values Cancel Reason Picklist value
    @AuraEnabled        
     public static List<String> getPickListValues(String objectType, String selectedField){
         List<String> pkListValues = new List<String>();
         Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectType);
         Schema.DescribeSObjectResult res = obj.getDescribe();
         Schema.DescribeFieldResult result = res.fields.getMap().get(selectedField).getDescribe();
         List<Schema.PicklistEntry> pkle = result.getPicklistValues();
         for( Schema.PicklistEntry pklVal : pkle){
             pkListValues.add(pklVal.getLabel());
         }  
         return pkListValues;
      }
         
    /*For Debooking the Status on the Order should be Activated .
    Amend Orders cannot be Debooked . 
    Cancellation of Order can be done before the Activation of teh ORder */
    
    @AuraEnabled
    public static string getOrderStatus(String OrderId)
    {
        string statusMessage='';
        List<Order> orderToQuery = new List<Order>();
        List<Contract> lstContractofOrder = new List<Contract>();
        List<OrderItem> oiList = new List<OrderItem> ();
        
        String statusCheck;
       String orderType ;
        Integer count = 0;
        if(String.isNotBlank(OrderId))
        {
            //Get Orderand Contract details to see if the Order can be Cancelled or Debooked
            orderToQuery = [SELECT Status,Source__c, Type,Id,SBQQ__Contracted__c , Sub_Type__c,Revenue_Agreement_Processed__c,Contract_Generated__c from Order where Id =:OrderId Limit 1];
            
            lstContractofOrder = [SELECT Id,AccountId,ContractNumber,ContractTerm,EndDate,Name,
                                  SBQQ__Order__c,SBQQ__RenewalOpportunityStage__c,
                                  SBQQ__RenewalOpportunity__c,StartDate,Status,SBQQ__RenewalForecast__c,
                                  Business_Model__c 
                                  FROM Contract
                                  WHERE SBQQ__Order__c =: OrderId
                                  ORDER BY StartDate ASC];
                                  
            List<Revenue_Agreement__c> RA = new List<Revenue_Agreement__c> ();
            RA = [Select Id,Stage__c from Revenue_Agreement__c where Id IN (Select Revenue_Agreement__c from Related_Order_and_Contract__c where Order__c =: OrderId) LIMIT 1];
            String RAStage = RA.size() > 0 ? RA[0].Stage__c : 'NoRevAgree';
            //T05                     
            for(Contract con : lstContractofOrder ){
                //<SALESRT-13648> - added condition to check if the Order Source is ES/PS
                if((orderToQuery.size() > 0 && (orderToQuery[0].Source__c == 'ES' || orderToQuery[0].Source__c == 'PS')) || con.SBQQ__RenewalForecast__c ||con.Business_Model__c == 'OEM - Royalty' ||con.Business_Model__c == 'POC'  || con.Business_Model__c == 'Product Fund EVAL')
                    count=count+1;
            }
           
            oiList = [Select Id from OrderItem where OrderId =: OrderId];
            
            if(!orderToQuery.isEmpty() && orderToQuery != Null){
                statusCheck = orderToQuery[0].Status;
                orderType = orderToQuery[0].Type;                 
            }
            
            //check for Order Products
            if(oiList == null || oiList.size() == 0)
            {
                statusMessage = 'NOORDERPRODUCTS';
            }
            //<T10> Added condition to handle Debook for Direct Orders
            else if(statusCheck != Null && statusCheck != '' && (statusCheck == 'Bill & Contract' || statusCheck =='Completed') && (RAStage == 'Sent to RMCS' || RAStage == 'Ready') && orderToQuery[0].Sub_Type__c == 'Direct Order')
            {
                statusMessage = 'ACTIVATEDDIRECT';
            }
            //Anil : Added check to initiate Debook flow
            else if(statusCheck != Null && statusCheck != '' && (statusCheck == 'Bill & Contract' || statusCheck =='Completed' || RAStage == 'Sent to RMCS' || RAStage == 'Ready') && orderType != 'Amendment' && statusCheck != 'Cancelled' &&
             orderToQuery[0].Sub_Type__c != 'Full Debook' && count > 0 && orderToQuery[0].SBQQ__Contracted__c ){
                statusMessage = 'ACTIVATED'; //If activated and type is not Amend we can de-book 
             }
             //Anil : Added check to initiate Cancel flow
             else if(statusCheck != Null && statusCheck != '' && statusCheck != 'Bill & Contract' && statusCheck != 'Completed' && statusCheck != 'Cancelled' && statusCheck != 'Debook' && (!orderToQuery[0].Revenue_Agreement_Processed__c && RAStage != 'Ready' && RAStage != 'Sent to RMCS')){
                statusMessage = 'READYTOCANCEL';  // Activate Cancel Flow.
             }
            //<T12> Wasim : Added check to handle Debook for Amendment Order
            else if(statusCheck != Null && statusCheck != '' && (statusCheck == 'Bill & Contract' || statusCheck =='Completed' || RAStage == 'Sent to RMCS' || RAStage == 'Ready') && orderType == 'Amendment' && statusCheck != 'Cancelled'){
              statusMessage = 'AMENDMENT';  //Type is Amend allow to Full Debook from Contract
          }
             else if(orderToQuery[0].Sub_Type__c == 'Full Debook' || statusCheck == 'Cancelled' || statusCheck == 'Debook'){
                 statusMessage = 'CANCELLEDDEBOOKED';  //Show error message
             }
             else if(!orderToQuery[0].SBQQ__Contracted__c){
                 statusMessage = 'NOTCONTRACTED';
             }             
             else if(count == 0){
                 statusMessage = 'NORENWLOPPTY';
             }             
             else{

             }
                
        }
        return statusMessage;
    }
    
    
    @AuraEnabled
    public static Id debookDirectOrder(String OrderId, String CancelReason, String CancelReasonText)
    {  
    
            List<Order> orderDetails = new List<Order>();
            List<Order> orderUpsert = new List<Order>();
            List<OrderItem> orderItemInsert = new List<OrderItem> ();
            
            Id newOrderId;
            
            //orderDetails = [SELECT Status,Sub_Type__c,Cancel_Debook_Reason__c,Cancel_Debook_Reason_text__c from Order where Id =:OrderId Limit 1];
            orderDetails = [SELECT Id,AccountId,BillingAddress,BillingAddress_PSFTID__c,BillingCity,BillingCountry,BillingName_PSFTID__c,BillingName__c,BillingPostalCode,BillingState,BillingStreet,
            BilltoAccount__c,BillToContactId,blng__BillingAccount__c,Business_Model__c,Cancel_Debook_Reason__c,Cancel_Debook_Reason_text__c,CurrencyIsoCode,Description,EffectiveDate,EndDate,EndUserAccount__c,EndUserAddress_PSFTID__c,
            EndUserAddress__c,EndUserCity__c,EndUserContact__c,EndUserCountry__c,EndUserPostalCode__c,EndUserStateProvince__c,EndUserStreet__c,External_ID__c,Legal_Entity__c,Name,OwnerId,OrderNumber,OrderReferenceNumber,
            PoDate,PoNumber,PO__c,Pricebook2Id,SBQQ__PaymentTerm__c,ShippingAddress,ShippingAddress_PSFTID__c,ShippingCity,ShippingCountry,ShippingName_PSFTID__c,ShippingName__c,
            ShippingPostalCode,ShippingState,ShippingStreet,Shipping_Email__c,Shipping_Preference__c,ShipToAccount__c,ShipToContactId,SoldAddress_PSFTID__c,SoldAddress__c,SoldCity__c,
            SoldCountry__c,SoldPostalCode__c,SoldStateProvince__c,SoldStreet__c,SoldToAccount__c,SoldToContact__c,Source__c,Status,Sub_Type__c,Type,SBQQ__PriceCalcStatus__c,Do_Not_Send_Invoices_to_Customer__c FROM Order where Id =:OrderId Limit 1];
            
            //orderDetails[0].Sub_Type__c = 'Full Debook';
            orderDetails[0].Status = 'Debook';
            orderDetails[0].Cancel_Debook_Reason__c = CancelReason;
            orderDetails[0].Cancel_Debook_Reason_text__c = CancelReasonText;
            orderDetails[0].Do_Not_Send_Invoices_to_Customer__c = 'Do Not Send All Invoices to Customer(S)'; //<T11> <I2C-1336>
            orderDetails[0].Id = OrderId;
            orderUpsert.add(orderDetails[0]);
            
            Order ordNew = orderDetails[0].clone();
            ordNew.Status = 'Draft';
            ordNew.Type = 'Amendment';
            ordNew.Cancel_Debook_Reason__c = '';
            ordNew.Cancel_Debook_Reason_text__c = '';
            ordNew.Sub_Type__c = 'Full Debook';
            ordNew.OrderReferenceNumber = orderDetails[0].OrderNumber;
            ordNew.Do_Not_Send_Invoices_to_Customer__c = 'Do Not Send All Invoices to Customer(S)'; //<T11><I2C-1336>
            orderUpsert.add(ordNew);
            
            
            
            try
            {
                List<Database.upsertResult> uResults = Database.upsert(orderUpsert,false);
                for(Database.upsertResult result:uResults)
                {
                    if(result.isSuccess() && result.isCreated()) 
                        newOrderId = result.getId();
                }
                
                if(newOrderId != null)
                {
                    for(OrderItem oi : [SELECT AvailableQuantity,blng__BillingAccount__c,blng__BillingGLRule__c,blng__BillingGLTreatment__c,blng__BillingRule__c,blng__BillingTreatment__c,blng__GroupId__c,
                                    blng__InvoiceGroupId__c,blng__InvoiceGrouping__c,blng__LegalEntity__c,blng__RevenueRecognitionRule__c,blng__TaxCity__c,blng__TaxCountry__c,blng__TaxCounty__c,
                                    blng__TaxGLRule__c,blng__TaxGLTreatment__c,blng__TaxRule__c,blng__TaxState__c,blng__TaxStatus__c,blng__TaxStreet2__c,blng__TaxStreet__c,blng__TaxTreatment__c,
                                    blng__TaxZipCode__c,Connector_Type__c,CPQ_Product_Type__c,CurrencyIsoCode,Currency__c,Description,EndDate,External_ID__c,Fulfillment_Method__c,Id,Invoice_Group__c,
                                    ListPrice,OrderId,PricebookEntryId,Product2Id,Product_Category__c,Purchase_Order_PO_Number__c,Quantity,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,
                                    SBQQ__ChargeType__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__OrderedQuantity__c,SBQQ__PricingMethod__c,SBQQ__ProductSubscriptionType__c,SBQQ__ProrateMultiplier__c,
                                    SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionType__c,ServiceDate,Tax_Category__c,Tax_Product_Type__c,UnitPrice FROM OrderItem where orderId =: orderId])
                    {
                        orderItem newoi = oi.Clone();
                        newoi.OrderId = newOrderId;
                        newoi.Quantity = oi.Quantity * (-1);
                        newoi.SBQQ__OrderedQuantity__c = newoi.Quantity;
                        newoi.Original_Order_Product__c = oi.Id;
                        newoi.Original_Order_Product_id__c = oi.Id;
                        newoi.SBQQ__RevisedOrderProduct__c = oi.Id;
                        orderItemInsert.add(newoi);
                    }
                    if(orderItemInsert != null && orderItemInsert.size() > 0)
                        insert orderItemInsert;
                    
                }
            }
            
            Catch(Exception e)
            {
                GAM.CreateExceptionRecords('CancelDebookOrder', e.getMessage(),'DebookDirectOrder');            
            } 
            
            
            
            return newOrderId;
    }
    
    @AuraEnabled
    public static Id debookOrder(String OrderId, String CancelReason, String CancelReasonText)
    {        
         List<Order> orderDetails = new List<Order>();
         List<Contract> lstContractofOrder = new List<Contract>();       
             
         Id masterContractId;
         
         if(String.isNotBlank(OrderId))
         {
            lstContractofOrder = [SELECT Id,AccountId,ContractNumber,ContractTerm,EndDate,Name,PSFT_Contract_Number__c,
                                  SBQQ__Order__c,SBQQ__RenewalOpportunityRecordTypeId__c,SBQQ__RenewalOpportunityStage__c,
                                  SBQQ__RenewalOpportunity__c,StartDate,Status 
                                  FROM Contract
                                  WHERE SBQQ__Order__c =: OrderId
                                  ORDER BY StartDate ASC];

            //Master Contract will be Order with Lowest Start Date if multiple contracts      
            if(!lstContractofOrder.isEmpty()){
                 masterContractId = lstContractofOrder[0].Id;
            }
            asyncDebookOrder(OrderId,CancelReason,CancelReasonText);
        }
        return masterContractId;       
       
    }
    //---------T01----------------------------------
    // Quote Model, QuoteLine Model and Quote Line Group Model are mandatory classes for below to run as expected. 
    /*<T02> public static QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }</T02>*/
    //---------T01----------------------------------
    
    /*    
    Method to be called if Order Status is not 'Ready for Billing
    */
    @AuraEnabled
    public static Id cancelOrder(String OrderId, String CancelReason, String CancelReasonText){
        
        List<Order> orderToBeCancelled = new List<Order>();
        List<SBQQ__Quote__c> quoteToBeReleased = new List<SBQQ__Quote__c>();
        List<OrderItem> orderItems = new List<OrderItem>();
        List<OrderItem> orderItemToBeCancelled = new List<OrderItem>();
        Id quoteId ;
        String orderType = 'test';
        if(String.isNotBlank(OrderId)){
            orderToBeCancelled = [SELECT Id,Status,SBQQ__Quote__c,Cancel_Debook_Reason__c,Cancel_Debook_Reason_text__c,OpportunityId,Type from Order where Id =:OrderId Limit 1];
            quoteToBeReleased  = [Select Id,Primary_Order__c,SBQQ__Ordered__c,SBQQ__Status__c,ApprovalStatus__c,SBQQ__Type__c from SBQQ__Quote__c where Id = :orderToBeCancelled[0].SBQQ__Quote__c Limit 1 ];
            
            if(orderToBeCancelled != null && orderToBeCancelled.size() > 0)
            {
                orderToBeCancelled[0].Status = 'Cancelled';
                quoteId = orderToBeCancelled[0].SBQQ__Quote__c ;
                orderToBeCancelled[0].SBQQ__Quote__c = null ;
                orderToBeCancelled[0].Cancel_Debook_Reason__c= CancelReason;
                orderToBeCancelled[0].Cancel_Debook_Reason_text__c = CancelReasonText;
                orderToBeCancelled[0].OpportunityId = null; //<T07>
                orderType = orderToBeCancelled[0].Type;
            }
            
            if(quoteToBeReleased != null && quoteToBeReleased.size() > 0)
            {
                quoteToBeReleased[0].Primary_Order__c = null;
                quoteToBeReleased[0].SBQQ__Ordered__c = false;
                quoteToBeReleased[0].SBQQ__Status__c = 'Draft';
                quoteToBeReleased[0].ApprovalStatus__c = null;
           
            
                if(quoteToBeReleased[0].SBQQ__Type__c == 'Quote'){
                    quoteToBeReleased[0].RecordTypeId = DraftQuoteRecordTypeID;
                }
                else if(quoteToBeReleased[0].SBQQ__Type__c == ' Amendment'){
                    quoteToBeReleased[0].RecordTypeId = DraftAmendRecordTypeID;
                }
                else{
                    quoteToBeReleased[0].RecordTypeId = DraftRenewRecordTypeID;
                }
            } 
                      
            orderItems = [Select Id, OrderId,SBQQ__QuoteLine__c from OrderItem where OrderId =: OrderId];
        }
        
        if(orderItems.size() >0){
            for(OrderItem orderproduct : orderItems ){
                orderproduct.SBQQ__QuoteLine__c = null;
                orderItemToBeCancelled.add(orderproduct);
            }
        }
        try{
            //update Order
            if(orderToBeCancelled.size() > 0){
                update orderToBeCancelled;
            }
            //update order product
            if(orderItemToBeCancelled.size() > 0){
                update orderItemToBeCancelled;
            }
            //update quote
            if(quoteToBeReleased.size() > 0){
                update quoteToBeReleased;
            }
            //<T08>
            if(orderType == 'New' || orderType == 'Renewal')
            {
                primaryOrderedContractedRenewal.doJob('Cancel_Bookings','Order_New_Renewal',OrderId);
            }
            
            if(orderType == 'Amendment')
            {
                primaryOrderedContractedRenewal.doJob('Cancel_Bookings','Order_Amendment',OrderId);
            }//<T08>
            
            //<T09>
            if(quoteId != null)
            {
                delete [Select Id from SBQQ__SubscribedQuoteLine__c where SBQQ__Quote__c =: quoteId];
            }//</T09>
            
            //<T06> releaseAssets(OrderId);
            if(quoteId == null)
                quoteId = orderId;

            OrgEntitlementService.deleteOrgEntitlements((Id) orderId); //<T13>            
            return quoteId ;
        
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('CancelDebookOrder', 'CancelOrder',e.getMessage());
            return quoteId ;
        }
    }
    
  /*  public static void releaseAssets(String OrderId){
        Set<Id> orderItemsId = new Set<Id>();
        List<Asset> assetstoBeReleased = new List<Asset>();
        List<Asset> assets = new List<Asset>();
        
        List<Order> cancelledOrder = new List<Order>(); 
        String orderType;
        if(String.isNotBlank(OrderId)){
             cancelledOrder = [SELECT Id,Status,SBQQ__Quote__c,Type from Order where Id =:OrderId Limit 1];
             orderType = cancelledOrder [0].Type;
           for (OrderItem oi : [Select Id, OrderId,SBQQ__QuoteLine__c from OrderItem where OrderId =: OrderId]){
               orderItemsId.add(oi.Id);
               
           }
        }
        
        if(orderItemsId.size() > 0){
            assets = [Select Id,SBQQ__OrderProduct__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__Quantity__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__EndDate__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionStartDate__c,Product2Id,Product2.SBQQ__AssetConversion__c,SBQQ__QuoteLine__c,SBQQ__CurrentSubscription__c, SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__Quantity__c  from Asset where SBQQ__OrderProduct__c IN: orderItemsId ];
        }
        
        System.debug('@@@@asssets'+ assets);
        for(Asset asset : assets){
            //if Order Type = New
            if(orderType == 'New'){
                 asset.SBQQ__OrderProduct__c = null;
                asset.SBQQ__SubscriptionEndDate__c = asset.SBQQ__SubscriptionStartDate__c;
                assetstoBeReleased.add(asset);
        }
         //if Order Type = Amend Or Renewal
         if(orderType == 'Amendment'){
             if(asset.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null){
                 asset.SBQQ__OrderProduct__c = asset.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c;
                 asset.SBQQ__SubscriptionEndDate__c = asset.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c;
                 asset.One_Per_Unit_Total_Assets__c  = asset.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__r.SBQQ__Quantity__c;
                 assetstoBeReleased.add(asset);
             }
             else{
                 asset.SBQQ__SubscriptionEndDate__c = asset.SBQQ__SubscriptionStartDate__c;
                 assetstoBeReleased.add(asset);
             }
         }
         
         if(orderType == 'Renewal'){
             if(asset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != null){
                 asset.SBQQ__OrderProduct__c = asset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c;
                 asset.SBQQ__SubscriptionEndDate__c = asset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__EndDate__c;
                 asset.One_Per_Unit_Total_Assets__c  = asset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__Quantity__c;
                 assetstoBeReleased.add(asset);
                  }
             else{
                 asset.SBQQ__SubscriptionEndDate__c = asset.SBQQ__SubscriptionStartDate__c;
                 assetstoBeReleased.add(asset);
                 
             }
         }
        
        }
        
        try{
            if(assetstoBeReleased.size() > 0){
                update assetstoBeReleased;
            }
        }
        Catch(Exception e){
            GAM.CreateExceptionRecords('CancelDebookOrder', 'ReleaseAssets',e.getMessage());
            
        }
        
    }*/
    
    
    public static void asyncDebookOrder(String OrderId, String CancelReason, String CancelReasonText){
        List<Order> orderDetails = new List<Order>();
         List<Contract> lstContractofOrder = new List<Contract>();
         List<SBQQ__Subscription__c> lstSubscriptionLines = new List<SBQQ__Subscription__c>();
         List<SBQQ__Subscription__c> lstSubsToUpdate = new List<SBQQ__Subscription__c>();
         Set<Id> setContractIds = new Set<Id>();
         Set<Id> setRenewalOpptysOfContract = new Set<Id>();
      
         Id masterContractId;
         
         if(String.isNotBlank(OrderId))
         {
            lstContractofOrder = [SELECT Id,AccountId,ContractNumber,ContractTerm,EndDate,Name,PSFT_Contract_Number__c,
                                  SBQQ__Order__c,SBQQ__RenewalOpportunityRecordTypeId__c,SBQQ__RenewalOpportunityStage__c,
                                  SBQQ__RenewalOpportunity__c,StartDate,Status 
                                  FROM Contract
                                  WHERE SBQQ__Order__c =: OrderId
                                  ORDER BY StartDate ASC];
            //Get the contracts associated to Order 
            for(Contract contractId : lstContractofOrder){
                setContractIds.add(contractId.Id);
                setRenewalOpptysOfContract.add(contractId.SBQQ__RenewalOpportunity__c);
            }                              
            
             
            lstSubscriptionLines = [SELECT Id,Name,Related_Asset__c,Related_Entitlement__c,SBQQ__Account__c,SBQQ__Contract__c,
                                    SBQQ__EndDate__c,SBQQ__OrderProduct__c,SBQQ__ProductId__c,SBQQ__ProductName__c,SBQQ__Product__c,
                                    SBQQ__Quantity__c,SBQQ__QuoteLine__c,SBQQ__StartDate__c,SBQQ__SubscriptionEndDate__c,
                                    SBQQ__SubscriptionStartDate__c ,SBQQ__QuoteLine__r.SBQQ__EffectiveStartDate__c,
                                    SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c,SBQQ__OrderProduct__r.ServiceDate,SBQQ__OrderProduct__r.EndDate
                                    FROM SBQQ__Subscription__c
                                    WHERE SBQQ__Contract__c =: setContractIds];
            //Master Contract will be Order with Lowest Start Date if multiple contracts      
            if(!lstContractofOrder.isEmpty()){
                 masterContractId = lstContractofOrder[0].Id;
            }
            //If multiple Contracts then associated all other subscription liens to Master Contract                          
            if(!lstContractofOrder.isEmpty() && lstContractofOrder.size() > 1){
                 for(SBQQ__Subscription__c subs : lstSubscriptionLines){
                    if(subs.SBQQ__Contract__c != masterContractId){
                        subs.SBQQ__Contract__c = masterContractId;
                    }
                    if(subs.SBQQ__OrderProduct__r.ServiceDate != Null || subs.SBQQ__OrderProduct__r.EndDate != Null){ //<T03>
                        subs.SBQQ__SubscriptionStartDate__c = subs.SBQQ__OrderProduct__r.ServiceDate; 
                        subs.SBQQ__SubscriptionEndDate__c = subs.SBQQ__OrderProduct__r.EndDate;                        
                    }
                    lstSubsToUpdate.add(subs);
                }
            }
            //If single Contrct on Order then just update the Stanr adn End dates from the Associated Quote Lines
            if(!lstContractofOrder.isEmpty() && lstContractofOrder.size() == 1){
                for(SBQQ__Subscription__c subs : lstSubscriptionLines){
                    if(subs.SBQQ__OrderProduct__r.ServiceDate != Null || subs.SBQQ__OrderProduct__r.EndDate != Null){
                        subs.SBQQ__SubscriptionStartDate__c = subs.SBQQ__OrderProduct__r.ServiceDate;
                        subs.SBQQ__SubscriptionEndDate__c = subs.SBQQ__OrderProduct__r.EndDate;                        //</T03>
                    }                    
                    lstSubsToUpdate.add(subs);
                }
            }
            
            try{
                 if(!lstSubsToUpdate.isEmpty()){            
                    Database.SaveResult [] updateResult = Database.update(lstSubsToUpdate, false);
                }   
            }
            Catch(Exception e){
                GAM.CreateExceptionRecords('CancelDebookOrder', 'DebookOrder',e.getMessage());            
            }       
            //Update the Debooked check on Order to True. 
            orderDetails = [SELECT Id,Status,Sub_Type__c,Cancel_Debook_Reason__c,Cancel_Debook_Reason_text__c,Do_Not_Send_Invoices_to_Customer__c  from Order where Id =:OrderId Limit 1];
            orderDetails[0].Sub_Type__c = 'Full Debook';
            orderDetails[0].Status = 'Debook';  //<T04>
            orderDetails[0].Cancel_Debook_Reason__c = CancelReason;
            orderDetails[0].Cancel_Debook_Reason_text__c = CancelReasonText;
            orderDetails[0].Do_Not_Send_Invoices_to_Customer__c = 'Do Not Send All Invoices to Customer(S)'; //<T11> <I2C-1336 PRE>
            try{
                update orderDetails;
            }
            Catch(Exception e){
                GAM.CreateExceptionRecords('CancelDebookOrder', 'DebookOrder',e.getMessage());            
            } 
            
        }
        //-----------T01-------------------------------
        //QuoteModel quote = load(masterContractId); <T02>       
        primaryOrderedContractedRenewal.doJob('Amend','Contract',masterContractId);
        //-----------T01-------------------------------
    
    }
          
}