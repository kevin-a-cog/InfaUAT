/*
    @created by       : cgowda
    @created on       : 08/08/22
    @Purpose          : contains the methods that defines the domain logic pertaining to Notifications
    @Testclass        : StripeNotificationTriggerHandlerTest
    @JIRA             : PAYGIT-2
    
Change History
****************************************************************************************************************
ModifiedBy          Date            Jira No.            Description                                        Tag
****************************************************************************************************************
*/
public with sharing class NotificationPlatform extends Notification{
    private static globalApexManager GAM = new globalApexManager();

    /**
    * Method Name : send
    * @param lstNew: N/A
    * @return return : void
    * @throws exception : NA
    * @description : Update the Notification records, by mapping the fields from Notification Subscription records, based on the event type
    */
    public override void send(){
        String emailTemplateName;
        SObject objUpdate = recordId.getSObjectType().newSObject(recordId);
        for (CriteriaInfo criteriaInfo : setCriteriaInfo){
            objUpdate.put('Message_Type__c',criteriaInfo.criteria.Notification_Type__c.split(';')[0]);
            objUpdate.put('Expiration_Date__c',getExpirationDate(Integer.valueOf(criteriaInfo.criteria.Platform_Notification_Expiration__c)));
            emailTemplateName = criteriaInfo.criteria.Template_Name__c;
            for(Notification_User__c notifUser:criteriaInfo.criteria.Notification_Users__r){
                objUpdate.put('Platform_Recipient_Type__c',notifUser.User_Type__c);
                objUpdate.put('Platform_Recipient_Role__c',notifUser.Platform_Recipient_Role__c);
                break;
            }
        }

        try{
            Database.SaveResult saveRes = Database.update(objUpdate);
            if(!saveRes.isSuccess()){
                GAM.CreateExceptionRecords('NotificationPlatform - Updating Notification Record: ', saveRes.getErrors()[0].getMessage(), recordId);
            }else{
                //Once the fields are successfully mapped from Notification Framework, populate the payload from the emailTemplate
                EmailTemplate emailTemplateRec = [Select Id, Subject, Body, HtmlValue From EmailTemplate Where DeveloperName =:emailTemplateName LIMIT 1];
                Notification.Message message = new Notification.Message();
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateRec.Id, null, recordId);
                objUpdate.put('Payload__c',mail.getPlainTextBody());

                saveRes = Database.update(objUpdate);

                if(!saveRes.isSuccess()){
                    GAM.CreateExceptionRecords('NotificationPlatform - Updating Payload on Notification Record: ', saveRes.getErrors()[0].getMessage(), recordId);
                }
            }
        }catch(Exception e){
            GAM.CreateExceptionRecords('NotificationPlatform', e.getMessage(),'Exception in send() : Unable to map Message Type,Expiration date');
        }
    }

    /**
    * Method Name : getExpirationDate
    * @param lstNew: expirationDay - expiry date in Number
    * @return return : String - DateTime in String format
    * @throws exception : NA
    * @description : get the Expiry date in a format as required by the platform
    */
    private String getExpirationDate(Integer expirationDay){

        DateTime expirationDate = datetime.now().addDays(expirationDay);		

        String dateValue = String.valueOf(expirationDate.dateGMT()).split(' ')[0];
        String timeValue = String.valueOf(expirationDate.timeGMT()).remove('Z');

        String dateTimeValue = dateValue+'T'+timeValue+'+00:00';
        return dateTimeValue;
    }
}