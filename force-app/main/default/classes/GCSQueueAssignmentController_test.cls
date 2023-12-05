@isTest
public class GCSQueueAssignmentController_test{
    static testmethod void testAllMethods(){
        GCSQueueAssignmentController.getGCSTeam();
        Custom_Notification_Filter__c customNotif = new Custom_Notification_Filter__c();
        customNotif.Filter_Priority__c = 'P1;P2';
        customNotif.GCS_Team__c = 'APAC-APS';
        customNotif.Filter_Products__c = 'Accelerator';
        customNotif.Queue_Membership__c = 'GCS L0 Queue';
        insert customNotif;
        GCSQueueAssignmentController.editSelectedFilter(customNotif.id);
        GCSQueueAssignmentController.cloneSelectedFilter(customNotif.id);
        GCSQueueAssignmentController.saveFilterCriteria(customNotif);
        GCSQueueAssignmentController.composeFilterText(customNotif);
        GCSQueueAssignmentController.deleteSelectedFilter(customNotif.id);
        GCSQueueAssignmentController.retrieveUserDetails(userinfo.getuserId(), null);
    }
}