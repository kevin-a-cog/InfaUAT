/*
   @created by       : VenkyK
   @created on       : 08/02/2020
   @Purpose          : Knowledge Handler class for LWC.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  15-Oct-2020      |   VenkyK                  |                   |   Initial Version
 |     2      |  11-Jan-2021      |   Sathish R               |                   |   Record Type Value added to the query for Aricle Preview Page
 |     3      |  08-Feb-2021      |   Ranjan                  |                   |
 |     4      |  23-Aug-2021      |   Sathish                 |    I2RT-3607      |   Publishing rights for a group of authors
 |     5      |  23-Aug-2021      |   Sathish                 |    I2RT-1557      |   Enable KB to Access the article using the Article Number in URL
 |     6      |  17-Jan-2022      |   Sathish                 |    I2RT-5132      |   Publishers Group - Workflow Change
 |     7      |  29-Mar-2022      |   Sathish                 |    I2RT-5354      |   Direct Approval for PAM and EOL , Product Release and Support Guide
 |     8      |  17-Apr-2023      | Deeksha Shetty            |    I2RT-8162      |   Article Details not showing up on Parameter articles in preview mode.
 |     9      |  23-May-2023      |   Sathish                 |    I2RT-8361      |   Ability for Publishers to submit articles for Technical Review.
 |     10     |  3-June-2023      |   Sathish                 |    I2RT-8326      |   PROD - KB External Search - In "Article Preview" screen images are not getting displayed to anonymous users if the article status is in Pending Technical Review.
 ****************************************************************************************************
 */

global without sharing class KBLWCHandler {


	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get last Feedback submitted by user
	 *
	 *————————————————————————————————————————————————————
	 * @param    Id
	 * @return   afl__afl_Article_Feedback__c
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static afl__afl_Article_Feedback__c getLastFeedback(Id recid) {
		afl__afl_Article_Feedback__c lastfdback = new afl__afl_Article_Feedback__c();

		for(afl__afl_Article_Feedback__c feedback : [SELECT Id,Like_Dislike__c,afl__Feedback_Status__c,Internal_Feedback_Reason__c,afl__Feedback_Vote_Description__c, createddate from afl__afl_Article_Feedback__c where createdbyid = :userinfo.getuserid() and Knowledge__c = :recid order by createddate desc LIMIT 1]) {
			lastfdback = feedback;
		}
		return lastfdback;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get logged in username
	 *
	 *————————————————————————————————————————————————————
	 * @param    none
	 * @return   username
	 *————————————————————————————————————————————————————
	 **/

	@AuraEnabled
	global static string getloggedusername() {
		system.debug('username'+userinfo.getusername());
		string uservalue = userinfo.getusername();
		return uservalue;
	}
	/**
	 *————————————————————————————————————————————————————
	 * @Description: To check the user existence using Federation Identifier.
	 *
	 *————————————————————————————————————————————————————
	 * @param    fedId
	 * @return   boolean userPresent
	 *————————————————————————————————————————————————————
	 **/

	@AuraEnabled
	global static boolean checkUserExistence(String fedId) {
		boolean userPresent =false;
		if(!String.isBlank(fedId)) {
			List<User> usrLst =  [Select Id from User where federationIdentifier=:fedId and isActive=true];
			if(!usrLst.isEmpty()) {
				userPresent=true;
			}
		}

		return userPresent;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To update existing feedback if the status is still new
	 *
	 *————————————————————————————————————————————————————
	 * @param    Id
	 * @return   NA
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static void updatefeedback(Id fdid, String likevalue, String fdreason, String fdcomments) {
		system.debug('value of fdreason'+fdreason);
		system.debug('value of fdid'+fdid);
		system.debug('value of likevalue'+likevalue);
		system.debug('value of fdcomments'+fdcomments);
		afl__afl_Article_Feedback__c feedback = [SELECT Id,Like_Dislike__c,afl__Feedback_Status__c,Internal_Feedback_Reason__c
		                                         from afl__afl_Article_Feedback__c where Id = :fdid];
		feedback.Like_Dislike__c = likevalue;
		feedback.Internal_Feedback_Reason__c = fdreason;
		feedback.afl__Feedback_Vote_Description__c = fdcomments;
		update feedback;


	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get the recent artilce created or in draft status.
	 *
	 *————————————————————————————————————————————————————
	 * @param    Id
	 * @return   String
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static List<Knowledge__kav> getDraftArticles(Id recId) {

		return [Select Id,isMasterLanguage,publishstatus,KnowledgeArticleId from Knowledge__kav where Id=: recId and publishstatus='Draft'];
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To check logged in user profile.
	 * returns true when logged in user is External Identity user
	 *————————————————————————————————————————————————————
	 * @param    None
	 * @return   Boolean
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	global static Boolean  getloggedinprofile() {
		system.debug('profile Id'+userinfo.getProfileId());
		system.debug('community profile Id'+Label.communityprofid);
		system.debug('guest user profile Id'+Label.guestuserprofile);
		Boolean returnbool = false;
		Boolean iscommunityuser = true;
		String profilename = '';
		try {
			List<User> usrLst =  [SELECT Id,Profile.Name from User where Id = :userinfo.getUserId()];
			if(!usrLst.isEmpty()) {
				profilename = String.valueOf(usrLst[0].Profile.Name).toLowerCase();
				if(profilename.indexOf('community') == -1)
				{
					iscommunityuser = false;
				}
			}
		} catch (Exception e) {
			system.debug('Exception in getloggedinprofile : '+e.getmessage()+e.getlinenumber());
		}
		if(userinfo.getProfileId() == Label.communityprofid || userinfo.getProfileId() == Label.guestuserprofile) {
			system.debug('inside');
			returnbool = true;
		}
		else if(iscommunityuser) {
			returnbool = true;
		}
		return returnbool;

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get logged in suer details.
	 * returns the UsersDetails
	 *————————————————————————————————————————————————————
	 * @param    None
	 * @return   String
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static UserDetailsWrapper  getCurrentUsersDetails() {
		UserDetailsWrapper varUserDetailsWrapper = new UserDetailsWrapper();
		varUserDetailsWrapper.UserType = 'Guest';
		varUserDetailsWrapper.FirstName = '';
		varUserDetailsWrapper.UserName = '';
		varUserDetailsWrapper.UserId = '';
		try{
			varUserDetailsWrapper.UserType = UserInfo.getUserType();
			varUserDetailsWrapper.FirstName = UserInfo.getFirstName();
			varUserDetailsWrapper.UserName = UserInfo.getUserName();
			varUserDetailsWrapper.UserId = UserInfo.getUserId();
		} catch (Exception e) {
			system.debug('Exception in getCurrentUsersDetails : '+e.getmessage()+e.getlinenumber());
		}
		return varUserDetailsWrapper;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get List of relatedkbrecords
	 *
	 *————————————————————————————————————————————————————
	 * @param    String
	 * @return   List
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static List<Related_KB__c> getKBRelatedrecs(String urlname) {


		return [SELECT Id, Referred_In__r.Title,Referred_In__r.URLName FROM Related_KB__c WHERE Referred_In__r.URLName   = : urlname];

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get List of records
	 *
	 *————————————————————————————————————————————————————
	 * @param    NA
	 * @return   List
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled(cacheable=true)
	public static List<Knowledge__kav> getkbList() {
		return [SELECT Id, ArticleNumber,URLName,ValidationStatus,Title FROM Knowledge__kav LIMIT 10];
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To Publish Translation
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static void publishTranslation(String articleId){

		try{
			Knowledge__kav kav = [SELECT Id, KnowledgeArticleId, ValidationStatus, PublishStatus From Knowledge__kav where Id = :articleId];
			//kav.ValidationStatus = 'Published';
			//update kav;
			KbManagement.PublishingService.completeTranslation(articleId);
			//KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, false);
		} catch (Exception e) {
			system.debug('Exception occured while publishing Translation'+e.getmessage()+e.getlinenumber());
		}
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Validate Translation
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static Translatewrapper validateTranslation(String articleId){
		List<String> templiststr = new List<String>();
		Knowledge__kav tempkav = [SELECT Id, KnowledgeArticleId, IsMasterLanguage,ValidationStatus, PublishStatus From Knowledge__kav where Id = :articleId];
		for(Knowledge__kav kb: [Select Id,Language from Knowledge__kav where KnowledgeArticleId = :tempkav.KnowledgeArticleId and IsMasterLanguage != true]) {
			templiststr.add(kb.Language);
		}
		Translatewrapper tw = new Translatewrapper();
		tw.kbrec = tempkav;
		tw.strlist = templiststr;

		return tw;

		//kav.ValidationStatus = 'Published';
		//update kav;
		/*Id idval;
		       Datetime dt;
		       String id = KbManagement.PublishingService.submitForTranslation('kA0S00000004te2KAA', 'ja',  idval, dt);
		       de
		       zh_TW
		       zh_CN*/


	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: Submit for Translation
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static void submittranslation(List<String> lstLanguage, Id kavId){
		System.debug('lstLanguage = ' + lstLanguage);
		System.debug('kavId = ' + kavId);

		try{
			for(String lang: lstLanguage) {
				System.debug('lang = ' + lang);
				translateArticle(kavId, lang);
			}
		}catch(Exception e) {
			System.debug('Exception occured while publishing Translation'+e.getmessage()+e.getlinenumber());
		}
	}

	@Future
	public static void translateArticle(Id kavId, String lang){
		Knowledge__kav sourceKAV = [Select Id, KnowledgeArticleId, IsMasterLanguage, ValidationStatus, PublishStatus,
		                            UrlName, IsVisibleInApp, IsVisibleInCsp, IsVisibleInPkb, IsVisibleInPrm,
		                            Description__c, Solution__c, Additional_Information__c, Internal_Notes__c, Alternate_Questions__c,
		                            Document_Priority__c, Expiration_Date__c, Expiry_Term__c, Industry__c, Keywords__c,
		                            Problem_Type__c, Project_Phases__c, User_Types__c, Primary_Product__c,
		                            Product_Component__c, Product_Version__c, Also_Applies_To__c,Visible_In_Public_Knowledge_Base__c,
		                            Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,
		                            Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,Alternate_Value__c,
		                            Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
		                            From Knowledge__kav
		                            Where Id = :kavId];

		String translatedKAVId = KbManagement.PublishingService.submitForTranslation(sourceKAV.KnowledgeArticleId, lang, null, null);

		Knowledge__kav translatedKAV = new Knowledge__kav(Id=translatedKAVId);
		translatedKAV.UrlName = sourceKAV.UrlName;
		translatedKAV.Description__c = sourceKAV.Description__c;
		translatedKAV.Solution__c = sourceKAV.Solution__c;
		translatedKAV.Additional_Information__c = sourceKAV.Additional_Information__c;
		translatedKAV.Internal_Notes__c = sourceKAV.Internal_Notes__c;
		translatedKAV.Alternate_Questions__c = sourceKAV.Alternate_Questions__c;
		translatedKAV.Document_Priority__c = sourceKAV.Document_Priority__c;
		translatedKAV.Expiration_Date__c = sourceKAV.Expiration_Date__c;
		translatedKAV.Expiry_Term__c = sourceKAV.Expiry_Term__c;
		translatedKAV.Industry__c = sourceKAV.Industry__c;
		translatedKAV.Keywords__c = sourceKAV.Keywords__c;
		translatedKAV.Problem_Type__c = sourceKAV.Problem_Type__c;
		translatedKAV.Project_Phases__c = sourceKAV.Project_Phases__c;
		translatedKAV.User_Types__c = sourceKAV.User_Types__c;
		translatedKAV.Primary_Product__c = sourceKAV.Primary_Product__c;
		translatedKAV.Product_Component__c = sourceKAV.Product_Component__c;
		translatedKAV.Product_Version__c = sourceKAV.Product_Version__c;
		translatedKAV.Also_Applies_To__c = sourceKAV.Also_Applies_To__c;
		translatedKAV.Visible_In_Public_Knowledge_Base__c = sourceKAV.Visible_In_Public_Knowledge_Base__c;

		/*Tag 8 starts*/
		translatedKAV.Parameter_Name__c = sourceKAV.Parameter_Name__c;
		translatedKAV.Definition__c = sourceKAV.Definition__c;
		translatedKAV.Component_Applicable__c = sourceKAV.Component_Applicable__c;
		translatedKAV.Parameter_Data_Type__c = sourceKAV.Parameter_Data_Type__c;
		translatedKAV.Recommended_Value__c = sourceKAV.Recommended_Value__c;
		translatedKAV.Behavior_with_Default_Value__c = sourceKAV.Behavior_with_Default_Value__c;
		translatedKAV.Behavior_with_Alternate_value__c = sourceKAV.Behavior_with_Alternate_value__c;
		translatedKAV.Alternate_Value__c = sourceKAV.Alternate_Value__c;
		translatedKAV.Possible_Error_Symptoms__c = sourceKAV.Possible_Error_Symptoms__c;
		translatedKAV.Error_Signatures__c = sourceKAV.Error_Signatures__c;
		translatedKAV.Steps_to_configure_the_parameter__c = sourceKAV.Steps_to_configure_the_parameter__c;
		translatedKAV.Any_additional_details_like_Screenshots__c = sourceKAV.Any_additional_details_like_Screenshots__c;
		/*Tag 8 ends*/

		translatedKAV.Created_By__c = UserInfo.getUserId();
		translatedKAV.Created_Date__c = System.now();
		translatedKAV.Last_Modified_By__c = UserInfo.getUserId();
		translatedKAV.Last_Modified_Date__c = System.now();
		update translatedKAV;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To retrieve  skills
	 *
	 *————————————————————————————————————————————————————
	 * @param    none
	 * @return   List<ProfileSkill>
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static List<ProfileSkill>  getskills(){


		return [SELECT Id,Name from ProfileSkill];

	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To Update expiry date and publish as same version
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static Id  extendAndPublish(String articleId, String extendterm){

		try{
			Knowledge__kav kav = [SELECT Id, ValidationStatus,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :articleId];
			String id = KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, false);
			system.debug('value of id'+id);
			system.debug('value of before kavid'+kav.Id);
			Knowledge__kav newkav = [SELECT Id, ValidationStatus,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :id];
			system.debug('value of ValidationStatus'+newkav.ValidationStatus);
			system.debug('value of PublishStatus'+newkav.PublishStatus);
			system.debug('value of newkav id'+newkav.Id);
			newkav.Expiry_Term__c = extendterm;
			newkav.ValidationStatus = 'Published';
			update newkav;
			KbManagement.PublishingService.publishArticle(newkav.KnowledgeArticleId, false);
			return newkav.Id;
		} catch (Exception e) {
			system.debug('Exception occured while extending article'+e.getmessage()+e.getlinenumber());
			return null;
		}
	}
	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get all the article versions
	 *
	 *————————————————————————————————————————————————————
	 * @param    articleId
	 * @return   List of Knowledge records
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static List<Knowledge__kav>  getAllArticles(String articleId){

		List<Knowledge__kav> knowledgeLst = new List<Knowledge__kav>();
		Knowledge__kav kav = [SELECT Id, ArticleNumber,UrlName,IsVisibleInPkb,ValidationStatus,Language,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :articleId];
		knowledgeLst = [SELECT Id,Language,ArticleNumber,UrlName,IsVisibleInPkb, ValidationStatus,PublishStatus,KnowledgeArticleId,Is_Pending_TR_Version_Published__c
		                from Knowledge__kav where KnowledgeArticleId = :kav.KnowledgeArticleId and Language = :kav.Language];
		system.debug('value of knowledgeLst'+knowledgeLst);

		return knowledgeLst;
	}
	/**
	 *————————————————————————————————————————————————————
	 * @Description: To check for any draft article present
	 *
	 *————————————————————————————————————————————————————
	 * @param    knowledgeArticleId
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static Boolean  checkForDraftArticle(String knowledgeArticleId,String language){
		boolean draftArticlePresent = false;
		// Knowledge__kav kav = [SELECT Id, ValidationStatus,Language,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :articleId];
		List<Knowledge__kav> knowledgeLst = [SELECT Id, ValidationStatus,PublishStatus,KnowledgeArticleId
		                                     from Knowledge__kav where KnowledgeArticleId = :knowledgeArticleId
		                                                                                    and PublishStatus='Draft' and Language = :language];
		system.debug('value of knowledgeLst'+knowledgeLst);
		if(knowledgeLst.size()>0) {
			draftArticlePresent=true;
			system.debug('inside check of draft articles');
		}
		return draftArticlePresent;
	}

	/**
	 *—————————————————————————— ——————————————————————————
	 * @Description: To Archive Article
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id, Comments
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	/*@AuraEnabled
	   public static void archiveArticle1(String articleId, String comments,String knowledgeArticleId, boolean archiveAll, boolean publishArticlePresent,String language,String publishStatus,boolean pendingTRArticlePresent){
	          system.debug('Inside the archiveArticle');

	          String archiveArticleId;
	          String draftArticleId;
	          Integer articleVersion;
	          Knowledge__kav kav;

	          if(publishStatus=='Online' || publishArticlePresent){

	                        kav = [SELECT Id, ValidationStatus,Title,Article_Type__c,ArticleNumber,Language,PublishStatus,KnowledgeArticleId,
	                        VersionNumber,ArticleNumber from Knowledge__kav
	                        where KnowledgeArticleId = :knowledgeArticleId and Language =:language and PublishStatus ='Online'];

	          }

	          if(!archiveAll && pendingTRArticlePresent){
	                        List<Knowledge__kav>  archivedArticle = [SELECT Id,VersionNumber,KnowledgeArticleId, CreatedDate,Is_Pending_TR_Version_Published__c,publishStatus FROM Knowledge__kav where KnowledgeArticleId=:knowledgeArticleId and IsLatestVersion =false and PublishStatus = 'archived' order By CreatedDate  desc Limit 1];
	                        if(!archivedArticle.isEmpty()){
	                                  archiveArticleId = archivedArticle[0].Id;
	                                  articleVersion =  archivedArticle[0].VersionNumber;
	                        }
	          }

	          if(publishStatus=='Online'){
	                        KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);
	          }

	          if(publishArticlePresent && publishStatus=='Draft' && !pendingTRArticlePresent){
	                        KbManagement.PublishingService.deleteDraftArticle(knowledgeArticleId);
	                        KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);

	          }
	          if(publishArticlePresent && publishStatus=='Draft' && pendingTRArticlePresent && archiveAll){
	                        Approval.unlock(articleId);
	                        KbManagement.PublishingService.deleteDraftArticle(knowledgeArticleId);
	                        KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);

	          }
	          if(publishArticlePresent && publishStatus=='Draft' && pendingTRArticlePresent && !archiveAll){
	                        Approval.unlock(articleId);
	                        system.debug('Inside Pending TR checked');
	                        KbManagement.PublishingService.deleteDraftArticle(knowledgeArticleId);
	                        if(String.isBlank(archiveArticleId)){
	                                  system.debug('Inside Pending TR checked and no archived articles');
	                                  KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);
	                        }

	          }
	          if(!publishArticlePresent && publishStatus=='Draft'){
	                        KbManagement.PublishingService.deleteDraftArticle(knowledgeArticleId);
	          }
	          if(!String.isBlank(archiveArticleId)){
	                        system.debug('article version value'+articleVersion);
	                        //KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);
	                        //draftArticleId = KbManagement.PublishingService.editArchivedArticle(knowledgeArticleId);
	                        draftArticleId = KbManagement.PublishingService.restoreOldVersion(knowledgeArticleId, articleVersion);
	                        system.debug('draft Article Id'+draftArticleId);

	                        Knowledge__kav newkav = [SELECT Id, ValidationStatus,PublishStatus,KnowledgeArticleId from Knowledge__kav where Id = :draftArticleId];
	                        system.debug('value of ValidationStatus'+newkav.ValidationStatus);
	                        system.debug('value of PublishStatus'+newkav.PublishStatus);
	                        system.debug('value of newkav id'+newkav.Id);
	                        newkav.ValidationStatus = 'Published';
	                        update newkav;
	                        KbManagement.PublishingService.publishArticle(newkav.KnowledgeArticleId, false);

	          }

	          if(kav!=null){
	                        system.debug('kav.Article_Type__c,ArticleNumber'+kav.Article_Type__c,ArticleNumber);
	                        system.debug('kav.ArticleNumber'+kav.ArticleNumber);
	                        system.debug('kav.Title'+kav.Title);
	                        system.debug('kav.Id'+kav.Id);
	                        //Knowledge__kav knwRec = [SELECT Id, isDeleted,ValidationStatus,Title,Article_Type__c,ArticleNumber,Language,PublishStatus,KnowledgeArticleId,
	                        //VersionNumber,ArticleNumber from Knowledge__kav where id =:kav.Id   all rows];

	                        // system.debug('new record'+knwRec);
	                        if(!pendingTRArticlePresent){
	                                  afl__afl_Article_Feedback__c af = new afl__afl_Article_Feedback__c();
	                                  af.Knowledge__c = kav.Id;
	                                  // af.afl__Article_Version__c = kav.VersionNumber;
	                                  af.afl__Article_Number__c =  kav.ArticleNumber;
	                                  af.afl__Article_Title__c = kav.Title;
	                                  af.afl__Action_Taken__c = 'Archived the Article';
	                                  af.afl__Knowledge_Article_Version_Id__c = kav.Id;
	                                  af.afl__Article_Link__c = Label.KB_URL + '/' + kav.Id + '/view';
	                                  af.afl__Feedback_Status__c = 'Closed';
	                                  af.Like_Dislike__c = 'None';
	                                  af.afl__Feedback_Source__c = 'Internal';
	                                  af.afl__Feedback_Vote_Description__c = comments;
	                                  af.Feedback_User__c = userinfo.getuserid();
	                                  af.ownerid =  Label.Feedback_Queue;
	                                  af.afl__Record_Type__c = kav.Article_Type__c,ArticleNumber;
	                                  af.Name = kav.Title.left(80);
	                                  INSERT  af;
	                        }

	          }


	   }*/

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To Archive Article
	 *
	 *————————————————————————————————————————————————————
	 * @param    Article Id, Comments
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static void archiveArticle(String articleId, String comments){
		system.debug('Inside the archiveArticle');

		Knowledge__kav kav = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where Id = :articleId];
		afl__afl_Article_Feedback__c af = new afl__afl_Article_Feedback__c();
		af.Knowledge__c = articleId;
		af.afl__Article_Version__c = kav.VersionNumber;
		af.afl__Article_Number__c =  kav.ArticleNumber;
		af.afl__Article_Title__c = kav.Title;
		af.afl__Action_Taken__c = 'Archived the Article';
		af.afl__Knowledge_Article_Version_Id__c = articleId;
		af.afl__Article_Link__c = Label.KB_URL + '/' + articleId + '/view';
		af.afl__Feedback_Status__c = 'Closed';
		af.Like_Dislike__c = 'None';
		af.afl__Feedback_Source__c = 'Internal';
		af.afl__Feedback_Vote_Description__c = comments;
		af.Feedback_User__c = userinfo.getuserid();
		af.ownerid =  Label.Feedback_Queue;
		af.Name = kav.Title.left(80);
		INSERT af;


		KbManagement.PublishingService.archiveOnlineArticle(kav.KnowledgeArticleId, null);


	}
	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get related articles that are not archived
	 *
	 *————————————————————————————————————————————————————
	 * @param    urlname
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static List<Related_KB__c> getRelatedArticles(String articleId, boolean externalUser){

		List<Related_KB__c> relatedKBList = new List<Related_KB__c>();
		List<Related_KB__c> ListOfRelatedKBRecords = new  List<Related_KB__c>();
		if(!String.isBlank(articleId)) {
			if(externalUser) {
				listOfRelatedKBRecords = [Select Id,Referred_Article__r.UrlName,Referred_Article__r.Title,Referred_Article__r.language from Related_KB__c where Referred_In__c = :articleId
				                                                                                                                                                                 and Referred_Article__r.PublishStatus = 'Online' and Referred_Article__r.IsVisibleInPkb = true];
			}else{
				listOfRelatedKBRecords = [Select Id,Referred_Article__r.UrlName,Referred_Article__r.Title,Referred_Article__r.language from Related_KB__c where Referred_In__c = :articleId
				                                                                                                                                                                 and Referred_Article__r.PublishStatus = 'Online'];
			}
		}
		if(!listOfRelatedKBRecords.isEmpty()) {
			for(Related_KB__c relatedKBRecs: listOfRelatedKBRecords)
			{
				relatedKBList.add(relatedKBRecs);
			}
		}
		system.debug('return list'+relatedKBList);
		return relatedKBList;
	}


	/**
	 *————————————————————————————————————————————————————
	 * @Description: used in Article Preview component,KBFeedbackInternal lwc component
	 *
	 *————————————————————————————————————————————————————
	 * @param    articleId
	 * @return   void
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static Knowledge__kav getArticle(String articleId){
		Knowledge__kav article;
		List<Knowledge__kav> lstKAV = [Select Id, Visible_In_Public_Knowledge_Base__c,ArticleNumber,Is_Pending_TR_Version_Published__c,Language,ArticleCreatedDate,is_Current_User_the_Author__c,Article_Type__c,RecordTypeId, Product_Component__c,UrlName,Keywords__c,Problem_Type__c,User_Types__c,Title, KnowledgeArticleId, PublishStatus, ValidationStatus, IsMasterLanguage, LastPublishedDate, Solution__c From Knowledge__kav Where Id = :articleId]; /*<3>*/

		if(!lstKAV.isEmpty()) {
			article = lstKAV.get(0);
		}
		return article;
	}

	@AuraEnabled
	public static Knowledge__kav getArticleForPreview(String kavId){
		Knowledge__kav article;
		/*<2>*/  /*8 - Added Paramter Article fields*/
		List<Knowledge__kav> lstKAV = [Select Id, KnowledgeArticleId, Title,
		                               Description__c, Solution__c, Additional_Information__c, Alternate_Questions__c, Internal_Notes__c,
		                               Primary_Product__c, Product_Version__c, Product_Component__c, Also_Applies_To__c,
		                               Keywords__c, Document_Priority__c, Language, Expiry_Term__c, Industry__c,
		                               Visible_In_Public_Knowledge_Base__c, Problem_Type__c, User_Types__c, Project_Phases__c,
		                               ArticleCreatedDate, Created_by_Formula__c, LastPublishedDate, Last_Modified_By_Formula__c, UrlName,
		                               Article_Type__c,ArticleNumber,Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,
		                               Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,Alternate_Value__c,
		                               Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
		                               From Knowledge__kav
		                               Where Id = :kavId];
		/*</2>*/

		if(!lstKAV.isEmpty()) {
			lstKAV = KBArticleHandler.getProcessedVersionKBImageTag(lstKAV); /*<10>*/
			article = lstKAV.get(0);
		}
		return article;
	}

	@AuraEnabled
	public static Knowledge__kav getArticleByURLName(String urlName, String lang){
		Knowledge__kav article;
		/*<2>*/ /*8 - Added Paramter Article fields*/
		List<Knowledge__kav> lstKAV = [Select Id, KnowledgeArticleId, Title,
		                               Description__c, Solution__c, Additional_Information__c, Alternate_Questions__c, Internal_Notes__c,
		                               Primary_Product__c, Product_Version__c, Product_Component__c, Also_Applies_To__c,
		                               Keywords__c, Document_Priority__c, Language, Expiry_Term__c, Industry__c,
		                               Visible_In_Public_Knowledge_Base__c, Problem_Type__c, User_Types__c, Project_Phases__c,
		                               ArticleCreatedDate, Created_by_Formula__c, LastPublishedDate, Last_Modified_By_Formula__c, UrlName,
		                               Article_Type__c,ArticleNumber,Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,
		                               Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,Alternate_Value__c,
		                               Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
		                               From Knowledge__kav
		                               Where PublishStatus='Online' And ValidationStatus='Pending Technical Review' And Language=:lang And URLName = :urlName];
		/*</2>*/

		if(!lstKAV.isEmpty()) {
			lstKAV = KBArticleHandler.getProcessedVersionKBImageTag(lstKAV); /*<10>*/
			article = lstKAV.get(0);
		}else{
			/*<2>*/ /*8 - Added Paramter Article fields*/
			lstKAV = [Select Id, KnowledgeArticleId, Title,
			          Description__c, Solution__c, Additional_Information__c, Alternate_Questions__c, Internal_Notes__c,
			          Primary_Product__c, Product_Version__c, Product_Component__c, Also_Applies_To__c,
			          Keywords__c, Document_Priority__c, Language, Expiry_Term__c, Industry__c,
			          Visible_In_Public_Knowledge_Base__c, Problem_Type__c, User_Types__c, Project_Phases__c,
			          ArticleCreatedDate, Created_by_Formula__c, LastPublishedDate, Last_Modified_By_Formula__c, UrlName,
			          Article_Type__c,ArticleNumber,Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,
			          Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,Alternate_Value__c,
			          Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
			          From Knowledge__kav
			          Where PublishStatus = 'Draft' And Language=:lang And URLName = :urlName];
			/*</2>*/

			if(!lstKAV.isEmpty()) {
				lstKAV = KBArticleHandler.getProcessedVersionKBImageTag(lstKAV); /*<10>*/
				article = lstKAV.get(0);
			}
		}
		return article;
	}

	@AuraEnabled
	public static Knowledge__kav getArticlePendingTR(String urlName, String lang){
		Knowledge__kav article;
		/*<2>*/
		List<Knowledge__kav> lstKAV = [Select Id, KnowledgeArticleId, Title,
		                               Description__c, Solution__c, Additional_Information__c, Alternate_Questions__c, Internal_Notes__c,
		                               Primary_Product__c, Product_Version__c, Product_Component__c, Also_Applies_To__c,
		                               Keywords__c, Document_Priority__c, Language, Expiry_Term__c, Industry__c,
		                               Visible_In_Public_Knowledge_Base__c, Problem_Type__c, User_Types__c, Project_Phases__c,
		                               ArticleCreatedDate, Created_by_Formula__c, LastPublishedDate, Last_Modified_By_Formula__c, UrlName,
		                               Article_Type__c,ArticleNumber,Parameter_Name__c,Definition__c,Component_Applicable__c,Parameter_Data_Type__c,
		                               Recommended_Value__c,Behavior_with_Default_Value__c,Behavior_with_Alternate_value__c,Alternate_Value__c,
		                               Possible_Error_Symptoms__c,Error_Signatures__c,Steps_to_configure_the_parameter__c,Any_additional_details_like_Screenshots__c
		                               From Knowledge__kav
		                               Where PublishStatus='Online' And Language=:lang And URLName = :urlName];
		/*</2>*/
		if(!lstKAV.isEmpty()) {
			article = lstKAV.get(0);
		}
		return article;
	}

	@AuraEnabled
	public static KB_Follow__c getKBFollow(String articleId, String userId){
		KB_Follow__c kbFollow;
		List<KB_Follow__c> lstKBFollow = [Select Id, Follower__c, Is_Followed__c From KB_Follow__c Where Knowledge_Id__c = :articleId And Follower__c = :userId];
		if(!lstKBFollow.isEmpty()) {
			kbFollow = lstKBFollow.get(0);
		}
		return kbFollow;
	}

	@AuraEnabled
	public static String getKBArticleQualityIndexScore(String articleId){
		String strAQIScore = '0';
		aqi_ltng_mng__Article_Quality__c kbAQI = new aqi_ltng_mng__Article_Quality__c();
		List<aqi_ltng_mng__Article_Quality__c>  lstkbAQI = [Select Id,aqi_ltng_mng__Knowledge_Article_Version_Id__c,aqi_ltng_mng__AQ_Score__c From aqi_ltng_mng__Article_Quality__c Where aqi_ltng_mng__Knowledge_Article_Version_Id__c = :articleId Order By LastModifiedDate desc LIMIT 1];
		if(!lstkbAQI.isEmpty()) {
			kbAQI = lstkbAQI.get(0);
			strAQIScore = String.valueOf(kbAQI.aqi_ltng_mng__AQ_Score__c);
		}
		return strAQIScore;
	}

	@AuraEnabled
	//I2RT-319
	public static List<Help_Item__mdt> getHelpItems(){
		List<Help_Item__mdt> lstHelpItem = [Select Id, Item_Label__c, Link_URL__c, Item_Order__c
		                                    From Help_Item__mdt
		                                    Where Pertains_To__c = 'Knowledge' And Active__c=true
		                                                                                      Order By Item_Order__c];
		return lstHelpItem;
	}

	@AuraEnabled
	public static String getApprovalProcessName(Id kavId){
		Knowledge__kav kb = [Select Id, IsVisibleInPkb, ValidationStatus, PublishStatus, Content_Approved__c,
		                     TR_Approval__c,ArticleCreatedById,Created_By__c,Article_Type__c
		                     From Knowledge__kav Where Id = :kavId];

		System.debug('getApprovalProcessName, validation status - ' + kb.ValidationStatus);
		System.debug('getApprovalProcessName, publish status - ' + kb.PublishStatus);

		String approvalProcessName = '';
		if('Draft'.equals(kb.ValidationStatus)) {

			//Is Current User Direct Approver And Author - Start /*</4>*/
			Boolean IsUserDirectApprover = false;
			Boolean IsUserArticleAuthor = false;
			Boolean IsUserArticleContributor = false;

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Direct Approver Group'];
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
				if(!objGroupMembers.isEmpty())
				{
					IsUserDirectApprover = true;
				}
			}

			if(kb.ArticleCreatedById == UserInfo.getUserId())
			{
				IsUserArticleAuthor = true;
			}

			if((kb.Created_By__c != null) && (kb.Created_By__c == UserInfo.getUserId()))
			{
				IsUserArticleContributor = true;
			}
			//Is Current User Direct Approver And Author - End /*</4>*/

			//Is Current Article if for PAM EOL Support Statement - Start - /*<7>*/
			if((!kb.IsVisibleInPkb) || ((kb.IsVisibleInPkb) && ((kb.Article_Type__c == 'Product Release') || (kb.Article_Type__c == 'Support Guide') || (kb.Article_Type__c == 'PAM EOL Support Statement') || (kb.Article_Type__c == 'RCA')))) {
				approvalProcessName = 'KB_Auto_Approval';
			}
			//Is Current Article if for PAM EOL Support Statement - End -  /*<7>*/
			//Start -  /*<9>*/
			else if((IsUserDirectApprover) && ((IsUserArticleAuthor) || (IsUserArticleContributor)) && (!kb.Content_Approved__c) && (kb.TR_Approval__c))
			{
				approvalProcessName = 'KB_Direct_Approval_Technical_Review';
			}
			//End -  /*<9>*/
			else if((IsUserDirectApprover) && ((IsUserArticleAuthor) || (IsUserArticleContributor)) && (!kb.Content_Approved__c))/*</4>*/
			{
				approvalProcessName = 'KB_Direct_Approval'; /*</4>*/
			}
			else if(!kb.Content_Approved__c) {
				approvalProcessName = 'KB_Content_Review';
			}else if(kb.TR_Approval__c) {
				approvalProcessName = 'KB_Technical_Review';
			}
		}else if('Draft'.equals(kb.PublishStatus)) {
			approvalProcessName = Label.KB_MSG_Review_InProgress;
		}else if('Online'.equals(kb.PublishStatus)) {
			approvalProcessName = Label.KB_MSG_Review_Published;
		}else if('Archived'.equals(kb.PublishStatus)) {
			approvalProcessName = Label.KB_MSG_Review_Archived;
		}
		System.debug('submitted for approval - ' + approvalProcessName);

		return approvalProcessName;
	}

	@AuraEnabled
	public static String submitForReview(Id kavId, String comments){

		system.debug('submitForReview : '+kavId);

		Knowledge__kav kblocal = [Select Id, KnowledgeArticleId,Article_Type__c From Knowledge__kav Where Id = :kavId];//Is Current user is PAM EOL Support Statement Approver - /*<7>*/
		List<Knowledge__kav> currentList = new List<Knowledge__kav>();
		currentList.add(kblocal);

		KnowledgeTriggerHelper helper = new KnowledgeTriggerHelper();

		String returnMsg = '';

		Boolean IsUserValidApprover = helper.validateUser(kblocal);//Is Current user is PAM EOL Support Statement Approver - /*<7>*/

		if(!IsUserValidApprover)
		{
			returnMsg = 'User does not have permission to submit '+ kblocal.Article_Type__c +' article.';
			return returnMsg;
		}

		helper.updateRelatedArticlesReferrenceInKB(currentList);



		Knowledge__kav kb = [Select Id, Title, IsVisibleInPkb,ArticleNumber, Primary_Product__c, ValidationStatus, Content_Approved__c, TR_Approval__c, Is_Tech_Reviewer_Assigned__c,
		                     Rejected_By_Technical_Reviewer__c,Product_Version__c,Product_Component__c
		                     From Knowledge__kav Where Id = :kavId];               //Is Current user is PAM EOL Support Statement Approver - /*<7>*/

		String approvalProcessName = KnowledgeTriggerHelper.getApprovalProcessName(kavId);
		//Start -  /*<9>*/
		Boolean isDAWithTR = false;
		if(approvalProcessName == 'KB_Direct_Approval_Technical_Review')
		{
			isDAWithTR = true;
			approvalProcessName = 'KB_Content_Review';
		}
		//End -  /*<9>*/


		// submit for approval
		System.debug('submitting for approval - ' + approvalProcessName);
		if(!String.isEmpty(approvalProcessName)) {
			returnMsg = KnowledgeTriggerHelper.submitForApproval(kavId, approvalProcessName, comments, UserInfo.getUserId());
			if('KB_Technical_Review'.equals(approvalProcessName)) {
				if('SUCCESS'.equals(returnMsg)) {
					KnowledgeTriggerHelper.postToChatterGroup(kb.Primary_Product__c, kb);
				}
			}
			//Publishers Group - Workflow Change I2RT-5132 - Start /*</6>*/
			if('KB_Direct_Approval'.equals(approvalProcessName)) {
				if('SUCCESS'.equals(returnMsg)) {
					ProcessInstanceWorkitem workItem = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: kavId];
					Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
					req.setComments('content approved!');
					req.setAction('Approve');
					req.setWorkitemId(workItem.Id);
					Approval.process(req);
					returnMsg = 'SUCCESS-D';
				}
			}
			//Publishers Group - Workflow Change I2RT-5132 - End /*</6>*/

			//Start -  /*<9>*/
			if('KB_Content_Review'.equals(approvalProcessName) && (isDAWithTR)) {
				if('SUCCESS'.equals(returnMsg)) {
					returnMsg = KnowledgeTriggerHelper.processDirectApprovalWithTR(kavId);
				}
			}
			//End -  /*<9>*/

		}else{
			returnMsg = 'Nothing to review!';
		}

		return returnMsg;
	}
	/**
	 *————————————————————————————————————————————————————
	 * @Description: to get the positive article feedback for an article record.
	 *
	 *————————————————————————————————————————————————————
	 * @param    kavId
	 * @return   integer
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static integer getPositiveFeedback(Id kavId){
		integer postiveFeedbackCount =0;
		Knowledge__kav knwRec = [Select Id,KnowledgeArticleId from Knowledge__kav where Id=:kavId]; /*<3>*/
		List<afl__afl_Article_Feedback__c> feedbackRecList = [Select Id,Knowledge__c,Like_Dislike__c from afl__afl_Article_Feedback__c where Knowledge__r.KnowledgeArticleId =:knwRec.KnowledgeArticleId and Like_Dislike__c ='Like']; /*<3>*/
		if(!feedbackRecList.isEmpty()) {
			postiveFeedbackCount = feedbackRecList.size();
		}
		return postiveFeedbackCount;
	}

	@AuraEnabled
	public static Boolean getCurrentUserDirectApprover(Id kavId){
		Boolean strResult = false;
		try {
			Knowledge__kav kb = [Select Id, IsVisibleInPkb, ValidationStatus, PublishStatus, Content_Approved__c,
			                     TR_Approval__c,ArticleCreatedById,Created_By__c
			                     From Knowledge__kav Where Id = :kavId];

			//Is Current User Direct Approver And Author - Start /*</4>*/
			Boolean IsUserDirectApprover = false;
			Boolean IsUserArticleAuthor = false;
			Boolean IsUserArticleContributor = false;
			Boolean IsTRApprovalRequired = false;  /*<9>*/

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Direct Approver Group'];
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				List<GroupMember> objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId AND UserOrGroupId = :UserInfo.getUserId()];
				if(!objGroupMembers.isEmpty())
				{
					IsUserDirectApprover = true;
				}
			}

			if(kb.ArticleCreatedById == UserInfo.getUserId())
			{
				IsUserArticleAuthor = true;
			}

			if((kb.Created_By__c != null) && (kb.Created_By__c == UserInfo.getUserId()))
			{
				IsUserArticleContributor = true;
			}

			//Start -  /*<9>*/			
			if(kb.TR_Approval__c)
			{
				IsTRApprovalRequired = true;
			}
			//End -  /*<9>*/

			if((IsUserDirectApprover) && (!IsTRApprovalRequired) && ((IsUserArticleAuthor) || (IsUserArticleContributor)))/*</4>*/
			{
				strResult = true;
			}
			//Is Current User Direct Approver And Author - End /*</4>*/
		} catch (Exception e) {
			system.debug('Exception occured while extending article'+e.getmessage()+e.getlinenumber());
		}
		return strResult;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: to get the actual Urlname using the article number.
	 *
	 *————————————————————————————————————————————————————
	 * @param    kavId
	 * @return   integer
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static String getUrlNameFromArticleNumber(String strArticleNumber){
		String strResult = strArticleNumber;
		try {
			List<Knowledge__kav> kbRec = [SELECT Id,URLName from Knowledge__kav WHERE ArticleNumber =:strArticleNumber ORDER BY createddate desc LIMIT 1];
			if(!kbRec.isEmpty()) {
				strResult = kbRec[0].URLName;
			}
		} catch (Exception e) {
			system.debug('Exception in getUrlNameFromArticleNumber : '+e.getmessage()+e.getlinenumber());
		}
		return strResult;
	}

	@AuraEnabled
	public static string setArticleGDPRComplianceUpvote(string strRecid,string strGDPRFeedbackData){
		String seacrchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter;
		APIKBCGFeedbackResponse apiKBCGFeedbackResponse = new APIKBCGFeedbackResponse();
		apiKBCGFeedbackResponse.ErrorMessage = '';
		apiKBCGFeedbackResponse.APIResponseStatus = '';
		apiKBCGFeedbackResponse.KBCGFeedbackForCheck = '';
		apiKBCGFeedbackResponse.GDPRFeedbackData = null;
		apiKBCGFeedbackResponse.RecordCount = '';

		APIKBCGFeedbackRequest apiKBCGFeedbackRequest = new APIKBCGFeedbackRequest();
		apiKBCGFeedbackRequest.Id = strRecid;
		apiKBCGFeedbackRequest.Data = strGDPRFeedbackData;

		string KBCGFeedbackAPIFlowStatus ='';

		try {
			if(strGDPRFeedbackData != '') {

				//string body = JSON.serialize(objSearchResultMessage,true);
				KBCGFeedbackAPIFlowStatus += '44';


				String contentComplianceCheckEndpoint = Label.KB_GDPR_Feedback_URL;

				KBCGFeedbackAPIFlowStatus += '95'+ contentComplianceCheckEndpoint;

				KBCGFeedbackAPIFlowStatus += '48';

				HttpRequest req = new HttpRequest();
				req.setEndpoint(contentComplianceCheckEndpoint);
				req.setMethod('POST');
				req.setHeader('Content-Type', 'application/json');
				string body = JSON.serialize(apiKBCGFeedbackRequest,true);
				req.setHeader('Content-Length', String.valueOf(body.length()));
				req.setBody(body);
				req.setTimeout(60000);
				apiKBCGFeedbackResponse.KBCGFeedbackForCheck = body;

				KBCGFeedbackAPIFlowStatus += '54';



				Http http = new Http();
				if(strGDPRFeedbackData != 'NONE')
				{
					HTTPResponse res = http.send(req);
					try {
						apiKBCGFeedbackResponse.APIResponseStatus = 'SUCCESS';
						apiKBCGFeedbackResponse.GDPRFeedbackData = res.getBody();
					} catch(Exception e) {

						apiKBCGFeedbackResponse.APIResponseStatus = 'ERROR';
						apiKBCGFeedbackResponse.ErrorMessage = e.getMessage();
						apiKBCGFeedbackResponse.GDPRFeedbackData = '';
					}
				}
				KBCGFeedbackAPIFlowStatus += '72';


				apiKBCGFeedbackResponse.KBCGFeedbackAPIFlowStatus = KBCGFeedbackAPIFlowStatus;
			}else {

			}
		} catch(Exception e) {

			apiKBCGFeedbackResponse.APIResponseStatus = 'ERROR';
			apiKBCGFeedbackResponse.ErrorMessage = e.getMessage();
			apiKBCGFeedbackResponse.KBCGFeedbackAPIFlowStatus = KBCGFeedbackAPIFlowStatus;
			system.debug('ERROR ' + e.getMessage());


		}
		return JSON.serialize(apiKBCGFeedbackResponse);
	}




	public class NavigationBarData {
	@AuraEnabled public String id;
	@AuraEnabled public String navBarItem;
	@AuraEnabled public String DeveloperName;
	@AuraEnabled public String link;
	@AuraEnabled public String title;
	@AuraEnabled public String description;
	@AuraEnabled public boolean ShowDivider;
	@AuraEnabled public boolean multiLevel;
	@AuraEnabled public Level2wrapper level2;
	}
	public class Level2wrapper {
	@AuraEnabled public boolean image;
	@AuraEnabled public String title;
	@AuraEnabled public String link;
	@AuraEnabled public String description;
	@AuraEnabled public String target;
	@AuraEnabled public List<DataLinksWrapper> datalinks;
	@AuraEnabled public List<FeaturedLinksWrapper> featuredLinks;
	@AuraEnabled public List<RegularLinksWrapper> regularLinks;

	}
  
	public class DataLinksWrapper {
	@AuraEnabled public boolean image = false;
	@AuraEnabled public String title;
	@AuraEnabled public String link;
	@AuraEnabled public String description;
	@AuraEnabled public String target;
	@AuraEnabled public boolean showLockIcon;
	}
  
	public class FeaturedLinksWrapper {
	@AuraEnabled public boolean image = false;
	@AuraEnabled public String title;
	@AuraEnabled public String link;
	@AuraEnabled public String description;
	@AuraEnabled public String target;
	@AuraEnabled public boolean authenticated = false;
	@AuraEnabled public boolean showLockIcon;
	}
  
	public class RegularLinksWrapper {
	@AuraEnabled public boolean image = false;
	@AuraEnabled public String title;
	@AuraEnabled public String link;
	@AuraEnabled public String target;
	@AuraEnabled public boolean showLockIcon;
	}
  
  
	/*
	   @AuraEnabled
	   public static String getKBRelatedrecs() {
  
		  List<KBWrapper> kbreclist = new List<KBWrapper>();
  
		  for(Related_KB__c relkb: [SELECT Id, Referred_Article_Name__c FROM Related_KB__c WHERE Referred_In__c   = 'ka0S0000000FHJnIAO']){
				KBWrapper kbrec = new KBWrapper();
				kbrec.idval = relkb.Id;
				kbrec.Name = relkb.Referred_Article_Name__c;
				kbreclist.add(kbrec);
		  }
  
		  Returnrecs res = new Returnrecs();
		  res.kbrecli = kbreclist;
		  res.returnval = 'relatedkbs';
		  //system.debug('serialize'+JSON.serialize(kbreclist));
		  //return JSON.serialize(kbrec);
		  return JSON.Serialize(res);
	   }
  
	   public class Returnrecs {
		  @AuraEnabled
		  public String returnval;
		  @AuraEnabled
		  public List<KBWrapper> kbrecli = new List<KBWrapper>();
	   }*/
  
	public class Translatewrapper {
	@AuraEnabled
	public Knowledge__kav kbrec;
	@AuraEnabled
	public List<String> strlist;
  
	}
  
	public class UserDetailsWrapper {
	@AuraEnabled
	public String UserName;
	@AuraEnabled
	public String FirstName;
	@AuraEnabled
	public String UserType;
	@AuraEnabled
	public String UserId;
	}
  
	public class APIKBCGFeedbackResponse
	{
	public string GDPRFeedbackData { get; set; }
	public string ErrorMessage { get; set; }
	public string APIResponseStatus { get; set; }
	public string KBCGFeedbackAPIFlowStatus { get; set; }
	public string KBCGFeedbackForCheck { get; set; }
	public string RecordCount { get; set; }
	}
  
	public class APIKBCGFeedbackRequest
	{
		public string Id { get; set; }
		public string Data { get; set; }  
	}
	
}