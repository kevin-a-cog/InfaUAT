/*
*****************************************************************************************************************
Class:          DownloadLinksApi
@Author:        Apyati
@Created Date:  8/7/2019.
@Description:   F2A-22 Api Test class for DownloadLinksApi
******************************************************************************************************************
*/

@isTest
public class DownloadLinksApiTest {
    
    @testSetup
    static void setupObjectTestData() 
    {
        
        sObject Obj1;
        
        Obj1 = new Installbase__c();
        UtilityTestData.mInstallbase.put('Name','Test Installbase');
        Obj1 = UtilityTest.putFieldRecord(obj1, UtilityTestData.mInstallbase);
        List<Installbase__c> lInstallbase = (List<Installbase__c>) UtilityTest.makeInsert(new List<sObject>{Obj1});
        
        obj1 = new Versions__c();
        UtilityTestData.mVersion.put('Install_Base__c',lInstallbase[0].id);
        UtilityTestData.mVersion.put('Name','TestVersion');
        obj1 = UtilityTest.putFieldRecord(obj1, UtilityTestData.mVersion);
        List<Versions__c> lversion = (List<Versions__c>) UtilityTest.makeInsert(new List<sObject>{Obj1});
         
        Obj1 = new Download_Link__c();
        UtilityTestData.mDownloadLink.put('Version__c',lversion[0].id);
        UtilityTestData.mDownloadLink.put('Name','TestVersion');
        UtilityTestData.mDownloadLink.put('URL__c','http://download.informatica.com/*/downloads/ActiveEndpoint/ActiveVOSUnix9245.zip');
        Obj1 = UtilityTest.putFieldRecord(Obj1, UtilityTestData.mDownloadLink);
        List<Download_Link__c> lDownloadlink = (List<Download_Link__c>) UtilityTest.makeInsert(new List<sObject>{obj1});
        
        Obj1 = new Fulfillment__c();
        UtilityTestData.mFulfillment.put ('Fullfillment_Name__c', 'Test Fulfillment');
        UtilityTestData.mFulfillment.put ('Active__c', 'True');
        Obj1 = UtilityTest.putFieldRecord(Obj1, UtilityTestData.mFulfillment);
        List<Fulfillment__c> lFulfillment= ( List<Fulfillment__c>) UtilityTest.makeInsert(new List<sObject>{obj1});

        Obj1 = new Fulfillment_Line__c();
        UtilityTestData.mFulfillmentLine.put ('Fullfillment__c', lFulfillment[0].id);
        UtilityTestData.mFulfillmentLine.put ('Name', 'Test Fulfillment Line');
        Obj1 = UtilityTest.putFieldRecord(Obj1, UtilityTestData.mFulfillmentLine);
        List<Fulfillment_Line__c> lFulfillmentLine= ( List<Fulfillment_Line__c>) UtilityTest.makeInsert(new List<sObject>{obj1});

        Obj1 = new Fulfillment_Version__c();
        UtilityTestData.mFulfillmentVersion.put ('Fullfillment_Line__c', lFulfillmentLine[0].id);
        UtilityTestData.mFulfillmentVersion.put ('InstallBase__c', lInstallbase[0].id);
        UtilityTestData.mFulfillmentVersion.put ('Supplied_Version__c', lVersion[0].id);
        Obj1 = UtilityTest.putFieldRecord(Obj1, UtilityTestData.mFulfillmentVersion);
        List<Fulfillment_Version__c> lFulfillmentVersion= ( List<Fulfillment_Version__c>) UtilityTest.makeInsert(new List<sObject>{obj1});

    }    
    
    
    
     static testMethod void testdownloadlinkapi(){
        
        Fulfillment__c FulfillmentRec= [Select id, name from fulfillment__c limit 1];
        String OrderNum = FulfillmentRec.name;
        
        //ARRANGE - setup request like the external system would....
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        req.requestURI = 'https://test.salesforce.com/services/apexrest/DownloadLinks/'+Ordernum;
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
        RestContext.response= res;
        
        
        //ACT - make the request from inside the test execution context, rather than from the external system
        Test.startTest();
        List<Versions__c> versionslst = downloadlinksAPI.getDownloadLink();
        Test.stopTest();
                 
        //System.assert( versionslst.size()>0);
        
        
    }
    
}