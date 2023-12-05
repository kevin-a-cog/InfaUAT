/*
Class:          apexSchedulerOneTest
@Author:        Ramesh M S
@Created Date:  17-SEP-2023
@Description:   Test class for apexSchedulerOne
*/
@isTest
public class apexSchedulerOneTest{

    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {Apex_Schedules__c.SObjectType,blng__InvoiceScheduler__c.SObjectType};
    
    @testSetup
    static void setupObjectTestData() {
    
        UnitOfWork uow1 = new UnitOfWork(MY_SOBJECTS);
        UnitOfWork uow2 = new UnitOfWork(MY_SOBJECTS);
        
        Apex_Schedules__c AS1 = new Apex_Schedules__c();
        AS1.Anonymous_Code__c = 'System.debug(' + '\'' + 'Test' + '\'' + ');';
        AS1.At_On__c = '60';
        AS1.Daily_Start_Date_Time__c = System.now().AddMinutes(5 - Math.MOD((System.now().Minute()),5));
        AS1.Job_Type__c = 'Anonymous';
        AS1.Run_Type__c = 'Daily';
        
        Apex_Schedules__c AS2 = new Apex_Schedules__c();
        AS2.Class_Name__c = 'revenueAgreementBatch';
        AS2.Batch_Size__c = 1;
        AS2.At_On__c = '15';
        AS2.Daily_Start_Date_Time__c = System.now().AddMinutes(5 - Math.MOD((System.now().Minute()),5));
        AS2.Job_Type__c = 'Batchable';
        AS2.Run_Type__c = 'Daily';
        
        Apex_Schedules__c AS3 = new Apex_Schedules__c();
        AS3.Class_Name__c = 'apexSchedulerOne';
        AS3.Batch_Size__c = 1;
        AS3.At_On__c = '5';
        AS3.Daily_Start_Date_Time__c = System.now().AddMinutes(5 - Math.MOD((System.now().Minute()),5));
        AS3.Job_Type__c = 'Schedulable';
        AS3.Run_Type__c = 'Daily';
        
        blng__InvoiceScheduler__c InvSch = new blng__InvoiceScheduler__c ();
        InvSch.Name = 'Adhoc Invoice Scheduler';
        InvSch.blng__AutomaticallyPostInvoices__c = TRUE;
        INVSch.blng__BillUsageCharges__c = FALSE;
        InvSch.blng__IncludeAllCurrencies__c = TRUE;
        InvSch.blng__InvoiceBatches__c = 'Batch 6';
        InvSch.blng__Type__c = 'Once';
        InvSch.blng__StartDateTime__c = System.now().addMinutes(1);
        InvSch.blng__TargetDate__c = System.now().addMinutes(1).Date();
        InvSch.blng__InvoiceDate__c = System.now().addMinutes(1).Date();
        
        Apex_Schedules__c AS4 = new Apex_Schedules__c();
        AS4.Class_Name__c = 'InvSch.Id';
        AS4.Batch_Size__c = 1;
        AS4.At_On__c = '60';
        AS4.Daily_Start_Date_Time__c = System.now().AddMinutes(5 - Math.MOD((System.now().Minute()),5));
        AS4.Job_Type__c = 'Invoice Scheduler';
        AS4.Run_Type__c = 'Daily';
                
        //insert new List<Apex_Schedules__c> {AS1,AS2,AS3};
        uow1.registerNew(AS1); uow1.registerNew(AS2); uow1.registerNew(AS3); uow1.registerNew(AS4); uow1.registerNew(InvSch);
        uow1.commitWork();
        
        for(Apex_Schedules__c apexSch : [Select Id,Job_Type__c from Apex_Schedules__c]){
            apexSch.Daily_Start_Date_Time__c = System.now().AddMinutes(-1);
            apexSch.Next_Run_Time__c = System.now().AddMinutes(-1);
            if(apexSch.Job_Type__c == 'Invoice Scheduler')
                apexSch.Class_Name__c = InvSch.Id;
            uow2.registerDirty(apexSch);
        }
        
        uow2.commitWork();
    }
    
  
    @isTest
    static void testApexSchedulerOneTestMethod(){
        
        System.schedule('apexSchedulerOne_job', '0 0 * * * ?', new apexSchedulerOne());
        
        Test.startTest();
        apexSchedulerOne.CallfromCAI();
        Test.stopTest();
    }
}