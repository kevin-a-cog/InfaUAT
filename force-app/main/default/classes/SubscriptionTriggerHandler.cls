/***************************************************************************
*        Name        :        SubscriptionTriggerHandler
*        Author      :        Thejaswini Sattenapalli
*        Date        :        14 Septmber 2017
*        Description :        Handler class for Subscription Trigger
****************************************************************************

Change History
******************************************************************************************************************************************
ModifiedBy          Date        Requested By                JIRA#           Description                                       Tag
******************************************************************************************************************************************
Rupanjana Mitra     11/2/2017   Thejaswini Sattenapalli                     Created methods to follow Trigger Framework
Deloitte            2/21/2019   Q2C                                         Populate renewal fields on contract
Deloitte            2/25/2019   Update related Assets                       Update Related assets current subscription
                                                                            to new subscription
Ambica              6/4/2019    Liz                         SALESRT-4232    Added null check before reading                   <T01>
                                                                            Subscription_Renewal_Type__c        
Vivek               7/24/2019   Sowmya/Liz                  SALESRT-4148    To stop population of Renewal type and Renewal
                                                                            Owner and thereby stop the creation of renewal
                                                                            Opporunity from contract based on Subscription 
                                                                            line behavior                                     <T02>
Wasim        11/12/2019  Liz              SALESRT-11149  Update the Product mix checkboxes based on 
                                      conditions which will determine the Renewal Type 
                                      through Process Builder.                          <T03>
Wasim        08/02/2020  Keerthana          SALESRT-11618  Renewal Routing getting failed due to 101 error. 
                                      Moving the logic from Process Builder to Trigger.  <T04>
cgowda       10-Oct-2022        payGo proj 22               SALESRT-14100   Update the Renewal type to one-time for Evergreen Contracts <SALESRT-14100>                                      
******************************************************************************************************************************************
*/
public class SubscriptionTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /*
* Handle AFTER INSERT trigger
*/
    public static void handleAfterInsert(List<SBQQ__Subscription__c> lstTriggerNew){        
        updateContractEndDate(lstTriggerNew);
        
        //<T04>
        Set<Contract> contractSet = new Set<Contract>();
        Set<Id> contractIdSet = new Set<Id>();
        for(SBQQ__Subscription__c objSubs : [SELECT Id,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE Id IN :lstTriggerNew])
        {
            contractIdSet.add(objSubs.SBQQ__Contract__c);
        }
        //<SALESRT-14100> : Added SBQQ__Evergreen__c field
        for(Contract objContract : [SELECT Id,SBQQ__Quote__c,SBQQ__RenewalForecast__c,Business_Model__c,One_Time__c,Support__c,DaaS__c,SBQQ__Evergreen__c FROM Contract WHERE Id IN :contractIdSet])
        {
            contractSet.add(objContract);
        }
        //</T04>
        updateProductMix(lstTriggerNew, null, null);
        //<T04>
        ContractTriggerHandler.assignRenewalTypeOwner(contractSet, null, null, 'Insert');
        //</T04>
        updateAssetLookup(lstTriggerNew);
    }
    
    /*
* Handle AFTER UPDATE trigger
*/
    public static void handleAfterUpdate(List<SBQQ__Subscription__c> lstTriggerNew, Map<Id,SBQQ__Subscription__c> mapTriggerOld, Map<Id,SBQQ__Subscription__c> mapTriggerNew){        
        updateContractEndDate(lstTriggerNew);
        updateProductMix(lstTriggerNew, mapTriggerOld, mapTriggerNew);
    }
    
    /*
     * Handle After Delete trigger
     */
    public static void handleAfterDelete(List<SBQQ__Subscription__c> lstTriggerOld){
        updateProductMix(lstTriggerOld, null, null);
    }

     /*
     * Handle After Undelete trigger
     */
    public static void handleAfterUndelete(List<SBQQ__Subscription__c> lstTriggerNew){
        updateProductMix(lstTriggerNew, null, null);
    }
    
    /*
* To Update a custom date field:Amended_End_Date__c on the Contract object
* based on the end dates of Subscription
*/
    public static void updateContractEndDate(List<SBQQ__Subscription__c> lstTriggerNew){    
        // GAM.CreateLogs('SubscriptionTriggerHandler', lstTriggerNew, 'lstTriggerNew: ');
        // create a map of Contract id and Contact Object  
        map<id,contract> MapIdWiseContracts = new map<id,contract>();
        //  create a set of Id, setOfContractsId
        set<string> setOfContractsId = new set<string>();
        // create a list of Contracts for update the conracts   
        List<contract> lstContractsForUpdate = new List<contract>();
        // create flags to denote the renewal types on the subscriptions
        Integer intSupport = 0;
        Integer intSubscription = 0;
        Integer intDaaS = 0; //<T02>
        Boolean foundMatch = false;

        // play a for loop on trigger.new and check if SBQQ__Contract__c field not null then add contract Id to the set   
        for(SBQQ__Subscription__c oSubscription : lstTriggerNew){
            if(oSubscription.SBQQ__Contract__c != null){
                setOfContractsId.add(oSubscription.SBQQ__Contract__c);
            }
        }
        // play a for loop on list of contracts where Id In setOfContractsId    
        for(contract oContract : [Select Id,Amended_End_Date__c,EndDate,Status,Renewal_Type__c,SBQQ__RenewalForecast__c,SBQQ__RenewalOpportunityStage__c,SBQQ__RenewalOwner__c,SBQQ__RenewalOpportunityRecordTypeId__c from Contract where Id IN : setOfContractsId]){
            // put the values in map  
            MapIdWiseContracts.put(oContract.Id,oContract); 
        }
        // play a for loop on  trigger.new and get the contract from map, 
        // and check the conditions for update the contract Amended_End_Date__c and
        // add updated contract to the list for update. 
        for(SBQQ__Subscription__c oSubscription : lstTriggerNew){
            if(MapIdWiseContracts.containsKey(oSubscription.SBQQ__Contract__c)){
                contract objContract = MapIdWiseContracts.get(oSubscription.SBQQ__Contract__c);
                if((objContract.Amended_End_Date__c == null ||
                    oSubscription.SBQQ__OptionLevel__c  == null) && 
                   oSubscription.SBQQ__EndDate__c > objContract.EndDate){
                       objContract.Amended_End_Date__c = oSubscription.SBQQ__EndDate__c ;
                       lstContractsForUpdate.add(objContract); 
                   } 
            }
        } 
        // Commented below logic of Renewal Type assignment since the logic is changed. Refer JIRA - 11149
        /*
        // Only perform this action on after insert        
        if (System.Trigger.isInsert && System.Trigger.isAfter) {
            // Retrieve all related Subscription records to the Contracts to parse through and populate the renewal values on
            // This could be an amendment and only one line is passed in, hence the query
            List<SBQQ__Subscription__c> subscriptionList = [SELECT Id, Name, Subscription_Renewal_Type__c,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c in: setOfContractsId];
            for(Contract contractL : MapIdWiseContracts.values()) { 
                //Add counter here
                for(SBQQ__Subscription__c oSubscription2 : subscriptionList) {
                    if(MapIdWiseContracts.containsKey(oSubscription2.SBQQ__Contract__c)) {
                        if(oSubscription2.Subscription_Renewal_Type__c!=null && oSubscription2.Subscription_Renewal_Type__c.equals('Support')){ // added null check <T01>
                            //if the condition is met the counter increases its value
                            intSupport=intSupport+1;
                        }
                        else if(oSubscription2.Subscription_Renewal_Type__c!=null && oSubscription2.Subscription_Renewal_Type__c.equals('Subscription')){ //added null check <T01>
                            //if the condition is met the counter increases its value
                            intSubscription=intSubscription+1;
                        }
                        //<T02>
                        else if(oSubscription2.Subscription_Renewal_Type__c!=null && oSubscription2.Subscription_Renewal_Type__c.equals('DaaS')){
                            intDaaS += 1;
                        }   
                        //</T02>                                     
                    }
                }
                // Cannot add two of the same Contract to the list so need to see if the list already contains the Contract record
                for (Contract singleContract: lstContractsForUpdate) {
                    // Matched the contract in the list
                    if(singleContract.id == contractL.id) {
                        foundMatch = true;
                        //assign the values from Renewal Type and Renewal Owner depending on the conditions                        
                        if(intSupport>=1){
                            setContractRenewalValues(singleContract, 'Support', System.Label.Support_Renewal_Owner);
                        }
                        else if(intSupport<1 && intSubscription>=1){
                            setContractRenewalValues(singleContract, 'Subscription', System.Label.Subscription_Renewal_Owner);
                        }
                        //<T02> Added for the else condition
                        else if(intSupport<1 && intSubscription<1 && intDaaS>=1){
                            setContractRenewalValues(singleContract, 'DaaS', System.Label.DaaS_Renewal_Owner);
                        }
                        else{
                            setContractRenewalValues(singleContract, null, null);
                        }
                        //</T02>
                    }                
                }
                if(!foundMatch) {
                    //assign the values from Renewal Type and Renewal Owner depending on the conditions
                    if(intSupport>=1){
                        setContractRenewalValues(contractL, 'Support', System.Label.Support_Renewal_Owner);
                    }
                    else if(intSupport<1 && intSubscription>=1){
                        setContractRenewalValues(contractL, 'Subscription', System.Label.Subscription_Renewal_Owner);
                    }
                    //<T02> Added for the else condition
                    else if(intSupport<1 && intSubscription<1 && intDaaS>=1){
                        setContractRenewalValues(contractL, 'DaaS', System.Label.DaaS_Renewal_Owner);
                    }
                    else{
                        setContractRenewalValues(contractL, null, null);
                    }
                    //</T02>
                    // Add the non-matched contract to the list
                    lstContractsForUpdate.add(contractL);                      
                }
                foundMatch = false;
                intSupport = 0;
                intSubscription = 0;
                intDaaS = 0;
            } 
        }   
    */
        // check the lstContractsForUpdate size before update 
        if(lstContractsForUpdate.size() > 0){
            try {
                update lstContractsForUpdate;  
            }
            catch(Exception e) {
                GAM.CreateLogs('Error from SubscriptionTriggerHandler while updating Contracts', String.valueOf(e.getMessage()));
            }
        }
        GAM.InsertDebugLogs();
    }
    
    //Commented below method for JIRA 11149 - since the Renewal Type and Renewal Owner assignment logic is changed
    /*
    public static void setContractRenewalValues(Contract con, String renewalType, String renewalOwner) {
        con.SBQQ__RenewalOpportunityRecordTypeId__c = System.Label.Opportunity_Renewal_Record_Type_Id;         
        con.Renewal_Type__c=renewalType;
        con.SBQQ__RenewalOwner__c = renewalOwner;
        con.Status = 'Activated';
        con.SBQQ__RenewalOpportunityStage__c = System.Label.Opportunity_Stage_Initiated;
    }
  */
    
    /*
    method Name : updateAssetLookup,
    * @param New Inserted Subscriptions
    * @return return-NA
    * @throws exception - NA
    * to udpate related assets subscriptions with newly created subscription.
    */   
    public static void updateAssetLookup(List<SBQQ__Subscription__c> lstTriggerNew){
        //Declaring the variables
        Set<Id> relatedAssetQuoteLineIds = new Set<Id>();
        Map<Id, List<Asset>> subscriptionToRelatedAssetsMap = new Map<Id, List<Asset>>();
        Map<Id, List<Asset>> quoteLineToRelatedAssetsMap = new Map<Id, List<Asset>>();
        Map<Id, Asset> updateFinalAssetMap = new Map<Id, Asset>();
        
        //Get all the related Quote Line ids
        for(SBQQ__Subscription__c asubscription : lstTriggerNew){
            if(asubscription.SBQQ__Quantity__c > 0){
                if(asubscription.SBQQ__QuoteLine__c != null){
                    relatedAssetQuoteLineIds.add(asubscription.SBQQ__QuoteLine__c);
                }
            }
        }
        
        //Create a map with quote line id and related assets.
        for(Asset assets : [SELECT Id, SBQQ__CurrentSubscription__c, SBQQ__QuoteLine__c FROM Asset WHERE SBQQ__QuoteLine__c IN: relatedAssetQuoteLineIds ]){
            if(quoteLineToRelatedAssetsMap.containsKey(assets.SBQQ__QuoteLine__c)){
                quoteLineToRelatedAssetsMap.get(assets.SBQQ__QuoteLine__c).add(assets);
            }
            else{
                List<Asset> assetList = new List<Asset>();
                assetList.add(assets);
                quoteLineToRelatedAssetsMap.put(assets.SBQQ__QuoteLine__c, assetList);
            }
        }

        //Create a map with Subscription id and related assets
        for(SBQQ__Subscription__c parentSubscription : lstTriggerNew){
            if(parentSubscription.SBQQ__Quantity__c > 0 && quoteLineToRelatedAssetsMap.containsKey(parentSubscription.SBQQ__QuoteLine__c)){
                if(subscriptionToRelatedAssetsMap.containsKey(parentSubscription.Id)){
                    subscriptionToRelatedAssetsMap.get(parentSubscription.Id).addAll(quoteLineToRelatedAssetsMap.get(parentSubscription.SBQQ__QuoteLine__c));
                }
                else{
                    subscriptionToRelatedAssetsMap.put(parentSubscription.Id, quoteLineToRelatedAssetsMap.get(parentSubscription.SBQQ__QuoteLine__c));
                }
            }
        }

        //Update the assets current suscription with new subscription
        for(Id keySubscription : subscriptionToRelatedAssetsMap.keyset()){
            for(Asset updateAsset : subscriptionToRelatedAssetsMap.get(keySubscription)){
                updateAsset.SBQQ__CurrentSubscription__c = keySubscription;
                updateFinalAssetMap.put(updateAsset.Id, updateAsset);
            }
        }
        
        //Perform the DML
        if(updateFinalAssetMap != null && updateFinalAssetMap.size() > 0){
            update updateFinalAssetMap.values();
        }
    }
    
    /*
* <T03>
method Name : updateProductMix,
* @param Inserted,Updated,Deleted,Undeleted Subscriptions
* @return return-NA
* @throws exception - NA
* to update the product mix checkboxes - JIRA 11149.
*/   
    public static void updateProductMix(List<SBQQ__Subscription__c> lstTrigger, 
                                        Map<Id,SBQQ__Subscription__c> mapTriggerOld, 
                                        Map<Id,SBQQ__Subscription__c> mapTriggerNew)
    {
        //  Create a set of Id, setOfContractsId
        Set<String> setOfContractsId = new Set<String>();
        Set<String> setOfSplitContractsId = new Set<String>();
        Set<Contract> setOfSplitContracts = new Set<Contract>();
        // Create a list to update Contract
        List<Contract> listUpdateContract = new List<Contract>();
        // Create a Map to check Subscription list Products for each Contract
        Map<Id,List<SBQQ__Subscription__c>> mapContractToRelatedSubscriptionLines = 
                            new Map<Id,List<SBQQ__Subscription__c>>();
        Integer intSupportCount = 0;
        Integer intICareCount = 0;
        Integer intDaasCount = 0;
        Integer intNotDaaSCount = 0;
        Boolean isNotOneTime = false;
        Boolean isSplitContract = false;
        List<String> listExcProdFamilyDaas = new List<String>();
        List<String> listIncBusUnitDaas = new List<String>();
        
        //Get the List of Product Family and Business Unit to check for DaaS Product
        listExcProdFamilyDaas = Label.DaaSExcludeProdFamily.split(',');
        listIncBusUnitDaas = Label.DaaSIncudeBusUnit.split(',');
        Set<String> setIncBusUnitDaas = new Set<String>();
        setIncBusUnitDaas.addAll(listIncBusUnitDaas);
        Set<String> setExcProdFamilyDaas = new Set<String>();
        setExcProdFamilyDaas.addAll(listExcProdFamilyDaas);
    Set<Id> setOfICareProductWrapper = new Set<Id>();
        
        // getAll Icare Wrapper Bundler products.
        for(SBQQ__ProductOption__c option : [SELECT id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c  
                                             FROM SBQQ__ProductOption__c 
                                             WHERE SBQQ__ConfiguredSKU__r.External_Id__c = :Label.Additional_Support_Services_External_Id]){
              setOfICareProductWrapper.add(option.SBQQ__ConfiguredSKU__c);
              setOfICareProductWrapper.add(option.SBQQ__OptionalSKU__c); 
        }
        
        // play a for loop on trigger.new and check if SBQQ__Contract__c field not null then add contract Id to the set   
        for(SBQQ__Subscription__c oSubscription : lstTrigger){
            if(oSubscription.SBQQ__Contract__c != null){
                setOfContractsId.add(oSubscription.SBQQ__Contract__c);
            }
        }
        //Check if the Contract Id is modified (For Split Contract). If it is split contract then add the Original Contract Id to ContractList 
        //to re-evaluate the Product Mix Type
        if(mapTriggerNew != null)
        {
            for(Id subscriptionId : mapTriggerNew.keyset())
            {
                if(mapTriggerOld.get(subscriptionId).SBQQ__Contract__c != mapTriggerNew.get(subscriptionId).SBQQ__Contract__c)
                {
                    setOfContractsId.add(mapTriggerOld.get(subscriptionId).SBQQ__Contract__c);
                    setOfSplitContractsId.add(mapTriggerOld.get(subscriptionId).SBQQ__Contract__c);
                }
            }
            if(setOfSplitContractsId.size() >0){ 
                isSplitContract = true;
            }
        }       
        
        Map<Id,Contract> mapContract = new Map<Id,Contract>([SELECT Id, (SELECT Id, SBQQ__Product__r.Name,
                                                                         SBQQ__Product__r.Forecast_Product__c, SBQQ__Product__r.Product_Family__c,
                                                                         SBQQ__Product__r.Business_Unit__c, SBQQ__Product__r.SBQQ__SubscriptionType__c, 
                                                                         SBQQ__Contract__c FROM SBQQ__Subscriptions__r) 
                                                             FROM Contract WHERE Id IN :setOfContractsId]);
        //Create a map with Contract Id and related Subscription Lines.
        if(mapContract.size() >0)
        {
            for(Contract objCon : mapContract.values())
            {
                if(objCon.SBQQ__Subscriptions__r != null)
                {                       
                    mapContractToRelatedSubscriptionLines.put(objCon.Id,objCon.SBQQ__Subscriptions__r);                    
                }
                else
                {
                    mapContractToRelatedSubscriptionLines.put(objCon.Id,null);
                }
            }
        }     
        if(mapContractToRelatedSubscriptionLines.size() >0)
        {
            //<SALESRT-14100> : Added SBQQ__Evergreen__c field
            for(Contract objContract : [SELECT Id,Business_Model__c,Status,SBQQ__RenewalOpportunityRecordTypeId__c,SBQQ__Evergreen__c FROM Contract 
                                        WHERE Id IN :mapContractToRelatedSubscriptionLines.keyset()])
            {
                if(mapContractToRelatedSubscriptionLines.get(objContract.Id).size() >0)
                {
                    for(SBQQ__Subscription__c objSubscription: mapContractToRelatedSubscriptionLines.get(objContract.Id))
                    {  
                        if(objSubscription.SBQQ__Product__c != null)
                        {
                            if(setOfICareProductWrapper.contains(objSubscription.SBQQ__Product__c))
                            {
                                intICareCount++;
                            }
                            if(objSubscription.SBQQ__Product__r.Forecast_Product__c == Label.Product2_Product_Family_Support)
                            {
                                intSupportCount++;
                            }
                            
                            //Exclude subscription lines from the contract with Product Family IN [Support, Services, Other] 
                            if(!setExcProdFamilyDaas.contains(objSubscription.SBQQ__Product__r.Product_Family__c))
                            {
                                //ALL remaining subscription lines should have products with Business Unit IN (Data as a Service, Address Doctor)
                                if(setIncBusUnitDaaS.contains(objSubscription.SBQQ__Product__r.Business_Unit__c))
                                {
                                    intdaaSCount++;
                                }
                            }    
                            else
                            {
                                intNotDaaSCount++;
                            }
                            
                            if(objSubscription.SBQQ__Product__r.SBQQ__SubscriptionType__c != Label.One_Time)
                            {
                                isNotOneTime = true;
                            }
                        }
                        //When Product is empty for Subscription Lines
                        else
                        {
                            intSupportCount = 0;
                            intdaaSCount = 0;
                            intNotDaaSCount = 0;
                            isNotOneTime = true;
                        }
                    }
                }
                //When there is no Subscription Lines for Contract
                else
                {
                    intSupportCount = 0;
                    intdaaSCount = 0;
                    intNotDaaSCount = 0;
                    intICareCount = 0;
                    isNotOneTime = true; 
                }
                if(mapContractToRelatedSubscriptionLines.get(objContract.Id).size() > 0 && 
                     intICareCount == mapContractToRelatedSubscriptionLines.get(objContract.Id).size()){
                    objContract.iCare__c = true;
                }else{
                    objContract.iCare__c = false;
                }
                if(intSupportCount>0)
                    objContract.Support__c = true;
                else
                    objContract.Support__c = false;
                
                if((mapContractToRelatedSubscriptionLines.get(objContract.Id).size() - intNotDaaSCount == intdaaSCount) && intdaaSCount>0)
                    objContract.DaaS__c = true;                 
                else
                    objContract.DaaS__c = false;
                
                if(!isNotOneTime)
                    objContract.One_Time__c = true;
                else
                    objContract.One_Time__c = false;
                
                if (System.Trigger.isInsert && System.Trigger.isAfter) 
                {
                    objContract.SBQQ__RenewalOpportunityRecordTypeId__c = System.Label.Opportunity_Renewal_Record_Type_Id; 
                    objContract.Status = 'Activated';
                    objContract.SBQQ__RenewalOpportunityStage__c = System.Label.Opportunity_Stage_Initiated;
                }
                listUpdateContract.add(objContract);
                intSupportCount = 0;
                intDaasCount = 0;
                intNotDaasCount = 0;
                isNotOneTime = false;
                intICareCount = 0;
            }
        }      
        //<T04 - On Contract Split>
        if(isSplitContract && listUpdateContract.size() >0){
            setOfSplitContracts.addAll(listUpdateContract);
            ContractTriggerHandler.assignRenewalTypeOwner(setOfSplitContracts, null, null, 'Update');
        }
        isSplitContract=false;
        //</T04>
        // check the lstContractsForUpdate size before update 
        if(listUpdateContract.size() > 0){
            try {                
                update listUpdateContract;  
            }
            catch(Exception e) {
                GAM.CreateExceptionRecords('SubscriptionTriggerHandler', 'exception in updateProductMix while updating Contract',e.getMessage());
            }
        }
    }
    //<T03>
}