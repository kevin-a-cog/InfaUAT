global class InternalCaseViewDataV1 implements Comparable{

    @AuraEnabled public Boolean bIsCaseComment {get;set;}
    @AuraEnabled public Boolean bIsEmail {get;set;}
    @AuraEnabled public Boolean bIsAttachment {get;set;}
    @AuraEnabled public Boolean bIsWebex {get;set;}
    @AuraEnabled public Boolean bIsCall {get;set;}
    @AuraEnabled public Boolean bIsSubCase {get;set;}
    @AuraEnabled public Boolean bIsFeedActivity {get;set;}
    

    @AuraEnabled public String redId {get;set;}

    @AuraEnabled public String type {get;set;}

    @AuraEnabled public DateTime createdAt {get;set;}
    
    @AuraEnabled public String commentBody {get;set;}
    
    @AuraEnabled public EmailMessage msg { get;set;}
    
    @AuraEnabled public Attachment attachment {get;set;}
    //<SupportProject>
   // public PSResponse__c psResponse { get;set;}
     //</SupportProject>
     @AuraEnabled public ActivityHistory webex{get;set;}
    
     @AuraEnabled public ActivityHistory call{get;set;}
    
     @AuraEnabled public Case relatedCase {get;set;}
    
     @AuraEnabled public feeditem feed { get;set;}  //T02
    
    //T01- Added to format the date to string so that the actual timestamp as per the object is represented instead of being converted to UTC
    @testVisible
    @AuraEnabled public String formattedDate {
        get {
            return createdAt.format();
        }
    }
    
    global Integer compareTo(Object other) {
        InternalCaseViewDataV1 compareToCopy = (InternalCaseViewDataV1 )other;       
        if(this.createdAt > compareToCopy.createdAt) return -1;
        if(this.createdAt == compareToCopy.createdAt) return 0;
        return 1;
    }
}