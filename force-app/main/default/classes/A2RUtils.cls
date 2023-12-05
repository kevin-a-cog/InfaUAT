/****************************************************************************************************************
Class:          A2RUtils
@Author:        vsabbell
@Created Date:  8/10/2018.
@Description:   Makes a chatter post for SMGHandoff and Updates Notification COunt. Also used as a wrapper to be used for Notify SMG Lightning Component.

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                             Tag
vsabbella           08/16/2018:                     Added Fieldset support to add fields to notificaton.
vsabbella            11/29                          Make Chatter post only once after sending email.Pb invokes this class
vsabbella            10/24:                         Disable chatter mentions                <T01>
vsabbella             12/05                         Trim fields with length > 250 chars
vsabbella .           04/2019                       Chatter post based on type of handoff(SMG,ASE etc.) 
Ambica              7/11/2019                       AR-927 added mention for chatterpost  <T02>
Ambica              10/9/2019                       AR-1000 Modified getmentionusers method to use chattergroup <T03>
Ambica              3/30/2020                       AR-1011 Modified getmentionusers method to use queue    <T04>
Ambica              3/30/2020                       AR-1096 Modified getchatterstring getmentionusers methods for engagement    <T05>
Venky K             5/4/2020                        AR-1034 To notify for new IPS project <T06>
*******************************************************************************************************************/

public with sharing class A2RUtils {
    
    private static final Integer MAX_CHATTER_POST_LENGTH=5000;
    private static final Integer MAX_CHATTER_FIELD_LENGTH=250;
    
    /*
* Util Method to make a chatter post using connect API for A2R
* Paramters: List<Id> for Related_Opportunity_Plan__c
*
* */
    public static boolean NotifyUsers(List<Id> oppPlanIds){
        return postFeedElementWithMention(oppPlanIds);
    }
    /*
* This method calls the ConnectAPI Helper to create chatter post with paramters mentions, SubjectId and Body content.
*
* */
    public static boolean postFeedElementWithMention(List<Id> recordIds){
        Boolean isPosted=false;
        String query = getQueryString(recordIds[0].getSobjectType());
        
        List<SObject> recordList =  Database.query(query+ ' Where Id In: recordIds');
        System.debug(LoggingLevel.ERROR, '-->'+JSON.serialize(recordList)); 
        
        //mentions =  returnMentionFormat(oppPlan.Opportunity__r.OwnerId);  <t01/>
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        try {
            if(!Test.isRunningTest()){
                //ConnectApi.FeedElement feedElement = ConnectApiHelper.postFeedItemWithRichText(null, oppPlanId, mentions + ChatterMessageString, '');
                for(Sobject sobj:recordList){
                    batchInputs.add(new ConnectApi.BatchInput(getChatterFeedItem(sobj)));
                }    
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
            }
            isPosted=true;
            
        }
        catch(Exception ex){
            isPosted=false;
            System.debug(LoggingLevel.ERROR,'Error Occured'+ex.getMessage()+Ex.getStackTraceString());
        }
        return isPosted;
    }
    
    public static ConnectApi.FeedItemInput getChatterFeedItem(Sobject sobj){
        String mentions='';
        
        mentions= mentions+ getMentionusers(sobj); //<T02>
        
        String ChatterMessageString=getChatterMessageString(sobj);
        if(String.isNotBlank(ChatterMessageString) && ChatterMessageString.length()>MAX_CHATTER_POST_LENGTH){ 
            ChatterMessageString = ChatterMessageString.substring(0,MAX_CHATTER_POST_LENGTH-50);
            ChatterMessageString += ' \\n' + Label.CSM_Chatter_Post_Max_Chars;
        }
        return getFeedItemInput((Id)sobj.get('Id'),ChatterMessageString +mentions); //<T02>
    }
    
    public static String getChatterMessageString(Sobject Sobj){
        
        String Objectname = Sobj.getSObjectType().getDescribe().getname();   
        
        String chatterMessageString= '\n  Handoff for \n\n';
        
        if( Objectname =='Related_Opportunity_Plan__c'){   
             
            Related_Opportunity_Plan__c rop =     (Related_Opportunity_Plan__c) Sobj;
            
            //---------------------<T06>
            if(rop.RecordType.DeveloperName == 'AdoptionServices') 
              chatterMessageString = 'New IPS Project created\n';
            Map<String,Schema.FieldSet> fsMap = Sobj.getSObjectType().getDescribe().fieldSets.getMap();
            
            for(Schema.FieldSetMember f : fsMap.get(rop.RecordType.DeveloperName).getFields()) {               
                chatterMessageString +=   getLabelAndValue(Sobj,f.getFieldPath()) ;
            }
        }
        //---------------------------------------<T05>
        if( Objectname =='Engagement__c'){        
            Engagement__c eng =     (Engagement__c)  Sobj;
            Map<String,Schema.FieldSet> fsMap = Sobj.getSObjectType().getDescribe().fieldSets.getMap();
            
            for(Schema.FieldSetMember f : fsMap.get(eng.RecordType.DeveloperName).getFields()) {
                chatterMessageString +=   getLabelAndValue(Sobj,f.getFieldPath()) ;
            }
        }
        //---------------------------------------</T05>
        
        
        
        return chatterMessageString;

    }
    
    //----------------------------------------<T02>
    //Method to fetch the sales consultant from renewal opportunity team
    public static String getMentionusers(Sobject Sobj){
        
        String mentions='';
        String Objectname = Sobj.getSObjectType().getDescribe().getname();   
        
        if( Objectname =='Related_Opportunity_Plan__c'){        
            
            Related_Opportunity_Plan__c rop = (Related_Opportunity_Plan__c) Sobj;
            
            //check if the recordtype is Presales 
            if(rop.RecordType.DeveloperName == Label.InterlockRecTypePresales){
                for (OpportunityTeamMember Otm : [Select id,UserId,TeamMemberRole from OpportunityTeamMember where TeamMemberRole =: Label.PresalesRole and OpportunityId=:rop.opportunity__c ]){
                    mentions=mentions+returnMentionFormat(otm.UserId);
                }
            }
            //-------------------------------------------------- <T03,T04>
            //check if the recordtype is CST
            else if(rop.RecordType.DeveloperName == Label.InterlockRecTypeCST){         
                /*
                for (CollaborationGroupMember cgm : [SELECT CollaborationGroupId, CollaborationGroup.name,Id,MemberId,Member.name FROM CollaborationGroupMember WHERE CollaborationGroup.name =: Label.CST_Chattergroup]){
                mentions=mentions+returnMentionFormat(cgm.MemberId);
                }
                */
                Group CSTGroup =  [Select Id from Group where type='Queue' and Name=: Label.INFA_CST_Queue] ;
                for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =: CSTGroup.id]) {
                    mentions=mentions+returnMentionFormat(gm.UserOrGroupId);
                }
            }
            //--------------------------------------------------</T03, /T04>
            
        }
        //--------------------------------------------------<T05>
        if( Objectname =='Engagement__c'){         
            Engagement__c eng =     (Engagement__c)  Sobj;
            if(eng.RecordType.DeveloperName == Label.EngagementRecTypeDigitalCSM){         
                Group CSMGroup =  [Select Id from Group where type='Queue' and Name=: Label.INFADigitalCSMQueue] ;
                for (GroupMember gm: [Select UserOrGroupId From GroupMember where GroupId =: CSMGroup.id]) {
                    mentions=mentions+returnMentionFormat(gm.UserOrGroupId);
                }
            }
        }
        //--------------------------------------------------</T05>
        return mentions ;
    }
    //---------------------------------------</T02>
    
    //---------------------------------------<T01>
    public static String returnMentionFormat(Id userId){
        return '{'+userId+'} ';
    }
    //---------------------------------------</T01>
    
    /*
* Util method to get the value from Sobject from parent relation.
* Eg: Plan__r.Business_Case__c.
*     Get the Business_Case__c field value from parent Plan.
*
* */
    public static String getLabelAndValue(Sobject Sobj, String fieldPath ){
        
        SObjectField  field;
        String fieldLabel;
        String str;
        
        if(fieldPath.contains('.')){
            List<String> reltionHierarchy = fieldPath.split('\\.');
            fieldPath = reltionHierarchy[reltionHierarchy.size()-1];
            reltionHierarchy.remove(reltionHierarchy.size()-1);
            for(String objectStr : reltionHierarchy){
                Sobj = Sobj.getSObject(objectStr);
            }
        }
        
        
        if (Sobj!=null){          
            field= Sobj.getSObjectType().getDescribe().fields.getMap().get(fieldPath);
            fieldLabel = field.getDescribe().getLabel();
            str = ''+ fieldLabel+':\n';
            Object obj = Sobj.get(field);
            if(obj instanceof Date || obj instanceof DateTime ){
                str += date.valueOf(obj).format();
            }
            else if(obj instanceof String){
                str += TrimString(''+Sobj.get(field));
            }
            else {
                str +=''+Sobj.get(field);
            }
            Str = str +'\n\n';
        }
        return ( (sobj!=null && Sobj.get(field)!=null)?str:'');
    }
    
    private static String TrimString(String str)
    {
        return ((str.length() >MAX_CHATTER_FIELD_LENGTH) ? (str.substring(0, MAX_CHATTER_FIELD_LENGTH)+'....') : (str));
    } 
    
    
    
    private static String getQueryString(SobjectType sobjType){
        String query = 'SELECT ';
        Set<String> fields = new Set<String>();
        Map<String,Schema.FieldSet> fieldSetMap = sobjType.getDescribe().fieldSets.getMap();
        for(String feildSetName: fieldSetMap.keySet()){
            Schema.FieldSet fs = fieldSetMap.get(feildSetName);
            for(Schema.FieldSetMember f : fs.getFields()) {
                fields.add(f.getFieldPath());
            }
        }
        fields.addAll(new List<String>{'Id','Name','RecordType.DeveloperName'});
        query+= String.join(new List<String>(fields),',');
        
        query += ' FROM '+sobjType.getDescribe().getName();
        
        return query;
    }
    
    public static ConnectApi.FeedItemInput getFeedItemInput(Id SubjectId, String body){
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = SubjectId;                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();                
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();                                
        messageBodyInput.messageSegments = ConnectApiHelper.getMessageSegmentInputs(body);
        input.body = messageBodyInput;
        return input;
    }
    
    public static ConnectApi.BatchInput[] getChatterFeed(Map<Id,String> feedContent){
        List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();
        for(Id subjectId: feedContent.keySet()){
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(getFeedItemInput(subjectId,feedContent.get(subjectId)));
            //String body = ;
            batchInputList.add(batchInput);
        }
        return batchInputList;
    }
    
}