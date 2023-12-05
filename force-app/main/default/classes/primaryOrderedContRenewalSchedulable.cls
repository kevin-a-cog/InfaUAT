/********************************************************************************************************************************************************************
 *  @Class Name: primaryOrderedContractedRenewalSchedulable
 *  @Author: Ramesh M S
 *  @Date: 15 MAY 2021
 *  @Description: Class to process Large Quotes/Order/Contracts. 
 * I2C-1022
 ********************************************************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy                Date              Requested By                               Description                                                             Tag   
 Wasim                     4-JAN-2022        Production Bug Fix - SALESRT-13411         False update on Quote calculation field after 3 minutes                 <T01>
 Wasim                    25-FEB-2022        I2C-1509                                   Capture the Earliest start date and Latest End Date for every order     <T03>
 Ramya Ravi               09-05-2022         I2C-1506                                   CPQ Invoice Acceleration automation & Default Bill Feq='Invoice Plan'   <I2C-1506>
                                                                                        for Order with products having different dates          

*********************************************************************************************************************************************************************/
public class primaryOrderedContRenewalSchedulable implements Schedulable{

    private String actionType;
    private String objectType;
    private Set<Id> recordIds;
    public static globalApexManager GAM = new globalApexManager();
    
    public primaryOrderedContRenewalSchedulable (String actionType, String objectType, Set<Id> ids) {    
        this.actionType = actionType;
        this.objectType = objectType;
        this.recordIds = ids;        
    }
    
    public class DateClass{
        public Date startDate {get; set;}
        public Date endDate {get; set;}
    }
    
    public void execute(SchedulableContext sc) {
      
        if(objectType == 'Order' && actionType == 'Set Order Date and Custom Bill Plan'){            
            //<T03> start
            Map<Id,Order> orderMap = new Map<Id,Order>();
            for(AggregateResult res : [SELECT min(EndDate) minEDate, max(EndDate) maxEDate,min(ServiceDate) minSDate, max(ServiceDate) maxSDate, OrderId orderId , min(Order.TotalAmount) totalAmount, min(TotalPrice) totalPrice, min(Order.Type) orderType, min(Order.Override_Billing_Frequency__c) overrideBF FROM OrderItem WHERE OrderId IN:recordIds GROUP BY OrderId])//<I2C-1506>
            {
                Date maxEndDate = Date.valueOf(res.get('maxEDate'));
                Date minEndDate = Date.valueOf(res.get('minEDate'));             //<I2C-1506>
                Date maxStartDate = Date.valueOf(res.get('maxSDate'));           //<I2C-1506>
                Date minStartDate = Date.valueOf(res.get('minSDate'));
                String orderId = String.ValueOf(res.get('orderId'));
                Decimal totalAmount = (decimal)res.get('totalAmount');           //<I2C-1506>
                Decimal totalPrice = (decimal)res.get('totalPrice');             //<I2C-1506>
                String orderType = String.valueOf(res.get('orderType'));         //<I2C-1506>
                String overrideBF = String.valueOf(res.get('overrideBF'));
                orderMap.put(orderId, new Order(Id=orderId, Revenue_Start_Date__c = minStartDate, Revenue_End_Date__c = maxEndDate)); 
                //considering single order record will be encountered //<I2C-1506>
                if( ((orderType!=null && (orderType=='New' || orderType=='Renewal')) &&
                    (maxEndDate!=minEndDate || maxStartDate!=minStartDate))
                    || 
                   (totalAmount!=null && totalAmount > 0 && totalPrice!=null && totalPrice < 0))//<I2C-1506>
                {
                    if(overrideBF == null)
                        UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(orderId,'Invoice_Plan_OnActivation',false);
                }//<I2C-1506>
            }
            if(orderMap.size() > 0)
            {
                try{                
                    
                    SBQQ.TriggerControl.disable();
                        update orderMap.values();
                    SBQQ.TriggerControl.enable();
                    
                } 
                catch(Exception e)
                {
                    GAM.CreateExceptionRecords('primaryOrderedContRenewalSchedulable class', e.getMessage(), 'Error while updating Rev StartDate_EndDate');          
                }            
            } 
            //<T03> end                                             
        }        
        //<T01> - Added if Condition
        else if(objectType == 'Order'){
            List<OrderItem> oiListToUpdate = new List<OrderItem> ();
            
            for(OrderItem oi : [Select Id from OrderItem where Id =: recordIds AND Order.Type = 'Amendment' AND Order.Status = 'Activated' AND SBQQ__BillingFrequency__c = 'Annual' 
                                AND SBQQ__QuoteLine__c != null AND SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null AND (SBQQ__ContractAction__c = 'Quantity Increase' OR SBQQ__ContractAction__c = 'Quantity Decrease')])  
            {
                oi.SBQQ__BillingFrequency__c = 'Invoice Plan';
                oiListToUpdate.add(oi);
                
            }
            try{
                if(oiListToUpdate.size() > 0)
                {
                    SBQQ.TriggerControl.disable();
                    update oiListToUpdate;
                    SBQQ.TriggerControl.enable();
                }
            }
            catch(Exception e){GAM.CreateExceptionRecords('primaryOrderedContRenewalSchedulable class', e.getMessage(), 'Error while updating Amendment Invoice Plan');
            }
        }//<T01> - Added below code
        else if(objectType == 'Quote' && actionType == 'Full Debook Recalculation'){
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c oSBQQ_Quote : [SELECT Id,Calculate__c FROM SBQQ__Quote__c WHERE Id IN :recordIds]){
                if(oSBQQ_Quote.Calculate__c){
                    oSBQQ_Quote.Calculate__c = FALSE;
                }
                else{
                    oSBQQ_Quote.Calculate__c = TRUE;
                }                
                quoteList.add(oSBQQ_Quote);
            }
            try{
                if(!quoteList.isEmpty())
                    update quoteList;     
            }
            catch(Exception e){ GAM.CreateExceptionRecords('primaryOrderedContRenewalSchedulable class', e.getMessage(), 'Error while retriggering Quote calculation for Full Debook');
            }
        }
        //<T01>
    }
}