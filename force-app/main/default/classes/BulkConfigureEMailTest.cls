@isTest
public class BulkConfigureEMailTest {
   
    @testSetup static void setup() {
         sObject contactSobj3 = new Contact();
         contactSobj3 = UtilityTest.putFieldRecord(contactSobj3, UtilityTestData.mContactData);
         contactSobj3.put('OwnerId', UserInfo.getUserId());
         UtilityTest.makeInsert(new List<sObject>{contactSobj3});
        
        sObject sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('ContactId', contactSobj3.Id );
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Case_Contact__c cc = new Case_Contact__c();
        cc.Email__c ='test@test.com';
        
         Case cse = [Select Id From Case Limit 1];
        List<Case_Comment__c> cc1 = new List<Case_Comment__c>();
        for(Integer i=0;i<5;i++){
            Case_Comment__c c = new Case_Comment__c();
           // c.Visibility__c ='External';
            //c.Inbound__c = false;
            c.Status__c ='Submitted';
            c.Comment__c =' this is a test' + i;
            c.Case__c= cse.Id;
            c.Sub_Type__c ='Initial Response';
            cc1.add(c);
        }
        Insert cc1;
            
    }
   
    
    
    @isTest(SeeAllData=false)
    static void testcallSendGridService(){
        Case cse = [Select Id From Case Limit 1];
        List<Case_Comment__c> cc = new List<Case_Comment__c>();
        for(Integer i=0;i<5;i++){
            Case_Comment__c c = new Case_Comment__c();
           // c.Visibility__c ='External';
            //c.Inbound__c = false;
            c.Status__c ='Submitted';
            c.Comment__c =' this is a test' + i;
            c.Case__c= cse.Id;
            c.Sub_Type__c ='Initial Response';
            cc.add(c);
        }
        Insert cc;
        system.debug(' inserted list'+Json.serializePretty(cc));
        Map<Id, Case_Comment__c> oldMap = new Map<Id, Case_Comment__c>();
        for (Case_Comment__c c: cc){ 
            oldMap.put(c.Id, c);
        }
        Test.startTest();
        for (Case_Comment__c c: cc){ 
           c.Inbound__c = false;
             c.Visibility__c ='External';
             c.Status__c ='Submitted';
             c.Email_Sent__c=false;
        }
        //update cc;
        Casecommenttriggerhelper cchelper = new Casecommenttriggerhelper();
        cchelper.callSendGridService(cc,oldMap);
        
      
        Test.stopTest();
    }
    
    
    
      private class MockSignNowCallouts implements HttpCalloutMock {
        // Implement this interface method 
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('api.sendgrid.com')){ 
                res.setBody('Success');
                res.setStatusCode(200);
            }
           
            
            return res;
        }

}
 
}