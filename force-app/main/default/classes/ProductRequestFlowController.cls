/****************************************************************************************************************************
 *  @Class Name: ProductRequestFlowController
 *  @Author: Puneet
 *  @Date: 
 *  @Description:This is a helper class which pulls the Products for selection on an Engagement for Partners
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/

public without sharing class ProductRequestFlowController{

    static Id PRM_RECORD_TYPE = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('PRM_Engagement').getRecordTypeId();
    public static globalApexManager GAM = new globalApexManager();
    public static Boolean internalEmailFlag = false;
    public static String SUBMITTED_IN_COMPLIANCE = 'Submitted In Compliance Review';
    public static String COMPLIANCE_REJECTED = 'Compliance Rejected';
    public static String NOT_SUBMITTED = 'Not Submitted';
    public static String SUBMITTED = 'Submitted';
    public static String REJECTED = 'Rejected';
    public static String COMPLETED = 'Completed';
    public static String PENDING_FULFILLEMNT = 'Pending Fulfilment';
    public static String PENDING_PRODUCT_REVIEW = 'Pending Product Review';

    /**
     * @description : method to update product requests
     */
    @AuraEnabled
    public static Boolean updateProductRequests(List<Id> productRequestIds, Map<String,Object> values){
        try {
            List<Product_Request__c> prodReqs = new List<Product_Request__c>();

            for(Id id : productRequestIds){
                Product_Request__c pr = new Product_Request__c();
                pr.Id = id;

                if(values != null && values.containsKey('Status__c')){
                
                    if(String.valueOf(values.get('Status__c')) == REJECTED){
                        
                        pr.Status__c = (String) values.get('Status__c');
                        pr.Rejection_Reason__c = (String) values.get('Rejection_Reason__c');
                    }
                    else{
                        pr.Status__c = (String) values.get('Status__c');
                        
                        if(values.get('License_Key_Org_ID__c') != null){
                            pr.License_Key_Org_ID__c = (String) values.get('License_Key_Org_ID__c');
                        }
                        
                        if(values.get('Fulfillment_Date__c') != null){
                            pr.Fulfillment_Date__c = Date.valueOf( (String) values.get('Fulfillment_Date__c') );
                        }
                    }
                    prodReqs.add(pr);
                }
            }

            if(!prodReqs.isEmpty()){
                update prodReqs;
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Product_Request__c> getProductRequests(String productFamily, String engagementId){
        return [SELECT Id,Name,Product__c,Product__r.Name,Status__c 
                    FROM Product_Request__c 
                    WHERE Engagement__c = :engagementId AND Internal_Product_Family__c = :productFamily];
    }

    /**
     * @description : method to retrieve mdm products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> retrieveMdmProducts(Id engagementId){
        try {
            return getProductRequests('MDM',engagementId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description : method to retrieve cloud products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> retrieveCloudProducts(Id engagementId){
        try {
            return getProductRequests('Cloud',engagementId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description : method to retrieve cdgc products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> retrieveCdgcProducts(Id engagementId){
        try {
            return getProductRequests('CDGC',engagementId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description : method to retrieve on premise products
     */
    @AuraEnabled(cacheable=true)
    public static List<Product_Request__c> retrieveOnPremProducts(Id engagementId){
        try {
            return getProductRequests('OnPremise',engagementId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description : method to get field set members
     */
    @AuraEnabled
    public static List<PRMProductHandlerUtility.FieldSetMember> getFields(String typeName, String fsName) 
    {
        return PRMProductHandlerUtility.getFieldDetails(typeName,fsName);
    }
    
    /* this method helps in returning the picklist values that need to be populated on the product selection form
    * @Method Name- getPicklistValues
    * @param parameter- string ObjectAPIName,fieldAPIName
    * @return - List of picklist values
    * @throws exception-n/a
    */
    @AuraEnabled
    public static List<PRMProductHandlerUtility.SelectOption> getPicklistValues(String ObjectAPIName,String fieldAPIName) 
    {
        return PRMProductHandlerUtility.getPicklistValues(ObjectAPIName,fieldAPIName);
    }

    /**
     * @description : method to get all products
     */
    @AuraEnabled
    public static ProductTableWrapper getProducts(String searchKeyWord, String fieldsStrQry){

        String searchKey = '%' + String.escapeSingleQuotes(searchKeyWord) + '%';
        List<ProductWrapper> lstProdRecords = new List<ProductWrapper>();
        String query = 'SELECT Id,'+fieldsStrQry + ' FROM Product2 WHERE {0}';

        if(!String.isBlank(searchKeyWord)){
            query += ' AND Name LIKE :searchKey';
        }
        query += ' order by Name';
        
        List<String> fieldList = fieldsStrQry.split(',');
        String finalQuery = 
            String.format(query, new List<Object>{
                System.Label.PRM_OnPremilterClause
            });
        Map<Id,Product2> prodMap = new Map<Id,Product2>((List<Product2>) Database.query(finalQuery)); 
        
        for(Product2 prod : prodMap.values()){
            
            ProductWrapper pw = new ProductWrapper();
            pw.isSelected = false;
            pw.prod = prod;
            pw.renewLicense = false;
            pw.serialnumber = '';
            pw.reqorproductversion = '';
            lstProdRecords.add(pw);
        }

        ProductTableWrapper ptw = new ProductTableWrapper();
        ptw.productWrap = lstProdRecords;
        ptw.fields = fieldList;

        return ptw;
    }

    /**
     * @description : method to retrieve mdm products with filters
     */
    @AuraEnabled
    public static Map<String,String> getMDMServices(){

        Map<String,String> services = new Map<String,String>();            
        String intialQuery = 'SELECT Id,Name FROM Product2 WHERE {0}';
        String finalQuery = 
            String.format(
                intialQuery, 
                new List<Object>{System.Label.PRM_MdmFilterClause}
            );
        List<Product2> prodList = Database.query(finalQuery);
            
        for(Product2 prod : prodList){
            
            if(!services.containsKey(prod.Id)){
                services.put(prod.Id, prod.Name);
            }
        }
        return services;
    }

    /**
     * @description : method to retrieve cloud products with filters
     */
    @AuraEnabled
    public static Map<String,String> getCloudervices(){

        Map<String,String> services = new Map<String,String>();            
        String intialQuery = 'SELECT Id,Name FROM Product2 WHERE {0}';
        String finalQuery = 
            String.format(
                intialQuery, 
                new List<Object>{System.Label.PRM_CloudProduct}
            );
        List<Product2> prodList = Database.query(finalQuery);
        
        if(!prodList.isEmpty()){
            services.put('Id',prodList[0].Id);
            services.put('Name',prodList[0].Name);
        }

        return services;
    }

    /**
     * @description : method to retrieve cdgc products with filters
     */
    @AuraEnabled
    public static Map<String,String> getCDGCServices(){

        Map<String,String> services = new Map<String,String>();
        String intialQuery = 'SELECT Id,Name FROM Product2 WHERE {0}';
        String finalQuery = 
            String.format(
                intialQuery, 
                new List<Object>{System.Label.PRM_CdgcFilterClause}
            );
        List<Product2> prodList = Database.query(finalQuery);

        for(Product2 prod : prodList){
            if(!services.containsKey(prod.Id)){
                services.put(prod.Id, prod.Name);
            }
        }
        return services;
    }

    /**
     * @description : method to save product requests and engagement
     */
    @AuraEnabled 
    public static String saveProductRequest(String jsonVal, Boolean isSubmit){
        String retVal = '';
        Boolean isUpsert = false;
        try{
            User currentUser = [SELECT Id,ContactId, Contact.AccountId,Name,Contact.Account.FCPA_Expiration_Date__c,Email FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1 ];
            Map<String,Object> initialMap = (Map<String,Object>) JSON.deserializeUntyped(jsonVal);
            Map<String,Object> engagementValueMap = (Map<String,Object>) initialMap.get('engagement');
            List<Object> products = (List<Object>) initialMap.get('products');
            Engagement__c engg = new Engagement__c();
            
            if(engagementValueMap.containsKey('Id')){
                engg.Id = (String) engagementValueMap.get('Id');
                isUpsert = true;
            }
            if(engagementValueMap.containsKey('Name')){
                engg.Name = (String) engagementValueMap.get('Name');
            }
            if(engagementValueMap.containsKey('Are_you_working_on_Opportunity__c')){
                engg.Are_you_working_on_Opportunity__c = (Boolean) engagementValueMap.get('Are_you_working_on_Opportunity__c');
            }
            if(engagementValueMap.containsKey('Is_customer_in_a_CIS_country__c')){
                engg.Is_customer_in_a_CIS_country__c = (String) engagementValueMap.get('Is_customer_in_a_CIS_country__c');
            }
            if(engagementValueMap.containsKey('How_will_this_software_be_used__c')){
                engg.How_will_this_software_be_used__c = (String) engagementValueMap.get('How_will_this_software_be_used__c');
            }
            if(engagementValueMap.containsKey('Customer_Name__c')){
                engg.Customer_Name__c = (String) engagementValueMap.get('Customer_Name__c');
            }
            if(engagementValueMap.containsKey('Comments__c')){
                engg.Comments__c = (String) engagementValueMap.get('Comments__c');
            }
            if(engagementValueMap.containsKey('Opportunity_Id__c')){
                engg.Opportunity_Id__c = (String) engagementValueMap.get('Opportunity_Id__c');
            }
            Boolean partnerInRussia = false;
            if(engagementValueMap.containsKey('Partner_in_Russia_or_Belarus__c')){
                partnerInRussia = (Boolean) engagementValueMap.get('Partner_in_Russia_or_Belarus__c');
            }
            
            engg.New_Flow_Request__c = true;
            engg.RecordTypeId = PRM_RECORD_TYPE;

            if(!partnerInRussia){
                User partnerUser = [SELECT Id,ContactId,Contact.MailingCountry,Contact.OtherCountry,IsPortalEnabled,
                                    Contact.AccountId,Contact.Account.ShippingCountry,Contact.Account.BillingCountry
                                FROM User where Id = :UserInfo.getUserId() LIMIT 1];
                
                if(partnerUser != null){
                    String countryLabel = System.Label.SanctionCountries;
                    List<String> countryList = countryLabel.split(',');

                    if((partnerUser.Contact.MailingCountry != null && countryList.contains(partnerUser.Contact.MailingCountry.toLowerCase())) || 
                        (partnerUser.Contact.OtherCountry != null && countryList.contains(partnerUser.Contact.MailingCountry.toLowerCase())) || 
                        (partnerUser.Contact.AccountId != null && partnerUser.Contact.Account.BillingCountry != null && countryList.contains(partnerUser.Contact.Account.BillingCountry.toLowerCase())) || 
                        (partnerUser.Contact.AccountId != null && partnerUser.Contact.Account.ShippingCountry != null && countryList.contains(partnerUser.Contact.Account.ShippingCountry.toLowerCase()))){
                        
                        partnerInRussia = true;
                    }
                }
            }

            if(isSubmit){
                
                if(engg.Is_customer_in_a_CIS_country__c == 'Yes' || partnerInRussia){
                    engg.Status__c = SUBMITTED_IN_COMPLIANCE;
                }
                else{
                    engg.Status__c = SUBMITTED;
                }
            }
            else{
                engg.Status__c = NOT_SUBMITTED;
            }
            
            engg.Requested_By__c = UserInfo.getUserId();
            upsert engg;
            
            Set<Id> existingProducts = new Set<Id>();
            List<Product_Request__c> productRequests = new List<Product_Request__c>();
            
            for(Object prodMap : products){

                Map<String,Object> finalProductMap = (Map<String,Object>) prodMap;
                Product_Request__c pr = new Product_Request__c();
                pr.Engagement__c = engg.Id;

                if(finalProductMap.containsKey('Id')){
                    pr.Id = (String) finalProductMap.get('Id');
                    existingProducts.add(pr.Id);
                }
                if(finalProductMap.containsKey('provisioningEnvironment')){
                    pr.Provisioning_Environment__c = (String) finalProductMap.get('provisioningEnvironment');
                }
                if(finalProductMap.containsKey('prod') && ((Map<String,Object>)finalProductMap.get('prod')).containsKey('Id')){
                    pr.Product__c = (String) ((Map<String,Object>)finalProductMap.get('prod')).get('Id');
                }
                if(finalProductMap.containsKey('trainingCompleted')){
                    pr.Training_Completed__c = (String) finalProductMap.get('trainingCompleted');
                }
                if(finalProductMap.containsKey('orgId')){
                    pr.License_Key_Org_ID__c = (String) finalProductMap.get('orgId');
                }
                if(finalProductMap.containsKey('renewLicense')){
                    pr.Renew_Existing_License__c = (Boolean) finalProductMap.get('renewLicense');
                }
                if(finalProductMap.containsKey('reqorproductversion')){
                    pr.Requirement_Or_Product_Version__c = (String) finalProductMap.get('reqorproductversion');
                }
                if(finalProductMap.containsKey('serialnumber')){
                    pr.Serial_No_For_Renewing_Licenses__c = (String) finalProductMap.get('serialnumber');
                }
                if(finalProductMap.containsKey('productFamily')){
                    pr.Internal_Product_Family__c = (String) finalProductMap.get('productFamily');
                }

                if(engg.Status__c != null && engg.Status__c != ''){
                    if(engg.Status__c == NOT_SUBMITTED){
                        pr.Status__c = NOT_SUBMITTED;
                    }
                    else if(engg.Status__c == SUBMITTED_IN_COMPLIANCE){
                        pr.Status__c = SUBMITTED_IN_COMPLIANCE;
                    }
                    else if(engg.Status__c == SUBMITTED){
                        if(pr.Internal_Product_Family__c == 'Cloud' || pr.Internal_Product_Family__c == 'OnPremise'){
                            pr.Status__c = PENDING_FULFILLEMNT;
                        }
                        else if(pr.Internal_Product_Family__c == 'MDM' || pr.Internal_Product_Family__c == 'CDGC'){
                            pr.Status__c = PENDING_PRODUCT_REVIEW;
                        }
                    }
                }

                if(pr.Internal_Product_Family__c == 'Cloud'){
                    pr.Start_Date__c = System.today();
                    pr.IPU_Quantity__c = Integer.valueOf(System.Label.PRM_DefaultIPUQuantity);
                    pr.IPU_Type__c = System.Label.PRM_DefaultIPUType;

                    if(currentUser != null && currentUser.Email != null){
                        pr.Partner_Email_Address__c = currentUser.Email;
                    }
                    if(currentUser != null && currentUser.Name != null){
                        pr.Partner_Name__c = currentUser.Name;
                    }
                    if(currentUser != null && currentUser.ContactId != null){
                        pr.Partner_Contact__c = currentUser.ContactId;
                        
                        if(currentUser.Contact.AccountId != null){
                            pr.Partner_Account__c = currentUser.Contact.AccountId;

                            if(currentUser.Contact.Account.FCPA_Expiration_Date__c != null){
                                pr.End_Date__c = currentUser.Contact.Account.FCPA_Expiration_Date__c;
                            }
                        }
                    }
                }
                productRequests.add(pr);
            }

            List<Product_Request__c> productReqList = [SELECT Id FROM Product_Request__c WHERE Engagement__c = :engg.Id AND Id NOT IN :existingProducts];

            if(!productReqList.isEmpty()){
                delete productReqList;
            }

            if(!productRequests.isEmpty()){
                upsert productRequests;
            }
            if(isSubmit){

                List<Product_Request__c> prodList = [SELECT Id FROM Product_Request__c WHERE (Internal_Product_Family__c = 'MDM' OR Internal_Product_Family__c = 'CDGC') AND Id IN :productRequests];
                List<PRM_EmailWrapper> wrapList = new List<PRM_EmailWrapper>();
                PRM_EmailWrapper wrap = new PRM_EmailWrapper();
                wrap.recordId = engg.Id;
                wrap.templateId = 'PRM_ProductRequestSubmissionNotify';
                wrap.ccEmails = '';
                wrap.userId = UserInfo.getUserId();
                wrapList.add(wrap);
                
                if(!prodList.isEmpty()){
                    PRM_EmailWrapper wrap2 = new PRM_EmailWrapper();
                    wrap2.recordId = engg.Id;
                    wrap2.templateId = 'PRM_ProductRequestNotifyInternal';
                    if(!Test.isRunningTest()){
                        wrapList.add(wrap2);
                    }
                }
                sendEmailWithTemplate(wrapList);
            }
            retVal = String.valueOf(engg.Id);
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            throw new AuraHandledException(errorMsg);
        }
        return retVal;
    }

    /**
     * @description : method to get data for existing records
     */
    @AuraEnabled
    public static String getDataForExistingRecord(String recordId){

        try{
            Engagement__c engg = [SELECT Id,Name,Are_you_working_on_Opportunity__c,Is_customer_in_a_CIS_country__c,
                                        How_will_this_software_be_used__c,Customer_Name__c,Comments__c,
                                        Opportunity_Id__c,New_Flow_Request__c,Status__c,Partner_in_Russia_or_Belarus__c,
                                        (SELECT Id,Name,Provisioning_Environment__c,Product__c,Product__r.Name,
                                            Training_Completed__c,License_Key_Org_ID__c,Renew_Existing_License__c,
                                            Requirement_Or_Product_Version__c,Serial_No_For_Renewing_Licenses__c,
                                            Internal_Product_Family__c
                                            FROM Product_Requests__r)
                                    FROM Engagement__c 
                                    WHERE Id =:recordId LIMIT 1];
            Map<String,Object> finalMap = new Map<String,Object>();

            Map<String,Object> engagementValueMap = new Map<String,Object>();
            engagementValueMap.put('Name',engg.Name);
            engagementValueMap.put('Are_you_working_on_Opportunity__c',engg.Are_you_working_on_Opportunity__c);
            engagementValueMap.put('Is_customer_in_a_CIS_country__c',engg.Is_customer_in_a_CIS_country__c);
            engagementValueMap.put('How_will_this_software_be_used__c',engg.How_will_this_software_be_used__c);
            engagementValueMap.put('Customer_Name__c',engg.Customer_Name__c);
            engagementValueMap.put('Comments__c',engg.Comments__c);
            engagementValueMap.put('Opportunity_Id__c',engg.Opportunity_Id__c);
            engagementValueMap.put('Id',engg.Id);
            engagementValueMap.put('New_Flow_Request__c',engg.New_Flow_Request__c);
            engagementValueMap.put('Status__c',engg.Status__c);
            engagementValueMap.put('Partner_in_Russia_or_Belarus__c',engg.Partner_in_Russia_or_Belarus__c);

            List<Object> products = new List<Object>();

            for(Product_Request__c pr : engg.Product_Requests__r){
                Map<String,Object> productMap = new Map<String,Object>();
                productMap.put('provisioningEnvironment',pr.Provisioning_Environment__c);
                productMap.put('trainingCompleted',pr.Training_Completed__c);
                productMap.put('orgId',pr.License_Key_Org_ID__c);
                productMap.put('renewLicense',pr.Renew_Existing_License__c);
                productMap.put('reqorproductversion',pr.Requirement_Or_Product_Version__c);
                productMap.put('serialnumber',pr.Serial_No_For_Renewing_Licenses__c);
                productMap.put('productFamily',pr.Internal_Product_Family__c);
                productMap.put('Id',pr.Id);

                Map<String,Object> internalProductMap = new Map<String,Object>();
                internalProductMap.put('Id',pr.Product__c);
                internalProductMap.put('Name',pr.Product__r.Name);

                productMap.put('prod',internalProductMap);
                products.add(productMap);
            }

            finalMap.put('engagement',engagementValueMap);
            finalMap.put('products',products);

            return JSON.serialize(finalMap);
        }
        catch(Exception e){
            String errorMsg = e.getMessage();
            throw new AuraHandledException(errorMsg);
        }
    }

    /**
     * @description : method to send email
     */
    public static void sendEmailWithTemplate(List<PRM_EmailWrapper> wrapList){

        Map<String, Object> Params = new Map<String, Object>();
        Params.put('EmailWraps',wrapList);
        Flow.Interview.PRM_SendEmail stage = new Flow.Interview.PRM_SendEmail(Params);
        stage.start();
    }

    /**
     * @description : method to get product requests
     */
    public static List<Product_Request__c> getProductRequests(Set<String> engagementIds){
        return [SELECT Id,Status__c,Engagement__c,Internal_Product_Family__c 
                FROM Product_Request__c 
                WHERE Engagement__c IN :engagementIds];
    }

    /**
     * @description : method to send email for engagement
     */
    public static void sendEmailsEngg(List<Engagement__c> newList, Map<Id,Engagement__c> oldMap){

        List<Messaging.SingleEmailMessage> singleMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id,Engagement__c> engagementMap = new Map<Id,Engagement__c>([SELECT Id,Status__c,Requested_By__c,Requested_By__r.Email,
            (SELECT Id,Name,Product__c,Product__r.Name,Status__c FROM Product_Requests__r WHERE (Internal_Product_Family__c = 'MDM' OR Internal_Product_Family__c = 'CDGC')) 
            FROM Engagement__c WHERE Id IN :newList AND RecordTypeId =:PRM_RECORD_TYPE]);

        List<PRM_EmailWrapper> wrapList = new List<PRM_EmailWrapper>();

        for(Engagement__c engg : newList){
            
            if(engg.RecordTypeId == PRM_RECORD_TYPE){
                if(oldMap != null && oldMap.get(engg.Id).Status__c != engg.Status__c && (engg.Status__c == COMPLIANCE_REJECTED || engg.Status__c == COMPLETED || engg.Status__c == REJECTED)){
                
                    PRM_EmailWrapper wrap = new PRM_EmailWrapper();
                    wrap.userId = engg.Requested_By__c;
                    wrap.recordId = engg.Id;
                    if(engg.Status__c == COMPLIANCE_REJECTED){
                        wrap.templateId = 'PRM_ProductRequestComplianceReject';
                    }
                    else{
                        wrap.templateId = 'PRM_ProductRequestCompletion';
                    }
                    wrapList.add(wrap);
                }
            }
        }

        if(!wrapList.isEmpty()){
            sendEmailWithTemplate(wrapList);
        }
    }

    /**
     * @description : method to update compliance on engagement
     */
    public static void updateEnagagementCompliance(List<Engagement__c> newList){
        Set<Id> engIdList = new Set<Id>();
        for(Engagement__c engg : newList){
            if(engg.RecordTypeId == PRM_RECORD_TYPE && engg.Partner_in_Russia_or_Belarus__c && engg.Status__c == SUBMITTED){
                engIdList.add(engg.Id);
            }
        }

        if(!engIdList.isEmpty()){
            updateEnagagementComplianceFuture(engIdList);
        }
    }

    /**
     * @description : method to update engagement status
     */
    @future
    public static void updateEnagagementComplianceFuture(Set<Id> engIdList){

        List<Engagement__c> engToUpdate = new List<Engagement__c>();
        for(Id engId : engIdList){

            Engagement__c engg = new Engagement__c();
            engg.Id = engId;
            engg.Status__c = SUBMITTED_IN_COMPLIANCE;
            engToUpdate.add(engg);
        }

        List<Product_Request__c> prodsToUpdate = new List<Product_Request__c>();
        for(Product_Request__c prodReq : [SELECT Id FROM Product_Request__c WHERE Engagement__c IN : engIdList]){
            prodReq.Status__c = SUBMITTED_IN_COMPLIANCE;
            prodsToUpdate.add(prodReq);
        }

        if(!engToUpdate.isEmpty()){
            update engToUpdate;
        }

        if(!prodsToUpdate.isEmpty()){
            update prodsToUpdate;
        }
    }

    /** 
     * @description : method to update product requests
     */
    public static void productRequestUpdates(List<Engagement__c> newList, Map<Id, Engagement__c> oldMap){

        Map<String,String> engagementToStatusMap = new Map<String,String>();
        Set<Id> engsToReview = new Set<Id>();
        for(Engagement__c engg : newList){
            if(engg.RecordTypeId == PRM_RECORD_TYPE){

                if(oldMap != null && oldMap.get(engg.Id).Status__c != engg.Status__c && (engg.Status__c == COMPLIANCE_REJECTED || engg.Status__c == NOT_SUBMITTED || engg.Status__c == SUBMITTED || engg.Status__c == SUBMITTED_IN_COMPLIANCE)){
                    
                    if(!engagementToStatusMap.containsKey(engg.Id)){
                        engagementToStatusMap.put(engg.Id, engg.Status__c);
                    }
                }
            }
        }
        List<Product_Request__c> prListToUpdate = new List<Product_Request__c>();

        if(!engagementToStatusMap.isEmpty()){

            List<Product_Request__c> prodList = getProductRequests(engagementToStatusMap.keySet());
        
            for(Product_Request__c pr : prodList){
                
                if(engagementToStatusMap.containsKey(pr.Engagement__c)){

                    String status = engagementToStatusMap.get(pr.Engagement__c);
                    Boolean hasUpdate = false;
                    if(status == COMPLIANCE_REJECTED){
                        pr.Status__c = COMPLIANCE_REJECTED;
                        hasUpdate = true;
                    }
                    else if(status == NOT_SUBMITTED){
                        pr.Status__c = NOT_SUBMITTED;
                        hasUpdate = true;
                    }
                    else if(status == SUBMITTED_IN_COMPLIANCE){
                        pr.Status__c = SUBMITTED_IN_COMPLIANCE;
                        hasUpdate = true;
                    }
                    else if(status == SUBMITTED){
                        if(pr.Internal_Product_Family__c == 'Cloud' || pr.Internal_Product_Family__c == 'OnPremise'){
                            pr.Status__c = PENDING_FULFILLEMNT;
                            hasUpdate = true;
                        }
                        else if(pr.Internal_Product_Family__c == 'MDM' || pr.Internal_Product_Family__c == 'CDGC'){
                            pr.Status__c = PENDING_PRODUCT_REVIEW;
                            hasUpdate = true;
                        }
                    }

                    if(hasUpdate){
                        prListToUpdate.add(pr);
                    }
                }
            }

            if(!prListToUpdate.isEmpty()){
                update prListToUpdate;
            }
        }
    }

    public class ProductTableWrapper{
        @AuraEnabled public List<ProductWrapper> productWrap{get;set;}
        @AuraEnabled public List<String> fields{get;set;}
    }

    public class ProductWrapper{
        @AuraEnabled public Product2 prod{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean renewLicense{get;set;}
        @AuraEnabled public String serialnumber{get;set;}
        @AuraEnabled public String reqorproductversion{get;set;}
    }
}