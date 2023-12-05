/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : Controller class for Engagement Lightning components
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************
balajip     11/25/2021  I2RT-5030   T01     method getCases - to include all types of Cases
balajip     12/22/2021  I2RT-5011   T02     added methods getColumnNames and saveColumnNames to persist 
                                                the column selection for the Manage Cases table
balajip     01/06/2022  I2RT-5229   T03     method updateCases - exception handling
Shashikanth 06/16/2023  I2RT-8535   T04     GEMS: Manage Escalated cases to have all cases from that Customer Account
*/
public with sharing class EngagementController {
    public EngagementController() {

    }

    @AuraEnabled
    public static List<Case> getCases(String engagementId, String supportAccountId, String customerAccountId){              //<T04>
        return [Select Id, Subject, CaseNumber, Case_Number__c, Status, Support_Account__c,Next_Action__c,Case_Last_Activity__c,
                    Engagement__c, Engagement__r.Title__c, Engagement__r.Engagement_Number__c, OwnerId, Owner.Name, 
                    Priority, Forecast_Product__c, Version__c, CreatedDate, ClosedDate, IsClosed,
                    Closing_Notes__c, Escalation_Notes__c, Engineer_Review_Comments__c, RecordType.Name, IsEscalated,
                    Case_Owner_Manager__c, Case_Owner_Manager__r.Name,Support_Account__r.Name                               //<T04>
                  From Case 
                  Where (Engagement__c = :engagementId Or Support_Account__c = :supportAccountId 
                            Or Support_Account__r.ParentId = :customerAccountId)    //<T04>
                    //T01 - commented out the condition on Record Type so that all types are retrieved
                    //And (RecordType.name = 'Operations' OR recordType.name = 'Technical')
                    ];
    }
 
    @AuraEnabled
    public static void updateEscalationNotes(String caseIds, String notes){
        System.debug('caseIds - ' + caseIds);
        Type typeListString = Type.forName('List<String>');
        List<String> lstCaseId = (List<String>)JSON.deserialize(caseIds, typeListString);
        System.debug('lstCaseId - ' + lstCaseId);

        List<CaseDetail> lstCaseDetail = new List<CaseDetail>();
        for(String caseId : lstCaseId){
            CaseDetail caseDetail = new CaseDetail();
            caseDetail.id = caseId;
            caseDetail.escalationNotes = notes;
            lstCaseDetail.add(caseDetail);
        }

        if(!lstCaseDetail.isEmpty()){
            updateCases(lstCaseDetail);
        }
    }

    public class CaseDetail{
        public String id;
        public String escalationNotes;
        public String closingNotes;
    }

    //T03 - Custom Exception class
    public class EscNotesException extends Exception {

    }

    @AuraEnabled
    public static void updateCases(Object data) {
        List<CaseDetail> lstCaseDetail = (List<CaseDetail>) JSON.deserialize(JSON.serialize(data), List<CaseDetail>.class);
        updateCases(lstCaseDetail);
    }

    public static void updateCases(List<CaseDetail> lstCaseDetail){
        List<Case> lstCaseToUpdate = new List<Case>();
        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();

        Set<Id> setCaseId = new Set<Id>();
        for(CaseDetail caseDetail: lstCaseDetail){
            setCaseId.add(caseDetail.id);
        }

        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, Closing_Notes__c, Escalation_Notes__c 
                                            From Case Where Id in :setCaseId]);
        
        for(CaseDetail caseDetail: lstCaseDetail){
            Case cse = mapCaseIdToCase.get(caseDetail.id);

            Boolean updateCase = false;
            if(!String.isEmpty(caseDetail.closingNotes) && caseDetail.closingNotes != cse.Closing_Notes__c){
                cse.Closing_Notes__c = caseDetail.closingNotes;
                updateCase = true;
            }

            if(!String.isEmpty(caseDetail.escalationNotes) && caseDetail.escalationNotes != cse.Escalation_Notes__c){
                //T03 - check if the User has access to update Escalation Notes on Case
                if(!CaseCommentUtilities.isGCSManager()){
                    throw new EscNotesException('Cannot update Escalation Notes!');
                }
                cse.Escalation_Notes__c = caseDetail.escalationNotes;
                updateCase = true;

                Case_Comment__c caseComment = new Case_Comment__c();
                caseComment.Case__c = caseDetail.id;
                caseComment.Status__c = CaseCommentService.STATUS_SUBMITTED;
                caseComment.Inbound__c = false;
                caseComment.Visibility__c = CaseCommentService.VISIBILITY_INTERNAL;
                caseComment.Comment_Category__c = 'Escalation Notes';
                caseComment.Comment__c = caseDetail.escalationNotes;
                lstCaseComment.add(caseComment);
            }

            if(updateCase){
                lstCaseToUpdate.add(cse);
            }
        }

        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;                
            if(!lstCaseComment.isEmpty()){
                insert lstCaseComment;
            }
        }
    }
    
    @AuraEnabled
    public static void removecasesfromEngagement(String caselist){
        List<Case> lstCaseToUpdate = new List<Case>();        
        Type typeListString = Type.forName('List<String>');
        List<String> lstCaseId = (List<String>)JSON.deserialize(caselist, typeListString);

        Set<Id> setCaseId = new Set<Id>();
         for(String caseId : lstCaseId){
            Case cse = new Case();
            cse.Id = caseId;            
            cse.Engagement__c =  null;
            lstCaseToUpdate.add(cse);
         }

        
        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;            
        }
    }

    //T02
    //retrives and returns the column selection for the current user
    @AuraEnabled
    public static List<String> getTableColumns(){
        List<String> lstColumnName = new List<String>();
        try {
            String columnNames = GCS_Config__c.getInstance().GEMS_Manage_Cases_Columns__c;
            lstColumnName = columnNames.split(',');
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return lstColumnName;
    }
    
    //T02
    //persists the column selection for the current user
    @AuraEnabled
    public static void saveTableColumns(List<String> lstColumnName){
        try {
            String columnNames = String.join(lstColumnName, ',');
            GCS_Config__c gcsConfig = GCS_Config__c.getInstance();
            gcsConfig.SetupOwnerId = UserInfo.getUserId();
            gcsConfig.GEMS_Manage_Cases_Columns__c = columnNames;
            upsert gcsConfig;
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
    }
}