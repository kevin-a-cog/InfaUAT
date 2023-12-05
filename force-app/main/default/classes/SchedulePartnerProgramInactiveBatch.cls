/*
@author : Vivek Warrier
@Date : 5-Aug-2019
@purpose : To schedule the batch class 'PartnerProgramInactiveBatch'
***********************************************************************************************************************************************
* Modified by       Date            Requested By                    Description                     
***********************************************************************************************************************************************
*
*
*/
public class SchedulePartnerProgramInactiveBatch implements Schedulable{
    public void execute(SchedulableContext sc){
        PartnerProgramInactiveBatch b = new PartnerProgramInactiveBatch();
        Database.executeBatch(b,200);
    }
}