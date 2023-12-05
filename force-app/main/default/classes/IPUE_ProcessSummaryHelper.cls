/**
 * Name         : IPUE_ProcessSummaryHelper
 * Author       : Colton Kloppel | ATG, Cognizant | colton.kloppel@atginfo.com
 * Created Date : July 27, 2021
 * Test Class   : IPUE_ProcessSummaryHelperTest
 * Description  : Collection of Helper Methods for retrieving existing estimation summaries and overwriting them or inserting new records.
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Colton Kloppel       07-27-2021      IPUE-24     Initial create
 */
public with sharing class IPUE_ProcessSummaryHelper {

    public class IPUEException extends Exception {}

    @AuraEnabled
    public static Id saveSummaryRecords(Id recordId, Estimation_Summary__c parentRecord,  List<Estimation_Summary_Line__c> childRecordList, String fileName){

            SummaryWrapper summaryToProcess = new SummaryWrapper(recordId, parentRecord, childRecordList,fileName); 
            upsert summaryToProcess.estimationSummaryToUpsert;

            if(!summaryToProcess.previousRecordExists){
                for(Estimation_Summary_Line__c newSummaryLine : summaryToProcess.summaryLinesToUpsert){
                    newSummaryLine.Estimation_Summary__c = summaryToProcess.estimationSummaryToUpsert.Id;
                }
            }

            upsert summaryToProcess.summaryLinesToUpsert;

            return summaryToProcess.estimationSummaryToUpsert.Id;
    
    }

    
    /********** Inner Class ********/

    public class SummaryWrapper{

        public Id recordId;
        public sObject relatedRecord;
        public String sObjName;
        public boolean previousRecordExists;
        public String fileName;
        public Estimation_Summary__c parentRecord;
        public List<Estimation_Summary_Line__c> childRecordList;
        public List<Estimation_Summary__c> existingSummaryList;
        public List<Estimation_Summary_Line__c> summaryLinesToUpsert;
        public Estimation_Summary__c estimationSummaryToUpsert;
        public List<Estimation_Summary_line__c> existingSummaryLines;
        public Map<String,Estimation_Summary_line__c> existingSummaryLinesByServiceIdMap;

    /************************************* Public Helper Methods *************************************/

        public SummaryWrapper(Id recordId, Estimation_Summary__c parentRecord,  List<Estimation_Summary_Line__c> childRecordList, String fileName){
            
            this.recordId = recordId;
            this.parentRecord = parentRecord;
            this.childRecordList = childRecordList;
            this.fileName = fileName;
            this.sObjName = recordId.getSObjectType().getDescribe().getName();
            this.relatedRecord = getRelatedRecord();
            this.previousRecordExists = false;
            this.existingSummaryList = retrieveExistingRecords();

            prepareParentForUpsert();
            associateToCurrentRecord();

            this.summaryLinesToUpsert = overwriteExistingSummaryLines();
            
        }

    /************************************* Private Helper Methods *************************************/
    private sObject getRelatedRecord(){

        String dynamicQueryFields = '';
        String dynamicFilter = '';
        
        if(this.sObjName == 'SBQQ__Quote__c'){
            dynamicQueryFields = ', New_Org_Opportunity_Number__c, SBQQ__Account__c, SBQQ__Opportunity2__c ';
        } else if(this.sObjName == 'Opportunity'){
            dynamicQueryFields = ', New_Org_Opportunity_Number__c, AccountId ';
        } else if(this.sObjName == 'Order'){
            dynamicQueryFields = ', Opportunity.New_Org_Opportunity_Number__c, OpportunityId, AccountId, SBQQ__Quote__c ';
        }

        //Query to return the data of the related object that an Estimation Summary was uploaded from.
        String queryString = 'SELECT Id ' + dynamicQueryFields +
                            'FROM ' + this.sObjName + ' ' +
                            'WHERE Id = \'' + this.recordId + '\' '
                            + dynamicFilter + 'LIMIT 1';

        return Database.Query(queryString);
                            
    }

    private List<Estimation_Summary__c> retrieveExistingRecords(){

            String dynamicQueryFields = '';
            String dynamicFilter = ''; 
            String manualUploadRecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();

            if(this.sObjName == 'SBQQ__Quote__c'){

                //Opportunity should be the main related record to each Estimation Summary. For Quotes, filter based on related opportunity if able. Otherwise filter on Quote__c.
                dynamicQueryFields = ', Opportunity__c, Quote__c';

                if(this.relatedRecord.get('SBQQ__Opportunity2__c') != null){
                    dynamicFilter = 'WHERE (Opportunity__c = \'' + this.relatedRecord.get('SBQQ__Opportunity2__c') + '\' OR Quote__c = \'' + this.recordId + '\') ';
                } else {
                    dynamicFilter =  'WHERE Quote__c = \'' + this.recordId + '\' ';
                }

            } else if(this.sObjName == 'Opportunity'){

                //Opportunity__c is the Opportunity Lookup field on the Estimation_Summary__c
                dynamicQueryFields = ', Opportunity__c';
                dynamicFilter = 'WHERE Opportunity__c = \'' + this.recordId + '\' ';

            } else if(this.sObjName == 'Order'){
                dynamicQueryFields = ', Opportunity__c';
                dynamicFilter = 'WHERE Opportunity__c = \'' + this.relatedRecord.get('OpportunityId') + '\' ';
            }

            //Query, including a subquery to retrieve the related Estimation Summary Lines.
            String queryString = 'SELECT Id, RecordTypeId ' + dynamicQueryFields + ', ' +
                                '(SELECT Id, Service_Id__c, Required_IPUs__c, Estimated_Quantity__c FROM Estimation_Summary_Lines__r) ' +
                                'FROM Estimation_Summary__c ' +
                                dynamicFilter +
                                'AND RecordTypeId = \'' + manualUploadRecordTypeId + '\' ' +
                                'LIMIT 1';

            System.Debug(queryString);
        
            return Database.query(queryString);

        }

        private void prepareParentForUpsert(){

            this.estimationSummaryToUpsert = this.parentRecord;
            if(!this.existingSummaryList.isEmpty()){
                if(this.existingSummaryList.size() > 1){
                    throw new IPUEException('More than one Estimation Summary related to the Opportunity was retrieved. Delete any manually generated summary records and retry.');
                }
                this.previousRecordExists = true;
                //Transfer existing Estimation Summary Id to the Estimation Summary received in payload.
                this.estimationSummaryToUpsert.Id = this.existingSummaryList[0].Id;
            } 

            this.estimationSummaryToUpsert.Name = getSummaryName(this.fileName);
            
            //IPUE-133, round up the Final IPU Estimate value.
            if(this.estimationSummaryToUpsert.Final_IPU_Estimate__c != null){
                Decimal originalIPUValue = this.estimationSummaryToUpsert.Total_Required_IPUs__c;
                this.estimationSummaryToUpsert.Total_Required_IPUs__c = originalIPUValue.round(RoundingMode.CEILING);
            }
            if(Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload') != null){
               this.estimationSummaryToUpsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
            }
        }

        private String getSummaryName(String defaultFileName) {

            String oppName;

            if (this.sObjName == 'Opportunity' || this.sObjName == 'SBQQ__Quote__c') {
                oppName = (String)this.relatedRecord.get('New_Org_Opportunity_Number__c');
            } else if (this.sObjName == 'Order' && this.relatedRecord.getsObject('Opportunity') != null) {
                oppName = (String)this.relatedRecord.getsObject('Opportunity').get('New_Org_Opportunity_Number__c');
            }
            
            if (oppName != null) {
                return 'IPU Estimation for Opportunity_#' + oppName;
            } else {
                return defaultFileName;
            }

        }

        private void associateToCurrentRecord(){
                
            if(this.sObjName == 'SBQQ__Quote__c'){

                //Estimation_Summary__c was uploaded via the Quote Layout. Associate the propery Quote and Opportunity.
                this.estimationSummaryToUpsert.Quote__c = recordId;
                //null check and associate to related Opportunity
                if(this.relatedRecord.get('SBQQ__Opportunity2__c') !=null){
                    this.estimationSummaryToUpsert.Opportunity__c = (Id)this.relatedRecord.get('SBQQ__Opportunity2__c');
                }
                if(this.relatedRecord.get('SBQQ__Account__c') != null){
                    this.estimationSummaryToUpsert.Account__c = (Id)this.relatedRecord.get('SBQQ__Account__c');
                }

            } else if(this.sObjName == 'Opportunity'){

                this.estimationSummaryToUpsert.Opportunity__c = recordId;
                if(this.relatedRecord.get('AccountId') != null){
                    this.estimationSummaryToUpsert.Account__c = (Id)this.relatedRecord.get('AccountId');
                }
            } else if(this.sObjName == 'Order'){
                if(this.relatedRecord.get('OpportunityId') != null){
                    this.estimationSummaryToUpsert.Opportunity__c = (Id)this.relatedRecord.get('OpportunityId');
                }
                if(this.relatedRecord.get('AccountId') != null){
                    this.estimationSummaryToUpsert.Account__c = (Id)this.relatedRecord.get('AccountId');
                }
                if(this.relatedRecord.get('SBQQ__Quote__c') != null){
                    this.estimationSummaryToUpsert.Quote__c = (Id)this.relatedRecord.get('SBQQ__Quote__c');
                }
            }
        }

        private List<Estimation_Summary_Line__c> overwriteExistingSummaryLines(){
            Id manualUploadRecordTypeId;
            if(Schema.SObjectType.Estimation_Summary_Line__c.getRecordTypeInfosByName().get('Manual Upload') != null){
                manualUploadRecordTypeId = Schema.SObjectType.Estimation_Summary_Line__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
            }

            List<Estimation_Summary_Line__c> summaryLinesToUpsert = new List<Estimation_Summary_Line__c>();
            this.existingSummaryLinesByServiceIdMap = new Map<String, Estimation_Summary_Line__c>();

            //Retrieve Summary Lines pulled from Subquery
            if(!this.existingSummaryList.isEmpty() && this.existingSummaryList[0].Estimation_Summary_Lines__r != null){
                this.existingSummaryLines = this.existingSummaryList[0].Estimation_Summary_Lines__r;
            
                //Map existing Summary Lines by Service_ID__c to be compared to new records from Payload
                for(Estimation_Summary_Line__c existingSummaryLine : this.existingSummaryLines){
                    this.existingSummaryLinesByServiceIdMap.put(existingSummaryLine.Service_Id__c,existingSummaryLine);
                }
            }

            //for the Summary Lines in the Payload, compare to existing and inherit the id of any matching service Id records. All other data is overwritten.
            for(Estimation_Summary_Line__c newSummaryLine : this.childRecordList){
                if(this.existingSummaryLinesByServiceIdMap.get(newSummaryLine.Service_Id__c) != null){
                    newSummaryLine.Id = this.existingSummaryLinesByServiceIdMap.get(newSummaryLine.Service_Id__c).Id;
                    this.existingSummaryLinesByServiceIdMap.remove(newSummaryLine.Service_Id__c);
                } else if(newSummaryLine.Estimation_Summary__c == null){
                    newSummaryLine.Estimation_Summary__c = this.estimationSummaryToUpsert.Id;
                }
                if(manualUploadRecordTypeId != null){
                    newSummaryLine.RecordTypeId = manualUploadRecordTypeId;
                }
                if(newSummaryLine.Required_IPUs__c != null){
                    Decimal originalValue = newSummaryLine.Required_IPUs__c;
                    newSummaryLine.Required_IPUs__c = originalValue.round(RoundingMode.CEILING);
                }
                
                summaryLinesToUpsert.add(newSummaryLine);
            }

            //The ExistingSummaryLinesByServiceIdMap removes matching Service Ids.  Set the values of those that remain to 0.
            for(Estimation_Summary_line__c obsoleteLine : this.existingSummaryLinesByServiceIdMap.values()){
                obsoleteLine.Estimated_Quantity__c = 0;
                obsoleteLine.Required_IPUs__c = 0;
                summaryLinesToUpsert.add(obsoleteLine);
            }
            
            return summaryLinesToUpsert;
        }
    }
}