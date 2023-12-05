/*
    Class:          CSMSuccessPortfolioSchedular
    @Author:        Karthi Gurusamy
    @Created Date:  24/02/2023
    @Description:   Schedular class to schedule  CSMUpdateSuccessPortfolioBatch
    @Test Class :   CSMUpdateSuccessPortfolioBatchTest

Change History
*******************************************************************************************************************************************************
ModifiedBy            Date          Requested By             Description                                                           Tag
*******************************************************************************************************************************************************
Karthi G             24-Feb-2023    AR-3107             Schedular class to schedule  CSMUpdateSuccessPortfolioBatch      Initial version                        
*******************************************************************************************************************************************************
*/
global with sharing class CSMSuccessPortfolioSchedular implements Schedulable {
    /*
    Method Name : execute
    Description : this method to instantiate the class you want to schedule.
    Parameters	 : A reference to the SchedulableContext object.                
    Return Type : void
    */
   global void execute(SchedulableContext sc) {
    CSMUpdateSuccessPortfolioBatch batchJob = new CSMUpdateSuccessPortfolioBatch(); 
       database.executebatch(batchJob);
   }
}