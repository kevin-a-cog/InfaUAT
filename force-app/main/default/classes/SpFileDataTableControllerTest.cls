@isTest
public class SpFileDataTableControllerTest {
    
  
    
     @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','Lname');
        UtilityTestData.mContactData.put('Email',userinfo.getUserEmail());
        UtilityTestData.mContactData.put('Phone','1231231234');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
       
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','Business Value');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 
        
          //Inserting Plan Comment.
        Plan_Comment__c objPlanComment = new Plan_Comment__c();
        objPlanComment.Comment__c = 'test';
        objPlanComment.Visibility__c = 'External';
        objPlanComment.Status__c = 'Submitted';
        objPlanComment.Plan__c = lPlan[0].Id;
        insert objPlanComment;
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
		//Content Version.
		ContentVersion objContentVersion = new ContentVersion();
		objContentVersion.Title = 'Test';
		objContentVersion.PathOnClient = 'Test.jpg';
		objContentVersion.VersionData = Blob.valueOf('Test Content');
		objContentVersion.IsMajorVersion = true;
		insert objContentVersion;

		//Content Document Link.
		ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
		objContentDocumentLink.LinkedEntityId = objPlanComment.Id;
		objContentDocumentLink.ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1][0].Id;
		objContentDocumentLink.ShareType = 'V';
		objContentDocumentLink.Visibility = 'AllUsers';
		insert objContentDocumentLink;
    }
    
    private static testmethod void planDataTableMethodTest(){        
        Plan_Contact__c oPC = [Select Id,Name,Plan__c From Plan_Contact__c LIMIT 1];
        Contact oCon = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        
        test.startTest();       
          SpFileDataTableController.fetchPlanFiles(oPC.Plan__c);
		  SpFileDataTableController.deleteFile(oPC.Plan__c);
		  try {
			SpFileDataTableController.updateFileDescription(oPC.Plan__c, 'test');
		  } catch(Exception objException) {}
        test.stopTest();
    }
    

}