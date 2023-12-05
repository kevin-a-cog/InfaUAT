/*
    @author: Diego Soto
    @since: 31-Jan-2019
    method : execute,
    return type : void,
    Exception Handeling : N/A
    Description : Schedule a batch class 'ContractRenewalTypeBatch' for updating Renewal Type to the Contract
   */

global class ContractRenewalTypeBatch_Schedule implements Schedulable{
    
     /**
* this method is Execute the apex batch
*
* @param Database.BatchableContext BC
* @return return-Void
* @throws exception - NA
*/
    global void execute(SchedulableContext ctx){
        
        //Create a new Instance of our Class ContractRenewalTypeBatch
        ContractRenewalTypeBatch contractRenewalType = new ContractRenewalTypeBatch();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(contractRenewalType,1);
    }
}