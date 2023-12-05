/*
   @created by       : SathishR
   @created on       : 24/03/2021
   @Purpose          : Knowledge Content Governance class for LWC.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by                |  Jira reference   |   ChangesMade
 |     1      |  15-Oct-2020      |   Sathish R                 |                   |   Initial Version
 |     2      |  15-May-2023      |   Sathish R                 |      I2RT-8342    |   Pass KB Primary product to Article Content Quality Check API call.
 ****************************************************************************************************
 */

global without sharing class KBContentGovernance {

	@AuraEnabled
	public static string getArticleGDPRCompliance(string recid){
		String seacrchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter;
		APIKBContentGovernanceResponse apiKBContentGovernanceResponse = new APIKBContentGovernanceResponse();
		apiKBContentGovernanceResponse.ErrorMessage = '';
		apiKBContentGovernanceResponse.APIResponseStatus = '';
		apiKBContentGovernanceResponse.KBContentForGDPRCheck = '';
		apiKBContentGovernanceResponse.GDPRData = null;
		apiKBContentGovernanceResponse.GDPRFeedbackData = null;
		apiKBContentGovernanceResponse.RecordCount = '';

		APIKBContentGovernanceRequest apiKBContentGovernanceRequest = new APIKBContentGovernanceRequest();
		apiKBContentGovernanceRequest.Title = 'NONE';
		apiKBContentGovernanceRequest.Solution = 'NONE';
		apiKBContentGovernanceRequest.Description = 'NONE';
		apiKBContentGovernanceRequest.Additional_Information = 'NONE';
		apiKBContentGovernanceRequest.Keywords = 'NONE';
		apiKBContentGovernanceRequest.Record_Type = 'NONE';
		apiKBContentGovernanceRequest.Problem_Type = 'NONE';

		KBFeedbackData objKBFeedbackData = new KBFeedbackData();
		objKBFeedbackData.Title = 'NONE';
		objKBFeedbackData.Solution = 'NONE';
		objKBFeedbackData.Description = 'NONE';
		objKBFeedbackData.Additional_Information = 'NONE';
		objKBFeedbackData.Keywords = 'NONE';
		objKBFeedbackData.Problem_Type = 'NONE';

		objKBFeedbackData.Id = 'NONE';
		objKBFeedbackData.GDPR_Compliance_Data_On_Upvote = 'NONE';
		objKBFeedbackData.Is_Upvoted_As_Noise_Words = 'NONE';
		objKBFeedbackData.LastModifiedDate = 'NONE';
		objKBFeedbackData.CreatedDate = 'NONE';
		objKBFeedbackData.IsDeleted = 'NONE';
		objKBFeedbackData.RecordTypeName = 'NONE';
		objKBFeedbackData.PublishStatus = 'NONE';
		objKBFeedbackData.ValidationStatus = 'NONE';
		objKBFeedbackData.Visible_In_Public_Knowledge_Base_c = 'NONE';
		objKBFeedbackData.VersionNumber = 'NONE';
		objKBFeedbackData.Language = 'NONE';
		objKBFeedbackData.Product = 'NONE';//<2>

		string KBContentGovernanceAPIFlowStatus ='';

		try {
			if(recid != null) {
				knowledge__kav kbarticle = [SELECT Id, Solution__c,Title,urlName,Additional_Information__c,Keywords__c,Description__c,Problem_Type__c,RecordType.Name,PublishStatus,ValidationStatus,VersionNumber,Language,Visible_In_Public_Knowledge_Base__c,Primary_Product__c from knowledge__kav where Id = :recid];//<2>

				//string body = JSON.serialize(objSearchResultMessage,true);
				KBContentGovernanceAPIFlowStatus += '44';
				apiKBContentGovernanceRequest.Title = kbarticle.Title;
				apiKBContentGovernanceRequest.Title = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Title,'UTF-8').replace('+', '%20');
				objKBFeedbackData.Title = apiKBContentGovernanceRequest.Title;
				if(kbarticle.Solution__c != null)
				{
					apiKBContentGovernanceRequest.Solution = String.valueOf(kbarticle.Solution__c).stripHtmlTags();
					apiKBContentGovernanceRequest.Solution = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Solution,'UTF-8').replace('+', '%20');
					objKBFeedbackData.Solution = apiKBContentGovernanceRequest.Solution;
				}

				if(kbarticle.Description__c != null)
				{
					apiKBContentGovernanceRequest.Description = String.valueOf(kbarticle.Description__c).stripHtmlTags();
					apiKBContentGovernanceRequest.Description = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Description,'UTF-8').replace('+', '%20');
					objKBFeedbackData.Description = apiKBContentGovernanceRequest.Description;
				}

				if(kbarticle.Additional_Information__c != null)
				{
					apiKBContentGovernanceRequest.Additional_Information = String.valueOf(kbarticle.Additional_Information__c).stripHtmlTags();
					apiKBContentGovernanceRequest.Additional_Information = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Additional_Information,'UTF-8').replace('+', '%20');
					objKBFeedbackData.Additional_Information = apiKBContentGovernanceRequest.Additional_Information;
				}

				if(kbarticle.Keywords__c != null)
				{
					apiKBContentGovernanceRequest.Keywords = String.valueOf(kbarticle.Keywords__c);
					apiKBContentGovernanceRequest.Keywords = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Keywords,'UTF-8').replace('+', '%20');
					objKBFeedbackData.Keywords = apiKBContentGovernanceRequest.Keywords;
				}


				if(kbarticle.RecordType.Name != null)
				{
					apiKBContentGovernanceRequest.Record_Type = String.valueOf(kbarticle.RecordType.Name);
					objKBFeedbackData.RecordTypeName = apiKBContentGovernanceRequest.Record_Type;
				}

				if(kbarticle.Problem_Type__c != null)
				{
					apiKBContentGovernanceRequest.Problem_Type = String.valueOf(kbarticle.Problem_Type__c);
					objKBFeedbackData.Problem_Type = apiKBContentGovernanceRequest.Problem_Type;
				}
				//<2>
				if(kbarticle.Primary_Product__c != null)
				{
					apiKBContentGovernanceRequest.Product = String.valueOf(kbarticle.Primary_Product__c);
					objKBFeedbackData.Product = apiKBContentGovernanceRequest.Product;
				}
				//</2>

				if(kbarticle.Id != null)
				{
					objKBFeedbackData.Id = String.valueOf(kbarticle.Id);
					objKBFeedbackData.Upvoted_By = String.valueOf(UserInfo.getUserId());
					objKBFeedbackData.Upvoted_By_Name = String.valueOf(UserInfo.getUserName());
					objKBFeedbackData.Is_Upvoted_As_Noise_Words = 'True';
				}

				if(kbarticle.PublishStatus != null)
				{
					objKBFeedbackData.PublishStatus = String.valueOf(kbarticle.PublishStatus);
				}

				if(kbarticle.ValidationStatus != null)
				{
					objKBFeedbackData.ValidationStatus = String.valueOf(kbarticle.ValidationStatus);
				}

				if(kbarticle.Language != null)
				{
					objKBFeedbackData.Language = String.valueOf(kbarticle.Language);
				}

				if(kbarticle.VersionNumber != null)
				{
					objKBFeedbackData.VersionNumber = String.valueOf(kbarticle.VersionNumber);
				}

				if(kbarticle.Visible_In_Public_Knowledge_Base__c != null)
				{
					objKBFeedbackData.Visible_In_Public_Knowledge_Base_c = String.valueOf(kbarticle.Visible_In_Public_Knowledge_Base__c);
				}

				String contentComplianceCheckEndpoint = Label.KB_GDPR_Compliance_URL;

				KBContentGovernanceAPIFlowStatus += '95'+ contentComplianceCheckEndpoint;

				KBContentGovernanceAPIFlowStatus += '48';

				HttpRequest req = new HttpRequest();
				req.setEndpoint(contentComplianceCheckEndpoint);
				req.setMethod('POST');
				req.setHeader('Content-Type', 'application/json');
				string body = JSON.serialize(apiKBContentGovernanceRequest,true);
				req.setHeader('Content-Length', String.valueOf(body.length()));
				req.setBody(body);
				req.setTimeout(60000);
				apiKBContentGovernanceResponse.KBContentForGDPRCheck = body;

				KBContentGovernanceAPIFlowStatus += '54';



				Http http = new Http();
				HTTPResponse res = http.send(req);
				try {
					apiKBContentGovernanceResponse.APIResponseStatus = 'SUCCESS';
					apiKBContentGovernanceResponse.GDPRData = res.getBody();
					//objKBFeedbackData.GDPR_Compliance_Data_On_Upvote = res.getBody();
					objKBFeedbackData.GDPR_Compliance_Data_On_Upvote = '';
					//String strBody = '{\"RESTResponse\":{\"headers\":{\"header\":[\"\",\"\",\"\",\"\",\"\",\"\",\"\"]},\"payload\":\"{\\\"Data\\\":[{\\\"Type\\\":\\\"GDPRCompliace\\\",\\\"Title\\\":\\\"Compliance Violation\\\",\\\"Output\\\":{\\\"IP Address\\\":{\\\"Keywords\\\":[\\\"182.168.1.255\\\"],\\\"Recommendation\\\":\\\"Replace with 1.1.1.1\\\",\\\"Violations\\\":\\\"Title\\\"},\\\"Is_Violated\\\":1}},{\\\"Type\\\":\\\"ContentStandardChecks\\\",\\\"Title\\\":\\\"Content Standard Checks\\\",\\\"Output\\\":{\\\"HTML_Output\\\":\\\"%3Ctable%0A%20%20%20%20style%3D%22width%3A100%25%3Bline-height%3A14px%3Bwidth%3A%20100%25%3Bline-height%3A14px%3B-webkit-border-radius%3A%208px%3B-moz-border-radius%3A%208px%3Boverflow%3Ahidden%3Bborder-radius%3A%209px%3B-pie-background%3A%20linear-gradient%28%23ece9d8%2C%20%23E5ECD8%29%3Bbox-shadow%3A%20%23666%200px%202px%203px%3Bbehavior%3A%20url%28Include%2FPIE.htc%29%3Bborder-color%3A%20white%20%21important%3Boverflow%3A%20hidden%3B%22%3E%0A%20%20%20%20%3Ctbody%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Article%20Section%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Guidelines%3C%2Ftd%3E%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Example%20Recommendation%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EPrefix%20according%20to%20the%20Template%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EFAQ%3A%20What%20is%20%E2%80%A6.%20in%20%26lt%3Bproduct%20name%26gt%3B%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%2C%20Description%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EAdd%20the%20error%20message%20in%20the%20title%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EERROR%3A%20%26lt%3BError%20message%26gt%3B%20while%20running%20%E2%80%A6...%20In%20%26lt%3Bproduct%20name%26gt%3B%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EReplace%20%22I%2FYou%2FWe%22%20with%20generic%20reference%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EReplace%20%22Can%20I%20Install%20%E2%80%A6%20%3F%22%20WITH%20%22Is%20it%20possible%20to%20install%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%3C%2Ftr%3E%0A%20%20%20%20%3C%2Ftbody%3E%0A%3C%2Ftable%3E\\\"}},{\\\"Type\\\":\\\"DidYouKnow\\\",\\\"Title\\\":\\\"Did You Know\\\",\\\"Output\\\":{\\\"HTML_Output\\\":\\\"%3Ctable%0A%20%20%20%20style%3D%22width%3A100%25%3Bline-height%3A14px%3Bwidth%3A%20100%25%3Bline-height%3A14px%3B-webkit-border-radius%3A%208px%3B-moz-border-radius%3A%208px%3Boverflow%3Ahidden%3Bborder-radius%3A%209px%3B-pie-background%3A%20linear-gradient%28%23ece9d8%2C%20%23E5ECD8%29%3Bbox-shadow%3A%20%23666%200px%202px%203px%3Bbehavior%3A%20url%28Include%2FPIE.htc%29%3Bborder-color%3A%20white%20%21important%3Boverflow%3A%20hidden%3B%22%3E%0A%20%20%20%20%3Ctbody%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Article%20Section%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Guidelines%3C%2Ftd%3E%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20style%3D%22border%3A%200px%20solid%20%23919191%3B%20background%3A%20var%28--lwc-colorBackgroundButtonDefaultActive%2Crgb%28243%2C%20242%2C%20242%29%29%3B%20font-weight%3A600%3B%20font-size%3A14px%3B%22%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20Example%20Recommendation%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EPrefix%20according%20to%20the%20Template%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EFAQ%3A%20What%20is%20%E2%80%A6.%20in%20%26lt%3Bproduct%20name%26gt%3B%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%2C%20Description%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EAdd%20the%20error%20message%20in%20the%20title%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EERROR%3A%20%26lt%3BError%20message%26gt%3B%20while%20running%20%E2%80%A6...%20In%20%26lt%3Bproduct%20name%26gt%3B%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%20%20%20%20%20%20%20%20%20%20%20%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3ETitle%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EReplace%20%22I%2FYou%2FWe%22%20with%20generic%20reference%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%20%20%20%20%3Ctd%20style%3D%22border%3A%200px%20solid%20%23919191%3B%22%3EReplace%20%22Can%20I%20Install%20%E2%80%A6%20%3F%22%20WITH%20%22Is%20it%20possible%20to%20install%3C%2Ftd%3E%0A%20%20%20%20%20%20%20%20%3C%2Ftr%3E%0A%20%20%20%20%20%20%20%20%3Ctr%3E%3C%2Ftr%3E%0A%20%20%20%20%3C%2Ftbody%3E%0A%3C%2Ftable%3E\\\"},\\\"Is_Violated\\\":1}}]}\"}}';
					//apiKBContentGovernanceResponse.GDPRData = strBody;

					apiKBContentGovernanceResponse.GDPRFeedbackData = JSON.serialize(objKBFeedbackData);


				} catch(Exception e) {

					apiKBContentGovernanceResponse.APIResponseStatus = 'ERROR';
					apiKBContentGovernanceResponse.ErrorMessage = e.getMessage();
					apiKBContentGovernanceResponse.GDPRData = '';
					objKBFeedbackData.GDPR_Compliance_Data_On_Upvote = '';
					apiKBContentGovernanceResponse.GDPRFeedbackData = JSON.serialize(objKBFeedbackData);


				}
				KBContentGovernanceAPIFlowStatus += '72';


				apiKBContentGovernanceResponse.KBContentGovernanceAPIFlowStatus = KBContentGovernanceAPIFlowStatus;
			}else {

			}
		} catch(Exception e) {

			apiKBContentGovernanceResponse.APIResponseStatus = 'ERROR';
			apiKBContentGovernanceResponse.ErrorMessage = e.getMessage();
			apiKBContentGovernanceResponse.KBContentGovernanceAPIFlowStatus = KBContentGovernanceAPIFlowStatus;
			system.debug('ERROR ' + e.getMessage());


		}
		return JSON.serialize(apiKBContentGovernanceResponse);
	}

	
	public static string getArticleGDPRComplianceInitial(string strTitle,string strSolution,string strDescription,string strAdditionalInformation,string strKeywords,string strRecordTypeName,string strProblemType,string strProduct){
		String seacrchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter;
		APIKBContentGovernanceResponse apiKBContentGovernanceResponse = new APIKBContentGovernanceResponse();
		apiKBContentGovernanceResponse.ErrorMessage = '';
		apiKBContentGovernanceResponse.APIResponseStatus = '';
		apiKBContentGovernanceResponse.KBContentForGDPRCheck = '';
		apiKBContentGovernanceResponse.GDPRData = null;
		apiKBContentGovernanceResponse.RecordCount = '';

		APIKBContentGovernanceRequest apiKBContentGovernanceRequest = new APIKBContentGovernanceRequest();
		apiKBContentGovernanceRequest.Title = 'NONE';
		apiKBContentGovernanceRequest.Solution = 'NONE';
		apiKBContentGovernanceRequest.Description = 'NONE';
		apiKBContentGovernanceRequest.Additional_Information = 'NONE';
		apiKBContentGovernanceRequest.Keywords = 'NONE';
		// apiKBContentGovernanceRequest.Internal_Notes = 'NONE';
		// apiKBContentGovernanceRequest.Alternate_Questions = 'NONE';


		string KBContentGovernanceAPIFlowStatus ='';

		try {
			if(strTitle != null) {


				//string body = JSON.serialize(objSearchResultMessage,true);
				KBContentGovernanceAPIFlowStatus += '44';
				apiKBContentGovernanceRequest.Title = strTitle;
				apiKBContentGovernanceRequest.Title = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Title,'UTF-8').replace('+', '%20');
				if(strSolution != null)
				{
					apiKBContentGovernanceRequest.Solution = String.valueOf(strSolution).stripHtmlTags();
					apiKBContentGovernanceRequest.Solution = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Solution,'UTF-8').replace('+', '%20');
				}

				if(strDescription != null)
				{
					apiKBContentGovernanceRequest.Description = String.valueOf(strDescription).stripHtmlTags();
					apiKBContentGovernanceRequest.Description = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Description,'UTF-8').replace('+', '%20');
				}

				if(strAdditionalInformation != null)
				{
					apiKBContentGovernanceRequest.Additional_Information = String.valueOf(strAdditionalInformation).stripHtmlTags();
					apiKBContentGovernanceRequest.Additional_Information = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Additional_Information,'UTF-8').replace('+', '%20');
				}

				if(strKeywords != null)
				{
					apiKBContentGovernanceRequest.Keywords = String.valueOf(strKeywords);
					apiKBContentGovernanceRequest.Keywords = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Keywords,'UTF-8').replace('+', '%20');
				}

				if(strRecordTypeName != null)
				{
					apiKBContentGovernanceRequest.Record_Type = String.valueOf(strRecordTypeName);
				}

				if(strProblemType != null)
				{
					apiKBContentGovernanceRequest.Problem_Type = String.valueOf(strProblemType);
				}

				//</2>
				if(strProduct != null)
				{
					apiKBContentGovernanceRequest.Product = String.valueOf(strProduct);
					apiKBContentGovernanceRequest.Product = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Product,'UTF-8').replace('+', '%20');
				}
				//</2>

				// if(kbarticle.Internal_Notes__c != null)
				// {
				// 	apiKBContentGovernanceRequest.Internal_Notes = String.valueOf(kbarticle.Internal_Notes__c).stripHtmlTags();
				// 	//apiKBContentGovernanceRequest.Internal_Notes = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Internal_Notes,'UTF-8').replace('+', '%20');
				// }

				// if(kbarticle.Alternate_Questions__c != null)
				// {
				// 	apiKBContentGovernanceRequest.Alternate_Questions = String.valueOf(kbarticle.Alternate_Questions__c);
				// 	//apiKBContentGovernanceRequest.Alternate_Questions = EncodingUtil.urlEncode(apiKBContentGovernanceRequest.Alternate_Questions,'UTF-8').replace('+', '%20');
				// }




				String contentComplianceCheckEndpoint = Label.KB_GDPR_Compliance_URL;



				KBContentGovernanceAPIFlowStatus += '48';

				HttpRequest req = new HttpRequest();
				req.setEndpoint(contentComplianceCheckEndpoint);
				req.setMethod('POST');
				req.setHeader('Content-Type', 'application/json');
				string body = JSON.serialize(apiKBContentGovernanceRequest,true);
				req.setHeader('Content-Length', String.valueOf(body.length()));
				req.setBody(body);
				apiKBContentGovernanceResponse.KBContentForGDPRCheck = body;

				KBContentGovernanceAPIFlowStatus += '54';



				// Http http = new Http();
				// HTTPResponse res = http.send(req);
				// try {
				// 	apiKBContentGovernanceResponse.APIResponseStatus = 'SUCCESS';
				// 	apiKBContentGovernanceResponse.GDPRData = res.getBody();


				// } catch(Exception e) {

				// 	apiKBContentGovernanceResponse.APIResponseStatus = 'ERROR';
				// 	apiKBContentGovernanceResponse.ErrorMessage = e.getMessage();
				// 	apiKBContentGovernanceResponse.GDPRData = '';


				// }
				KBContentGovernanceAPIFlowStatus += '72';


				apiKBContentGovernanceResponse.KBContentGovernanceAPIFlowStatus = KBContentGovernanceAPIFlowStatus;
			}else {

			}
		} catch(Exception e) {

			apiKBContentGovernanceResponse.APIResponseStatus = 'ERROR';
			apiKBContentGovernanceResponse.ErrorMessage = e.getMessage();
			apiKBContentGovernanceResponse.KBContentGovernanceAPIFlowStatus = KBContentGovernanceAPIFlowStatus;
			system.debug('ERROR ' + e.getMessage());


		}
		return apiKBContentGovernanceResponse.KBContentForGDPRCheck;
	}


	public class APIKBContentGovernanceResponse
	{
	public string GDPRData { get; set; }
	public string GDPRFeedbackData { get; set; }
	public string ErrorMessage { get; set; }
	public string APIResponseStatus { get; set; }
	public string KBContentGovernanceAPIFlowStatus { get; set; }
	public string KBContentForGDPRCheck { get; set; }
	public string RecordCount { get; set; }
	}



	public class APIKBContentGovernanceRequest
	{
	public string Title { get; set; }
	public string Solution { get; set; }
	public string Description { get; set; }
	public string Additional_Information { get; set; }
	public string Keywords { get; set; }
	public string Problem_Type { get; set; }
	public string Record_Type { get; set; }
	public string Product { get; set; }//<2>
	}


	public class KBFeedbackData
	{
	public string Title { get; set; }
	public string Solution { get; set; }
	public string Description { get; set; }
	public string Additional_Information { get; set; }
	public string Keywords { get; set; }
	public string Problem_Type { get; set; }	
	public string Product { get; set; }//<2>
	public string Id { get; set; }
	public string GDPR_Compliance_Data_On_Upvote { get; set; }
	public string Upvoted_By { get; set; }
	public string Upvoted_By_Name { get; set; }
	public string Is_Upvoted_As_Noise_Words { get; set; }	
	public string LastModifiedDate { get; set; }
	public string CreatedDate { get; set; }
	public string IsDeleted { get; set; }
	public string RecordTypeName { get; set; }
	public string PublishStatus { get; set; }
	public string ValidationStatus { get; set; }
	public string Visible_In_Public_Knowledge_Base_c { get; set; }
	public string VersionNumber { get; set; }
	public string Language { get; set; }
	}

}