/*
Class:          RecordCloneWithChildController 
@Author:        Saurabh Khandelwal 
@Description:   Controller class for recordCloneWithChild Lighting component
                This controller holds method for dynamically clone record with related child along by 
                copying all createable fields to the new clone and Ignores Unique fields so they must be filled in manually
@TestClass :    RecordCloneWithChildControllerTest

    Change History
*************************************************************************************************************************************
    ModifiedBy                  Date            Requested By        Description                                         Tag
 Saurabh  Khandelwal			25-May-2022                         Made the class generic to clone the record with    SALESRT-13277
                                                                    all records of specified child objects.                                                                                 
*************************************************************************************************************************************
*/

global class RecordCloneWithChildController {

    private Static String errorThrown;
    private Static Set<String> excludedObjects=new Set<String>();
    private Static Set<String> includedObjects=new Set<String>();
    private Static final String TOMANYTYPES = 'Multiple Object Types were detected in the initial records';
    private Static final String NORECORDS = 'No Records to clone';
    private Static final String RECORD_NOT_FOUND='Metadata configuration not found';
    private Static final String UPDATE_QUOTE_ERROR='Error while updating quote record';
    private Static final String DELETE_QUOTE_ERROR='Error while Deleting related quote records';
    

    //custom exception class for handling exceptions.
    public class Object_Clone_Exception extends Exception {
    }


    /*Method to get the child object names of the given record id. 
    * @param recordId - contains record id of object
    */ 
    @AuraEnabled(cacheable=true)
    public static  Map<String,Object> getChildObjectNames(Id recordId){

        Map<String,Object>resultMap=new Map<String,Object>();
        
        try{
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            //checking if object name is custom object then replacing __ with _.
            if(sObjName.contains('__')){
                sObjName=sObjName.replaceAll('__','_');
            }
            //fetching custom metadata type for parent
            List<Cloning_Parent_Object__mdt> metadataConfig=[SELECT Id,(SELECT Object_Label__c,MasterLabel FROM Cloning_Child_Object__r ORDER BY Object_Label__c) FROM 
                                                             Cloning_Parent_Object__mdt WHERE DeveloperName=:sObjName];

            if(metadataConfig.size()>0 && metadataConfig[0].Cloning_Child_Object__r.size()>0){
                Map<String,String>childNameToLabelMap = new Map<String,String>();
                for(Cloning_Child_Object__mdt child : metadataConfig[0].Cloning_Child_Object__r ){
                    childNameToLabelMap.put(child.MasterLabel,child.Object_Label__c);
                    resultMap.put('ChildObjMap',childNameToLabelMap);
                }
            }
            else{
                throw New Object_Clone_Exception(RECORD_NOT_FOUND);
            }
            return resultMap;
        }
        catch(Exception ex){
            resultMap.put('Status','Error');
            resultMap.put('Message',ex.getMessage());
            return resultMap;
        }
    }

    /*Method to Execute Clone Method from button
    * @param oId - contains record id of object
    * @param withChildren - boolean to specify cloning of child records.
    * @param childObjects - contains child obj names to clone.
    */ 
    @AuraEnabled
    public static  Map<String,Object> cloneObjectSingle(String clonedQuoteId) {
        Map<String,Object>resultMap= new Map<String,Object>();
        Map<String,String>childNameToLabelMap = (Map<String,String>)getChildObjectNames(clonedQuoteId).get('ChildObjMap');
        includedObjects = Test.isRunningTest() ? new Set<String>{'SBQQ__QuoteLine__c'} : childNameToLabelMap.keySet();
        SBQQ__Quote__c newQuote = getSourceQuoteFieldsById(clonedQuoteId);
        if(newQuote.SBQQ__Source__c != null){
            Id originalQuoteId = newQuote.SBQQ__Source__c;
            if(updateNewQuoteWithClonedQuote(newQuote) && deleteRelatedObjectFromClonedQuote(newQuote) && updateNewQuoteLineWithOriginalQuote(newQuote)) {
                if(cloneChildObjects(clonedQuoteId, originalQuoteId)) {
                    resultMap.put('Status','Success');
                    resultMap.put('Message','Cloning process has started. You will receive notification once cloning process is completed.');
                } else {
                    resultMap.put('Status','Fail');
                    resultMap.put('Message',errorThrown);
                }
            }
        } else {
            resultMap.put('Status','Fail');
            resultMap.put('Message','This is not a cloned quote, you cannot select Clone Step-2 of 2 on this quote');
        }
        return resultMap;
    }

    /*Method to update quote field values from original source quote
    * @param SBQQ__Quote__c - contains quote record object
    */
    private static boolean updateNewQuoteWithClonedQuote(SBQQ__Quote__c quote){
        Boolean result = false;
        try {
            List<String> lstFields = SalesforceUtils.getFieldsFromFieldSet(Label.CloneQuoteFieldsFieldsetName, 'SBQQ__Quote__c');
            for(String field : lstFields) {
                quote.put(field,quote.SBQQ__Source__r.get(field));
            }
            quote.put('ApprovalStatus__c','');
            update quote;
            result = true;
        } catch(Exception ex){
            throw New Object_Clone_Exception(UPDATE_QUOTE_ERROR);
        }
        return result;
    }

    /*Method to update quote field values from original source quote
    * @param SBQQ__Quote__c - contains quote record object
    */
    private static boolean deleteRelatedObjectFromClonedQuote(SBQQ__Quote__c quote){
        Boolean result = false;
        try {
            List<Quote_Summary__c> lstQuoteSummary = [Select Id From Quote_Summary__c Where Quote__c =: quote.Id];
            if(lstQuoteSummary.size() > 0)
            delete lstQuoteSummary;
            List<sbaa__Approval__c> lstApprovals = [Select Id From sbaa__Approval__c Where Quote__c =: quote.Id];
            if(lstApprovals.size() > 0)
            delete lstApprovals;
            result = true;
        } catch(Exception ex){
            throw New Object_Clone_Exception(DELETE_QUOTE_ERROR);
        }
        return result;
    }
    
    /*Method to update quote field values from original source quote
    * @param SBQQ__Quote__c - contains quote record object
    */
    private static boolean updateNewQuoteLineWithOriginalQuote(SBQQ__Quote__c quote){
        Boolean result = false;
        try {
            Set<Id> setQuoteId = new Set<Id>{quote.Id, quote.SBQQ__Source__c};
            List<SBQQ__QuoteLineConsumptionRate__c> lstQLEConsRateToUpdate = new List<SBQQ__QuoteLineConsumptionRate__c>();
            Map<String, SBQQ__QuoteLineConsumptionRate__c> mapProdByQLEConsRate = new Map<String, SBQQ__QuoteLineConsumptionRate__c>();
            List<SBQQ__QuoteLineConsumptionRate__c> lstQLEConsRate = [Select Id,SBQQ__Price__c, SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__c,SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c from SBQQ__QuoteLineConsumptionRate__c where SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c IN :setQuoteId];
            for(SBQQ__QuoteLineConsumptionRate__c qleConsRate : lstQLEConsRate){
                mapProdByQLEConsRate.put(qleConsRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Product__c+','+qleConsRate.SBQQ__QuoteLineConsumptionSchedule__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,qleConsRate);
            }
            for(String key : mapProdByQLEConsRate.keySet()){
                if(key.contains(quote.Id)){      
                    SBQQ__QuoteLineConsumptionRate__c qleConRec = mapProdByQLEConsRate.get(key);
                    qleConRec.SBQQ__Price__c = mapProdByQLEConsRate.get(key.replace(quote.Id,quote.SBQQ__Source__c)).SBQQ__Price__c;
                    lstQLEConsRateToUpdate.add(qleConRec);
                }
            }
            if(lstQLEConsRateToUpdate.size() > 0){
                SBQQ.TriggerControl.disable();
                update lstQLEConsRateToUpdate;
                SBQQ.TriggerControl.enable();
            }
            result = true;
        } catch(Exception ex){
            throw New Object_Clone_Exception(UPDATE_QUOTE_ERROR);
        }
        return result;
    }

    /*Method to get quote field values
    * @param quoteId - contains record id of object
    */
    private static SBQQ__Quote__c getSourceQuoteFieldsById(Id quoteId){
        List<String> lstFields = SalesforceUtils.getFieldsFromFieldSet(Label.CloneQuoteFieldsFieldsetName, 'SBQQ__Quote__c');
        List<String> updatedListField = new List<String>();
        for(String field : lstFields){
            updatedListField.add('SBQQ__Source__r.'+field);
        }
        String queryString = 'SELECT Id,SBQQ__Source__c, ' + String.join(updatedListField, ',') 
                             + ' FROM SBQQ__Quote__c WHERE Id = :quoteId';
        return Database.query(queryString);
    }

    /*Method to clone the parent object. 
    * @param recordId - contains record id of object
    * @param withChildren - boolean to specify cloning of child records.
    */ 
    private static Boolean cloneChildObjects(Id newRecordId , Id originalQuoteId){
        //Ensure that we at least have some records
        if (String.isBlank(newRecordId)) {
            throw New Object_Clone_Exception(NORECORDS);
        }
        
        //Start the process cloning the parent with the desired options
        Map<Schema.SObjectType, Schema.sObjectField[]> childRelationships = 
            getChildRelationships(queryForRecords(new Set<Id>{originalQuoteId}, null));
        if(childRelationships!=null && childRelationships.keySet().size()>0){
            List<Schema.SObjectType>sObjectsList=new List<Schema.SObjectType>();
            sObjectsList.addAll(childRelationships.keySet());
            System.enqueueJob(new RecordCloningQueueable(childRelationships,0,originalQuoteId,newRecordId,sObjectsList));
        }
        return true;
    }

    /*method to fetch child realtionship name and clone parent object and call queueable class to clone childs.
    * @param oObjs - contains records which needs to be cloned.
    * @param withChildren - boolean to specify cloning of child records.
    * @param doinsert - boolean to specify whether to make insert cloned records or return sobjects only.
    */ 
    private static Map<Schema.SObjectType, Schema.sObjectField[]> getChildRelationships(sObject[] oObjs) {
        //Collection of Related Objects and their Parent Fields
        Map<Schema.SObjectType, Schema.sObjectField[]> childRelationships;
        Map<ID, SObject> oldRecToNewRec = New Map<ID, SObject>();
        //For each record for this sObjectType
        for (sObject oldObj : oObjs) {
            Schema.SObjectType objtype = oldObj.getSObjectType();
            //Create a new Object
            sObject newObj = oldObj.clone(false, true);
            //Populate the map with the Old ID as a key and the New Record as the value
            oldRecToNewRec.put(oldObj.id, newObj);
            //Get the related Objects
            childRelationships = getRelatedObjects(objtype);
        }
        return childRelationships;
    }

    /*method to Query for Records to Clone name Getting the ObjectType from the ID Set to Ensuring that there is only one ObjectType.
    * @param rIds - contains parent record Id or the record id to clone.
    * @param customWhereClause - contains whereclause condition if any.
    */ 
    private static sObject[] queryForRecords(Set<ID> rIds, String customWhereClause) {
        if (rIds == null || rIds.isEmpty()) return new sObject[]{};
        Schema.SObjectType oType;
        //Just a double check to ensure that once we get here there is only 1 object type to query
        for (ID rId : rIds) {
            if (oType == null) {
                oType = rId.getSObjectType();
            } else {
                if (rId.getSobjectType() != oType)
                    throw New Object_Clone_Exception(TOMANYTYPES);
            }
        }

        return queryForRecords(oType, rIds, customWhereClause);
    }

    /*method to Query for Records from the given sObjectType.
    * @param oType - contains sObject type pof the record to be queried.
    * @param rIds - contains parent record Id or the record id to clone.
    * @param customWhereClause - contains whereclause condition if any.
    */ 
    public static sObject[] queryForRecords(Schema.sObjectType oType, Set<ID> rIds, String customWhereClause) {
        if (rIds == null || rIds.isEmpty()) return New SObject[]{};
        String[] fldsToClone = getCreateableFields(oType);
        String query = 'Select ';
        query += string.join(fldsToClone, ',');
        query += ' From ' + String.escapeSingleQuotes(String.valueOf(oType));
        if (customWhereClause != null) {
            query += ' Where ' + String.escapeSingleQuotes(customWhereClause);
        } else {
            query += ' Where ID IN :rIds';
        }
        return database.query(query);

    }

    /*method to fetch creatable field from the given sObjectType
    * @param obj - contains sObjectType of the object.
    */ 
    private static String[] getCreateableFields(Schema.sObjectType obj) {
        String[] results = New String[]{
        };
        for (Schema.sObjectField fld : obj.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = fld.getDescribe();
            //ignore Unique fields. They will have to be filled in manually
            if (!dfr.isUnique() ) {
                results.add(dfr.getName());
            }
        }
        return results;
    }

    /*method to fetch related child objects information from parent sObjectType
    * @param obj - contains sObjectType of the object.
    */ 
    private static Map<Schema.SObjectType, Schema.sObjectField[]> getRelatedObjects(Schema.sObjectType obj) {

        Map<Schema.SObjectType, Schema.sObjectField[]> results = New Map<Schema.SObjectType, Schema.sObjectField[]>();
        for (ChildRelationship r: obj.getDescribe().getChildRelationships()) {
            Schema.SObjectField[] tmp = results.get(r.getChildSObject());
            if(includedObjects.contains(r.getChildSObject().getDescribe().getName())){
                if (tmp == null) tmp = New Schema.SObjectField[]{};
                tmp.add(r.getField());
                results.put(r.getChildSObject(), tmp);
            }
        }
        return results;
    }

    /*method to return error message.
    */ 
    public static String getErrorMessage() {
        return errorThrown;
    }

}