@isTest
public class UnitOfWorkTest {
    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {Account.SObjectType,
                                                                                    pse__Region__c.SObjectType,
                                                                                    pse__Work_Calendar__c.SObjectType,
                                                                                    Contact.SObjectType
                                                                                    };
        @testSetup
        static void initializeData(){
            //Test insert DML - Unit of Work
            UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
            
            //Add Account - single record
            String accRecType  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId(); 
            Account acc = new Account();
            acc.RecordTypeId = accRecType;
            acc.Name = 'Test Account 1';
            acc.CSM_Segment__c='Digital Touch';
            acc.Contract_Company_Group__c='Prospect';
            acc.Payment_Terms__c='Net 30';
            acc.BillingCountry='India';
            uow.registerNew(acc);
            
            //Add Regions - list of records
            List<pse__Region__c> regionList = new List<pse__Region__c>();
            pse__Region__c regionRec1 = new pse__Region__c();
            regionRec1.Name = 'Test Region 1';
            regionRec1.pse__Action_Update_Current_Time_Period__c = false;
            regionRec1.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec1);
            
            pse__Region__c regionRec2 = new pse__Region__c();
            regionRec2.Name = 'Test Region 2';
            regionRec2.pse__Action_Update_Current_Time_Period__c = false;
            regionRec2.psa_pm_Allow_Customer_Project__c = true;
            regionList.add(regionRec2);
            uow.registerNew(regionList);
            
            //Add Work Calendar - single record
            pse__Work_Calendar__c defaultWorkCalendar1 = new pse__Work_Calendar__c(Name='Test Work Calendar 1');
            defaultWorkCalendar1.pse__Sunday_Hours__c= 8;
            defaultWorkCalendar1.pse__Monday_Hours__c=8;
            defaultWorkCalendar1.pse__Tuesday_Hours__c=8;
            defaultWorkCalendar1.pse__Wednesday_Hours__c=8;
            defaultWorkCalendar1.pse__Thursday_Hours__c=8;
            defaultWorkCalendar1.pse__Friday_Hours__c=8;
            defaultWorkCalendar1.pse__Saturday_Hours__c=8;   
            uow.registerNew(defaultWorkCalendar1);
            
            pse__Work_Calendar__c defaultWorkCalendar2 = new pse__Work_Calendar__c(Name='Test Work Calendar 2');
            defaultWorkCalendar2.pse__Sunday_Hours__c= 8;
            defaultWorkCalendar2.pse__Monday_Hours__c=8;
            defaultWorkCalendar2.pse__Tuesday_Hours__c=8;
            defaultWorkCalendar2.pse__Wednesday_Hours__c=8;
            defaultWorkCalendar2.pse__Thursday_Hours__c=8;
            defaultWorkCalendar2.pse__Friday_Hours__c=8;
            defaultWorkCalendar2.pse__Saturday_Hours__c=8;   
            uow.registerNew(defaultWorkCalendar2);
            
            //Add Contact - with the relationship fields
            Contact con = new Contact();
            con.LastName ='Contact';
            con.FirstName = 'Test';
            con.Email='test.email@gmail.com';
            con.pse__Is_Resource__c =true;
            con.pse__Is_Resource_Active__c=true;
            con.CurrencyIsoCode='USD';
            con.pse__Resource_Role__c='Regional Manager';
            con.pse__Default_Cost_Rate__c = 10;
            con.psa_Target_Bill_Rate__c=10;
            con.MailingCountry='India';
            uow.registerRelationship(con, Contact.pse__Region__c, regionRec1);
            uow.registerRelationship(con, Contact.pse__Work_Calendar__c, defaultWorkCalendar1);
            uow.registerNew(con,Contact.AccountId,acc);
            
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }
    //test Update DML - Unit of Work
    @isTest
    static void testUpdateDML(){
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        
        //Update Account name - single record
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Name = 'Test Account';
        uow.registerDirty(acc);
        
        //Update regions - list of records/record with field List
        List<pse__Region__c> regionList = [SELECT Id FROM pse__Region__c LIMIT 2];
        regionList[0].Name = 'Informatica';        
        regionList[1].Name = 'US';        
        uow.registerDirty(regionList,new List<SObjectField> {pse__Region__c.Name});
        regionList[0].CurrencyIsoCode = 'USD';
        uow.registerDirty(regionList[0],new List<SObjectField> {pse__Region__c.CurrencyIsoCode});
        
        //Update Work Calendar - List of records
        List<pse__Work_Calendar__c> wcList = [SELECT Id FROM pse__Work_Calendar__c LIMIT 2];        
        wcList[0].Name = 'Test WC 1';
        wcList[0].Name = 'Test WC 2';
        uow.registerDirty(wcList);
        
        //Update contact - with relationships
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        uow.registerDirty(con, Contact.pse__Region__c, regionList[1]);
        
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
    }
    //test Upsert DML - Unit of Work
    @isTest
    static void testUpsertDML(){
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        
        //Upsert - list of records
        List<pse__Region__c> regionList = [SELECT Id FROM pse__Region__c LIMIT 1];
        regionList[0].Name = 'INFA';
        pse__Region__c regionRec = new pse__Region__c();
        regionRec.Name = 'India';
        regionRec.pse__Action_Update_Current_Time_Period__c = false;
        regionRec.psa_pm_Allow_Customer_Project__c = true;
        regionList.add(regionRec);
        
        uow.registerUpsert(regionList);
        
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
    }
     //test Delete DML - Unit of Work
    @isTest
    static void testDeleteDML(){
        UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        
        //Delete - list of records
        List<pse__Region__c> regionList = [SELECT Id FROM pse__Region__c LIMIT 2];
        uow.registerDeleted(regionList);
        
        Test.startTest();
        uow.commitWork();
        Test.stopTest();
    }    
}