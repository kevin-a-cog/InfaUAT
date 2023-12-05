/*
 * Name      :  spPlanDetailsController
 * Author    :  Akhilesh Soni
 * Created Date  :   1/18/2022
 * Description  :  Class to handle Plan, plancomment creation from community

 Change History
 **********************************************************************************************************
 Modified By      Date      Jira No.    Description                      Tag
 **********************************************************************************************************
 Harshita Joshi  08/06/2022 AR-2754    handle the plan comment format     T01
 Harshita Joshi  21/10/2022 AR-2984    handle cases w.r.t contact         T02
 */
public without sharing class spPlanDetailsController {

    //Public variables.
    public static final String STRING_COMMENT_HEADER = '<strong>Following update has been made by ' + UserInfo.getName() + '/' + UserInfo.getUserEmail() + 
            '. Please do the needful.</strong><br></br><br></br>';
   @AuraEnabled(cacheable=true)
   public static wrapperPlanContactsRoleAccess planControlAccessInfo(string selectedPlanId){
      
      wrapperPlanContactsRoleAccess oWrapperPlanContactsRoleAccess = new wrapperPlanContactsRoleAccess();
      oWrapperPlanContactsRoleAccess.hasSignOffAccess = false;
      oWrapperPlanContactsRoleAccess.hasObjectivesandMilestonesAccess = false;
      oWrapperPlanContactsRoleAccess.hasManageContactsAccess = false;

      list<Plan_Contact__c> lstPlanContact = new list<Plan_Contact__c>();
      User oCurrentUser = [Select Id,Name,Email From User Where Id =: userinfo.getUserId() LIMIT 1];

      list<CSM_Plan_Contacts_Role_Access__mdt> lstMetaPlanContacts = [Select Id,label,Functionality_Name__c,
                                                                      Role_Access__c,developerName 
                                                                      from CSM_Plan_Contacts_Role_Access__mdt];
      list<string> lstRoles_ObjectiveSignOff = new list<string>();
      list<string> lstRoles_ObjectivesandMilestones = new list<string>();
      list<string> lstRoles_ManageContacts = new list<string>();

      for(CSM_Plan_Contacts_Role_Access__mdt pcr : lstMetaPlanContacts){
         if(pcr.Functionality_Name__c == 'Objective Sign Off'){
            lstRoles_ObjectiveSignOff = pcr.Role_Access__c.split(';'); 
         } 

         if(pcr.Functionality_Name__c == 'Objectives and Milestones'){
            lstRoles_ObjectivesandMilestones = pcr.Role_Access__c.split(';');
         }

         if(pcr.Functionality_Name__c == 'Manage Contacts'){
            lstRoles_ManageContacts = pcr.Role_Access__c.split(';');
         }         
      }

      for(Plan_Contact__c pc : [SELECT Id,Role__c
                                FROM Plan_Contact__c
                                WHERE Contact_email__c = :oCurrentUser.Email AND Plan__c = :selectedPlanId LIMIT 1]){

         if(lstRoles_ObjectiveSignOff.contains(pc.Role__c)){
            oWrapperPlanContactsRoleAccess.hasSignOffAccess = true;
         }

         if(lstRoles_ObjectivesandMilestones.contains(pc.Role__c)){
            oWrapperPlanContactsRoleAccess.hasObjectivesandMilestonesAccess = true;
         }

         if(lstRoles_ManageContacts.contains(pc.Role__c)){
            oWrapperPlanContactsRoleAccess.hasManageContactsAccess = true;
         }
      }
       
      return oWrapperPlanContactsRoleAccess;
   }



   public class wrapperPlanContactsRoleAccess{
       @auraEnabled public boolean hasSignOffAccess;
       @auraEnabled  public boolean hasObjectivesandMilestonesAccess;
       @auraEnabled  public boolean hasManageContactsAccess;
   }


   
   @AuraEnabled(cacheable=true)
   public static list<picklistWrapper> fetchPicklistData(string objObject,string fld){      
      system.debug('objObject --->' + objObject);
      system.debug('fld --->' + fld);

      list<picklistWrapper> lstWrapperResult = new list<picklistWrapper> ();                   
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType objType = gd.get(objObject);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();          
      map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();    
      list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();          
      for (Schema.PicklistEntry a: values) {
         picklistWrapper oPicklistWrapper = new picklistWrapper();
            oPicklistWrapper.label = a.getLabel();
            oPicklistWrapper.value = a.getValue();
            lstWrapperResult.add(oPicklistWrapper);
      }
      system.debug('allOpts ---->' + lstWrapperResult);
      return lstWrapperResult;      
   }


   public class picklistWrapper{
      @AuraEnabled public string label;
      @AuraEnabled public string value;
   }




   @AuraEnabled(cacheable=true)
    public static list<Plan_Contact__c> fetchAllPlansForCurrentUser(){
        User oCurrentUser = [Select Id,Name,Email,contactId,Contact.Email From User Where Id =: userinfo.getUserId() LIMIT 1];
        list<Plan_Contact__c> lstPlan_Contact = new list<Plan_Contact__c>();
        set<string> setPlanId = new set<string>();
        string sContactEmail = oCurrentUser.ContactId != null ? oCurrentUser.Contact.Email : oCurrentUser.Email;
         for(Plan_Contact__c pc : [SELECT Id, Plan__c,Plan__r.Is_Internal__c,Plan__r.Name,Is_Favourite__c,Plan__r.CreatedDate, 
                                   Plan__r.Account__c,Contact__c,Contact__r.Email
                                   FROM Plan_Contact__c
                                   WHERE Is_Success_Community_User__c = TRUE AND Contact__r.Email = : sContactEmail
                                   AND Contact__c != null
                                   AND Plan__c != null AND Plan__r.Is_Internal__c = false ORDER BY Plan__r.CreatedDate DESC]){   
               if(!setPlanId.contains(pc.Plan__c)){ 
                  lstPlan_Contact.add(pc);
               }                                                                             
               setPlanId.add(pc.Plan__c);
         }  

        return lstPlan_Contact;
   }

    
   @AuraEnabled
   public static list<Plan_Contact__c> makePlanFav(string planConId, boolean favValue){
      Plan_Contact__c obj = new Plan_Contact__c();
      obj.Id = planConId;
      obj.Is_Favourite__c = favValue;
      Update obj;

      // unfavourite others 
      User oCurrentUser = [Select Id,Name,Email From User Where Id =: userinfo.getUserId() LIMIT 1];
        list<Plan_Contact__c> lstPlan_Contact = new list<Plan_Contact__c>();
        set<string> setPlanId = new set<string>();
         for(Plan_Contact__c pc : [SELECT Id, Plan__c,Plan__r.Name,Is_Favourite__c, 
                                   Plan__r.Account__c,Contact__c,Contact__r.Email
                                   FROM Plan_Contact__c
                                   WHERE Contact__r.Email = :oCurrentUser.Email 
                                   AND Contact__c != null AND Is_Favourite__c=true
                                   AND Plan__c != null]){   
               if(!setPlanId.contains(pc.Plan__c)){
                  if(pc.Id != planConId ){
                     pc.Is_Favourite__c = false;
                     lstPlan_Contact.add(pc);
                  }
               }                                                                             
               setPlanId.add(pc.Plan__c);
         }
         
         if(lstPlan_Contact.size() > 0){
            Update lstPlan_Contact;
         }

        
      return fetchAllPlansForCurrentUser();
   }


   @AuraEnabled(cacheable=true)
   public static Plan__c fetchPlanDetail(string recordId){
      
      Plan__c obj = [Select Id,Name,CreatedDate,Description__c,LastModifiedDate,Closure_Date__c,Stage__c,Account__c,Account__r.Name 
                     From Plan__c 
                     Where Id =:recordId LIMIT 1];//Description__c,
      
      return obj;

   }

   @AuraEnabled
   public static Plan__c fetchPlanDetailnoncache(string recordId){
      
      Plan__c obj = [Select Id,Name,CreatedDate,Description__c,LastModifiedDate,Closure_Date__c,Stage__c,Account__c,Account__r.Name 
                     From Plan__c 
                     Where Id =:recordId LIMIT 1];//Description__c,
      system.debug('obj:'+obj.Stage__c);
      return obj;

   }
   @AuraEnabled(cacheable=true)
   public static GlobalDataTableWrapperClass checkSignOffStatus(string selectedPlanId){
        return getRecords(selectedPlanId);
   }


   @AuraEnabled
   public static GlobalDataTableWrapperClass fetchAllSignOffObjecives(string selectedPlanId) {
        return getRecords(selectedPlanId);
   }


   @AuraEnabled
   public static GlobalDataTableWrapperClass updateObjectiveSignOff(list<string> lstObjectiveToSignOff,string selectedPlanId, String strComments, List<String> lstFileIds){
      list<Objective__c> lstObje = new list<Objective__c>();                                           
      User oCurrentUser = [Select Id,Name,Email,contactId From User Where Id =: userinfo.getUserId() LIMIT 1];
      for(string objId : lstObjectiveToSignOff){
         Objective__c obj = new Objective__c();
         obj.Id = objId;
         obj.Sign_Off_Status__c = 'Approved';
         obj.Customer_Sign_off_Contact__c = oCurrentUser.contactId;
         obj.Sign_Off_Date__c = system.today() ;
         obj.Signed_Off_By__c = 'Customer';
         lstObje.add(obj);
      }

      if(lstObje.size() > 0){
           update lstObje; 

            //We create a comment, if needed.
            if(String.isNotBlank(strComments)) {
                Plan_Comment__c objPlanComment = new Plan_Comment__c();
                objPlanComment.Comment__c = STRING_COMMENT_HEADER + 'Success Plan Signoff' + '<br></br><br></br>The following objectives have been signed off by ' + oCurrentUser.Name + 
                        ' with the comment:<br></br>' + strComments + '<br></br><ul>';
                for(Objective__c objRecord : [SELECT Name FROM Objective__c WHERE Id IN :lstObjectiveToSignOff LIMIT 1000]) {
                    objPlanComment.Comment__c += '<li>' + objRecord.Name + '</li>';
                }
                objPlanComment.Comment__c += '</ul>';
                objPlanComment.Plan__c = selectedPlanId;
                objPlanComment.Visibility__c = 'External';
                objPlanComment.Type__c = 'Inbound';
                objPlanComment.Status__c = 'Submitted';
                objPlanComment.Inbound__c = true;
                insert objPlanComment;

                //If we received Files.
                relateFilesToPlanComment(objPlanComment.Id, lstFileIds);
            }

            //Now we return the result.
           return checkSignOffStatus(selectedPlanId);
      }
       return null;
   }



   @AuraEnabled
   public static void createRiskPlanComment(string strComments, string strCaseId,string strReason,string strReasonMap, string planId, List<String> lstFileIds){
      //<T01>
      string commentReason;
      Map<String, Object> msr = (Map<String, Object>)JSON.deserializeUntyped(strReasonMap);
         for(String Str: strReason.split(';')){
               if(commentReason == null){
               commentReason = String.valueOf(msr.get(Str));
               }
               else{
               commentReason = commentReason +', ' + String.valueOf(msr.get(Str));
               }
         } //</T01>
         if(String.isNotBlank(commentReason)) {
            strComments = commentReason + ')</br>' + strComments;
         }  
         Plan_Comment__c planRec = new Plan_Comment__c();
         planRec.Comment__c = STRING_COMMENT_HEADER + ' Discuss Current Project Challenges (' + strComments;
         planRec.Plan__c = planId;
         planRec.Visibility__c = 'External';
         planRec.Type__c = 'Inbound';
         planRec.Sub_Type__c = 'Attention Request';
         planRec.Status__c = 'Submitted';
         planRec.Case__c = strCaseId;
         planRec.Customer_Risk_Reason__c = strReason;
         planRec.Attention_Request_Status__c = 'New';
      Insert planRec;

      //If we received Files.
      relateFilesToPlanComment(planRec.Id, lstFileIds);
   }

   @AuraEnabled
   public static void createContactYourCsm(string planId, string strComments,string strReason, string category, List<String> lstFileIds){
      
      string tempStrComments = STRING_COMMENT_HEADER; 

      if(category == 'Adoption Related Queries'){           
         tempStrComments += '</br>'+category + ' (' + strReason + ') </br>' + strComments;  //<T01>
      }

      else if(category == 'Discuss New Initiatives'){
         tempStrComments += '</br>'+category + ' (' + strReason + ') </br>' + strComments; 
      }
      else if(category == 'Request for meeting'){
         tempStrComments += '</br>'+category + '<p>' + strComments + '</p>'; //</T01>
         system.debug('tempStrComments>>>>>'+tempStrComments);
      }


      Plan_Comment__c planRec = new Plan_Comment__c();
         planRec.Comment__c = tempStrComments;
         planRec.Plan__c = planId;
         planRec.Visibility__c = 'External';
         planRec.Type__c = 'Inbound';
         planRec.Status__c = 'Submitted';      
         //planRec.Customer_Risk_Reason__c = strReason;
         planRec.Attention_Request_Status__c = 'New';
         Insert planRec;

         //If we received Files.
         relateFilesToPlanComment(planRec.Id, lstFileIds);
   }


   @AuraEnabled(cacheable=true)
   public static planDetailWrapper fetchPlanRelatedDetail(string sPlanId){
   
      planDetailWrapper objPlanDetailWrapper = new planDetailWrapper();

      // get plan with Customer Account
      Plan__c oPlan = [SELECT Id,Account__c,Contact__c,Account__r.RecordType.Name From Plan__c WHERE Id =:sPlanId];

      // get Support Account 
      set<string> setSupportAccount = new set<string>(); 

      for(Account sa : [SELECT id from Account 
                        WHERE RecordType.Name= 'Support Account' 
                        AND ParentId = : oPlan.Account__c 
                        AND Active__c = TRUE]){
           setSupportAccount.add(sa.Id);
      }


        User oCurrentUser = [Select Id,Name,Email From User Where Id =: userinfo.getUserId() LIMIT 1];
        string planContactId;
        string planContact_ContactRecordId;
         for(Plan_Contact__c pc : [SELECT Id,Contact__c FROM Plan_Contact__c
                                   WHERE Contact__r.Email = :oCurrentUser.Email 
                                   AND Plan__c =: oPlan.Id  AND Plan__r.Is_Internal__c = false ORDER BY Plan__r.CreatedDate DESC]){   
             planContactId = pc.Id;
             planContact_ContactRecordId = pc.Contact__c;
      }  

      boolean bPlanContactSameAsSupportContact = false;

      if(planContact_ContactRecordId != null){
         for(AccountContactRelation acr : [SELECT ID FROM AccountContactRelation 
         WHERE AccountId IN : setSupportAccount 
         AND ContactId =: planContact_ContactRecordId LIMIT 1]){
          bPlanContactSameAsSupportContact = true;
         }      
      }
      
      objPlanDetailWrapper.bPlanContactSameAsSupportContact = bPlanContactSameAsSupportContact;
      return objPlanDetailWrapper;                                                 
   }


   public class planDetailWrapper{
    
      @AuraEnabled public boolean bPlanContactSameAsSupportContact;
  

   }



   @AuraEnabled(cacheable=true)
   public static List<LookupSearchResult> lookupCombinedSearch(String searchTerm, List<String> selectedIds, string sPlanId) {
       // Prepare query parameters
       searchTerm = '%' + searchTerm + '%';
       

       // Prepare results
       List<LookupSearchResult> results = new List<LookupSearchResult>();

       list<Case> searchResults = new list<Case>();
       User oCurrentUser = [Select Id,Name,Email From User Where Id =: userinfo.getUserId() LIMIT 1];//<T02>
      // get plan with Customer Account  and customer contact
       list<Plan_Contact__c> pc = [SELECT Id,Contact__c,Plan__r.Account__c FROM Plan_Contact__c
                                    WHERE Contact__r.Email = :oCurrentUser.Email 
                                    AND Plan__c =: sPlanId and Plan__r.Account__c <> NULL ORDER BY Plan__r.CreatedDate DESC];//</T02>
      
     // Plan__c oPlan = [SELECT Id,Account__c,Contact__c,Account__r.RecordType.Name From Plan__c WHERE Id =:sPlanId];

       for(Case oCase : [Select Id,CaseNumber,Priority From Case Where CaseNumber LIKE : searchTerm AND Support_Account__r.ParentId = :pc[0].Plan__r.Account__c and contactid =:pc[0].Contact__c AND Id NOT IN :selectedIds]){ //</T02>
          searchResults.add(oCase);
       }

       // Extract case  & convert them into LookupSearchResult
       String caseIcon = 'standard:case';
       Case[] lstCases = searchResults;
       for (Case cs : lstCases) {
           String Priority = cs.Priority == null ? '' : + cs.Priority;
           results.add(new LookupSearchResult(cs.Id, 'Case', caseIcon, cs.CaseNumber, Priority));
       }
       
       // Sort all results on title
       results.sort();

       return results;
   }
   
    /*
     Method Name : relateFilesToPlanComment
     Description : This method creates the relationships between a Plan Comments and its Files.
     Parameters  : String, called from relateFilesToPlanComment, strPlanCommentId Plan Comment Id.
                   List, called from relateFilesToPlanComment, lstFileIds File Ids.
     Return Type : None
     */
    private static void relateFilesToPlanComment(String strPlanCommentId, List<String> lstFileIds) {
        List<ContentDocumentLink> lstPlanCommentFileRelationships = new List<ContentDocumentLink>();
        if(String.isNotBlank(strPlanCommentId) && lstFileIds != null && !lstFileIds.isEmpty()) {
            for(String strId : lstFileIds) {
                lstPlanCommentFileRelationships.add(new ContentDocumentLink(LinkedEntityId = strPlanCommentId, ContentDocumentId = strId));
            }
            insert lstPlanCommentFileRelationships;
        }
    }

    /*
     Method Name : doesPlanHasCasesRelatedToItsSupportAccount
     Description : This method returs TRUE if the given plan has Cases related to its Support Account.
     Parameters  : String, called from doesPlanHasCasesRelatedToItsSupportAccount, strPlanId Plan Id.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static Boolean doesPlanHasCasesRelatedToItsSupportAccount(String strPlanId) {
        Boolean boolResult = false;
        
        //If we received data.
        if(String.isNotBlank(strPlanId)) {
          User oCurrentUser = [Select Id,Name,Email From User Where Id =: userinfo.getUserId() LIMIT 1];//<T02>
         // get plan with Customer Account  and customer contact
          list<Plan_Contact__c> pc = [SELECT Id,Contact__c,Plan__r.Account__c FROM Plan_Contact__c
                                       WHERE Contact__r.Email = :oCurrentUser.Email 
                                       AND Plan__c =: strPlanId and Plan__r.Account__c <> NULL  ORDER BY Plan__r.CreatedDate DESC];//</T02>
            //We get the related account.
           // for(Plan__c objPlan : [SELECT Account__c FROM Plan__c WHERE Id = :strPlanId AND Account__c <> NULL LIMIT 1]) {

                //Now we check if we have cases related to the Support Account.
                for(Case objCase : [SELECT Id FROM Case WHERE Support_Account__r.ParentId = :pc[0].Plan__r.Account__c and contactid =:pc[0].Contact__c LIMIT 1]) {//</T02>
                    boolResult = true;
                }
            //}
        }
        return boolResult;
    }

    /*
     Method Name : getRecords
     Description : This method returns the Plan Partner records related to the provided Plan.
     Parameters  : String, called from getRecords, strPlanId Record Id.
                   Boolean, called from getRecords, boolGetAssingedRecords If we should get Assigned records or Unassiged records.
     Return Type : Columns and records.
     */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strPlanId) {
        String strCleanPlanId;
        String strObjectName = Objective__c.class.getName();
        GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();

        //If we received a Plan Id.
        if(String.isNotBlank(strPlanId)) {
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);

            //Now we get the table details.
            objDataTable.strObjectName = strObjectName;
            objDataTable.strFielSetName = 'Success_Portal_Table_Sign_Off';
            objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);

            //Now we prepare the response.
            objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ', Business_Goal__c, Technical_Goal__c FROM ' + strObjectName + 
                    ' WHERE Plan__c = :strCleanPlanId AND Sign_Off_Status__c = \'Waiting for Customer Signoff\' AND Is_Internal__c = FALSE LIMIT 10000');
        }
        return objDataTable;
    }
}