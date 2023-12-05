/*
 * Name         :   CSMUtilities
 * Author       :   Deva M
 * Created Date :   08-10-2021
 * Description  :   Generic class with methods can be reused at multiple places

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Deva M                 08-10-2021      N/A             Initial version.            N/A
 */
public with sharing class CSMUtilities {
    public final static String ROLE_CSM = 'CSM';
    public final static String ROLE_CSM_MANAGER = 'CSM Manager';
    //Comment Type Constants
    public final static String TYPE_CASSINI = 'Cassini';
    public final static String TYPE_INBOUND = 'Inbound';
    public final static String TYPE_EXTERNAL = 'External';
    public final static String TYPE_INTERNAL = 'Internal';
    public final static String TYPE_PRIVATE = 'Private';
    public final static String TYPE_JIRA = 'JIRA';
    /* *Depricated* */
    //public final static String SUBTYPE_PAFUPDATE= 'PAF Update';
    //public final static String SUBTYPE_AUTOPILOT= 'Auto Pilot';
    //public final static String SUBTYPE_GENERAL= 'General';  
    //public final static String SUBTYPE_PAF = 'PAF';    
    //public final static String SUBTYPE_OBJECTIVE_AND_MILESTONE = 'Objectives & Milestone';
    //public final static String SUBTYPE_CLOSING_NOTES = 'Closing Notes';
    //Comment sub type Contants
    public final static String SUBTYPE_PLANHEALTHREASON = 'Plan Health Reason';
    public final static String SUBTYPE_PLAN = 'Plan';
    public final static String SUBTYPE_CSM_MANAGER = 'Manager';
    public final static String SUBTYPE_RISK = 'Risk';
    public final static String SUBTYPE_ENGAGEMENT = 'Engagement';
    //comment status constants
    public final static String STATUS_SUBMITTED = 'Submitted'; 
    public final static String STATUS_DRAFT = 'Draft';
    public final static String STATUS_SCHEDULED = 'Scheduled';
    public final static String STATUS_PREDRAFT = 'Pre Draft';
    public final static String STATUS_ESCALATED= 'Escalated';

    public final static String PERMISSION_CSMUSER= 'CSMUser';
    public final static String PERMISSION_CSOUSER= 'CSOUser';
    public final static String PERMISSION_CSM_EXTERNAL= 'CSM_Success_External';
    public final static String PERMISSION_CSMMANAGERUSER= 'CSMManager';   
    public final static String RISK_RESOLVED= 'Resolved';  
    public final static String RISK_UNRESOLVED= 'Unresolved';  
     //Email Template Folder name
     public static String CSM_INTERNAL_EMAIL_FOLDER_DEVELOPERNAME= 'CSMInternalPlanCommentsTemplates';

    
     /*
     Method Name : createPlanTeamMember
     Description : This method create a plan team record instance with provided inputs
     Parameters  : Id planRecordId, record id from plan
                   String userEmail, string of user email for the plan team member     
                   Id userRecordId, Id of user reacord for the plan team member    
                   String teamMemberRole, string of user email for the plan team member            
     Return Type : n/a
     */
    public static Plan_Team__c createPlanTeamMember(Id planRecordId,String userEmail, Id userRecordId,String teamMemberRole){
        Plan_Team__c planTeamMember = new Plan_Team__c();
        planTeamMember.Plan__c = planRecordId;
        planTeamMember.User_Email__c = userEmail;
        planTeamMember.User__c = userRecordId;
        planTeamMember.Role__c = teamMemberRole; 
        return planTeamMember;
    }

    /** Method Name : createPlanTeamMember
     Description : This method create a plan team record instance with provided inputs
     Parameters  : CSMUtilsWrapper.PlanTeam           
     Return Type : n/a
     */
    public static List<Plan_Team__c> createPlanTeamMember(List<CSMUtilsWrapper.PlanTeam> planTeamWrapperList){
        List<Plan_Team__c> planTeamToInsert = new List<Plan_Team__c>();

        for(CSMUtilsWrapper.PlanTeam pTeam : planTeamWrapperList){
            Plan_Team__c planTeamMember = new Plan_Team__c();
            planTeamMember.Plan__c = pTeam.planId;
            planTeamMember.User_Email__c = pTeam.userEmail;
            planTeamMember.User__c = pTeam.userId;
            planTeamMember.Role__c = pTeam.role; 
            planTeamMember.First_Name__c = pTeam.firstName;
            planTeamMember.Last_Name__c = pTeam.lastName;            
            planTeamMember.Source__c = pTeam.source;

            planTeamToInsert.add(planTeamMember);
        }
        return planTeamToInsert;
    }


     /*
     Method Name : createPlanComment
     Description : This method create a plan comment record instance
     Parameters  : String planRecordId, record id from plan 
                   String commentValue, string of comments provided                
     Return Type : Plan_Comment__c
     */
    public static Plan_Comment__c createPlanComment(String planRecordId,String commentValue, String commentStatus, String commentType,String commentSubType, Boolean isAutomated ) { 
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=planRecordId);
        planComment.Comment__c=commentValue;
        planComment.Type__c=commentType;
        planComment.Sub_Type__c=commentSubType;
        planComment.Status__c=commentStatus;
        planComment.Is_Automated__c=isAutomated;
        return planComment;
    }

    /*
    Method Name : evaluateCondition
    Description : Method to evaulate the records using dynamic script engine and return true if the criteia configured in meta data with record passed to this
    Parameters  : SObject record, record that need tio validate against
                  String condition, dynamic condition        
    Return Type : n/a
    */
     public static Boolean evaluateCondition(SObject record, String condition){
        Boolean returnValue = false;
        Map<String, Object> context = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));    
        try{
            ScriptEngine scriptEngine = ScriptEngine.getInstance();
            Object result = scriptEngine.eval(condition, context);           
            returnValue = (Boolean)result;
        }catch(Exception ex){
            System.debug('exception = ' + ex.getMessage());
        }        
        return returnValue;
    }
  /*
    Method Name : getPlanCommentSetting
    Description : metod to query metadata for provided developer name
    Parameters  : String settingName, metadata DeveloperName filter
    Return Type : n/a
    */
    public static Plan_Comment_Setting__mdt getPlanCommentSetting(String settingName){
        return [SELECT Id,Condition__c
                FROM Plan_Comment_Setting__mdt  
                WHERE IsActive__c = true
                AND DeveloperName =:settingName];
    }
    /*
	 Method Name : hasCSMPermisson
	 Description : This method returns the boolean variable if provided csm custom permission available.
	 Parameters	 : Boolean, called from multiple classes, pass the plan autopilot value.
	 Return Type : Boolean
	 */
	public static Boolean hasCSMPermisson(Boolean boolPlanAutoPilot) {		
		return ((FeatureManagement.checkPermission(PERMISSION_CSMUSER) || FeatureManagement.checkPermission(PERMISSION_CSM_EXTERNAL)) && !boolPlanAutoPilot);
	}

     /*
	 Method Name : hasCSOPermisson
	 Description : This method returns the boolean variable if user has CSO permission.
	 Parameters	 : Boolean, called from multiple classes.
	 Return Type : Boolean
	 */
	public static Boolean hasCSOPermisson() {		
		return FeatureManagement.checkPermission(PERMISSION_CSOUSER);
	}

     /*
	 Method Name : hasCSMManagerPermisson
	 Description : This method returns the boolean variable if user has CSM Manager permission.
	 Parameters	 : Boolean, called from multiple classes
	 Return Type : Boolean
	 */
	public static Boolean hasCSMManagerPermisson() {		
		return FeatureManagement.checkPermission(PERMISSION_CSMMANAGERUSER);
	}
     /*
    Method Name : getCSMUserByRole
    Description : method to get the user manager details for plan
    Parameters  : Set<Id> planIdSet, set of Plan Recordid
                    String strRole, sString of user role
    Return Type : Map<String,User>
    */ 
    public static Map<String,Plan_Team__c> getCSMUserByRole(Set<Id> planIdSet, Set<String> setRole){
        Map<String,Plan_Team__c> planUserMap = new Map<String,Plan_Team__c>();
        for(Plan_Team__c pTeam:[SELECT Id, Plan__c, Role__c, User__c FROM Plan_Team__c WHERE Plan__c IN :planIdSet AND Role__c=:setRole ORDER BY CreatedDate DESC]){
            if(pTeam.Plan__c != null && pTeam.User__c != null && !planUserMap.containsKey(pTeam.Plan__c)){
                planUserMap.put(pTeam.Plan__c+'~'+pTeam.Role__c,pTeam);
            }
        }
        return planUserMap;
    }	

  /*  public static ConnectApi.BatchInput postChatBatchInstance(String strObjId,String strMessage,String strUserRecordId){        
      
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = strObjId;

        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = strMessage;
        body.messageSegments.add(textSegment);

        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = strUserRecordId;//target user for Chatter post
        body.messageSegments.add(mentionSegmentInput);

        input.body = body;

        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
        return batchInput;
    }*/

    /*
	 Method Name : getUserTimeZone
	 Description : This method will retrurn logged in user time zone
	 Parameters	 : na
	 Return Type : String, timezone of user
	 */
    public static String getUserTimeZone(){
        return  [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()].TimeZoneSidKey;
    }

     /*
	 Method Name : getEmailTemplate
	 Description : This method returns the email template map for the provided email template folder.
	 Parameters	 : NA.
	 Return Type : Map<String,EmailTemplate>, map of email template
	 */
    public static Map<String,EmailTemplate> getEmailTemplate(){
        Map<String,EmailTemplate> mapEmailTemplates = new Map<String,EmailTemplate>();
        Id idFolder = [SELECT Id, ParentId, Name, DeveloperName FROM Folder Where DeveloperName =:CSM_INTERNAL_EMAIL_FOLDER_DEVELOPERNAME].Id;
        for(EmailTemplate objEmail:[SELECT Id, FolderId, FolderName, Name, DeveloperName, HtmlValue, Subject, Body FROM EmailTemplate WHERE FolderId=:idFolder]){
            mapEmailTemplates.put(objEmail.Name,objEmail);
        }
        return mapEmailTemplates;
    }
}