/*
    @created by       : Aishwarya Badri
	@created on       : 01/08/2021
    @Purpose          : Case comment trigger handler class.
    @Testclass        : 
    @JIRA : 
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description                                 Jira No.       Tag
	Akhilesh        13-4-21     Utopia phase 2      completeIRMilestones method is merged 
													in processCaseComments so commented here
	Akhilesh		16-4-21		Utopia phase 2		processCaseComments is added in to after	
													update even as well to handle 
													pre-draft/draft comments	
	Deva	        05-07-21   Utopia phase 2 		update method after update for processcase I2RT-2129
													case record			
 ****************************************************************************************************
*/

public class CaseCommentTriggerHandler extends TriggerHandler{
    
  	private CaseCommentTriggerHelper helper = new CaseCommentTriggerHelper();
     
	public override void beforeInsert() {         
		System.debug('CaseCommentTriggerHandler.. beforeInsert.. ');
		//check for recursion
        if(globalApexManager.avoidRecursion('CaseCommentTrigger', 'before', 'insert') ) {
            return;
        }
		helper.storeSearchableString((List<Case_Comment__c>) newList);
	}

	public override void afterInsert() {
		System.debug('CaseCommentTriggerHandler.. afterInsert.. ');
		//check for recursion
        if(globalApexManager.avoidRecursion('CaseCommentTrigger', 'after', 'insert') ) {
            return;
        }
		System.debug('afterInsert ENTRY');
        //@Akhilesh 13 Apr 2021 -- start
		//helper.completeIRMilestones((List<Case_Comment__c>) newList);     
		//@Akhilesh 13 Apr 2021 -- end

		helper.updateCaseInfo((List<Case_Comment__c>) newList);
		//Deva passign the oldamp null for after insert event  [I2RT-2129]
		helper.processCaseComments((List<Case_Comment__c>) newList,null);
		helper.callSendGridService((List<Case_Comment__c>) newList,null);
		helper.notify((List<Case_Comment__c>) newList, null);
        CaseCommentTriggerHelper.postJiraUpdate(JSON.serialize(newList[0]));
	}
	
	public override void beforeUpdate() {        
		
		//check for recursion
        if(globalApexManager.avoidRecursion('CaseCommentTrigger', 'before', 'update') ) {
            return;
        }
		helper.storeSearchableString((List<Case_Comment__c>) newList);
	}     
	
	public override void afterUpdate() {        
        if(globalApexManager.avoidRecursion('CaseCommentTrigger', 'after', 'update') ) {
            return;
        }
		//Deva passing old map param for exisitng methiod on 06 July 2021 for [I2RT-2129]
		//@Akhilesh 16 Apr 2021 -- start [I2RT-2095]
		helper.processCaseComments((List<Case_Comment__c>) newList,(Map<Id, Case_Comment__c>) oldMap); 
		//@Akhilesh 16 Apr 2021 -- end [I2RT-2095]
		helper.notify((List<Case_Comment__c>) newList, (Map<Id, Case_Comment__c>) oldMap);
        helper.callSendGridService((List<Case_Comment__c>) newList, (Map<Id, Case_Comment__c>) oldMap);
	}
}