global class helpReputationFeedBestAnswerCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('("ReputationPointsWrapper":[BestCommentIdList=(0D76C000000F6axSAC),"TopicAssignmentList=(TopicAssignment":{Id=0FT6C000000DxpQWAS,EntityId=0D56C00000Qq0T8SAJ,TopicId=0TO6S000000JAAOWA4}")"])');
        return res;
    }
}