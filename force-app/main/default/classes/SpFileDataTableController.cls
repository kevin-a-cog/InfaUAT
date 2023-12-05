// Akhilesh 
// 17 jan 2022
public without sharing class SpFileDataTableController {

    @AuraEnabled
    public static List<FileWrapperClass> fetchPlanFiles(string planId) {
		FileWrapperClass objFile;
		Set<Id> setContentDocumentIds = new Set<Id>();
		List<FileWrapperClass> lstFiles = new List<FileWrapperClass>();
        set<string> setPlanCommentId = new set<string>();
        for(Plan_Comment__c pc : [SELECT id,Visibility__c,Type__c,Status__c,Plan__c 
                                    FROM Plan_Comment__c 
                                    WHERE Plan__c = :  planId                                    
                                    AND Visibility__c = 'External' 
                                    AND Status__c = 'Submitted' ORDER BY createdDate desc]){

                                        setPlanCommentId.add(pc.Id);
            
        }
        if(setPlanCommentId.size() != 0){
          for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
		  		ContentDocument.Title, ContentDocument.Description, ContentDocument.createdDate, ContentDocument.FileType,ContentDocument.ContentSize, contentDocument.Owner.Name
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId In :setPlanCommentId ORDER BY ContentDocument.createdDate desc]){
			objFile = new FileWrapperClass();
			objFile.objDocument = cdl;
			lstFiles.add(objFile);
			setContentDocumentIds.add(cdl.ContentDocumentId);
          }   

		  //Now we get the latest Content Versions.
		  if(!lstFiles.isEmpty()) {
			for(ContentVersion objContentVersion : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :setContentDocumentIds AND IsLatest = TRUE LIMIT 10000]) {
				for(FileWrapperClass objDocument : lstFiles) {
					if(objContentVersion.ContentDocumentId == objDocument.objDocument.ContentDocumentId) {
						objDocument.idLatestVersion = objContentVersion.id;
					}
				}
			}
		  }
        }
          return lstFiles;      
    }

	/*
     Method Name : deleteFile
     Description : This method deletes the record related to the given id.
     Parameters  : Id, called from deleteFile, idRecord Record id.
     Return Type : None
     */
	@AuraEnabled(cacheable = false)
    public static void deleteFile(Id idRecord) {
		Database.delete(idRecord, false);
	}

	/*
     Method Name : updateFileDescription
     Description : This method updates a File description.
     Parameters  : Id, called from updateFileDescription, idRecord Record id.
	 			   String, called from updateFileDescription, strDescription File description.
     Return Type : None
     */
	@AuraEnabled(cacheable = false)
    public static void updateFileDescription(Id idRecord, String strDescription) {
		update new ContentDocument(Id = idRecord, Description = strDescription);
	}

	//Inner class for Files.
	public class FileWrapperClass {

		//Public variables.
		@AuraEnabled
        public ContentDocumentLink objDocument {get; set;}
		@AuraEnabled
        public Id idLatestVersion {get; set;}
    }
}