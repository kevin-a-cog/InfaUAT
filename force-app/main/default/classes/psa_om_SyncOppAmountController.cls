/*
@created by       : MAHESH GANTI
@created on       : 12/24/2020
@Purpose          : Controller Class to sync Opportunity PS Amount to the Budget

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                         Jira No.      Tag
Wasim           20-Sep-2022     Manoj               Quote & Budget Values Sync                          PSA-2562      <T1>
****************************************************************************************************************************
*/
public without sharing class psa_om_SyncOppAmountController {
    
    /**
    * Method called on Click of a Custom button on the Project record that will sync Primary Quote data on to the project
    * @param Id ProjectId
    * @return String : Success/Error.
    * @throws exception - NA
    */
    @AuraEnabled
    public static void syncOppAmount(Id budgId){
        if(budgId <> null){

            pse__Budget__c budjRec = [SELECT Id,CurrencyIsoCode,Name,pse__Opportunity__c,pse__Project__c,pse__Amount__c,pse__Type__c
                                        FROM pse__Budget__c WHERE ID = :budgId LIMIT 1];           
            
            /**
             *  if(budjRec.pse__Type__c<> 'Customer Purchase Order'){
                throw new AuraHandledException('Error: Budget Amount can only be updated for Budgets records Customer Purchase Order');
            }
             */
           
            Id oppId = budjRec.pse__Opportunity__c;
            if(oppId == null){
                throw new AuraHandledException('Error: There is no Opportunity Record for the Budget');
            }
            System.debug('***SOD-oppId***'+oppId);

            List<Opportunity> oppRec = new List<Opportunity>([SELECT Id,Name,Professional_Services_Total__c FROM Opportunity WHERE  Id = :oppId LIMIT 1]);
            
            System.debug('***SOD-oppRec***'+oppRec);
            /**
             * if(oppRec.isEmpty()){
                throw new AuraHandledException('Error: There is no Primary Quote related to the Project Opportunity, Cannot Sync data from Quote');
            }
             */
            //<T1> - Start
            //Get Sum of PS Expenses from the Opportunity Product
            AggregateResult[] agr = [SELECT SUM(UnitPrice) totalExpenseAmount FROM OpportunityLineItem 
                                     WHERE OpportunityId = :oppId AND Product2.Name LIKE '%Expense%' AND 
                                     Product2.Business_Unit__c = 'Professional Services' AND Product2.IsActive = TRUE];
           
            Decimal totalExpenseAmount = 0;
            Map<String,Decimal> mapCurrencyExcRate = new Map<String,Decimal>();
            //If the query returns valid value
            if(agr.size() > 0 && agr[0].get('totalExpenseAmount') != null){
                totalExpenseAmount = (Decimal) agr[0].get('totalExpenseAmount');
                //Convert the Expense Amount based on the ISOCode for the Budget
                //Get the Conversion Rate for the Currencies
                for(DatedConversionRate DCR : [SELECT Id,ConversionRate,IsoCode FROM DatedConversionRate WHERE StartDate = THIS_MONTH]){
                    mapCurrencyExcRate.put(DCR.IsoCode, DCR.ConversionRate);
                } 
                if(budjRec.CurrencyIsoCode != 'USD'){                       
                    if(mapCurrencyExcRate.get(budjRec.CurrencyIsoCode) != null)
                    totalExpenseAmount =  totalExpenseAmount * mapCurrencyExcRate.get(budjRec.CurrencyIsoCode);
                }
                totalExpenseAmount = totalExpenseAmount.setScale(0,System.RoundingMode.CEILING);
            }

            //</T1> - End
            if(oppRec.size()>0){
                try{                    
                    budjRec.pse__Expense_Amount__c =  totalExpenseAmount;//<T1>                  
                    budjRec.pse__Amount__c = oppRec[0].Professional_Services_Total__c - totalExpenseAmount; //<T1>
                    update budjRec;
                    System.debug('***SOD-budjRec***'+budjRec);
                }catch(exception e){throw new AuraHandledException('Error Saving Budget record:' + e.getMessage());}                       
            }
        }
    }
}