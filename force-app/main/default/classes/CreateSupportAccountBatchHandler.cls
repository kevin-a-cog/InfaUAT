/*
Class:          CreateSupportAccountBatchHandler 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Hanlder Class for craeteSupportAccountBatch
***********************************************************************************
MODIFIED BY         JIRA          DESCRIPTION                                   TAG
***********************************************************************************
Vignesh Divakaran   I2RT-5360     Create Primary Contact as inactive            T01
Vignesh Divakaran   I2RT-5484     Add Ship To contact as primary contact on     T02
                                  new support account
Vignesh Divakaran   I2RT-5484     SOQL without querying the requested field fix T03
Shashikanth         I2RT-9491     Truncating Engagement Name length             T04
                                  if its more than the field length
*/

public with sharing class CreateSupportAccountBatchHandler {

    public static final String BASIC_PACK = 'Case Pack';

    public static void CreateSupportAccounts( List<Asset> lstAssets) {

        System.debug('Enter Method CreateSupportAccounts');

        map<Id,Asset> mapAssets = new map<Id,Asset>(lstAssets);
        map<Id,Asset> mapAssetRelatedSubscription = new map<Id,Asset>();
        map<Id,Id> mapAssetServiceAccount = new map<Id,Id>();
        map<Id,List<Asset>> mapContractAssets = new map<Id,List<Asset>>();
        map<Id,String> mapContractBusinessModel = new Map<Id,String>();
        set<Id> ContractIds = new Set<Id>();
        map<id,Id> mapContractSupportAccount = new map<id,Id>();
        List<Asset> lstUpdateAssets = new List<Asset>();
        List<Account> lstInsertSupportAccount = new List<Account>();
        List<Engagement__c> lstInsertEngagement = new List<Engagement__c>();
        List<AccountContactRelation> lstInsertSupportContacts = new List<AccountContactRelation>();
        Set<id> setNewEngagementIds = new set<Id>();
        set<Id> setNewSupportAccounts = new set<id>();
        set<Id> setSupportAccountsToRecalculate = new set<id>();
        List<Engagement__c> lstUpdateEngagements = new List<Engagement__c>();
        map<Id,Id> mapContractEngagement = new map<id,Id>();
        //map<Id,Id> mapContractEndUser = new map<id,Id>(); Commented as part of <T02>
        map<Id,Id> mapContractShipToUser = new map<id,Id>(); //<T02>
        set<id> setAssetsUpdated = new set<id>();
        map<Id,Id> mapBPAssetAccount = new map<id,Id>();
        map<id,List<id>> mapAccountSupportAccount = new map<id,List<id>>();
        set<Id> renewedSubscriptionIds = new set<Id>();
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id EngagementRecType = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('GCS Administration').getRecordTypeId();

       String GCSAdminQueueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and Name = :Label.GCSAdminQueue Limit 1].Id;

        GlobalApexManager GAM = new GlobalApexManager();
        for(Asset newAsset : lstAssets){
            //check for renewed
            if(newAsset?.SBQQ__QuoteLine__r?.SBQQ__RenewedSubscription__c != null){
                mapAssetRelatedSubscription.put(newAsset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,newAsset ) ;
                renewedSubscriptionIds.add(newAsset.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
            }
            //check for amended
            else if(newAsset?.SBQQ__QuoteLine__r?.SBQQ__UpgradedSubscription__c !=null){
                mapAssetRelatedSubscription.put(newAsset.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,newAsset) ;
            }

            //check for basic pack 
            if(newAsset.Product2.Edition__c == BASIC_PACK && newAsset.AccountId !=null ){
                mapBPAssetAccount.put(newAsset.Id,newAsset.AccountId);
            }
            //check for contract
            else if(newAsset?.SBQQ__CurrentSubscription__r?.SBQQ__Contract__c!=null){               
                ContractIds.add(newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c);
                mapContractBusinessModel.put(newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c,newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__r.Business_Model__c);
                if(mapContractAssets.containskey(newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c)){
                    mapContractAssets.get(newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c).add(newAsset);
                }
                else{
                    List<Asset> lstAsset = new List<Asset>();
                    lstAsset.add(newAsset);
                    mapContractAssets.put(newAsset.SBQQ__CurrentSubscription__r.SBQQ__Contract__c,lstAsset);
                }
            }
        }

        System.debug('mapAssetRelatedSubscription'+ mapAssetRelatedSubscription);
        System.debug('mapContractAssets'+ mapContractAssets);
        System.debug('mapBPAssetAccount'+ mapBPAssetAccount);

        //get the support accounts available under the customer account
        for(Account sa : [select Id,ParentId from Account where ParentId in :mapBPAssetAccount.values() and RecordtypeId =:SupportAccountRecType and Active__c=true]){
            if(mapAccountSupportAccount.containskey(sa.ParentId)){
                mapAccountSupportAccount.get(sa.ParentId).add(sa.id);
            }else{
                List<id> saids= new List<id>();
                saids.add(sa.id);
                mapAccountSupportAccount.put(sa.ParentId,saids);
            }
        }
        System.debug('mapAccountSupportAccount'+ mapAccountSupportAccount);

        //map the support account to basic pack asset only if there is one support account under the customer account
        for(Id assetId: mapBPAssetAccount.keySet() ){
            if(mapAccountSupportAccount.containskey(mapBPAssetAccount.get(assetId))&& mapAccountSupportAccount?.get(mapBPAssetAccount.get(assetId))?.size()==1){
                Asset updateAsset = new Asset(Id=assetId);
                updateAsset.Support_Account__c = mapAccountSupportAccount.get(mapBPAssetAccount.get(assetId))[0];
                system.debug('updateAsset-->'+updateAsset);
                lstUpdateAssets.add(updateAsset);
            }
        }

       //check if contract has support account linked to any asset        
        for(Asset a : [Select id, Support_Account__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c from Asset where  SBQQ__CurrentSubscription__r.SBQQ__Contract__c in :ContractIds and Support_Account__c!= null and id not in:mapAssets.keyset() ]){
            mapContractSupportAccount.put(a.SBQQ__CurrentSubscription__r.SBQQ__Contract__c,a.Support_Account__c);
        }
        
        System.debug('mapContractSupportAccount'+ mapContractSupportAccount);


        //check for related Asset support account
        for( Asset oldAsset : [Select id,Support_Account__c,SBQQ__CurrentSubscription__c from Asset where SBQQ__CurrentSubscription__c in : mapAssetRelatedSubscription.keyset()and Support_Account__c !=null ]){ //<T03>
            mapContractSupportAccount.put(mapAssetRelatedSubscription.get(oldAsset.SBQQ__CurrentSubscription__c)?.SBQQ__CurrentSubscription__r?.SBQQ__Contract__c,oldAsset.Support_Account__c);
        }
        System.debug('mapContractSupportAccount'+ mapContractSupportAccount);


        for(Id contractId : mapContractAssets.keyset()){
            //if Support Account exits update assets with same support account
            if(mapContractSupportAccount.containskey(contractId)){
                for(Asset a : mapContractAssets.get(contractId)){
                    Asset updateAsset = new Asset(Id=a.id);
                    updateAsset.Support_Account__c = mapContractSupportAccount.get(contractId);
                    system.debug('updateAsset-->'+updateAsset);
                    lstUpdateAssets.add(updateAsset);
                }
            }
            //Create new support Account , engagement
            else {

                    String customerAccountId = mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].AccountId : '';
                    String customerAccountName = mapContractAssets.get(contractId)[0].Account?.Name!= null? mapContractAssets.get(contractId)[0].Account?.Name: '';
                    String customerAccountCountry = mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].Account?.BillingCountry : '';
                    String customerAccountState = mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].Account?.BillingState : '';
                    String customerAccountCity = mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].Account?.BillingCity : '';
                    String customerAccountStreet = mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].Account?.BillingStreet : '';
                    String customerAccountCurrency= mapContractAssets.get(contractId)[0].AccountId!= null? mapContractAssets.get(contractId)[0].Account?.CurrencyIsoCode : '';
                    String OrderId = mapContractAssets?.get(contractId)[0].SBQQ__CurrentSubscription__r?.SBQQ__Contract__r?.SBQQ__Order__c ;
                    String EndUserContact = mapContractAssets?.get(contractId)[0].SBQQ__CurrentSubscription__r?.SBQQ__Contract__r?.SBQQ__Order__r?.EndUserContact__c ;
                    String ShipToContact = mapContractAssets?.get(contractId)[0].SBQQ__CurrentSubscription__r?.SBQQ__Contract__r?.SBQQ__Order__r?.ShipToContactId;

                    /* Commented as part of <T02>
                    if(EndUserContact!= null){
                    mapContractEndUser.put(ContractId,EndUserContact);
                    }*/

                    //---------------------------------------<T02>--------------------------------
                    if(ShipToContact != null){
                        mapContractShipToUser.put(ContractId, ShipToContact);
                    }
                    //---------------------------------------</T02>-------------------------------

                    //<T04>
                    String engName = customerAccountName;
                    String engNameSuffix = ' Engagement';
                    Integer engNamefieldLength = Schema.SObjectType.Engagement__c.fields.Name.getLength();
                    Integer engNameMaxLength = engNamefieldLength - engNameSuffix.length();

                    if(engName.length() > engNameMaxLength)
                    {
                        engName = engName.left(engNameMaxLength);
                    }
                    engName = engName + engNameSuffix;
                    //</T04>

                    Engagement__c newEngagement = new Engagement__c();
                    newEngagement.Account__c = customerAccountId;
                    newEngagement.Contract__c = ContractId;
                    newEngagement.Order__c = OrderId;
                    //newEngagement.Primary_Contact__c = EndUserContact;
                    newEngagement.Primary_Contact__c = ShipToContact ;
                    newEngagement.RecordtypeId =EngagementRecType ;
                    newEngagement.Name = engName;                 //<T04>
                    newEngagement.OwnerId= GCSAdminQueueId;
                    lstInsertEngagement.add(newEngagement);

                    //

                   Account supportAcc= new Account();
                   supportAcc.ParentId = customerAccountId;
                   supportAcc.BillingCountry = customerAccountCountry;
                   supportAcc.BillingState = customerAccountState;
                   supportAcc.BillingCity = customerAccountCity;
                   supportAcc.BillingStreet = customerAccountStreet;
                   supportAcc.CurrencyIsoCode = customerAccountCurrency;
                   supportAcc.Contract__c = ContractId;
                   supportAcc.RecordtypeId =SupportAccountRecType ;
                   supportAcc.Name = customerAccountName +' '+'Support Account';
                   if(mapContractBusinessModel?.get(ContractId) == 'POC'){
                    supportAcc.Support_Account_Type__c = 'POC';
                   }
                   lstInsertSupportAccount.add(supportAcc);
            }
        } 

        system.debug('lstInsertEngagement'+ lstInsertEngagement);
        
        if(lstInsertEngagement!=null && lstInsertEngagement.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertEngagement);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewEngagementIds.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->insert of support account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        //get nrely created enagegment
        For(Engagement__c eng : [Select id,Contract__c from Engagement__c where id in :setNewEngagementIds]){
            mapContractEngagement.put(eng.Contract__c, eng.id);
        }
        //Map Support account with nee enagement
        for( Account  acc :lstInsertSupportAccount){
            acc.Engagement__c = mapContractEngagement?.get(acc.Contract__c);
        }
        system.debug('lstInsertSupportAccount'+ lstInsertSupportAccount);

        if(lstInsertSupportAccount!=null && lstInsertSupportAccount.size()>0){
            Database.SaveResult[] srList = Database.insert(lstInsertSupportAccount);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setNewSupportAccounts.add(sr.getId());
                }
                else{
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->insert of support account failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

        system.debug('setNewSupportAccounts'+setNewSupportAccounts);

        //Update Assets, enagement wiith newly created support account
        for(Account supportAccount: [select id,Contract__c from Account where id in :setNewSupportAccounts]){

            System.debug( 'SupportAccount.Contract__c'+ supportAccount.Contract__c);
            if(!mapContractSupportAccount.containskey(supportAccount.Contract__c)){
                for(Asset a : mapContractAssets.get(supportAccount.Contract__c)){
                    Asset updateAsset = new Asset(Id=a.id);
                    updateAsset.Support_Account__c = supportAccount.Id;
                    lstUpdateAssets.add(updateAsset);
                }
            }
        
            if(mapContractEngagement.containsKey(supportAccount.Contract__c)){
                Engagement__c updateEng = new Engagement__c(Id = mapContractEngagement.get(supportAccount.Contract__c));
                updateEng.Support_Account__c = supportAccount.Id;
                lstUpdateEngagements.add(updateEng);
            }
            //add ship to contact as primary support account contact
            if(mapContractShipToUser.containskey(supportAccount.Contract__c)){ //<T02>
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId= mapContractShipToUser.get(supportAccount.Contract__c); //<T02>
                acr.AccountId = supportAccount.id;
                acr.Primary__c = true;
                acr.isActive = false; //<T01>
                acr.Access_Level__c = 'Read/Write';
                lstInsertSupportContacts.add(acr);
            }
        }

        //Update Support Account on Assets
        system.debug('lstUpdateAssets'+ lstUpdateAssets);
        if(lstUpdateAssets!= null && lstUpdateAssets.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateAssets);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()){
                    setAssetsUpdated.add(sr.getId());
                }
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->update of asset with support account failed', err.getMessage(), sr.getId());
                    }
                }
            }

        }

        //Update EP on Assets
        if(setAssetsUpdated?.size()>0){
            EntitledProductService.createEntitledProducts(setAssetsUpdated, null);
        }
        
        system.debug('lstUpdateEngagements'+ lstUpdateEngagements);

        if(lstUpdateEngagements!= null && lstUpdateEngagements.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateEngagements);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->update of asset with support account failed', err.getMessage(), sr.getId());
                    }
                }
            }

        }

        system.debug('lstInsertSupportContacts'+ lstInsertSupportContacts);

        if(lstInsertSupportContacts!= null && lstInsertSupportContacts.size()>0){
            Database.SaveResult[] srList = Database.Insert(lstInsertSupportContacts);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('CreateSupportAccountBatchHandler-->CreateSupportAccounts-->insert of support account contact failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }

    
        System.debug('Exit Method CreateSupportAccounts');

    }
}