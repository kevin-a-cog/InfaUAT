/*
 Change History
 *******************************************************************************************************************
 Modified By            Date            Jira No.            Description                                         Tag
 *******************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                    	            NA
 Vignesh Divakaran      04-Feb-2022     I2RT-5185           AAE session to be allowed to for Signature Select   T01
 

 */
public with sharing class esAskAnExpertFlowContainerController {
   
    // depricated
    @AuraEnabled
    public static boolean checkAAEMonthlyLimitation(string supportAccId){
        boolean hasLimitReached = true;

        integer thisMonthAAEBookings = [SELECT count() FROM ServiceAppointment where ParentRecordId  = :supportAccId AND appointmenttype = 'Ask_An_Expert' AND CreatedDate = THIS_MONTH];
        if(thisMonthAAEBookings < 2){
            hasLimitReached = false;
        }        
        return hasLimitReached;
    }


    @AuraEnabled
    public static string fetchAAEResources(){
        List<string> lstResourceId = new list<string>();

        for(ServiceResource SR : [SELECT Id, Name, IsActive, ResourceType FROM ServiceResource where name like  'Ask An Expert%' AND isActive = true]){
            lstResourceId.add(SR.Id);  
        }

        return string.join(lstResourceId,',');
    }
    

    @AuraEnabled
    public static boolean hasAccessCheck(string supportAccountId){
        boolean hasAccessonAAE = false; 
        boolean hasReadWriteAccess = false;
        String contactId;
        for(User u : [Select Id, ContactId from User where Id =: UserInfo.getUserId() and ContactId!=null ]){
            contactId = u?.ContactId;
        }

        try {
            for(Account acc : [SELECT Id, Success_Offering__c FROM account where id =: supportAccountId ]){
                if(acc.Success_Offering__c == 'Premium Success' || acc.Success_Offering__c == 'Signature Success' || acc.Success_Offering__c == 'Signature Select'){ //<T01>
                    hasAccessonAAE = true;
                } 
           }

           if(!String.isEmpty(supportAccountId) && !String.isEmpty(contactId)){
             for(AccountContactRelation c : [Select Id,AccountId,ContactId,Contact.AccountId,Contact.Account.Name,Account.Name,
                                            Contact.Name,Contact.Email,Contact.Phone, Roles,Timezone__c, Primary__c,IsActive,Access_Level__c from AccountContactRelation 
                                            where AccountId =: supportAccountId and ContactId =: contactId limit 1]){                                                                                                
                    hasReadWriteAccess = c.Access_Level__c != null && c.Access_Level__c == 'Read/Write' ? true : false;                                                
             }
           }


            
        } catch (Exception e) {

            throw new AuraHandledException(e.getMessage());

        }

        return (hasAccessonAAE && hasReadWriteAccess);
    }

}