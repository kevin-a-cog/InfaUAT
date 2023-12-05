public class MassUpdateSubscriptionController {
    
    @AuraEnabled
    public static ContractWrapper getDetails(String recordId){
        List<Contract> contractList = [SELECT Id,ContractNumber,Name,AccountId,Account.Name,(SELECT Id,Name,SBQQ__Account__c,SBQQ__Account__r.Name FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id = :recordId];
        ContractWrapper cw = new ContractWrapper();
        if(!contractList.isEmpty()){
            if(contractList[0].SBQQ__Subscriptions__r != null && !contractList[0].SBQQ__Subscriptions__r.isEmpty()){
                List<SBQQ__Subscription__c> subList = contractList[0].SBQQ__Subscriptions__r;
                cw.accountId = subList[0].SBQQ__Account__c;
                cw.accountName = subList[0].SBQQ__Account__r.Name;
            }
            cw.contractId = contractList[0].Id;
            cw.contractName = contractList[0].ContractNumber;
        }
        return cw;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> searchAccounts(String searchTerm){
        List<AccountWrapper> accountWrapperList = new List<AccountWrapper>();
        try {
            System.debug('@@searchTerm'+searchTerm);
            String finsearchTerm = '%' + searchTerm + '%';
            List<Account> accList = new List<Account>();
            if(searchTerm != '' && searchTerm != null){
                accList = [SELECT Id,New_Org_Account_Number__c,BillingState,BillingCountry,Phone,RecordTypeId,RecordType.Name,DNBI__DnB_DUNS_NO__c,Global_Ultimate_Number__c,OwnerId,Owner.Name,Name
                                FROM Account WHERE Name LIKE :finsearchTerm OR New_Org_Account_Number__c LIKE :finsearchTerm LIMIT 10];
            }                
            else{
                accList = [SELECT Id,New_Org_Account_Number__c,BillingState,BillingCountry,Phone,RecordTypeId,RecordType.Name,DNBI__DnB_DUNS_NO__c,Global_Ultimate_Number__c,OwnerId,Owner.Name,Name
                                FROM Account Order By LastViewedDate LIMIT 10];
            }
            System.debug('@@accList'+accList);
            
            for(Account acc : accList){
                AccountWrapper aw = new AccountWrapper();
                aw.accountName = acc.Name;
                aw.accountNumber = acc.New_Org_Account_Number__c;
                aw.stateProvince = acc.BillingState;
                aw.country = acc.BillingCountry;
                aw.phone = acc.Phone;
                aw.recordTypeId = acc.RecordTypeId;
                aw.recordTypeName = acc.RecordType.Name;
                aw.dunsNumber = acc.DNBI__DnB_DUNS_NO__c;
                aw.ultimateNumber = acc.Global_Ultimate_Number__c;
                aw.ownerId = acc.OwnerId;
                aw.ownerAlias = acc.Owner.Name;
                aw.Id = acc.Id;
                accountWrapperList.add(aw);
            }
            return accountWrapperList;
        } catch (Exception e) {
            System.debug('@@ee');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateSubscription(String contractId,String accountId){
        try{
            if(contractId != '' && contractId != null && accountId != null && accountId != ''){
                List<SBQQ__Subscription__c> subscriptionListToUpdate = new List<SBQQ__Subscription__c>();
                List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
                subscriptionList = [SELECT Id,SBQQ__Account__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = :contractId];
                for(SBQQ__Subscription__c sub : subscriptionList){
                    sub.SBQQ__Account__c = accountId;
                    subscriptionListToUpdate.add(sub);
                }
                if(!subscriptionListToUpdate.isEmpty()){
                    update subscriptionListToUpdate;
                }
            }
            else if(contractId == '' || contractId == null){
                return 'ContractId Can\'t be null!';
            }
            else if(accountId == '' || accountId == null){
                return 'accountId Can\'t be null!';
            }
        }
        catch(Exception e){
            return 'false';
        }
        return 'true';
    }

    public class AccountWrapper{
        @AuraEnabled public String accountName; 
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String stateProvince;
        @AuraEnabled public String country;
        @AuraEnabled public String phone;
        @AuraEnabled public String recordTypeId;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String dunsNumber;
        @AuraEnabled public String ultimateNumber;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String ownerAlias;
        @AuraEnabled public String Id;
    }

    public class ContractWrapper{
        @AuraEnabled public String contractId;
        @AuraEnabled public String contractName;
        @AuraEnabled public String accountName;
        @AuraEnabled public String accountId;
    }

    public String contractId;

    public MassUpdateSubscriptionController(ApexPages.StandardSetController cntlr){
        String jId = Apexpages.currentpage().getparameters().get('id'); 
        contractId = jId;
    } 

    public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__massUpdateSubscriptionAura?c__contractid='+contractId;
        PageReference pgReturnPage = new PageReference(returnUrl);
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }
}