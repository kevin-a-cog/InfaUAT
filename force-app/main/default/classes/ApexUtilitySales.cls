/*
 * Name         :   ApexUtilitySales
 * Created Date :   10/28/2022
 * Description  :   This is an Utility Class for sales.

 Change History
 *************************************************************************************************************
 Modified By            Date            Jira No.        Description                                     Tag
 *************************************************************************************************************
 Puneet          10/28/2022             SALESRT-14408       Account Predective Bucket Score         <SALESRT-14408>
 */
public class ApexUtilitySales {
    
    public static globalApexManager GAM = new globalApexManager();

    /* <SALESRT-14408>
    * Method Name : calculateAccountPredectiveBucket
    * Description : this method is used to calculate ls predective bucket on account
    * Parameters  : accountIds - Set of account ids
    * Return Type : void
    */
    @future
    public static void calculateAccountPredectiveBucket(Set<Id> accountIds){

        String bucketLabel = System.Label.LSPredectiveBucket;
        String[] buckets = bucketLabel.split(',');

        Map<String,String> bucketingMap = new Map<String,String>();
        for(String bucket : buckets){
            if(bucket.indexOf('=') > -1){
                String[] individualBuckets = bucket.split('=');
                if(individualBuckets.size() > 1 && !bucketingMap.containsKey(individualBuckets[0])){
                    bucketingMap.put(individualBuckets[0],individualBuckets[1]);
                }
            }
        }

        Map<Id,Integer> accountToMaxScoreMap = new Map<Id,Integer>();

        for(AggregateResult ar : [SELECT max(LS_Person_Predictive_Score__c) maxval,Account__c FROM Lead WHERE Account__c IN :accountIds group by Account__c]){
            Id accountId = (Id) ar.get('Account__c');
            Integer maxScore = Integer.valueOf((Decimal) ar.get('maxval'));

            if(accountId != null && !accountToMaxScoreMap.containsKey(accountId)){
                accountToMaxScoreMap.put(accountId, maxScore);
            }
        }

        for(AggregateResult ar : [SELECT max(LS_Person_Predictive_Score__c) maxval,AccountId FROM Contact WHERE AccountId IN :accountIds group by AccountId]){
            Id accountId = (Id) ar.get('AccountId');
            Integer maxScore = Integer.valueOf((Decimal) ar.get('maxval'));

            if(accountId != null && accountToMaxScoreMap.containsKey(accountId)){
                if(accountToMaxScoreMap.get(accountId) != null && maxScore != null){
                    Integer maxVal = Math.max(accountToMaxScoreMap.get(accountId), maxScore);
                    accountToMaxScoreMap.put(accountId, maxVal);
                }
                else if(accountToMaxScoreMap.get(accountId) == null && maxScore != null){
                    accountToMaxScoreMap.put(accountId, maxScore);
                }
                else if(accountToMaxScoreMap.get(accountId) == null && maxScore == null){
                    accountToMaxScoreMap.put(accountId, null);
                }
            }
            else if(accountId != null){
                if(maxScore != null){
                    accountToMaxScoreMap.put(accountId, maxScore);
                }
                else{
                    accountToMaxScoreMap.put(accountId, null);
                }
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        
        for(Id key : accountToMaxScoreMap.keySet()){
            
            Integer maxVal = accountToMaxScoreMap.get(key);
            String finalBucket = '';

            if(maxVal != null){
                for(String bucketKey : bucketingMap.keySet()){

                    String[] fromToVal = bucketKey.split('-');
                    if(fromToVal.size() > 1){
                        Integer fromVal = Integer.valueOf(fromToVal[0]);
                        Integer toVal = Integer.valueOf(fromToVal[1]);
                        if(maxVal >= fromVal && maxVal <= toVal){
                            finalBucket = bucketingMap.get(bucketKey);
                        }
                    }
                }
            }

            Account acc = new Account();
            acc.Id = key;
            acc.LS_Account_Predictive_Bucket__c = finalBucket;
            accountsToUpdate.add(acc);
        }

        if(!accountsToUpdate.isEmpty()){
            try{
                update accountsToUpdate;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ApexUtilitySales.calculateAccountPredectiveBucket', 'Error while updating ls predective bucket: ', e.getMessage());
            }
        }
    }
}