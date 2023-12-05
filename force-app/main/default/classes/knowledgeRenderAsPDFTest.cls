@isTest
public class knowledgeRenderAsPDFTest {

	@testSetup
	static void initializeData(){
		Knowledge__kav knwRec = new Knowledge__kav();
		knwRec.Title = 'Article One';
		knwRec.UrlName = '00000001';
		knwRec.Expiration_Date__c = system.today().addDays(-3);
		knwRec.Primary_Product__c = 'Active VOS';
		knwRec.Product_Version__c = '9.2.4';
		knwRec.Product_Component__c = 'ActiveVOS Console';
		knwRec.Visible_In_Public_Knowledge_Base__c = true;
		insert knwRec;
	}
	@isTest
	static void knowledgeRenderAsPDFTest(){
		Knowledge__kav knwRec = [Select Id,UrlName,Language,KnowledgeArticleId from Knowledge__kav];

		String fileName = 'KB_' + knwRec.UrlName + '.pdf';
		String contentDisposition = 'attachment; filename=' + fileName;

		PageReference pageRef = Page.KnowledgeRenderPDF;
		Test.setCurrentPage(pageRef);
		Test.StartTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(knwRec);
		ApexPages.currentPage().getParameters().put('Id',knwRec.KnowledgeArticleId);
		ApexPages.currentPage().getParameters().put('Language',knwRec.Language);
		knowledgeRenderAsPDF obj = new knowledgeRenderAsPDF(sc);
		Test.StopTest();
		Map<String,String> getHeaders = Apexpages.currentPage().getHeaders();
		String contentType = getHeaders.get('content-disposition');
		system.assertEquals(contentDisposition, getHeaders.get('content-disposition'));

	}
}