/*
   @created by       : balajip
   @created on       : 07/27/2020
   @Purpose          : Knowledge handler class.
   @Testclass        :
   @JIRA :


   Change History

 ****************************************************************************************************
 |  Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |   1      |  27-Jan-2021      |   Ranjan                  |    I2RT-767       |   Check GDPR Compliance flag
 |   2      |  09-Apr-2021      |   Sathish                 |    I2RT-1887      |   Rejected articles are displayed in search (Internal & External)
 |   3      |  23-Aug-2021      |   Sathish                 |    I2RT-557       |   URLName will be replaced with ArticleNumber
 |   4      |  29-Mar-2022      |   Sathish                 |    I2RT-5354      |   Direct Approval for PAM and EOL , Product Release and Support Guide
 |   5      |  25-Jul-2022      |   Deeksha Shetty          |    I2RT-6524      |   Additional double Quote (“) or semi-colon (;) is getting added in the article
 ****************************************************************************************************
 */

public class KnowledgeTriggerHandler extends TriggerHandler {

//Iniitialize the helper method to be called
	private KnowledgeTriggerHelper helper = new KnowledgeTriggerHelper();

//Methods related to the module to be called in before insert context
	public override void beforeInsert() {
		// system.debug('KnowledgeTriggerHandler : beforeInsert');
		//helper.validateLanguage((List<Knowledge__kav>) newList, null);
		//helper.validateAuthor((List<Knowledge__kav>) newList); //Is Current User PAM EOL Approver - /*<4>*/
		helper.validateProduct((List<Knowledge__kav>) newList);
		helper.resetFieldValues((List<Knowledge__kav>) newList, null);
		helper.setValues((List<Knowledge__kav>) newList, null);
		helper.checkContributedKBField((List<Knowledge__kav>) newList);
		helper.captureGDPRData((List<Knowledge__kav>) newList, null);
		helper.checkCharAppendBeforeInsertOrUpdate((List<Knowledge__kav>) newList,null,null,true);   /* Tag 5 */

	}

//Methods related to the module to be called in after insert context
	public override void afterInsert() {
		// system.debug('KnowledgeTriggerHandler : afterInsert');
		helper.updateDataCategories((Map<Id, Knowledge__kav>) newMap, null);
		helper.copyRelatedArticlesReferrenceInKB((List<Knowledge__kav>) newList, null);
		helper.copyFiles((List<Knowledge__kav>) newList, null);
		helper.updateURLName((List<Knowledge__kav>) newList, null);
		// helper.relatePublishedArticle((Map<Id, Knowledge__kav>) newMap);
		//helper.managetopics((Map<Id, Knowledge__kav>) newMap, null);

	}

//Methods related to the module to be called in before update context
	public override void beforeUpdate() {
		// system.debug('KnowledgeTriggerHandler : beforeUpdate');
		helper.validateAQI((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
		helper.validateProduct((List<Knowledge__kav>) newList);
		helper.resetURLName((List<Knowledge__kav>) newList, (Map<Id, Knowledge__kav>) oldMap);
		helper.setValues((List<Knowledge__kav>) newList, (Map<Id, Knowledge__kav>) oldMap);
		helper.captureReviewer((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
		helper.captureGDPRAcknowledgement((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap); /* Tag 1 */
		helper.updateArticleData((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
		helper.checkCharAppendBeforeInsertOrUpdate((List<Knowledge__kav>) newList,(Map<Id, Knowledge__kav>) oldMap,(Map<Id, Knowledge__kav>) newMap,false);   /* Tag 5 */
	}

//Methods related to the module to be called in after update context
	public override void afterUpdate() {
		// system.debug('KnowledgeTriggerHandler : afterUpdate');
		helper.updateDataCategories((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
		//helper.managetopics((Map<Id, Knowledge__kav>) newMap, null);
		helper.processApproval((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
		helper.processArchival((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);          /* Tag 2 */
		helper.processAutoApproval((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap); /* Tag 2 */
		helper.shareFiles((Map<Id, Knowledge__kav>) newMap, (Map<Id, Knowledge__kav>) oldMap);
	}
}