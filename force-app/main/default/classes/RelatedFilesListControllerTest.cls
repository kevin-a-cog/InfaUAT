@isTest
public class RelatedFilesListControllerTest {
    
    @testSetup
    private static void testDataSetup(){
    
        
        Knowledge__kav article = new Knowledge__kav();
        article.URLName = String.valueof(Integer.valueof((Math.random() * 10)));
        article.Title= 'Article From Test Class';
        insert article;
       
        //create ContentVersion  record 
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;  
        
        //Fetching ContentDocument records.
        List<ContentDocument> listContentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
         //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = article.id;
        cdl.ContentDocumentId = listContentDocuments[0].Id;
        cdl.shareType = 'V';
        insert cdl;        
    }
    
    @isTest
    private static void testGetRelatedFileOfKBArticle(){
        Knowledge__kav article = [SELECT id,Title from Knowledge__kav WHERE Title= 'Article From Test Class'];
        RelatedFilesListController.getRelatedFileOfKBArticle(article.Id);
    }   
}