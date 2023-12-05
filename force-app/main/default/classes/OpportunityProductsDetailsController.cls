/*
Class:          OpportunityProductDetailsController
@Authors:       Bhavika
@Created Date:  
@Description:   Handler class for Opportunity Product related functions
*/

/*
Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                             Tag
Himanjan Bora     11/10/2017                       Provided comments                     Code Comments
Lokesh Kumar      30 Jan 2017    TKT-001089        Modified the SOQL by                      <T1>
                                                   adding product family field            
Chandana Gowda    5 Nov 2020     SALESRT-11547     Fetching the Opty type                    <T2>

Ranjan 			  29 Apr 2021	PSA				   Hiding AddProduct/Edit Product            <T3>
*************************************************************************************************
*/

public class OpportunityProductsDetailsController {
    
    /**
    * The method returns a boolean which is used to hide the Add Products/Edit Products button
    * for users who has been provided with the custom permission PSA_Opportunity_Product_Read_Only. 
    * 
    */
    @AuraEnabled
    public static boolean checkForCustomPermission(){
        boolean hideButtons = false; // <T3>
        if(FeatureManagement.checkPermission('PSA_Opportunity_Product_Read_Only')){
            hideButtons = true;
        }
           return hideButtons;         
    }
    
    
    /**
    * The method returns a list of Opportunity Products related to an Opportunity. Returns accordingly for 
    * a Primary and a Split opportunity.
    * @param String oppProdId - The Opportunity ID of the Opportunity
    * 
    * @return List lstOppLineItems - List of Opportunity Line Items for the given opportunity
    * @throws 
    */
    @AuraEnabled
    public static List<OpportunityLineItem> getOppotunityProductsDetails(String oppProdId){ 
        
        //list to fetch all opp line items from opp
        List<OpportunityLineItem> lstOppLineItems = new List<OpportunityLineItem>() ;
        
        //Fetch all opportunites and related opportunities
        List<Opportunity> lstOpportunity = [ Select Id, Name, Primary_or_Secondary__c, Related_Opportunity__c,
                                            (Select Id, Opportunity.CurrencyISOCode, Product2.Name, Product2.Orderable__c, Product2.Product_Family__c, Product_Family__c, Forecast_Product__c, UnitPrice, Primary__c, Orderable__c, TotalPrice, Transaction_Type__c, 
                                             LastModifiedBy.Name, LastModifiedDate, Createdby.Name, CreatedDate from OpportunityLineItems) ,
                                            (Select Id,Name,OrderableIn__c,Related_Opportunity__c, Primary_or_Secondary__c from Opportunities2__r ) 
                                            from opportunity where Id =:oppProdId limit 1] ;
        
        if(null != lstOpportunity && !lstOpportunity.isEmpty())
        {
            if(null != lstOpportunity[0].OpportunityLineItems)
            {
                lstOppLineItems.addAll(lstOpportunity[0].OpportunityLineItems);
            }
            globalApexManager GAM = new globalApexManager();
            
            //For the primary Opp, fetch all related opp fields
            if(lstOpportunity[0].Primary_or_Secondary__c == 'Primary') 
            {
                GAM.CreateLogs('getOppotunityProductsDetails',lstOpportunity[0],'OpportunityList');
                
                //set of related opp Ids
                Set<Id> stIds = new Set<Id>() ;
                if(null != lstOpportunity[0].Opportunities2__r)
                {
                    for(Opportunity secOpportunities : lstOpportunity[0].Opportunities2__r)
                    {
                        GAM.InsertDebugLogs();
                        stIds.add(secOpportunities.Id) ;
                    }
                } 
                
                //Fetch opp line item of all related opp
               // <T1> Updated the SOQL by quering Product2.Product_Family__c field </T1>
                List<OpportunityLineItem> lstSecOpportunityLi = [  Select Id, Opportunity.CurrencyISOCode, Product2.Name,Product2.Product_Family__c, Product_Family__c, Forecast_Product__c, UnitPrice, Primary__c,
                                                                 Orderable__c, TotalPrice, Transaction_Type__c , LastModifiedBy.Name, LastModifiedDate, Createdby.Name, CreatedDate from OpportunityLineItem Where OpportunityId IN : stIds ]  ;
                
                if (lstSecOpportunityLi.size() != 0) {
                    lstOppLineItems.addAll(lstSecOpportunityLi) ;
                    GAM.CreateLogs('getOppotunityProductsDetails',lstSecOpportunityLi[0],'SecOpportunityList');
                }
            }   
        }
        
        return lstOppLineItems;
    }  
    
    /**
    * The method removes an Opportunity Product from the related list on the Opportunity.
    * @param String oliId - The ID of the Opportunity Line Item
    * 
    * @return void
    * @throws 
    */
    @AuraEnabled
    public static void deleteOpportunityLineItem(String oliId) {
        globalApexManager GAM1 = new globalApexManager();
        
        try {
            OpportunityLineItem oliServer = [SELECT Id FROM OpportunityLineItem WHERE Id = :oliId LIMIT 1]; 
            if(null != oliServer)
            {
                delete oliServer; 
            }
        } 
        catch (DmlException e) {
            GAM1.CreateExceptionRecords('deleteOpportunityLineItem',e.GetMessage(),oliId);
        }
    }
    
    /**
    * Method to update and save the Opp Line items after they are added to the Opportunity
    * @param String recOppLineItem - Serialized Line Item
    * 
    * @return String
    * @throws 
    */
    @AuraEnabled
    public static String saveOpportunityLineItem(String recOppLineItem) {
        
        globalApexManager GAM2 = new globalApexManager();
        //Fetch Opp Line Item Id
        OpportunityLineItem recOppLineItem_deserialized = (OpportunityLineItem)System.JSON.deserialize(recOppLineItem,OpportunityLineItem.class);
        Id oliID = recOppLineItem_deserialized.Id; 
        
        try {
            OpportunityLineItem oliFromServer = [SELECT Id, UnitPrice, Transaction_Type__c FROM OpportunityLineItem WHERE Id = : oliID LIMIT 1];
            //Update Opp Line item fields: UnitPrice, Transaction Type
            if(null != oliFromServer)
            {
                oliFromServer.UnitPrice = recOppLineItem_deserialized.UnitPrice; 
                
                oliFromServer.Transaction_Type__c = recOppLineItem_deserialized.Transaction_Type__c != '--None--' ? recOppLineItem_deserialized.Transaction_Type__c : '';
                
                update oliFromServer;
            }
            
        }  
        catch (DmlException e) {
            GAM2.CreateExceptionRecords('saveOpportunityLineItem',e.GetMessage(),recOppLineItem_deserialized.Id);
            return e.getMessage();
        }
        return 'true';
    }
        
    
    /**
    * The method returns opportunity fields based on opp Id
    * @param String oppId - The ID of the Opportunity
    */
    @AuraEnabled
    public static Opportunity getOpportunity (String oppId) {
        return  [SELECT Id, Name, Split__c, Split_Percentage__c, Split_From__c,Type,SBQQ__RenewedContract__c FROM Opportunity WHERE Id =: oppId LIMIT 1]; //<T2>
    } 
    
    /**
    * The method returns a list of the transaction type of the Opportunity Line Items added to the Opportunity
    * @return String - list of the transaction type
    */
    @AuraEnabled
    public static String[] getTransTypeSelect () {
        String[] transTypeOps = new List<String>(); 
        transTypeOps.add('--None--'); 
        
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Transaction_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        
        for (Schema.PicklistEntry f : ple) {
            transTypeOps.add (f.getValue()); 
        }
        
        return transTypeOps; 
    }
    
    /**
    * The method calls the Sync SOP function for the given opportunity ID.
    * @param String oppId - The ID of the Opportunity
    * @return String - Return if sync successful or error
    */
    @AuraEnabled
    public static String syncSOPConnect(String oppId) {
        return syncSOPController.syncSOP(oppId); 
    }
    
    /**
    * The method calls the Sync Quote function based on method type. 
    * @param String oppId - The ID of the Opportunity
    * @param String oppSplitPrct - Split percent in case of split opportunity
    * @param String method - Method type to decide to sync Quote button is clicked on Primary/Split Opp  
    * @return String - Return if sync successful or error
    */
    @AuraEnabled
    public static String syncQuoteConnect(String oppId, Decimal oppSplitPrct, String method) {
        if (method == 'syncQuotePrimary') {
            return SyncQuoteController.syncQuotePrimary (oppId, oppSplitPrct); 
        }
        else {
            return SyncQuoteController.syncQuoteSecondary (oppId, oppSplitPrct);
        }
    }

    @AuraEnabled
    public static List<SBQQ__Subscription__c> getContractProducts(String contractId) {
        List<SBQQ__Subscription__c> lstSubscription = [SELECT Id,SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =:contractId ORDER BY Name];
        return lstSubscription;
    }    
       
}