/*
Class:          ViewAllOpportunityProductsController
@Authors:       Lien Ly
@Created Date:  
@Description:   Controller class for  ViewAllOpportunityProducts component

Change History
*************************************************************************************************
Modified By          Date        Requested By        Description                                Tag
Chandana Gowda     27-Sept-2019                     Modified the class to read the fields to    T01
                                                    be displayed from fieldSet
Ranjan 			   29 Apr 2021	PSA				   Hiding AddProduct/Edit Product            <T2>
*************************************************************************************************
*/

public class ViewAllOpportunityProductsController {

    @AuraEnabled
    public static String getOppCurrencyIsoCode(String opportunityID){
        Opportunity oppRec = [SELECT Id,CurrencyIsoCode FROM Opportunity WHERE Id = :opportunityID];
        return oppRec.CurrencyIsoCode;
    }    
     
    /**
    * The method returns a boolean which is used to hide the Add Products/Edit Products button
    * for users who has been provided with the custom permission PSA_Opportunity_Product_Read_Only. 
    * 
    */
    @AuraEnabled
    public static boolean checkForCustomPermission(){
        boolean hideButtons = false; // <T2>
        if(FeatureManagement.checkPermission('PSA_Opportunity_Product_Read_Only')){
            hideButtons = true;
        }
           return hideButtons;         
    }
    
    

    /*Method to read the fields to display from the Fieldset View all opportunity products
    * @param Name -n/a
    * @throws exception -n/a
    * @return Map<String,String> : returns Map with key being the field Label name and value being the Field API Name
    */
    //Added the method getFields to read the fields to display in the table from the Fieldset--------</T01>
    @AuraEnabled
    public static Map<String,List<String>> getFields(){
        Map<String,List<String>> mapTypefields=new Map<String,List<String>>();
        List<Schema.FieldSetMember> fs =Schema.SObjectType.OpportunityLineItem.fieldSets.View_all_opportunity_products.getFields();
        if(fs != NULL){
            for(Schema.FieldSetMember fsMember:fs){
                List<String> lst= new List<String>();
                lst.add(fsMember.getLabel());
                lst.add(String.valueOf(fsMember.getType()));
                mapTypefields.put(fsMember.getFieldPath(),lst);
            }
        }
        return mapTypefields;
    }

    /**
    * The method returns a list of Opportunity Products related to an Opportunity.
    * @param String opportunityID - The Opportunity ID of the Opportunity
    * 
    * @return List oliList - List of Opportunity Line Items for the given opportunity
    * @throws 
    */
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItemsWrapper (String opportunityID,List<String> oliColumns){

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        String oliColumnsString =String.join(oliColumns,','); 
        globalApexManager GAM = new globalApexManager();
        System.debug('oliColumnsString.....'+oliColumnsString);
        // Query Opportunity 
        Opportunity o = Database.query('SELECT Id, Name, Primary_or_Secondary__c, OrderableIn__c,(SELECT Id,'+oliColumnsString+',CreatedBy.Name,LastModifiedBy.Name,Statement_of_Position_SOP_Amount__c,TotalPrice FROM OpportunityLineItems),(SELECT Id,Name,Deal_Type__c,Primary_or_Secondary__c, OrderableIn__c FROM Opportunities2__r) FROM Opportunity WHERE Id =:opportunityID LIMIT 1');                  
    
        // Create main OpportunityLineItem list - This list is either 'Primary' or 'Blank'         
        for (OpportunityLineItem oli : o.OpportunityLineItems) {
            oliList.add(oli); 
        }

        // Query secondary OpportunityLineItem list 
        if (o.Primary_or_Secondary__c == 'Primary') {

            Set<Id> secondaryOppId = new Set<Id>(); 

            for (Opportunity secondaryO : o.Opportunities2__r) {
                secondaryOppId.add(secondaryO.Id); 
            }

            List<OpportunityLineItem> secondaryOLI =Database.query('SELECT Id,'+oliColumnsString+',CreatedBy.Name,LastModifiedBy.Name,Statement_of_Position_SOP_Amount__c,TotalPrice FROM OpportunityLineItem WHERE OpportunityId IN : secondaryOppId');
            
            for (OpportunityLineItem oli : secondaryOLI) {
                oliList.add(oli); 
            }
            GAM.CreateLogs('getOpportunityLineItemsWrapper', oliList, 'SecOpportunityList');
        }
        
        //--------------------------------------------------------------<T01>        
        /* Add all OpportunityLineItem to OpportunityLineItemWrapper class 
        for (OpportunityLineItem oli : oliList) {
            OpportunityLineItemWrapper oliw = new OpportunityLineItemWrapper(oli); 
            oliw.OpportunityName = o.Name; 
            oliWrapperList.add(oliw); 
        } //--------------------------------------------------------------</T01> */

        GAM.InsertDebugLogs();
        return  oliList;
        //return oliWrapperList;
    }

   /**
    * The method will save the OpportunityLineitems .
    * @param String oliWrapper     
    * @return void        
    * @throws
    *     @AuraEnabled
    public static void saveOpportunityLineItem (String oliWrapper) {
        OpportunityLineItemWrapper oliWrapper_deserialized = (OpportunityLineItemWrapper)System.JSON.deserialize(oliWrapper,OpportunityLineItemWrapper.class);
        Id oliID = oliWrapper_deserialized.oli.Id; 
        globalApexManager GAM1 = new globalApexManager();

        try {
            OpportunityLineItem oliFromServer = [SELECT Id, UnitPrice, Transaction_Type__c FROM OpportunityLineItem WHERE Id = : oliID LIMIT 1]; 

            oliFromServer.UnitPrice = oliWrapper_deserialized.UnitPrice; 

            if (oliWrapper_deserialized.TransactionType != '--None--')
                oliFromServer.Transaction_Type__c = oliWrapper_deserialized.TransactionType; 
            else 
                oliFromServer.Transaction_Type__c = ''; 

            update oliFromServer; 
            GAM1.CreateLogs('saveOpportunityLineItem', oliFromServer, 'SaveOpportunityLineItemRec');
        }
        catch (DmlException e) {

           GAM1.CreateExceptionRecords('saveOpportunityLineItem', e.GetMessage(), oliID);
        }
    }
    */
    //Modified the  method to use the OpportunityLineItem instead of the wrapper-------<T01>
    @AuraEnabled
    public static void saveOpportunityLineItem (OpportunityLineItem oliWrapper) {
        
        globalApexManager GAM1 = new globalApexManager();
        try {
           update oliWrapper; 
           GAM1.CreateLogs('saveOpportunityLineItem', oliWrapper, 'SaveOpportunityLineItemRec');
        }
        catch (DmlException e) {
           GAM1.CreateExceptionRecords('saveOpportunityLineItem', e.GetMessage(), oliWrapper.Id);
        }
    }

    /**
    * The method will get selected products to Delete.
    * @param String oliID - The ID of OpportunityLineItem        
    * @return List oliWrapperList-List of slected OpportunityLineitems to delete        
    * @throws
    *     @AuraEnabled
    public static List<OpportunityLineItemWrapper> deleteOpportunityLineItem (String oliID, String opportunityID) {
        List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>(); 
        globalApexManager GAM2 = new globalApexManager();

        try {
            OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Id =: oliID LIMIT 1]; 
            delete oli; 

            GAM2.CreateLogs('deleteOpportunityLineItem', oli, 'deleteOpportunityLineItem');
        } 
        catch (DmlException e) {

            GAM2.CreateExceptionRecords('deleteOpportunityLineItem', e.GetMessage(), oliID);
        }

        oliWrapperList = getOpportunityLineItemsWrapper(opportunityID); 

        return oliWrapperList; 
    } 
    */
    //Modified the method to return null instead of OpportunityLineItemWrapper-------<T01>
    @AuraEnabled
    public static void deleteOpportunityLineItem (String oliID) {
        globalApexManager GAM2 = new globalApexManager();
        try {
            OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Id =: oliID LIMIT 1]; 
            delete oli;
            GAM2.CreateLogs('deleteOpportunityLineItem', oli, 'deleteOpportunityLineItem');
        } 
        catch (DmlException e) {
            GAM2.CreateExceptionRecords('deleteOpportunityLineItem', e.GetMessage(), oliID);
        }
    }

    // Method to Update Transactiontype field 
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
    
    //------------------------------------------------------<T01>

    /*public class OpportunityLineItemWrapper {

        @AuraEnabled
        public OpportunityLineItem oli {get; set;} 
        @AuraEnabled
        public Decimal UnitPrice {get; set;}
        @AuraEnabled
        public String OpportunityName {get; set;}
        @AuraEnabled
        public String TransactionType {get; set;}
       
        public OpportunityLineItemWrapper(OpportunityLineItem oliParam){
            oli = oliParam; 

            // Lightning does not work with oli.UnitPrice
            UnitPrice = oli.UnitPrice;
            TransactionType = oli.Transaction_Type__c; 
        }
    }*/
    
    //------------------------------------------------------</T01>
}