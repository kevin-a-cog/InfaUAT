/*
 * Name			:	CaseCommentUtilities
 * Author		:	Deva M
 * Created Date	: 	06-07-2021
 * Description	:	CaseCommentUtilities for generic method which will be used related to case comment

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		6/2/2021		N/A				Initial version.			N/A
 */
public class CaseCommentUtilities {
    /*  
	 Method Name : getServiceCloudSettings
	 Description : This method returns the metadata setting congifured for the provided developername.
	 Parameters	 : String, general setting api name 
	 Return Type : Service_Cloud_General_Setting__mdt record
	 */
    public static Service_Cloud_General_Setting__mdt getServiceCloudSettings(String developerName){ 
        Service_Cloud_General_Setting__mdt obj=new Service_Cloud_General_Setting__mdt();
        for(Service_Cloud_General_Setting__mdt v: [SELECT Filter_Condition__c, Id, DeveloperName FROM Service_Cloud_General_Setting__mdt where DeveloperName=:developerName]){
            obj=v;
        }
        return obj;
    }    

    /*  
	 Method Name : evaluateCondition
	 Description : This method returns the metadata setting congifured for the provided developername.
	 Parameters	 : SObject record, that evaluate against the condition  
                   String condition, condition that configured for the logic
	 Return Type : Boolean, return if the conditon satisfied
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
	 Method Name : isGCSManager
	 Description : This method returns true if the user have custom permission GC_Manager
	 Parameters	 : N/A
	 Return Type : Boolean, return if the conditon satisfied
	 */
    public static Boolean isGCSManager(){
        return FeatureManagement.checkPermission('GCS_Manager');
    }
}