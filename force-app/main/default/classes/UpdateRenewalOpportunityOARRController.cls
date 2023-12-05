/*
 * Class to update the Renewal Opportunity on Contract to trigger the Roll Up Helper
 */

public with sharing class UpdateRenewalOpportunityOARRController {

    @AuraEnabled
    public static Boolean recalculateOARR(Id oppId) {

        try {
            if(oppId != null) {
				
                //Disable the CPQ triggers
                SBQQ.TriggerControl.disable();
                list<Contract> contractList = new list<Contract>();
                set<Id> contractIdSet = new set<Id>();
                
				//Fetch all the contracts related to the triggered opp
                for(Contract cont : [SELECT Id, SBQQ__RenewalOpportunity__c 
                                    FROM Contract
                                    WHERE SBQQ__RenewalOpportunity__c =: oppId]) {
                    
                    cont.SBQQ__RenewalOpportunity__c = null;  
                    contractList.add(cont);   
                    contractIdSet.add(cont.Id);                                   
                }
				
                //to remove the opp from the contract
                if(!contractList.isEmpty() && contractList.size() > 0) {
                    update contractList;
                }

                contractList = new list<Contract>(); 

                //to populate the renewal opp
                for(Id contractId : contractIdSet) {
                    
                    Contract cont = new Contract(Id = contractId, SBQQ__RenewalOpportunity__c = oppId);
                    contractList.add(cont);                                      
                }
				
                //DML to update the contract and trigger the RollUp Helper
                if(!contractList.isEmpty() && contractList.size() > 0) {
                    update contractList;
                }
                
                return true;
            }
                   
            return false;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } finally {
            //Enable the CPQ triggers
            SBQQ.TriggerControl.enable();
        }

    }

    
}