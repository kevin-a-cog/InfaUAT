/*
Class:          EntitledProductController 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Controller Class for Temporary Support
**************************************************************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                                                                          TAG
**************************************************************************************************************************
Vignesh D       I2RT-4972      Extend Support for entitled product, and also create temporary asset & entitlement   T01
Vignesh D       I2RT-5411      Update the format of EP Name                                                         T02
Vignesh D       I2RT-6212      Default Premium Success as the support level for Signature Success support accounts  T03
                               when creating temporary entitlements     
Sandeep D       I2rt-6485      clean up Techincal product lines                                                     t04
Vignesh D       I2RT-8398      Added filter to exclude Archived EPs                                                 T05
*/


public with sharing class EntitledProductController {
    

    //Retrive List of UnEntitled Products to be shown for temporary support 
    @AuraEnabled (cacheable=true)
    public static List<String> getUnEntitledProducts(Id AccountId){

            Set<String> EntitledProducts= new set<String>();
            List<String> lstDeliveryMethod = new List<String>();
            List<String> unEntitledProducts = new List<String>();

            //Get Active Entitled Products under the Support Account
            for(Entitled_Product__c EP: [Select Id,Name,Forecast_Product__c,Pricing_Model__c,Delivery_Method__c from Entitled_Product__c where Support_Account__c = :AccountId and End_Date__c >=Today AND Archived__c = false order by Name ASC]){ //<T05>
                EntitledProducts.add(EP.Name);
            }

            //Get Unentitled Product ( All Products from Technical Line  minus Entitled Products) T04 - added where condition to the query 
            for(Technical_Product_Line__c tp :[select Id,Name,Delivery_method__c from Technical_Product_Line__c Where status__c = 'Active'order by Name ASC])
            {
                if(tp.Name!=null && tp.Delivery_method__c!=null)
                {
                    if(tp.Delivery_method__c.contains(';'))
                    {
                        lstDeliveryMethod = tp.delivery_method__c.split(';');

                        if(!lstDeliveryMethod.isEmpty())
                        {
                            for(String dm: lstDeliveryMethod)
                            {
                                if(!String.isBlank(dm) && !EntitledProducts.contains(tp.Name +'('+ dm+')'))
                                {
                                    unEntitledProducts.add(tp.Name+'('+ dm+')');
                                }
                            }
                        }
                    }else {
                        if(!EntitledProducts.contains(tp.Name +'('+tp.delivery_method__c+')')) //<T02>
                        {
                            unEntitledProducts.add(tp.Name +'('+ tp.delivery_method__c+')');
                        }
                    }
                }
            }
            return unEntitledProducts;
       
    }


    //Create Temporary Support Entitled Product
    @AuraEnabled
    public static string upsertTempSupport(Id AccountId, String Product , Date EndDate, String SuccessOffering, String Reason){

            if(!String.isBlank(Product) && EndDate!= null){
                
                String ForecastProduct = '';
                String Delivery = '';

                //Retrive the Product name and Delivery method from the string
                Schema.DescribeFieldResult DeliveryValues = Entitled_Product__c.Delivery_Method__c.getDescribe();
                for(Schema.PicklistEntry del : DeliveryValues.getPicklistValues()){
                    if(Product?.contains(del.getLabel())){
                        Integer DeliveryIndex = Product.indexOf(del.getLabel());
                         Delivery = Product.substring(DeliveryIndex,Product.length()-1 );
                         ForecastProduct = Product.substring(0,DeliveryIndex-1 );
                    }
                }

               
                //Check if temporary Support EP exists for the same product
                List<Entitled_Product__c> lstTempSupport = [Select Id, Forecast_Product__c,Delivery_Method__c,End_Date__c from Entitled_Product__c where Manual_Creation_Override__c = true and Forecast_Product__c =:ForecastProduct and Delivery_Method__c = :Delivery and Support_Account__c =:AccountId AND Archived__c = false limit 1 ]; //<T05>

                //Get the customer account 
                Account SupportAccount = [Select Id,Active__c, ParentId, Success_Offering__c,End_Date__c from Account where Id =:AccountId limit 1];
                
                Account updateSupportAccount = new Account(Id= SupportAccount.Id);

                //Update existing temp support
                if(lstTempSupport?.size() > 0 ){
                    Entitled_Product__c tempEp = new Entitled_Product__c(Id = lstTempSupport[0].Id);
                    tempEp.End_Date__c = EndDate;
                    Update tempEp;

                }
                //Create new Temp Support EP
                else {
                    Entitled_Product__c newTempEP = new Entitled_Product__c();
                    newTempEP.Account__c = SupportAccount?.ParentId;
                    newTempEP.Support_Account__c = AccountId;
                    newTempEP.Name = ForecastProduct+'('+Delivery+')';
                    newTempEP.Forecast_Product__c=ForecastProduct;
                    newTempEP.Delivery_method__c = Delivery;
                    newTempEP.End_Date__c = EndDate;
                    //newTempEP.Support_level__c = SupportAccount?.Success_Offering__c;
                    newTempEP.Support_level__c = SuccessOffering;
                    newTempEP.Manual_Creation_override__c = true;
                    newTempEP.Reason_for_Temporary_Support__c = Reason;

                    Insert newTempEP;
                }

                 //@Akhilesh 27 Sept 2021 -- start
                 Boolean bUpdateSupportAccount = false;

                 if(SupportAccount.End_Date__c == null || SupportAccount.End_Date__c < System.Today()){

                    Asset ast= new Asset();
                    ast.Name = 'Temporary Support';
                    ast.Support_Account__c = AccountId;
                    ast.AccountId= SupportAccount?.ParentId;
                    //ast.SBQQ__SubscriptionEndDate__c= EndDate;
                    insert ast ;

                    String slaProcessId =null;
                    for(SlaProcess sp :[Select Id, Name From SlaProcess Where isActive =true And Name = :SuccessOffering limit 1]){
                        slaProcessId = sp.Id;
                    }

                    Entitlement ent = new Entitlement();
                    ent.Name = 'Temporary Support';
                    ent.Support_Level__c = SuccessOffering;
                    ent.SlaProcessId = slaProcessId;
                    ent.AccountId = SupportAccount.parentId;
                    ent.startDate = system.today();
                    ent.EndDate= EndDate;
                    ent.Assetid = ast.id;
                    insert ent;

                    updateSupportAccount.Entitlement__c = ent.Id;
                    bUpdateSupportAccount = true;
                 }                 
                 //@Akhielsh 27 Sept 2021 -- end
                 

                if(!SupportAccount.Active__c || bUpdateSupportAccount){
                    updateSupportAccount.Active__c = true;
                    Update updateSupportAccount;
                }

                return 'Success';
            }
            else{
                return 'Product Not Found';
            }
        
    }

    //---------------------------------------<T01>-----------------------------

    /*
     Method Name : extendProductSupport
     Description : This method extends the support for the entitled product.
     Parameters  : String, called from extendProductSupport, strEntitledProductObj.
     Return Type : Booelan.
     */
    @AuraEnabled
    public static Boolean extendProductSupport(String strEntitledProductObj){
        try {
            Entitled_Product__c objEntitledProduct = new Entitled_Product__c();
            objEntitledProduct = (Entitled_Product__c) JSON.deserialize(strEntitledProductObj, Entitled_Product__c.class);
            objEntitledProduct.Override_Entitlement_Date__c = true;

            //Now we update the entitled product.
            update objEntitledProduct;

            //Now we query the updated entitled product.
            Entitled_Product__c objEntitledProductUpdated = [Select Id,Account__c,Support_Account__c,End_Date__c from Entitled_Product__c where Id =: objEntitledProduct.Id];

            //Now we query Support Account.
            Account objSupportAccount = [Select Id,ParentId,Success_Offering__c from Account where Id =: objEntitledProductUpdated.Support_Account__c];

            //Now we create a temporary asset and associate it to entitled product.
            Asset objAsset= new Asset();
            objAsset.Name = 'Temporary Support';
            objAsset.AccountId= objSupportAccount.ParentId;
            objAsset.Support_Account__c = objSupportAccount.Id;
            objAsset.Entitled_Product__c = objEntitledProductUpdated.Id;
            insert objAsset;

            //Now we query active entitlement process for the success offering
            String strSuccessOffering = objSupportAccount.Success_Offering__c == 'Signature Success' ? 'Premium Success' : objSupportAccount.Success_Offering__c; //<T03>
            String strSlaProcessId = [Select Id from SlaProcess Where IsActive = true AND Name =: strSuccessOffering limit 1]?.Id; //<T03>
            
            //Now we create temporary entitlement and associate it to asset.
            Entitlement objEntitlement = new Entitlement();
            objEntitlement.Name = 'Temporary Support';
            objEntitlement.AccountId = objSupportAccount.ParentId;
            objEntitlement.Support_Level__c = strSuccessOffering; //<T03>       
            objEntitlement.SlaProcessId = strSlaProcessId;
            objEntitlement.StartDate = System.today();
            objEntitlement.EndDate= objEntitledProductUpdated.End_Date__c;
            objEntitlement.AssetId = objAsset.Id;
            insert objEntitlement;

            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //---------------------------------------</T01>-----------------------------
}