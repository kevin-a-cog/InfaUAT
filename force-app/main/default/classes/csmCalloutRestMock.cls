@isTest
global with sharing class csmCalloutRestMock implements HTTPCalloutMock {
     // Creating a fake response
     global HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        // Setting the response body
        response.setBody('{}');
        response.setHeader('Content-Type', 'application/json');
        // Setting the response code
        response.setStatusCode(200);
        // Returning the response
        return response;
    }

}