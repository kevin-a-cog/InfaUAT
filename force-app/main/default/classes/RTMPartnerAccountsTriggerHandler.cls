/*
Class:          RTMPartnerAccountsTriggerHandler
@Author:        Anusha Akella
@Created Date:  04/27/2022
@Description:   Class to set the sequence for newly created Partners
*/
public with sharing class RTMPartnerAccountsTriggerHandler {
    /* this method called by RTMPartnerAccounttrigger
    * @Method Name- handleBeforeInsert
    * @param triggernew - list of new RTM_Partner_Account__c
    * @param parameter- triggernew
    * @return return- n/a
    */ 
    public static void handleBeforeInsert(List<RTM_Partner_Account__c> lstTriggerNew){
        setTierSeq(lstTriggerNew);
    }
    /* this method called by RTMPartnerAccounttrigger
    * @Method Name- handleAfterDelete
    * @param triggerOldMap - Map of old RTM_Partner_Account__c
    * @param parameter- triggerOldMap
    * @return return- n/a
    */ 
    public static void handleAfterDelete(map<id,RTM_Partner_Account__c> triggerOldMap){
        reOrderTierSeq(triggerOldMap); 
        calculateAndUpdateHoldOnQuote(null, triggerOldMap);
    }
    
    /* this method called by RTMPartnerAccounttrigger
    * @Method Name- handleAfterInsert
    * @param triggerOldMap - list of new RTM_Partner_Account__c
    * @param parameter- lstTriggerNew
    * @return return- n/a
    */ 
    public static void handleAfterInsert(list<RTM_Partner_Account__c> lstTriggerNew){
        callNotificationService(lstTriggerNew, null);
        calculateAndUpdateHoldOnQuote(lstTriggerNew, null);
    }
    
    /* this method called by RTMPartnerAccounttrigger
    * @Method Name- handleBeforeDelete
    * @param triggerOldMap - list of new RTM_Partner_Account__c
    * @param parameter- oldMap
    * @return return- n/a
    */ 
    public static void handleBeforeDelete(Map<Id,RTM_Partner_Account__c> oldMap){
    }
    
    /* this method called by before Insert trigger
    * @Method Name- setTierSeq
    * @param parameter- List<RTM_Partner_Account__c>
    * @return return- n/a
    */ 
    public static void setTierSeq(List<RTM_Partner_Account__c> lstNewRecords){
        Map<Id, String> mapQuoteToTier = new Map<Id, String>();
        Map<Id, List<RTM_Partner_Account__c>> mapQuoteToPartnerAccs = getMapQuoteToPartnerAccount(lstNewRecords);
        if(!mapQuoteToPartnerAccs.isEmpty()){
            for(RTM_Partner_Account__c partnerAccount : [Select Id,Tier__c, Quote__c from RTM_Partner_Account__c where Quote__c in:mapQuoteToPartnerAccs.keySet() ORDER BY Tier__c Asc NULLS FIRST]){
                mapQuoteToTier.put(partnerAccount.Quote__c, partnerAccount.Tier__c);
            }
        }
        for(Id quoteId : mapQuoteToPartnerAccs.keySet()){
            Integer tier = mapQuoteToTier.get(quoteId) != null ? Integer.valueOf(mapQuoteToTier.get(quoteId)) +1 : 2; 
            for(RTM_Partner_Account__c partnerAcc : mapQuoteToPartnerAccs.get(quoteId)){
                partnerAcc.Tier__c = String.valueOf(tier);
                tier++;
            }
        }
    }

    /* this method called by after delete trigger
    * @Method Name- reOrderTierSeq
    * @param parameter- Map<Id,RTM_Partner_Account__c>
    * @return return- n/a
    */ 

    public static void reOrderTierSeq(Map<Id,RTM_Partner_Account__c> mapOldRecords){
        globalApexManager GAM = new globalApexManager();
        Map<Id, String> mapQuoteToTier = new Map<Id, String>();
        Map<Id, List<RTM_Partner_Account__c>> mapQuoteToPartnerAccs = new Map<Id, List<RTM_Partner_Account__c>>();
        for(RTM_Partner_Account__c partnerAccount : mapOldRecords.values()){
            if(partnerAccount.Tier__c != null){
                mapQuoteToTier.put(partnerAccount.Quote__c,partnerAccount.Tier__c);
            }
        }
        if(!mapQuoteToTier.isEmpty()){
            for(RTM_Partner_Account__c partnerAcc : [Select Id,Tier__c,Quote__c from RTM_Partner_Account__c where Quote__c in:mapQuoteToTier.keySet() ORDER BY Tier__c ASC NULLS LAST]){
                if(!mapQuoteToPartnerAccs.containsKey(partnerAcc.Quote__c)){
                    mapQuoteToPartnerAccs.put(partnerAcc.Quote__c, new List<RTM_Partner_Account__c>());
                }
                mapQuoteToPartnerAccs.get(partnerAcc.Quote__c).add(partnerAcc);
            }
        }
        List<RTM_Partner_Account__c> lstPartnerAccsToUpdate = new List<RTM_Partner_Account__c>();
        for(Id quoteId : mapQuoteToPartnerAccs.keySet()){
            Integer removedTier = Integer.valueOf(mapQuoteToTier.get(quoteId));
            Integer endTier = removedTier;
            for(RTM_Partner_Account__c partnerAcc : mapQuoteToPartnerAccs.get(quoteId)){
                if(partnerAcc.Tier__c != null && removedTier < Integer.valueOf(partnerAcc.Tier__c)){
                    partnerAcc.Tier__c = String.valueOf(Integer.valueOf(partnerAcc.Tier__c)-1);
                    lstPartnerAccsToUpdate.add(partnerAcc);
                    endTier = endTier+1;
                }
                if(partnerAcc.Tier__c == null){
                    partnerAcc.Tier__c = String.valueOf(endTier);
                    endTier = endTier+1;
                    lstPartnerAccsToUpdate.add(partnerAcc);
                }
            }
        }
        try{
            if(!lstPartnerAccsToUpdate.isEmpty()){
                update lstPartnerAccsToUpdate;
            }
        } catch(Exception e){
            GAM.CreateLogs('RTMPartnerAccountsTriggerHandler.reOrderTierSeq', lstPartnerAccsToUpdate, 'lstPartnerAccsToUpdate');
        }
    }

    /* this method returns Map<Id, List<RTM_Partner_Account__c>>
    * @Method Name- getMapQuoteToPartnerAccount
    * @param parameter- List<RTM_Partner_Account__c>
    * @return return- Map<Id, List<RTM_Partner_Account__c>>
    * @throws exception-n/a
    */ 

    private static Map<Id, List<RTM_Partner_Account__c>> getMapQuoteToPartnerAccount(List<RTM_Partner_Account__c> lstPartnerAccounts){
        Map<Id, List<RTM_Partner_Account__c>> mapQuoteToPartnerAccs = new Map<Id, List<RTM_Partner_Account__c>>();
        for(RTM_Partner_Account__c partnerAccount : lstPartnerAccounts){
            if((partnerAccount.Tier__c == null && Trigger.isInsert) || (Trigger.isDelete)){
                //prepare of map of quote to List<partner account> records.
                if(!mapQuoteToPartnerAccs.containsKey(partnerAccount.Quote__c)){
                    mapQuoteToPartnerAccs.put(partnerAccount.Quote__c,new List<RTM_Partner_Account__c>());
                }
                mapQuoteToPartnerAccs.get(partnerAccount.Quote__c).add(partnerAccount);
            }
        }
        return mapQuoteToPartnerAccs;
    }
    
    
    /* SALESRT-14026
    * this method returns NA
    * @Method Name- callNotificationService
    * @param parameter- List<RTM_Partner_Account__c> and oldMap
    * @throws exception-n/a
    */ 
    private static void callNotificationService(list<RTM_Partner_Account__c> lstTriggerNew, map<Id, RTM_Partner_Account__c> oldMap) {
        NotificationService.notify(lstTriggerNew, oldMap);
    }

    /**
     * @description : method to calculate and update hold on account
     * 
     * @param newList : list of rtm partner accounts
     * @param oldMap : old map
     */
    public static void calculateAndUpdateHoldOnQuote(list<RTM_Partner_Account__c> newList, map<Id, RTM_Partner_Account__c> oldMap){

        Set<Id> quoteSet = new Set<Id>();
        String legalHoldString = System.Label.LegalAccountHoldValues;
        List<String> holdValues = legalHoldString.split(',');
        List<SBQQ__Quote__c> quoteListToUpdate = new List<SBQQ__Quote__c>();
        
        String holdValuesAsString = '(\'' + String.join(holdValues, '\', \'') + '\')';

        if(Trigger.isInsert){

            for(RTM_Partner_Account__c rtmPartner : newList){

                quoteSet.add(rtmPartner.Quote__c);
            }
        }
        else if(Trigger.isDelete){
            
            for(RTM_Partner_Account__c rtmPartner : oldMap.values()){

                quoteSet.add(rtmPartner.Quote__c);
            }
        }

        if(!quoteSet.isEmpty()){

            Set<Id> quotesWithHold = new Set<Id>();

            String query = 'SELECT Id,Partner_Account__c,Quote__c,Partner_Account__r.Account_Hold_Reasons__c '+
            'FROM RTM_Partner_Account__c ' +
            'WHERE Quote__c IN :quoteSet AND '+
            'Partner_Account__r.Account_Hold_Reasons__c INCLUDES ' + holdValuesAsString;

            for(RTM_Partner_Account__c rtmPartner : Database.query(query)){

                quotesWithHold.add(rtmPartner.Quote__c);
            }

            if(!quoteSet.isEmpty()){

                for(Id quoteId : quoteSet){
                    
                    if(quotesWithHold.contains(quoteId)){
                        
                        SBQQ__Quote__c quot = new SBQQ__Quote__c();
                        quot.Id = quoteId;
                        quot.Legal_Account_Hold__c = true;
                        quoteListToUpdate.add(quot);
                    }
                    else{
                        SBQQ__Quote__c quot = new SBQQ__Quote__c();
                        quot.Id = quoteId;
                        quot.Legal_Account_Hold__c = false;
                        quoteListToUpdate.add(quot);
                    }
                }
            }

            if(!quoteListToUpdate.isEmpty()){
                update quoteListToUpdate;
            }
        }
    }
}