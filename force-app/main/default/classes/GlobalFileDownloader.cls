/*
 * Name			:	GlobalFileDownloader
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/01/2021
 * Description	:	Global File Downloader controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/01/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalFileDownloader {

	/*
	 Method Name : getRecords
	 Description : This method returns the Files related to the given Id.
	 Parameters	 : String, called from getRecords, strRecordId Parent Record Id.
	 Return Type : GlobalDataTableWrapperClass
	 */
    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String strRecordId) {
		String strCleanRecordId;
		String strObjectName;
		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		List<Id> lstIds = new List<Id>();

		//First we make sure we received an id.
		if(String.isNotBlank(strRecordId)) {
			strCleanRecordId = String.escapeSingleQuotes(strRecordId);

			//Now we get all the related documents.
			for(ContentDocumentLink objDocumentLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :strCleanRecordId LIMIT 1000]) {
				lstIds.add(objDocumentLink.ContentDocumentId);
			}
	
			//Now we create the table.
			if(!lstIds.isEmpty()) {
				strObjectName = ContentDocument.class.getName();
				objDataTable.strObjectName = strObjectName;
				objDataTable.lstFieldNames = new List<String>();
				objDataTable.lstFieldNames.add('Title');
				objDataTable.lstFieldNames.add('FileType');
				objDataTable.lstFieldNames.add('CreatedDate');
				objDataTable.lstFieldNames.add('CreatedById');
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
		
				//Now we prepare the response.
				objDataTable.lstRecords = Database.query('SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + 
						' WHERE Id IN :lstIds WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1000');
			}
		}
		return objDataTable;
	}
}