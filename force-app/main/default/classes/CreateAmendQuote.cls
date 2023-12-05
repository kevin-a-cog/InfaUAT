/*Class Name - CreateAmendQuote
  Test Class - CreateAmendQuoteTest
  Description - Created of Project Elevate SALESRT-15880 & SALESRT-15482
*/
/*Change History
*******************************************************************************************************************************************************************************
ModifiedBy              Date             JIRA Ticket                  Description                                                                                      Tag
*******************************************************************************************************************************************************************************
Chandana Gowda         27-Jul-2023       SALESRT-17160            Check opty name length before update                                                              <T1>
*/
public with sharing class CreateAmendQuote {
    public static globalApexManager GAM = new globalApexManager();
    @TestVisible private static Id amendQuoteId;
    @TestVisible private static String testJson;
    public static Id createAmendQuoteFromContract(Id contractId){
        try{
            String quoteJSON = Test.isRunningTest() ? testJson : SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
            QuoteModel quote = (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
            System.debug('AMENDMENT QUOTE ID ::'+quote.record.get('Id'));
            System.debug('#### END ####');
            return (Id) quote.record.get('Id');
        }catch(Exception e){
            return e.getMessage();
        }
    }

    //called from LWC after selecting same date amendment type 
    //1. Creates an amendment quote
    //2. Links the quote to the NNB Opportunity where the amendment process initiated from.
    @AuraEnabled
    public static List<String> relinkAmendQuote(String contractId,String newOpportunityId, String amendType){
        List<String> result = new List<String>();
        try{
            Id quoteId = Test.isRunningTest() ? amendQuoteId : createAmendQuoteFromContract((Id)contractId);
            if(String.isNotBlank(quoteId)){
                relinkOpty(quoteId,newOpportunityId, amendType);
                result.add('Success');
                result.add((String)quoteId);
            }else{
                result.add('Failed');
                result.add(System.Label.Amend_API_Failure_Message);
            }
            return result;
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('CreateAmendQuote', e.getMessage(),'Exception in relinkAmendQuote: ');
            result.add('Failed');
            result.add(e.getMessage());
            return result;
        }
    }

    @future
    public static void relinkOpty(Id quoteId,Id newOpportunityId, String amendType){
        String relinkStatus = RelinkOpptyController.submitQuoteDetails(quoteId,newOpportunityId, amendType, '');
    }
    
    //called from LWC after clicking on Early Renew button on Opportunity Detail Page (Renewal Rec type) 
    //1. Creates an amendment quote
    //2. Updates the opportunity details with default values
    //3. Updates Quote details to run early terminate logic.
    @AuraEnabled
    public static List<String> earlyRenew(Id oppId){
        List<String> result = new List<String>();
        try{
            Opportunity opp = [Select SBQQ__RenewedContract__c from Opportunity where Id = :oppId Limit 1];
            if((opp <> NULL && opp.SBQQ__RenewedContract__c <> NULL) ||  Test.isRunningTest()){
                Id quoteId = Test.isRunningTest() ? amendQuoteId : createAmendQuoteFromContract(opp.SBQQ__RenewedContract__c);
                if(String.isNotBlank(quoteId)){
                    updateOpptyDetails(quoteId); 
                    earlyterminateLines(quoteId);
                    result.add('Success');
                    result.add((String)quoteId);
                }
                else{
                    result.add('Failed');
                    result.add(System.Label.Amend_API_Failure_Message);
                }
            }else{
                    result.add('Failed');
                    result.add(System.Label.InvalidEearlyRenewInitiation);
            }
            return result;
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('CreateAmendQuote', e.getMessage(),'Exception in earlyRenew: ');
            result.add('Failed');
            result.add(e.getMessage());
            return result;
        }
    }

    @future
    public static void earlyterminateLines(Id quoteId){
        try{
            SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(Id = quoteId);
            quoteRec.Group__c = 'Early Terminate'; //this value will be reset on quote record after early terminate process is complete.
            quoteRec.SBQQ__Primary__c = false;
            quoteRec.Amend_Type__c = 'Early Renewal - Extend End Date';
            update quoteRec;
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('CreateAmendQuote', e.getMessage(),'Exception in earlyterminateLines: ');
        }
    }

    public static void updateOpptyDetails(Id quoteId){
        try{
            SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__Opportunity2__c,  SBQQ__MasterContract__r.ARR_Cloud__c, SBQQ__MasterContract__r.ARR_Perpetual_Support__c , 
                                    SBQQ__MasterContract__r.ARR_DaaS__c, SBQQ__MasterContract__r.ARR_OnPrem_Subscription__c, SBQQ__MasterContract__r.ARR_Subscription_Support__c,
                                    SBQQ__Opportunity2__r.Name
                                    FROM SBQQ__Quote__c WHERE Id = :quoteId limit 1];
            if(quote <> NULL){
                Id renewalOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
                Opportunity amendOpp = new Opportunity();
                amendOpp.Id = quotE.SBQQ__Opportunity2__c;
                //copy the ARR amounts from master contrat on the Quote.
                amendOpp.OARR_Cloud1__c = quote.SBQQ__MasterContract__r.ARR_Cloud__c;
                amendOpp.OARR_Perpetual_Support1__c = quote.SBQQ__MasterContract__r.ARR_Perpetual_Support__c;
                amendOpp.OARR_DaaS1__c = quote.SBQQ__MasterContract__r.ARR_DaaS__c;
                amendOpp.OARR_OnPrem_Subscription1__c = quote.SBQQ__MasterContract__r.ARR_OnPrem_Subscription__c;
                amendOpp.OARR_Subscription_Support1__c = quote.SBQQ__MasterContract__r.ARR_Subscription_Support__c;
                amendOpp.ARR_Cloud__c = amendOpp.OARR_Cloud1__c;
                amendOpp.ARR_DaaS__c = amendOpp.OARR_DaaS1__c;
                amendOpp.ARR_Perpetual_Support__c = amendOpp.OARR_Perpetual_Support1__c;
                amendOpp.ARR_Subscription_Support__c = amendOpp.OARR_Subscription_Support1__c;            
                amendOpp.ARROnPrem_Subscription1__c = amendOpp.OARR_OnPrem_Subscription1__c;
                amendOpp.recordTypeId = renewalOppRecTypeId;//update recordtype as Renewal Opportunity.
                amendOpp.stageName = 'Initiated';
                amendOpp.Renewal_Status__c = 'Building quote-Paperwork not sent';
                //-------------------------------------------------------------------<T1> : Added length check 
                amendOpp.Name = quote.SBQQ__Opportunity2__r.Name.containsIgnoreCase('Amend') ? (quote.SBQQ__Opportunity2__r.Name.replace('Amend', 'Early Renew').length() <= 120 ? quote.SBQQ__Opportunity2__r.Name.replace('Amend', 'Early Renew'): quote.SBQQ__Opportunity2__r.Name) : quote.SBQQ__Opportunity2__r.Name;//SALESRT-16878 CR - Early Renewal Opportunity Naming Convention
                //-------------------------------------------------------------------<T1/>
                globalApexManager.avoidRecursion('OpportunityBeforeUpdate');
                globalApexManager.avoidRecursion('OpportunityAfterUpdate');
                globalApexManager.avoidRecursion('OpportunityLineItemAfterUpdate');
                update amendOpp;
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('CreateAmendQuote', e.getMessage(),'Exception in updateOpptyDetails: ');
        }
    }
}