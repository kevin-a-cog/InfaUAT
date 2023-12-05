/*
Class:          QuoteBannersController
@Author:        Chandana Gowda
@Created Date:  17 Jun 2021
@Description:   Controller class for QuoteBanner LWC component - Used on Quote Record Page

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Ramya Ravi       17/09/2021        SALESRT-13272      Oct Month Build Jira  Prevent creating an Order if the Pricebook entry is inactive  <SALESRT-13272>
Singh Dayanidhee       24/12/2021        SALESRT-13282     Jan Month Build 2022  Alert to warn that start date on quote header is later than a quote line  <SALESRT-13282>
Wasim Akram      13/12/2021         SALESRT-13225       Jan 2022 Build      RTM automation for quote BillTo/ShipTo/SoldTo/EndUser          <SALESRT-13225>
Ramya Ravi       05/01/2022        SALESRT-13285      Jan Month Build Jira  Prevent quote and oppty account mismatch  <SALESRT-13285>
Ramya Ravi       01-02-2022       SALESRT-13624       To remove the related contract condition in the quote banner <SALESRT-13624>
KAPIL TILWANI 	 01-03-2022		  SALESRT-13608		  Alert to users when quote line/s start date is in past from today <SALESRT-13608>
Nishit S         11-15-2022       SALESRT-13539       Default term for all QLE lines to have at least one month         <SALESRT-13539>
Nishant          06-18-2023       SALESRT-15083       Adding Amendment Opp IPU Banner logic
Puneet          23/08/2023     SALESRT-17084        IPU Validation for all oppty & quote types                          <SALESRT-17084>
Nishant         15-09-2023                          
***********************************************************************************************************************************************************
*/
public class QuoteBannersController {
    /* Method Name : checkStartDate
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Date
    * @throws exception - NA
    * @description - Return Today's Date or Quote Start Date, whichever is greater
    */
    @AuraEnabled(cacheable=true)
    public static Date checkStartDate(Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id =:quoteId LIMIT 1];
        if(quoteRec.SBQQ__StartDate__c < System.Today()){
            return System.Today();
        }
        return quoteRec.SBQQ__StartDate__c;
    }

    /* Method Name : getQuoteLineItemsStartDate <SALESRT-13282>
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Array of Dates
    * @throws exception - NA
    * @description - Return all the start date of quote line items
    */
    @AuraEnabled(cacheable=true)
    public static Boolean getQuoteLineItemsStartDate(Id quoteId, Date headerStartDate) {
        List<SBQQ__QuoteLine__c> quoteLineRec = [ SELECT Id, SBQQ__EffectiveStartDate__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND SBQQ__EffectiveStartDate__c < :headerStartDate];
        return quoteLineRec.isEmpty();
    }

    /* Method Name : checkEarlyTerminate
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - return true if Co-Term Long banner is not be displayed on the Quote
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkEarlyTerminate(Id quoteId){
        Boolean res = false;
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id,SBQQ__Quantity__c,SBQQ__EffectiveEndDate__c,SBQQ__EndDate__c,SBQQ__UpgradedSubscription__c,SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c,SBQQ__UpgradedSubscription__r.SBQQ__TerminatedDate__c,SBQQ__Quote__r.SBQQ__EndDate__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId AND ((SBQQ__UpgradedSubscription__c != null) OR (SBQQ__UpgradedSubscription__c = null AND SBQQ__Product__r.Business_Unit__c NOT IN ('Education Services','Professional Services','Marketing')))];
        for(SBQQ__QuoteLine__c quoteLine:lstQuoteLine){
            if((quoteLine.SBQQ__UpgradedSubscription__c != null && quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__TerminatedDate__c == null && (quoteLine.SBQQ__Quantity__c != 0||quoteLine.SBQQ__EndDate__c != quoteLine.SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c)) 
            || (quoteLine.SBQQ__UpgradedSubscription__c == null && quoteLine.SBQQ__Quote__r.SBQQ__EndDate__c != quoteLine.SBQQ__EffectiveEndDate__c)){
                res =true;
                break;
            }
        }
        return res;
    }
    
    /* Method Name : checkInactivePBE  <SALESRT-13272>
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - return true if price book inactive banner should be displayed on the Quote
    * <SALESRT-13272>
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkInactivePBE(Id quoteId){
        Boolean BannerResult = false;
        List<Id> lstproducts = new List<Id>();        
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        
        // To get products, price book, currency type
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id,SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__Quote__r.CurrencyIsoCode, SBQQ__Product__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId and SBQQ__Quote__r.SBQQ__Ordered__c = false ];
        
        //Products list
        for(SBQQ__QuoteLine__c li:lstQuoteLine){
            if(li.SBQQ__Product__c!=null)
              lstproducts.add(li.SBQQ__Product__c)  ;
        }
        
        // To get list of inactive pricebook entries
        if(lstQuoteLine.size()>0 && lstproducts.size()>0)    
        {
            lstPricebookEntry = [SELECT id, Name, IsActive , Pricebook2.Name from PricebookEntry where Pricebook2.id =: lstQuoteLine[0].SBQQ__Quote__r.SBQQ__PriceBook__c and Product2Id in : lstproducts and CurrencyIsoCode =: lstQuoteLine[0].SBQQ__Quote__r.CurrencyIsoCode and IsActive = false];
        }
        //To set noBannerResult to true when the there is not inactive PBE
        if(lstPricebookEntry.size() > 0)
        {
           BannerResult =true;            
        }       
        return BannerResult;
    }
    //<SALESRT-13225>
    /* Method Name : checkParties
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
* @description - return message based on RTM value 
*/
    @AuraEnabled(cacheable=true)
    public static String checkParties(Id quoteId){
        SBQQ__Quote__c quoteRec = [SELECT Id,Route_To_Market__c,BillToAccount__r.RecordType.name,EndUserAccount__r.RecordType.name,ShiptToAccount__r.recordtype.name, SoldToAccount__r.RecordType.name FROM SBQQ__Quote__c WHERE Id =:quoteId LIMIT 1];
        String message = '';
        String parties = '';
        List<String> partiesList = new List<String>();
        if(quoteRec.Route_To_Market__c == Label.Direct){
            if(String.isNotBlank(quoteRec.BillToAccount__c) && quoteRec.BillToAccount__r.RecordType.name.contains(Label.ResellerDistributor)){
                partiesList.add('BILL TO');
            }
            if(String.isNotBlank(quoteRec.EndUserAccount__c) && quoteRec.EndUserAccount__r.RecordType.name.contains(Label.ResellerDistributor)){
                partiesList.add('END USER');
            }
            if(String.isNotBlank(quoteRec.ShiptToAccount__c) && quoteRec.ShiptToAccount__r.RecordType.name.contains(Label.ResellerDistributor)){
                partiesList.add('SHIP TO');
            }
            if(String.isNotBlank(quoteRec.SoldToAccount__c) && quoteRec.SoldToAccount__r.RecordType.name.contains(Label.ResellerDistributor)){
                partiesList.add('SOLD TO');
            }
        }
        else{
            if(String.isBlank(quoteRec.BillToAccount__c) || (String.isNotBlank(quoteRec.BillToAccount__c) && !quoteRec.BillToAccount__r.RecordType.name.contains(Label.ResellerDistributor))){
                partiesList.add('BILL TO');
            }
            /* Commented to accomodate the last minute changes for SALESRT-13225
            if(String.isBlank(quoteRec.SoldToAccount__c) || (String.isNotBlank(quoteRec.SoldToAccount__c) && !quoteRec.SoldToAccount__r.RecordType.name.contains(Label.ResellerDistributor))){
                partiesList.add('SOLD TO');
            }
			*/
        }
        if(!partiesList.isEmpty()){
            for(String party : partiesList){
                parties = parties + party + ','+ ' ';
            }
            parties = parties.trim().removeEnd(',');
            message = 'ROUTE TO MARKET IS '+ '\'' + quoteRec.Route_To_Market__c.toUpperCase() + '\''+ '.'+' PLEASE ENSURE'+' '+ '\'' + parties + '\'' +' ';
            if(partiesList.size () == 1)
                message = message + 'DETAIL IS UPDATED ACCORDINGLY.';
            else
                message = message + 'DETAILS ARE UPDATED ACCORDINGLY.';
        }
        return message;
    }
    //</SALESRT-13225>
    
     /* Method Name : checkaccounts  <SALESRT-13285>
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - return true if accounts mismatch banner should be displayed on the Quote
    * <SALESRT-13285> <SALESRT-13624>
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkaccounts(Id quoteId){
        Boolean BannerResult = false;
        
        // To get products, price book, currency type
        List<SBQQ__Quote__c> lstQuotes = [select id, SBQQ__Account__c,SBQQ__MasterContract__c, EndUserAccount__c, SBQQ__MasterContract__r.AccountId,SBQQ__Opportunity2__r.AccountId from SBQQ__Quote__c WHERE id =:quoteId ];
       
        //To set noBannerResult to true when the accounts mismatch
        for(SBQQ__Quote__c lstQuote:lstQuotes )
        {
          if( lstQuote.SBQQ__Account__c ==  lstQuote.SBQQ__Opportunity2__r.AccountId
             &&
             (lstQuote.EndUserAccount__c == null || 
              (lstQuote.EndUserAccount__c != null && lstQuote.EndUserAccount__c == lstQuote.SBQQ__Account__c))
             &&
               (lstQuote.SBQQ__MasterContract__c == null || 
                (lstQuote.SBQQ__MasterContract__c != null && lstQuote.SBQQ__MasterContract__r.AccountId != null && lstQuote.SBQQ__MasterContract__r.AccountId == lstQuote.SBQQ__Account__c))             
             )
          {  BannerResult = false;  }
           else
            {
               BannerResult =true;  
            }         
        }
     
        return BannerResult;
    }
    
    
    /* Method Name : checkOpptyaccounts  <SALESRT-13285>
    * @param mapNew - quoteId - Oppty RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - return true if accounts mismatch banner should be displayed on the oppty
    * <SALESRT-13285>
    */
    @AuraEnabled(cacheable=true)
    public static Boolean checkOpptyaccounts(Id quoteId){
        Boolean BannerResult = false;
        
        // To get products, price book, currency type
        List<Opportunity> lstOpptys = [SELECT Id,AccountId, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.AccountId, SBQQ__PrimaryQuote__r.SBQQ__Account__c, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.EndUserAccount__c ,SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c,  SBQQ__PrimaryQuote__r.SBQQ__MasterContract__r.AccountId from Opportunity where id =:quoteId ];
       
        //To set noBannerResult to true when the accounts mismatch
        for(Opportunity lstOppty: lstOpptys)
        {
            if(lstOppty.SBQQ__PrimaryQuote__c != null)
            {
                 if( lstOppty.AccountId ==  lstOppty.SBQQ__PrimaryQuote__r.SBQQ__Account__c
             &&
             (lstOppty.SBQQ__PrimaryQuote__r.EndUserAccount__c == null || 
              (lstOppty.SBQQ__PrimaryQuote__r.EndUserAccount__c != null && lstOppty.SBQQ__PrimaryQuote__r.EndUserAccount__c == lstOppty.SBQQ__PrimaryQuote__r.SBQQ__Account__c))
             &&
               (lstOppty.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c == null || 
                (lstOppty.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c != null && lstOppty.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__r.AccountId != null && lstOppty.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__r.AccountId == lstOppty.SBQQ__PrimaryQuote__r.SBQQ__Account__c))             
             )
          {  BannerResult = false;  }
           else
            {
               BannerResult =true;  
            }      
            }
            else
            {
                if(lstOppty.SBQQ__AmendedContract__r != null && lstOppty.SBQQ__AmendedContract__r.AccountId != null && 
                   lstOppty.SBQQ__AmendedContract__r.AccountId != lstOppty.AccountId
                  ) 
                    {  BannerResult = true;  }
                    else
                    {
                        BannerResult =false;  
                    }         
                }
        }
        return BannerResult;
     
    }

    /* Method Name : checkQuoteLineStartDate  <SALESRT-13285>
    * @param - quoteId - Quote RecordId
    * @return return - Boolean
    * @description - return true or false if any quoteLine item with effectivedate < today.
    * <SALESRT-13285>
    */

    @AuraEnabled
    public static boolean checkQuoteLineStartDate(Id quoteId){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('SalesSuperUser');
        if(!hasCustomPermission && !Test.isRunningTest()){
            return false;
        }else{
            return [SELECT count()
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c =:quoteId
                AND SBQQ__Quote__r.SBQQ__Type__c = 'Quote'
                AND SBQQ__Quote__r.SBQQ__Status__c = 'Approved'
                //AND SBQQ__Product__r.Product_Family__c = 'IPU'
                AND SBQQ__Quote__r.SBQQ__Primary__c = TRUE
                AND SBQQ__EffectiveStartDate__c < Today
                AND SBQQ__Quote__r.Backdated_Start_Date_Reason__c = NULL]  > 0 ? true : false;
        }
    }
    
    /* Method Name : checkForIPUProduct
    * @param - RecordId - Opportunity RecordId
    * @return return - Boolean
    * @description - Banner is getting displayed for all users without adding any IPU product in the record.
    * IPUE-259
    */
    @AuraEnabled (cacheable = true)
    public static String checkForIPUProduct(String recordId) {
        Opportunity oppRec = [SELECT Id,(SELECT Id FROM Estimation_Summaries__r WHERE Primary__c = true),(SELECT Id FROM OpportunityLineItems WHERE (Product2.Product_Family__c = 'IPU' OR Product2.Name LIKE '%IPU%') AND (Upsell_ACV__c > 0 OR New_ACV__c > 0 OR Offset_ACV__c > 0) LIMIT 1) FROM Opportunity WHERE Id = :recordId LIMIT 1];
        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__c, (SELECT Id FROM SBQQ__LineItems__r WHERE  SBQQ__Product__r.Product_Family__c = 'IPU' AND (Upsell_ACV__c > 0 OR New_ACV__c > 0 OR Offset_ACV__c > 0) LIMIT 1) FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: recordId AND (SBQQ__Primary__c = true OR Price_Holds__c = true)];

        if(oppRec.Estimation_Summaries__r.isEmpty() && !quoteList.isEmpty() && !quoteList[0].SBQQ__LineItems__r.isEmpty()){
            return 'FromQuote';
        }

        if(oppRec.Estimation_Summaries__r.isEmpty() && !oppRec.OpportunityLineItems.isEmpty()) {
            Boolean result = oppRec.Estimation_Summaries__r.isEmpty() && !oppRec.OpportunityLineItems.isEmpty();
            if(result){
                return 'FromOpportunity';
            }
        }

        return 'false';
    }

    @AuraEnabled (cacheable = true)
    public static boolean checkForIPUProductQuoteOnly(String recordId) {

        List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__Opportunity2__c, (SELECT Id FROM SBQQ__LineItems__r WHERE  SBQQ__Product__r.Product_Family__c = 'IPU' AND (Upsell_ACV__c > 0 OR New_ACV__c > 0 OR Offset_ACV__c > 0) LIMIT 1) FROM SBQQ__Quote__c WHERE Id =: recordId AND (SBQQ__Primary__c = true OR Price_Holds__c = true)];
        List<Estimation_Summary__c> summaries = [SELECT Id FROM Estimation_Summary__c WHERE Primary__c = true AND Opportunity__c = :quoteList[0].SBQQ__Opportunity2__c];
        
        
        if(summaries.isEmpty() && !quoteList[0].SBQQ__LineItems__r.isEmpty()){
            return true;
        }

        return false;
    }

    //SALESRT-13539 START
    /* Method Name : getQuoteLineItemsSubTermOutput SALESRT-13539
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - Return all the start date of quote line items
    */
    @AuraEnabled(cacheable=true)
    public static Boolean getQuoteLineItemsSubTermOutput(Id quoteId) {
        List<SBQQ__QuoteLine__c> quoteLines = [ SELECT Id, Sub_Term_Output__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND Sub_Term_Output__c < 1];
        return !quoteLines.isEmpty();
    }

    //SALESRT-17038
    @AuraEnabled
    public static Boolean checkOutOfSync(Id quoteId){
        List<SBQQ__Quote__c> quoteList = [
            SELECT Id, SBQQ__Opportunity2__c,CreatedDate
            FROM SBQQ__Quote__c 
            WHERE Id =: quoteId];

        if(!quoteList.isEmpty()){

            List<Contract> contractList = [SELECT Id,Amendment_Contracted_Date_Time__c FROM Contract WHERE SBQQ__RenewalOpportunity__c = :quoteList[0].SBQQ__Opportunity2__c];
            Boolean check = false;

            for(Contract contr : contractList){
                if(contr.Amendment_Contracted_Date_Time__c != null && quoteList[0].CreatedDate <= contr.Amendment_Contracted_Date_Time__c){
                    check = true;
                    break;
                }
            }
            return check;
        }
        return false;
    }
}