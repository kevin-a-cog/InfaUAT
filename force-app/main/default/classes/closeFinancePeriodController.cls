/*
Class:          closeFinancePeriodController
@Author:        RamEsh M S
@Created Date:  28-Apr-2021
@Description:   I2C-1125 - Class to close Finance Period.

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                             Tag
**********************************************************************************************************************************************************
Nishit S			08-31-2021	I2C-1345			Finance Period object moving future order's generate date to current active Period		<I2C-1345>
**********************************************************************************************************************************************************
*/

global class closeFinancePeriodController implements Database.Batchable<Sobject>
{

public static globalApexManager GAM = new globalApexManager();
public blng__FinancePeriod__c FPIdClosed;
public blng__FinancePeriod__c FPIdActive;
public blng__FinancePeriod__c FPIdFuture;

  
    global closeFinancePeriodController(List<blng__FinancePeriod__c> FPListToUpsert)
    {
        for(blng__FinancePeriod__c FP : FPListToUpsert)
        {
            if(FP.blng__PeriodStatus__c == 'Closed')
                FPIdClosed = FP;
            else if(FP.blng__PeriodStatus__c == 'Open' && FP.Active__c)
                FPIdActive = FP;
            else if(FP.blng__PeriodStatus__c == 'Open' && !FP.Active__c)
                FPIdFuture = FP;
        }
    }
    
    global List<Order> start(Database.BatchableContext bc)
    {
        List<Order> orderList = new List<Order> ();
        orderList = [Select Id from Order where Finance_Period__c =: FPIdClosed.Id AND Revenue_Agreement_Processed__c = FALSE AND Status IN ('Draft','Activated')];
        return orderList;

    }
    
    global void execute(Database.BatchableContext bc, List<Order> scope)
    {
        
        system.debug(FPIdClosed);
        system.debug(FPIdActive);
        system.debug(FPIdFuture);
        Id OrderId;
        boolean moveOrder = FALSE;
        List<Order> orderListToUpdate = new List<Order> ();
        List<Related_Order_and_Contract__c> ROCList = new List<Related_Order_and_Contract__c> ();

        if(scope != null)
            orderId = scope[0].Id;
        
        if(orderId != null)
        {
            Order ORD = [Select Id,Status,Revenue_Agreement_Processed__c,Finance_Period__c,Generate_Date__c from Order where Id =: orderId LIMIT 1]; 
            ROCList = [Select Id,Revenue_Agreement__c,Revenue_Agreement__r.Stage__c from Related_Order_and_Contract__c where Order__c =: orderId LIMIT 1];   
            
            if(ROCList.size() > 0)
            {
                if(ROCList[0].Revenue_Agreement__r.Stage__c == 'Draft' || ROCList[0].Revenue_Agreement__r.Stage__c == 'Pre-Allocate' || ROCList[0].Revenue_Agreement__c == null) 
                    moveOrder = TRUE;
            }
            else
                moveOrder = TRUE;
            
            if(moveOrder)
            {
                
                if(ORD.Generate_Date__c >= FPIdFuture.blng__PeriodStartDate__c)
                {
                    ORD.Finance_Period__c = FPIdFuture.Id;
                }
                else
                {
                    ORD.Finance_Period__c = FPIdActive.Id;
                     if(ORD.Generate_Date__c < FPIdActive.blng__PeriodStartDate__c) //<I2C-1345>
                         ORD.Generate_Date__c = FPIdActive.blng__PeriodStartDate__c;
                }
                
                orderListToUpdate.add(ORD);
            }
            
        }
        
        if(orderListToUpdate.size() > 0)
        {
            try
            {
                SBQQ.TriggerControl.disable();
                update orderListToUpdate;
                SBQQ.TriggerControl.enable();
                
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('move orders to next FP', e.getMessage(), 'error from closeFinancePeriodController Batch');
            } 
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }


    @AuraEnabled
    public static List<blng__FinancePeriod__c> onLoad(Id FPId)
    {
    
        blng__FinancePeriod__c ActiveFPId = new blng__FinancePeriod__c ();
        blng__FinancePeriod__c FutureFPId = new blng__FinancePeriod__c ();
        List<blng__FinancePeriod__c> FPList = new List<blng__FinancePeriod__c> ();
        Map<Integer,String> MonthName = new Map<Integer,String> {1=>'JAN',2=>'FEB',3=>'MAR',4=>'APR',5=>'MAY',6=>'JUN',7=>'JUL',8=>'AUG',9=>'SEP',10=>'OCT',11=>'NOV',12=>'DEC'};
        
        for(blng__FinancePeriod__c FP : [Select Id,Name,Active__c,Close_Date__c,blng__PeriodStartDate__c,blng__PeriodEndDate__c,blng__PeriodStatus__c,blng__FinanceBook__c,RecordTypeId from blng__FinancePeriod__c where blng__PeriodStatus__c = 'Open' AND blng__FinanceBook__r.Name = 'Booking' AND RecordType.Name = 'Booking' ORDER BY blng__PeriodStartDate__c ASC])
        {
            if(FP.Active__c)
                ActiveFPId = FP;
            else
                FutureFPId = FP;
        }
        
        blng__FinancePeriod__c FP = new blng__FinancePeriod__c ();
        FP.blng__PeriodStartDate__c = FutureFPId.blng__PeriodEndDate__c + 1;
        FP.blng__PeriodEndDate__c = FP.blng__PeriodStartDate__c + Date.daysInMonth(FP.blng__PeriodStartDate__c.year(), FP.blng__PeriodStartDate__c.month()) - 1;
        FP.Active__c = FALSE;
        FP.blng__PeriodStatus__c = 'Open';
        FP.blng__FinanceBook__c = FutureFPId.blng__FinanceBook__c;
        FP.RecordTypeId = FutureFPId.RecordTypeId;
        FP.Name = MonthName.get(FP.blng__PeriodStartDate__c.month()) + '-' + FP.blng__PeriodStartDate__c.year() + ' : Booking';
        
        FPList.add(ActiveFPId);
        FPList.add(FutureFPId);
        FPList.add(FP);
        return FPList;
    }
    
    @AuraEnabled
    public static void closeAndMoveOrders(Id FPId,Date CloseDate)
    {
        List<blng__FinancePeriod__c> FPListToUpsert = new List<blng__FinancePeriod__c> ();
        
        FPListToUpsert = onLoad(FPId);
        
        for(blng__FinancePeriod__c FP : FPListToUpsert)
        {
            if(FP.Id == FPId)
            {
                FP.blng__PeriodStatus__c = 'Closed';
                FP.Active__c = FALSE;
                if(FP.Close_Date__c == null || CloseDate == null)
                    FP.Close_Date__c = Date.Today();
                 else if(CloseDate != null)
                     FP.Close_Date__c = CloseDate;
            }
            else if(FP.Id != null)
            {
                FP.Active__c = TRUE;
            }
        }
        
        if(FPListToUpsert !=null)
        {
            try{
                
                SBQQ.TriggerControl.disable();
                upsert FPListToUpsert;
                SBQQ.TriggerControl.enable();
                
                closeFinancePeriodController FPBatch = new closeFinancePeriodController(FPListToUpsert);
                database.executebatch(FPBatch,1);
            }
            catch(Exception e)
            {
                GAM.CreateExceptionRecords('Finance Period Closure', e.getMessage(), 'error from closeFinancePeriodController');
                throw new AuraHandledException(e.getMessage());
            } 
        }
    }
    
}