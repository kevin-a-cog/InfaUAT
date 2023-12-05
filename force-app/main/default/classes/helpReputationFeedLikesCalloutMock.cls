global class helpReputationFeedLikesCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('("ReputationPointsForLikesWrapper":["FeedItemLikesData=(FeedItem":{Id=0D56C00000QpsGzSAJ,LikeCount=1,CreatedById=0053f000000JXaBAAW},"FeedItem":{Id=0D56C00000QpXLESA3,LikeCount=2,CreatedById=0053f000000JXaBAAW}")","TopicAssignmentList=(TopicAssignment":{Id=0FT6C000000DxmgWAC,EntityId=0D56C00000QpXLESA3,TopicId=0TO6S000000JAALWA4},"TopicAssignment":{Id=0FT6C000000DxpBWAS,EntityId=0D56C00000QpsGzSAJ,TopicId=0TO6S000000JAAKWA4}")"])');
        return res;
    }
}