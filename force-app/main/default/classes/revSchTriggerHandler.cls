/*
Class:            revSchTriggerHandler
@Author:          RamEsh M S
@Created Date:    09 July 2020
@Description:     I2C-659
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                 Requested By                 Description                                                                         Tag
Sumit Mittal              4-AUG-2020            I2C-752,             Bookings Project             Added the method to create/update                                                  <T01>
                                                I2C-900                                          Bookings and Booking lines
RamEsh M S                14-AUG-2020                                Finance                      Remove Delta Logic that creates Revenue Schedules for Delta Amount.                <T02>
                                                                                                 It is no longer required by the Integration.                                                                                                
RamEsh M S                17-DEC-2020           I2C-1109             Finance                      Update the logic to create/update Booking when RA is moved to Allocation Validated  <T03>
  
Nishit S                  22 JUN 2021           I2C-1268             Finance             Manual Allocation Flag not being updated on RA's with Manual Allocation      <T04>
Nishit S                  24 JUN 2021           I2C-1267 & 1268      Finance             Deleting Ship Date and Manual Allocation fields                  <T05>
Nishit S                  25 FEB 2022           I2C-1250             Finance             Order product is not populated in all the booking lines                <I2C-1250>
Nishit S                  23 MAR 2022           I2C-1542             Finance             Consumption Overage - Usage Based Invoicing & Revenue                       <I2C-1542>
Nishit S                  20 APR 2022           I2C-1580             Finance             Consumption Overage - Update the Ship date and Deferred Revenue Accounting Date     <I2C-1580>
RamEsh M S                06-SEP-2022           I2C-1658             Finance             Automate the Revenue Agreement processing of Usage generated Revenue Schedules for PayGo <I2C-1658> 
Nishit S                  21-NOV-2022           I2C-1744             Finance             Flex IPU - Order & Invoice Processing                                                      <I2C-1744>
Nishit S                  27-FEB-2023           I2C-1848             Finance             Flex IPU Orders - Automate the processing of Usage Generated Revenue Schedules             <I2C-1848>
********************************************************************************************************************************************************************************************************************
*/

public class revSchTriggerHandler
{
    public static globalApexManager GAM = new globalApexManager();
     
    public static void revSchBeforeInsert(List<blng__RevenueSchedule__c> newList){
       //<I2C-1542> START
        Set<Id> invoiceLineIdsSet = new Set<Id>();
        for(blng__RevenueSchedule__c rs : newList){
            invoiceLineIdsSet.add(rs.blng__InvoiceLine__c);
        } 
        Map<Id,blng__InvoiceLine__c> invoiceLineMap = new Map<Id,blng__InvoiceLine__c>([SELECT Id,blng__StartDate__c,blng__EndDate__c,blng__Quantity__c, blng__UsageSummary__r.blng__SummaryStartDate__c, 
                                                                                        blng__UsageSummary__r.blng__SummaryEndDate__c,blng__Invoice__c, blng__Invoice__r.blng__InvoiceDate__c,
                                                                                        blng__UsageSummary__r.blng__TotalQuantity__c, blng__Product__r.Amoritization_Schedule__c, 
                                                                                        blng__OrderProduct__c, blng__OrderProduct__r.Term__c, blng__Product__c, blng__UsageSummary__r.blng__UnitPrice__c,
                                                                                        Name, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.Name, blng__Product__r.SBQQ__HasConsumptionSchedule__c,
                                                                                        blng__Product__r.Business_Unit__c, blng__Product__r.Edition__c, blng__Invoice__r.blng__InvoicePostedDate__c,
                                                                                        blng__OrderProduct__r.Order.Source__c, //Added blng__InvoicePostedDate__c <I2C-1580>,
                                                                                        blng__Product__r.GTM_Model__c, blng__Product__r.Option_Scale__c, blng__OrderProduct__r.SBQQ__RequiredBy__c,
                                                                                        blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c, blng__OrderProduct__r.Order.type,
                                                                                        blng__OrderProduct__r.Product2.GTM_Model__c, blng__OrderProduct__r.Product2.Option_Scale__c
                                                                                        FROM blng__InvoiceLine__c 
                                                                                        WHERE Id IN :invoiceLineIdsSet]);
        Set<Id> orderId = new Set<Id>();
        Map<Id,Id> invLineRevAgrMap = new Map<Id,Id>();
        Map<Id,Revenue_Agreement__c> revAgreementUpdateList = new Map<Id,Revenue_Agreement__c>();
        Map<Id,Related_Order_and_Contract__c> ROCList = new Map<Id,Related_Order_and_Contract__c> ();
        //Map<Id, Related_Order_and_Contract__c> invoiceContractMap = new Map<Id,Related_Order_and_Contract__c> (); //<I2C-1744>
        Set<Id> requiredByOrderProducts = new Set<Id>();//<I2C-1744>
        Set<Id> originalOrderProducts = new Set<Id>();//<I2C-1744>
        Set<Id> containsDaaSOverage = new Set<Id> (); //<I2C-1848>
        Set<Id> revAgreeStageNotReady = new Set<Id> (); //<I2C-1848>

        
        
        
        for(blng__InvoiceLine__c invLine : invoiceLineMap.Values()){
            orderId.add(invLine.blng__OrderProduct__r.OrderId);
            requiredByOrderProducts.add(invLine.blng__OrderProduct__r.SBQQ__RequiredBy__c);//<I2C-1744>
            originalOrderProducts.add(invLine.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c);
        }
        
        for(Related_Order_and_Contract__c roc : [SELECT Revenue_Agreement__c,Revenue_Agreement__r.Stage__c, Order__c, Invoice__c, Contract__r.StartDate, Contract__r.EndDate FROM Related_Order_and_Contract__c WHERE Order__c IN :orderId]){
            invLineRevAgrMap.put(roc.Order__c, roc.Revenue_Agreement__c);
            if(roc.Revenue_Agreement__r.Stage__c != 'Ready' && roc.Revenue_Agreement__r.Stage__c != 'Sent to RMCS')
                revAgreeStageNotReady.add(roc.Revenue_Agreement__c);
        }
        
        //<I2C-1744> start
        
        Map<Id, List<blng__UsageSummary__c>> commitmentUSMap = new Map<Id, List<blng__UsageSummary__c>>();
        Map<Id, List<blng__UsageSummary__c>> originalUSMap = new Map<Id, List<blng__UsageSummary__c>>();
        List<blng__UsageSummary__c> originalUSList = new List<blng__UsageSummary__c>();
        String GTM_Model = Label.IPU_Product_GTM_Value;

        for(OrderItem orderProduct : [select id, Product2.name, SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c, Order.type, (select id, blng__SummaryStartDate__c, blng__SummaryEndDate__c from blng__OrderProductUsageMediations__r ) 
                                      from OrderItem where Product2.Option_Scale__c != 'Overage' and Product2.GTM_Model__c =: GTM_Model and Product2.SBQQ__HasConsumptionSchedule__c =true 
                                      AND (SBQQ__RequiredBy__c IN :requiredByOrderProducts OR SBQQ__RequiredBy__c IN :originalOrderProducts)]){ 
                                          /*if(orderProduct.Order.type == 'Amendment' && orderProduct.SBQQ__RequiredBy__c == NULL){
                                              originalUSMap.put(orderProduct.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,orderProduct.blng__OrderProductUsageMediations__r);
                                          }
                                          else*/
                                              commitmentUSMap.put(orderProduct.SBQQ__RequiredBy__c, orderProduct.blng__OrderProductUsageMediations__r);
                                      }
        //<I2C-1744> ends 
        for (blng__RevenueSchedule__c rs : newList){ 
            if(rs.blng__InvoiceLine__c!= NULL){
                //<I2C-1744> START
                if(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Product__r.GTM_Model__c == GTM_Model && invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Product__r.Option_Scale__c == 'Overage'){
                    if(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r.Order.type == 'Amendment' && invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r.SBQQ__RequiredBy__c == NULL && invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__r?.SBQQ__OrderProduct__c != null){
                        for(blng__UsageSummary__c us : commitmentUSMap.get(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.SBQQ__QuoteLine__r?.SBQQ__RequiredBy__r?.SBQQ__UpgradedSubscription__r?.SBQQ__OrderProduct__c)){
                            if(invoiceLineMap.get(rs.blng__InvoiceLine__c).blng__StartDate__c >= us.blng__SummaryStartDate__c && invoiceLineMap.get(rs.blng__InvoiceLine__c).blng__EndDate__c <= us.blng__SummaryEndDate__c){
                                rs.blng__RevenueStartDate__c = us.blng__SummaryStartDate__c;
                                rs.blng__RevenueEndDate__c = us.blng__SummaryEndDate__c;
                            }
                        }
                    }
                    else{
                        for(blng__UsageSummary__c us : commitmentUSMap.get(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.SBQQ__RequiredBy__c)){//values()[0]) //get(rs.blng__InvoiceLine__r.blng__OrderProduct__r.Id))
                            if(invoiceLineMap.get(rs.blng__InvoiceLine__c).blng__StartDate__c >= us.blng__SummaryStartDate__c && invoiceLineMap.get(rs.blng__InvoiceLine__c).blng__EndDate__c <= us.blng__SummaryEndDate__c){
                                rs.blng__RevenueStartDate__c = us.blng__SummaryStartDate__c;
                                rs.blng__RevenueEndDate__c = us.blng__SummaryEndDate__c;
                            }
                        }
                }
                }
                //<I2C-1744> END
                else{
                    rs.blng__RevenueStartDate__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__StartDate__c;
                    rs.blng__RevenueEndDate__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__EndDate__c;
                }

                rs.Deferred_Revenue_Acct_Date__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Invoice__r?.blng__InvoicePostedDate__c; // Changed to blng__InvoicePostedDate__c <I2C-1580>
                rs.Revenue_Category__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Product__r.Amoritization_Schedule__c;
                rs.blng__OrderProduct__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__c;
                rs.Quantity__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Quantity__c;
                rs.Product__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Product__c;
                rs.Extended_List_Price__c = rs.blng__TotalRevenueAmount__c;
                rs.Revenue_Agreement__c = invLineRevAgrMap.get(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.OrderId);
                rs.Usage_Summary_Generated__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__UsageSummary__c != null ? TRUE : FALSE;
                
                //<I2C-1658> STARTS
                if((invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.Order?.Source__c == 'Ecommerce - Paygo') 
                   || (invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.Product2.Option_Scale__c == 'Overage' && invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.Product2.GTM_Model__c == GTM_Model)) // Added for <I2C-1848>
                {
                    RS.Allocated_Booking__c = RS.blng__TotalRevenueAmount__c;
                    RS.Allocated_Bookings__c = RS.blng__TotalRevenueAmount__c;   
                    revAgreementUpdateList.put(rs.Revenue_Agreement__c,new Revenue_Agreement__c(Id = rs.Revenue_Agreement__c, Stage__c = containsDaaSOverage?.contains(rs.Revenue_Agreement__c) ? 'Draft' : (revAgreeStageNotReady?.contains(rs.Revenue_Agreement__c) ? 'Draft' : 'Ready') ,Pre_Allocated__c = containsDaaSOverage?.contains(rs.Revenue_Agreement__c) ? FALSE : (revAgreeStageNotReady?.contains(rs.Revenue_Agreement__c) ? FALSE : TRUE))); 
                    ROCList.put(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Invoice__c,new Related_Order_and_Contract__c(Revenue_Agreement__c = rs.Revenue_Agreement__c,Order__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.OrderId,Invoice__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Invoice__c,Usage_Summary_Generated__c = TRUE));
                }//<I2C-1658> ENDS
                else if(rs.Usage_Summary_Generated__c)
                {
                    revAgreementUpdateList.put(rs.Revenue_Agreement__c,new Revenue_Agreement__c(Id = rs.Revenue_Agreement__c, Stage__c = 'Draft', Pre_Allocated__c = FALSE)); 
                    containsDaaSOverage.add(rs.Revenue_Agreement__c);
                    ROCList.put(invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Invoice__c,new Related_Order_and_Contract__c(Revenue_Agreement__c = rs.Revenue_Agreement__c,Order__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__OrderProduct__r?.OrderId,Invoice__c = invoiceLineMap.get(rs.blng__InvoiceLine__c)?.blng__Invoice__c,Usage_Summary_Generated__c = TRUE));
                }
                
            }
        }
        if(revAgreementUpdateList.size()>0){
            try{
                update revAgreementUpdateList.values();
            }catch(Exception e){
                System.debug('Error Updating RA');
            }
        }
        if(ROCList.size()>0){
            try{
                insert ROCList.values();
            }catch(Exception e){
                System.debug('Error Updating ROCList');
            }
        }
        
    }
    
    public static void revSchAfterInsert(Map<Id,blng__RevenueSchedule__c> newMap)
    {
       //<I2C-1658> STARTS Collecting Revenue Agreements of Revenue Schdules of Pay GO Orders created from Invoice. And passing to create Booking Line Details. Since the RA Stage would be Ready, it wouldn't impact Booking of DaaS Usage.
       Set<Id> revAgrIdsB = new Set<Id> ();
       for(blng__RevenueSchedule__c RS : newMap.values())
       {
           if(RS.Usage_Summary_Generated__c && Rs.blng__InvoiceLine__c != NULL && RS.Revenue_Agreement__c != NULL)
           {
               revAgrIdsB.add(RS.Revenue_Agreement__c);
           }
       }
       
       if(revAgrIdsB.size() > 0)  
            createUpdateBookings(revAgrIdsB,'Revenue Agreement');
            
       //<I2C-1658> ENDS     
 
    }
    
    public static void revSchBeforeUpdate(Map<Id,blng__RevenueSchedule__c> newMap,Map<Id,blng__RevenueSchedule__c> oldMap)
    {
        for(blng__RevenueSchedule__c RS : newMap.values())
        {
            //updates allocated booking only for first time.
            RS.Allocated_Booking__c = (RS.Allocated_Booking__c == null && RS.Allocated_Bookings__c != null && oldMap.get(RS.Id).Allocated_Bookings__c == null) ? RS.Allocated_Bookings__c : RS.Allocated_Booking__c;
            //updates allocated booking on every change.
            //RS.Allocated_Booking__c = (RS.Allocated_Booking__c == null && RS.Allocated_Bookings__c != null && oldMap.get(RS.Id).Allocated_Bookings__c == null) || (RS.Allocated_Bookings__c != oldMap.get(RS.Id).Allocated_Bookings__c && RS.Allocated_Bookings__c != null) ? RS.Allocated_Bookings__c : RS.Allocated_Booking__c;
          
            //<T04>
            if(!newMap.get(RS.Id).Sent_to_RMCS__c) //<T05> Uncomment after deleting
               RS.Manual_Allocation__c = newMap.get(RS.Id).Allocated_Booking__c != newMap.get(RS.Id).Allocated_Bookings__c;//<T05> Uncomment after deleting
            //</T04>
        }
        

    }
    
    public static void revSchAfterUpdate(Map<Id,blng__RevenueSchedule__c> newMap,Map<Id,blng__RevenueSchedule__c> oldMap)
    {
       
       Set<Id> RSIds = new Set<Id> ();
        
        for(Id RSId : newMap.keySet())
        {
            if(newMap.get(RSId).Allocated_Booking__c != oldMap.get(RSId).Allocated_Booking__c ||
                newMap.get(RSId).Order_Changes_Recorded__c != oldMap.get(RSId).Order_Changes_Recorded__c)      
                 RSIds.add(RSId);
        }   
        createUpdateBookings(RSIds,'Revenue Schedule');  //</T01> <T03>

    }
    


    /* <T01> <T03>
* createUpdateBookings : Input parameters newMap,oldMap
* Description : This method creates the Bookings and Booking line details if none exist or Updates the booking header if exist.
* Return Void.
*/
    
    public Static void createUpdateBookings(Set<Id> recordIds, String objectType) {
        //variable initializations
        Set<Id> setParentRAIds = new Set<id>();
        List<blng__RevenueSchedule__c> listRSLines = new List<blng__RevenueSchedule__c>();
        List<Booking__c> newListInsertBookings = new List<Booking__c>();
        List<Booking__c> listUpdateBookings = new List<Booking__c>();
        List<Booking_Line_Details__c> newListInsertBookingLine = new List<Booking_Line_Details__c>();
        Map<id,Booking__c> mapRAIdBooking = new Map<Id, Booking__c>();
        Map<id,Booking_Line_Details__c > mapRSIdBookingLineDetail = new Map<Id, Booking_Line_Details__c >();
        Map<Id,blng__RevenueSchedule__c> newMap = new Map<Id,blng__RevenueSchedule__c> ();
        Set<String> RAStages = new Set<String> {'Allocation Validated','Ready','Sent to RMCS'};
        
        if(objectType == 'Revenue Schedule')
            newMap = new Map<Id,blng__RevenueSchedule__c> ([Select Id,Allocated_Booking__c,Allocated_Bookings__c,Bookings__c,Extended_List_Price__c,/*Manual_Allocation__c, <T05>*/
                                                           Order_Changes_Recorded__c,Order_Number__c,Parent_RS__c,Parent_RS__r.blng__OrderProduct__c,Percentage_Allocation__c,Product__c,Quantity__c,Revenue_Agreement__r.Stage__c,
                                                           Revenue_Agreement__c,Revenue_Category__c,RS_Number__c,/*Ship_Date__c,<T05>*/Status__c,blng__TotalRevenueAmount__c, 
                                                           blng__OrderProduct__c from blng__RevenueSchedule__c where Id =: recordIds AND Revenue_Agreement__r.Stage__c =: RAStages]);
        
        if(objectType == 'Revenue Agreement')
            newMap = new Map<Id,blng__RevenueSchedule__c> ([Select Id,Allocated_Booking__c,Allocated_Bookings__c,Bookings__c,Extended_List_Price__c,/*Manual_Allocation__c, <T05>*/
                                                           Order_Changes_Recorded__c,Order_Number__c,Parent_RS__c,Parent_RS__r.blng__OrderProduct__c,Percentage_Allocation__c,Product__c,Quantity__c,Revenue_Agreement__r.Stage__c,
                                                           Revenue_Agreement__c,Revenue_Category__c,RS_Number__c,/*Ship_Date__c,<T05>*/Status__c,blng__TotalRevenueAmount__c, 
                                                           blng__OrderProduct__c from blng__RevenueSchedule__c where Revenue_Agreement__c =: recordIds AND Revenue_Agreement__r.Stage__c =: RAStages]);
        
        if(objectType == 'Order')
            newMap = new Map<Id,blng__RevenueSchedule__c> ([Select Id,Allocated_Booking__c,Allocated_Bookings__c,Bookings__c,Extended_List_Price__c,/*Manual_Allocation__c, <T05>*/
                                                           Order_Changes_Recorded__c,Order_Number__c,Parent_RS__c,Parent_RS__r.blng__OrderProduct__c,Percentage_Allocation__c,Product__c,Quantity__c,Revenue_Agreement__r.Stage__c,
                                                           Revenue_Agreement__c,Revenue_Category__c,RS_Number__c,/*Ship_Date__c,<T05>*/Status__c,blng__TotalRevenueAmount__c, 
                                                           blng__OrderProduct__c,blng__OrderProduct__r.OrderId from blng__RevenueSchedule__c where (blng__OrderProduct__r.OrderId =: recordIds OR Parent_RS__r.blng__OrderProduct__r.OrderId =: recordIds) AND Revenue_Agreement__r.Stage__c =: RAStages]);
        
        
        //looping over RS lines to retrieve the basic details
        for(blng__RevenueSchedule__c RS : newMap.values()) {
            /*if(RS.Sent_to_RMCS__c &&
               (RS.Sent_to_RMCS__c != oldMap.get(RS.Id).Sent_to_RMCS__c ||
                 RS.Allocated_Booking__c != oldMap.get(RS.Id).Allocated_Booking__c ||
                RS.Order_Changes_Recorded__c != oldMap.get(RS.Id).Order_Changes_Recorded__c)) {*/
                    listRSLines.add(RS);
                    setParentRAIds.add(RS.Revenue_Agreement__c);
                //}
        }    
        system.debug('listRSLines'+listRSLines);
        system.debug('setParentRAIds'+setParentRAIds);
        if(!listRSLines.isEmpty() &&
           setParentRAIds != Null &&
           setParentRAIds.size() > 0) {
               //Check if any Bookings are already linked with Parent Revenue Agreements
               for(Booking__c booking : [Select id, Account__c,Revenue_Agreement__c, Revenue_Agreement__r.Id, 
                                         Revenue_Agreement__r.Stage__c, Reprocess_Booking__c,  
                                         (Select Id, Booking__r.Revenue_Agreement__r.Id, Revenue_Schedule__c, Product__c, Order_Product__c from Booking_Line_Details__r)
                                         from Booking__c 
                                         where Revenue_Agreement__r.Id IN :setParentRAIds]) {
                                             
                                             //Populated the below map with the RAId vs Booking record linked
                                             mapRAIdBooking.put(booking.Revenue_Agreement__r.Id,booking);
                                             for(Booking_Line_Details__c bookingLines : booking.Booking_Line_Details__r) {
                                                 //Populate the below map with RS ids vs Booking Line Detail record
                                                 mapRSIdBookingLineDetail.put(bookingLines.Revenue_Schedule__c, bookingLines);
                                             }
                                         }
               
               system.debug('mapRABookingIds ='+mapRAIdBooking);
               system.debug('mapRSIdBookingLineDetail ='+mapRSIdBookingLineDetail);
               
               //Update the setParentRAIds so that we can create the missing Booking header records for remaining RA ids.
               setParentRAIds.removeAll(mapRAIdBooking.KeySet());
               
               //Insertion of Booking header and updating the mapRAIdBooking for reference.
               if(setParentRAIds.size() > 0) {
                   for(Revenue_Agreement__c revAgreement : [Select Id, Account__c from Revenue_Agreement__c where Id IN: setParentRAIds]) {
                       Booking__c newBookingRec = new Booking__c();
                       newBookingRec.Revenue_Agreement__c = revAgreement.Id;
                       newBookingRec.Account__c = revAgreement.Account__c;
                       newBookingRec.CurrencyIsoCode = 'USD';
                       newBookingRec.Reprocess_Booking__c = System.isBatch() ? FALSE : TRUE;
                       newBookingRec.RecordTypeId = Schema.SObjectType.Booking__c.getRecordTypeInfosByName().get('Bookings').getRecordTypeId();
                       newListInsertBookings.add(newBookingRec);
                   }
                   try {
                       if(!newListInsertBookings.isEmpty()) {
                           insert newListInsertBookings;
                       } 
                   }catch (Exception e) {
                       GAM.CreateExceptionRecords('Create Bookings header record', e.getMessage(), 'error from revSchTriggerHandler');
                       
                   }
                   system.debug('Inserted items : '+newListInsertBookings);
                   for(Booking__c newBooking : newListInsertBookings) {
                       mapRAIdBooking.put(newBooking.Revenue_Agreement__c,newBooking);
                   }
               }
               
               //Insert of Booking Line details Or update for Booking header if RS lines allocations are changed and have a linked Booking line.
               for(blng__RevenueSchedule__c RS : listRSLines) {
                   system.debug('RS :::'+RS);
                   system.debug('mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c :::'+mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c);
                       if(mapRSIdBookingLineDetail.ContainsKey(RS.Id) &&
                          mapRAIdBooking.ContainsKey(RS.Revenue_Agreement__c) && 
                          !mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c) {
                              system.debug('inside');
                              mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c = True;
                              listUpdateBookings.add(mapRAIdBooking.get(RS.Revenue_Agreement__c));
                          } else If(!mapRSIdBookingLineDetail.ContainsKey(RS.Id) &&
                                    mapRAIdBooking.ContainsKey(RS.Revenue_Agreement__c)){
                                        
                                        //Create Booking line details
                                        Booking_Line_Details__c newBookingLine = new Booking_Line_Details__c();
                                        newBookingLine.Name = 'BD-'+RS.RS_Number__c;
                                        newBookingLine.Booking__c = mapRAIdBooking.get(RS.Revenue_Agreement__c).Id;
                                        newBookingLine.CurrencyIsoCode = 'USD';
                                        newBookingLine.Order_Product__c = RS.blng__OrderProduct__c == NULL ? RS.Parent_RS__r?.blng__OrderProduct__c : RS.blng__OrderProduct__c; //I2C-1250 New Logic update for march Build
                                        newBookingLine.Product__c = RS.Product__c;
                                        newBookingLine.Revenue_Schedule__c = RS.Id;
                                        newBookingLine.RecordTypeId = Schema.SObjectType.Booking_Line_Details__c.getRecordTypeInfosByName().get('Booking Line Detail').getRecordTypeId();
                                        newBookingLine.Manual_Adjustment__c = False;
                                        newListInsertBookingLine.add(newBookingLine);
                                        
                                        //Also check if the header Reprocess Flag is to be reset for calculation
                                        if(!mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c) {
                                            mapRAIdBooking.get(RS.Revenue_Agreement__c).Reprocess_Booking__c = True;
                                            listUpdateBookings.add(mapRAIdBooking.get(RS.Revenue_Agreement__c)); 
                                        }
                                    }
                   
               }
               try
               {
                   if(!newListInsertBookingLine.isEmpty()) {
                       insert newListInsertBookingLine;
                   }
                   if(!listUpdateBookings.isEmpty()) {
                       update listUpdateBookings;
                   }
               }catch(Exception e) {
                   GAM.CreateExceptionRecords('Create/Update of Bookings and Bookings line detail', e.getMessage(), 'error from revSchTriggerHandler');
               } 
           }
    }
}