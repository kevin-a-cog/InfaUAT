/*
    @created by       : MAHESH GANTI
    @created on       : DECEMBER 22 2020
    @Purpose          : Service level class to handle PSA-Project updates.
    @Testclass        : 
    @JIRA             : PSA-111
    @Tag              : T01   
 */
public without sharing class psa_om_AmmendOpportunityHandler {
    
    public static globalApexManager GAM = new globalApexManager();

    /**
    * Method called from PSA-Update Project Id on Contract Batc
    * @param parameter-  - list of filtered Contract records to process.
    * @return return-void
    * @throws exception - NA
    */
    public static void updateProjectIdOnContract(List<Contract> contToProcess){
        
        List<Contract> contractRecsToUpdate = new List<Contract>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Id> oppIdProjIdMap = new Map<Id,Id>();
        List<Contract> baseContractList = new List<Contract>([SELECT Id,Name,SBQQ__Opportunity__c,PSA_OM_Project__c 
                                                                FROM Contract
                                                                WHERE ID IN :contToProcess]);
        // first loop to get the Opportunities 
        for(Contract contRec : baseContractList){
            if(contRec.SBQQ__Opportunity__c <> null){
                oppIdSet.add(contRec.SBQQ__Opportunity__c); //Add the Opportunity on Contract.
            }
        }

        if(oppIdSet.size()>0){
            oppIdProjIdMap = getOppIdProjIdMap(oppIdSet); //get the Opportunity Id & Project Id Map.
        }

        // second loop to populate projec id on Contract record.
        for(Contract contRec : baseContractList){
            if(oppIdProjIdMap.containsKey(contRec.SBQQ__Opportunity__c)){
                contRec.PSA_OM_Project__c = oppIdProjIdMap.get(contRec.SBQQ__Opportunity__c);
                contractRecsToUpdate.add(contRec);
            }
        }

        if(contractRecsToUpdate.size()>0){
            try{
                Database.SaveResult[] contRecListToUpdate = Database.Update(contractRecsToUpdate, false);
                //update contractRecsToUpdate;
            }catch(Exception ex){
                GAM.CreateExceptionRecords('PSA-UPDATE PROJECT CONTRACT BATCH', 'Error in Updating Contracts',ex.getMessage());
            }
            
        }
    }

    /**
    * Method called from BEFORE INSERT OF OPPORTUNITY TRIGGER
    * @param parameter-  - list of Opp records being created.
    * @return return-void
    * @throws exception - NA
    */
    public static void populateProjectOnAmendOpportunity(List<Opportunity> oppList){
        for(Opportunity oppRec : oppList){
            if(oppRec.PSA_OM_Contract_Project__c <> null){  // only Process Opp Records that have a Contract Id value, PSA_OM_Contract_Project__c is a formula field from Contract.
                oppRec.PSA_OM_Primary_Project__c = oppRec.PSA_OM_Contract_Project__c; //copy the formula field to the actual looup field.
            }           
        }
    }

    /**
    * Method called from BEFORE UPDATE OF OPPORTUNITY TRIGGER
    * @param parameter-  - old Map and new map values of Opportunity records
    * @return return-void
    * @throws exception - NA
    */
    public static void checkIfProjectExistsForPSOpps(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
        
        Set<Id> SetofErrOpps = new Set<Id>();
        Set<Id> oppIdToProcess = new Set<Id>();
        
         boolean byPassSOGUsers = FeatureManagement.checkPermission('SalesSuperUser')?True:false;
        //Initial loop to only process records that actually have change in Stage ==> Comparing old map and new map.
       
        for(Opportunity oldOpp : oldMap.values()){
            for(Opportunity newOpp : newMap.values()){
                if((oldOpp.Id == newOpp.Id) && ((oldOpp.StageName <> newOpp.StageName) || (oldOpp.Substage__c <> newOpp.Substage__c))  && 
                        (newOpp.StageName =='Closed Won' ||  newOpp.Substage__c == 'Sales Won')){ //Added Sub Stage value check.
                    oppIdToProcess.add(newOpp.Id);
                }
            }
        }
        if(oppIdToProcess <> null && oppIdToProcess.size()>0){
            try{
                List<Opportunity> baseList = new List<Opportunity>([SELECT Id,Name,Professional_Services_Total__c,StageName,PSA_OM_Primary_Project__c,pse__Primary_Project__c,
                                                            (SELECT Id,Name,psa_om_Interlock__c FROM pse__Projects__r),
                                                            (SELECT Id,Name,PricebookEntry.Product2.Offering_Type__c FROM OpportunityLineItems WHERE PricebookEntry.Product2.Offering_Type__c= :Label.PSA_PS_OfferingType)
                                                            FROM Opportunity
                                                            WHERE ID IN :oppIdToProcess]);
                for(Opportunity oppRec : baseList){
                    if((oppRec.OpportunityLineItems.size()>0) && (oppRec.pse__Primary_Project__c == null) && (oppRec.PSA_OM_Primary_Project__c == null) && (oppRec.pse__Projects__r.size() == 0)){
                        SetofErrOpps.add(oppRec.Id);
                    }
                }         
                //Looping through the trigger variable and throwing error where the Error conditon is met
                if(SetofErrOpps.size() > 0){
                    for(Opportunity Opp : newMap.values()){
                        if(SetofErrOpps.contains(Opp.Id) && !byPassSOGUsers){
                            Opp.addError(Label.PSA_OpportunityTrigger_ErrorMessage);
                        }
                    }
                }
            }catch(Exception ex){
                GAM.CreateExceptionRecords('PSA-BEFORE OPPORTUNITY UPDATE LOGIC', 'Error processing PSA-project existance check',ex.getMessage());
            }
            
        }               
    }
 

    /**
    * Service level method to fetch the primary project of the Opportunity record.
    * @param parameter-  - Set<OpportunityId>
    * @return return- Map<OpportunityId, Project Id>
    * @throws exception - NA
    */
    public static Map<Id,Id> getOppIdProjIdMap(Set<Id> oppIdSet){
        Map<Id,Id> oppProjIdMap = new Map<Id,Id>();
        List<Opportunity> baseOppList = new List<Opportunity>([SELECT Id,Name,StageName,(SELECT Id,Name,psa_om_Interlock__c  FROM pse__Projects__r WHERE psa_om_Interlock__c = NULL) 
                                                                FROM Opportunity 
                                                                WHERE Id IN:oppIdSet]);

        if(baseOppList.size()>0){
            for(Opportunity oppRec : baseOppList){
                if(oppRec.pse__Projects__r.size() > 0){
                    Id projId = oppRec.pse__Projects__r[0].Id;
                    oppProjIdMap.put(oppRec.Id,projId);
                }
            }
        }
        return oppProjIdMap;
    }

    /**
    * Method called from PSA- Sync Oppty to Project Batch to update child projects.
    * @param parameter-  - list of Opporutnities that have been updated
    * @return return-void
    * @throws exception - NA
    */
    public static void updateProjectFromOppty(List<Opportunity> oppToProcess){

        List<pse__Proj__c> baseProjectList = new List<pse__Proj__c>([SELECT Id,pse__Opportunity__c,pse__Region__c,psa_pm_Journey__c FROM pse__Proj__c WHERE pse__Opportunity__c IN :oppToProcess]);
        System.debug('baseProjectList '+baseProjectList);
        List<pse__Proj__c> projRecsToUpdate = new List<pse__Proj__c>();
        Map<Id,List<pse__Proj__c>> oppIdProjListMap = new  Map<Id,List<pse__Proj__c>>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,pse__Region__c,Sales_Journey__c FROM Opportunity WHERE ID IN :oppToProcess]);
        
        System.debug('oppMap '+oppMap );

        for(pse__Proj__c projRec : baseProjectList){
            if(projRec.pse__Opportunity__c <> null){
                if(oppIdProjListMap.containsKey(projRec.pse__Opportunity__c)){
                    List<pse__Proj__c> childprojList = oppIdProjListMap.get(projRec.pse__Opportunity__c);
                    childprojList.add(projRec);
                }else{
                    List<pse__Proj__c> projList = new List<pse__Proj__c>();
                    projList.add(projRec);
                    oppIdProjListMap.put(projRec.pse__Opportunity__c,projList);
                }
            }
        }
        System.debug('oppIdProjListMap'+oppIdProjListMap);
        for(Id oppId : oppIdProjListMap.keyset()){
            List<pse__Proj__c> childProjList = oppIdProjListMap.get(oppId);
            for(pse__Proj__c prjRec : childProjList){
                if(oppMap.containsKey(prjRec.pse__Opportunity__c)){
                    prjRec.pse__Region__c = oppMap.get(prjRec.pse__Opportunity__c).pse__Region__c;
                    prjRec.psa_pm_Journey__c = oppMap.get(prjRec.pse__Opportunity__c).Sales_Journey__c;
                    projRecsToUpdate.add(prjRec);
                }
            }           
        }
       System.debug('projRecsToUpdate'+projRecsToUpdate);
        if(projRecsToUpdate.size()>0){
            try{
                Database.SaveResult[] projListToUpdate = Database.Update(projRecsToUpdate, false);
                System.debug('projListToUpdate '+projListToUpdate);
                //update projRecsToUpdate;
            }catch(Exception ex){
                GAM.CreateExceptionRecords('PSA- SYNC OPPORTUNITY-PROJECT BATCH', 'Error in Updating projects',ex.getMessage());
            }          
        }
    }

    /**
    * Method called from BEFORE UPDATE OF OPPORTUNITY TRIGGER to populate 
    * @param parameter-  - list of Opp records being created.
    * @return return-void
    * @throws exception - NA
    */
    public static void populatePSADateTimeStamp(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
     System.debug('IA CALLED');
        for(Opportunity oldOpp : oldMap.values()){
            for(Opportunity newOpp : newMap.values()){
            System.debug('PSA_Field_Change_Timestamp__c ='+newOpp.PSA_Field_Change_Timestamp__c );
            System.debug('pse__Region__c ='+newOpp.pse__Region__c );
            System.debug('Sales_Journey__c ='+newOpp.Sales_Journey__c);
                if((oldOpp.Id == newOpp.Id) && ((oldOpp.pse__Region__c <> newOpp.pse__Region__c) || (oldOpp.Sales_Journey__c <> newOpp.Sales_Journey__c))){
                    newOpp.PSA_Field_Change_Timestamp__c = DateTime.now();
                    
                }
                 System.debug('PSA_Field_Change_Timestamp__c ='+newOpp.PSA_Field_Change_Timestamp__c );
            }
        }
    }
    
}