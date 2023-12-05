/*
@author : Vivek Warrier
@Date : 5-Aug-2019
@purpose : To move the Partner Program de-activation Action from Process Builder to batch class to get rid of time based Flows.
***********************************************************************************************************************************************
* Modified by       Date            Requested By                    Description                     
***********************************************************************************************************************************************
*
*
*/
public class PartnerProgramInactiveBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        String myDate = DateTime.now().addDays(-90).format('yyyy-MM-dd');
        //Checking Program Status = 'Active' in the query itself, so that only those PPs get picked up
        String query = 'SELECT Id,Program_Status__c,End_Date__c FROM Partner_Program__c WHERE Program_Status__c = \'Active\' AND End_Date__c = ' + myDate;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Partner_Program__c> scope){
        List<Partner_Program__c> pprgUpdate = new List<Partner_Program__c>();
        for(Partner_Program__c pprg : scope){
            pprg.Program_Status__c = 'Inactive';
            pprgUpdate.add(pprg);        
        }
        Update pprgUpdate;
    }
    
    public void finish(Database.BatchableContext bc){
        //Write finish logic here
    }
}