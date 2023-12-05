/*
Class:  globalCustomSettingsTest
        @Author:        Anil Solanki
        @Created Date:  25 April 2018
        @Description:   Test Class for globalCustomSettings Class.
*/
@isTest
private class globalCustomSettingsTest{

    static testmethod void FetchCustomSettingsTest() {
        Global_Settings__c settings = new Global_Settings__c(
            name = 'production',
            Developer_Value__c = 'test',
            Production_Value__c = 'test1',
            UAT_Value__c = 'test2'
        );

        insert settings;

        Test.startTest();
            globalCustomSettings globalCS = new globalCustomSettings();
            globalCS.FetchCustomSettings(settings.Name);
        Test.stopTest();

    }
}