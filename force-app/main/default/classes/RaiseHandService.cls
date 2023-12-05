/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to RaiseHand Object
    @Testclass        : 
    @JIRA             : 
    
Change History
**********************************************************************************************************************************
ModifiedBy          Date        Jira No.        Description                                                             Tag
**********************************************************************************************************************************
Deva M             27-07-21     Utopia phase2   Modified the logic to merge standard 
                                                    case team logic to custom case team logic      
Venky K            05-08-21     Utopia          One feeditem for collab with all subsequent updates as feedcomment      T01
balajip            28-03-21     I2RT-5811       To fix the STRING_TOO_LONG exception on creating Collaboration request 
                                                    for Esclation via email                                             T02
balajip            07/13/2022   I2RT-6153       To replace GCS_Segment__c field with Segment__c field in the 
                                                    notifications                                                       T03
balajip            10/27/2022   I2RT-6955       To post a comment instead of updating the Post when a Get Help request 
                                                    is converted to Co-own                                              T04
Isha Bansal         02/22/2023  I2RT-7258       Need to have a join a customer meeting option for Product specialists   T05
Shashikanth         08/17/2023  I2RT-8610       When I assign a CoOwn to some one else, the main case still             T06
                                                shows I accepted the co own
*/
public without sharing class RaiseHandService {
    public enum RaiseHandEvent {ON_OPEN, ON_ASSIGNMENT}

    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_CLOSED = 'Closed';

    public static final String TYPE_GET_HELP = 'Get Help';
    public static final String TYPE_CO_OWN = 'Co-own';
    public static final String TYPE_CUSTOMER_MEETING = 'Join a Customer Meeting';
    public static final String TYPE_REPRO_ENV_SETUP = 'Repro Environment Setup';
    public static final String TYPE_MANAGE_ESCALATION = 'Manage Escalation';

    public static final String SUBTYPE_PSREVIEW = 'PS Review';
    public static final String SUBTYPE_MULTIPRODUCT = 'Multi Product';
    public static final String SUBTYPE_OPERATIONS = 'Operations';
    public static final String SUBTYPE_SUPPORTENGINEER = 'Support Engineer'; //T05
    
    public static final String HTML_PARA_START = '<p>';
    public static final String HTML_PARA_END = '</p>';

    public static List<Raise_Hand_Skill_Mapping__mdt> lstRaiseHandSkillMapping = new List<Raise_Hand_Skill_Mapping__mdt>();

    static{
        lstRaiseHandSkillMapping = [Select Raise_Hand_Type__c, Raise_Hand_Subtype__c, Skill_Type__c, Is_Skill_Product_Specific__c 
                                        From Raise_Hand_Skill_Mapping__mdt
                                        Where IsActive__c = true];
    }

    public RaiseHandService() {

    }

    private static String htmlParagraph(String content){
        return HTML_PARA_START + content + HTML_PARA_END;
    }

    public static string constructCaseCommentpublic(Raise_Hand__c raiseHand){ 
        return constructCaseComment(raiseHand, RaiseHandEvent.ON_OPEN, null);           //<T06>
    }
    
    private static String constructCaseComment(Raise_Hand__c raiseHand, RaiseHandEvent raiseHandEvent, String acceptedByUserName){      ////<T06>
        String caseComment;

        caseComment = htmlParagraph('Title: '+raiseHand.Title__c);
        caseComment += htmlParagraph('Description: '+raiseHand.Description__c);
        if(SUBTYPE_OPERATIONS.equals(raiseHand.Subtype__c)) {
            caseComment += htmlParagraph(raiseHand.Type__c + ' - ' + raiseHand.Subtype__c);
        }else{
            caseComment += htmlParagraph(raiseHand.Type__c + ' - ' + raiseHand.Product__c);
        }
        caseComment += htmlParagraph('Status: ' + raiseHand.Status__c);

        if(TYPE_GET_HELP.equals(raiseHand.Type__c)) {
            caseComment += htmlParagraph('Product: ' + raiseHand.Product__c);
            caseComment += htmlParagraph('Question: ' + raiseHand.Question__c);
        }else if(TYPE_CO_OWN.equals(raiseHand.Type__c)) {
            caseComment += htmlParagraph('Collaborate with: ' + raiseHand.Subtype__c);
            if(!SUBTYPE_OPERATIONS.equals(raiseHand.Subtype__c)) {
                caseComment += htmlParagraph('Product: ' + raiseHand.Product__c);
            }
        }else if(TYPE_CUSTOMER_MEETING.equals(raiseHand.Type__c)) {
            caseComment += htmlParagraph('Product: ' + raiseHand.Product__c);
            caseComment += htmlParagraph('Time: ' + raiseHand.Meeting_Time__c);                
        }else if(TYPE_REPRO_ENV_SETUP.equals(raiseHand.Type__c)) {
            caseComment += htmlParagraph('Product: ' + raiseHand.Product__c);
            String description = '';
            if(String.isNotEmpty(raiseHand.Description__c)){
                description = raiseHand.Description__c;
                description = description.stripHtmlTags();
            }
            caseComment += htmlParagraph('Description: ' + description);                
        }
        
        if(raiseHandEvent == RaiseHandService.RaiseHandEvent.ON_ASSIGNMENT)
        {
            //<T06>
            String reqAssignedToName = '';
            if(String.isNotEmpty(acceptedByUserName))
            {
                reqAssignedToName = acceptedByUserName;
            }
            else if(raiseHand.Owner != null && String.isNotBlank(raiseHand.Owner.Name))
            {
                reqAssignedToName = raiseHand.Owner.Name;
            }
            
            if(String.isNotBlank(reqAssignedToName))
            {
                caseComment += htmlParagraph('Request is assigned to ' + reqAssignedToName);
            }
            //</T06>
        }

        return caseComment;
    }

    public static List<String> getSkills(String type, String subtype, String productName){
        List<String> lstSkill = new List<String>();
        for(Raise_Hand_Skill_Mapping__mdt mapping : lstRaiseHandSkillMapping){
            if(type.equals(mapping.Raise_Hand_Type__c) && (String.isEmpty(subtype) || subtype.equals(mapping.Raise_Hand_Subtype__c))){
                if(mapping.Is_Skill_Product_Specific__c){
                    lstSkill.addAll(SkillService.getSkillNames(mapping.Skill_Type__c, productName));
                }else{
                    lstSkill.addAll(SkillService.getSkillNames(mapping.Skill_Type__c));
                }
            }
        }
        lstSkill.sort();
        return lstSkill;
    }

    public static Id raiseRequest(Raise_Hand__c raiseHand){
        Raise_Hand__c raiseHandOrig;
        Boolean raisehandexists = false;

        if(raiseHand.Id != null){
            raiseHandOrig = [Select Id, Name, OwnerId, Owner.Name, Feed_Item_Id__c, Case__c, Case__r.OwnerId, Engagement__c, 
                                Skill__c, Product__c, Title__c, CreatedById, CreatedDate,
                                Type__c, Subtype__c, Status__c, Question__c, Repro_Expectation__c,
                                Meeting_Time__c, Accepted_On__c, Accepted_By__c, Closed_On__c
                            From Raise_Hand__c Where Id = :raiseHand.Id];

            raiseHand.Id = null;
            raiseHand.Feed_Item_Id__c = '';            
        }

        Case cse;
        if(raiseHand.Case__c != null){
            cse = [Select Id, OwnerId, CaseNumber, Priority, Forecast_Product__c, Support_Level__c,
                      Version__c, Segment__c, Acc__c, //T03
                      Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                      Account.Name, Account.New_Org_Account_Number__c 
                    From Case Where Id = :raiseHand.Case__c];    
        }

        if(raiseHand.Status__c == null){
            raiseHand.Status__c = STATUS_OPEN;
        }

        if(raiseHand.Name == null){
            String raiseHandName = raiseHand.Type__c;
            if(SUBTYPE_OPERATIONS.equals(raiseHand.Subtype__c)){
                raiseHandName += '-' + raiseHand.Subtype__c;
            }else if(String.isNotEmpty(raiseHand.Product__c)){
                raiseHandName += '-' + raiseHand.Product__c;
            }else if(String.isNotEmpty(raiseHand.Skill__c)){
                raiseHandName += '-' + raiseHand.Skill__c;
            }
            if(cse != null){
                raiseHandName += '-' + cse.CaseNumber;
            }
            //T02 - trim the value to 80 characters before setting the Name field value
            raiseHand.Name = raiseHandName.left(80);
        }

        if(raiseHand.OwnerId == null){
            raiseHand.OwnerId = SkillService.mapQueueNameToQueueId.get(SkillService.getSkillByName(raiseHand.Skill__c).Queue_Name__c);
        }

        insert raiseHand;
        
        List<Raise_Hand__c> lstRaiseHandToUpdate = new List<Raise_Hand__c>();
        if(TYPE_GET_HELP.equals(raiseHand.Type__c)){
            String chatterGroupName = SkillService.getSkillByName(raiseHand.Skill__c).Chatter_Group_Name__c;
            Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get(chatterGroupName).Id;
            Id currentUserId = UserInfo.getUserId();
            ConnectApi.FeedElement feedElement = chatterPostQuestion(null, raiseHand.Case__c, raiseHand.Id, chatterGroupId, null, currentUserId, 'Get Help Request:', raiseHand.Question__c, '');
            if(feedElement!=null){
                raiseHand.Feed_Item_Id__c = feedElement.Id;     
            }
            lstRaiseHandToUpdate.add(raiseHand);
        }

        List<PendingServiceRouting> lstPendingServRouting = new List<PendingServiceRouting>();
        if(raiseHandOrig != null){
            raiseHandOrig.Status__c = STATUS_CLOSED;
            raiseHandOrig.Closed_On__c = System.now();
            raiseHandOrig.Is_Converted__c = true;
            raiseHandOrig.Converted_To__c = raiseHand.Id;
            lstRaiseHandToUpdate.add(raiseHandOrig);

            lstPendingServRouting = [Select Id From PendingServiceRouting Where WorkItemId = :raiseHandOrig.Id];
            if(!lstPendingServRouting.isEmpty()){
                delete lstPendingServRouting;
            }

            String questionClosed = 'This Get Help request is promoted as Co-own and the Question is closed for further discussion!';
            //T04 post a comment instead of updating the Post to avoid the permission issue.
            try{
                chatterPostComment(raiseHandOrig.Feed_Item_Id__c, questionClosed);
            }catch(exception ex){
                System.debug('Error occurred while trying to post a comment to the Chatter Question.. ' + ex.getMessage());
            }
        }

        if(!TYPE_MANAGE_ESCALATION.equals(raiseHand.Type__c) && !TYPE_GET_HELP.equals(raiseHand.Type__c)){
            String chatterGroupName = SkillService.getSkillByName(raiseHand.Skill__c).Chatter_Group_Name__c;            
            Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get(chatterGroupName).Id; 
            
            Set<Id> setGroupId = new Set<Id>{chatterGroupId};
            ConnectApi.FeedElement feedElement = notificationNewRequest(cse, raiseHand, chatterGroupId);
            for(Raise_Hand__c rh: lstRaiseHandToUpdate){
                if(rh.Id == raiseHand.Id){
                    if(feedElement!=null){
                        rh.Feed_Item_Id__c = feedElement.Id;
                    }                    
                    raisehandexists = true;
                }
            }
            if(!raisehandexists){
                if(feedElement!=null){
                    raiseHand.Feed_Item_Id__c = feedElement.Id; 
                    lstRaiseHandToUpdate.add(raiseHand);
                }
            }
        }
        
        //I2RT-4213
        if(!TYPE_MANAGE_ESCALATION.equals(raiseHand.Type__c)){
            String caseComment = constructCaseComment(raiseHand, RaiseHandEvent.ON_OPEN, null);
            insert CaseCommentService.createRaiseHand(cse.Id, caseComment); //comment on case.
        }

        if(!lstRaiseHandToUpdate.isEmpty()){
            update lstRaiseHandToUpdate;
        }

        return raiseHand.Id;
    }

    public static Id raiseEscalation(Id caseId, Id engagementId){
        Case cse = [Select Id, CaseNumber From Case Where Id=:caseId];

        Raise_Hand__c raiseHand = new Raise_Hand__c();
        raiseHand.Case__c = caseId;
        raiseHand.Engagement__c = engagementId;
        raiseHand.Status__c = STATUS_OPEN;
        raiseHand.Type__c = TYPE_MANAGE_ESCALATION;
        raiseHand.Skill__c = SkillService.SKILL_ESCALATION_MANAGER;
        raiseHand.Name = TYPE_MANAGE_ESCALATION + '-' + cse.CaseNumber;

        return raiseRequest(raiseHand);
    }

    public static Id raiseEscalation(Id engagementId){
        Engagement__c engagement = [Select Id, Name, Title__c From Engagement__c Where Id=:engagementId];

        Raise_Hand__c raiseHand = new Raise_Hand__c();
        //raiseHand.Case__c = caseId;
        raiseHand.Engagement__c = engagementId;
        raiseHand.Status__c = STATUS_OPEN;
        raiseHand.Type__c = TYPE_MANAGE_ESCALATION;
        raiseHand.Skill__c = SkillService.SKILL_ESCALATION_MANAGER;
        
        //T02 - trim the value to 80 characters before setting the Name field value
        String raiseHandName = String.isNotEmpty(engagement?.Title__c) ? TYPE_MANAGE_ESCALATION + '-' + engagement.Title__c : TYPE_MANAGE_ESCALATION;
        raiseHand.Name = raiseHandName.left(80); 

        return raiseRequest(raiseHand);
    }

    public static void onAssignment(Set<Id> setRaiseHandId){
        onAssignment(setRaiseHandId, null);
    }
    
    public static void onAssignment(Set<Id> setRaiseHandId, Id assigneeUserId){
        System.debug('On assignment entry');
        //Deva Commented to Exclude CaseTeamMember logic
        //List<CaseTeamMember> lstCaseTM = new List<CaseTeamMember>();
        //To hold the list of case team records that need be inserted

        String assigneeUserName = '';
        
        List<Case_Team__c> lstCaseTM = new List<Case_Team__c>();

        List<Raise_Hand__c> lstRaiseHand = [Select Id,Description__c, Name, OwnerId, Owner.Name, Feed_Item_Id__c, Case__c, Case__r.OwnerId, Engagement__c, 
                                                Skill__c, Product__c, Title__c, CreatedById, CreatedDate,
                                                Type__c, Subtype__c, Status__c, Question__c, Repro_Expectation__c,
                                                Meeting_Time__c, Accepted_On__c, Accepted_By__c, Closed_On__c
                                              From Raise_Hand__c Where Id in :setRaiseHandId];

        Set<Id> setCaseId = new Set<Id>();
        for(Raise_Hand__c raiseHand : lstRaiseHand){
            if(raiseHand.Case__c != null){
                setCaseId.add(raiseHand.Case__c);
            }
        }
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>([Select Id, OwnerId, CaseNumber, Priority, Forecast_Product__c, Support_Level__c,
                                                                Version__c, Segment__c, Acc__c, //T03
                                                                Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                                                                Account.Name, Account.New_Org_Account_Number__c 
                                                            From Case Where Id = :setCaseId]);

        List<Raise_Hand__c> lstRaiseHandToUpdate = new List<Raise_Hand__c>();
        List<Case_Comment__c> lstCaseComment = new List<Case_Comment__c>();
        for (Raise_Hand__c raiseHand : lstRaiseHand) {
            Case cse;
            if(raiseHand.Case__c != null){
                cse = mapCaseIdToCase.get(raiseHand.Case__c);
            }
            System.debug('Type = ' + raiseHand.Type__c);
            System.debug('case = ' + raiseHand.Case__c);
            
            if(assigneeUserId != null){
                raiseHand.OwnerId = assigneeUserId;
                assigneeUserName = UserInfo.getName();
            }

            System.debug('new owner = ' + raiseHand.OwnerId);

            ConnectApi.FeedElement feedElement;
            ConnectApi.Comment commentInput;

            raiseHand.Status__c = STATUS_CLOSED;
            if (User.SobjectType == raiseHand.OwnerId.getSobjectType()) {
                if(TYPE_CO_OWN.equals(raiseHand.Type__c)){
                    //Deva Commented to Exclude CaseTeamMember
                    //CaseTeamMember caseTeamMember;
                    Case_Team__c caseTeamMember = CaseTeamService.createMember(raiseHand.Case__c, raiseHand.OwnerId, CaseTeamService.TEAM_ROLE_CO_OWNER);
                    lstCaseTM.add(caseTeamMember);
    
                    String chatterContent = ' added as co-owner';
                    System.debug('case owner id-->'+raiseHand.Case__r.OwnerId);
                    if(string.isblank(raiseHand.Feed_Item_Id__c)){
                        feedElement = chatterPostOnAssignment(raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent); 
                    } else {
                        commentInput = chatterfeedcommentOnAssignment('Collaboration Update',raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent, raisehand.Feed_Item_Id__c); //T01
                    }
                }else if(TYPE_GET_HELP.equals(raiseHand.Type__c)){
                    String chatterGroupName = SkillService.getSkillByName(raiseHand.Skill__c).Chatter_Group_Name__c;
                    Id chatterGroupId = SkillService.mapCollabGroupNameToGroup.get(chatterGroupName).Id;

                    try{
                        feedElement = chatterPostQuestion(raiseHand.Feed_Item_Id__c, raiseHand.Case__c, raiseHand.Id, chatterGroupId, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, 'Get Help Request:', raiseHand.Question__c, ' is working on a answer');
                    }catch(exception ex){
                        System.debug('Exception occurred while trying to update the Chatter Question.. ' + ex.getMessage());
                    }

                    raiseHand.Status__c = STATUS_IN_PROGRESS;
                }else if(TYPE_REPRO_ENV_SETUP.equals(raiseHand.Type__c)){
                    //I2RT-4456
                    Case_Team__c caseTeamMember = CaseTeamService.createMember(raiseHand.Case__c, raiseHand.OwnerId, CaseTeamService.TEAM_ROLE_COLLABORATOR);
                    lstCaseTM.add(caseTeamMember);
                    
                    String chatterContent = ' is working on this request to setup the Repro Environment \r\n\r\n Expectation : ' + raiseHand.Repro_Expectation__c;
                    if(string.isblank(raiseHand.Feed_Item_Id__c)){
                        feedElement = chatterPostOnAssignment(raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent);
                    } else{
                        commentInput = chatterfeedcommentOnAssignment('Collaboration Update',raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent, raisehand.Feed_Item_Id__c); //T01
                    }
                }else if(TYPE_CUSTOMER_MEETING.equals(raiseHand.Type__c)){
                    //I2RT-4456
                    Case_Team__c caseTeamMember = CaseTeamService.createMember(raiseHand.Case__c, raiseHand.OwnerId, CaseTeamService.TEAM_ROLE_COLLABORATOR);
                    lstCaseTM.add(caseTeamMember);
                    
                    String chatterContent = ' accepted to join the customer meeting.';
                    if(string.isblank(raiseHand.Feed_Item_Id__c)){
                        feedElement = chatterPostOnAssignment(raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent);
                    }else{
                        commentInput = chatterfeedcommentOnAssignment('Collaboration Update',raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, chatterContent, raisehand.Feed_Item_Id__c); //T01
                    }
                }else if(TYPE_MANAGE_ESCALATION.equals(raiseHand.Type__c)){
                    if(raiseHand.Case__c != null){
                        //Deva Commented to Exclude CaseTeamMember
                        //CaseTeamMember caseTeamMember;
                         Case_Team__c caseTeamMember  = CaseTeamService.createMember(raiseHand.Case__c, raiseHand.OwnerId, CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER);
                        lstCaseTM.add(caseTeamMember);
                    }else{
                        for(Case escalatedCase : [Select Id From Case Where Engagement__c = :raiseHand.Engagement__c]){
                            //Deva Commented to Exclude CaseTeamMember
                            //CaseTeamMember caseTeamMember;
                            Case_Team__c caseTeamMember  = CaseTeamService.createMember(escalatedCase.Id, raiseHand.OwnerId, CaseTeamService.TEAM_ROLE_ESCALATION_MANAGER);
                            lstCaseTM.add(caseTeamMember);
                        }
                    }

                    Engagement__c engagement = new Engagement__c();
                    engagement.Id = raiseHand.Engagement__c;
                    engagement.OwnerId = raiseHand.OwnerId;
                    update engagement;
                }
            }

            if(feedElement!=null && string.isblank(raiseHand.Feed_Item_Id__c)){
                raiseHand.Feed_Item_Id__c = feedElement.Id;
            }
            raiseHand.Is_Assigned__c = true;
            raiseHand.Accepted_By__c = raiseHand.OwnerId;
            raiseHand.Accepted_On__c = System.now();
            if(raiseHand.Status__c == STATUS_CLOSED){
                raiseHand.Closed_On__c = System.now();
            }
            lstRaiseHandToUpdate.add(raiseHand);

            if(raiseHand.Case__c != null){
               // System.debug(raiseHand+' comments '+RaiseHandEvent.ON_ASSIGNMENT);
                String caseComment = constructCaseComment(raiseHand, RaiseHandEvent.ON_ASSIGNMENT, assigneeUserName);
                
               // System.assertEquals(null, caseComment);
                lstCaseComment.add(CaseCommentService.createRaiseHand(raiseHand.Case__c, caseComment));
            }
            
            //T01: Post feedcomment for feeditem for non get help requests
            if(!TYPE_MANAGE_ESCALATION.equals(raiseHand.Type__c) && !TYPE_GET_HELP.equals(raiseHand.Type__c)){
                if(!string.isblank(raiseHand.Feed_Item_Id__c)){
                    feeditemOnAccept(raiseHand.Case__c, raiseHand.Id, raiseHand.Case__r.OwnerId, raiseHand.OwnerId, ' is now Closed', raisehand.Feed_Item_Id__c);
                }else{
                    notificationOnAccept(cse, raiseHand);
                }
            }
        }
        system.debug('@@@---lstCaseTM---->>>'+lstCaseTM);
        if(!lstRaiseHandToUpdate.isEmpty()){
            
            update lstRaiseHandToUpdate;
            if(!lstCaseComment.isEmpty()){
                insert lstCaseComment;
            }    
        }

        if(!lstCaseTM.isEmpty()){
            CaseTeamService.checkAndCreate(lstCaseTM);
        }
    }
    
    public static ConnectApi.FeedElement notificationNewRequest(Case cse, Raise_Hand__c raiseHand, Id chatterGroupId){
        return notify('New Collaboration', cse, raiseHand, chatterGroupId);
    }
    
    public static ConnectApi.Comment feeditemOnAccept(Id caseId, Id raiseHandId, Id caseOwnerId, Id taskOwnerId, String content, String feedelemid){
        return chatterfeedcommentOnAssignment('Collaboration Update: ',caseId, raiseHandId, caseOwnerId, taskOwnerId, content, feedelemid);   
    }

    public static ConnectApi.FeedElement notificationOnAccept(Case cse, Raise_Hand__c raiseHand){
        return notify('Collaboration Update', cse, raiseHand, raiseHand.CreatedById);
    }

    public static ConnectApi.FeedElement notify(String activity, Case cse, Raise_Hand__c raiseHand, Id idToMention){
        //I2RT-4916 - check if the Product is selected on the Case
        String productContent = '';
        if(String.isNotEmpty(cse.Forecast_Product__c)){
            productContent = cse.Forecast_Product__c + ', ';
        }

        //String content = raiseHand.Type__c + ': ' + productContent + cse.Priority + ' Case ' + cse.CaseNumber + ' for ' + cse.Support_Account__r.Name + ', ' + cse.Support_Level__c;

        String content = (raiseHand.Type__c!=NULL ? raiseHand.Type__c  : '') + ': ' + productContent + (cse.Priority!=NULL ? cse.Priority : '' ) 
        + ' Case ' + (cse.CaseNumber!=NULL ? cse.CaseNumber : '' ) + ' for ' + (cse.Support_Account__r.Name!=NULL ? cse.Support_Account__r.Name : '') 
                                + ', ' + (cse.Support_Level__c!=NULL ? cse.Support_Level__c : '')  ; //T05 null handle
                                                
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Title', raiseHand.Title__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Description', raiseHand.Description__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Collab Type', raiseHand.Type__c));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Activity', activity));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Summary', raiseHand.Name));
        
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Status', raiseHand.Status__c));
        if(raiseHand.Accepted_By__c != null){
            messageBodyInput.messageSegments.add(ChatterService.inputText('Acceptor: '));
            messageBodyInput.messageSegments.add(ChatterService.inputLink(raiseHand.Accepted_By__c));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        }

        String createdDate = String.valueOf(raiseHand.CreatedDate);
        if(raiseHand.CreatedDate == null){
            createdDate = String.valueOf(System.now());
        }

        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Created On', createdDate));
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Case Number', cse.CaseNumber));
        messageBodyInput.messageSegments.add(ChatterService.inputText('Case Owner / Team: '));
        messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.OwnerId));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNameValue('Priority', cse.Priority));
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
        messageBodyInput.messageSegments.add(ChatterService.inputLink(cse.Id));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());

        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputMention(idToMention));    

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = cse.Id;
        feedItemInput.body = messageBodyInput;
    
        ConnectApi.FeedElement feedElement;
        if(!Test.isRunningTest()){
            feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);    
        }
        return feedElement;
    }

    //T04 - method to post comment in the given chatter post
    public static void chatterPostComment(Id feeditemid, String commentText){
        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, feeditemid, commentText);
    }

    public static ConnectApi.FeedElement chatterPostQuestion(Id feeditemid, Id caseId, Id raiseHandId, Id chatterGroupId, Id caseOwnerId, Id taskOwnerId, String questionTitle, String question, String remarks){
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        if(taskOwnerId == null){
            if(String.isNotEmpty(remarks)){
                messageBodyInput.messageSegments.add(ChatterService.inputText(remarks));
                messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
                messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            }
        }
        
        messageBodyInput.messageSegments.add(ChatterService.inputText(question));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        
        if(taskOwnerId != null){
            messageBodyInput.messageSegments.add(ChatterService.inputMention(taskOwnerId));
            if(String.isNotEmpty(remarks)){
                messageBodyInput.messageSegments.add(ChatterService.inputText(remarks));
                messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            }
        }

        messageBodyInput.messageSegments.add(ChatterService.inputText('Collaboration Request: '));
        messageBodyInput.messageSegments.add(ChatterService.inputLink(raiseHandId));
        if(chatterGroupId != null){
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(chatterGroupId));    
        }

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = messageBodyInput;
    
        if(String.isNotEmpty(questionTitle)){
            //I2RT-4318 
            if(feeditemid != null && questionTitle.equals('Get Help Request (Closed):')){
                List<FeedComment> lstFeedComment = [SELECT Id,InsertedById FROM FeedComment WHERE FeedItemId = :feeditemid];
                if(!lstFeedComment.isEmpty()){
                    messageBodyInput.messageSegments.add(ChatterService.inputMention(lstFeedComment.get(0).InsertedById));
                }
            }
            ConnectApi.QuestionAndAnswersCapabilityInput questionAndAnswersCapabilityInput = new ConnectApi.QuestionAndAnswersCapabilityInput();
            questionAndAnswersCapabilityInput.questionTitle = questionTitle;
            ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
            feedElementCapabilitiesInput.questionAndAnswers = questionAndAnswersCapabilityInput;
            feedItemInput.capabilities = feedElementCapabilitiesInput;    
        }

        ConnectApi.FeedElement feedElement;
        if(feeditemid == null){
            feedItemInput.subjectId = caseId;
            if(!Test.isRunningTest()){
                feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
            }
        }else{
            if(!Test.isRunningTest()){
                feedElement = ConnectApi.ChatterFeeds.updateFeedElement(null, feeditemid, feedItemInput);
            }
        }
        return feedElement;
    }

    public static ConnectApi.FeedElement chatterPostOnAssignment(Id caseId, Id raiseHandId, Id caseOwnerId, Id taskOwnerId, String content){
        System.debug('caseOwnerId-->'+caseOwnerId);
        
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(ChatterService.inputMention(taskOwnerId));
        messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
        messageBodyInput.messageSegments.add(ChatterService.inputText('Collaboration Request: '));
        messageBodyInput.messageSegments.add(ChatterService.inputLink(raiseHandId));

        if(caseOwnerId != null && 'User'.equals(caseOwnerId.getSobjectType().getDescribe().getLabel())){
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(caseOwnerId));    
        }
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.subjectId = caseId;
        feedItemInput.body = messageBodyInput;

        ConnectApi.FeedElement feedElement;
        if(!Test.isRunningTest()){
            feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        }
        return feedElement;
    }


    /*
     * @description: Create feedcomment for the feeditem 
     * @date: 08-August-2021
     * @param:  Type of update, caseid, raisehandid, caseownerid, taskownerid, content, feeditemid
     * @returns: N/A
     */

    public static ConnectApi.Comment chatterfeedcommentOnAssignment(String activity,Id caseId, Id raiseHandId, Id caseOwnerId, Id taskOwnerId, String content, String feedelemid){
        System.debug('caseOwnerId-->'+caseOwnerId);
        String communityId = null;
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        if(!content.contains('Closed')){
            messageBodyInput.messageSegments.add(ChatterService.inputMention(taskOwnerId));
            messageBodyInput.messageSegments.add(ChatterService.inputText(content));
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputText(activity));
            messageBodyInput.messageSegments.add(ChatterService.inputLink(raiseHandId));
        } else{
            messageBodyInput.messageSegments.add(ChatterService.inputText(activity));
            messageBodyInput.messageSegments.add(ChatterService.inputLink(raiseHandId));
            messageBodyInput.messageSegments.add(ChatterService.inputText(content));
        }
        
        
        

        if(caseOwnerId != null && 'User'.equals(caseOwnerId.getSobjectType().getDescribe().getLabel())){
            messageBodyInput.messageSegments.add(ChatterService.inputNewLine());
            messageBodyInput.messageSegments.add(ChatterService.inputMention(caseOwnerId));    
        }
        if(!content.contains('Closed')){
            messageBodyInput.messageSegments.add(ChatterService.inputMention(taskOwnerId));
        }
        ConnectApi.CommentInput  commentInput  = new ConnectApi.CommentInput();
        //commentInput.subjectId = caseId;
        commentInput.body = messageBodyInput;

        ConnectApi.Comment  commentRep ;
        if(!Test.isRunningTest()){
            commentRep  = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedelemid, commentInput, null);
        }
        return commentRep ;
    }

    /*
     * @description: Update GetHelp Type records with status to 'In Progress', when there is a new FeedComment on FeedItem  
     * @date: 07-September-2021
     * @param:  feedcomments
     * @returns: N/A
     */
    public static void updateStatus(List<FeedComment> feedComments){

        Set<Raise_Hand__c> raiseHandsToUpdate = new set<Raise_Hand__c>();
        Set<Id> feedItemIds = new Set<Id>();

        for(FeedComment FC : feedComments){
            if(FC.FeedItemId != null){
                feedItemIds.add(FC.FeedItemId);
            }
        }

        for(Raise_Hand__c raiseHand : [Select Id,Status__c from Raise_Hand__c where Feed_Item_Id__c IN :feedItemIds AND Type__c = :TYPE_GET_HELP AND Status__c = :STATUS_OPEN]){
            raiseHand.status__c = STATUS_IN_PROGRESS;
            raiseHandsToUpdate.add(raiseHand);
        }

        if(raiseHandsToUpdate.size() > 0){
            update new List<Raise_Hand__c>(raiseHandsToUpdate);
        }
    }

}