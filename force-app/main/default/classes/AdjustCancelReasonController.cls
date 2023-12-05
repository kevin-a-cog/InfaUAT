/*
Class:          AdjustCancelReasonController
@Author:        Chandana Gowda
@Created Date:  05 Nov 2020
@Description:   COntroller class for Adjust Cancel reason lightning component
*/

/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/
public with sharing class AdjustCancelReasonController {

    //To load the unrenewed records
    @AuraEnabled
    public static List<Unrenewed__c> getUnrenewedRecs(Id quoteId){
        List<Unrenewed__c> lstUnrenewed = [SELECT Id,Name,Is_Parent__c,Subscription__r.SBQQ__Contract__c,Subscription__r.SBQQ__ContractNumber__c,
                                            Subscription__c,Subscription__r.Name,Product__r.Name,Quote__r.Name,Quote__r.Primary_Order__c,Quote__r.Primary_Order__r.Status,
                                            Churn_Status__c,Parent_Product_Name__c  FROM Unrenewed__c 
                                            WHERE Quote__c = :quoteId AND Churn_Status__c = null];
        return lstUnrenewed;
    }

    //To update the cancel reason on the renewed records
    @AuraEnabled
    public static void updateUnrenewedRecs(List<Unrenewed__c> lstUnrenwedRecs){
        try{
            Database.SaveResult[] srList = Database.update(lstUnrenwedRecs,false);
        }catch(Exception e){

        }
    }

    //To update the cancel reason on unrenewed records and stamp the time on previous contract
    @AuraEnabled
    public static void updateUnrenewedRecsAndPush(List<Unrenewed__c> lstUnrenwedRecs){
        try{
            Database.SaveResult[] srList = Database.update(lstUnrenwedRecs,false);
            List<Id> updatedUnrenewRecs = new List<Id>();
            Set<Id> setContractIds = new Set<Id>();
            List<Contract> lstContractUpdate = new List<Contract>();
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    updatedUnrenewRecs.add(sr.getId());
                }
            }
            List<Unrenewed__c> lstUnrenwedRecsUpdated = [SELECT  Id,Subscription__c,Subscription__r.SBQQ__Contract__c,Churn_Status__c FROM Unrenewed__c WHERE Id IN:updatedUnrenewRecs];
            for(Unrenewed__c unrenew:lstUnrenwedRecsUpdated){
                setContractIds.add(unrenew.Subscription__r.SBQQ__Contract__c);
            }
            for(Id contractId:setContractIds){
                Contract contractRec = new Contract(Id = contractId,Contract_Status_Trigger_Time__c = System.Now());
                lstContractUpdate.add(contractRec);
            }
            Database.SaveResult[] subList = Database.update(lstContractUpdate,false);
        }catch(Exception e){

        }
    }    
}