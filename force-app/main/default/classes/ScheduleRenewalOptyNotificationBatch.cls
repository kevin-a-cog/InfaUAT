/*
@author : Vivek Warrier
@Date : 7/31/2019
@purpose : To schedule the batch class 'RenewalOpportunityNotificationBatch'
***********************************************************************************************************************************************
* Modified by       Date            Requested By                    Description                     
***********************************************************************************************************************************************
*
*
*/
public class ScheduleRenewalOptyNotificationBatch implements Schedulable{
    public void execute(SchedulableContext sc){
        RenewalOpportunityNotificationBatch b = new RenewalOpportunityNotificationBatch();
        Database.executeBatch(b,200);
    }
}