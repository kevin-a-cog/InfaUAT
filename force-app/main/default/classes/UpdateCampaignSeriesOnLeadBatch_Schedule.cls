/****************************************************************************************************************************
 *  @Class Name: UpdateCampaignSeriesOnLeadBatch_Schedule
 *  @Author: Anil Solanki
 *  @Date: 25th March 2021
 *  @Description: Schduler for UpdateCampaignSeriesOnLeadBatch JIRA : SALESRT-12922
 *****************************************************************************************************************************/

global class UpdateCampaignSeriesOnLeadBatch_Schedule implements Schedulable{
//Run the Batch 
    global void execute(SchedulableContext ctx)
    {
        UpdateCampaignSeriesOnLeadBatch updateCampSeries= new UpdateCampaignSeriesOnLeadBatch();
        database.executebatch(updateCampSeries);
    }
    
}