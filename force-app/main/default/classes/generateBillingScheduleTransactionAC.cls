/****************************************************************************************************************************
 *  @Class Name: generateBillingScheduleTransactionAC
 *  @Author: Ramesh M S
 *  @Date: 12 Mar 2020
 *  @Description: Class to process Custom Invoicing. This is utilized by quick action "Custom Invoicing" on Order. 
 *****************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                Date              Requested By              Description                                                      Tag   
 
 Ramesh M S                12 Mar 2020       SALESRT-11712             This class is utlized by "Custom Invoicing" button on Order
                                                                       to create/cancel Billing Schedule and Billing Transaction
                                                                       for Billing Frequency = Invoice Plan.
 RamEsh M S                13 AUG 2020       I2C-726                   Changing the stage check from "Activated" to "Bill & Contract"
                                                                       to create Billing Schedule and Billing Transactions              <T01>  
 RamEsh M S                10-NOV-2020       I2C-1095                  Allow custom billing in "Completed" status after cancelling First Invoice <T02>     
 RamEsh M S                17-DEC-2020       SALESRT-12351             Cancel Pending Transactions and Rebill using updated Bill Plans     <T03>  
 RamEsh M S                19-MAR-2021       SALESRT-12946             Moving from Aggregate to For loop as Currency field is truncated to two decimals for SUM() <T04>   
 RamEsh M S                26-APR-2021       I2C-1220                  Add a tolerance of 1$ diff(where Order Amount - Sum of Bill Plan Amount <= 1) so that the decimal difference which cannot be seen in UI can be ignored.   <T05>    
Nishit S          23-DEC-2021    I2C-1388          Multi-year Term Invoices, reformatting Invoice lines      <I2C-1388>
Nishit S          2-MAR-2021    I2C-1532          Revert I2C-1388-Multi-year Term Invoices,             <I2C-1532>
                                    reformatting Invoice lines code changes      
 ****************************************************************************************************************************/
public class generateBillingScheduleTransactionAC
{
    public static globalApexManager GAM = new globalApexManager();
   
    
    @AuraEnabled
    public static String onLoadCmp(Id orderId)
    {
        system.debug(orderId);
        Decimal totalPercentage = 0;
        Decimal totalOrderAmount = 0;
        Decimal calculatedTotalAmount = 0;
        Decimal partialOrderAmount = 0;
        Decimal OrderAmount = 0;
        boolean invSchd = false;
        String messageOnLoad = null;
        boolean InvPlan = false;
        boolean partialORD = false;
        String ordCurrency;
        
        for(Invoice_Schedule__c InvSch :[SELECT Bill_Percentage__c,Bill_Amount__c,Calculated_Bill_Amount__c,Calculated_Bill_Percentage__c,CurrencyIsoCode,Id,Invoice_Date__c,Name,Order_Product__c,Order__c,Partial_Order__c FROM Invoice_Schedule__c where Order__c = :orderID])
        {
            if(InvSch.Bill_Percentage__c != null)
            {
                totalPercentage = totalPercentage + InvSch.Bill_Percentage__c;
                if(!InvSch.Partial_Order__c)
                    calculatedTotalAmount = calculatedTotalAmount  + InvSch.Calculated_Bill_Amount__c;
                else
                    partialORD = true;
            }
            else
                totalOrderAmount = totalOrderAmount + InvSch.Bill_Amount__c;
                
            invSchd = true;
        }
        
        
        for(OrderItem oi : [Select Id,OrderItemNumber,CurrencyIsoCode,TotalPrice,SBQQ__OrderProductBookings__c,OrderId,Order.OrderNumber,Order.SBQQ__OrderBookings__c,Order.TotalAmount,Order.SBQQ__Quote__r.SBQQ__BillingFrequency__c,SBQQ__ChargeType__c,SBQQ__BillingFrequency__c,blng__BillingTreatment__r.blng__InvoicePlan__c,blng__BillingTreatment__r.blng__CancellationInvoicePlan__c from OrderItem where SBQQ__BillingFrequency__c =: 'Invoice Plan' AND OrderId =: orderId])
        {
            InvPlan = true;
            OrderAmount = oi.Order.TotalAmount;
            ordCurrency = oi.CurrencyIsoCode;
            partialOrderAmount = partialOrderAmount + oi.TotalPrice;//.setScale(2, RoundingMode.HALF_UP);
        }
        
        partialOrderAmount = partialOrderAmount;//.setScale(2,RoundingMode.HALF_UP);<T05>
        calculatedTotalAmount = calculatedTotalAmount;//.setScale(2,RoundingMode.HALF_UP);<T05>
        
        //system.debug('TotalOrderAmount : ' + totalOrderAmount);
        //system.debug('PartialOrderAmount : ' + partialOrderAmount);
        
        //system.debug('Order TOtal Amount is : ' + OrderAmount);
        //system.debug('Order Total Amount afetr round off : ' + OrderAmount.setScale(2, RoundingMode.HALF_UP));
        
        if(!invSchd)
        {
            messageOnLoad = Label.NoInvSch;
        }
        
        
        if(totalPercentage != 0 && ((partialOrderAmount - calculatedTotalAmount) < 0 || (partialOrderAmount - calculatedTotalAmount) > 1) && !partialORD) //ord.TotalAmount.setScale(2, RoundingMode.HALF_UP)) //<T05>
        {
            messageOnLoad = Label.BillPlanCalAmt;
            messageOnLoad = messageOnLoad  + '<br/>' + '<br/>' + '<b>Order Amount : ' + partialOrderAmount + '<br/>' + 'Calculated Amount : ' + calculatedTotalAmount + '</b>';
        }
        
        if(totalOrderAmount != 0 && totalOrderAmount > 0 && partialOrderAmount > 0 && (totalOrderAmount - partialOrderAmount > 0 || (ordCurrency != 'JPY' && ordCurrency != 'KRW' && partialOrderAmount - totalOrderAmount > 0.1) || ((ordCurrency == 'JPY' || ordCurrency == 'KRW') && partialOrderAmount - totalOrderAmount > 1))) //ord.TotalAmount.setScale(2, RoundingMode.HALF_UP)) //<T05>
        {
            messageOnLoad = Label.InvSchBillAmountnot100;
            messageOnLoad = messageOnLoad + '<br/>' + '<br/>' + '<b>Order Amount : ' + partialOrderAmount  + '<br/>' + 'Sum of Bill Plans Bill Amount : ' + totalOrderAmount + '</b>'; 
        }
        
         if(totalOrderAmount != 0 && totalOrderAmount < 0 && partialOrderAmount < 0 && ( partialOrderAmount - totalOrderAmount> 0 || (ordCurrency != 'JPY' && ordCurrency != 'KRW' && Math.ABS(partialOrderAmount - totalOrderAmount)  > 0.1) || ((ordCurrency == 'JPY' || ordCurrency == 'KRW') && Math.ABS(partialOrderAmount - totalOrderAmount) > 1))) //ord.TotalAmount.setScale(2, RoundingMode.HALF_UP)) //<T05>
        {
            messageOnLoad = Label.InvSchBillAmountnot100;
            messageOnLoad = messageOnLoad + '<br/>' + '<br/>' + '<b>Order Amount : ' + partialOrderAmount  + '<br/>' + 'Sum of Bill Plans Bill Amount : ' + totalOrderAmount + '</b>'; 
        }
        
        if(totalOrderAmount != 0 && totalPercentage != 0)
        {
            messageOnLoad = Label.BillPlanPercentageAmount;
        }
        
        if(totalPercentage != 0 && totalPercentage > 100)
        {
            messageOnLoad = Label.InvSchBillPer100;
        }
        
        if(totalPercentage != 0 && totalPercentage < 100 && totalPercentage > 0)
        {
            messageOnLoad = Label.InvSchBillPernot100;
        }
        
       
        if(!InvPlan)
        {
            messageOnLoad = Label.CustomInvoicingBF;
        }
        
        if(!FeatureManagement.checkPermission('CustomInvoicingCreate'))
        {
            messageOnLoad = Label.CustomInvoicingPermissions;
        }
        
        
        return messageOnLoad;
    }
    
    public static string createMessage(Id OrderId)
    {
        List<blng__BillingSchedule__c> billingScheduleList = new List<blng__BillingSchedule__c>();
        List<blng__BillingTransaction__c> billingTransactionList = new List<blng__BillingTransaction__c> ();
        List<Invoice_Schedule__c> BPList = new List<Invoice_Schedule__c> ();
        string messageCreate = null;
        //billingTransactionList = [Select Id from blng__BillingTransaction__c where Order_LKP__c =: orderId AND blng__OverrideStatus__c = null AND blng__Status__c != null AND blng__Status__c != 'Cancelled'];
        BPList = [Select Id from Invoice_Schedule__c where Id NOT IN (Select Invoice_Schedule__c from blng__BillingTransaction__c where Order_LKP__c =: orderId AND blng__OverrideStatus__c = null AND blng__Status__c != null AND blng__Status__c != 'Cancelled')];
        
        Order ord = new Order ();
        ord = [Select Id,Status from Order where Id=: orderId];
        
        if(BPList.size() <= 0)
        {
            messageCreate = Label.BSBTCreated;
        }
        
        if(ord.Status != 'Bill & Contract' && ord.Status != 'Completed') //<T01> //<T02>
        {
            messageCreate = Label.OrdNotAct;
        }
        return messageCreate;
    }
    
    public static string cancelMessage(Id OrderId)
    {
        
        List<blng__BillingTransaction__c> billingTransactionList = new List<blng__BillingTransaction__c> ();
        string messageCancel = null;
        billingTransactionList = [Select Id from blng__BillingTransaction__c where Order_LKP__c =: orderId AND blng__OverrideStatus__c != 'Cancelled' AND blng__Status__c =: 'Pending'];
        
        if(billingTransactionList.size() == 0)
        {
            messageCancel = Label.BSBTCancelled;
        }
        return messageCancel;
    }
    
    
    @AuraEnabled
    public static String createBillingScheduleTransaction(Id orderId,String type)
    {
        
        List<blng__BillingSchedule__c> billingScheduleList = new List<blng__BillingSchedule__c>();
        List<blng__BillingTransaction__c> billingTransactionList = new List<blng__BillingTransaction__c> ();
        List<Invoice_Schedule__c> BillPlanList = new List<Invoice_Schedule__c> ();
        Map<Id,Decimal> bTSumBP = new Map<Id,Decimal> ();
        Map<Id,List<blng__BillingTransaction__c>> bTSumBPListMap = new Map<Id,List<blng__BillingTransaction__c>> ();
        Map<Id,Invoice_Schedule__c> BPMap = new Map<Id,Invoice_Schedule__c> ();
        Map<Id,OrderItem> OrderItemMap = new Map<Id,OrderItem> ();
        Map<Id,Decimal> BTSumEx = new Map<Id,Decimal> (); 
        Set<Id> BSExIds = new Set<Id> ();
        Id blngBSOPId;
        Id BPId;
        String message = null;
        integer counter = 0;
        Decimal OPAmtFinal = 0;
        Decimal TotalBSAmt = 0;
        Decimal blngBSOPAmt;
        boolean correction = Boolean.valueOf(Label.BillAmountCorrection);
        
            delete [Select Id from blng__BillingSchedule__c where Order_LKP__c =: orderId AND (blng__Status__c =: 'Cancelled' OR (blng__NumberOfBilledBillingTransactions__c = 0 AND blng__NumberOfCanceledBillingTransactions__c > 0))];
            
            if(type == 'New')
                message = createMessage(orderId);
            
            if(message != null)
                return message;
            
            
            for(blng__BillingSchedule__c BS : [Select blng__OrderProduct__c ,Id from blng__BillingSchedule__c where Order_LKP__c =: orderId])
                BSExIds.add(BS.blng__OrderProduct__c);
            
            
            for(OrderItem oi : [Select Id,OrderItemNumber,CurrencyIsoCode,TotalPrice,Quantity,ServiceDate,EndDate,SBQQ__OrderProductBookings__c,OrderId,Order.OrderNumber,SBQQ__ChargeType__c,SBQQ__BillingFrequency__c,blng__BillingTreatment__r.blng__InvoicePlan__c,blng__BillingTreatment__r.blng__CancellationInvoicePlan__c, Product2.Option_Scale__c, Product2.Business_Unit__c from OrderItem where SBQQ__BillingFrequency__c =: 'Invoice Plan'  AND OrderId =: orderId])
            {
                blng__BillingSchedule__c blngBS = new blng__BillingSchedule__c ();
                
                //Added blank check for product attributes
                if(oi.SBQQ__BillingFrequency__c == 'Invoice Plan' && BSExIds != null && !BSExIds.contains(oi.Id))
                {
                    blngBS.Name = 'BS-' + oi.Order.OrderNumber + '-' + oi.OrderItemNumber ;
                    blngBS.blng__Amount__c = oi.TotalPrice;
                    blngBS.blng__InvoicePlan__c = oi.blng__BillingTreatment__r.blng__InvoicePlan__c;
                    blngBS.Order_LKP__c = oi.OrderId;
                    blngBS.blng__OrderProduct__c = oi.Id;
                    blngBS.CurrencyIsoCode = oi.CurrencyIsoCode;
                    billingScheduleList.add(blngBS);
                    //TotalBSAmt = TotalBSAmt + oi.TotalPrice;
                    system.debug(blngBS);
                }
                
                TotalBSAmt = TotalBSAmt + oi.TotalPrice;
                OrderItemMap.put(oi.Id,oi);
            }
            
            //TotalBSAmt = TotalBSAmt.setScale(2,RoundingMode.HALF_UP);<T05>
      

            try
            {
                if(billingScheduleList.size() > 0)
                {
                    insert billingScheduleList;
                    
                 }
           
            }
            catch(exception e)
            {
                
                GAM.CreateExceptionRecords('generateBillingSchedule -->', e.getMessage(), '-->'+'error from Billing Schedule creation for' + orderId);
                throw new AuraHandledException(e.getMessage());
            }
       
        
        if(type == 'New')
        {
            billingScheduleList = [Select Id,Name,blng__Amount__c,blng__InvoicePlan__c,Order_LKP__c,blng__OrderProduct__c,CurrencyIsoCode from blng__BillingSchedule__c where Order_LKP__c =: orderId];
            
            /*<T04> SUM(blng__Amount__c) truncates to two decimals and causing error "Total amount for billing transactions exceeds billing schedule total. Enter a lower number or cancel this transaction: []" 
            for(AggregateResult res : [SELECT SUM(blng__Amount__c ) sumofT, Order_Product__c opId FROM blng__BillingTransaction__c WHERE Order_LKP__c =: orderId AND blng__OverrideStatus__c = null AND blng__Status__c != null AND blng__Status__c != 'Cancelled' GROUP BY Order_Product__c])
            {
                Decimal sumofT = Double.ValueOf(res.get('sumofT'));
                String opId = String.ValueOf(res.get('opId'));   
                BTSumEx.put(opId,sumofT);
                
            }*/
            
            for(blng__BillingTransaction__c BT : [SELECT blng__Amount__c, Order_Product__c FROM blng__BillingTransaction__c WHERE Order_LKP__c =: orderId AND blng__OverrideStatus__c = null AND blng__Status__c != null AND blng__Status__c != 'Cancelled' ORDER BY Order_Product__c ASC])
            {
                if(BTSumEx.get(BT.Order_Product__c) != null)
                {
                    Decimal BTAmtMap = BTSumEx.get(BT.Order_Product__c);
                    BTSumEx.put(BT.Order_Product__c,BTAmtMap + BT.blng__Amount__c);
                }
                else
                    BTSumEx.put(BT.Order_Product__c,BT.blng__Amount__c);
                
            }
        }
        
        BillPlanList = [SELECT Bill_Percentage__c,Bill_Amount__c,Calculated_Bill_Amount__c,Calculated_Bill_Percentage__c,CurrencyIsoCode,Id,Invoice_Date__c,Name,Order_Product__c,Order__c,Partial_Order__c FROM Invoice_Schedule__c where Order__c = :orderId AND Id NOT IN (select Invoice_Schedule__c from blng__BillingTransaction__c where blng__OverrideStatus__c = null AND blng__Status__c != null AND blng__Status__c != 'Cancelled' AND Order_LKP__c =: orderId )];
        //I2C-1532 Removed ORDER BY Invoice_Date__c ASC 
        //Added ORDER BY to the above query sort the bill plans according to Invoice Date <I2C-1388>
     //I2C-1388 Multiplier for Days to add to start Date and End Date

        //Map<Id, Date> orderItemNextBPDate = new Map<Id, Date>();//I2C-1388 //Removed for I2C-1532
        for(blng__BillingSchedule__c blngBS : billingScheduleList)
        {
            Integer bpCounter = 0;
            blng__BillingTransaction__c blngBT = new blng__BillingTransaction__c ();
            Decimal OPAmount = 0;
            Decimal bTSum = 0;
            counter = counter + 1;
            //Integer totalBillingDays = 0; //I2C-1388 //Commented for I2C-1532
            //Integer bpBillingDays = 0;//I2C-1388 //Commented for I2C-1532
            List<blng__BillingTransaction__c> BTList = new List<blng__BillingTransaction__c>();
            
            for(Invoice_Schedule__c InvSch : BillPlanList)
            {
                //bpCounter = bpCounter +1; //I2C-1388 //Commented for I2C-1532
                blngBT = new blng__BillingTransaction__c (); 
                BPMap.put(InvSch.Id,InvSch);
                /*I2C-1388 START //I2C-1532 Code Revert 
                totalBillingDays = OrderItemMap.get(blngBS.blng__OrderProduct__c).ServiceDate.daysBetween(OrderItemMap.get(blngBS.blng__OrderProduct__c).EndDate); //Calculates Total Billing days  
                if(bpCounter == 1)
                    blngBT.blng__ServicePeriodStart__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).ServiceDate;
                else
                    blngBT.blng__ServicePeriodStart__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).ServiceDate.addDays(bpBillingDays+1);
                *///I2C-1388 ENDS //Commented for I2C-1532 Code Revert
                if(InvSch.Bill_Percentage__c != null){
                    blngBT.blng__Amount__c = ((InvSch.Bill_Percentage__c * blngBS.blng__Amount__c)/100).setScale(blngBS.blng__Amount__c.scale());//, RoundingMode.HALF_UP);<T05>
                    //bpBillingDays = bpBillingDays + Math.round((InvSch.Bill_Percentage__c * totalBillingDays)/100);//I2C-1388 //Commented for I2C-1532
                }
                else if(InvSch.Partial_Order__c && InvSch.Bill_Amount__c != null){
                    blngBT.blng__Amount__c = ((InvSch.Bill_Amount__c/TotalBSAmt)* blngBS.blng__Amount__c).setScale(blngBS.blng__Amount__c.scale());//, RoundingMode.HALF_UP);<T05>
                    //bpBillingDays = bpBillingDays + Math.round((InvSch.Bill_Amount__c/TotalBSAmt) * totalBillingDays);//I2C-1388 //Commented for I2C-1532
                }
                else{
                    blngBT.blng__Amount__c = ((InvSch.Calculated_Bill_Percentage__c * blngBS.blng__Amount__c)/100).setScale(blngBS.blng__Amount__c.scale());//, RoundingMode.HALF_UP);<T05>
                    //bpBillingDays = bpBillingDays + Math.round((InvSch.Calculated_Bill_Percentage__c * totalBillingDays)/100);//I2C-1388 //Commented for I2C-1532
                }
                /*I2C-1388 START //Commented for I2C-1532
                if(bpCounter == BillPlanList.size())
                    blngBt.blng__ServicePeriodEnd__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).EndDate;
                else
                    blngBt.blng__ServicePeriodEnd__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).ServiceDate.addDays(bpBillingDays);
                */ //I2C-1388 ENDS //Commented for I2C-1532

                    
                blngBT.blng__BillingSchedule__c = blngBS.Id;
                blngBT.blng__BillingTargetDate__c = InvSch.Invoice_Date__c;
                blngBT.blng__Source__c = 'Standard';
                blngBT.blng__Status__c = 'Pending';
                blngBT.blng__Quantity__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).Quantity;
                blngBT.blng__ServicePeriodStart__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).ServiceDate; //Uncommented for I2C-1532
                blngBt.blng__ServicePeriodEnd__c = OrderItemMap.get(blngBS.blng__OrderProduct__c).EndDate; //Uncommented for I2C-1532
                blngBT.CurrencyIsoCode = blngBS.CurrencyIsoCode;
                blngBT.Name = (blngBS.Name).replace('BS-','BT-');
                blngBT.Order_LKP__c = orderId;
                blngBT.Order_Product__c = blngBS.blng__OrderProduct__c;
                blngBT.Invoice_Schedule__c = InvSch.Id;
                //billingTransactionList.add(blngBT);
                OPAmount = OPAmount + blngBT.blng__Amount__c;
                
                    if(bTSumBPListMap.get(blngBS.blng__OrderProduct__c) != null)
                    {
                        BTList = BtSumBPListMap.get(blngBS.blng__OrderProduct__c);
                        BTList.add(blngBT);
                        bTSumBPListMap.put(blngBS.blng__OrderProduct__c,BTList);
                    }
                    else
                    {
                        BTList.add(blngBT);
                        bTSumBPListMap.put(blngBS.blng__OrderProduct__c,BTList);
                    }  
                
                system.debug('Billing Transaction : ' + 'ORDER PRODUCT : ' + blngBS.blng__OrderProduct__c + blngBT);
                
                if(blngBS.blng__Amount__c != 0 && math.abs(blngBS.blng__Amount__c) > 0)
                {
                    BPId = InvSch.Id;
                    blngBSOPId = blngBS.blng__OrderProduct__c;
                    blngBSOPAmt = blngBS.blng__Amount__c;
                    
                    if(bTSumBP.get(InvSch.Id) != null)
                    {
                        bTSum = bTSumBP.get(InvSch.Id) + blngBT.blng__Amount__c;
                        bTSumBP.put(InvSch.Id,bTSum);
                    }
                    else
                    {
                        bTSumBP.put(InvSch.Id,blngBT.blng__Amount__c);
                    }
                    
                }
            }
            
            if(Correction)
            {
                system.debug('Billing Schedule Total Amount : ' + blngBS.blng__Amount__c);
                
                if(BTSumEx.get(blngBS.blng__OrderProduct__c) != null)
                        OPAmount = OPAmount + BTSumEx.get(blngBS.blng__OrderProduct__c);
                
                system.debug('correction : ' + (blngBS.blng__Amount__c - OPAmount));
                        
                if(OPAmount != 0 && (blngBS.blng__Amount__c - OPAmount) != 0 && blngBS.blng__Amount__c != 0)
                {
                    system.debug('Before correction : bTSum : ' + bTSum + 'correction in decimals : ' + (blngBS.blng__Amount__c - OPAmount));
                    bTSum = bTSumBP.get(BPId) - blngBT.blng__Amount__c;
                    blngBT.blng__Amount__c = blngBT.blng__Amount__c + (blngBS.blng__Amount__c - OPAmount);
                    bTSum = bTSum + blngBT.blng__Amount__c;
                    bTSumBP.put(BPId,bTSum);
                    system.debug('After Correction : bTSum : ' + bTSum);
                    
                }  
                
                
                
                if(billingScheduleList.size() == counter)
                {
                        Integer BTsize;
                        if(bTSumBPListMap != null)
                        {
                            if(bTSumBPListMap.get(blngBSOPId) != null)
                            {
                                BTsize = bTSumBPListMap.get(blngBSOPId).size();
                                for(blng__BillingTransaction__c BTOP : bTSumBPListMap.get(blngBSOPId))
                                {
                                    BTsize = BTsize - 1;
                                    system.debug('Before Invoice Correction : ' + BTOP.blng__Amount__c);
                                    if(BPMap != null)
                                    {
                                        if(BPMap.get(BTOP.Invoice_Schedule__c) != null)
                                        {
                                            if(BPMap.get(BTOP.Invoice_Schedule__c).Calculated_Bill_Amount__c != null && (BPMap.get(BTOP.Invoice_Schedule__c).Calculated_Bill_Amount__c - bTSumBP.get(BTOP.Invoice_Schedule__c) != 0))
                                                BTOP.blng__Amount__c = BTOP.blng__Amount__c + BPMap.get(BTOP.Invoice_Schedule__c).Calculated_Bill_Amount__c - bTSumBP.get(BTOP.Invoice_Schedule__c);
                                            
                                            if(BPMap.get(BTOP.Invoice_Schedule__c).Bill_Amount__c != null && (BPMap.get(BTOP.Invoice_Schedule__c).Bill_Amount__c - bTSumBP.get(BTOP.Invoice_Schedule__c)) != 0)
                                                BTOP.blng__Amount__c = BTOP.blng__Amount__c + BPMap.get(BTOP.Invoice_Schedule__c).Bill_Amount__c - bTSumBP.get(BTOP.Invoice_Schedule__c);
                                            system.debug('After Invoice Correction : ' + BTOP.blng__Amount__c);
                                            OPAmtFinal = OPAmtFinal + BTOP.blng__Amount__c;
                                            if(BTsize == 0)
                                            {
                                                if(BTSumEx.get(blngBSOPId) != null)
                                                    OPAmtFinal = OPAmtFinal + BTSumEx.get(blngBSOPId);
                                                BTOP.blng__Amount__c = BTOP.blng__Amount__c + (blngBSOPAmt - OPAmtFinal);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
                
             }
            
        }
        
        try
        {
            if(bTSumBPListMap.values() != null)
            {
                for(Id OPID : bTSumBPListMap.keyset())
                    billingTransactionList.addAll(bTSumBPListMap.get(OPID));
                
                delete [Select Id,blng__Status__c, blng__OverrideStatus__c from blng__BillingTransaction__c where Order_LKP__c =: orderId AND blng__OverrideStatus__c =: 'Cancelled'];
                
                if(billingTransactionList.size() > 0)
                    insert billingTransactionList;
            }
        }
        catch(exception e)
        {
            GAM.CreateExceptionRecords('generateBillingSchedule -->', e.getMessage(), '-->' + 'error from Billing Transaction creation for' + orderId);
            throw new AuraHandledException(e.getMessage());
        }
        
        return message;
 
            
    }
    
    @AuraEnabled
    public static String cancelBillingScheduleTransaction(Id orderId)
    {
         List<blng__BillingTransaction__c> billingTransactionList = new List<blng__BillingTransaction__c> ();
         String message = null;
         message = cancelMessage(orderId);
        
        if(message != null)
        return message;
        
         for(blng__BillingTransaction__c blngBT : [SELECT blng__AmountToBeBilled__c,blng__Amount__c,blng__BillingSchedule__c,blng__BillingTargetDate__c,blng__OverrideBillingTargetDate__c,blng__OverrideStatus__c,blng__Source__c,blng__Status__c,Id,Invoice_Schedule__c,Name,Order_LKP__c FROM blng__BillingTransaction__c where blng__Status__c =: 'Pending' AND blng__OverrideStatus__c = null AND Order_LKP__c =: OrderId])
         {
             blngBT.blng__OverrideStatus__c = 'Cancelled';
             billingTransactionList.add(blngBT);
         }
         
         try
        {
            if(billingTransactionList.size() > 0)
                update billingTransactionList;
        }
        catch(exception e)
        {
            GAM.CreateExceptionRecords('generateBillingSchedule -->', e.getMessage(), '-->' + 'error from Billing Transaction Cancellation for' + orderId);
            throw new AuraHandledException(e.getMessage());
        } 
        
        return message;
    }
    /*
    <T03> This method cancels all pending Billing Transactions and create new Transactions using modified Bill Plans.
    */
    @AuraEnabled
    public static String cancelandRegenerate(Id orderId)
    {
         
         String message = null;
         message = cancelBillingScheduleTransaction(orderId);
         
        try
        {
            if(message == null)
            {
                message = createBillingScheduleTransaction(orderId,'CancelandRebill');    
            }
        }
        catch(exception e)
        {
            GAM.CreateExceptionRecords('generateBillingSchedule -->', e.getMessage(), '-->' + 'error from Billing Transaction Cancellation for' + orderId);
            throw new AuraHandledException(e.getMessage());
        } 
        
        return message;
    }
    
}