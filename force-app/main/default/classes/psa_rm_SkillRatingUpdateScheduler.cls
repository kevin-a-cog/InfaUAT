/*
Class:          psa_rm_SkillRatingUpdateScheduler
@Author:        PAVITHRA V
@Created Date:  DECEMBER 12 2021
@Description:   Scheduler class to schedule psa_rm_SkillRatingUpdateScheduler
*/
global class psa_rm_SkillRatingUpdateScheduler implements Schedulable{ 

    global void execute(SchedulableContext sc) {
        psa_rm_SkillRatingUpdateBatch skillRatingBatch = new psa_rm_SkillRatingUpdateBatch();
        Database.executeBatch(skillRatingBatch, 200);
    }
}