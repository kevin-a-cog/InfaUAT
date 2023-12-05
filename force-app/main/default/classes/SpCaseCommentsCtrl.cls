/*
 * Name			:	SpCaseCommentsCtrl
 * Author		:	Akhilesh Soni
 * Created Date	: 	2/1/2022
 * Description	:	Class used to create or fetch case comments.

 Change History
 *****************************************************************************************************************************
 Modified By			 Date			Jira No.		Description					                         Tag
 *****************************************************************************************************************************
 Harshita J		        07/11/2022		AR-2817			Added signoff validation	                         <t1>
 Harshita j             07/20/2022      AR-2840         check if comment is already signedOff or not         <t2>
 Karthi G               23-09-2022      AR-2948         Remove Email from Customer portal                    <T3>

 *****************************************************************************************************************************
 */
public without sharing class SpCaseCommentsCtrl {
  @AuraEnabled(cacheable=true)
    public static List<CSMPlanCommunicationWrapperClass> fetchPlanComment(string planId,string sortDirection, string cmtSearchText, boolean bRefreshData){
        return fetchPlanCommentGeneral(planId, sortDirection, cmtSearchText, bRefreshData);
    } 

	@AuraEnabled(cacheable=false)
    public static List<CSMPlanCommunicationWrapperClass> fetchPlanCommentNoCache(string planId,string sortDirection, string cmtSearchText, boolean bRefreshData){
        return fetchPlanCommentGeneral(planId, sortDirection, cmtSearchText, bRefreshData);
    } 

	private static List<CSMPlanCommunicationWrapperClass> fetchPlanCommentGeneral(string planId,string sortDirection, string cmtSearchText, boolean bRefreshData){
      //  Boolean boolShouldDisplayEmails = false;   //<T3>
        Boolean checkSignOffAccess = checkSignOffAccess(planId);
        Boolean checkSignOffRecords = checkSignOffRecords(planId);
        CSMPlanCommunicationWrapperClass objWrappedRecord;
        List<CSMPlanCommunicationWrapperClass> lstPlan_Comment = new List<CSMPlanCommunicationWrapperClass>();

        //We create the datetime filter.
        DateTime datTFilterDate = DateTime.parse(Label.Plan_Comment_Limit);

        //Now we execute the queries.
        string sQuery = 'SELECT id, Case__c, Case__r.CaseNumber, Inbound__c, Is_Automated__c,Comment__c,Parent_Comment__c,Createdby.Name, Createdby.FirstName,Createdby.LastName, CreatedBy.FullPhotoUrl,CreatedDate, LastModifiedDate, CreatedById, Plan__c, ' +
                'Subject__c, Type__c, Request_Sign_Off__c, Sub_Type__c, Status__c, Visibility__c, Importance__c, Date_Time_Scheduled__c, Plan__r.Id, (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks), ' + 
                '(SELECT Is_Automated__c, id,Inbound__c, Comment__c,Parent_Comment__c,Createdby.Name, Createdby.FirstName,Createdby.LastName, CreatedBy.FullPhotoUrl,CreatedDate, LastModifiedDate, CreatedById, Plan__c,Subject__c, Type__c, Request_Sign_Off__c, Sub_Type__c, Status__c, Visibility__c, Importance__c, Date_Time_Scheduled__c, Plan__r.Id,Created_By__c FROM Plan_Comments__r), Created_By__c FROM Plan_Comment__c  WHERE Visibility__c = \'External\'  AND Status__c=\'Submitted\' AND (Type__c = \'External\' OR ' + 
                'Type__c = \'Inbound\') AND Plan__c =: planId AND CreatedDate >= :datTFilterDate'; 
        for(Plan_Comment__c pc : Database.query(sQuery)){  
            system.debug('pc>>>>>>>'+pc);
            system.debug('cmtSearchText>>>>>>>'+cmtSearchText);
            
           if(cmtSearchText == ''){
            objWrappedRecord = CSMPlanCommunicationController.convertSObjectToPlanCommentWrapper(pc);
            objWrappedRecord.boolExternalSorting = true;
            objWrappedRecord.strSortDirection = sortDirection;
            //<t2>
            if(pc.Comment__c.contains(label.Check_If_Request_For_Sign_OFF)){
              objWrappedRecord.needToSignOff = true;
            }
            else{
              objWrappedRecord.needToSignOff = false;   
            }
            //</t2>
            objWrappedRecord.hasSignOffAccess = checkSignOffAccess;//<t1/>
            objWrappedRecord.hasSignOffRecords = checkSignOffRecords;//<t1/>
            
            lstPlan_Comment.add(objWrappedRecord);
           }
           else{
            if(pc.Comment__c.containsIgnoreCase(cmtSearchText)) {
                objWrappedRecord = CSMPlanCommunicationController.convertSObjectToPlanCommentWrapper(pc);
                objWrappedRecord.boolExternalSorting = true;
                objWrappedRecord.strSortDirection = sortDirection;
                //<t2>
                if(pc.Comment__c.contains(label.Check_If_Request_For_Sign_OFF)){
                 objWrappedRecord.needToSignOff = true;
                }
                else{
                 objWrappedRecord.needToSignOff = false;   
                }
                //</t2>
                 objWrappedRecord.hasSignOffAccess = checkSignOffAccess;//<t1/>
                 objWrappedRecord.hasSignOffRecords = checkSignOffRecords;//<t1/>
                lstPlan_Comment.add(objWrappedRecord);
            }
           }                      
        }

        //<T3>
    /*    //Now we check if the current user has access to Emails.
        for(User objCurrentUser : [SELECT ContactId FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1]) {
            for(Plan_Contact__c objPlanContact : [SELECT Role__c FROM Plan_Contact__c WHERE Contact__c = :objCurrentUser.ContactId AND Plan__c = :planId LIMIT 1]) {
                for(CSM_Plan_Contacts_Role_Access__mdt objAccess : [SELECT Role_Access__c FROM CSM_Plan_Contacts_Role_Access__mdt WHERE Functionality_Name__c = 'Show Email in Community' LIMIT 1]) {
                    if(String.isNotBlank(objPlanContact.Role__c) && String.isNotBlank(objAccess.Role_Access__c) && objAccess.Role_Access__c.containsIgnoreCase(objPlanContact.Role__c)) {
                        boolShouldDisplayEmails = true;
                    }
                }
            }
        }

        //Now we query the email records.
        if(boolShouldDisplayEmails) {
            for(EmailMessage objEmailMessage : [SELECT MessageDate, Id, FromName, Incoming, CreatedById, Plan__c, Subject, HTMLBody, LastModifiedDate, CreatedDate, CreatedBy.FullPhotoUrl, 
                    CreatedBy.Name, Createdby.FirstName, Createdby.LastName, Plan__r.CSM_isAutoPilot__c, (SELECT ContentDocument.Title, ContentDocument.FileExtension, ContentDocumentId, Id FROM 
                    ContentDocumentLinks) FROM EmailMessage WHERE RelatedToId = :planId AND MessageDate >= :datTFilterDate LIMIT 10000]) {
                
                //We return all the records if no search term was provided, or if the record matches the search terms.
                if(String.isBlank(cmtSearchText) || objEmailMessage.HTMLBody.containsIgnoreCase(cmtSearchText)) {
                    objWrappedRecord = CSMPlanCommunicationController.convertSObjectToPlanCommentWrapper(objEmailMessage);
                    objWrappedRecord.boolExternalSorting = true;
                    objWrappedRecord.strSortDirection = sortDirection;
                    objWrappedRecord.hasSignOffAccess = checkSignOffAccess;//<t1/>
                    objWrappedRecord.hasSignOffRecords = checkSignOffRecords;//<t1/>
                    lstPlan_Comment.add(objWrappedRecord);
                }
            }
        } */ 
        //</T3>
        
        //We sort the record.
        lstPlan_Comment.sort();

        //Return the results.
        return lstPlan_Comment;
    }  
    //<t1>
    public static Boolean checkSignOffAccess(string planId){
    Boolean boolShouldSignOff = false;
      list<User> objCurrentUser = [SELECT ContactId FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
            for(Plan_Contact__c objPlanContact : [SELECT Role__c FROM Plan_Contact__c WHERE Contact__c = :objCurrentUser[0].ContactId AND Plan__c = :planId LIMIT 1]) {
                for(CSM_Plan_Contacts_Role_Access__mdt objAccess : [SELECT Role_Access__c FROM CSM_Plan_Contacts_Role_Access__mdt WHERE  Functionality_Name__c = 'Objective Sign Off' LIMIT 1]) {
                    if(String.isNotBlank(objPlanContact.Role__c) && String.isNotBlank(objAccess.Role_Access__c) && objAccess.Role_Access__c.containsIgnoreCase(objPlanContact.Role__c)){
                        boolShouldSignOff = true;
                    }
                }
            }
       return boolShouldSignOff; 
    }
    public static Boolean checkSignOffRecords(string planId){
    Boolean boolShouldSignOff = false;
    String strObjectName = Objective__c.class.getName();
     list<Objective__c> objRecords =  Database.query('SELECT id,' + 'Business_Goal__c, Technical_Goal__c FROM ' + strObjectName + 
					' WHERE Plan__c = :planId AND Sign_Off_Status__c = \'Waiting for Customer Signoff\' AND Is_Internal__c = FALSE LIMIT 10000');
       if(objRecords.size() >0){
          boolShouldSignOff = true;
       }
       return boolShouldSignOff; 
    }
    //</t1>
    @AuraEnabled
    public static string createNewPlanComment(string sComment, string planid){
      try {
        Plan_Comment__c pc = new Plan_Comment__c ();
        pc.Comment__c = sComment;
        pc.Visibility__c = 'External';
        pc.Type__c = 'Inbound';
        pc.Status__c = 'Submitted';
        pc.Plan__c = planid;
        INSERT pc; 
        return pc.Id;
        
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    
    }
   
    @AuraEnabled(cacheable = false)
    public static void tagFilestoComments(String strPlanId, String strCommentId,List<String> fileIdList) {
        List<ContentDocumentLink> lstContentDocLink = new List<ContentDocumentLink>();
        List<ContentDocumentLink> lstContentDocLinkToInsert = new List<ContentDocumentLink>();
        if(!fileIdList.isEmpty()) {
            Set<Id> setCommentId = new Set<Id>();
            setCommentId.add(Id.valueOf(strCommentId));
            lstContentDocLink = [Select Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension 
            From ContentDocumentLink 
            Where ContentDocumentId In :fileIdList];
        }
        for(ContentDocumentLink contentDocLink : lstContentDocLink) {
            if(contentDocLink.LinkedEntityId == Id.valueOf(strPlanId)){
                lstContentDocLinkToInsert.add(new ContentDocumentLink(LinkedEntityId = strCommentId, ContentDocumentId = contentDocLink.ContentDocumentId));
            }
        }
        //insert attachments
        if(!lstContentDocLinkToInsert.isEmpty()) {
            insert lstContentDocLinkToInsert;
        }
    }
}