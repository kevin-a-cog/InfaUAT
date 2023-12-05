public without sharing class IPUE_AcitivtyUtils {

    public static List<Estimation_Output__c>getEstOutputWithFeeds(String estSummaryId)
    {
        return [SELECT Id,Name,CreatedDate,CreatedBy.Name,Estimation_Schedule__r.Consumption_Description__c,
                (SELECT Id FROM Feeds) FROM Estimation_Output__c WHERE Estimation_Summary__c = :estSummaryId];
    }
}