/*
Class:          psa_em_ExpenseRollupFixBatchScheduler
@Author:        Vivek Warrier
@Created Date:  19-Jul-2021
@Description:   Scheduler class to schedule Expense Report Issue Fix Class to correct Total Non-Billable and Total Reimwbursement Amounts.
*/
global class psa_em_ExpenseRollupFixBatchScheduler implements Schedulable{ 

    global void execute(SchedulableContext sc) {
        psa_em_ExpenseRollupFixBatch pseExpenseBatch = new psa_em_ExpenseRollupFixBatch();
        Database.executeBatch(pseExpenseBatch, 200);
    }
}