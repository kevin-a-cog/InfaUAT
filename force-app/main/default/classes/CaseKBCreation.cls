/*
   @created by       : SathishR
   @created on       : 08/02/2020
   @Purpose          : Case to KB Link happens from this class.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  11-July-2021     |   Sathish R               |                   |   Initial Version
 |     2      |  29-Aug-2022      |   Sathish R               |   I2RT-6631       |   Removal Of KB Action Mandatory
 |     3      |  25-Oct-2022      |   Sathish R               |   I2RT-7308       |   Add Article Validation status and Article language
 |            |                   |                           |                   |   columns in the KB list under KB action on case console
 |     4      |  25-Oct-2022      |   Sathish R               |   I2RT-7074       |   Trigger a notification to the KB team when article with VS= Draft/ Pending CR
 |            |                   |                           |                   |   is attached to a case under closure.
 |     5      |  21-Jul-2023      |   Deeksha Shetty          |   I2RT-8607       |   Case collaborator/ co-owner to be original author of KB when he creates a new KB via case console
 |     6      |  25-Oct-2023      |   Sathish R               |    I2RT-9212      |   New column - 'Article Record Type' in attached KBs and search results KB table in case layout.
 ****************************************************************************************************
 */

global without sharing class CaseKBCreation {

	public static String KB_URL = Label.KB_URL;/* Tag 4 */
	public static String KB_Attached_To_Case_Email = Label.KB_Attached_To_Case_Email;/* Tag 4 */
	public static String KB_Attached_To_Case_Recipients = Label.KB_Attached_To_Case_Recipients;/* Tag 4 */
	


	public CaseKBCreation() {

	}


	/*******************************************************************************************************
	 * @description Returns the session id
	 */
	@AuraEnabled
	public static string getCaseToKB(string strRecordId) {

		CaseToKBResponse caseToKBResponse = new CaseToKBResponse();
		caseToKBResponse.ErrorMessage = '';
		caseToKBResponse.ResponseStatus = '';
		caseToKBResponse.DataFlowStatus = '';
		caseToKBResponse.searchKBDataList = null;
		String strDataFlowStatus = '';
		try {
			List<SearchKBResultData> searchKBResultDatas = new List<SearchKBResultData>();
			//strDataFlowStatus += ' ' + strRecordId;
			List<Case_KB__c> casetokbRecList = [SELECT Id, Knowledge__r.Id, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c,Knowledge__r.Language,Knowledge__r.ValidationStatus,Knowledge__r.RecordType.Name FROM Case_KB__c WHERE Case_KB__c.Case__r.Id =: strRecordId AND Knowledge__c != null]; //<3><T06>

			for (Case_KB__c ojbCaseKB : casetokbRecList) {
				SearchKBResultData searchKBResultData = new SearchKBResultData();
				searchKBResultData.infadocid = '';
				searchKBResultData.infavalidationstatus = ojbCaseKB.Knowledge__r.ValidationStatus != null ?  ojbCaseKB.Knowledge__r.ValidationStatus  : '';//<3>
				searchKBResultData.athenalanguage = ojbCaseKB.Knowledge__r.Language != null ?  ojbCaseKB.Knowledge__r.Language  : '';//<3>
				searchKBResultData.sfarticlenumber = ojbCaseKB.Knowledge__r.ArticleNumber != null ?  ojbCaseKB.Knowledge__r.ArticleNumber  : '';
				searchKBResultData.sfid = ojbCaseKB.Knowledge__r.Id != null ?  ojbCaseKB.Knowledge__r.Id : '';
				searchKBResultData.title = ojbCaseKB.Knowledge__r.Title != null ?  ojbCaseKB.Knowledge__r.Title  : '';
				searchKBResultData.infarecordtypename = ojbCaseKB.Knowledge__r.RecordType.Name != null ?  ojbCaseKB.Knowledge__r.RecordType.Name  : '';//<T06>
				searchKBResultDatas.add(searchKBResultData);
			}
			//strDataFlowStatus += ' casetokbRecList ' + JSON.serialize(casetokbRecList);

			List<CoveoV2__CoveoCaseAttachedResult__c> objCaseAttachedResultList = [Select Id,CoveoV2__case__c, CoveoV2__Title__c,Name,CoveoV2__ResultUrl__c from CoveoV2__CoveoCaseAttachedResult__c WHERE CoveoV2__case__c =: strRecordId];
			//strDataFlowStatus += ' objCaseAttachedResultList ' + JSON.serialize(objCaseAttachedResultList);
			List<String> lststrUrl = new List<String>();
			List<String> lststrTitle = new List<String>();
			for(CoveoV2__CoveoCaseAttachedResult__c objCaseAttachedResult : objCaseAttachedResultList)
			{
				String strArticleURL = objCaseAttachedResult.CoveoV2__ResultUrl__c;
				String strArticleTitle = objCaseAttachedResult.CoveoV2__Title__c;
				strDataFlowStatus += ' strArticleURL ' + strArticleURL;

				if(strArticleURL.right(3) == '...')
				{
					if(strArticleTitle != '')
						lststrTitle.add(strArticleTitle);
				}
				else if(strArticleURL.indexOf('/s/articlepreview?') > -1)
				{
					String[] strURLArray = strArticleURL.split('/');

					//strDataFlowStatus += ' strURLArray ' + strURLArray;

					String strOnlyQueryString = strURLArray[strURLArray.size()-1];
					String[] strQueryStringArray = strOnlyQueryString.split('&');
					String strArticleURLName = '';
					for(String qrystr : strQueryStringArray)
					{
						if(qrystr.contains('articlepreview?c__number='))
						{
							strArticleURLName = qrystr.replace('articlepreview?c__number=', '');
							strArticleURLName = strArticleURLName.trim();
						}
					}
					//strDataFlowStatus += ' strArticleURLName ' + strArticleURLName;

					if(strArticleURLName != '')
						lststrUrl.add(strArticleURLName);
				}
				else if(strArticleURL.indexOf('/s/article/') > -1) {

					String[] strURLArray = strArticleURL.split('/');

					String strOnlyQueryString = strURLArray[strURLArray.size()-1];
					String[] strQueryStringArray = strOnlyQueryString.split('\\?');
					String strArticleURLName = '';
					for(String qrystr : strQueryStringArray)
					{
						strArticleURLName = qrystr.trim();
						break;
					}

					//strDataFlowStatus += ' strArticleURLName ' + strArticleURLName;

					if(strArticleURLName != '')
						lststrUrl.add(strArticleURLName);
				}
			}

			List<Knowledge__kav> attachedKBList = [SELECT Id, ArticleNumber, Title, UrlName, Language, ValidationStatus,RecordType.Name FROM Knowledge__kav WHERE UrlName IN :lststrUrl or Title IN : lststrTitle];//<3><T06>

			//strDataFlowStatus += ' lststrUrl ' + JSON.serialize(lststrUrl);
			//strDataFlowStatus += ' lststrTitle ' + lststrTitle;

			for (Knowledge__kav attachedKB : attachedKBList) {
				SearchKBResultData searchKBResultData = new SearchKBResultData();
				searchKBResultData.infadocid = '';
				searchKBResultData.infavalidationstatus = attachedKB.ValidationStatus != null ?  attachedKB.ValidationStatus  : '';//<3>
				searchKBResultData.athenalanguage = attachedKB.Language != null ?  attachedKB.Language  : '';//<3>
				searchKBResultData.sfarticlenumber = attachedKB.ArticleNumber != null ?  attachedKB.ArticleNumber  : '';
				searchKBResultData.sfid = attachedKB.Id != null ?  attachedKB.Id : '';
				searchKBResultData.title = attachedKB.Title != null ?  attachedKB.Title  : '';
				searchKBResultData.infarecordtypename = attachedKB.RecordType.Name != null ?  attachedKB.RecordType.Name  : '';//<T06>
				searchKBResultDatas.add(searchKBResultData);
			}

			//strDataFlowStatus += ' attachedKBList ' + JSON.serialize(attachedKBList);


			caseToKBResponse.ResponseStatus = 'OK';
			caseToKBResponse.searchKBDataList = searchKBResultDatas;
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;


		} catch (Exception e) {
			caseToKBResponse.ResponseStatus = 'ERROR';
			caseToKBResponse.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;

		}
		return JSON.serialize(caseToKBResponse);
	}

	@AuraEnabled
	public static string processKnowledgeBaseArticle(string strRecordId,string strKeywords,string strArticleType,string strActionType,string strArticleId) {

		CaseToKBResponse caseToKBResponse = new CaseToKBResponse();
		caseToKBResponse.ErrorMessage = '';
		caseToKBResponse.ResponseStatus = '';
		caseToKBResponse.DataFlowStatus = '';
		caseToKBResponse.searchKBDataList = null;
		String strDataFlowStatus = '';
		String CREATE_NEW = 'Create New';
		String USE_EXISTING = 'Use Existing';
		String UPDATED_EXISTING = 'Updated Existing';
		String NOT_APPLICABLE = 'NA';//Jira : I2RT-4955
		try {
			strDataFlowStatus += ' ' + strActionType + ' ' + strRecordId;
			Case caseRecord = [SELECT Id, CaseNumber, Status, Subject, Description, Priority, Next_Action__c, Forecast_Product__c, Version__c,
			                   CreatedDate, LastmodifiedDate,Closing_Notes__c,Component__c,Problem_Type__c,OwnerId,Root_Cause_Analysis__c FROM Case WHERE Id = :strRecordId];

			List<Case_KB__c> casekbExistCreateNew = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND Type__c = :CREATE_NEW];

			List<Case_KB__c> casekbExistUpdateOrUseOrNAOrBlank = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND (Type__c = :USE_EXISTING OR Type__c = :UPDATED_EXISTING OR Type__c = null OR Type__c = '')];

			//Jira : I2RT-4955
			List<Case_KB__c> casekbExistNotApplicable = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strRecordId AND Type__c = :NOT_APPLICABLE];

			if(strActionType == CREATE_NEW)
			{

				if(caseRecord != null && casekbExistCreateNew.isEmpty() == true)
				{
					//Jira : I2RT-4955 - Start
					if(!casekbExistNotApplicable.isEmpty())
					{
						delete casekbExistNotApplicable;
					}
					//Jira : I2RT-4955 - End
					
                    
                    /*Tag 5 starts */
                    
                    List<Raise_Hand__c> collaboratorList = [SELECT Accepted_By__c from Raise_Hand__c 
                                                            where Case__c=:strRecordId AND Status__c='Closed' AND Accepted_By__c=:userinfo.getUserId() 
                                                            Order by Accepted_On__c DESC  LIMIT 1];
                    System.debug('collaboratorList='+collaboratorList);
                    
                    /*Tag 5 ends */
                    

					strDataFlowStatus += ' Create New Section';
					string title = caseRecord.Subject != null ? caseRecord.Subject : '';
					string keywords =  strKeywords != null ? strKeywords : '';
					string internalNotes = caseRecord.CaseNumber != null ? caseRecord.CaseNumber : '';
					string infaProducts = caseRecord.Forecast_Product__c != null ? caseRecord.Forecast_Product__c : '';
					string solution = caseRecord.Closing_Notes__c != null ? caseRecord.Closing_Notes__c : '';
					solution += caseRecord.Description != null ? ' \n'+ caseRecord.Description : '';

					string problemDescription =  caseRecord.Description != null ? caseRecord.Description : '';
					problemDescription += caseRecord.Root_Cause_Analysis__c != null ? ' \n'+caseRecord.Root_Cause_Analysis__c : '';

					string template = strArticleType != null ? strArticleType.trim().toLowerCase() : '';
					string recordtypeid = '';
					string caseId =  caseRecord.Id != null ? caseRecord.Id : '';
					string productversion = caseRecord.Version__c != null ? caseRecord.Version__c : '';
					string component = caseRecord.Component__c != null ? caseRecord.Component__c : '';
					string problemtype = caserecord.Problem_Type__c != null ? caserecord.Problem_Type__c : '';
					string actiontype = strActionType != null ? strActionType : '';
					string ownerid = caseRecord.OwnerId != null ? caserecord.OwnerId : '';
					string solutionrectypeid = null;


					if(template != 'faq' && template != 'whitepaper' && template != 'how to')
					{
						problemDescription =  caseRecord.Description != null ? caseRecord.Description : '';
						problemDescription += caseRecord.Root_Cause_Analysis__c != null ? ' \n'+caseRecord.Root_Cause_Analysis__c : '';
					}
					else {
						problemDescription = '';
					}


					infaProducts = getPickListValue(infaProducts,Knowledge__kav.Primary_Product__c,'','');
					productversion = getPickListValue(productversion,Knowledge__kav.Product_Version__c,'Primary_Product__c',infaProducts);
					component = getPickListValue(component,Knowledge__kav.Product_Component__c,'Primary_Product__c',infaProducts);
					problemtype = getPickListValue(problemtype,Knowledge__kav.Problem_Type__c,'','');



					List<RecordType> kbRecordTypeList= [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Knowledge__kav'];

					for(RecordType kbRecordType : kbRecordTypeList)
					{
						if(string.valueOf(kbRecordType.Name).trim().toLowerCase() == template)
						{
							recordtypeid = kbRecordType.Id;
						}
						if(string.valueOf(kbRecordType.Name).trim().toLowerCase() == 'solution')
						{
							solutionrectypeid = kbRecordType.Id;
						}
					}

					recordtypeid = recordtypeid.trim() == '' ? solutionrectypeid : recordtypeid;

					Integer randomNumber = Integer.valueof((Math.random() * 1000000000));
					String strUrlName = 'KB' + String.valueOf(randomNumber);
					Knowledge__kav knwRec = new Knowledge__kav();
					knwRec.Title = title;
					knwRec.UrlName = strUrlName;
					knwRec.Expiration_Date__c = system.today().addYears(1);
					knwRec.Primary_Product__c = infaProducts;
					knwRec.Solution__c = solution;
					knwRec.Description__c = problemDescription;
					knwRec.Additional_Information__c = '';
					knwRec.Keywords__c = keywords;
					knwRec.Product_Version__c = productversion;
					knwRec.Product_Component__c = component;
					knwRec.Problem_Type__c = problemtype;
                    /* Tag 5 starts */
					knwRec.Created_By__c = (collaboratorList.size()>0) ? collaboratorList[0].Accepted_By__c : ownerid;
                    if(collaboratorList.size()>0) knwRec.Original_Author__c = collaboratorList[0].Accepted_By__c;
                    /* Tag 5 ends */
					knwRec.RecordTypeId = recordtypeid;
					knwRec.Internal_Notes__c = internalNotes;

					strDataFlowStatus += ' Going to Insert KB ' + JSON.serialize(knwRec);

					strDataFlowStatus += ' Before KB Insert';

					insert knwRec;

					knwRec = [SELECT Id, ValidationStatus,Title,PublishStatus,KnowledgeArticleId,VersionNumber,ArticleNumber from Knowledge__kav where UrlName =:strUrlName];


					knwRec.UrlName = String.valueOf(knwRec.ArticleNumber);
					update knwRec;

					Case_KB__c caseKBRec = new Case_KB__c();
					caseKBRec.Case__c = strRecordId;
					caseKBRec.Knowledge__c = knwRec.Id;
					caseKBRec.Type__c = actiontype;
					caseKBRec.Name = 'KB'+String.valueOf(knwRec.Id)+'Case'+strRecordId;
					caseKBRec.ArticleNumber__c = String.valueOf(knwRec.ArticleNumber);
					insert caseKBRec;


					strDataFlowStatus += ' After KB Insert';
					strDataFlowStatus += '############# caseKBRec'+JSON.serialize(caseKBRec)+ ' #################';
				}
			}
			else if(strActionType == USE_EXISTING || strActionType == UPDATED_EXISTING)
			{
				if(caseRecord != null)
				{
					sendAlertOnCaseKBAttachment(strArticleId,caseRecord.CaseNumber,caseRecord.Id);/* Tag 4 */
					//Jira : I2RT-4955 - Start
					if(!casekbExistNotApplicable.isEmpty())
					{
						delete casekbExistNotApplicable;
					}
					//Jira : I2RT-4955 - End

					strDataFlowStatus += ' existing case size ' + String.valueOf(casekbExistUpdateOrUseOrNAOrBlank.size());
					if(casekbExistUpdateOrUseOrNAOrBlank.isEmpty() && casekbExistCreateNew.isEmpty())
					{
						List<Knowledge__kav> kbInsertRecList = new List<Knowledge__kav>();
						casekbExistUpdateOrUseOrNAOrBlank = new List<Case_KB__c>();
						List<String> straryKBId = strArticleId.split(';');
						kbInsertRecList = [SELECT Id, ArticleNumber FROM Knowledge__kav WHERE Id IN :straryKBId];
						for (Knowledge__kav objKB : kbInsertRecList) {
							Case_KB__c casetokbRec = new Case_KB__c();
							strDataFlowStatus += ' KBID ' + String.valueOf(objKB.Id);
							casetokbRec.Knowledge__c = objKB.Id;
							casetokbRec.Case__c= caseRecord.Id;
							casetokbRec.Type__c = strActionType;
							casetokbRec.Name = 'KB'+String.valueOf(objKB.Id)+'Case'+strRecordId;
							casetokbRec.ArticleNumber__c = String.valueOf(objKB.ArticleNumber);
							casekbExistUpdateOrUseOrNAOrBlank.add(casetokbRec);
						}
						strDataFlowStatus += ' Going to Insert CaseToKB ' + JSON.serialize(casekbExistUpdateOrUseOrNAOrBlank);
						insert casekbExistUpdateOrUseOrNAOrBlank;
					}
					else {
						List<Id> listLatestKBIdForDelete = new List<Id>();
						List<Id> listLatestKBIdForInsert = new List<Id>();
						List<Id> listExistingKBIdForDelete = new List<Id>();
						List<Id> listExistingKBIdForInsert = new List<Id>();
						List<Id> listExistingKBIdForUpdate = new List<Id>();




						List<Case_KB__c> casekbInsertRecList = new List<Case_KB__c>();
						List<Case_KB__c> casekbDeleteRecList = new List<Case_KB__c>();
						List<Case_KB__c> casekbUpdateRecList = new List<Case_KB__c>();

						List<Knowledge__kav> kbInsertRecList = new List<Knowledge__kav>();

						strDataFlowStatus += ' variable assigned';
						for(String strLatest : strArticleId.split(';'))
						{
							if(strLatest != null && strLatest != '')
							{
								listLatestKBIdForDelete.add(strLatest);
								listLatestKBIdForInsert.add(strLatest);
							}
						}
						strDataFlowStatus += ' listLatestKBIdForDelete length ' + String.valueOf(listLatestKBIdForDelete.size());

						for(Case_KB__c objExisting : casekbExistUpdateOrUseOrNAOrBlank)
						{
							listExistingKBIdForDelete.add(String.valueOf(objExisting.Knowledge__c));
							listExistingKBIdForInsert.add(String.valueOf(objExisting.Knowledge__c));
						}


						strDataFlowStatus += ' listExistingKBIdForDelete length ' + String.valueOf(listExistingKBIdForDelete.size());
						strDataFlowStatus += ' listLatestKBIdForDelete length ' + String.valueOf(listLatestKBIdForDelete.size());


						for (Integer i = (listLatestKBIdForInsert.size() - 1); i >= 0; i--) {
							for (Integer j = 0; j < listExistingKBIdForInsert.size(); j++) {
								if(String.valueOf(listLatestKBIdForInsert[i]) == String.valueOf(listExistingKBIdForInsert[j]))
								{
									listLatestKBIdForInsert.remove(i);
									break;
								}
							}
						}

						//Case_KB Record with Create New Type is maintained in the object once it is inserted
						//Delete those id from the Exisintg Case_KB Records Which will be inserted.
						if(!casekbExistCreateNew.isEmpty())
						{
							String strKBId = String.valueOf(casekbExistCreateNew[0].Knowledge__c);
							for (Integer i = (listLatestKBIdForInsert.size() - 1); i >= 0; i--) {
								if(String.valueOf(listLatestKBIdForInsert[i]) == strKBId)
								{
									listLatestKBIdForInsert.remove(i);
									break;
								}
							}
						}

						strDataFlowStatus += ' listLatestKBIdForInsert length ' + String.valueOf(listLatestKBIdForInsert.size());



						for (Integer i = (listExistingKBIdForDelete.size() - 1); i >= 0; i--) {
							for (Integer j = 0; j < listLatestKBIdForDelete.size(); j++) {
								if(String.valueOf(listLatestKBIdForDelete[j]) == String.valueOf(listExistingKBIdForDelete[i]))
								{
									strDataFlowStatus += ' setUpdateKBId added for updation ';
									listExistingKBIdForUpdate.add(listExistingKBIdForDelete[i]);
									listExistingKBIdForDelete.remove(i);
									break;
								}
							}
						}

						//Case_KB Record with Create New Type is maintained in the object once it is inserted
						//Delete those id from the Exisintg Case_KB Records Which will be uopdated
						if(!casekbExistCreateNew.isEmpty())
						{
							String strKBId = String.valueOf(casekbExistCreateNew[0].Knowledge__c);
							for (Integer i = (listExistingKBIdForUpdate.size() - 1); i >= 0; i--) {
								if(String.valueOf(listExistingKBIdForUpdate[i]) == strKBId)
								{
									strDataFlowStatus += ' Delete Create New Record from Existing Update List ';
									listExistingKBIdForDelete.add(listExistingKBIdForUpdate[i]);
									listExistingKBIdForUpdate.remove(i);
									break;
								}
							}
						}



						strDataFlowStatus += ' listExistingKBIdForUpdate length ' + String.valueOf(listExistingKBIdForUpdate.size());

						casekbDeleteRecList = [SELECT Id,Case__c,Knowledge__c FROM Case_KB__c WHERE Case__c = :strRecordId and Knowledge__c IN :listExistingKBIdForDelete AND (Type__c = :USE_EXISTING OR Type__c = :UPDATED_EXISTING OR Type__c = null OR Type__c = '')];
						if(!casekbDeleteRecList.isEmpty())
						{
							delete casekbDeleteRecList;
							strDataFlowStatus += ' Delete';
						}

						strDataFlowStatus += ' casekbUpdateRecList length ' + String.valueOf(casekbUpdateRecList.size());



						casekbUpdateRecList = [SELECT Id, Knowledge__c,Case__c, Type__c FROM Case_KB__c WHERE Case__c = :strRecordId and Knowledge__c IN :listExistingKBIdForUpdate AND (Type__c = :USE_EXISTING OR Type__c = :UPDATED_EXISTING OR Type__c = null OR Type__c = '')];
						if(!casekbUpdateRecList.isEmpty())
						{
							for (Integer i = 0; i < casekbUpdateRecList.size(); i++) {
								casekbUpdateRecList[i].Type__c = strActionType;
							}
							update casekbUpdateRecList;
							strDataFlowStatus += ' Update';
						}

						strDataFlowStatus += ' casekbUpdateRecList length ' + String.valueOf(casekbUpdateRecList.size());

						kbInsertRecList = [SELECT Id, ArticleNumber FROM Knowledge__kav WHERE Id IN :listLatestKBIdForInsert];

						for(Knowledge__kav objKB : kbInsertRecList) {
							Case_KB__c casetokbRec = new Case_KB__c();
							strDataFlowStatus += ' KBID ' + String.valueOf(objKB.Id);
							casetokbRec.Knowledge__c = objKB.Id;
							casetokbRec.Case__c = caseRecord.Id;
							casetokbRec.Type__c = strActionType;
							casetokbRec.Name = 'KB'+String.valueOf(objKB.Id)+'Case'+strRecordId;
							casetokbRec.ArticleNumber__c = String.valueOf(objKB.ArticleNumber);
							casekbInsertRecList.add(casetokbRec);
						}

						strDataFlowStatus += ' lstInsertKBId length ' + String.valueOf(listLatestKBIdForInsert.size());
						if(!casekbInsertRecList.isEmpty())
						{
							insert casekbInsertRecList;
							strDataFlowStatus += ' Insert';
							strDataFlowStatus += '############# '+JSON.serialize(casekbInsertRecList)+ ' #################';
						}

						strDataFlowStatus += ' casekbInsertRecList length ' + String.valueOf(casekbInsertRecList.size());
					}
				}

			}
			//Jira : I2RT-4955 - Start
			else if(strActionType == NOT_APPLICABLE) {

				if(caseRecord != null && (casekbExistNotApplicable.isEmpty() == true))
				{
					if(!casekbExistUpdateOrUseOrNAOrBlank.isEmpty())
					{
						delete casekbExistUpdateOrUseOrNAOrBlank;
					}

					if(!casekbExistCreateNew.isEmpty())
					{
						delete casekbExistCreateNew;
					}

					string actiontype = strActionType != null ? strActionType : '';

					Case_KB__c caseKBRec = new Case_KB__c();
					caseKBRec.Case__c = strRecordId;
					caseKBRec.Type__c = actiontype;
					caseKBRec.Name = 'KBNA'+'Case'+strRecordId;
					insert caseKBRec;
					strDataFlowStatus += '############# '+JSON.serialize(caseKBRec)+ ' #################';

				}
			}
			//Jira : I2RT-4955 - End

			caseToKBResponse.ResponseStatus = 'OK';
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;


		} catch (Exception e) {
			caseToKBResponse.ResponseStatus = 'ERROR';
			caseToKBResponse.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;

		}
		return JSON.serialize(caseToKBResponse);
	}

	public static string getPickListValue(string strInputValue,Schema.sObjectField dependentField,string controlFieldName, string controlFieldValue)
	{
		string strResult = '';
		try{
			Schema.DescribeFieldResult describePickListField = dependentField.getDescribe();

			Schema.sObjectField controllerField = describePickListField.getController();

			boolean isPickListValuePresent = false;
			boolean isPickListValueValidWithControlField = false;
			String base64string = '';
			List<Schema.PicklistEntry> valuesPickListField = describePickListField.getPicklistValues();
			for(Schema.PicklistEntry valuePickListField : valuesPickListField) {
				if((valuePickListField.getValue().trim().toLowerCase() == strInputValue.trim().toLowerCase()) && valuePickListField.isActive() == true)
				{
					strResult = valuePickListField.getValue();
					strResult = strResult.trim();
					isPickListValuePresent = true;
					system.debug ('dependentfield Object' + JSON.serialize(valuePickListField));
					base64string = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(valuePickListField))).get('validFor'));
					break;
				}
			}

			if(controlFieldName != '' && isPickListValuePresent == true)
			{
				system.debug ('dependentfield Object base64string ' + base64string);

				Map<String, List<String> > objResults = new Map<String, List<String> >();
				List<String> controllingValues = new List<String>();

				if(controllerField != null) {
					Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
					List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());

					for (Schema.PicklistEntry ple : controllerValues) {
						String value = ple.getValue();
						//objResults.put(value, new List<String>());
						controllingValues.add(value);
					}

					if(base64string != null)
					{
						system.debug ('dependentfield Object binary ' + base64ToBits(base64string));
						String binarystring = base64ToBits(base64string);
						List<String> binarychars = binarystring.split('');
						for (Integer i = 0; i < binarychars.size(); i++) {
							if(binarychars[i] == '1')
							{
								if(controllingValues.get(i) == controlFieldValue)
								{
									isPickListValueValidWithControlField = true;
									system.debug ('dependentfield Matched Value ' + controllingValues.get(i));
								}
							}
						}
					}
				}
			}
			else if(isPickListValuePresent == true)
			{
				isPickListValueValidWithControlField = true;
			}

			if(isPickListValueValidWithControlField != true)
			{
				strResult = '';
			}

		} catch (Exception e) {
			system.debug('Exception in valueForPickList : '+e.getmessage() + ' ' + e.getlinenumber());
		}
		return strResult;
	}

	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	private static final String base64Chars = '' +
	                                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
	                                          'abcdefghijklmnopqrstuvwxyz' +
	                                          '0123456789+/';


	public static String base64ToBits(String validFor) {


		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}

	@AuraEnabled
	public static string processCaseKB(string strCaseRecordId,string strKBRecordId,string strKBArticleNumber,string strKBActionType) {

		CaseToKBResponse caseToKBResponse = new CaseToKBResponse();
		caseToKBResponse.ErrorMessage = '';
		caseToKBResponse.ResponseStatus = '';
		caseToKBResponse.DataFlowStatus = '';
		caseToKBResponse.searchKBDataList = null;
		String strDataFlowStatus = '';
		String CREATE_NEW = 'Create New';
		String USE_EXISTING = 'Use Existing';
		String UPDATED_EXISTING = 'Updated Existing';
		String NO_ACTION = 'NA';
		String BLANK_ACTION = '';
		try {
			strDataFlowStatus += ' ' + strKBActionType + ' ' + strCaseRecordId;
			Case caseRecord = [SELECT Id, CaseNumber, Status, Subject, Description, Priority, Next_Action__c, Forecast_Product__c, Version__c,
			                   CreatedDate, LastmodifiedDate,Closing_Notes__c,Component__c,Problem_Type__c,OwnerId,Root_Cause_Analysis__c FROM Case WHERE Id = :strCaseRecordId];

			List<Case_KB__c> casekbExistCreateNew = [SELECT Id, Knowledge__r.Id,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strCaseRecordId AND Type__c = :CREATE_NEW];


			List<Case_KB__c> casekbExistUpdateOrUseOrNAOrBlank = [SELECT Id, Knowledge__r.Id,Knowledge__c,Case__c, Knowledge__r.ArticleNumber, Knowledge__r.Title,Type__c FROM Case_KB__c WHERE Case__c = :strCaseRecordId AND Knowledge__c = :strKBRecordId AND (Type__c = :USE_EXISTING OR Type__c = :UPDATED_EXISTING OR Type__c = :NO_ACTION OR Type__c = null OR Type__c = '')];

			if(strKBActionType == CREATE_NEW)
			{

				if(caseRecord != null && casekbExistCreateNew.isEmpty() == true)
				{
					strDataFlowStatus += ' Create New Section';

					Case_KB__c caseKBRec = new Case_KB__c();
					caseKBRec.Case__c = strCaseRecordId;
					caseKBRec.Knowledge__c = strKBRecordId;
					caseKBRec.Type__c = strKBActionType;
					caseKBRec.Name = 'KB'+String.valueOf(strKBRecordId)+'Case'+strCaseRecordId;
					caseKBRec.ArticleNumber__c = String.valueOf(strKBArticleNumber);
					insert caseKBRec;


					strDataFlowStatus += ' After KB Insert';
				}
			}
			else if(strKBActionType == USE_EXISTING || strKBActionType == UPDATED_EXISTING)
			{
				if(caseRecord != null)
				{
					strDataFlowStatus += ' existing case size ' + String.valueOf(casekbExistUpdateOrUseOrNAOrBlank.size());
					if(casekbExistUpdateOrUseOrNAOrBlank.isEmpty() && casekbExistCreateNew.isEmpty())
					{
						Case_KB__c caseKBRec = new Case_KB__c();
						caseKBRec.Case__c = strCaseRecordId;
						caseKBRec.Knowledge__c = strKBRecordId;
						caseKBRec.Type__c = strKBActionType;
						caseKBRec.Name = 'KB'+String.valueOf(strKBRecordId)+'Case'+strCaseRecordId;
						caseKBRec.ArticleNumber__c = String.valueOf(strKBArticleNumber);

						strDataFlowStatus += ' Going to Insert CaseToKB ' + JSON.serialize(caseKBRec);
						insert caseKBRec;
					}
					else
					{
						if(!casekbExistUpdateOrUseOrNAOrBlank.isEmpty())
						{
							for (Integer i = 0; i < casekbExistUpdateOrUseOrNAOrBlank.size(); i++) {
								casekbExistUpdateOrUseOrNAOrBlank[i].Type__c = strKBActionType;
							}
							strDataFlowStatus += ' Going to Insert CaseToKB ' + JSON.serialize(casekbExistUpdateOrUseOrNAOrBlank);
							update casekbExistUpdateOrUseOrNAOrBlank;
						}

					}

				}

			}
			//Start /*<2>*/
			else if(strKBActionType == '')
			{
				if(caseRecord != null && casekbExistUpdateOrUseOrNAOrBlank.isEmpty() == true)
				{
					strDataFlowStatus += ' No KB Action';

					Case_KB__c caseKBRec = new Case_KB__c();
					caseKBRec.Case__c = strCaseRecordId;
					caseKBRec.Knowledge__c = strKBRecordId;
					caseKBRec.Name = 'KB'+String.valueOf(strKBRecordId)+'Case'+strCaseRecordId;
					caseKBRec.ArticleNumber__c = String.valueOf(strKBArticleNumber);
					insert caseKBRec;

					strDataFlowStatus += ' After Cased KB Insert';
				}
				else
				{
					if(caseRecord != null && casekbExistUpdateOrUseOrNAOrBlank.isEmpty() == false)
					{
						for (Integer i = 0; i < casekbExistUpdateOrUseOrNAOrBlank.size(); i++) {
							casekbExistUpdateOrUseOrNAOrBlank[i].Type__c = strKBActionType;
						}
						strDataFlowStatus += ' Going to update CaseToKB ' + JSON.serialize(casekbExistUpdateOrUseOrNAOrBlank);
						update casekbExistUpdateOrUseOrNAOrBlank;
					}
				}
			}
			//End /*</2>*/

			caseToKBResponse.ResponseStatus = 'OK';
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;


		} catch (Exception e) {
			caseToKBResponse.ResponseStatus = 'ERROR';
			caseToKBResponse.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
			caseToKBResponse.DataFlowStatus = strDataFlowStatus;

		}
		return JSON.serialize(caseToKBResponse);
	}

	@AuraEnabled
	public static string getKBToCase(string strKAVRecordId, string strKARecordId,string strKAVArticleNumber) {

		KBToCaseResponse kbToCaseResponse = new KBToCaseResponse();
		kbToCaseResponse.ErrorMessage = '';
		kbToCaseResponse.ResponseStatus = '';
		kbToCaseResponse.DataFlowStatus = '';
		kbToCaseResponse.searchCaseDataList = null;
		String strDataFlowStatus = '';
		try {
			List<SearchCaseResultData> searchCaseResultDatas = new List<SearchCaseResultData>();
			strDataFlowStatus += ' ' + strKAVRecordId;
			strDataFlowStatus += ' ' + strKARecordId;
			strDataFlowStatus += ' ' + strKAVArticleNumber;
			//Jira : I2RT-4955
			List<Case_KB__c> casetokbRecList = [SELECT Id,  Knowledge__r.Id, Case__r.Id, Case__r.CaseNumber, Case__r.Subject,Type__c FROM Case_KB__c WHERE Knowledge__r.Id =: strKAVRecordId order by LastModifiedDate desc];
			//strDataFlowStatus += ' casetokbRecList 1 ' + JSON.serialize(casetokbRecList);

			if(casetokbRecList.isEmpty())
			{
				casetokbRecList = [SELECT Id,  Knowledge__r.Id, Case__r.Id, Case__r.CaseNumber, Case__r.Subject,Type__c FROM Case_KB__c WHERE Knowledge__r.KnowledgeArticleId =: strKARecordId order by LastModifiedDate desc];
				//strDataFlowStatus += ' casetokbRecList 2 ' + JSON.serialize(casetokbRecList);
			}

			if(casetokbRecList.isEmpty())
			{
				casetokbRecList = [SELECT Id,  Knowledge__r.Id, Case__r.Id, Case__r.CaseNumber, Case__r.Subject,Type__c FROM Case_KB__c WHERE ArticleNumber__c =: strKAVArticleNumber order by LastModifiedDate desc];
				//strDataFlowStatus += ' casetokbRecList 2 ' + JSON.serialize(casetokbRecList);
			}

			for (Case_KB__c objCaseKB : casetokbRecList) {
				SearchCaseResultData searchCaseResultData = new SearchCaseResultData();
				searchCaseResultData.Id = objCaseKB.Id != null ?  objCaseKB.Id  : '';
				searchCaseResultData.CaseId = objCaseKB.Case__r.Id != null ?  objCaseKB.Case__r.Id  : '';
				searchCaseResultData.CaseNumber = objCaseKB.Case__r.CaseNumber != null ?  objCaseKB.Case__r.CaseNumber  : '';
				searchCaseResultData.Subject = objCaseKB.Case__r.Subject != null ?  objCaseKB.Case__r.Subject : '';
				searchCaseResultData.Type = objCaseKB.Type__c != null ?  objCaseKB.Type__c  : '';
				searchCaseResultDatas.add(searchCaseResultData);
			}
			strDataFlowStatus += ' casetokbRecList 3 ' + JSON.serialize(casetokbRecList);

			kbToCaseResponse.ResponseStatus = 'OK';
			kbToCaseResponse.searchCaseDataList = searchCaseResultDatas;
			kbToCaseResponse.DataFlowStatus = strDataFlowStatus;


		} catch (Exception e) {
			kbToCaseResponse.ResponseStatus = 'ERROR';
			kbToCaseResponse.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
			kbToCaseResponse.DataFlowStatus = strDataFlowStatus;

		}
		return JSON.serialize(kbToCaseResponse);
	}

	@AuraEnabled
	public static string updateKBToCase(string strCaseKBRecordId,string strKBRecordId) {

		KBToCaseResponse kbToCaseResponse = new KBToCaseResponse();
		kbToCaseResponse.ErrorMessage = '';
		kbToCaseResponse.ResponseStatus = '';
		kbToCaseResponse.DataFlowStatus = '';
		kbToCaseResponse.searchCaseDataList = null;
		String strDataFlowStatus = '';
		try {

			List<Case_KB__c> casetokbDeletedRecList = [SELECT Id,  Knowledge__r.Id, Case__r.Id, Case__r.CaseNumber, Case__r.Subject,Type__c FROM Case_KB__c WHERE Id =: strCaseKBRecordId];
			if(!casetokbDeletedRecList.isEmpty())
			{
				delete casetokbDeletedRecList;
				strDataFlowStatus += ' after delete';
			}


			List<SearchCaseResultData> searchCaseResultDatas = new List<SearchCaseResultData>();
			strDataFlowStatus += ' ' + strKBRecordId;
			List<Case_KB__c> casetokbRecList = [SELECT Id,  Knowledge__r.Id, Case__r.Id, Case__r.CaseNumber, Case__r.Subject,Type__c FROM Case_KB__c WHERE Knowledge__r.Id =: strKBRecordId];

			for (Case_KB__c objCaseKB : casetokbRecList) {
				SearchCaseResultData searchCaseResultData = new SearchCaseResultData();
				searchCaseResultData.Id = objCaseKB.Id != null ?  objCaseKB.Id  : '';
				searchCaseResultData.CaseId = objCaseKB.Case__r.Id != null ?  objCaseKB.Case__r.Id  : '';
				searchCaseResultData.CaseNumber = objCaseKB.Case__r.CaseNumber != null ?  objCaseKB.Case__r.CaseNumber  : '';
				searchCaseResultData.Subject = objCaseKB.Case__r.Subject != null ?  objCaseKB.Case__r.Subject : '';
				searchCaseResultData.Type = objCaseKB.Type__c != null ?  objCaseKB.Type__c  : '';
				searchCaseResultDatas.add(searchCaseResultData);
			}
			//strDataFlowStatus += ' casetokbRecList ' + JSON.serialize(casetokbRecList);

			kbToCaseResponse.ResponseStatus = 'OK';
			kbToCaseResponse.searchCaseDataList = searchCaseResultDatas;
			kbToCaseResponse.DataFlowStatus = strDataFlowStatus;


		} catch (Exception e) {
			kbToCaseResponse.ResponseStatus = 'ERROR';
			kbToCaseResponse.ErrorMessage = e.getMessage() + ' ' + e.getLineNumber();
			kbToCaseResponse.DataFlowStatus = strDataFlowStatus;

		}
		return JSON.serialize(kbToCaseResponse);
	}

	//Jira : I2RT-7074 - Start
	@future
	public static void sendAlertOnCaseKBAttachment(string strKBRecordIds,string strCaseNumber,string strCaseRecordId) {
		String strResult = '';
		try{
			List<ConnectApi.BatchInput> chatterPostInputs = new List<ConnectApi.BatchInput>();
			List<Messaging.SingleEmailMessage> emailInputs= new List<Messaging.SingleEmailMessage>();
			List<Knowledge__kav> kbAttachedToCase = new List<Knowledge__kav>();
			List<CollaborationGroup> kbContentReviewerGroup = new List<CollaborationGroup>();
			list<string> lstKBRecordIds = new list<string>();
			for(String element : strKBRecordIds.split (';')) {
				lstKBRecordIds.add(element);
			}
			kbAttachedToCase = [Select Id, LastModifiedDate, Title,ArticleNumber,CreatedDate,LastModifiedById,Primary_Product__c,ValidationStatus,PublishStatus From Knowledge__kav WHERE Id IN :lstKBRecordIds AND ValidationStatus IN ('Pending Content Review','Draft')];

			String [] strEmailRecipients = new List<String>();
			for(String element : KB_Attached_To_Case_Recipients.split (';')) {
				strEmailRecipients.add(element);
			}

			List<Group> objGroups = [Select Id,Name,Type from Group WHERE Name ='KB Content Review Group'];
			List<GroupMember> objGroupMembers = new List<GroupMember>();
			if(!objGroups.isEmpty())
			{
				String grpId = objGroups[0].Id;
				objGroupMembers= [Select GroupId,Group.Name,UserOrGroupId FROM GroupMember WHERE GroupId = :grpId];
			}

			for(Knowledge__kav objKB : kbAttachedToCase) {
				emailInputs.add(sendEmailOnCaseKBAttachment(objKB,strCaseNumber,strCaseRecordId,strEmailRecipients));
				if(!objGroupMembers.isEmpty())
				{
					for(GroupMember objGrp : objGroupMembers) {
						chatterPostInputs.add(sendChatterPostOnCaseKBAttachment(objKB,strCaseNumber,strCaseRecordId,objGrp.UserOrGroupId));
					}
				}
			}

			if(!Test.isRunningTest() && !chatterPostInputs.isEmpty()) {ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostInputs); }

			if(!Test.isRunningTest()) {Messaging.sendEmail(emailInputs);  }

		}
		catch(Exception ex) {
			System.debug('sendAlertOnCaseKBAttachment Method : exception occurred - ' + ex.getMessage());
			strResult = ex.getMessage() + ' ' + ex.getLineNumber();
		}
		//return strResult;
	}

	public static Messaging.SingleEmailMessage sendEmailOnCaseKBAttachment(Knowledge__kav knwRec,String strLclCaseNumber, string strLclCaseRecordId, String [] strLclRecipients){


		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		String strSubject = 'KB '+ knwRec.ArticleNumber +' has been attached to case';
		String strKBDBodyHtml = KB_Attached_To_Case_Email;
		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strProduct = knwRec.Primary_Product__c != null ?  knwRec.Primary_Product__c  : '';
		String strValidationStatus = knwRec.ValidationStatus != null ?  knwRec.ValidationStatus  : '';
		String strPublishStatus = knwRec.PublishStatus != null ?  knwRec.PublishStatus  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBURL$##',KB_URL).replace('$##KBID$##',strKBId);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBARTICLENUMBER$##',strArticleNumber).replace('$##KBTITLE$##',strTitle);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##CASENUMBER$##',strLclCaseNumber).replace('$##KBPRIMARYPRODUCT$##',strProduct);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBVALIDATIONSTATUS$##',strValidationStatus);
		strKBDBodyHtml = strKBDBodyHtml.replace('$##KBPUBLISHSTATUS$##',strPublishStatus);

		mail.setSubject(strSubject);
		mail.setHtmlBody(strKBDBodyHtml);
		mail.setToAddresses(strLclRecipients);

		return mail;
	}

	public static ConnectApi.BatchInput sendChatterPostOnCaseKBAttachment(knowledge__kav knwRec, String strLclCaseNumber, string strLclCaseRecordId,String strLclRecipient){

		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		// Text content of a chatter body
		ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput20 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput21 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput30 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput3 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput4 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput5 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput6 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput textSegmentInput7 = new ConnectApi.TextSegmentInput();
		ConnectApi.TextSegmentInput nextLineTextSegment = new ConnectApi.TextSegmentInput();

		// To make the text bold
		ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupBeginSegment.markupType = ConnectApi.MarkupType.bold;
		markupEndSegment.markupType = ConnectApi.MarkupType.bold;

		// To have sentences in next line
		ConnectApi.MarkupBeginSegmentInput paragraphBegin = new ConnectApi.MarkupBeginSegmentInput();
		ConnectApi.MarkupEndSegmentInput paragraphEnd = new ConnectApi.MarkupEndSegmentInput();
		paragraphBegin.markupType = ConnectApi.MarkupType.paragraph;
		paragraphEnd.markupType = ConnectApi.MarkupType.paragraph;

		// To have the hyperlink of the KB record
		ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
		entityLinkSegmentInput.entityId = knwRec.Id;


		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();


		
		String strKBId =  knwRec.Id != null ?  knwRec.Id  : '';
		String strTitle = knwRec.Title != null ?  knwRec.Title  : '';
		String strProduct = knwRec.Primary_Product__c != null ?  knwRec.Primary_Product__c  : '';
		String strValidationStatus = knwRec.ValidationStatus != null ?  knwRec.ValidationStatus  : '';
		String strPublishStatus = knwRec.PublishStatus != null ?  knwRec.PublishStatus  : '';
		String strArticleNumber = knwRec.ArticleNumber != null ?  knwRec.ArticleNumber  : '';

		textSegmentInput1.text = 'Hi team,';
		textSegmentInput20.text = 'Article ';
		textSegmentInput21.text = ' has been attached to Case '+ strLclCaseNumber  +'. Please treat this article as a P1 to expedite publishing.';
		textSegmentInput30.text = 'Article Number : '+ strArticleNumber;
		textSegmentInput3.text = 'Product: '+ strProduct;
		textSegmentInput4.text = 'Validation Status: ' + strValidationStatus;
		textSegmentInput5.text = 'Publication Status: ' + strPublishStatus;
		textSegmentInput6.text = 'This is a system generated notification.';
		textSegmentInput7.text = 'Do not reply to this chat.';
		nextLineTextSegment.text ='&nbsp;';



		// first sentence start
		messageBodyInput.messageSegments.add(textSegmentInput1);
		// first sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);


		// second sentence start
		messageBodyInput.messageSegments.add(textSegmentInput20);
		messageBodyInput.messageSegments.add(entityLinkSegmentInput);
		messageBodyInput.messageSegments.add(textSegmentInput21);
		// second sentence end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Three Zero sentence (Bold) start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput30);
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Three Zero sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Third sentence (Bold) start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput3);
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Third sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Four sentence (Bold) start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput4);
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Four sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// Five sentence (Bold) start
		messageBodyInput.messageSegments.add(markupBeginSegment);
		messageBodyInput.messageSegments.add(textSegmentInput5);
		messageBodyInput.messageSegments.add(markupEndSegment);
		// Five sentence (Bold) end

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 6th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput6);
		// 6th sentence start

		messageBodyInput.messageSegments.add(paragraphBegin);
		messageBodyInput.messageSegments.add(nextLineTextSegment);
		messageBodyInput.messageSegments.add(paragraphEnd);

		// 7th sentence start
		messageBodyInput.messageSegments.add(textSegmentInput7);
		// 7th sentence start
		


		system.debug('messagebody'+messageBodyInput);
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = strLclRecipient;
		
		ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
		return batchInput;

	}

	//Jira : I2RT-7074 - End


	public class SearchKBResultData
	{
		public string infadocid   { get; set; }
		public string sfarticlenumber   { get; set; }
		public string title   { get; set; }
		public string sfid   { get; set; }
		public string infavalidationstatus   { get; set; }//<3>
		public string athenalanguage   { get; set; }//<3>
		public string infarecordtypename   { get; set; }//<T05>
	}

	public class SearchCaseResultData
	{
		public string Id   { get; set; }
		public string CaseId   { get; set; }
		public string CaseNumber   { get; set; }
		public string Subject   { get; set; }
		public string Type   { get; set; }
	}

	public class CaseToKBResponse
	{
		public string ErrorMessage { get; set; }
		public string ResponseStatus { get; set; }
		public string DataFlowStatus { get; set; }
		public List<SearchKBResultData> searchKBDataList;
	}

	public class KBToCaseResponse
	{
		public string ErrorMessage { get; set; }
		public string ResponseStatus { get; set; }
		public string DataFlowStatus { get; set; }
		public List<SearchCaseResultData> searchCaseDataList;
	}
  
	
}