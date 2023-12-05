/*
* Name			:	CSMLoadJiraCommentToPlanCommentQueuable
* Author		:	Deva M
* Created Date	: 	019/11/2021
* Description	:	Queable class to load plan comment from Jira comment

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				29/11/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMLoadJiraCommentToPlanCommentQueuable implements Queueable{
    public List<FeedItem> lstFeedItemRecords ; 
    public CSMLoadJiraCommentToPlanCommentQueuable(List<FeedItem> lstFeedItemRecords) {
        this.lstFeedItemRecords = lstFeedItemRecords;
    }
    public void execute(QueueableContext context) {
        CSMJIRACommentsService helperJira=new CSMJIRACommentsService();
        if(lstFeedItemRecords!=null && lstFeedItemRecords.size()>0){
            helperJira.createPlanCommentFromFeedItem(lstFeedItemRecords);
        }
    }
}