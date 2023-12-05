public with sharing class PocEngagementRelatedListController {
    
    @AuraEnabled(cacheable=true)
    public static string fetchPocEngagements(string engagementId){

        Engagement__c oEng = [Select Id,Opportunity__c From Engagement__c WHERE Id =:engagementId];
      //  list<Engagement__c> lstResult = new list<Engagement__c>();
      /*  if(oEng.Opportunity__c != null){
       
            for(Engagement__c eng : [Select Id,Name,Success_App__c From Engagement__c WHERE Opportunity__c =: oEng.Opportunity__c AND RecordType.Name = 'POC']){
                lstResult.add(eng);
            }

        }
        return lstResult;*/
        string strObjectApiName = 'Engagement__c';
        string strfieldSetName = 'POC_Engagement';
        Map<String, String> returnMap = new Map<String,String>();
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){

            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();

	    String query = 'SELECT ';
	    for(Schema.FieldSetMember f : lstFSMember) {
	        query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM ' + strObjectApiName + ' WHERE Opportunity__c = ' + '\''+oEng.Opportunity__c+'\''  + ' AND RecordType.Name = \'POC\'' ;
            

            
             List<SObject> lstRecords = Database.query(query);
            system.debug('lstRecords>>> '+ lstRecords);
	     returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
	     returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
	     return JSON.serialize(returnMap);
        }
        return null;

    }


    @AuraEnabled(cacheable = false)
    public static GlobalDataTableWrapperClass getRecords(String engagementId) {
		Engagement__c oEng = [Select Id,Opportunity__c From Engagement__c WHERE Id =:engagementId];
		String strCleanPlanId;
		String strObjectName = Engagement__c.class.getName();

		GlobalDataTableWrapperClass objDataTable = new GlobalDataTableWrapperClass();
		if(String.isNotBlank(engagementId)) {
			strCleanPlanId = String.escapeSingleQuotes(engagementId);		
				//Now we get the table details.
				objDataTable.strObjectName = strObjectName;
				objDataTable.strFielSetName = 'POC_Engagement';
				objDataTable = GlobalDataTableUtilitiesClass.getDataTableDetails(objDataTable);
				//Now we prepare the response.
                string sQuery = '';
                 sQuery += 'SELECT ' + String.join(objDataTable.lstFieldNames, ',') + ' FROM ' + strObjectName + ' ';
                 sQuery += ' WHERE Opportunity__c = ' + '\''+oEng.Opportunity__c+'\''  + ' AND RecordType.Name = \'POC\'' ;

				objDataTable.lstRecords = Database.query(sQuery);
			
		}
		return objDataTable;
    }
}