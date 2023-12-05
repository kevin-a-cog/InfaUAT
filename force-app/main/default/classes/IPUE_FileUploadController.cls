/**
 * Name         : IPUE_FileUploadController
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : July 12, 2021
 * Test Class   : IPUE_FileUploadControllerTest
 * Description  : This is the Apex Controller for the ipueFileUpload LWC
 *
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       07-12-2021      IPUE-9      Initial create
 */
public with sharing class IPUE_FileUploadController {

    public class IPUEException extends Exception {}
    public static globalApexManager GAM = new globalApexManager();

    public class FileDataModel{
        @AuraEnabled public String parentObjectAPI;
        @AuraEnabled public String childRelationshipAPI;
        @AuraEnabled public Map<String, Map<String, String>> fieldMappingMap = new Map<String, Map<String, String>>();
        @AuraEnabled public Map<String, String> sObjectBySheetMap = new Map<String, String>();
    }



    @AuraEnabled(cacheable=true)
    public static FileDataModel fetchData(Id recordId){

        FileDataModel dataModel = new FileDataModel();


        List<IPUE_Workbook_Sheet__mdt> workSheetMdt = [
            SELECT Id, Sheet_Name__c, sObject_API__c, Child_sObject_API__c, Child_Relationship_API__c
            FROM IPUE_Workbook_Sheet__mdt
        ];

        // Currently, we are only supporting 1 set of Parent/Child objects
        for (IPUE_Workbook_Sheet__mdt sheet : workSheetMdt) {

            dataModel.sObjectBySheetMap.put(sheet.Sheet_Name__c, sheet.sObject_API__c);

            if (sheet.Child_Relationship_API__c != null) {
                dataModel.parentObjectAPI = sheet.sObject_API__c;
                dataModel.childRelationshipAPI = sheet.Child_Relationship_API__c;
                break;
            }
        }

        List<IPUE_Workbook_Field_Mapping__mdt> fieldMappingMetadata = [
            SELECT Id, Column_Header__c, Record_Field_API__c, Label,
            IPUE_Workbook_Sheet__r.Sheet_Name__c, IPUE_Workbook_Sheet__r.sObject_API__c,
            IPUE_Workbook_Sheet__r.Child_Relationship_API__c
            FROM IPUE_Workbook_Field_Mapping__mdt
        ];

        for (IPUE_Workbook_Field_Mapping__mdt mappingMetadata : fieldMappingMetadata) {

            String columnHeader = mappingMetadata.Column_Header__c;
            String recordFieldAPI = mappingMetadata.Record_Field_API__c;
            String sheetName = mappingMetadata.IPUE_Workbook_Sheet__r.Sheet_Name__c;
            String sObjectAPI = mappingMetadata.IPUE_Workbook_Sheet__r.sObject_API__c;

            if (!dataModel.fieldMappingMap.containsKey(sheetName)) {
                dataModel.fieldMappingMap.put(sheetName, new Map<String, String>());
            }

            Map<String, String> fieldMap = dataModel.fieldMappingMap.get(sheetName);
            fieldMap.put(columnHeader, recordFieldAPI);

            dataModel.fieldMappingMap.put(sheetName, fieldMap);
        }

        return dataModel;

    }

    @AuraEnabled
    public static Id processFile(Id recordId, Estimation_Summary__c parentRecord,  List<Estimation_Summary_Line__c> childRecordList, String base64Data, String fileName){

        try {
            IPUE_FileAttachmentHelper.attachFile(recordId,base64Data, fileName);
            Id summaryId = IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, parentRecord, childRecordList, fileName);

            return summaryId;

       } catch (Exception ex) {

            System.debug('Exception: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            throw new IPUEException('IPUE_FIleUploadController Error: ' + ex.getMessage());

        }
    }
    @AuraEnabled
    public static List<Exceptions_Log__c> handleErrors(String errorCause, String messageAndStackTrace){
        try {

            GAM.CreateLogs(errorCause,messageAndStackTrace);
            GAM.InsertDebugLogs();
            return globalApexManager.lstExpLog;

        } catch (Exception ex) {

            System.debug('Exception: ' + ex);
            System.debug('Exception message: ' + ex.getMessage());
            System.debug('Exception stack trace: ' + ex.getStackTraceString());
            System.debug('Exception cause: ' + ex.getCause());
            throw new AuraHandledException(ex.getMessage());

        }
    }
}