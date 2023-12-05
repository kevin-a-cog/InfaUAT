global class helpPaygoCAICalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error":{"code":500,"detail":{"reason":" Id for temp.tmp_User not set"},"message":" Id for temp.tmp_User not set"}}');
        res.setStatusCode(500);
        return res;
    }

}