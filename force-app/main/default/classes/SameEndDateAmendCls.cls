/*Class Name - SameEndDateAmendCls
  Test Class - CreateAmendQuoteTest
  Description - Created of Project Elevate SALESRT-15880 & SALESRT-15482
*/
/*CHANGE LOG
*/
public with sharing class SameEndDateAmendCls {
    @AuraEnabled
    public static List<Contract> fetchContractsDetails(String oppAcctId){
        try {
            List<Contract> contracts = [SELECT Id, ContractNumber, StartDate, Annual_Recurring_Revenue1__c,EndDate, Status_Custom__c, Name,Renewal_Type__c,
                                        SBQQ__Order__r.OrderNumber,	SBQQ__Order__c	,SBQQ__Quote__r.Name, SBQQ__Quote__c 
                                        FROM Contract WHERE EndDate > TODAY AND AccountId = :oppAcctId AND Status_Custom__c = 'Active' order by EndDate DESC];
            return contracts;
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static List<Contract> searchForContract(String oppAcctId, String searchStr){
        try {
            searchStr = '%' + String.escapeSingleQuotes(searchStr.trim()) + '%';
            String statusVal = 'Active';
            String query = 'SELECT Id, ContractNumber, StartDate, Annual_Recurring_Revenue1__c,EndDate, Status_Custom__c, Name,Renewal_Type__c,'+
                            'SBQQ__Order__r.OrderNumber, SBQQ__Order__c	,SBQQ__Quote__r.Name,	SBQQ__Quote__c FROM Contract '+
                            'WHERE EndDate > TODAY AND AccountId = :oppAcctId AND Status_Custom__c = :statusVal AND (contractnumber LIKE :searchStr OR Name LIKE :searchStr)';
            return Database.query(query);
            
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }
}