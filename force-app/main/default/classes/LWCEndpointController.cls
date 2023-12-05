/*
Class:              LWCEndpointController
@Author:            Coveo/Madhu Shanthappa
@Created Date:      11-Sep-2023
@Description:       I2RT-8961:Apex class provided by Coveo for Endpoint for Coveo API Call and is used for Einstein Bot COveo search
@TestClass:         LWCEndpointControllerTest
Change History:
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.               Requested By            Description                                    Tag
*********************************************************************************************************************************************

*/
public without sharing class LWCEndpointController {

  @AuraEnabled(cacheable=true)
  public static string getEndpoint(String searchHub) {
    Map<String, Object> endpoint = CoveoV2.Globals.getEndpointData();
    endpoint.put('token', CoveoV2.Globals.generateSearchToken(
        new Map<String,Object>{
            'searchHub' => searchHub
        }
    ));
    return JSON.serialize(endpoint);
  }
}