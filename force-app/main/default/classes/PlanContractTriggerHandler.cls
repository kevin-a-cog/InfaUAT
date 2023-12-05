/*
* Class :        PlanContractTriggerHandler
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for Plan Contract Triggers
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************

*/



public with sharing class PlanContractTriggerHandler {

    public static globalApexManager GAM = new globalApexManager();

    public static void handlebeforeInsert(List<Plan_Contract__c> lstNewPlanContarts){
       updatePlanContract(lstNewPlanContarts);  
    }
    
    public static void handlebeforeUpdate(List<Plan_Contract__c> lstNewPlanContarts){
      updatePlanContract(lstNewPlanContarts);
    }

    
    public static void updatePlanContract(List<Plan_Contract__c> lstNewPlanContarts){
        
        Map<Id, Plan_Contract__c> MapContractPlan = new map<Id,Plan_Contract__c>();
        Map<Id, Plan_Contract__c> MapOpportunityPlan = new map<Id,Plan_Contract__c>();
        List<Plan_Contract__c> LstUpdatePlanContract = new List<Plan_Contract__c>();
        
        for(Plan_Contract__c plancontract :lstNewPlanContarts) {
            if(plancontract.Plan__c!=null && plancontract.Opportunity__c==null && plancontract.Contract__c!=null){
                MapContractPlan.put(plancontract.Contract__c,plancontract);
            }
            if(plancontract.Plan__c!=null && plancontract.Opportunity__c!=null && plancontract.Contract__c==null){
                MapOpportunityPlan.put(plancontract.Opportunity__c,plancontract);
            }
        }
        
        for (Contract con : [Select id,SBQQ__Opportunity__c from Contract where id in :MapContractPlan.keyset() or SBQQ__Opportunity__c in : MapOpportunityPlan.keySet()]){
            Try{
                if(MapContractPlan.Containskey(con.id)&& con.SBQQ__Opportunity__c!=null){               
                    MapContractPlan.get(con.id).Opportunity__c= con.SBQQ__Opportunity__c;   
                }
                if(con.SBQQ__Opportunity__c!=null && MapOpportunityPlan.containsKey(con.SBQQ__Opportunity__c)){           
                    MapOpportunityPlan.get(con.id).Contract__c= con.id;            
                }
            }
            Catch(exception e){
                  GAM.CreateExceptionRecords('PlanContractTriggerHanlder-->updatePlanContract-->Update of Plan Contract failed', e.getMessage(), con.id);
            }
        }
        
        
    }
    
    
}