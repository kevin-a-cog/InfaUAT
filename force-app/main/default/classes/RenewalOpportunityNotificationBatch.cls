/*
@author : Vivek Warrier
@Date : 7/31/2019
@purpose : To move the CSM Notification Chatter Post from Process Builder to batch class to get rid of time based Flows.
***********************************************************************************************************************************************
* Modified by       Date            Requested By                    Description                     
***********************************************************************************************************************************************
* Narpavi Prabu   9/6/2022           Sarojini             AR-2447- Send Notification to SMG Queue and Renewal Opty Owner 120 days ahead of Close Date
*
*/
public class RenewalOpportunityNotificationBatch implements Database.Batchable<sObject>{

    private static final String RENEWAL_RECORDTYPE_NAME = Label.Renewal_Opportunity;
    private static final String DAYS_TO_NOTIFY = Label.No_Of_Days_for_CSM_notify_for_RenewalOpty;
    String dt = DateTime.now().addDays(Integer.valueOf(DAYS_TO_NOTIFY)).format('yyyy-MM-dd');
    
    // Added for  AR-2447  
    private static final String DAYS_TO_NOTIFY_SMG = label.No_Of_Days_for_SMG_notify_for_RenewalOpty;
    String smgdt= DateTime.now().addDays(Integer.valueOf(DAYS_TO_NOTIFY_SMG)).format('yyyy-MM-dd');
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        //AR-2447 : Modified the query to check the close date is 120 or 140 days in opportunity and update the opportunity
        String query = 'SELECT Id,CloseDate FROM Opportunity WHERE Recordtype.Name = \'' + RENEWAL_RECORDTYPE_NAME + '\' AND (CloseDate = ' + dt + 'OR CloseDate = ' + smgdt+')';
        System.debug('Query => '+ query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        List<Opportunity> OppUpdate = new List<Opportunity>();
        for(Opportunity opp : scope){
        string s = string.valueof(opp.CloseDate);
        if(s == smgdt)
        {
            opp.Renewal_120_Days_SMG_Notify__c= true;
            OppUpdate.add(opp);
        }
        else if (s == dt)
        { 
            opp.Renewal_120_Days_Away__c = true;
            OppUpdate.add(opp);
        }
        Update OppUpdate;
    }
  }  

    public void finish(Database.BatchableContext bc){
        //Write finish logic here
    }
}