/*
* Name : helpInternalIdeaDetails
* Author : Deeksha Shetty
* Created Date :
* Description : Controller for internalIdeaDetailComponent LWC component.
Change History
*********************************************************************************************************************************************
Modified By      Date         Jira No.       Description                                                               Tag
Deepika BG    18-OCT-2023     I2RT-9274      Tech Debt: Remove "New" and "Active" values from New list of CR status    T1
*********************************************************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/


public without sharing class helpInternalIdeaDetails {
    
    @AuraEnabled(Cacheable=true)
    public static List<ideaWrapper> ideasDisplay(){
        try{            
            List<Idea> ideaDetail = [SELECT Id, Title,Upvote_Count__c,Categories,Body, Status,createdDate,lastModifiedDate,
                                     CreatorName FROM Idea where Categories EXCLUDES('Change Request') AND 
                                     Categories!='Change Request' AND Categories!=null AND Status!=null  
                                     ORDER BY createdDate DESC] ;
             List<ideaWrapper> ideawraplist = new List<ideaWrapper>();
            
            List<Id> allIds = new List<Id>();
            for(Idea idd:ideaDetail ){
                allIds.add(idd.Id);
            }
            
            List<Community_Interactions__c> upvotecountlist = [Select Id__c from Community_Interactions__c where Id__c IN:allIds 
                                                               AND Vote__c='Upvote'];
            
            Map<Id,List<Community_Interactions__c>> upvotecountforIdea = new Map<Id,List<Community_Interactions__c>>();
            
            for(Community_Interactions__c com: upvotecountlist){               
                if(!upvotecountforIdea.keyset().contains(com.Id__c)){
                    upvotecountforIdea.put(com.Id__c,new List<Community_Interactions__c>{com});
                }
                else{
                    upvotecountforIdea.get(com.Id__c).add(com);
                }
            }
            
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){
                    ideaWrapper wrap = new ideaWrapper();                                    
                    if(upvotecountforIdea.keyset().contains(item.Id)){
                        wrap.upvoteCount= upvotecountforIdea.get(item.Id).size();                        
                    }
                    else{
                        wrap.upvoteCount= 0;
                    }                    
                    wrap.Status = item.Status;
                    wrap.ideaId = item.Id;
                    wrap.Title = item.title;                    
                    wrap.Category = item.Categories;
                    DateTime dT = item.CreatedDate;
                    wrap.Body = item.Body.stripHtmlTags();
                    wrap.CreatedDate = dT.format('MM/dd/YYYY');
                    DateTime dT2 = item.lastModifiedDate;
                    wrap.LastModifiedDate = dT2.format('MM/dd/YYYY');
                    wrap.CreatorName = item.CreatorName;
                    wrap.URL = '/lightning/cmp/c__internalIdeasLandingWrapper?c__crecordId='+item.Id;
                    ideawraplist.add(wrap);
                }}
            
            return ideawraplist;
        }
        Catch(Exception e){
            system.debug('Error in Ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    
    @AuraEnabled(Cacheable=true)
    public static ideaWrapper ideadisplayOnId(String IdeaId){
        try{            
            List<Idea> ideaDetail = [SELECT Id, Title,Upvote_Count__c,Categories,Body, Status,createdDate,lastModifiedDate,
                                     CreatorName FROM Idea where Id=:IdeaId] ;
            List<String> categoryList = new List<String>();
                        
             ideaWrapper wrap = new ideaWrapper();
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){                                                        
                    if(item.Upvote_Count__c == null){wrap.upvoteCount=0;}
                    else{wrap.upvoteCount= item.Upvote_Count__c;}                    
                    wrap.Status = item.Status;
                    wrap.ideaId = item.Id;
                    wrap.Title = item.title;
                    if(item.Categories.contains(';')){
                        categoryList = item.Categories.split(';');
                    }
                    else{
                        categoryList.add(item.Categories);
                    }                    
                    wrap.CategoryList = categoryList;
                    wrap.Body = item.Body;
                    DateTime dT = item.CreatedDate;
                    wrap.CreatedDate = dT.format('MM/dd/YYYY');
                    DateTime dT2 = item.lastModifiedDate;
                    wrap.LastModifiedDate = dT2.format('MM/dd/YYYY');
                    wrap.CreatorName = item.CreatorName;
                }}
            
            return wrap;
        }
        Catch(Exception e){
            system.debug('Error in Ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    @AuraEnabled
    public static String ideadisplayPostEdit(String IdeaId,List<String> category,String Status, String title,String Descrip,Integer Upvote){
        try{            
            List<Idea> ideaDetail = [SELECT Id, Title,Upvote_Count__c,Categories,Body, Status,createdDate,lastModifiedDate,
                                     CreatorName FROM Idea where Id=:IdeaId];
             
            if(ideaDetail.size()>0){
                for(Idea item : ideaDetail){                                                        
                    if(item.Upvote_Count__c == null || Upvote==null ){item.Upvote_Count__c=0;}
                    else{item.Upvote_Count__c =Upvote ;}                    
                    item.Status = Status;
                    item.Id = IdeaId;
                    item.title = title;
                    if(category.size()>1){
                        item.Categories = string.join(category,';');
                    }
                    else{
                        item.Categories = category[0];
                    }                    
                    
                    item.Body = Descrip;
                    
                }}
            
            update ideaDetail;
            return 'Success';
        }
        Catch(Exception e){
            system.debug('Error in ideadisplayPostEdit : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
   
    
    
    @AuraEnabled
    public static string handleIdeaStatusChange(string status, String IdeaId){
        try{
            List<Idea> updatedIdea = [Select Id,Status From Idea Where Id =:IdeaId];
            if(updatedIdea.size()>0){
                updatedIdea[0].Status = status;
                update updatedIdea;
            }
            return 'Success';                        
        }
        Catch(Exception e){
            system.debug('Error in handleIdeaStatusChange : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    

    
    @AuraEnabled
    public static String createIdea(String title, List<string> category,string body){
        try{
            System.debug('body > ' + body);
            if( (title!=null || title!='' ) && category!=null && (body!=null || body!='') ){
                Idea id1 = new Idea();
                id1.Body = body;
                id1.Categories = String.join(category,';');
                id1.Title = title;
                id1.Status = 'Draft';
                id1.CommunityId = [Select Id From Community where Name='Informatica Network'].Id;
                insert id1;
                return id1.Id;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in idea creation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getCategoryPicklistValues(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = Idea.Categories.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> IdeaCategories = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
                if(objPickList.getLabel()!='Change Request')
                IdeaCategories.add(objPickList.getLabel());
				IdeaCategories.sort();                
            }
            return IdeaCategories;
            
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getStatusPicklistValues(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = Idea.Status.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> IdeaStatuses = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
                if(objPickList.getLabel()=='Draft' ||objPickList.getLabel()=='New' ||objPickList.getLabel()=='Active')
                IdeaStatuses.add(objPickList.getLabel());
                IdeaStatuses.sort();
            }
            return IdeaStatuses;
            
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getStatusPicklistValuesForCRs(){
        try{ //Tag 1 starts
            help_Infa_Custom_Label__mdt ideaStatus = help_Infa_Custom_Label__mdt.getInstance('helpIdea'); // T1

            Schema.DescribeFieldResult objFieldDescribe = Idea.Status.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> IdeaStatuses = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
                    
                if(!(ideaStatus.Idea_Status__c.contains(objPickList.getLabel()))) // T1
                {                
                IdeaStatuses.add(objPickList.getLabel());
                IdeaStatuses.sort();
                }
            }
            return IdeaStatuses;
            // Tag 1 ends
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getStatusPicklistValuesWithoutDraft(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = Idea.Status.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> IdeaStatuses = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                if(objPickList.getLabel()=='New'|| objPickList.getLabel()=='Active')
                IdeaStatuses.add(objPickList.getLabel());
                IdeaStatuses.sort();
            }
            return IdeaStatuses;
            
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getStatusValuesForFilter(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = Idea.Status.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> IdeaStatuses = new List<String>();
            IdeaStatuses.add('All');
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                if(objPickList.getLabel()=='Draft' || objPickList.getLabel()=='New' || objPickList.getLabel()=='Active' ){
                    IdeaStatuses.add(objPickList.getLabel());                   
                }                				             
            }                           
            return IdeaStatuses;
            
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
           
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static filterWrappers fetchFilterValues(){
        try{                                    
            List<String> categororiesList = getCategoryPicklistValues(); 
            List<String> statusList = getStatusPicklistValues();
			List<String> statusFilterList = getStatusValuesForFilter();            
            filterWrappers wrap = new filterWrappers();
            wrap.categoriesFilter = categororiesList;
            wrap.statusFilter = statusList;
			wrap.statusIdeasLanding = statusFilterList;
			wrap.statusWithNoDraft = getStatusPicklistValuesWithoutDraft();
            wrap.crStatuses = getStatusPicklistValuesForCRs();
            return wrap;            
        }
        Catch(Exception e){
            system.debug('Error in Fetch Filters : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static filterWrappers fetchFilterAfterTabSwitch(){
        try{                                    
            List<String> categororiesList = getCategoryPicklistValues(); 
            List<String> statusList = getStatusPicklistValues();
			List<String> statusFilterList = getStatusValuesForFilter();            
            filterWrappers wrap = new filterWrappers();
            wrap.categoriesFilter = categororiesList;
            wrap.statusFilter = statusList;
			wrap.statusIdeasLanding = statusFilterList;
			wrap.statusWithNoDraft = getStatusPicklistValuesWithoutDraft();        
            return wrap;            
        }
        Catch(Exception e){
            system.debug('Error in fetchFilterAfterTabSwitch : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSelectedIdea(String topicId){
        try{
            String topicselected;
            String topicName;
            if(topicId!=null){
                topicName = [SELECT Name FROM Topic where Id=:topicId].Name;
                System.debug('topicName='+topicName);
                List<String> topicsList = getCategoryPicklistValues();                
                for(String tpname : topicsList){
                    if(tpname ==topicName){
                        topicselected = tpname;
                        break;
                    }
                }
            
			
                if(topicselected==null){
                    List<Help_Community__mdt> parentCommunity = [SELECT ParentCommunity__c, SubCommunities__c FROM Help_Community__mdt];
                    for(String tpname : topicsList){                                               
                        for(Help_Community__mdt parentComm: parentCommunity){
                            List<String> subCommunities = parentComm.SubCommunities__c.toLowercase().split(';');
                            if(subCommunities.contains(topicName.toLowercase()) && parentComm.ParentCommunity__c.toLowercase()==tpname){                               
                                topicselected = tpname;                                
                            }
                        }
                    }                                        
                }
            }
            
            if(topicselected!=null) return topicselected;
            else return null;
            
            
            
        } catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }            
    }
    
    
    
    
    public class ideaWrapper{
        @AuraEnabled public String ideaId;
        @AuraEnabled public String Title;
        @AuraEnabled public String Body;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String LastModifiedDate;
        @AuraEnabled public String CreatorName;
        @AuraEnabled public String communityName;
        @AuraEnabled public String Category;
		@AuraEnabled public List<String> CategoryList;          
        @AuraEnabled public decimal upvoteCount;
        @AuraEnabled public String Status;
        @AuraEnabled public String URL;
    }
    
    public class filterWrappers{       
        @AuraEnabled public List<String> categoriesFilter;
        @AuraEnabled public List<String> statusFilter;
        @AuraEnabled public List<String> statusIdeasLanding;
        @AuraEnabled public List<String> statusWithNoDraft;
        @AuraEnabled public List<String> crStatuses;
    }
    
    
    
}