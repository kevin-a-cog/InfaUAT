/*      Class:          ReactivateContractLinesController
@Author:        Sumitkumar Mittal
@Created Date:  28-June-2019
@Description:   QCA - 1309 - This class is being used for taking the contract Id and pull all 
Subscription Records which are not renewed by using the Lightning Quick action 
button on record detail page.
*/
/*
Change History
**********************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
Sumitkumar Mittal   8/15/2019   QCA-1442            Updated the design and base component as per JIRA.      T1
                                                    Updated the completed class and component.
Sumitkumar Mittal   9/17/2020   SalesRT-12204       Updated the reference for updated fields of Contract
Ambica              11/17/2020                      Remove ortoo references                                T03
Nishant             09/19/2023  SALESRT-15016       Split Contract - Defaults on child contracts           T04
***********************************************************************************************************
*/
public class ReactivateContractLinesController {
     
    /** 
* Get Fields in specified FieldSet
* @param typeName - SObject Name (i.e. Account, Contact, Opportunity, etc.)
* @param fsName - FieldSet Name 
* @return List of FieldSetMember Object 
*/
    @AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        for (Schema.FieldSetMember f: fieldSet) {
            fset.add(new FieldSetMember(f));
        }
        
        return fset;
    }
    
    //Defining the FieldSetMember to initiate the Fieldset properties in the component
    public class FieldSetMember {
        
        @AuraEnabled public Boolean DBRequired {get; set;}
        @AuraEnabled public String fieldPath {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public Boolean required {get; set;}
        @AuraEnabled public String type {get; set;}
        
        public FieldSetMember(Schema.FieldSetMember f){
            this.DBRequired = f.getDbRequired(); 
            this.fieldPath = f.getFieldPath(); 
            this.label = f.getLabel(); 
            this.required = f.getRequired(); 
            this.type = '' + f.getType(); 
        }
    }
    
    /** 
* Get all the Subscription records for the contract Id passed
* @param id : Contract Id
* @param queryString - FieldSet field API 
* @return List of SBQQ__Subscription__c Object 
*/    
    @AuraEnabled
    public static list<SBQQ__Subscription__c > fetchParentSubscriptionProducts(Id ContractId, String queryString) {
        List<SBQQ__Subscription__c > returnSubList = new List<SBQQ__Subscription__c >();
        List<SBQQ__Subscription__c > nonContractedSubscriptions = new List<SBQQ__Subscription__c >();
        String recordId = ContractId;
        //Fetch Parent Subscription records
        String qry = 'SELECT ' + queryString + ',SBQQ__Contract__r.SBQQ__RenewalOpportunity__c'+
            ',SBQQ__Contract__r.SBQQ__RenewalQuoted__c'+
            ',SBQQ__QuoteLine__r.Name'+
            ', SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c'+
            ', SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__c'+
            ',SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c'+
            ', (Select id, SBQQ__RenewedSubscription__c, SBQQ__Quote__r.RecordType.DeveloperName'+
            ',SBQQ__Quote__r.Primary_Order__r.SBQQ__Contracted__c, SBQQ__Quote__c '+
            'from SBQQ__RenewalQuoteLines__r) '+
            'from SBQQ__Subscription__c '+
            'where SBQQ__Contract__c =: recordId AND SBQQ__RequiredById__c = Null';
        returnSubList = Database.query(qry); 
        system.debug('returnSubList::::::'+returnSubList);
        //List of Subscriptions
        if(returnSubList != Null &&
           returnSubList.size() > 0) {
               for (SBQQ__Subscription__c sub: returnSubList) {
                   //Flag added to check if the subscription record needs to be released or not
                   Boolean addSubscriptionRecord = False;
                   system.debug('Subscription lines ::: '+sub);
                   system.debug(' Quote lines ::: '+sub.SBQQ__RenewalQuoteLines__r);
                   if(sub.SBQQ__Contract__r.SBQQ__RenewalQuoted__c) {
                       //Renewal Quote is created so need to check for the cancel lines only
                       if(sub.SBQQ__RenewalQuoteLines__r.size() == 0) {
                           //Condition stating : renewal lines have been created out of subscription
                           addSubscriptionRecord = True;
                       } else {
                           system.debug('Inside');
                           system.debug(' Quote lines  sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c ::: '+sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c);
                           system.debug(' Quote lines  subsub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c ::: '+sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c);
                           
                           system.debug(' sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c ::: '+sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c);
                           if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != Null &&
                              sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c != Null &&
                              sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__c != Null && 
                              sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c == True) {
                                  for (SBQQ__QuoteLine__c qle : sub.SBQQ__RenewalQuoteLines__r) {
                                      if(qle.SBQQ__Quote__c != sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c) {
                                          addSubscriptionRecord = True;
                                      } else {
                                          addSubscriptionRecord = False;
                                          break;
                                      }
                                  }
                              }
                       } 
                   }else {
                       //Renewal Quoted is false --> Early Renewal
                       addSubscriptionRecord = True; 
                   }
                   if(addSubscriptionRecord) {
                       nonContractedSubscriptions.add(sub);
                   }
               }
           }
        return nonContractedSubscriptions;
    }
    
    
    /** 
* Get all the Subscription records for the contract Id passed
* @param id : Subscriotion Ids 
* @return 
*/      
    @AuraEnabled
    public static String transferRecords(List<String> lstRecordId, Id contractId) {
        //This method will be invoked from a single contract as its being called from a lightning component
        //This will contain only 1 record as its being called from a lightning component and only 1 contract id will be passed
        List<Contract> recordToInsert = new  List<Contract>();
        //List<Contract> orginalContractUpdate = new List<Contract>();
        
        for(Contract originalContract : [SELECT Original_Contract__c,Business_Model__c,AccountId,Annual_Recurring_Revenue1__c,APXT_Redlining__Contract_Family_Parent__c,
                                      APXT_Redlining__Contract_Family_Root__c,APXT_Redlining__Primary_Document_Title__c,
                                      APXT_Redlining__Primary_Document__c,BillingAddress,BillingAddress_PSFTID__c,BillingCity,
                                      BillingCountry,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingName_PSFTID__c,
                                      BillingPostalCode,BillingState,BillingStreet,BilltoAccount__c,BillToContact__c,CompanySignedDate,
                                      CompanySignedId,ContractNumber,ContractTerm,Contract_Creation_Run__c,CurrencyIsoCode,CustomerSignedDate,
                                      CustomerSignedId,CustomerSignedTitle,Description,Dev_Renewal_Price_Rollup__c,Do_Not_Renew__c,
                                      EndDate,EndUserAccount__c,EndUserAddress_PSFTID__c,EndUserCity__c,EndUserContact__c,EndUserCountry__c,
                                      EndUserPostalCode__c,EndUserStateProvince__c,EndUserStreet__c,Legal_Entity__c,Name,
                                      // ortoo_e2a__Thread_Id__c,<T03>
                                      OwnerExpirationNotice,Pricebook2Id,PSFT_Contract_Number__c,Renewal_Type__c,
                                      SBQQ__AmendmentOpportunityRecordTypeId__c,SBQQ__AmendmentOpportunityStage__c,SBQQ__AmendmentOwner__c,
                                      SBQQ__AmendmentPricebookId__c,SBQQ__AmendmentRenewalBehavior__c,SBQQ__AmendmentStartDate__c,
                                      SBQQ__DefaultRenewalContactRoles__c,SBQQ__DefaultRenewalPartners__c,SBQQ__DisableAmendmentCoTerm__c,
                                      SBQQ__ExpirationDate__c,SBQQ__MasterContract__c,SBQQ__MDQRenewalBehavior__c,SBQQ__OpportunityPricebookId__c,
                                      SBQQ__Opportunity__c,SBQQ__Order__c,SBQQ__PreserveBundleStructureUponRenewals__c,SBQQ__Quote__c,
                                      SBQQ__RenewalForecast__c,SBQQ__RenewalOpportunityRecordTypeId__c,SBQQ__RenewalOpportunityStage__c,
                                      SBQQ__RenewalOpportunity__c,SBQQ__RenewalOwner__c,SBQQ__RenewalPricebookId__c,SBQQ__RenewalQuoted__c,
                                      SBQQ__RenewalTerm__c,SBQQ__RenewalUpliftRate__c,SBQQ__SubscriptionQuantitiesCombined__c,ShippingAddress,
                                      ShippingAddress_PSFTID__c,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,
                                      ShippingLongitude,ShippingName_PSFTID__c,ShippingPostalCode,ShippingState,ShippingStreet,
                                      Shipping_Email__c,ShipToAccount__c,ShipToContact__c,Software_Annual_Recurring_Revenue1__c,
                                      SoldAddress_PSFTID__c,SoldCity__c,SoldCountry__c,SoldPostalCode__c,SoldStateProvince__c,
                                      SoldStreet__c,SoldToAccount__c,SoldToContact__c,SpecialTerms,StartDate,Support_Annual_Recurring_Revenue1__c,
                                      SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c 
                                      FROM Contract
                                      where Id =: contractId]) {
                                          
                                          Contract clonedRecord = originalContract.clone();
                                          clonedRecord.SBQQ__RenewalForecast__c = False;
                                          clonedRecord.SBQQ__RenewalQuoted__c =False;
                                          clonedRecord.SBQQ__RenewalOpportunity__c =Null;
                                          clonedRecord.Original_Contract__c  = contractId;
                                          recordToInsert.add(clonedRecord);
                                          /*if(originalContract.SBQQ__RenewalForecast__c) {
                                                originalContract.SBQQ__RenewalForecast__c = False; 
                                                orginalContractUpdate.add(originalContract);
                                          }*/
                                      }
        
        List<SBQQ__Subscription__c> nonContractedSubscriptions = new List<SBQQ__Subscription__c>([Select id, SBQQ__Contract__c, Cancel_Reason__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,
                                                                                                  SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,
                                                                                                  SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.Primary_Order__c, 
                                                                                                  SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Ordered__c, 
                                                                                                  (Select id, SBQQ__RenewedSubscription__c, SBQQ__Quote__r.RecordType.DeveloperName,
                                                                                                   SBQQ__Quote__r.Primary_Order__r.SBQQ__Contracted__c, SBQQ__Quote__c 
                                                                                                   from SBQQ__RenewalQuoteLines__r 
                                                                                                   order by createdDate DESC) 
                                                                                                  from SBQQ__Subscription__c 
                                                                                                  where SBQQ__RootId__c IN: lstRecordId]);
        List<SBQQ__Subscription__c> updateSubscriptions = new List<SBQQ__Subscription__c>();
        
        if(nonContractedSubscriptions != Null && nonContractedSubscriptions.size() > 0) {
            try {
                //insert cloned contract;
                insert recordToInsert;
                //update the Subcription parent contract link
                for (SBQQ__Subscription__c sub : nonContractedSubscriptions) {
                    sub.SBQQ__Contract__c = recordToInsert[0].Id;
                    updateSubscriptions.add(sub);
                }
                
                //DML operation for the update
                update updateSubscriptions;
                
                Set<Id> contractIds = new Set<Id>();

                for(Contract contract : recordToInsert){

                    contractIds.add(contract.Id);
                }

                if(!contractIds.isEmpty()){
                    updateContracts(contractIds);
                }

                Return recordToInsert[0].Id;
            }catch (exception e) {
                system.debug('Exception :'+e.getMessage()) ;
                Return 'Fail';
            }
        } else {
            //Return fail is there are no records to be cloned as no non contracted subscription is present on the Contract
            return 'Fail';
        }
    }
    
    /**
     * @description : Method to update contract status
     * 
     * @param : contractIds - set of contract ids
     * 
     * @return : NA
     */
    @future
    public static void updateContracts(Set<Id> contractIds){

        List<Contract> recordsToUpdate = new List<Contract>();
        
        for(Id contractId : contractIds){

            Contract con = new Contract();
            con.Id = contractId;
            con.Status = 'Activated';
            recordsToUpdate.add(con);
        }

        if(!recordsToUpdate.isEmpty()){
            update recordsToUpdate;
        }
    }
}