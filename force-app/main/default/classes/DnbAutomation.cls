/*
Class:          DnbAutomation 
@Author:        Nishit S
@Created Date:  
@Description:   
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
Nishit S        I2C-1318        D&B Functionality in the new org
Nishit S        I2C-1378        Renewal Maintenance Quote 'Credit Status' not automatically set to "Approved"       <I2C-1378>
Nishit S		I2C-1444		DnBi call failing for Net Amount value with too many decimal places					<I2C-1444>
*/

public without sharing class DnbAutomation {
    public static globalApexManager GAM = new globalApexManager();
    public static boolean futureRun = false;
    @invocableMethod(label='upsertQuoteSummary')
    public static void upsertQuoteSummary(List<Id> quoteIdList){
        if(!futureRun)
            upsertQuoteSummaryFuture(quoteIdList); //trigger future method
        
    }
    @future
    public static void upsertQuoteSummaryFuture(List<Id> quoteIdList){
        futureRun = true;
        Decimal professionalServicesTotal = 0;
        Decimal educationServicesTotal = 0;
        Decimal MainteneneceTotal = 0;
        try{
            Id quoteId = quoteIdList[0];
            SBQQ__Quote__c quote = [SELECT Id, SBQQ__NetAmount__c, SBQQ__SubscriptionTerm__c,BillToAccount__c, SBQQ__Account__c,SBQQ__Opportunity2__c, BillToContact__c, CurrencyIsoCode,
                                    (SELECT SBQQ__NetTotal__c ,SBQQ__Product__r.Business_Unit__c,SBQQ__Product__r.Forecast_Product__c 
                                     FROM SBQQ__LineItems__r WHERE  SBQQ__Product__r.Business_Unit__c = 'Professional Services' 
                                     OR SBQQ__Product__r.Business_Unit__c = 'Education Services' 
                                     OR SBQQ__Product__r.Forecast_Product__c = 'Support'
                                    )
                                    FROM SBQQ__Quote__c WHERE Id =:quoteId];
            for(SBQQ__QuoteLine__c quoteLine: quote.SBQQ__LineItems__r){
                if(quoteLine.SBQQ__Product__r.Business_Unit__c == 'Professional Services') //Calculations for PS total
                    professionalServicesTotal += quoteLine.SBQQ__NetTotal__c;
                if(quoteLine.SBQQ__Product__r.Business_Unit__c == 'Education Services')//Calculations for ES total
                    educationServicesTotal += quoteLine.SBQQ__NetTotal__c;
                if(quoteLine.SBQQ__Product__r.Forecast_Product__c == 'Support')//Calculations for maintenence total
                    MainteneneceTotal += quoteLine.SBQQ__NetTotal__c;
            }
            Quote_Summary__c quoteSummary = new Quote_Summary__c();
            List<Quote_Summary__c> quoteSummaryList = [SELECT Id,Net_Amount__c, Bill_To_Account__c, Bill_to_Account_Old__c, Net_Amount_Old__c
                                                       FROM Quote_Summary__c WHERE Quote__c = :quoteId LIMIT 1];  //Check if a Quote Summary already exists
            if(!quoteSummaryList.isEmpty()){
                quoteSummary = quoteSummaryList[0];
            }
            else{
                quoteSummary.Quote__c = quoteId;                 
            }
            quoteSummary.Quote_Id__c = quote.Id;
            quoteSummary.Account__c = quote.SBQQ__Account__c;
            quoteSummary.Opportunity__c = quote.SBQQ__Opportunity2__c;
            quoteSummary.CurrencyIsoCode = quote.CurrencyIsoCode;
            quoteSummary.Professional_Services_Revenue__c = Math.round(professionalServicesTotal); //<I2C-1378/>
            quoteSummary.Education_Services_Revenue__c = Math.round(educationServicesTotal);//<I2C-1378/>
            quoteSummary.Maintenance_Revenue__c = Math.round(MainteneneceTotal);//<I2C-1378/>
            quoteSummary.Bill_to_Account_Old__c = quoteSummary.Bill_To_Account__c;  //tracking for Chatter Notification
            quoteSummary.Bill_To_Account__c = quote.BillToAccount__c;
            quoteSummary.Bill_to_Contact__c = quote.BillToContact__c;
            
            quoteSummary.Net_Amount_Old__c = quoteSummary.Net_Amount__c != null ? Math.round(quoteSummary.Net_Amount__c) : quoteSummary.Net_Amount_Old__c;//tracking for Chatter Notification <I2C-1378/>
            quoteSummary.Net_Amount__c = Math.round(quote.SBQQ__NetAmount__c); //<I2C-1378/>
            if(quoteSummary.Net_Amount__c == (quoteSummary.Professional_Services_Revenue__c + quoteSummary.Education_Services_Revenue__c + quoteSummary.Maintenance_Revenue__c)) //Credit Check not required
                quoteSummary.Net_Amount__c = 0;        
            
            if(quoteSummary.Net_Amount__c != null && quote.SBQQ__SubscriptionTerm__c >= 12)
                quoteSummary.Net_Amount__c = Math.round((quoteSummary.Net_Amount__c * 12 ) / quote.SBQQ__SubscriptionTerm__c); //<I2C-1444> 
            
            upsert quoteSummary;
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('DnbAutomation on Quote Summary-->', ex.getMessage(), '-->' + 'error from creating Quote Summary record');
            
        }
    }    
}