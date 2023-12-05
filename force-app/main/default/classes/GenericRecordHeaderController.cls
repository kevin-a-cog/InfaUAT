/*
    @Created Date:  April 2022
    @Description:   This is the Controller for the generic record header component. This Apex Controller fetches and builds the
    data based on metadata name configuration.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                         Tag

    Saurabh Khandelwal    04-Apr-2022                   Initial create and fetches data based on metadata config.            <T1>
    ********************************************************************************************************************************************
*/
public with sharing class GenericRecordHeaderController {
    
    /*
     * method fetchRecordConfig
     * @param recordId: Id of the object record from which LWC was called from.
     * @param customMetadataConfigName: name of the metadata configuration.
     * @description: Query out record data based on metadata config and set data in wrapper to show on UI.
     */
    @AuraEnabled
    public static Map<String,Object> fetchRecordConfig(Id recordId,String customMetadataConfigName){

        Map<String,Object>resultMap= new Map<String,Object>();
        
        try{
            
            DataWrapper wrapper= new DataWrapper();
            Schema.DescribeSObjectResult sObjectResult=recordId.getSObjectType().getDescribe();
            String objectName=sObjectResult.getName();
            wrapper.objectName=sObjectResult.getLabel();
            List<Record_Header_Configuration__mdt>recordConfig = [SELECT MasterLabel,Enable_Follow_Button__c,Field_Labels__c,Field_Names__c,Show_List_Header__c,
                                                                  List_Header_URL__c,List_Header__c,Object_Icon__c FROM Record_Header_Configuration__mdt
                                                                  WHERE MasterLabel=:customMetadataConfigName];
            //checking if metadata config exists.
            if(recordConfig.size()>0){
                wrapper.showFollowButton=recordConfig[0].Enable_Follow_Button__c;
                //setting property for record header.
                wrapper.recordHeader=new RecordHeader(recordConfig[0].List_Header__c,recordConfig[0].List_Header_URL__c,recordConfig[0].Show_List_Header__c);
                wrapper.objectIcon= recordConfig[0].Object_Icon__c;
                if(wrapper.showFollowButton){
                    List<EntitySubscription> entitysubscription = [SELECT Id FROM EntitySubscription WHERE parentId =: recordId AND subscriberId =: UserInfo.getUserId() LIMIT 1];
                    if(entitysubscription.size()>0){
                        wrapper.isRecordFollowed=true;
                    }
                    else{
                        wrapper.isRecordFollowed=false;
                    }
                }

                String query='SELECT ';
                if(String.isNotBlank(recordConfig[0].Field_Names__c)){
                    if(recordConfig[0].Field_Names__c.split(',').indexOf('Name')==-1){
                        query+='Name,' ;
                    }
                    query+=recordConfig[0].Field_Names__c;
                    query+=' FROM '+objectName+' WHERE Id=:recordId';
                    system.debug('query'+query);
                    List<sObject>data=Database.query(query);
                    List<FieldsWrapper>fieldsList=new List<FieldsWrapper>();
                    List<String>fieldLabels=recordConfig[0].Field_Labels__c.split(',');
                    List<String>fieldNames=recordConfig[0].Field_Names__c.split(',');
                    for(Integer i=0;i<fieldNames.size();i++){
    
                        fieldsList.add(new FieldsWrapper(fieldLabels[i],(Object)data[0].get(fieldNames[i])));
                    }
                    wrapper.recordName=(String)data[0].get('Name');
                    wrapper.fieldsList=fieldsList;
                }
                resultMap.put('Status','Success');
                resultMap.put('Data',JSON.serialize(wrapper));
                
            }else{
                //no metadata record found
                resultMap.put('Status','Error');
                resultMap.put('Message','No Custom Metadata configuration found');
            }      
            return resultMap;
        }
        catch(Exception e){
            resultMap.put('Status','Error');
            resultMap.put('Message',e.getMessage());
            return resultMap;
        }                                                     
    }
    
    /*
     * method followRecord
     * @param recordId: Id of the object record from which LWC was called from.
     * @param isFollow: indicate to follow/unfollow record.
     * @description: This method is used to Follow/UnFollow record.
     */
    @AuraEnabled
    public static Map<String,Object> followRecord(Id recordId,Boolean isFollow) {
        Map<String,Object>resultMap= new Map<String,Object>();
        try{
            //fetching object name.
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            Id loggedInUserId=UserInfo.getUserId();
            Set<Id>recordIds= new Set<Id>{recordId};
            if(sObjName=='Estimation_Summary__c'){
                //fetching est outputs.
                Map<Id,Estimation_Output__c>estOutMap= new Map<Id,Estimation_Output__c>([SELECT Id FROM Estimation_Output__c WHERE 
                                                                                        Estimation_Summary__c=:recordId]);
                recordIds.addAll(estOutMap.keySet());
            }
            //setting data
            Set<String>setRecordUserIds=new Set<String>();
            for(Id recId : recordIds){
                setRecordUserIds.add(recId+'-'+loggedInUserId);
            }

            if(isFollow){
                EstimatorCollaboratorTriggerHandler.followRecords(setRecordUserIds);
            }
            else if(!isFollow){
                EstimatorCollaboratorTriggerHandler.unfollowRecords(setRecordUserIds);
            }

            resultMap.put('Status','Success');
            return resultMap;
        }
        catch(Exception except){
        system.debug('Error->'+except.getMessage());
        resultMap.put('Status','Error');
        resultMap.put('Message',except.getMessage());
        return resultMap;
     }
    }
  
    //wrapper class for sending result.
    public class DataWrapper{
        @AuraEnabled
        public String objectName {get;set;}
        @AuraEnabled
        public String objectIcon {get;set;}
        @AuraEnabled
        public String recordName {get;set;}
        @AuraEnabled
        public Boolean isRecordFollowed {get;set;}
        @AuraEnabled
        public Boolean showFollowButton {get;set;}
        @AuraEnabled
        public List<FieldsWrapper> fieldsList {get;set;}
        @AuraEnabled
        public RecordHeader recordHeader {get;set;}
    }
    public class FieldsWrapper{
        @AuraEnabled
        public String fieldLabel {get;set;}
        @AuraEnabled
        public Object fieldValue {get;set;}
        @AuraEnabled
        public Boolean isNumeric {get;set;}

        public FieldsWrapper(String fieldLabel, Object fieldValue){
            this.fieldLabel=fieldLabel;
            this.fieldValue=fieldValue;
            if(String.valueOf(fieldValue).isNumeric()){
                this.isNumeric=true;
            }
        }
    }
    public class RecordHeader{
        @AuraEnabled
        public String headerName {get;set;}
        @AuraEnabled
        public String headerURL {get;set;}
        @AuraEnabled
        public Boolean showHeader {get;set;}

        public RecordHeader(String headerName, String headerURL, Boolean showHeader){
            this.headerName=headerName;
            this.headerURL=headerURL;
            this.showHeader=showHeader;
        }
    }

}