/****************************************************************************************************************************
 *  @Class Name: AuraProductRequestAddProductsHandler
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-11-30 
 *  @Description:This is a helper class which pulls the Products for selection on an Engagement for Partners
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public class AuraProductRequestAddProductsHandler
{
    public static globalApexManager GAM = new globalApexManager();
    
    /* this method helps in validating the Engagement Status, if it's already 'Fulfilled' then blocks users from adding/removing products
    * @Method Name- StatusValidator
    * @param parameter- string EgmtId
    * @return return- String
    * @throws exception-n/a
    */
    @AuraEnabled
    public static string StatusValidator(String EgmtId)
    {
        string statusMessage='';
        if(String.isNotBlank(EgmtId))
        {
            List<Engagement__c> engmntList = [SELECT Status__c from Engagement__c where Id =:EgmtId];
            system.debug('engmntList :'+engmntList);
            String statusCheck = [SELECT Status__c from Engagement__c where Id =:EgmtId].Status__c;
            Schema.DescribeSObjectResult egmtSObj = Schema.sObjectType.Engagement__c;
            Boolean hasEditAccessOnEgmt = egmtSObj.isUpdateable();
            
            if(!hasEditAccessOnEgmt){
            	statusMessage = label.PRM_Sobject_Access_Error;
        	}
            else if(statusCheck == 'Fulfilled' && hasEditAccessOnEgmt){
            	statusMessage = label.PRM_Engagement_StatusValidationError;
    		}
            else{
            	statusMessage = 'SUCCESS';
			}			           
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
        system.debug('searchKeyWord :'+searchKeyWord);
        system.debug('pillsList :'+pillsList);
        system.debug('fieldQry :'+fieldQry);
        String searchKey = '%' + searchKeyWord + '%';
        List<Product2> lstProdRecords = new List<Product2>();
        
        //String SOQL1 = 'Select Id,Name,Product_Family__c,Family,Delivery_Method__c,Pricing_Business_Model__c,Processing_Engine__c from Product2 Where Name LIKE: searchKey AND Forecastable__c=True AND IsActive=True';
        String SOQL1 = 'Select ' + fieldQry + ' from Product2 Where Name LIKE :searchKey AND PRM_Products__c <> null AND IsActive=True AND Orderable__c=True order by Name';
        
        lstProdRecords = Database.query(SOQL1); 
        
        //@26-06 Added this part to avoid user to select same pills again.
        GAM.CreateLogs('opportunityUpdate','pillsList: '+pillsList);
		List<Product2> pillsListSelected = (List<Product2>)System.JSON.deserialize(pillsList,List<Product2>.class);
        for(Product2 objlstProdRecords: lstProdRecords){
            for(Product2 pill:pillsListSelected){
                if(objlstProdRecords.Id == pill.Id){
                    objlstProdRecords.Is_Selected__c= true;
                }
            }
        }
        
        try {
            GAM.InsertDebugLogs();  
        } catch(Exception e){
            for(Product2 product :lstProdRecords){
                GAM.CreateExceptionRecords('productSearchBar', e.GetMessage(), product.Id);
            }
        }
        return  lstProdRecords;
    }
	
    /* this method will fetch the products based on the selected value from the 'Products' picklist
    * @Method Name- searchProducts
    * @param parameter- string family,String pillsList, String fieldsStrQry
    * @return return- List<Product2>
    * @throws exception-Stores into Exceptions logs custom Object
    */
    
    @AuraEnabled
    public static List<Product2> searchProducts(String family, String pillsList, String fieldsStrQry)
    {
        system.debug('family :'+family);
        system.debug('pillsList :'+pillsList);
        system.debug('fieldsStrQry :'+fieldsStrQry);
        List<Product2> lstProdRecords = new List<Product2>();
        
        String SOQL = 'Select ' + fieldsStrQry + ' from Product2 where PRM_Products__c <> null AND IsActive=True AND Orderable__c=True';
        
        if(family != NULL && !String.isBlank(family))
            SOQL += ' AND PRM_Products__c = \''+family+'\' ';
        
        SOQL += ' order by Name'; 
        lstProdRecords = Database.query(SOQL);
        
        //Added this part to avoid user to select same pills again.
        List<Product2> pillsListSelected = (List<Product2>)System.JSON.deserialize(pillsList,List<Product2>.class);
        for(Product2 objlstProdRecords: lstProdRecords){
            for(Product2 pill:pillsListSelected){
                if(objlstProdRecords.Id == pill.Id){
                    objlstProdRecords.Is_Selected__c= true;
                }
            }
        }
        return lstProdRecords;
    }
    
    
    /* this method will Save the selected products to the Deal Registration Product Table,if 
    * they don't need additional data like IpAddress,HostNames etc, else navigates users to another screen asking to fill those additional details.
    * @Method Name- saveSelectedProducts
    * @param parameter- string ProdReqRecords,String EgmtId
    * @return return- List<PRMProductHandlerUtility.PRMProductHandlerUtility>
    * @throws exception-Shows Exception Error on Toast
    */
   
    @AuraEnabled
    public static List<PRMProductHandlerUtility> saveSelectedProducts(string ProdReqRecords,String EgmtId)
    {
        List<PRMProductHandlerUtility> customProdList = new List<PRMProductHandlerUtility>();
        Set<Id> rcvdProdIds = new Set<Id>();
        List<Product_Request__c> ProdReqsLst = new List<Product_Request__c>();
        Map<Id,String> prodNeedValidation = new Map<Id,String>();
        Map<Id,String> prodNoNeedValidation = new Map<Id,String>();
        if(!string.isBlank(ProdReqRecords))
        {
         try
         {
            List<Product2> productsList = (List<Product2>)System.JSON.deserialize(ProdReqRecords,List<Product2>.class);
            
            for(Product2 product:productsList)
            {
                rcvdProdIds.add(product.Id);               
            }
             
            if(!rcvdProdIds.isEmpty())
        	{
            	for(Product2 pd2 : [SELECT Id,Name from Product2 where Id IN :rcvdProdIds])
            	{
                   	prodNoNeedValidation.put(pd2.Id,pd2.Name);
           	 	}
        	} 
             
            //products which needs validation
            prodNeedValidation = productValidaterequired(rcvdProdIds);
          	
             system.debug('NeedValidation :'+prodNeedValidation);
             system.debug('All products :'+prodNoNeedValidation);
            for (Id key : prodNeedValidation.keySet())
			{
    			prodNoNeedValidation.remove(key);
			}
             system.debug('prodNoNeedValidation :'+prodNoNeedValidation);
             
          if(!prodNoNeedValidation.isEmpty())
          {
             for(Id i : prodNoNeedValidation.Keyset())
             {
                 PRMProductHandlerUtility psdp = new PRMProductHandlerUtility();
                    psdp.productrefId = i;
                    if(prodNoNeedValidation.Keyset().Contains(i))
                    {
                        psdp.productrefName = prodNoNeedValidation.get(i);
                    }
                    else
                    {
                        psdp.productrefName = '';
                    }
                    psdp.orgID = '';
                    psdp.ipAddress = '';
                    psdp.hostName = '';
                    psdp.reqType = '';
                 	psdp.Comments = '';
                    psdp.LicenseKeyOrgID = '';
                    psdp.requestupdatedkey = '';
                 	psdp.reqFieldsYes = false;
                    psdp.statusMsg='NeedValidation';
                 	customProdList.add(psdp);
                 
             } 
          }
          if(!prodNeedValidation.isEmpty())
          { 
             
             for(Id i : prodNeedValidation.Keyset())
             {
                 PRMProductHandlerUtility psdp = new PRMProductHandlerUtility();
                    psdp.productrefId = i;
                    if(prodNeedValidation.Keyset().Contains(i))
                    {
                        psdp.productrefName = prodNeedValidation.get(i);
                    }
                    else
                    {
                        psdp.productrefName = '';
                    }
                    psdp.orgID = '';
                    psdp.ipAddress = '';
                    psdp.hostName = '';
                    psdp.reqType = '';
                 	psdp.Comments = '';
                    psdp.LicenseKeyOrgID = '';
                    psdp.requestupdatedkey = '';
                 	psdp.reqFieldsYes = true;
                    psdp.statusMsg='NeedValidation';
                 	customProdList.add(psdp);
                 
             }           
          }
       } 
       catch(Exception e)
       {PRMProductHandlerUtility psdp = new PRMProductHandlerUtility();psdp.productrefId = '';psdp.productrefName = '';psdp.orgID = '';psdp.ipAddress = '';psdp.hostName = '';psdp.reqType = '';psdp.Comments = '';psdp.LicenseKeyOrgID = '';psdp.requestupdatedkey = '';psdp.statusMsg=e.getMessage();customProdList.add(psdp);} 
    }
    system.debug('customProdList :'+customProdList);
    return customProdList;
    }
    
    public static Map<Id,String> productValidaterequired(Set<Id> productIds)
    {
        
        Set<String> validatedProdSet = new Set<String>();
        Map<Id,String> selectedProductsIdNameMap = new Map<Id,String>();
        Map<Id,String> productIdNameMap = new Map<Id,String>(); 
        List<String> InvalidProducts = new List<String>();
        
        //Get the Product Names listed in the Custom Metadata
        for(PRM_Custom_Data_Settings__mdt metadata : [SELECT Host_Name_Products__c,IP_Address_Products__c,New_Request_Products__c,New_Request_Org_ID_Weblink__c from PRM_Custom_Data_Settings__mdt limit 1])
        {
          if(metadata.IP_Address_Products__c != null && metadata.IP_Address_Products__c != ''){
              validatedProdSet.addAll(((metadata.IP_Address_Products__c).deleteWhitespace()).split(','));
          }
          if(metadata.Host_Name_Products__c != null && metadata.Host_Name_Products__c != ''){
              validatedProdSet.addAll(((metadata.Host_Name_Products__c).deleteWhitespace()).split(','));
          }
          if(metadata.New_Request_Products__c != null && metadata.New_Request_Products__c != ''){
              validatedProdSet.addAll(((metadata.New_Request_Products__c).deleteWhitespace()).split(',')); 
          }
        }
        
        if(!productIds.isEmpty())
        {
            for(Product2 pd2 : [SELECT Id,Name from Product2 where Id IN :productIds])
            {
               if(validatedProdSet.Contains((pd2.Name).deleteWhitespace()))
                   
               selectedProductsIdNameMap.put(pd2.Id,pd2.Name);
            }
        }
         
       return selectedProductsIdNameMap;
    }
     
    @AuraEnabled
    public static string saveProductsWithAdditionalDetails(string productData,String EgmtId) 
    {
        string retMsg='';
        if(!string.isBlank(productData))
        {
            List<Product_Request__c> productReqToinsert = new List<Product_Request__c>();
            
            List<PRMProductHandlerUtility> lstProductRecords = 
            (List<PRMProductHandlerUtility>)
            System.JSON.deserialize(productData,List<PRMProductHandlerUtility>.class);
             
            for(PRMProductHandlerUtility objProductRecords : lstProductRecords)
            {
                Product_Request__c preq = new Product_Request__c
                (
                    Engagement__c=EgmtId,
                    Is_this_a_new_request__c=objProductRecords.reqType,
                    Please_enter_existing_request_email_OrgI__c=objProductRecords.orgID,
                    Product__c=objProductRecords.productrefId,
                    What_is_the_machine_host_name__c=objProductRecords.hostName,
                    What_is_your_IP_Address__c=objProductRecords.ipAddress,
                    Comments__c=objProductRecords.Comments,
                    License_Key_Org_ID__c=objProductRecords.LicenseKeyOrgID,
                    Is_this_a_request_for_an_updated_key__c=objProductRecords.requestupdatedkey
                );
                productReqToinsert.add(preq);
                
            }
            
            try
            {
                system.debug('productReqToinsert :'+productReqToinsert);
                if(!productReqToinsert.isEmpty())
                {
                    insert productReqToinsert;
                    retMsg = 'Success';
                }
            }
            
            catch(DmlException e)
            {
                system.debug('e :'+e);
                retMsg = e.getdmlMessage(0);
            }   
        }
    return retMsg;
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
    * @Method Name- getSavedProductRequests
    * @param parameter- string EgmtId
    * @return return- List<Product_Request__c>
    * @throws exception-n/a
    */
    
    @AuraEnabled
    public static List<Product_Request__c> getSavedProductRequests(String EgmtId)
    {
        List<Product_Request__c> listToPopulate = new List<Product_Request__c>();
        if(String.isNotBlank(EgmtId))
        {
            listToPopulate = [select id,product__r.name from Product_Request__c where Engagement__c =:EgmtId];
        }
        return listToPopulate;
    }
    
    /* this method will help in deleting the deal registration products from the selected product pilllist
    * @Method Name- deleteSavedProductRequests
    * @param parameter- string ProdReqId,EgmtId
    * @return return- String
    * @throws exception-Shows Exception Error on Toast
    */

    @AuraEnabled
    public static String deleteSavedProductRequests(List<String> ProdReqId,String EgmtId)
    {
        system.debug('ProdReqId :'+ ProdReqId);
        List<Product_Request__c> listToDelete;
        string retMsg='';
        if(ProdReqId !=null && !ProdReqId.isEmpty())
        {
            listToDelete = [select id from Product_Request__c where Id IN :ProdReqId];
            
        }
        If(listToDelete !=null && !listToDelete.isEmpty())
        {
            try
            {
                if(listToDelete != null && !listToDelete.isEmpty() && 
                Schema.getGlobalDescribe().get('Product_Request__c').getDescribe().isDeletable())
                {
                    Delete listToDelete;
                    retMsg = 'Success';
                }            
            } 
            catch(DmlException e)
            {return e.getdmlMessage(0);}
        }
        return retMsg;
    }
    
    /* this method helps in returning the new Org Id generate URL to the Partners
    * @Method Name- getNewOrgIdURL
    * @param parameter- 
    * @return - URL String
    * @throws exception- with an empty URL
    */
    
    @AuraEnabled
    public static String getNewOrgIdURL() 
    {
       String orgIdURL;
       try
       {
           orgIdURL = [SELECT New_Request_Org_ID_Weblink__c from PRM_Custom_Data_Settings__mdt limit 1].New_Request_Org_ID_Weblink__c ;
       }
       catch(Exception e)
       {orgIdURL = '';}
       return orgIdURL;
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
    
    /* this method helps in returning the Controlling field values(as Key) and Dependent field Values(as Values) of dependent picklists
    * @Method Name- getDependentOptionsImpl
    * @param parameter- string objApiName,contrfieldApiName,depfieldApiName
    * @return return- Map<String, List<String>>
    * @throws exception-n/a
    */
    
    @AuraEnabled
    public static Map<String, List<String>> getDependentOptionsImpl(String objApiName, String contrfieldApiName, String depfieldApiName)
    {       
        return PRMProductHandlerUtility.getDependentPicklistValues(objApiName,contrfieldApiName,depfieldApiName);
    }
}