/*
        @Author:        Stephanie Viereckl
        @Created Date:  Nov 4 2021
        @Description:   Mock Response used in IPUE_IntegrationServiceTest

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 4 2021  IPUE-110                        Initial Create                     
    ********************************************************************************************************************************************
*/

@isTest
global class IPUE_IntegrationMockResponse implements HttpCalloutMock {
    
    HttpResponse[] responses = new HttpResponse[0];
    
    global HttpResponse respond(HTTPRequest req){
        return responses.remove(0);
    }

    global void addResponse(Integer statusCode){
        String responseBody = '{ "API_A": 5, "API_B": "b", "API_C": "hooray!", "API_PARENT": {"API_CHILD": "nested value", "ZERO": 0}, "icSessionId":"5dw2RptZqW3fL2PJyBaJgj"}';
        addResponse(statusCode, responseBody);
    }

    // Overload method to be able to accept a specific response if needed
    global void addResponse(Integer statusCode, String responseBody){

        //fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        responses.add(res);
    }

}