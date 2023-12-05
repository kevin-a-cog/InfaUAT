/****************************************************************************************************************************
 *  @Class Name: ProductRequestTriggerHandler
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-12-20 
 *  @Description:This is a handler class for ProductRequest.
 *****************************************************************************************************************************
 ChangeHistory      
 Puneet             31/07/2023 			  SALESRT-15141					  <SALESRT-15141>
 ****************************************************************************************************************************/
 public without sharing class ProductRequestTriggerHandler
 {
    //Add All Before Insert Logic Here
    public static void ProductRequestBeforeInsert(List<Product_Request__c> newProdReqList){
    }
    // <SALESRT-15141> begin here
    public static void beforeUpdate(List<Product_Request__c> newList, Map<Id,Product_Request__c> oldMap){
    }

    public static void afterUpdate(List<Product_Request__c> newList, Map<Id,Product_Request__c> oldMap){
        productRequestOverallStatus(newList, oldMap);
    }

    /**
     * @description : the method is used to update engagement status when all Product Requests are fulfilled or rejected.
     */
    public static void productRequestOverallStatus(List<Product_Request__c> newList, Map<Id,Product_Request__c> oldMap){

        Set<Id> enggId = new Set<Id>();
        for(Product_Request__c pr : newList){

            if(oldMap != null && oldMap.get(pr.Id).Status__c != pr.Status__c){
                enggId.add(pr.Engagement__c);
            }
        }
        Set<Id> enggToUpdate = new Set<Id>();
        for(Engagement__c engg : [SELECT Id,Status__c,(SELECT Id,Name,Status__c FROM Product_Requests__r) FROM Engagement__c WHERE Id IN :enggId]){

            Boolean allCompleted = true;

            if(engg.Product_Requests__r.isEmpty()){
                allCompleted = false;
            }
            for(Product_Request__c pr : engg.Product_Requests__r){
                if(pr.Status__c != 'Fulfilled' && pr.Status__c != 'Rejected'){
                    allCompleted = false;
                    break;
                }
            }

            if(allCompleted){
                enggToUpdate.add(engg.Id);
            }
        }
        
        if(!enggToUpdate.isEmpty()){
            updateEngagements(enggToUpdate);
        }
    }

    /**
     * @description: method used to udpate engagements
     */
    @future
    public static void updateEngagements(Set<Id> enggToUpdate){

        List<Engagement__c> engsToUpdate = new List<Engagement__c>();
        if(!enggToUpdate.isEmpty()){
            for(Id engId : enggToUpdate){
                Engagement__c engg = new Engagement__c();
                engg.Id = engId;
                engg.Status__c = 'Completed';
                engsToUpdate.add(engg);
            }

            if(!engsToUpdate.isEmpty()){
                update engsToUpdate;
            }
        }
    }
    // <SALESRT-15141> end here
 }