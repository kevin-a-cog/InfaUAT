global class helpCoveoVideoCalloutMock  implements HttpCalloutMock{
     global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"totalCount" : 5472,"results" : [ {"title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","printableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","clickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","raw" :{"systitle" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","clickableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ytthumbnailurl" : "https://i.ytimg.com/vi/56ptHKf_B0U/mqdefault.jpg","printableuri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","udate" : 1641568034000,"rowid" : 1641607828317879983},"Title" : "Configuring an IAM Assume Role to Access AWS Resources Using PowerExchange for Amazon S3","Uri" : "https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","PrintableUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","ClickUri" : "https://www.youtube.com/watch?v=56ptHKf_B0U","UniqueId" : "42.8693$https://youtube.com/Channel:UCSelL9LuO0Ubp1TQ5QhO0NA/Video:56ptHKf_B0U","Excerpt" : "This video demonstrates how to configure an IAM assume role to access AWS resources using PowerExchange for Amazon S3.","FirstSentences" : null}]}');
        res.setStatusCode(200);
        return res;
    }
}