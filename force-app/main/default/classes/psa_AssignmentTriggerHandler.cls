/*
@created by       : MAHESH GANTI
@created on       : 10/19/2020
@Purpose          : Handler class for psa_AssignmentTrigger.

Change History
*************************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  	|   	Description                            	|  Jira No.      	| Tag No:	|
************|***************|***********************|***********************************************|*******************|***********|
RANJAN		|	03/21/2021	|						|	Update Project's End Date with Max 		   	|  PSA-1461		 	| 	<T1>	|
			|				|						|	Assignment End Date						   	|					|			|
------------|---------------|-----------------------|-----------------------------------------------|-------------------|-----------|
RANJAN		|	03/29/2021	|						|	Populate MSA Fields on Creation			   	|  PSA-1499	    	| 	<T2>	|
------------|---------------|-----------------------|-----------------------------------------------|-------------------|-----------|		
RANJAN		|   03/29/2021	|						|	beforeAssignmentDelete - commented since   	|					|			|
			|				|						|	assignment wont be deleted 				   	|  					| 	<T3>	|
------------|---------------|-----------------------|-----------------------------------------------|-------------------|-----------|
Wasim Akram |    8/18/2021  | Bellamkonda, Sarojini	|  	INC0520210-On updating the bill rate on    	|  PSA-1830  	  	|			|
			|				|						|	assignment update the bill rate of unbilled	|					|	<T4>	|
			|				|						|	timecard's under the assignment			   	|					|			|
------------|---------------|-----------------------|-----------------------------------------------|-------------------|-----------|
Wasim Akram	|	8/23/2021	|	Neha Kumari			|	Add Field "Subcontractor Hourly Rate" to   	|  PSA-1900	 		|			|
			|				|						|	"Sub-Contractor Request Line" object and map|					|	<T5>	|
			|				|						|	it to Cost Rate on Assignment				|					|			|
------------|---------------|-----------------------|-----------------------------------------------|-------------------|-----------|
Vivek W 	|	29-Jun-2022	|	Neha Kumari			|	add populate assignment logic for population|  PSA-2066	 		|	<T6>	|
			|				|						|	of PM contact on Assignment on insert and on|					|	    	|
*************************************************************************************************************************************
*/
public class psa_AssignmentTriggerHandler extends TriggerHandler{
    
    private psa_us_AssignmentTriggerHelper helper = new psa_us_AssignmentTriggerHelper();
    // private psa_rr_AssignmentTriggerHelper rrHelper = new psa_rr_AssignmentTriggerHelper();

    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        // rrHelper.runValidationsOnInsert((List<pse__Assignment__c>) newList);
        PsaAssignmentHandler.beforeUpdateHandler((Map<Id, pse__Assignment__c>) newMap,(Map<Id, pse__Assignment__c>) oldMap,(List<pse__Assignment__c>) newList); //<T5>
        // helper.prePopulateMSAFields((List<pse__Assignment__c>) newList); // <T2>
        helper.populateAssignmentFields((List<pse__Assignment__c>) newList);//T6
    }

    //Methods related to the module to be called in after update context
    public override void beforeUpdate() { 
        PsaAssignmentHandler.beforeUpdateHandler((Map<Id, pse__Assignment__c>) newMap,(Map<Id, pse__Assignment__c>) oldMap,(List<pse__Assignment__c>) newList); //<T5>
        
    }

    //Methods related to the module to be called in after update context
    public override void beforeDelete() {        
       // helper.beforeAssignmentDelete((List<pse__Assignment__c>) newList); <T3>
    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.createPermControlAfterAssignInsert((List<pse__Assignment__c>) newList, (Map<Id, pse__Assignment__c>) newMap);
        helper.updateProjectEndDate((List<pse__Assignment__c>) newList);
    }       
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {          
        helper.updatePermControlAfterAssignUpdate((List<pse__Assignment__c>) oldList,(List<pse__Assignment__c>) newList,(Map<Id, pse__Assignment__c>) oldMap, (Map<Id, pse__Assignment__c>) newMap);
    	helper.updateProjectEndDate((List<pse__Assignment__c>) newList); // <T1>
    	helper.updateBillRateonTimeCards((Map<Id, pse__Assignment__c>) oldMap, (Map<Id, pse__Assignment__c>) newMap);//<T4>
    }

    //Methods related to the module to be called in after update context
    public override void afterDelete() {        
        
    }
}