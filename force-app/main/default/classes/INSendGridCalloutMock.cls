global class INSendGridCalloutMock  implements HttpCalloutMock{
     global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"errors":[{"message":"The content_id parameter is required if disposition = inline.","field":"attachments.0.content_id","help":"http://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/errors.html#message.attachments.content_id"}]}');
        res.setStatusCode(400);
        return res;
    }
}