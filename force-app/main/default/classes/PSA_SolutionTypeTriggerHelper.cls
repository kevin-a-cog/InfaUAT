/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : helper class for PSA_SolutionTypeTriggerHandler.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                            |  Jira No.      | Tag No:


***************************************************************************************************************************
*/
public class PSA_SolutionTypeTriggerHelper {
    
    /**
* Method to prepopulate the fields on solution type records.
* @param newList => Trigger.new
* @return return-void
* @throws exception - error message added to the record.
*/
    public void prepopulateFieldsOnInsert(List<psa_pm_Solution_Type__c> newList){
        
        Set<Id> opptyIds = new Set<Id>();
        
        for(psa_pm_Solution_Type__c newRec : newList){
            
            if(!String.isBlank(newRec.Opportunity__c) && String.isBlank(newRec.psa_pm_Project__c)){
                opptyIds.add(newRec.Opportunity__c);
            }
        }
        Map<Id,Id> opptyProjMap = new Map<Id,Id>();
        if(!opptyIds.isEmpty()){
            for(pse__Proj__c projRec :[Select Id,pse__Opportunity__c from pse__Proj__c where pse__Opportunity__c=:opptyIds ORDER BY CREATEDDATE ASC ])
            {
                if(!opptyProjMap.containsKey(projRec.pse__Opportunity__c)){
                    opptyProjMap.put(projRec.pse__Opportunity__c,projRec.Id); 
                }
                
            }
            
            if(opptyProjMap!=null && !opptyProjMap.keySet().isEmpty()){
                
                for(psa_pm_Solution_Type__c newRec : newList){
                    
                    if(opptyProjMap.containsKey(newRec.Opportunity__c)){
                        newRec.psa_pm_Project__c = opptyProjMap.get(newRec.Opportunity__c);
                    }
                }
            }
        }
    }
    /**
* Method to validate the Total Product Split percentage of solution type records under a opportunity and throw a message if 
* the total product split percentage is greater than 100.
* @param newList => Trigger.new
* @return return-void
* @throws exception - error message added to the record.
*/
    public void validateProductSplitPercentageOnInsert(List<psa_pm_Solution_Type__c> newList){
        
        Set<Id> opptyIds = new Set<Id>();
        
        Map<Id,Decimal> opptySolnTypePercentageMap = new Map<Id,Decimal>();
        Map<Id,Decimal> opptyTotalSolnTypePercentageMap = new Map<Id,Decimal>();
        for(psa_pm_Solution_Type__c newRec : newList){
            if(!String.isBlank(newRec.Opportunity__c) && newRec.PSA_PM_Product_Split__c!=null){
                opptyIds.add(newRec.Opportunity__c);
            }
        }
        if(!opptyIds.isEmpty()){
            
            for(psa_pm_Solution_Type__c solnRec : [Select Id,PSA_PM_Product_Split__c,Opportunity__c from psa_pm_Solution_Type__c 
                                                   where Opportunity__c IN :opptyIds and PSA_PM_Product_Split__c!=null])
            {
                if(!opptySolnTypePercentageMap.containsKey(solnRec.Opportunity__c)){
                    opptySolnTypePercentageMap.put(solnRec.Opportunity__c,solnRec.PSA_PM_Product_Split__c);
                }else{
                    Decimal i = opptySolnTypePercentageMap.get(solnRec.Opportunity__c)+solnRec.PSA_PM_Product_Split__c;
                    opptySolnTypePercentageMap.put(solnRec.Opportunity__c,i);
                }
            }
            for(psa_pm_Solution_Type__c newRec : newList){
                
                if(newRec.PSA_PM_Product_Split__c!=null){
                    if(!opptySolnTypePercentageMap.containsKey(newRec.Opportunity__c)){
                        opptySolnTypePercentageMap.put(newRec.Opportunity__c,newRec.PSA_PM_Product_Split__c);
                    }else{
                        Decimal i = opptySolnTypePercentageMap.get(newRec.Opportunity__c)+newRec.PSA_PM_Product_Split__c;
                        opptySolnTypePercentageMap.put(newRec.Opportunity__c,i);
                    } 
                    
                    if(opptySolnTypePercentageMap.get(newRec.Opportunity__c)>100){
                        if(!opptyTotalSolnTypePercentageMap.containsKey(newRec.Opportunity__c)){
                            Decimal currentTotal = (opptySolnTypePercentageMap.get(newRec.Opportunity__c) - newRec.PSA_PM_Product_Split__c)>0?(opptySolnTypePercentageMap.get(newRec.Opportunity__c) - newRec.PSA_PM_Product_Split__c):0; 
                            opptyTotalSolnTypePercentageMap.put(newRec.Opportunity__c,currentTotal);
                        }
                        newRec.addError('Product Split % total for all lines is reaching more than 100%, current total Product Split% is '+opptyTotalSolnTypePercentageMap.get(newRec.Opportunity__c)+'%.');   
                    }
                }
            }
            
        }
    }
    /**
* Method to validate the Total Product Split percentage of solution type records under a opportunity and throw a message if 
* the total product split percentage is greater than 100.
* @param newMap => Trigger.newMap,oldMap => Trigger.oldMap
* @return return-void
* @throws exception - error message added to the record.
*/
    public void validateProductSplitPercentageOnUpdate(Map<Id,psa_pm_Solution_Type__c> newMap,Map<Id,psa_pm_Solution_Type__c> oldMap){
        
        Set<Id> opptyIds = new Set<Id>();
        Set<Id> solnTypeIds = new Set<Id>();
        Map<Id,Decimal> opptySolnTypePercentageMap = new Map<Id,Decimal>();
        Map<Id,Decimal> opptyTotalSolnTypePercentageMap = new Map<Id,Decimal>();
        for(psa_pm_Solution_Type__c newRec : newMap.values()){
            psa_pm_Solution_Type__c oldRec = oldMap.get(newRec.Id);
            if(!String.isBlank(newRec.Opportunity__c) && newRec.PSA_PM_Product_Split__c!=null &&
               oldRec.PSA_PM_Product_Split__c!=newRec.PSA_PM_Product_Split__c){
                   opptyIds.add(newRec.Opportunity__c);
                   solnTypeIds.add(newRec.Id);
               }
        }
        if(!opptyIds.isEmpty()){
            
            for(psa_pm_Solution_Type__c solnRec : [Select Id,PSA_PM_Product_Split__c,Opportunity__c from psa_pm_Solution_Type__c 
                                                   where Opportunity__c IN :opptyIds and PSA_PM_Product_Split__c!=null])
            {
                if(!solnTypeIds.contains(solnRec.Id)){
                    if(!opptySolnTypePercentageMap.containsKey(solnRec.Opportunity__c)){
                        opptySolnTypePercentageMap.put(solnRec.Opportunity__c,solnRec.PSA_PM_Product_Split__c);
                    }else{
                        Decimal i = opptySolnTypePercentageMap.get(solnRec.Opportunity__c)+solnRec.PSA_PM_Product_Split__c;
                        opptySolnTypePercentageMap.put(solnRec.Opportunity__c,i);
                    }  
                }              
            }
            
            for(psa_pm_Solution_Type__c newRec : newMap.values()){
                if(newRec.PSA_PM_Product_Split__c!=null){ 
                    if(!opptySolnTypePercentageMap.containsKey(newRec.Opportunity__c)){
                        opptySolnTypePercentageMap.put(newRec.Opportunity__c,newRec.PSA_PM_Product_Split__c);
                    }else{
                        Decimal i = opptySolnTypePercentageMap.get(newRec.Opportunity__c)+newRec.PSA_PM_Product_Split__c;
                        opptySolnTypePercentageMap.put(newRec.Opportunity__c,i);
                    } 
                    if(opptySolnTypePercentageMap.get(newRec.Opportunity__c)>100){
                        if(!opptyTotalSolnTypePercentageMap.containsKey(newRec.Opportunity__c)){
                            Decimal currentTotal = (opptySolnTypePercentageMap.get(newRec.Opportunity__c) - newRec.PSA_PM_Product_Split__c)>0?(opptySolnTypePercentageMap.get(newRec.Opportunity__c) - newRec.PSA_PM_Product_Split__c):0; 
                            opptyTotalSolnTypePercentageMap.put(newRec.Opportunity__c,currentTotal);
                        }
                        newRec.addError('Product Allocation % total for all lines is reaching more than 100%, current total Product Allocation % is '+opptyTotalSolnTypePercentageMap.get(newRec.Opportunity__c)+'%.');   
                    }
                }
            }
        }
    }    
    
}