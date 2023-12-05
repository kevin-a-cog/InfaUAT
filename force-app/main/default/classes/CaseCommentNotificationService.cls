public with sharing class CaseCommentNotificationService extends NotificationService{
    public CaseCommentNotificationService() {

    }
    
    protected override void getSubscribedTeamMembers(){
        Set<Id> setUserId = new Set<Id>();

        Boolean isInbound = (Boolean)recordNew.get('Inbound__c');
        String caseId = (String)recordNew.get('Case__c');

        if(isInbound){
            List<CaseTeamMember> lstCaseTeamMember = [Select Id, MemberId From CaseTeamMember Where ParentId = :caseId];
            for(CaseTeamMember teamMember : lstCaseTeamMember){
                setUserId.add(teamMember.MemberId);
            }
    
            List<Subscription__c> lstSubscription = [Select Id, Record_Id__c, Subscriber_Id__c, Subscribed__c 
                                                From Subscription__c Where Record_Id__c = :caseId];
    
            for(Subscription__c sub : lstSubscription){
                if(sub.Subscribed__c){
                    setUserId.add(sub.Subscriber_Id__c);
                }else{
                    setUserId.remove(sub.Subscriber_Id__c);
                }
            }
    
            mapNotifTypeToUserIds.put('Salesforce Bell', setUserId);    
        }
    }

    protected override String getTitle(){
        String title = 'Comment on the Case #' + recordNew.get('Case_Number__c');
        return title;
    }
    
    protected override String getTextMsgBody(){
        String body = 'Description: ' + recordNew.get('Comment_to_Search__c');
        return body;
    }

    protected override String getEmailMsgBody(){
        String body = 'Description: ' + recordNew.get('Comment_to_Search__c');
        return body;
    }
}