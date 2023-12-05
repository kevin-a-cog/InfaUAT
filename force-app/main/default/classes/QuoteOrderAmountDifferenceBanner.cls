/*
 * @author : Kiran G
 * @date   : 5 Jan 2021
 * @purpose: SALESRT-12516 To display banner on Draft Order Status when the Quote and Order Amount does not match 
             SALESRT-12763 Payment Term not available when Payment Term is Other
             SALESRT-12763 Bill Plan not available when Billing Frequency is Invoice Plan
Change History
***************************************************************************************************************
ModifiedBy       Date        Ticket No.          Requested By        Description                           					Tag  
Kiran G        1 Feb 2021    SALESRT-12763       Raghu N             Payment Term and Bill Plan messages   					T01
Kiran G        1 Mar 2021    TAX-19              Murali V            Check Tax Exempt Status               					T02
RamEsh M S     17-MAR-2021   SALESRT-12863       Finance             Adjustment Reason Code                					<T03>
Wasim		   19-JUL-2021	 I2C-1323			 Finance			 Check if Adjustment Reason Code is populated on 		<T04>
																	 Direct Order
Wasim          15-DEC-2021   I2C-1421            Finance             Merged all the methods to a single method. And added   <T05>
                                                                     Amendment Type blank check.
Nishit S       28-JUN-2022   I2C-1631            Kain L              Display Banner Message on the Order when Quote has "Term For Convenience" flag marked <I2C-1631>                                                                    
                                                                    
Nishit S       20-JUL-2022   I2C-1626            Kain L              Material Rights Future Renewals Pricing - Alert Notification       <I2C-1626>
Nishit S	   24-APR-2023	 I2C-1729							     Multi Contract Swaps - Update the Related Revenue Order Field for Amendment Orders					<I2C-1729>
Sreerekha	   04-JUL-2023   I2C-1939								 Enhance the Related Revenue Order Automation logic
Nishit S       15-AUG-2023   I2C-1987            Kain L              CPQ Validate Billing banner when criteria is met       <I2C-1987>
*/
public class QuoteOrderAmountDifferenceBanner{ 
    //Create a wrapper class to pass it to LWC component   
    public class WrapperOrderDetails{
        @AuraEnabled
        public Boolean diffAmtGreaterThanOne {get; set;}
        @AuraEnabled
        public Boolean ptNotAvailable {get; set;}
        @AuraEnabled
        public Boolean bpNotExists {get; set;}     
        @AuraEnabled   
        public Boolean bsbtNotExist {get; set;}
        @AuraEnabled
        public Boolean exemptNeedsValidation {get; set;}
        @AuraEnabled
        public Boolean adjCodeNotExist {get; set;}
        @AuraEnabled
        public Boolean amendTypeBlank {get; set;}
        @AuraEnabled
        public Boolean termForConvenience {get; set;} //<I2C-1631>
        @AuraEnabled
        public Boolean MaterialRightsBannerMessage {get; set;} //<I2C-1626>
        @AuraEnabled
        public Boolean RelRevOrderBannerMessage {get; set;} //<I2C-1929>
        @AuraEnabled
        public Boolean RelRevOrderCalculatingMessage {get; set;} //<I2C-1939>
        @AuraEnabled
        public Boolean validateBillingMessage {get; set;} //
    }
    @AuraEnabled(cacheable=true)
    public static WrapperOrderDetails loadOrderData(Id recordId){
        //Create and assign variables
        Double diff = 0;
        Decimal minutes = 0; //<I2C-1939>
        List<blng__BillingSchedule__c> lstBS = new List<blng__BillingSchedule__c>();
        List<blng__BillingTransaction__c> lstBT = new List<blng__BillingTransaction__c>();
        List<Invoice_Schedule__c> lstBillPlans = new List<Invoice_Schedule__c>();
        List<Payment_Term__c> lstPTs = new List<Payment_Term__c>();
        List<Order> lstOrders = new List<Order>();
        WrapperOrderDetails  wrapper = new WrapperOrderDetails();
        wrapper.diffAmtGreaterThanOne = false;
        wrapper.ptNotAvailable = false;
        wrapper.bpNotExists = false;
        wrapper.bsbtNotExist = false;
        wrapper.exemptNeedsValidation = false;
        wrapper.adjCodeNotExist = false;
        wrapper.amendTypeBlank = false;
        wrapper.termForConvenience = false; //<I2C-1631>
        wrapper.MaterialRightsBannerMessage = false; //<I2C-1626>
        wrapper.RelRevOrderBannerMessage = false; //<I2C-1729>
        wrapper.RelRevOrderCalculatingMessage = false; //<I2C-1739>
        //Get Order Details
        lstOrders =  new List<Order>([ Select Id,Status,
                                        SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__NetAmount__c, SBQQ__Quote__r.Term_for_Convenience__c,
                                        TotalAmount,Source__c,Amendment_Type__c,
                                        SBQQ__PaymentTerm__c,Type,Adjustment_Reason_Code__c,blng__InvoiceBatch__c,blng__TotalBilling__c, 
                                        SBQQ__Quote__r.Material_Rights_Applicable__c, Related_Revenue_Orders__c,ActivatedDate,
                                        blng__BillingDayOfMonth__c, EffectiveDate,  override_Billing_Frequency__c, currencyIsoCode                                           
                                        FROM Order 
                                        WHERE Id =: recordId                                                                                             
                                    ]);
        //Get Order Products of Order to see if any oder product is Invoice PLan
        List<OrderItem> lstOLI = new List<OrderItem>(); //refactored the query 
        List<OrderItem> allOrderProducts = new List<OrderItem>(); //refactored the query- captures all orderitems 
        for(OrderItem orderitem : [ Select Id , SBQQ__BillingFrequency__c,OrderId, ServiceDate FROM OrderItem WHERE OrderId =: recordId]){
            if(orderitem.SBQQ__BillingFrequency__c == 'Invoice Plan'){
                lstOLI.add(orderitem);
            }
            allOrderProducts.add(orderitem);
        }                                        
        //Get List of Payment Terms related to the Order
        lstPTs = [Select Id,Order__c,Order__r.SBQQ__PaymentTerm__c,Order__r.Status from Payment_Term__c 
                  where Order__c =: recordId];

        // Get Bill Plans and Billing Transaction related to the Order
        lstBillPlans = [Select Id,Order__c,Order__r.Status from Invoice_Schedule__c where Order__c =: recordId];
        lstBT = [Select Id from blng__BillingTransaction__c where Order_LKP__c =: recordId];
        
        //Check if Order List is not empty
        if(lstOrders.size() > 0 && lstOrders != null){
            //Check if Amount Difference is greater than one. 
            if(lstOrders[0].Status == 'Draft' && lstOrders[0].SBQQ__Quote__c != NULL) { 
                    diff = math.abs(lstOrders[0].SBQQ__Quote__r.SBQQ__NetAmount__c - lstOrders[0].TotalAmount) ;            
                }
            if(diff > 1){
                wrapper.diffAmtGreaterThanOne = true;
            }

            //Check if Payment Term is Available for the Order
            if(lstOrders[0].SBQQ__PaymentTerm__c  == 'Other'){
                if(lstPTs.size() <= 0 ){
                    wrapper.ptNotAvailable = true;
                } 
            }                
            
            //Check if Bill Plan Exists
            if(lstOLI.size() > 0 && lstOrders[0].Status != 'Draft'){           
                if(lstBillPlans.size() <= 0 ){
                    wrapper.bpNotExists = true;  
                }
            }
            
            //Check if Bill Plan and Billing Transaction Exists
            if(lstOLI.size() > 0 && lstBillPlans.size() > 0 
            && (lstOrders[0].Status == 'Bill & Contract' || lstOrders[0].Status == 'Completed')){
                if(lstBT.size() <= 0){
                    wrapper.bsbtNotExist = true;
                }                      
            }   

            //Check if Invoice Batch is in Hold Status
            if(lstOrders[0].SBQQ__Quote__c != NULL ){
                if(lstOrders[0].blng__InvoiceBatch__c == 'Hold Invoice'){
                    wrapper.exemptNeedsValidation = true;
                }
            }
           
            //Check Adjustment Reason Code on -ve Amendment Order
            if((lstOrders[0].Status != 'Draft' && lstOrders[0].Adjustment_Reason_Code__c == null && lstOrders[0].Type == 'Amendment' && lstOrders[0].TotalAmount < 0 && math.abs(lstOrders[0].blng__TotalBilling__c - lstOrders[0].TotalAmount) > 1)
            || (lstOrders[0].Status != 'Draft' && lstOrders[0].SBQQ__Quote__c == null && lstOrders[0].Adjustment_Reason_Code__c == null && lstOrders[0].TotalAmount < 0)){//<T04>
                wrapper.adjCodeNotExist = true;
            }                      
               
            //Check if Amendment Tye is Blank on Order
            if(lstOrders.size() > 0 && lstOrders != null){
                if(lstOrders[0].Type == 'Amendment' && String.isBlank(lstOrders[0].Amendment_Type__c)){
                    wrapper.amendTypeBlank = true;
                }
            }

            //<I2C-1631> Check if Term_for_Convenience__c is true on Quote
            if(lstOrders[0]?.SBQQ__Quote__r?.Term_for_Convenience__c == TRUE ){
                wrapper.termForConvenience = true;
            }
            //<I2C-1631> ENDS
            

            //<I2C-1626> Check if Material_Rights_Applicable__c is true on Quote
            if(lstOrders[0]?.SBQQ__Quote__r.Material_Rights_Applicable__c == 'Yes' ){
                wrapper.MaterialRightsBannerMessage = true;
            }
            //<I2C-1626> ENDS
            //<I2C-1729> Check if Related_Revenue_Orders__c is blank on Quote
            //<I2C-1939> 
            if(lstOrders[0]?.ActivatedDate != null)
        	minutes = Integer.valueOf((system.now().getTime() - lstOrders[0]?.ActivatedDate.getTime())/(1000*60));
            
            if(lstOrders[0]?.Related_Revenue_Orders__c == NULL && lstOrders[0].Status != 'Draft' && minutes > 15){
                wrapper.RelRevOrderBannerMessage = true;
            }
            //<I2C-1729> ENDS
            if(lstOrders[0]?.Related_Revenue_Orders__c == NULL && lstOrders[0].Status != 'Draft' && minutes < 15){
                wrapper.RelRevOrderCalculatingMessage = true;
            }
            //<I2C-1987> STARTS
            Double conversionRate = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode = :lstOrders[0].currencyIsoCode].ConversionRate;
            for(OrderItem oi : allOrderProducts){
                if(
                    (oi.SBQQ__BillingFrequency__c != 'Invoice Plan' && 
                     lstOrders[0].EffectiveDate != oi.ServiceDate && 
                     lstOrders[0].blng__BillingDayOfMonth__c != String.valueOf(oi.ServiceDate.day())) || 
                    (lstOrders[0].Override_Billing_Frequency__c == 'One Time' && (Math.round(lstOrders[0].TotalAmount)/conversionRate) >= 300000)
                ){
                    wrapper.validateBillingMessage = true;
                    break;
                }
            }
            //<I2C-1987> ENDS

        }
        return wrapper;
    }
    /*
    @AuraEnabled(cacheable=true)
    public static String getDifferenceAmount(Id recordId){
        string statusMessage='';
        Double diff = 0;
        List<Order> lstOrders = new List<Order>();
        //Get Order Total Amount and Quote Net Amount if its in Draft Status
        //lstOrders = [Select Id,SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__NetAmount__c,TotalAmount,Source__c,Status  from Order where Id =: recordId AND Status = 'Draft'];
        lstOrders = getOrderDetails(recordId);
        //Get the difference from QUote to Order and if difference is greater than 1 then display banner . Do not display for ES/SP and
        // Partner fee orders as they will not have quote
        
        if(lstOrders.size() > 0 && lstOrders != null && lstOrders[0].Status == 'Draft') {   
            if(lstOrders[0].SBQQ__Quote__c != NULL ){
                diff = math.abs(lstOrders[0].SBQQ__Quote__r.SBQQ__NetAmount__c - lstOrders[0].TotalAmount) ;            
            }
        }
        if(diff > 1)
            statusMessage = 'GREATERTHAN1';
        else
            statusMessage = 'LESSTHAN1';
            
       return statusMessage ;
    }
    
    //T01
    @AuraEnabled(cacheable=true)
    public static String checkPaymentTerm(Id recordId){
        String PTStatus = '';
        List<Payment_Term__c> lstPTs = new List<Payment_Term__c>();
        List<Order> lstOrders = new List<Order>();
        
        //Get Order Details
        //lstOrders = [Select Id,Status,SBQQ__PaymentTerm__c  from Order where Id =: recordId AND Status = 'Draft'];
        lstOrders = getOrderDetails(recordId);
        //Get the Payment Term records and Payment Term on Order to check if its Other
        lstPTs = [Select Id,Order__c,Order__r.SBQQ__PaymentTerm__c,Order__r.Status from Payment_Term__c where Order__c =: recordId];
        
        if(lstOrders.size() > 0 && lstOrders != null){
            if(lstOrders[0].SBQQ__PaymentTerm__c  == 'Other'){
                if(lstPTs.size() <= 0 )
                    PTStatus = 'NOTAVAILABLE';        
                else            
                   PTStatus = 'AVAILABLE'; 
            }
        }
           
        return PTStatus;
    }

    //T01
    @AuraEnabled(cacheable=true)
    public static String checkBillPlans(Id recordId){
        String BPExists = '';
        List<Invoice_Schedule__c> lstBillPlans = new List<Invoice_Schedule__c>();
        List<Order> lstOrders = new List<Order>();
        
        //Get the Order details         
        lstOrders = getOrderDetails(recordId);
        //Get Order Products of Order to see if any oder product is Invoice PLan
        List<OrderItem> lstOLI = new List<OrderItem>([ Select Id , SBQQ__BillingFrequency__c,OrderId
                                                       FROM OrderItem
                                                       WHERE OrderId =: recordId AND SBQQ__BillingFrequency__c = 'Invoice Plan'
                                                     ]);
                                                     
        // Get Bill Plans of the Billing Frequency is Invoice Plan
        lstBillPlans = [Select Id,Order__c,Order__r.Status from Invoice_Schedule__c where Order__c =: recordId];        
       
        if(lstOrders.size() > 0 && lstOrders != null && lstOLI.size() > 0 && lstOrders[0].Status != 'Draft'){           
                if(lstBillPlans.size() <= 0 )
                    BPExists = 'NOTEXIST';  
                else
                    BPExists = 'EXIST';
            
        }
        return BPExists;
    } 

    //T01 Check Billing Schedules and Billing Transactions
    @AuraEnabled(cacheable=true)
    public static String checkBSBT(Id recordId){
        String BSBT = '';
        List<Invoice_Schedule__c> lstBillPlans = new List<Invoice_Schedule__c>();
        List<Order> lstOrders = new List<Order>();
        List<blng__BillingSchedule__c> lstBS = new List<blng__BillingSchedule__c>();
        List<blng__BillingTransaction__c> lstBT = new List<blng__BillingTransaction__c>();
        
        lstOrders = getOrderDetails(recordId);
        //Get Order Products of Order to see if any oder product is Invoice PLan
        List<OrderItem> lstOLI = new List<OrderItem>([ Select Id , SBQQ__BillingFrequency__c,OrderId
                                                       FROM OrderItem
                                                       WHERE OrderId =: recordId AND SBQQ__BillingFrequency__c = 'Invoice Plan'
                                                     ]);                                                    
        // Get Bill Plans of the Billing Frequency is Invoice Plan
        lstBillPlans = [Select Id,Order__c,Order__r.Status from Invoice_Schedule__c where Order__c =: recordId];
        lstBT = [Select Id from blng__BillingTransaction__c where Order_LKP__c =: recordId];
        
        if(lstOrders.size() > 0 && lstOrders != null && lstOLI.size() > 0 && lstBillPlans.size() > 0 
           && (lstOrders[0].Status == 'Bill & Contract' || lstOrders[0].Status == 'Completed')){
               if(lstBT.size() <= 0)
                   BSBT = 'NOTEXIST';
               else
                   BSBT = 'EXIST';                        
        }   
        return BSBT;                        
    
    }       
    
     //T02 Check if Invoice Batch is Hold
    @AuraEnabled(cacheable=true)
    public static String checkExemptStatus(Id recordId){
        String exemptStatus = '';
        List<Order> lstOrders = new List<Order>();
        
        lstOrders = getOrderDetails(recordId);
        
        if(lstOrders.size() > 0 && lstOrders != null && lstOrders[0].SBQQ__Quote__c != NULL ){
            if(lstOrders[0].blng__InvoiceBatch__c == 'Hold Invoice')
                exemptStatus = 'NEEDSVALIDATION';
            else
                exemptStatus = 'OTHER';
            
        }
        return exemptStatus;
    }       
    //T02
    
    //T03 Check Adjustment Reason Code on -ve Amendment Order
    @AuraEnabled(cacheable=true)
    public static String checkAdjustCode(Id recordId){
        String AdCode = '';
        
        List<Order> lstOrders = new List<Order>();
       
        lstOrders = getOrderDetails(recordId);
      
        if(lstOrders.size() > 0 && lstOrders != null){
            if((lstOrders[0].Status != 'Draft' && lstOrders[0].Adjustment_Reason_Code__c == null && lstOrders[0].Type == 'Amendment' && lstOrders[0].TotalAmount < 0 && math.abs(lstOrders[0].blng__TotalBilling__c - lstOrders[0].TotalAmount) > 1)
               || (lstOrders[0].Status != 'Draft' && lstOrders[0].SBQQ__Quote__c == null && lstOrders[0].Adjustment_Reason_Code__c == null && lstOrders[0].TotalAmount < 0))//<T04>
                   AdCode = 'NOTEXIST';
               else
                   AdCode = 'EXIST';                        
        }   
        return AdCode;                        
    
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkAmendType(Id recordId){
        Boolean retVal = false;
        List<Order> lstOrders = new List<Order>();       
        lstOrders = getOrderDetails(recordId);
        if(lstOrders.size() > 0 && lstOrders != null){
            if(lstOrders[0].Type == 'Amendment' && String.isBlank(lstOrders[0].Amendment_Type__c)){
                retVal = true;
            }
        }
        return retVal;
    }

    //Generic method to get order details
    public static List<Order> getOrderDetails(Id recordId){
        List<Order> lstOrderDetails = new List<Order>([ Select Id,Status,
                                                        SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__NetAmount__c,
                                                        TotalAmount,Source__c,Amendment_Type__c,
                                                        SBQQ__PaymentTerm__c,Type,Adjustment_Reason_Code__c,blng__InvoiceBatch__c,blng__TotalBilling__c                                                     
                                                        FROM Order 
                                                        WHERE Id =: recordId                                                                                             
                                                      ]);
        return lstOrderDetails;                                                 
    }
    */ 
}