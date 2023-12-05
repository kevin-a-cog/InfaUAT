/*
 * Name			:	CSMObjectivesSignoffController
 * Author		:	Deva M
 * Created Date	: 	30/11/2021
 * Description	:	controller for Objective Sign off component

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva           		30/11/2021		N/A				Initial version.			N/A
 */
public with sharing class CSMObjectivesSignoffController {
    public static String STRING_OBJECTIVE_SIGN_OFF_FIELD_SET_NAME = 'CSM_Objective_Sign_Off_Table_Fiield_Set';
    public static String STRING_EMAIL_TEMPLATE_FOLDER_NAME = 'Objective Signoff Email Templates';
    public static String STRING_FIELD_SET_NAME = 'Plan_Contacts';
    /*
	 Method Name : getRecords
	 Description : This method returns the Plan objectieves records related to the provided Plan.
	 Parameters	 : String, called from getRecords, strPlanId Record Id.
	 Return Type : GlobalDataTableWrapperClass, Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId) {
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        String strCleanRecordId;
        String strObjectName = Objective__c.class.getName();
        Boolean boolInternal=false;
        //First we make sure we received an id.
		if(String.isNotBlank(strPlanId)) {
            strCleanRecordId = String.escapeSingleQuotes(strPlanId);
            //Now we get the table details.
            objDataTable.strObjectName = strObjectName;
            objDataTable.strFielSetName = STRING_OBJECTIVE_SIGN_OFF_FIELD_SET_NAME;
            objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
            //Now we prepare the response.
            objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Plan__r.CSM_isAutoPilot__c,Plan__r.Name FROM ' + strObjectName + ' WHERE Plan__c = :strCleanRecordId AND Sign_Off_Date__c = null AND Is_Internal__c=:boolInternal LIMIT 1000');
		 }
        return objDataTable;
    }   
    /*
	 Method Name : getContactRecords
	 Description : This method returns the Plan contact records related to the provided Plan.
	 Parameters	 : String, called from getContactRecords, strPlanId Record Id.
	 Return Type : GlobalDataTableWrapperClass, Columns and records.
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getContactRecords(String strPlanId) {
        //Filter plan contacts with roles of Business Owner and Technical Owner
        Set<String> setRoles = new Set<String>{'Business Owner','Technical Owner'};
        String strCleanPlanId;
		String strObjectName = Plan_Contact__c.class.getName();
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            //Now we get the table details.
			objDataTable.strObjectName = strObjectName;
			objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
			objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
			//Now we prepare the response.
            objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',Contact__c,Contact_Name__c FROM ' + strObjectName + ' WHERE Plan__c = :strCleanPlanId AND Role__c IN:setRoles LIMIT 1000');
        }
        return objDataTable;
    } 

    /*
	 Method Name : fetchMergedQuickText
	 Description : This method returns the list of email templates configured for quick action.
	 Parameters	 : String, called from fetchMergedQuickText, strPlanId Record Id.
                   String, called from fetchMergedQuickText, strEmailTeamplateName Email TemPlateName.
	 Return Type : String, body text of email template
	 */
    @AuraEnabled(cacheable = false)
    public static String fetchMergedQuickText(String strPlanId,String strEmailTeamplateName) {        
        String mergedText = '';
        mergedText = csmPlanQuickActionController.getEmailBody(strPlanId, strEmailTeamplateName);
        return mergedText;   
    }

    /*
	 Method Name : createObJectivePlanComment
	 Description : This method create a plan comment record when plan is moved auto pilot
	 Parameters	 : String planRecordId, record id from plan quick action auto pilot 
                   String createObJectivePlanComment, string of comments added in signoff screen                   
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void createObJectivePlanComment(String planRecordId,String commentBody, String strContactId,List<Objective__c> lstSelectedObjectives) {        
        String strCleanRecordId;
        String strCleanContactId;
        List<Objective__c> lstUpdatedObjectives = new List<Objective__c>();
        //If we have plan record Id
        if(String.isNotBlank(planRecordId)) {            
            strCleanRecordId = String.escapeSingleQuotes(planRecordId);
            if(String.isNotBlank(strContactId)){
                strCleanContactId = String.escapeSingleQuotes(strContactId);
                //if Selected records are passed
                if(lstSelectedObjectives != null &&  lstSelectedObjectives.size()>0){
                    for(Objective__c objRec:lstSelectedObjectives){
                        lstUpdatedObjectives.add(new Objective__c(Id=objRec.Id, Customer_Sign_off_Contact__c = strCleanContactId,Sign_Off_Date__c=System.today()));
                    }
                }
                //update objective
                update lstUpdatedObjectives;               
            }
            //Cretea Plan comment for objetive sign off          
            Plan_Comment__c planComment = CSMUtilities.createPlanComment(strCleanRecordId,commentBody,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_EXTERNAL,CSMUtilities.SUBTYPE_PLAN,false);
            planComment.Visibility__c = CSMUtilities.TYPE_EXTERNAL;
            insert planComment;
        }
    }


    /*
	 Method Name : updateSignoffObjectives
	 Description : This method will update selected objectives with sign off date
	 Parameters	 : String strContactId, record id of plan contact
                   List lstSelectedObjectives, List of selected objectives                
	 Return Type : n/a
	 */
    @AuraEnabled(cacheable = false)
    public static void updateSignoffObjectives(String strContactId,List<Objective__c> lstSelectedObjectives) {        
        System.debug('==>'+strContactId); 
        List<Objective__c> lstUpdatedObjectives = new List<Objective__c>();
        String strCleanContactId;
       //Check if contact is not blank
        if(String.isNotBlank(strContactId)){
            strCleanContactId = String.escapeSingleQuotes(strContactId);
        }
        System.debug('==>'+strCleanContactId);
        //if Selected records are passed
        if(lstSelectedObjectives != null &&  lstSelectedObjectives.size()>0){
            for(Objective__c objRec:lstSelectedObjectives){
                Objective__c obj=new Objective__c(Id=objRec.Id);
                if(String.isNotBlank(strCleanContactId)){
                    obj.Customer_Sign_off_Contact__c = strCleanContactId;
                    obj.Sign_Off_Date__c=System.today();
                    obj.Sign_Off_Status__c='Approved';
                    obj.Signed_Off_By__c='CSM';
                }else{
                    obj.Sign_Off_Status__c='Waiting for Customer Signoff';
                }
                lstUpdatedObjectives.add(obj);
            }
            //update objective
            update lstUpdatedObjectives;               
        }
    }
}