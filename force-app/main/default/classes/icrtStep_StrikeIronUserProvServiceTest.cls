/*
Class:  icrtStep_StrikeIronUserProvisionServiceTest
        @Author:        Anil Solanki
        @Created Date:  4 May 2018
        @Description:   Test Class for icrtStep_StrikeIronUserProvisionService Class.
*/
@isTest
private class icrtStep_StrikeIronUserProvServiceTest{
    @isTest
    static void testrequestribe(){
        icrt.IAeAutomatedStepService service = new icrtStep_StrikeIronUserProvisionService();
        icrt.AeServiceDescription response = service.describe();
        System.assertEquals(response.name, 'icrtStep_StrikeIronUserProvisionService');
        System.assertEquals(response.namespaceQualifier, null);
        System.assertEquals(response.displayName, 'StrikeIron User Provisioning Service');
        System.assertEquals(response.Description, 'StrikeIron Trial User Provisioning Service to the Platform from Salesforce');
        System.assertEquals(response.inputParameter.size(), 12);
        System.assertEquals(response.outputParameter.size(), 1);
    }
    
    @isTest
    static void testInvoke(){
        icrt.AeServiceRequest request = new icrt.AeServiceRequest();

        request.addParameter('LeadId', UserInfo.getUserId());
        request.addParameter('Email', 'testing-Ambica@inforamtica.com');
        request.addParameter('FirstName', 'Ambica');
        request.addParameter('LastName', 'Pyati');
        request.addParameter('CompanyName', 'Informatica');
        request.addParameter('Title', 'Ms');
        request.addParameter('Address1', 'Test Address 1');
        request.addParameter('Address2', 'Test Address 1');
        request.addParameter('City', 'Test City');
        request.addParameter('State_Province', 'Test State');
        request.addParameter('Country', 'Test Country');
        request.addParameter('Zip_PostalCode', '12345');
        request.addParameter('PhoneNumber', '8884189560');
        
        Test.setMock(WebServiceMock.class, new StrikeIronWebserviceMock());

        // invoke the service
        icrt.IAeAutomatedStepService service = new icrtStep_StrikeIronUserProvisionService();
        icrt.AeServiceResponse response = service.invoke(request);
        System.assertEquals(response.parameter.size() > 0, true);
    }
}