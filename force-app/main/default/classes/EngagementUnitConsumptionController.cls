public class EngagementUnitConsumptionController {

    /*
	 Method Name : checkIsEngUnitUpdatable
	 Description : This method checks whether the Engagement_unit__c is updateable or not
	 Parameters	 : None
	 Return Type : Boolean
	*/
    @AuraEnabled(Cacheable = false)
    public static Boolean checkIsEngUnitUpdatable(){
       try{
            if (Schema.sObjectType.Engagement_Unit__c.isUpdateable()){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getEngUnitConsumptionsType
	 Description : This method gets the Type of EU consumption record like Engagement, Case etc
	 Parameters	 : Id
	 Return Type : Map<String,String>
	*/
    @AuraEnabled(Cacheable = true)
    public static Map<String,String> getEngUnitConsumptionsType(Id idRecord){
       try{
            if(idRecord != null){
                Map<String, String> sObjLabelTypeMap = new Map<String, String>();
                List<Engagement_Unit_Consumption__c> conUnitList = [SELECT Id,Context_Id__c FROM Engagement_Unit_Consumption__c WHERE Engagement_Unit__c=:idRecord AND Status__c = 'Consumed'];
                for(Engagement_Unit_Consumption__c engCon:conUnitList){
                    Id conId = (Id)engCon.Context_Id__c;
                    String conIdObjType = String.valueOf(conId.getSObjectType());
                    if(!sObjLabelTypeMap.containsKey(conIdObjType)){
                        String conIdObjLabel = String.valueOf(conId.getSObjectType().getDescribe().getLabel());
                        sObjLabelTypeMap.put(conIdObjType,conIdObjLabel);
                    }
                }
                return sObjLabelTypeMap;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : getEngUnitConsumptionsRecordDetails
	 Description : This method gets the id and name of the selected EU consumption Type
	 Parameters	 : Id - EU recordId, String - recType of EU consumption Type
	 Return Type : List<EngWrapper>
	*/
    @AuraEnabled
    public static List<EngWrapper> getEngUnitConsumptionsRecordDetails(String idRecord, String recType){
        try {
            List<Engagement_Unit_Consumption__c> conUnitList = [SELECT Id,Context_Id__c FROM Engagement_Unit_Consumption__c WHERE Engagement_Unit__c=:idRecord AND Status__c = 'Consumed'];
            List<Id> idListEng = new List<Id>();
            for(Engagement_Unit_Consumption__c engCon:conUnitList){
                Id conId = (Id)engCon.Context_Id__c;
                String conIdObjType = String.valueOf(conId.getSObjectType());
                if(conIdObjType == recType){
                    idListEng.add(engCon.Context_Id__c);
                }
            }
            List<String> lstOfName = new List<String>();
            List<sObject> sobjList;
            String nameField;
            Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sobjType = gd.get(recType);
            Schema.DescribeSObjectResult sObjRes = sobjType.getDescribe();
            Map<String, Schema.SObjectField> mapOfFields = sObjRes.fields.getMap();
            for(String fieldName : mapOfFields.keySet()){
                if(mapOfFields.get(fieldName).getDescribe().isNameField()){
                    nameField = mapOfFields.get(fieldName).getDescribe().getName();
                    break;
                }
            }
            if(!idListEng.isEmpty()){
                String query = 'SELECT Id, ' + nameField + ' FROM ' + recType + ' WHERE Id IN :idListEng';
                sobjList = Database.query(query);
            }
            List<EngWrapper> engWrapperList = new List<EngWrapper>();
            for(Sobject obj:sobjList){
                EngWrapper engWrapper = new EngWrapper();
                engWrapper.engId = (Id)obj.get('Id');
                engWrapper.displayName = String.valueOf(obj.get(nameField));
                engWrapperList.add(engWrapper);
            }
            return engWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
	 Method Name : updateEngUnitConsumptionStatus
	 Description : This method updates the Eng Unit consumption status to the selected status(cancelled/completed)
	 Parameters	 : List<String> - IdEngList, String - idRecord, String - status
	 Return Type : Boolean
	*/
    @AuraEnabled
    public static Boolean updateEngUnitConsumptionStatus(List<String> IdEngList, String idRecord, String status){
        try {
            for(Engagement_Unit_Consumption__c engUnitCon:[SELECT Id,Context_Id__c,Initiated_By__c,Type__c FROM Engagement_Unit_Consumption__c WHERE Engagement_Unit__c=:idRecord AND Context_Id__c =:IdEngList]){
                EngagementUnitServiceWrapper req= new EngagementUnitServiceWrapper();
                req.boolIsInternalUser = engUnitCon.Initiated_By__c=='CSM';
                req.strStatus = status;
                req.strContextId = engUnitCon.Context_Id__c;
                if(engUnitCon.Type__c == 'Success'){
                    SuccessEngagementUnitService.updateEngagementUnitConsumptionStatus(req);
                }else{
                    EngagementUnitService.updateEngagementUnitConsumptionStatus(req);
                }
                
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class EngWrapper{
        @AuraEnabled public Id engId{get;set;}
        @AuraEnabled public String displayName{get;set;}
    }

}