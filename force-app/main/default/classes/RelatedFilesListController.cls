public without sharing class RelatedFilesListController {
    
    @AuraEnabled
    public static List<ContentDocumentWrapper> getRelatedFileOfKBArticle(Id kbArticleId){
        
        List<ContentDocumentWrapper> conDocWrapList = new List<ContentDocumentWrapper>(); // List that will be passed to the UI.
        
        if(String.IsNotBlank(kbArticleId)){
            
            Map<Id,ContentDocumentLink> conDocLinkMap = new Map<Id,ContentDocumentLink>([SELECT Id,ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :kbArticleId]);                            
            Map<Id,String> versURLMap = new Map<Id,String>();
            Set<Id> conDocIdSet = new Set<Id>();
            List<ContentVersion> finalConVerList = new List<ContentVersion>();
            Map<Id,Id> verDocMap = new Map<Id,Id>();
        
            if(conDocLinkMap.size()>0){
                // MAY NEED LOGIC TO CHECK VISIBILITY OF CONDOC LINK RECORDS VISIBILITY AND UPDATE IS NECESSARY.
                
                for (ContentDocumentLink cdlinkRec : conDocLinkMap.values()) {
                    conDocIdSet.add(cdlinkRec.ContentDocumentId);
                }
            }
            
            Map<Id,ContentDocument> conDocMap = new Map<Id,ContentDocument>([SELECT id,Title,ContentSize,ContentAssetId,CreatedById,CreatedDate,Description,FileExtension,FileType,OwnerId,ParentId
                                                                            FROM ContentDocument
                                                                            WHERE Id IN:conDocIdSet]);
            
            if(conDocIdSet.size()>0){
                versURLMap = getConDistributionMap(conDocIdSet);
                
            }
            
            if(versURLMap.size()>0){
                finalConVerList = [SELECT Id, ContentDocumentId, IsMajorVersion, IsLatest 
                                    FROM ContentVersion WHERE ID IN:versURLMap.keyset() AND IsLatest = true];
            }
            for(ContentVersion conVer : finalConVerList){
                verDocMap.put(conVer.ContentDocumentId,conVer.Id);
            }
                
            
            
            if(conDocMap.size()>0){
                for(ContentDocument  cd : conDocMap.values()){
                    ContentDocumentWrapper conWrap = new ContentDocumentWrapper();
                    //conWrap.conDoc = new ContentDocument();
                    conWrap.conDoc = cd;
                    Id conVerId = verDocMap.get(cd.Id);
                    conWrap.conURL= versURLMap.get(conVerId);
                    conDocWrapList.add(conWrap);
                }
            }
        }
        
        system.debug('*******conDocWrapList**'+conDocWrapList);
    
        return conDocWrapList;
       
    }
    
    
    public static Map<Id,String> getConDistributionMap(Set<Id> conDocIds){
        
        Map<Id,String> conVerURLMap = new Map<Id,String>();
        Map<Id,ContentVersion> conVerMap = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId, IsMajorVersion, IsLatest FROM ContentVersion 
                                                                        WHERE ContentDocumentId IN :conDocIds AND IsLatest = true]);
        Map<Id,contentDistribution> conDisMap = new Map<Id,contentDistribution>();
        Map<Id,Id> verDocIdMap = new Map<Id,Id>();
        Set<Id> parentConVerIdSet = new Set<Id>();
        Set<Id> orphanConVerIdSet = new Set<Id>();
        List<ContentDistribution> baseconDisList = new List<ContentDistribution>();
        List<ContentDistribution> conDisListToInsert = new List<ContentDistribution>();
        List<ContentDistribution> finalConDisList = new List<ContentDistribution>();
        
        
        if(conVerMap.size()>0){
            baseconDisList = [SELECT Id,Name,ContentDownloadUrl,ContentVersionId FROM ContentDistribution 
                              WHERE ContentVersionId IN :conVerMap.Keyset()];
            
            for(ContentVersion conVerRec : conVerMap.Values()){
                verDocIdMap.put(conVerRec.Id,conVerRec.ContentDocumentId);
            }
        }
        
        //check if all ContentVersion Records have ContentDistribution Records.
        
        for(ContentDistribution conDisRec : baseconDisList){
            parentConVerIdSet.add(conDisRec.ContentVersionId);
        }
        system.debug('*******parentConVerIdSet**'+parentConVerIdSet);
        
        for(Id conVerId : conVerMap.keyset()){
            if(!parentConVerIdSet.contains(conVerId)){
                orphanConVerIdSet.add(conVerId);
            }
        }
        system.debug('*******orphanConVerIdSet**'+orphanConVerIdSet);
        
        if(orphanConVerIdSet.size()>0){
            for(Id orConVerId : orphanConVerIdSet){
                ContentDistribution conDisRec = new ContentDistribution();
                conDisRec.Name = 'Record Created via Apex-CustomFileComponent';
                conDisRec.ContentVersionId = orConVerId;
                conDisRec.PreferencesNotifyOnVisit = false;
                //conDisRec.ContentDocumentId = verDocIdMap.get(orConVerId); //NOR WRITABLE 
                //conDisRec.PreferencesAllowViewInBrowser = true;
                conDisListToInsert.add(conDisRec);
            }
        }
        
        if(conDisListToInsert.size()>0){
            insert conDisListToInsert;
            system.debug('*******conDisListToInserted**'+conDisListToInsert);
        }
        
        //Requery ContentDistribution Records.
             
        finalConDisList = [SELECT id,Name,ContentDocumentId,ContentDownloadUrl,ContentVersionId,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN :conVerMap.Keyset()];
        
        for(ContentDistribution cd : finalConDisList){            
            conVerURLMap.put(cd.ContentVersionId, cd.ContentDownloadUrl); 
            
        } 
        system.debug('*******conVerURLMap**'+conVerURLMap);
        return conVerURLMap;
          
    }
    
    
      
    public class ContentDocumentWrapper{
        @AuraEnabled
        public ContentDocument conDoc;
        @AuraEnabled
        public string conURL;
    }

}