public with sharing class HelpHotfixController {

    @AuraEnabled
    public static List<Download__c> getDownloads(String filters, String searchKey, String sortBy, String releaseType, String limitSize){
        System.debug('filterMap ||  ' + filters);
        Map<String,Object> filterMap = (Map<String,Object>)JSON.deserializeUntyped(filters);
        String query = 'Select Id,Name,Html_Description__c,Product__c, Release_Notes_URL__c,Download_Url__c,Other_Downloads__c From Download__c ';
        String productFilter = ' Product__c in (replaceProduct) ' ;
        String searchFilter = ' Name like \'%' + searchKey +'%\' ' ;
        String osFilter = ' Operating_System__c in (replaceOS) ';
        String processorFilter = ' Processor__c in (replaceProcessor) ';
        String releaseFilter = ' Release_Type__c = \'' + releaseType + '\' ';
        String orderBy = ' order by CreatedDate ' + sortBy;
        String productFilterConditions = '';
        String osFilterConditions = '';
        String processorFilterConditions = '';
        String limitQuerySize = ' LIMIT ' + ((limitSize == '0') ? '9 ' : limitSize);
        System.debug('filterMap ||  ' + filterMap);
        System.debug('filterMap || operatingSystem || ' + filterMap.get('operatingSystem'));
        System.debug('filterMap || processor || ' + filterMap.get('processor'));
        List<Object> productFilterLst = (List<Object>) filterMap.get('product') != null ? (List<Object>) filterMap.get('product') : new List<Object>();
        List<Object> osFilterLst = (List<Object>) filterMap.get('operatingSystem') != null ? (List<Object>) filterMap.get('operatingSystem') : new List<Object>();
        List<Object> processorFilterLst = (List<Object>) filterMap.get('processor') != null ? (List<Object>) filterMap.get('processor') : new List<Object>();
        for(Object product: productFilterLst){
            productFilterConditions+= '\''+product +'\',';
        }
        if(productFilterConditions != ''){
            productFilter = productFilter.replace('replaceProduct', productFilterConditions.substring(0,productFilterConditions.length()-1));
        }
        for(Object os: osFilterLst){
            osFilterConditions+= '\''+os +'\',';
        }
        if(osFilterConditions != ''){
            osFilter = osFilter.replace('replaceOS', osFilterConditions.substring(0,osFilterConditions.length()-1));
        }
        for(Object processor: processorFilterLst){
            processorFilterConditions+= '\''+processor +'\',';
        }
        if(processorFilterConditions != ''){
            processorFilter = processorFilter.replace('replaceProcessor', processorFilterConditions.substring(0,processorFilterConditions.length()-1));
        }

        String fullQuery = query +  ' Where ' +  releaseFilter;
        if(productFilterLst.size() > 0 ){
            fullQuery += ' and ' + productFilter;
        }
        if(osFilterLst.size() > 0){
            fullQuery += ' and ' + osFilter;
        }
        if(processorFilterLst.size() > 0){
            fullQuery += ' and ' + processorFilter;
        } 
        if(searchKey != null && searchKey!= ''){
            fullQuery += ' and ' + searchFilter;
        }
        fullQuery += orderBy;
        fullQuery += limitQuerySize;
        System.debug('fullQuery : ' + fullQuery);
        DownloadController dCtrl = new DownloadController();
        // List<Download__c> downloadLst = [Select Id,Name,Html_Description__c,Release_Notes_URL__c,Download_Url__c,Other_Downloads__c From Download__c];
        return dCtrl.getDownloads(fullQuery);
    }

    @AuraEnabled
    public static help_Infa_Custom_Label__mdt getMetadataRecordFromCustomLabel(String metadataName){
        String recordIdToReturn = '';
        metadataName = String.escapeSingleQuotes(metadataName);
        if(!String.isEmpty(metadataName)){
            help_Infa_Custom_Label__mdt help_meta = help_Infa_Custom_Label__mdt.getInstance(metadataName);
            return help_meta;
        }
        return null;
    }

    without sharing class DownloadController{
        public List<Download__c> getDownloads(String fullQuery){
            List<Download__c> downloadLst = (List<Download__c>)Database.query(fullQuery);
            return downloadLst;
        }
    }

    
}