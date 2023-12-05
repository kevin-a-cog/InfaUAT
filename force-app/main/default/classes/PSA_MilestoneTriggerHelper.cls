/*
@created by       : RANJAN KISHORE
@created on       : 03/02/2021
@Purpose          : Helper class for PSA_MilestoneTriggerHandler.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Pavithra        11/24/2021                       Update the Date of First Value on project when          PSA-1863         T01
												 the related milestone has Actual date populated 
Wasim			05/19/2023						 Service Units Implementation							 PSA-2606 		  T02
*/	

public class PSA_MilestoneTriggerHelper {
    public static globalApexManager GAM = new globalApexManager();
    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {pse__Proj__c.SObjectType};//</T02>
        
    public void populateFieldsOnInsert(List<pse__Milestone__c> newList){        
        for(pse__Milestone__c mileStoneRec : newList){
            mileStoneRec.pse__Admin_Global_Edit__c =true;
         }
    }
    
    //<T01> : Update the Date of First Value on project when the related milestone has Actual date populated
    public void updateProjectFields(List<pse__Milestone__c> newList , Map<Id,pse__Milestone__c> oldMap, string operationType){
        Map<Id,pse__Milestone__c> projectToMilestoneMap = new Map<Id,pse__Milestone__c>();
        Set<Id> projIdSet = new Set<Id>();
        //<T02>
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        //List<pse__Proj__c> projUpdateList = new List<pse__Proj__c>();
        
        List<pse__Milestone__c> milestoneList = operationType == 'DELETE' ? oldMap.values() : newList;//<T02>
        for(pse__Milestone__c milestone : milestoneList){
            if((operationType == 'INSERT' || operationType == 'UPDATE') && ((oldMap <> null && milestone.pse__Actual_Date__c <> oldMap?.get(milestone.Id)?.pse__Actual_Date__c && milestone.pse__Actual_Date__c <> null) 
                                                                            || (milestone.pse__Actual_Date__c <> null && oldMap == null)) && milestone.Name.startsWith('FTV')){
                                                                                projectToMilestoneMap.put(milestone.pse__Project__c,milestone);
                                                                            }            
            //when the approved milestone is created
            if((operationType == 'INSERT' && milestone.pse__Approved__c && milestone.pse__Status__c == 'Approved' && milestone.psa_Milestone_Service_Unit__c > 0)
               //when one of the fields in milestone is updated - when the milestone Approved or when the milestone status is changed to approved or the service credits on milestone is changed
               ||(operationType == 'UPDATE' && (milestone.pse__Approved__c && milestone.pse__Status__c == 'Approved' && milestone.psa_Milestone_Service_Unit__c >= 0) && (oldMap.get(milestone.Id).pse__Approved__c != milestone.pse__Approved__c || milestone.pse__Status__c <> oldMap.get(milestone.Id).pse__Status__c || milestone.psa_Milestone_Service_Unit__c <> oldMap.get(milestone.Id).psa_Milestone_Service_Unit__c))
               //when the milestone is deleted 
               ||(operationType == 'DELETE' && milestone.psa_Milestone_Service_Unit__c > 0)
              )
            {
                projIdSet.add(milestone.pse__Project__c);
            }
        }
        if(projIdSet.size() > 0){
            Map<Id,pse__proj__c> projMap = new Map<Id,pse__proj__c>([SELECT Id,psa_Service_Units__c FROM pse__proj__c WHERE ID IN :projIdSet]);
            
            //The query will contain the sum of Milestone Service unit for each project
            List<AggregateResult> agrList = [SELECT SUM(psa_Milestone_Service_Unit__c) SumofServiceUnits,pse__Project__c FROM pse__Milestone__c
                                             WHERE pse__Approved__c = TRUE AND pse__Status__c = 'Approved' AND psa_Milestone_Service_Unit__c > 0
                                             AND pse__Project__c IN :projIdSet
                                             GROUP BY pse__Project__c];
            for(AggregateResult agr : agrList){
                Id projId = (Id) agr.get('pse__Project__c');
                Decimal serviceUnits = (Decimal)agr.get('SumofServiceUnits'); 
                //Check if the sum of Milestone service units does not exceed the Project Service units
                if(serviceUnits <= projMap.get(projId).psa_Service_Units__c){
                    pse__Proj__c proj = new pse__Proj__c(Id = projId, psa_Service_Units_Used__c = serviceUnits);
                    //projUpdateList.add(proj);//stores the project list to be updated
                    uow.registerDirty(proj);
                }
                else{
                    newList[0].addError('Project service units limit exceeded. Please reduce the Milestone service units');
                }
            }
        }
        //</T02>
        for(Id projectId : projectToMilestoneMap.keySet()){
            pse__Proj__c project = new pse__Proj__c();
            project.Id = projectId;
            project.psa_pm_Date_of_First_Value__c = projectToMilestoneMap.get(project.Id).pse__Actual_Date__c;
            //projUpdateList.add(project);//stores the project list to be updated
           uow.registerDirty(project, new List<SObjectField> { pse__Proj__c.psa_pm_Date_of_First_Value__c });//</T02>
        }
        try{
            uow.commitWork();//</T02>
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('Error caused from PSA_MilestoneTriggerHelper class in updateProjectFields method', e.getMessage(),milestoneList[0].Id);
        }
        
    }
}