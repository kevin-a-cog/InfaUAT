/*
Change History
*********************************************************************************************************************
ModifiedBy     Date         Jira No.    Tag     Description                                                 
*********************************************************************************************************************
balajip        07/19/22     I2RT-6662   T01     to call the saveComment method to take care of functionalities on comment submission.
Vignesh D      12/01/22     I2RT-7532   T02     Bulkified scheduled case comment submission
*/

public class SendNotificationAction {

    /**
     * @description Method to send bell icon notification to the user and update the Status to Submitted for Case Comment
     */
    @InvocableMethod(label='Send Notification to User' description='Send notification and submit the case comment' category='Case Collaboration')
    public static void sendNotificationToUser(List<Id> idList) {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName = :Label.Case_Comment_Reminder_Custom_Notification_Dev_Name];
        Set<Id> recordToUpdateIdSet = new Set<Id>();
        Set<Id> setCaseIds = new Set<Id>();                                          
    
        for(Case_Comment__c cc : [SELECT Id, CreatedById, Case__r.CaseNumber, Comment_to_Search__c, Case__c FROM Case_Comment__c WHERE Id IN :idList]) { //<T02>
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Case comment has been added to Case: ' + cc.Case__r.CaseNumber);
            notification.setBody('A new Case comment has been added to case:\n' + cc.Comment_to_Search__c);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(cc.Id);
            try {
                notification.send(new Set<String> { cc.CreatedById });
                recordToUpdateIdSet.add(cc.Id);
                setCaseIds.add(cc.Case__c); //<T02>
            } catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }

        //T01 - calling the saveComment method to take care of functionalities on comment submission.
        if(!recordToUpdateIdSet.isEmpty()) {
            //---------------------------------------<T02>-------------------------------
            /*List<Case_Comment__c> lstCaseComment = [Select Id, Case__c, Status__c, Type__c, Sub_Type__c, Comment__c,
                                                        Comment_Category__c, Inbound__c, Visibility__c, Parent_Comment__c,
                                                        Is_Replied_To__c, Scheduled_Case_Next_Action__c 
                                                        From Case_Comment__c 
                                                        Where Id in :recordToUpdateIdSet];
            
            for(Case_Comment__c caseComment : lstCaseComment){
                caseComment.Status__c = 'Submitted';
                CaseCommentController.saveComment(caseComment, new List<String>());
                CaseController.updateNextAction(caseComment.Case__c, caseComment.Scheduled_Case_Next_Action__c, True);
            }*/
            Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id,
                                                        RCA_Pending_flag__c,
                                                        Is_RCA_Sent__c
                                                        FROM Case 
                                                        WHERE Id IN :setCaseIds]);
    
            List<Case_Comment__c> lstCaseComments = [SELECT Id,
                                                            Case__c,
                                                            Status__c,
                                                            Type__c,
                                                            Sub_Type__c,
                                                            Comment__c,
                                                            Comment_Category__c,
                                                            Inbound__c,
                                                            Visibility__c,
                                                            Parent_Comment__c,
                                                            Is_Replied_To__c,
                                                            Scheduled_Case_Next_Action__c 
                                                            FROM Case_Comment__c 
                                                            WHERE Id IN :recordToUpdateIdSet];
            List<Case> lstCasesToUpdate = new List<Case>();
            Set<Id> setClosedCaseIds = new Set<Id>();
                                                            
            for(Case_Comment__c objCaseComment : lstCaseComments){
                Case objCaseOld = mapCases.get(objCaseComment.Case__c);
                Case objCaseNew = new Case(Id=objCaseComment.Case__c);
                objCaseNew.Next_Action__c = objCaseComment.Scheduled_Case_Next_Action__c;
                objCaseComment.Status__c = 'Submitted';

                if(String.isNotEmpty(objCaseComment.Type__c)){

                    switch on objCaseComment.Type__c {
                        when 'Request More Info' {
                            objCaseNew.Status = 'Research';
                            objCaseComment.Sub_Type__c = 'General Response';
                            objCaseComment.Comment_Category__c = 'General Comments';
                        }
                        when 'Provide Solution' {
                            objCaseNew.Is_RCA_Sent__c = objCaseOld.RCA_Pending_flag__c == 'Yes' ? false : objCaseOld.RCA_Pending_flag__c == 'No' ? true : false;
                            objCaseNew.Status = 'Solution';
                            objCaseComment.Sub_Type__c = 'Solution Response';
                            objCaseComment.Comment_Category__c = 'General Comments';
                        }
                        when 'Send RCA' {
                            objCaseNew.Is_RCA_Sent__c = true;
                            objCaseComment.Sub_Type__c = 'Solution Response';
                            objCaseComment.Comment_Category__c = 'General Comments'; 
                        }
                        when 'Delay Close' {
                            objCaseNew.Is_Delay_Close__c = true;
                            objCaseComment.Comment_Category__c = 'General Comments';
                        }
                        when 'Close Case' {
                            objCaseNew.Status = 'Closed';
                            objCaseComment.Sub_Type__c = 'General Response';
                            objCaseComment.Comment_Category__c = 'General Comments';
                            setClosedCaseIds.add(objCaseNew.Id);
                        }
                    }
                }
                lstCasesToUpdate.add(objCaseNew);
            }
            delete [SELECT Id FROM Case_Comment__c WHERE Case__c IN :setClosedCaseIds and Status__c = 'Scheduled' AND Id NOT IN :lstCaseComments];
            update lstCasesToUpdate;
            update lstCaseComments;
            //---------------------------------------<T02>-------------------------------
        }
    }
    
}