/*
 * Name			:	CSMCreateAdoptionFactorRecordSchedular
 * Author		:	Deva M
 * Created Date	: 	30/09/2021
 * Description	:	this Batch will run the schedule job of adoption factor record

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					30/09/2021		AR-1575			Initial version.			N/A
 */
global with sharing class CSMCreateAdoptionFactorRecordSchedular implements Schedulable {
     /*
	 Method Name : execute
	 Description : this method to instantiate the class you want to schedule.
	 Parameters	 : A reference to the SchedulableContext object.                
	 Return Type : void
	 */
    global void execute(SchedulableContext sc) {
        CSMCreateAdoptionFactorRecordBatch batchJob = new CSMCreateAdoptionFactorRecordBatch(); 
        database.executebatch(batchJob);
    }
}