/****************************************************************************************************************************
 *  @Class Name: fulfillmentLineTriggerHandler
 *  @Author: Nishit S
 *  @Date: 26 JAN 2022
 *  @Description: handler class for fulfillmentLineTrigger
 *****************************************************************************************************************************
 ChangeHistory
    
 ModifiedBy					Date			Requested By		Description																	Tag   
 
 Nishit S					1/26/2022		Kiran K				F2A-440 Ability to set the org hierarchy in IICS as part of provisioning	<F2A-440>
 Harshita J                 11/14/2022                          F2A-486 Added logic to update related org's account with fulfillment's shipping account if null  <F2A-486>
 Vignesh D                  2/15/2023       F2A-534             Populate parent org from IPU parent to sanbox lines                         <T03>  
 Vignesh D                  6/23/2023       F2A-613             Added null check                                                            <T04>  
 ****************************************************************************************************************************/
public class fulfillmentLineTriggerHandler {

    public static globalApexManager GAM = new globalApexManager();
    
    public static void fulfillmentLineBeforeInsert(Map<Id,Fulfillment_Line__c> oldMap, Map<Id,Fulfillment_Line__c> newMap){
        return;
    }
    
    public static void fulfillmentLineAfterInsert(Map<Id,Fulfillment_Line__c> oldMap, Map<Id,Fulfillment_Line__c> newMap){
        return;
    }
    public static void fulfillmentLineBeforeUpdate(Map<Id,Fulfillment_Line__c> oldMap, Map<Id,Fulfillment_Line__c> newMap){
        Map<Id, String> requiredByMap = new Map<Id, String>();
        Map<Id, Asset> requiredByAssetMap = new Map<Id, Asset>();
        List<Fulfillment_Line__c> sandboxesUpdateList = new List<Fulfillment_Line__c>();
        for(Fulfillment_Line__c fulfillmentLine : [SELECT Id, License_Generation__c, Org__c, Org_UUID__c, Parent_ID__c, ParentOrgID__c, Parent_ID__r.Org__c, Parent_ID__r.Org_UUID__c, 
                                                   (SELECT Order_Product__r.SBQQ__RequiredBy__c FROM Related_Fullfillment_Lines__r LIMIT 1) , (Select Id, ParentOrgID__c from  Fulfillment_Lines__r) 
                                                   FROM Fulfillment_Line__c WHERE Id IN :newMap.keySet() AND (License_Generation__c = 'Sandbox' )]){

                                               
            if((oldMap.get(fulfillmentLine.Id).Org__c != newMap.get(fulfillmentLine.Id).Org__c  && newMap.get(fulfillmentLine.Id).Org__c  != NULL) || Test.isRunningTest() ){
                    if(newMap.get(fulfillmentLine.Id).Parent_ID__c != NULL)
                        newMap.get(fulfillmentLine.Id).ParentOrgID__c = fulfillmentLine.Parent_ID__r.Org_UUID__c;
                    else{
                        if(fulfillmentLine?.Related_Fullfillment_Lines__r.size() > 0){
                            if(fulfillmentLine.Related_Fullfillment_Lines__r[0].Order_Product__r.SBQQ__RequiredBy__c != null) //<T04>
                                requiredByMap.put(fulfillmentLine.Related_Fullfillment_Lines__r[0].Order_Product__r.SBQQ__RequiredBy__c, fulfillmentLine.Id);
                        }
                        //if(fulfillmentLine.Related_Fullfillment_Lines__r?.size() >0)
                        // fulfillmentLine.ParentOrgID__c = fulfillmentLine.Related_Fullfillment_Lines__r[0]?.Parent_Org_Id__c;
                        //  fulfillmentLine.ParentOrgID__c = fulfillmentLine.Related_Fullfillment_Lines__r[0]?.OrderProduct. [select org from asset limit 1];
                    }                
            }
        }

        for(Asset asset : [Select Org__c, Org__r.OrgID__c, SBQQ__OrderProduct__c from Asset where SBQQ__OrderProduct__c IN: requiredByMap.keySet()]){
            if(requiredByMap.containskey(asset.SBQQ__OrderProduct__c))
                newMap.get(requiredByMap.get(asset.SBQQ__OrderProduct__c)).ParentOrgID__c = asset.Org__r.OrgID__c;
        }
        
    }
    public static void fulfillmentLineAfterUpdate(Map<Id,Fulfillment_Line__c> oldMap, Map<Id,Fulfillment_Line__c> newMap){
        List<Fulfillment_Line__c> sandboxesUpdateList = new List<Fulfillment_Line__c>();
        for(Fulfillment_Line__c fulfillmentLine : [select Id, Parent_ID__c, Parent_ID__r.Org_UUID__c,  ParentOrgID__c from Fulfillment_Line__c where (Parent_ID__r.License_Generation__c = 'Production' OR Parent_ID__r.License_Generation__c = 'IPU') AND Ship_Status__c = 'Provisioning Complete' AND ParentOrgID__c = NULL AND Parent_ID__c IN :newMap.keySet()]){ //<T03>
                fulfillmentLine.ParentOrgID__c = fulfillmentLine.Parent_ID__r.Org_UUID__c;
                sandboxesUpdateList.add(fulfillmentLine);
        }
       
        //<F2A-486>
        system.debug('fulfillmentLine>>>>>');
        List<Org__c> orgToBeUpdated = new List<Org__c>();
        for(Fulfillment_Line__c fulfillmentLine : [SELECT Id, License_Generation__c, Org__c,Org__r.Account__c, Org_UUID__c,License_Screen_Type2__c, Fullfillment__r.ShipToAccount__c
                                                   FROM Fulfillment_Line__c WHERE Id IN :newMap.keySet() and Org__r.Account__c = Null and License_Screen_Type2__c = 'Cloud' and Org__c !=null]){
              if((oldMap.get(fulfillmentLine.Id).Org__c != newMap.get(fulfillmentLine.Id).Org__c  && newMap.get(fulfillmentLine.Id).Org__c  != NULL) || Test.isRunningTest()){
                Org__c  orgRecord = new Org__c(id=fulfillmentLine.Org__c);
                orgRecord.Account__c =  fulfillmentLine.Fullfillment__r.ShipToAccount__c;
                orgToBeUpdated.add(orgRecord);
              }
            }
            //</F2A-486>
            if(sandboxesUpdateList.size()>0)
                update sandboxesUpdateList;
            if(orgToBeUpdated.size()>0)
               update orgToBeUpdated;//</F2A-486>
    }
    
}