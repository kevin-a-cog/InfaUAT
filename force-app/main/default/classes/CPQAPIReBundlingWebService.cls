/*
Class:          CPQAPIReBundlingWebService
@Author:        Anusha Akella
@Created Date:  4/24/2022
@Description:   This is used for testing Purposes toupdate Quoteline Parameters.
*/
@RestResource(urlMapping='/CPQAPIReBundlingWebService/UpdateToBundle')
global class CPQAPIReBundlingWebService {
    
    @InvocableMethod(label='Call CPQ API' description='API to add Products to the Quote')
    global static void runCPQAPIForBundlingFlow(List<QuoteParams> params) {
        
        runCPQAPIForBundling(params[0]); 
    }
    
    @HttpPost
    global static void runCPQAPIForBundling(QuoteParams params) {
        system.debug('input parameters'+params);                                         
        Id QuoteRecordId = ID.valueOf(params.quoteID);
        QuoteReader quoteReader = new QuoteReader();
        QuoteModel quote = quoteReader.read(QuoteRecordId);
        
        Id parentQLId;
        Decimal parentQuantity;
        Decimal parentDiscount;
        Map<Id, Integer> optionProdQuantityMap = new Map<Id, Integer>();
        Map<Id, Integer> optionProdDiscountMap = new Map<Id, Integer>(); //Self Quote - Map for discount
        Set<Id> setRemoveOptionIds = new Set<Id>();
        //List<ProductModel> listProductModels = new List<ProductModel>();
        List<ProductModel> updatedProductModels = new List<ProductModel>();
        Set<Id> qleDeleteIds = new Set<Id>();
        Map<Id,QuoteLineModel> existingQLIMap = new Map<Id,QuoteLineModel>();
        //to Map product Id and subscription Id
        Map<Id,Id> subLinesMap = new Map<Id,Id> ();
        
        try{
            Map<String, quoteLineItemParams> mapQLI = new Map<String, quoteLineItemParams> ();
            if(params.quoteLineItemdParamsList != Null) {
                for(quoteLineItemParams qliParam: params.quoteLineItemdParamsList) {
                    if(String.isNotBlank(qliParam.optionProductId)) {
                        mapQLI.put(qliParam.optionProductId, qliParam);
                    }
                }
            }
            
            //quote.lineItems - Existing line items.
            for (QuoteLineModel qle : quote.lineItems) {
                if (qle.record.SBQQ__Product__c == params.parentProdId) {
                    parentQLId = qle.record.Id;
                    qleDeleteIds.add(qle.record.Id);
                    break;
                }  
            }
            // find all the related child records which are part of bundle.
            for (QuoteLineModel qle : quote.lineItems) {
                
                existingQLIMap.put(qle.record.SBQQ__Product__c,qle);
                if (parentQLId != Null && qle.record.SBQQ__RequiredBy__c == parentQLId) {
                    optionProdQuantityMap.put(qle.record.SBQQ__Product__c, Integer.valueOf(qle.record.SBQQ__Quantity__c));
                    qleDeleteIds.add(qle.record.Id);
                }
            }
            system.debug('Subscriptionline'+existingQLIMap);
            system.debug('addOptionSKUIds'+params.addOptionSKUIds);
            //Check for new options(Child Prod) to be added/add quantity for existing options.
            if(String.isNotBlank(params.addOptionSKUIds)) {
                for (String prodId : params.addOptionSKUIds.split(';')) {
                    if (optionProdQuantityMap.containsKey(Id.valueOf(prodId.substringBefore(':')))) {
                        //Integer previousVal = optionProdQuantityMap.get(Id.valueOf(prodId.substringBefore(':')));
                        optionProdQuantityMap.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfter(':')));
                    } else {
                        optionProdQuantityMap.put(Id.valueOf(prodId.substringBefore(':')),Integer.valueOf(prodId.substringAfter(':')));
                    }  
                }
            }
            
            ProductModel product = new ProductModel();
            ProductReader productReader = new ProductReader();
            product = productReader.read(params.parentProdId,params.pricebookId,params.currencyValue);
            //FeatureModel feature = new FeatureModel();
            
            //listProductModels.add(product);
            List<ConfigurationModel> updatedConfigModels = new List<ConfigurationModel>();
            Map<String, FeatureModel> mapProdFeature = new Map<String, FeatureModel>();
            
            for(FeatureModel feature : product.features) {
                mapProdFeature.put(feature.record.Id,feature);
            }
            
            for(OptionModel optionModel : product.options) {
                system.debug('optionModel :'+optionModel);
                if ((!optionProdQuantityMap.isEmpty())) {
                    
                    //if (optionModel.record.SBQQ__Selected__c && optionModel.record.SBQQ__Bundled__c && mapProdFeature.get(optionModel.record.SBQQ__Feature__c).record.Name != 'Included' &&!optionProdQuantityMap.containsKey(optionModel.record.SBQQ__OptionalSKU__c)) {
                    if (mapProdFeature.get(optionModel.record.SBQQ__Feature__c).record.Name != 'Included' &&!optionProdQuantityMap.containsKey(optionModel.record.SBQQ__OptionalSKU__c)) {    
                        system.debug('optionModel -- optionModel.record.SBQQ__Feature__r.Name'+optionModel.record.Name+ 'Id Test ' +optionModel.record.SBQQ__Feature__c+ 'Name test ' +mapProdFeature.get(optionModel.record.SBQQ__Feature__c).record.Name);
                        setRemoveOptionIds.add(optionModel.record.SBQQ__OptionalSKU__c);
                    }
                    if(String.isNotBlank(params.removeOptionSKUids)){
                        for(String prodId : params.removeOptionSKUids.split(';')){
                            setRemoveOptionIds.add(Id.valueOf(prodId));
                        }
                    }
                    if (optionProdQuantityMap.Containskey(optionModel.record.SBQQ__OptionalSKU__c)) {
                        if((optionModel.record.SBQQ__Selected__c && optionModel.record.SBQQ__Bundled__c) || optionModel.record.SBQQ__Selected__c) {
                            continue;
                        }
                        //Add the option into the parent bundle
                        product.configuration.optionConfigurations.add(returnConfigModel(optionModel,optionProdQuantityMap, params.pricebookId, params.currencyValue));
                    }
                }
            }
            
            if(product.configuration != null){
                system.debug('inside product.configuration'+product.configuration);
                product.configuration.configured = true;
                product.configuration.configurationEntered = true;
                for(ConfigurationModel configModel : product.configuration.optionConfigurations) {
                    if(!setRemoveOptionIds.isEmpty() && setRemoveOptionIds.Contains(configModel.configuredProductId)) {
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
            QuoteModel updateQuote = populateQuote(quote, params);
            ProductAdder adder = new ProductAdder();
            //deleteQuoteLines(qleDeleteIds);
            QuoteModel quoteWithProducts = adder.add(updateQuote, updatedProductModels, 0);
            
            //Validate the Quote if any errors then msgs will have all the errors list : 
            Validator validator = new Validator();
            List<String> msgs = validator.validate(quoteWithProducts);
            
            //Collection variable to store the updated Quotelinemodel from below loop:
            List<QuoteLineModel> updatedQuoteLineModels = new List<QuoteLineModel>();
            
            //Update the quantity of the Quote lines in the Quote  -- START
            
            for(QuoteLineModel ql : quoteWithProducts.lineItems) {
                if (mapQLI.containsKey(ql.record.SBQQ__Product__c)) {
                    system.debug('entering the loop mapQLI'+mapQLI);
                    populateQuoteLines(mapQLI, ql, existingQLIMap);
                } else if (existingQLIMap.containsKey(ql.record.SBQQ__Product__c)) {
                    populateExistingQuoteLines(existingQLIMap,ql);
                }
                
                updatedQuoteLineModels.add(ql);
            }
            quoteWithProducts.lineItems.clear();
            quoteWithProducts.lineItems.addall(updatedQuoteLineModels);
            
            system.debug('quoteWithProducts'+quoteWithProducts);
            ID jobID = System.enqueueJob(new CPQAPIReBundlingQueueble(quoteWithProducts,qleDeleteIds));
            System.debug('jobID'+jobID);
        }
        catch(Exception ex){
            system.debug('Exeption');
            if(quote.record.isSelfService__c){
                Self_Service_Quote_Summary__c selfServiceQuoteSummary = [SELECT Id, ErrorLog__c, Status__c FROM Self_Service_Quote_Summary__c WHERE Quote__c = :quote.record.Id LIMIT 1];
                update new Self_Service_Quote_Summary__c(Id = selfServiceQuoteSummary.Id, Status__c = 'Integration- Failed to add products', ErrorLog__c = 'Exception in CPQ API: ' + ex.getMessage());
            }
        }
        
    }
    
    private static ConfigurationModel returnConfigModel(OptionModel optionM, Map<id, Integer> mapaddOptionIdsQuantity, Id pricebookId, String currencyValue ){
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
        system.debug('cm.optionConfigurations'+cm.optionConfigurations);
        return cm;
    }
    
    private static QuoteLineModel populateQuoteLines(Map<String, quoteLineItemParams> mapQLI, QuoteLineModel ql, Map<Id, QuoteLineModel> existingQLIMap){
        system.debug('inside populateQuoteLines'+mapQLI);
        quoteLineItemParams qliParams = mapQLI.get(ql.record.SBQQ__Product__c);
        ql.record.Billing_Frequency_Override__c = String.isNotBlank(qliParams.billingFrequencyoverride) ? Boolean.valueOf(qliParams.billingFrequencyoverride) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Billing_Frequency_Override__c : false);
            ql.record.SBQQ__BillingFrequency__c = String.isNotBlank(qliParams.billingFrequency) ? qliParams.billingFrequency : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__BillingFrequency__c : null);
                ql.record.Transaction_Type__c = String.isNotBlank(qliParams.transactionType) ? qliParams.transactionType : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Transaction_Type__c : null);
                    ql.record.Annual_Recurring_Revenue__c = String.isNotBlank(qliParams.annualRecurringRevenue) ? Decimal.valueOf(qliParams.annualRecurringRevenue) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Annual_Recurring_Revenue__c : null);
                        ql.record.SBQQ__SubscriptionPercent__c = String.isNotBlank(qliParams.percentOfTotal) ? Decimal.valueOf(qliParams.percentOfTotal) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__SubscriptionPercent__c : null);
                            ql.record.Upsell_ACV__c = String.isNotBlank(qliParams.upsellABV) ? Decimal.valueOf(qliParams.upsellABV) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Upsell_ACV__c : null);
                                ql.record.Uplift_Notes__c = String.isNotBlank(qliParams.renewalNotes) ? qliParams.renewalNotes : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Uplift_Notes__c : null);
                                    ql.record.License_Value_Per_Unit__c = String.isNotBlank(qliParams.adjustedNetUnitAmt) ? Decimal.valueOf(qliParams.adjustedNetUnitAmt) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.License_Value_Per_Unit__c : null);
                                        ql.record.SBQQ__EndDate__c = String.isNotBlank(qliParams.endDate) ? Date.valueOf(qliParams.endDate) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__EndDate__c : null);
                                            ql.record.SBQQ__StartDate__c = String.isNotBlank(qliParams.startDate) ? Date.parse(qliParams.startDate) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__StartDate__c : null);
                                                ql.record.SBQQ__Quantity__c = String.isNotBlank(qliParams.quantity) ? Decimal.valueOf(qliParams.quantity) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__Quantity__c : null);
                                                    ql.record.SBQQ__Discount__c = String.isNotBlank(qliParams.discount) ? Decimal.valueOf(qliParams.discount) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__Discount__c : null);
                                                        ql.record.Credit_Amount__c = String.isNotBlank(qliParams.creditAmount) ? Decimal.valueOf(qliParams.creditAmount) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Credit_Amount__c : null);
                                                            ql.record.Credit_Type__c = String.isNotBlank(qliParams.creditType) ? String.valueOf(qliParams.creditType) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Credit_Type__c : null);
                                                                ql.record.IPS_Cash__c = String.isNotBlank(qliParams.ipsCash) ? Decimal.valueOf(qliParams.ipsCash) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.IPS_Cash__c : null);
                                                                    ql.record.Line_Level_Discount__c = String.isNotBlank(qliParams.incrementalDiscount) ? Decimal.valueOf(qliParams.incrementalDiscount) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Line_Level_Discount__c : null);
                                                                        ql.record.Target_Amount__c = String.isNotBlank(qliParams.targetAmount) ? Decimal.valueOf(qliParams.targetAmount) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Target_Amount__c : null);
                                                                            ql.record.Line_level_Uplift__c = String.isNotBlank(qliParams.uplift) ? Decimal.valueOf(qliParams.uplift) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.Line_level_Uplift__c : null);
                                                                                ql.record.SBQQ__UpliftAmount__c = String.isNotBlank(qliParams.upliftAmt) ? Decimal.valueOf(qliParams.upliftAmt) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpliftAmount__c : null);
                                                                                    ql.record.SBQQ__CustomerPrice__c = String.isNotBlank(qliParams.customerPrice) ? Decimal.valueOf(qliParams.customerPrice) : (existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__CustomerPrice__c : null);
                                                                                        ql.record.SBQQ__RenewedSubscription__c = existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__RenewedSubscription__c : null;
        ql.record.SBQQ__UpgradedSubscription__c = existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpgradedSubscription__c : null;
        // ql.record.SBQQ__UpgradedSubscription__c = existingQLIMap.containskey(ql.record.SBQQ__Product__c) ? existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpgradedSubscription__c : null;
        system.debug('ql'+ql);
        
        return ql;
    }
    
    private static QuoteLineModel populateExistingQuoteLines(Map<Id, QuoteLineModel> existingQLIMap, QuoteLineModel ql){
        system.debug('populateExistingQuoteLines.creditType'+existingQLIMap.get(ql.record.SBQQ__Product__c).record.Line_level_Uplift__c);
        system.debug('populateExistingQuoteLines.upliftAmt'+existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpliftAmount__c);
        ql.record.Billing_Frequency_Override__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Billing_Frequency_Override__c;
        ql.record.SBQQ__BillingFrequency__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__BillingFrequency__c;
        ql.record.Transaction_Type__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Transaction_Type__c;
        ql.record.Annual_Recurring_Revenue__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Annual_Recurring_Revenue__c;
        ql.record.SBQQ__SubscriptionPercent__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__SubscriptionPercent__c;
        ql.record.Upsell_ACV__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Upsell_ACV__c;
        ql.record.Uplift_Notes__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Uplift_Notes__c;
        ql.record.License_Value_Per_Unit__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.License_Value_Per_Unit__c;
        ql.record.SBQQ__EndDate__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__EndDate__c;
        ql.record.SBQQ__StartDate__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__StartDate__c;
        ql.record.SBQQ__Quantity__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__Quantity__c;
        ql.record.SBQQ__Discount__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__Discount__c; //Self Quote
        ql.record.Credit_Amount__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Credit_Amount__c;
        ql.record.Credit_Type__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Credit_Type__c;
        ql.record.IPS_Cash__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.IPS_Cash__c;
        ql.record.Line_Level_Discount__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Line_Level_Discount__c;
        ql.record.Target_Amount__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Target_Amount__c;
        ql.record.Line_level_Uplift__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.Line_level_Uplift__c;
        ql.record.SBQQ__UpliftAmount__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpliftAmount__c;
        ql.record.SBQQ__CustomerPrice__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__CustomerPrice__c;
        ql.record.SBQQ__RenewedSubscription__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__RenewedSubscription__c;
        ql.record.SBQQ__UpgradedSubscription__c = existingQLIMap.get(ql.record.SBQQ__Product__c).record.SBQQ__UpgradedSubscription__c;
        return ql;
    }
    
    private static QuoteModel populateQuote( QuoteModel quote, QuoteParams params){
        quote.record.SBQQ__StartDate__c = String.isNotBlank(params.startDate) ? Date.parse(params.startDate) : quote.record.SBQQ__StartDate__c;
        quote.record.SBQQ__SubscriptionTerm__c = String.isNotBlank(params.subscriptionTerm) ? Decimal.valueOf(params.subscriptionTerm) : quote.record.SBQQ__SubscriptionTerm__c;
        quote.record.SBQQ__EndDate__c = String.isNotBlank(params.endDate) ? Date.valueOf(params.endDate) : quote.record.SBQQ__EndDate__c;
        //quote.record.Total_Discount_Percent__c = String.isNotBlank(params.totalDiscountPecnt) ? Decimal.valueOf(params.totalDiscountPecnt) : quote.record.Total_Discount_Percent__c;
        //quote.record.SBQQ__NetAmount__c = String.isNotBlank(params.netAmount) ? Decimal.valueOf(params.netAmount) : quote.record.SBQQ__NetAmount__c;
        quote.record.Override_Support_Level__c = String.isNotBlank(params.overrideSupportLevel) ? Boolean.valueOf(params.overrideSupportLevel) : quote.record.Override_Support_Level__c;
        quote.record.EditLinesFieldSetName__c = String.isNotBlank(params.EditLnFieldSet) ? params.EditLnFieldSet : quote.record.EditLinesFieldSetName__c;
        quote.record.Target_Customer_Amount__c = String.isNotBlank(params.TargetCustomerAmt) ? Decimal.valueOf(params.TargetCustomerAmt) : quote.record.Target_Customer_Amount__c;
        quote.record.Group__c = String.isNotBlank(params.groupheader) ? params.groupheader : quote.record.Group__c;
        quote.record.Group_Discount__c = String.isNotBlank(params.groupDiscount) ? Decimal.valueOf(params.groupDiscount) : quote.record.Group_Discount__c;
        quote.record.Group_Uplift__c = String.isNotBlank(params.groupUplift) ? Decimal.valueOf(params.groupUplift) : quote.record.Group_Uplift__c;
        quote.record.Uplift_Method__c = String.isNotBlank(params.upliftMethod) ? params.upliftMethod : quote.record.Uplift_Method__c;
        quote.record.Uplift_Rate__c = String.isNotBlank(params.upliftRate) ? params.upliftRate : quote.record.Uplift_Rate__c;
        quote.record.Uplift_Applied__c = String.isNotBlank(params.upliftApplied) ? params.upliftApplied : quote.record.Uplift_Applied__c;
        return quote;
    }
    //Method to delete existing QL's
    @future
    public static void deleteQuoteLines(Set<Id> qleDeleteIds) {
        
        List<SBQQ__Quoteline__c> qlDeleteList = new List<SBQQ__QuoteLine__c>();
        system.debug('erntering del'+qleDeleteIds);
        for(Id qlId :qleDeleteIds) {
            SBQQ__QuoteLine__c qlRec = new SBQQ__QuoteLine__c(Id = qlId);
            qlDeleteList.add(qlRec);
        }
        If(!qlDeleteList.isEmpty()) {
            delete qlDeleteList;
        }
        //system.enqueueJob(new CPQAPICalculateQteQueueble(quoteWithProducts));
    }
    /**
* Class:Params
* Description: Wrapper class for storing the params
* return: NA
* params: NA
**/
    global class QuoteParams{
        @InvocableVariable
        global String quoteID;
        @InvocableVariable
        global String pricebookId; 
        @InvocableVariable
        global String currencyValue;
        @InvocableVariable 
        global String parentProdId;
        @InvocableVariable
        global String addOptionSKUIds;
        @InvocableVariable
        global String removeOptionSKUids;
        @InvocableVariable
        global String startDate;//SBQQ__StartDate__c
        @InvocableVariable
        global String subscriptionTerm;//SBQQ__SubscriptionTerm__c
        @InvocableVariable
        global String endDate; //SBQQ__EndDate__c
        @InvocableVariable
        global String totalDiscountPecnt;//Total_Discount_Percent__c
        @InvocableVariable
        global String netAmount;//SBQQ__NetAmount__c
        @InvocableVariable
        global String overrideSupportLevel;//Override_Support_Level__c
        @InvocableVariable
        global String EditLnFieldSet;//EditLinesFieldSetName__c
        @InvocableVariable
        global String TargetCustomerAmt;//Target_Customer_Amount__c
        @InvocableVariable
        global String groupheader;//Group__c
        @InvocableVariable
        global String groupDiscount;//Group_Discount__c
        @InvocableVariable
        global String groupUplift;//Group_Uplift__c
        @InvocableVariable
        global String upliftMethod;//Uplift_Method__c
        @InvocableVariable
        global String upliftRate;//Uplift_Rate__c
        @InvocableVariable
        global string upliftApplied;//Uplift_Applied__c
        @InvocableVariable
        global List<quoteLineItemParams> quoteLineItemdParamsList;
    }
    
    global class quoteLineItemParams{
        global String optionProductId;
        global String billingFrequencyoverride;//Boolean
        global String billingFrequency;//Decimal
        global String transactionType;
        global String percentOfTotal;//Decimal
        global String upsellABV;//Decimal
        global String renewalNotes;
        global String adjustedNetUnitAmt;//Decimal
        global String endDate;//date
        global String startDate;
        global String priorContactNumber;//Decimal
        global String creditAmount;//Decimal
        global String creditType;
        global String annualRecurringRevenue;//Decimal
        global String quantity;//Decimal
        global String discount;//Self Quote - discount %
        global String ipsCash;
        global String incrementalDiscount; //Line_Level_Discount__c
        global String targetAmount;//Target_Amount__c
        global String uplift;//Line_level_Uplift__c
        global String upliftAmt;//SBQQ__UpliftAmount__c
        global string customerPrice;//SBQQ__CustomerPrice__c
    }
}