/*
*****************************************************************************************************************
Class:          DownloadLinksApi
@Author:        Apyati
@Created Date:  8/7/2019.
@Description:   F2A-22 Api Class used by ESD to retrive downlond links for order fulfillment
******************************************************************************************************************
Change History
*******************************************************************************************************************
        ModifiedBy          Date        Requested By        Description                                         Tag
        Ambica Pyati       10/15/2019                       Updated query to pull fulfillment
															versions from active fullments only

********************************************************************************************************************
*/


@RestResource(urlMapping='/DownloadLinks/*')
global without sharing class DownloadLinksApi{

    @HttpGet
    global static List<Versions__c> getDownloadLink() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //Gget the ordernumber from api request
        String OrderNum = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        //Qurey fulfillment versions
        List<Versions__c> result =[SELECT Install_Base__c,InstallBase_Name__c,Name,(SELECT Name,URL__c FROM Download_Link__r) FROM Versions__c 
                                   				where Id in (SELECT Supplied_Version__c FROM Fulfillment_Version__c  
                                                             	where Fullfillment_Line__r.Fullfillment__r.Active__c=true 
                                                             		AND (Order__r.OrderNumber=:OrderNum OR Fullfillment_Line__r.Fullfillment__r.name =:OrderNum)) order by InstallBase_Name__c ];
        return result;

    }
    
}