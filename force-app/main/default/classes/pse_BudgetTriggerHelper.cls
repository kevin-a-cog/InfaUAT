/*
@created by       : PAVITHRA
@created on       : 11/24/2021
@Purpose          : Helper class for pse_BudgetTriggerHandler.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class pse_BudgetTriggerHelper {

    public static globalApexManager GAM = new globalApexManager();
    
    public void updateProjectPlannedHours(List<pse__Budget__c> newList, Map<Id,pse__Budget__c> oldMap){
        
        Map<Id,List<pse__Budget__c>> projectToBudgetMap = new Map<Id,List<pse__Budget__c>>();
        List<pse__Proj__c> projectToUpdateList = new List<pse__Proj__c>();
        
        for(pse__Budget__c budget : newList){
            if(budget.pse__Type__c == 'Customer Purchase Order Change Request' && budget.Additional_Hours__c <> null 
               && ((budget.pse__Status__c == 'Approved' && oldMap == null) 
               || (budget.pse__Status__c == 'Approved' && budget.pse__Status__c <> oldMap?.get(budget.Id).pse__Status__c && oldMap <> null))){
                   
                   if(projectToBudgetMap.containsKey(budget.pse__Project__c)){
                       List<pse__Budget__c> tempList = projectToBudgetMap.get(budget.pse__Project__c);
                       tempList.add(budget);
                       projectToBudgetMap.put(budget.pse__Project__c , tempList);
                   }else{
                       projectToBudgetMap.put(budget.pse__Project__c , new List<pse__Budget__c>{budget});
                   }
               }
        }
        
        if(projectToBudgetMap <> null){
            for(pse__Proj__c project : [Select Id,pse__Planned_Hours__c from pse__Proj__c where Id in :projectToBudgetMap.keySet()]){
                pse__Proj__c proj = new pse__Proj__c();
                proj.Id = project.Id;
                if(project.pse__Planned_Hours__c <> null){
                    proj.pse__Planned_Hours__c = project.pse__Planned_Hours__c;
                }else{
                    proj.pse__Planned_Hours__c = 0;
                }
                
                for(pse__Budget__c approvedBudget : projectToBudgetMap.get(project.Id)){
                    proj.pse__Planned_Hours__c = proj.pse__Planned_Hours__c + approvedBudget.Additional_Hours__c;
                }
                projectToUpdateList.add(proj);
            }
        }
        
        if(projectToUpdateList?.size()>0){
            try{
                update projectToUpdateList;
            }catch(Exception e){
                GAM.CreateExceptionRecords('Update of Planned Hours field in Project failed', e.getMessage(), 'pse_BudgetTriggerHelper ---> updateProjectPlanningHours');
            }
        }
    }
    
    public void deductProjectPlannedHours(Map<Id,pse__Budget__c> oldMap){
        
        Map<Id,List<pse__Budget__c>> projectToBudgetMap = new Map<Id,List<pse__Budget__c>>();
        List<pse__Proj__c> projectToUpdateList = new List<pse__Proj__c>();
        
        for(pse__Budget__c budget : oldMap.values()){
            if(budget.pse__Status__c == 'Approved' && budget.Additional_Hours__c <> null){
                if(projectToBudgetMap.containsKey(budget.pse__Project__c)){
                       List<pse__Budget__c> tempList = projectToBudgetMap.get(budget.pse__Project__c);
                       tempList.add(budget);
                       projectToBudgetMap.put(budget.pse__Project__c , tempList);
                   }else{
                       projectToBudgetMap.put(budget.pse__Project__c , new List<pse__Budget__c>{budget});
                   }
            }
        }
        
        if(projectToBudgetMap <> null){
            for(pse__Proj__c project : [Select Id,pse__Planned_Hours__c from pse__Proj__c where Id in :projectToBudgetMap.keySet()]){
                pse__Proj__c proj = new pse__Proj__c();
                proj.Id = project.Id;
                if(project.pse__Planned_Hours__c <> null){
                    proj.pse__Planned_Hours__c = project.pse__Planned_Hours__c;
                }else{
                    proj.pse__Planned_Hours__c = 0;
                }
                
                for(pse__Budget__c approvedBudget : projectToBudgetMap.get(project.Id)){
                    proj.pse__Planned_Hours__c = proj.pse__Planned_Hours__c - approvedBudget.Additional_Hours__c;
                }
                projectToUpdateList.add(proj);
            }
        }
        
        if(projectToUpdateList?.size()>0){
            try{
                update projectToUpdateList;
            }catch(Exception e){
                GAM.CreateExceptionRecords('Update of Planned Hours field in Project failed', e.getMessage(), 'pse_BudgetTriggerHelper ---> deductProjectPlannedHours');
            }
        }
    }
}