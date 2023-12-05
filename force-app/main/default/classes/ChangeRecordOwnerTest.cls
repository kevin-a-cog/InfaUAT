/*
    @created by       : Isha Bansal
    @created on       : 03/29/2023
    @Purpose          : Test class for ChangeRecordOwner
    @Testclass        : ChangeRecordOwnerTest
    @JIRA             : I2RT - 6727    
 Change History
 ****************************************************************************************************************
 ModifiedBy         Date        Jira No.    Tag                         Description										Tag no 
 */
@isTest


private class ChangeRecordOwnerTest {

    @testSetup
    static void maketestdata() { 
        // Create a test record to use as the new owner
        Profile salesProfile = [SELECT Id, Name FROM Profile WHERE Name='Employee'];

        User oldOwner = new user(LastName = 'Sing', FirstName = 'Mira', Alias = 'mirs', Email = 'mirasing@test.com', Username = 'mirasing@test.com', TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey ='UTF-8' , LocaleSidKey ='en_US' ,ProfileId = salesProfile.id);
        insert oldOwner;
        
        User newOwner = new user(LastName = 'Doe', FirstName = 'John', Alias = 'jond', Email = 'jonhdoe@test.com', Username = 'jonhdoe@test.com', TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey ='UTF-8' , LocaleSidKey ='en_US' ,ProfileId = salesProfile.id);
        insert newOwner;

       
        User adminusr = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        system.runAs(adminusr){
        List<PermissionSetAssignment> lstInsertPermissionSets = new List<PermissionSetAssignment>();
        for(PermissionSet ps: [SELECT ID,Name From PermissionSet WHERE Name in('GCS_Engineer', 'GCS_Manager2','GCS_Administration')]){
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = newOwner.id, PermissionSetId = ps.Id ));
            lstInsertPermissionSets.add(new PermissionSetAssignment(AssigneeId = oldOwner.id, PermissionSetId = ps.Id ));
        }
        insert lstInsertPermissionSets;
        }
        // Create a test case record        
        Sobject sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Subject', 'TestClass');
        
        List<Case> testCase = (List<Case>)UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Engagement record
        sObject sObj1 = new Engagement__c();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj1});


        //create an collaboration record
        Raise_Hand__c raiseHandCoOwn = new Raise_Hand__c();
        raiseHandCoOwn.Case__c = testCase[0].Id;
        raiseHandCoOwn.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandCoOwn.Type__c = RaiseHandService.TYPE_CO_OWN;
        raiseHandCoOwn.Subtype__c = RaiseHandService.SUBTYPE_MULTIPRODUCT;
        raiseHandCoOwn.Skill__c = 'PowerCenter - PS';
        raiseHandCoOwn.ownerId=oldOwner.Id;
        insert raiseHandCoOwn;

    }

    @isTest
    static void testCaseChangeOwner() {  
        List<Case> testCase=[select Id ,ownerId,subject from Case where Subject='TestClass' limit 1];
        List<Raise_Hand__c> raisehand=[select Id from Raise_Hand__c limit 1];
        List<Engagement__c> engRec=[select Id from Engagement__c limit 1];
      Test.startTest();
      ChangeRecordOwner.SobjectWrapper wrapobj=ChangeRecordOwner.getObjectSpecificLabel(testCase[0].Id);
      Test.stopTest();      
      System.assertEquals(wrapobj.changeOwnerLabel,'Change Case Owner',true);  


     wrapobj=ChangeRecordOwner.getObjectSpecificLabel(raisehand[0].Id);
      System.assertEquals(wrapobj.changeOwnerLabel,'Change Collaborate Owner',true);  

      wrapobj=ChangeRecordOwner.getObjectSpecificLabel(engRec[0].Id);
      System.assertEquals(wrapobj.changeOwnerLabel,'Change Engagement Owner',true);  

     }

}