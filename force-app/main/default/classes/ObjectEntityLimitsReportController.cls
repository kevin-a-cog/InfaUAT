/****************************************************************************************************************
Class:          ObjectEntityLimitsReportController
@Author:        Mohammed Anies
@Created Date:   14-July-2022
@Description:   Class for fetching entity limit details for selected object and identifying limits breaching defined threshold percentage.

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Mohammed Anies      12-Sep-2022                        Karthik Thitte      Added getScheduledJobs method to fetch active scheduled jobs

************************************************************************************************************************************************************
******************************************************************************************************************/
public with sharing class ObjectEntityLimitsReportController {
    
    @AuraEnabled(cacheable=true)
    public static List<ObjectLimitDisplayData> getObjectLimit(){

        List<ObjectLimitDisplayData> lstdisplayResultData = new List<ObjectLimitDisplayData>();
        List<ObjectLimitData> finalREsultdata = new List<ObjectLimitData>();
        ObjectLimitResponse  resLimits = new ObjectLimitResponse();
        string[] strObjectList = new String[]{};

        List<Limit_Monitoring_Parameter__mdt> mdtLimitMonitoring =  new List<Limit_Monitoring_Parameter__mdt>();        
        mdtLimitMonitoring = [SELECT Parameter_Value__c from Limit_Monitoring_Parameter__mdt where Label ='Object Entity List'];

        List<Limit_Monitoring_Parameter__mdt> mdtLimitMonitoringThreshold =  new List<Limit_Monitoring_Parameter__mdt>();        
        mdtLimitMonitoringThreshold = [SELECT Parameter_Value__c from Limit_Monitoring_Parameter__mdt where Label ='Entity Limit Threshold'];
        integer limitThreshold = Integer.valueOf(mdtLimitMonitoringThreshold[0].Parameter_Value__c);

        if (mdtLimitMonitoring != null) {
            strObjectList = mdtLimitMonitoring[0].Parameter_Value__c.split(',');
            
        }    
        

        for (string objectDevName : strObjectList) {
                
            //String apiName = 'Case';
            String apiName = objectDevName;
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            HttpResponse resp = new HttpResponse();
            
            req.setMethod('GET');
            req.setEndpoint('callout:LimMon_NC/services/data/v54.0/tooling/query/?q=SELECT+Type,+Label,+Remaining,+Max,+EntityDefinitionid+FROM+EntityLimit+where+EntityDefinitionid=\''+apiName+'\'');
            resp = h.send(req);
            
            
            
            if(resp.getStatusCode() == 200 ){
                resLimits = (ObjectLimitResponse)JSON.deserialize(resp.getBody(), ObjectLimitResponse.class);
                
                List<ObjectLimitData> resultLimits = new List<ObjectLimitData>();
                
                for(ObjectLimitData objlimits : resLimits.records)
                {
                    integer percentageUsed = ((objlimits.Max - objlimits.Remaining) * 100) / objlimits.Max;
                    
                    if( percentageUsed >= limitThreshold) {
                        
                        lstdisplayResultData.add(new ObjectLimitDisplayData(objlimits.EntityDefinitionId,objlimits.Label,objlimits.Max,objlimits.Remaining,percentageUsed));

                    }
                    
                    
                }

            }
            
        }
        if (lstdisplayResultData.size() > 0) {
            return lstdisplayResultData;
            
        }
               
        return null;
    }

    public class ObjectLimitResponse{
        public List<ObjectLimitData> records;
    }

    public class ObjectLimitData{
        @AuraEnabled
        public Integer Remaining;
        @AuraEnabled
        public Integer Max;
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String EntityDefinitionId;
    }

    public class ObjectLimitDisplayData{
        @AuraEnabled
        public Integer Remaining;
        @AuraEnabled
        public Integer Max;
        @AuraEnabled
        public String Label;
        @AuraEnabled
        public Integer UsedPercentage;
        @AuraEnabled
        public String EntityDefinitionId;

        public ObjectLimitDisplayData(String EntityDefinitionId,String Label,Integer Max,Integer Remaining,Integer UsedPercentage){
            this.EntityDefinitionId = EntityDefinitionId;
            this.Label = Label;
            this.Max = Max;
            this.Remaining = Remaining;
            this.UsedPercentage = UsedPercentage;
        }


    }

    @AuraEnabled(cacheable=true)
    public static List<ScheduledJobsDetails> getAllScheduledJobs(){
        try {
            List<Crontrigger> jobs =  new List<Crontrigger>();    
            List<ScheduledJobsDetails> resultJobs = new List<ScheduledJobsDetails>();
            
            jobs = [SELECT cronjobDetail.name,CreatedBy.name,CreatedDate,CronJobDetailId,NextFireTime,OwnerId,State,TimesTriggered FROM Crontrigger WHERE cronjobDetail.JobType = '7' and State NOT IN ('DELETED','COMPLETE','ERROR')];
            
            for(Crontrigger cronJob:jobs){
                resultJobs.add(new ScheduledJobsDetails(cronJob.cronjobDetail.name,cronJob.CreatedBy.name,cronJob.CreatedDate,cronJob.CronJobDetailId,cronJob.NextFireTime,cronJob.OwnerId,cronJob.State,cronJob.TimesTriggered));
            }

            return resultJobs;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ScheduledJobsDetails {
        @AuraEnabled
        public String cronjobDetailName;
        @AuraEnabled
        public String CreatedBy;
        @AuraEnabled
        public Datetime CreatedDate;
        @AuraEnabled
        public String CronJobDetailId;
        @AuraEnabled
        public Datetime NextFireTime;
        @AuraEnabled
        public String OwnerId;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public Integer TimesTriggered;

        public ScheduledJobsDetails(String cronjobDetailName,String CreatedBy,Datetime CreatedDate, String CronJobDetailId,Datetime NextFireTime,String OwnerId,String State,Integer TimesTriggered){
            this.cronjobDetailName = cronjobDetailName;
            this.CreatedBy = CreatedBy;
            this.CreatedDate = CreatedDate;
            this.CronJobDetailId = CronJobDetailId;
            this.NextFireTime = NextFireTime;
            this.OwnerId = OwnerId;
            this.State = State;
            this.TimesTriggered = TimesTriggered;

        }
        

        
    }
}