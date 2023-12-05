/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to Engagement Object
    @Testclass        : 
    @JIRA             : 
    
Change History
******************************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
******************************************************************************************************************
Ashik       11/03/2022  I2RT-5490   T01     Commented the block that adds Escalation managers as user 
                                                mentions from Escalation_Manager Queue to chatter post.
balajip     28-03-21    I2RT-5811   T02     To fix the STRING_TOO_LONG exception on creating Collaboration request 
                                                for Esclation via email
balajip     07/13/2022  I2RT-6153   T03     To replace GCS_Segment__c field with Segment__c field in the notifications
******************************************************************************************************************

 */
public without sharing class EngagementService {

    public static final String RECORD_TYPE_NAME_SUPPORT_ESCALATION = 'Support Escalation';
    
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_CLOSED = 'Closed';

    public static final Set<String> setStatusOpen = new Set<String>{'New', 'Verified', 'Active Engaged', 'Wait', 'Analysis'};

    public EngagementService() {

    }
    
    public static Id getRecordTypeId(String recordTypeName){
        Schema.DescribeSObjectResult engagementSchema = Schema.SObjectType.Engagement__c;
        return engagementSchema.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();       
    }

    public static Engagement__c create(Id recordTypeId, Id accId, Id ownerId, String title, String priority, String severity, String source, String category,String detail,String contact){
        Engagement__c engagement = new Engagement__c();
        Account acc = [Select Id, Name, ParentId from Account where Id = :accId];

        //T02 - trim the value to 80 characters before setting the Name field value
        String engName = 'ENG:' + acc.Name;
        engagement.Name = engName.left(80);
        engagement.Support_Account__c = accId;
        engagement.Account__c = acc.ParentId;
        engagement.RecordTypeId = recordTypeId;

        engagement.Title__c = title;
        engagement.Detail__c = detail;
        engagement.Source__c = source;
        engagement.Priority__c = String.isEmpty(priority) ? 'P2' : priority;
        engagement.Category__c = String.isEmpty(category) ? 'Escalation' : category;
        engagement.Severity__c = severity;

        if(ownerId!=null){
            engagement.ownerId = ownerId;
        }

        if(String.isNotEmpty(contact)){
            engagement.Primary_Escalation_Contact__c = contact;
        }

        return engagement;
    }

    public static Engagement__c createSupportEscalation(Id accId, String title, String priority, String severity, String source, String category,String detail,String contact){
        Id recordTypeId = getRecordTypeId(RECORD_TYPE_NAME_SUPPORT_ESCALATION);
        Id ownerId = SkillService.mapQueueNameToQueueId.get(SkillService.getSkillByName(SkillService.SKILL_ESCALATION_MANAGER).Queue_Name__c);
        Engagement__c engagement = create(recordTypeId, accId, ownerId, title, priority, severity, source, category,detail, contact);
        return engagement;
    }

    public static Engagement__c createSupportEscalation(Id accId){
        Engagement__c engagement = createSupportEscalation(accId, '', '', '', '', '','','');
        return engagement;
    }

    public static Engagement__c getSupportEngagement(Id accountId){
        Engagement__c engagement = createSupportEscalation(accountId);
        insert engagement;
        return engagement;
    }
    
    public static ConnectApi.FeedItemInput notifyCaseTeam(Case cse, Engagement__c engagement, String activity){
        //I2RT-4916 - check if the Product is selected on the Case
        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }
        
        String content = 'Escalation: ' + productContent + cse.Priority 
                                + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name 
                                + ', ' + cse.Support_Level__c;
                                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Escalation Number', engagement.Engagement_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Activity', activity));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Owner / Team', cse.Owner_Name__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Summary', engagement.Title__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Severity', engagement.Severity__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Product', cse.Forecast_Product__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Version', cse.Version__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Number', cse.Support_Account__r.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Support Account Name', cse.Support_Account__r.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Name', cse.Account.Name));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Success Offering', cse.Support_Level__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Customer Segmentation', cse.Segment__c)); //T03
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('ACC Flag', String.valueOf(cse.Acc__c)));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('GCS PAL', System.Label.Cassini_Account + cse.Account.New_Org_Account_Number__c));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Link: '));
        messageBodyInput.messageSegments.add(ChatterService.inputHyperlink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        Set<Id> setUserIdToPost = CaseTeamService.getCaseSubscribers(cse.Id, true, true, true, true);
        
        for(Id userId : setUserIdToPost){
            messageBodyInput.messageSegments.add(ChatterService.inputSpace());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(userId));    
        }

        /*ProfileSkill profileSkill = SkillService.getSkillByName('Escalation Manager');
        if(profileSkill != null){
            if(SkillService.mapCollabGroupNameToGroup.containsKey(profileSkill.Chatter_Group_Name__c)){
                CollaborationGroup collabGroup = SkillService.mapCollabGroupNameToGroup.get(profileSkill.Chatter_Group_Name__c);
                messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
                messageBodyInput.messageSegments.add(ChatterService.inputSpace());
                messageBodyInput.messageSegments.add(ChatterService.inputMention(collabGroup.Id));
            }
        }*/
        /*<T1> begin
        try{
            for(Id escalationUserId : SkillService.setEscalationUserId){
                messageBodyInput.messageSegments.add(ChatterService.inputSpace());
                messageBodyInput.messageSegments.add(ChatterService.inputMention(escalationUserId));
            }    
        }catch(Exception ex){
            System.debug('Exception while trying to mention the users from Escalation Managers Queue' + ex.getMessage());
        }</T1> end*/

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = cse.Id;
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        return feedItemInput;
    }

    public static void updateLastActivity(Set<Id> setEngagementId){
        List<Engagement__c> lstEngagementToUpdate = new List<Engagement__c>();
        lstEngagementToUpdate = [Select Id, Last_Activity__c
                                    From Engagement__c 
                                    Where RecordType.Name = :RECORD_TYPE_NAME_SUPPORT_ESCALATION 
                                        And Id in :setEngagementId];
        for(Engagement__c eng : lstEngagementToUpdate){
            eng.Last_Activity__c = System.now();
        }
        if(!lstEngagementToUpdate.isEmpty()){
            update lstEngagementToUpdate;
        }
    }
    
}