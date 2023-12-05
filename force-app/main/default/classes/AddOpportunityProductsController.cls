/*
Class:          AddOpportunityProductsController
@Author:        Shweta Chadha 
@Created Date:  7/5/2017
@Description:   Controller class for OpportunityProductList Lighting component
                This is for Main custom related products list for the Hybrid deal management(opportunity)

/*
Change History
************************************************************************************************************************************
ModifiedBy              Date        	Requested By        Description                           							Tag

Himanjan				08-Dec-2017		Anil				Commenting the method "fetchOppRecordType" since now we			T01
															are using "fetchOpportunityType" to populate the field
															Transaction type in Opportunity Products.
Sumit Mittal			19-Jun-2017		QCA-1229			Updated the logic to pull the product from the Pricebook set	T02
															on the Opportunity and removing the check of isStandard

************************************************************************************************************************************
*/


public class AddOpportunityProductsController
{
    public static globalApexManager GAM = new globalApexManager();
    
    public class OppProductsWrapperClass {
        @AuraEnabled public Product2 product;
        @AuraEnabled public Map<String,List<String>> optionsMap;        
    }
    /* this method will Update the selected products 
    * @param parameter- String pillsList,List<Product2> lstProdRecords
    * @return return- void
    * @throws exception-n/a
    */
    public static void updateSelected(String pillsList,List<Product2> lstProdRecords){
        List<Product2> pillsListSelected = (List<Product2>)System.JSON.deserialize(pillsList,List<Product2>.class);
        for(Product2 objlstProdRecords: lstProdRecords){
            for(Product2 pill:pillsListSelected){
                if(objlstProdRecords.Id == pill.Id){
                    objlstProdRecords.Is_Selected__c = true;
                }
            }
        }
    }
    
    /* this method fetches record in product search bar based on keyword
    * @param parameter-String searchKeyWord,String pillsList, String fieldQry
    * @return return- List<Product2>
    * @throws exception-n/a
    */
    @AuraEnabled 
    public static List<Product2> productSearchBar(String searchKeyWord,String pillsList, String fieldQry){
        String searchKey = '%' + searchKeyWord + '%';
        List<Product2> productList = new List<Product2>();
        
        //String SOQL1 = 'Select Id,Name,Products__c,Product_Family__c,Family,Delivery_Method__c,Pricing_Business_Model__c,Processing_Engine__c from Product2 Where Name LIKE: searchKey AND Forecastable__c=True AND IsActive=True';
        String SOQL1 = 'Select ' + fieldQry + ' from Product2 Where Name LIKE :searchKey AND Forecastable__c=True AND IsActive=True order by Name';
        
        productList = Database.query(SOQL1); 
        
        //@26-06 Added this part to avoid user to select same pills again.
        GAM.CreateLogs('opportunityUpdate','pillsList: '+pillsList);
        updateSelected(pillsList,productList);
        
        try {
            GAM.InsertDebugLogs();  
        } catch(Exception e){
            for(Product2 product :productList){
                GAM.CreateExceptionRecords('productSearchBar', e.GetMessage(), product.Id);
            }
        }
        
        return  productList;
    }
    
    
    /* This method will return list of product2 records where Forecastable__c=True AND IsActive=True
    * @param parameter-string pillsList, String fieldString 
    * @return return- List<Product2>
    * @throws exception-n/a
    */
    @AuraEnabled 
    public static List<Product2> initProducts(String pillsList, String fieldString ){
        List<Product2> productList = new List<Product2>();
        
        String qry = 'SELECT ' + fieldString + ' from Product2 where Forecastable__c=True AND IsActive=True order by Name';
        productList = Database.query(qry); 
        updateSelected(pillsList,productList);
        return  productList;
    }
    /* This method will returns selected picklist value dynamically
    * @param parameter-N/a 
    * @return return- OppProductsWrapperClass 
    * @throws exception-n/a
    */
    @AuraEnabled
    public static OppProductsWrapperClass getPage () {
        OppProductsWrapperClass oppProdWrapper = new OppProductsWrapperClass();
        oppProdWrapper.optionsMap = getFieldsMapPicklists();
        return oppProdWrapper;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getFieldsMapPicklists(){
        //this map contains fieldOptions that were selected 
        Map<String,List<String>> optionsMap = new Map<String,List<String>>();        
        //List<String> fieldNamesList = new List<String>{'Product_Family__c','Products__c','Family',
        //                                            'Pricing_Business_Model__c','Processing_Engine__c'};
        List<String> fieldNamesList = new List<String>{'Product_Family__c','Forecast_Product__c','Family',
            'Pricing_Business_Model__c','Processing_Engine__c'};
                
                Schema.sObjectType sobject_type = Product2.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        
        for(String field_name : fieldNamesList){
            List<Schema.PicklistEntry> pick_list_values = new List<Schema.PicklistEntry>();
            List<String> fieldOptions = new List<String>();
            pick_list_values.addAll(field_map.get(field_name).getDescribe().getPickListValues());
            for (Schema.PicklistEntry f: pick_list_values) {
                fieldOptions.add(f.getLabel());
            }
            optionsMap.put(field_name,fieldOptions);
        }
        return optionsMap;
        
    }
    /* 21-06 modified to check if there is any products under the selected pills, to avoid to user to select the same product multiple times
    * @param parameter-String family, String forcast, String Bussiness, String family2, String engine,String pillsList, String fieldsStrQry                                       
    * @return return- List<Product2> 
    * @throws exception-n/a
    */
    @AuraEnabled
    public static List<Product2> searchProducts(String family, String forcast, String Bussiness, String family2, String engine,
                                                String pillsList, String fieldsStrQry)
    {
        List<Product2> productList = new List<Product2>();
        
        String SOQL = 'Select ' + fieldsStrQry + ' from Product2 where Forecastable__c=True AND IsActive=True';
        
        //if(forcast!=NULL && !String.isBlank(forcast))
        //    SOQL += ' AND Products__c = \''+forcast+'\' ';
        if(forcast!=NULL && !String.isBlank(forcast))
            SOQL += ' AND Forecast_Product__c = \''+forcast+'\' ';
        
        if(family != NULL && !String.isBlank(family))
            SOQL += ' AND Product_Family__c = \''+family+'\'';
        
        if(family2!=NULL && !String.isBlank(family2))
            SOQL += ' AND Family = \''+family2+'\'';
        
        SOQL += ' order by Name'; 
        productList = Database.query(SOQL);
        
        //21-06 Added this part to avoid user to select same pills again.
        List<Product2> pillsListSelected = (List<Product2>)System.JSON.deserialize(pillsList,List<Product2>.class);
        for(Product2 objlstProdRecords: productList){
            for(Product2 pill:pillsListSelected){
                if(objlstProdRecords.Id == pill.Id){
                    objlstProdRecords.Is_Selected__c= true;
                }
            }
        }
        return productList;
    }
    
    /* this method will return selected products 
    * @param parameter- string prodRecords, String oppId, String fieldStringQry
    * @return return- List<PricebookEntry>
    * @throws exception-n/a
    */
    @AuraEnabled
    public static List<PricebookEntry> getSelectedProducts(string prodRecords, String oppId, String fieldStringQry) {
        String currencyStr='';
        String Pricebook2IdStr = '';
        
        List<Opportunity> oppList = [SELECT CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE Id = :oppId];
        
        if(!oppList.isEmpty()){
            for(Opportunity opp: oppList){
                currencyStr = opp.CurrencyIsoCode;
                Pricebook2IdStr = opp.Pricebook2Id;
            }
        }
        
        List<PricebookEntry> priceSelectedProducts = new List<PricebookEntry>();
        if(!string.isBlank(prodRecords)){
            
            List<Product2> lstprodRecords = (List<Product2>)System.JSON.deserialize(prodRecords,List<Product2>.class);
            
            //Perform Operation with records 
            List<Id> selectedProdIds = new List<Id>();
            
            
            
            for(Product2 objProdRecords:lstprodRecords)
            {
                if(objProdRecords.Is_Selected__c)
                {      
                    selectedProdIds.add(objProdRecords.Id);
                }
            }
            
            String qry =    'SELECT Id,Product2Id, Pricebook2Id, Pricebook2.isStandard, ' 
                + fieldStringQry + 
                ',UnitPrice,ProductCode FROM PricebookEntry WHERE IsActive=TRUE AND Product2Id IN: selectedProdIds AND Pricebook2.IsActive=TRUE AND CurrencyIsoCode =:currencyStr AND Pricebook2id =: Pricebook2IdStr'; //T02
            priceSelectedProducts = Database.query(qry); 
        }
        
        return priceSelectedProducts;
        
    }
    /* this method will Save the selected products returned from getSelectedProducts(...)
    * @param parameter- string oppProdRecords,String oppId, String transactionType
    * @return return- void
    * @throws exception-n/a
    */
   
    @AuraEnabled
    public static String saveSelectedProducts(string oppProdRecords,String oppId, String transactionType) {
        List<OpportunityLineItem> oppProdsLst;
        if(!string.isBlank(oppProdRecords)){
            /* T02
            Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
            
            Opportunity opp = [SELECT Id,Pricebook2Id FROM Opportunity WHERE Id =: oppId]; 
            if(opp.Pricebook2Id == null || opp.Pricebook2Id != standardPB.Id){ //Vidya - 08/31/2017 - Added opp.Pricebook2Id == null, Kendra - 08/31/2017 - Added opp.Pricebook2Id != standardPB.Id
                opp.Pricebook2Id = standardPB.Id;
                try{
                    update opp;
                } catch(DMLException e){
                    GAM.CreateExceptionRecords('AddOpportunityProductsController->saveSelectedProducts',e.GetMessage(),'error while updating: ');
                }
            }
            */
            List<PricebookEntry> lstOppProdRecords = (List<PricebookEntry>)System.JSON.deserialize(oppProdRecords,List<PricebookEntry>.class);
            Map<String, String> transactionTypeMap = (Map<String, String>)System.JSON.deserialize(transactionType,Map<String,String>.class); 
            
            //Perform Operation with records 
            oppProdsLst = new List<OpportunityLineItem>();
            GAM.CreateLogs('saveSelectedProducts',oppProdsLst,'OpportunityProductsList');
            for(PricebookEntry objOppProdRecords : lstOppProdRecords) {          
                OpportunityLineItem oppProdrec = new OpportunityLineItem();
                oppProdrec.OpportunityId = oppId;
                oppProdrec.UnitPrice = objOppProdRecords.UnitPrice;
                oppProdrec.PricebookEntryId = objOppProdRecords.Id;
                
                // Assign value to Transaction Type
                String transTypeValue = transactionTypeMap.get(objOppProdRecords.Id); 
                if (transTypeValue != '--None--') 
                    oppProdrec.Transaction_Type__c = transTypeValue; 
                else 
                    oppProdrec.Transaction_Type__c = ''; 
                
                oppProdsLst.add(oppProdrec);
            }
            
            try {
                insert oppProdsLst;
            } catch (System.DmlException e) {
                GAM.CreateExceptionRecords('saveSelectedProducts', e.GetMessage(),'error while inserting oppProdsLst');
                return e.getMessage();
            }
        }
        
        //Try,Catch block for debug logs and exceptionlog, framework
        try {
            GAM.InsertDebugLogs();  
        } catch(Exception e){
            for(OpportunityLineItem oplt : oppProdsLst){
                GAM.CreateExceptionRecords('saveSelectedProducts', e.GetMessage(), oplt.Id);
            }
            return e.getMessage();
        }
        return 'true'; 
    }
    
    /** 
* Get Fields in specified FieldSet
* @param typeName - SObject Name (i.e. Account, Contact, Opportunity, etc.)
* @param fsName - FieldSet Name 
* @return List of FieldSetMember Object 
*/
    @AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
        
        return fset;
    }
    
        /** 
* Method will return transactiontype selectec products
* @param Name - n/a
* @trows exception -n/a
* @return transTypeOps 
*/
    
    @AuraEnabled
    public static List<PicklistOptions> getTransTypeSelect () {
        List<PicklistOptions> transTypeOps = new List<PicklistOptions>(); 
        
        // Add empty option 
        PicklistOptions emptyOption = new PicklistOptions ('--None--', '--None--'); 
        transTypeOps.add(emptyOption); 
        
        // Add actual piclist entries 
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Transaction_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        
        for (Schema.PicklistEntry f : ple) {
            transTypeOps.add(new PicklistOptions(f)); 
        }
        
        return transTypeOps; 
    }
    
    public class PicklistOptions {
        
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}
        
        public PicklistOptions (Schema.PicklistEntry p) {
            this.value = p.getValue(); 
            this.label = p.getLabel(); 
        }
        
        public PicklistOptions (String v, String l) {
            this.value = v; 
            this.label = l; 
        }
    }
    
    public class FieldSetMember {
        
        @AuraEnabled public Boolean DBRequired {get; set;}
        @AuraEnabled public String fieldPath {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public Boolean required {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String productFieldName {get; set; }
        
        public FieldSetMember(Schema.FieldSetMember f){
            this.DBRequired = f.getDbRequired(); 
            this.fieldPath = f.getFieldPath(); 
            this.label = f.getLabel(); 
            this.required = f.getRequired(); 
            this.type = '' + f.getType(); 
        }
    }
    
    public class DisplayProductRecords {
        
        @AuraEnabled public boolean isSelected;
        @AuraEnabled public string Name;
        @AuraEnabled public string Products;
        @AuraEnabled public string Orderable;
        @AuraEnabled public string ForecastFamily;
        @AuraEnabled public string ProductFamily;
        @AuraEnabled public string DeliveryMethod;
        @AuraEnabled public string PricingBusinessModel;
        @AuraEnabled public string ProcessingEngine;
        @AuraEnabled public string prodId;
        
        public DisplayProductRecords(){
            isSelected = false;
            Name = '';
            Products = '';
            Orderable = '';
            ForecastFamily='';
            ProductFamily='';
            DeliveryMethod='';
            PricingBusinessModel='';
            ProcessingEngine=''; 
        }
    }
    
    public class DisplayOpportunityProducts {
        @AuraEnabled public double salesPrice;
        @AuraEnabled public double changedPrice;
        @AuraEnabled public string prodName;
        @AuraEnabled public string prodFamily;
        @AuraEnabled public string prodProducts;
        @AuraEnabled public string prodId;
        @AuraEnabled public string PriceBookEnteryId; 
        
        public DisplayOpportunityProducts(){
            prodName = '';
            prodFamily='';
            prodProducts='';
            prodId='';
        }
    }
    
    
    /**
    * this method fetches the record type field for selected Opportunity
    * @param typeName - String recordId
    * @throws exception- n/a 
    * @return  fetchOppRecordType
    */
    
    // T01
    /*@AuraEnabled
    public static String fetchOppRecordType(String recordId)
    {
        if(recordId != null && recordId != ''){
            List<recordType> opp = [SELECT DeveloperName, SobjectType from recordType 
                                    where Id in (SELECT RecordTypeId FROM Opportunity where Id = :recordId )];
            if(opp != null && !opp.isEmpty()){
                return opp[0].DeveloperName;
            }
        }
        return null;
    }*/
    
    
    // T01
    /**
    * This method fetches the type field for selected Opportunity
    * @param typeName - String recordId
    * @throws exception- n/a 
    * @return Type
    */
    
    @AuraEnabled
    public static String fetchOpportunityType(String recordId) {
        if(recordId != null && recordId != ''){
            List<Opportunity> oppTypeList = [SELECT Type from Opportunity where Id = :recordId];
            if(oppTypeList != null && !oppTypeList.isEmpty()){
                return oppTypeList[0].Type;
            }
        }
        return null;
    }
    
    // T02
    /**
    * This method fetches the Pricebook Name field for selected Opportunity
    * @param typeName - String recordId
    * @throws exception- n/a 
    * @return Type
    */
    
    @AuraEnabled
    public static String fetchOpportunityPricebook(String recordId) {
        system.debug('Sumit:::'+recordId);
        if(recordId != null && recordId != ''){
            List<Opportunity> oppPricebookList = [SELECT Pricebook2.Name from Opportunity where Id = :recordId];
            if(oppPricebookList != null && !oppPricebookList.isEmpty()){
                system.debug(oppPricebookList[0].Pricebook2.Name);
                return oppPricebookList[0].Pricebook2.Name;
            }
        }
        return null;
    }
    
    
}