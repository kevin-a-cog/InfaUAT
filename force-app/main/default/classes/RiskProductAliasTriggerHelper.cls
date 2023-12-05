/*
* Name			:	RiskProductAliasTriggerHelper
* Author		:	Deva M
* Created Date	: 	21/02/2022
* Description	:	helper class which implements interface process methods for Trigger events on Risk Product Alias Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M		        21/02/2022		N/A				Initial version.			N/A
*/
public with sharing class RiskProductAliasTriggerHelper {
    /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterInsert(List<Risk_Product_Alias__c> newList){
         //AR-2217	
         System.enqueueJob(new CSMCreateMapRiskProductsQueueable(newList,false));
    }

    /*
    Method Name : processBefoprocessAfterUpdatereUpdate
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Risk_Product_Alias__c> newList,Map<Id,Risk_Product_Alias__c> oldMap){
        List<Risk_Product_Alias__c> lstProcessedRisk = new List<Risk_Product_Alias__c>();
        //Filter records on update of 
        for(Risk_Product_Alias__c objNew:newList){
            if(oldMap.containsKey(objNew.Id) && oldMap.get(objNew.Id)!=null){
                Risk_Product_Alias__c oldObj = oldMap.get(objNew.Id); 
                if(oldObj.Plan_Product_Alias__c!= objNew.Plan_Product_Alias__c && objNew.Plan_Product_Alias__c!=null){
                    lstProcessedRisk.add(objNew);
                }
            }
        }
        if(lstProcessedRisk.size()>0){
            //AR-2217	
            System.enqueueJob(new CSMCreateMapRiskProductsQueueable(lstProcessedRisk,true));
        }

    }

     /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
    public void processAfterDelete(List<Risk_Product_Alias__c> oldList){
        //AR-2217	
        System.enqueueJob(new CSMCreateMapRiskProductsQueueable(oldList,true));
    }
    
  
}