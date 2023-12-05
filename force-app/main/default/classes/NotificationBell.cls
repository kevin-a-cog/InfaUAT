/*
    @created by       : balajip
    @created on       : 03/02/2020
    @Purpose          : Bell notification
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
Venky K       10/7/2021               T01          To notify case team and account team
*/
public with sharing class NotificationBell extends Notification {
    
    public static Id notificationDesktopId;
    public static Id notificationMobileId;
    public static Id notificationBothId;
    
    static{
        for(CustomNotificationType notifType : [SELECT Id, DeveloperName FROM CustomNotificationType]){
            if('Notification_Service_Desktop'.equals(notifType.DeveloperName)){
                notificationDesktopId = notifType.Id;
            }else if('Notification_Service_Mobile'.equals(notifType.DeveloperName)){
                notificationMobileId = notifType.Id;
            }else if('Notification_Service_Desktop_Mobile'.equals(notifType.DeveloperName)){
                notificationBothId = notifType.Id;
            }
        }
    }

    public NotificationBell() {

    }

    public override void send(){
        for (CriteriaInfo criteriaInfo : setCriteriaInfo){
            Map<String, Set<String>> mapNotifTypeToUsers = new Map<String, Set<String>>();
            List<String> setNotifType = criteriaInfo.criteria.Notification_Type__c.split(';');
            for(String notifType : setNotifType){
                Set<String> setUserId = new Set<String>();
                if(mapNotifTypeToUsers.containsKey(notifType)){
                    setUserId = mapNotifTypeToUsers.get(notifType);
                }else{
                    mapNotifTypeToUsers.put(notifType, setUserId);
                }
                setUserId.addAll(criteriaInfo.setUserId);
            }

            for(String notifType : mapNotifTypeToUsers.keyset()){
                Set<String> setTargetUserId = mapNotifTypeToUsers.get(notifType);
    
                Id notificationTypeId;
                if('Salesforce Bell - Desktop'.equals(notifType)){
                    notificationTypeId = notificationDesktopId;
                }else if('Salesforce Bell - Mobile'.equals(notifType)){
                    notificationTypeId = notificationMobileId;
                }
    
                if(notificationTypeId != null){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setNotificationTypeId(notificationTypeId);
                    notification.setTargetId(recordId);
                    //notification.setSenderId(senderId);
                    notification.setTitle(criteriaInfo.message.title);
                    notification.setBody(criteriaInfo.message.bodyText);
        
                    try {
                        notification.send(setTargetUserId);
                    } catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                    }    
                }
            }
        }
    }
}