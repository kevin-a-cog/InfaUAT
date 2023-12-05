/*
 * Name			:	EngagementCatalogueController
 * Author		:	Chaitanya Toleti
 * Created Date	: 	06/15/2023
 * Description	:	Engagement Catalogue class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Chaitanya Toleti		06/15/2023		N/A				Initial version.			N/A
 Chaitanya Toleti		08/17/2023		AR-3365			new MFA engagement			T01
 Chaitanya Toleti		11/09/2023		AR-3542			Autopilot plan milestones
                                                         are displayed			    T02
 Chaitanya Toleti		11/29/2023		AR-3552			Increase Engagement products
                                                         length			            T03
 */
public without sharing class EngagementCatalogueController {

    /*
	 Method Name : isEUPresent
	 Description : This method checks whether the Engagement units are present for a particular account
	 Parameters	 : idAccount, strType, wrapper - EC_AEMWrapper
	 Return Type : Boolean
	*/
    @AuraEnabled(Cacheable = true)
    public static Boolean isEUPresent(String idAccount, String strType, EC_AEMWrapper EC_AEMData){
        try {
            //initally when the wire adapter is called the AEMData & idAccount will be null, so return null
            if(EC_AEMData==null || idAccount == null || idAccount == ''){
                return null;
            }
            EngagementUnitServiceWrapper objNewRecord = new EngagementUnitServiceWrapper();
            objNewRecord.strType = strType;
            objNewRecord.idAccount = idAccount;
            objNewRecord.intUnits = Integer.valueof(EC_AEMData.engagementUnit);
            objNewRecord.boolIsInternalUser = false;
            EngagementUnitServiceWrapper objResult = SuccessEngagementUnitService.validateEngagementUnits(objNewRecord);
            return objResult.boolResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : createCSAEngagement
	 Description : This method checks whether the Engagement units are present for a particular account
	 Parameters	 : idAccount, idContact, timezone, wrapper - EC_ActionsWrapper, wrapper - EC_AEMWrapper, list of wrapper - EC_AnswerWrapper, list of uploaded file Ids
	 Return Type : Boolean
	*/
    @AuraEnabled
    public static Boolean createCSAEngagement(String idAccount, String idContact, String idPlan, String timezone, String timeZoneSIDKey, EC_ActionsWrapper ecActions, EC_AEMWrapper EC_AEMData, List<EC_AnswerWrapper> EC_userResponses, List<Id> uploadedFileIds){
        Boolean isEngUnitCosumed = false;
        try {
            String approvalSubLabel = System.Label.SA_ApprovalSub_Customer;
            Engagement__c engToInsert = new Engagement__c();
            engToInsert.put('RecType__c','CSA');//<T01>
            engToInsert.put('Account__c',idAccount);
            engToInsert.put('Primary_Contact__c',idContact);
            engToInsert.put('Engagement_Model__c','Repeatable');            
            engToInsert.put('Approval_Subject_Dev__c',approvalSubLabel);
            if(timezone!=null && timezone!=''){
                engToInsert.put('Customer_Time_Zone__c',timezone);
            }else if(timeZoneSIDKey!=null && timeZoneSIDKey!=''){
                engToInsert.put('Customer_Time_Zone__c',CSMPlanEngagementController.getTimeZone(timeZoneSIDKey));
            }
            String recordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get(ecActions.recordType).getRecordTypeId();
            engToInsert.put('RecordTypeId',recordTypeId);
            Group csaGrp = [SELECT Id FROM Group WHERE DeveloperName=:ecActions.ownerQueue AND Type = 'Queue'];
            engToInsert.put('OwnerId',csaGrp.Id);
            
            engToInsert.put('AEM_EC_Id__c',EC_AEMData.engagementId);
            engToInsert.put('Engagement_ID__c',EC_AEMData.infaJourneyId);
            if(EC_AEMData.infaJourneyValue!=null){
                engToInsert.put('Engagement_Journey__c',EC_AEMData.infaJourneyValue[0]);
            }
            engToInsert.put('Title__c',EC_AEMData.title);
            engToInsert.put('Is_Internal_Engagement__c',false);
            engToInsert.put('Engagement_Category__c',convertListToString(EC_AEMData.engagementCategoryTag));
            engToInsert.put('Adoption_Stage__c',convertListToString(EC_AEMData.adoptionStageTag));
            engToInsert.put('Engagement_Products__c',convertListToString(EC_AEMData.engagementProductTag));
            engToInsert.put('Focus_Area__c',convertListToString(EC_AEMData.engagementFocusAreaTag));
            engToInsert.put('Use_case_and_Tags__c',convertListToString(EC_AEMData.engagementUseCaseTag));
            engToInsert.put('Content_Type__c',convertListToString(EC_AEMData.tags));
            engToInsert.put('Engagement_Units__c',Integer.valueof(EC_AEMData.engagementUnit));
            engToInsert.put('Requested_By_Group__c','Customer');
            engToInsert.put('Requested_By__c',UserInfo.getUserId());
            engToInsert.put('CST_Requested_for__c',getCSARequestedFor(EC_AEMData.engagementTypeTag));
            engToInsert.put('Name','Customer requested assistance with ' +EC_AEMData.infaJourneyId);
            CSM_Static_Value__mdt ameUrlMdt = CSM_Static_Value__mdt.getInstance('EC_AEM_CalloutURL');
            //List<String> urlSplit = EC_AEMData.URL.split('/');
            //Integer urlSize = urlSplit.size();
            String url = ameUrlMdt.value__c+EC_AEMData.URL+'.html';
            engToInsert.put('Catalog_URL__c',url);

            for(EC_AnswerWrapper ans:EC_userResponses){
                if(ans.Name!='Text-Readonly' && ans.Name!='File'){
                    if(ans.Type!='Datetime' && ans.Type!='Date'){
                        engToInsert.put(ans.Name,ans.Answer);
                    }
                    if(ans.Type=='Date' && ans.Answer!=null && ans.Answer!=''){
                        engToInsert.put(ans.Name,date.valueOf(ans.Answer)); 
                    }
                    if(ans.Name=='Milestone__c' && ans.Answer!=null && ans.Answer!='' && ans.Answer!='None'){
                        Milestone__c objRecord = [SELECT Objective__r.Plan__c FROM Milestone__c WHERE Id = :ans.Answer];
                        engToInsert.put('Plan__c',objRecord.Objective__r.Plan__c);
                    }
                }
            }
            if(idPlan!=null && idPlan!=''){
                engToInsert.put('Plan__c',idPlan);
            }
            if(engToInsert.get('Plan__c')!=null){
                Id planId = (Id)engToInsert.get('Plan__c');
                for(Engagement__c objEng :[SELECT Id,OwnerId, Owner.Name From Engagement__c WHERE Plan__c =:planId AND RecordTypeId=:recordTypeId ORDER BY CreatedDate DESC] ){
                    if(objEng.OwnerID.getsobjecttype() == User.sobjecttype ){
                        engToInsert.put('Suggested_CST__c','Suggested CSA: '+objEng.Owner.Name);
                        break;
                    }
                }
            }
            SavePoint spBeforeEngInsert = Database.setSavepoint();
            insert engToInsert;
            
            if(!uploadedFileIds.isEmpty()){
                List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
                for(Id fileId:uploadedFileIds){
                    ContentDocumentLink cdlink = New ContentDocumentLink();
                    cdlink.LinkedEntityId = engToInsert.Id;
                    cdlink.ContentDocumentId = fileId;
                    cdlink.shareType = 'V';
                    cdLinkList.add(cdlink);
                }
                if(!cdLinkList.isEmpty()){
                    insert cdLinkList;
                }
            }

            String strType = 'Success';
            String strContextId = engToInsert.Id;
            isEngUnitCosumed = consumeEU(strType, strContextId, idAccount, idContact, EC_AEMData.engagementUnit);
            if(isEngUnitCosumed == false){//If unable to consume eng units then revert the engagement creation.
                Database.rollback(spBeforeEngInsert);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return System.label.EC_SuccessEngagementMsg;
        return isEngUnitCosumed;
    }

    /*
	 Method Name : consumeEU
	 Description : This method calls the consumeEngagementUnits to consume the EU
	 Parameters	 : strType, strContextId, idAccount, idContact, reqUnits
	 Return Type : Boolean
	*/
    public static Boolean consumeEU(String strType, String strContextId, String idAccount, String idContact, String reqUnits){
        EngagementUnitServiceWrapper objNewRecord = new EngagementUnitServiceWrapper();
        objNewRecord.strType = strType;
        objNewRecord.strContextId = strContextId;
        objNewRecord.idAccount = idAccount;
        objNewRecord.idContact = idContact;
        objNewRecord.intUnits = Integer.valueof(reqUnits);
        EngagementUnitServiceWrapper objResponse = SuccessEngagementUnitService.consumeEngagementUnits(objNewRecord);
        return objResponse.boolResult;
    }

    /*
	 Method Name : getECUrl
	 Description : gets the full EC Url
	 Parameters	 : EC_AEMData - wrapper class EC_AEMWrapper
	 Return Type : String
	*/
    @AuraEnabled(cacheable=true)
    public static String getECUrl(EC_AEMWrapper EC_AEMData){
        try{
            CSM_Static_Value__mdt ameUrlMdt = CSM_Static_Value__mdt.getInstance('EC_AEM_CalloutURL');
            String url = ameUrlMdt.value__c+EC_AEMData.URL+'.html';
            return url;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : convertListToString
	 Description : This method converts the list of String to Substring of 255 String
	 Parameters	 : aemValue - List of String
	 Return Type : String
	*/
    private static String convertListToString(List<String> aemValue){
        String aemString = '';
        Integer count = 0;
        if(!aemValue.isEmpty()){
            aemValue.sort();
            for(String str:aemValue){
                count++;
                aemString += str;
                if(count != aemValue.size()){
                    aemString += ',';
                }
            }
        }
        /*if(aemString.length()>255){ <T03> commenting the truncation code
            aemString = aemString.substring(0,255);
        }*/
        return aemString;
    }

    /*
	 Method Name : getCSARequestedFor
	 Description : This method gets the CSARequestedFor value other than Best Practices.
	 Parameters	 : csaRequested - List of String
	 Return Type : String
	*/
    private static String getCSARequestedFor(List<String> csaRequested){
        String csaBestPractice = 'Best Practices';
        if(!csaRequested.isEmpty()){
            for(String str:csaRequested){
                if(str!=csaBestPractice){
                    csaBestPractice = str;
                    break;
                }
            }
        }
        return csaBestPractice;
    }


    /*
	 Method Name : getFieldLabelAndFieldAPI
	 Description : This method gets the Fieldset headers
	 Parameters	 : none
	 Return Type : String
	*/
    @AuraEnabled
    public static String getFieldLabelAndFieldAPI(){
        List<Map<String ,String>> listOfFieldSet  = new  List<Map<String ,String>>();
        try {
            for(Schema.FieldSetMember fieldset : SObjectType.Engagement__c.FieldSets.EngagementCatalogueDatatable.getFields()) {
                Map<String ,String> lableAPIMap = new Map<String ,String>();
                lableAPIMap.put(fieldset.getLabel(),fieldset.getFieldPath());
                listOfFieldSet.add(lableAPIMap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(SObjectType.Engagement__c.FieldSets.EngagementCatalogueDatatable.getFields());

    }

    /*
	 Method Name : getPreviousEngagements
	 Description : This method gets the Fieldset values
	 Parameters	 : accId, engagementType
	 Return Type : String
	*/
    @AuraEnabled(Cacheable = true)
    public static List<Engagement__c> getPreviousEngagements(String accId, String engagementType) {
        try {
            if(accId==null || accId=='' || engagementType=='' || engagementType==null){
                return null;
            }
            List<Schema.FieldSetMember> fieldSetList = SObjectType.Engagement__c.FieldSets.EngagementCatalogueDatatable.getFields();
            String recordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get(engagementType).getRecordTypeId();
            String queryString = 'SELECT ';
            Integer count = 0;
            for (Schema.FieldSetMember fieldSet : fieldSetList) {
                count++;
                queryString += fieldSet.getFieldPath();
                if(count!=fieldSetList.size()){
                    queryString += ',';
                }
            }
            queryString += ' FROM Engagement__c WHERE Account__c = '+'\''+accId+'\' AND RecordTypeId = '
                                +'\''+recordTypeId+'\' AND Is_Internal_Engagement__c = false '
                                +' AND Engagement_Model__c = \'Repeatable\' AND CreatedDate = LAST_N_DAYS:365 ORDER BY CreatedDate DESC';
            return Database.query(queryString);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getMilestones
	 Description : This method gets the Milestones for the contactid or the planid
	 Parameters	 : contactId, planId
	 Return Type : List of Milestone
	*/
    @AuraEnabled(Cacheable = true)
    public static List<Milestone__c> getMilestones(String contactId, String planId){
        try {
            if(planId!=null && planId!=''){
                List<Milestone__c> milestoneList = [SELECT Id, Name, Objective__r.Plan__r.Name, Is_Internal__c 
                                                        FROM Milestone__c WHERE Objective__r.Plan__c = :planId 
                                                        AND Is_Internal__c = false 
                                                        AND Objective__r.Is_Internal__c = false 
                                                        AND Objective__r.Plan__r.Is_Internal__c = false 
                                                        AND Objective__r.Plan__r.Status__c = 'Active'
                                                        AND Objective__r.Plan__r.CSM_isAutoPilot__c = false //<T02>
                                                        AND Objective__r.Plan__r.AutoPilot_Status__c != 'Submitted for Approval'//<T02>
                                                        AND Status__c IN ('Yet to Start','In Progress')];
                return milestoneList;
            }
            List<Plan_Contact__c> planContactList = [SELECT Plan__c FROM Plan_Contact__c 
                                                        WHERE Contact__c =:contactId
                                                        AND Is_Success_Community_User__c = true];
            List<Id> planIdList = new List<Id>();
            List<Milestone__c> milestoneList;
            if(!planContactList.isEmpty()){
                for(Plan_Contact__c planContact:planContactList){
                    planIdList.add(planContact.Plan__c);
                }
                if(!planIdList.isEmpty()){
                    milestoneList = [SELECT Id, Name, Objective__r.Plan__r.Name, Is_Internal__c 
                                        FROM Milestone__c WHERE Objective__r.Plan__c IN :planIdList 
                                        AND Is_Internal__c = false 
                                        AND Objective__r.Is_Internal__c = false 
                                        AND Objective__r.Plan__r.Is_Internal__c = false 
                                        AND Objective__r.Plan__r.Status__c = 'Active'
                                        AND Objective__r.Plan__r.CSM_isAutoPilot__c = false//<T02>
                                        AND Objective__r.Plan__r.AutoPilot_Status__c != 'Submitted for Approval'//<T02>
                                        AND Status__c IN ('Yet to Start','In Progress')];
                }
            }
            return milestoneList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : hasActiveExternalPlan
	 Description : This method checks whether the contact has any active external plans associated
	 Parameters	 : idContact
	 Return Type : Boolean
	*/
    @AuraEnabled(Cacheable = true)
    public static Boolean hasActiveExternalPlan(String idContact, String idPlan){
        try {
            if(idPlan!=null && idPlan!=''){
                Integer count = [SELECT COUNT() FROM Plan__c
                                WHERE Id = :idPlan
                                AND Is_Internal__c = false
                                AND Status__c ='Active'
                                AND CSM_isAutoPilot__c = false
                                AND AutoPilot_Status__c != 'Submitted for Approval'];//<T02>
                if(count>0){
                    return true;
                }
                return false;
            }
            if(idContact == null && idContact == ''){
                return null;
            }
            Integer count = [SELECT COUNT() FROM Plan_Contact__c  
                                WHERE Contact__c = :idContact 
                                AND Plan__r.Is_Internal__c = false 
                                AND Is_Success_Community_User__c = true 
                                AND Plan__r.Status__c ='Active'
                                AND Plan__r.CSM_isAutoPilot__c =false//<T02>
                                AND Plan__r.AutoPilot_Status__c != 'Submitted for Approval'];//<T02>
            if(count>0){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getUserDetails
	 Description : This method gets the logged in user details
	 Parameters	 : none
	 Return Type : User
	*/
    @AuraEnabled(Cacheable = true)
    public static User getUserDetails(){
        try {
            User oktaUser = [SELECT Id, Email,ContactId, Contact.AccountId,Contact.TimeZone_Lookup__r.Timezone__c,TimeZoneSidKey
                                FROM User WHERE IsActive = true 
                                AND usertype IN ('powercustomersuccess')
                                AND Id=:UserInfo.getUserId()];
            return oktaUser;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getECActions
	 Description : This method gets the action & question list
	 Parameters	 : actionId
	 Return Type : wrapper of EC_ActionsWrapper
	*/
    @AuraEnabled(cacheable = true)
    public static EC_ActionsWrapper getECActions(String actionId){
        try {
            if(actionId=='' || actionId==null){
                return null;
            }
            EC_ActionsWrapper actWrapper = new EC_ActionsWrapper();
            EC_Action__c ec_action = [SELECT Id,Name,Action_Label__c,Object__c,Record_Type__c,Queue__c,(SELECT Id,Label__c,Data_Type__c,Field_API_Name__c,Is_Required__c,Options_TextMessage__c,Name,Sort_Order__c,Placeholder__c,Tooltip__c FROM Questions_Engagement_Catalog__r ORDER BY Sort_Order__c) FROM EC_Action__c WHERE AEM_Action_Id__c = :actionId];
            actWrapper.uniqueName = ec_action.Name;
            actWrapper.label = ec_action.Action_Label__c;
            actWrapper.sobjectAPIName = ec_action.Object__c;
            actWrapper.recordType = ec_action.Record_Type__c;
            actWrapper.ownerQueue = ec_action.Queue__c;
            List<EC_ActionsWrapper.EC_QuestionsWrapper> questWrapperList = new List<EC_ActionsWrapper.EC_QuestionsWrapper>();
            for(EC_Questions__c ec_ques:ec_action.Questions_Engagement_Catalog__r){
                EC_ActionsWrapper.EC_QuestionsWrapper questWrapper = new EC_ActionsWrapper.EC_QuestionsWrapper();
                questWrapper.Label = ec_ques.Label__c;
                questWrapper.Type = ec_ques.Data_Type__c;
                questWrapper.Is_Required = ec_ques.Is_Required__c;
                questWrapper.Type_Option = ec_ques.Options_TextMessage__c;
                questWrapper.Name = ec_ques.Name;
                questWrapper.Sort_Order = (Integer)ec_ques.Sort_Order__c;
                questWrapper.Placeholder = ec_ques.Placeholder__c;
                questWrapper.Tooltip = ec_ques.Tooltip__c;
                questWrapper.FieldApiName = ec_ques.Field_API_Name__c;
                questWrapperList.add(questWrapper);
            }
            actWrapper.questions = questWrapperList;
            return actWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getAEMParameterDetails
	 Description : This method makes a callout to AEM
	 Parameters	 : engagementId
	 Return Type : wrapper of EC_AEMWrapper
	*/
    @AuraEnabled(cacheable = true)
    public static EC_AEMWrapper getAEMParameterDetails(String engagementId){
        if(engagementId=='' || engagementId ==null){
            return null;
        }
        try {
            EC_AEMWrapper aemDetails;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            CSM_Static_Value__mdt ameUrlMdt = CSM_Static_Value__mdt.getInstance('EC_AEM_CalloutURL');
            String url = ameUrlMdt.value__c+'/content/informatica-cxp/resourcepaths/catalog.metadata.json?engagementId='+engagementId;
            req.setEndpoint(url);
            req.setMethod('GET');
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                aemDetails = (EC_AEMWrapper) JSON.deserialize(res.getBody(), EC_AEMWrapper.class);
            }
            return aemDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getAcceptedFileFormats
	 Description : This method gets the accepted file formats
	 Parameters	 : none
	 Return Type : List of String
	*/
    /*@AuraEnabled
    public static List<String> getAcceptedFileFormats(){
        try {
            List<String> acceptedFormates = new List<String>();
            List<Accepted_File_Type__mdt> fileFormates = New List<Accepted_File_Type__mdt>();
            fileFormates = [SELECT Id, Developername from Accepted_File_Type__mdt];
            if(!fileFormates.isEmpty()){
                for(Accepted_File_Type__mdt fileFormate : fileFormates){
                    acceptedFormates.add('.'+fileFormate.Developername);
                }
            }
            return acceptedFormates;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/

    /*
	 Method Name : deleteFile
	 Description : This method deletes the uploaded file
	 Parameters	 : Id
	 Return Type : none
	*/
    @AuraEnabled
    public static void deleteFile(Id fileIdToDelete) {
		Database.delete(fileIdToDelete, false);
	}

    public class EC_AnswerWrapper{
        @AuraEnabled
        public String Name{get;set;}

        @AuraEnabled
        public String Answer{get;set;}

        @AuraEnabled
        public String Type{get;set;}
    }
}