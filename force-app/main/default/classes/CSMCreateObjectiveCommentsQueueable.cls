/*
 * Name      :  CSMCreateObjectiveCommentsQueueable
 * Author    :  Deva M
 * Created Date  :   30/01/2022
 * Description  :  Queuable class for Plan Communication-  Internal Comments Automation module for Objective object

 Change History
 **********************************************************************************************************
 Modified By      Date      Jira No.    Description          Tag
 **********************************************************************************************************
 Deva M             30/11/2021    AR-1734        Initial version.      N/A
 */
public with sharing class CSMCreateObjectiveCommentsQueueable implements Queueable {

    public String PLAN_OBJECTIVE_SIGN_OFF_BY_CUSTOMER = 'Plan_Objective_is_signed_off_by_customer';
    //Local variables
    Map<Id,Objective__c> mapObjective;
    //Constructor
    public CSMCreateObjectiveCommentsQueueable(Map<Id,Objective__c> mapObjective) {
        //Initialize
        this.mapObjective = mapObjective;
    }
    //Logic run here
    public void execute(System.QueueableContext qc) {
        createObjectiveInternalComment(mapObjective);
    }

    /*
    Method Name : createObjectiveInternalComment
    Description : This method will create internal plan comments for Objecitve Records
    Parameters   : Map<Id,Objective__c> mapObjective, Called from Objective after update
    Return Type : NA
    */
    public void createObjectiveInternalComment(Map<Id,Objective__c> mapObjective){
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        if(mapObjective.size()>0){
            String  userTimeZoneName = CSMUtilities.getUserTimeZone();
            Map<String,EmailTemplate> mapEmailTemplates = CSMUtilities.getEmailTemplate();
            for(Objective__c  obj : mapObjective.values()){
                //When the objecitve is signed
                if(mapEmailTemplates.get(PLAN_OBJECTIVE_SIGN_OFF_BY_CUSTOMER)!=null){
                    String mergedText = csmPlanQuickActionController.renderTemplate(obj.Id, mapEmailTemplates.get(PLAN_OBJECTIVE_SIGN_OFF_BY_CUSTOMER).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(CSMUtilities.createPlanComment(obj.Plan__c,
                                                                        mergedText,
                                                                        CSMUtilities.STATUS_SUBMITTED,
                                                                        CSMUtilities.TYPE_INTERNAL,
                                                                        CSMUtilities.SUBTYPE_PLAN,
                                                                        true
                                                                        )

                    );
                }
            }
            //Now insert plan comments
            if(lstPlanComments.size()>0){
                insert lstPlanComments;
            }
        }
    }
}