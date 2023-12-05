/*
 * Name			:	EngineerWorkspaceTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/30/2021
 * Description	:	Engineer Workspace test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/30/2021		N/A				Initial version.			N/A
 */
@isTest
global class RestCalloutUtilityTestClass implements HttpCalloutMock {

	//Public variables.
	private Integer intStatusCode;
	private String strBody;
	private Map<String, String> mapHeaders;

	/*
	 Method Name : RestCalloutUtilityTestClass
	 Description : Constructor of the class.
	 Parameters	 : None
	 Return Type : None
	 */
	public RestCalloutUtilityTestClass(Map<String, String> mapHeaders, String strBody, Integer intStatusCode) {
		this.mapHeaders = mapHeaders;
		this.strBody = strBody;
		this.intStatusCode = intStatusCode;
	}

    /*
	 Method Name : respond
	 Description : HTTP response method.
	 Parameters	 : HTTPRequest, called from respond, objRequest Request.
	 Return Type : HTTPResponse
	 */
    global HTTPResponse respond(HTTPRequest objRequest) {
        HttpResponse objResponse = new HttpResponse();
		if(mapHeaders != null) {
			for(String strHeader : mapHeaders.keySet()) {
				objResponse.setHeader(strHeader, mapHeaders.get(strHeader));
			}
		}
        objResponse.setBody(strBody);
        objResponse.setStatusCode(intStatusCode);
        return objResponse; 
    }
}