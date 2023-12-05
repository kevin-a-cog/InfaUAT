@isTest
global class MockAEMHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"actionId":"a3d8I000000Ecw5QAC","title":"IDMC Agile Development Practices","adoptionStageTag":["plan","plan1"],"engagementProductTag":["cloud application integration","cloud data integration","platform"],"URL":"/content/informatica-cxp/en_us/engagements-catalog/idmc-agile-development-practices","tags":["engagement catalog"],"engagementUnit":"1","infaJourneyId":"CLD-018","engagementFocusAreaTag":["functional"],"engagementOverview":"<p>Review standard setup, development and deployment practices for an Agile team working in the IDMC platform</p>","engagementActionTag":"request expert assistance","engagementUseCaseTag":["managed runtimes"],"engagementTypeTag":["Best Practice","Rescue"],"engagementCategoryTag":["cloud integration"],"engagementId":"engagementId109064725","isInternalEngagement":"false"}');
        res.setStatusCode(200);
        return res;
    }
}