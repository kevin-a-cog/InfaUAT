/*
    @created by       : Pavithra V
    @created on       : 09/03/2021
    @Purpose          : Controller class for caseDependentPicklist LWC
    @Testclass        : caseDependentPicklistCtrlTest
    @JIRA             : I2RT-672
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date            Jira No.    Tag     Description
 ****************************************************************************************************
 Venky K        08/25/2021                  T01      show all problem types if Delivery Method does not exist
 Vignesh D      08/04/2022      I2RT-6864   T02      Escape string variables
 Shashikanth    09/20/2023      I2RT-9026   T03      Capture Components fields even for Fulfilment cases
 */
public class caseDependentPicklistController {
    
    public static globalApexManager GAM = new globalApexManager();
        
        @AuraEnabled
        public static wrapperClass getProductAttributes( String caseId) {
        
            wrapperClass wrp = new wrapperClass();
            
            Map<String, Map<String, List<String>>> componentsMap = new Map<String, Map<String, List<String>>>();
            Map<String, Map<String, List<String>>> fulfillmentComponentsMap = new Map<String, Map<String, List<String>>>();               //<T03>
            Map<String, List<String>> versionsMap = new Map<String, List<String>>();
            Map<String, List<String>> problemsMap = new Map<String, List<String>>();
            List<String> allProducts = new List<String>();
            
            List<Technical_Product_Line__c> tpLines = [Select Id, Name, Component_SubComponent__c, Version__c, Problem_Type__c from Technical_Product_Line__c where Status__c = 'Active' ORDER BY Name];
            
            Case cs = [Select Id,Forecast_Product__c,Createddate, Component__c, Subcomponent__c, Problem_Type__c, Version__c,Record_Type_Name__c,Delivery_Method__c,RecordTypeId,RecordType.Name from Case where Id =:caseId];
    
            Map<String, Service_Cloud_General_Setting__mdt> serCloudSettings = Service_Cloud_General_Setting__mdt.getAll();
            Id OperationsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
            Id TechnicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
            Id FulfillmentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Fulfillment').getRecordTypeId();       //<T03>
    
            for(Technical_Product_Line__c TP : tpLines){
                allProducts.add(TP.Name);
                if(TP.Component_SubComponent__c != null){
                    List<String> level1Split = tp.Component_SubComponent__c.split(';');
                    for(String level1 : level1Split){
                        List<String>  level2Split = level1.split(':');
                        Map<String, List<String>> tempComponentsList = componentsMap.get(TP.Name) == null ? new Map<String, List<String>>() : componentsMap.get(TP.Name);
                        if(level1Split != null && level2Split != null){
                            if(level2Split.size() > 1){
                                tempComponentsList.put(level2Split[0],level2Split[1].split('~'));
                            }else{
                                if(level2Split.IsEmpty()){
                                    tempComponentsList.put('None', null);
                                }
                                else{
                                    tempComponentsList.put(level2Split[0],null);
                                }
                            }
                        }
                        componentsMap.put(TP.Name, tempComponentsList);
                    }
                }
                List<String> tempVersionList = versionsMap.get(TP.Name) == null ? new List<String>() : versionsMap.get(TP.Name);
                Map<String, String> versionMap = new Map<String, String>();
                if(TP.Version__c != null){
                    for(String s : TP.Version__c.split(';')){
                        versionMap.put(s.toUpperCase(), s);
                        tempVersionList.add(s.toUpperCase());
                    }
                }else{
                    
                }
                tempVersionList.sort();
                List<String> sortedVersions = new List<String>();
                for(String s : tempVersionList){
                    sortedVersions.add(versionMap.get(s));
                }
                versionsMap.put(TP.Name, sortedVersions);
    
                 /* Commented as part of I2RT-2550 - Start */
                    /* if(TP.Problem_Type__c != null){
                        for(String s : TP.Problem_Type__c.split(';')){
                            problemMap.put(s.toUpperCase(), s);
                            tempProblemList.add(s.toUpperCase());
                        }
                    }else{
                        
                    } */
                    /* Commented as part of I2RT-2550 - End */
               
            }
             /* Modified as part of I2RT-2550 - Start */
             String deliveryMethod = cs.Delivery_Method__c;
             String key = (cs.RecordTypeId == OperationsRecordTypeId) ? cs.RecordType.Name :
             (cs.RecordTypeId == TechnicalRecordTypeId &&  deliveryMethod != null) ? (cs.RecordType.Name + deliveryMethod.deleteWhitespace()) : '';
            if(problemsMap.get(key) == null){
                List<String> tempProblemList =  new List<String>();
                Map<String, String> problemMap = new Map<String, String>();
    
    
    
                if (cs.Record_Type_Name__c == 'Operations') {
                    String problemTypes = serCloudSettings.get('OPERATIONS_CASE_TYPE').Problem_Types__c;
                    for(String s : problemTypes.split(';')){
                        problemMap.put(s.toUpperCase(), s);
                        tempProblemList.add(s.toUpperCase());
                    }
                } 
                // Amarender - Added additional On Premise condition below as part of I2RT-3085
                else if (cs.Record_Type_Name__c == 'Technical' && (cs.Delivery_Method__c=='Hosted Single Tenant' || cs.Delivery_Method__c=='On Premise')) {
                    String problemTypes = serCloudSettings.get('TECHNICAL_CASE_SINGLE_TENANT').Problem_Types__c;
                    for(String s : problemTypes.split(';')){
                        problemMap.put(s.toUpperCase(), s);
                        tempProblemList.add(s.toUpperCase());
                    }
                }else if (cs.Record_Type_Name__c == 'Technical' && cs.Delivery_Method__c=='Hosted Multi Tenant') {
                    String problemTypes = serCloudSettings.get('TECHNICAL_CASE_MULTI_TENANT').Problem_Types__c;
                    for(String s : problemTypes.split(';')){
                        problemMap.put(s.toUpperCase(), s);
                        tempProblemList.add(s.toUpperCase());
                    }
                } 
                //<T01>  Venky  - If Delivery Method does not exist on case system will show all problem types for Single and Multi Tenant
                else if(cs.Record_Type_Name__c == 'Technical'){
                    String problemTypes = serCloudSettings.get('TECHNICAL_CASE_MULTI_TENANT').Problem_Types__c;
                    for(String s : problemTypes.split(';')){
                        problemMap.put(s.toUpperCase(), s);
                        tempProblemList.add(s.toUpperCase());
                    }
                    problemTypes = serCloudSettings.get('TECHNICAL_CASE_SINGLE_TENANT').Problem_Types__c;
                    for(String s : problemTypes.split(';')){
                        problemMap.put(s.toUpperCase(), s);
                        tempProblemList.add(s.toUpperCase());
                    }
                }
    
                
    
                tempProblemList.sort();
                List<String> sortedProblems = new List<String>();
                for(String s : tempProblemList){
                    sortedProblems.add(problemMap.get(s));
                }
                problemsMap.put(key, sortedProblems);
            }
            /* Modified as part of I2RT-2550 - End */

            //<T03>
            if(cs.RecordTypeId == FulfillmentRecordTypeId){
                fulfillmentComponentsMap = getFulfillmentComponents();
            }
            //</T03>

            wrp.componentsMap = componentsMap;
            wrp.fulfillmentComponentsMap = fulfillmentComponentsMap;        //<T03>
            wrp.versionsMap = versionsMap;
            wrp.problemsMap = problemsMap;
            wrp.allProducts = allProducts;
            wrp.caseRecDetails = cs;
        
            return wrp;
            
        }

        //<T03>
        /*
        @description    : gets the Components and SubComponents for Fulfillment
        @date           : 09/20/2023
        @param          : 
        @return         : Map<String, Map<String, List<String>>>
        */
        private static Map<String, Map<String, List<String>>> getFulfillmentComponents()
        {
            Map<String, Map<String, List<String>>> fulfillmentComponentsList = new Map<String, Map<String, List<String>>>();
            List<Service_Cloud_General_Setting__mdt> serviceCloudGeneralSettingList = [Select Fulfillment_Delivery_Method__c,Component_SubComponent__c  from Service_Cloud_General_Setting__mdt Where Fulfillment_Delivery_Method__c != null];

            for(Service_Cloud_General_Setting__mdt serviceCloudGeneralSetting : serviceCloudGeneralSettingList){
                if(String.isEmpty(serviceCloudGeneralSetting.Component_SubComponent__c)){
                    continue;
                }

                Map<String, List<String>> compSubcompList = getFulfillmentCompSubcompList(serviceCloudGeneralSetting.Component_SubComponent__c);
                if(compSubcompList != null){
                    fulfillmentComponentsList.put(serviceCloudGeneralSetting.Fulfillment_Delivery_Method__c, compSubCompList);
                }
            }
            return fulfillmentComponentsList;
        }

        /*
        @description    : Processes the Comp & SubComp details string and converts in to Map
        @date           : 09/20/2023
        @param          : 
        @return         : Map<String, List<String>>
        */
        private static Map<String, List<String>> getFulfillmentCompSubcompList(string compSubcompDetails)
        {
            Map<String, List<String>> compSubcompList = new Map<String, List<String>>();
            List<String> level1Split = compSubcompDetails.split(';');

            for(String level1 : level1Split){
                List<String>  level2Split = level1.split(':');                
                if(level2Split != null && level2Split.size() > 1){
                    compSubCompList.put(level2Split[0], level2Split[1].split('~'));
                }
                else if (level2Split != null && level2Split.size() > 0){
                    compSubCompList.put(level2Split[0], null);
                }
            }
            return compSubcompList;
        }
        //</T03>

        @AuraEnabled
        public static String saveProductDetails(String caseId ,String selectedProduct, String selectedComponent, String selectedSubComponent, String selectedProblemType, String selectedVersion , Map<String, Map<String, List<String>>> componentsMap,Map<String, List<String>> versionsMap, Boolean unentProduct){
            System.debug('selectedSubComponent >>'+ selectedSubComponent); 
            //---------------------------------------<T02>-------------------------------
            selectedProduct = GlobalUtility.escapeSingleQuotes(selectedProduct);
            selectedComponent = GlobalUtility.escapeSingleQuotes(selectedComponent);
            selectedSubComponent = GlobalUtility.escapeSingleQuotes(selectedSubComponent);
            selectedProblemType = GlobalUtility.escapeSingleQuotes(selectedProblemType);
            selectedVersion = GlobalUtility.escapeSingleQuotes(selectedVersion);
            //---------------------------------------</T02>-------------------------------
            String message ='';
            Case cs = [Select Id,Forecast_Product__c, Component__c, Subcomponent__c, Problem_Type__c, Version__c,Record_Type_Name__c,Unentitled_Product__c from Case where Id =:caseId]; //project__c,is_hosted__c -MISSING FIELDS
            cs.Forecast_Product__c = selectedProduct == 'None' ? null : selectedProduct;
            if(componentsMap.get(selectedProduct) != null && componentsMap.get(selectedProduct).containsKey('None'))
                cs.Component__c = selectedComponent == 'None' ? 'None' : selectedComponent;
            else
                cs.Component__c = selectedComponent == 'None' ? null : selectedComponent;
            cs.Subcomponent__c = selectedSubComponent == 'None' ? null : selectedSubComponent;
            cs.Problem_Type__c = selectedProblemType == 'None' ? null : selectedProblemType;
            if(versionsMap.get(selectedProduct) != null && !versionsMap.get(selectedProduct).IsEmpty() && versionsMap.get(selectedProduct).contains('None'))
                cs.Version__c = selectedVersion == 'None' ? 'None' : selectedVersion;
            else
                cs.Version__c = selectedVersion == 'None' ? null : selectedVersion;
            if(unentProduct != null && cs.Unentitled_Product__c != unentProduct)
                cs.Unentitled_Product__c = unentProduct;
            /** 
            for(Asset a : [Select Id, SKU__r.Delivery_Method__c,SKU__r.Termed_License_Quantity__c from Asset where Project__c = :cs.project__c]){                
                    if(a.SKU__r.Termed_License_Quantity__c  != null  &&  a.SKU__r.Delivery_Method__c == Label.Hosted_Single_Tenant) {
                        String s1 = Forecast_product_alias__c.getvalues(a.SKU__r.Termed_License_Quantity__c) != null?Forecast_product_alias__c.getvalues(a.SKU__r.Termed_License_Quantity__c).alias__c:a.SKU__r.Termed_License_Quantity__c;                    
                        if (cs.Forecast_Product__c == s1 && cs.is_hosted__c == FALSE){
                            cs.is_hosted__c = TRUE;
                        } else if( cs.is_hosted__c == TRUE){
                            cs.is_hosted__c = FALSE;
                        }
                    }
            }
            **/
            
            Database.SaveResult r = Database.update(cs, false);
            if(!r.isSuccess()){
                for(Database.Error e : r.getErrors()){ 
                    message = 'Error Occurred in '+ e.getMessage();
                    GAM.CreateLogs('caseDependentPicklistController.saveProductDetails', cs, 'case Record');
                }
            }else{
                message = 'SUCCESS';
            }
            System.debug('message : '+ message);
            return message;
            
        }
        
        @AuraEnabled
        public static Case getCaseDetails(String caseId){
            Case cs = [Select Id,Forecast_Product__c, Component__c, Subcomponent__c, Problem_Type__c, Version__c,Record_Type_Name__c from Case where Id =:caseId];
            return cs;        
        }
        
        @AuraEnabled
        public static void checkExistingValues(String caseId, String selectedComponent, String selectedSubComponent, String selectedProblemType, String selectedVersion){
                Case cs = [Select Id,Forecast_Product__c, Component__c, Subcomponent__c, Problem_Type__c, Version__c,Record_Type_Name__c from Case where Id =:caseId];
                //---------------------------------------<T02>-------------------------------
                selectedComponent = GlobalUtility.escapeSingleQuotes(selectedComponent);
                selectedSubComponent = GlobalUtility.escapeSingleQuotes(selectedSubComponent);
                selectedProblemType = GlobalUtility.escapeSingleQuotes(selectedProblemType);
                selectedVersion = GlobalUtility.escapeSingleQuotes(selectedVersion);
                //---------------------------------------</T02>-------------------------------
                cs.Component__c  = selectedComponent == 'None' ? null : selectedComponent;
                cs.Subcomponent__c = selectedSubComponent == 'None' ? null : selectedSubComponent;
                cs.Problem_Type__c  = selectedProblemType == 'None' ? null : selectedProblemType;
                cs.Version__c  = selectedVersion == 'None' ? null : selectedVersion;
            
                Database.SaveResult r = Database.update(cs, false);
            
            if(!r.isSuccess()){
                for(Database.Error e : r.getErrors()){ 
                    GAM.CreateLogs('caseDependentPicklistController.saveProductDetails', cs, e.getMessage());
                }
            }
        }
        /** Wrapper class */
        public class wrapperClass{
            @AuraEnabled
            public Map<String, Map<String, List<String>>> componentsMap {get; set;}

            //<T03>
            @AuraEnabled
            public Map<String, Map<String, List<String>>> fulfillmentComponentsMap {get; set;}
            //</T03>
        
            @AuraEnabled
            public Map<String, List<String>> versionsMap {get; set;}
        
            @AuraEnabled
            public Map<String, List<String>> problemsMap {get; set;}
        
            @AuraEnabled
            public List<String> allProducts {get; set;}
    
            @AuraEnabled
            public Case caseRecDetails {get; set;}
         }
        
        }