/**
 * Name         : IPUE_FileAttachmentHelper
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : July 12, 2021
 * Test Class   : IPUE_FileAttachmentHelperTest
 * Description  : 
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       07-12-2021      IPUE-21     Initial create
 */
public with sharing class IPUE_FileAttachmentHelper {

    @AuraEnabled
    public static Boolean attachFile(Id currentRecordId, String base64Data, String defaultFileName){

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        // Create a FileCreator for the Current Record to get all data needed for ContentVersion creation
        FileCreator currentFile = new FileCreator(currentRecordId, defaultFileName);
        currentFile.createContentVersion(base64Data);

        // If the Current Record does not have existing ContentDocumentLink records, create them
        if (currentFile.contentDocLink == null) {
            currentFile.createContentDocumentLink();
        }

        // If the Current Record is SBQQ__Quote__c and there is a related Opportunity, then create records for Opportunity record as well
        if (currentFile.sObjectName == 'SBQQ__Quote__c' && (Id)currentFile.sObj.get('SBQQ__Opportunity2__c') != null) {

            Id relatedOppId = (Id)currentFile.sObj.get('SBQQ__Opportunity2__c');
            
            FileCreator relatedOppFile = new FileCreator(relatedOppId, defaultFileName);
            relatedOppFile.createContentVersion(base64Data);

            // If the Opportunity Record does not have existing ContentDocumentLink records, create them
            if (relatedOppFile.contentDocLink == null) {
                relatedOppFile.createContentDocumentLink();
            }
        }

        return true;

    }

    /********** Inner Class ********/

    public class FileCreator {

        public Id recordId;
        public Id contentDocId;
        public String sObjectName;
        public String fileName;
        public sObject sObj;
        public ContentDocumentLink contentDocLink;
        public Id contentVersionId;

        public FileCreator(Id recordId, String defaultFileName){

            this.recordId = recordId;
            this.sObjectName = recordId.getSObjectType().getDescribe().getName();
            this.sObj = queryRecord();
            this.fileName = getFileName(defaultFileName);
            this.contentDocLink = getContentDocumentLink();
            this.contentDocId = this.contentDocLink.ContentDocumentId;

        }

        /************************************* Public Helper Methods *************************************/

        public void createContentVersion(String base64Data){
            
            ContentVersion contentVersion       = new ContentVersion();
            contentVersion.IsMajorVersion       = false; // Major versions cannot be replaced
            contentVersion.Description          = 'ContentVersion created automatically via the IPUE Estimator Upload LWC (IPUE_FileAttachmentHelper).';
            contentVersion.VersionData          = EncodingUtil.base64Decode(base64Data);
            contentVersion.ContentDocumentId    = this.contentDocId;
            contentVersion.Title                = this.fileName;
            contentVersion.PathOnClient         = '/' + this.fileName;
            contentVersion.OwnerId              = UserInfo.getUserId();
    
            insert contentVersion;

            this.contentVersionId = contentVersion.Id;
    
        }

        public void createContentDocumentLink(){
            
            ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :this.contentVersionId LIMIT 1];
                
            ContentDocumentLink contentDocLink  = new ContentDocumentLink();
            contentDocLink.ContentDocumentId    = contentVersion.ContentDocumentId;
            contentDocLink.LinkedEntityId       = this.recordId;
            contentDocLink.Visibility           = 'AllUsers';
            contentDocLink.ShareType            = 'I';
            
            insert contentDocLink;
    
        }

        /************************************* Private Helper Methods *************************************/

        private sObject queryRecord(){

            List<String> fieldsToQuery = new List<String>();
            String dynamicFields = '';

            if (this.sObjectName == 'Opportunity') {
                fieldsToQuery.add('New_Org_Opportunity_Number__c');
            } else if (this.sObjectName == 'SBQQ__Quote__c') {
                fieldsToQuery.add('SBQQ__Opportunity2__c');
                fieldsToQuery.add('New_Org_Opportunity_Number__c');
            } else if (this.sObjectName == 'Order') {
                fieldsToQuery.add('Opportunity.New_Org_Opportunity_Number__c');
            }

            for (String field : fieldsToQuery) {
                dynamicFields += ', ';
                dynamicFields += field;
            }

            String query = 'SELECT Id ' + dynamicFields + ', ' +
                           '(SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) ' +
                           'FROM ' + this.sObjectName + ' ' +
                           'WHERE Id = \'' + this.recordId + '\' LIMIT 1';

            return Database.query(query);

        }

        private String getFileName(String defaultFileName) {

            String oppName;

            if (this.sObjectName == 'Opportunity' || this.sObjectName == 'SBQQ__Quote__c') {
                oppName = (String)this.sObj.get('New_Org_Opportunity_Number__c');
            } else if (this.sObjectName == 'Order' && this.sObj.getsObject('Opportunity') != null) {
                oppName = (String)this.sObj.getsObject('Opportunity').get('New_Org_Opportunity_Number__c');
            }
            
            if (oppName != null) {
                return 'IPU Estimation for Opportunity_#' + oppName + '.xlsx';
            } else {
                return defaultFileName;
            }

        }

        private ContentDocumentLink getContentDocumentLink() {

            for (ContentDocumentLink link : this.sObj.getsObjects('ContentDocumentLinks')) {
                if (link.LinkedEntityId == this.recordId && link.ContentDocument.Title == this.fileName) {
                    return link;
                }
            }

            return null;
        }

    }

}