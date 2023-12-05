/*
    @Author:        Stephanie Viereckl
    @Created Date:  Nov 3 2021
    @Description:   This test class covers the IPUE_IntegrationService class.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 4 2021  IPUE-105                        Initial Create                     
    ********************************************************************************************************************************************
*/

@isTest
public with sharing class IPUE_IntegrationServiceTest {
    
    private static String testJsonRequest = '{test: {testA: "value"}}';

    /**
     * Test Integration Service when mock response is 200 (success)
     */
    @isTest
    private static void test200Response(){

        // Setup API Information record used in HttpRequest
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', 'abcd1234', '', null);

        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(200);
       
        //Make the mock request
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock);
        String response = IPUE_IntegrationService.makeCallout(testJsonRequest, apiInfo.Id);

        Test.stopTest();

    }
    
    /**
     * Test Integration Service when mock response is 200 (success)
     */
    @isTest
    private static void test200ResponseWithNamedCred(){

        // Setup API Information record used in HttpRequest
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', 'abcd1234', 'ICS_session_ID_for_IPU', 20);

        String responseBody = '{"icSessionId":"5dw2RptZqW3fL2PJyBaJgj"}';
        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(200, responseBody);
       
        //Make the mock request
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock);
        String response = IPUE_IntegrationService.makeCallout(testJsonRequest, apiInfo.Id);

        Test.stopTest();

    }
    
    /**
     * Test Integration Service when mock response is 200 (success)
     */
    @isTest
    private static void test200ResponseWithNamedCredException(){
        Boolean exceptionCaught = false;

        // Setup API Information record used in HttpRequest
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', 'abcd1234', 'ICS_session_ID_for_IPU', null);

        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(200);
       	try {
            //Make the mock request
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock);
            IPUE_IntegrationService.newSecurityKey = false;
            String response = IPUE_IntegrationService.makeCallout(testJsonRequest, apiInfo.Id);
            Test.stopTest();
            
        } catch (Exception ex) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught, 'Exception not thrown and caught as expected');
    }

    /**
     * Test Integration Service when mock response is 400 (error)
     */
    @isTest
    private static void test400Response(){

        // Setup API Information record used in HttpRequest
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', 'abcd1234', '', null);

        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(400);
       

        Boolean exceptionCaught = false;

        try {

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, mock);
            String response = IPUE_IntegrationService.makeCallout(testJsonRequest, apiInfo.Id);
    
            Test.stopTest();
    
        } catch (Exception ex) {

            exceptionCaught = true;

        }

        System.assert(exceptionCaught, 'Exception not thrown and caught as expected');

    }

    /**
     * Test Integration Service when no API Information record exists, therefore causing an exception to be
     * thrown when building the HttpRequest
     */
    @isTest
    private static void testExceptionPath(){

        // Do not create API Information record to throw exception

        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(200);
       
        Boolean exceptionCaught = false;

        try {

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, mock);
            String response = IPUE_IntegrationService.makeCallout(testJsonRequest, null);
    
            Test.stopTest();
    
        } catch (Exception ex) {

            exceptionCaught = true;

        }

        System.assert(exceptionCaught, 'Exception not thrown and caught as expected');
    }

    /**
     * Test Integration Service when no API Information record exists, therefore causing an exception to be
     * thrown when building the HttpRequest
     */
    @isTest
    private static void testFailedToReturnSimilarCustomers(){

        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', 'abcd1234', '', null);

        IPUE_IntegrationMockResponse mock = new IPUE_IntegrationMockResponse();
        mock.addResponse(200, 'Failed to Returned Similar Customers');
       
        Boolean exceptionCaught = false;

        try {

            Test.startTest();

            Test.setMock(HttpCalloutMock.class, mock);
            String response = IPUE_IntegrationService.makeCallout(testJsonRequest, apiInfo.Id);
    
            Test.stopTest();
    
        } catch (Exception ex) {

            exceptionCaught = true;

        }

        System.assert(exceptionCaught, 'Exception not thrown and caught as expected');
    }


}