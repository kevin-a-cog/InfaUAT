/*
   @created by       : Sathish Rajalingam
   @created on       : 20/01/2022
   @Purpose          : KBLWCHandler test class.
   @Testclass        :
   @JIRA             :


   Change History

 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 ****************************************************************************************************

 */
@isTest
public with sharing class KBLWCHandlerTest {




	@isTest
	public static void testOther(){

		Profile intProfile = [select id from profile where name = 'System Administrator'];

		User KBMigUser = new User(
			ProfileId = intProfile.Id,
			Username = 'kbmigrationuser@informatica.com',
			Alias = 'kbmig',
			Email='kbmigrationuser@informatica.com',
			EmailEncodingKey='UTF-8',
			Firstname='KB',
			Lastname='Migration User Test',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			TimeZoneSidKey='America/Chicago',
			UserPermissionsKnowledgeUser = true);
		insert KBMigUser;

		System.runAs(KBMigUser){

			Knowledge__kav kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle One';
			kavMocData.UrlName = '0100001';
			kavMocData.Migrated_Article_Id__c = '0100001';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;

			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle two';
			kavMocData.UrlName = '0100002';
			kavMocData.Migrated_Article_Id__c = '0100002';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;


			kavMocData = new Knowledge__kav();
			kavMocData.Title = 'Test Article Artcle Three';
			kavMocData.UrlName = '0100003';
			kavMocData.Migrated_Article_Id__c = '0100003';
			kavMocData.Primary_Product__c = 'PowerCenter';
			kavMocData.Migrated_PublishStatus__c = 'Approved';
			kavMocData.ValidationStatus= 'Published';
			insert kavMocData;
			
		}
								
	}
	
}