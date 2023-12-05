/*
* Created the class for the CPQ API Testing POC
* Date : 7th Jan 2020
* Authors : Anil/Sumit
*Changes/Updates:
Sumit   8-Jun-2020      Nested Bundle enhancement(Insert and Update), POT issue fix
*/
@RestResource(urlMapping='/CPQAPIAutomationWebService/AddProductToQuote')
global class CPQAPIAutomationWebService {
    
    //Method to invoke CPQ API's in asyn mode for the insert operation of the products
    @HttpPost
    global static void runCPQApiAutomationInsert(String quoteID, 
                                                 String pricebookId, 
                                                 String currencyValue, 
                                                 String parentProdIds, 
                                                 String addOptionSKUIds, 
                                                 String removeOptionSKUids, 
                                                 String nestedChildLevelSKUids,
                                                 String nesteeChildLevelAddOptionSKUids) {
        
        //Read Quote :
        Id QuoteRecordId = ID.valueOf(quoteID);
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(QuoteRecordId);
        System.debug(quote);
        
        //Maps to store the id vs quantity parameter for the SKU's
        Map<Id, Integer> mapparentProductIdsQuantity = new Map<Id, Integer>();
        Map<Id, Integer> mapaddOptionIdsQuantity = new Map<Id, Integer>();
        Set<Id> setRemoveOptionIds = new Set<Id>();
        Set<Id> nestedLevel1SKUId = new Set<Id>();
        Map<Id, Integer> mapAddLevel1OptionIdsQuantity = new Map<Id, Integer>();
        
        //Loops to seperatet the strings into the ID and integer for processing
        for(String prodId : parentProdIds.split(';')){
            mapparentProductIdsQuantity.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfterLast(':')));
        }
        if(addOptionSKUIds != Null && addOptionSKUIds != ''){
            for(String prodId : addOptionSKUIds.split(';')){
                mapaddOptionIdsQuantity.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfterLast(':')));
            }
        }
        if(removeOptionSKUids != Null && removeOptionSKUids != ''){
            for(String prodId : removeOptionSKUids.split(';')){
                setRemoveOptionIds.add(Id.valueOf(prodId));
            }
        }
        if(nestedChildLevelSKUids != Null && nestedChildLevelSKUids != ''){
            for(String prodId : nestedChildLevelSKUids.split(';')){
                nestedLevel1SKUId.add(Id.valueOf(prodId));
            }
        } 
        if(nesteeChildLevelAddOptionSKUids != Null && nesteeChildLevelAddOptionSKUids != ''){
            for(String prodId : nesteeChildLevelAddOptionSKUids.split(';')){
                mapAddLevel1OptionIdsQuantity.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfterLast(':')));
            }
        }                                             
        
        system.debug('mapparentProductIdsQuantity ='+mapparentProductIdsQuantity);        
        system.debug('mapaddOptionIdsQuantity keyset='+mapaddOptionIdsQuantity.keyset());
        system.debug('mapaddOptionIdsQuantity values='+mapaddOptionIdsQuantity.values());
        
        //Declare the productmodel list to store all the product bundle w.r.t parentproductid received
        List<ProductModel> listProductModels = new List<ProductModel>();
        
        //Read Product :
        for(Id prodId : mapparentProductIdsQuantity.keyset()) {
            ProductModel product = new ProductModel();
            ProductReader productReader = new ProductReader();
            product = productReader.read(prodId,pricebookId,currencyValue);
            listProductModels.add(product);
        }
        //Collection variable of ProductModel to store newly created CM's
        List<ProductModel> updatedProductModels = new List<ProductModel>();
        
        //Updating the configuration of the Parent product with additional options ---- START
        for(ProductModel product : listProductModels) {
            List<ConfigurationModel> updatedConfigModels = new List<ConfigurationModel>();
            for(OptionModel optionModel : product.options) {
                System.debug('&&&&&' + optionModel);
                if(mapaddOptionIdsQuantity != Null && 
                   mapaddOptionIdsQuantity.size() > 0 && 
                   (mapaddOptionIdsQuantity.Containskey(optionModel.record.SBQQ__OptionalSKU__c))){
                       //Add the option into the parent bundle
                       product.configuration.optionConfigurations.add(returnConfigModel(optionModel,mapaddOptionIdsQuantity,nestedLevel1SKUId, mapAddLevel1OptionIdsQuantity, pricebookId, currencyValue));
                   }
            }
            if(product.configuration != null){
                product.configuration.configured = true;
                product.configuration.configurationEntered = true;
                for(ConfigurationModel configModel : product.configuration.optionConfigurations) {
                    if(setRemoveOptionIds != Null &&
                       setRemoveOptionIds.Contains(configModel.configuredProductId)) {
                           continue;
                       }
                    configModel.configured = true;
                    configModel.configurationEntered = true;
                    updatedConfigModels.add(configModel);
                }
                product.configuration.optionConfigurations.clear();
                product.configuration.optionConfigurations.addall(updatedConfigModels);
            }
            //List of updated product bundles to be added to the quote
            updatedProductModels.add(product);
        }
        
        //Updating the configuration of the Parent product with additional options ---- END
        
        //Add product :
        ProductAdder adder = new ProductAdder();
        QuoteModel quoteWithProducts = adder.add(quote, updatedProductModels, 0);  // THIS LINE IS GETTING THE EXCEPTION
        System.debug(quoteWithProducts);
        
        //Validate the Quote if any errors then msgs will have all the errors list : 
        Validator validator = new Validator();
        List<String> msgs = validator.validate(quoteWithProducts);
        System.debug(msgs);
        
        //Calculate and Save the Quote :
        
        //Collection variable to store the updated Quotelinemodel from below loop:
        List<QuoteLineModel> updatedQuoteLineModels = new List<QuoteLineModel>();
        
        //Update the quantity of the Quote lines in the Quote  -- START
        for(QuoteLineModel ql : quoteWithProducts.lineItems) {
            system.debug('&&&&&& ==='+ql.record);
            if(mapparentProductIdsQuantity.containsKey(ql.record.SBQQ__Product__c) ) {
                ql.record.SBQQ__Quantity__c = mapparentProductIdsQuantity.get(ql.record.SBQQ__Product__c);
            } 
            updatedQuoteLineModels.add(ql);
        }
        quoteWithProducts.lineItems.clear();
        quoteWithProducts.lineItems.addall(updatedQuoteLineModels);
        //Update the quantity of the Quote lines in the Quote  -- END
        
        //SAVE AND CALCULATE the final quote                                           
        QuoteCalculator calculator = new QuoteCalculator();
        calculator.calculate(quoteWithProducts, 'MyCallback');
    }
                                                 
                                                 
    //Method to invoke CPQ API's in asyn mode for the update operation of the products
    @HttpPatch
    global static void runCPQApiAutomationUpdate(String quoteID, 
                                                 String updateProdIdsQuantity, 
                                                 String updateProdIdsDiscount) {
        
        //Read Quote :
        Id QuoteRecordId = ID.valueOf(quoteID);
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(QuoteRecordId );
        System.debug(quote);
        
        //Maps to store the id vs quantity parameter for the SKU's
        Map<Id, Integer> mapparentProductIdsQuantity = new Map<Id, Integer>();
        Map<Id, Integer> mapparentProductIdsDiscount = new Map<Id, Integer>();
        
        //Loops to seperatet the strings into the ID and integer for processing
        if(updateProdIdsQuantity != Null  && updateProdIdsQuantity != '') {
            for(String prodId : updateProdIdsQuantity.split(';')){
                mapparentProductIdsQuantity.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfterLast(':')));
            } 
        }
        if(updateProdIdsDiscount != Null  && updateProdIdsDiscount != '') {
            for(String prodId : updateProdIdsDiscount.split(';')){
                mapparentProductIdsDiscount.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfterLast(':')));
            } 
        }
        
        //Collection variable to store the updated Quotelinemodel from below loop:
        List<QuoteLineModel> updatedQuoteLineModels = new List<QuoteLineModel>();
        
        //Update the quantity of the Quote lines in the Quote  -- START
        for(QuoteLineModel ql : quote.lineItems) {
            system.debug('&&&&&& ==='+ql.record);
            if(mapparentProductIdsQuantity != Null && mapparentProductIdsQuantity.containsKey(ql.record.SBQQ__Product__c) ) {
                ql.record.SBQQ__Quantity__c = mapparentProductIdsQuantity.get(ql.record.SBQQ__Product__c);
                ql.record.SBQQ__BundledQuantity__c = mapparentProductIdsQuantity.get(ql.record.SBQQ__Product__c);
            }
            if(mapparentProductIdsDiscount != Null && mapparentProductIdsDiscount.containsKey(ql.record.SBQQ__Product__c) ) {
                ql.record.SBQQ__Discount__c = mapparentProductIdsDiscount.get(ql.record.SBQQ__Product__c);
            }
            updatedQuoteLineModels.add(ql);
            
        }
        quote.lineItems.clear();
        quote.lineItems.addall(updatedQuoteLineModels);
        //Update the quantity of the Quote lines in the Quote  -- END
        
        QuoteCalculator calculator = new QuoteCalculator();
        calculator.calculate(quote, 'MyCallback');
    }
    
    private static ConfigurationModel returnConfigModel(OptionModel optionM,Map<id, Integer> mapaddOptionIdsQuantity, Set<id> nestedLevel1SKUId, map<id,Integer> mapAddLevel1OptionIdsQuantity, Id pricebookId, String currencyValue ){
        ConfigurationModel cm = new ConfigurationModel();
        cm.configuredProductId = optionM.record.SBQQ__OptionalSKU__c;
        //Updating the quantity of the options being added.
        if(mapaddOptionIdsQuantity != null && mapaddOptionIdsQuantity.containsKey(optionM.record.SBQQ__OptionalSKU__c)) {
            optionM.record.SBQQ__Quantity__c = mapaddOptionIdsQuantity.get(optionM.record.SBQQ__OptionalSKU__c);
        }
        cm.optionData = optionM.record;
        cm.configurationData = new SBQQ__ProductOption__c();
        cm.configured = false;
        cm.isDynamicOption = false;
        cm.optionId = optionM.record.Id;
        cm.priceEditable = false;
        cm.optionConfigurations = new List<ConfigurationModel>();
        
        //Adding the child options
        if(nestedLevel1SKUId.contains(optionM.record.SBQQ__OptionalSKU__c)) {
            ProductModel childProduct = new ProductModel();
            ProductReader productReader = new ProductReader();
            childProduct = productReader.read(optionM.record.SBQQ__OptionalSKU__c,pricebookId,currencyValue);
            
            for(OptionModel optionModelLevel_1 : childProduct.options) {
                if(mapAddLevel1OptionIdsQuantity != Null && 
                   mapAddLevel1OptionIdsQuantity.size() > 0 && 
                   mapAddLevel1OptionIdsQuantity.Containskey(optionModelLevel_1.record.SBQQ__OptionalSKU__c)) {
                       //Add the option into the parent bundle
                       cm.optionConfigurations.add(returnConfigModel(optionModelLevel_1,mapAddLevel1OptionIdsQuantity, nestedLevel1SKUId, mapAddLevel1OptionIdsQuantity, pricebookId, currencyValue));
                   }
            }
        }
        
        return cm;
    }
}