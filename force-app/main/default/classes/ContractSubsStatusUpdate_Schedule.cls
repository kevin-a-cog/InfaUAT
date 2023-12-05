/*
Class:          ContractSubsStatusUpdate_Schedule
@Author:        Chandana Gowda
@Created Date:  05 Nov 2020
@Description:   Schedule a batch class 'ContractAndSubsStatusUpdateBatch' for updating Status on subscription and contract

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
************************************************************************************************************************************************************
*/
global class ContractSubsStatusUpdate_Schedule implements Schedulable{
     /**
    * this method is Execute the apex batch
    *
    * @param Database.BatchableContext BC
    * @return return-Void
    * @throws exception - NA
    */
    global void execute(SchedulableContext ctx){
        
        //Create a new Instance of our Class ContractAndSubsStatusUpdateBatch
        ContractAndSubsStatusUpdateBatch contractStatusBatch = new ContractAndSubsStatusUpdateBatch();
        database.executebatch(contractStatusBatch,199);
    }
}