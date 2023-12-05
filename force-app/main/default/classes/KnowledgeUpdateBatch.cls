/*
@created by       : balajip
@created on       : 09/07/2020
@Purpose          : Batch class to Archive/Delete Knowledge Articles
@Testclass        :
@JIRA             : I2RT-62


Change History

****************************************************************************************************
|  Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|   1      |  28-Jan-2021      |   Ranjan                  |    I2RT-862       |   Added changes related to Notify Author
|   2      |  23-Oct-2023      |   Sathish R               |    I2RT-9179      |   Delete case KB record from case details if case KB is being auto deleted from SFDC due to non submission.
****************************************************************************************************

*/
public class KnowledgeUpdateBatch implements Database.Batchable<sObject> {
      
      public static String ARCHIVE_EXPIRED_ARTICLES = 'ARCHIVE';
      public static String DELETE_STALE_DRAFT_ARTICLES = 'DELETE';
      public static String TEST_DELETE_STALE_DRAFT_ARTICLES = 'TEST DELETE';
      public static String NOTIFY_AUTHORS = 'NOTIFY AUTHORS'; /* Tag 1 */
      public static String TEST_NOTIFY_AUTHORS = 'TEST NOTIFY AUTHORS'; /* Tag 1  for testing purpose created*/
      public static String KB_URL = Label.KB_URL;/* Tag 1 */
      
      
      String jobType;
      
      public KnowledgeUpdateBatch(){
            this.jobType = ARCHIVE_EXPIRED_ARTICLES;
      }
      
      public KnowledgeUpdateBatch(String jobType){
            this.jobType = jobType;
      }
      
      public Database.QueryLocator start(Database.BatchableContext BC){
            String SOQL;
            Integer noOfDays;
            if(this.jobType == ARCHIVE_EXPIRED_ARTICLES) { //List of knowledge article versions that are Online but expired.
                  noOfDays = Integer.valueOf(Label.KB_Archive_Expired_Article_in_Days);
                  SOQL='Select Id, LastModifiedDate, KnowledgeArticleId, Title From Knowledge__kav Where PublishStatus=\'Online\' And Expiration_Date__c < Last_N_Days:' + noOfDays;
            }else if(this.jobType == DELETE_STALE_DRAFT_ARTICLES) { //List of Draft knowledge article versions that are not updated since a certain no. of days.
                  noOfDays = Integer.valueOf(Label.KB_Delete_Draft_Article_in_Days);
                  SOQL='Select Id, LastModifiedDate, KnowledgeArticleId, Title,ArticleNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,Created_By__r.Name,Primary_Product__c,Technical_Reviewer_Rejected__c,Content_Reviewer_Rejected__c From Knowledge__kav Where Technical_Reviewer_Rejected__c = FALSE And Content_Reviewer_Rejected__c = FALSE And PublishStatus=\'Draft\' And ValidationStatus=\'Draft\' And LastModifiedDate < Last_N_Days:' + noOfDays;
            }else if(this.jobType == NOTIFY_AUTHORS) { /* Tag 1 */
                  noOfDays = Integer.valueOf(Label.KB_Delete_Draft_Article_in_Days) - 7;
                  Integer n = noOfDays+1;
                  SOQL='Select Id,LastmodifiedDate, KnowledgeArticleId,ArticleNumber,Title,Original_Author__r.Email,Original_Author__c,Created_By__c,Created_By__r.Email From Knowledge__kav Where PublishStatus=\'Draft\' And ValidationStatus=\'Draft\' And LastModifiedDate < Last_N_Days:' + noOfDays+' and  LastModifiedDate = Last_N_Days:'+n;
                  
            }else if(this.jobType == TEST_NOTIFY_AUTHORS) { // Created this block for Test Run
                  SOQL='Select Id,LastmodifiedDate, KnowledgeArticleId,ArticleNumber,Title,Original_Author__r.Email,Original_Author__c,Created_By__c,Created_By__r.Email From Knowledge__kav Where PublishStatus=\'Draft\' And ValidationStatus=\'Draft\' And CreatedDate  > YESTERDAY';
                  
            }else if(this.jobType == TEST_DELETE_STALE_DRAFT_ARTICLES) { // Created this block for Test Run
                  SOQL='Select Id, LastModifiedDate, KnowledgeArticleId, Title,ArticleNumber,CreatedDate,CreatedBy.Name,LastModifiedBy.Name,Created_By__r.Name,Primary_Product__c From Knowledge__kav Where PublishStatus=\'Draft\' And ValidationStatus=\'Draft\' And CreatedDate = TODAY';
                  
            }
            
            System.debug('SOQL - ' + SOQL);
            return Database.getQueryLocator(SOQL);
      }
      
      public void execute(Database.BatchableContext BC, List<sObject> scope){
            
            List<ConnectApi.BatchInput> chatterPostInputs = new List<ConnectApi.BatchInput>();
            List<Messaging.SingleEmailMessage> emailInputs= new List<Messaging.SingleEmailMessage>();    
            Set<Id> articleIds= new Set<Id>();/* Tag 2 */   
            for(sobject s : scope) {
                  Knowledge__kav kav = (Knowledge__kav)s;
                  System.debug('kav Id - ' + kav.Id);
                  Datetime lastmod = kav.LastmodifiedDate.addDays(45);
                  String articleDeletionDate = lastmod.format('MMMM')+' '+lastmod.day()+', '+lastmod.year();
                  try{
                        System.debug('-------job type ' + this.jobType);
                        if(this.jobType == ARCHIVE_EXPIRED_ARTICLES) {
                              System.debug('about to archive the article with Id - ' + kav.Id);
                              System.debug('about to archive the article with lastmodifieddate - ' + kav.LastModifiedDate.format());
                              KbManagement.PublishingService.archiveOnlineArticle(kav.KnowledgeArticleId, null);
                        }else if(this.jobType == DELETE_STALE_DRAFT_ARTICLES || this.jobType == TEST_DELETE_STALE_DRAFT_ARTICLES) {
                              System.debug('about to delete the article with Id - ' + kav.Id);
                              System.debug('about to delete the article with lastmodifieddate - ' + kav.LastModifiedDate.format());                              
                              articleIds.add(kav.Id);/* Tag 2 */
                        }else if(this.jobType == NOTIFY_AUTHORS || this.jobType == TEST_NOTIFY_AUTHORS) {/* Tag 1 */
                              chatterPostInputs.add(KBNotifyAuthor.createChatterPostContent(kav,articleDeletionDate));
                              emailInputs.add(KBNotifyAuthor.createEmailAlertContent(kav,KB_URL,articleDeletionDate));
                              
                        }
                  }catch(Exception ex) {
                        System.debug(ex.getMessage());
                  }
            }
            if(this.jobType == DELETE_STALE_DRAFT_ARTICLES || this.jobType == TEST_DELETE_STALE_DRAFT_ARTICLES) {
                  /* Tag 2 - Start - Deletes the Case KB Record which is related to KB Record and then deletes the KB Record*/
			if(!articleIds.isEmpty()) {
				System.debug('about to delete the case kb related to kb ids - ' + articleIds.toString());
				Delete [SELECT Id,Type__c,Knowledge__c from Case_KB__c where Knowledge__c in : articleIds And Type__c IN ('Create New','Use Existing','Updated Existing')];
			}
			for(sobject s : scope) {
                        try{ 
                              Knowledge__kav kav = (Knowledge__kav)s;
                              System.debug('about to delete the article with Id - ' + kav.Id);
                              System.debug('about to delete the article with lastmodifieddate - ' + kav.LastModifiedDate.format());
                              KbManagement.PublishingService.deleteDraftArticle(kav.KnowledgeArticleId);
                        }catch(Exception ex) {
                              System.debug(ex.getMessage());
                        }				
			}
                  /* Tag 2 - End */
                  emailInputs.add(KBNotifyAuthor.createEmailAlertContentOnDeletion(scope));
                  if(!Test.isRunningTest() && !emailInputs.isEmpty()){Messaging.sendEmail(emailInputs);  }                    
            }
            
            if(this.jobType == NOTIFY_AUTHORS || this.jobType == TEST_NOTIFY_AUTHORS){/* Tag 1 */
                  // Post on chatter to the Authors.
                  if(!Test.isRunningTest() && !chatterPostInputs.isEmpty()){ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostInputs); }
                  // Send the email to the Authors.
                  if(!Test.isRunningTest() && !emailInputs.isEmpty()){Messaging.sendEmail(emailInputs);  } 
                  
            }
            
            
      }
      
      public void finish(Database.BatchableContext BC){
            
      }
}