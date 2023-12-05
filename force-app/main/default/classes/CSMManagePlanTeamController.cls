/*
 * Name         :   CSMManagePlanTeamController
 * Author       :   Deva M
 * Created Date :   07/02/2021
 * Description  :   Manage Plan Team controller.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Deva M                 07/02/2021      N/A             Initial version.            N/A
 */
public without sharing class CSMManagePlanTeamController {
    //Public variables.
    public static String STRING_ACCOUNT_TERRITORY_VIEW      = 'AccountUserTerritory2View';
    public static String STRING_ACCOUNT_TEAM_MEMBER         = 'AccountTeamMember';
    public static String STRING_FIELD_SET_NAME              = 'Plan_Team_Table_Fields';
    private final static String ROLE_CSM = 'CSM';
    private final static String ROLE_CSM_MANAGER = 'CSM Manager';
    /*
     Method Name : getAssignedRecords
     Description : This method returns the Plan team assigned records related to the provided Plan.
     Parameters  : String, called from getAssignedRecords, strPlanId Record Id.
                   String, called from getAssignedRecords, strplanAccountId Record Id.
     Return Type : Columns and records.
     */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getAssignedRecords(String strPlanId,String strplanAccountId) {
        String strCleanPlanId;
        String strObjectName = Plan_Team__c.class.getName();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
        }
        //Now we get the table details.
        objDataTable.strObjectName = strObjectName;
        objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
        objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
        //Now we prepare the response.
        objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',icollabTeam__c,User__c,Full_Name__c FROM ' + strObjectName + ' WHERE Plan__c = :strCleanPlanId ORDER BY User__r.Name ASC LIMIT 1000');

        return objDataTable;
    }
     /*
     Method Name : getUnassignedRecords
     Description : This method returns the Plan team un assigned records related to the provided Plan.
     Parameters  : String, called from getAssignedRecords, strPlanId Record Id.
                   String, called from getAssignedRecords, strplanAccountId Record Id.
     Return Type : Columns and records.
     */
    @AuraEnabled(cacheable = false)
    public static DataTableWrapperClass getUnassignedRecords(String strPlanId,String strplanAccountId) {
        String strCleanPlanId;
        String strCleanAccountId;
        DataTableWrapperClass objDataTable = new DataTableWrapperClass();
        //Map to hold both AccountUserTerritory2View and AccountTeamMember and make the unique records based on user id
        Map<Id,SObject> accounTeamMap = new Map<Id,SObject>();
        List<DataTableWrapperClass.TableRowWrapper> planObjList = new List<DataTableWrapperClass.TableRowWrapper>();
        set<Id> planTeamUserIdSet = new Set<Id>();
        set<String> opportunityIdset = new Set<String>();
        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            //Query and process asigned records
            for(Plan_Team__c pt:CSMDataTableQueryUtilities.getPlanTeamByPlanId(new Set<String>{strCleanPlanId})){
                if(pt.User__c!=null){
                    planTeamUserIdSet.add(pt.User__c);
                }               
            }
            //Query Plan Contracts and add the Opportunity to set
            for(Plan_Contract__c pc:CSMDataTableQueryUtilities.getPlanContractByPlanId(new Set<String>{strCleanPlanId})){
                if(pc.Opportunity__c!=null){
                    opportunityIdset.add(pc.Opportunity__c);
                }               
            }
        }
           //If we received a account Id.
        if(string.isnotBlank(strplanAccountId)){      
            strCleanAccountId  = String.escapeSingleQuotes(strplanAccountId); 
             //Query OpportunityTeamMember associated to plan => Plan Contract => OpportunityTeamMember
            if(opportunityIdset.size()>0){
                for(OpportunityTeamMember oppMember:CSMDataTableQueryUtilities.getOpportunityTeamMemberByOpportunity(opportunityIdset)){
                    accounTeamMap.put(oppMember.UserId,oppMember);
                }
            }
            //Query and Process AccountUserTerritory2View records        
            for(AccountUserTerritory2View accTMem:CSMDataTableQueryUtilities.getAccountUserTerritory2ViewByAccountId(new Set<String>{strCleanAccountId})){                accounTeamMap.put(accTMem.UserId,accTMem);
            }
            //Query Account team member associated to plan => account => AccountTeamMember
            for(AccountTeamMember accMember:CSMDataTableQueryUtilities.getAccountTeamMemberByAccountId(new Set<String>{strCleanAccountId})){
                accounTeamMap.put(accMember.UserId,accMember);
            }
        }
        //Process Un assinged records
        if(accounTeamMap.size()>0){
            for(SObject obj:accounTeamMap.values()){               
                DataTableWrapperClass.TableRowWrapper planObj = new DataTableWrapperClass.TableRowWrapper();                    
                if(obj instanceof AccountUserTerritory2View){   // Type cast from sobject type to apprpriate object                     
                    AccountUserTerritory2View accTMem = (AccountUserTerritory2View)obj;
                    if(!planTeamUserIdSet.contains(accTMem.UserId)){
                        planObj.memberName=accTMem.User.Name; planObj.memberEmail=accTMem.User.Email;                        planObj.memberRole=accTMem.RoleInTerritory2;                        planObj.Id = accTMem.Id;                        planObj.userId = accTMem.UserId;                        planObj.source ='Account Territory';                        planObjList.add(planObj);
                    }
                } if(obj instanceof AccountTeamMember){
                    AccountTeamMember accMember = (AccountTeamMember)obj;// Type cast from sobject type to apprpriate object  
                    if(!planTeamUserIdSet.contains(accMember.UserId)){
                        planObj.memberName=accMember.User.Name;                
                        planObj.memberEmail=accMember.User.Email;
                        planObj.memberRole=accMember.TeamMemberRole; 
                        planObj.Id = accMember.Id;
                        planObj.userId = accMember.UserId;
                        planObj.source ='Account Team';
                        planObjList.add(planObj);
                    }
                } if(obj instanceof OpportunityTeamMember){
                    OpportunityTeamMember oppMember = (OpportunityTeamMember)obj;// Type cast from sobject type to apprpriate object  
                    if(!planTeamUserIdSet.contains(oppMember.UserId)){
                        planObj.memberName=oppMember.User.Name;                
                        planObj.memberEmail=oppMember.User.Email;
                        planObj.memberRole=oppMember.TeamMemberRole; 
                        planObj.Id = oppMember.Id;
                        planObj.userId = oppMember.UserId;
                        planObj.source ='Opportunity Team';
                        planObjList.add(planObj);
                    }
                }
            }
        }  

        //Now assing the actual coloumns that need to display on table 
        objDataTable.lstColumns=new List<DataTableWrapperClass.ColumnWrapper>();      
        objDataTable.lstColumns.add(prepareColumn('memberName','Name','String'));
        objDataTable.lstColumns.add(prepareColumn('memberEmail','Email','email'));
        objDataTable.lstColumns.add(prepareColumn('memberRole','Role','String'));
        objDataTable.lstColumns.add(prepareColumn('source','Source','String'));
        objDataTable.lstRecords = planObjList;
        return objDataTable;
    }

    /*
     Method Name : getRecordsDeleted
     Description : This method deletes the PPlan_Team__c record.
     Parameters  : List<Plan_Team__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
                   String, called from getRecordsDeleted, strPlanId Record Id.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static Boolean getRecordsDeleted(List<Plan_Team__c> lstRecords,String strPlanId) {
        String strCleanPlanId;
        Boolean csmTeamAvailable = false;
        Boolean csmManagerTeamAvailable = false;        
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);       
            for(Plan_Team__c pTeam:[SELECT Id, Role__c,Primary__c FROM Plan_Team__c WHERE Plan__c=:strCleanPlanId AND Id NOT IN :lstRecords]){
                if(String.isNotBlank(pTeam.Role__c) && pTeam.Role__c.equals(ROLE_CSM) && pTeam.Primary__c){                    csmTeamAvailable = true;
                }
                if(String.isNotBlank(pTeam.Role__c) && pTeam.Role__c.equals(ROLE_CSM_MANAGER) && pTeam.Primary__c){                    csmManagerTeamAvailable = true;
                }
            }
        }
        if(csmTeamAvailable && csmManagerTeamAvailable){            delete lstRecords;
        }
        return (csmTeamAvailable && csmManagerTeamAvailable);
    }
    /*
     Method Name : getRecordsRelated
     Description : This method insert the Plan Team record.
     Parameters  : List<TableRowWrapper>, called from getRecordsDeleted, lstRecords Records to be inserted.
     Return Type : None
     */
    @AuraEnabled
    public static void getRecordsRelated(String strRecordId,List<DataTableWrapperClass.TableRowWrapper> lstRecords){
        List<Plan_Team__c> platTeamListToInsert = new List<Plan_Team__c>();
        Set<String> planTeamRoleSet = new Set<String>{'CSA','CSM','Account Manager','IPS RM','IPS consultant','EM','HPM','CSM Manager','IPS Project Manager','Escalation Manager'};
        //Get the selected records iterate and create plan team instance and add it to above list and insert
        if(lstRecords!=null && lstRecords.size()>0 && String.isNotBlank(strRecordId)){
            for(DataTableWrapperClass.TableRowWrapper ptwrap:lstRecords){
                Plan_Team__c objPlanTeam = new Plan_Team__c(Plan__c=strRecordId,User__c=ptwrap.userId);
                //check if team member role matched 
                if(planTeamRoleSet.contains(ptwrap.memberRole)){
                    objPlanTeam.Role__c = ptwrap.memberRole;
                }else{
                    objPlanTeam.Role__c = 'Collaborator';
                }
                platTeamListToInsert.add(objPlanTeam);
            }
        }
        //Now insert the records if the selected records are not blank
        insert platTeamListToInsert;        
    }
     /*
     Method Name : getRecordsUpdated
     Description : This method updates the provided records.
     Parameters  : List<Plan_Team__c>, called from getRecordsUpdated, lstRecords Records to be updated.
     Return Type : None
     */
    @AuraEnabled
    public static void getRecordsUpdated(List<Plan_Team__c> lstRecords){
        update lstRecords;
    }
    /*
     Method Name : prepareColumn
     Description : This generic methiod will prepare a coloumn wrppaer instance with provided valies 
     Parameters  : String fieldName, this will fieldname declared from wrapper instance
                   String label, this will label declared from wrapper instance
                   String objType, this will objType declared from wrapper instance
     Return Type : None
     */
    private static DataTableWrapperClass.ColumnWrapper prepareColumn(String fieldName,  string  label, string type){
      
        DataTableWrapperClass.ColumnWrapper objColumn = new DataTableWrapperClass.ColumnWrapper();
        objColumn.fieldName = fieldName;
        objColumn.label = label;
        objColumn.type = type; 
        objColumn.sortable = true;              
        return objColumn;
    } 
}