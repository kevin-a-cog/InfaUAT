/*
Class:          viewDownloadLinksController 
@Author:        Chandana Gowda
@Created Date:  10/30/2019
@Description:   Controller class for viewDownloadLinks Lighting component
                This class is used to query the Active fulfillment associated with the order and
                its related fulfillment Line ,Versions and download Links
    
Change History
*************************************************************************************************************************************
*************************************************************************************************************************************
*/
public with sharing class viewDownloadLinksController {
    
    /*Method to get the data to be displayed in the table.
    * @param fullFillmentId
    * @throws exception -n/a
    * @return List<Map<String,String>>
    */ 
    @AuraEnabled
    public static List<Map<String,String>> getData(Id fullFillmentId){
        List<Map<String,String>> data= new List<Map<String,String>>();
        Map<Id,List<Id>> mapFflineVersion = new Map<Id,List<Id>>();
        Map<Id,List<Id>> mapVerDwnldLink = new Map<Id,List<Id>>();
        Map<Id,String> versionIds= new Map<Id,String>();
        List<Download_Link__c> lstDownloadLink = new List<Download_Link__c>();
        Integer count=0;

        Map<Id,Fulfillment_Line__c> mapFulfillmentLine=new Map<Id,Fulfillment_Line__c>([SELECT Id,Name FROM Fulfillment_Line__c WHERE Fullfillment__c IN (SELECT Id FROM Fulfillment__c WHERE Id =: fullFillmentId)]);
                
        Map<Id,Fulfillment_Version__c> mapFulfillmentVersion=new Map<Id,Fulfillment_Version__c>([SELECT Id,Supplied_Version__c,Supplied_Version__r.InstallBase_Name__c,Fullfillment_Line__c,Fullfillment_Line__r.Name FROM Fulfillment_Version__c WHERE Fullfillment_Line__c IN :mapFulfillmentLine.keySet()]);
        
        //Creating a map of Fulfillment Line to Version
        for(Fulfillment_Version__c ver:mapFulfillmentVersion.values()){
            versionIds.put(ver.Supplied_Version__c,ver.Supplied_Version__r.InstallBase_Name__c);            
            if(!mapFflineVersion.containsKey(ver.Fullfillment_Line__c))
                mapFflineVersion.put(ver.Fullfillment_Line__c,new List<String>{ver.Supplied_Version__c});
            else {
                List<Id> lstVersions=mapFflineVersion.get(ver.Fullfillment_Line__c);
                lstVersions.add(ver.Supplied_Version__c);
                mapFflineVersion.put(ver.Fullfillment_Line__c,lstVersions);
            }
        }

        //Creating a map of versions to associated download Links
        Map<Id,Download_Link__c> mapDownloadLink=new Map<Id,Download_Link__c>([SELECT Id,Name,Version__c,Version__r.Name,URL__c FROM Download_Link__c WHERE Version__c IN :versionIds.keySet()]);
        for(Download_Link__c dwnldLnk:mapDownloadLink.values()){
            if(!mapVerDwnldLink.containsKey(dwnldLnk.Version__c))
                mapVerDwnldLink.put(dwnldLnk.Version__c,new List<String>{dwnldLnk.Id});
            else {
                List<Id> lstdwnldLnk=mapVerDwnldLink.get(dwnldLnk.Version__c);
                lstdwnldLnk.add(dwnldLnk.Id);
                mapVerDwnldLink.put(dwnldLnk.Version__c,lstdwnldLnk);
            }
        }

        //Formating the data as required by the lightnin:datatable
        for(Id ffLineId:mapFulfillmentLine.keySet()){
            List<Id> lstVersions= mapFflineVersion.get(ffLineId);
            if(lstVersions!=null){
                for(Id versionId:lstVersions){
                    List<Id> lstdwnldLnk = mapVerDwnldLink.get(versionId);
                    for(Id dwnldLnk:lstdwnldLnk){
                        Map<String,String> row= new Map<String,String>();
                        row.put('Download_Link__c',mapDownloadLink.get(dwnldLnk).URL__c);
                        row.put('InstallBase_Name__c',versionIds.get(versionId));                        
                        row.put('Version__c',mapDownloadLink.get(dwnldLnk).Version__r.Name);
                        row.put('Fullfillment_Line__c',mapFulfillmentLine.get(ffLineId).Name);
                        row.put('Id',String.valueOf(count++));
                        data.add(row);
                    }
                }
            }
        }
        System.debug(data);
        return data;
    }
}

/*
viewDownloadLinksController.getData('a3d540000001TLsAAM');
*/