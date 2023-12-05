/*************************************************************************
Name:           PsaAssignmentHandler
Author:         Soniya Chouhan
Created Date:   2/23/2021
Description:    psa_AssignmentTrigger's helper populate Resource Manager field.
Change History
*************************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  	|   	Description                            	|  Jira No.      	| Tag No:	|
************|***************|***********************|***********************************************|*******************|***********|
Wasim Akram	|	08/23/2021	|		Neha Kumari		|	Add Field "Subcontractor Hourly Rate" to 	|  PSA-1900		 	| 	<T1>	|
			|				|						|	"Sub-Contractor Request Line" object and map|					|			|
			|				|						|	it to Cost Rate on Assignment				|					|			|
Wasim Akram |   03/21/2023  |       Neha Kumari     |   Default fields when the Type = Shadowing    |   PSA-2917        |   <T2>    |
*************************************************************************************************************************************
*/
public class PsaAssignmentHandler {
    
     public static void beforeUpdateHandler(Map<Id, pse__Assignment__c> newMap, Map<Id, pse__Assignment__c> oldMap,List<pse__Assignment__c> assignmentList){
        //v4    
        List<Id> sfUserIdList = new List<Id>();
        List<Id> contactIdList = new List<Id>();
        List<Id> oppOwnerIdList = new List<Id>();         
        Set<Id> subConLineSet = new Set<Id>();//<T1>
        for(pse__Assignment__c assign : assignmentList){ 
            if(assign.PSA_RM_Resource_salesforce_user_Id__c != null){
                sfUserIdList.add(assign.PSA_RM_Resource_salesforce_user_Id__c);
            }    
            //<T1> - Process only on update
            if(oldMap != null){
                //Add to set only when the Sub Contractor Request Line is changed on Assignment
                if(assign.PSA_RM_Sub_Contractor_Request_Line__c != null && assign.PSA_RM_Sub_Contractor_Request_Line__c != oldMap.get(assign.Id).PSA_RM_Sub_Contractor_Request_Line__c){
                    subConLineSet.add(assign.PSA_RM_Sub_Contractor_Request_Line__c);
                }
            }
            //</T1>
            //<T2>
            //On both insert and update, if the Assignment Type = Shadowing then default the Cost Rate Amount to 0 and Use default cost rate to false            
            if(assign.psa_rm_Assignment_Type__c == 'Shadowing' && (oldMap == null || assign.psa_rm_Assignment_Type__c != oldMap.get(assign.Id).psa_rm_Assignment_Type__c)){
                assign.pse__Cost_Rate_Amount__c = 0;
                assign.pse__Use_Resource_Default_Cost_Rate__c = false;
            }
            //</T2>
        }
        
         Map<Id,psa_rm_Sub_Contractor_Request_Line__c> subConLineMap;
         //<T1> - Query the Sub Contractor Hourly Rate from Sub Contractor Request Line
         if(subConLineSet.size() > 0){
             subConLineMap = new Map<Id,psa_rm_Sub_Contractor_Request_Line__c>([SELECT psa_rm_Subcontractor_Hourly_Rate__c FROM psa_rm_Sub_Contractor_Request_Line__c WHERE Id IN :subConLineSet]);                           
         }
         //</T1>
         Map<Id,User> usrMap = new Map<Id,User>([select id,managerId from user where id IN :sfUserIdList limit :limits.getLimitQueryRows()]);
		
        //Added null check as this same method is used for before insert also and empty map is sent this case.
        for(pse__Assignment__c assgnmt : assignmentList){
            if(usrMap != null && assgnmt.PSA_RM_Resource_salesforce_user_Id__c != null && usrMap.get(assgnmt.PSA_RM_Resource_salesforce_user_Id__c) != null && usrMap.get(assgnmt.PSA_RM_Resource_salesforce_user_Id__c).managerId != null){
                assgnmt.PSA_RM_Resource_s_manager_user__c = usrMap.get(assgnmt.PSA_RM_Resource_salesforce_user_Id__c).managerId;    
            }else{
                assgnmt.PSA_RM_Resource_s_manager_user__c = null;
            }
            
            //Ends v4
            //<T1> - Assign the Cost Rate in Assignment from Hourly Rate of Sub Contractor Request Line 
            //<T2> - Added a condition to ignore Assignment Type = Shadowing
            if(subConLineMap != null && subConLineMap.containsKey(assgnmt.PSA_RM_Sub_Contractor_Request_Line__c) && assgnmt.psa_rm_Assignment_Type__c != 'Shadowing'){
                assgnmt.pse__Cost_Rate_Amount__c = subConLineMap.get(assgnmt.PSA_RM_Sub_Contractor_Request_Line__c).psa_rm_Subcontractor_Hourly_Rate__c;            	
            }
            //</T1>
        }
    }
}