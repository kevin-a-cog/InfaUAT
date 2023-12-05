@isTest
public class helpCoveoArticlesControllerTest {
    
    @IsTest(SeeAllData=true)
    static void testmethod3(){
        test.startTest();
        try{
			Test.setMock(HttpCalloutMock.class, new helpCoveoArticleCalloutMock());            
            helpCoveoArticlesController.getDetails('token');                     
         
        }
        Catch(Exception ex){}
        test.stopTest();
    }

}