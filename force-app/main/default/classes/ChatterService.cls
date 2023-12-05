public without sharing class ChatterService {
    
    public static ConnectApi.TextSegmentInput inputNameValue(String name, String value){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        if(value == null){
            value = '';
        }
        textInput.text = name + ': ' + value + '\r\n';
        return textInput;
    }

    public static ConnectApi.TextSegmentInput inputNewLine(){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        textInput.text = '\r\n';
        return textInput;
    }

    public static ConnectApi.TextSegmentInput inputSpace(){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        textInput.text = ' ';
        return textInput;
    }

    public static ConnectApi.TextSegmentInput inputText(String value){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        if(value == null){
            value = '';
        }
        textInput.text = value;
        return textInput;
    }

    public static ConnectApi.MentionSegmentInput inputMention(Id idToMention){
        ConnectApi.MentionSegmentInput mentionInput = new ConnectApi.MentionSegmentInput();       
        mentionInput.id = idToMention;
        return mentionInput;
    }

    public static ConnectApi.EntityLinkSegmentInput inputLink(Id entityId){
        ConnectApi.EntityLinkSegmentInput linkInput = new ConnectApi.EntityLinkSegmentInput();       
        linkInput.entityId = entityId;
        return linkInput;
    }

    public static ConnectApi.LinkSegmentInput inputHyperlink(String recordId){
        String host = System.Url.getOrgDomainUrl().toExternalForm() + '/';
        ConnectApi.LinkSegmentInput linkInput = new ConnectApi.LinkSegmentInput();   
        Id idval = Id.valueOf(recordId); 
        String sobjectType = idval.getSObjectType().getDescribe().getName();    
        linkInput.url = host + 'lightning/r/' + sobjectType +'/'+ recordId + '/view';
        return linkInput;
    }
    
}