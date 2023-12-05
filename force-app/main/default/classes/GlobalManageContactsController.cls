/*
 * Name         :   GlobalManageContactsController
 * Author       :   Monserrat Pedroza
 * Created Date :   8/19/2021
 * Description  :   Global Manage Contacts controller.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      8/19/2021       N/A             Initial version.            N/A
 */
public with sharing class GlobalManageContactsController {

    //Public variables.
    public static String STRING_FIELD_SET_NAME_ASSIGNED = 'Engagement_Contacts_Assigned';

    /*
     Method Name : getRecords
     Description : This method returns the Assigned or Unassigned records, related to the provided record id.
     Parameters  : String, called from getRecords, strRecordId Record Id.
                   Boolean, called from getRecords, boolGetAssigned If we should return Assigned records.
     Return Type : GlobalDataTableWrapperClass
     */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId, Boolean boolGetAssigned) {
        String strQuery;
        String strCleanRecordId;
        String strCleanRecordIdParent;
        String strObjectName;
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

        //If we received a Account Id.
        if(boolGetAssigned != null && boolGetAssigned) {

            //Now we get the table details.
            strCleanRecordId = String.escapeSingleQuotes(strRecordId);
            strObjectName = Engagement_Contacts__c.class.getName();
            objDataTable.strObjectName = strObjectName;
            objDataTable.strFielSetName = STRING_FIELD_SET_NAME_ASSIGNED;
            objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

            //Now we prepare the response.
            objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
                    ' WHERE Engagement__c = :strCleanRecordId ORDER BY CreatedDate DESC LIMIT 1000');
        } else {

            //First we get the Account__c value.
            strCleanRecordId = String.escapeSingleQuotes(strRecordId);
            strCleanRecordIdParent = String.escapeSingleQuotes(strRecordId);
            for(Engagement__c objRecord : [SELECT Account__c FROM Engagement__c WHERE Id = :strCleanRecordId]) {
                strCleanRecordId = objRecord.Account__c;

                //Now we get the table details.
                strObjectName = AccountContactRelation.class.getName();
                objDataTable.strObjectName = strObjectName;
                objDataTable.lstFieldNames = new List<String>();
                objDataTable.lstFieldNames.add('Access_Level__c');
                objDataTable.lstFieldNames.add('AccountId');
                objDataTable.lstFieldNames.add('Account_Contact_External__c');
                objDataTable.lstFieldNames.add('ContactId');
                objDataTable.lstFieldNames.add('Is_Admin__c');
                objDataTable.lstFieldNames.add('Primary__c');
                objDataTable.lstFieldNames.add('StartDate');
                objDataTable.lstFieldNames.add('EndDate');
                objDataTable.lstFieldNames.add('Timezone__c');
                objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

                //Now we prepare the response.
                objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
                        ' WHERE AccountId = :strCleanRecordId AND ContactId <> NULL AND ContactId NOT IN (SELECT Contact__c FROM ' + 
                        Engagement_Contacts__c.class.getName() + 
                        ' WHERE Engagement__c = :strCleanRecordIdParent) ORDER BY CreatedDate DESC LIMIT 1000');
            }
        }
        return objDataTable;
    }

    /*
     Method Name : getRecordsDeleted
     Description : This method removes the relationship with the provided list of records.
     Parameters  : List, called from getRecordsDeleted, lstRecords Records to be deattached.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getRecordsDeleted(List<Engagement_Contacts__c> lstRecords) {
        if(lstRecords != null && !lstRecords.isEmpty()) {
            for(Engagement_Contacts__c objRecord : lstRecords){
                objRecord.Engagement__c = null;
            }
            update lstRecords;
        }
    }

    /*
     Method Name : getRecordsRelated
     Description : This method relates the corresponding records with the provided Id.
     Parameters  : String, called from getRecordsRelated, strRecordId Record to be related to the list of records.
                   List, called from getRecordsRelated, lstRecords Records to be related.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getRecordsRelated(String strRecordId, List<Id> lstRecords) {
        String strCleanRecordId;
        Engagement_Contacts__c objAssignedRecord;
        List<Engagement_Contacts__c> lstAssignedRecords = new List<Engagement_Contacts__c>();

        //If we received a Plan Id.
        if(String.isNotBlank(strRecordId) && lstRecords != null && !lstRecords.isEmpty()) {
            strCleanRecordId = String.escapeSingleQuotes(strRecordId);
            for(Id idRecord : lstRecords) {
                objAssignedRecord = new Engagement_Contacts__c();
                objAssignedRecord.Engagement__c = strCleanRecordId;
                objAssignedRecord.Contact__c = idRecord;
                lstAssignedRecords.add(objAssignedRecord);
            }
            if(!lstAssignedRecords.isEmpty()) {
                insert lstAssignedRecords;
            }
        }
    }

    /*
     Method Name : getRecordsUpdated
     Description : This method updates the provided records.
     Parameters  : List, called from getRecordsUpdated, lstRecords Records to be updated.
                   List, called from getRecordsUpdated, lstRecords Records to be updated.
     Return Type : None
     */
    @AuraEnabled
    public static void getRecordsUpdated(List<Engagement_Contacts__c> lstAssignedRecords, List<AccountContactRelation> lstUnassignedRecords) {
        if(lstAssignedRecords != null && !lstAssignedRecords.isEmpty()) {
            update lstAssignedRecords;
        } else if(lstUnassignedRecords != null && !lstUnassignedRecords.isEmpty()) {
            update lstUnassignedRecords;
        }
    }
}