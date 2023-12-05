/****************************************************************************************************************
Class:          EntityLimitsDisplayController
@Author:        Dayanidhi Singh/Mohammed Anies
@Created Date:   14-April-2022
@Description:    Class for fetching entity limit details for selected object

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description


************************************************************************************************************************************************************
******************************************************************************************************************/
public with sharing class EntityLimitsDisplayController {
    
    @AuraEnabled(cacheable=true)
    public static List<Limit_Monitoring_Parameter__mdt> getLimitMonitoringObjectOptions(){
        List<Limit_Monitoring_Parameter__mdt> options =  new List<Limit_Monitoring_Parameter__mdt>();        
        options = [SELECT Parameter_Value__c from Limit_Monitoring_Parameter__mdt where Label ='Object Entity List'];
        return options;
    }

    

    @AuraEnabled
    public static List<ObjectLimitData> getObjectLimit(String apiName){
        
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();
        
        req.setMethod('GET');
        req.setEndpoint('callout:LimMon_NC/services/data/v54.0/tooling/query/?q=SELECT+Type,+Label,+Remaining,+Max,+EntityDefinitionid+FROM+EntityLimit+where+EntityDefinitionid=\''+apiName+'\'');
        resp = h.send(req);
        
        if(resp.getStatusCode() == 200 ){
            ObjectLimitResponse limits = (ObjectLimitResponse)JSON.deserialize(resp.getBody(), ObjectLimitResponse.class);
            return limits.records;
        }
       
        return null;
    }

    public class ObjectLimitResponse{
        public List<ObjectLimitData> records;
    }

    public class ObjectLimitData{

        @AuraEnabled
        public String Type;
        @AuraEnabled
        public Integer Remaining;
        @AuraEnabled
        public Integer Max;
        @AuraEnabled
        public String Label;
    }

    
}