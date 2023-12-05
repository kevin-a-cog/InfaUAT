/*
Class:          ErpSiteExemptStatusUpdateBatch
@Author:        Chandana Gowda
@Created Date:  04 Mar 21
@Description:   Batch to update Exempt Status to Override on ERP Site, Created for TAX-19

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/
global class ErpSiteExemptStatusUpdateBatch implements Database.Batchable<sObject>,Schedulable{
    //This List contains the Contracts for updateglobal 
    public static globalApexManager GAM = new globalApexManager();

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String exemptStatus = 'Exempt';
        Date today = System.today();

        query = 'SELECT Id,Exempt_Status__c,Exemption_On_File__c '+
                'FROM ERP_Site__c '+
                'WHERE Exempt_Status__c = :exemptStatus AND Exemption_On_File__c = false AND Exempt_Status_Date_Stamp__c = :today';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ERP_Site__c> scope){
        List<ERP_Site__c> lstErpSiteToUpdate = new List<ERP_Site__c>();
        for(ERP_Site__c erpSite:scope){
            ERP_Site__c siteRec = new ERP_Site__c(Id = erpSite.Id);
            siteRec.Exempt_Status__c = 'Override';
            lstErpSiteToUpdate.add(siteRec);
        }
        if(!lstErpSiteToUpdate.isEmpty()){
            try{
                update lstErpSiteToUpdate;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ErpSiteExemptStatusUpdateBatch','Exception in ExemptStatusUpdateBatch:  ' , e.getMessage());
            }
        }              
    } 
    
    global void finish(Database.BatchableContext BC){
        GAM.CreateLogs('ERP Site Exempt Status Update Batch --> finish','timestamp:' + System.now());
        //Insert debug Logs
        GAM.InsertDebugLogs();        
    } 
    global void execute(SchedulableContext ctx){
                
        //Create a new Instance of our Class ErpSiteExemptStatusUpdateBatch
        ErpSiteExemptStatusUpdateBatch exemptStatusBatch = new ErpSiteExemptStatusUpdateBatch();
        database.executebatch(exemptStatusBatch,200);
    }     
}