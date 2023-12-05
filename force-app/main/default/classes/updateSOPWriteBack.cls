/***************************************************************************************************************************************************************
 *  @Class Name: updateSOPWriteBack
 *  @Author: Ramesh M S
 *  @Date: 26 AUG 2020
 *  @Description: I2C-792 - Class to write back SOP Amount on Order Products after Revenue Agreement is set to Ready  
                            
 ****************************************************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                    Date                       Requested By                     Description                                                                                         Tag   
 
RamEsh M S                     10-AUG-2020                                                 Class to write back SOP Amount on Order Products after Revenue Agreement is set to Ready                                                   
Wasim                          20-SEP-2021                                                 Moved the SOPWriteback class from execute method to separate method                                <T01>                 
***************************************************************************************************************************************************************/
global class updateSOPWriteBack implements Queueable{
    
    public static globalApexManager GAM = new globalApexManager();
    public Set<Id> orderIds;
    
    
    global updateSOPWriteBack(Set<Id> orderIds)
    {
        this.orderIds = orderIds;
    }
    
    global void execute(QueueableContext context)
    {
        processSOPWriteback(orderIds);
    }
    //<T01>
    public static void processSOPWriteback(Set<Id> orderIds){
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>();
        Map<Id,OrderItem> orderItemMapUpdate = new Map<Id,OrderItem>();
        Map<Id,Decimal> parentChildAmount = new Map<Id,Decimal>();
        
        for(orderItem oi : [Select Id,New_Statement_of_Position_SOP_ACV__c,Renewal_Statement_of_Position_SOP_ACV__c,Statement_of_Position_SOP_Amount__c,
                            Upsell_Statement_of_Position_SOP_ACV__c,TotalPrice,SBQQ__QuoteLine__c,Product2.SBQQ__ChargeType__c,Product2.CPQ_Product_Type__c,
                            SBQQ__QuoteLine__r.Transaction_Type__c,SBQQ__QuoteLine__r.Current_ACV__c,SBQQ__QuoteLine__r.Renewal_ACV__c from OrderItem where OrderId =: orderIds])
        {
            orderItemMap.put(oi.Id,oi);
        }
        
        for(blng__RevenueSchedule__c RS : [Select Id,Allocated_Booking__c,blng__OrderProduct__c,Parent_RS__c,Parent_RS__r.blng__OrderProduct__c 
                                            from blng__RevenueSchedule__c where blng__OrderProduct__c = : orderItemMap.keySet() OR Parent_RS__r.blng__OrderProduct__c =: orderItemMap.keySet()])
        {
            system.debug('RS:'+RS);
            orderItem oi = new orderItem ();
            oi = orderItemMap.get(RS.blng__OrderProduct__c);
            system.debug('oi:'+oi);            
            system.debug('RS.Parent_RS__c:'+RS.Parent_RS__c);
            if(oi != null)
            {
                //calculateSOP(oi,RS);
                orderItemMapUpdate.put(oi.Id,calculateSOP(oi,RS.Allocated_Booking__c));
            }
            else if(RS.Parent_RS__c != null)
            {
                if(RS.Parent_RS__r.blng__OrderProduct__c != null)
                {
                    Decimal allocatedBookingAmt = RS.Allocated_Booking__c != null ? RS.Allocated_Booking__c : 0.0 ;
                    Decimal AllocatedAmt = parentChildAmount.get(RS.Parent_RS__r.blng__OrderProduct__c) != null ? parentChildAmount.get(RS.Parent_RS__r.blng__OrderProduct__c) + allocatedBookingAmt : allocatedBookingAmt;
                    parentChildAmount.put(RS.Parent_RS__r.blng__OrderProduct__c,AllocatedAmt);
                }
            }
            
        }
        
        for(Id oId : parentChildAmount.keySet())
        {
            orderItemMapUpdate.put(oId,calculateSOP(orderItemMap.get(oId),parentChildAmount.get(oId)));
        }
        
        if(orderItemMapUpdate.size() > 0)
        {
            try{
                update orderItemMapUpdate.values();
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('updateSOPWriteBack ', e.getMessage(), ' error while updating SOP Writeback from RA to Order Products.');
            } 
        }
    }
    //<T01>
    public static OrderItem calculateSOP(orderItem oi,Decimal RSAmount)
    {
                if(RSAmount == null)
                    RSAmount = 0;
                
                oi.Statement_of_Position_SOP_Amount__c = RSAmount;
                    
                if(oi.SBQQ__QuoteLine__c == null || oi.Product2.SBQQ__ChargeType__c == 'One-Time' || oi.Product2.CPQ_Product_Type__c == 'Perpetual' || oi.TotalPrice == 0)
                {
                    // Do Nothing
                }
                else if(oi.SBQQ__QuoteLine__r.Transaction_Type__c == 'New')
                {
                    oi.New_Statement_of_Position_SOP_ACV__c = RSAmount;
                }
                else if(oi.SBQQ__QuoteLine__r.Transaction_Type__c == 'Upsell')
                {
                    oi.Upsell_Statement_of_Position_SOP_ACV__c = RSAmount;
                }
                else if(oi.SBQQ__QuoteLine__r.Transaction_Type__c == 'Renewal' && oi.SBQQ__QuoteLine__r.Current_ACV__c != null && oi.SBQQ__QuoteLine__r.Current_ACV__c != 0)
                {
                    oi.Renewal_Statement_of_Position_SOP_ACV__c = (oi.SBQQ__QuoteLine__r.Renewal_ACV__c/oi.SBQQ__QuoteLine__r.Current_ACV__c) * RSAmount;
                    oi.Upsell_Statement_of_Position_SOP_ACV__c = ((oi.SBQQ__QuoteLine__r.Current_ACV__c - oi.SBQQ__QuoteLine__r.Renewal_ACV__c)/oi.SBQQ__QuoteLine__r.Current_ACV__c) * RSAmount;
                }
                
                return oi;
    }
}