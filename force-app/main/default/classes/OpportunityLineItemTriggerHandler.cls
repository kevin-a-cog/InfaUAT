/*
Class:          OpportunityLineItemTriggerHandler
@Author:        Gaurav Sadhwani
@Created Date:  12/11/2016
@Description:   Handler class for Opportunity Line Item triggers
*/
 
/*
Change History
************************************************************************************************************************************
ModifiedBy                  Date        Requested By        Description                                     Tag
Thejaswini Sattenapalli     13/7/2017                       Added method updateOppotunityDealType           DealTypeRequirement
                                                            for DealType Requirement

Rupanjana Mitra             10/10/2017                      Added method to update Sales Price for          Split Opp Sync Quote/Sync SOP       
                                                            After Insert/Update                             Requirement

Himanjan                    18/10/2017      Anil            Removed hardcoded strings and used labels       #Labels

Rajesh Cherukuri            10/11/2017                      UAT deffect (TKT-000828)                        <TKT-000828>

Ritika Gupta                22/10/2018      Prasanth        Added code to rollup Support Subscription       <T01>
                                                            Family Amount on the Cloud Bucket(Cloud_Subscription__c)
Ritika Gupta                29/01/2019      Prasanth        SALESRT-3963 - Added code to rollup Forecast Price(in place iof unitprice),
                                                            if Product is Daas and Quote Line is tagged.    <T02>
Chandana Gowda              06-Jun-2019     Prasanth        SALESRT-4128 Added the logic to make the 
                                                            integration fields 0 when no optyproducts exits  <T03>       
Vivek Warrier               06-May-2019     Liz Matthews    Commenting out code related to Secondary Oppor-
                                                            tunity Creation                                 <T04>
Ritika Gupta                08-May-2019     SALESRT-4119    Conditions added to rollup Forecast Price to Integration fields(in place of unit price),
                                                            after a quote is made Primary.                   <T05>                                           
Ramya Ravi                  21/10/2020      SALESRT-12452   To optimize the trigger and move oppty product   <T06>
                                                            process builders to trigger as an invocable method
Ramya Ravi                  07/12/2020      SALESRT-12637   To overcome the Values are not getting synced to Opportunity Product
                                                            if the Override OBV is performed                 <T07>     
RamEsh M S                  18-MAR-2021     SALESRT-12919    Original_ACV__c is not calculated on Quote Line and commenting the lines.                                 <T08>   
RamEsh M S                  16-MAR-2021     I2C-1252         Updating logic to Calculate Unit Price with Large Quote settings turned on  <T09>    
Puneet Lohia                25-Jun-2021     SALESRT-12507   IPS & GES - Opportunity field update             <T12507>
Anusha Akella               26-JUL-2021     SALESRT-13141   Renewal/ Upsell Criteria is updated to enter the loop. This update is made to hold the old value of unit price 
                                                            and compare with new value; QL == null criteria is removed. Since all amend opty comes with QL.    <T10>
Anusha Akella               23-Aug-2021     SALESRT-13141   Previous fix failed the renewal scenario, in this we are separating the scenario's for renewals & Upsell <T11>  
Chandana Gowda              26-Jul-2023     SALESRT-17215   Make ARR 0 for cancelled lines                  <T12>
Chandana Gowda              14-Aug-2023     SALESRT-17070   Added logic to handle Offset ACV    <T13>
VENKATESH BALLA             19-OCT-2023     SALESRT-17662   Added logic to assign ACV values irrespective of product type.    <T14>
************************************************************************************************************************************
*/

/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/

public with sharing class OpportunityLineItemTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /**
    * this method is invoked from after update event of Opportunity Line Item
    *
    * @param parameter- mapOld - map of old Opportunities Line Item
    * @param parameter- mapNew - map of new Opportunities Line Item
    * @return return-void
    * @throws exception - NA
    */
    public static Map<Id,OpportunityLineItem> OldMapReference = new Map<Id,OpportunityLineItem>(); //<T06>
    public static void handleAfterUpdate(Map<Id,OpportunityLineItem> mapOld, Map<Id,OpportunityLineItem> mapNew){       
        //<T06>
        if(!mapOld.isEmpty()){
            for(OpportunityLineItem oldmp : mapOld.values()) {
                OldMapReference.put(oldmp.id, oldmp);
            }
        }
        //opportunityUpdate(mapOld, mapNew);       
        //updateSalesPrice(mapOld, mapNew);
    }
    
    /**
    * this method is invoked from after insert event of Opportunity Line Item
    *
    * @param parameter- mapNew - map of new Opportunities Line Item
    * @return return-void
    * @throws exception - NA
    */
    
    public static void handleAfterInsert(Map<Id,OpportunityLineItem> mapNew){       
        //opportunityUpdate(null, mapNew);        
        // updateSalesPrice(null, mapNew);
    }
    
    
    /**
    * this method is invoked from after delete event of Opportunity Line Item
    *
    * @param lstNew - map of old and new Opportunity line Item
    * @return return-void
    * @throws exception - NA
    */
    
    public static void handleAfterDelete(Map<Id,OpportunityLineItem> mapOld){
        //opportunityUpdate(null,mapOld);
    }
    
     /** Added as part of <T12507>
    * this method is invoked from before insert event of Opportunity Line Item
    *
    * @param lstNew - list of new Opportunity line Item
    * @return return-void
    * @throws exception - NA
    */
    public static void handleBeforeInsert(List<OpportunityLineItem> newList){
        updateBusinessUnit(newList);
    }

    /** Added as part of <T12507>
    * this method is used to update business unit from product
    *
    * @param lstNew - list of new Opportunity line Item
    * @return return-void
    * @throws exception - NA
    */
    public static void updateBusinessUnit(List<OpportunityLineItem> newList){
        Set<Id> productIds = new Set<Id>();
        for(OpportunityLineItem oli : newList){
            if(oli.Product2Id != null){
                productIds.add(oli.Product2Id);
            }
        }
        if(!productIds.isEmpty()){
            Map<Id,Product2> productsMap = new Map<Id,Product2>([SELECT Id,Business_Unit__c FROM Product2 WHERE Id IN :productIds]);
            for(OpportunityLineItem oli : newList){
                if(oli.Product2Id != null){
                    oli.Business_Unit__c = productsMap.containsKey(oli.Product2Id) && 
                                            productsMap.get(oli.Product2Id).Business_Unit__c != null ? 
                                            productsMap.get(oli.Product2Id).Business_Unit__c : '';
                }
            }
            
        }
    }
    
    /**
    * this method captures modification done on OpportunityLineItem and populate them on Opportunity
    * @param parameter- mapOld - map of old Opportunities Line Item
    * @param parameter- mapNew - map of new Opportunities Line Item
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
   /* static void opportunityUpdate(Map<Id,OpportunityLineItem> mapOld, Map<Id,OpportunityLineItem> mapNew){
        
        Map<Id,List<OpportunityLineItem>> opptyExistingLineItemMap = new Map<Id,List<OpportunityLineItem>>();
        Set<Id> opptyIdSet = new Set<Id>();
        String productNameLabel = Label.Opportunity_Product_Name;
        List<String> lstProductName = productNameLabel.split('==');
        Map<Id,Opportunity> finalOpptyMap = new Map<Id,Opportunity>();
        
        //iterate through the line items in the transaction and populate the map 
        for(OpportunityLineItem newopptyLineItem :mapNew.values()) {
            opptyIdSet.add(newopptyLineItem.OpportunityId);
        }
        system.debug('OldMapReference>>'+OldMapReference);*/
        //populate the map of opportunity and existing line items on the opportunity
        /*for(Opportunity opp : [SELECT Id, Name, Daas_Subscription__c, Cloud_Subscription__c , On_Prem_perpetual__C,On_Prem_Subscription__c,
                               (SELECT Id,UnitPrice,Product_Family__c,OpportunityId, SBQQ__QuoteLine__c, Forecast_Price__c, Order_Product__c  from OpportunityLineItems where Product_Family__c != NULL)
                               FROM Opportunity WHERE ID IN :opptyIdSet]) {
                                   List<OpportunityLineItem> opptyLineList = new List<OpportunityLineItem>();
                                   opptyLineList = opp.OpportunityLineItems;
                                   opptyExistingLineItemMap.put(opp.Id,opptyLineList);
         }*/
        
       /* for(OpportunityLineItem oli : [SELECT Id,UnitPrice,Product_Family__c,OpportunityId, SBQQ__QuoteLine__c, Forecast_Price__c, Order_Product__c from OpportunityLineItem where Product_Family__c != NULL AND OpportunityId =: opptyIdSet])
        {           
               List<OpportunityLineItem> oliList = opptyExistingLineItemMap.get(oli.OpportunityId);          
               if(oliList == null)                  
               oliList = new List<OpportunityLineItem> ();
               oliList.add(oli);
               opptyExistingLineItemMap.put(oli.OpportunityId,oliList);             
        } 
      
        for (Id OpportunityId : opptyExistingLineItemMap.keySet()) //use keyset instead of values <T03>
        {
            //variables to store Total
            Decimal daasSubscription = 0.0;
            Decimal cloudSubscription = 0.0;
            Decimal OnPremperpetual= 0.0;
            Decimal OnPremSubscription= 0.0;
            List<OpportunityLineItem> OpptyLineItemList=opptyExistingLineItemMap.get(OpportunityId);
            //iterate through the line items
            //checking if no opty products exists
     
            for (OpportunityLineItem opptyLine : OpptyLineItemList)
            {
                   
                //DAAS Subscription 
                if(opptyLine.Product_Family__c.equalsIgnoreCase(lstProductName[0])) {
                    //daasSubscription+=  opptyLine.UnitPrice;
                    //----------------------------------------------------------<T02>
                    if(opptyLine.SBQQ__QuoteLine__c != null){
                        daasSubscription+=  opptyLine.Forecast_Price__c;
                    }else{
                        daasSubscription+=  opptyLine.UnitPrice;
                    }
                    //----------------------------------------------------------</T02>
                }
                
                //Cloud Subscription    
                if(opptyLine.Product_Family__c.equalsIgnoreCase(lstProductName[1]) || opptyLine.Product_Family__c.equalsIgnoreCase(lstProductName[4])) {//<T01>
                    //cloudSubscription+= opptyLine.UnitPrice;
                    //----------------------------------------------------------<T05>
                    if(opptyLine.SBQQ__QuoteLine__c != null){
                        cloudSubscription+=  opptyLine.Forecast_Price__c;
                    }else{
                        cloudSubscription+=  opptyLine.UnitPrice;
                    }
                    //----------------------------------------------------------<T05>
                }
                
                //OnPremperpetual
                if(opptyLine.Product_Family__c.equalsIgnoreCase(lstProductName[2])) {
                    //OnPremperpetual+=   opptyLine.UnitPrice;
                    //----------------------------------------------------------<T05>
                    if(opptyLine.SBQQ__QuoteLine__c != null){
                        OnPremperpetual+=  opptyLine.Forecast_Price__c;
                    }else{
                        OnPremperpetual+=  opptyLine.UnitPrice;
                    }
                    //----------------------------------------------------------<T05>
                }
                
                //OnPremSubscription 
                if(opptyLine.Product_Family__c.equalsIgnoreCase(lstProductName[3])) {
                    //OnPremSubscription+=    opptyLine.UnitPrice;
                    //----------------------------------------------------------<T05>
                    if(opptyLine.SBQQ__QuoteLine__c != null){
                        OnPremSubscription+=  opptyLine.Forecast_Price__c;
                    }else{
                        OnPremSubscription+=  opptyLine.UnitPrice;
                    }
                    //----------------------------------------------------------<T05>
                }
            }
             
            //end of iteration of line items
            finalOpptyMap.put(OpportunityId,new Opportunity(Id=OpportunityId
                                                            ,Daas_Subscription__c = daasSubscription
                                                            ,Cloud_Subscription__c = cloudSubscription
                                                            ,On_Prem_perpetual__c = OnPremperpetual
                                                            ,On_Prem_Subscription__c = OnPremSubscription));
           
        }

        //update the opportunities
        Database.SaveResult[] srList = Database.update(finalOpptyMap.values(),false);
        
        if(!finalOpptyMap.values().IsEmpty()){
            globalApexManager GAM = new globalApexManager();
            GAM.CreateLogs('opportunityUpdate',finalOpptyMap.values(),'OpportunitytoUpdateList');
            try{ 
                GAM.InsertDebugLogs();
                
            }
            Catch(Exception e){
                for(Opportunity opp :finalOpptyMap.values()){
                    GAM.CreateExceptionRecords('opportunityUpdate', e.GetMessage(),opp.Id);
                }
            }
        } 
    }*/
    
     /** // <T06> 
    * this invocable method captures modification done on OpportunityLineItem 
    * @param parameter- mapOld - map of old Opportunities Line Item
    * @param parameter- mapNew - map of new Opportunities Line Item
    * @return return- void
    * @throws exception-captures exception in a debug log
    * Moved 'Set Sales price to 0 for records with Product Family other than DI,DQ,DSG,MDM' process builder to trigger for optimization
    * Moved 'Sync Quote/SOP_1' process builder to trigger for optimization
    */
      
    @InvocableMethod
    public static void opportunityLIUpdate(List<Id> NewOLIID) {
        
        if(Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
            //Variable declaration
            Map<Id,Opportunity> OpptyMap = new Map<Id,Opportunity>();
            Map<Id,Product2> ProductMap = new Map<Id,Product2>();
            Map<Id,SBQQ__QuoteLine__c> QuoteLineItemMap = new Map<Id,SBQQ__QuoteLine__c>();
            Map<Id,OrderItem> OrderProductMap = new Map<Id,OrderItem>();
            
            
            List<Id> OpptyMapID = new  List<Id>();
            List<Id>  ProductMapID = new  List<Id> ();
            List<Id>  QuoteLineItemMapID = new  List<Id> ();
            List<Id>  OrderProductMapID = new  List<Id> ();
            List<OpportunityLineItem> TempOpptyLIMap = new List<OpportunityLineItem>();              
            List<OpportunityLineItem> finalOpptyLIMap = new List<OpportunityLineItem>(); 
            
            Boolean IsNew = true;
            
            if(!OldMapReference.isEmpty()) {
                IsNew = false;
            }
            
            for(OpportunityLineItem newolilist : [Select id,OpportunityId,Product2Id,Product2.Delivery_Method__c,SBQQ__QuoteLine__c,Order_Product__c,Product_Family__c,Forecast_Product__c,Forecast_Family_Text__c, Forecast_Product_Text__c, Quantity, Statement_of_Position_SOP_Amount__c, UnitPrice, Forecast_Price__c, Current_ACV__c, Original_ACV__c, Current_TCV__c, Transaction_Type__c, Incremental_ARR__c, Annual_Recurring_Revenue__c, New_ACV__c, Renewal_ACV__c, Upsell_ACV__c,Offset_ACV__c,Total_Booking_Value__c from OpportunityLineItem where id=: NewOLIID ]){
                TempOpptyLIMap.add(newolilist);
            }
            
            //Iterate over the Line items and get OpptyID, product ID, quoteline ID in the list
            for(OpportunityLineItem newopptyLineItem :TempOpptyLIMap) {
                if(newopptyLineItem.OpportunityId!=null)
                    OpptyMapID.add(newopptyLineItem.OpportunityId );
                if(newopptyLineItem.Product2Id!=null)
                    ProductMapID.add(newopptyLineItem.Product2Id );
                if(newopptyLineItem.SBQQ__QuoteLine__c!=null)
                    QuoteLineItemMapID.add(newopptyLineItem.SBQQ__QuoteLine__c) ;  
                if(newopptyLineItem.Order_Product__c!=null)
                    OrderProductMapID.add(newopptyLineItem.Order_Product__c) ;   
            }
            //Fetch Oppty values in the map
            for( Opportunity oppty :[Select id, Split_Percentage__c, Split_From__c, SBQQ__PrimaryQuote__c from opportunity where id =: OpptyMapID ]) {
                OpptyMap.put(oppty.id,oppty);
            }
            //Fetch product2 values in the map
            for( Product2 pdt :[Select id, Pricing_Business_Model__c,Product_Family__c,Family from Product2 where  id =: ProductMapID ]) {
                ProductMap.put(pdt.id,pdt);
            }
            //Fetch quoteline values in the map
            for( SBQQ__QuoteLine__c qli :[Select id, Current_TCV__c, Current_ACV__c , Original_ACV__c,New_ACV__c, Renewal_ACV__c, Upsell_ACV__c,Offset_ACV__c from SBQQ__QuoteLine__c where id =:  QuoteLineItemMapID ]) {
                QuoteLineItemMap.put(qli.id,qli);
            }
            //Fetch orderproduct values in the map
            for( OrderItem op :[Select id,Statement_of_Position_SOP_Amount__c  from OrderItem where id =:  OrderProductMapID ]) {
                OrderProductMap.put(op.id,op);
            }
            
            // Iterate over the line items and update the values 
            for( OpportunityLineItem opptyLI : TempOpptyLIMap) {
                
                OpportunityLineItem opptyLine = new OpportunityLineItem();
                opptyLine = opptyLI.clone(false, false, false, false);
                opptyLine.id=opptyLI.Id;
                Opportunity OliOppty= new Opportunity();
                Product2 OliProduct = new Product2();
                SBQQ__QuoteLine__c Oliquotelineitem = new  SBQQ__QuoteLine__c();
                OrderItem Oliorderpdt = new OrderItem();
                Decimal unitprice = opptyLine.UnitPrice;
                
                if(OpptyMap.containsKey(opptyLine.OpportunityId))   
                    OliOppty = OpptyMap.get(opptyLine.OpportunityId);
                
                if(ProductMap.containsKey(opptyLine.Product2Id))   
                    OliProduct = ProductMap.get(opptyLine.Product2Id);  
                
                if(QuoteLineItemMap.containsKey(opptyLine.SBQQ__QuoteLine__c))   
                    Oliquotelineitem = QuoteLineItemMap.get(opptyLine.SBQQ__QuoteLine__c);
                
                if(OrderProductMap.containsKey(opptyLine.Order_Product__c))   
                    Oliorderpdt = OrderProductMap.get(opptyLine.Order_Product__c);
                                
                //Copying product family and forecast product names 
                If(opptyLine.Product_Family__c != null)  
                    opptyLine.Forecast_Family_Text__c =   opptyLine.Product_Family__c;
                
                //Copying product delivery method
                If(opptyLine.Product2.Delivery_Method__c != null)  
                    opptyLine.Product_Delivery_Method_Text__c =   opptyLine.Product2.Delivery_Method__c;
                
                If(opptyLine.Forecast_Product__c != null)  
                    opptyLine.Forecast_Product_Text__c =   opptyLine.Forecast_Product__c;

                //set quantity = 1
                If (opptyLine.Quantity!= 1) 
                    opptyLine.Quantity= 1;  
                
                //Order Product is not NULL, SOP amount or Split % is changed, Update SOP amount and Sales price
                if(  !IsNew &&  opptyLine.Order_Product__c != null &&  (
                    (  OldMapReference.get(opptyLine.Id).Statement_of_Position_SOP_Amount__c !=  opptyLine.Statement_of_Position_SOP_Amount__c ||  opptyLine.Statement_of_Position_SOP_Amount__c == 0  ) ||
                    (  OliOppty.Split_Percentage__c != 100 )
                )
                  )                              
                {
                    if(Oliorderpdt.Statement_of_Position_SOP_Amount__c !=null &&  OliOppty.Split_Percentage__c!=null ) 
                        opptyLine.Statement_of_Position_SOP_Amount__c =  (Oliorderpdt.Statement_of_Position_SOP_Amount__c   *   OliOppty.Split_Percentage__c) /100;
                    
                    if(opptyLine.Forecast_Price__c!=null) 
                        opptyLine.UnitPrice = opptyLine.Forecast_Price__c;
                }
                   
                   // Total Booking Value or Current TCV is changed , Update Sales price
                   
                   /*<T09>
                    if(!IsNew)
                    { 
                    if (
                    (OldMapReference.get(opptyLine.Id) != null) && //<T07> 
                    (( (OldMapReference.get(opptyLine.Id).Total_Booking_Value__c !=  opptyLine.Total_Booking_Value__c) ||  (OldMapReference.get(opptyLine.Id).Current_TCV__c !=  opptyLine.Current_TCV__c) )//<T07> 
                    && opptyLine.Statement_of_Position_SOP_Amount__c == null))
                    {
                    if(opptyLine.Forecast_Price__c!=null) 
                    opptyLine.UnitPrice = opptyLine.Forecast_Price__c;
                    }
                    }
                    </T09>*/
                
                //<T09>
                if(opptyLine.Forecast_Price__c != null && opptyLine.Forecast_Price__c != 0 && opptyLine.UnitPrice != opptyLine.Forecast_Price__c) 
                    opptyLine.UnitPrice = opptyLine.Forecast_Price__c;
                //</T09>    
                
                //Quote Line is Inserted
                if(opptyLine.SBQQ__QuoteLine__c!= null)
                {
                    //updating Current_ACV__c from quotelineitem * split percentage into oli
                    if(Oliquotelineitem.Current_ACV__c!=null) { 
                        opptyLine.Current_ACV__c = (Oliquotelineitem.Current_ACV__c * OliOppty.Split_Percentage__c) /100 ; 
                    }  
                    //updating Original_ACV__c from quotelineitem * split percentage into oli
                    //if(Oliquotelineitem.Original_ACV__c!=null) { opptyLine.Original_ACV__c = (Oliquotelineitem.Original_ACV__c * OliOppty.Split_Percentage__c)/100  ; } //<T08> 
                    //updating Current_TCV__c from quotelineitem * split percentage into oli
                    if(Oliquotelineitem.Current_TCV__c!=null) { 
                        opptyLine.Current_TCV__c = (Oliquotelineitem.Current_TCV__c * OliOppty.Split_Percentage__c)/100  ; 
                    } 
                    if(opptyLine.Forecast_Price__c!=null) 
                        opptyLine.UnitPrice = opptyLine.Forecast_Price__c;
                        //---------------------------------------------------------------<T12> - START
                        if(opptyLine.Transaction_Type__c == 'Cancelled'){
                            opptyLine.Annual_Recurring_Revenue__c = 0;
                        }                        
                        //---------------------------------------------------------------<T12> - END
                }
                else   //Quote Line is not Inserted
                {
                    if( opptyLine.Transaction_Type__c=='New' && opptyLine.UnitPrice!=null)
                    {
                        opptyLine.Annual_Recurring_Revenue__c = opptyLine.UnitPrice;
                        opptyLine.Incremental_ARR__c  = opptyLine.UnitPrice;
                    }
                }
                //ABV values update          
                List<String> TransType = new List<String>{'New','Renewal','Upsell','Offset','Cancelled'};
                String tempTranstype;

                //Assigning the transaction types
                /*if(opptyLine.Transaction_Type__c==TransType[0]){tempTranstype=TransType[0];}
                else if(opptyLine.Transaction_Type__c==TransType[1]){tempTranstype=TransType[1];}
                else if(opptyLine.Transaction_Type__c==TransType[2]){tempTranstype=TransType[2];}*/
                tempTranstype = opptyLine.Transaction_Type__c;
                //If transaction type is New
                if(opptyLine.Transaction_Type__c==TransType[0])
                {       
                    //<SALESRT-17662> - commented one of the conditions.         
                    If(   
                        (
                            (IsNew && opptyLine.UnitPrice!=null && opptyLine.Transaction_Type__c==tempTranstype && opptyLine.SBQQ__QuoteLine__c==null) ||
                            (IsNew && opptyLine.UnitPrice!=null && opptyLine.Transaction_Type__c==tempTranstype && OliOppty.Split_Percentage__c!=100) ||                
                            (
                                !IsNew &&  opptyLine.Transaction_Type__c==tempTranstype && 
                                (
                                    (  (OldMapReference.get(opptyLine.Id) != null) && //<T07> 
                                     ( OldMapReference.get(opptyLine.Id).Transaction_Type__c !=  opptyLine.Transaction_Type__c || //<T07> 
                                      (OldMapReference.get(opptyLine.Id).UnitPrice !=  opptyLine.UnitPrice && opptyLine.SBQQ__QuoteLine__c==null )//<T07>  
                                     ))|| 
                                    (opptyLine.Forecast_Price__c!=null && opptyLine.SBQQ__QuoteLine__c!=null  )
                                ) &&
                                opptyLine.UnitPrice!=null
                            ) //Big AND end                  
                        ) /*&&  //Big OR end 
                        (
                            ( OliProduct.Pricing_Business_Model__c == null  || OliProduct.Pricing_Business_Model__c == 'Subscription') &&
                            ( opptyLine.Product_Family__c ==  null || opptyLine.Product_Family__c.contains('Subscription') ||  OliProduct.Product_Family__c ==  'Support') //one condition
                        )*/     
                    )
                    {
                        if(opptyLine.Forecast_Price__c!=null && opptyLine.SBQQ__QuoteLine__c!=null) 
                        {
                            opptyLine.New_ACV__c = opptyLine.Forecast_Price__c ;
                        }
                        else
                        {
                            if( opptyLine.UnitPrice!=null ) 
                                opptyLine.New_ACV__c = opptyLine.UnitPrice;
                        }
                        opptyline.Renewal_ACV__c = 0;
                        opptyline.Upsell_ACV__c = 0 ;                        
                        //-----------------------------------------------------------------------------------------------------------<T13> 
                        opptyline.Offset_ACV__c = 0 ;
                    }
                }
                //If transaction type is Renewal / Upsell
                //Overriding <T07> changes with <T10>
                
                else {
                    Boolean Condition1; 
                    Boolean Condition2;
                    //<SALESRT-17662> - commented to remove Condition3
                    /*Boolean Condition3;
                    Condition3 = (OliProduct.Pricing_Business_Model__c == null  || OliProduct.Pricing_Business_Model__c == 'Subscription') && 
                        (opptyLine.Product_Family__c ==  null || opptyLine.Product_Family__c.contains('Subscription') || OliProduct.Product_Family__c ==  'Support');
                    */
                    //<T11>
                    /* if(opptyLine.Transaction_Type__c==TransType[1]){
                    Condition1 = (IsNew && opptyLine.UnitPrice!=null && opptyLine.Transaction_Type__c==tempTranstype && opptyLine.SBQQ__QuoteLine__c==null);
                    Condition2 = (!IsNew && opptyLine.Transaction_Type__c==tempTranstype && OldMapReference.get(opptyLine.Id) != null &&
                    OldMapReference.get(opptyLine.Id).Transaction_Type__c !=  opptyLine.Transaction_Type__c && opptyLine.UnitPrice!=null);

                    } else if(opptyLine.Transaction_Type__c==TransType[2]){*/                    
                    Condition1 = (IsNew && opptyLine.UnitPrice!=null && opptyLine.Transaction_Type__c==tempTranstype); 
                    Condition2 = (!IsNew && opptyLine.Transaction_Type__c==tempTranstype && 
                                  ((OldMapReference.get(opptyLine.Id) != null) &&
                                   (OldMapReference.get(opptyLine.Id).Transaction_Type__c !=  opptyLine.Transaction_Type__c ||UnitPrice != opptyLine.UnitPrice)) && opptyLine.UnitPrice!=null);
                    //<T11>
                    //<SALESRT-17662> - commented to remove Condition3
                    //if((Condition1 || Condition2) && Condition3){
                    if(Condition1 || Condition2){
                        if(opptyLine.Transaction_Type__c==TransType[1]){
                            
                            if(opptyLine.Forecast_Price__c!=0 && opptyLine.SBQQ__QuoteLine__c!=null) {
                                //opptyline.Renewal_ACV__c = opptyLine.Forecast_Price__c ; 
                                opptyline.Renewal_ACV__c = Oliquotelineitem.Renewal_ACV__c != null ? (Oliquotelineitem.Renewal_ACV__c * OliOppty.Split_Percentage__c) /100 : Oliquotelineitem.Renewal_ACV__c;
                                opptyline.Upsell_ACV__c  = Oliquotelineitem.Upsell_ACV__c != null ? (Oliquotelineitem.Upsell_ACV__c * OliOppty.Split_Percentage__c) /100 : Oliquotelineitem.Upsell_ACV__c;                  
                            } else {
                                if(opptyLine.UnitPrice!=null) {
                                    opptyline.Renewal_ACV__c = opptyLine.UnitPrice;
                                }
                                opptyline.Upsell_ACV__c  = 0 ;
                            }
                            opptyline.New_ACV__c = 0;
                            opptyline.Offset_ACV__c = 0 ;
                        }
                        if(opptyLine.Transaction_Type__c==TransType[2]){
                            if(opptyLine.Forecast_Price__c!=0 && opptyLine.SBQQ__QuoteLine__c!=null){
                                //opptyline.Upsell_ACV__c = opptyLine.Forecast_Price__c ; 
                                opptyline.Upsell_ACV__c  = Oliquotelineitem.Upsell_ACV__c != null ? Oliquotelineitem.Upsell_ACV__c * (OliOppty.Split_Percentage__c /100) : Oliquotelineitem.Upsell_ACV__c;                    
                            } else {
                                if(opptyLine.UnitPrice!=null)   
                                    opptyline.Upsell_ACV__c = opptyLine.UnitPrice;
                            }
                            opptyline.New_ACV__c = 0;
                            opptyline.Renewal_ACV__c = 0 ;
                            opptyline.Offset_ACV__c = 0 ;
                        }
                        if(opptyLine.Transaction_Type__c==TransType[3]){
                            
                            if(opptyLine.Forecast_Price__c!=0 && opptyLine.SBQQ__QuoteLine__c!=null) {
                                opptyline.Offset_ACV__c =  Oliquotelineitem.Offset_ACV__c != null ? Oliquotelineitem.Offset_ACV__c * (OliOppty.Split_Percentage__c /100) :  Oliquotelineitem.Offset_ACV__c;
                                opptyline.Upsell_ACV__c  = Oliquotelineitem.Upsell_ACV__c != null ? Oliquotelineitem.Upsell_ACV__c * (OliOppty.Split_Percentage__c /100) : Oliquotelineitem.Upsell_ACV__c;                   
                            } else {
                                if(opptyLine.UnitPrice!=null)
                                    opptyline.Offset_ACV__c = opptyLine.UnitPrice;
                            }
                            opptyline.New_ACV__c = 0;
                            opptyline.Renewal_ACV__c = 0 ;

                        }
                        if(opptyLine.Transaction_Type__c==TransType[4]){
                            if(opptyLine.Forecast_Price__c!=0 && opptyLine.SBQQ__QuoteLine__c!=null){
                                opptyline.Offset_ACV__c =  Oliquotelineitem.Offset_ACV__c != null ? Oliquotelineitem.Offset_ACV__c * (OliOppty.Split_Percentage__c /100) :  Oliquotelineitem.Offset_ACV__c;
                            }else{
                                if(opptyLine.UnitPrice!=null)   
                                    opptyline.Offset_ACV__c = opptyLine.UnitPrice;
                            }
                            opptyline.New_ACV__c = 0;
                            opptyline.Renewal_ACV__c = 0 ;
                            opptyline.Upsell_ACV__c = 0 ;

                        }
                    }
                    
                }
                //-----------------------------------------------------------------------------------------------------------</T13>                
                finalOpptyLIMap.add(opptyLine);            
            }
            
            //update the opportunity lineitems
            SBQQ.TriggerControl.disable();
            Database.SaveResult[] srListOpptyLI = Database.update(finalOpptyLIMap,false);
            SBQQ.TriggerControl.enable();
            if(finalOpptyLIMap.size()>0){
                globalApexManager GAM = new globalApexManager();
                GAM.CreateLogs('opportunityLIUpdate',finalOpptyLIMap,'OpportunityLIUpdateList');
                try{ 
                    GAM.InsertDebugLogs();
                    
                }
                Catch(Exception e){
                    for(OpportunityLineItem opp :finalOpptyLIMap){
                        GAM.CreateExceptionRecords('opportunityLIUpdate', e.GetMessage(),opp.Id);
                    }
                }
            } 
        }
    }    
}