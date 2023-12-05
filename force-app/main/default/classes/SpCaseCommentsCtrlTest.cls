@isTest
public class SpCaseCommentsCtrlTest {
    
    @testSetup
    static void setupObjectTestData() {
        System.runAs(createTestUser('System Administrator', true)) {
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
            objPlanComment.Subject__c = 'test sub';
            objPlanComment.Sub_Type__c = 'Plan';
            objPlanComment.Visibility__c = 'External';
            objPlanComment.Status__c = 'Submitted';
            objPlanComment.Type__c = 'External';
            objPlanComment.Plan__c = lPlan[0].Id;
            insert objPlanComment;
            
            
            //Email Message
            EmailMessage objEmail = new EmailMessage();
            objEmail.FromAddress = 'test@informatica.com';
            objEmail.ToAddress= 'test@xyz.org';
            objEmail.Subject = 'Test email';
            objEmail.HtmlBody = 'Test email body';
            objEmail.RelatedToId = lPlan[0].Id;
            objEmail.MessageDate = System.today();
            objEmail.ThreadIdentifier = '<NQjlI000000000000000000000000000000000000000000000R6WS8Z00LEpzWDUKSSy2oVK06gclOw@sfdc.net>';
            insert objEmail;
        }
    }
    
    private static testmethod void MethodTest(){ 
        List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();
        Plan__c objPlan = new Plan__c();
        Contact oCon = new Contact();
        User objUser = new User();
        
        System.runAs(createTestUser('System Administrator', true)) {
        objPlan = [Select Id,CreatedDate From Plan__c LIMIT 1];
        
        oCon = [Select Id,FirstName,LastName,Email,Phone,AccountId From Contact LIMIT 1];
        objUser = createTestUser('Customer Community Plus Login User', false);
        objUser.ContactId = oCon.Id;
        insert objUser;
        
        //Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success_External_Users']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objUser.Id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }
        
        
        
            
            //Plan Contacts
            sObject PlanContact = new Plan_Contact__c();
            UtilityTestData.mPlanContact.put('Plan__c',objPlan.Id);
            UtilityTestData.mPlanContact.put('Contact__c',oCon.Id);
            UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
            UtilityTestData.mPlanContact.put('Role__c','Technical Owner');
            PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
            UtilityTest.makeInsert(new List<sObject>{PlanContact});
            Plan_Contact__c oPC = [Select Id,Name,Plan__c, Contact__c From Plan_Contact__c LIMIT 1];
            DateTime datTFilterDate = DateTime.parse(Label.Plan_Comment_Limit);
            Plan_Comment__c objPlanComment1 = new Plan_Comment__c();
            objPlanComment1.Comment__c = 'test';
            objPlanComment1.Visibility__c = 'External';
            objPlanComment1.Status__c = 'Submitted';
            objPlanComment1.Type__c = 'Inbound';
            objPlanComment1.Plan__c = objPlan.Id;
            insert objPlanComment1;
            //Test.setCreatedDate(objPlanComment1.Id, DateTime.newInstance(2024,05,01));
            string planId = objPlan.Id;
            system.debug('>>>>>>>>>>Datee'+objPlanComment1.createdDate);
            system.debug('>>>>>>>>>>datTFilterDate'+datTFilterDate);
            string sQuery = 'SELECT id,Inbound__c, Is_Automated__c,Comment__c,Parent_Comment__c,Createdby.Name, Createdby.FirstName,Createdby.LastName, CreatedBy.FullPhotoUrl,CreatedDate, LastModifiedDate, CreatedById, Plan__c, ' +
                'Subject__c, Type__c, Sub_Type__c, Status__c, Visibility__c, Importance__c, Date_Time_Scheduled__c, Plan__r.Id, (SELECT Id FROM ContentDocumentLinks), ' + 
                '(SELECT Is_Automated__c, id,Inbound__c, Comment__c,Parent_Comment__c,Createdby.Name, Createdby.FirstName,Createdby.LastName, CreatedBy.FullPhotoUrl,CreatedDate, LastModifiedDate, CreatedById, Plan__c,Subject__c, Type__c, Sub_Type__c, Status__c, Visibility__c, Importance__c, Date_Time_Scheduled__c, Plan__r.Id,Created_By__c FROM Plan_Comments__r), Created_By__c FROM Plan_Comment__c  WHERE Visibility__c = \'External\'  AND Status__c=\'Submitted\' AND (Type__c = \'External\' OR ' + 
                'Type__c = \'Inbound\') AND Plan__c =: planId AND CreatedDate >= :datTFilterDate'; 
            system.debug('>>>>>>>>>>QQQQ'+sQuery);
            system.debug('>>>>>>>>>>'+Database.query(sQuery));
            test.startTest();      
            SpCaseCommentsCtrl.fetchPlanComment(string.valueOf(objPlan.Id) ,'asc' ,'',false);  
            SpCaseCommentsCtrl.fetchPlanComment(string.valueOf(objPlan.Id) ,'asc' , 'test',false);  
            string planCmtId = SpCaseCommentsCtrl.createNewPlanComment('test', string.valueOf(objPlan.Id));
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'a picture',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            SpCaseCommentsCtrl.tagFilestoComments(string.valueOf(objPlan.Id), planCmtId, new list<string>{documents[0].Id});   
            test.stopTest();
        }
        
        System.runAs(objUser){
            SpCaseCommentsCtrl.fetchPlanComment(string.valueOf(objPlan.Id) ,'desc', '',false);       
            SpCaseCommentsCtrl.fetchPlanComment(string.valueOf(objPlan.Id) ,'asc' ,'',false);  
        }
    } 
    
    /*
Method Name : createTestUser
Description : This method serves as a Utility method to create Test users.
Parameters  : String, called from createTestUser, strProfileName Profile name.
Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
Return Type : User record.
*/
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;
        UserRole objUserRole;
        
        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];
        
        //Now we get a role.
        objUserRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'GCS' LIMIT 1];
        
        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            objTestUser.UserRoleId = objUserRole.Id;
            insert objTestUser;
        }
        
        //Now we return the result.
        return objTestUser;
    }
}