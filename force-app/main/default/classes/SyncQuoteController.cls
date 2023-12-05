/*
Class:          SyncQuoteController
@Authors:       Rupanjana Mitra, Himanjan Bora
@Created Date:  4 August 2017
@Description:   Handler class for the button "Sync Quote" on Opportunity.
*/

/*
Change History
***************************************************************************************************************************************************************************************************************
Modified By          Date        Requested By        Description                                                                                                       Tag
***************************************************************************************************************************************************************************************************************
Rupanjana Mitra     10/10/2017                       Include new fields                                                                                       Change in Sync Quote functionality

Vivek Warrier       06-Jun-2019  Liz Matthews        Commenting out the updateOppotunityDealType                                                              <T01>
                                                     method call

Sumitkumar Mittal   16-Sept-2020 Liz Mathews         Removing the duplicate fields (TOTAL_ACV__c, 
                                                     Annual_Contract_Value_ACV__c) and replacing it
                                                     with Total_ABV__c.     
RamEsh M S          18-MAR-2021  SALESRT-12919       Original_ACV__c is not calculated on Quote Line and commenting the lines.                                 <T02>
Chandana Gowda      20-Jul-2023  SALESRT-17070       Added logic to handle Offset ACV                                                                          <T03>
***************************************************************************************************************************************************************************************************************
*/

/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/

global class SyncQuoteController {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /**
    * The method responds to the button click on "Sync Quote". If the opportunity in context is a primary opportunity
    * the method will update the field:Sales Price for all the Product Line Items associated with the opportunity
    *
    * @param String opportunityID - The Opportunity ID of the Opportunity on which Sync Quote was clicked
    * @param Decimal decOpportunitySplitPercent - The value from the field Split % in the Opportunity.
    * 
    * @return String strResult - Message containing the result of the method (Pass or Fail)
    * @throws 
    *
    */
    webService static String syncQuotePrimary(String oppId, Decimal oppSplitPrct){
        //String sResult = Label.Error_Message_SyncQuote_Primary;
        String sResult = Label.Success_Message_Sync;
        //If there is no Primary Quote on Opportunity, throw error
        List<SBQQ__Quote__c> quote=[SELECT Id FROM SBQQ__Quote__c where SBQQ__Opportunity2__c=:oppId and SBQQ__Primary__c=true];
        if(null==quote || quote.size()==0)
        {
            sResult= Label.Error_Message_No_Primary_Quote;
            return sResult;
        }
        
        //Fetch productlineitems of opportunity
        List<OpportunityLineItem> updatedOppProductList=new List<OpportunityLineItem>();
        for (OpportunityLineItem oli : [SELECT Id,UnitPrice,Total_ABV__c,Current_TCV__c FROM OpportunityLineItem WHERE OpportunityId =:oppId])
        {
            decimal total_acv=oli.Total_ABV__c;
            decimal current_tcv=oli.Current_TCV__c;
            Decimal salesPrice = getUpdatedSalesPrice(oppSplitPrct, total_acv, current_tcv);
            if (salesPrice != null && salesPrice != -1) {
                oli.UnitPrice = salesPrice;   
            }   
            updatedOppProductList.add(oli);
        }
        GAM.CreateLogs('syncQuotePrimary',updatedOppProductList,'Modified OpportunityLineItem List: ');
        Database.SaveResult[] srList = Database.update(updatedOppProductList,false);
        for(Database.SaveResult sr:srList){
            if(!sr.isSuccess())
            {
                GAM.CreateLogs('syncQuotePrimary','Error while updaing Sales Price: '+sr.getErrors());
            }
        }
        GAM.InsertDebugLogs();
        return sResult;
    }
    
    /**
    * The method responds to the button click on "Sync Quote". If the opportunity in context is a Split opportunity
    * the method will delete all the Product Line Items associated with the opportunity and then insert all the items
    * from it's Primary opportunity.
    * 
    * @param String opportunityID - The Opportunity ID of the Opportunity on which Sync Quote was clicked
    * @param Decimal opportunitySplitPercent - The value from the field Split % in the Opportunity.
    * 
    * @return String errorMessage - Message containing the result of the method (Pass or Fail)
    * @throws 
    */
    
    webService static String syncQuoteSecondary(String opportunityID, Decimal opportunitySplitPercent) {
        
        // String to find the status of the button click. This string value will be returned back to the page.
        String errorMessage = Label.Success_Message_Sync;
        
        //new check where If split opp currency code is different from primary opp currency code, throw error - START
        Opportunity opp = [SELECT Id, CurrencyIsoCode, Split_From__c, Split_From__r.CurrencyIsoCode FROM Opportunity WHERE Id =:opportunityID];
        if(null != opp.Split_From__c && null != opp.Split_From__r.CurrencyIsoCode && null != opp.CurrencyIsoCode && opp.CurrencyIsoCode != opp.Split_From__r.CurrencyIsoCode)
        {
            errorMessage = Label.Error_Message_Curreny_Code_Mismatch;
            return errorMessage;
        }
        
        //new check - END
        
        
        // Get all the product line items from the split opportunity and delete them.        
        List<OpportunityLineItem> toBeDeletedItems = [SELECT Id, Forecast_Product__c FROM OpportunityLineItem WHERE OpportunityId =:opportunityID]; 
        
        if (toBeDeletedItems != null && toBeDeletedItems.size() > 0) {
            GAM.CreateLogs('syncQuoteSecondary',toBeDeletedItems,'OpportunityLineItems to be deleted: ');
            Database.DeleteResult[] drList = Database.delete(toBeDeletedItems,false);
            for(Database.DeleteResult sr:drList){
                if(!sr.isSuccess())
                {
                    GAM.CreateLogs('syncQuoteSecondary','Errors in deleting product line items from Opportunity: '+sr.getErrors());
                }
            }
        }
        
        /* Get all the product line items from the primary opportunity and insert them in the product line list
        of the split opportunity. */
        
        // Finding the ID of the Primary Opportunity from the Split Opportunity
        List<Opportunity> opportunityList = [SELECT Split_From__c FROM Opportunity WHERE Id =:opportunityID];
        String primaryOpportunityID = opportunityList[0].Split_From__c;
        
        // Getting all the product line items associated with the Primary Opportunity
        List<OpportunityLineItem> primaryOpportunityLineItems = [SELECT PricebookEntryId,Forecast_Price__c,Statement_of_Position_SOP_Amount__c,Total_Booking_Value__c,Current_ACV__c,Current_TCV__c,Description,ListPrice,New_ACV__c,OpportunityId,Order_Product__c,Original_ACV__c,Parent__c,Product2Id,ProductCode,Quantity,Renewal_ACV__c,SBQQ__ParentID__c,SBQQ__QuoteLine__c,Total_ABV__c,Transaction_Type__c,UnitPrice,Upsell_ACV__c,Offset_ACV__c FROM OpportunityLineItem where OpportunityId =:primaryOpportunityID];
        
        // From the list of Opportunity Line Items fetched from the Primary opportunity, make a list of Opportunity Line Items
        // which will contain all the line items and then insert this list to the Split Opportunity.
        
        List<OpportunityLineItem> toBeCreatedItems = new List<OpportunityLineItem>();
        for (OpportunityLineItem item : primaryOpportunityLineItems) {
            
            OpportunityLineItem currentLineItem = new OpportunityLineItem();
            
            // The Opportunity ID should be the Split Opportunity's ID. The other details should be exact replica of the line item
            // fetched from the Primary Opportunity.
            currentLineItem.OpportunityId = opportunityID;
            
            currentLineItem.Current_ACV__c = item.Current_ACV__c;
            currentLineItem.Current_TCV__c = item.Current_TCV__c;
            currentLineItem.Description = item.Description;
            currentLineItem.New_ACV__c = item.New_ACV__c;
            currentLineItem.Order_Product__c = item.Order_Product__c;
            //currentLineItem.Original_ACV__c = item.Original_ACV__c; //<T02>
            currentLineItem.Quantity = item.Quantity;
            currentLineItem.Renewal_ACV__c = item.Renewal_ACV__c;
            currentLineItem.SBQQ__QuoteLine__c = item.SBQQ__QuoteLine__c;
            currentLineItem.Transaction_Type__c = item.Transaction_Type__c;
            currentLineItem.Upsell_ACV__c = item.Upsell_ACV__c;   
            currentLineItem.PricebookEntryId = item.PricebookEntryId;
            /*start:added new values to be copied over
            */
            currentLineItem.Total_Booking_Value__c = item.Total_Booking_Value__c;
            currentLineItem.Statement_of_Position_SOP_Amount__c = item.Statement_of_Position_SOP_Amount__c;
            currentLineItem.UnitPrice = item.Forecast_Price__c;            
            currentLineItem.Offset_ACV__c = item.Offset_ACV__c; //<T03>
            /*end:added new values to be copied over
            */
           /*
            Decimal salesPrice = getUpdatedSalesPrice(opportunitySplitPercent, currentLineItem.Total_ABV__c, currentLineItem.Current_TCV__c);
            if (salesPrice != null && salesPrice != -1) {
                currentLineItem.UnitPrice = salesPrice;   
            } 
            */
            toBeCreatedItems.add(currentLineItem);
        }
        GAM.CreateLogs('syncQuoteSecondary',toBeCreatedItems,'OpportunityLineItems to be added to split opp.: ');
        Database.SaveResult[] srList = Database.insert(toBeCreatedItems, false);
        for(Database.SaveResult sr:srList){
            if(!sr.isSuccess())
            {
                GAM.CreateLogs('syncQuoteSecondary','Error in inserting new Product Lines in the Opportunity: '+sr.getErrors());
            }
        }
       // OpportunityLineItemTriggerHandler OpptyLineItemTrigger = new OpportunityLineItemTriggerHandler();
        //OpportunityLineItemTriggerHandler.updateOppotunityDealType(toBeCreatedItems); //<T01>
        GAM.InsertDebugLogs();
        return errorMessage;
    }
    
    /** 
    * This method will return the Sales price based on the logic below.
    * 
    * If decTotalACV__C <> 0/NULL/BLANK then decTotalACV__C * Split % else decCurrentTCV__C*Split %. 
    * @param Decimal decPercent - The value of the field "Split%" from the Opportunity.
    * @param Decimal decTotalACV - The value of the field TOTAL_ACV from the Opportunity.
    * @param Decimal decCurrentTCV - The value of the field Current_TCV from the Opportunity.
    * 
    * @return Decimal - The Sales Price of the Product line item.
    * @throws 
    * 
    */
    
    public static Decimal getUpdatedSalesPrice(Decimal percent, Decimal total_ACV, Decimal current_TCV) {
        String recordId='percent: '+percent+'total_ACV: '+total_ACV+'current_TCV: '+current_TCV;
        Decimal result = 0;
        try {
            if (percent == 0) {
                result = 1 / percent;
            }
            if (null != total_ACV && total_ACV != 0) {
                result = total_ACV * percent;
                return result;
            } else if(null != current_TCV){
                result = current_TCV * percent;
                return result;
            }
        }catch (Exception ex) {
            GAM.CreateExceptionRecords('getUpdatedSalOesPrice', 'Exception occured while updating sales price' + ex.getMessage(), recordId);
            return -1;
        }
        return -1;
    }
}