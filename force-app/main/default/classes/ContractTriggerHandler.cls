/*
    Class:          ContractTriggerHandler
    
    @Author:        Sumitkumar Mittal
    @Created Date:  06/25/2019
    @Description:   handler class for Contract triggers
    */
    
    /*
    Change History
    *****************************************************************************************************************************************
    ModifiedBy          Date            Ticket No.          Requested By        Description                                                 Tag
    Sumit Mittal        06/25/2019      QCA-1287            2D Release          Method to populate Renewal and Amend                        T01
    pricebookIds.    
    Wasim               08/02/2020      SALESRT-11618       Keerthana           Renewal Routing getting failed due to 101 error CPQ Upgrade.
                                                                                Moving the logic from Process Builder to Trigger.           T02
    Wasim               02/21/2020      SALESRT-11534       Sunil Mirapuri      Routing Renewal Type to DaaS - Change Precedence of Support 
                                                                                and DaaS.                                                   T03
    Ambica              03/04/2020      SALESRT-11447       Sunil Mirapuri      Map Uplift Notes from Quote to Contract                     T04
    Wasim               02/03/2020      SALESRT-11196       Bhanu Prasad        Consolidate Renewal Opportunity OARR if multiple contracts 
                                                                                were co-termed and Closed Won.                              T05
    RamEsh M S          05/22/2020      SALESRT-11653       Chitra              Default Renewal Term as incremental of 12 using Contract 
                                                                                Term.                                                       T06 
    Sumit Mittal        05/29/2020      SALESRT-12063       Technical Debt      Updated the currency key in the mapping2Key                 T07
    RamEsh M S          07/23/2020      SALESRT-12261                           Adding condition to check for Primary flag on PriceBook and
                                                                                removing date check.                                        T08
    Ramya Ravi      20/08/2020          SALESRT-12112       Ramya Ravi          Renewal routing logic change                                T09
    
    Vignesh D           10/05/2020      F2A-224                                 Comment code that sets Entitlement Creation Status & Run    T10
                                                                                as part of the Asset Revamp             
    Chandana Gowda      11/11/2020      SALESRT-12290       Chitra              Added the logic to update timestamp on amendment of the     T11
                                                                                contract
                                                                                
    Anil Solanki    19-Feb-2021         Salesrt-12772       March Build         Remove condition to check for Is Primary when Assigning Renewal and Amend Pricebook.<T12>
    Ramya Ravi      01-Apr-2021         SALESRT-12220       April Build         Capture the user clicked 'Renewal Quoted' <SALESRT-12220>
    Ramya Ravi      03-May-2021         SALESRT-12976       May Build 21        Make "Default Renewal Contact Roles" to FALSE on Contract creation <SALESRT-12976>
    Chandana Gowda  19-Apr-2021         SALESRT-12957       May Build 21        Update the contract fields when co-term long order is contracted <SALESRT-12957>
    Chandana Gowda  10-Oct-2022         SALESRT-14100       payGo proj 22       Update the Renewal type to one-time for Evergreen Contracts <SALESRT-14100>
	Nishant Bansal  24-Apr-2023         SALESRT-13388       May Build       	Populate the Amendment Contracted date and trigger the Notification
	Sreerekha 		26-Jul-2023			SALESRT-15479		Aug Build			Modernization Credit Ledger  <SALESRT-15479>
*****************************************************************************************************************************************
    */
    
    public class ContractTriggerHandler{
        
        public static globalApexManager GAM = new globalApexManager();
        //<T02>
        //Variable to avoid calling the same method twice on Insert
        public static boolean boolInsert = false;
        //</T02>
        /*
    Method Name : handleBeforeInsert,
    * @param lstTriggerNew - list of new Contract
    * @return return-void
    * @throws exception - NA
    
    This method call from 'ContractBeforeInsert' Trigger on Contract Object
    */
        
        public static void handleBeforeInsert(List<Contract> lstTriggerNew){
            UpdateDefaultRenewalContactRoles(lstTriggerNew);     //<SALESRT-12976>
            updateRenewAmendPricebookIds(lstTriggerNew);
              UpdateModernizationOpportunity(lstTriggerNew); //SALESRT-15479
           //<T10> updateAssetEntitlementFields(lstTriggerNew);
        }
        
         // //<SALESRT-12976> starts
    /*
    Method Name : UpdateDefaultRenewalContactRoles,
    * @param lstTriggerNew - list of new Contract
    * @return return-void
    * @throws exception - NA

    This method call from 'ContractBeforeInsert' Trigger on Contract Object to update Default Renewal Contact Roles to false upon contract creation
    */
      public static void UpdateDefaultRenewalContactRoles(List<Contract> lstTriggerNew){         
    for(Contract li: lstTriggerNew)
        {
            li.SBQQ__DefaultRenewalContactRoles__c = false;           
        }     
      }    
    //<SALESRT-12976> ends 
        
        //<T02>
        /*
    Method Name : handleAfterInsert,
    * @param lstTriggerNew - list of new Contract
    * @return return-void
    * @throws exception - NA
    
    This method call from 'ContractAfterInsert' Trigger on Contract Object
    */
        public static void handleAfterInsert(List<Contract> lstTriggerNew)
        {
            boolInsert = true;
          
        }
        //</T02>
      
        //<T02>
    //<SALESRT-15479>
    /*
    Method Name : UpdateModernizationOpportunity,
    * @param lstTriggerNew - list of new Contract
    * @return return-void
    * @throws exception - NA

    This method call from 'ContractBeforeInsert' Trigger on Contract Object to update Modernization Opportunity if credit has been assigned
    */
        public static void UpdateModernizationOpportunity(List<Contract> lstTriggerNew){
            Set<Id> setOpportunityIds = new Set<Id>();
            
            for(Contract con : lstTriggerNew){
                if(con.SBQQ__Opportunity__c != null){
                      setOpportunityIds.add(con.SBQQ__Opportunity__c);
                }               
            }
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
            if(setOpportunityIds.size() > 0){
            mapOpportunity = new Map<Id,Opportunity>([select Id, SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.Modernization_Opportunity__c from Opportunity where Id IN:setOpportunityIds]);
            	}
            for(Contract con : lstTriggerNew){
                if(mapOpportunity.containsKey(con.SBQQ__Opportunity__c) && mapOpportunity.get(con.SBQQ__Opportunity__c).SBQQ__RenewedContract__r.Modernization_Opportunity__c != null){
                   con.Modernization_Opportunity__c = mapOpportunity.get(con.SBQQ__Opportunity__c).SBQQ__RenewedContract__r.Modernization_Opportunity__c;
                 }
                   }
            
        }
     //<SALESRT-15479> Ends
           /*
    Method Name : handleBeforeUpdate,
    * @param lstTriggerNew - list of new Contract, mapTriggerNewMap - Trigger.Newmap, mapTriggerOldMap - Trigger.OldMap
    * @return return-void
    * @throws exception - NA
    
    This method call from 'ContractBeforeUpdate' Trigger on Contract Object
    */
        public static void handleBeforeUpdate(List<Contract> lstTriggerNew, Map<Id,Contract> mapTriggerNewMap, Map<Id,Contract> mapTriggerOldMap)
        {
            //Holds the set of Contracts from Trigger
            Set<Contract> setContracts = new Set<Contract>();
            Map<Id,Id> mapContractOrderIds = new Map<Id,Id>(); //<SALESRT-12957>
            //Loop through the Contract Trigger List
            for(Contract objContract : lstTriggerNew)
            {
                //On amend update the timestamp for contract status update <T11>
                if(objContract.SBQQ__Order__c != null && objContract.SBQQ__Order__c != mapTriggerOldMap.get(objContract.Id).SBQQ__Order__c){
                    objContract.Contract_Status_Trigger_Time__c = System.now();
                    objContract.Amendment_Contracted_Date_Time__c = System.now();
                    //objContract.Amendment_Contracted_Notification__c = true;
                    mapContractOrderIds.put(objContract.Id,objContract.SBQQ__Order__c);//<SALESRT-12957>
                }

                //Add to set if Renewal Forecast is FALSE and if any of these fields are edited: Business Model, Renewal Type and Product Mix fields - OneTime,Support,DaaS
                if(!objContract.SBQQ__RenewalForecast__c && (mapTriggerNewMap.get(objContract.Id).Business_Model__c != mapTriggerOldMap.get(objContract.Id).Business_Model__c
                                                             || mapTriggerNewMap.get(objContract.Id).One_Time__c != mapTriggerOldMap.get(objContract.Id).One_Time__c
                                                             || mapTriggerNewMap.get(objContract.Id).Support__c != mapTriggerOldMap.get(objContract.Id).Support__c  
                                                             || mapTriggerNewMap.get(objContract.Id).DaaS__c != mapTriggerOldMap.get(objContract.Id).DaaS__c
                                                             || mapTriggerNewMap.get(objContract.Id).iCare__c != mapTriggerOldMap.get(objContract.Id).iCare__c
                                                             || mapTriggerNewMap.get(objContract.Id).Renewal_Type__c != mapTriggerOldMap.get(objContract.Id).Renewal_Type__c))
                {
                    setContracts.add(objContract);
                }
                
                //<T05>
                //Check if the Renewal Opportunity lookup in Contract is changed and it should not be changed from empty. Renewal Opportunity will be empty for the Contract before Renewal Forecast is checked.
                //Based on Renewal_Opportunity_Changed_Date__c field update, the Non Master Renewal Opportunity stage is set to Duplicate - ICS Job
                if(!String.IsBlank(mapTriggerOldMap.get(objContract.Id).SBQQ__RenewalOpportunity__c) &&
                   mapTriggerNewMap.get(objContract.Id).SBQQ__RenewalOpportunity__c != mapTriggerOldMap.get(objContract.Id).SBQQ__RenewalOpportunity__c)           
                {
                    objContract.Renewal_Opportunity_Changed_Date__c = System.now();
                }
                //Do not update the Stage to 'Duplicate' in ICS Job when the Renewal Forecast is changed to False. SALESRT - 11884 bug fix
                if(!objContract.SBQQ__RenewalForecast__c && objContract.Renewal_Opportunity_Changed_Date__c != null)
                {
                    objContract.Renewal_Opportunity_Changed_Date__c = null;
                }
                //</T05>
                /*//<T06>
                if(mapTriggerNewMap.get(objContract.Id).SBQQ__RenewalTerm__c != mapTriggerOldMap.get(objContract.Id).SBQQ__RenewalTerm__c || mapTriggerNewMap.get(objContract.Id).ContractTerm != mapTriggerOldMap.get(objContract.Id).ContractTerm)
                    objContract.SBQQ__RenewalTerm__c = math.mod(objContract.ContractTerm,12) != 0 ? 12 : objContract.ContractTerm; //</T06>*/
                    
                //<SALESRT-12220>
                if(objContract.SBQQ__RenewalQuoted__c &&
                  objContract.SBQQ__RenewalQuoted__c != mapTriggerOldMap.get(objContract.Id).SBQQ__RenewalQuoted__c) {
                    objContract.Renewal_Quote_Owner__c = UserInfo.getUserId();
                }//</SALESRT-12220>
            }
            //If the Contract set is not empty and if the Trigger Event is not Insert
            if(setContracts.size()>0 && !boolInsert){
                    assignRenewalTypeOwner(setContracts,mapTriggerNewMap,mapTriggerOldMap,'Update');
            } 
            if(!mapContractOrderIds.isEmpty()){
                updateOnAmendContract(mapContractOrderIds,mapTriggerNewMap);
                updateAmendmentNotification(mapContractOrderIds);
            }    
        }
        
        /*
        Method Name : UpdateDefaultRenewalContactRoles,
        * @param lstTriggerNew - list of new Contract
        * @return return-void
        * This method call from 'ContractAfterUpdate' Trigger on Contract Object to to call the notification framework.
        */
        public static void handleAfterUpdate(List<Contract> lstTriggerNew, Map<Id,Contract> mapTriggerNewMap, Map<Id,Contract> mapTriggerOldMap) {    
            callNotificationService(lstTriggerNew, mapTriggerOldMap);
        }
    //---------------------------------------------------------------------------------//<SALESRT-12957>
    /*
    Method Name : updateOnAmendContract
    * @param lstAmendContract - list of new Contract, mapTriggerOldMap - Trigger.OldMap
    * @return return-void
    * @throws exception - NA
    To update the contract fields when amended order is contracted
    */
    public static void updateOnAmendContract(Map<Id,Id> mapContractOrderIds,Map<Id,Contract> mapTriggerNewMap){
        //Getting order and quote details
        Map<Id,order> mapOrder = new Map<Id,order>([SELECT Id,Co_Term_Long__c,SBQQ__Quote__r.SBQQ__StartDate__c ,SBQQ__Quote__r.SBQQ__EndDate__c FROM order WHERE Id IN :mapContractOrderIds.values()]);
        List<Opportunity> lstRenewalOptytoUpdate = new List<Opportunity>();
        
        for(Id contractId:mapContractOrderIds.keyset()){
            Contract contractRec = mapTriggerNewMap.get(contractId);
            Order orderRec = mapOrder.get(mapContractOrderIds.get(contractId));
            //If order co-term long = true
            if(orderRec.Co_Term_Long__c){
                mapTriggerNewMap.get(contractId).EndDate = orderRec.SBQQ__Quote__r.SBQQ__EndDate__c;
                mapTriggerNewMap.get(contractId).ContractTerm = contractRec.StartDate.monthsBetween(orderRec.SBQQ__Quote__r.SBQQ__EndDate__c);
                mapTriggerNewMap.get(contractId).SBQQ__RenewalTerm__c = orderRec.SBQQ__Quote__r.SBQQ__StartDate__c.monthsBetween(orderRec.SBQQ__Quote__r.SBQQ__EndDate__c);
                //updating close date on renewal opty
                if(contractRec.SBQQ__RenewalOpportunity__c != null){
                    Opportunity renOpp = new Opportunity(Id = contractRec.SBQQ__RenewalOpportunity__c);
                    renOpp.CloseDate = orderRec.SBQQ__Quote__r.SBQQ__EndDate__c;
                    lstRenewalOptytoUpdate.add(renOpp);
                }
            }            
        }
        if(!lstRenewalOptytoUpdate.isEmpty()){
            try{
                SBQQ.TriggerControl.disable();
                    Database.SaveResult[] sr =  Database.update(lstRenewalOptytoUpdate,false);
                SBQQ.TriggerControl.enable();

                
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('Error in updating Renewal Opty', 'updateOnAmendContract',e.getMessage());            
            }             
        }
    }
    //-----------------------------------------------------------------------------------------------------------------</SALESRT-12957>        
           /*
    Method Name : updateAssetEntitlementFields,
    * @param listContract - list of new Contract
    * @return return-void
    * @throws exception - NA
      To initiate Entitlement values on Contract Object
    */
        public static void updateAssetEntitlementFields(List<Contract> listContract)
        {
            //Loop through the List of Contract
            for(Contract ObjContract: listContract)
            {
                objContract.Entitlement_Creation_Status__c = 'Initiated';
                objContract.Entitlement_Creation_Run__c = System.now() - 0.036;
            }
        }
        /*
    Method Name : assignRenewalTypeOwner,
    * @param contractSet - set of new Contract,mapNewContracts - Trigger.NewMap,  mapOldContracts- Trigger.OldMap, TriggerType - Type of Trigger(Insert,Update)
    * @return return-void
    * @throws exception - NA
      To assign Renewal Type based on Renewal Routing Logic - Moved from Process Builder
    */
        public static void assignRenewalTypeOwner(Set<Contract> contractSet,Map<Id,Contract> mapNewContracts, Map<Id,Contract> mapOldContracts, string TriggerType){
            
            //Check if Renewal Type is changed Manually.Otherwise use Routing Table
            Boolean isUpdated = false;
            //Holds the Business Model of Contract
            String strBusinessModel = '';
            //Map of Label Name and Renewal Type Mapping Custom metadata
            Map<String,RenewalTypeMapping__mdt> mapRenewalTypeMapping = new Map<String,RenewalTypeMapping__mdt>();
            //Map of Label Name and Renewal Owner Mapping Custom metadata
            Map<String,RenewalOwnerMapping__mdt> mapRenewalOwnerMapping = new Map<String,RenewalOwnerMapping__mdt>();
            //Get the Mappings of Renewal Owner, Renewal Forecast from Renewal Owner Mapping Custom Metadata
            for(RenewalOwnerMapping__mdt objRenewalMapping: [SELECT MasterLabel,RenewalForecast__c, RenewalOwner__c FROM RenewalOwnerMapping__mdt])
            {
                mapRenewalOwnerMapping.put(objRenewalMapping.MasterLabel,objRenewalMapping);            
            }
            //Get the Mappings of Business Model, Renewal Type from Renewal Type Mapping Custom Metadata
            for(RenewalTypeMapping__mdt objRenewalMapping: [SELECT MasterLabel,BusinessModel__c,RenewalType__c FROM RenewalTypeMapping__mdt])
            {
                mapRenewalTypeMapping.put(objRenewalMapping.MasterLabel,objRenewalMapping);
            }
            //Create a List of Contract to update
            List<Contract> listUpdateContract = new List<Contract>();
            //Create a Map of Contract Id and Quote Business Model
            Map<Id,String> mapContractIdToQuoteBusModel = new Map<Id,String>();
            //Create a Map of Quote Id and Contract Id
            Map<Id,List<Id>> mapQuoteIdToContractId = new Map<Id,List<Id>>();
            //Holds the set of Contract for Insert/Update
            Set<Contract> setContractAll = new Set<Contract>();
            // On Contract Insert, create a Map of Contract Id with Quote's Business Model
            if(triggerType == 'Insert')
            {
                //Get the Default values to be assigned on Contract
                for(Contract objContract: [SELECT Id,SBQQ__Quote__c,iCare__c,One_Time__c,DaaS__c,Support__c,Renewal_Type__c,Business_Model__c,EndDate,SBQQ__Quote__r.RecordtypeId,SBQQ__Quote__r.CurrencyIsoCode,
                                           SBQQ__Quote__r.Business_Model__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.New_Org_Opportunity_Number__c,SBQQ__RenewalTerm__c,ContractTerm,SBQQ__Evergreen__c /**<SALESRT-14100> Fetch Evergreen field */
                                           FROM Contract WHERE Id IN :contractSet])
                {
                    //Form a map of Quote Id and Contract Id
                    if(mapQuoteIdToContractId.containsKey(objContract.SBQQ__Quote__c)){
                        mapQuoteIdToContractId.get(objContract.SBQQ__Quote__c).add(objContract.Id);
                    }
                    else{
                        mapQuoteIdToContractId.put(objContract.SBQQ__Quote__c,new List<Id>{objContract.Id});
                    }
                    setContractAll.add(objContract);
                }
                //Get the Business Model from Quote
                for(SBQQ__Quote__c objQuote: [SELECT Id,Business_Model__c FROM SBQQ__Quote__c WHERE Id IN :mapQuoteIdToContractId.keySet()])
                {
                    //If the map of Quote Id and Contract Id is not Empty
                    if(mapQuoteIdToContractId.size() >0){
                        //Form a Map of Contract Id and Quote's Business Model
                        for(Id contractId : mapQuoteIdToContractId.get(objQuote.Id)){
                            mapContractIdToQuoteBusModel.put(contractId,objQuote.Business_Model__c);
                        }
                    }
                }
            }
            // On Contract update, take the Business Model from Contract itself
            else
            {
                setContractAll.addAll(contractSet);
            }
            
            //If the map from Custom Metadata are not Empty
            if(mapRenewalOwnerMapping.size() >0 && mapRenewalTypeMapping.size() >0){
                //Loop through the set of Contracts
                for(Contract objContract : setContractAll)
                {
                    //On Contract Insert
                    if(triggerType == 'Insert')
                    {
                        //If Contract's Business Model is Blank then assign from Quote's Business Model
                        if(String.IsBlank(objContract.Business_Model__c)){
                        strBusinessModel = mapContractIdToQuoteBusModel.get(objContract.Id);
                        }
                        //If Contract's Business Model is not Blank, then take the Business Model from Contract itself.
                        else{
                          strBusinessModel = objContract.Business_Model__c;
                        }
                        //Assign Default values for Contract
                        if(objContract.SBQQ__Quote__r !=null){
                            objContract.Business_Model__c = objContract.SBQQ__Quote__r.Business_Model__c;
                            objContract.CurrencyIsoCode = objContract.SBQQ__Quote__r.CurrencyIsoCode;
                            objContract.SBQQ__Quote__r.RecordtypeId = Label.Contracted_Quote_Record_Type;
                        }
                        objContract.Amended_End_Date__c = objContract.EndDate;
                        objContract.OwnerExpirationNotice = '120';
                        objContract.SBQQ__AmendmentOpportunityStage__c = Label.Opportunity_Stage_Qualified;
                        //objContract.SBQQ__DefaultRenewalContactRoles__c = true; //<SALESRT-12976>
                        objContract.SBQQ__PreserveBundleStructureUponRenewals__c = true;
                        objContract.SBQQ__RenewalOpportunityRecordTypeId__c = Label.Opportunity_Renewal_Record_Type_Id;
                        objContract.SBQQ__RenewalOpportunityStage__c = Label.Opportunity_Stage_Initiated;
                        //If Related Opportunity of Contract is not Empty and contains New Org Opportunity Number
                        if(objContract.SBQQ__Opportunity__c != null  && objContract.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c != null)
                            objContract.Name = 'Contract for Opportunity #'+ objContract.SBQQ__Opportunity__r.New_Org_Opportunity_Number__c.left(54);
                       // objContract.SBQQ__RenewalTerm__c = math.mod(objContract.ContractTerm,12) != 0 ? 12 : objContract.ContractTerm; //<T06>
                    }
                    //On Contract Update
                    else
                    {                    
                        strBusinessModel = objContract.Business_Model__c;
                        //Trigger.NewMap and Trigger.OldMap is not empty
                        if(mapNewContracts != null && mapOldContracts != null){     
                            //On Manual change of Renewal Type, assign the correct Renewal Owner
                            if(mapNewContracts.get(objContract.Id).Renewal_Type__c != null &&
                               mapNewContracts.get(objContract.Id).Renewal_Type__c != mapOldContracts.get(objContract.Id).Renewal_Type__c)
                            {                                
                                //If Renewal Type is not blank
                                if(String.isNotBlank(objContract.Renewal_Type__c)){
                                    listUpdateContract.addAll(updateRenewalForecastTypeandOwner(objContract,mapNewContracts.get(objContract.Id).Renewal_Type__c,mapRenewalOwnerMapping));          
                                    //updateRenewalForecastTypeandOwner(objContract,objContract.Renewal_Type__c,mapRenewalOwnerMapping);             
                                }
                                isUpdated = true;
                            }
                        }
                    }
                    //If it is not a Manual Renewal Type change, then assign the Renewal Type and Owner based on Routing Table 
                    if(!isUpdated)
                    {
                        //If Product Mix is OneTime
                        //<SALESRT-14100> : Added check for Evergreen contracts
                        if(objContract.SBQQ__Evergreen__c || objContract.One_Time__c)
                        {
                            objContract.Renewal_Type__c = mapRenewalTypeMapping.get('OneTime').RenewalType__c;
                        }
                        //If Business Model is POC, Product Fund EVAL
                        else if(mapRenewalTypeMapping.get(strBusinessModel) != null)
                        {
                            //Check the Label Name of Custom Metadata and Contract business Model to get the correct Renewal Type
                            if(mapRenewalTypeMapping.get(strBusinessModel).BusinessModel__c == strBusinessModel){
                                objContract.Renewal_Type__c = mapRenewalTypeMapping.get(strBusinessModel).RenewalType__c;
                            }
                        }
                        //If Business Model is Standard or Product Fund or Any
                        else
                        {
                            //If Business Model is Standard or Product Fund
                            if(strBusinessModel == 'Standard' || strBusinessModel == 'Product Fund'|| strBusinessModel == 'GSA')        // T09
                            {
                                /* <T03>
                                if(objContract.Support__c)
                                {
                                    strBusinessModel = strBusinessModel+' '+'Support';
                                }
                                else 
                                </T03>
                                */
                                //Precedence of DaaS and Support is changed - 11534
                                //If Product Mix is DaaS
                                if(objContract.DaaS__c)
                                {
                                    strBusinessModel = strBusinessModel+' '+'DaaS';
                                }
                                // If Product is ICare
                                else if(objContract.iCare__c)
                                {
                                    strBusinessModel = strBusinessModel+' '+'iCare';
                                }
                                // <T03>
                                // If Product Mix is Support
                                else if(objContract.Support__c)
                                {
                                    strBusinessModel = strBusinessModel+' '+'Support';
                                }
                                // </T03>
                                //If Product Mix is Support
                                else
                                {
                                    strBusinessModel = strBusinessModel+' '+'Any';
                                } 
                            }
                            //For all other Business Model
                            else{
                                strBusinessModel = 'Any';
                            }
                            
                            objContract.Renewal_Type__c = mapRenewalTypeMapping.get(strBusinessModel).RenewalType__c;
                            
                        }            
                        //assign the Renewal Owner
                        //updateRenewalForecastTypeandOwner(objContract,objContract.Renewal_Type__c,mapRenewalOwnerMapping);
                        listUpdateContract.addAll(updateRenewalForecastTypeandOwner(objContract,objContract.Renewal_Type__c,mapRenewalOwnerMapping));                
                    }
                    isUpdated = false;
                    strBusinessModel = '';
                }
            }
            //If the Trigger Event Type is Insert and Contract List is not Empty
            if(TriggerType == 'Insert' && listUpdateContract.size() >0){
                //update the Contract List
                update listUpdateContract;
            }
        }
        /*
    Method Name : updateRenewalForecastTypeandOwner,
    * @param contractSet - set of new Contract,strRenewalType - Renewal Type, mapRenewalOwnerMapping - Custom Metadata of Renewal Combinations
    * @return return-List<Contract>
    * @throws exception - NA
      To assign Renewal Owner based on Renewal Routing Logic - Moved from Process Builder
    */
        public static List<Contract> updateRenewalForecastTypeandOwner(Contract objContract,String strRenewalType,Map<String,RenewalOwnerMapping__mdt> mapRenewalOwnerMapping)
            //public static void updateRenewalForecastTypeandOwner(Contract objContract,String strRenewalType,Map<String,RenewalOwnerMapping__mdt> mapRenewalOwnerMapping)
        {
            //List of Contracts to update 
            List<Contract> listContract = new List<Contract>();
            //Assign the Renewal Owner and Renewal Forecast Trigger Time
            if(String.isNotBlank(strRenewalType)){
                objContract.SBQQ__RenewalOwner__c = mapRenewalOwnerMapping.get(strRenewalType).RenewalOwner__c;
                objContract.Renewal_Forecast_trigger_time__c = System.now();
            }
            listContract.add(objContract);
            return listContract;
        }   
        //</T02>
        
        /* <T01>
    Method Name : updateRenewAmendPricebookIds,
    * @param lstTriggerNew - list of new Contract
    * @return return-void
    * @throws exception - NA
    
    This method will update the renew and amend pricebook id fields on the Contract 
    so that if the new renewal or amend opportunity is created from the contract will 
    have new logic PricebookId populated.
    */
        static void updateRenewAmendPricebookIds(List<Contract> newContractsList){
            try{
                Map<String, set<id>> mapPBidOpptyIds = new Map<String, Set<id>>();
                Set<id> setOpptyIds = new Set<id>();
                Map<String, Id> mapKeyPricebookId = new Map<String, Id>();
                Map<String, Id> mapKeyCurrencyPricebookId = new Map<String, Id>();
                Map<Id,Contract> mapQuoteToContract = new Map<Id,Contract>(); //<T04>
                for(Pricebook_Assignment_Mapping__mdt countryBasedPricebook : [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, Pricebook_Id__c, Currency_ISO_Code__c FROM Pricebook_Assignment_Mapping__mdt]) {
                    String mappingKey = countryBasedPricebook.MasterLabel+';'+countryBasedPricebook.Currency_ISO_Code__c;
                    String mapping2Key = countryBasedPricebook.MasterLabel+';USD';                                                              
                    if(!mapKeyPricebookId.containsKey(mappingKey)) {
                        mapKeyPricebookId.put(mappingKey,countryBasedPricebook.Pricebook_Id__c);
                        //Added below logic to have a map of currency vs pricebookId as per the revised requirement of the JIRA
                        mapKeyCurrencyPricebookId.put(countryBasedPricebook.Currency_ISO_Code__c,countryBasedPricebook.Pricebook_Id__c);
                        mapKeyPricebookId.put(mapping2Key,countryBasedPricebook.Pricebook_Id__c);
                    }
                }
                
                for(Contract cntrct : newContractsList) {
                    //-------------------------- <T04>
                    // Get quoted from contract
                    mapQuoteToContract.put(cntrct.SBQQ__Quote__c,cntrct);  
                    //-----------------------</T04>
                    //<T12> Commented code : For new Contract the Renewal and Amend Pricebook should always come based on  Opportunity Currency Code and Account BillingCountry Mapping. 
                    /*
                    if(mapPBidOpptyIds.containsKey(cntrct.SBQQ__OpportunityPricebookId__c)) {
                        mapPBidOpptyIds.get(cntrct.SBQQ__OpportunityPricebookId__c).add(cntrct.SBQQ__Opportunity__c);
                    } else {
                        mapPBidOpptyIds.put(cntrct.SBQQ__OpportunityPricebookId__c, new Set<Id>{cntrct.SBQQ__Opportunity__c});
                    }
                    */
                    //<T12> Start
                    if(cntrct.SBQQ__Opportunity__c != null){
                        setOpptyIds.add(cntrct.SBQQ__Opportunity__c);
                    }
                    //<T12> END
                }
               
                //<T12> Commented code : For new Contract the Renewal and Amend Pricebook should always come based on  Opportunity Currency Code and Account BillingCountry Mapping.               
               
               /*
               DateTime checkCreatedDate = DateTime.valueOf((Label.contractPricebookCreatedDate).replace('T', ' '));
                for(Pricebook2 pb : [Select id from Pricebook2 where Id IN: mapPBidOpptyIds.keyset() AND /*CreatedDate <: checkCreatedDate*/ /*Primary__c = FALSE]) { //<T08>
                    String pbId = String.valueOf(pb.Id).substring(0, 15);
                    
                    if(mapPBidOpptyIds.containsKey(pbId) 
                       && mapPBidOpptyIds.get(pbId) != Null ) {
                           for(Id opttyId : mapPBidOpptyIds.get(pbId)) {
                               setOpptyIds.add(opttyId);
                               
                               
                           }
                       }
                }
                */
                if(setOpptyIds != null && !setOpptyIds.isEmpty()){
                    
                    map<Id, Opportunity> mapIdOpportunityRecord = new map<Id, Opportunity>([SELECT Id, CurrencyIsoCode, Account.BillingCountry FROM Opportunity Where id IN :setOpptyIds]);
                    
                    for(Contract cntrct : newContractsList){
                       if(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c) != NULL 
                           && mapIdOpportunityRecord.containsKey(cntrct.SBQQ__Opportunity__c) 
                           && mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).Account.BillingCountry != Null
                           && mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).Account.BillingCountry != '' 
                           && mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode != Null
                           && mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode != '') {
                               //Updated below if logic as per the revised logic in the requirement JIRA to check for the pricebooks
                               if(mapKeyPricebookId.containsKey(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).Account.BillingCountry.Left(40)+';'+mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode)) {
                                   cntrct.SBQQ__RenewalPricebookId__c = mapKeyPricebookId.get(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).Account.BillingCountry.Left(40)+';'+mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode);
                                   cntrct.SBQQ__AmendmentPricebookId__c = mapKeyPricebookId.get(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).Account.BillingCountry.Left(40)+';'+mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode);
                               } else if(mapKeyCurrencyPricebookId.containsKey(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode)) {
                                   cntrct.SBQQ__RenewalPricebookId__c = mapKeyCurrencyPricebookId.get(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode);
                                   cntrct.SBQQ__AmendmentPricebookId__c = mapKeyCurrencyPricebookId.get(mapIdOpportunityRecord.get(cntrct.SBQQ__Opportunity__c).CurrencyIsoCode);
                               }
                           }
                    }
                }
                
                //-------------------------- <T04>
    
                
                if(mapQuoteToContract != null && mapQuoteToContract.Keyset()!= null){
                    
                    For( SBQQ__Quote__c sbqqquote: [Select Id,Uplift_Notes__c from SBQQ__Quote__c where Id in : mapQuoteToContract.keyset()]){
                       
                       If(sbqqquote.Uplift_Notes__c!=null){
                      Contract con= mapQuoteToContract.get(sbqqquote.Id);
                      con.Uplift_Notes__c =sbqqquote.Uplift_Notes__c;
                       }
                    } 
                }
               //-------------------------- </T04>
    
            }
            Catch(Exception ex){
    
                GAM.CreateExceptionRecords('ContractTriggerHandler', 'Exception in updateRenewAmendPricebookIds method',ex.getMessage());
            }       
        }
        
        /*
        Method Name : updateAmendmentNotification,
        * @param mapContractOrderIds - map Of contract Id and order id
        * <SALESRT-13388>
        * This method call from 'ContractAfterUpdate' Trigger on Contract Object to to call the notification framework.
        */
        @future
        public static void updateAmendmentNotification(map<Id, Id> mapContractOrderIds) {
            list<Contract> contractList = new list<Contract>();
            for(Id contractId : mapContractOrderIds.keyset()) {
                Contract contract = new Contract(Id = contractId, Amendment_Contracted_Notification__c = true);
                contractList.add(contract);
            }
            
            if(contractList.size() > 0 ) {
                update contractList;
            }
        }
        
        /*
        Method Name : UpdateDefaultRenewalContactRoles,
        * @param lstTriggerNew - list of new Contract
        * <SALESRT-13388>
        * This method call from 'ContractAfterUpdate' Trigger on Contract Object to to call the notification framework.
        */
        private static void callNotificationService(list<Contract> lstTriggerNew, map<Id, Contract> oldMap) { 
            NotificationService.notify(trigger.new, oldMap);
        }
    }