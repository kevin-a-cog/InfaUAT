/*
    @Created Date:  March 2022
    @Description:   This is the Controller for the generic list view LWC. This Apex Controller fetches and builds the
    list view Data based on custom metadata configuration.This class is covered by IPUE_CustomListViewCntlrTest.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                 Tag
    Saurabh Khandelwal    10-Mar-2022   IPUE-160        Fetched list view data as per metadata config.              <T1>
    ********************************************************************************************************************************************
*/

public class IPUE_CustomListViewCntlr {
    
    /*
     * method getWrapperOfSObjectFieldColumnActionValues
     * @param metaDataName: name of the custom metadata record.
     * @param isLoadMore: boolean to indicate whether it is called for load more.
     * @param query: query to be executed if its called from loadmore.
     * @description: Query the custom metadata record and create data for the generic list view and also added load
     *               more functionality logic.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getWrapperOfSObjectFieldColumnActionValues(String metaDataName , Boolean isLoadMore, String query, String recordId)
    {
        Map<String,object>resultMap = new Map<String,Object>();
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();

        if(!isLoadMore)
        {

            Custom_List_View__mdt listViewMetaData= [SELECT Id, DeveloperName, Object_Name__c, Field_Value__c, Column_JSON__c, 
                                                    Filter_Fields__c,Filter_Conditions__c,Filter_Values__c,
                                                    Table_Title__c, Limit__c,Object_Icon__c,Table_Header_BackGround_Color__c,
                                                    Hide_Header__c,Table_Header_Text_Color__c FROM Custom_List_View__mdt 
                                                    WHERE Label =:String.escapeSingleQuotes(metaDataName)];

            List<DataTableColumns> dataTableList =new List<DataTableColumns>();
            if(listViewMetaData.Column_JSON__c!=null){
                dataTableList = (List<DataTableColumns>)JSON.deserialize(listViewMetaData.Column_JSON__c, List<DataTableColumns>.class);
            }
        
            String fieldsNameToQuery='';
            
            if(listViewMetaData.Field_Value__c!=null){
                
                List<String>fieldsList=listViewMetaData.Field_Value__c.split(',');
                for(String str : fieldsList)
                {
                    fieldsNameToQuery+=str+','; 
                }   
            }
       
            String queryString='SELECT ';
            if(fieldsNameToQuery!=''){
                queryString+=String.escapeSingleQuotes(fieldsNameToQuery);
            }
            queryString+='Id FROM '+String.escapeSingleQuotes(listViewMetaData.Object_Name__c);
            
            if(listViewMetaData.Filter_Fields__c!=null){
                String whereClause='';
                String []filterfields=listViewMetaData.Filter_Fields__c.split(',');
                String []filterCondition=listViewMetaData.Filter_Conditions__c.split(',');
                String []filterValues=listViewMetaData.Filter_Values__c.split(',');

                for(integer i=0;i<filterfields.size();i++){
                    whereClause+=String.escapeSingleQuotes(filterfields[i])+String.escapeSingleQuotes(filterCondition[i]);

                    if(filterValues[i].contains('\'')){
                        whereClause+= '\'' + String.escapeSingleQuotes(filterValues[i]) + '\'';
                    }else{
                        whereClause+=String.escapeSingleQuotes(filterValues[i]);
                    }
                    
                    if(i!=filterfields.size()-1){
                        whereClause+=' AND ';
                    }            
                }
                queryString+=' WHERE '+whereClause;
            }
            
            //if limit is null then setting default limit of 20.
            Integer queryLimit=listViewMetaData.Limit__c!=null ? Integer.valueOf(listViewMetaData.Limit__c) : 20;
            queryString+=' LIMIT '+String.escapeSingleQuotes(String.valueOf(queryLimit));

            resultMap.put('Query',queryString);
            queryString+=' OFFSET 0';
           SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, Database.query(queryString));
           // List<sObject>dataList=securityDecision.getRemovedFields().get(listViewMetaData.Object_Name__c);
            for(SObject SObjectItem :  securityDecision.getRecords())
            {
                lstDataTableData.add(SObjectItem);
            }

            DataTableResponse finalWrapper   = new DataTableResponse();
            finalWrapper.tableTitle          = listViewMetaData.Table_Title__c;
            finalWrapper.queryLimit          = queryLimit;
            finalWrapper.tableHeaderBackgroundColor = listViewMetaData.Table_Header_BackGround_Color__c ;
            finalWrapper.tableHeaderTextColor = listViewMetaData.Table_Header_Text_Color__c;
            finalWrapper.tableIcon          = listViewMetaData.Object_Icon__c !=null ? listViewMetaData.Object_Icon__c : 'custom:custom7';
            finalWrapper.lstDataTableColumns = dataTableList;
            finalWrapper.hideHeader = listViewMetaData.Hide_Header__c;
            finalWrapper.lstDataTableData    = lstDataTableData;
            resultMap.put('DataTableWrapper',finalWrapper);
        }
        else{
            //when user has load more
            resultMap.put('dataList',Database.query(query));
        }
        
        return resultMap;
    }

   //wrapper class for deserializing datatable column json. 
   public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public TypeAttributes typeAttributes {get;set;}
        @AuraEnabled
        public CellAttributes cellAttributes {get;set;}
       
        @AuraEnabled
        public Boolean sortable {get;set;}

        public DataTableColumns(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;          
        }
    }

    public class TypeAttributes{    
        @AuraEnabled
        public String target {get;set;} 
        @AuraEnabled
        public Label label {get;set;}
    }

    public class CellAttributes{    
        @AuraEnabled
        public String alignment {get;set;} 
    } 

    public class Label{
        @AuraEnabled
        public String fieldName {get;set;}
    }

    //wrapper class for sending result. 
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
        @AuraEnabled
        public String tableTitle {get;set;}  
        @AuraEnabled
        public String tableIcon {get;set;} 
        @AuraEnabled
        public String tableHeaderBackgroundColor {get;set;} 
        @AuraEnabled
        public String tableHeaderTextColor{get;set;} 
        @AuraEnabled
        public Integer queryLimit {get;set;} 
        @AuraEnabled
        public Boolean hideHeader {get;set;}
    }
}