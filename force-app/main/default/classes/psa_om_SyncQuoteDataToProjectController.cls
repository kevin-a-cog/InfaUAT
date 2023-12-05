/*
@created by       : MAHESH GANTI
@created on       : 12/17/2020
@Purpose          : Controller Class to sync Quote data to Project

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
Wasim           25-May-2022     Sarojini            Party Address Master - Create new address reference   PSA-2447       <T1>   
                                                    fields on Project and Sync with Quote   
Wasim           25-Nov-2022     Ajay                PMO Project Page Automation Requests                  PSA-2681       <T2>                                      
Wasim 			17-May-2023		Neha				Service Units implementation - Assign Service credit  PSA-2606		 <T3>
													value to Proj from Quote
Wasim           16-Oct-2023     Wasim               The Billing Email when revised in the Quote should    PSA-3219       <T4>
                                                    sync to the project
****************************************************************************************************************************
*/
public without sharing class psa_om_SyncQuoteDataToProjectController {
    
    /**
* @description - Method called on Click of a Custom button on the Project record that will sync Primary Quote data on to the project
* @param projId - pass the project Id
* @return String : Success/Error.
* @throws exception - NA
*/
    @AuraEnabled
    public static String syncQuoteDate(Id projId){        
        String message;
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        if(FeatureManagement.checkPermission('PSA_Operations') || FeatureManagement.checkPermission('PSA_Deal_Desk')
           || userProfileName=='System Administrator'){ 
               try{
                   pse__Proj__c projRec = [SELECT id,Name,PSA_OM_ERP_Ship_to_Name_ID__c,PSA_OM_ERP_Bill_to_Name_ID__c,PSA_OM_ERP_Shipping_Site_ID__c,PSA_OM_ERP_Billing_Site_ID__c,PSA_OM_Ship_to_Account__c,PSA_OM_Bill_to_Account__c,PSA_OM_Bill_To_Contact__c,pse__Opportunity__c,psa_pm_Payment_Terms__c,PSA_OM_Planned_Margin__c,PSA_OM_Customer_Signoff__c,PSA_OM_Budget_Hours__c
                                           FROM pse__Proj__c WHERE ID = :projId LIMIT 1];           
                   Id oppId = projRec.pse__Opportunity__c;
                   
                   //<T1> - Added two new fields in the below query to sync from Quote
                   List<SBQQ__Quote__c> quoteRecList = new List<SBQQ__Quote__c>([SELECT Id,Business_Unit__c,ShipToContact__r.Peoplesoft_External_ID__c,BillToContact__r.Peoplesoft_External_ID__c,BillToAccount__r.Peoplesoft_External_ID__c,ShiptToAccount__r.Peoplesoft_External_ID__c,SBQQ__ShippingCity__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,SBQQ__ShippingPostalCode__c,
                                                                                 SBQQ__ShippingStreet__c,ShippingAddress_PSFTID__c,ShippingName_PSFTID__c,SBQQ__BillingPostalCode__c,Bill_to_Email__c,
                                                                                 BillingName_PSFTID__c,SBQQ__BillingStreet__c,SBQQ__BillingState__c,SBQQ__BillingCountry__c,SBQQ__BillingCity__c,
                                                                                 BillingAddress_PSFTID__c,ShiptToAccount__c,ShipToContact__c,PSA_OM_Planned_Margin__c,SBQQ__PaymentTerms__c,PO__c,
                                                                                 BillToAccount__c,BillToContact__c,Name,SBQQ__Opportunity2__c,SBQQ__Primary__c,PSA_OM_Customer_Signoff__c,Shipping_Email__c,
                                                                                 psa_Service_Units__c, PSA_OM_Budget_Hours__c, Bill_To_Additional_Reference_Info__c, Ship_To_Additional_Reference_Info__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true 
                                                                                 AND SBQQ__Opportunity2__c = :oppId LIMIT 1]);
                   if(!quoteRecList.isEmpty()){                       
                       pse__Proj__c updateProjRec = mapQuoteFieldValuesToProjectRec(projRec,quoteRecList[0]);
                       update updateProjRec;
                       message = 'Success:Sync Quote to Project is successful.';                       
                   }
                   else{
                       message = 'Info:There is no Primary Quote related to the Project Opportunity, Cannot Sync data from Quote';
                   }
               }
               catch(exception e){
                   message = 'Error:'+e.getMessage();
               } 
           }
           else{
               message ='Info:You do not have the ability to sync Quote to Project.';
           }
        return message;
    }
    /**    
    * @description - Method to map the project fields with quote values
    * @param projRec - project record
    * @param quoteRec - quote record
    * @return pse__Proj__c - project record
    * @throws exception - NA
    */
    public static pse__Proj__c mapQuoteFieldValuesToProjectRec(pse__Proj__c projRec,SBQQ__Quote__c quoteRec){
        
        // pse__Proj__c mappedProjectRec = projRec;        
        // projRec.Id = projRec.Id;        
        projRec.PSA_OM_Planned_Margin__c = quoteRec.PSA_OM_Planned_Margin__c;
        projRec.PSA_OM_Customer_Signoff__c = quoteRec.PSA_OM_Customer_Signoff__c;
        projRec.PSA_OM_Budget_Hours__c = quoteRec.PSA_OM_Budget_Hours__c;
        projRec.pse__Planned_Hours__c = quoteRec.PSA_OM_Budget_Hours__c;//<T2>
        projRec.psa_Service_Units__c = quoteRec.psa_Service_Units__c;//<T3>
        projRec.psa_pm_Payment_Terms__c =  quoteRec.SBQQ__PaymentTerms__c;
        projRec.PSA_Primary_Quote__c =  quoteRec.Id;
        projRec.PSA_OM_Billing_Email__c = quoteRec.Bill_to_Email__c;//<T4>
        projRec.PSA_OM_Shipping_Email__c = quoteRec.Shipping_Email__c;//<T4>
        projRec.PO_Number__c = quoteRec.PO__c;//<T4>
        // populate business unit
        if(!String.isBlank(quoteRec.Business_Unit__c)){
            List<psa_pm_Business_Unit__c> busUnitList = new List<psa_pm_Business_Unit__c>([SELECT Id,Name FROM psa_pm_Business_Unit__c WHERE NAME =:quoteRec.Business_Unit__c Limit 1]);
            projRec.psa_pm_Business_Unit__c = busUnitList[0].Id;
        }
        
        // Bill to details
        projRec.PSA_OM_Bill_to_Account__c = quoteRec.BillToAccount__c;
        projRec.PSA_ERP_Bill_To_Customer_Id__c =  quoteRec.BillToAccount__r.Peoplesoft_External_ID__c;
        projRec.PSA_OM_Bill_To_Contact__c =  quoteRec.BillToContact__c;
        projRec.PSA_ERP_Bill_To_Contact_Id__c =  quoteRec.BillToContact__r.Peoplesoft_External_ID__c;
        projRec.PSA_OM_Bill_To_City__c = quoteRec.SBQQ__BillingCity__c;
        projRec.PSA_OM_Bill_To_Street__c = quoteRec.SBQQ__BillingStreet__c;
        projRec.PSA_OM_Bill_To_State__c = quoteRec.SBQQ__BillingState__c;
        projRec.PSA_OM_Bill_To_Country__c = quoteRec.SBQQ__BillingCountry__c;
        projRec.PSA_OM_Bill_To_Postal_Code__c = quoteRec.SBQQ__BillingPostalCode__c;
        projRec.PSA_OM_Bill_To_Additional_Reference_Info__c = quoteRec.Bill_To_Additional_Reference_Info__c; //<T1>
        
        if(String.isBlank(projRec.PSA_OM_ERP_Bill_to_Name_ID__c)){
            projRec.PSA_OM_ERP_Bill_to_Name_ID__c = quoteRec.BillingName_PSFTID__c;
        }
        if(String.isBlank(projRec.PSA_OM_ERP_Billing_Site_ID__c)){
            projRec.PSA_OM_ERP_Billing_Site_ID__c = quoteRec.BillingAddress_PSFTID__c;
        }        
        // Ship to Details
        projRec.PSA_OM_Ship_to_Account__c =  quoteRec.ShiptToAccount__c;
        projRec.PSA_ERP_Ship_To_Customer_Id__c =  quoteRec.ShiptToAccount__r.Peoplesoft_External_ID__c;
        projRec.PSA_OM_Ship_to_Contact__c =  quoteRec.ShipToContact__c;
        projRec.PSA_ERP_Ship_To_Contact_Id__c =  quoteRec.ShipToContact__r.Peoplesoft_External_ID__c;
        projRec.PSA_OM_Ship_To_City__c =  quoteRec.SBQQ__ShippingCity__c;
        projRec.PSA_OM_Ship_To_Country__c =  quoteRec.SBQQ__ShippingCountry__c;
        projRec.PSA_OM_Ship_To_Postal_Code__c =  quoteRec.SBQQ__ShippingPostalCode__c;
        projRec.PSA_OM_Ship_To_State__c =  quoteRec.SBQQ__ShippingState__c;
        projRec.PSA_OM_Ship_To_Street__c =  quoteRec.SBQQ__ShippingStreet__c;
        projRec.PSA_OM_Ship_To_Additional_Reference_Info__c = quoteRec.Ship_To_Additional_Reference_Info__c; //<T1>

        if(String.isBlank(projRec.PSA_OM_ERP_Ship_to_Name_ID__c)){
            projRec.PSA_OM_ERP_Ship_to_Name_ID__c =  quoteRec.ShippingName_PSFTID__c;
        }
        if(String.isBlank(projRec.PSA_OM_ERP_Shipping_Site_ID__c)){
            projRec.PSA_OM_ERP_Shipping_Site_ID__c =  quoteRec.ShippingAddress_PSFTID__c;
        }        
        return projRec;        
    }
}