/*
Trigger: topicAfterInsert
@Author: Utkarsh Jain     
@Created Date: 23-NOv-22
@Description: This is called to delete a topic created using hashtag by non-admin users.

Change History
**************************************************************************************************************************
Modified By            Date                Jira No.            Description                                               Tag
**************************************************************************************************************************
                                                               when the #tag is used in the discussion content   
Utkarsh Jain           04-May-2023         I2RT-8305           New product is getting created while tagging the discussion. 1                                                   
*/

trigger topicAfterInsert on Topic (after insert) {
    if(globalApexManager.avoidRecursion('topicAfterInsert')) {
        return;
    }
    // Tag 1 Start
    helpQuestions.deleteHashtagTopic(Trigger.new, Trigger.new[0].NetworkId);
    // Tag 1 End
}