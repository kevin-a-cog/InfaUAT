/*
 * Name			:	CSMCreateEngagementCommentsQueueable
 * Author		:	Deva M
 * Created Date	: 	30/01/2022
 * Description	:	Queuable class for Plan Communication-  Internal Comments Automation module for engagement object

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		30/11/2021		AR-1734				Initial version.			N/A
 Chaitanya T            08/21/2023      AR-3385             MFA comments                T01
 */
public with sharing class CSMCreateEngagementCommentsQueueable implements Queueable {
    //Email Template Names
    public String CST_ENGAGEMENT_COMPLETED= 'Completed_CST_Engagement_Template'; 
    public String MFA_ENGAGEMENT_COMPLETED= 'Completed_MFA_Engagement_Template'; 
    public String IPS_ENGAGEMENT_COMPLETED= 'IPS_Engagement_is_Closed';
    public String GEMS_ENGAGEMENT_COMPLETED= 'GEMS_Engagement_is_Closed';
    public Id GEMEngSRecTypeID = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId(); 
    public Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
    public Id IPSJumpStartRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
       
    //Local variables
    Map<Id,Engagement__c> mapEnagement;
    //Constructor
    public CSMCreateEngagementCommentsQueueable(Map<Id,Engagement__c> mapEnagement) {
        //Initialize
        this.mapEnagement = mapEnagement;
    }
    //Logic run here
    public void execute(System.QueueableContext qc) {
        createEngagementInternalComment(mapEnagement);
    }

    /*
	 Method Name : createEngagementInternalComment
	 Description : This method will create internal plan comments for various engagement types
	 Parameters	 : Map<Id,Engagement__c> mapEnagement, Called from Engagement after update
	 Return Type : NA
	 */
    public void createEngagementInternalComment(Map<Id,Engagement__c> mapEnagement){
     
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        if(mapEnagement.size()>0){
            String  userTimeZoneName = CSMUtilities.getUserTimeZone();
            Map<String,EmailTemplate> mapEmailTemplates = CSMUtilities.getEmailTemplate();
            for(Engagement__c  objEng : mapEnagement.values()){
                //When the CST Engagement status is complete
                if(mapEmailTemplates.get(CST_ENGAGEMENT_COMPLETED)!=null && objEng.RecordTypeId == CSTEngagementRT && objEng.RecType__c=='CSA'){
                    String mergedText = csmPlanQuickActionController.renderTemplate(objEng.Id, mapEmailTemplates.get(CST_ENGAGEMENT_COMPLETED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(prepareEngagementPlanComment(mergedText,objEng.Plan__c));
                }
                //When the MFA Engagement status is complete - <T01> start
                if(mapEmailTemplates.get(MFA_ENGAGEMENT_COMPLETED)!=null && objEng.RecordTypeId == CSTEngagementRT && objEng.RecType__c=='MFA'){
                    String mergedText = csmPlanQuickActionController.renderTemplate(objEng.Id, mapEmailTemplates.get(MFA_ENGAGEMENT_COMPLETED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(prepareEngagementPlanComment(mergedText,objEng.Plan__c));
                }//<T01> end
                //When IPS Engagement (Project) is Closed
                if(mapEmailTemplates.get(IPS_ENGAGEMENT_COMPLETED)!=null && objEng.RecordTypeId == IPSJumpStartRT){
                    String mergedText = csmPlanQuickActionController.renderTemplate(objEng.Id, mapEmailTemplates.get(IPS_ENGAGEMENT_COMPLETED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(prepareEngagementPlanComment(mergedText,objEng.Plan__c));
                }
                //GEMS escalation case has been closed
                if(mapEmailTemplates.get(GEMS_ENGAGEMENT_COMPLETED)!=null && objEng.RecordTypeId == GEMEngSRecTypeID){
                    String mergedText = csmPlanQuickActionController.renderTemplate(objEng.Id, mapEmailTemplates.get(GEMS_ENGAGEMENT_COMPLETED).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(prepareEngagementPlanComment(mergedText,objEng.Plan__c));
                }
            }
            //Now insert plan comments
            if(lstPlanComments.size()>0){
                insert lstPlanComments;
            }
        }
    }

     /*
	 Method Name : prepareEngagementPlanComment
	 Description : This method returns the Plan Comment for Engagement.
	 Parameters	 : String strComment, merged comment text form email template
                   Id planRecordId, plan record id
	 Return Type : Plan_Comment__c, Plan comment instance
	*/
    public static Plan_Comment__c prepareEngagementPlanComment(String strComment,Id planRecordId){
        return CSMUtilities.createPlanComment(planRecordId,
                                                strComment,
                                                CSMUtilities.STATUS_SUBMITTED,
                                                CSMUtilities.TYPE_INTERNAL,
                                                CSMUtilities.SUBTYPE_ENGAGEMENT,
                                                true
                                                );
    }
}