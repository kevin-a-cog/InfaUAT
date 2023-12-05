public class AccountSearchResultWrapper {
    @AuraEnabled
    public String accountName{get;set;}
    @AuraEnabled
    public String address{get;set;}
    @AuraEnabled
    public String accountNumber{get;set;}
    @AuraEnabled
    public String city{get;set;}
    @AuraEnabled
    public String state{get;set;}
    @AuraEnabled
    public String postalCode{get;set;}
    @AuraEnabled
    public String country{get;set;}
    @AuraEnabled
    public String site_gduns{get;set;}
    @AuraEnabled
    public String salesforce_id{get;set;}
    @AuraEnabled
    public Boolean isSalesforceRecord{get;set;}
    @AuraEnabled
    public String phoneNumber{get;set;}
    @AuraEnabled
    public String website{get;set;}
    //SALESRT-13356
    @AuraEnabled
    public String Account_Type{get;set;}
    @AuraEnabled
    public String source{get;set;} 
    //
    public static List<AccountSearchResultWrapper> parse(String json){
            return (List<AccountSearchResultWrapper>) System.JSON.deserialize(json, List<AccountSearchResultWrapper>.class);
    }
}