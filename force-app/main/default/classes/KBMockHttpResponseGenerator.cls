@isTest
global class KBMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('token')){
            res.setBody('{"token":"testToken"}');
        }else{
            string response = '{'+
                '"results": ['+
                '{'+
                '"title": "Test Article 1",'+
                '"clickUri": "https://uat-infa.cs198.force.com/customersupport/s/article/000111506",'+
                '"raw": {'+
                '"infadocid": "000111506",'+
                '"sysfiletype": "html"'+
                '}'+
                '},'+
                '{'+
                '"title": "Test Article 2",'+
                '"clickUri": "https://uat-infa.cs198.force.com/customersupport/s/article/000111507",'+
                '"raw": {'+
                '"infadocid": "000111507",'+
                '"sysfiletype": "html"'+
                '}'+
                '},'+
                '{'+
                '"title": "Test Article 3",'+
                '"clickUri": "https://uat-infa.cs198.force.com/customersupport/s/article/000111508",'+
                '"raw": {'+
                '"infadocid": "000111508",'+
                '"sysfiletype": "html"'+
                '}'+
                '}'+
                ']'+
                '}';
            
            res.setBody(response);
        }
        
        //res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
    }
}