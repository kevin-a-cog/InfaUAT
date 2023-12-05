/****************************************************************************************************************
Class:          ObjectEntityLimitsReportControllerTest
@Author:        Mohammed Anies
@Created Date:   28-July-2022
@Description:    

Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description


************************************************************************************************************************************************************
******************************************************************************************************************/

@isTest
public with sharing class ObjectEntityLimitsReportControllerTest {
   @isTest
    public static void testGetObjectLimit(){
        Test.setMock(HttpCalloutMock.class, new ToolingAPIMock(objectlimitresponse, 200));
        Test.startTest();
        integer getObjectLimitCount = ObjectEntityLimitsReportController.getObjectLimit().size();
        Test.stopTest();
        system.assert(getObjectLimitCount > 1, 'Org Limits Size not greater than 1');

   }

   

   @isTest
    public static void LimitsDisplayGetObjectLimit(){
        Test.setMock(HttpCalloutMock.class, new ToolingAPIMock(objectlimitresponse, 200));
        Test.startTest();
        integer getObjectLimitCount = EntityLimitsDisplayController.getObjectLimit('Account').size();
        Test.stopTest();
        system.assert(getObjectLimitCount > 1, 'Size not greater than 1');

   }

   @isTest
    public static void LimitsDisplayGetObjectLimitNullResponse(){
        Test.setMock(HttpCalloutMock.class, new ToolingAPIMock(objectlimitresponse, 400));
        Test.startTest();
        EntityLimitsDisplayController.getObjectLimit('Account');
        Test.stopTest();
        

   }

   @isTest
   static void getLimitMonitoringObjectOptions(){
    //Test.startTest();
    integer countMonitoringObjectList = EntityLimitsDisplayController.getLimitMonitoringObjectOptions().size();
    //Test.stopTest();
    //system.assert(countMonitoringObjectList > 1, 'No Records Defined');
    
   }

   @isTest
   static void testScheduledJobs(){
    //Test.startTest();
    integer countMonitoringObjectList = ObjectEntityLimitsReportController.getAllScheduledJobs().size();
    //Test.stopTest();
    //system.assert(countMonitoringObjectList > 1, 'No Records Defined');
    
   }

  
public class ToolingAPIMock implements HttpCalloutMock {
    private String testResponse;
    private Integer testStatusCode;

    public ToolingAPIMock(String testResponse, Integer testStatusCode){
        this.testResponse = testResponse;
        this.testStatusCode = testStatusCode;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(testResponse);
        res.setStatusCode(testStatusCode);
        return res;
    }
}
   private static string objectlimitresponse = '{"size":11,"totalSize":11,"done":true,"queryLocator":null,"entityTypeName":"EntityLimit","records":[{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.CustomFields"},"Type":"CustomFields","Label":"Custom Fields","Remaining":659,"Max":800,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.RollupSummary"},"Type":"RollupSummary","Label":"Rollup Summary Fields","Remaining":23,"Max":25,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.CustomRelationship"},"Type":"CustomRelationship","Label":"Custom Relationship Fields","Remaining":28,"Max":40,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.ActiveRules"},"Type":"ActiveRules","Label":"Active Workflow Rules","Remaining":44,"Max":50,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.TotalRules"},"Type":"TotalRules","Label":"Total Workflow Rules","Remaining":493,"Max":500,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.ApprovalProcesses"},"Type":"ApprovalProcesses","Label":"Approval Processes","Remaining":500,"Max":500,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.ActiveLookupFilters"},"Type":"ActiveLookupFilters","Label":"Active Lookup Filters","Remaining":5,"Max":5,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.ActiveValidationRules"},"Type":"ActiveValidationRules","Label":"Active Validation Rules","Remaining":490,"Max":500,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.VLookup"},"Type":"VLookup","Label":"VLOOKUP Functions","Remaining":10,"Max":10,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.SharingRules"},"Type":"SharingRules","Label":"Sharing Rules (Both Owner- and Criteria-based)","Remaining":296,"Max":300,"EntityDefinitionId":"Account"},{"attributes":{"type":"EntityLimit","url":"/services/data/v45.0/tooling/sobjects/EntityLimit/Account.CbsSharingRules"},"Type":"CbsSharingRules","Label":"Sharing Rules (Criteria-based Only)","Remaining":46,"Max":50,"EntityDefinitionId":"Account"}]}';
}