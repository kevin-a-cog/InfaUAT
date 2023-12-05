/*
    @Author:        Stephanie Viereckl
    @Created Date:  Nov 2021
    @Description:   This test class covers the ApiFieldMappingTrigger and ApiFieldMappingTriggerHandler class.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 2021    IPUE-105                        Initial Create                     
    ********************************************************************************************************************************************
*/

@isTest
public with sharing class ApiFieldMappingTriggerHandlerTest {
    
    public static String apiFieldMappingName = 'test_value';

    /**
     * Test deleting a Lightning Service Template that has a Lightning Service Member associated to check that the after delete triggers will successfully
     * delete the Lightning Service Member
     */
    @isTest
    private static void deleteLightningServiceMembersTest(){

        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', '1234abcd', '', null);
        API_Field_Mapping__c fieldMapping = IPUE_TestUtils.createFieldMapping(false, apiFieldMappingName, 'data.test', apiInfo.Id, null);
        fieldMapping.API_Field_Type__c = 'Response';
        insert fieldMapping;

        // List<Page_Section__c> pageSections = [SELECT Id FROM Page_Section__c];
        Lightning_Service_Template__c template = IPUE_TestUtils.createServiceTemplate(true, 'Test Template', '$' + apiFieldMappingName, null);

        List<Lightning_Service_Member__c> lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.debug('lightningServiceMembers before deleting: ' + lightningServiceMembers);

        System.assertEquals(1, lightningServiceMembers.size(), 'Lightning Service Member was not created as expected.');

        delete fieldMapping;

        lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.debug('lightningServiceMembers after deleting: ' + lightningServiceMembers);

        System.assertEquals(0, lightningServiceMembers.size(), 'Lightning Service Member was not deleted.');

    }

}