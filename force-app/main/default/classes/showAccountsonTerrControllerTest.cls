/*
Class:          showAccountsonTerrControllerTest
@Author:        Wasim Akram
@Created Date:  29/6/2021
@Description:   Test Class for showAccountsonTerrController class

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description 
******************************************************************
*/
@IsTest
public class showAccountsonTerrControllerTest {
    
    // Test method for Accounts
    @isTest(SeeAllData=true)
    private static void checkAccounts(){
        Territory2Model terrModel = new Territory2Model(name='INFA',DeveloperName = 'INFA');
        insert terrModel;
        Territory2Type terrType   = [SELECT Id, DeveloperName FROM Territory2Type LIMIT 1];
        Territory2 terr = new Territory2();
        if(terrType != NULL){
            terr.name='EMEA South';
            terr.Territory2ModelId = terrModel.Id; 
            terr.DeveloperName = 'EMEA_South';
            terr.Territory2TypeId = terrType.Id;
            insert terr;
        }   
        List<Territory2> terrList = [SELECT Id FROM Territory2 LIMIT 1];   
        if(terrList.size() > 0){
            Test.StartTest(); 
            PageReference pageRef = Page.showAccountsonTerr;
            pageRef.getParameters().put('Id', String.valueOf(terrList[0].Id));
            pageRef.getParameters().put('buttonName', 'Accounts');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(terrList[0]); 
            showAccountsonTerrController.isLightningTheme = false;
            showAccountsonTerrController controllerClass = new showAccountsonTerrController(sc);   
            Test.StopTest();  
        }
    }
    
    // Test method for Opportunities
    @isTest(SeeAllData=true)
    private static void checkOpportunities(){
        Territory2Model terrModel = new Territory2Model(name='INFA',DeveloperName = 'INFA');
        insert terrModel;
        Territory2Type terrType   = [SELECT Id, DeveloperName FROM Territory2Type LIMIT 1];
        Territory2 terr = new Territory2();
        if(terrType != NULL){
            terr.name='EMEA South';
            terr.Territory2ModelId = terrModel.Id; 
            terr.DeveloperName = 'EMEA_South';
            terr.Territory2TypeId = terrType.Id;
            insert terr;
        }   
        List<Territory2> terrList = [SELECT Id,Name FROM Territory2 LIMIT 1];
        if(terrList.size() > 0){
            Test.StartTest(); 
            PageReference pageRef = Page.showAccountsonTerr;
            pageRef.getParameters().put('Id', String.valueOf(terrList[0].Id));
            pageRef.getParameters().put('buttonName', 'Opportunities');
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(terrList[0]);
            showAccountsonTerrController.isLightningTheme = true;
            showAccountsonTerrController controllerClass = new showAccountsonTerrController(sc);
            Test.StopTest(); 
        }
    }
}