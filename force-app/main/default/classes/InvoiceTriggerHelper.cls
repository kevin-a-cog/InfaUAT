/***************************************************************************
*        Name        :        InvoiceTriggerHelper
*        Author      :        Ramesh M S
*        Date        :        18-SEP-2022
*        Description :        Trigger Helper for Invoice 
****************************************************************************
Change History
**********************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                           Tag
Sreerekha		17 JUN 2023		I2C-1887			RA is not moved to ready when the overage line invoice is cancelled and rebilled      <T01>
**********************************************************************************************************************************************        */
public class InvoiceTriggerHelper {
    public static globalApexManager GAM = new globalApexManager();
    
    public static void handleCancelRebill(Set<Id> invoiceIds)
    {
        List<blng__RevenueSchedule__c> RSListToUpsert = new List<blng__RevenueSchedule__c> ();
        Map<Id,Revenue_Agreement__c> RAMapToUpdate = new Map<Id,Revenue_Agreement__c> ();
        String GTM_Model = Label.IPU_Product_GTM_Value; //I2C-1887
        
        for(blng__RevenueSchedule__c RS : [Select Id, Usage_Summary_Generated__c,Sent_to_RMCS__c,blng__OrderProduct__c,CurrencyIsoCode,Name,Revenue_Agreement__c,
                                           blng__TotalRevenueAmount__c,blng__LegalEntity__c,blng__RevenueDistributionMethod__c,blng__RevenueEndDate__c,Product__c,Percentage_Allocation__c,Quantity__c,
                                           blng__RevenueFinanceBook__c,blng__RevenueRecognitionGLRule__c,blng__RevenueRecognitionGLTreatment__c,blng__RevenueRecognitionRule__c,Parent_RS__c,
                                           blng__RevenueRecognitionTreatment__c,blng__RevenueStartDate__c,Deferred_Revenue_Acct_Date__c,Revenue_Category__c,blng__InvoiceLine__c,
                                           Ship_Date__c,Allocated_Booking__c,Allocated_Bookings__c,Extended_List_Price__c,PSFT_Contract_Line__c, ListRate__c,blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.Source__c,
                                            Revenue_Agreement__r.Stage__c, blng__InvoiceLine__r.blng__UsageSummary__c,Revenue_Agreement__r.Pre_Allocated__c,
                                            blng__InvoiceLine__r.blng__InvoiceLineStatus__c, blng__InvoiceLine__r.blng__Invoice__r.blng__InvoiceStatus__c,blng__OrderProduct__r.Product2Id, blng__OrderProduct__r.Product2.Option_Scale__c,blng__OrderProduct__r.Product2.GTM_Model__c
                                            from blng__RevenueSchedule__c where blng__InvoiceLine__r.blng__Invoice__c =: invoiceIds])
        {
            if(!RS.Sent_to_RMCS__c ){
                RS.Revenue_Agreement__c = NULL;
                RSListToUpsert.add(RS);
            }
            else if(RS.Sent_to_RMCS__c ){
                 blng__RevenueSchedule__c RSClone = RS.clone();
                 RSClone.Quantity__c = RS.Quantity__c != NULL ? RS.Quantity__c * (-1) : RS.Quantity__c;
                 RSClone.blng__TotalRevenueAmount__c = RS.blng__TotalRevenueAmount__c != NULL ? RS.blng__TotalRevenueAmount__c * (-1) : RS.blng__TotalRevenueAmount__c;
                 RSClone.Allocated_Booking__c = RSClone.blng__TotalRevenueAmount__c;
                 RSClone.Allocated_Bookings__c = RSClone.blng__TotalRevenueAmount__c; 
                 RSClone.Sent_to_RMCS__c = FALSE; 
               /* //I2C-1887 start
               if((RS.blng__OrderProduct__r?.Order?.Source__c == 'Ecommerce - Paygo') || (RS.blng__OrderProduct__r?.Product2.Option_Scale__c == 'Overage' && RS.blng__OrderProduct__r?.Product2.GTM_Model__c == GTM_Model))
                {
                  RS.Revenue_Agreement__r.Stage__c = 'Ready';
                  RS.Revenue_Agreement__r.Pre_Allocated__c = TRUE;                    
                }
                else{
                   RS.Revenue_Agreement__r.Stage__c = 'Draft';
                   RS.Revenue_Agreement__r.Pre_Allocated__c = FALSE; 
                }
                //I2C-1887 end
                 RAMapToUpdate.put(RS.Revenue_Agreement__c,RS.Revenue_Agreement__r);*/ //<T01>
                 RSListToUpsert.add(RSClone);
            }
        }
        
        if(RSListToUpsert != NULL && RSListToUpsert.size() > 0){
          //globalApexManager.avoidRecursion('RevSchBeforeInsert'); //<T01>
            globalApexManager.avoidRecursion('RevAgrrAfterUpdate');
            globalApexManager.avoidRecursion('RevAgrrBeforeUpdate');
            SBQQ.TriggerControl.disable(); // we don't need CPQ and Billing code to execute
            upsert RSListToUpsert;
          //update RAMapToUpdate.values(); //<T01>              
            SBQQ.TriggerControl.enable();                       
            
        }
    }
}