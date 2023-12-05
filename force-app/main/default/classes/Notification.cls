public abstract class Notification{
    public NotificationService.NotificationEvent event;
    public Id recordId;              
    public SObject recordData;

    public Set<CriteriaInfo> setCriteriaInfo = new Set<CriteriaInfo>();

    public abstract void send();

    public class Message{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String bodyText;
        @AuraEnabled
        public String bodyHTML;
    }

    public class CriteriaInfo{
        public Notification_Criteria__c criteria;
        public Message message;
        public Set<String> setUserId;
    }
}