/*
* Name			:	CSMSendSurveyToPlanContacts
* Author		:	Pavithra V
* Created Date	: 	09/29/2021
* Description	:	Send Survey To Plan Contacts

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					                Tag
**********************************************************************************************************
 Narpavi Prabu     13/03/2023       AR-3113       Update the eng owner in plan for engagement  T01
                                                  insert  
 Chaitanya T       08/25/2023       AR-3365       new Engagement type MFA                       T02
 Chaitanya T       11/27/2023       AR-3408       Plan contact is not receiving Survey for 
                                                  another Engagement once responded to Survey   T03
*/
public class CSMSendSurveyToPlanContacts {
    
	public static String ONBOARDING_SURVEY = 'ONBOARDING_SURVEY';
    public static String OUTCOME_SURVEY = 'OUTCOME_SURVEY';
    public static String CST_SURVEY = 'CST_SURVEY';
    public static String MFA_SURVEY = 'MFA_SURVEY';
    
    
    /*
    Method Name : updateengowneronplan 
    Description : Methods to update eng owner name on plan as this is needed for getfeedback survey to show eng owner for CST surveys
    */
    @AuraEnabled
    public static void updateengowneronplan(List<Engagement__c> englist){ 
        Plan__c pl;
        List<Plan__c> updateplanlist = new List<Plan__c>();
        try{
            //<T01>
            for(Engagement__c eng:[Select id,Owner.Name,Plan__c from Engagement__c where id IN : englist] ){
                if(eng.Plan__c != null && eng.Owner.Name != null){
                    pl = new Plan__c();                    
                    pl.Id = eng.Plan__c;                    
                    pl.Dev_CST_Engagement_Owner__c = eng.Owner.Name;                    
                    updateplanlist.add(pl);
                    system.debug('New Test www');
            	}
            }
        	if(updateplanlist.size() > 0)            	
                update updateplanlist;
        }Catch(Exception e){
            System.debug('Exception occured in updateengowneronplan:'+e.getmessage()+e.getLineNumber());
        }
    }
    
    
    /*
    Method Name : updateSurveyFlagOnPlanContact
    Description : Methods to update the Survey flags in Plan Contacts to trigger the Survey email
    */
    @AuraEnabled
    public static void updateSurveyFlagOnPlanContact(List<String> planList , String surveyType){
        List<Plan_Comment__c> planCommentList = new List<Plan_Comment__c>();
        List<Plan_Contact__c> pContactUpdateList = new List<Plan_Contact__c>();
        List<Plan_Contact__c> planContactList = new List<Plan_Contact__c>();
        List<String> rolesList = new List<String>();
        Set<Id> respondedPlanContactIds = new Set<Id>();
        Set<Id> resendPlanContactIds = new Set<Id>();
        String recordTypeName = '';
        String engType = '';//<T03>
        
        /** Get the Roles & Survey RecordType Name from Custom Label **/
        if(surveyType == ONBOARDING_SURVEY){
           rolesList = System.label.CSMOnboardingSurveyRoles.split(';');
		   recordTypeName = System.label.CSMOnboardingRecordType;           
        } else if(surveyType == OUTCOME_SURVEY){
            rolesList =  System.label.CSMOutcomeSurveyRoles.split(';');
            recordTypeName = System.label.CSMOutcomeRecordType;  
        }else if(surveyType == CST_SURVEY){
            rolesList =  System.label.CSMCSTSurveyRoles.split(';');
            recordTypeName = System.label.CSMCSTRecordType;
            engType = 'CSA';//<T03>  
        }else if(surveyType == MFA_SURVEY){//<T02> start
            rolesList =  System.label.CSMMFASurveyRoles.split(';');
            recordTypeName = System.label.CSMMFARecordType;
            engType = 'MFA';//<T03>
        }//<T02> end
         
        /** Get the applicable Plan Contact List as per the Survey Type **/
		String query = 'SELECT Id,Business_Outcome_Survey_Sent__c,CST_Survey_Sent__c,Onboarding_Survey_Count__c,Outcome_Survey_Count__c,CST_Survey_Count__c,Contact_Name__c,Plan__c,MFA_Survey_Sent__c,MFA_Survey_Count__c FROM Plan_Contact__c WHERE Plan__c IN :planList';
		
        if(rolesList?.size() > 0){
           query += ' AND Role__c IN :rolesList';
        }
        List<Plan_Contact__c> totalPlanContactList = Database.query(query);
		
        if(surveyType == ONBOARDING_SURVEY || surveyType == OUTCOME_SURVEY){//<T03> start
            /** Get the Plan Contacts who responded to the Survey Already **/
            for(Survey_Response__c response : [SELECT Id,Plan_Contact__c,Plan__c from Survey_Response__c where Plan_Contact__c in:totalPlanContactList and RecordType.DeveloperName =:recordTypeName]){
                respondedPlanContactIds.add(response.Plan_Contact__c);
            }
            
            /** Filter the Plan Contacts who haven't responded to the Survey yet **/
            for(Plan_Contact__c pCon : totalPlanContactList){
                if(!respondedPlanContactIds.contains(pCon.Id)){
                    planContactList.add(pCon);
                }
            }
        }else{
            Map<Id,Integer> planEngCountMap = new Map<Id,Integer>();
            Set<Id> notRespondedPlanContactIds = new Set<Id>();
            // Fetch all the engagements under each plan and create a map with key - planId and value - no of engagements
            for(AggregateResult eng:[SELECT Plan__c, COUNT(Id) NoOfEng FROM Engagement__c WHERE Plan__c IN :planList AND Status__c !='Close without Engagement' AND RecType__c =:engType GROUP BY Plan__c]){
                planEngCountMap.put((Id)eng.get('Plan__c'),(Integer)eng.get('NoOfEng'));
            }
            // Initialize a map of plan contacts and each survey responses as 0 under each plan
            Map<Id,Map<Id,Integer>> totalPlanIdPlanContactMap = new Map<Id,Map<Id,Integer>>();
            for(Plan_Contact__c pCon:totalPlanContactList){
                if(totalPlanIdPlanContactMap.containsKey(pCon.Plan__c)){
                    Map<Id,Integer> planContactMap = totalPlanIdPlanContactMap.get(pCon.Plan__c);
                    planContactMap.put(pCon.Id,0);
                    totalPlanIdPlanContactMap.put(pCon.Plan__c,planContactMap);
                }else{
                    Map<Id,Integer> planContactMap = new Map<Id,Integer>();
                    planContactMap.put(pCon.Id,0);
                    totalPlanIdPlanContactMap.put(pCon.Plan__c,planContactMap);
                }
            }
            // Iterate through all the responses and calculate the count of each plan contact no of responses
            for(AggregateResult response : [SELECT COUNT(Id) surevyResponses,Plan_Contact__c,Plan__c FROM Survey_Response__c WHERE Plan_Contact__c in:totalPlanContactList AND RecordType.DeveloperName =:recordTypeName GROUP BY Plan_Contact__c,Plan__c]){
                if(totalPlanIdPlanContactMap.containsKey((Id)response.get('Plan__c'))){
                    Map<Id,Integer> PlanContactResponseMap = totalPlanIdPlanContactMap.get((Id)response.get('Plan__c'));
                    PlanContactResponseMap.put((Id)response.get('Plan_Contact__c'),(Integer)response.get('surevyResponses'));
                    totalPlanIdPlanContactMap.put((Id)response.get('Plan__c'),PlanContactResponseMap);
                }else{
                    Map<Id,Integer> PlanContactResponseMap = new Map<Id,Integer>();
                    PlanContactResponseMap.put((Id)response.get('Plan_Contact__c'),(Integer)response.get('surevyResponses'));
                    totalPlanIdPlanContactMap.put((Id)response.get('Plan__c'),PlanContactResponseMap);
                }
            }
            // For each plan, the no of survey responses of each plan contact is less than no of engagements, then consider that plan contact
            if(totalPlanIdPlanContactMap.size()>0){
                for(Id planId:totalPlanIdPlanContactMap.keySet()){
                    for(Id planContactId:totalPlanIdPlanContactMap.get(planId).keySet()){
                        Integer noOfEng = planEngCountMap?.get(planId);
                        Integer noOfSurveyResponses = totalPlanIdPlanContactMap.get(planId).get(planContactId);
                        if(noOfSurveyResponses < noOfEng){
                            notRespondedPlanContactIds.add(planContactId);
                        }
                    }
                }
            }
            for(Plan_Contact__c pCon : totalPlanContactList){
                if(notRespondedPlanContactIds?.contains(pCon.Id)){
                    planContactList.add(pCon);
                }
            }
        }//</T03> end
        Map<Id,List<String>> onBoardingSurveyMap = new Map<Id,List<String>>();
        Map<Id,List<String>> outcomeSurveyMap = new Map<Id,List<String>>();
        Map<Id,List<String>> cstSurveyMap = new Map<Id,List<String>>();
        Map<Id,List<String>> mfaSurveyMap = new Map<Id,List<String>>();
        /** Update the Survey flags in Plan Contact **/
        for(Plan_Contact__c pCon : planContactList){
            if(surveyType == ONBOARDING_SURVEY){
                if(pCon.Onboarding_Survey_Count__c == null){
                    pCon.Onboarding_Survey_Count__c = 0;
                }
                pCon.Onboarding_Survey_Count__c = pCon.Onboarding_Survey_Count__c + 1;
                pCon.Onboarding_Survey_Sent__c = true;
                pContactUpdateList.add(pCon);
                if(!onBoardingSurveyMap.containsKey(pCon.Plan__c)){
                    onBoardingSurveyMap.put(pCon.Plan__c, new List<String>{pCon.Contact_Name__c});
                }else{
                    onBoardingSurveyMap.get(pCon.Plan__c).add(pCon.Contact_Name__c);
                }
            }else if(surveyType == OUTCOME_SURVEY){
                if(pCon.Outcome_Survey_Count__c == null){
                    pCon.Outcome_Survey_Count__c = 0;
                }
                pCon.Outcome_Survey_Count__c = pCon.Outcome_Survey_Count__c + 1;
                pCon.Business_Outcome_Survey_Sent__c = true;
                pContactUpdateList.add(pCon);
                if(!outcomeSurveyMap.containsKey(pCon.Plan__c)){
                    outcomeSurveyMap.put(pCon.Plan__c, new List<String>{pCon.Contact_Name__c});
                }else{
                    outcomeSurveyMap.get(pCon.Plan__c).add(pCon.Contact_Name__c);
                }
            }else if(surveyType == CST_SURVEY){
                if(pCon.CST_Survey_Count__c == null ){
                    pCon.CST_Survey_Count__c = 0;   
                              
                }
                pCon.CST_Survey_Sent__c = true;   
                pCon.CST_Survey_Count__c = pCon.CST_Survey_Count__c + 1;               
                pContactUpdateList.add(pCon);
                if(!cstSurveyMap.containsKey(pCon.Plan__c)){
                    cstSurveyMap.put(pCon.Plan__c, new List<String>{pCon.Contact_Name__c});
                }else{
                    cstSurveyMap.get(pCon.Plan__c).add(pCon.Contact_Name__c);
                }
            }else if(surveyType == MFA_SURVEY){//<T02> start
                if(pCon.MFA_Survey_Count__c == null){
                    pCon.MFA_Survey_Count__c = 0;
                }
                pCon.MFA_Survey_Sent__c = true;
                pCon.MFA_Survey_Count__c = pCon.MFA_Survey_Count__c + 1;
                pContactUpdateList.add(pCon);
                if(!mfaSurveyMap.containsKey(pCon.Plan__c)){
                    mfaSurveyMap.put(pCon.Plan__c, new List<String>{pCon.Contact_Name__c});
                }else{
                    mfaSurveyMap.get(pCon.Plan__c).add(pCon.Contact_Name__c);
                }
            }//<T02> end
        }

        if(onBoardingSurveyMap.size()>0){
            for(Id planRecordId:onBoardingSurveyMap.keySet()){
                planCommentList.add(CSMUtilities.createPlanComment(planRecordId,'<p>Onboarding Survey sent to following contact(s): </p>' + '<p>' +  String.join(onBoardingSurveyMap.get(planRecordId), ', ')+ '</p>' ,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }           
        }
        if(outcomeSurveyMap.size()>0){
            for(Id planRecordId:outcomeSurveyMap.keySet()){
                planCommentList.add(CSMUtilities.createPlanComment(planRecordId,'<p>Business Outcome Survey sent to following contact(s): </p>' + '<p>' +  String.join(outcomeSurveyMap.get(planRecordId), ', ')  + '</p>' ,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }
        }
        if(cstSurveyMap.size()>0){
            for(Id planRecordId:cstSurveyMap.keySet()){
                planCommentList.add(CSMUtilities.createPlanComment(planRecordId,'<p>CSA Survey sent to following contact(s): </p>' + '<p>' +   String.join(cstSurveyMap.get(planRecordId), ', ') + '</p>' ,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }
        }
        if(mfaSurveyMap.size()>0){//<T02> start
            for(Id planRecordId:mfaSurveyMap.keySet()){
                planCommentList.add(CSMUtilities.createPlanComment(planRecordId,'<p>MFA Survey sent to following contact(s): </p>' + '<p>' +   String.join(mfaSurveyMap.get(planRecordId), ', ') + '</p>' ,CSMUtilities.STATUS_SUBMITTED,CSMUtilities.TYPE_INTERNAL,CSMUtilities.SUBTYPE_PLAN,TRUE));
            }
        }//<T02> end
      
        System.debug('pContactUpdateList >> '+ pContactUpdateList);
        /**  Update the checkboxes to true to Send the Survey **/
        if(pContactUpdateList?.size()>0){
            update pContactUpdateList;
        }

        if(planCommentList.size()>0){
            insert planCommentList;
        }
        
    }

    //<T03> start
    /*
    Method Name : updateSurveyFlagOnPlanContact
    Description : Method to update the Survey flags on Engagement once survey is sent
    Parameters	: String engRecId, engRecType
	Return Type : n/a
    */
    @AuraEnabled
    public static void updateSurveyFlagOnEng(String engRecId, String engRecType){
        globalApexManager GAM = new globalApexManager();
        List<Schema.SObjectType> sObjects = new Schema.SObjectType[] {Engagement__c.SobjectType};
        UnitOfWork uow = new UnitOfWork(sObjects);
        Engagement__c engRec = [SELECT Id,CST_Survey_Sent__c,MFA_Survey_Sent__c FROM Engagement__c WHERE Id=:engRecId];
        if(engRecType == 'CSA'){
            engRec.CST_Survey_Sent__c = true;
        }else if(engRecType == 'MFA'){
            engRec.MFA_Survey_Sent__c = true;
        }

        try{
            uow.registerDirty(engRec);
            uow.commitWork();
        }catch(Exception e){
            GAM.CreateExceptionRecords('Error caused from updating the Eng Survey Sent flag status', e.getMessage(),engRecId);
            throw new AuraHandledException(e.getMessage());
        }
    }//</T03> end
}