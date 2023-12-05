/*
 * Name			:	CSMCreateOpportunityCommentsQueueable
 * Author		:	Deva M
 * Created Date	: 	30/01/2022
 * Description	:	Queuable class for Plan Communication-  Internal Comments Automation module for Opportunity obkject

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		30/11/2021		AR-1734				Initial version.			N/A
 */
public with sharing class CSMCreateOpportunityCommentsQueueable implements Queueable{
    public String OPPTY_CLOSED_TEMPLATE='Renewal_Oppty_Closed';
    //Local Variables
    Set<Id> setOpportunity;
    //Constructor 
    public CSMCreateOpportunityCommentsQueueable(Set<Id> setOpportunity) {
        this.setOpportunity=setOpportunity;
    }

    //Logic run here
    public void execute(System.QueueableContext qc) {
        createOpportunityInternalComment(setOpportunity);
    }
    
    /*
	 Method Name : createPlanInternalComment
	 Description : This method will create internal plan comments for Opportunity Records
	 Parameters	 : Set<Id> setOpportunity
	 Return Type : NA
	*/
    public void createOpportunityInternalComment(Set<Id> setOpportunity ){        
        //opportunity closed won or lost
        if(setOpportunity.size()>0){
            List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
            String  userTimeZoneName = CSMUtilities.getUserTimeZone();
            Map<String,EmailTemplate> mapEmailTemplates = CSMUtilities.getEmailTemplate(); 
            for(Related_Opportunity_Plan__c obj:[SELECT Id, Plan__c, Opportunity__c FROM Related_Opportunity_Plan__c WHERE Opportunity__c=:setOpportunity]){
                if(obj.Opportunity__c != null && obj.Plan__c != null && mapEmailTemplates.get(OPPTY_CLOSED_TEMPLATE)!=null){
                    String mergedText = csmPlanQuickActionController.renderTemplate(obj.Opportunity__c, mapEmailTemplates.get(OPPTY_CLOSED_TEMPLATE).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                    lstPlanComments.add(preparePlanPlanComment(mergedText,obj.Plan__c));
                }
            }
            if(lstPlanComments.size()>0){
                insert lstPlanComments;
            }
        }
    }

    /*
	 Method Name : preparePlanPlanComment
	 Description : This method returns the Plan Comment for Plan.
	 Parameters	 : String strComment, merged comment text form email template
                   Id planRecordId, plan record id
	 Return Type : Plan_Comment__c, Plan comment instance
	*/
    public static Plan_Comment__c preparePlanPlanComment(String strComment,Id planRecordId){
        return CSMUtilities.createPlanComment(planRecordId,
                                                strComment,
                                                CSMUtilities.STATUS_SUBMITTED,
                                                CSMUtilities.TYPE_INTERNAL,
                                                CSMUtilities.SUBTYPE_PLAN,
                                                true
                                                );
    }
}