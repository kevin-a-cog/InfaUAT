global class helpArticleCalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
		res.setBody('{"totalCount" : 5472,"results" : [ {"raw" :{"systitle" : "ERROR:The source connection selected for the Synchronization task has no associated object. Select a different source connection. while using a Salesforce connection in DSS source","infapublicurl" : "https://sit-infa.cs211.force.com/support/s/articlepreview/?c__number=ERROR-The-source-connection-selected-for-the-Synchronization-task-has-no-associated-object-Select-a-different-source-connection-while-using-a-Salesforce-connection-in-DSS-source&language=en_US","clickableuri" : "https://sit-infa.cs211.force.com/support/s/articlepreview/?c__number=ERROR-The-source-connection-selected-for-the-Synchronization-task-has-no-associated-object-Select-a-different-source-connection-while-using-a-Salesforce-connection-in-DSS-source&language=en_US","sfprimaryproduct" : "Cloud Integration"} }]}');        
        return res;
    }

}