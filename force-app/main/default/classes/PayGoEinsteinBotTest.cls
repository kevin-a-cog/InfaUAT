/*
Class:              EinsteinPayGoMainMenu
@Author:            Sandeep Duggi
@Created Date:      20-Sep-2023
@Description:       Test class to cover the feture of EinsteinBot
                    Test coverage for PayGoEinsteinBotGetTranscriptVariables,PayGoEinsteinBotAnswer
                    PayGoEinsteinBotMainMenu, PayGoEinsteinBotSecondaryMenu        
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************
*/
@isTest
public class PayGoEinsteinBotTest {
  
    @isTest
    static void testGetUserDetails() {
        //insert Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.BillingCountry='USA';
        insert acct;
        //insert contact
        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.FirstName = 'Test';
        contact.Email = 'test@example.com';
        contact.accountId = acct.Id;
        insert contact; 
        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;   
        // Create LiveChatTranscript records
        LiveChatTranscript testTranscript = new LiveChatTranscript(
            First_Name__c = 'Test',
            Last_Name__c = 'Test',
            Email__c = 'test@example.com',
            Customer_Journey__c = 'PAYGO',
            LiveChatVisitorid = lcv.id
        );
        insert testTranscript;
        // Create a TranscriptInput instance
        PayGoEinsteinBotGetTranscriptVariables.TranscriptInput input = new PayGoEinsteinBotGetTranscriptVariables.TranscriptInput();
        input.routableID = testTranscript.Id;
        List<PayGoEinsteinBotGetTranscriptVariables.TranscriptInput> ListInput = new List<PayGoEinsteinBotGetTranscriptVariables.TranscriptInput>();  
        ListInput.add(input);
        // Call the method to be tested
        Test.startTest();
        List<PayGoEinsteinBotGetTranscriptVariables.CustomerDetailOutput> result = PayGoEinsteinBotGetTranscriptVariables.getUserDetails(new List<PayGoEinsteinBotGetTranscriptVariables.TranscriptInput>{ input });
        PayGoEinsteinBotGetTranscriptVariables.TranscriptInput transcriptInput = ListInput[0];
        Test.stopTest();
        // Assert the results
        PayGoEinsteinBotGetTranscriptVariables.CustomerDetailOutput customerData = result[0];
        System.assertEquals('Test', customerData.firstName, 'First name should match');
        // Verify that the Contact is updated
        LiveChatTranscript testrecord = [select id,Contact.FirstName,ContactId from LiveChatTranscript where id = :input.routableID ];
        System.assertEquals('Test', testrecord.Contact.FirstName, 'First name should match');
    }

    @isTest
    static void testGetUserDetailsNoContact() {   
        //insert Live Chat Visitor
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        // Create test data - LiveChatTranscript records
        LiveChatTranscript testTranscript = new LiveChatTranscript(
            First_Name__c = 'TestNoFirstName',
            Last_Name__c = 'TestNoLastName',
            Email__c = 'testNoemail@example.com',
            Customer_Journey__c = 'PAYGO',
            LiveChatVisitorid = lcv.id
        );
        insert testTranscript;
        // Create a TranscriptInput instance
        PayGoEinsteinBotGetTranscriptVariables.TranscriptInput input = new PayGoEinsteinBotGetTranscriptVariables.TranscriptInput();
        input.routableID = testTranscript.Id; 
        // Call the method to be tested
        Test.startTest();
        List<PayGoEinsteinBotGetTranscriptVariables.CustomerDetailOutput> result = PayGoEinsteinBotGetTranscriptVariables.getUserDetails(new List<PayGoEinsteinBotGetTranscriptVariables.TranscriptInput>{ input });
        Test.stopTest();
        // Assert the results
        PayGoEinsteinBotGetTranscriptVariables.CustomerDetailOutput customerData = result[0];
        System.assertEquals('TestNoFirstName', customerData.firstName, 'First name should match');
          // Verify there is no Contact is 
        LiveChatTranscript lv = [select id,Contact.FirstName from LiveChatTranscript  LIMIT 1];
        System.assertEquals(null, lv.Contact.FirstName, 'No Contact');
    }
    
    @isTest
    static void testGetAnswer() {
        // Create test data
        List<String> selectedMenu = new List<String>{'Chat with an Expert'};
        // Call the getAnswer method
         Test.startTest();
        List<PayGoEinsteinBotAnswer.AnswerOutput> result = PayGoEinsteinBotAnswer.getAnswer(selectedMenu);
           Test.stopTest();
        // Assert that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');
        // Assert that the result list contains one item
        System.assertEquals(1, result.size(), 'Result should contain one item'); 
    }

    @isTest
    static void PayGoEinsteinBotSecondaryMenuTest() {
        // Call the getAnswer method
         Test.startTest();
        List<List<String>> result = PayGoEinsteinBotSecondaryMenu.getSecondaryMenu();
           Test.stopTest();
        // Assert that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null');     
    }
     @isTest
    static void PayGoEinsteinBotMainMenuTest() {
         Test.startTest();
        List<List<String>> result = PayGoEinsteinBotMainMenu.getMainMenu();
           Test.stopTest();
        // Assert that the result is not null
        System.assertNotEquals(null, result, 'Result should not be null'); 
    }  
}