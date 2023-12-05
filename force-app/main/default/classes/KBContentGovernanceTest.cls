/**
* @description       :
* @author            : Sathish Rajalingam
* @group             :
* @last modified on  : 09-06-2021
* @last modified by  : SF Developer
* Modifications Log
* Ver   Date         Author               Modification
* 1.0   02-08-2021   Sathish Rajalingam   Initial Version

****************************************************************************************************
|  Tag    |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|   1     |  08-Apr-2021      |   Sathish R               |    I2RT-       |  
****************************************************************************************************


**/
@isTest
public with sharing class KBContentGovernanceTest {
    @testSetup
    private static void initializeData(){
          
          
          Profile intProfile = [select id from profile where name = 'System Administrator'];
          
          User KBMigUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationuserkbcg@informatica.com',
			Alias = 'kbmig',
			Email='kbmigrationuserkbcg@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Migration User',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBMigUser;
          
          System.runAs(KBMigUser){
                
                
                //Integer noOfDays =  Integer.valueOf(Label.KB_Archive_Expired_Article_in_Days)+1;
                Knowledge__kav knwRec = new Knowledge__kav();
                knwRec.Title = 'Article One';
                knwRec.UrlName = '00000001';
                knwRec.Expiration_Date__c = system.today().addDays(30);
                knwRec.Primary_Product__c = 'Active VOS';
                knwRec.Product_Version__c = '9.2.4';
                knwRec.Product_Component__c = 'ActiveVOS Console';
                knwRec.Solution__c = '50.112.49.143';
                knwRec.Description__c = '50.112.49.143';
                knwRec.Additional_Information__c = '50.112.49.143';
                knwRec.Keywords__c = '50.112.49.143';
                

                knwRec.Visible_In_Public_Knowledge_Base__c = true;
                
                                                
                List<Knowledge__kav> kbRecList = new List<Knowledge__kav>();
                kbRecList.add(knwRec);              
                
                insert kbRecList;
                                                
          }
          
    }

    @isTest
      static void getArticleGDPRComplianceTest(){
                        
            List<sObject> scope = [SELECT Id, Solution__c,Title,UrlName,Additional_Information__c,Keywords__c,Description__c FROM Knowledge__kav WHERE UrlName = '00000001' LIMIT 1];
                      
            Test.startTest();
            
            KBContentGovernance.getArticleGDPRCompliance(scope[0].Id);

            KBContentGovernance.getArticleGDPRComplianceInitial('Test Article One','Test Article One','Test Article One','Test Article One','Test Article One','FAQ','NONE','PowerCenter');
            
            Test.stopTest();
            
      }
}