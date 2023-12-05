/*
Class:          AccountSearchControllerMock
@Author:        Jiju N
@Created Date:  14 Dec 2021
@Description:   Mock class for AccountSearchControllerTest

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
global class AccountSearchControllerMock implements HTTPCalloutMock {
    // Creating a fake response
    global HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        // Setting the response body
        response.setBody('[{"accountName":"Test Account","accountNumber":"A00000000","address":"Test Street","city":"Test City","country":"USA","isSalesforceRecord":true,"postalCode":"000-0000","salesforce_id":"0014100000AaaA0AAA","site_gduns":"abcdef","source":"SFDC","state":"Test State","Account_Type":"Customer Account"},{"accountName":"Test Account1","accountNumber":"A000010000","address":"Test Street1","city":"Test City1","country":"USA","isSalesforceRecord":false,"postalCode":"000-0000","salesforce_id":"","site_gduns":"abcdef","source":"MDM","state":"Test State"}]');
        // Setting the response header
        response.setHeader('Content-Type', 'application/json');
        // Setting the response code
        response.setStatusCode(200);
        // Returning the response
        return response;
    }
}