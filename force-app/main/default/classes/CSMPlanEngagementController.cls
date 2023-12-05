/*
Change History
************************************************************************************************************************
Modified By        Date       Jira No.     Description                                 					Tag
************************************************************************************************************************
Narpavi Prabu   21/09/2022    AR-2925      Email sent to opportunity Owner for Dealclossure Handoff      T01         
Karthi G	    25/10/2022    AR-2969      CSM to PS Cloud Modernization Handoffs process		         T02     
Chaitanya T		08/17/2023	  AR-3365	   new MFA engagement											 T03
Chaitanya T		11/07/2023	  AR-3537	   Map Engagement Requested for values using metadata			 T04    
 */
public with sharing class CSMPlanEngagementController {
	//Public variables.
	 public static String STRING_FIELD_SET_NAME = 'PlanEngagement';
	 public static globalApexManager GAM = new globalApexManager();
 
	 //Check
	 /*
	  Method Name : getRecords
	  Description : This method returns the Risks and Issues records related to the provided Id.
	  Parameters  : String, called from getRecords, strRecordId Record Id.
	  Return Type : Columns and records.
	  */
	 @AuraEnabled(cacheable = false)
	 public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
		 String strCleanRecordId;
		 String strObjectName = Engagement__c.class.getName();
		 GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
 
		 //If we received a Risk Id.
		 if(String.isNotBlank(strRecordId)) {
 
			 //We clean the Risk Id.
			 strCleanRecordId = String.escapeSingleQuotes(strRecordId);
 
			 //If we received Plan id, we get Plan Product records.
			 objDataTable.strObjectName = strObjectName;
			 objDataTable.strFielSetName = STRING_FIELD_SET_NAME;
			 objDataTable.mapCustomColumnLabels = new Map<String, String>();
			 objDataTable.mapCustomColumnLabels.put('Owner.Id', 'Owner');
			 objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
			 
			 //Now we prepare the response.
			 objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ',RecordType.Name FROM ' + strObjectName + 
					 ' WHERE Plan__c = :strCleanRecordId WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC LIMIT 1000');
		 }
		 return objDataTable;
	 }
 
	 /*
	  Method Name : getRecordsDeleted
	  Description : This method deletes the provided list of records.
	  Parameters  : List<Risk_Issue__c>, called from getRecordsDeleted, lstRecords Records to be deleted.
	  Return Type : None
	  */
	 @AuraEnabled(cacheable = false)
	 public static void getRecordsDeleted(List<Engagement__c> lstRecords) {
		delete lstRecords;
	 }
	 
 
	 @AuraEnabled(cacheable = false)
	 public static  Map<Id,RecordType> getRecordTypes() {
		 Map<Id, RecordType> recordtypeMap = new Map<Id, RecordType>();
		 for(RecordType info : [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Engagement__c']) {
			 if((info.DeveloperName == 'CST' || info.DeveloperName == 'IPS_Jumpstart' || info.DeveloperName == 'Support_Escalation') && info.Name.trim() != ''){
				 recordTypeMap.put(info.Id, info);
			 }
		 }
		 return recordtypeMap;
	 }
 
	 @AuraEnabled(cacheable = false)
	 public static String getRecordsInserted(Engagement__c engagement) {
		 Map<Id,Account> accountMap = new Map<Id,Account>();
		 Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>();
 
		 String engagementId = '';
 
		 Id IPSJumpstart = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('IPS_Jumpstart').getRecordTypeId();
		 Id CSTEngagement = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
		 String planId = engagement.Plan__c;
		 Boolean isPC2IICS=false;
		 pse__Proj__c proj;
		 // Only if Jumpstart Engagement
		 if(engagement.RecordTypeId == IPSJumpstart){            
			 isPC2IICS = [Select Id, COE_Group__c from Plan__c where Id=:planId]?.COE_Group__c=='PC2IICS';
			 String ownerManagerId=  [Select Id, ManagerId FROM User WHERE Id =: userInfo.getUserId()]?.ManagerId;           
			 List<Plan_Team__c> CSMManagerList = [Select Id,User__c from Plan_Team__c where Role__c = 'CSM Manager' and Plan__c =:planId order by CreatedDate Desc];
			 if(engagement.Account__c <> null){          
				 accountMap = new Map<Id,Account>([Select Id,Name,Health_Score__c,Geo__c from Account where Id=:engagement.Account__c]);
			 }
			 if(engagement.Opportunity__c <> null){
				 opptyMap = new Map<Id,Opportunity>([Select Id,Name,New_Org_Opportunity_Number__c from Opportunity where Id=:engagement.Opportunity__c]);
			 }
 
			 if(accountMap.get(engagement.Account__c).Name.length() > 60){
				 engagement.Name = accountMap.get(engagement.Account__c).Name.substring(0,60) + '-' + opptyMap.get(engagement.Opportunity__c).New_Org_Opportunity_Number__c;
			 }else{
				 engagement.Name = accountMap.get(engagement.Account__c).Name + '-' + opptyMap.get(engagement.Opportunity__c).New_Org_Opportunity_Number__c;
			 }     
			 if(!isPC2IICS){
				engagement.Name = engagement.Name + '- JS';
			 }
			 if(engagement.Description__c?.length()>32200){				
				engagement.Project_Notes__c = 'Health Score : '+accountMap.get(engagement.Account__c).Health_Score__c+'; '+'Comments:'+engagement.Description__c?.substring(0,32200)+'; '+'CSM: '+ UserInfo.getName();
			 }    
			 else{				
				engagement.Project_Notes__c = 'Health Score : '+accountMap.get(engagement.Account__c).Health_Score__c+'; '+'Comments:'+engagement.Description__c+'; '+'CSM: '+ UserInfo.getName();
			 }
			 engagement.Project_Category__c = isPC2IICS?'Billable':'Non-Billable';
			 engagement.Project_Sub_Type__c = 'Jumpstart';
			 engagement.Project_Status__c = 'Green'; 
			 engagement.Owner_Manager__c = CSMManagerList?.size() >0 ? CSMManagerList[0].User__c : ownerManagerId;

			 if(isPC2IICS){
				proj =[SELECT Id,Name,psa_pm_Engagement__c,pse__Stage__c,pse__Project_Status__c,psa_pm_Date_of_First_Value__c,psa_om_Estimated_Begin_Date__c,psa_pm_Portfolio_Manager__r.Name,
                                                                pse__Project_Manager__c,PSA_OM_IPS_Package__c,pse__Project_Manager__r.Name,pse__Start_Date__c,pse__End_Date__c,psa_pm_Engagement_Type__c,psa_pm_Project_Sub_Type__c,pse__Project_Type__c,psa_pm_Project_Notes__c
                                                                FROM pse__Proj__c
                                                                WHERE Id = :engagement.IPS_Project__c LIMIT 1];
				
				if(proj!=null){
					engagement.Project_Name__c = proj.Name;
                    engagement.Stage__c = proj.pse__Stage__c;
                    engagement.Project_Status__c = proj.pse__Project_Status__c;
					engagement.Project_Sub_Type__c = proj.psa_pm_Project_Sub_Type__c;
                    engagement.IPS_Project_Manager__c = proj.pse__Project_Manager__r.Name;
                    engagement.Project_Manager__c = proj.pse__Project_Manager__c;
                    engagement.Portfolio_Manager__c = proj.psa_pm_Portfolio_Manager__r.Name;
                    //engagement.Project_Notes__c = proj.psa_pm_Project_Notes__c;
                    engagement.Date_of_First_Value__c = proj.psa_pm_Date_of_First_Value__c;
                    engagement.IPSProject_Start_Date__c = proj.pse__Start_Date__c;
                    engagement.IPSProject_End_Date__c = proj.pse__End_Date__c;
                    engagement.Project_Type__c = proj.pse__Project_Type__c;
                    if( proj.pse__Stage__c == 'Completed'){
						engagement.Status__c = 'Completed';
                    }else if(proj.pse__Stage__c == 'Canceled' || proj.pse__Stage__c == 'Cancelled'){
                        engagement.Status__c = 'Cancelled';
                    }
				}
			 }

		 }else if(engagement.RecordTypeId == CSTEngagement && engagement.RecType__c == 'CSA'){
			 //List<Plan_Team__c> existingCSTs = [Select Id,User__c from Plan_Team__c where Role__c = 'CST'and Plan__c =:planId and User__c <> null order by CreatedDate Desc];
			 engagement.Requested_By__c = UserInfo.getUserId();
			 Group CSTQueue = [Select Id from Group where Type='Queue' and DeveloperName='INFA_CST' Limit 1];
			 engagement.OwnerId = CSTQueue.Id;
			 if(!Test.isRunningTest()){
			 engagement.Status__c = 'Submitted for Approval';  
			 }
				   
			 //Deva : AR-1925 - Under the plan there is CST Engagement That already exisits => populate owner of the engagement 
			 //if there are multiple CST engagement => pick the latest one(CREATED DATE DESC) and suggest the owner. 
			 if(planId!=null && planId!=''){
				 for(Engagement__c objEng :[SELECT Id,OwnerId, Owner.Name From Engagement__c WHERE Plan__c =:planId AND RecordTypeId=:CSTEngagement AND RecType__c='CSA' ORDER BY CreatedDate DESC] ){
					 if(objEng.OwnerID.getsobjecttype() == User.sobjecttype ){
						 engagement.Suggested_CST__c = 'Suggested CSA: '+objEng.Owner.Name;
						 break;
					 }
				 }
			 }
			}else if(engagement.RecordTypeId == CSTEngagement && engagement.RecType__c == 'MFA'){//<T03> start
				engagement.Requested_By__c = UserInfo.getUserId();
				Group MFAQueue = [Select Id from Group where Type='Queue' and DeveloperName='INFA_MFA' Limit 1];
				engagement.OwnerId = MFAQueue.Id;
				if(!Test.isRunningTest()){
					engagement.Status__c = 'Submitted for Approval';
				}
				//if there are multiple CST engagement with type MFA => pick the latest one(CREATED DATE DESC) and suggest the owner. 
				if(planId!=null && planId!=''){
					for(Engagement__c objEng :[SELECT Id,OwnerId, Owner.Name From Engagement__c WHERE Plan__c =:planId AND RecordTypeId=:CSTEngagement AND RecType__c='MFA' ORDER BY CreatedDate DESC] ){
						if(objEng.OwnerID.getsobjecttype() == User.sobjecttype ){
							engagement.Suggested_CST__c = 'Suggested MFA: '+objEng.Owner.Name;
							break;
						}
					}
				}
			}//<T03> end
 
		 if(engagement <> null){
			 insert engagement;
			 engagementId = engagement.Id;
			 if(isPC2IICS && engagement.Id!=null && engagement.RecordTypeId == IPSJumpstart){
				pse__Proj__c projRec= new pse__Proj__c(Id=engagement.IPS_Project__c,psa_pm_Engagement__c=engagement.Id);
				     
				if(engagement.Description__c?.length()>9500){				
					projRec.psa_pm_Project_Notes__c = 'Health Score : '+accountMap.get(engagement.Account__c).Health_Score__c+'; '+'Comments:'+engagement.Description__c?.substring(0,9500)+'; '+'CSM: '+ UserInfo.getName();
				 }    
				 else{				
					projRec.psa_pm_Project_Notes__c = 'Health Score : '+accountMap.get(engagement.Account__c).Health_Score__c+'; '+'Comments:'+engagement.Description__c+'; '+'CSM: '+ UserInfo.getName();
				 }
				//update projRec;
				CSMWithoutSharingUtility.updateProject(projRec);
			 }
		 }
		 
		 if(isPC2IICS && engagement.Id!=null && engagement.RecordTypeId == IPSJumpstart){
			List<ConnectApi.BatchInput> lstBatchInput = new List<ConnectApi.BatchInput>();
			Id adoptionservices= [select id, name from CollaborationGroup where name ='Adoption Services Approvers']?.Id;
			ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
			messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
			
			messageBodyInput.messageSegments.add(ChatterService.inputMention(UserInfo.getUserId()));
			messageBodyInput.messageSegments.add(ChatterService.inputSpace());
			messageBodyInput.messageSegments.add(ChatterService.inputLink(proj.pse__Project_Manager__c));
			messageBodyInput.messageSegments.add(ChatterService.inputSpace());
			if(adoptionservices!=null){
				messageBodyInput.messageSegments.add(ChatterService.inputMention(adoptionservices));
			}
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
			messageBodyInput.messageSegments.add(ChatterService.inputText('An existing Project has been associated with this Engagement. Please refer to Project Notes for more information'));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());		 
			messageBodyInput.messageSegments.add(ChatterService.inputText('Please find the details below and take the necessary action.'));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());		 
			messageBodyInput.messageSegments.add(ChatterService.inputText('Have a great day!'));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());				
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());	

			messageBodyInput.messageSegments.add(ChatterService.inputText('Account : '));	 
			messageBodyInput.messageSegments.add(ChatterService.inputLink(engagement.Account__c));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
			
			messageBodyInput.messageSegments.add(ChatterService.inputText('Project : '));	 
			messageBodyInput.messageSegments.add(ChatterService.inputLink(engagement.IPS_Project__c));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());	
			messageBodyInput.messageSegments.add(ChatterService.inputText('Project Manager : '));
			messageBodyInput.messageSegments.add(ChatterService.inputLink(proj.pse__Project_Manager__c));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());	

			messageBodyInput.messageSegments.add(ChatterService.inputText('Engagement : '));	 
			messageBodyInput.messageSegments.add(ChatterService.inputLink(engagement.Id));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());	
			messageBodyInput.messageSegments.add(ChatterService.inputText('CSM : '));
			messageBodyInput.messageSegments.add(ChatterService.inputMention(UserInfo.getUserId()));
			messageBodyInput.messageSegments.add(ChatterService.inputNewLine());	

			messageBodyInput.messageSegments.add(ChatterService.inputText('Opportunity : '));	 
			messageBodyInput.messageSegments.add(ChatterService.inputLink(engagement.Opportunity__c));


			ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
			feedItemInput.subjectId = engagementId;
			feedItemInput.body = messageBodyInput;
			feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
			lstBatchInput.add(new ConnectApi.BatchInput(feedItemInput));

			if(!lstBatchInput.isEmpty()){
				if(!Test.isRunningTest()){
					ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), lstBatchInput);
				}
			}
		}
		 return engagementId;
	 }
 
	 /** Custom Lookup search */
	 @AuraEnabled(cacheable=true)
	public static List<LookupSearchResult> lookupSearch(String searchTerm, List<String> selectedIds, String objectName, String planId) {
		// Prepare query parameters
		
		String NNBOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Sales_Opportunity').getRecordTypeId();       
		String RenewalOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();       
		
		List<LookupSearchResult> results = new List<LookupSearchResult>();
		// Execute search query
		if(objectName == 'Opportunity'){
			 searchTerm = '%'+searchTerm+'%';
			 Set<Id> opptyIdSet = new Set<Id>();
			 Set<Id> accountIdSet = new Set<Id>();
			 for(Related_Opportunity_Plan__c interlock : [Select Id,Original_Opportunity__c,Opportunity__c,Plan__r.Account__c from Related_Opportunity_Plan__c where Plan__c =:planId]){
				 if(interlock.Original_Opportunity__c <> null){
					 opptyIdSet.add(interlock.Original_Opportunity__c);
				 }
				 if(interlock.Opportunity__c <> null){
					 opptyIdSet.add(interlock.Opportunity__c);
				 }
				 if(interlock.Plan__r.Account__c!=null){
					 accountIdSet.add(interlock.Plan__r.Account__c);
				 }
			 }
			 String opptyIcon = 'standard:opportunity';          
			 for (Opportunity oppty : [Select Id,Name from Opportunity where Id in :opptyIdSet AND AccountId IN :accountIdSet AND Name like:searchTerm ]) {
				 results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, ''));
			 }
 
		}else if(objectName == 'Contact'){
		 searchTerm = '%'+searchTerm+'%';
		 Plan_Contact__c[] lPlanContact = [Select Id,Name,Contact_Name__c,Contact__r.Name,Contact__c FROM Plan_Contact__c WHERE Id NOT IN :selectedIds AND Plan__c =:planId AND Contact__r.Name LIKE :searchTerm ];
 
		 String contactIcon = 'standard:contact';        
			 for (Plan_Contact__c con : lPlanContact) {
				 results.add(new LookupSearchResult(con.Contact__c, 'Contact', contactIcon, con.Contact_Name__c, ''));
			 }
		}else if(objectName == 'Renewal_Opportunity__c'){
			 searchTerm += '*';
			 List<List<SObject>> searchResults = [
			 FIND :searchTerm
			 IN NAME FIELDS
			 RETURNING
			 Opportunity (Id, Name WHERE Id NOT IN :selectedIds AND RecordTypeId =:RenewalOpportunity)               
			 LIMIT 10
		 ];
		 
			 String opptyIcon = 'standard:opportunity';
			 Opportunity[] lOpportunity = (List<Opportunity>) searchResults[0];
			 for (Opportunity oppty : lOpportunity) {
				 results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, ''));
			 }
		}
		//<T02>
		else if(objectName == 'pse__Proj__c'){
			searchTerm = '%'+searchTerm+'%';

			String projIcon = 'standard:shift_type';        
			for (pse__Proj__c proj : [SELECT Id,Name, psa_pm_Engagement__c,pse__Opportunity__c,psa_pm_Project_Category__c from pse__Proj__c where pse__Is_Billable__c=true AND pse__Opportunity__c=:planId AND psa_pm_Engagement__c='' AND Name LIKE :searchTerm]) {
				results.add(new LookupSearchResult(proj.Id, 'pse__Proj__c', projIcon, proj.Name, ''));
			}
		}
		//</T02>
		// Sort all results on title
		results.sort();
 
		return results;
	}
 
	
	 /*
	  Method Name : getDefaultRecords
	  Description : This method returns the dfault records of lookup.
	  Parameters  : String, called from getRecords, strRecordId Record Id.
	  Return Type : LookupSearchResult
	  modified by : Harshita Joshi <tag1>
	  */
	 @AuraEnabled(cacheable = false)
	 public static List<LookupSearchResult> getDefaultRecords(String strRecordId,String objectName) {
		 String strCleanRecordId;
		 List<LookupSearchResult> results = new List<LookupSearchResult>();
		 if(objectName == 'Contact'){
			String contactIcon = 'standard:contact';    
			//If we received a Risk Id.
				if(String.isNotBlank(strRecordId)) {
				 //We clean the plan Id.
				 strCleanRecordId = String.escapeSingleQuotes(strRecordId);
				 for (Plan_Contact__c con : [Select Id,Name,Contact_Name__c,Contact__r.Name,Contact__c FROM Plan_Contact__c WHERE Plan__c = : strCleanRecordId]) {
					 results.add(new LookupSearchResult(con.Contact__c, 'Contact', contactIcon, con.Contact_Name__c, ''));
				 }
			 }
		 }
		 //<tag1> as part of AR-2509
		 else if(objectName == 'Opportunity'){
			 Set<Id> opptyIdSet = new Set<Id>();
			 Set<Id> accountIdSet = new Set<Id>();
			 String oppIcon = 'standard:opportunity';
			 if(String.isNotBlank(strRecordId)) {
				 //We clean the plan Id.
				 strCleanRecordId = String.escapeSingleQuotes(strRecordId);
				 for (Related_Opportunity_Plan__c opp : [Select Id,Original_Opportunity__c,Opportunity__c,Plan__r.Account__c FROM Related_Opportunity_Plan__c WHERE Plan__c = : strCleanRecordId]) {
					 if(opp.Original_Opportunity__c <> null){
						 opptyIdSet.add(opp.Original_Opportunity__c);
					 }
					 if(opp.Opportunity__c <> null){
						 opptyIdSet.add(opp.Opportunity__c);
					 }
					 if(opp.Plan__r.Account__c!=null){
						 accountIdSet.add(opp.Plan__r.Account__c);
					 }
				 }
				 for(Opportunity opp : [Select Id,Name from Opportunity where Id in :opptyIdSet AND AccountId IN :accountIdSet ]){
					 results.add(new LookupSearchResult(opp.Id, 'Opportunity', oppIcon, opp.Name, ''));
				 }
			 } 
		 }//</tag1>   
		 //<T02>
		 else if(objectName == 'pse__Proj__c'){
			String projIcon = 'standard:shift_type';    
			//If we received a Risk Id.
				if(String.isNotBlank(strRecordId)) {
				 //We clean the plan Id.
				 strCleanRecordId = String.escapeSingleQuotes(strRecordId);
				 for (pse__Proj__c proj : [SELECT Id,Name, psa_pm_Engagement__c, psa_pm_Engagement__r.Name,pse__Opportunity__c,pse__Opportunity__r.Name, pse__Opportunity__r.New_Org_Opportunity_Number__c,psa_pm_Project_Category__c from pse__Proj__c where pse__Is_Billable__c=true AND pse__Opportunity__c=:strRecordId ORDER BY psa_pm_Engagement__c DESC NULLS FIRST]) {
					if(proj.psa_pm_Engagement__c==null){
					 	results.add(new LookupSearchResult(proj.Id, 'pse__Proj__c', projIcon, proj.Name, ''));
					}
					else{
						results.add(new LookupSearchResult(proj.Id, 'pse__Proj__c', projIcon, 'EngagementExist', ' '+proj.psa_pm_Engagement__r.Name+', Opportunity:'+proj.pse__Opportunity__r.Name+'; '+proj.pse__Opportunity__r.New_Org_Opportunity_Number__c));
					}
				 }
			 }
		 }
		 //</T02>   
		 return results; 
	 }
	 @AuraEnabled(cacheable = false)
	 public static Boolean checkRenewalOppty(String opptyId) {
		 Boolean isRenewalOpptyAvailable = false;
 
		 for(Contract con : [Select Id,SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c from Contract where SBQQ__Opportunity__c =:opptyId order by CreatedDate asc]){
			 if(con.SBQQ__RenewalOpportunity__c <> null){
				 isRenewalOpptyAvailable = true;
				 break;
			 }
		 }
 
		 return isRenewalOpptyAvailable;
	 }

	 /*
	<T01>
	 Method Name : emailNotification
	 Description : This methods used to send email notification for the opportunity owner,engagement owner and Account Manager for deal closure.
	 Invoked from the flow 'Deal Closure Handoff Email Notification to CSM'
	 */	
	@InvocableMethod(label='Deal Closure Email Notification to Opportunity Owner') 
	public static void emailNotification(List<string> engId )
	{
		  if(engId !=null)
		  {
			try
			{
				OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =:Label.Customer_Success_Email];
				 string engagementid;
				 List <String> sendmailtoUser = new List<String> ();
				 for(Engagement__c eng : [Select id,Opportunity__r.OwnerId,OwnerId,Account_Manager__c from Engagement__c where id=:engId])
				 {
				 engagementid=eng.id;
				 sendmailtoUser.add(eng.Opportunity__r.OwnerId);
				 sendmailtoUser.add(eng.OwnerId);
				 if(eng.Account_Manager__c !=null)
				 {
					sendmailtoUser.add(eng.Account_Manager__c);
				 }
 
				 }
				 Contact con=[select id from Contact limit 1];
				 
				 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				 mail.setToAddresses(sendmailtoUser);
				 
				 EmailTemplate emailTemplate =[Select Id from EmailTemplate where DeveloperName = 'Deal_Closure_Handoff'];
				 mail.setTemplateID(emailTemplate.Id);
				 mail.setWhatId(engagementid);
				 mail.settargetobjectid(con.id);
				 mail.setSaveAsActivity(false);
				 mail.setTreatTargetObjectAsRecipient(false);
				 mail.setOrgWideEmailAddressId(owea.Id);
			 
				 Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail });
				 system.debug('Email Sent'+er);
			}
			Catch(Exception e){
				 GAM.CreateExceptionRecords('CSMPlanEngagementController', 'Exception in emailNotification Deal Closure',e.getMessage());     
		 }    
 
		 }
		  
	}
	//</T01>

	//<T02>
	@AuraEnabled(cacheable=false)
   public static void logComment(String strPlanId, String message){
       if(String.isNotBlank(strPlanId)) {
           String strCleanPlanId = String.escapeSingleQuotes(strPlanId);
           Plan_Comment__c planCommentRecord = CSMUtilities.createPlanComment(strCleanPlanId,message,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,'Engagement',true);
           insert planCommentRecord;
       }
   }
	//<T02>

	@AuraEnabled(cacheable=true)
	public static List<Plan_Contact__c> getPlanContacts(Id planId){
		try {
			return [SELECT Id,Contact__c,Contact__r.Name,Contact__r.TimeZone_Lookup__r.Timezone__c from Plan_Contact__c WHERE Plan__c = :planId ORDER BY Contact__r.Name];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<Milestone__c> getPlanMilestones(Id planId){
		try {
			return [SELECT Id,Name from Milestone__c WHERE Status__c IN ('Yet to Start','In Progress') AND Objective__c IN (SELECT Id from Objective__c WHERE Plan__c = :planId AND Plan__r.Status__c ='Active')];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static String getTimeZone(String sidKey){
		String key='';
		 Schema.DescribeFieldResult fieldResult = Engagement__c.Customer_Time_Zone__c.getDescribe();
		 for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
			if(pickListVal.getValue().containsIgnoreCase(sidKey)){
				key = pickListVal.getValue();
				break;
			}
		 }     
		 return key;
	 }

	//<T04> start
	/*
	 Method Name : getEngagementRequestedFor
	 Description : This method maps the engagement requested for values with the values from custom metadata
	 Parameters	 : List of String - engRequestedFor
	 Return Type : String
	*/
	@AuraEnabled(cacheable=false)
	public static String getEngagementRequestedFor(List<String> engRequestedFor){
		try {
			CSM_Static_Value__mdt engReqForValues = [SELECT Id, Value_Long_text__c FROM CSM_Static_Value__mdt WHERE DeveloperName = 'CSM_Engagement_Requested_For_Mappings'];
			Map<String,String> engReqForMap = new Map<String,String>();
			for(String str:engReqForValues.Value_Long_text__c.split(';')){
				engReqForMap.put(str.split(':')[0],str.split(':')[1]);
			}
			if(engReqForMap.size()>0 && engReqForMap.containsKey(engRequestedFor[0])){
				return engReqForMap.get(engRequestedFor[0]);
			}
			return engRequestedFor[0];
		} catch (Exception e) {
			GAM.CreateLogs('Error caused while mapping the custom metadata values with engagement requested for in the class CSMPlanEngagementController in getEngagementRequestedFor method', e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}
	}
	//</T04> end
	 
 }