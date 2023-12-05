/*
Class:          ContractRenewalTypeBatch 

@Author:        Diego Soto
@Created Date:  31 January 2019
@Description:   Batch class for Checked Renewal Forecast to the Contract depending of Status and Renewal Forecast
*/
 

/*
Change History
************************************************************************************************************************************
ModifiedBy          Date        Requested By            Description                                 Tag
Diego Soto        02/05/2019    Michael Bruch       The class has ben modified, to when 
                                                    the "Renewal Forecast" field = fals  
                                                    and the "Status" field of the contract 
                                                    is activated, the "Renewal Forecast" 
                                                    field is updated to true.
Sumit Mittal      11/12/2019    SalesRT-11133       Updated the condition to skip checking 
                                                    the renewal forecast if the Business Model 
                                                    is : OEM Royalty, Picklist Fund EVAL, POC. 
Wasim Akram       12/11/2019    SalesRT-11149       Updated the condition based on Product Mix
                                                    and Business Model combinations.
Wasim Akram       08/02/2020    SALESRT-11618       Moving the Renewal Forecast Update Logic from   <T01>
                                                    Process Builder to Batch.

Anil Solanki     05/15/2020     SALESRT-12047       Updated query to include Renewal Type changed to MR on migrated contract <T02>                              
Ramya Ravi       03-May-2021    SALESRT-12976       Updated query to pull contracts that have Default Renewal Contact Roles = FALSE  AND Created Date in LAST 3 DAYS AND Renewal Forecast = TRUE AND Renewal Opportunity != NULL. <SALESRT-12976>
Ramya Ravi       20-May-2021    SALESRT-13014       Modify the class to avoid record lock issue <SALESRT-13014>
************************************************************************************************************************************
*/

global class ContractRenewalTypeBatch implements Database.Batchable<sObject>{
    //This List contains the Contracts for update
    global List<Contract> contractList = new List<Contract>();
    public static globalApexManager GAM = new globalApexManager();
    public Map<Id,ID> OppIDs =new Map<Id,ID>();//<SALESRT-12976>
    List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();//<SALESRT-12976>
    List<OpportunityContactRole> oldContactRoleList = new List<OpportunityContactRole>();//<SALESRT-12976>    
    List<Contract> ContractListToUpdate = new List<Contract>();//<SALESRT-13014>
     /**
* this method is started the apex batch
*
* @param Database.BatchableContext BC
* @return return-Database.QueryLocator
* @throws exception - captures exception in a Exception log record
*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String strStatus= 'Activated';
        //<T02> : Added String to HOLD renewal Type MR value <T02>
        String renewalTypeMR = 'MR';
        //</T02>
        //Assign value to query variable 
        //<T01>Query Updated
        //<T02> Addec condition to include migrated contract where renewal type is changed to MR.
        //<SALESRT-12976> <SALESRT-13014>
       query = 'SELECT Id,Status,SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c,Renewal_Type__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,EndDate,SBQQ__RenewalOpportunityStage__c,SBQQ__RenewalOwner__c,SBQQ__RenewalOpportunityRecordTypeId__c, Business_Model__c, Support__c,One_Time__c,SBQQ__DefaultRenewalContactRoles__c, CreatedDate, Renewal_Forecast_trigger_time__c  FROM Contract WHERE (Status=:strStatus AND SBQQ__RenewalForecast__c=False AND SBQQ__RenewalQuoted__c = False AND PSFT_Contract_Number__c = null AND Renewal_Type__c != null AND (CreatedDate = LAST_N_DAYS:1 OR Renewal_Forecast_trigger_time__c = LAST_N_DAYS:1)) OR (SBQQ__RenewalForecast__c = FALSE AND Renewal_Type__c != null AND Renewal_Type__c =:renewalTypeMR) OR (SBQQ__RenewalForecast__c = TRUE AND SBQQ__RenewalOpportunity__c = NULL  AND CreatedDate = LAST_N_DAYS:5 )  OR (SBQQ__DefaultRenewalContactRoles__c=FALSE AND SBQQ__RenewalForecast__c=TRUE AND SBQQ__RenewalOpportunity__c != NULL AND (CreatedDate = LAST_N_DAYS:3 OR Renewal_Forecast_trigger_time__c = LAST_N_DAYS:1))';
        return Database.getQueryLocator(query);
    }
    
    /**
* this method is execute method the apex batch
*
* @param Database.BatchableContext BC
* @param List<Contract>
* @return return-Database.QueryLocator
* @throws exception - captures exception in a Exception log record
*/
    global void execute(Database.BatchableContext BC, List<Contract> scope)
    {        
        // if no contracts meet the criteria in the start then no need to go through this logic
        //if (scope != null && scope.size() > 0) {
        //Check every contract to set the Renewal Forecast True
        for(Contract con : scope){
            //The contract is added to the list with its update, 
            //<T1>
            //Modified the below if condition for JIRA 11149
            
            if(!(con.Renewal_Type__c == 'OneTime'|| con.Renewal_Type__c == 'In Review' || con.Renewal_Type__c == 'Manual'))
                //</T01>
            { 
                con.SBQQ__RenewalForecast__c = TRUE;  
                
            }
            //<SALESRT-12976> starts 
            if( con.SBQQ__DefaultRenewalContactRoles__c==FALSE 
               && con.SBQQ__RenewalForecast__c==TRUE 
               && con.SBQQ__RenewalOpportunity__c != NULL               
              )
            {
                con.SBQQ__DefaultRenewalContactRoles__c = TRUE;
                OppIDs.put(con.SBQQ__Opportunity__c,con.SBQQ__RenewalOpportunity__c );
            }
            //<SALESRT-13014> if loop
            if( con.SBQQ__RenewalForecast__c==TRUE 
                && con.SBQQ__RenewalOpportunity__c == NULL                
              )
            {
                 con.SBQQ__RenewalForecast__c = FALSE; 
                Contract RenewalContract =new Contract(id=con.id,SBQQ__RenewalForecast__c = TRUE);                
                 ContractListToUpdate.add(RenewalContract);
            }
            contractList.add(con);          
        }
        if(OppIDs.keySet()!=null && !OppIDs.isEmpty())
        {
            oldContactRoleList = [Select id, ContactId, OpportunityId, IsPrimary , Role from OpportunityContactRole where OpportunityId =: OppIDs.keySet()];
            
            for(OpportunityContactRole li: oldContactRoleList)
            {
                OpportunityContactRole newContactRole = li.clone(false, true, false, false);
                if(OppIDs.get(newContactRole.OpportunityId) != null)
                { newContactRole.OpportunityId = OppIDs.get(newContactRole.OpportunityId); }
                newContactRoleList.add(newContactRole);
            } 
        }     
        
        
        if(!newContactRoleList.isEmpty()){
            try{
                //insert the List of Contracts
                insert newContactRoleList;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ContractRenewalTypeBatch','Exception in ContractRenewalTypeBatch newContactRoleList:  ' , e.getMessage());
            }
        }   
        //<SALESRT-12976> ends
        
        if(!contractList.isEmpty()){
            try{
                //Update the List of Contracts
                update contractList;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ContractRenewalTypeBatch','Exception in ContractRenewalTypeBatch:  ' , e.getMessage());
            }
        }   
         //<SALESRT-13014> contract update
        if(!ContractListToUpdate.isEmpty())
        {
            try{
                //Update the List of Contracts
                update ContractListToUpdate;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ContractRenewalTypeBatch','Exception in ContractRenewalTypeBatch ContractListToUpdate:  ' , e.getMessage());
            }  
        }
        
        
        
        //Insert debug Logs
        GAM.Insertdebuglogs();
        //}
    }

        /**
* this method is Finish method the apex batch
*
* @param Database.BatchableContext BC
* @return Void
* @throws NA
*/  
    global void finish(Database.BatchableContext BC)
    {
        GAM.CreateLogs('ContractUpdated --> finish','timestamp:' + System.now());
        //Insert debug Logs
        GAM.InsertDebugLogs();
    }

}