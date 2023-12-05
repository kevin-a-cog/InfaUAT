/*
@created by       : Pavithra V
@created on       : 21/01/2021
@Purpose          : Controller Class to Create Solution Type records on a click on a button

Change History
****************************************************************************************************************************
ModifiedBy             | Date         |   Requested By   |  Description                         | Jira No. |  Tag
Rohit Niranjanamath    | 20-July-2023 |   Aug Build '23  |  Solution type update                | PSA-3080 |  T1
****************************************************************************************************************************
*/
public  without sharing class psa_CreateSolutionTypeController {
    
    /**
* Method called on Click of a Custom button on the Project record that will create solution types.
* @param Id ProjectId
* @return String : Success/Error.
* @throws exception - NA
*/
    @AuraEnabled
    public static void createSolutionTypeRecs(Id opportunityId){
        
        System.debug('opportunityId' + opportunityId);
        
        String projId;
        Id relOppId;        
        Opportunity oppRec = [SELECT id,Name,Related_Opportunity__c FROM Opportunity where ID =:opportunityId];
        List<pse__Proj__c> projList = [SELECT id,pse__Opportunity__c FROM pse__Proj__c WHERE pse__Opportunity__c = :opportunityId ORDER BY CREATEDDATE ASC LIMIT 1];
        
        if(!projList.isEmpty()){
            projId = projList[0].Id;
        }
        
        if(!String.isBlank(oppRec.Related_Opportunity__c)){
            relOppId = oppRec.Related_Opportunity__c;  
        }else{
            relOppId = oppRec.Id;
        }
        // Id oppId = oppRec.Id;
        // Id relOppId = oppRec.Related_Opportunity__c;
        System.debug('***STC-relOppId*** '+relOppId);
        
        Set<String> comboSet = new Set<String>();
        List<psa_pm_Solution_Type__c> solTypeRecsToupsert = new List<psa_pm_Solution_Type__c>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        
        oppLineItemList=[SELECT Id,Product2Id,Product2.Name,Product2.Family, Product2.Product_Family__c, 
                         Product2.Forecast_Product__c,Product2.Pricing_Business_Model__c,Product2.Processing_Engine__c,
                         Product2.Delivery_Method__c FROM OpportunityLineItem WHERE OpportunityId = :relOppId
                         AND (NOT Product2.Offering_Type__c like '%Support%')];
        
        
        System.debug('***STC-oppLineItemList*** '+oppLineItemList);
        
        if(oppLineItemList.isEmpty()){
            AuraHandledException e = new AuraHandledException('Error: No Opportunity Products exist');
            e.setMessage('Error: No Opportunity Products exist');
            system.debug(e);
            throw e;
        }
        
        if(!oppLineItemList.isEmpty()){
            for(psa_pm_Solution_Type__c solnRec:[Select Id,psa_pm_Project__c,PSA_PM_Forecast_Family__c,PSA_PM_Product_Family__c,PSA_PM_Forecast_Product__c, PSA_PM_Pricing_Business_Model__c,
                                                 PSA_PM_Processing_Engine__c, PSA_PM_Delivery_Method__c, Is_Automated__c
                                                 from psa_pm_Solution_Type__c where Opportunity__c=:opportunityId])
            {
                string combokey = solnRec.PSA_PM_Forecast_Family__c+solnRec.PSA_PM_Product_Family__c+solnRec.PSA_PM_Forecast_Product__c+solnRec.PSA_PM_Pricing_Business_Model__c+solnRec.PSA_PM_Processing_Engine__c+solnRec.PSA_PM_Delivery_Method__c;
                System.debug('***STC-combokey***'+combokey);
                if(!comboSet.contains(combokey)){
                    comboSet.add(combokey);
                    if(String.isBlank(solnRec.psa_pm_Project__c) && !String.isBlank(projId)){
                        solnRec.psa_pm_Project__c = projId;
                        solTypeRecsToupsert.add(solnRec);
                    }
                }
            }
            
            for(OpportunityLineItem oppLineItem : oppLineItemList){
                string combokey = oppLineItem.Product2.Family+oppLineItem.Product2.Product_Family__c+oppLineItem.Product2.Forecast_Product__c+oppLineItem.Product2.Pricing_Business_Model__c+oppLineItem.Product2.Processing_Engine__c+oppLineItem.Product2.Delivery_Method__c;
                System.debug('***STC-combokey***'+combokey);
                if(!comboSet.contains(combokey)){
                    comboSet.add(combokey);
                    psa_pm_Solution_Type__c solTypeRec = new psa_pm_Solution_Type__c();
                    if(projId <> null){
                        solTypeRec.psa_pm_Project__c = projId;
                    }               
                    solTypeRec.Opportunity__c = opportunityId;
                    solTypeRec.PSA_PM_Forecast_Family__c = oppLineItem.Product2.Family;
                    solTypeRec.PSA_PM_Product_Family__c = oppLineItem.Product2.Product_Family__c;
                    solTypeRec.PSA_PM_Forecast_Product__c = oppLineItem.Product2.Forecast_Product__c;
                    solTypeRec.PSA_PM_Pricing_Business_Model__c = oppLineItem.Product2.Pricing_Business_Model__c;
                    solTypeRec.PSA_PM_Processing_Engine__c = oppLineItem.Product2.Processing_Engine__c;
                    solTypeRec.PSA_PM_Delivery_Method__c = oppLineItem.Product2.Delivery_Method__c;
                    solTypeRec.Is_Automated__c = true;
                    //<T1> - Start
                    solTypeRec.PSA_PM_Product_Split__c = 0;
                    //<T1> - End
                    solTypeRecsToupsert.add(solTypeRec);
                }
            }  
        }
        
        if(!solTypeRecsToupsert.isEmpty()){
            try{
                if(solTypeRecsToupsert.size()>0){
                    upsert solTypeRecsToupsert;
                }
            }catch(exception e){
                throw new AuraHandledException('Error Saving Records.  Details:' + e.getMessage());                   
            }               
        }               
    }
    
    
}