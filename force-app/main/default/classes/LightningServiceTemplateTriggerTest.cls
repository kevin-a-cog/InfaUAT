/*
    @Author:        Stephanie Viereckl
    @Created Date:  Nov 2021
    @Description:   This test class covers the LightningServiceTemplateTrigger and LightningServiceTemplateTriggerHandler class.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Nov 2021    IPUE-105                        Initial Create                     
    ********************************************************************************************************************************************
*/

@isTest
public with sharing class LightningServiceTemplateTriggerTest {
    
    public static String apiFieldMappingName = 'test_value';

    @TestSetup
    static void setup(){

        IPUE_TestUtils.setupFormData();
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration', 'www.test.com', 'Bearer Token', '1234abcd', '', null);
        API_Field_Mapping__c fieldMapping = IPUE_TestUtils.createFieldMapping(false, apiFieldMappingName, 'data.test', apiInfo.Id, null);
        fieldMapping.API_Field_Type__c = 'Response';
        insert fieldMapping;

    }

    /**
     * Test inserting the Lightning Service Template to ensure after insert triggers create a Lightning Service Member correctly. In addition, test updating
     * the Content field on a Lightning Service Template to ensure the after update triggers remove the Lightning Service Member as expected.
     */
    @isTest
    private static void reconcileLightningServiceMembersTest(){

        List<Page_Section__c> pageSections = [SELECT Id FROM Page_Section__c];
        Lightning_Service_Template__c template = IPUE_TestUtils.createServiceTemplate(true, 'Test Template', '$' + apiFieldMappingName, pageSections[0].Id);

        List<Lightning_Service_Member__c> lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.assertEquals(1, lightningServiceMembers.size(), 'Lightning Service Member did not get created as expected.');
        System.assertEquals(template.Id, lightningServiceMembers[0].Lightning_Service_Template__c, 'Lightning Service Member was not mapped correctly.');

        template.Content__c = '';
        update template;

        lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.assertEquals(0, lightningServiceMembers.size(), 'Lightning Service Member was not deleted.');

    }

    /**
     * Test deleting a Lightning Service Template that has a Lightning Service Member associated to check that the after delete triggers will successfully
     * delete the Lightning Service Member
     */
    @isTest
    private static void deleteLightningServiceMembersTest(){

        List<Page_Section__c> pageSections = [SELECT Id FROM Page_Section__c];
        Lightning_Service_Template__c template = IPUE_TestUtils.createServiceTemplate(true, 'Test Template', '$' + apiFieldMappingName, pageSections[0].Id);

        List<Lightning_Service_Member__c> lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.debug('lightningServiceMembers before deleting: ' + lightningServiceMembers);

        System.assertEquals(1, lightningServiceMembers.size(), 'Lightning Service Member was not created as expected.');

        delete template;

        lightningServiceMembers = [
            SELECT Id, Lightning_Service_Template__c
            FROM Lightning_Service_Member__c
        ];

        System.debug('lightningServiceMembers after deleting: ' + lightningServiceMembers);

        System.assertEquals(0, lightningServiceMembers.size(), 'Lightning Service Member was not deleted.');

    }

}