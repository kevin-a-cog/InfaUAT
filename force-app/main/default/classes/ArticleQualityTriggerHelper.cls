/*
@created by       : balajip
@created on       : 07/27/2020
@Purpose          : Article Quality trigger handler helper class.
@Testclass        : 
@JIRA             : 


Change History

****************************************************************************************************
|   Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|    1      |  27-Jan-2021      |   Ranjan                  |    I2RT-767       |   Check GDPR Compliance 
****************************************************************************************************
*/
public class ArticleQualityTriggerHelper {
      
      /**
      *————————————————————————————————————————————————————
      * @Description: 
      * 
      *————————————————————————————————————————————————————
      * @param    New and old map
      * @return   void
      *————————————————————————————————————————————————————
      **/
      public void updateRelatedArticles(Map<Id, aqi_ltng_mng__Article_Quality__c> newMap) {
            Map<String, Id> mapArticleIdToAQId = new Map<String, Id>();
            
            Set<Id> setArticleId = new Set<Id>();
            for(aqi_ltng_mng__Article_Quality__c  articleQuality: newMap.values()){
                  System.debug('TR Approval' + articleQuality.TR_Approval_Required__c);
                  
                  setArticleId.add(articleQuality.aqi_ltng_mng__Knowledge_Article_Id__c);
                  mapArticleIdToAQId.put(articleQuality.aqi_ltng_mng__Knowledge_Article_Id__c, articleQuality.Id);
            }
            
            List<Knowledge__kav> lstKAVToUpdate = new List<Knowledge__kav>();
            for(Knowledge__kav kb : [Select Id, KnowledgeArticleId From Knowledge__kav Where KnowledgeArticleId in :setArticleId And PublishStatus='Draft' And IsMasterLanguage=True]){
                  aqi_ltng_mng__Article_Quality__c articleQuality = newMap.get(mapArticleIdToAQId.get(kb.KnowledgeArticleId));
                  
                  kb.TR_Approval__c = articleQuality.TR_Approval_Required__c;
                  kb.AQI_Score__c = articleQuality.aqi_ltng_mng__AQ_Score__c;
                  kb.Content_Update__c= articleQuality.Content_Update__c;
                  kb.GDPR_Acknowledgement_by_CR__c = articleQuality.Is_the_content_clear__c; /* Tag 1 */
                  lstKAVToUpdate.add(kb);
            }
            
            if(!lstKAVToUpdate.isEmpty()){
                  update lstKAVToUpdate;
            }
      }
}