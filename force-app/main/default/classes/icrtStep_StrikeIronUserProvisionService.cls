/*
        Class:          icrtStep_StrikeIronUserProvisionService
        @Author:        Ambica Pyati
        @Created Date:  06 June 2017
        @Description:   Websevice call out for provisiong users in Strike Iron 


    Change History
*****************************************************************************************************************************
    ModifiedBy          Date        Requested By        Description                                             Tag
    
******************************************************************************************************************************
*/

global class icrtStep_StrikeIronUserProvisionService implements icrt.IAeAutomatedStepService
{
    
    private static icrt.AeServiceDescription sdesc;// define icrtStep properties
    private static StrikeIron_Config__c strikeIronConfig;// custom setting for Strike Iron Parameters
     
    static
    {
        strikeIronConfig = new StrikeIron_Config__c();
        strikeIronConfig = StrikeIron_Config__c.getInstance();
    }
    
    
    // define icrtStep properties and parameter types
    static
    {
        sdesc = new icrt.AeServiceDescription();
        
        sdesc.serviceType = 'Step';
        sdesc.namespaceQualifier = icrt.AeServiceDescription.getNamespacePrefixForClass('icrtStep_StrikeIronUserProvisionService');
        sdesc.name = 'icrtStep_StrikeIronUserProvisionService';
        sdesc.displayName = 'StrikeIron User Provisioning Service';
        sdesc.description = 'StrikeIron Trial User Provisioning Service to the Platform from Salesforce';
        
        sdesc.addInputParameterDesc('Email', 'string', true);
        sdesc.addInputParameterDesc('FirstName', 'string', true);
        sdesc.addInputParameterDesc('LastName', 'string', true);
        sdesc.addInputParameterDesc('CompanyName', 'string', false);
        sdesc.addInputParameterDesc('Title', 'string', false);
        sdesc.addInputParameterDesc('Address1', 'string', false);
        sdesc.addInputParameterDesc('Address2', 'string', false);
        sdesc.addInputParameterDesc('City', 'string', false);
        sdesc.addInputParameterDesc('State_Province', 'string', false);
        sdesc.addInputParameterDesc('Country', 'string', false);
        sdesc.addInputParameterDesc('Zip_PostalCode', 'string', false);
        sdesc.addInputParameterDesc('PhoneNumber', 'string', false);
        
               
        sdesc.addOutputParameterDesc('statusCode', 'string');
    }
    
    
    
    /**
    * this method is invoked from ICRT to describe the ICRT step
    * @param NA
    * @return return-void
    * @throws exception - NA
    */
    
    global icrt.AeServiceDescription describe() 
    {  
        return sdesc;    
    } 
    
    
     /**
    * this method is invoked from ICRT to read the parametes from the ICRT step and make a call to Strike Iron for user provisioning
    * @param NA
    * @return return-void
    * @throws exception - NA
    */    
    
    global icrt.AeServiceResponse invoke (icrt.AeServiceRequest req) 
    { 
        String statusCode = '';
        
        icrt.AeServiceResponse response = new icrt.AeServiceResponse();
        
        Map<String, Object> reqParams = req.getTypedParameterMap(sdesc.getInputParameterMap());
        
        String Email =  (String) reqParams.get('Email'); 
        String FirstName =  (String) reqParams.get('FirstName'); 
        String LastName =  (String) reqParams.get('LastName');
        String CompanyName =  (String) reqParams.get('CompanyName'); 
        String Title =  (String) reqParams.get('Title'); 
        String Address1 =  (String) reqParams.get('Address1'); 
        String Address2 =  (String) reqParams.get('Address2'); 
        String City =  (String) reqParams.get('City'); 
        String State_Province =  (String) reqParams.get('State_Province');
        String Country =  (String) reqParams.get('Country');
        String Zip_PostalCode =  (String) reqParams.get('Zip_PostalCode');
        String PhoneNumber =  (String) reqParams.get('PhoneNumber');
        
        //Assign the webservice parameters from custom setting
        Boolean ActivateUser = strikeIronConfig.Activate_User__c;
        Boolean SuppressEmail = strikeIronConfig.Suppress_Email__c;
        Boolean ValidateEmail = strikeIronConfig.Validate_Email__c;
        Integer EmailValidationTimeout = (Integer) strikeIronConfig.Email_Validation_Time_out__c;
        
        //Assign the parameters from custom setting for User Authentication 
        StrikeIronAdminInfo.RegisteredUser regUser = new StrikeIronAdminInfo.RegisteredUser();
       
        //Get user credentials from custom setting
        globalCustomSettings gcsetting = new globalCustomSettings();             
        regUser.UserID = gcsetting.FetchCustomSettings('StrikeIronUserName');
        regUser.Password = gcsetting.FetchCustomSettings('StrikeIronPassword');    
        
        StrikeIronAdminInfo.LicenseInfo licInfo = new StrikeIronAdminInfo.LicenseInfo();
        licInfo.RegisteredUser = regUser;
         
       
        StrikeIronAdminService.User_L2Soap siService = new StrikeIronAdminService.User_L2Soap();
        
        siService.LicenseInfo = licInfo;
        
        StrikeIronAdminService.SIWsOutputOfNewUser AddUser = new StrikeIronAdminService.SIWsOutputOfNewUser();
        
        //assign user parameters
        AddUser = siService.AddUser(FirstName, LastName, CompanyName, Email, Title, Address1, Address2, City, State_Province, Country, Zip_PostalCode, PhoneNumber, ActivateUser, SuppressEmail, ValidateEmail, EmailValidationTimeout);
    
         //web service call to privsion the user  
        if(!Test.isRunningtest())
        {
            if(String.isnotBlank(String.valueOf(AddUser.ServiceStatus.StatusNbr)))   
                statusCode = String.valueOf(AddUser.ServiceStatus.StatusNbr); 
        }
        
        //send status code to ICRT variable
        response.addParameter('statusCode', statusCode);
        
        return response;
        
    }
}