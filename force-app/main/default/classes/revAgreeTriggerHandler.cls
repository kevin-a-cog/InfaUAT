/*
        Class:            revAgreeTriggerHandler
        @Author:          RamEsh M S
        @Created Date:    08 July 2020
        @Description:     I2C-659
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                 JIRA                Requested By                 Description                                                                                           Tag
Anil Solanki              08/06/2020           I2C-726              Kiran A                     Update Revenue_Agreement_Processed__c to TRUE if Revenue Agreement is moved to Ready                  <T01>
RamEsh M S                14-AUG-2020          I2C-839              Finance                     Added validation to check if Order is CMS approved and Provisioning Completed                         <T02>
                                                                                                when RA is set to Ready. 
RamEsh M S                25-AUG-2020          I2C-922              Finance                     Remove references of Type of Modification                                                             <T03>    
RamEsh M S                17-DEC-2020          I2C-1109             Finance                     Bookings Create/Update                                                                                <T04>    
RamEsh M S                17-MAR-2021          SALESRT-12863        Finance                     Check if Adjustment Reason Code is populated on -ve Amendment Order                                   <T05>                                                                                                             
Wasim            19-Jul-2021       I2C-1323        Finance            Check if Adjustment Reason Code is populated on Direct Order                      <T06>
Wasim            20-SEP-2021       SALESRT-13309    Finance            Moving SOPWriteback logic from Queueable to Batch                            <T07>
Nishit S                  18-MAY-2022           I2C-1586            Finance                     Prevent setting Revenue Agreement to Ready if Amendment Type field is not Populated on Order        <I2C-1586>  
Nishit S                6-1-2022                SALESRT-13975       Finance                     Add decimal tolerance of 0.1 to ignore the validation as exceptions                                 <T08>
Nishit S				2-1-2022				I2C-1775			Finance						Prevent setting Revenue Agreement to Ready if "Related Revenue Order" field is not Populated on Order <I2C-1775>
Nishit S				3-15-2022				I2C-1848             Finance             Flex IPU Orders - Automate the processing of Usage Generated Revenue Schedules             <I2C-1848>
********************************************************************************************************************************************************************************************************************
*/

public class revAgreeTriggerHandler
{

    public static globalApexManager GAM = new globalApexManager();
    public static void revAgrrBeforeUpdate(Map<Id,Revenue_Agreement__c> newMap,Map<Id,Revenue_Agreement__c> oldMap)
    {
        Set<Id> revAgrIds = new Set<Id> ();
        
        for(Revenue_Agreement__c revAgrr : newMap.values())
        {
            if(revAgrr.Stage__c == 'Draft' && oldMap.get(revAgrr.Id).Stage__c != 'Draft')
            {
                newMap.get(revAgrr.Id).Pre_Allocated__c = FALSE;
                //newMap.get(revAgrr.Id).Type_of_Modification__c = null;
                newMap.get(revAgrr.Id).Manual_Allocation__c = FALSE;
                revAgrIds.add(revAgrr.Id);
             }
             
             if(revAgrr.Term_for_convenience__c && !revAgrr.Force_Error__c && revAgrr.Term_for_convenience__c != oldMap.get(revAgrr.Id).Term_for_convenience__c)
                 revAgrr.Force_Error__c = TRUE;
                
        }
        
        if(!revAgrIds.isEmpty())
            resetValonDraft(revAgrIds);
            
    
    }
    
    public static void revAgrrAfterUpdate(Map<Id,Revenue_Agreement__c> newMap,Map<Id,Revenue_Agreement__c> oldMap)
    {
        /*for(AggregateResult AR : [SELECT Revenue_Agreement__r.Id revId,SUM(blng__TotalRevenueAmount__c)total,SUM(Allocated_Booking__c)manual,SUM(Allocated_Bookings__c)engine FROM blng__RevenueSchedule__c WHERE Revenue_Agreement__c =: newMap.keySet() GROUP BY Revenue_Agreement__r.Id ])
        {
            Id revAgrrId = (Id) AR.get('revId');
            Decimal TotalAmt = (Decimal) AR.get('total');
            Decimal AllocatedAmt = (Decimal) AR.get('manual');
            String revCurr = newMap.get(revAgrrId).CurrencyIsoCode;
            if(AllocatedAmt != TotalAmt && newMap.get(revAgrrId).Stage__c == 'Ready')
                newMap.get(revAgrrId).addError('Sum of Total Billed Amount ( ' + revCurr + ' ' + TotalAmt + ' ) of all Revenue Schedules is not equal to Sum of Allocated Bookings ( ' + revCurr + ' ' + AllocatedAmt + ' ). ' + 'There is difference of ' + revCurr + ' ' + (TotalAmt - AllocatedAmt));
        }*/
        Set<Id> revAgrIdsReady = new Set<Id>();
        Set<Id> revAgrIdsB = new Set<Id> ();
        
        for(Revenue_Agreement__c revAgrr : newMap.values())
        {
            if(revAgrr.Stage__c == 'Ready' && oldMap.get(revAgrr.Id).Stage__c != 'Ready')
            {
                revAgrIdsReady.add(revAgrr.Id);
            }
            
            if(revAgrr.Stage__c == 'Allocation Validated' && oldMap.get(revAgrr.Id).Stage__c != 'Allocation Validated') //<T04>
                revAgrIdsB.add(revAgrr.Id);
            
        }
        
        if(revAgrIdsReady.size() > 0) //<T01>
            updateOrder(revAgrIdsReady,newMap);
            
        if(revAgrIdsB.size() > 0)  //<T04>
            revSchTriggerHandler.createUpdateBookings(revAgrIdsB,'Revenue Agreement');
    }
    
    /*
    This method reset values on Revenue Schedules when the Revenue Agreement Stage is set to Draft.
    This is defined as @future as the fields that are reset used in Roll Up Helper to update values back on Revenue Agreement and records SELF_REFERENCE_FROM_TRIGGER cannot be updated Real-Time.
    */
    @future
    public static void resetValonDraft(Set<Id> revAgrIds)
    {
        List<blng__RevenueSchedule__c> RSListToUpdate = new List<blng__RevenueSchedule__c> ();
        for(blng__RevenueSchedule__c RS : [Select Id,Allocated_Booking__c,Allocated_Bookings__c,Sent_to_RMCS__c,Status__c from blng__RevenueSchedule__c where Revenue_Agreement__c =: revAgrIds AND Sent_to_RMCS__c = FALSE])
        {
             RS.Allocated_Booking__c = null;
             RS.Allocated_Bookings__c = null;
             //RS.Status__c = RS.Delta_Line__c ? 'Inactive' :  RS.Status__c ;
             RSListToUpdate.add(RS);   
        }
        if(RSListToUpdate.size() > 0)
        {
            try{
                update RSListToUpdate;
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('resetValonDraft', e.getMessage(), 'error from revAgreeTriggerHandler');
            } 
        }    
    }
    // <T01>
    //This Method will update revnue agreement processed to TRUE on ORDER once the Revenue Agreement is set to READY
    public static void updateOrder(Set<Id> revAgrIdsReady,Map<Id,Revenue_Agreement__c> newMap){
        Boolean isAdmin = FeatureManagement.checkPermission('SystemAdmin'); //<I2C-1848> skipping validations for System Admin
        List<Order> ordersToUpdate = new List<Order>();
        //Set<Id> orderIds = new Set<Id> ();  <T07>
        for(Related_Order_and_Contract__c rca : [Select Id,Order__c,Order__r.SBQQ__Quote__c,Order__r.OrderNumber,Order__r.CMS_Approved__c,
                                                 Order__r.Provisioning_Complete_Date__c,Order__r.Status,Order__r.Revenue_Agreement_Processed__c,
                                                 Order__r.Type,Order__r.TotalAmount,Order__r.Adjustment_Reason_Code__c, Order__r.Amendment_Type__c, 
                                                 Revenue_Agreement__c, Revenue_Agreement__r.Business_Model__c, Order__r.Related_Revenue_Orders__c 
                                                 from Related_Order_and_Contract__c where Revenue_Agreement__c IN: revAgrIdsReady]){
            //<I2C-1586> START
            if(rca.Order__r.Status != 'Cancelled' && rca.Order__r.Type == 'Amendment' && rca.Order__r.Amendment_Type__c == NULL && !isAdmin) //<I2C-1586> and <I2C-1848>
            {
               newMap.get(rca.Revenue_Agreement__c).addError(GAM.DisplayErrorMessage('RAReadyWithoutAmendmentType')); //<I2C-1586> Changed to use GAM.DisplayErrorMessage
            }
            //<I2C-1586> END
            //<I2C-1775> START 
            if(!isAdmin && rca.Order__r.Type == 'Amendment' && rca.Order__r.Status != 'Cancelled' && (rca.Order__r.Amendment_Type__c == NULL || rca.Order__r.Amendment_Type__c == 'Partial Cancellation' 
                                                    || rca.Order__r.Amendment_Type__c == 'Full Cancellation' || rca.Order__r.Amendment_Type__c == 'Swap'
                                                   || rca.Order__r.Amendment_Type__c == 'Debook/Rebook' ) && rca.Order__r.Related_Revenue_Orders__c == NULL) //<I2C-1586>
            {
               newMap.get(rca.Revenue_Agreement__c).addError(GAM.DisplayErrorMessage('RAReadyWithoutRelated')); //<I2C-1586> Changed to use GAM.DisplayErrorMessage
            }
                                                    
            //<I2C-1775> END
                        
            if(rca.Order__r.Status != 'Cancelled' && (!rca.Order__r.CMS_Approved__c || rca.Order__r.Provisioning_Complete_Date__c == null) && !isAdmin) //<T02> and //<I2C-1848>
            {
               newMap.get(rca.Revenue_Agreement__c).addError( GAM.DisplayErrorMessage('RAReadyWithoutCMS&Provisioning1') + rca.Order__r.OrderNumber + GAM.DisplayErrorMessage('RAReadyWithoutCMS&Provisioning2')); //<I2C-1586> Changed to use GAM.DisplayErrorMessage
            }
            else if(rca.Order__r.Revenue_Agreement_Processed__c == False && rca.Order__r.Status != 'Cancelled')
            {
                if(!isAdmin && ((rca.Order__r.Type == 'Amendment' && Math.abs(rca.Order__r.TotalAmount) > 0.1 && rca.Order__r.TotalAmount < 0 && rca.Order__r.Adjustment_Reason_Code__c == null) //<T05> <T08> <I2C-1848>
                   ||(rca.Order__r.SBQQ__Quote__c == null && Math.abs(rca.Order__r.TotalAmount) > 0.1 && rca.Order__r.TotalAmount < 0 && rca.Order__r.Adjustment_Reason_Code__c == null)))//<T06> <T08> Added condition for adding decimal tolerance of 0.1 to ignore the validation as exceptions
                {
                    newMap.get(rca.Revenue_Agreement__c).addError(GAM.DisplayErrorMessage('RAReadyWithoutAdjustmentReasonCode1')  + rca.Order__r.OrderNumber + GAM.DisplayErrorMessage('RAReadyWithoutAdjustmentReasonCode2'));
                }
                else{
                    rca.Order__r.Revenue_Agreement_Processed__c = TRUE;
                    ordersToUpdate.add(rca.Order__r);
                    //orderIds.add(rca.Order__c);  <T07>
                }
            }
        }
        System.debug('@@@@@@@OrdersToUpdate' + ordersToUpdate);
        if(ordersToUpdate.size() > 0){            
                //updateSOPWriteBack updateJob = new updateSOPWriteBack(orderIds);  <T07>
                //ID jobID = System.enqueueJob(updateJob);  <T07>
                update ordersToUpdate;             
        }
    }
}