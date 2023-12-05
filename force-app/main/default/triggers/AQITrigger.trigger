/*
    @created by       : balajip
    @created on       : 07/27/2020
    @Purpose          : ArticleQuality Trigger.
    @Testclass        : 
    @JIRA             : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 
*/
trigger AQITrigger on aqi_ltng_mng__Article_Quality__c(after delete, after insert, after update, before delete, before insert, before update) {
        
	/*Hierarchy custom setting created in the system with all the triggers names as //checkbox *fields, validation rules checkbox, process builder checkbox, workflow checkbox so that we can *control each logical implementation via custom setting controller.
	**/
	Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
	
	//check if the user/profile/org level access for the trigger is OFF/ON
	if (bts == null || bts.ArticleQuality__c)  {
		//Calling the handler method to check for the context/recursive check of the trigger invocation.
		new ArticleQualityTriggerHandler().process();
	}
}