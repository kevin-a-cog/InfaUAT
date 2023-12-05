@isTest
public class CoveoKBSearchTest {
    
    @testSetup
    static void initializeData(){
        
        // insert Knowledge Record
        Knowledge__kav knwRec = new Knowledge__kav();
        knwRec.Title = 'Article One';
        knwRec.UrlName = '00000001';
        knwRec.Solution__c='Simple solution';
        knwRec.Additional_Information__c = 'Test Information provided';
        knwRec.Keywords__c ='Article';
        knwRec.Expiration_Date__c = system.today().addDays(-3);
        knwRec.Primary_Product__c = 'Active VOS';
        knwRec.Product_Version__c = '9.2.4';
        knwRec.Product_Component__c = 'ActiveVOS Console';
        knwRec.Visible_In_Public_Knowledge_Base__c = true;
        insert knwRec;
        
        // insert custom settings
        AthenaSearch__c settings = new AthenaSearch__c();
        settings.CoveoEndPoint__c='https://platform.cloud.coveo.com';
        settings.CoveoOrgName__c='informaticasandbox';
        settings.CoveoSearchHubKBSearchPublic__c='AthenaKBSearchPublic';
        settings.CoveoPipelineKBSearchPublic__c='Customers';
        settings.PublicFilterExpression__c='@infaviewpermissions=public';
        settings.CoveoSearchHubKBSearchInternal__c='AthenaKBSearchInternal';
        settings.CoveoPipelineKBSearchInternal__c='Support Engineers';
        settings.InternalFilterExpression__c='@infaviewpermissions=(internal,public)';
        settings.CoveoSearchTokenGenAPIKey__c = 'abcd-efgh-ijkl';
        settings.SetupOwnerId=UserInfo.getOrganizationId();
        insert settings;
        
        AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
        system.debug('searchSettings'+searchSettings);
        
    }
    @isTest
    static void getSimilarArticlesTest1(){
       String numberOfArticles = '3';
        Knowledge__kav knwRec = [Select Id from Knowledge__kav where Title = 'Article One' Limit 1];
        Test.startTest();  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new KBMockHttpResponseGenerator());
        
        String searchToken = CoveoKBSearch.getSearchToken();  
        system.debug('value of searchToken'+searchToken);
         Map<String, Object> completeJson = (Map<String, Object>)JSON.deserializeUntyped(searchToken);
        system.debug('token jus'+json.deserializeUntyped(searchToken));
        String apiSearchToken = String.valueOf(completeJson.get('APISearchToken'));
        system.debug('token  '+apiSearchToken);
        String similarArticleResult = CoveoKBSearch.getSimilararticles(apiSearchToken, knwRec.Id, numberOfArticles, 'Internal');
        system.debug('similarArticleResult'+similarArticleResult);
        CoveoKBSearch.APISearchDataResponse resWrapper = (CoveoKBSearch.APISearchDataResponse)System.JSON.deserialize(similarArticleResult,CoveoKBSearch.APISearchDataResponse.class);
        system.debug('resWrapper'+resWrapper);
        system.debug('resWrapper searchResultList'+resWrapper.searchDataList);
        Test.stopTest();
        system.assertEquals(numberOfArticles, String.valueOf(resWrapper.searchDataList.size()));
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0]);
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0].title);
        system.assertEquals('Test Article 1', resWrapper.searchDataList[0].title);
        system.assertEquals('000111507', resWrapper.searchDataList[1].infadocid);
        system.assertEquals('html', resWrapper.searchDataList[2].sysfiletype);
    }
    @isTest
    static void getSimilarArticlesTest2(){
       String numberOfArticles = '3';
        Test.startTest();  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new KBMockHttpResponseGenerator());
        
        String searchToken = CoveoKBSearch.getSearchToken();  
        system.debug('value of searchToken'+searchToken);
         Map<String, Object> completeJson = (Map<String, Object>)JSON.deserializeUntyped(searchToken);
        system.debug('token jus'+json.deserializeUntyped(searchToken));
        String apiSearchToken = String.valueOf(completeJson.get('APISearchToken'));
        system.debug('token  '+apiSearchToken);
        String similarArticleResult = CoveoKBSearch.getSimilararticles(apiSearchToken, null, numberOfArticles, 'Internal');
        system.debug('similarArticleResult'+similarArticleResult);
        CoveoKBSearch.APISearchDataResponse resWrapper = (CoveoKBSearch.APISearchDataResponse)System.JSON.deserialize(similarArticleResult,CoveoKBSearch.APISearchDataResponse.class);
        system.debug('resWrapper'+resWrapper); 
        system.debug('resWrapper searchResultList'+resWrapper.searchDataList);
        Test.stopTest();
        system.assertEquals(numberOfArticles, String.valueOf(resWrapper.searchDataList.size()));
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0]);
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0].title);
        system.assertEquals('Test Article 1', resWrapper.searchDataList[0].title);
        system.assertEquals('000111507', resWrapper.searchDataList[1].infadocid);
        system.assertEquals('html', resWrapper.searchDataList[2].sysfiletype);
    }
    @isTest
    static void getSimilarArticlesTest3(){
       String numberOfArticles = '3';
        Knowledge__kav knwRec = [Select Id from Knowledge__kav where Title = 'Article One' Limit 1];
        Test.startTest();  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new KBMockHttpResponseGenerator());
        
        String searchToken = CoveoKBSearch.getSearchToken();  
        system.debug('value of searchToken'+searchToken);
         Map<String, Object> completeJson = (Map<String, Object>)JSON.deserializeUntyped(searchToken);
        system.debug('token jus'+json.deserializeUntyped(searchToken));
        String apiSearchToken = String.valueOf(completeJson.get('APISearchToken'));
        system.debug('token  '+apiSearchToken);
        String similarArticleResult = CoveoKBSearch.getSimilararticles(apiSearchToken, knwRec.Id, numberOfArticles, 'External');
        system.debug('similarArticleResult'+similarArticleResult);
        CoveoKBSearch.APISearchDataResponse resWrapper = (CoveoKBSearch.APISearchDataResponse)System.JSON.deserialize(similarArticleResult,CoveoKBSearch.APISearchDataResponse.class);
        system.debug('resWrapper'+resWrapper);
        system.debug('resWrapper searchResultList'+resWrapper.searchDataList);
        Test.stopTest();
        system.assertEquals(numberOfArticles, String.valueOf(resWrapper.searchDataList.size()));
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0]);
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0].title);
        system.assertEquals('Test Article 1', resWrapper.searchDataList[0].title);
        system.assertEquals('000111507', resWrapper.searchDataList[1].infadocid);
        system.assertEquals('html', resWrapper.searchDataList[2].sysfiletype);
    }

    @isTest
    static void getArticleDetailsTest1(){
       String numberOfArticles = '3';
        Knowledge__kav knwRec = [Select Id from Knowledge__kav where Title = 'Article One' Limit 1];
        Test.startTest();  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new KBMockHttpResponseGenerator());
        
        String searchToken = CoveoKBSearch.getSearchToken();  
        system.debug('value of searchToken'+searchToken);
         Map<String, Object> completeJson = (Map<String, Object>)JSON.deserializeUntyped(searchToken);
        system.debug('token jus'+json.deserializeUntyped(searchToken));
        String apiSearchToken = String.valueOf(completeJson.get('APISearchToken'));
        system.debug('token  '+apiSearchToken);
        String similarArticleResult = CoveoKBSearch.getArticleDetails(apiSearchToken, knwRec.Id, numberOfArticles, 'Internal');
        system.debug('similarArticleResult'+similarArticleResult);
        CoveoKBSearch.APISearchDataResponse resWrapper = (CoveoKBSearch.APISearchDataResponse)System.JSON.deserialize(similarArticleResult,CoveoKBSearch.APISearchDataResponse.class);
        system.debug('resWrapper'+resWrapper);
        system.debug('resWrapper searchResultList'+resWrapper.searchDataList);
        Test.stopTest();
        system.assertEquals(numberOfArticles, String.valueOf(resWrapper.searchDataList.size()));
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0]);
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0].title);
        system.assertEquals('Test Article 1', resWrapper.searchDataList[0].title);
        system.assertEquals('000111507', resWrapper.searchDataList[1].infadocid);
        system.assertEquals('html', resWrapper.searchDataList[2].sysfiletype);
    }

    @isTest
    static void getArticleDetailsTest2(){
       String numberOfArticles = '3';
        Knowledge__kav knwRec = [Select Id from Knowledge__kav where Title = 'Article One' Limit 1];
        Test.startTest();  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new KBMockHttpResponseGenerator());
        
        String searchToken = CoveoKBSearch.getSearchToken();  
        system.debug('value of searchToken'+searchToken);
         Map<String, Object> completeJson = (Map<String, Object>)JSON.deserializeUntyped(searchToken);
        system.debug('token jus'+json.deserializeUntyped(searchToken));
        String apiSearchToken = String.valueOf(completeJson.get('APISearchToken'));
        system.debug('token  '+apiSearchToken);
        String similarArticleResult = CoveoKBSearch.getArticleDetails(apiSearchToken, knwRec.Id, numberOfArticles, 'External');
        system.debug('similarArticleResult'+similarArticleResult);
        CoveoKBSearch.APISearchDataResponse resWrapper = (CoveoKBSearch.APISearchDataResponse)System.JSON.deserialize(similarArticleResult,CoveoKBSearch.APISearchDataResponse.class);
        system.debug('resWrapper'+resWrapper);
        system.debug('resWrapper searchResultList'+resWrapper.searchDataList);
        Test.stopTest();
        system.assertEquals(numberOfArticles, String.valueOf(resWrapper.searchDataList.size()));
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0]);
        system.debug('searchDataList[0]'+resWrapper.searchDataList[0].title);
        system.assertEquals('Test Article 1', resWrapper.searchDataList[0].title);
        system.assertEquals('000111507', resWrapper.searchDataList[1].infadocid);
        system.assertEquals('html', resWrapper.searchDataList[2].sysfiletype);
    }

    
}