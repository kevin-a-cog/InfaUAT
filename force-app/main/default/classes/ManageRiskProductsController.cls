/*
* Class :        ManageRiskProductsController
* Author:        Ambica P
* Created Date:  5 Sep 2020
* Description:   Controller class for Manage Risk Products Creation 
*/

public with sharing class ManageRiskProductsController {

        @AuraEnabled
        public static string insertRisk(string riskRec){
                Risk_Issue__c riskRecordToCreate = (Risk_Issue__c)JSON.deserialize(riskRec, Risk_Issue__c.class);
                riskRecordToCreate.RecordTypeId =label.RiskRecType;

                try {
                        insert riskRecordToCreate;
                   } catch (System.DmlException e) {
                       system.debug('Exception while creating risk'+e.getmessage());
                   }
                return riskRecordToCreate.Id;
        }

        @AuraEnabled
        public static List<Related_Risk_Product__c> getRiskProducts(String riskId){
               
                if(String.isNotBlank(riskId)){
                List<Related_Risk_Product__c> lstRiskProducts = new List<Related_Risk_Product__c>();
              //  String qureyStr = 'Select Id,Name,Plan_Product__c,Plan_Product__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c from Related_Risk_Product__c where Risk_Issue__c =\''+riskId+'\'' ;

                lstRiskProducts = [Select Id,Name,Plan_Product__c,Account_Product__c,Account_Product__r.Forecast_Product__c,Plan_Product__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c from Related_Risk_Product__c where Risk_Issue__c = :riskId ];
                return lstRiskProducts;
                }

                return null;
        }

        @AuraEnabled
        public static List<Related_Account_Plan__c> getPlanProducts(String riskId, String planId){


                List<Related_Account_Plan__c> lstPlanProducts = new List<Related_Account_Plan__c>();
                set<Id> riskProdIds = new set<id>();
                for( Related_Risk_Product__c riskProd : [Select Id,Plan_Product__c from Related_Risk_Product__c where Risk_Issue__c =:riskId] ){
                        riskProdIds.add(riskProd.plan_product__c);
                }
                //Get other plan product from risk'splan 
                lstPlanProducts = [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Risk_formula__c,Product__c,CurrencyIsoCode,convertCurrency(ARR__c) ConvertedARR__c from Related_Account_Plan__c where Account_Plan__c = :planId and Id not in :riskProdIds ];

                return lstPlanProducts;
        }

        @AuraEnabled
        public static string removeRiskProducts(List<Related_Risk_Product__c> riskProducts){
                string returnMessage;
                if(riskProducts != null && riskProducts.size() > 0){
                        try{
                            delete riskProducts;
                            returnMessage = 'SUCCESS';
                        }
                        catch(Exception e){
                            returnMessage = 'Error: '+e.getMessage();
                        }
                }
                return returnMessage ;
        }

        @AuraEnabled
        public static string addRiskProducts( List<Related_Account_Plan__c> planProducts,String riskId){
                string returnMessage;

                List<Related_Risk_Product__c> lstRiskProducts = new List<Related_Risk_Product__c>();
                if(planProducts!= null && planProducts.size()>0){
                        for(  Related_Account_Plan__c PP : planProducts){
                                Related_Risk_Product__c RP = new Related_Risk_Product__c();
                                RP.Plan_Product__c =PP.id;
                                RP.Risk_Issue__c = riskId;
                                lstRiskProducts.add(RP);
                        }
                }
                if(lstRiskProducts!=null && lstRiskProducts.size()>0){
                       try{
                        insert lstRiskProducts;
                        returnMessage= 'SUCCESS';
                       } catch(Exception e){
                        returnMessage = 'Error: '+e.getMessage();
                        }
                }
                return returnMessage;

        }
    
    @AuraEnabled
    public static Boolean getRiskproductslist(String recid)
    {
        Boolean bl;
        List<Related_Risk_Product__c> lstRiskProducts = new List<Related_Risk_Product__c>(); 
        List<Related_Account_Plan__c> lstPlanProducts = new List<Related_Account_Plan__c>();
        List<Risk_Issue__c> lstRisks=new List<Risk_Issue__c>();
        if(recid!=null && recid!='')
        {
            lstRiskProducts=[select Id,Name,Plan_Product__c from Related_Risk_Product__c where  Risk_Issue__c=:recid ];
            if(lstRiskProducts!=null && lstRiskProducts.size()>0)
            {
                bl=true;
            }else
            {
               
                lstRisks=[select Id,Name,Plan__c from Risk_Issue__c where Id=:recid limit 1];
                if(lstRisks[0].Plan__c !=null)
                {
                       lstPlanProducts= [Select Id,Name,Contract__r.ContractNumber,Opportunity__r.Name,Account_Plan__r.Name,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c,ARR__c,Stage__c,End_Date__c,Status__c,Risk_formula__c from Related_Account_Plan__c where Account_Plan__c = :lstRisks[0].Plan__c ];
                }
                if(lstPlanProducts!=null && lstPlanProducts.size()>0)
                {
                    bl=false;
                }else
                {
                     bl=true;
                }
            }
        }
        return bl;
    }

}