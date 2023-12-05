/**
* @author Conga Services, ahafez
* @date 20180914
* @version 1.00
* @description ContentDocumentLinkTriggerHandler called from ContentDocumentLinkAfterInsert Trigger

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.     Requested By         Description                                                               Tag
Chandana Gowda    25 Feb 2021       TAX-19         Tax Project 21       Update the field on ERP Site ID when document is attached                 <T1>
Amar Pasham       20 Oct 2021       UTOPIA                              Setting Visibility to Internal Users for the files linked to Cases        <T2>
                                                                        when a files is uploaded using Chatter. 
Pavithra V      09-Nov-2021    COSMOS      AR-1584             Share the Engagement files to the FF Project                              <T3>
Manuraj Kuwar    10-Nov-2021    COSMOS                          Create ContentDocumentLink for Project from Engagement                    <T4>
Ramya Ravi        17 Mar 2022       TAX-238                    Create new field to capture that Exemption Documentation is uploaded      <TAX-238>
                                    and the upload date   
Anusha Akella     March 15 2021     IPUE 161                            IPUE-161 delete the records and Create the records. name of the file is configurable by SDoc's. <T01>
Anusha Akella     March 15 2021     IPUE 161                            Update the visibility to share with community users 
Ramya Ravi        June 14 2022      TAX-237                Whenever a file is uploaded in the Tax Information Section, link the same file to Quote too. <TAX-237>
Harshita J        25-Aug-2022    COSMOS      AR-2877             Create ContentDocumentLink for Engagement from Project.                     <T5>
Puneet            19-Oct-2022       I2C-1692                    Update Quote Summary Has attachment field if file is uploaded.                  <I2C-1692>
************************************************************************************************************************************************************
*/
public class ContentDocumentLinkTriggerHandler {
    public static globalApexManager GAM = new globalApexManager();       
/**
* @description Method called from After Insert trigger state, calls checkForSync method
*/
public static void ContentDocumentLinkAfterInsert(List<ContentDocumentLink> cdlList){
    if(CongaTriggerHelper.DoExecute('ContentDocLink.CheckForSync') || Test.isRunningTest()){
        CheckForSync(cdlList);
    }
    if(CongaTriggerHelper.DoExecute('ContentDocLink.AttachToLegalAgreement') || Test.isRunningTest()){
        AttachToLegalAgreement(cdlList);
    }        
    contentDocumentCreateForProject(cdlList); /**<T4>**/ 
    contentDocumentCreateForEngagement(cdlList);/**<T5>**/  
    sharefileKnowledge(cdlList);
    updateQuoteSummary(cdlList);
}

/**
* @author Conga Services
* @date 20180914
* @version 1.00
* @description Checks if LinkedEntity is syncing across Conga Platform and updates IsCongaFile__c field to true if syncing
*/
public static void CheckForSync(List<ContentDocumentLink> cdlList){
Set<Id> contentDocumentIds = new Set<Id>();
List<ContentVersion> cvList = new List<ContentVersion>();
for(ContentDocumentLink cdl : cdlList){
  if(cdl.LinkedEntity.Type != 'User'){
    contentDocumentIds.add(cdl.ContentDocumentId);
  }
}
if(contentDocumentIds.size() > 0){
  cvList = [SELECT Id, ContentDocumentId, IsCongaFile__c FROM ContentVersion WHERE IsLatest = true and ContentDocumentId IN :contentDocumentIds];
}
    List<ContentVersion> cvToUpdate = new List<ContentVersion>();
if(cvList.size() > 0){
  for(ContentDocumentLink cdl : cdlList){
    for(ContentVersion cv : cvList){
      if(cdl.ContentDocumentId == cv.ContentDocumentId && cv.IsCongaFile__c == false){
        if(!APXT_Redlining.PlatformDataService.isRecordExcluded(cdl.LinkedEntityId)){
                        cvToUpdate.add(new ContentVersion(Id = cv.Id, IsCongaFile__c = true));
        }
      }    
    }
  }
  if(cvToUpdate.size()>0){
            update cvToUpdate;
        }
}
}

/**
* @author Conga Services, gmodica 
* @date 20181012
* @version 1.00
* @description Links a DocuSign Status document with the Legal Agreement
*/
public static void AttachToLegalAgreement(List<ContentDocumentLink> links){        
    String docuSignStatusObjectName = SObjectType.dsfs__DocuSign_Status__c.name;
    String docuSignStatusObjectPrefix = dsfs__DocuSign_Status__c.SObjectType.getDescribe().getKeyPrefix();
    String legalAgreementObjectName = SObjectType.Legal_Agreement__c.name;
    
    // get the document Ids related only to DocuSign Status objects
    Set<Id> docuSignStatusIds = new Set<Id>();
    Set<Id> contentDocumentIds = new Set<Id>();
    for(ContentDocumentLink link : links) {
        if(link.LinkedEntity.Type == docuSignStatusObjectName || String.valueOf(link.LinkedEntityId).startsWith(docuSignStatusObjectPrefix)){
            docuSignStatusIds.add(link.LinkedEntityId);
    contentDocumentIds.add(link.ContentDocumentId);
  }
    }
    
    if(contentDocumentIds.isEmpty() || docuSignStatusIds.isEmpty()) {
        return;
    }
    
    List<ContentDocumentLink> existingLinks = [select Id,LinkedEntityId, LinkedEntity.Type, ContentDocumentId from ContentDocumentLink where ContentDocumentId in :contentDocumentIds];
    Map<Id,List<ContentDocumentLink>> documentIdToLinks = new Map<Id,List<ContentDocumentLink>>();
    for(ContentDocumentLink link : existingLinks) {
        if(!documentIdToLinks.containsKey(link.ContentDocumentId)) documentIdToLinks.put(link.ContentDocumentId, new List<ContentDocumentLink>());
        documentIdToLinks.get(link.ContentDocumentId).add(link);
    }

    Map<Id,dsfs__DocuSign_Status__c> docuSignStatuses = new Map<Id,dsfs__DocuSign_Status__c>([select Id,Legal_Agreement__c from dsfs__DocuSign_Status__c where Id in :docuSignStatusIds]);
    
    // for each link inserted, find out if there's an existing link for the corresponding legal agreement, and if not then create one
    List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
  
    for(ContentDocumentLink link : links) {
        dsfs__DocuSign_Status__c docuSignStatus = docuSignStatuses.get(link.LinkedEntityId);
        
        Boolean existsLinkForLegalAgreement = false;
        List<ContentDocumentLink> existingLinksForDocument = documentIdToLinks.get(link.ContentDocumentId);
        if(existingLinksForDocument != null && !existingLinksForDocument.isEmpty()) {
            for(ContentDocumentLink existingLink : existingLinksForDocument) {
                if(existingLink.LinkedEntity.Type == legalAgreementObjectName && existingLink.LinkedEntityId == docuSignStatus.Legal_Agreement__c) {
                    existsLinkForLegalAgreement = true;
                    break;
                }
            }
        }
        
        if(!existsLinkForLegalAgreement) {
            ContentDocumentLink legalAgreementLink = link.clone();
            legalAgreementLink.LinkedEntityId = docuSignStatus.Legal_Agreement__c;
            linksToInsert.add(legalAgreementLink);
        }
    }
    
    if(!linksToInsert.isEmpty()) insert linksToInsert;
}

/**
* @author Venky K
* @date 20200925
* @version 1.00
* @description Checks if LinkedEntity is knowledge and share it with all users
*/

public static void sharefileKnowledge(List<ContentDocumentLink> links){

    set<Id> setids = new set<Id>();
    List<ContentDocumentLink> updatecdllist = new List<ContentDocumentLink>();  
    List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();    //<TAX-237>
     Set<Id> setErpSiteIds = new Set<Id>();
    Set<Id> conDocSet = new Set<Id>();
    
    for(ContentDocumentLink cdl: links){
      setids.add(cdl.contentdocumentid);
    }
    system.debug('setids'+setids);
   
    if(setids.size() > 0){
        for(ContentDocumentLink cdl : [Select Id,LinkedEntity.Type,contentdocumentid, LinkedEntityId from ContentDocumentLink where contentdocumentid in :setids]){
            system.debug('cdl'+cdl);
            system.debug('cdl.LinkedEntity.Type'+cdl.LinkedEntity.Type);
            if(cdl.LinkedEntity.Type == 'Knowledge__kav' || cdl.LinkedEntity.Type == 'Engagement__c' || cdl.LinkedEntity.Type == 'Related_Opportunity_Plan__c'|| cdl.LinkedEntity.Type == 'ERP_Site__c' /*<T1> <T3>*/){
                //-----------------------------------------<T1>
                if(cdl.LinkedEntity.Type == 'ERP_Site__c'){
                   setErpSiteIds.add(cdl.LinkedEntityId);  
                   cdllist.add(cdl);//<TAX-237>
                   continue;
               }//-----------------------------------------</T1>
               cdl.Visibility = 'AllUsers';
                updatecdllist.add(cdl);
               system.debug('cdl.contentdocumentid'+cdl.contentdocumentid);
              conDocSet.add(cdl.contentdocumentid);                   
            }
        }      
    }
        
    system.debug('conDocSet'+conDocSet);
    
     //<TAX-238> start 
    if(!setErpSiteIds.isEmpty()){
        UpdateERPSIte(setErpSiteIds,cdllist); //<TAX-237> added new parameter
       
    }
         //<TAX-238> end
   
    if(updatecdllist.size() > 0){
        try{
            update updatecdllist;
        } catch(Exception e){
            system.debug('Exception occurent in sharefileKnowledge'+e.getmessage());
        }
    } 
    
    // INSERT CONTENT DISTRIBUTION RECORDS.
    if(conDocSet.size() > 0){
        List<ContentDistribution> conDisListToInsert = new List<ContentDistribution>();
        Map<Id,Id> conVerDocMap = new Map<Id,Id>();
        Map<Id, ContentDocument> contDocMap = new Map<Id, ContentDocument>([ SELECT Id,Title,FileExtension FROM ContentDocument WHERE Id IN: conDocSet]);
        
        system.debug('contDocMap'+contDocMap);
        Map<Id,ContentVersion> conVerMap = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId, IsMajorVersion, IsLatest FROM ContentVersion 
                                                                        WHERE ContentDocumentId IN :conDocSet AND IsLatest = true]);
        
        system.debug('conVerMap'+conVerMap);
        if(conVerMap.size()>0){
            for(ContentVersion conVer : conVerMap.values()){
                conVerDocMap.put(conVer.Id,conVer.ContentDocumentId);
            }
        }
        system.debug('conVerDocMap'+conVerDocMap);
        if(conVerDocMap.size()>0){
            for(Id conVerId : conVerMap.keyset()){
                ContentDistribution conDisRec = new ContentDistribution();
                Id docId = conVerDocMap.get(conVerId);
                conDisRec.Name = contDocMap.get(docId).Title;
                conDisRec.ContentVersionId = conVerId;
                conDisRec.PreferencesNotifyOnVisit = false;
                conDisListToInsert.add(conDisRec);
            }
        }
        system.debug('conDisListToInsert'+conDisListToInsert);
        if(conDisListToInsert.size() > 0){
            try{
                insert conDisListToInsert;
            } catch(Exception e){
                system.debug('Exception Occured in creating Content Distribution records'+e.getmessage());
            }
    }
        
    }
    
}

 /** <TAX-238>
* @method UpdateERPSIte
* @date 20223103
* @version 1.00
* @description Updates ERP site and related quote
*/

public static void UpdateERPSIte(Set<ID> setErpSiteIds, List<ContentDocumentLink> updatecdllist){//<TAX-237>  added new parameter
    
   Map<ID,List<ID>> mapContentDocumentToQuotes = new Map<ID,List<ID>>(); //<TAX-237>    
  
    if(!setErpSiteIds.isEmpty()){
        List<ERP_Site__c> lstERPSiteUpdate = new List<ERP_Site__c>();
        List<SBQQ__Quote__c> ListQuotes = [Select id, Exemption_Document_Uploaded__c, Sold_to_Account_ERP_Site__c from SBQQ__Quote__c where Sold_to_Account_ERP_Site__c =:setErpSiteIds and SBQQ__Opportunity2__r.StageName not In ('Closed Won', 'Closed Lost','Duplicate','No Opportunity') ];//<TAX-237> 
        for(Id erpSiteId:setErpSiteIds){
            ERP_Site__c erpSite = new ERP_Site__c(Id = erpSiteId);                              
            erpSite.Latest_Exemption_File_Upload_Date__c = system.today();   
            erpSite.Exempt_Documentation_Attached__c = true;
            lstERPSiteUpdate.add(erpSite);                
        }
        
        for(SBQQ__Quote__c Qlist:ListQuotes){
           Qlist.Exemption_Document_Uploaded__c = true;                
        }               
        
        if(lstERPSiteUpdate.size() > 0){
            try{
                update lstERPSiteUpdate;
            } catch(Exception ex){
                 GAM.CreateExceptionRecords('ContentDocumentLinkTriggerHandler', 'Exception in UpdateERPSIte',ex.getMessage());
            }
             GAM.InsertDebugLogs();
        } 
        
        if(ListQuotes.size() > 0){
            try{
                 SBQQ.TriggerControl.disable();
                update ListQuotes;
                  SBQQ.TriggerControl.enable();
            } catch(Exception ex){
                 GAM.CreateExceptionRecords('ContentDocumentLinkTriggerHandler', 'Exception in UpdateERPSIte',ex.getMessage());
            }
              GAM.InsertDebugLogs();
        }            
        //<TAX-237> starts                       
                for(ContentDocumentLink cdl:updatecdllist)
                { 
                    List<ID> quoteList = new List<ID>();
                    if(ListQuotes!=null){
                        for(SBQQ__Quote__c Qlist:ListQuotes)
                        {                               
                            if(cdl.LinkedEntityId == Qlist.Sold_to_Account_ERP_Site__c )
                            {                                     
                                quoteList.add(Qlist.id);
                            }  
                        } 
                    }                    
                 if(quoteList.size()>0)
                 {
                     mapContentDocumentToQuotes.put(cdl.ContentDocumentId,quoteList);
                 }                                          
                }   
        if(!mapContentDocumentToQuotes.isEmpty())
                LinkFileToQuotes(mapContentDocumentToQuotes);  //<TAX-237> ends                                              
    }      
}

/**
* @author Jakin P
* @date 7 May, 2021
* @version 1.00
* @description Give access to all user for case attachments.
*/
public static void ContentDocumentLinkBeforeInsert(List<ContentDocumentLink> cdlList){
  if(globalApexManager.avoidRecursion('contentDocumentLink',  'before', 'insert') ) {
      return;
  }
  //shareFileForCase(cdlList);
  updateCDLVisibilityForIPUE(cdlList);
  updateCaseVisibility(cdlList);
}

/*public static void shareFileForCase(List<ContentDocumentLink> links){
  for(ContentDocumentLink documentLink : links){
    if(String.valueOf(documentLink.LinkedEntityId).startsWith('500')){
      system.debug('@@Visibility==');
      documentLink.Visibility = 'AllUsers';
    }
  }
}*/

public static void updateCaseVisibility(List<ContentDocumentLink> links){
  Set<Id> docIds = new Set<Id>();
  Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
  Boolean caseCommentRecord = false;
  Boolean caseRecord = false;
  
    
  for(ContentDocumentLink cdl: links){
      docIds.add(cdl.ContentDocumentId);
      cdlMap.put(cdl.LinkedEntityId,cdl);
  }
    Map<Id,ContentDocument> conDoc = new Map<Id,ContentDocument>([Select Id,CreatedBy.UserType,LatestPublishedVersion.FirstPublishLocation.Type,CreatedById From ContentDocument where Id in :docIds]);
    List<String> externalUsers = new List<String>{'PowerPartner','PowerCustomerSuccess'};
 for(ContentDocumentLink cdl: links){
    /* 
    Changes by Amarender
    1.  Setting Visibility to Internal Users for the files linked to Cases when a files is uploaded using Chatter.
        When a file is uploaded to Chatter, LatestPublishedVersion.FirstPublishLocation.Type will be "User".
    */
  //  if(String.valueOf(cdl.LinkedEntityId).startsWith('500') && !externalUsers.contains(conDoc?.get(cdl.ContentDocumentId)?.CreatedBy.UserType) && UserInfo.getUserId() == conDoc.get(cdl.ContentDocumentId)?.CreatedById){
   if(String.valueOf(cdl.LinkedEntityId).startsWith('500')){
      caseRecord = true;
      if(conDoc?.get(cdl.ContentDocumentId)?.LatestPublishedVersion.FirstPublishLocation.Type == 'User' && !externalUsers.contains(conDoc?.get(cdl.ContentDocumentId)?.CreatedBy.UserType) && UserInfo.getUserId() == conDoc.get(cdl.ContentDocumentId)?.CreatedById){
        cdl.Visibility='InternalUsers';
        cdl.ShareType='I';
      }
    }
 }
    /* for(ContentDocumentLink cdl: [Select Id,LinkedEntityId,LinkedEntity.Type From ContentDocumentLink where ContentDocumentId in :docIds]){
        if(cdl.LinkedEntity.Type == 'Case_Comment__c'){  
            caseCommentRecord = true;     
            cdlMap.put(cdl.LinkedEntityId,cdl);
        }
         
    }
    
    if(caseCommentRecord && caseRecord){
        for(Case_Comment__c cc: [Select Id,Case__c,Visibility__c from Case_Comment__c where Id in :cdlMap.keyset() and Visibility__c = 'External' order by CreatedDate desc Limit 1]){
                cdlMap.get(cc.Case__c).Visibility = 'AllUsers';
        }
    }
    if(!cdlMap.Values().isEmpty())
        links = cdlMap.Values(); */
}

/**<T4> : Share the files with Project ,whenever a file is inserted in Engagement **/
public static void contentDocumentCreateForProject(List<ContentDocumentLink> links){
    Map<Id,List<Id>> engagementToContentDocMap = new Map<Id,List<Id>>();
    List<ContentDocumentLink> ContentDocumentLinksToInsert = new List<ContentDocumentLink>();
    Set<Id> contentDocumentIdSet = new Set<Id>();
    Set<Id> LinkedEntitySet = new Set<Id>();
    
    for(ContentDocumentLink cdlink :links){
        contentDocumentIdSet.add(cdlink.ContentDocumentId);
        LinkedEntitySet.add(cdlink.LinkedEntityId);
    }
    
    for(ContentDocumentLink cdl :[Select Id,LinkedEntity.Type,LinkedEntityId,LinkedEntity.RecordType.DeveloperName,ContentDocumentId from ContentDocumentLink where ContentDocumentId in :contentDocumentIdSet and LinkedEntityId in :LinkedEntitySet]){
        if(cdl.LinkedEntity.Type == 'Engagement__c' && cdl.LinkedEntity.RecordType.DeveloperName == 'IPS_JumpStart'){
            if(engagementToContentDocMap.containsKey(cdl.LinkedEntityId)){
                List<Id> tempList = engagementToContentDocMap.get(cdl.LinkedEntityId);
                tempList.add(cdl.ContentDocumentId);
                engagementToContentDocMap.put(cdl.LinkedEntityId,tempList);
            }else{
                engagementToContentDocMap.put(cdl.LinkedEntityId,new List<Id>{cdl.ContentDocumentId});
            }
        }
    }
    
    if(engagementToContentDocMap.keySet()?.size() >0){
        for(pse__Proj__c project : [Select Id,psa_pm_Engagement__c,(select id,ContentDocumentId from ContentDocumentLinks) from pse__Proj__c where psa_pm_Engagement__c in :engagementToContentDocMap.keySet()]){
            set<id> cDI = new set<id>();
            if(project.ContentDocumentLinks!= null){//<T5>
              for(ContentDocumentLink alreadyCdl:project.ContentDocumentLinks){
                cDI.add(alreadyCdl.ContentDocumentId);
              } // for handling duplicacy and recursion
            }//<T5>  
            for(Id contentDocumentId : engagementToContentDocMap.get(project.psa_pm_Engagement__c)){
                if(!cDI.contains(contentDocumentId)){
                ContentDocumentLink link = New ContentDocumentLink();
                link.LinkedEntityId = project.Id;
                link.ContentDocumentId = contentDocumentId;
                ContentDocumentLinksToInsert.add(link);
                }
            }
        }
    }
    
    if(ContentDocumentLinksToInsert?.size() > 0){
        insert ContentDocumentLinksToInsert;
    }
    
}

/**<T5> : Share the files with Engagement ,whenever a file is inserted in Project with view access **/
public static void contentDocumentCreateForEngagement(List<ContentDocumentLink> links){
    Map<Id,List<Id>> projectToContentDocMap = new Map<Id,List<Id>>();
    List<ContentDocumentLink> ContentDocumentLinksToInsert = new List<ContentDocumentLink>();
    map<id,id> conDocRealtedIdMap = new map<id,id>();
    for(ContentDocumentLink cdlink :links){
        if(!conDocRealtedIdMap.containskey(cdlink.ContentDocumentId) && cdlink.LinkedEntityId.getSobjectType() == Schema.pse__Proj__c.SObjectType){
         conDocRealtedIdMap.put(cdlink.LinkedEntityId,cdlink.ContentDocumentId);
        }
    }
    for(pse__Proj__c pro: [select id,psa_pm_Engagement__c from pse__Proj__c where id in :conDocRealtedIdMap.keyset()]){
      if(projectToContentDocMap.containsKey(pro.psa_pm_Engagement__c)){
                List<Id> tempList = projectToContentDocMap.get(pro.psa_pm_Engagement__c);
                tempList.add(conDocRealtedIdMap.get(pro.id));
                projectToContentDocMap.put(pro.psa_pm_Engagement__c,tempList);
        }
        else{
                projectToContentDocMap.put(pro.psa_pm_Engagement__c,new List<Id>{conDocRealtedIdMap.get(pro.id)});
        }
    } 
    if(projectToContentDocMap.keySet()?.size() >0){
        for(Engagement__c eng : [Select Id,(select id,ContentDocumentId from ContentDocumentLinks) from Engagement__c where id in :projectToContentDocMap.keySet() and RecordType.DeveloperName = 'IPS_JumpStart']){
            set<id> cDI = new set<id>();
            if(eng.ContentDocumentLinks!= null){
              for(ContentDocumentLink alreadyCdl:eng.ContentDocumentLinks){
                cDI.add(alreadyCdl.ContentDocumentId);
              } // for handling duplicacy and recursion
            }
            for(Id contentDocumentId : projectToContentDocMap.get(eng.id)){
                if(!cDI.contains(contentDocumentId)){
                ContentDocumentLink link = New ContentDocumentLink();
                link.LinkedEntityId = eng.Id;
                link.ShareType = 'V';
                link.ContentDocumentId = contentDocumentId;
                ContentDocumentLinksToInsert.add(link);
                }
                
            }
        }
    }
    
    if(ContentDocumentLinksToInsert?.size() > 0){
        insert ContentDocumentLinksToInsert;
    }
    
}

public static void updateCDLVisibilityForIPUE (List<ContentDocumentLink> linkList) {
    for(ContentDocumentLink cdl : linkList) {
        if (cdl.LinkedEntityId.getSObjectType() == Estimation_Summary__c.sObjectType) {
            cdl.visibility = 'AllUsers';
            cdl.ShareType = 'I';
        }
    }
}

 /** <TAX-237>
* @method - LinkFileToQuotes   
* @description - Creates a copy of contentdocument link to related quotes
*/     
   public static void LinkFileToQuotes(Map<Id,List<ID>> mapContentDocumentToQuotes){                
    List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
    if(!mapContentDocumentToQuotes.isEmpty()){          
        for(ID contentDocumentID: mapContentDocumentToQuotes.keySet())
        {   for(ID quoteID: mapContentDocumentToQuotes.get(contentDocumentID) ) 
                {                       
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = contentDocumentID;
                    cdl.LinkedEntityId = quoteID;
                    cdl.ShareType = 'I';
                    cdl.Visibility = 'AllUsers';   
                    lstContentDocumentLink.add(cdl);
                }                 
        }           
    }                 
        if(lstContentDocumentLink.size() > 0){
            try{
                Database.insert(lstContentDocumentLink,false);
            } catch(Exception ex){                     
                 GAM.CreateExceptionRecords('ContentDocumentLinkTriggerHandler', 'Exception in UpdateERPSIte lstContentDocumentLinkInsert',ex.getMessage());
            }
             GAM.InsertDebugLogs();
        }           
    }
    
    /** <I2C-1692>
    * @method - update qutore summary for files   
    * @description - update quote summary if a file is uploaded. 
    */  
    public static void updateQuoteSummary(List<ContentDocumentLink> linkList){
        
        Set<Id> parentIds = new Set<Id>();

        for(ContentDocumentLink contentLink : linkList){

            if(contentLink.LinkedEntityId != null){
                parentIds.add( contentLink.LinkedEntityId );
            }
        }
        
        if(!parentIds.isEmpty()){
            List<Quote_Summary__c> quotSumToUpdate = new List<Quote_Summary__c>();
            
            for(Quote_Summary__c quotSum : [SELECT Id,Has_Attachment__c,(SELECT Id FROM ContentDocumentLinks) FROM Quote_Summary__c WHERE Id IN :parentIds]){
                
                if(!quotSum.ContentDocumentLinks.isEmpty()){
                    quotSum.Has_Attachment__c = true;
                }
                else{
                    quotSum.Has_Attachment__c = false;
                }
                quotSumToUpdate.add(quotSum);
            }

            if(!quotSumToUpdate.isEmpty()){
                update quotSumToUpdate;
            }
        }
    }
}