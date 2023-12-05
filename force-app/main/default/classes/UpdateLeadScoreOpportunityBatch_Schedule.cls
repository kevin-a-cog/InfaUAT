/****************************************************************************************************************************
 *  @Class Name: UpdateLeadScoreOpportunityBatch_Schedule
 *  @Author: Anil Solanki
 *  @Date: 1st March 2021
 *  @Description: Schduler for UpdateLeadScoreOpportunityBatch JIRA : Salesrt-12797
 *****************************************************************************************************************************/

global class UpdateLeadScoreOpportunityBatch_Schedule implements Schedulable{
//Run the Batch 
    global void execute(SchedulableContext ctx)
    {
        UpdateLeadScoreOpportunityBatch updateScore= new UpdateLeadScoreOpportunityBatch();
        database.executebatch(updateScore);
    }
    
}