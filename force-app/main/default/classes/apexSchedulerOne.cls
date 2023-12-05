/***************************************************************************************************************************************************************
 *  @Class Name: apexSchedulerOne
 *  @Author: Ramesh M S
 *  @Date: 28-AUG-2023
 *  @Description: INNOHUB-11 & SALESRT-17437 & SALESRT-17294 - Framework for Salesforce Apex Scheduler 
 ****************************************************************************************************************************************************************
ChangeHistory
    
ModifiedBy                    Date                       Requested By                     Description                                        Tag   

**************************************************************************************************************************************************************************************************************************/

@RestResource(urlMapping='/ApexScheduleOneExecute')
global class apexSchedulerOne implements Schedulable{

    global static globalApexManager GAM = new globalApexManager();
    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {Apex_Schedules__c.SObjectType,blng__InvoiceScheduler__c.SObjectType};
    
    //Constructor
    global apexSchedulerOne()
    {
        
    }
    
    //Receive the 
    @HttpPost
    global static String CallfromCAI()
    {
        return executeJob();
    }
    
    // execute method of Scheduler Class
    global void execute(SchedulableContext ctx)
    {
        executeJob();
    }
    
    /*
    Method that queries all entries from Apex Schedules to process and calculate Next Run Time.
    This method is called from the execute method of Scheduler Class.
    */
    public static String executeJob()
    {
        DateTime dateTimeNow = System.Now();
        Map<Id,Apex_Schedules__c> apexScheduleMap = new Map<Id,Apex_Schedules__c> ();
        Map<Id,blng__InvoiceScheduler__c> invSchMap = new Map<Id,blng__InvoiceScheduler__c> ();
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
              
        try
        {
            for(Apex_Schedules__c apexSchedule : [SELECT Anonymous_Code__c,Last_Executed__c,At_On__c,Async_Apex_Job_Id__c,Batch_Size__c,Class_Name__c,CreatedDate,CurrencyIsoCode,Daily_Start_Date_Time__c,Final_End_Date__c,Final_Run_Time__c,Id,Job_Type__c,LastModifiedDate,Name,Next_Run_Time__c,OwnerId,Repeat_Interval__c,Run_Type__c 
            FROM Apex_Schedules__c where Daily_Start_Date_Time__c <=: dateTimeNow AND 
                                         Next_Run_Time__c <=: dateTimeNow AND 
                                         ((Repeat_Interval__c > 0 AND (Final_Run_Time__c = NULL OR Final_Run_Time__c >=: dateTimeNow)) OR (Repeat_Interval__c = 0))
                                         ORDER BY Job_Type__c ASC])
            {
                DateTime NextRunTime = apexSchedule.Next_Run_Time__c.addMinutes(Integer.valueOf(apexSchedule.Repeat_Interval__c));
                
                NextRunTime = DateTime.newInstance(dateTimeNow.date(), apexSchedule.Daily_Start_Date_Time__c.Time());
                dateTimeNow = dateTimeNow.addSeconds((dateTimeNow.second()) * -1);
                NextRunTime = dateTimeNow.addMinutes(Integer.valueOf(apexSchedule.Repeat_Interval__c) - (Integer.valueOf(Math.MOD((dateTimeNow.getTime() - NextRunTime.getTime()) / (1000 * 60),Math.roundToLong(apexSchedule.Repeat_Interval__c)))));

                
                apexScheduleMap.put(apexSchedule.Id,new Apex_Schedules__c(Id=apexSchedule.Id,Next_Run_Time__c = (apexSchedule.Repeat_Interval__c == 0 ? null : (NextRunTime <= apexSchedule.Final_Run_Time__c || apexSchedule.Final_Run_Time__c == null) ? NextRunTime : null)));
                
                if(apexSchedule.Job_Type__c == 'Schedulable')
                {
                    DateTime nextSchTime = apexSchedule.Next_Run_Time__c.addMinutes(Integer.valueOf(apexSchedule.Repeat_Interval__c));
                    nextSchTime = nextSchTime < dateTimeNow ? dateTimeNow.addMinutes(Integer.valueOf(apexSchedule.Repeat_Interval__c)) : nextSchTime ;
                    apexScheduleMap.get(apexSchedule.Id).put('Next_Run_Time__c',nextSchTime);
                    
                    String scheduleDay=String.valueof(nextSchTime.day());         
                    String scheduleHour=String.valueof(nextSchTime.hour());         
                    String scheduleMinute=String.valueof(nextSchTime.minute());         
                    String scheduleMonth=String.valueof(nextSchTime.month());         
                    String scheduleYear=String.valueof(nextSchTime.year());  
                    
                    String CRON_EXPRESSION = '0 ' + scheduleMinute + ' ' + scheduleHour + ' ' + scheduleDay + ' ' + scheduleMonth + ' ? ' + scheduleYear;    
                    
                    System.debug('CRON_EXPRESSION: '+CRON_EXPRESSION);  
                    
                    //system.abortjob(apexSchedule.Async_Apex_Job_Id__c);    
                    apexSchedule.Async_Apex_Job_Id__c = System.schedule('ApexScheduler - ' + nextSchTime.formatGMT('EEE, MMM d yyyy HH:mm:ss') + ' GMT', CRON_EXPRESSION, new apexSchedulerOne());
                    apexScheduleMap.get(apexSchedule.Id).put('Async_Apex_Job_Id__c',apexSchedule.Async_Apex_Job_Id__c);
                }
                else if(apexSchedule.Job_Type__c == 'Batchable')
                {
                    Type customClass = Type.forName(apexSchedule.Class_Name__c);
                    Id jobId = Database.executeBatch( (Database.Batchable<SObject>) customClass.newInstance() , Integer.valueOf(apexSchedule.Batch_Size__c));
                }
                else if(apexSchedule.Job_Type__c == 'Anonymous')
                {
                    executeAnonymousinFuture(apexSchedule.Anonymous_Code__c);
                }
                else if(apexSchedule.Job_Type__c == 'Invoice Scheduler')
                {
                        invSchMap.put(apexSchedule.Class_Name__c,new blng__InvoiceScheduler__c(Id=apexSchedule.Class_Name__c,blng__StartDateTime__c = apexSchedule.Next_Run_Time__c.addMinutes(1),blng__TargetDate__c = apexSchedule.Next_Run_Time__c.addMinutes(1).Date(),blng__InvoiceDate__c = apexSchedule.Next_Run_Time__c.addMinutes(1).Date()));
                }
                
                
            }
            
       
       if(apexScheduleMap.size() > 0){
           //update apexScheduleMap.values();
           uow.registerDirty(apexScheduleMap.values());
       }
           
       if(invSchMap.size() > 0){
           //update invSchMap.values();
            uow.registerDirty(invSchMap.values());
       }
       
       uow.commitWork();
       
       return 'Success';
       
       }
       
       catch(Exception ex){
           GAM.CreateExceptionRecords('Apex Scheduler', ex.getMessage(), 'error from Apex Scheduler');
           return ex.getMessage();
       }
    }
    
    /*
    This is future method for making callouts and execute anonymous code.
    The execution and callout should be made in future and exclude from other transactions performed in execute method of Scheduler Class. This is to avoid  Error - 'You have uncommitted work pending. Please commit or rollback before calling out'
    */
    @future(callout=true)
    public static void executeAnonymousinFuture(String anonymousCode)
    {
        executeAnonymous(anonymousCode);
    }
    
    /*
    The method to make an API call using Tooling API for executing anonymous script. 
    This method is called from execute of Scheduler class for the Anonymous entries in Apex Schedule object.
    */
    public static void executeAnonymous(String anonymousCode)
    {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(system.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/tooling/executeAnonymous/?anonymousBody=' + EncodingUtil.urlEncode(anonymousCode,'UTF-8'));
        req.setMethod('GET');
        Http h = new Http();
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
        }
        
    }
    
    /*
    This is Trigger Handler for the trigger of Apex Schedule Object.
    */
    public static void apexScheduleTriggerHandler(List<Apex_Schedules__c> apexSchedulesNew)
    {
        for(Apex_Schedules__c apexsch : apexSchedulesNew)
        {
            if(apexsch.Run_Type__c == 'Once')
                apexsch.Repeat_Interval__c = 0;
            else if(apexsch.Run_Type__c == 'Daily')
                apexsch.Repeat_Interval__c = Integer.valueOf(apexsch.At_On__c);
            else if(apexsch.Run_Type__c == 'Weekly')
                apexsch.Repeat_Interval__c = 10080;
                
            apexsch.Next_Run_Time__c = apexsch.Daily_Start_Date_Time__c;
            
            if(apexsch.Daily_Start_Date_Time__c < System.now())
                apexsch.addError('Please keep the Start Date Time in future');
            
            if(math.mod(apexsch.Daily_Start_Date_Time__c.minute(),5) != 0)
                apexsch.addError('Please keep the Start Date Time in multiple of 5 minutes like *0 OR *5');
        
        }
        
    }
    
}