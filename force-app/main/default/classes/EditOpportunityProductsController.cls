/*
Class:          EditOpportunityProductController
@Authors:       Lien Ly
@Created Date:  7/25/2017 
@Description:   Controller class for EditOpportunityProducts Lighting Component for Edit Products

/*
Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                 Tag
Thejaswini           8/18/2017                      logic to Updating the transactiontype field
*************************************************************************************************
*/

/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/
public class EditOpportunityProductsController {

    public static globalApexManager GAM = new globalApexManager();
    
    /**
    * The method will get selected products to edit.
    * @param String opportunityID - The ID of the Opportunity
    * 
    * @return List oliWrapperList-List of slected OpportunityLineitems to edit
    *         List oliList -list OpportunityLineitems
    * @throws 
    */
     
    @AuraEnabled
    public static List<OpportunityLineItemWrapper> getOpportunityLineItemsWrapper (String opportunityID){

        //List of selected OpportunityLineitems to edit
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>(); 
        //List of OpportunityLineitems
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>(); 

        //oliList = [SELECT Id, Product2.Name, Product_Family__c, Forecast_Product__c, UnitPrice, Parent__c FROM OpportunityLineItem WHERE OpportunityId = : opportunityID];

        
        // Query on Opportunity and Opporutunity lineitem to fetch all opp line item, related opp from given opp
        Opportunity opportunity;
        for(opportunity opp:[SELECT Id, Primary_or_Secondary__c, OrderableIn__c,
                        (SELECT Id, Orderable__c, Opportunity.CurrencyISOCode, Product2.Name, Product2.Orderable__c, Product_Family__c, Forecast_Product__c, UnitPrice, Parent__c, Transaction_Type__c, Primary__c FROM OpportunityLineItems),
                        (SELECT Id,Name,Deal_Type__c,Primary_or_Secondary__c, OrderableIn__c FROM Opportunities2__r) 
                        FROM Opportunity WHERE Id =:opportunityID LIMIT 1]){
            
           opportunity = opp;       
        }                  
        if(opportunity != null){
            Boolean bDoNotQuerySecondary = false;
                 
            // Create main OpportunityLineItem list - This list is either 'Primary' or 'Blank'         
            for (OpportunityLineItem oli : opportunity.OpportunityLineItems) {
                
                oliList.add(oli); 
                if(oli.Product2.Orderable__c == false){
                    bDoNotQuerySecondary = true;
                }
            }

            // Query secondary OpportunityLineItem list 
            if (opportunity.Primary_or_Secondary__c == 'Primary' && bDoNotQuerySecondary != true){

                Set<Id> secondaryOppIdSet = new Set<Id>(); 

                for (Opportunity secondaryOpp : opportunity.Opportunities2__r) {
                    secondaryOppIdSet.add(secondaryOpp.Id); 
                }
                //fetch all related opp from primary opp
                List<OpportunityLineItem> secondaryOLI = [SELECT Id,Orderable__c, Opportunity.CurrencyISOCode, Product2.Name, Product_Family__c, Forecast_Product__c, UnitPrice, Parent__c, Transaction_Type__c, Primary__c FROM OpportunityLineItem WHERE OpportunityId IN : secondaryOppIdSet];
                
                for (OpportunityLineItem oli : secondaryOLI) {
                    
                    oliList.add(oli); 
                }
                GAM.CreateLogs('getOpportunityLineItemsWrapper',oliList,'SecOpportunityList');
            }
        }
        // Add all OpportunityLineItem to OpportunityLineItemWrapper class 
        for (OpportunityLineItem oli : oliList) {
            
            OpportunityLineItemWrapper oliw = new OpportunityLineItemWrapper(oli); 
            oliWrapperList.add(oliw);
            
        }

        GAM.InsertDebugLogs();
        return oliWrapperList; 
    }
    /**
    * The method will get selected products to Delete.
    * @param String toBeDeletedOLI_ID - The ID of the to be deleted records
    *        
    * @return List oliWrapperList-List of slected OpportunityLineitems to edit
    *        
    * @throws 
    */

    @AuraEnabled
    public static List<OpportunityLineItemWrapper> deleteOpportunityLineItemServer(String toBeDeletedOLI_ID, String opportunityID) {
      
        //List of slected OpportunityLineitems to edit
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>(); 
     
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Id =: toBeDeletedOLI_ID LIMIT 1]; 

        try {
            delete oli; 

            GAM.CreateLogs('deleteOpportunityLineItemServer',oli,'deleteOpportunityLineItem');
        } 
        catch (DmlException e) {
           
           GAM.CreateExceptionRecords('deleteOpportunityLineItemServer',e.GetMessage(),toBeDeletedOLI_ID);
        }
       
        oliWrapperList = getOpportunityLineItemsWrapper(opportunityID); 
        
      
        //oliWrapperList.remove(0);
        GAM.InsertDebugLogs();
        return oliWrapperList; 
    }
    
    /**
    * The method will save the OpportunityLineitems .
    * @param String oliWrapperList,opportunityID     
    * @return void
    *        
    * @throws 
    */

    @AuraEnabled
    public static string saveOpportunityLineItem(String oliWrapperList, String opportunityID) {
        List<OpportunityLineItemWrapper> oliUpdatedWrapperList_deserialized = (List<OpportunityLineItemWrapper>)System.JSON.deserialize(oliWrapperList,List<OpportunityLineItemWrapper>.class);
        //GAM.CreateLogs('saveOpportunityLineItem',oliUpdatedWrapperList_deserialized,'oliUpdatedWrapperList_deserialized List: ');
        //Set<Id> oliID = new Set<Id>(); 

        /*--comment existing code
         *  for (OpportunityLineItemWrapper oliw : oliUpdatedWrapperList_deserialized) {
            oliID.add(oliw.oli.Id); 
        }*/

        try {
            /*--comment existing code-- 
             * List<OpportunityLineItem> oliListServer = [SELECT Id, UnitPrice, Transaction_Type__c FROM OpportunityLineItem WHERE Id IN : oliID]; 
            for (OpportunityLineItem oli : oliListServer) {
                for (OpportunityLineItemWrapper oliw : oliUpdatedWrapperList_deserialized) {
                    if (oli.Id == oliw.oli.Id) {
                        oli.UnitPrice = oliw.UnitPrice; 

                        if (oliw.TransactionType != '--None--')
                            oli.Transaction_Type__c = oliw.TransactionType;
                        
                        else 
                            oli.Transaction_Type__c = ''; 
                        

                        update oli; 

                        GAM.CreateLogs('saveOpportunityLineItem',oliListServer,'SaveOpportunityLineItemRec');
                    }
                }
            }*/
           // Updated Code for edit Opportunity Products
            List<opportunityLineItem> lstForUpdateLineItems = new List<opportunityLineItem>();
            
             // play a for loop on opportunityline items for transactiontype and Unitprice update 
             
            for (OpportunityLineItemWrapper oliw : oliUpdatedWrapperList_deserialized) {
                   opportunityLineItem oOLI = new opportunityLineItem();
                    oOLI.Id = oliw.oli.Id;
                    oOLI.UnitPrice = oliw.UnitPrice; 
                      if(oliw.TransactionType != '--None--'){
                        oOLI.Transaction_Type__c = oliw.TransactionType;
                      }
                      else{ 
                        oOLI.Transaction_Type__c = ''; 
                      }   
                      lstForUpdateLineItems.add(oOLI);  
                      GAM.CreateLogs('saveOpportunityLineItem',oliw.oli,'SaveOpportunityLineItemRec');
            }
            GAM.CreateLogs('saveOpportunityLineItem',lstForUpdateLineItems,'lstForUpdateLineItems List: ');
            update lstForUpdateLineItems;
        }
        catch (DmlException e) {
           
           GAM.CreateExceptionRecords('saveOpportunityLineItem',e.GetMessage(),'error from saveOpportunityLineItem');
           return e.getMessage();
        }
        GAM.InsertDebugLogs();
        return 'true';
    }
 
   /**
    * The Method to Update Transactiontype field.   
    * @return string       
    * @throws NA
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

    public class OpportunityLineItemWrapper {

        @AuraEnabled
        public OpportunityLineItem oli {get; set;} 
        @AuraEnabled
        public Decimal UnitPrice {get; set;}
        @AuraEnabled
        public String TransactionType {get; set;}
       
        public OpportunityLineItemWrapper(OpportunityLineItem oliParam){
            oli = oliParam; 

            // Lightning does not work with oli.UnitPrice
            UnitPrice = oli.UnitPrice;
            TransactionType = oli.Transaction_Type__c; 
        }
    }
}