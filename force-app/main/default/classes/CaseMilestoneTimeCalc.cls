/*
@created by       : SFDC Developer
@created on       : 11/01/2020
@Purpose          : Case handler class.
@Testclass        : 
@JIRA             : 


Change History
****************************************************************************************************
ModifiedBy      Date             Description                                         Jira No.       Tag
Venky K         03 July 2021     Added OGR Migrated and IR Migrated scenarios                      T01
****************************************************************************************************
*/ 


global class CaseMilestoneTimeCalc implements Support.MilestoneTriggerTimeCalculator{
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        Integer responseTime=30;
        System.debug('calculateMilestoneTriggerTime entry->');
        System.debug('caseId--> '+caseId);
        if(caseId!=null && caseId!='')
        {
            Case cse = [Select Id, eOGR_in_Mins__c,IR_in_Mins__c,OGR_in_Mins__c From Case Where Id=:caseId]; 	

            MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneTypeId];
            System.debug('eOGR_in_Mins__c = ' + cse.eOGR_in_Mins__c);
            
                if(cse.eOGR_in_Mins__c >0){
                    responseTime = Integer.valueOf(cse.eOGR_in_Mins__c);
                }
            //---------------------------------<T01>-------------------------------
            if(cse.IR_in_Mins__c > 0 && mt.Name.contains('Initial Response Migrated')){
                System.debug('IR Migrated minutes = ' + cse.IR_in_Mins__c);
                responseTime = Integer.valueOf(cse.IR_in_Mins__c);
            }
            if(cse.OGR_in_Mins__c > 0 && mt.Name.contains('Ongoing Response Migrated')){
                System.debug('OGR Migrated minutes = ' + cse.OGR_in_Mins__c);
                responseTime = Integer.valueOf(cse.OGR_in_Mins__c);
            }
            //---------------------------------<T01>-------------------------------
        }
        
        
        
        System.debug('responseTime = ' + responseTime);
        return responseTime;
    }
}