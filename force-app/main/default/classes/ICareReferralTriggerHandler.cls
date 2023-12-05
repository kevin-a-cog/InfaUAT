/*
    @created by       : balajip
    @created on       : 01/19/2021
    @Purpose          : ICare Referral trigger handler class.
    @Testclass        : 
    @JIRA : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description   Jira No.       Tag
 ****************************************************************************************************
 */

public class ICareReferralTriggerHandler {
    public static final String QUEUE_ICARE = 'iCare';
    public static final Group iCareQueue;

    static{
        iCareQueue = [Select Id From Group Where DeveloperName = :QUEUE_ICARE And Type='Queue'];
    }

    public static void setDefaultValues(List<iCare_Referral__c> newList) {
        Set<Id> setCaseId = new Set<Id>();
        Set<Id> setSupportAccountId = new Set<Id>();
        for (iCare_Referral__c referral : newList) {
            System.debug('Subject = ' + referral.Subject__c);
            System.debug('Case = ' + referral.Case__c);
            System.debug('Support Account = ' + referral.Support_Account__c);

            if(referral.Case__c != null){
                setCaseId.add(referral.Case__c);
            }else if(referral.Support_Account__c != null){
                setSupportAccountId.add(referral.Support_Account__c);
            }

            //assign to icare queue
            if(referral.OwnerId == UserInfo.getUserId()){
                referral.OwnerId = iCareQueue.Id;
            }
        }

        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, Support_Account__c, AccountId From Case Where Id in :setCaseId]);
        Map<Id, Account> mapAccountIdToSupportAccount = new Map<Id, Account>([Select Id, ParentId From Account Where Id in :setSupportAccountId]);

        for (iCare_Referral__c referral : newList) {
            System.debug('Case = ' + referral.Case__c);
            if(referral.Case__c != null){
                Case cse = mapCaseIdToCase.get(referral.Case__c);
                referral.Support_Account__c = cse.Support_Account__c;
                referral.Customer_Account__c = cse.AccountId;
            }else if(referral.Support_Account__c != null){
                Account acc = mapAccountIdToSupportAccount.get(referral.Support_Account__c);
                referral.Customer_Account__c = acc.ParentId;
            }
        }
    }
}