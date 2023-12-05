/*
Class:          OverrideTaxOnQuoteController
@Author:        Chandana Gowda
@Created Date:  14 Jul 2021
@Description:   Controller class for Quote Quick action Override Tax
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
***********************************************************************************************************************************************************
*/
public with sharing class OverrideTaxOnQuoteController {
    /* Method Name : setExemptStatusToOverride
    * @param mapNew - quoteId - Quote RecordId
    * @return return - String
    * @throws exception - NA
    * @description - Return true if Tax Exempt status is set to override, else returns false
    */    
    @AuraEnabled
    public static String setExemptStatusToOverride(Id quoteId){
        String res = 'Success';
        SBQQ__Quote__c quoteRec = [SELECT Id,Business_Unit__c,SoldToAccount__c,SoldToAccount__r.ERP_Company__c,Sold_to_Account_ERP_Site__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,SBQQ__ShippingCity__c,SBQQ__ShippingPostalCode__c,SBQQ__ShippingStreet__c FROM SBQQ__Quote__c WHERE Id = :quoteId];
        
        ERP_Site__c erpSitetoUpsert = new ERP_Site__c();
        //If ERP Site exists on Quote update the Exempt Status
        if(quoteRec.Sold_to_Account_ERP_Site__c != null){
            erpSitetoUpsert.Id = quoteRec.Sold_to_Account_ERP_Site__c;
            erpSitetoUpsert.Exempt_Status__c = 'Override';
        }else{
            Map<Id,ERP_Site__c> erpSiteMap = new Map<Id,ERP_Site__c>([SELECT Id,ERP_Company__c,State_Province__c,Country__c FROM ERP_Site__c WHERE ERP_Company__c = :quoteRec.SoldToAccount__r.ERP_Company__c]);
            Boolean erpSitePresent = false;
            //
            for(ERP_Site__c erpSite:erpSiteMap.values()){
                if(quoteRec.SBQQ__ShippingCountry__c == erpSite.Country__c && quoteRec.SBQQ__ShippingState__c == erpSite.State_Province__c){
                    erpSitePresent = true;
                    erpSitetoUpsert.Id = erpSite.Id;
                    erpSitetoUpsert.Exempt_Status__c = 'Override';
                    break;
                }
            }
            if(!erpSitePresent){
                erpSitetoUpsert.State_Province__c = quoteRec.SBQQ__ShippingState__c;
                erpSitetoUpsert.Country__c = quoteRec.SBQQ__ShippingCountry__c;
                erpSitetoUpsert.City__c = quoteRec.SBQQ__ShippingCity__c;
                erpSitetoUpsert.Address_Line_1__c = quoteRec.SBQQ__ShippingStreet__c;
                erpSitetoUpsert.ZIP_Code__c = quoteRec.SBQQ__ShippingPostalCode__c;
                erpSitetoUpsert.Name = quoteRec.SBQQ__ShippingCountry__c+'_'+quoteRec.SBQQ__ShippingState__c; //populating ERP Site Name as Country_State/Province
                erpSitetoUpsert.ERP_Company__c = quoteRec.SoldToAccount__r.ERP_Company__c;
                erpSitetoUpsert.Dev_Quote_Id__c = quoteId;
                erpSitetoUpsert.Exempt_Status__c = 'Override';
            }
        }                
        
        try{
            Database.UpsertResult upRes = Database.upsert(erpSitetoUpsert,false);
            if(!upRes.isSuccess()){
                res = 'Failed';
            }else{
                if(quoteRec.Sold_to_Account_ERP_Site__c == null){
                    SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(Id = quoteRec.Id,Sold_to_Account_ERP_Site__c = upRes.getId());
                    SBQQ.TriggerControl.disable();
                    update quoteToUpdate;
                    SBQQ.TriggerControl.enable();
                }
            }
        }catch(DmlException e){
            res = 'Failed';
        }
        return res;
    }
    /* Method Name : checkTaxApplicable
    * @param mapNew - quoteId - Quote RecordId
    * @return return - Boolean
    * @throws exception - NA
    * @description - Return true if Tax Applicable, else returns false
    */    
    @AuraEnabled(cacheable=true)
    public static Boolean checkTaxApplicable(Id quoteId){
        Boolean res = false;
        if(quoteId != null){
            SBQQ__Quote__c quoteRec = [SELECT Id,Business_Unit__c,Sold_to_Account_ERP_Site__c,SBQQ__ShippingCountry__c FROM SBQQ__Quote__c WHERE Id =:quoteId LIMIT 1];
            if(quoteRec.Business_Unit__c == 'US001'){
                Map<Id,Tax_Country__mdt> mapTaxCountries = new Map<Id,Tax_Country__mdt>([SELECT MasterLabel,CMS_Chatter_Group__c,CMS_Queue_Id__c FROM Tax_Country__mdt WHERE MasterLabel = :quoteRec.SBQQ__ShippingCountry__c AND Is_Taxable__c = true]);
                if(!mapTaxCountries.isEmpty()){
                    res = true;
                }
            }
        }
        return res;
    }    
}