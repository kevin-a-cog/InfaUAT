/*
Class:          associateProductsToIBController 
@Author:        Chandana Gowda 
@Created Date:  7-Aug-2019
@Description:   Controller class for associateProductsToIB Component

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
*/
public with sharing class associateProductsToIBController {
    
    public static globalApexManager GAM = new globalApexManager();
    public static DescribeSObjectResult objResult = Schema.getGlobalDescribe().get('Product2').getDescribe();
    
    /*Method to get the values of the picklist.
    * @param Name -String fieldApiName : API Name of the Picklist field
    * @throws exception -n/a
    * @return List<String>
    */    
    public static List<String> getPickListValuesIntoList(String fieldApiName){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    /*Method to get the Map of the picklist Names and associated Values.
    * @param Name -n/a
    * @throws exception -n/a
    * @return Map<String,List<String>> : returns Map with key being the picklist name and value being the picklist values
    */    
    @AuraEnabled
    public static Map<String,List<String>> getPicklistValues(){
        Map<String,List<String>> picklistValues=new Map<String,List<String>>();
        picklistValues.put('productFamily',getPickListValuesIntoList('Product_Family__c'));
        picklistValues.put('forecastProduct',getPickListValuesIntoList('Forecast_Product__c'));
        picklistValues.put('businessUnit',getPickListValuesIntoList('Business_Unit__c'));
        return picklistValues;
    }
    
    /*Method to read the fields to display from the Fieldset Associate InstallBase
    * @param Name -n/a
    * @throws exception -n/a
    * @return Map<String,String> : returns Map with key being the field Label name and value being the Field API Name
    */
    @AuraEnabled
    public static Map<String,String> getFields(){
        Map<String,String> fields=new Map<String,String>();
        List<Schema.FieldSetMember> fs =Schema.SObjectType.Product2.fieldSets.Associate_InstallBase.getFields();
        if(fs != NULL){
            for(Schema.FieldSetMember fsMember:fs)
                fields.put(fsMember.getLabel(),fsMember.getFieldPath());
        }
        return fields;
    }

    /*Method to query the product records based on the filter
    * @param Name -String forecastProduct,String productFamily,String addOnCountry,String addOnCategory,String businessUnit,String queryfields,String installBase
    * @throws exception -n/a
    * @return Map<String,String> : returns the result product records matching the filter criteria
    */    
    @AuraEnabled
    public static List<Product2> getProducts(String searchKeyword,String forecastProduct,String productFamily,String addOnCountry,String addOnCategory,String businessUnit,List<String> queryfields,String installBase,List<sObject> pillsList){
        List<Product2> prods=new List<Product2>();
        List<Id> existingProds=new List<Id>();
        List<InstallBase_Mapping__c> installBaseMappings=[SELECT Id,Product__c FROM InstallBase_Mapping__c WHERE Install_Base__c=:installBase];
        for(InstallBase_Mapping__c IBMapping:installBaseMappings){
               existingProds.add((Id)IBMapping.get('Product__c'));         
        }
        String queryfieldString=String.escapeSingleQuotes(String.join(queryfields,','));
        String soql='SELECT Id,'+queryfieldString+' FROM Product2 WHERE Id NOT IN :existingProds';
        
        if(forecastProduct!=NULL && !String.isBlank(forecastProduct))
            soql += ' AND Forecast_Product__c = \''+String.escapeSingleQuotes(forecastProduct)+'\' ';

        if(productFamily!=NULL && !String.isBlank(productFamily))
            soql += ' AND Product_Family__c = \''+String.escapeSingleQuotes(productFamily)+'\' ';
        
        if(businessUnit!=NULL && !String.isBlank(businessUnit))
            soql += ' AND Business_Unit__c = \''+String.escapeSingleQuotes(businessUnit)+'\' ';                    

        if(searchKeyWord != NULL || !String.ISBLANK(searchKeyWord)){
            soql +=' AND Name LIKE \'%'+String.escapeSingleQuotes(searchKeyword)+'%\'';
        }
        soql +=' LIMIT 200';
        prods=Database.query(soql);
        updateSelected(pillsList,prods);
        return prods;
    }

    /*Method to query the product records based on the filter
    * @param Name -List<InstallBase_Mapping__c> installBaseMappings: List of records to insert
    * @throws exception -n/a
    * @return Map<String,String> : n/a
    */    
    @AuraEnabled
    public static void insertinstallBaseMapping(List<InstallBase_Mapping__c> installBaseMappings){
        GAM.CreateLogs('insertinstallBaseMapping',installBaseMappings,'installBaseMappings');
        try {
        	Database.insert(installBaseMappings);
        }catch (System.DmlException e) {
                GAM.CreateExceptionRecords('insertinstallBaseMapping:', e.GetMessage(),'error while inserting installBase Mapping records');
        }
    }

    /* this method will Update the selected records 
    * @param parameter- String pillsList,List<sObject> lstContactRecords
    * @return return- void
    * @throws exception-n/a
    */    
    public static void updateSelected(List<sObject> pillsList,List<sObject> lstContactRecords){
        
        //List<sObject> pillsListSelected = (List<sObject>)System.JSON.deserialize(pillsList,List<sObject>.class);
            for(sObject objlstContactRecords:  lstContactRecords){
                for(sObject pill:pillsList){
                    if(objlstContactRecords.Id == pill.Id){
                        objlstContactRecords.put('Is_Selected__c' ,true);
                    }
                }
            }
    }       
}