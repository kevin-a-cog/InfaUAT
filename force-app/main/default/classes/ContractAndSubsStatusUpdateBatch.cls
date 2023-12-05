/*
Class:          ContractAndSubsStatusUpdateBatch
@Author:        Chandana Gowda
@Created Date:  05 Nov 2020
@Description:   Batch to update the Subscription status based on cancel reason and
                contract status

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Ramya Ravi         22 Apr 2021     SALESRT-12220       May Build 21        Update the Owner of the Qoute as per the Contracts 'Renewal Quote Owner' feild value.   <T01> 
Chandana Gowda     22 Dec 2021     SALESRT-13543       Jan build 22        Allow partial success on update of subscription and contract status.         <T02>
Anusha Akella      31 Aug 2021     SALESRT-14100       Aug Build 22        Populate status on subscription and custom status on Contract        <SALESRT-14100>    
************************************************************************************************************************************************************
*/
global class ContractAndSubsStatusUpdateBatch implements Database.Batchable<sObject>{
    //This List contains the Contracts for updateglobal 
    List<Contract> contractList = new List<Contract>();   
    global List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    public static globalApexManager GAM = new globalApexManager();    
    private final static List<string> SUB_STATUS_REASON_CANCELLED = String.valueOf(Label.Subscription_Reason_Cancelled).split(';');    
    private final static List<string> SUB_STATUS_REASON_TRADEIN = String.valueOf(Label.Subscription_Reason_Trade_In).split(';');    
    private final static List<string> SUB_STATUS_REASON_RENEWED = String.valueOf(Label.Subscription_Reason_Renewed).split(';');


    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        String BacklogStatus = 'Backlog';
        DateTime dt = System.Now().addHours(-6);
        //getting all contracts modified in last 1 hour
        Map<Id,Contract> contractMap=new Map<Id,Contract>([SELECT Id,Contract_Status_Trigger_Time__c,SBQQ__Opportunity__c,CreatedDate 
                                                            FROM Contract WHERE Contract_Status_Trigger_Time__c >=:dt OR CreatedDate >=:dt]);
        Set<Id> setContractIds = new Set<Id>();
        Set<Id> RenOppIds = new Set<Id>();
        for(Contract contractRec:contractMap.values()){
            if(contractRec.CreatedDate >= dt && contractRec.SBQQ__Opportunity__c != null)
            {
                RenOppIds.add(contractRec.SBQQ__Opportunity__c);
            }
        }
        //to get all the contracts that were co-termed to the renewal Opty
        Map<Id,Contract> allRelatedContractMap=new Map<Id,Contract>([SELECT Id,Contract_Status_Trigger_Time__c,SBQQ__Opportunity__c,CreatedDate 
                                                            FROM Contract WHERE SBQQ__RenewalOpportunity__c IN : RenOppIds]);
        setContractIds.addAll(contractMap.keySet());
        setContractIds.addAll(allRelatedContractMap.keySet());

        query = 'SELECT Id,SBQQ__Contract__c,Status__c,Cancel_Reason__c,SBQQ__EndDate__c,SBQQ__SubscriptionType__c,'+
                'SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed,SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__r.SBQQ__Contracted__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,'+  //<T01>
                'SBQQ__Contract__r.SBQQ__RenewalQuoted__c,SBQQ__Contract__r.SBQQ__Order__c,SBQQ__Contract__r.SBQQ__Order__r.Sub_Type__c,'+
                '(SELECT Id,Subscription__c,Churn_Status__c FROM Unrenewed__r WHERE Quote__r.Primary_Order__r.SBQQ__Contracted__c = true), '+
                '(SELECT Id,SBQQ__Contract__c,Status__c,Cancel_Reason__c,SBQQ__EndDate__c,SBQQ__SubscriptionType__c,'+
                'SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed,SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__r.SBQQ__Contracted__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,'+  //<T01>
                'SBQQ__Contract__r.SBQQ__RenewalQuoted__c,SBQQ__Contract__r.SBQQ__Order__c,SBQQ__Contract__r.SBQQ__Order__r.Sub_Type__c FROM SBQQ__Revisions__r) FROM SBQQ__Subscription__c WHERE SBQQ__RevisedSubscription__c = null AND (SBQQ__Contract__c IN :setContractIds'+
                ' OR (SBQQ__EndDate__c < TODAY AND Status__c != :BacklogStatus AND SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed = false))';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> scope)
    {   
        Set<Id> setContractIds = new Set<Id>();   
        Map<Id,SBQQ__Subscription__c> subscriptionMap = new Map<Id,SBQQ__Subscription__c>();
        //Creating a Map of Subscription records
        for(SBQQ__Subscription__c subRec:scope){
            subscriptionMap.put(subRec.Id, subRec);
        }

        for(SBQQ__Subscription__c subRec:subscriptionMap.values()){
            //Updating the cancel reason from Junction Object
            for(Unrenewed__c unrenwedRec:subRec.Unrenewed__r){
                subRec.Cancel_Reason__c = unrenwedRec.Churn_Status__c;
            }
            //Updating the cancel reason and status and the subscription lines that were amended            
            for(SBQQ__Subscription__c revSubRec:subRec.SBQQ__Revisions__r){
                revSubRec.Cancel_Reason__c = subRec.Cancel_Reason__c;

                if(revSubRec.SBQQ__Contract__r.SBQQ__Order__r.Sub_Type__c == 'Full Debook'){
                    revSubRec.Status__c = 'De-booked';
                }
                else if(revSubRec.Cancel_Reason__c != null){
                    if(SUB_STATUS_REASON_RENEWED.contains(revSubRec.Cancel_Reason__c))
                        revSubRec.Status__c = 'Renewed';
                    if(SUB_STATUS_REASON_CANCELLED.contains(revSubRec.Cancel_Reason__c))
                        revSubRec.Status__c = 'Cancelled';
                    if(SUB_STATUS_REASON_TRADEIN.contains(revSubRec.Cancel_Reason__c))
                        revSubRec.Status__c = 'Trade-In/Upgrade';
                }
                else if(revSubRec.Cancel_Reason__c == null){
                    if((revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName == 'Closed Lost')){
                        revSubRec.Status__c = 'Cancelled';
                    }

                    else if(revSubRec.SBQQ__SubscriptionType__c == 'One-Time'){            
                        revSubRec.Status__c = 'Non-Renewable';
                    }

                    else if(revSubRec.SBQQ__EndDate__c < System.today() && revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed == false){
                        revSubRec.Status__c = 'Backlog';
                    }

                 //   else if(revSubRec.SBQQ__Contract__r.SBQQ__RenewalQuoted__c == true || (revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c != null)){
                       else if(revSubRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__r.SBQQ__Contracted__c == true){ //<T01>    
                    revSubRec.Status__c = 'Renewed';
                    }
                    else if(revSubRec.SBQQ__EndDate__c > System.today()){
                        revSubRec.Status__c = 'Pending Renewal';
                    }
                }
                subscriptionMap.put(revSubRec.Id, revSubRec); 
            }

            if(subRec.SBQQ__Contract__r.SBQQ__Order__r.Sub_Type__c == 'Full Debook'){
                subRec.Status__c = 'De-booked';
            }
            else if(subRec.Cancel_Reason__c != null){
                if(SUB_STATUS_REASON_RENEWED.contains(subrec.Cancel_Reason__c))
                    subRec.Status__c = 'Renewed';
                if(SUB_STATUS_REASON_CANCELLED.contains(subrec.Cancel_Reason__c))
                    subRec.Status__c = 'Cancelled';
                if(SUB_STATUS_REASON_TRADEIN.contains(subrec.Cancel_Reason__c))
                    subRec.Status__c = 'Trade-In/Upgrade';
            }
            else if(subRec.Cancel_Reason__c == null){
                //<SALESRT-14100>
                if(subRec.SBQQ__SubscriptionType__c == 'Evergreen'){            
                    subRec.Status__c = 'Evergreen';
                }
                else if((subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.StageName == 'Closed Lost')){
                    subRec.Status__c = 'Cancelled';
                }
				
                else if(subRec.SBQQ__SubscriptionType__c == 'One-Time'){            
                    subRec.Status__c = 'Non-Renewable';
                }

                else if(subRec.SBQQ__EndDate__c < System.today() && subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed == false){
                    subRec.Status__c = 'Backlog';
                }

             //   else if(subRec.SBQQ__Contract__r.SBQQ__RenewalQuoted__c == true || (subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c != null)){
                else if(subRec.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__r.SBQQ__Contracted__c == true){ //<T01> 
                    subRec.Status__c = 'Renewed';
                }
                else if(subRec.SBQQ__EndDate__c > System.today()){
                    subRec.Status__c = 'Pending Renewal';
                }
            }
            subscriptionMap.put(subRec.Id, subRec); 
            setContractIds.add(subRec.SBQQ__Contract__c);           
        }
        if(!subscriptionMap.values().isEmpty()){
            try{
                //Update the List of Subscription
                //----------------------------------------------------<T02>
                //update subscriptionMap.values();
                Database.SaveResult[] lstSaveResult = Database.update(subscriptionMap.values(), false);
                for(Database.SaveResult saveRes:lstSaveResult){
                    if(!saveRes.isSuccess()){
                        GAM.CreateLogs('ContractAndSubsStatusUpdateBatch - Error updating subscription status', saveRes.getId(),String.valueOf(saveRes.getErrors()[0].getStatusCode()), saveRes.getErrors()[0].getMessage());
                    }
                }
                //----------------------------------------------------<T02/>
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ContractAndSubsStatusUpdateBatch','Exception in ContractAndSubsStatusUpdateBatch: ' , e.getMessage());
            }
        }

        //To update the Status on subscription        
        Map<Id,Contract> mapContracts = new Map<Id,Contract>([SELECT Id,Status_Custom__c,(SELECT Id,Status__c,SBQQ__Contract__c FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id IN :setContractIds]);
        Map<Id,Map<String,Integer>> mapContractwithSubStatus = new Map<Id,Map<String,Integer>>();

        for(Contract contractRec:mapContracts.values()){
            if(!mapContractwithSubStatus.keySet().contains(contractRec.Id)){
                //<SALESRT-14100> adding Evergreen
                Map<String, Integer> statusMap = new Map<String, Integer>{'Pending Renewal' => 0,'Renewed' => 0,'Backlog' => 0,'Trade-In/Upgrade' => 0,
                                                                        'Cancelled' => 0,'De-booked' => 0,'Non-Renewable' => 0,'Evergreen' =>0};
                mapContractwithSubStatus.put(contractRec.Id, statusMap);                                                                        
            }
            for(SBQQ__Subscription__c subRec:contractRec.SBQQ__Subscriptions__r){
                Map<String, Integer> statusMap = mapContractwithSubStatus.get(contractRec.Id);
                if(subRec.Status__c != null){
                    Integer count = statusMap.get(subRec.Status__c) + 1;
                    statusMap.put(subRec.Status__c, count);
                    mapContractwithSubStatus.put(contractRec.Id,statusMap);
                }
            }
            if(mapContractwithSubStatus.get(contractRec.Id) != null){
                //<SALESRT-14100> Adding Evergreen
                if(mapContractwithSubStatus.get(contractRec.Id).get('Pending Renewal') != 0 || mapContractwithSubStatus.get(contractRec.Id).get('Backlog') != 0 || mapContractwithSubStatus.get(contractRec.Id).get('Evergreen') != 0 ){
                    contractRec.Status_Custom__c = 'Active';
                }
                if(mapContractwithSubStatus.get(contractRec.Id).get('Pending Renewal') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Backlog') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Renewed') != 0){
                    contractRec.Status_Custom__c = 'Renewed';
                }
                //<SALESRT-14100>
                if(mapContractwithSubStatus.get(contractRec.Id).get('Pending Renewal') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Backlog') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Renewed') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Evergreen') == 0){
                    
                    if(mapContractwithSubStatus.get(contractRec.Id).get('Trade-In/Upgrade') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Cancelled') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Non-Renewable') == 0 
                    && mapContractwithSubStatus.get(contractRec.Id).get('De-booked') != 0){
                        contractRec.Status_Custom__c = 'De-booked';
                    }
                
                    else if(mapContractwithSubStatus.get(contractRec.Id).get('Trade-In/Upgrade') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Cancelled') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('De-booked') == 0 
                    && mapContractwithSubStatus.get(contractRec.Id).get('Non-Renewable') != 0){
                        contractRec.Status_Custom__c = 'Not Renewable';
                    }
                    else if(mapContractwithSubStatus.get(contractRec.Id).get('Non-Renewable') == 0  && mapContractwithSubStatus.get(contractRec.Id).get('De-booked') == 0 && mapContractwithSubStatus.get(contractRec.Id).get('Cancelled') == 0
                    && mapContractwithSubStatus.get(contractRec.Id).get('Trade-In/Upgrade') != 0){
                        contractRec.Status_Custom__c = 'Not Renewable';
                    }
                    else{
                        contractRec.Status_Custom__c = 'Terminated';
                    }
                }
                contractList.add(contractRec);
            }            
        }

        if(!contractList.isEmpty()){
            try{
                //Update the List of Contracts
                //----------------------------------------------------<T02>
                //update contractList;
                Database.SaveResult[] lstSaveResult = Database.update(contractList, false);
                for(Database.SaveResult saveRes:lstSaveResult){
                    if(!saveRes.isSuccess()){
                        GAM.CreateLogs('ContractAndSubsStatusUpdateBatch - Error updating contract status', saveRes.getId(),String.valueOf(saveRes.getErrors()[0].getStatusCode()), saveRes.getErrors()[0].getMessage());
                    }
                }
                //----------------------------------------------------<T02/>
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('ContractRenewalTypeBatch','Exception in ContractRenewalTypeBatch:  ' , e.getMessage());
            }
        }
        GAM.InsertDebugLogs();        
    } 
    global void finish(Database.BatchableContext BC)
    {
        GAM.CreateLogs('Contract And Subscription Status Update Batch --> finish','timestamp:' + System.now());
        //Insert debug Logs
        GAM.InsertDebugLogs();        
    }  
}