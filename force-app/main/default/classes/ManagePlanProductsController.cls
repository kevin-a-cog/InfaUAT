/**
 * @description       : 
 * @author            : Vignesh D
 * @group             : 
 * @last modified on  : 09-07-2020
 * @last modified by  : Vignesh D
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   09-04-2020   Vignesh D   Initial Version
 * 2.0   09-02-2021   Pavithra V  Update the Exception handling code
**/


public with sharing class ManagePlanProductsController {

    //To get all assigned plan products for a given plan    
    @AuraEnabled
    public static List<Related_Account_Plan__c> getPlanProducts(String planId){

        if(String.isNotBlank(planId)){
            List<Related_Account_Plan__c> planProducts = [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Product__c,Risk_formula__c,CurrencyIsoCode,convertCurrency(ARR__c) ConvertedARR__c from Related_Account_Plan__c where Account_Plan__c =: planId order by Status__c ASC];
            return planProducts;
        }
        else{
            return null;
        }
    }

   //To get all account products that are assigned to a plan.
    @AuraEnabled
    public static List<Related_Account_Plan__c> getPlanProducts2(String planId, String AccountId){
        
        if(String.isNotBlank(AccountId)){
            List<Related_Account_Plan__c> planProducts = [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Risk_formula__c,CurrencyIsoCode,convertCurrency(ARR__c) ConvertedARR__c from Related_Account_Plan__c where Account_Plan__r.Account__c = :AccountId and Account_Plan__c != null order by Status__c ASC];
            return planProducts;
        }
        else{
            return null;
        }

    }

    //To get all unassigned account products.
    @AuraEnabled
    public static List<Related_Account_Plan__c> getAllPlanProducts(String AccountId, Boolean showNotApplicable){
        System.debug('AccountId -> '+AccountId);
        if(String.isNotBlank(AccountId)){
            if(!showNotApplicable){
                List<Related_Account_Plan__c> planProducts = [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Risk_formula__c,CurrencyIsoCode,convertCurrency(ARR__c) ConvertedARR__c from Related_Account_Plan__c where Account__c =: AccountId and Account_Plan__c = null and Stage__c NOT IN ('Not Applicable') and Status__c NOT IN ('Expired') order by Status__c ASC];
                return planProducts;
            }
            else{
                List<Related_Account_Plan__c> planProducts = [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Risk_formula__c,CurrencyIsoCode,convertCurrency(ARR__c) ConvertedARR__c from Related_Account_Plan__c where Account__c =: AccountId and Account_Plan__c = null and Status__c NOT IN ('Expired') order by Status__c ASC];
                return planProducts;
            }
        }
        else{
            return null;
        }
    }

    
    @AuraEnabled
    public static String savePlanProducts(List<Related_Account_Plan__c> planProducts){
        String returnMessage;

        if(planProducts != null && planProducts.size() > 0){
            try{
                update planProducts;
                returnMessage = 'SUCCESS';

            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }

        return returnMessage;

    }
    

    @AuraEnabled
    public static string removePlanFromPlanProducts(List<Related_Account_Plan__c> planProducts){
        String returnMessage;

        if(planProducts != null && planProducts.size() > 0){
            for(Related_Account_Plan__c pp : planProducts){
                pp.Account_Plan__c = null;
            }

            try{
                update planProducts;
                returnMessage = 'SUCCESS';

            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }

        return returnMessage;
    }

    @AuraEnabled
    public static string addPlanProductsToPlan(List<Related_Account_Plan__c> planProducts, String planId){
        String returnMessage;

        if(planProducts != null && planProducts.size() > 0 && String.isNotBlank(planId)){
            for(Related_Account_Plan__c pp : planProducts){
                pp.Account_Plan__c = planId;
            }
            try{
                update planProducts;
                returnMessage = 'SUCCESS';

            }
            catch(Exception e){
                returnMessage = 'Error: '+e.getMessage();
            }
        }
        return returnMessage;
    }

    //To get dynamic lookup results based on the user input
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String SearchKey = '%'+String.escapeSingleQuotes(searchTerm)+'%';
        if(filter != null && filter != ''){
            List<sObject> lookUpList = [Select Id, Name from Plan__c Where Name Like :SearchKey AND Account__c = :filter];
            return lookUpList;
        }
        else{
            return null;
        }
    }

     /*Method to fetch record types.
    * @param Name - none
    * @throws exception -n/a
    * @return Map<Id,String>
    */

    @AuraEnabled       
    public static Map<Id,String> getRecordTypeValues(){
        
        Map<Id, String> recordtypeMap = new Map<Id, String>();
        //Get all record types of Contact object
        List<Schema.RecordTypeInfo> recordTypeInfoList = Plan__c.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo info: recordTypeInfoList) {
            //Check record type is available for current user profile
            if(info.isAvailable()) {
                //Check master record type
                if(info.getName() != 'Master' && info.getName().trim() != ''){
                    recordtypeMap.put(info.getRecordTypeId(), info.getName());
                }                
            }
        }    
        
        return recordtypeMap;
    }

     /*Method to fetch account id from lob id.
    * @param Name - lobid
    * @throws exception -n/a
    * @return Accountid
    */
    
    @AuraEnabled
    public static Id LOBrcrd(String recrdID){ 
        Id idval = Id.valueof(recrdID);
		Account_LOB__c lobrcrd = new Account_LOB__c();
		if(idval.getSObjectType().getDescribe().getName()  == 'Account_LOB__c')
    	  lobrcrd	=  [select id,Name,Account__c,Account__r.Name from Account_LOB__c where id =:recrdID];
        
            
        
        return lobrcrd.Account__c;
    }

    /*Method to create plan.
    * @param Name - planrecord, recordtype
    * @throws exception -n/a
    * @return Boolean---Created plan id
    */

    @AuraEnabled
    public static string insertplan(String planRec,String planRecTypeId) {
        system.debug('PLAN RECORD DETAILS'+planRec);
        system.debug('plan rec type'+planRecTypeId);
        Plan__c planRecordToCreate = (Plan__c)JSON.deserialize(planRec, Plan__c.class);
        planRecordToCreate.RecordTypeId = planRecTypeId;       
		
        if(planRecordToCreate != null){
            insert planRecordToCreate;
        }
        return planRecordToCreate.Id;
    }

     /*Method to get the plan product count.
    * @param Name - planId
    * @throws exception -n/a
    * @return Boolean---Response will be true if Account has atleast one assigned/unassigned plan products
    */
    @AuraEnabled
    public static Boolean planproductcount(String recid){
        List<string> lstIncludeOfferingType = Label.A2RIncludeOfferingTypes.split(';');
        Boolean planproducexist = false;
        List<Related_Account_Plan__c> planproducst = new List<Related_Account_Plan__c>();
        for(Related_Account_Plan__c rp: [SELECT Id from Related_Account_Plan__c where (Account__c = :recid OR Account_Plan__r.Account__c = :recid) and Offering_Type__c IN :lstIncludeOfferingType and Status__c = 'Active' LIMIT 1]){
            planproducexist = true;
        }
         
        return planproducexist;
    }

     /*Method to get the if there are zero plan products.
    * @param Name - planId
    * @throws exception -n/a
    * @return Boolean---Response will be true  if plan or account has atleast assigned/unassigned plan products
    */
    @AuraEnabled
    public static Boolean getplanproductslist(String recid){
        
        List<string> lstIncludeOfferingType = Label.A2RIncludeOfferingTypes.split(';');
        List<Related_Account_Plan__c> planproducts = new List<Related_Account_Plan__c>();
        Plan__c pl = new Plan__c();
        Boolean bl;
        planproducts = [SELECT Id from Related_Account_Plan__c where Account_Plan__c = :recid and Offering_Type__c IN :lstIncludeOfferingType and Status__c = 'Active' LIMIT 1];
        if(planproducts.size() == 0){
        	pl = [ SELECT Id, Account__c,RecordType.DeveloperName from Plan__c where Id = :recid];
            String rectypes = Label.planrectypes;
            if(rectypes.contains(pl.RecordType.DeveloperName)){
                bl = true;
            } else {
            	bl = !planproductcount(pl.Account__c);
            }
        } else {
            bl = TRUE;
        }
         
        return bl;
    }
    


}