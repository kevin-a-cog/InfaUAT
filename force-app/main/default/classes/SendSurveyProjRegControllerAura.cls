/****************************************************************************************************************************
 *  @Class Name: SendSurveyProjRegControllerAura
 *  @Author: Deloitte
 *  @Date: 2017-12-07 
 *  @Description:PRM US- 1761 - This class is being used for Sending a Survey to the end customer on project
				 registration, when the status of the project registration is Complete-Send Survey and the 
				 Send Survey button is clicked by PSG user.
 *****************************************************************************************************************************
 ChangeHistory      
 ****************************************************************************************************************************/

public class SendSurveyProjRegControllerAura {
    
	/* this method helps in validating if the logged in user has permission set of PSG.
    * @Method Name- CheckUserIsPSG
    * @param parameter- 
    * @return return- Boolean
    * @throws exception-n/a
    */
    Private static boolean CheckUserIsPSG(){
        
     	Boolean user_has_permission = false;
        Id userId = UserInfo.getUserid();
        Integer recordsNumber = 0;
        Set < Id > permissionSetIds = new Set < Id >();
        List < User > userList = new List < User >();
        
        for ( SetupEntityAccess access : [	SELECT ParentId FROM SetupEntityAccess 
                                           	WHERE SetupEntityId IN ( SELECT Id 
											FROM CustomPermission
											WHERE DeveloperName = :label.PRM_Send_Survey_Label )])
        {
        	permissionSetIds.add(access.ParentId);    
        }
        
        userList = [SELECT Username FROM User WHERE Id IN (
                	SELECT AssigneeId FROM PermissionSetAssignment
                	WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =: userId ) LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
     	
        if(userList != null && !userList.isEmpty())
        {
        	recordsNumber = userList.size();
        }
        IF(recordsNumber > 0){
            user_has_permission = true;
        }
        
        return user_has_permission;
    }
    

	/* this method helps in validating if there are any duplicate Evaluation 
	* records for the Project Registration.
    * @Method Name- CheckDuplicateEval
    * @param parameter- Id projRegID
    * @return return- Boolean
    * @throws exception-n/a
    */    
    Private static boolean CheckDuplicateEval(Id projRegID){
        boolean duplicate_Eval = false;
        Integer prRecordsNumber = 0;
        
        List<Evaluation__c> repeatedRecords = [SELECT Eval.Id 
                                               FROM Evaluation__c AS Eval
                                               WHERE Eval.Project_Registration__c = :projRegID];
        
        if(repeatedRecords != null && !repeatedRecords.isEmpty())
        {
        	prRecordsNumber = repeatedRecords.size();
        }
        IF(prRecordsNumber > 0)
        {
            duplicate_Eval = true;
        }
        return duplicate_Eval;
    }
    
    /* this method helps in validating if the status of the Project Reg is Complete - Send Survey
    * before proceeding to send survey. 
    * @Method Name- CheckProjRegStatusSendSurvey
    * @param parameter- String projRegStatus
    * @return return- Boolean
    * @throws exception-n/a
    */
    Private static boolean CheckProjRegStatusSendSurvey(String projRegStatus){
    	boolean IsStatusSendSurvey = false;
        if(projRegStatus == label.PRM_ProjectRegistration_Status_Complete_Send_Survey){
         	  IsStatusSendSurvey = true;
        }
        return IsStatusSendSurvey;
    }
    
    /* this method  used to fetch the Project Registration fields which are used for 
	* validation checks before proceeding to send survey.
	* records for the Project Registration.
    * @Method Name- FetchProjRegFields
    * @param parameter- Id projRegID
    * @return return- Project_Registration__c
    * @throws exception-n/a
    */
	Private static Project_Registration__c FetchProjRegFields(Id projRegID){

        Project_Registration__c getProjReg = [SELECT pr.Id, pr.Status__c, pr.Customer_Contact_Email__c 
											  FROM Project_Registration__c AS pr
											  WHERE pr.Id =:projRegID ];
        
        return getProjReg;
    }

    /* SendSurveyProjRegPostValidation method is referenced in SendSurveyProjRegController Lightning cmp.
    * this method is used to check if validations are all met for the Project Registration inorder to send survey.	
    * @Method Name- SendSurveyProjRegPostValidation
    * @param parameter- Id projRegID
    * @return return- string
    * @throws exception-n/a
    */
    @AuraEnabled
    Public static string SendSurveyProjRegPostValidation(Id projRegID){
        Boolean UserCheck = CheckUserIsPSG();

        Boolean DuplicateCheck = CheckDuplicateEval(projRegID);
		Project_Registration__c currentProjReg = FetchProjRegFields(projRegID);
        
        Boolean ProjRegStatusSendSurvey = false;
		Boolean ProjRegCustomerEmail = false;
        if(String.isNotBlank(currentProjReg.Status__c)) {
			ProjRegStatusSendSurvey = CheckProjRegStatusSendSurvey(currentProjReg.Status__c);
        }
		
        if(String.isNotBlank(currentProjReg.Customer_Contact_Email__c)) {
            ProjRegCustomerEmail = true;
        }
		
		string result;
        
		if(UserCheck == false){
            result = Label.PRM_User_Access_Issue_Message;
        }
        else if(ProjRegStatusSendSurvey == false){
            result = Label.PRM_Project_Reg_no_Survey;
        }
        else if(DuplicateCheck == true){
            result = Label.PRM_Duplicate_Issue_Message;
        }
        else if(ProjRegCustomerEmail == false){
            result = Label.PRM_Customer_Email_Null_Message;
        }
        else{
            result = Label.PRM_Project_Reg_Success_Message;
        }
        return result;
    }
}