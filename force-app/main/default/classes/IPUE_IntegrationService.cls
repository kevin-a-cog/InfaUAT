/*
    @Author:        Stephanie Viereckl
    @Created Date:  October 2021
    @Description: This class is an integration framework designed to work in conjunction with the API_Information__c custom object. A HttpRequest
    is build out based on the applicable API Information record, and the HttpResponse is returned.  
    This class is covered by IPUE_IntegrationServiceTest class.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Description                                                 Tag

    Stephanie Viereckl  Oct 2021    IPUE-105      Initial Create
    Chandana Gowda      10-Mar-22   IPUE-220      Changed to without Sharing                
	Jiju N				25-Apr-23	SALESRT-15343	Updated authentication logic
    ********************************************************************************************************************************************
*/

global without sharing class IPUE_IntegrationService {

    @TestVisible static Boolean newSecurityKey = true;
    public static Boolean expiredSecurityKey = false;
    public static Integer callCount = 0;
    global class IntegrationException extends Exception {}

    global static String makeCallout(String requestBody, Id apiInformationId) {

        HttpResponse response = new HttpResponse();
        API_Information__c integrationData = getSessionId(apiInformationId);
        try {
        
            System.debug('IPUE_IntegrationService: HTTP Request Body: ' + requestBody);
            // Build out Http Request and Send to Integration
            Http http = new Http();
            HttpRequest request = buildRequest(requestBody, integrationData);
            System.debug('IPUE_IntegrationService HTTP Request: ' + request);
            response = http.send(request);
            update integrationData;
        } catch (Exception ex) {

            System.debug('IPUE_IntegrationService Exception: ' + ex);
            System.debug('IPUE_IntegrationService Exception message: ' + ex.getMessage());
            System.debug('IPUE_IntegrationService Exception stack trace: ' + ex.getStackTraceString());
            System.debug('IPUE_IntegrationService Exception cause: ' + ex.getCause());
            throw new IntegrationException('Error sending request related to the following API Information record: ' + 
                                           integrationData.name + ' | Error: ' + String.valueOf(ex)
            );

        }
        return handleResponse(response);  
    
    }

    private static HttpRequest buildRequest(String requestBody, API_Information__c integrationData){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(integrationData.API_URL__c);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');

        String securityType = parseSecurityType(integrationData.Security_Header_Type__c);
        
        if(integrationData.Named_Credential__c != '' && integrationData.Named_Credential__c != null){
            request.setHeader('IDS-SESSION-ID', integrationData.Security_Key__c);
            request.setHeader('Authorization', securityType);
        } else {
        	request.setHeader('Authorization', securityType + integrationData.Security_Key__c);
        }
        request.setBody(requestBody);
        return request;
    }

    private static String parseSecurityType(String headerType){
        if (headerType == 'Bearer Token') {
            return 'Bearer ';
        } else {
            return null;
        }

    }

    private static String handleResponse(HttpResponse response){

        Integer statusCode = response.getStatusCode();
        String responseBody = response.getBody();

        System.debug('IPUE_IntegrationService: HTTP Response Status: ' + statusCode);
        System.debug('IPUE_IntegrationService: HTTP Response Status: ' + JSON.serialize(responseBody));

        if (statusCode < 200 || statusCode > 299) {
            
            System.debug('IPUE_IntegrationService: HTTP ERROR: ' + responseBody);
            System.debug('IPUE_IntegrationService: The status code returned was not expected: ' + response.getStatusCode() + ' | Status Code: ' + response.getStatus());

            String message = 'Integration Error: ' + response.getStatusCode() + ' | Status Code: ' + response.getStatus() + ' | Response: ' + responseBody;

            if (message.length() > 255) {

                message = message.subString(0, 250) + '...';

            }
            throw new IntegrationException(message);
        
        } else if (responseBody.contains('Failed to Returned Similar Customers')) {

            String message = 'Integration call was successful but failed to return similar customers. This may be due to an invalid JSON request.' ;
            throw new IntegrationException(message);

        } else {
            System.debug('IPUE_IntegrationService: HTTP Response Body: ' + responseBody);
        }

        return responseBody;

    }

    private static API_Information__c getSessionId(Id apiInformationId){
        //API_Information__c updatedIntegrationObj = new API_Information__c();
        // Query out Custom Metadata where integration details are stored
        API_Information__c integrationData = [
            SELECT Name, Security_Key__c, API_URL__c, Security_Header_Type__c , LastModifiedDate, Named_Credential__c, Minutes_to_Expire__c
            FROM API_Information__c
            WHERE Id = :apiInformationId
            LIMIT 1
        ];
        Decimal minToExpire = integrationData.Minutes_to_Expire__c != null ? integrationData.Minutes_to_Expire__c : 0.0;
        DateTime minutesAgo = System.now().addMinutes(minToExpire.intValue() * -1);
        String securityKey;
        if(integrationData.Named_Credential__c != '' && integrationData.Named_Credential__c != null){
            if(integrationData.LastModifiedDate > minutesAgo) {
                securityKey = integrationData.Security_Key__c;
            } else {
                securityKey = getSecurityKey(integrationData);
                integrationData.Security_Key__c = securityKey;
            } 
        } else {
            securityKey = integrationData.Security_Key__c;
        }
        return integrationData;
    }
    
    public static String getSecurityKey(API_Information__c integrationData){
        String securityKey;
        HttpResponse response = new HttpResponse();
        try {
            // Build out Http Request and Send to Integration
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:'+integrationData.Named_Credential__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            string requestBody = '{"@type":"login", "username" : "{!$Credential.Username}", "password" : "{!$Credential.Password}"}';
			request.setBody(requestBody);
            response = http.send(request);
            
            Integer statusCode = response.getStatusCode();
        	String responseBody = response.getBody();

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

			// Extract the icSessionId value from the map
			securityKey = (String) jsonMap.get('icSessionId');
            
        }  catch (Exception ex) {

            System.debug('IPUE_IntegrationService Exception: ' + ex);
            System.debug('IPUE_IntegrationService Exception message: ' + ex.getMessage());
            System.debug('IPUE_IntegrationService Exception stack trace: ' + ex.getStackTraceString());
            System.debug('IPUE_IntegrationService Exception cause: ' + ex.getCause());
            throw new IntegrationException('Error sending request related to getting security key: ' + String.valueOf(ex));
        }
        return securityKey;
    }
}