/***************************************************************************************************************************************************************
 *  @Class Name: revenueAgreementBatch
 *  @Author: Ramesh M S
 *  @Date: 23 JUN 2020
 *  @Description: I2C-659 - Class to link Revenue Schedules to Revenue Agreement and link Contract to Related Juntion Object. Also, create custom Revenue Schedules for
                  Revenue Allocation.  
 ****************************************************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                    Date                       Requested By                     Description                                        Tag   
 
 RamEsh M S                    27-10-2020                 I2C-1080                          Create Contract                                   <T01>
 RamEsh M S                    02-11-2020                 I2C-1079                          Allow RA creation for Partner Fee Orders          <T02>
 RamEsh M S                    02-12-2020                 SALESRT-12627                     Retrigger contract creation                       <T03>
 RamEsh M S                    02-12-2020                 Tech Debt                         Automate Order Completion Status                  <T04>
 RamEsh M S                    22-02-2021                 SALESRT-12621                     Reallocation POT Support in Amendment             <T05>
 RamEsh M S                    18-03-2021                 I2C-1230                          Update QTY to POT Support on Reallocation in Amendment <T06>
 Nishit S                      07-JUL-2021                 I2C-1267                          Revenue Schedules for Royalty Fees are not
                                                                                            populated with Ship Dates              <T07>
 RamEsh M S                    29-JUL-2021                I2C-1335                          To create Contract for Product Fund Remix Amend Order from Batch Process <I2C-1335>
 Wasim                         20-SEP-2021                SALESRT-13309                     Moving the Substage assignment logic from ordertriggerhandler to this class <SALESRT-13309>
 Wasim                         03-JAN-2022                CPQ Upgrade '22 Winter            Adding logic to delete ROC for Revison Order Downstream = Fulfillment and create Contract - overcome access issue <T08> 
 RamEsh M S                    09-FEB-2022                I2C-1497                          Update Revenue Category on Amended Revenue Schedule with Revenue Category of Original Revenue Schedule <I2C-1497>
 Wasim                         25-FEB-2022                I2C-1446                          Revenue Schedules with more than 10 child lines breaking Allocation Engine and Interface <I2C-1446>
 Ramya Ravi                    01-June-2022               I2C-1611                          Add 'List Rate' field to the Revenue Schedule <I2C-1611>
 RamEsh M S                    29-AUG-2022                I2C-1701                          Added tolerance of 0.5 on Total Amount to handle 0$ Amendments <I2C-1701>
 RamEsh M S                    30-AUG-2022                I2C-1639                          Mark Order and RA to complete for PAYG Orders on the start day of Subscription              <I2C-1639>
 RamEsh M S                    28-OCT-2022                I2C-1766                          Handling duplicate RA creation issue for amendments from contract that created prior to PSFT Project <I2C-1766>
 Nishit S                      30-JAN-2023                I2C-1841                          Flex IPU - SFDC Revenue & Bookings Object Amendment Start Date changes                               <I2C-1841>
 Nishit S                      24-APR-2023                I2C-1729                          Multi Contract Swaps - Update the Related Revenue Order Field for Amendment Orders                  <I2C-1729>
 Sreerekha                     08-JUN-2023                I2C-1939                          Enhance the Related Revenue Order Automation logic    <T09>
 Nishit S                      25-JUL-2023                I2C-1979                          Clear the "Force Error" flag on Revenue Agreement Amendment when status is set back to Draft    <I2C-1979>
 RamEsh M S                    01-DEC-2023                I2C-2081                          Amendment Created Via Split Contract doesn't update the existing RA instead creating a New RA <I2C-2081>
**************************************************************************************************************************************************************************************************************************/
global class revenueAgreementBatch implements Schedulable, Database.Batchable<Sobject>/*, Database.Stateful*/{
    
    public static globalApexManager GAM = new globalApexManager();
    public Id orderId;
    
    global revenueAgreementBatch()
    {
        
    }
    
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        String OrderStatus = 'Activated';
        String Bill_Contract = 'Bill & Contract';
        String strCompleted = 'Completed';
        String revOrd = Label.RevisionLabel;
        String ordAmend = 'Amendment';
        String BMPF = 'Product Fund';
        String subType = 'Remix';
        String orderSource = 'Ecommerce - Paygo'; //<I2C-1639>
        Set<String> RAStage = new Set<String> ();
        RAStage.add('Ready');
        RAStage.add('Sent to RMCS');
        Decimal ordAmtTol = Decimal.valueOf(Label.OrdAmtToleranceComp); //I2C-1701
        
        //String query = 'Select Id,Order__c,Order__r.Type,Order__r.Status,Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Quote__r.Primary_Order__c,Contract__c,Contract__r.Status,Revenue_Agreement__c,Original_Order__c,Order__r.CurrencyIsoCode,Order__r.Legal_Entity__c,Order__r.Business_Model__c,Unique_ID__c,Booked_Date__c,Order__r.SBQQ__Quote__r.Term_for_convenience__c from Related_Order_and_Contract__c where (Contract__c = null AND Order__r.SBQQ__Contracted__c = TRUE AND Revenue_Agreement__c != null) OR (Order__r.Status =: OrderStatus AND Revenue_Agreement__c = null)';
        String query = 'Select Id,Order__r.Opportunity.Enable_Downstream__c, Order__r.OpportunityId,Order__r.Opportunity.Substage__c,Order__c,Order__r.AccountId,Order__r.Type,Order__r.Status,Order__r.Source__c,Order__r.SBQQ__Quote__c,Order__r.Original_Order__c,Order__r.SBQQ__Quote__r.SBQQ__MasterContract__c,Order__r.blng__TotalBilling__c,'+
                        'Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Quote__r.Primary_Order__c,Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__c,Contract__c,Contract__r.Status,Revenue_Agreement__c,Original_Order__c,Order__r.CurrencyIsoCode,Order__r.TotalAmount,'+
                        'Order__r.Legal_Entity__c,Order__r.Business_Model__c,Unique_ID__c,Booked_Date__c,Order__r.SBQQ__Quote__r.Term_for_convenience__c,Order__r.Contract_Generated__c,Order__r.Asset_Creation_Status__c,'+
                        'Revenue_Agreement__r.Stage__c,Order__r.SBQQ__Contracted__c,Order__r.Revenue_Agreement_Processed__c,Order__r.Plan_Products_Created__c,Order__r.Sub_Type__c,Invoice__c,Usage_Summary_Generated__c,Order__r.Related_Revenue_Orders__c from Related_Order_and_Contract__c where '+
                        '(Contract__c = null AND Order__r.SBQQ__Contracted__c = TRUE AND Revenue_Agreement__c != null AND Order__r.SBQQ__Quote__c != null AND Order__r.Contract_Generated__c = TRUE AND Usage_Summary_Generated__c = FALSE) '+
                        'OR (Usage_Summary_Generated__c = TRUE AND Unique_ID__c = null AND Order__r.SBQQ__Quote__c != null AND Order__r.Contract_Generated__c = FALSE AND Revenue_Agreement__c != null) '+
                        'OR (Order__r.Status =: OrderStatus AND Revenue_Agreement__c = null AND (Order__r.Source__c != :orderSource OR (Order__r.Source__c = :orderSource AND Order__r.CMS_Approved__c = true))) '+ //<I2C-1639> - create RA after CMS for Ecommerce - Paygo orders
                        'OR (Contract__c = null AND Order__r.SBQQ__Quote__c != null AND Order__r.Contract_Generated__c = FALSE AND Revenue_Agreement__c != null AND Order__r.Revenue_Agreement_Processed__c = TRUE AND Revenue_Agreement__r.Stage__c IN: RAStage AND Usage_Summary_Generated__c = FALSE) '+
                        'OR (Contract__c = null AND Order__r.SBQQ__Quote__c != null AND Order__r.Type =:ordAmend AND Order__r.Business_Model__c =: BMPF AND Order__r.Sub_Type__c =: subType AND Order__r.Contract_Generated__c = FALSE AND Order__r.Revenue_Agreement_Processed__c = TRUE)'+//<I2C-1335>
                        'OR (Order__r.Status =: Bill_Contract AND Order__r.Asset_Creation_Status__c =: strCompleted  AND Order__r.Contract_Generated__c = TRUE AND Order__r.Plan_Products_Created__c = TRUE AND ((Order__r.blng__TotalBilling__c != 0 AND Order__r.TotalAmount != 0) OR (Order__r.TotalAmount <=' + ordAmtTol + 'AND Order__r.TotalAmount >=' + -ordAmtTol + ') OR Order__r.Sub_Type__c =: revOrd))';
        //system.debug('#size:'+Database.getQueryLocator(query).size());
        return Database.getQueryLocator(query);

    }
    
    global void execute(SchedulableContext ctx)
    {
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,1);
    }
    
    global void execute(Database.BatchableContext bc, List<Related_Order_and_Contract__c> scope)
    {
         List<blng__RevenueSchedule__c> RSList = new List<blng__RevenueSchedule__c> ();
         List<Related_Order_and_Contract__c> ROCList = new List<Related_Order_and_Contract__c> ();
         List<Related_Order_and_Contract__c> OrROCList = new List<Related_Order_and_Contract__c> ();
         Id originalOrderId;
         Id masterContractId;//<I2C-1766>
         Related_Order_and_Contract__c originalROC = new Related_Order_and_Contract__c ();
         Revenue_Agreement__c originalRA = new Revenue_Agreement__c ();
         List<blng__RevenueSchedule__c> RSMCList = new List<blng__RevenueSchedule__c> ();
         List<blng__RevenueSchedule__c> RSPOTList = new List<blng__RevenueSchedule__c> ();
         Map<Id,Id> OIROI = new Map<Id,Id> ();
         Map<Id,Id> OIRS = new Map<Id,Id> ();
         Map<Id,Id> OPQLSet = new Map<Id,Id> ();
         List<Contract> masterContract = new List<Contract> ();
         List<Related_Order_and_Contract__c> delROCList = new List<Related_Order_and_Contract__c> ();
         List<Related_Order_and_Contract__c> ROCScope = new List<Related_Order_and_Contract__c> ();
         List<Opportunity> oppList = new List<Opportunity>(); //<SALESRT-13309>
         Set<Id> orderIds = new Set<Id>();  //<SALESRT-13309>
         Boolean isFulfillmentRevisionOrder = false; //<T08> 
         Set<Id> processOrgRevCat = new Set<Id> ();     //I2C-1497
         Decimal ordAmtTol = Decimal.valueOf(Label.OrdAmtToleranceComp); //I2C-1701
        String GTM_Model = Label.IPU_Product_GTM_Value;//<I2C-1841>
        
         for(Related_Order_and_Contract__c RC : scope)
         {
             ROCScope.add(RC);
         }  
             if(!ROCScope.isEmpty())
             {
                 Related_Order_and_Contract__c ROC  = ROCScope[0];
                 //<T08> - Added the if condition and variable assignment 
                 if(Label.RevisionLabel.equals(ROC.Order__r.Sub_Type__c) && ROC.Order__r.Opportunity != null && ROC.Order__r.Opportunity.Enable_Downstream__c != null && !ROC.Order__r.Opportunity.Enable_Downstream__c.contains('Revenue Agreement')){
                     isFulfillmentRevisionOrder = true;
                 }
         
             try
             {                
                 if(ROC.Order__r.Status == 'Activated' && ROC.Revenue_Agreement__c == null && !isFulfillmentRevisionOrder) //<T08>
                 {
                     RSList = fetchRevenueSchedules(ROC.Order__r.Id);
                     
                     if(ROC.Order__r.Type == 'New' || ROC.Order__r.Type == 'Renewal')
                     {
                         //RSList = [Select Id,Revenue_Agreement__c,blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Product2Id,blng__OrderProduct__r.Quantity,blng__TotalRevenueAmount__c from blng__RevenueSchedule__c where blng__OrderProduct__r.OrderId =: ROC.Order__c];
                         
                         if(RSList.size() > 0)
                         {
                             Revenue_Agreement__c RANew = new Revenue_Agreement__c ();
                             RANew.Stage__c = 'Draft';
                             RANew.Pre_Allocated__c = FALSE;
                             RANew.Business_Model__c = ROC.Order__r.Business_Model__c;
                             RANew.CurrencyIsoCode = ROC.Order__r.CurrencyIsoCode;
                             RANew.Legal_Entity__c = ROC.Order__r.Legal_Entity__c;
                             RANew.Term_for_convenience__c = ROC.Order__r.SBQQ__Quote__r.Term_for_convenience__c;
                             RANew.Force_Error__c = RANew.Term_for_convenience__c;
                             RANew.Account__c = ROC.Order__r.AccountId;// Anil added account field on RA.
                             //<I2C-1639> START 
                             if(ROC.Order__r.Source__c == 'Ecommerce - Paygo'){     
                                 RANew.Pre_Allocated__c = true; 
                                 RANew.Stage__c = 'Sent to RMCS';  
                             }  
                             //<I2C-1639> ENDS
                             insert RANew;
                             
                            
                             
                             
                             ROC.Revenue_Agreement__c = RANew.Id;
                             ROC.Unique_ID__c = ROC.Order__c + '-' + RANew.Id;
                             //ROC.Booked_Date__c = ROC.Order__r.Generate_Date__c;
                             update ROC;
                             
                               //<I2C-1639> START 
                             if(ROC.Order__r.Source__c == 'Ecommerce - Paygo'){ 
                                 revSchTriggerHandler.createUpdateBookings(new Set<Id>{RANew.Id},'Revenue Agreement');
                                 revAgreeTriggerHandler.updateOrder(new Set<Id>{RANew.Id},new Map<Id,Revenue_Agreement__c> {RANew.Id => RANew});
                             }
                               //<I2C-1639> ENDS
                           
                             for(blng__RevenueSchedule__c RS : RSList)
                             {
                                 RS.Revenue_Agreement__c = RANew.Id;
                                 RS.Product__c = RS.blng__OrderProduct__r.Product2Id;
                                 RS.Quantity__c = RS.blng__OrderProduct__r.Quantity;
                                 // <T07> RS.Ship_Date__c = RS.blng__OrderProduct__r.Product2.Provisionable_New__c ? RS.blng__OrderProduct__r.Ship_Date__c : null;  //I2C-1267
                                 RS.Deferred_Revenue_Acct_Date__c = RS.blng__OrderProduct__r.Order.Provisioning_Complete_Date__c;
                                 RS.RS_Number__c = (RS.Name).subString(3);
                                 RS.Extended_List_Price__c = RS.blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c != null && RS.blng__OrderProduct__r.Quantity != null ? RS.blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c * RS.blng__OrderProduct__r.Quantity : RS.Extended_List_Price__c;
                                 RS.Revenue_Category__c = RS.blng__OrderProduct__r.Product2.Amoritization_Schedule__c; //I2C-1497                                 
                                 RS.ListRate__c =RS.blng__OrderProduct__r.PricebookEntry?.UnitPrice;//<I2C-1611>
                                 OIROI.put(RS.blng__OrderProduct__c,RS.blng__OrderProduct__r.SBQQ__RequiredBy__c);
                                 OIRS.put(RS.blng__OrderProduct__c,RS.Id);
                                 //<I2C-1639> Revenue Schedule changes  
                                 if(RS.blng__OrderProduct__r.Order.Source__c == 'Ecommerce - Paygo'){   
                                     RS.Allocated_Booking__c = RS.blng__TotalRevenueAmount__c;
                                     RS.Allocated_Bookings__c = RS.blng__TotalRevenueAmount__c;   
                                 }  
                                 //<I2C-1639>    
                             }
                             RSMCList = masterChildRS(RSList,RANew.Id,OIROI,OIRS,'NEW_RENEWAL');
                             if(!RSMCList.isEmpty())
                                 RSList.addAll(RSMCList);
                            
                                 if(!RSList.isEmpty())
                                 {
                                     SBQQ.TriggerControl.disable(); // we don't need CPQ and Billing code to execute
                                     upsert RSList;
                                     SBQQ.TriggerControl.enable();
                                 }
                            
                             
                         }
                        /*<T02> else
                         {
                             if(ROC.Order__r.Source__c == 'Fee' && (ROC.Order__r.SBQQ__Quote__c == null || ROC.Order__r.SBQQ__Quote__c == ''))
                                 delROCList.add(ROC);
                         }<T/02>*/
                     }
                     
                     if(ROC.Order__r.Type == 'Amendment' && !(ROC.Order__r.Business_Model__c == 'Product Fund' && ROC.Order__r.Sub_Type__c == 'Remix') && !isFulfillmentRevisionOrder) //<I2C-1335> <T08>
                     {
                         List<Order> ordList = new List<Order> ();
                         //RSList = [Select Id,Revenue_Agreement__c,blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Product2Id,blng__OrderProduct__r.Quantity,blng__TotalRevenueAmount__c from blng__RevenueSchedule__c where blng__OrderProduct__r.OrderId =: ROC.Order__c];
                         //originalOrderId = ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Quote__r.Primary_Order__c;
                         masterContractId = ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__c; ////<I2C-1766>
                         system.debug('masterContractId :'+masterContractId );
                         system.debug('ROC.Order__r:'+ROC.Order__c);
                         system.debug('ROC.Order__r.SBQQ__Quote__r:'+ROC.Order__r.SBQQ__Quote__c);
                         system.debug('ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r:'+ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__c);
                         
                         if(ROC.Order__r.SBQQ__Quote__c == null)
                         {
                             ordList = [Select Id from Order where OrderNumber =: ROC.Order__r.Original_Order__c LIMIT 1];
                             if(ordList != null && ordList.size() > 0)
                                 originalOrderId = ordList[0].Id;
                         }
                          //I2C-1766 -- updating the query to collect original RA for Direct ORder and Qoute to Order
                         if(ROC.Order__r.SBQQ__Quote__c == null){
                             OrROCList = [Select Id,Revenue_Agreement__c,Revenue_Agreement__r.Id,Revenue_Agreement__r.Name from Related_Order_and_Contract__c where Order__c =: originalOrderId LIMIT 1];   
                         }
                         else{
                             originalOrderId = ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__c; //<I2C-2081>
                             OrROCList = [Select Id,Revenue_Agreement__c,Revenue_Agreement__r.Id,Revenue_Agreement__r.Name from Related_Order_and_Contract__c where Contract__c =: masterContractId  /*<I2C-2081>*/OR Order__c =: originalOrderId  /*<I2C-2081>*/ORDER BY CreatedDate DESC LIMIT 1]; //<I2C-1766>
                         }
                         masterContract = [Select Id,PSFT_Contract_Number__c,SBQQ__Order__r.External_ID__c from Contract where Id =: ROC.Order__r.SBQQ__Quote__r.SBQQ__MasterContract__c];
                         Revenue_Agreement__c RANew = new Revenue_Agreement__c ();
                         system.debug('OrROCList ' + OrROCList);
                         
                         if(RSList.size() > 0)
                         {
                             if(OrROCList.size() > 0)
                             {
                                 originalROC = OrROCList[0];
                                 ROC.Revenue_Agreement__c = originalROC.Revenue_Agreement__c;
                                 ROC.Unique_ID__c = ROC.Order__c + '-' + originalROC.Revenue_Agreement__c;
                                 //ROC.Booked_Date__c = ROC.Order__r.Generate_Date__c;
                                 update ROC;
                             }
                             else
                             {
                                 
                                 RANew.Stage__c = 'Draft';
                                 RANew.Pre_Allocated__c = FALSE;
                                 RANew.Business_Model__c = ROC.Order__r.Business_Model__c;
                                 RANew.CurrencyIsoCode = ROC.Order__r.CurrencyIsoCode;
                                 RANew.Legal_Entity__c = ROC.Order__r.Legal_Entity__c;
                                 RANew.Term_for_convenience__c = ROC.Order__r.SBQQ__Quote__r.Term_for_convenience__c;
                                 RANew.Force_Error__c = RANew.Term_for_convenience__c; 
                                 RANew.Account__c = ROC.Order__r.AccountId;// Anil added account field on RA.
                                 if(masterContract.size() > 0)
                                 {
                                     RANew.PSFT_Contract__c = masterContract[0].PSFT_Contract_Number__c != null ? masterContract[0].PSFT_Contract_Number__c : masterContract[0].SBQQ__Order__r.External_ID__c;
                                 }
                                 insert RANew;
                                 
                                 ROC.Revenue_Agreement__c = RANew.Id;
                                 ROC.Unique_ID__c = ROC.Order__c + '-' + RANew.Id;
                                 update ROC;
                             }
                             
                             for(blng__RevenueSchedule__c RS : RSList)
                             {
                                 RS.Revenue_Agreement__c = ROC.Revenue_Agreement__c;
                                 RS.Product__c = RS.blng__OrderProduct__r.Product2Id;
                                 RS.Quantity__c = RS.blng__OrderProduct__r.Quantity;
                                 // <T07> RS.Ship_Date__c = RS.blng__OrderProduct__r.Product2.Provisionable_New__c ? RS.blng__OrderProduct__r.Ship_Date__c : null;
                                 RS.Deferred_Revenue_Acct_Date__c = RS.blng__OrderProduct__r.Order.Provisioning_Complete_Date__c;
                                 RS.RS_Number__c = (RS.Name).subString(3);
                                 RS.PSFT_Contract_Line__c = RANew.PSFT_Contract__c != null ? RS.RS_Number__c : RS.PSFT_Contract_Line__c;
                                 RS.Extended_List_Price__c = RS.blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c != null && RS.blng__OrderProduct__r.Quantity != null ? RS.blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c * RS.blng__OrderProduct__r.Quantity : RS.Extended_List_Price__c;
                                 RS.Revenue_Category__c = RS.blng__OrderProduct__r.Product2.Amoritization_Schedule__c; //I2C-1497
                                 RS.ListRate__c =RS.blng__OrderProduct__r.PricebookEntry?.UnitPrice;//<I2C-1611>
                                 //<I2C-1841> START
                                 if(RS.blng__RevenueStartDate__c < system.today() && RS.blng__OrderProduct__r.SBQQ__RequiredBy__c == NULL && RS.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.GTM_Model__c == GTM_Model && RS.blng__OrderProduct__r.Order.Type == 'Amendment' && RS.blng__OrderProduct__r.product2.Product_Category__c != 'Wrapper' && RS.blng__OrderProduct__r.SBQQ__ContractAction__c != 'Cancel'){
                                     RS.blng__RevenueStartDate__c = RS.blng__OrderProduct__r.Order.Generate_Date__c;
                                 }
                                 //<I2C-1841> END
                                 OIROI.put(RS.blng__OrderProduct__c,RS.blng__OrderProduct__r.SBQQ__RequiredBy__c);
                                 OIRS.put(RS.blng__OrderProduct__c,RS.Id);
                                
                                 if(RS.blng__OrderProduct__r.SBQQ__SubscriptionPricing__c == 'Percent Of Total' && RS.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null && RS.blng__OrderProduct__r.SBQQ__ContractAction__c != 'Cancel' && 
                                 RS.blng__OrderProduct__r.Product2.Product_Family__c == 'Support' && (RS.blng__OrderProduct__r.Product2.Forecast_Product__c == 'Support' || RS.blng__OrderProduct__r.Product2.Forecast_Product__c == 'Subscription Support'))
                                 {
                                     OPQLSet.put(RS.blng__OrderProduct__c,RS.blng__OrderProduct__r.SBQQ__QuoteLine__c);
                                 }
                                 if(RS.blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null) //I2C-1497
                                 {
                                     processOrgRevCat.add(RS.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c);
                                 }
                             }
                             
                             if(!processOrgRevCat.isEmpty() && processOrgRevCat != null)//I2C-1497
                                 updateRevenueCategory(processOrgRevCat,RSList);
                             
                             RSMCList = masterChildRS(RSList,ROC.Revenue_Agreement__c,OIROI,OIRS,RANew.PSFT_Contract__c);
                             if(!RSMCList.isEmpty())
                                 RSList.addAll(RSMCList);
                                 
                             //Collect POT Support lines of Amendment Order in Map and pass it to recalcPOTSuport() method to create separate lines for +ve and  -ve amounts <T05>    
                             if(!OPQLSet.isEmpty() && OPQLSet != null)
                             {
                                RSPOTList = recalcPOTSuport(RSList,OPQLSet);
                                if(!RSPOTList.isEmpty())
                                    RSList.addAll(RSPOTList);
                             } //<T05>
                             
                             if(!RSList.isEmpty())
                             {
                                 if(OrROCList.size() > 0)
                                 {
                                     globalApexManager.avoidRecursion('RevAgrrBeforeUpdate');
                                     system.debug('originalROC:'+originalROC);
                                     system.debug('originalROC.Revenue_Agreement__c:'+originalROC.Revenue_Agreement__c);
                                     originalRA = [Select Id,Stage__c,Pre_Allocated__c from Revenue_Agreement__c where Id =: originalROC.Revenue_Agreement__c LIMIT 1];
                                     originalRA.Stage__c = 'Draft';
                                     originalRA.Force_Error__c = false;  //I2C-1979 clear the flag force error
                                     originalRA.Pre_Allocated__c = FALSE;
                                     originalRA.Reset__c = TRUE;
                                     update originalRA;
                                     originalRA.Reset__c = FALSE;
                                     
                                     update originalRA;
                                 }
                                 SBQQ.TriggerControl.disable(); // we don't need CPQ and Billing code to execute
                                 upsert RSList;
                                 SBQQ.TriggerControl.enable();
                             }
                             
                            
                             
                             /*originalRA = [Select Id,Stage__c,Pre_Allocated__c from Revenue_Agreement__c where Id =: originalROC.Revenue_Agreement__c LIMIT 1];
                             originalRA.Stage__c = 'Draft';
                             originalRA.Pre_Allocated__c = FALSE;
                             originalRA.Reset__c = TRUE;
                             update originalRA;
                             originalRA.Reset__c = FALSE;
                             update originalRA;*/
                         }
                     }
                     if(ROC.Order__r.Type == 'Amendment' && ROC.Order__r.Source__c != 'Ecommerce - Paygo' && ROC.Order__r.Related_Revenue_Orders__c == NULL){
                        updateRelatedRevOrder(RSList);
                     }
                 }
                 system.debug('ROC.Contract__c:'+ROC.Contract__c);
                 system.debug('ROC.Revenue_Agreement__c:'+ROC.Revenue_Agreement__c);
                 system.debug('ROC.Order__r.Contract_Generated__c:'+ROC.Order__r.Contract_Generated__c);
                 if(ROC.Contract__c == null && ROC.Revenue_Agreement__c != null && ROC.Order__r.Contract_Generated__c)
                 {
                     if(ROC.Order__r.Type == 'New' || ROC.Order__r.Type == 'Renewal' || ROC.Order__r.Type == 'Amendment')
                     {
                         if(ROC.Usage_Summary_Generated__c)
                             ROC.Unique_ID__c =  ROC.Order__c + '-' + ROC.Revenue_Agreement__c + '-' + ROC.Invoice__c;
                         boolean firstContract = false;
                         for(Contract con : [Select Id,SBQQ__Order__c from Contract where SBQQ__Order__c =: ROC.Order__c])
                         {
                             if(!firstContract)
                             {
                                 ROC.Contract__c = con.Id;
                                 ROC.Unique_ID__c = ROC.Order__c + '-' + ROC.Revenue_Agreement__c + '-' + con.Id;
                                 ROCList.add(ROC);
                                 firstContract = true;
                             }
                             else
                             {
                                 Related_Order_and_Contract__c ROCClone = ROC.clone();
                                 ROCClone.Id = null;
                                 ROCClone.Contract__c = con.Id;
                                 ROCClone.Unique_ID__c = ROC.Order__c + '-' + ROC.Revenue_Agreement__c + '-' + con.Id;
                                 ROClist.add(ROCClone);
                             }
                         }
                         if(ROCList.size() > 0)
                         upsert ROCList;
                     }
                     
                    /* if(ROC.Order__r.Type == 'Amendment')
                     {
                         
                     }*/
                 }
                 
                 //<T01> Added below code to create contract from system context with Deployment Master to overcome access issues and lock row issues.
                 if(!ROC.Order__r.Contract_Generated__c && ROC.Contract__c == null && ((ROC.Order__r.Type == 'Amendment' && ROC.Order__r.Business_Model__c == 'Product Fund' && ROC.Order__r.Sub_Type__c == 'Remix') || //<I2C-1335>
                 (ROC.Revenue_Agreement__c != null && (ROC.Revenue_Agreement__r.Stage__c == 'Ready' || ROC.Revenue_Agreement__r.Stage__c == 'Sent to RMCS')) || isFulfillmentRevisionOrder) && 
                 (ROC.Order__r.Revenue_Agreement_Processed__c || isFulfillmentRevisionOrder)) //<T08> - Added conditions for Revision Order
                 {
                     List<Order> orToConList = new List<Order> ();
                     set<Id> retriggerIds = new Set<Id> ();
                     for(Order o : [Select Id,SBQQ__Contracted__c,Contract_Generated__c from Order where Id =: ROC.Order__c AND Id IN (Select OrderId from OrderItem where SBQQ__Status__c =: 'Activated' AND SBQQ__Activated__c = TRUE AND OrderId =: ROC.Order__c)])
                     {
                         if(!o.SBQQ__Contracted__c && !o.Contract_Generated__c)
                         {
                              //<SALESRT-13309>
                              //Update the Opportunity substage to Booked when RA is changed to Ready
                              if(ROC.Order__r.OpportunityId != null && ROC.Order__r.Opportunity != null &&
                                 ROC.Order__r.Opportunity.Substage__c != 'Booked' && !Label.RevisionLabel.equals(ROC.Order__r.Sub_Type__c)){
                                  oppList.add(new Opportunity(Id = ROC.Order__r.OpportunityId, Substage__c = 'Booked')); 
                             }
                             if(oppList.size() > 0){
                                 update oppList;
                             }
                                 orderIds.add(ROC.Order__c);
                             //update SOP fields in Order Products from Revenue Schedule
                               if(!isFulfillmentRevisionOrder)
                                 updateSOPWriteBack.processSOPWriteback(orderIds);
                             //</SALESRT-13309>
                             o.SBQQ__Contracted__c = TRUE;
                             orToConList.add(o);
                         }
                         else if(o.SBQQ__Contracted__c && !o.Contract_Generated__c) //<T03>
                         {
                             o.SBQQ__Contracted__c = FALSE;
                             orToConList.add(o);
                             retriggerIds.add(o.Id);
                         }
                     }
                     Database.SaveResult[] saveResult; 
                     if(orToConList.size() > 0)
                       saveResult = Database.update(orToConList);                     
                     
                     orToConList = new List<Order> ();
                     if(retriggerIds.size() > 0) //<T03>
                     {
                         for(Id oId : retriggerIds)
                             orToConList.add(new Order(Id = oId, SBQQ__Contracted__c = TRUE));
                         
                         if(orToConList.size() > 0)
                             update orToConList;
                     }  
                     //<T08> - Added logic to Revision Order Enable Downstream = Fulfillment in Winter '22 CPQ Upgrade
                     for(Database.SaveResult s : saveResult){
                         if(s.isSuccess() && isFulfillmentRevisionOrder){
                             delete ROC;
                             break;
                         }
                     }
                     //</T08>
                 }//</T01>
                 
                 //<T04> Added below logic to automate moving Order to Completed status based on condition.
                 if(ROC.Order__r.Status == 'Bill & Contract' && ROC.Order__r.Asset_Creation_Status__c == 'Completed'  && ROC.Order__r.Contract_Generated__c && ROC.Order__r.Plan_Products_Created__c && ((math.ABS(ROC.Order__r.blng__TotalBilling__c) > 0 && ROC.Order__r.TotalAmount != 0) || Math.ABS(ROC.Order__r.TotalAmount) <= ordAmtTol || Label.RevisionLabel.equals(ROC.Order__r.Sub_Type__c))) //I2C-1701 Added tolerance of 0.5 on Total Amount
                 {
                     List<Order> orToUpdate = new List<Order> ();
                     for(Order o : [Select Id,SBQQ__Contracted__c,Contract_Generated__c,Status,Asset_Creation_Status__c,Plan_Products_Created__c,Sub_Type__c from Order where Id =: ROC.Order__c])
                     {
                         if(o.Status == 'Bill & Contract')
                         {
                             o.status = 'Completed';
                             orToUpdate.add(o);
                         }
                         if(orToUpdate.size() > 0)
                             update orToUpdate;
                     }
                 }//</T04>
             }
             catch(Exception e)
             {                 
                 GAM.CreateExceptionRecords('Revenue Agreement Batch', e.getMessage(), 'error from revenueAgreementBatch');
             } 
         } 
      /*<T02>   if(delROCList.size() > 0)
             delete delROCList;  </T02>*/
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
    
       //<I2C-1939> To fetch the Revenue Schdules from an order
    public static List<blng__RevenueSchedule__c> fetchRevenueSchedules(Id orderId){
        
        List<blng__RevenueSchedule__c> RevSchList = new List<blng__RevenueSchedule__c> ();
         RevSchList = [Select Id,CurrencyIsoCode,Name,RS_Number__c,Revenue_Agreement__c,blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Product2Id,blng__OrderProduct__r.Quantity,
                               blng__TotalRevenueAmount__c,blng__LegalEntity__c,blng__OrderProduct__c,blng__RevenueDistributionMethod__c,blng__RevenueEndDate__c,
                               blng__RevenueFinanceBook__c,blng__RevenueRecognitionGLRule__c,blng__RevenueRecognitionGLTreatment__c,blng__RevenueRecognitionRule__c,
                               blng__RevenueRecognitionTreatment__c,blng__RevenueStartDate__c,blng__OrderProduct__r.SBQQ__RequiredBy__c,blng__OrderProduct__r.Ship_Date__c,Deferred_Revenue_Acct_Date__c,
                               Ship_Date__c,Allocated_Booking__c,Allocated_Bookings__c,Extended_List_Price__c,blng__OrderProduct__r.PeopleSoft_Extended_List_Price__c,blng__OrderProduct__r.OrderItemNumber,
                               blng__OrderProduct__r.Order.Provisioning_Complete_Date__c,Product__r.Provisionable_New__c,blng__OrderProduct__r.Product2.Provisionable_New__c,PSFT_Contract_Line__c,blng__OrderProduct__r.SBQQ__QuoteLine__c,
                               blng__OrderProduct__r.SBQQ__SubscriptionPricing__c,blng__OrderProduct__r.SBQQ__ContractAction__c,blng__OrderProduct__r.Product2.Product_Family__c,blng__OrderProduct__r.Product2.Forecast_Product__c,
                               blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c,blng__OrderProduct__r.Product2.Amoritization_Schedule__c, 
                               blng__OrderProduct__r.PricebookEntry.Pricebook2ID, ListRate__c,blng__OrderProduct__r.PricebookEntry.UnitPrice,blng__OrderProduct__r.Order.Source__c,  //<I2C-1611
                               blng__OrderProduct__r.product2.GTM_Model__c, blng__OrderProduct__r.Order.Type, blng__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.GTM_Model__c,blng__OrderProduct__r.product2.Product_Category__c, blng__OrderProduct__r.Order.Generate_Date__c, // <I2C-1841>
                               blng__OrderProduct__r.SBQQ__RequiredBy__r.Product2.Option_Scale__c, blng__OrderProduct__r.Product2.Option_Scale__c, blng__OrderProduct__r.TotalPrice, //I2C-1729
                               blng__OrderProduct__r.Order.OrderNumber, blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.Order.Related_Revenue_Orders__c,blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.OrderId,blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.Order.OrderNumber
                               from blng__RevenueSchedule__c where blng__OrderProduct__r.OrderId =: orderId];
        return RevSchList;
    }
    
    public static List<blng__RevenueSchedule__c> masterChildRS (List<blng__RevenueSchedule__c> RSList,Id RAId,Map<Id,Id> OIROI,Map<Id,Id> OIRS,String PSFTCN)
    {
        Map<Id,List<blng__RevenueSchedule__c>> prodRSListMap = new Map<Id,List<blng__RevenueSchedule__c>> ();
        Map<Id,List<SBQQ__ProductOption__c>> prodPOListMap = new Map<Id,List<SBQQ__ProductOption__c>> ();
        List<blng__RevenueSchedule__c> MCRSList = new List<blng__RevenueSchedule__c> ();
        //<I2C-1611> starts
        Set<String> currencyIDs = new Set<String>(); 
        Set<Id> productIDs = new Set<Id>();
        Map<Id, List<PricebookEntry>> pbeMap = new Map<Id, List<PricebookEntry>>();        
        List<ID> pricebookIDS = new List<ID>();
        ID Standard_Price_Book = Label.Standard_Price_Book ;
        pricebookIDS.add(Standard_Price_Book);
        //<I2C-1611> ends
         
                         for(blng__RevenueSchedule__c RS : RSList)
                         {
                             RS.Parent_RS__c = OIRS.get(OIROI.get(RS.blng__OrderProduct__c));
                             //<I2C-1611> starts
                             if(RS.CurrencyIsoCode!=null) 
                                 currencyIDs.add(RS.CurrencyIsoCode);
                             if(RS.blng__OrderProduct__r.PricebookEntry.Pricebook2ID!=null) 
                                 pricebookIDs.add(RS.blng__OrderProduct__r.PricebookEntry.Pricebook2ID);
                             //<I2C-1611> ends
                             if(prodRSListMap.get(RS.blng__OrderProduct__r.Product2Id) == null)
                                 prodRSListMap.put(RS.blng__OrderProduct__r.Product2Id,new List<blng__RevenueSchedule__c> {RS});
                             else
                                 prodRSListMap.get(RS.blng__OrderProduct__r.Product2Id).add(RS);                            
                         }
                         
                         for(SBQQ__ProductOption__c PO : [Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,Percentage_Allocation__c,SBQQ__OptionalSKU__r.Amoritization_Schedule__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c =: prodRSListMap.keyset() AND Is_Child__c = TRUE AND Percentage_Allocation__c != null])
                         {
                             //<I2C-1611> starts
                             if(PO.SBQQ__OptionalSKU__c!=null) 
                                 productIDs.add(PO.SBQQ__OptionalSKU__c);
                             //<I2C-1611> ends
                             if(prodPOListMap.get(PO.SBQQ__ConfiguredSKU__c) == null)
                                 prodPOListMap.put(PO.SBQQ__ConfiguredSKU__c,new List<SBQQ__ProductOption__c> {PO});
                             else
                                 prodPOListMap.get(PO.SBQQ__ConfiguredSKU__c).add(PO);                             
                         }
                        //get pricebook //<I2C-1611>
                         for(PricebookEntry pbe : [select id , Product2Id , CurrencyIsoCode , UnitPrice, Pricebook2Id from PricebookEntry where  Product2Id in : productIDs and Pricebook2Id in : pricebookIDs  and CurrencyIsoCode in : currencyIDs])
                         {
                             if(pbeMap.containskey(pbe.Product2Id))                            
                                 pbeMap.get(pbe.Product2Id).add(pbe);                                                             
                             else                             
                             {
                                 list<PricebookEntry> pbelist =  new List<PricebookEntry>();  
                                 pbelist.add(pbe);
                                 pbeMap.put(pbe.Product2Id, pbelist);     
                             }                                                    
                         } //<I2C-1611>
        
                         for(Id prodId : prodPOListMap.keyset())
                         {
                             for(blng__RevenueSchedule__c RS : prodRSListMap.get(prodId))
                             {
                                 integer i = 0;
                                 for(SBQQ__ProductOption__c PO : prodPOListMap.get(prodId))
                                 {
                                     i = i + 1;
                                     blng__RevenueSchedule__c RSChild = RS.clone();
                                     //RSChild.Id = null;
                                     RSChild.blng__OrderProduct__c = null;
                                     RSChild.blng__TotalRevenueAmount__c = 0;
                                     RSChild.Percentage_Allocation__c = PO.Percentage_Allocation__c;
                                     RSChild.Product__c = PO.SBQQ__OptionalSKU__c;
                                     RSChild.Quantity__c = RS.blng__OrderProduct__r.Quantity;
                                     RSChild.Revenue_Agreement__c = RAId;
                                     // <T07> RSChild.Ship_Date__c = RS.blng__OrderProduct__r.Product2.Provisionable_New__c ? RS.blng__OrderProduct__r.Ship_Date__c : null;
                                     RSChild.Deferred_Revenue_Acct_Date__c = RS.Deferred_Revenue_Acct_Date__c;
                                     RSChild.Parent_RS__c = RS.Id;
                                     //RSChild.RS_Number__c = (RS.Name).subString(3) + '-' + i ; <I2C-1446> - Commented this line
                                     RSChild.RS_Number__c = (RS.Name).subString(3) + '-' + String.valueOf(i).leftPad(3,'0'); //<I2C-1446> - Added to get the RS Number in 3 digits as 001,101,100...
                                     RSChild.PSFT_Contract_Line__c = PSFTCN != null && PSFTCN != 'NEW_RENEWAL'? RSChild.RS_Number__c : RS.PSFT_Contract_Line__c;
                                     RSChild.Extended_List_Price__c = null;
                                     RSChild.Revenue_Category__c = PO.SBQQ__OptionalSKU__r?.Amoritization_Schedule__c; //I2C-1497
                                     //<I2C-1611> starts- To populate list rate
                                     RSChild.ListRate__c = null;
                                     if(pbeMap.containskey(PO.SBQQ__OptionalSKU__c)){
                                           for(PricebookEntry pbe:pbeMap.get(PO.SBQQ__OptionalSKU__c))
                                      {                                                                              
                                           if(pbe.Pricebook2Id ==  RS.blng__OrderProduct__r.PricebookEntry.Pricebook2ID)
                                           {
                                               RSChild.ListRate__c = pbe?.UnitPrice;     
                                           }
                                           else if (pbe.Pricebook2Id ==  pricebookIDS[0] && 
                                                    RSChild.ListRate__c == null )
                                           {
                                               RSChild.ListRate__c = pbe?.UnitPrice;  
                                           }    
                                        
                                      }//<I2C-1611> ends
                                     }
                                                                         
                                     MCRSList.add(RSChild);
                                 }
                             }
                         }
                         
      return MCRSList;                   
    }
    
    /*
    <T05>
    The method recalcPOTSuport() calculates, sum and split +ve amount and -ve amount of POT Support lines of Amendment Order 
    and create another RS to have one RS for +ve amount and other for -ve amount. This is needed for Allocation Integration.
    */
    public static List<blng__RevenueSchedule__c> recalcPOTSuport(List<blng__RevenueSchedule__c> RSList,Map<Id,Id> OPQLSet)
    {
        List<blng__RevenueSchedule__c> newPOTRS = new List<blng__RevenueSchedule__c> ();
        Map<Id,Decimal> positiveMap = new Map<Id,Decimal> ();
        Map<Id,Decimal> negativeMap = new Map<Id,Decimal> ();
        Set<String> POTQLSet = new Set<String> ();
        Map<Id,SBQQ__SubscribedQuoteLine__c> subPOTMap = new Map<Id,SBQQ__SubscribedQuoteLine__c> ();
        
        system.debug('OPQLSet:'+OPQLSet);  
        for(SBQQ__SubscribedQuoteLine__c subQL: [Select Id,SBQQ__AssetQuoteLine__c,SBQQ__SubscriptionQuoteLine__c, SBQQ__SubscriptionBasePrice__c, SBQQ__AssetQuoteLineQuantity__c,
        SBQQ__AssetQuoteLine__r.SBQQ__NetTotal__c, SBQQ__SubscriptionNetTotal__c,SBQQ__SubscriptionQuoteLine__r.SBQQ__SubscriptionPercent__c,SBQQ__SubscriptionQuoteLine__r.SBQQ__Discount__c from SBQQ__SubscribedQuoteLine__c where SBQQ__SubscriptionQuoteLine__c =: OPQLSet.values() ORDER BY SBQQ__SubscriptionQuoteLine__c, CreatedDate ASC])
        {
            system.debug('subQL:'+subQL);
            String POQLIdentifier = String.valueOf(subQL.SBQQ__AssetQuoteLine__c) + ';' + String.valueOf(subQL.SBQQ__SubscriptionQuoteLine__c);
            system.debug('POQLIdentifier:'+POQLIdentifier);
            if(!POTQLSet.contains(POQLIdentifier))
            {
                system.debug('inside if POQLIdentifier');
                POTQLSet.add(POQLIdentifier);
                subPOTMap.put(subQL.SBQQ__SubscriptionQuoteLine__c,subQL);
                //If QTY is > 0, then it is Increase of QTY or addition of new line in existing bundle
                if(subQL.SBQQ__AssetQuoteLineQuantity__c > 0)
                {
                    if(positiveMap.get(subQL.SBQQ__SubscriptionQuoteLine__c) != null)
                        positiveMap.put(subQL.SBQQ__SubscriptionQuoteLine__c , positiveMap.get(subQL.SBQQ__SubscriptionQuoteLine__c) + (subQL.SBQQ__SubscriptionBasePrice__c * subQL.SBQQ__AssetQuoteLineQuantity__c));
                    else
                        positiveMap.put(subQL.SBQQ__SubscriptionQuoteLine__c , (subQL.SBQQ__SubscriptionBasePrice__c * subQL.SBQQ__AssetQuoteLineQuantity__c));
                
                }
                system.debug('subQL.SBQQ__AssetQuoteLineQuantity__c:'+subQL.SBQQ__AssetQuoteLineQuantity__c);
                //If QTY is < 0, then it is Decrease of QTY or Cancellation of line
                if(subQL.SBQQ__AssetQuoteLineQuantity__c < 0)
                {
                    if(negativeMap.get(subQL.SBQQ__SubscriptionQuoteLine__c) != null)
                        negativeMap.put(subQL.SBQQ__SubscriptionQuoteLine__c , negativeMap.get(subQL.SBQQ__SubscriptionQuoteLine__c) + (subQL.SBQQ__SubscriptionBasePrice__c * subQL.SBQQ__AssetQuoteLineQuantity__c));
                    else
                        negativeMap.put(subQL.SBQQ__SubscriptionQuoteLine__c , (subQL.SBQQ__SubscriptionBasePrice__c * subQL.SBQQ__AssetQuoteLineQuantity__c));
                }
            }
        }
        system.debug('positiveMap:'+positiveMap);
        // Iterate through RSList and split the +ve and -ve amount into two different RS.
            for(blng__RevenueSchedule__c RS : RSList)
            {
                if(OPQLSet.get(RS.blng__OrderProduct__c) != null)
                {
                        Id qlId = OPQLSet.get(RS.blng__OrderProduct__c);
        system.debug('RS.blng__OrderProduct__c:'+RS.blng__OrderProduct__c);            
        system.debug('qlId:'+qlId);
                    system.debug('positiveMap.get(qlId):'+positiveMap.get(qlId));
                        if(positiveMap.get(qlId) != null && negativeMap.get(qlId) != null)
                        {
                            if(RS.blng__TotalRevenueAmount__c >= 0)
                                RS.blng__TotalRevenueAmount__c = positiveMap.get(qlId);
                            else if(RS.blng__TotalRevenueAmount__c < 0)
                                RS.blng__TotalRevenueAmount__c = negativeMap.get(qlId);
                            
                            
                                     blng__RevenueSchedule__c RSChild = RS.clone();
                                     RSChild.blng__TotalRevenueAmount__c = RS.blng__TotalRevenueAmount__c >= 0 ? negativeMap.get(qlId) : positiveMap.get(qlId);
                                     RSChild.Parent_RS__c = RS.Id;
                                     RSChild.RS_Number__c = (RS.Name).subString(3) + '-1';
                                     
                                     //<T06> I2C-1230 Updating quantity as per amount
                                     RSChild.Quantity__c = RSChild.blng__TotalRevenueAmount__c >= 0 ? 1 : -1;
                                     RS.Quantity__c = RS.blng__TotalRevenueAmount__c >= 0 ? 1 : -1;
                                     
                                     
                             RS.blng__TotalRevenueAmount__c = RS.blng__TotalRevenueAmount__c * subPOTMap.get(qlId).SBQQ__SubscriptionQuoteLine__r.SBQQ__SubscriptionPercent__c/100;
                             RSChild.blng__TotalRevenueAmount__c = RSChild.blng__TotalRevenueAmount__c * subPOTMap.get(qlId).SBQQ__SubscriptionQuoteLine__r.SBQQ__SubscriptionPercent__c/100;
                             
                            if(subPOTMap.get(qlId) != null && subPOTMap.get(qlId).SBQQ__SubscriptionQuoteLine__r.SBQQ__Discount__c != null) // In Amendment we have discount only as % and not amount. So checking only for Discount % and then applying it to calculated amount
                            {
                                RS.blng__TotalRevenueAmount__c = RS.blng__TotalRevenueAmount__c - (RS.blng__TotalRevenueAmount__c * subPOTMap.get(qlId).SBQQ__SubscriptionQuoteLine__r.SBQQ__Discount__c/100);
                                
                                RSChild.blng__TotalRevenueAmount__c = RSChild.blng__TotalRevenueAmount__c - (RSChild.blng__TotalRevenueAmount__c * subPOTMap.get(qlId).SBQQ__SubscriptionQuoteLine__r.SBQQ__Discount__c/100);
                            }
                                   
                                     newPOTRS.add(RSChild); 
                        }
                    
                }
            }
        
        
        return newPOTRS;
    }
    
    /*
    <I2C-1497>
    The method updateRevenueCategory() fetches Revenue Category from Original Lines to update on Amended Lines for Amendment Order.
    The Amended lines should fall into same Revenue Category for Revenue Allocation.
    */
    public static void updateRevenueCategory(Set<Id> processOrgRevCat,List<blng__RevenueSchedule__c> RSList)
    {
        Map<Id,String> originalRevCat = new Map<Id,String> ();
        
        for(blng__RevenueSchedule__c RS : [Select Id,blng__OrderProduct__c, Revenue_Category__c from blng__RevenueSchedule__c where blng__OrderProduct__c = : processOrgRevCat])
        {
            originalRevCat.put(RS.blng__OrderProduct__c,RS.Revenue_Category__c);
        }
        
        if(!originalRevCat.isEmpty() && originalRevCat != null)
        {
            for(blng__RevenueSchedule__c RS : RSList)
            {
                if(RS.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c != null && originalRevCat.get(RS.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c) != null)
                    RS.Revenue_Category__c = originalRevCat.get(RS.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c);
            }
        }
    }
    
     //I2C-1939 
     @InvocableMethod(label='update RelatedRevOrder')
     public static void updateOrder(List<Id> orderIds){
     List<blng__RevenueSchedule__c> RSList = new List<blng__RevenueSchedule__c> ();
        RSList = fetchRevenueSchedules(orderIds[0]);        
        updateRelatedRevOrder(RSList);
    }
    
    /*<I2C-1729>
    */
    public static void updateRelatedRevOrder(List<blng__RevenueSchedule__c> RSList)
    {
        Set<id> revisedOpSet = new Set<id>(); //Set containing revised orderProducts of negative orderItems
        Id orderIdAddOn;
        String relatedRevenueOrderAddon;
        Id orderIdNegativeQTY;
        String relatedRevenueOrderSingleRMCS;
        String relatedRevenueOrderSingleOrder; //<T09>
        List<Order> orderList = new List<Order>();
        Map<String,String> RMCSContract_RRO_Map = new Map<String,String> ();
        Map<String,Related_Order_and_Contract__c> orderRROMap = new Map<String,Related_Order_and_Contract__c> ();
        Set<Id> revisedOrderSet = new Set<Id> ();
        Set<String> revisedOrderNumber = new Set<String> ();
        Integer oldOrgOrderCount = 0;
        String oldOrgOrder;
        String oldOrder;
        Map<Id,Order> orderMapToUpdate = new Map<Id,Order> ();
        Set<Id> revAgreementSet = new Set<Id>();
        
        for(blng__RevenueSchedule__c RS : RSList)
        {
            
               if(rs.blng__OrderProduct__r.Quantity < 0 && rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c != NULL) // Swap Or Cancellation or Partial Cancellation or Full Debook
               {
                   if(rs.blng__OrderProduct__r.Product2.Option_Scale__c != 'Credit' && rs.blng__OrderProduct__r.SBQQ__RequiredBy__r?.Product2.Option_Scale__c != 'Credit') // Ignore all Credit SKU
                   {
                       revisedOpSet.add(rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__c); 
                       revAgreementSet.add(rs.Revenue_Agreement__c);
                       orderIdNegativeQTY = rs.blng__OrderProduct__r.OrderId;
                       revisedOrderSet.add(rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.OrderId);
                       relatedRevenueOrderSingleOrder = Integer.valueOf(rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.Order.OrderNumber) + '';
                       revisedOrderNumber.add(Integer.valueOf(rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.Order.OrderNumber) + '');
                       revisedOrderNumber.add(Integer.valueOf(rs.blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.Order.Related_Revenue_Orders__c) + '');
                   }
               }
               else if(rs.blng__OrderProduct__r.Quantity > 0) // Increase in QTY or Add new Line in AMendment 
               {
                    orderIdAddOn = rs.blng__OrderProduct__r.OrderId;
                    relatedRevenueOrderAddon = Integer.valueOf(rs.blng__OrderProduct__r.Order.OrderNumber) + '';
               }
             
        }

        if(revisedOpSet.isEmpty()) // If there is no Swap or Cancellation, then it is Upsell or Add-On. So populate RRO with Order Number
        {
            orderMapToUpdate.put(orderIdAddOn , new Order(Id = orderIdAddOn, Related_Revenue_Orders__c = relatedRevenueOrderAddon));
        }
        else // If there is Swap or Cancellation
        {
            //Commented as part of I2C-1939 <T09>
            // Query all Revenue Schedules of Revised Order Product to check whether it is single RMCS or multiple RMCS Swap
          /*  for(blng__RevenueSchedule__c revisedRS : [select blng__OrderProduct__r.SBQQ__RevisedOrderProduct__r.OrderId, RMCS_Contract_Number__c, blng__OrderProduct__c, blng__OrderProduct__r.OrderId,blng__OrderProduct__r.Order.OrderNumber,blng__OrderProduct__r.Order.Related_Revenue_Orders__c from blng__RevenueSchedule__c where blng__OrderProduct__c IN :revisedOpSet AND RMCS_Contract_Number__c != NULL AND Revenue_Agreement__c != NULL])
            {
                RMCSContract_RRO_Map.put(revisedRS.RMCS_Contract_Number__c,revisedRS.blng__OrderProduct__r.Order.Related_Revenue_Orders__c);
                relatedRevenueOrderSingleRMCS = revisedRS.blng__OrderProduct__r.Order.Related_Revenue_Orders__c;
            }
            
            if(!RMCSContract_RRO_Map.isEmpty() && RMCSContract_RRO_Map.keySet().size() == 1) // If all RS of Revised Product is of Single RMCS Contract
            {
                orderMapToUpdate.put(orderIdNegativeQTY , new Order(Id = orderIdNegativeQTY, Related_Revenue_Orders__c = relatedRevenueOrderSingleRMCS));
            }
            else if(!RMCSContract_RRO_Map.isEmpty() && RMCSContract_RRO_Map.keySet().size() > 1) // If all RS of Revised Product is from multiple RMCS Contract
            {*/

            // Query all Revenue Schedules of Revised Order Product to check whether it is Single Contract or Multi Contract Swap
            
            // I2C -1939             
            if(!revisedOrderSet.isEmpty() && revisedOrderSet.size() == 1)
            {     
                orderMapToUpdate.put(orderIdNegativeQTY , new Order(Id = orderIdNegativeQTY, Related_Revenue_Orders__c = relatedRevenueOrderSingleOrder));
            }
            else if(!revisedOrderSet.isEmpty() && revisedOrderSet.size() > 1)  // I2C -1939 Ends
            {
                for(Related_Order_and_Contract__c ROC : [Select Id,Order__c,Order__r.OrderNumber,  Order__r.Type, Order__r.Related_Revenue_Orders__c,Revenue_Agreement__c from Related_Order_and_Contract__c Where Revenue_Agreement__c =: revAgreementSet])
                {
                    orderRROMap.put(ROC.Order__c,ROC);
                }
                for(Id revOrderId : revisedOrderSet)
                {
                    if(!orderRROMap.isEmpty() && orderRROMap.get(revOrderId) != null && orderRROMap.get(revOrderId).Order__r.Related_Revenue_Orders__c != null)
                    {
                        if(orderRROMap.get(revOrderId).Order__r?.Related_Revenue_Orders__c?.trim().isNumeric()) // For New Org Orders, store MINIMUM Order Number in OldOrder String
                        {
                            if(oldOrder == null)
                                oldOrder = orderRROMap.get(revOrderId).Order__r?.Related_Revenue_Orders__c?.trim();
                            else{
                                oldOrder = Integer.valueOf(oldOrder) > Integer.valueOf(orderRROMap.get(revOrderId).Order__r?.Related_Revenue_Orders__c?.trim()) ? orderRROMap.get(revOrderId).Order__r?.Related_Revenue_Orders__c?.trim() : oldOrder;
                            } 
                        }
                        else // For Old Org Orders that starts with "ORD" 
                        {
                            oldOrgOrder = orderRROMap.get(revOrderId).Order__r?.Related_Revenue_Orders__c;
                            oldOrgOrderCount = + 1;
                        }
                        
                    }
                }
                
                if(oldOrgOrderCount == 1){ // If there is only one Old Org Order from the Revised Order Product, then use the same
                    orderMapToUpdate.put(orderIdNegativeQTY , new Order(Id = orderIdNegativeQTY, Related_Revenue_Orders__c = oldOrgOrder));
                    oldOrder = oldOrgOrder;
                }
                else if(oldOrgOrderCount < 1){ // If there is no Old Org Order from the Revised Order Product, then use the Minimum Order
                    orderMapToUpdate.put(orderIdNegativeQTY , new Order(Id = orderIdNegativeQTY, Related_Revenue_Orders__c = oldOrder));
                }
                for(Related_Order_and_Contract__c ROC : orderRROMap.values()) // Iterate through ROC object and find orders that get affected and update
                {
                    if(revisedOrderSet.contains(ROC.Order__c) && ROC.Order__r.Related_Revenue_Orders__c?.trim() != oldOrder){
                        orderMapToUpdate.put(ROC.Order__c , new Order(Id = ROC.Order__c, Related_Revenue_Orders__c = oldOrder));
                    }
                    if(ROC.Order__r.Related_Revenue_Orders__c?.trim().isNumeric() != null && ROC.Order__c != orderIdNegativeQTY)
                    {
                        if(revisedOrderNumber.contains(Integer.valueOf(ROC.Order__r.Related_Revenue_Orders__c?.trim()) + '') && ROC.Order__r.Related_Revenue_Orders__c?.trim() != oldOrder)
                            orderMapToUpdate.put(ROC.Order__c , new Order(Id = ROC.Order__c, Related_Revenue_Orders__c = oldOrder));
                    }
                }
                
            }
        }
        
        
        try{
            SBQQ.TriggerControl.disable();
            globalApexManager.avoidRecursion('OrderBeforeUpdate');
            globalApexManager.avoidRecursion('OrderAfterUpdate');
            
            update orderMapToUpdate.values();
            SBQQ.TriggerControl.enable();
            
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('Revenue Agreement Batch', ex.getMessage(), 'error from revenueAgreementBatch.updateRelatedRevOrder');
        }
    
        
      
        
      
    }
    
 
    
    
    /*I2C-1939 
     public class Requests {
    @InvocableVariable(label='RevenueSchedule Records for Input' required=true)
    public List<blng__RevenueSchedule__c> RSRecords;
             }*/
}