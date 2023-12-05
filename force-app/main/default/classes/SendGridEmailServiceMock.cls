/*
Class:          SendGridEmailServiceMock
@Author:        Pavithra V
@Created Date:  15-Mar-2021
@Description:   Mock class for SendGridEmailService

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
global  class SendGridEmailServiceMock implements HTTPCalloutMock {
    
    // Creating a fake response
    global HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        // Setting the response body
        response.setBody('{"tracking_settings":{"click_tracking":{"enable":true}},"template_id":"d-fc28c4bf07ad49f68534627eae7cd878","reply_to":{"name":"Informatica Support","email":"test@test.com"},"personalizations":[{"to":[{"name":"Test Contact","email":"test@test.com"}],"subject":null,"dynamic_template_data":{"null"} }]}');
        // Setting the response header
        response.setHeader('Content-Type', 'application/json');
        // Setting the response code
        response.setStatusCode(200);
        // Returning the response
        return response;
    }

}