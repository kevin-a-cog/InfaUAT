/*
Class:          psa_om_InterlockFileController
@Author:        MAHESH GANTI
@Created Date:  NOVEMBER 25 2020
@Description:   Apex class to fetch the List of Files under the Interlock record
*/
public without sharing class psa_om_InterlockFileController {
    
    /**
    * Method to fetch interlock files and display on a custom LWC
    * @param PSA-project Id
    * @return return- List<Wrapper object - File name + Download URL>
    * @throws exception - NA
    */
    @AuraEnabled
    public static List<ContentDocumentWrapper> getInterLockFiles(Id projId){
        
        system.debug('****IFC***ProjID'  +projId);
        List<ContentDocumentWrapper> conWrapList = new List<ContentDocumentWrapper>();
        List<ContentDocument> fileList = new List<ContentDocument>();
        Set<Id> contDocIdSet = new Set<Id>();
        if(String.IsNotBlank(projId)){
            Id interlockId;
			pse__Proj__c projRec = [SELECT Id,psa_om_Interlock__c FROM pse__Proj__c WHERE Id = :projId LIMIT 1];
            system.debug('****IFC***projRec'  +projRec);
            if(projRec <> null && projRec.psa_om_Interlock__c <> null){
                interlockId = projRec.psa_om_Interlock__c;
            }
            system.debug('****IFC***interlockId'  +interlockId);
            if(interlockId <> null){
                for(ContentDocumentLink cntDoc : [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :interlockId]){
                    contDocIdSet.add(cntDoc.ContentDocumentId);
                }
            }
            
            system.debug('*******contDocIdSet**'+contDocIdSet.size());
            
            Map<Id,String> baseFileURLMap = new Map<Id,String>();
            if(contDocIdSet.size()>0){
                baseFileURLMap = getFileURLMap(contDocIdSet);
                system.debug('*******baseFileURLMap**'+baseFileURLMap.size());
                system.debug('*******baseFileURLMap**'+baseFileURLMap);
                fileList  = [SELECT ContentSize,ContentAssetId,CreatedById,CreatedBy.Name,CreatedDate,Description,FileExtension,FileType,Id,OwnerId,ParentId,Title FROM ContentDocument WHERE ID IN :contDocIdSet];
                if(fileList.size()>0){				
					for(ContentDocument  cd : fileList){
						ContentDocumentWrapper conWrap = new ContentDocumentWrapper();
						conWrap.conDoc = new ContentDocument();
						conWrap.conDoc = cd;
						conWrap.conURL= baseFileURLMap.get(cd.Id);
						conWrapList.add(conWrap);
					}
				}
            
            }
        }   
        system.debug('*******conWrapList**'+conWrapList);
        return conWrapList;
    }
    
    @AuraEnabled
    public static List<ContentDocumentWrapper> getEngagementFiles(Id projId){
        
        system.debug('****IFC***ProjID'  +projId);
        List<ContentDocumentWrapper> conWrapList = new List<ContentDocumentWrapper>();
        List<ContentDocument> fileList = new List<ContentDocument>();
        Set<Id> contDocIdSet = new Set<Id>();
        if(String.IsNotBlank(projId)){
            Id engagementId;
			pse__Proj__c projRec = [SELECT Id,psa_pm_Engagement__c FROM pse__Proj__c WHERE Id = :projId LIMIT 1];
            system.debug('****IFC***projRec'  +projRec);
            if(projRec <> null && projRec.psa_pm_Engagement__c <> null){
                engagementId = projRec.psa_pm_Engagement__c;
            }
            system.debug('****IFC***engagementId'  +engagementId);
            if(engagementId <> null){
                for(ContentDocumentLink cntDoc : [SELECT ContentDocumentId,Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :engagementId]){
                    contDocIdSet.add(cntDoc.ContentDocumentId);
                }
            }
            
            system.debug('*******contDocIdSet**'+contDocIdSet.size());
            
            Map<Id,String> baseFileURLMap = new Map<Id,String>();
            if(contDocIdSet.size()>0){
                baseFileURLMap = getFileURLMap(contDocIdSet);
                system.debug('*******baseFileURLMap**'+baseFileURLMap.size());
                system.debug('*******baseFileURLMap**'+baseFileURLMap);
                fileList  = [SELECT ContentSize,ContentAssetId,CreatedById,CreatedBy.Name,CreatedDate,Description,FileExtension,FileType,Id,OwnerId,ParentId,Title FROM ContentDocument WHERE ID IN :contDocIdSet];
                if(fileList.size()>0){				
					for(ContentDocument  cd : fileList){
						ContentDocumentWrapper conWrap = new ContentDocumentWrapper();
						conWrap.conDoc = new ContentDocument();
						conWrap.conDoc = cd;
						conWrap.conURL= baseFileURLMap.get(cd.Id);
						conWrapList.add(conWrap);
					}
				}
            
            }
        }   
        system.debug('*******conWrapList**'+conWrapList);
        return conWrapList;
    }
    
    public static Map<Id,String> getFileURLMap(Set<Id> docsIdSet){
        Map<Id,String> fileURLMap = new Map<Id,String>(); 
        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId  FROM ContentVersion WHERE ContentDocumentId IN :docsIdSet AND IsLatest = true];
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        
        system.debug('*******cvList**'+cvList);
        if(!cvList.isEmpty()){
            cdList = [SELECT Id,Name,ContentDocumentId,ContentDownloadUrl,ContentVersionId,DistributionPublicUrl 
                        FROM ContentDistribution 
                        WHERE ContentVersionId IN :cvList];
        }
        system.debug('*******cdList**'+cdList);
        if(!cdList.isEmpty()){
            for(ContentDistribution cd : cdList){            
                fileURLMap.put(cd.ContentDocumentId, cd.ContentDownloadUrl);            
            } 
        }      
        /**
         List<ContentDistribution> cdList = new List<ContentDistribution>([SELECT Id, Name, ContentDownloadUrl, ContentVersionId 
                                    FROM ContentDistribution 
                                    WHERE ContentVersionId IN :cvList]);
               
        system.debug('*******CDLISR**'+cdList.size());
		 
        for(ContentVersion cv : cvList){
            String cvDownloadURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + cv.Id;
            fileURLMap.put(cv.ContentDocumentId, cvDownloadURL); 
            
        }
        */       
        return fileURLMap;
    } 
      
    public class ContentDocumentWrapper{
        @AuraEnabled
        public ContentDocument conDoc;
        @AuraEnabled
        public string conURL;
    }

}