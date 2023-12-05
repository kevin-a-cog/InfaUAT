@isTest
public class psa_ShadowLeadRequestTriggerHelperTest{
    private static List<Schema.SObjectType> mySObjects = new Schema.SObjectType[] {
                                                        Bypass_Trigger_Settings__c.SObjectType,
                                                        Account.SObjectType,
                                                        pse__Region__c.SObjectType,
                                                        Contact.SObjectType,
                                                        psa_Shadow_Lead_Request__c.SObjectType
                                                        };
    @TestSetup
    static void createTestData(){
        UnitOfWork uow = new UnitOfWork(mySObjects);
        User userObj = [SELECT Id, Name FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
        RecordType rt = [SELECT id,Name FROM RecordType WHERE SobjectType='Contact' AND DeveloperName='Customer_Contact' LIMIT 1];
        RecordType AccRecType = [SELECT id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Customer_Account' LIMIT 1];
        
        //Activate the trigger
        Bypass_Trigger_Settings__c settings = new Bypass_Trigger_Settings__c(SetupOwnerId = UserInfo.getUserId(),
                                                psa_Shadow_Lead_Request_Trigger__c = true);
        uow.registerUpsert(settings);

        System.runAs(userObj){
            //Create Account
            Account acc = new Account(Name = 'Test Account', RecordTypeId = AccRecType.Id, BillingCountry = 'India');
            uow.registerNew(acc);
            
            //Create Region 
            pse__Region__c region = new pse__Region__c(Name = 'Test Region-1');
            uow.registerNew(region); 

            //Create Contact
            Contact con = new Contact(LastName = 'Test Contact' ,pse__Resource_Role__c = 'Regional Manager', pse__Is_Resource__c = true,RecordTypeId = rt.Id,
                    Is_Primary__c = false, pse__Is_Resource_Active__c = true, pse__Default_Cost_Rate__c = 10,psa_Employee_Type__c = 'Informatica-Non PS',
                    pse__Salesforce_User__c = userObj.Id);
            uow.registerRelationship(con, Contact.pse__Region__c, region);
            uow.registerNew(con, Contact.AccountId, acc);
            
            //Create Shadow Lead Request record
            psa_Shadow_Lead_Request__c shadowRec  = new psa_Shadow_Lead_Request__c(Submitted_Date__c = System.Today(),Certification_attached__c = false);
            uow.registerNew(shadowRec, psa_Shadow_Lead_Request__c.Resource_Name__c, con);

            //Commit to the database
            Test.startTest();
            uow.commitWork();
            Test.stopTest();
        }        
    }
    @isTest
    private static void testCertificationAttachedFail(){
        List<Contact> lcontact = [SELECT Id FROM Contact LIMIT 1];  
        List<psa_Shadow_Lead_Request__c> lshadowRec = [SELECT Id FROM psa_Shadow_Lead_Request__c LIMIT 1]; 
        Test.startTest();        
        //Update the Certification attached to TRUE without attaching the files
        try{
            lshadowRec[0].Certification_attached__c = true;
            update lshadowRec;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            //Check if the validation error is thrown
            System.assertEquals(true, expectedExceptionThrown);
            
        }        
        Test.stopTest();
    }
    @isTest
    private static void testCertificationAttachedPass(){
        List<Contact> lcontact = [SELECT Id FROM Contact LIMIT 1];  
        List<psa_Shadow_Lead_Request__c> lshadowRec = [SELECT Id FROM psa_Shadow_Lead_Request__c LIMIT 1]; 
        Test.startTest();        
        //Create ContentVersion
        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Test',
                                        PathOnClient = 'Test.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        								);
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //Create ContentDocumentLink record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = lshadowRec[0].Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        lshadowRec[0].Certification_attached__c = true;
        update lshadowRec;
        
        lcontact = [SELECT Id,Certified_Shadow_Lead__c FROM Contact LIMIT 1];
        //Check if the Certified Shadow Lead is TRUE for the related Contact
        System.assertEquals(true, lcontact[0].Certified_Shadow_Lead__c); 
        Test.stopTest();
    }    
}