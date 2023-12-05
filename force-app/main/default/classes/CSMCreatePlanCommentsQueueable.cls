/*
 * Name			:	CSMCreatePlanCommentsQueueable
 * Author		:	Deva M
 * Created Date	: 	30/01/2022
 * Description	:	Queuable class for Plan Communication-  Internal Comments Automation module for plan obkject

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		30/11/2021		AR-1734				Initial version.			N/A
 */
public with sharing class CSMCreatePlanCommentsQueueable implements Queueable{
    public static globalApexManager gamObj = new globalApexManager();
    List<Plan_Comment__c> lstPlanComments; 
    //Constructor
    public CSMCreatePlanCommentsQueueable(List<Plan_Comment__c> lstPlanComments) {
        this.lstPlanComments=lstPlanComments;
    }
    //Logic run here
    public void execute(System.QueueableContext qc) {
        createPlanInternalComment(lstPlanComments);
    }
    /*
	 Method Name : createPlanInternalComment
	 Description : This method will create internal plan comments for Plan Records
	 Parameters	 : Map<Id,Plan__c> mapPlan, Called from Plan after update via queuable
	 Return Type : NA
	*/
    public void createPlanInternalComment(List<Plan_Comment__c> lstPlanComments){
        //Now insert plan comments
        if(lstPlanComments.size()>0){
            try{
                insert lstPlanComments;
            }catch(Exception ex){
                gamObj.CreateExceptionRecords('CSMCreatePlanCommentsQueueable', 'exception in execute queue',ex.getMessage());
            }
        }
    }   
}