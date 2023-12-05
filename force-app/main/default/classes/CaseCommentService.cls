/*
    @created by       : balajip
    @created on       : 01/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to Case Comment Object
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
public with sharing class CaseCommentService {

    public static final String VISIBILITY_PRIVATE = 'Private';
    public static final String VISIBILITY_INTERNAL = 'Internal';
    public static final String VISIBILITY_EXTERNAL = 'External';

    public static final String STATUS_PREDRAFT = 'Pre Draft';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_SCHEDULED = 'Scheduled';
    public static final String STATUS_SUBMITTED = 'Submitted';

    public static final String TYPE_CALLBACK = 'Callback';
    public static final String TYPE_REVISE_PRIORITY = 'Revise Priority';
    public static final String TYPE_ESCALATION = 'Escalation';
    public static final String TYPE_RAISE_HAND = 'Raise Hand';
    
    public CaseCommentService() {

    }

    //utility method that creates a Case Comment record with the given values.
    public static Case_Comment__c createComment(Id caseId, Id ownerId, String comments, String type, String status, Boolean inbound, String visibility, Boolean importance){
        Case_Comment__c caseComment = new Case_Comment__c();
        caseComment.Case__c = caseId;
        CaseComment.Type__c = type;
        caseComment.Status__c = status;
        caseComment.Inbound__c = inbound;
        caseComment.Visibility__c = visibility;
        caseComment.Importance__c = importance;
        caseComment.Comment__c = comments;
        caseComment.OwnerId = ownerId;

        return caseComment;
    }

    //creates a Case Comment for attention request
    public static Case_Comment__c createAttnRequest(Id caseId, String forecastProduct, String requestType, String comment){
        String comments = '';
        if(TYPE_REVISE_PRIORITY.equals(requestType)){
            comments = 'Request to revise the priority </br></br>' + comment;
        }else if(TYPE_CALLBACK.equals(requestType)){
            comments = 'Request for a callback </br></br>' +  comment;
        } else {
            comments = comment;
        }

        Case_Comment__c caseComment = new Case_Comment__c();
        if(!String.isEmpty(forecastProduct)){
            caseComment.OwnerId = CaseService.getProductQueue(forecastProduct);
        }
        caseComment.Case__c = caseId;
        CaseComment.Type__c = requestType;
        caseComment.Status__c = STATUS_SUBMITTED;
        caseComment.Inbound__c = true;
        caseComment.Visibility__c = VISIBILITY_EXTERNAL; //VISIBILITY_INTERNAL; //Amarender - Updated to External
        caseComment.Comment__c = comments;

        return caseComment;
    }
    
    //creates a Case Comment for escalation
    public static Case_Comment__c createEscalationComment(Id caseId, String reason, String comment){
        Case cse = [Select Id, OwnerId From Case Where Id = :caseId];

        Id ownerId;
        if('User'.equals(cse.OwnerId.getSobjectType().getDescribe().getName())){
            User usr = CaseControllerWithoutSharing.getUser(cse.OwnerId);
            if(usr.ManagerId != null){
                ownerId = usr.ManagerId;
            }    
        }
        if(ownerId == null){
            ownerId = CaseService.getEscalationQueue();
        }

        Case_Comment__c caseComment = new Case_Comment__c();
        caseComment.OwnerId = ownerId;
        caseComment.Case__c = caseId;
        CaseComment.Type__c = TYPE_ESCALATION;
        caseComment.Status__c = STATUS_SUBMITTED;
        caseComment.Inbound__c = true;
        caseComment.Visibility__c =  VISIBILITY_EXTERNAL; //VISIBILITY_INTERNAL; //Amarender - Updated to External
        caseComment.Comment__c = 'Escalation - ' + reason;
        if(String.isNotEmpty(comment)){
            caseComment.Comment__c += '</br></br> ' + comment;
        }

        return caseComment;
    }
    
    //creates a Case Comment for Raise Hand
    public static Case_Comment__c createRaiseHand(Id caseId, String comment){

        Case_Comment__c caseComment = new Case_Comment__c();
        //caseComment.OwnerId = ;
        caseComment.Case__c = caseId;
        CaseComment.Type__c = TYPE_RAISE_HAND;
        caseComment.Status__c = STATUS_SUBMITTED;
        caseComment.Inbound__c = false;
        caseComment.Visibility__c = VISIBILITY_INTERNAL;        
        caseComment.Comment__c = comment;

        return caseComment;
    }

    //I2RT-4229 creates a Case Comment for cloned case
    public static Case_Comment__c createClonedCaseComment(Id caseId, String comment){
        Case_Comment__c caseComment = new Case_Comment__c();
        caseComment.Case__c = caseId;
        caseComment.Status__c = STATUS_SUBMITTED;
        caseComment.Inbound__c = false;
        caseComment.Visibility__c = VISIBILITY_INTERNAL;        
        caseComment.Comment__c = comment;
        return caseComment;
    }
}