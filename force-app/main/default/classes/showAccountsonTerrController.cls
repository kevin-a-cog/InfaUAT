/*
Class:          showAccountsonTerrController
@Author:        Wasim Akram
@Created Date:  29/6/2021
@Description:   SALESRT-12995 : Controller class for showAccountsonTerr vf page - To open Report in new Tab

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description 
******************************************************************
*/
public class showAccountsonTerrController {
    public Id terrId {get;set;}
    public String url {get;set;}
    public String terrUrl {get;set;}
    @TestVisible
    static boolean isLightningTheme = (UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4u'); 
    public showAccountsonTerrController(ApexPages.StandardController stdController) {
        terrId = Apexpages.currentpage().getparameters().get('Id');
        String button = Apexpages.currentpage().getparameters().get('buttonName');
        
        List<Territory2> terrObj = [SELECT Name FROM Territory2 WHERE Id = :terrId LIMIT 1];
        List<Report> reportList = new List<Report>();
        
        String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
        baseUrl = baseUrl.replace('my.salesforce', 'lightning.force');
        if(button == 'Accounts'){
            reportList = [SELECT Id FROM Report WHERE name ='Territories with accounts' LIMIT 1];
            if(reportList.size() > 0){
                if(isLightningTheme){
                	url = baseUrl + '/lightning/r/Report/'+reportList[0].Id+'/view?fv0='+terrObj[0].Name;
                }
                else{
                    url = baseUrl +'/'+ reportList[0].Id+'?pv0='+terrObj[0].Name;
                }                    
            }
        }
        else if(button == 'Opportunities'){
            reportList = [SELECT Id,Name FROM Report WHERE name ='Territories with Opportunities' LIMIT 1];
            if(reportList.size() > 0 && terrObj.size() > 0){
                if(isLightningTheme){
                	url = baseUrl + '/lightning/r/Report/'+reportList[0].Id+'/view?fv0='+terrObj[0].Name;
                }
                else{
                    url = baseUrl +'/'+ reportList[0].Id+'?pv0='+terrObj[0].Name;
                }
            }
        }	
        if(isLightningTheme){
        	terrUrl = baseUrl + '/lightning/setup/Territory2Models/page?address=%2F'+terrId+'%3Fsetupid%3DTerritory2Models';
    	}
        else{
            terrUrl = baseUrl + '/'+terrId;
        }
    }
}