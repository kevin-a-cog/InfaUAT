/****************************************************************************************************************************
 *  @Class Name: DealRegistrationAddProductsHandler
 *  @Author: Deloitte
 *  @Date: 2017-11-30 
 *  @Description:This is a helper class which pulls the Products for selection on a Lead for Partners
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public class DealRegistrationAddProductsHandler
{
    public static globalApexManager GAM = new globalApexManager();
    
	/* this method helps in validating the Deal Registration Status, if it's  'New' then show the Dynamic message on Community
    * @Method Name- newStatusCheckDR
    * @param parameter- string DealId
    * @return return- String
    * @throws exception-n/a
    */
    @AuraEnabled
    public static string newStatusCheckDR(String DealId)
    {
        string statusMessage='';
        List<Lead> drToQuery = new List<Lead>();
        String statusCheck;
        if(String.isNotBlank(DealId))
        {
            drToQuery = [SELECT Status from Lead where Id =:DealId Limit 1];
            
            if(!drToQuery.isEmpty() && drToQuery != Null){
                statusCheck = drToQuery[0].Status;
            }
            if(statusCheck != Null && statusCheck != '' && statusCheck == 'New')
            statusMessage = 'NEW';           
        }
        return statusMessage;
    }    
    
    /* this method helps in validating the Lead-Deal Registration Status, if it's not 'New' then blocks users from adding/removing products
    * @Method Name- SubmitStatusValidator
    * @param parameter- string DealId
    * @return return- String
    * @throws exception-n/a
    */
    @AuraEnabled
    public static string SubmitStatusValidator(String DealId)
    {
        string statusMessage='';
        List<Lead> drToQuery = new List<Lead>();
        integer numOfProd ;
        String statusCheck;
        if(String.isNotBlank(DealId))
        {
            drToQuery = [SELECT Status from Lead where Id =:DealId Limit 1];
            AggregateResult ar = [Select count(id) from Deal_Registration_Products__c where Lead__c =:DealId ];
            numOfProd = (integer)ar.get('expr0') ;
                
            if(!drToQuery.isEmpty() && drToQuery != Null){
                statusCheck = drToQuery[0].Status;
            }
            
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Lead;
            Boolean hasEditAccessOnDR = drSObj.isUpdateable();
            if(!hasEditAccessOnDR){
	            statusMessage = label.PRM_Sobject_Access_Error;
            }else if(statusCheck != 'New' && hasEditAccessOnDR){
	            statusMessage = label.PRM_DealRegistration_StatusValidationError;
            }else if(numOfProd==0){
	            statusMessage = label.PRM_DealSubmit_Error;
            }else{
	            statusMessage = Label.PRM_Success_Message;
            }           
        }
        return statusMessage;
    }
    
    
    /* this method helps in validating the Lead-Deal Registration Status, if it's not 'New' then blocks users from adding/removing products
    * @Method Name- StatusValidator
    * @param parameter- string DealId
    * @return return- String
    * @throws exception-n/a
    */
    @AuraEnabled
    public static string StatusValidator(String DealId)
    {
        string statusMessage='';       
        List<Lead> drToQuery = new List<Lead>();
        String statusCheck;
        if(String.isNotBlank(DealId))
        {
            drToQuery = [SELECT Status from Lead where Id =:DealId Limit 1];
            if(!drToQuery.isEmpty() && drToQuery != Null){
                statusCheck = drToQuery[0].Status;
            }            
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Lead;
            Boolean hasEditAccessOnDR = drSObj.isUpdateable();
            if(!hasEditAccessOnDR){
	            statusMessage = label.PRM_Sobject_Access_Error;
            }else if(statusCheck != 'New' && hasEditAccessOnDR){
	            statusMessage = label.PRM_DealRegistration_StatusValidationError;
            }else{
	            statusMessage = Label.PRM_Success_Message;
            }           
        }
        return statusMessage;
    }
    
    /* this method helps in submitting a deal for approval for the first time.
    * @Method Name- SubmitDealForApproval
    * @param parameter- string DealId
    * @return return- String
    * @throws exception-n/a
    */
    @AuraEnabled
    public static string SubmitDealForApproval(String DealId)
    {
        string statusMessage='';
        List<Lead> drToUpdate = new List<Lead>();
        
        for(Lead dr : [SELECT Id,Status,RecordTypeId from Lead where Id =:DealId AND Status = 'New'])
        {
            dr.Status = 'Received';
            drToUpdate.add(dr);
        }
        
        try
        {
            if(!drToUpdate.isEmpty() && Schema.getGlobalDescribe().get('Lead').getDescribe().isUpdateable())
            {
                Database.SaveResult[] DR_update = Database.update(drToUpdate);
                statusMessage = Label.PRM_Success_Message;
            }
            else
            {
                statusMessage=label.PRM_DealRegistration_StatusValidationError;
            }
        }
        catch(DmlException e)
        {
        	GAM.CreateLogs('DealRegistrationAddProductsHandler:SubmitDealForApproval At 108','ApexClass:DealRegistrationAddProductsHandler');
        	return e.getdmlMessage(0);
        }
       return statusMessage;
    }
    
    /* this method will fetch the products based on the entered keyword in searchbar comparing with the 'Name' field
    * @Method Name- productSearchBar
    * @param parameter- string searchKeyWord,String pillsList, String fieldQry
    * @return return- List<Product2>
    * @throws exception-Stores into Exceptions logs custom Object
    */
    
    @AuraEnabled 
    public static List<Product2> productSearchBar(String searchKeyWord,String pillsList, String fieldQry){
        String searchKey = '%' + searchKeyWord + '%';
        List<Product2> lstProdRecords = new List<Product2>(); 
        
        Set<String> PRMProdFamilySet = new Set<String>(); 
        if(PRMProdFamilySet.isEmpty())
        {
            PRMProdFamilySet = PRMProductHandlerUtility.prmProductFamilySet(); 
        }
        
        if(!PRMProdFamilySet.isEmpty())
        {
            String SOQL1 = 'Select ' + fieldQry + ' from Product2 Where Name LIKE: searchKey AND Product_Family__c IN: PRMProdFamilySet'+
                ' AND Forecastable__c=True AND IsActive=True order by Name Limit '+(Limits.getLimitQueryRows() - Limits.getQueryRows());
            
            lstProdRecords = Database.query(SOQL1); 
        }
        
        //@26-06 Added this part to avoid user to select same pills again.
        GAM.CreateLogs('opportunityUpdate','pillsList: '+pillsList);
        
        try {
            GAM.InsertDebugLogs();  
        } catch(Exception e){
            for(Product2 product :lstProdRecords){
                GAM.CreateExceptionRecords('productSearchBar', e.GetMessage(), product.Id);
            }
        }
        
        return  lstProdRecords;
    }
    
    /* this method will Save the selected products to the Deal Registration Product Table
    * @Method Name- saveSelectedProducts
    * @param parameter- string oppProdRecords,String oppId, String transactionType
    * @return return- String
    * @throws exception-Shows Exception Error on Toast
    */
   
    @AuraEnabled
    public static String saveSelectedProducts(string dealProdRecords,String dealRegId) 
    {
        string retMsg='';
        List<Deal_Registration_Products__c> drProdsLst = new List<Deal_Registration_Products__c>();
        if(!string.isBlank(dealProdRecords)){
            List<Product2> productsList = (List<Product2>)System.JSON.deserialize(dealProdRecords,List<Product2>.class);
            for(Product2 product:productsList)
            {
                Deal_Registration_Products__c drProduct = new Deal_Registration_Products__c(
                                        Lead__c=dealRegId,
                                        Product__c=product.Id
                                        );
                drProdsLst.add(drProduct);
            }
            try
            {
                if(drProdsLst != null && !drProdsLst.isEmpty())
                {
                    //insert drProdsLst;
                    Database.SaveResult[] DR_Prdct_insert = Database.insert(drProdsLst);
                    retMsg = 'Success';
                }
            } 
            catch(DmlException e)
            {
                return e.getdmlMessage(0);
            }
        
    }return retMsg;
    }
    
    /** 
    * Get Fields in specified FieldSet
    * @Method Name- getFields
    * @param typeName - SObject Name (i.e. Account, Contact, Opportunity, etc.)
    * @param fsName - FieldSet Name 
    * @return List of FieldSetMember Object 
    */
    
    @AuraEnabled
    public static List<PRMProductHandlerUtility.FieldSetMember> getFields(String typeName, String fsName) 
    {
        return PRMProductHandlerUtility.getFieldDetails(typeName,fsName);
    }
    
    
    /* this method will fetch the already saved products on the popup pills.
    * @Method Name- getSavedDealRegProducts
    * @param parameter- string DealRegId
    * @return return- List<Deal_Registration_Products__c>
    * @throws exception-n/a
    */
    
    @AuraEnabled
    public static List<Deal_Registration_Products__c> getSavedDealRegProducts(String DealRegId)
    {
        List<Deal_Registration_Products__c> listToPopulate = new List<Deal_Registration_Products__c>();
        if(String.isNotBlank(DealRegId))
        {
            listToPopulate = [select id,product__r.name from Deal_Registration_Products__c where Lead__c =:DealRegId];
        }
        return listToPopulate;
    }
    
    /* this method will help in deleting the deal registration products from the selected product pilllist
    * @Method Name- deleteSavedDealRegProducts
    * @param parameter- string DealRegProdId,DealRegId
    * @return return- String
    * @throws exception-Shows Exception Error on Toast
    */
    
    @AuraEnabled
    public static String deleteSavedDealRegProducts(List<String> DealRegProdId,String DealRegId)
    {
        string retMsg='';
        List<Deal_Registration_Products__c> listToDelete;

        if(DealRegProdId !=null && !DealRegProdId.isEmpty())
        {
            listToDelete = [select id from Deal_Registration_Products__c where Id IN :DealRegProdId];
            
        }
        If(listToDelete !=null && !listToDelete.isEmpty())
        {
            try
            {
                if(listToDelete != null && !listToDelete.isEmpty() && 
                Schema.getGlobalDescribe().get('Deal_Registration_Products__c').getDescribe().isDeletable())
                {
                    //Delete listToDelete;
                    Database.DeleteResult[] DR_Prdct_Dels = Database.delete(listToDelete);
                    retMsg = 'Success';
                }            
            } 
            catch(DmlException e)
            {
                GAM.CreateLogs('DealRegistrationAddProductsHandler:deleteSavedDealRegProducts At 262','ApexClass:DealRegistrationAddProductsHandler');
                return e.getdmlMessage(0);
            }
        }
        return retMsg;
    }

}