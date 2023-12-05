/*
    @created by       : Pavithra V
    @created on       : 09/03/2021
    @Purpose          : Controller class for GCS QueueAssignment LWC
    @Testclass        : GCSQueueAssignmentControllerTest
    @JIRA             : I2RT-1394
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */

public with sharing class GCSQueueAssignmentController{
    
    @AuraEnabled
    public static PicklistValWrapper getGCSTeam() {
        PicklistValWrapper pvwrap = new PicklistValWrapper();
        
        /** GCS Team Picklist Value**/
        for(Schema.PicklistEntry entry  : User.GCS_Team__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.gcsTeamPicklistValList.add(picklistVal);
        }
        
        /** Queue Member Picklist Value **/
        for(QueueSobject qSobj  : [Select Id, Queue.Name from QueueSobject where SobjectType = 'Case']){
            String picklistVal = qSobj.Queue.Name + ';;'+ qSobj.Queue.Name;
            pvwrap.queueMemberPicklistValList.add(picklistVal);
        }
        
        /** Products Picklist Value **/
        for(Schema.PicklistEntry entry  : Case.Forecast_Product__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.productsPicklistValList.add(picklistVal);
        }
        
        /** Component Picklist Value **/
        for(Schema.PicklistEntry entry  : Case.Component__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.componentsPicklistValList.add(picklistVal);
        }
        
        /** Success Offering Picklist Value**/
        for(Schema.PicklistEntry entry  : Entitlement.Support_Level__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.succOfferingPicklistValList.add(picklistVal);
        }
        
        /** Region Picklist Value **/
        for(Schema.PicklistEntry entry  : Custom_Notification_Filter__c.Filter_Regions__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.regionPicklistValList.add(picklistVal);
        }
        
        /** Priority Picklist Value **/
        for(Schema.PicklistEntry entry  : Custom_Notification_Filter__c.Filter_Priority__c.getDescribe().getPicklistValues()){
            String picklistVal = entry.getLabel() + ';;'+ entry.getValue();
            pvwrap.priorityPicklistValList.add(picklistVal);
        }
        
        /** Time Zone Picklist Value **/
        for(TimeZone__c tzone  :[Select Id, Name from TimeZone__c]){
            String picklistVal = tzone.Name + ';;'+ tzone.Name;
            pvwrap.timeZonePicklistValList.add(picklistVal);
        }
        
        return pvwrap;
    }
    
    @AuraEnabled
    public static void deleteSelectedFilter(String filterId){
        Custom_Notification_Filter__c filter = new Custom_Notification_Filter__c();
        filter.Id = filterId;
        Delete filter;
    }
    
    @AuraEnabled
    public static Custom_Notification_Filter__c editSelectedFilter(String filterId){
        Custom_Notification_Filter__c filter = [Select Id, User__c, GCS_Team__c, Queue_Membership__c, Filter_Priority__c, Filter_Product_Lines__c, Filter_Products__c, Filter_Regions__c, Filter_Support_Levels__c, Filter_Timezone__c from Custom_Notification_Filter__c where Id=:filterId order by CreatedDate asc];
    	return filter;
    }
    
    @AuraEnabled
    public static void cloneSelectedFilter(String filterId){
        Custom_Notification_Filter__c filter = [Select Id, User__c, GCS_Team__c, Queue_Membership__c, Filter_Priority__c, Filter_Product_Lines__c, Filter_Products__c, Filter_Regions__c, Filter_Support_Levels__c, Filter_Timezone__c from Custom_Notification_Filter__c where Id=:filterId order by CreatedDate asc];
    	Custom_Notification_Filter__c clonedUsr = filter.clone(False, True, False, False);
        Insert clonedUsr;
    }
    
    @AuraEnabled
    public static void saveFilterCriteria(Custom_Notification_Filter__c filterCriteria){
        Custom_Notification_Filter__c filter = filterCriteria;
        upsert filter;
    }

    @AuraEnabled
    public static List<FilterWrapper> retrieveUserDetails(String selectedUserId, String selectedGCSTeam) {
        List<FilterWrapper> filterWrappers= new List<FilterWrapper>();
        List<Custom_Notification_Filter__c> customNotifilterList = new List<Custom_Notification_Filter__c>();
        
        if(selectedUserId <> null){
            customNotifilterList = [Select Id, User__c, GCS_Team__c, Queue_Membership__c, Filter_Priority__c, Filter_Product_Lines__c, Filter_Products__c, Filter_Regions__c, Filter_Support_Levels__c, Filter_Timezone__c from Custom_Notification_Filter__c where User__c=: selectedUserId order by CreatedDate asc];
            if(customNotifilterList.size() > 0){
                for(Custom_Notification_Filter__c uf : customNotifilterList){
                    FilterWrapper FW = new FilterWrapper();
                    FW.filterText = composeFilterText(uf);
                    FW.usrFilter = uf;
                    FW.usrFilterId = uf.Id;
                    filterWrappers.add(FW);
                }
            }
        }else if(selectedGCSTeam <> null){
            customNotifilterList = [Select Id, User__c, GCS_Team__c, Queue_Membership__c, Filter_Priority__c, Filter_Product_Lines__c, Filter_Products__c, Filter_Regions__c, Filter_Support_Levels__c, Filter_Timezone__c from Custom_Notification_Filter__c where GCS_Team__c =: selectedGCSTeam  order by CreatedDate asc];
            if(customNotifilterList.size() > 0){
                for(Custom_Notification_Filter__c uf : customNotifilterList){
                    FilterWrapper FW = new FilterWrapper();
                    FW.filterText = composeFilterText(uf);
                    FW.usrFilter = uf;
                    FW.usrFilterId = uf.Id;
                    filterWrappers.add(FW);
                    System.debug('FW.usrFilterId : '+ FW.usrFilterId);
                    System.debug('FW.usrFilter : '+ FW.usrFilter);
                }
            }
        }
        System.debug('filterWrappers : '+ filterWrappers);
		
        return filterWrappers;
    }

    public static String composeFilterText(Custom_Notification_Filter__c userFilter){
        String filterMessage = 'All Cases Which Belong To ';
        filterMessage += '<b>('+userFilter.Queue_Membership__c?.replace(';', ' OR ')+')</b> Queue AND HAS ';
        if(userFilter.Filter_Product_Lines__c == null || userFilter.Filter_Product_Lines__c == ''){
            filterMessage += '<b>ANY</b> Product AND '; 
        }else{
            filterMessage += '<b>('+userFilter.Filter_Product_Lines__c.replace(';', ' OR ')+')</b> Product AND ';
        }
        filterMessage = filterMessage.replace(' OR )',')');
        //.removeEnd(' OR ');
        if(userFilter.Filter_Products__c == null || userFilter.Filter_Products__c == ''){
            filterMessage += '<b>ANY</b> Component AND '; 
        }else{
            filterMessage += '<b>('+userFilter.Filter_Products__c.replace(';', ' OR ')+')</b> Component AND ';
        }            
        filterMessage = filterMessage.replace(' OR )',')');
        //----------------------------------------------------------------<T02>
        if(userFilter.Filter_Support_Levels__c == null || userFilter.Filter_Support_Levels__c == ''){
            filterMessage += '<b>ANY</b> Success Offering AND '; 
        }else{                
            filterMessage += '<b>('+userFilter.Filter_Support_Levels__c.replace(';', ' OR ')+')</b> Success Offering AND ';
        }
        //----------------------------------------------------------------</T02>
        filterMessage = filterMessage.replace(' OR )',')');
        if(userFilter.Filter_Regions__c == null || userFilter.Filter_Regions__c == ''){
            filterMessage += '<b>ANY</b> Region AND '; 
        }else{
            filterMessage += '<b>('+userFilter.Filter_Regions__c.replace(';', ' OR ')+')</b> Region AND ';
        }
        filterMessage = filterMessage.replace(' OR )',')');
        if(userFilter.Filter_Priority__c == null || userFilter.Filter_Priority__c == ''){
            filterMessage += '<b>ANY</b> Priority AND '; 
        }else{
            filterMessage += '<b>('+userFilter.Filter_Priority__c.replace(';', ' OR ')+')</b> Priority AND ';
        }
        filterMessage = filterMessage.replace(' OR )',')');
        if(userFilter.Filter_Timezone__c == null || userFilter.Filter_Timezone__c == ''){
            filterMessage += '<b>ANY</b> Timezone '; 
        }else{
            filterMessage += '<b>('+userFilter.Filter_Timezone__c.replace(';', ' OR ')+')</b> Timezone ';
        }
        filterMessage = filterMessage.replace(' OR )',')');
        return filterMessage;
    }

    public Class FilterWrapper{
        @AuraEnabled
        Public String filterText {get; set;}
        @AuraEnabled
        Public Custom_Notification_Filter__c usrFilter {get; set;}
        @AuraEnabled
        Public String usrFilterId {get; set;}
    }
    
    public Class PicklistValWrapper{
        @AuraEnabled
        Public List<String> gcsTeamPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> queueMemberPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> productsPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> componentsPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> succOfferingPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> regionPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> priorityPicklistValList {get; set;}
        
        @AuraEnabled
        Public List<String> timeZonePicklistValList {get; set;}
        
        public PicklistValWrapper(){
            gcsTeamPicklistValList = new List<String>();
            queueMemberPicklistValList = new List<String>();
            productsPicklistValList = new List<String>();
            componentsPicklistValList = new List<String>();
            succOfferingPicklistValList = new List<String>();
            regionPicklistValList = new List<String>();
            priorityPicklistValList = new List<String>();
            timeZonePicklistValList = new List<String>();
        }
        
    }
}