/*
 * Name			:	CSMCreateAdoptionFactorRecordBatch
 * Author		:	Deva M
 * Created Date	: 	30/09/2021
 * Description	:	this Batch will create adoption factor shell records under plan

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					        Tag
 **********************************************************************************************************
 Deva M					30/09/2021		AR-1575			Initial version.			        N/A
 Deva M					29/11/2021		AR-1823			Paff comments and 
                                                        chatter notificaitons		        N/A
 Karthi G               20/09/2022      AR-2919         Logic to create Shell PAF
                                                        record on due date and add
                                                        plan comment                        <T01>
**********************************************************************************************************
 */
global class CSMCreateAdoptionFactorRecordBatch implements Database.Batchable<sObject>{
    global static globalApexManager gam = new globalApexManager();
    /*
	 Method Name : start
	 Description : To collect the records or objects to pass to the interface method execute, call the start method at the beginning of a batch Apex job.
	 Parameters	 : A reference to the Database.BatchableContext object.                
	 Return Type : This method returns either a Database.QueryLocator object or an iterable that contains the records or objects passed to the job.
	 */
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query=Label.PAFReassesmentQuery;
        return Database.getQueryLocator(query);
    }
    /*
	 Method Name : execute
	 Description : To do the required processing for each chunk of data, use the execute method. 
                   This method is called for each batch of records that you pass to it.
	 Parameters	 : A reference to the Database.BatchableContext object.
                   A list of Plan__c, such as List<Plan__c>. 
	 Return Type : void
	 */
    global void execute(Database.BatchableContext BC, List<Plan__c> planRecords){
        try{
            List<Adoption_Factor__c> pafRecords = new List<Adoption_Factor__c>();
            for(Plan__c pl:planRecords){
                if(pl.Adoption_Factor__r!=null && pl.Adoption_Factor__r.size()>0 && pl.Adoption_Factor__r[0].Status__c=='Final'){
                    pafRecords.add(pl.Adoption_Factor__r);
                }
            }
            if(pafRecords!=null && pafRecords.size()>0){
                CSMCreateAdoptionFactorRecords obj = new CSMCreateAdoptionFactorRecords();
                obj.handlePAFOverdue(pafRecords);
            } 
        }          
        catch(Exception e){
            gam.CreateLogs('CLASS: CSMCreateAdoptionFactorRecordBatch | METHOD: execute', JSON.serialize(e));
        }
                
    }
     /*
	 Method Name : finish
	 Description : execute post-processing operations, use the finish method. This method is called after all batches are processed.
	 Parameters	 : A reference to the Database.BatchableContext object.
	 Return Type : void
	 */
    global void finish(Database.BatchableContext BC){
        //Insert debug Logs
        gam.CreateLogs('CSMCreateAdoptionFactorRecordBatch--> finish','timestamp:'+System.now());
        gam.InsertDebugLogs();
    }
}