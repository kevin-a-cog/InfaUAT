/*
        Class:          StrikeIronWebserviceMock 
        @Author:        Ambica Pyati
        @Created Date:  06 June 2017
        @Description:   US-1583 Mock Websevice for testing the StrokeIron webservice 


    Change History
*****************************************************************************************************************************
    ModifiedBy          Date        Requested By        Description                                             Tag
    
******************************************************************************************************************************
*/


@isTest                       
global class StrikeIronWebserviceMock implements WebServiceMock {
   
   global void doInvoke(Object stub,Object request,Map<String, Object> response,String endpoint,String soapAction,String requestName,String responseNS,String responseName,String responseType) 
   {
       if(request instanceof StrikeIronAdminService.AddUser_element)
                response.put('response_x', new StrikeIronAdminService.AddUserResponse_element());
       
       if(request instanceof StrikeIronAdminService.GetStatusCodesForMethod_element)
                response.put('response_x', new StrikeIronAdminService.GetStatusCodesForMethodResponse_element());
                
        if(request instanceof StrikeIronAdminService.GetServiceInfo_element)
                response.put('response_x', new StrikeIronAdminService.GetServiceInfoResponse_element());
                
        if(request instanceof StrikeIronAdminInfo.GetRemainingHits_element)
                response.put('response_x', new StrikeIronAdminInfo.GetRemainingHitsResponse_element());
                
        if(request instanceof StrikeIronAdminService.GetStatusCodes_element)
                response.put('response_x', new StrikeIronAdminService.GetStatusCodesResponse_element());
       
        new StrikeIronAdminService.SIWsOutputOfMethodStatusRecord();
         new StrikeIronAdminService.MethodStatusRecord();
        new StrikeIronAdminService.SIWsStatus();
        new StrikeIronAdminService.SIWsResultArrayOfSIWsStatus();
        new StrikeIronAdminService.SIWsOutputOfSIWsResultArrayOfMethodStatusRecord();
        new StrikeIronAdminService.ArrayOfMethodStatusRecord();
        new StrikeIronAdminService.ServiceInfoRecord();
        new StrikeIronAdminService.SIWsResultArrayOfMethodStatusRecord();
        new StrikeIronAdminService.SIWsResultArrayOfServiceInfoRecord();
        new StrikeIronAdminService.ArrayOfSIWsStatus();
        new StrikeIronAdminService.ArrayOfServiceInfoRecord();
        new StrikeIronAdminService.NewUser();
        new StrikeIronAdminService.SIWsOutputOfSIWsResultArrayOfServiceInfoRecord();
        new StrikeIronAdminInfo.SubscriptionInfo();
   }
   
   @isTest static void testStrikeIronService() 
   {              
        Test.setMock(WebServiceMock.class, new StrikeIronWebserviceMock());
        
        StrikeIronAdminService.User_L2Soap siService = new StrikeIronAdminService.User_L2Soap();
            
        String Email = 'testing-user@inforamtica.com';
        String FirstName = 'Test';
        String LastName = 'user';
        String CompanyName = 'Informatica';
        String Title = 'Mr';
        String Address1 = 'Test Address 1';
        String Address2 = 'Test Address 1';
        String City = 'Test City';
        String State_Province = 'Test State';
        String Country = 'Test Country';
        String Zip_PostalCode = '12345';
        String PhoneNumber = '987654321';
        Boolean ActivateUser = false;
        Boolean SuppressEmail = false;
        Boolean ValidateEmail = false;
        Integer EmailValidationTimeout = 120;
        
        siService.AddUser(FirstName, LastName, CompanyName, Email, Title, Address1, Address2, City, State_Province, Country, Zip_PostalCode, PhoneNumber, ActivateUser, SuppressEmail, ValidateEmail, EmailValidationTimeout);
        
        String methodName = 'GetStatusCodes';
        siService.GetStatusCodesForMethod(methodName);
        
        siService.GetServiceInfo();
        
        siService.GetRemainingHits();
        
        siService.GetStatusCodes();
       
   }
}