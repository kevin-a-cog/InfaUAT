/*
Class:          QuoteTriggerHandler
@Author:        Thejaswini Sattenapalli
@Created Date:  07/25/2017
@Description:   handler class for SBQQ__Quote__c triggers
*/
/*
Change History
*****************************************************************************************************************************************
ModifiedBy          Date        Ticket No.          Requested By        Description                                                 Tag
Kendra Claiborne    09/28/2017  -                   Prasanth            Updated how legal entity multi country fields were being referenced since this is a semi-colon delimited string
Kendra              10/17/2017  -                   Prasanth            Added Trigger Recursion Framework to this class and removed from QuoteAfterInsert to allow the logic to be ran
twice in the scenario for Renewal Quotes that require the Related Contract to be populated on the Quote since
on the first run to the Renew Contract a ghost Quote is created and deleted
Vivek Warrier       10-Nov-2017 TKT-000811          Prasanth             Edited the mapping of Countries to avoid case-sensitivity       <T02>
Lokesh kumar        15-Nov-2017 TKT-000892          Prasanth             Added a condition on update to bypass the legal entity updete   <T03>
if Shipping country is not modified
Kendra Claiborne    11/15/2017                      Prasanth             Added null checkers to cross reference fields
Kendra Claiborne    11/21/2017                      Prasanth             Added condition to set BillToName and ShipToName to blank if the Quote Type = New
Kendra Claiborne    12/13/2017                      Anil Solanki         Added additional criteria to handleAfterInsert and handleAfterUpdate to populate the Price Book in a Renew or Amendment 
scenario if the Contract's Quote's PriceBook2Id and PriceBook2 custom fields are populated
Kendra Claiborne    01/03/2018                      Prasanth P.          Added logic to populate QLE's End Date Localized based on the related Quote's Territory during Before Update Context
Kendra Claiborne    01/16/2018                      iLabs                Added logic to resolve SOQL 101 error experienced in UAT during 1/9/2018 Dot Release
Kendra Claiborne    02/2/2018   TKT-001010          Sriram Gopalan       Modified logic to calculate the End Date Localized in a Leap Year scenario.
The logic takes the new date and subtractes one day, which will roll to the 
previous month if the date defined is at the beginning of the month 
(so rather than getting 2/0/19 you will see 1/31/19)
Anil Solanki        02/08/2018  TKT-001070           Sriram Gopalan      Added Logic to check set Related contract on Quote on Insert for Renewal Scenario <T04>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Moved code to 'populate Legal Entity based on Ship To Country' to before Context. 
And create new methods for Code related to Amendment and renewal Quotes<T12>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Moved logic to set Quote values from 'Set Quote values' Process builder to Before Insert trigger.
Created following new methods for the same-setValuesForNewQuote(), setValuesForRenewalQuote(), setValuesForAmendQuote(), setValuesForAllQuoteTypes()<T06>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Moved logic to update Quote values from 'Update Quote Values' Process Builder to Before Update trigger.
Created a new method updateQuoteValues() for the same.<T07>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Fix for TKT-001070.Moved Code to Update Related Contract Field on Quote and Map Related Contract's parent Quote and Order Values to Renewal Quote, to Before Update context.
New Method Created for this - setRenewalQuoteValuesFromContract() <T08>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Moved Code to Map Master Contract's parent Quote and Order Values to Amendment Quote, to Before Update Context.
New Method Created for this - setAmendQuoteValuesFromContract() <T09>
Ritika Gupta        04/04/2018  TKT-001070           Nitin Gupta         Optimized code of updateQuoteLine() method<T10>
Ritika Gupta        04/05/2018  TKT-001070           Nitin Gupta         Commented 'handleAfterUpdate' handler method<T11>
Vivek Warrier       02-Apr-2018 US-2180             Justin Jarus         Pulling address details onto Quote from Contact, not Account    <T05>  
Ritika Gupta        04/12/2018  SALESRT-3284         Nitin Gupta         Making Bill to Name & Ship to Name Blank for Renewal & Amendment Quotes. <T13>
Vivek Warrier       15-May-2018 US-2272              Justin Jarus        Populating the 'Sold To Attention To' field for the SOG Coversheet  <T14>
Ritika Gupta        07/06/2018  SALESRT-3487                             Moved the codeblcok related to Pricebook assignment for LATAM, before EA.<T15>
Ritika Gupta        16-May-2018 TKT-001265           Bhanu               Added logic to set Quote Type as 'Renewal' on New Quote SAVE, if Opportunity Record Type = Renewal.<T16>
Anil Solanki        15-Aug-2018 CM-6                 Kevin Hanna         Added Logic to Populate Quote Fields from Contract instead of Order/Quote in case on Migrated Contract<T17>
Ritika Gupta        04-Sep-2018  CM-35                Prasanth           Added code in QuoteBeforeInsert -> setValuesForRenewalQuote to populate SBQQ__SubscriptionTerm__c on renewal quote created 
from Migrated Contract. Will remove this code later if needed.<T18>
Sumit Mittal        4-Dec-2018  QCA-290/325          Q2C 2a              Added the code to update the checkbox DEV_Override_Default_is_Null__c, Dev_Partner_Override_Default_is_Null__c -- checkbox to be unchecked when the 
length of Override_Default_Language__c is greater than zero else check it <T19>
Vivek Warrier       07-Dec-2018  SALESRT-3939         Prasanth           To fix the issue with the Bill to Account Name not appearing in the Exhibit A <T20>
Anil Solanki        22-Jan-2019  QCA-377            Q2C 2a               Logic to update Amendment ARR fields on Quote from Process Builder to Trigger<T21>
Ritika Gupta        23-Jan-2019  SALESRT-3955         Ritika             Added logic to nullify End date on Renewal quotes and populate subscription term for non-Migrate contracts also.<T22>
Vivek Warrier       08-Feb-2019  SALESRT-4010        Keerthana           Considering the QLI Subsc Term before the Quote Subsc Term for End Date Localized population <T23>
Sumit Mittal        06-Feb-2019  QCA-520             Q2C 2b              Logic to populate the Coversheet Checklist type for Renewed Quote from the original related Quote. <T24>
Anil Solanki        27-Mar-2019  QCA-801             Q2c 2b              Added the code to update the checkbox DEV_Special_Remarks_Is_Null__c, DEV_Partner_Special_Remarks_Is_Null__c -- checkbox to be unchecked when the
length of Special_Remarks1__c,Partner_Special_Remarks__c  is greater than zero respectively else check it <T25>
Vivek Warrier       03-Apr-2019  NA (Tech Debt)      NA                  Changed the code to add the condition (when there is a change in Subc Term/Start Date/End Date) for
triggering QLE update from Quote <T26> 
Ritika Gupta        06-May-2019  SALESRT-4071        May Build           Added optimized code to fix Amend Address fields issue for new and Migrated contracts.
Commented existing code block.
And added mapping for PO number and Subscription term to default values on Amend quote<T27>
Vivek Warrier       10-Jun-2019  SALESRT-4207        Liz Matthews        Defaulting Billing Frequency to Annual and Show Dates to True for Renewal Quotes <T28>
Ritika Gupta        9-June-2019  SALESRT-4289        July Build          Fixed End date Localized for LATAM and updated contains to startsWith for checking territory<T8>
Sumit Mittal        12-Jun-2019  QCA-1238            Q2C 2d              Added the code to populated Contracted Uplift for renewal and amend scenarios <T29>
Sumit Mittal        05-Jun-2019  QCA-1229            Q2C 2d              Commented the code to set the pricebook as per territory. <T30>
Sumit Mittal        23-Jul-2019  QCA-1105            Q2C 2d              Updated method updateQuoteLines and also optimized it to get the all the quotelines.<T31>
Todd Abraham        25-Jul-2019  QCA-1407            Q2C 2d              Added code to populate Price Book based on PriceBook Id until CPQ is upgraded to version 214 or higher <T32>
Vivek Warrier       27-Sep-2019  SALESRT-4287        Sales Oct           Added code to populate the Discount Approval User who is used to populate SalesRep/Acct Owner  <T33>
according to the Quote Type
Kiran G             21-Oct-2019  INC0324845          OCT                 Updated the format for LATAM as DD/MM/YYYY instead of  MM/DD/YYYY   <T34>
Sumit Mittal        30-Oct-2019  SalesRT-11133       OCT                 Added the mapping for the Business model from Contract to Renewal and Amend Quote created and Sub type (Quote) to amend Quote   <T35> 
Vivek Warrier       08-Jan-2020  SALESRT-11353       Liz Matthews        Splitting the terrtory APJ to AP and JP    <T36>    
Wasim Akram         14-Jan-2020  SALERT-11149        Liz                 Handled an error which was occuring since the Quote__r field values is used 
to assign values to variables without querying from Contract <T37>
Ambica              4-Mar-2020  SALESRT-11447        MR                  Default Uplift Notes, Uplift Method and Uplift applied from contract /previous quote <T40>
Sumit Mittal        15-Apr-2020 SalesRT-11830        May Build           Default the owner and Subtype field from the Opportunity for the Admin flow. <T41>
RamEsh M S          15-May-2020  SALESRT-12035       May Build           Fix to populate Bill To Account Output and End User Account Text on Renewals <T42>
RamEsh M S          24-JUN-2020  SALESRT-12173       July Build          Copy Custom Payment Term from Original to Amendment   <T43>
Sumit Mittal        17-Sept-2020 Salesrt-12204       Sept Build          Updated the code for the reference to Contract fields newly updated fields 
                                                                         Annual_Recurring_Revenue__c, Software_Annual_Recurring_Revenue__c, Support_Annual_Recurring_Revenue__c.
Chandana Gowda      05 Nov 2020  SALESRT 12290      Nov build 20         Added logic to update the subscription Lines status on creation of renewal quote from contract     <T43-1>
Chandana Gowda      05 Nov 2020  SALESRT 12290      Nov build 20         Removed the logic to update the cancel reason <T44> 
Anil Solanki        5-NOV-2020   SALESRT-12316      Nov Build           Copy Infa Compliance Flag from Oppty to Compliance Settlement on Quote<T46>  
Chandana Gowda      19 Nov 2020  SALESRT-12584      Nov Build 20         Remove logic to to copy signature block values from previous quote <T47> 
Ramya Ravi          11 Dec 2020  SALESRT-12490      Jan Build 20         Prevent order creation if Quote Line Start Date < Quote Start Date  <T48> 
Ambica Pyati        18 Dec 2020  PSA-436            PSA                  Populate PSA Approver fields on quote <T49>
Chandana Gowda      24 Feb 2021  TAX-21             Tax Project 21       Create CMS Request Enagagement record when a quote is create/Sold to Account is updated <T50>
Ramya Ravi          01 Apr 2021  SALESRT-11918      Apr Build 21         Updated the sequencing of setAmendQuoteValuesFromContract method with the upgrade services settings.   <SALESRT-11918>
Ramya Ravi          01 Apr 2021  SALESRT-12220      Apr Build 21         Update the Owner of the Qoute as per the Contracts 'Renewal Quote Owner' feild value   <SALESRT-12220>
Chandana Gowda      16 Mar 2021  TAX-105            Tax Project 21       Upsert ERP Site Records when Ship to Address is updated <T51>
Chandana Gowda      22-APR-2021  SALESRT-12736      May Build 21         End Date Localization for Territories FEDOPS Territories                <T12736>
Ramya Ravi          22 Apr 2021  SALESRT-12220      May Build 21         Remove the logic to update the subscription Lines status on creation of renewal quote from contract     <SALESRT-12849>
Chandana Gowda      30 Apr 2021  F2A-370            Sarojini B           Added the logic to update ES Approver fields on creation of all types of quote     <F2A-370>
Nishit Sardessai    28 Jul 2021  I2c-1318           Aug Build 21         Added logic to create Quote Summary on Approval Status 'Pending' or 'Approved'     <I2C-1318>
Chandana Gowda      24 Aug 2021  TAX-197            Kain Lau             CMS notification is trigger when Opportunity Stage is at 50% or higher <TAX-197>
Wasim Akram        09 Aug 2021  SALESRT-13090      Sep Build 21         Sync Route To Market and Detail RTM field between Oppty and Quote <SALESRT-13090>
Chandana Gowda      27 Aug 2021  SALESRT-13260      Sep Build 21         EndDate Localization Issue - Allowing rerun when Apply_PO_to_All_Lines__c is checked <T13260>
Nishit S            22 Sep 2021     TAX-200         Oct Build 21        Invoke ONESOURCE only when generating Output Documents upon initial Quote creation      <TAX-200> 
                                                                        or after editing Quotes based on criteria
Chandana Gowda    23 Sep 2021  SALESRT-13270     Oct Build 21      Removing the logic to update End date Localized field <T13270>
Wasim Akram      05 Oct 2021 SALESRT-13387    Oct Build 21    RTM: Secondary Partner field to carried over to order and contract <SALESRT-13387>
Wasim Akram      25 Nov 2021  SALESRT-13225    Jan Build 22    RTM automation for quote BillTo/ShipTo/SoldTo/EndUser <SALESRT-13225>
Ramya Ravi       21 April 2021  TAX-249        May Build 22    Update the tax language logic to display on Output Documents when Exempt Status is blank <TAX-249>
Puneet Lohia        20 Apr 2022 SALESRT-13687   May Build 22    RTM Automation : Updates for edit scenario      <SALESRT-13687>
Puneet Lohia        20 Apr 2022 SALESRT-13705   May Build 22    RTM Automation : Updates for creation for Renewal & Amended Quotes      <SALESRT-13705>
Puneet Lohia        20 Apr 2022 SALESRT-13673   May Build 22    RTM Automation : Update RTM on opportunities for primary quote  <SALESRT-13673>
Anusha Akella    27 Apr 2022  SALESRT-13635     May Build 22     Clone Partner Object related list for Amend and Renewed Quote(s),comment secondary Partner <SALESRT-13635>
Ramya Ravi     20 May 2022    TAX-274           June Build 22        Update the tax language logic to display on Output Documents for Amend quotes  <TAX-274>  
Nishit S    16 Jun 2022    TAX-273              July Build      When updating the Renewal Quote Ship to Country to lower case, Tax Information Tab disappears    <TAX-273>
Nishit S    7 AUG 2022      I2C-1626            Aug Build               Material Rights Future Renewals Pricing - Alert Notification                             <I2C-1626>     
Puneet Lohia           3/3/2023        SALESRT-14838   Validate IPUs between Quote and IPU Estimator   <SALESRT-14838>
Nishant Bansal         19/6/2023       SALESRT-13388   to call the notification framework
VENKATESH BALLA 06-08-2023  SALESRT-15482       PROJECT ELEVATE - JULY'23 Automate Amendment Quote (Early Renewal/Coterm Long) from Opportunity <SALESRT-15482>
VENKATESH BALLA 06-08-2023  SALESRT-16909       PROJECT ELEVATE - JULY'23 CR - End Date Validation Criteria for Early Renewal <SALESRT-16909>
Chandana Gowda  15-07-23    SALESRT-16984       PROJECT ELEVATE - JULY'23 Restrict Delete capability <SALESRT-16984>
Nishant Bansal  24/7/23     SALESRT-14285       RTM Automation: Legal Entity Handling on Onchange
Sreerekha       19 JUL 2023 SALESRT-15522       Introduce Additional Ship to Contact & Email on Quote                         <SALESRT-15522>
Nishit S    7 JUL 2023        SALESRT-15481     Ability for Reps to Self Quote - Pilot 
*****************************************************************************************************************************************
*/
/*
------------------------------------------------------------------------------< T01>
//Changes done
//
------------------------------------------------------------------------------</T01>
*/
public class QuoteTriggerHandler{
    
    public static String FROM_INSERT = 'FROM_INSERT';
    public static String FROM_UPDATE = 'FROM_UPDATE';
    public static globalApexManager GAM = new globalApexManager();
    private static Boolean IS_INSERT = false;//<T09></T09>
    public static Integer beforeUpdateCount = 0;
    /*
Method Name : handleBeforeInsert,
* @param lstTriggerNew - list of new SBQQ__Quote__c
* @return return-void
* @throws exception - NA
This method call from 'QuoteBeforeInsert' Trigger on SBQQ__Quote__c Object
*/
    
    public static void handleBeforeInsert(List<SBQQ__Quote__c> lstTriggerNew){
         
        //updateSBQQ_Quote(lstTriggerNew); <SALESRT-13225> Changed the method parameters
        updateSBQQ_Quote(lstTriggerNew, FROM_INSERT, null, null);// <SALESRT-13225>
        updateQuoteLegalEntity(lstTriggerNew, null);//<T12></T12>    
        
        //-----------------------------------------------------------<T06>
        List<SBQQ__Quote__c> listNewQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listRenewalQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listAmendQuotes = new List<SBQQ__Quote__c>();
        
        //---------------------------------------------------------------------------------------------------------------------<T16>
        Set<Id> setOpportunityIds = new Set<Id>();
        Id renewlOppRecordTypeId;
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        
        If(rtMapByName.containsKey(Label.Renewal_Opportunity)){
            renewlOppRecordTypeId = rtMapByName.get(Label.Renewal_Opportunity).getRecordTypeId();
        }
        system.debug('recTypeId:'+renewlOppRecordTypeId);
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__Opportunity2__c != null && oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New){
                setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);
            }
        }
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        if(setOpportunityIds.size() > 0){
            mapOpportunity = new Map<Id, Opportunity>([Select Id, RecordTypeId from Opportunity where Id in : setOpportunityIds]);
        }
        //---------------------------------------------------------------------------------------------------------------------</T16>
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            //---------------------------------------------------------------------------------------------------------------------<T16>
            if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New && oSBQQ_Quote.SBQQ__Opportunity2__c != null && mapOpportunity.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).RecordTypeId == renewlOppRecordTypeId){
                oSBQQ_Quote.SBQQ__Type__c = Label.Quote_Type_Renewal;
            }
            //---------------------------------------------------------------------------------------------------------------------</T16>
            
            if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New || oSBQQ_Quote.RecordTypeId == Label.New_Quote_Record_Type){
                listNewQuotes.add(oSBQQ_Quote);
            }else if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Renewal){
                listRenewalQuotes.add(oSBQQ_Quote);    
            }else if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Amendment){
                IS_INSERT = true;
                listAmendQuotes.add(oSBQQ_Quote);
            }
        }
        
        PSASetValuesForAllQuotes(lstTriggerNew);//<T49>
        
        setValuesForAllQuoteTypes(lstTriggerNew);
        if(listNewQuotes.size() > 0){
            setValuesForNewQuote(listNewQuotes);   
        }
        if(listRenewalQuotes.size() > 0){
            setValuesForRenewalQuote(listRenewalQuotes);   
        }
        if(listAmendQuotes.size() > 0){
            setValuesForAmendQuote(listAmendQuotes);
            setAmendQuoteValuesFromContract(listAmendQuotes, null);   //<SALESRT-11918>
        }
        updateTaxApplicable(lstTriggerNew);//<TAX-249> <TAX-274>
        //-----------------------------------------------------------</T06>        
    }
    
    
    /*
    Method Name : handleAfterInsert,
    * @param mapNew - Map<Id,SBQQ__Quote__c>
    * @return return-void
    * @throws exception - NA
    this method call from 'QuoteAfterInsert' Trigger on SBQQ__Quote__c Object, it will create a CMS Request Enagement Record if necessary
    */   
    
    public static void handleAfterInsert(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        //----------------------------------------------------------------------------------------------<T50>
        List<SBQQ__Quote__c> lstQuotesCMSRequest = new List<SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> mapNewQuotes = new Map<Id, SBQQ__Quote__c>();
        for(SBQQ__Quote__c quoteRec:mapNew.values()){
            if((quoteRec.SBQQ__Type__c == 'Quote'||quoteRec.SBQQ__Type__c == 'Renewal') && quoteRec.Business_Unit__c == 'US001' && quoteRec.SBQQ__Opportunity2__c != null &&(quoteRec.SoldToAccount__c != null || quoteRec.BilltoAccount__c != null) && quoteRec.SBQQ__ShippingCountry__c != null){
                lstQuotesCMSRequest.add(quoteRec);
            }
            if (quoteRec.SBQQ__Type__c == 'Renewal' || quoteRec.SBQQ__Type__c == 'Amendment') {
                mapNewQuotes.put(quoteRec.Id, quoteRec);
            }

        }
        if(!lstQuotesCMSRequest.isEmpty()){            
            createCMSRequest(lstQuotesCMSRequest);
        }
        //----------------------------------------------------------------------------------------------</T50>        
        //<SALESRT-13635>
        if (!mapNewQuotes.isEmpty()) {
            cloneRTMPartnerAccounts(mapNewQuotes);
        }
        
        callNotificationService(mapNew.values(), mapOld);
    }
    
    /*
    * Method Name : cloneRTMPartnerAccounts
    * @param mapNew - newMap
    * Jira Request: <SALESRT-13635>
    * @return return-void
    * @throws exception - NA
    This method would be called from 'handleAfterInsert' method to clone the
    RTM Partner Accounts from original quote to renewal or amendment quotes on creation.
    */  
    public static void cloneRTMPartnerAccounts(Map<Id,SBQQ__Quote__c> mapNew){
        Set<Id> setOriginalQuoteIds = new Set<Id>();
        Map<Id, Id> mapNewQuoteToOriginal = new Map<Id, Id>();
        List<RTM_Partner_Account__c> lstPartnerAccoutsToInsert = new List<RTM_Partner_Account__c>();
        for(SBQQ__Quote__c quoteRec : [Select Id,SBQQ__Type__c,Related_Contract__c,SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__c,SBQQ__MasterContract__c,Related_Contract__r.SBQQ__Quote__c,SBQQ__MasterContract__r.SBQQ__Quote__c from SBQQ__Quote__c where Id in: mapNew.keySet()]){
            if(quoteRec.SBQQ__Type__c == 'Renewal' || quoteRec.SBQQ__Type__c == 'Amendment'){
                if((quoteRec.SBQQ__Opportunity2__c != null && quoteRec.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != null && quoteRec.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__c != Null)){
                    setOriginalQuoteIds.add(quoteRec.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__c);
                    mapNewQuoteToOriginal.put(quoteRec.Id, quoteRec.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__c);
                }
                if(quoteRec.SBQQ__MasterContract__c != null && quoteRec.SBQQ__MasterContract__r.SBQQ__Quote__c != null){
                    setOriginalQuoteIds.add(quoteRec.SBQQ__MasterContract__r.SBQQ__Quote__c);
                    mapNewQuoteToOriginal.put(quoteRec.Id, quoteRec.SBQQ__MasterContract__r.SBQQ__Quote__c);
                }
            }
        }
        if(!setOriginalQuoteIds.isEmpty()){
            Map<Id, SBQQ__Quote__c> mapOriginalQuotes = new Map<Id, SBQQ__Quote__c>([Select Id,(Select Id,Partner_Account__c,Tier__c from RTM_Partner_Accounts__r) from SBQQ__Quote__c where Id in:setOriginalQuoteIds]);
            for(Id quoteId : mapNewQuoteToOriginal.keyset()){
                Id originalQuoteId =  mapNewQuoteToOriginal.get(quoteId);
                if(mapOriginalQuotes.containsKey(originalQuoteId)){
                    for(RTM_Partner_Account__c partnerAccount : mapOriginalQuotes.get(originalQuoteId).RTM_Partner_Accounts__r){
                        RTM_Partner_Account__c partnerAccClone = partnerAccount.clone();
                        partnerAccClone.Quote__c = quoteId;
                        lstPartnerAccoutsToInsert.add(partnerAccClone);
                    }
                }
            }
        }
        if(!lstPartnerAccoutsToInsert.isEmpty()){
            try{
                insert lstPartnerAccoutsToInsert;
            } catch(Exception e){
                GAM.CreateLogs('QuoteTriggerHandler.cloneRTMPartnerAccounts', lstPartnerAccoutsToInsert, 'lstPartnerAccoutsToInsert');
            } 
        }
    }

    /*
    * Method Name : updateSubsStatus
    * @param mapNew - newMap,oldMap
    * @return return-void
    * @throws exception - NA

    This method call from 'QuoteAfterUpdate' Trigger on SBQQ__Quote__c Object to update the 
    subscription status to renewed on renwal quote creation
    */     
    //-------------------------------------------------------------------------------------<T43-1>
    // // commented as part of <SALESRT-12849> starts
 /*   public static void updateSubsStatus(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        
        set<Id> setOppId = new set<Id>();
        List<Contract> lstContractUpdate = new List<Contract>();
        for(SBQQ__Quote__c quoteRec : mapNew.values()){
            if(quoteRec.SBQQ__Type__c == 'Renewal' && quoteRec.SBQQ__Opportunity2__c!= null){
                setOppId.add(quoteRec.SBQQ__Opportunity2__c);
            }
        }
        
        if(!setOppId.isEmpty()){
            Map<Id,Contract> mapContractToUpdate = new Map<Id,Contract>([SELECT Id FROM Contract WHERE SBQQ__RenewalOpportunity__c IN :setOppId]);            
            if(!mapContractToUpdate.isEmpty()){
                for(Contract conRec:mapContractToUpdate.values()){
                    Contract contRec = new Contract(Id = conRec.Id);
                    contRec.Contract_Status_Trigger_Time__c = System.now();
                    lstContractUpdate.add(contRec);
                }
            }
            
            if(!lstContractUpdate.isEmpty()){
                try{
                    Database.SaveResult[] srList = Database.update(lstContractUpdate, false);
                } catch(Exception e){
                    GAM.CreateLogs('QuoteTriggerHandler.updateSubsStatus', lstContractUpdate, 'lstContractUpdate');
                }
            }
        }
    } 
    //-------------------------------------------------------------------------------------</T43-1>   
    */
     // commented as part of <SALESRT-12849> ends  
    
    /*
* Method Name : handleBeforeUpdate
* @param mapNew - Map<Id,SBQQ__Quote__c>
* @return return-void
* @throws exception - NA
This method call from 'QuoteBeforeUpdate' Trigger on SBQQ__Quote__c Object
*/ 
    public static void handleBeforeUpdate(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        
        preventOrderCreation(mapNew, mapOld);//<T48> 
        manageQuoteAddress(mapNew, mapOld);//<T05></T05><SALESRT-14833><SALESRT-15062>
        updateQuoteLegalEntity(mapNew.values(), mapOld);//<T12></T12>        
        updateQuoteValues(mapNew.values(), mapOld);//<T07></T07>
        updateSBQQ_Quote(mapNew.values(), FROM_UPDATE, mapNew, mapOld);
       
        //-----------------------------------------------------------<T08><T09>
        List<SBQQ__Quote__c> listRenewalQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listAmendQuotes = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listUpdateTaxApplicable = new List<SBQQ__Quote__c>();//<TAX-249>
        for(SBQQ__Quote__c oSBQQ_Quote : mapNew.values()){
            if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Renewal){
                listRenewalQuotes.add(oSBQQ_Quote);
            }else if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Amendment){
                listAmendQuotes.add(oSBQQ_Quote);
            }
        }
        
        if(listRenewalQuotes.size() > 0){
            setRenewalQuoteValuesFromContract(listRenewalQuotes, mapOld);   
            // updateSubsStatus(mapNew,mapOld); //<T43-1/> //  <SALESRT-12849>
        }
        if(listAmendQuotes.size() > 0){
            setAmendQuoteValuesFromContract(listAmendQuotes, mapOld); 
        }
        //-----------------------------------------------------------</T08></T09>
        //updateQuoteLine(mapNew, mapOld);  //Commenting as part of <T13270>
        
        //<TAX-200>
        for(SBQQ__Quote__c quote : mapNew.values()){
            if(quote.Tax_Update_Status__c != 'Compute Tax'){
                for(Schema.FieldSetMember fsm:SObjectType.SBQQ__Quote__c.FieldSets.Update_Tax.getFields()){
                    if(quote.get(fsm.getFieldPath()) != mapOld.get(quote.Id).get(fsm.getFieldPath())){
                        quote.Tax_Update_Status__c = 'Compute Tax';
                        break;
                    }
                }
            }
            //<TAX-249> starts               
            if(quote.SBQQ__ShippingCountry__c != mapOld.get(quote.Id).SBQQ__ShippingCountry__c  
               || quote.Legal_Entity__c != mapOld.get(quote.Id).Legal_Entity__c                
              )               
            { 
               listUpdateTaxApplicable.add(quote);  
            }//<TAX-249> ends   
        }
        //</TAX-200>
        
        for(SBQQ__Quote__c sbqqQuote : mapNew.values()){ //<I2C-1318>
            if((sbqqQuote.ApprovalStatus__c == 'Pending') || (sbqqQuote.ApprovalStatus__c == 'Approved') && !sbqqQuote.SBQQ__Ordered__c){
                DnbAutomation.upsertQuoteSummary(new List<Id>{sbqqQuote.Id});
            }
            if(sbqqQuote.SBQQ__Ordered__c && (mapOld.get(sbqqQuote.Id).SBQQ__Ordered__c != mapNew.get(sbqqQuote.Id).SBQQ__Ordered__c) && !System.isFuture()){ //I2C-1626: Check Material Rights
                CheckMaterialRights.checkmaterialRightsFuture(new List<Id>{sbqqQuote.Id});
            }
        }
        if(listUpdateTaxApplicable.size()>0)
        updateTaxApplicable(listUpdateTaxApplicable);//<TAX-249>
        validateEndDateOnEarlyRenewal(mapNew.values(), mapOld);//SALESRT-15482
    }
    /*//<T48> 
    Method Name : preventOrderCreation,
    * @param mapNew - list of new SBQQ__Quote__c
    @param mapOld - list of old SBQQ__Quote__c
    * @return return-void
    * @throws exception - NA
    This method call from 'QuoteBeforeUpdate' Trigger on SBQQ__Quote__c Object
    before Update a  Record This method Will validate if Quote Line Start Date < Quote Start Date
    */     
    
     private static void preventOrderCreation(Map<Id,SBQQ__Quote__c> mapNew, Map<Id,SBQQ__Quote__c> mapOld){
                
        Map<Id,Date> MapofQuoteIdtoDate = new Map<Id,Date>();
       // Set<Id> SetofQuoteIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote : mapNew.values()){  
               system.debug('old ordered'+mapOld.get(quote.Id).SBQQ__Ordered__c);
            system.debug('new ordered'+quote.SBQQ__Ordered__c);
           if(mapOld.get(quote.Id).SBQQ__Ordered__c != quote.SBQQ__Ordered__c)
           {MapofQuoteIdtoDate.put(quote.id,quote.SBQQ__StartDate__c);}
        }
         for(SBQQ__Quote__c quote : mapNew.values())
         { if(MapofQuoteIdtoDate.containsKey(quote.id))
         {
            Date dt= MapofQuoteIdtoDate.get(quote.id); 
            List<SBQQ__Quoteline__c> sbqq_quoteline  = [SELECT Id, SBQQ__EffectiveStartDate__c, SBQQ__Quote__c from SBQQ__Quoteline__c where SBQQ__Quote__c =: quote.id and SBQQ__EffectiveStartDate__c <:dt  ] ;           
             if(sbqq_quoteline.size()>0)
             {
                 quote.addError('Quote Line start date must be greater than the Quote header Start Date');
             }}
         }    
     }
    
    /*
Method Name : updateSBQQ_Quote,
* @param lstTriggerNew - list of new SBQQ__Quote__c
* @return return-void
* @throws exception - NA
This method call from 'QuoteBeforeInsert' Trigger on SBQQ__Quote__c Object
before Insert a new Record This method Will Be auto populate the field values based on 
Opportunity Contact Roles From Related Opportunity 
*/   
    //<SALESRT-13225> Added conditions for trigger insert and update and logic for Sold To/Ship To/End User/Bill To fields.
    public static void updateSBQQ_Quote(List<SBQQ__Quote__c> lstTriggerNew, String triggerContext, Map<Id,SBQQ__Quote__c> mapNew, Map<Id,SBQQ__Quote__c> mapOld){
        //Set of String Id to capture oSBQQ_Quote record Oppotunity Id's   
        Set<Id> setOfOpportunityIds = new Set<Id>();
        //Set of Id Type to capture oSBQQ__Quote record Master Contract Ids
        Set<Id> setOfMasterContractIds = new Set<Id>();
        //create a map of String [opportunityId|Role], and opportunityContactRole      
        Map<String,opportunityContactRole> mapsetOppIdWiseContactRoles = new map<String,opportunityContactRole>();
        //Create a Map of String[OpportunityId] and Opportunity
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        //Create a Map of String{ContractId] and Contract
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        system.debug('inside updateSBQQ_Quote');
        // Iterate a for loop on lstTriggerNew (SBQQ__Quote__c) Values and 
        // add opportunity Id's from oSBQQ_Quote record if SBQQ__Opportunity2__c not equal to null and 
        // SBQQ__Type__c equal to 'Quote'
        if(triggerContext == FROM_INSERT){
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
                //if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New){<T13></T13>
                if(oSBQQ_Quote.SBQQ__ShippingName__c != null){
                    oSBQQ_Quote.SBQQ__ShippingName__c = '';
                }
                
                if(oSBQQ_Quote.SBQQ__BillingName__c != null){
                    oSBQQ_Quote.SBQQ__BillingName__c = '';
                }
                //}
                
                //<T19>
                if(oSBQQ_Quote.Override_Default_Language__c != null && oSBQQ_Quote.Override_Default_Language__c.length() > 0) {
                    oSBQQ_Quote.DEV_Override_Default_is_Null__c = false;
                }       
                if(oSBQQ_Quote.Partner_Override_Default_Language__c != null && oSBQQ_Quote.Partner_Override_Default_Language__c.length() > 0) {
                    oSBQQ_Quote.DEV_Partner_Override_Default_is_Null__c = false;
                }//</T19> 
                
                //<T25>
                if(oSBQQ_Quote.Special_Remarks1__c != null && oSBQQ_Quote.Special_Remarks1__c.length() > 0) {
                    oSBQQ_Quote.DEV_Special_Remarks_Is_Null__c = false;
                }       
                if(oSBQQ_Quote.Partner_Special_Remarks__c  != null && oSBQQ_Quote.Partner_Special_Remarks__c.length() > 0) {
                    oSBQQ_Quote.DEV_Partner_Special_Remarks_Is_Null__c = false;
                }//</T25> 
            }      
        }
        //if(oSBQQ_Quote.SBQQ__Opportunity2__c != null){
        //Capture the Quote's Opportunity if the Quote Type = New or Renewal
        
        //}  
        Boolean updateQuoteContactRole = false;
        Boolean isRunOnUpdateOfRTMOrDetails = false;
        Map<Id,Boolean> mapUpdateQuote = new Map<Id, Boolean>();
        Map<Id,Id> mapContactQuote = new Map<Id,Id>(); //<SALESRT-15522>
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__Opportunity2__c != null && (oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New || oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Renewal || oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Amendment)){//<T10>Commented the previous line and merged the condition here </T10>
                setOfOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);
            }
            //Update only when RTM fields are changed and only on NNB Quote edit
            if(triggerContext == FROM_UPDATE){
                //<SALESRT-15522>
                if(oSBQQ_Quote.Additional_Ship_to_Contact__c != null && oSBQQ_Quote.Additional_Ship_to_Contact__c != mapOld.get(oSBQQ_Quote.Id).Additional_Ship_to_Contact__c){                 
                mapContactQuote.put(oSBQQ_Quote.Id,oSBQQ_Quote.Additional_Ship_to_Contact__c); 
                }
                if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New && (mapNew.get(oSBQQ_Quote.Id).Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c || mapNew.get(oSBQQ_Quote.Id).Detail_RTM__c != mapOld.get(oSBQQ_Quote.Id).Detail_RTM__c)){
                    updateQuoteContactRole = true;
                    mapUpdateQuote.put(oSBQQ_Quote.Id, true);
                }
                else{
                    mapUpdateQuote.put(oSBQQ_Quote.Id, false);
                }

                if(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && 
                    (mapNew.get(oSBQQ_Quote.Id).Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c 
                    || mapNew.get(oSBQQ_Quote.Id).Detail_RTM__c != mapOld.get(oSBQQ_Quote.Id).Detail_RTM__c)) {
                        isRunOnUpdateOfRTMOrDetails = true;
                }
                }
            }
        
        if(triggerContext == FROM_INSERT || isRunOnUpdateOfRTMOrDetails){ // || updateQuoteContactRole : <SALESRT-13687> -> Removed the condition to drive the logic on update
            
            String shipToTerritoryArea = '';
            List<Contact> contactList = new List<Contact>();
            //if setOfOpportunityIds size greter then 0 then..   
            if(setOfOpportunityIds.size() > 0){
                opportunityMap = new Map<Id, Opportunity>([select id,SBQQ__RenewedContract__c, Territory_Name__c, Territory2.Area__c,
                                                            SBQQ__RenewedContract__r.SBQQ__Order__c,SBQQ__RenewedContract__r.SBQQ__Order__r.Route_To_Market__c,SBQQ__RenewedContract__r.SBQQ__Order__r.Detail_RTM__c,   //<SALESRT-13705>
                                                            SBQQ__RenewedContract__r.Route_To_Market__c,SBQQ__RenewedContract__r.Detail_RTM__c,SBQQ__AmendedContract__c,                                                //<SALESRT-13705>
                                                            SBQQ__AmendedContract__r.Route_To_Market__c,SBQQ__AmendedContract__r.Detail_RTM__c,SBQQ__AmendedContract__r.SBQQ__Order__c,                                 //<SALESRT-13705>
                                                            SBQQ__AmendedContract__r.SBQQ__Order__r.Route_To_Market__c,SBQQ__AmendedContract__r.SBQQ__Order__r.Detail_RTM__c,                                           //<SALESRT-13705>
                                                           Route_To_Market__c,Detail_RTM__c, //<SALESRT-13090>
                                                           (select id,OpportunityId,ContactId,/*<T05>*/
                                                            Contact.MailingStreet,Contact.MailingCity,Contact.MailingState,Contact.MailingPostalCode,Contact.MailingCountry,/*</T05>*//*<T14>*/
                                                            Contact.FirstName, Contact.LastName,/*</T14>*/
                                                            Contact.AccountId,Contact.Account.BillingStreet,Contact.Account.BillingCity,Contact.Account.BillingState,Contact.Account.BillingPostalCode,Contact.Account.BillingCountry, Contact.Email,Role, Contact.Account.Name, Contact.Account.Area__c from OpportunityContactRoles) from opportunity where Id IN :setOfOpportunityIds]);
                
                // play a for loop on opportunity with there OpportunityContactRoles where Opportunity Id In : setOfOpportunityIds  
                for(Opportunity opp : opportunityMap.values()){
                    // play a for loop again on OpportunityContactRoles and add key and value to the map.   
                    for(opportunityContactRole oContRole :opp.OpportunityContactRoles){
                        // create a map key with Opportunity Id | and Contact Role 
                        String sTempKey = opp.Id+'|'+oContRole.Role ;
                        mapsetOppIdWiseContactRoles.put(sTempKey,oContRole);
                        
                        if(oContRole.Role == Label.Contact_Role_ShippingContact && oContRole.Contact.Account.Area__c != null) {
                            shipToTerritoryArea = oContRole.Contact.Account.Area__c;
                        } else if(oContRole.Role == Label.Contact_Role_EndUser && shipToTerritoryArea == '' && oContRole.Contact.Account.Area__c != null) {
                            shipToTerritoryArea = oContRole.Contact.Account.Area__c;
                        }
                        
                    }
                }
            }
            
            // play a for loop again on lstTriggerNew [List<SBQQ__Quote__c>] values     
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){            
                //check if oSBQQ_Quote.SBQQ__Opportunity2__c not equal to null and SBQQ__Type__c equal to 'Quote' then.. 
                if(oSBQQ_Quote.SBQQ__Opportunity2__c != null) {
                    //(mapUpdateQuote.size() > 0 && mapUpdateQuote.get(oSBQQ_Quote.Id) && updateQuoteContactRole) ||
                    //<SALESRT-13687> -> Removed the condition to drive the logic on update
                    if(triggerContext == FROM_INSERT || isRunOnUpdateOfRTMOrDetails){
                        //<SALESRT-13090> Populate the Route to Market fields from Oppty to Quote :: SALESRT-13705 updates the logic for this.
                        //<SALESRT-13705> Update : populate Route to market for amemdment & renewal from contract & order , for nnb it should be from oppty :: start here
                        if(opportunityMap.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && triggerContext == FROM_INSERT){
                            Opportunity tempOpty = opportunityMap.get(oSBQQ_Quote.SBQQ__Opportunity2__c);
                            if(tempOpty != null){
                                if(oSBQQ_Quote.SBQQ__Type__c == 'Renewal' && tempOpty.SBQQ__RenewedContract__c != null){
                                    if(tempOpty.SBQQ__RenewedContract__r.SBQQ__Order__c != null ){
                                        oSBQQ_Quote.Route_To_Market__c = tempOpty.SBQQ__RenewedContract__r.SBQQ__Order__r.Route_To_Market__c;
                                        oSBQQ_Quote.Detail_RTM__c = tempOpty.SBQQ__RenewedContract__r.SBQQ__Order__r.Detail_RTM__c;
                                    }
                                    else{
                                        oSBQQ_Quote.Route_To_Market__c = tempOpty.SBQQ__RenewedContract__r.Route_To_Market__c;
                                        oSBQQ_Quote.Detail_RTM__c = tempOpty.SBQQ__RenewedContract__r.Detail_RTM__c;
                                    }
                                }
                                else if(oSBQQ_Quote.SBQQ__Type__c == 'Amendment' && tempOpty.SBQQ__AmendedContract__c != null){
                                    if(tempOpty.SBQQ__AmendedContract__r.SBQQ__Order__c != null ){
                                        oSBQQ_Quote.Route_To_Market__c = tempOpty.SBQQ__AmendedContract__r.SBQQ__Order__r.Route_To_Market__c;
                                        oSBQQ_Quote.Detail_RTM__c = tempOpty.SBQQ__AmendedContract__r.SBQQ__Order__r.Detail_RTM__c;
                                    }
                                    else{
                                        oSBQQ_Quote.Route_To_Market__c = tempOpty.SBQQ__AmendedContract__r.Route_To_Market__c;
                                        oSBQQ_Quote.Detail_RTM__c = tempOpty.SBQQ__AmendedContract__r.Detail_RTM__c;
                                    }
                                }
                                else if(oSBQQ_Quote.SBQQ__Type__c == 'Quote'){
                                    oSBQQ_Quote.Route_To_Market__c = opportunityMap.get(oSBQQ_Quote.SBQQ__Opportunity2__c).Route_To_Market__c; 
                                    oSBQQ_Quote.Detail_RTM__c = opportunityMap.get(oSBQQ_Quote.SBQQ__Opportunity2__c).Detail_RTM__c;    
                                }
                            }
                        }
                        //<SALESRT-13705> Update : populate Route to market for amemdment & renewal from contract & order , for nnb it should be from oppty :: end here
                        //</SALESRT-13090>
                        String contactId = '';
                        //Eventhough the Contact Role is not present, default the Bill To details when the RTM is Market Place Private and RTM Detail has some value
                        if(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.MicrosoftAzure){
                            contactId = Label.ContactIdMicrosoft;
                        }
                        else if((oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.AmazonAWS)){
                            if(shipToTerritoryArea != '' && shipToTerritoryArea.startsWith('EMEA LATAM') ) {
                                contactId = Label.ContactIdAmazonEMEA_LATAM;
                            } else if(shipToTerritoryArea != '' && shipToTerritoryArea.startsWith('EMEA')) {
                                contactId = Label.ContactIdAmazonEMEA;
                            } else {
                                contactId = Label.ContactIdAmazon;
                            }
                        }
                        else if((oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.AmazonAWSPartner)){
                            if(shipToTerritoryArea != '' && shipToTerritoryArea.startsWith('EMEA LATAM') ) {
                                contactId = Label.ContactIdAmazonEMEA_LATAM;
                            } else if(shipToTerritoryArea != '' && shipToTerritoryArea.startsWith('EMEA')) {
                                contactId = Label.ContactIdAmazonEMEA;
                            } else {
                                contactId = Label.ContactIdAmazon;
                            }
                        }
                        else if((oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.GCP)){
                            contactId = Label.ContactIdGoogle;
                        }
                        if(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isNotBlank(oSBQQ_Quote.Detail_RTM__c)){
                            List<Contact> con = [SELECT Id, Email, name,account.name,accountid,MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet FROM Contact WHERE Id = :contactId];
                            if(con.size() > 0){
                                oSBQQ_Quote.BillToContact__c = con[0].Id;
                                oSBQQ_Quote.SBQQ__BillingStreet__c = con[0].MailingStreet;
                                oSBQQ_Quote.SBQQ__BillingCity__c = con[0].MailingCity;
                                oSBQQ_Quote.SBQQ__BillingState__c = con[0].MailingState;
                                oSBQQ_Quote.SBQQ__BillingPostalCode__c = con[0].MailingPostalCode;
                                oSBQQ_Quote.SBQQ__BillingCountry__c = con[0].MailingCountry;
                                
                                oSBQQ_Quote.BillToAccount__c = con[0].accountid;
                                oSBQQ_Quote.Bill_to_account_Text__c = con[0].account.name;
                                
                                contactList.add(con[0]);
                            } 
                            else{
                                //oSBQQ_Quote.addError('The Contact record for the selected Route to Market Detail is not present');
                            }
                        }
                        // for update SoldToAccount__c,SoldToContact__c based on contact role  
                        // create 2 String Key with OpportunityId '|' and Contact Role  
                        //String sKeySoldTo = oSBQQ_Quote.SBQQ__Opportunity2__c+'|'+Label.Contact_Role_SoldTo;
                        String sKeyEndUser = oSBQQ_Quote.SBQQ__Opportunity2__c+'|'+Label.Contact_Role_EndUser;
                        
                        // check if mapsetOppIdWiseContactRoles Map contains sKeySoldTo then set the 
                        // SoldToAccount__c, SoldToContact__c and Address Compound fields on SBQQ__Quote__c record 
                        /* SALESRT-13225 - Commenting code for Sold To since business instructed not to consider Sold To OCR
                        if(mapsetOppIdWiseContactRoles.containsKey(sKeySoldTo)){
                        opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeySoldTo);
                        oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                        oSBQQ_Quote.SoldToContact__c = OCR.ContactId;
                        oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;//T14
                        
                        //Calling method to return the required values <T05>
                        Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                        
                        // update Compound Address  
                        oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street'); //= OCR.Contact.Account.BillingStreet;
                        oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City'); //= OCR.Contact.Account.BillingCity;
                        oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State'); //= OCR.Contact.Account.BillingState;
                        oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode'); //= OCR.Contact.Account.BillingPostalCode;
                        oSBQQ_Quote.SoldCountry__c= MapofAddressValues.get('Country'); //= OCR.Contact.Account.BillingCountry;
                        //</T05>
                        
                        }
                        // else if check if mapsetOppIdWiseContactRoles Map contains sKeyEndUser then set the  
                        // SoldToAccount__c, SoldToContact__c and Address Compound fields on SBQQ__Quote__c record   
                        else if(mapsetOppIdWiseContactRoles.containsKey(sKeyEndUser)){
                        opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyEndUser);
                        oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                        oSBQQ_Quote.SoldToContact__c = OCR.ContactId;
                        oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;//T14
                        
                        //Calling method to return the required values <T05>
                        Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                        
                        // update Compound Address 
                        oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street');
                        oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City');
                        oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State');
                        oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode');
                        oSBQQ_Quote.SoldCountry__c = MapofAddressValues.get('Country');
                        //</T05>
                        }
                        // else set the SoldToAccount__c,SoldToContact__c and Compound Address fields to Null/Blank
                        else{
                        oSBQQ_Quote.SoldToAccount__c = null;
                        oSBQQ_Quote.SoldToContact__c = null;
                        // update Compound Address 
                        oSBQQ_Quote.SoldStreet__c = null;
                        oSBQQ_Quote.SoldCity__c = null;
                        oSBQQ_Quote.SoldStateProvince__c = null;
                        oSBQQ_Quote.SoldPostalCode__c = null;
                        oSBQQ_Quote.SoldCountry__c = null;
                        }       
                        */
                        // for update ShiptToAccount__c,ShipToContact__c,Shipping_Email__c base on contact role 
                        // create a String Type Key with Opportunity Id and 'Shipping Contact' Role  
                        String sKeyShippingContact = oSBQQ_Quote.SBQQ__Opportunity2__c+'|'+Label.Contact_Role_ShippingContact;
                        // check if mapsetOppIdWiseContactRoles Map contains sKeyShippingContact then set the 
                        // ShiptToAccount__c, ShipToContact__c,Shipping_Email__c and Address Compound fields on SBQQ__Quote__c record
                        if(mapsetOppIdWiseContactRoles.containsKey(sKeyShippingContact)){
                            opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyShippingContact);
                            oSBQQ_Quote.ShiptToAccount__c = OCR.Contact.AccountId;
                            oSBQQ_Quote.ShipToContact__c = OCR.ContactId;
                            oSBQQ_Quote.Shipping_Email__c = OCR.Contact.Email;
                            
                            //Calling method to return the required values <T05>
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            // update Compound Address  
                            oSBQQ_Quote.SBQQ__ShippingStreet__c = MapofAddressValues.get('Street');
                            oSBQQ_Quote.SBQQ__ShippingCity__c = MapofAddressValues.get('City');
                            oSBQQ_Quote.SBQQ__ShippingState__c = MapofAddressValues.get('State');
                            oSBQQ_Quote.SBQQ__ShippingPostalCode__c = MapofAddressValues.get('ZipCode');
                            oSBQQ_Quote.SBQQ__ShippingCountry__c = MapofAddressValues.get('Country');
                            //</T05>
                        }
                        // else if check if mapsetOppIdWiseContactRoles Map contains sKeyEndUser then set the  
                        // ShiptToAccount__c, ShipToContact__c,Shipping_Email__c and Address Compound fields on SBQQ__Quote__c record
                        else if(mapsetOppIdWiseContactRoles.containsKey(sKeyEndUser)){
                            opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyEndUser);
                            oSBQQ_Quote.ShiptToAccount__c = OCR.Contact.AccountId;
                            oSBQQ_Quote.ShipToContact__c = OCR.ContactId;
                            oSBQQ_Quote.Shipping_Email__c = OCR.Contact.Email;
                            
                            //Calling method to return the required values <T05>
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            // update Compound Address  
                            oSBQQ_Quote.SBQQ__ShippingStreet__c = MapofAddressValues.get('Street');
                            oSBQQ_Quote.SBQQ__ShippingCity__c = MapofAddressValues.get('City');
                            oSBQQ_Quote.SBQQ__ShippingState__c = MapofAddressValues.get('State');
                            oSBQQ_Quote.SBQQ__ShippingPostalCode__c = MapofAddressValues.get('ZipCode');
                            oSBQQ_Quote.SBQQ__ShippingCountry__c = MapofAddressValues.get('Country'); 
                            //</T05>
                        }
                        // else set the ShiptToAccount__c,ShipToContact__c,Shipping_Email__c and Compound Address fields to Null/Blank
                        else{
                            oSBQQ_Quote.ShiptToAccount__c = null;
                            oSBQQ_Quote.ShipToContact__c = null;
                            oSBQQ_Quote.Shipping_Email__c = null;
                            
                            // update Compound Address  
                            oSBQQ_Quote.SBQQ__ShippingStreet__c = null;
                            oSBQQ_Quote.SBQQ__ShippingCity__c = null;
                            oSBQQ_Quote.SBQQ__ShippingState__c = null;
                            oSBQQ_Quote.SBQQ__ShippingPostalCode__c = null;
                            oSBQQ_Quote.SBQQ__ShippingCountry__c = null; 
                        }  
                        //<SALESRT-13225> - Added logic based on Route to Market field
                        // for update BillToAccount__c,BillToContact__c base on contact role 
                        // create a String Type Key with Opportunity Id and 'Billing Contact' Role  
                        String sKeyBillToAccount = oSBQQ_Quote.SBQQ__Opportunity2__c+'|'+Label.Contact_Role_BillingContact;
                        // check if mapsetOppIdWiseContactRoles Map contains sKeyBillToAccount then set the 
                        // BillToAccount__c, BillToContact__c and Address Compound fields on SBQQ__Quote__c record
                        
                        if(mapsetOppIdWiseContactRoles.containsKey(sKeyBillToAccount)){
                            opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyBillToAccount);
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            //For RTM = Direct or Partner
                            if(oSBQQ_Quote.Route_To_Market__c == Label.Direct || oSBQQ_Quote.Route_To_Market__c == Label.ResellerDistributor || (oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isBlank(oSBQQ_Quote.Detail_RTM__c))){
                                oSBQQ_Quote.BillToAccount__c = OCR.Contact.AccountId;
                                oSBQQ_Quote.BillToContact__c = OCR.ContactId; 
                                oSBQQ_Quote.Bill_to_account_Text__c = OCR.Contact.Account.Name;//<T07></T07>                                                                  
                                oSBQQ_Quote.SBQQ__BillingStreet__c = MapofAddressValues.get('Street');
                                oSBQQ_Quote.SBQQ__BillingCity__c = MapofAddressValues.get('City');
                                oSBQQ_Quote.SBQQ__BillingState__c = MapofAddressValues.get('State');
                                oSBQQ_Quote.SBQQ__BillingPostalCode__c = MapofAddressValues.get('ZipCode');
                                oSBQQ_Quote.SBQQ__BillingCountry__c = MapofAddressValues.get('Country'); 
                                //If RTM = 'Partner' assign the Bill To information to Sold To - <SALESRT-13225>
                                if(oSBQQ_Quote.Route_To_Market__c == Label.ResellerDistributor){
                                    oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                                    oSBQQ_Quote.SoldToContact__c = OCR.ContactId; 
                                    oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;
                                    oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street');
                                    oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City');
                                    oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State');
                                    oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode');
                                    oSBQQ_Quote.SoldCountry__c = MapofAddressValues.get('Country');
                                } 
                            }
                        }
                        // else if check if mapsetOppIdWiseContactRoles Map contains sKeyEndUser then set the  
                        // BillToAccount__c, BillToContact__c and Address Compound fields on SBQQ__Quote__c record
                        else if(mapsetOppIdWiseContactRoles.containsKey(sKeyEndUser)){
                            opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyEndUser);
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            //For RTM = Direct or Partner
                            if(oSBQQ_Quote.Route_To_Market__c == Label.Direct || oSBQQ_Quote.Route_To_Market__c == Label.ResellerDistributor || (oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isBlank(oSBQQ_Quote.Detail_RTM__c))){
                                oSBQQ_Quote.BillToAccount__c = OCR.Contact.AccountId;
                                oSBQQ_Quote.BillToContact__c = OCR.ContactId;
                                oSBQQ_Quote.Bill_to_account_Text__c = OCR.Contact.Account.Name;//<T07></T07>                                
                                oSBQQ_Quote.SBQQ__BillingStreet__c = MapofAddressValues.get('Street');
                                oSBQQ_Quote.SBQQ__BillingCity__c = MapofAddressValues.get('City');
                                oSBQQ_Quote.SBQQ__BillingState__c = MapofAddressValues.get('State');
                                oSBQQ_Quote.SBQQ__BillingPostalCode__c = MapofAddressValues.get('ZipCode');
                                oSBQQ_Quote.SBQQ__BillingCountry__c = MapofAddressValues.get('Country');
                                //If RTM = Partner assign the End User information to Sold To - <SALESRT-13225>
                                if(oSBQQ_Quote.Route_To_Market__c == Label.ResellerDistributor){
                                    oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                                    oSBQQ_Quote.SoldToContact__c = OCR.ContactId; 
                                    oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;
                                    oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street');
                                    oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City');
                                    oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State');
                                    oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode');
                                    oSBQQ_Quote.SoldCountry__c = MapofAddressValues.get('Country');
                                }
                            }
                        }
                        // else set the BillToAccount__c,BillToContact__c, and Compound Address fields to Null/Blank
                        else{
                            //If RTM is not Market Place Private or RTM is Market Place Private and Bill To Contact is still blank then empty the Bill To values.
                            if(!(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isNotBlank(oSBQQ_Quote.Detail_RTM__c)) || (oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isBlank(oSBQQ_Quote.Detail_RTM__c)) || 
                               (oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && String.isNotBlank(oSBQQ_Quote.Detail_RTM__c) && String.isBlank(oSBQQ_Quote.BillToContact__c))){
                                   oSBQQ_Quote.BillToAccount__c =  null;
                                   oSBQQ_Quote.BillToContact__c =  null;
                                   
                                   // update Compound Address  
                                   oSBQQ_Quote.SBQQ__BillingStreet__c = null;
                                   oSBQQ_Quote.SBQQ__BillingCity__c = null;
                                   oSBQQ_Quote.SBQQ__BillingState__c = null;
                                   oSBQQ_Quote.SBQQ__BillingPostalCode__c = null;
                                   oSBQQ_Quote.SBQQ__BillingCountry__c = null;
                                   //<SALESRT-13225>
                                   if(oSBQQ_Quote.Route_To_Market__c == Label.ResellerDistributor){
                                       oSBQQ_Quote.SoldToAccount__c = null;
                                       oSBQQ_Quote.SoldToContact__c = null; 
                                       oSBQQ_Quote.SoldStreet__c = null;
                                       oSBQQ_Quote.SoldCity__c = null;
                                       oSBQQ_Quote.SoldStateProvince__c = null;
                                       oSBQQ_Quote.SoldPostalCode__c = null;
                                       oSBQQ_Quote.SoldCountry__c = null;
                                   }
                               }
                        } 
                        // for update EndUserAccount__c,EndUserContact__c base on contact role 
                        // check if mapsetOppIdWiseContactRoles Map contains sKeyEndUser then set the 
                        // EndUserAccount__c, EndUserContact__c and Address Compound fields on SBQQ__Quote__c record  
                        if(mapsetOppIdWiseContactRoles.containsKey(sKeyEndUser)){
                            opportunityContactrole OCR = mapsetOppIdWiseContactRoles.get(sKeyEndUser);
                            oSBQQ_Quote.EndUserAccount__c = OCR.Contact.AccountId;
                            oSBQQ_Quote.EndUserContact__c = OCR.ContactId;
                            oSBQQ_Quote.End_User_Account_Text__c = OCR.Contact.Account.Name;//<T07></T07>
                            //If RTM = Direct or Market Place Private, assign the End User information to Sold To - <SALESRT-13225>
                            if(oSBQQ_Quote.Route_To_Market__c == Label.Direct || oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate){
                                oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                                oSBQQ_Quote.SoldToContact__c = OCR.ContactId; 
                                oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;
                            }
                            
                            //Calling method to return the required values <T05>
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            // update Compound Address  
                            oSBQQ_Quote.EndUserStreet__c = MapofAddressValues.get('Street');
                            oSBQQ_Quote.EndUserCity__c = MapofAddressValues.get('City');
                            oSBQQ_Quote.EndUserStateProvince__c = MapofAddressValues.get('State');
                            oSBQQ_Quote.EndUserPostalCode__c = MapofAddressValues.get('ZipCode');
                            oSBQQ_Quote.EndUserCountry__c = MapofAddressValues.get('Country'); 
                            //</T05>
                            //If RTM = Direct or Market Place Private, assign the End User Address information to Sold To - <SALESRT-13225>
                            if(oSBQQ_Quote.Route_To_Market__c == Label.Direct || oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate){
                                oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street');
                                oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City');
                                oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State');
                                oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode');
                                oSBQQ_Quote.SoldCountry__c = MapofAddressValues.get('Country');
                            }                            
                        }
                        // else set the EndUserAccount__c,EndUserContact__c, and Compound Address fields to Null/Blank 
                        else{
                            oSBQQ_Quote.EndUserAccount__c = null;
                            oSBQQ_Quote.EndUserContact__c = null;
                            
                            // update Compound Address  
                            oSBQQ_Quote.EndUserStreet__c = null;
                            oSBQQ_Quote.EndUserCity__c = null;
                            oSBQQ_Quote.EndUserStateProvince__c = null;
                            oSBQQ_Quote.EndUserPostalCode__c = null;
                            oSBQQ_Quote.EndUserCountry__c = null;
                            //<SALESRT-13225>
                            if(oSBQQ_Quote.Route_To_Market__c == Label.Direct || oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate){
                                oSBQQ_Quote.SoldToAccount__c = null;
                                oSBQQ_Quote.SoldToContact__c = null; 
                                oSBQQ_Quote.SoldStreet__c = null;
                                oSBQQ_Quote.SoldCity__c = null;
                                oSBQQ_Quote.SoldStateProvince__c = null;
                                oSBQQ_Quote.SoldPostalCode__c = null;
                                oSBQQ_Quote.SoldCountry__c = null;
                            }
                        }

                        //SALESRT-13625 - Populate Sold To from Bill To else from End user
                        if(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.AmazonAWSPartner 
                            && (mapsetOppIdWiseContactRoles.containsKey(sKeyBillToAccount) || mapsetOppIdWiseContactRoles.containsKey(sKeyEndUser)) ) {

                            opportunityContactrole OCR;
                        
                            if(mapsetOppIdWiseContactRoles.containsKey(sKeyBillToAccount)) {
                                OCR = mapsetOppIdWiseContactRoles.get(sKeyBillToAccount);
                            } else {
                                OCR = mapsetOppIdWiseContactRoles.get(sKeyEndUser);
                            }  
                            
                            Map<String,String> MapofAddressValues = contactAddressCheck(OCR);
                            
                            oSBQQ_Quote.SoldToAccount__c = OCR.Contact.AccountId;
                            oSBQQ_Quote.SoldToContact__c = OCR.ContactId; 
                            oSBQQ_Quote.Sold_To_Contact_Name__c = OCR.Contact.FirstName + ' ' + OCR.Contact.LastName;
                            oSBQQ_Quote.SoldStreet__c = MapofAddressValues.get('Street');
                            oSBQQ_Quote.SoldCity__c = MapofAddressValues.get('City');
                            oSBQQ_Quote.SoldStateProvince__c = MapofAddressValues.get('State');
                            oSBQQ_Quote.SoldPostalCode__c = MapofAddressValues.get('ZipCode');
                            oSBQQ_Quote.SoldCountry__c = MapofAddressValues.get('Country');
                        }
                        
                        //SALESRT-13625 - Populate Ship to & Sold To
                        if(oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate && oSBQQ_Quote.Detail_RTM__c == Label.GCP && contactList.size() > 0) {
                            
                            oSBQQ_Quote.SoldToContact__c = contactList[0].Id;
                            oSBQQ_Quote.SoldStreet__c = contactList[0].MailingStreet;
                            oSBQQ_Quote.SoldCity__c = contactList[0].MailingCity;
                            oSBQQ_Quote.SoldStateProvince__c = contactList[0].MailingState;
                            oSBQQ_Quote.SoldPostalCode__c = contactList[0].MailingPostalCode;
                            oSBQQ_Quote.SoldCountry__c = contactList[0].MailingCountry;
                            oSBQQ_Quote.SoldToAccount__c = contactList[0].accountid;
                            oSBQQ_Quote.Sold_To_Contact_Name__c = contactList[0].name;
                            
                            oSBQQ_Quote.ShipToContact__c = contactList[0].Id;
                            oSBQQ_Quote.SBQQ__ShippingStreet__c = contactList[0].MailingStreet;
                            oSBQQ_Quote.SBQQ__ShippingCity__c = contactList[0].MailingCity;
                            oSBQQ_Quote.SBQQ__ShippingState__c = contactList[0].MailingState;
                            oSBQQ_Quote.SBQQ__ShippingPostalCode__c = contactList[0].MailingPostalCode;
                            oSBQQ_Quote.SBQQ__ShippingCountry__c = contactList[0].MailingCountry;
                            oSBQQ_Quote.ShiptToAccount__c = contactList[0].accountid;
                            oSBQQ_Quote.Shipping_Email__c = contactList[0].Email;
                        }
                        
                    }
                }                
                GAM.CreateLogs('updateSBQQ_Quote',oSBQQ_Quote, 'Quote to be updated: ');
            }  
            GAM.InsertDebugLogs();
        }
        
        if(triggerContext == FROM_UPDATE){     //<SALESRT-13673> : changes start
            List<Opportunity> opptyListToUpdate = new List<Opportunity>();
            Map<Id,Contact> mapContactEmail = new Map<Id,Contact>([Select id,Email from Contact where  ID IN :mapContactQuote.values()]); //<SALESRT-15522>
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
                //<SALESRT-15522> Update Additional Shipping Email on Quote from Additional Ship to Contact's Email
              if(mapContactEmail.containsKey(mapContactQuote.get(oSBQQ_Quote.Id)) && mapContactEmail.get(mapContactQuote.get(oSBQQ_Quote.Id)).Email !=null){
                    oSBQQ_Quote.Additional_Shipping_Email__c = mapContactEmail.get(mapContactQuote.get(oSBQQ_Quote.Id)).Email;
                  }  
                 //<SALESRT-15522> Ends 
                if((oSBQQ_Quote.SBQQ__Primary__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__Primary__c || 
                    oSBQQ_Quote.Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c || 
                    oSBQQ_Quote.Detail_RTM__c != mapOld.get(oSBQQ_Quote.Id).Detail_RTM__c) 
                    && (oSBQQ_Quote.SBQQ__Primary__c && oSBQQ_Quote.SBQQ__Opportunity2__c != null)){
                        
                    Opportunity oppty = new Opportunity();
                    oppty.Id = oSBQQ_Quote.SBQQ__Opportunity2__c;
                    oppty.Route_To_Market__c = oSBQQ_Quote.Route_To_Market__c;
                    oppty.Detail_RTM__c = oSBQQ_Quote.Detail_RTM__c;
                    opptyListToUpdate.add(oppty);
                }
            }
            if(!opptyListToUpdate.isEmpty()){
                update opptyListToUpdate;
            }
        }
        // <SALESRT-13673> : changes end
    }
    
    /*
<T05>
Method Name : contactAddressCheck
@param OCR - OpportunityContactrole
@return Map<String,String>
@throws exception : NA
This method will be called to set the Address in Quote based on the Contact Role
*/
    
    private static Map<String,String> contactAddressCheck(OpportunityContactrole OCR){
        Map<String,String> ListofMapsofAdLeveltoValue = new Map<String,String>();
        if(OCR.Contact.MailingStreet != null && OCR.Contact.MailingCity != null && OCR.Contact.MailingPostalCode != null && OCR.Contact.MailingCountry != null){
            ListofMapsofAdLeveltoValue.put('Street', OCR.Contact.MailingStreet);
            ListofMapsofAdLeveltoValue.put('City', OCR.Contact.MailingCity);
            ListofMapsofAdLeveltoValue.put('ZipCode', OCR.Contact.MailingPostalCode);
            ListofMapsofAdLeveltoValue.put('State', OCR.Contact.MailingState);
            ListofMapsofAdLeveltoValue.put('Country', OCR.Contact.MailingCountry);
        }
        else{
            ListofMapsofAdLeveltoValue.put('Street', OCR.Contact.Account.BillingStreet);
            ListofMapsofAdLeveltoValue.put('City', OCR.Contact.Account.BillingCity);
            ListofMapsofAdLeveltoValue.put('ZipCode', OCR.Contact.Account.BillingPostalCode);
            ListofMapsofAdLeveltoValue.put('State', OCR.Contact.Account.BillingState);
            ListofMapsofAdLeveltoValue.put('Country', OCR.Contact.Account.BillingCountry);
        }
        return ListofMapsofAdLeveltoValue;
    }
    //</T05>
    
    
    /*
* If the Quote's Start Date, End Date, or Subscription Term is modified, update the Quote Line's field - End_Date_Localized__c 
* based on the Quote Line's Quote's Territory assignment
* @param parameter - mapNew - List of new Quotes, mapOld - List of old Quotes
* @return return - void
* @throws exception-captures exception in a debug log
* <T31> Optimized the below method to be used for general Quote line updates.
* <T13270> Commenting the method
*/
    /*public static void updateQuoteLine(Map<Id, SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        Map<Id, SBQQ__QuoteLine__c> qleToUpdateMap = new Map<Id, SBQQ__QuoteLine__c>(); //Map of Quote Line records to be udpated
        Set<Id> quoteIds = new Set<Id>(); //Gather all Opportunity Id's whose Territory has changed
        
        //<T31>Moving the Quoteline query map above the if condition to pull all the quotelines in a map
        Map<Id, SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, Name, SBQQ__StartDate__c, SBQQ__Quote__c, 
                                                                                     SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.Territory__c, 
                                                                                     SBQQ__Quote__r.SBQQ__EndDate__c, SBQQ__Quote__r.SBQQ__StartDate__c, 
                                                                                     End_Date_Output_QL__c, End_Date_Localized__c, SBQQ__EndDate__c,SBQQ__Quote__r.SBQQ__Ordered__c,                         //</T31>
                                                                                     /*<T23>SBQQ__SubscriptionTerm__c/*</T23> 
                                                                                     FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :mapNew.Keyset()]);                        // Checking for the new ids of the Quote
        
        for(SBQQ__Quote__c quote : mapNew.values()){
            //Check if the End Date, Start Date, or Subscription Term was modified
            if(quote.SBQQ__StartDate__c != mapOld.get(quote.Id).SBQQ__StartDate__c ||
               quote.SBQQ__EndDate__c != mapOld.get(quote.Id).SBQQ__EndDate__c ||
               quote.SBQQ__SubscriptionTerm__c != mapOld.get(quote.Id).SBQQ__SubscriptionTerm__c ||
               quote.Apply_PO_to_All_Lines__c!= mapOld.get(quote.Id).Apply_PO_to_All_Lines__c){ //<T26> //<T13260>
                   //Only capture the Quote Id if the above fields were modified meaning the End_Date_Localized__c needs to be updated
                   quoteIds.add(quote.Id);
                   GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'The Quote - ' + quote.Name + ' StartDate, EndDate, or SubscriptionTerm was modified');
               }//<T26>
        }
        /****************************Monitoring Purposes**************************************
        System.debug('Size of quoteLinesMap: ' + quoteLinesMap.values().size());
        /******************************************************************
        
        for(SBQQ__QuoteLine__c qle : quoteLinesMap.values()){
            //--------------------------------------------Code Optimization<T10>
            if(quoteIds != null &&
               quoteIds.size() > 0 &&
               quoteIds.contains(qle.SBQQ__Quote__c)){
                   
                   Date tempEndDate;
                   Integer thisTerm; //<T23>
                   if(qle.SBQQ__EndDate__c != null){//Take the Quote Line's End Date
                       tempEndDate = qle.End_Date_Output_QL__c;
                   }else{//Take the Quote's End Date
                       if(mapNew.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
                           tempEndDate = mapNew.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c;
                       }else{ //<T23> Checking if the QLI has the Subsc Term in the first place
                           if(qle.SBQQ__SubscriptionTerm__c != null){
                               thisTerm = Integer.valueOf(qle.SBQQ__SubscriptionTerm__c);
                           } else{ //If the QLI doesn't, then checking if the Quote has a Term, and taking it from there
                               if(mapNew.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c != null){
                                   thisTerm = Integer.valueOf(mapNew.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c);
                               }
                           } //</T23>
                           if(thisTerm != null){
                               if(qle.SBQQ__StartDate__c != null){
                                   tempEndDate = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T23> thisTerm
                               }else if(mapNew.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
                                   tempEndDate = mapNew.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T23> thisTerm
                               }
                           }
                       }
                   }
                   //--------------------------------------------Code Optimization</T10>
                   
                   if(qle.SBQQ__Quote__r.Territory__c != null){ //Check that the Quote has an associated Territory
                       //Assign End Date Localized format based on the Territory Name      
                       String territoryName = qle.SBQQ__Quote__r.Territory__c;
                       /*--------------------------------------------------------------------------<T12736> - added as default else part
                       //Assign Date Format mm/dd/yyyy
                       if(territoryName.startsWith('NA') ){//<T8>  <T34> removed LATAM from here
                           if(tempEndDate != null){
                               qle.End_Date_Localized__c = tempEndDate.month() + '/' + tempEndDate.day() + '/' + tempEndDate.year();
                           }                           
                           GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'Territory contains NA . Assigning End Date Localized - ' + qle.End_Date_Localized__c);
                           qleToUpdateMap.put(qle.Id, qle);
                       }
                       //--------------------------------------------------------------------------<T12736/>
                       //Assign Date Format yyyy/mm/dd
                       if(territoryName.startsWith('AP') || territoryName.startsWith('JP')){//<T8> <T36>
                           if(tempEndDate != null){
                               qle.End_Date_Localized__c =  tempEndDate.year() + '/' + tempEndDate.month() + '/' + tempEndDate.day();
                           }                           
                           GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'Territory contains APJ. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
                           qleToUpdateMap.put(qle.Id, qle);
                       }
                       
                       //Assign Date Format dd/mm/yyyy
                       else if(territoryName.startsWith('EA') || territoryName.startsWith('EA_S_LAT')){//<T8> <T34>
                           if(tempEndDate != null){
                               qle.End_Date_Localized__c =  tempEndDate.day() + '/' + tempEndDate.month() + '/' + tempEndDate.year();
                           }                           
                           GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'Territory contains EA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
                           qleToUpdateMap.put(qle.Id, qle);
                       }else{
                            if(tempEndDate != null){
                                qle.End_Date_Localized__c = tempEndDate.month() + '/' + tempEndDate.day() + '/' + tempEndDate.year();
                            }                           
                            GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'Territory contains NA . Assigning End Date Localized - ' + qle.End_Date_Localized__c);
                            qleToUpdateMap.put(qle.Id, qle);
                       }
                   } else{
                       //If the Quote's Territory is not populated, default End Date Localized to the format for Territory that contains 'NA' - mm/dd/yyyy
                       if(tempEndDate != null){
                           qle.End_Date_Localized__c =  tempEndDate.month() + '/' + tempEndDate.day() + '/' + tempEndDate.year();
                       }                       
                       GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLine', 'Quotes Territory is blank. Assigning End Date Localized based on NA format - ' + qle.End_Date_Localized__c);
                       qleToUpdateMap.put(qle.Id, qle);
                   }
               }
            /*
            //<T31><T44> 
            if(qle.Cancel_Reason__c != '' && qle.Cancel_Reason__c != Null && mapNew.get(qle.SBQQ__Quote__c).SBQQ__Ordered__c) {
            qle.Cancel_Reason__c ='';
            qleToUpdateMap.put(qle.Id, qle);
            }
            //</T31></T44> 
        }
        
        
        //DML Update call on the Quote Line Map to update the field - End_Date_Localized__c 
        if(qleToUpdateMap.size() > 0 && qleToUpdateMap != null){
            SBQQ.TriggerControl.disable(); //<T26> 
            try{
                globalApexManager.avoidRecursion('QuoteLineBeforeUpdate'); //Stop the QuoteLineBeforeUpdate Trigger from running to avoid recursion
                Database.SaveResult[] srList = Database.update(qleToUpdateMap.values(), true);
                globalApexManager.avoidRecursion('QuoteLineBeforeUpdate'); //Stop the QuoteLineBeforeUpdate Trigger from running to avoid recursion
            }
            catch(DmlException e)
            {
                GAM.CreateExceptionRecords('QuoteTriggerHandler.updateQuoteLine', 'Error while updating Quote Lines: ', e.getMessage());
            }
            SBQQ.TriggerControl.enable(); //<T26>
        }
    }*/
    //----------------------------------------------------------------------------------------------<T50>
    /*
    * Creates CMS Request Engagement Record if the Sold to Account ERP Id is not populated and 
    * the Opportunity Stage is Final Negotiation/Committed or the Probability is greater than 70
    * @param parameter - lstQuotesCMSRequest
    * @return return - void
    * @throws exception-captures exception in a debug log
    */
    public static void createCMSRequest(List<SBQQ__Quote__c> lstQuotesCMSRequest){
        String ENGMNT_CMS_REQUEST = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('CMS Request').getRecordTypeId();
        Decimal Early_CMS_Oppty_Probability = Decimal.valueOf(Label.Early_CMS_Oppty_Probability); //<TAX-197>
        Map<Id,SBQQ__Quote__c> mapQuoteRecs = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Id> mapQuoteSoldToAccount = new Map<Id,Id>();
        Map<Id,Id> mapQuoteBillToAccount = new Map<Id,Id>();
        Map<Id,String> mapAccountCMSRequestType = new Map<Id,String>(); //Map of Account and CMS Request Type  
    
        //Creating a map of Quote, Quote with Sold to Account, Quote with BillTo Account
        for(SBQQ__Quote__c quoteRec: lstQuotesCMSRequest){
            mapQuoteRecs.put(quoteRec.Id,quoteRec);
            if(quoteRec.SoldToAccount__c != null){
                mapQuoteSoldToAccount.put(quoteRec.Id,quoteRec.SoldToAccount__c);
                mapAccountCMSRequestType.put(quoteRec.SoldToAccount__c,'SoldTo');
            }
            if(quoteRec.BilltoAccount__c != null){
                mapQuoteBillToAccount.put(quoteRec.Id,quoteRec.BilltoAccount__c);
                mapAccountCMSRequestType.put(quoteRec.BilltoAccount__c,'BillTo');
            }
        }
    
        if(!mapAccountCMSRequestType.isEmpty()){
            //Fetch the account date along with CMS Request Enagagement Records where Peoplesoft_External_ID__c is null 
            Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id,Name,Peoplesoft_External_ID__c,(SELECT Id FROM Sales_Support_Requests__r WHERE RecordTypeId =:ENGMNT_CMS_REQUEST) FROM Account WHERE Id IN:mapAccountCMSRequestType.keySet() AND Peoplesoft_External_ID__c = null]);
            
            //Creating a map of quote and Shipping country where SoldTo, BillTo Account does not have Peoplesoft_External_ID__c populated
            Map<Id,String> mapQuoteShippingCountry = new Map<Id,String>();
            if(!mapQuoteSoldToAccount.isEmpty()){
                for(Id quoteId:mapQuoteSoldToAccount.keySet()){
                    if(mapAccount.containsKey(mapQuoteSoldToAccount.get(quoteId))){
                        mapQuoteShippingCountry.put(quoteId,mapQuoteRecs.get(quoteId).SBQQ__ShippingCountry__c);
                    }
                }
            }
            if(!mapQuoteBillToAccount.isEmpty()){
                for(Id quoteId:mapQuoteBillToAccount.keySet()){
                    if(mapAccount.containsKey(mapQuoteBillToAccount.get(quoteId))){
                        mapQuoteShippingCountry.put(quoteId,mapQuoteRecs.get(quoteId).SBQQ__ShippingCountry__c);
                    }
                }
            }
            
            if(!mapQuoteShippingCountry.isEmpty()){
                //Querying Quotes along with Opty information, get only the quotes where Probability >= 50
                Map<Id,SBQQ__Quote__c> mapQuoteOptyInfo = new Map<Id,SBQQ__Quote__c>([SELECT Id,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Probability,SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE isSelfService__c = TRUE OR (Id IN :mapQuoteShippingCountry.keySet()
                                                                                      AND SBQQ__Opportunity2__r.Probability >= :Early_CMS_Oppty_Probability)]); //<TAX-197>
                //Removing the quotes from the map which do not have probability >= 50
                for(Id quoteId:mapQuoteShippingCountry.keySet()){
                    if(!mapQuoteOptyInfo.containsKey(quoteId)){
                        mapQuoteShippingCountry.remove(quoteId);
                    }
                }
    
                if(!mapQuoteShippingCountry.isEmpty()){
                    //Geting the list of countries for which CMS team has to be notified
                    Map<Id,Tax_Country__mdt> mapTaxCountries = new Map<Id,Tax_Country__mdt>([SELECT MasterLabel,CMS_Chatter_Group__c,CMS_Queue_Id__c FROM Tax_Country__mdt WHERE MasterLabel IN :mapQuoteShippingCountry.values() AND CMS_Chatter_Group__c != null]);
                    if(!mapTaxCountries.isEmpty()){ 
                        //Creating a map of country,CMS group
                        Map<String,List<String>> mapCountryCMSInfo = new Map<String,List<String>>();
                        for(Tax_Country__mdt countryRec:mapTaxCountries.values()){
                            mapCountryCMSInfo.put(countryRec.MasterLabel,new List<String>{countryRec.CMS_Chatter_Group__c,countryRec.CMS_Queue_Id__c});
                        }
    
                        //Removing the quotes from the map for which Tax_Country__mdt entry does not exists
                        for(Id quoteId:mapQuoteShippingCountry.keySet()){
                            if(!mapCountryCMSInfo.containsKey(mapQuoteShippingCountry.get(quoteId))){
                                mapQuoteShippingCountry.remove(quoteId);
                            }
                        }
    
                        if(!mapQuoteShippingCountry.isEmpty()){
                            //Creating a map of Account, CMS Request Engagement Record count
                            Map<Id,Integer> mapAccCMSRequestCount = new Map<Id,Integer>();
                            for(Account Acc:mapAccount.values()){
                                    mapAccCMSRequestCount.put(Acc.Id,Acc.Sales_Support_Requests__r.size());
                            }
                            
                            List<Engagement__c> lstEngagementToInsert = new List<Engagement__c>();
                            for(Id quoteId:mapQuoteShippingCountry.keySet()){
                                //Adding both SoldTo, BillTo Account to the set
                                Set<Id> setAccIds = new set<Id>();
                                setAccIds.add(mapQuoteSoldToAccount.get(quoteId));
                                setAccIds.add(mapQuoteBillToAccount.get(quoteId));
                                for(Id accId:setAccIds){
                                    if(mapAccCMSRequestCount.get(accId) < 1){ //Create new Enagement record only for the Accounts without any existing CMS Request reords
                                        Engagement__c engagementRec = new Engagement__c();
                                        if(mapAccountCMSRequestType.get(accId) == 'SoldTo'){
                                            engagementRec.Title__c = 'Process CMS for the Sold to Account';
                                        }else{
                                            engagementRec.Title__c = 'Process CMS for the Bill to Account';
                                        }
                                        engagementRec.RecordTypeId = ENGMNT_CMS_REQUEST;
                                        engagementRec.OwnerId = mapCountryCMSInfo.get(mapQuoteShippingCountry.get(quoteId))[1];
                                        engagementRec.Dev_CMS_Group_Id__c = mapCountryCMSInfo.get(mapQuoteShippingCountry.get(quoteId))[0];
                                        engagementRec.Name = 'CMS Request for '+mapAccount.get(accId).Name;
                                        engagementRec.Opportunity__c = mapQuoteOptyInfo.get(quoteId).SBQQ__Opportunity2__c;
                                        engagementRec.Quote__c = quoteId;
                                        engagementRec.Account__c = accId;
                                        lstEngagementToInsert.add(engagementRec);
                                    }
                                }
                            }
                            
                            //Inserting the CMS Request Engagement Records
                            if(!lstEngagementToInsert.isEmpty()){
                                try{
                                    Database.SaveResult[] srList = Database.insert(lstEngagementToInsert, false);
                                } catch(Exception e){
                                    GAM.CreateLogs('QuoteTriggerHandler.createCMSRequest', lstEngagementToInsert, 'lstEngagementToInsert');
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //----------------------------------------------------------------------------------------------</T50>
    //----------------------------------------------------------------------------------------------<T51>
    /*
    * Is shipping addess is changed calls the logic to upsert ERP Site on Quote
    * @param parameter - lstQuoteIds - list of Quote Ids populated when called from before update
    * @return return - void
    * @throws exception-captures exception in a debug log
    */
    public static void upsertERPSite(List<Id> lstQuoteIds){
        Map<Id,String> mapQuoteIdTaxExemptionNumber = new Map<Id,String>();
        Map<Id,Decimal> mapQuoteIdTaxAmount = new Map<Id,Decimal>();
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,SBQQ__Quote__c> mapQuoteRecs = new Map<Id,SBQQ__Quote__c>([SELECT Id,SoldToAccount__c,SoldToAccount__r.ERP_Company__c,Sold_to_Account_ERP_Site__r.Name,Sold_to_Account_ERP_Site__r.ERP_Company__c,Sold_to_Account_ERP_Site__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,SBQQ__ShippingCity__c,SBQQ__ShippingPostalCode__c,SBQQ__ShippingStreet__c,
        SBQQ__StartDate__c, SBQQ__EndDate__c,Calculated_Tax_Amount__c,Exemption_number__c FROM SBQQ__Quote__c WHERE Id IN :lstQuoteIds]);
        for(SBQQ__Quote__c quoteRec:mapQuoteRecs.values()){
            mapQuoteIdTaxExemptionNumber.put(quoteRec.Id,quoteRec.Exemption_number__c);
            mapQuoteIdTaxAmount.put(quoteRec.Id,quoteRec.Calculated_Tax_Amount__c);
            quoteMap.put(quoteRec.Id,quoteRec);
        }

        if(!quoteMap.isEmpty()){
            QuoteLineTriggerHandler.upsertErpSiteRecords(mapQuoteIdTaxExemptionNumber,mapQuoteIdTaxAmount,quoteMap);
        }
    }
    public static void handleAfterUpdate(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        updateRTMFieldsOppty(mapNew, mapOld);
        List<Id> lstQuotetoUpdate = new List<Id>();
        
        for(SBQQ__Quote__c oSBQQ_Quote : mapNew.values()){
            if(oSBQQ_Quote.OneSource_Last_Call_Time__c != mapOld.get(oSBQQ_Quote.Id).OneSource_Last_Call_Time__c){
                lstQuotetoUpdate.add(oSBQQ_Quote.Id);
            }

        }
        if(!lstQuotetoUpdate.isEmpty()){
            upsertERPSite(lstQuotetoUpdate);
        }
         //<SALESRT-13090>
        
        QuoteTriggerHandler.recalculateWarning(mapNew.values(), mapOld);
        callNotificationService(mapNew.values(), mapOld);
    }    
    //<SALESRT-13090>
    /*
    Method Name : updateRTMFieldsOppty
    * @param mapNew - Map<Id,SBQQ__Quote__c>,Map<Id, SBQQ__Quote__c>
    * @return return-void
    * @throws exception - NA
    */
    public static void updateRTMFieldsOppty(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        List<Opportunity> listOpp = new List<Opportunity>();
        for(SBQQ__Quote__c quote : mapNew.values()){
            if((!quote.SBQQ__Ordered__c) && quote.SBQQ__Primary__c &&  quote.SBQQ__Opportunity2__c != null){               
                   Opportunity opp = new Opportunity(Id = quote.SBQQ__Opportunity2__c,
                                                     Route_To_Market__c = quote.Route_To_Market__c,
                                                     Detail_RTM__c = quote.Detail_RTM__c);
                   listOpp.add(opp); 
               }
        }
        if(listOpp.size() > 0){
            try{
                Database.update(listOpp, false);
            }
            catch(DmlException e)
            {
                GAM.CreateExceptionRecords('QuoteTriggerHandler.updateRTMFieldsOppty', 'Error while updating Opportunity: ', e.getMessage());
            }
        }        
    }
    //</SALESRT-13090>
    //----------------------------------------------------------------------------------------------</T51>    
    
    /*
        Method Name : handleAfterUpdate
        * @param mapNew - Map<Id,SBQQ__Quote__c>
        * @return return-void
        * @throws exception - NA
        this method call from 'QuoteAfterInsert' and 'QuoteAfterUpdate' Trigger on SBQQ__Quote__c Object
        It will update field: LegalEntity as per value of SBQQ__ShippingCountry__c, 
        BilltoContact__c from Related_Contract__c.BillToContact__c,
        ShiptoContact__c from Related_Contract__c.ShipToContact__c,
        */ 
            
            /*public static void handleAfterUpdate(Map<Id,SBQQ__Quote__c> mapNew, Map<Id, SBQQ__Quote__c> mapOld){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id, Name, SBQQ__Type__c, SoldCountry__c, SBQQ__ShippingCountry__c, BillToContact__c, ShipToContact__c, Price_Book_2__c, SBQQ__PriceBook__c, SBQQ__PricebookId__c, SBQQ__StartDate__c,
        SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c, Related_Contract__c, Related_Contract__r.SBQQ__Quote__r.Price_Book_2__c, Related_Contract__r.SBQQ__Quote__r.SBQQ__PriceBook__c, 
        Related_Contract__r.SBQQ__Quote__r.SBQQ__PricebookId__c, Related_Contract__r.SBQQ__Order__r.BillToContactId, Related_Contract__r.SBQQ__Order__r.ShipToContactId, SBQQ__MasterContract__c, 
        SBQQ__MasterContract__r.SBQQ__Quote__r.Price_Book_2__c, SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__PricebookId__c, 
        SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, Territory__c
        FROM SBQQ__Quote__c 
        WHERE Id IN :mapNew.keySet()];
        //updateQuoteLegalEntity(mapNew, mapOld, lstQuote, FROM_UPDATE);
        }<T11>*/
            
            
            /*
        Method Name : updateQuoteLegalEntity
        * @param List<SBQQ__Quote__c> lstTriggerNew, Map<Id, SBQQ__Quote__c> mapOld
        * @return return-void
        * @throws exception - NA
        */
    //<T12> ReFactored Code To populate Legal Entity, to move it to before Context. And create new methods for Code related to Amendment and Renewal Quotes. 
    //This Method is called from 'Before Insert' and 'Before Update' Event on SBQQ__Quote__c Object </T12>
    private static void updateQuoteLegalEntity(List<SBQQ__Quote__c> lstTriggerNew, Map<Id, SBQQ__Quote__c> mapOld) {
        String countries = ''; //String to hold concatenation of Countries if Quote's Shipping Country is populated
        List<blng__LegalEntity__c> legalEntityList = new List<blng__LegalEntity__c>(); //List of Legal Entity records if Quote Shipping Country is populated
        Boolean isShipToChanged = false;
        Boolean isMarketplacePrivate = false;
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            //If SBQQ__Country__c is not blank, fetch SBQQ__ShippingCountry__c
            if(String.isNotBlank(oSBQQ_Quote.SBQQ__ShippingCountry__c)){   
                countries += oSBQQ_Quote.SBQQ__ShippingCountry__c + ';,';
            }
            if(oSBQQ_Quote.SBQQ__ShippingCountry__c != null && oSBQQ_Quote.Route_To_Market__c != Label.MarketPlacePrivate 
               && (mapOld == null || mapOld.get(oSBQQ_Quote.ID).SBQQ__ShippingCountry__c != oSBQQ_Quote.SBQQ__ShippingCountry__c || oSBQQ_Quote.Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c)) {//SALESRT-14285
                isShipToChanged = true;
            }
            
            if(!Test.isRunningTest()) {
                if(mapOld == null && oSBQQ_Quote.Route_To_Market__c != null && oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate) {
                    oSBQQ_Quote.Legal_Entity__c = Label.Legal_Entity_Informatica_LLC;
                    isMarketplacePrivate = true;
                } //SALESRT-14285
                else if(mapOld != null && oSBQQ_Quote.Route_To_Market__c != null && oSBQQ_Quote.Route_To_Market__c == Label.MarketPlacePrivate
                    && ( oSBQQ_Quote.Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c 
                        || (oSBQQ_Quote.Detail_RTM__c != null && oSBQQ_Quote.Detail_RTM__c != mapOld.get(oSBQQ_Quote.Id).Detail_RTM__c && (oSBQQ_Quote.Detail_RTM__c == Label.MicrosoftAzure 
                        || oSBQQ_Quote.Detail_RTM__c == Label.AmazonAWS || oSBQQ_Quote.Detail_RTM__c == Label.AmazonAWSPartner || oSBQQ_Quote.Detail_RTM__c == Label.GCP ))) ) {
                            oSBQQ_Quote.Legal_Entity__c = Label.Legal_Entity_Informatica_LLC;
                            isMarketplacePrivate = true;
                }//SALESRT-14285
            }
            
            
        }
        
        if(isShipToChanged && !isMarketplacePrivate){
            if(countries != ''){
                //Query for Legal Entities
                legalEntityList = [SELECT Id, Name, Multi_Country_Mapping1__c, Multi_Country_Mapping2__c, CurrencyIsoCode  from blng__LegalEntity__c where Multi_Country_Mapping1__c INCLUDES (:countries) or Multi_Country_Mapping2__c INCLUDES (:countries)]; //Self-Quote- added CurrencyIsoCode
            }
            
            //Create maps for countries in Multi_Country_Mapping1__c and Multi_Country_Mapping2__c, with Legal Entity
            Map<String, Id> multiCountryMapping1Map = new Map<String, Id> ();
            Map<String, Id> multiCountryMapping2Map = new Map<String, Id> ();
            for(blng__LegalEntity__c legalEntity : legalEntityList){
                List<String> countryMapping1List = new List<String>();
                List<String> countryMapping2List = new List<String>();
                
                if(String.isNotBlank(legalEntity.Multi_Country_Mapping1__c)){
                    countryMapping1List = legalEntity.Multi_Country_Mapping1__c.split(';');
                }
                
                if(String.isNotBlank(legalEntity.Multi_Country_Mapping2__c)){
                    countryMapping2List = legalEntity.Multi_Country_Mapping2__c.split(';');
                }
                
                if(countryMapping1List.size() > 0){
                    for(String country1 : countryMapping1List){
                        if(!multiCountryMapping1Map.containsKey(country1.toLowerCase())){ //<T02>
                            multiCountryMapping1Map.put(country1.toLowerCase(), legalEntity.Id); //<T02>
                        }
                    }
                }
                
                if(countryMapping2List.size() > 0){
                    for(String country2 : countryMapping2List){
                        if(!multiCountryMapping2Map.containsKey(country2.toLowerCase())){ //<T02>
                            multiCountryMapping2Map.put(country2.toLowerCase(), legalEntity.Id); //<T02>
                        }
                    }
                }
            }
            
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){ 
                //Update LegalEntity if For New Quote or if Ship To Country is changed
                if(oSBQQ_Quote.SBQQ__ShippingCountry__c != null && (mapOld == null || mapOld.get(oSBQQ_Quote.ID).SBQQ__ShippingCountry__c != oSBQQ_Quote.SBQQ__ShippingCountry__c || oSBQQ_Quote.Route_To_Market__c != mapOld.get(oSBQQ_Quote.Id).Route_To_Market__c)) {
                    if(multiCountryMapping1Map.containsKey(oSBQQ_Quote.SBQQ__ShippingCountry__c.toLowerCase())){
                        oSBQQ_Quote.Legal_Entity__c = multiCountryMapping1Map.get(oSBQQ_Quote.SBQQ__ShippingCountry__c.toLowerCase());
                    }else if(multiCountryMapping2Map.containsKey(oSBQQ_Quote.SBQQ__ShippingCountry__c.toLowerCase())){
                        oSBQQ_Quote.Legal_Entity__c = multiCountryMapping2Map.get(oSBQQ_Quote.SBQQ__ShippingCountry__c.toLowerCase());
                        
                    }
                    GAM.CreateLogs('QuoteTriggerHandler.updateQuoteLegalEntity', oSBQQ_Quote.Id, 'oSBQQ_Quote.Legal_Entity__c', oSBQQ_Quote.Legal_Entity__c);
                }
            }
            
            GAM.InsertDebugLogs();
        }

    }
    
    
    /*Method Name : setValuesForNewQuote
    * @param List<SBQQ__Quote__c> lstTriggerNew
    * @return return-void
    * @throws exception - NA
    */
    /*<T06>Method to Set Values on 'New' Type of Quote, when a new Quote is created. All quote update logic from 'Set Values Quote' Process Builder has been moved in here.
    This Method is called from 'Before Insert' Event on SBQQ__Quote__c Object </T06>*/ 
    private static void setValuesForNewQuote(List<SBQQ__Quote__c> lstTriggerNew){
        Set<Id> setOpportunityIds = new Set<Id>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__Opportunity2__c != null){
                setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);   
            }
        }
        
        if(setOpportunityIds.size() > 0){
            //Query values from Opportunity to be populated on Quote
            mapOpportunity = queryOpportunity(setOpportunityIds);
        }
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            //setValuesForAllQuoteTypes(oSBQQ_Quote, mapOpportunity);

                
            oSBQQ_Quote.Shipping_Preference__c = 'Mail';
            
            if(oSBQQ_Quote.SBQQ__Opportunity2__c != null && mapOpportunity.containskey(oSBQQ_Quote.SBQQ__Opportunity2__c)){
                oSBQQ_Quote.CurrencyIsoCode = mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).CurrencyIsoCode;
            }
                
            /*<T30>
            //Default PriceBook Based on the Territory
            system.debug('Territory__c:'+oSBQQ_Quote.Territory__c);
            if(oSBQQ_Quote.Territory__c != null && oSBQQ_Quote.Territory__c.startsWith('APJ')){ //APJ has been split to AP and JP
            oSBQQ_Quote.Price_Book_2__c = Label.List_Price_Book_APJ_Id;
            oSBQQ_Quote.SBQQ__PricebookId__c = Label.List_Price_Book_APJ_Id;
            }else if( oSBQQ_Quote.Territory__c != null && oSBQQ_Quote.Territory__c.startsWith('EA_S_LAT')){//<T15>
            oSBQQ_Quote.Price_Book_2__c = Label.List_Price_Book_LATAM_Id;
            oSBQQ_Quote.SBQQ__PricebookId__c = Label.List_Price_Book_LATAM_Id;
            }else if(oSBQQ_Quote.Territory__c != null && oSBQQ_Quote.Territory__c.startsWith('EA')){//<T15>
            oSBQQ_Quote.Price_Book_2__c = Label.List_Price_Book_EMEA_Id;
            oSBQQ_Quote.SBQQ__PricebookId__c = Label.List_Price_Book_EMEA_Id;     
            }else{
            oSBQQ_Quote.Price_Book_2__c = Label.List_Book_Price_US_Id;
            oSBQQ_Quote.SBQQ__PricebookId__c = Label.List_Book_Price_US_Id;
            }
            </T30>*/
            //<T32>
            //SBQQ__PriceBook__c population based on SBQQ__PricebookId__c until CPQ is upgraded to version 214 or higher
            system.debug('Price Book'+oSBQQ_Quote.SBQQ__PriceBook__c+ '= Pricebook ID' +oSBQQ_Quote.SBQQ__PricebookId__c);
            if(oSBQQ_Quote.SBQQ__PriceBook__c == null) {
                oSBQQ_Quote.SBQQ__PriceBook__c = oSBQQ_Quote.SBQQ__PricebookId__c;
            }
            //<T32>    
            GAM.CreateLogs('QuoteTriggerHandler.setValuesForNewQuote', oSBQQ_Quote, 'New Quote Values on Insert:');
        }
        GAM.InsertDebugLogs();
    }
    
    /*
    Method Name : setValuesForRenewalQuote
    * @param List<SBQQ__Quote__c> lstTriggerNew
    * @return return-void
    * @throws exception - NA
    */
    /*<T06>Method to Set Values on 'Renewal' Type of Quote, when a new Quote is created. All quote update logic from 'Set Values Quote' Process Builder has been moved in here.
    This Method is called from 'Before Insert' Event on SBQQ__Quote__c Object </T06>*/ 
    private static void setValuesForRenewalQuote(List<SBQQ__Quote__c> lstTriggerNew){
        Set<Id> setOpportunityIds = new Set<Id>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Set<Id> setContractIdsWithoutOrder = new Set<Id>();
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            //setValuesForAllQuoteTypes(oSBQQ_Quote, mapOpportunity);
            
            oSBQQ_Quote.RecordTypeId = Label.Draft_Renewal_Quote_Record_Type; //Set Record type to Draft_Renewal_Quote_Record_Type
            oSBQQ_Quote.EditLinesFieldSetName__c = 'Renewal';
            
            //---------------------------------------------------------------------------------------------------------<T18>
            if(oSBQQ_Quote.Related_Contract__c == null && oSBQQ_Quote.SBQQ__Opportunity2__c != null){
                setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);
            }
            //---------------------------------------------------------------------------------------------------------</T18>
            
            //<T32>
            //SBQQ__PriceBook__c population based on SBQQ__PricebookId__c until CPQ is upgraded to version 214 or higher
            system.debug('Price Book'+oSBQQ_Quote.SBQQ__PriceBook__c+ '= Pricebook ID' +oSBQQ_Quote.SBQQ__PricebookId__c);
            if(oSBQQ_Quote.SBQQ__PriceBook__c == null) {
                oSBQQ_Quote.SBQQ__PriceBook__c = oSBQQ_Quote.SBQQ__PricebookId__c;
            }
            //<T32> 
            GAM.CreateLogs('QuoteTriggerHandler.setValuesForRenewalQuote', oSBQQ_Quote, 'Renewal Quote Values on Insert:');
        }
        
        //---------------------------------------------------------------------------------------------------------<T18>
        //Code Added to populate SBQQ__RenewalTerm__c on the Renewal Quotes created from the Migrated Contracts.
        if(setOpportunityIds.size() > 0){
            mapOpportunity = queryOpportunity(setOpportunityIds);
        }
        
        //for new Renewal Quotes created from mirgated contracts(where Orde is null) - Collect Contract Id from Opportunity SBQQ__RenewedContract__c field in setContractIdsWithoutOrder
        for(Opportunity opp : mapOpportunity.values()){
            if(opp.SBQQ__RenewedContract__c != null){ //Removed condition '&& opp.SBQQ__RenewedContract__r.SBQQ__Order__c == null'<T22>
                setContractIdsWithoutOrder.add(opp.SBQQ__RenewedContract__c);
            } 
        }
        
        Map<Id, Contract> mapContractWithoutOrder = new Map<Id, Contract>();
        if(setContractIdsWithoutOrder.size() > 0){
            //created map mapContractWithoutOrder to get the SBQQ__RenewalTerm__c, to be populated on the Renewal Quote
            mapContractWithoutOrder = new Map<Id, Contract>([SELECT Id,SBQQ__RenewalTerm__c
                                                             //SBQQ__Quote__r.Secondary_Partner__c //<SALESRT-13387><SALESRT-13635>
                                                             FROM Contract 
                                                             WHERE Id IN : setContractIdsWithoutOrder]);
            
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
                if(oSBQQ_Quote.SBQQ__Opportunity2__c != null && mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null
                   && mapContractWithoutOrder.containskey(mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c) ){//removed order check condition<T22>
                       oSBQQ_Quote.SBQQ__SubscriptionTerm__c = mapContractWithoutOrder.get(mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).SBQQ__RenewalTerm__c;
                       system.debug('SBQQ__EndDate__c:'+oSBQQ_Quote.SBQQ__EndDate__c);
                       oSBQQ_Quote.SBQQ__EndDate__c = null; //make End date as null<T22>
                       //oSBQQ_Quote.Secondary_Partner__c = mapContractWithoutOrder.get(mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).SBQQ__Quote__r.Secondary_Partner__c;//<SALESRT-13387><SALESRT-13635>
                   }
            }
            
        }
        //---------------------------------------------------------------------------------------------------------</T18>
        
        //setRenewalQuoteValuesFromContract(lstTriggerNew, null, mapOpportunity);
        GAM.InsertDebugLogs();
    }
    
    /*
    Method Name : setValuesForAmendQuote
    * @param List<SBQQ__Quote__c> lstTriggerNew
    * @return return-void
    * @throws exception - NA
    */
    /*<T06>Method to Set Values on 'Amendment' Type of Quote, when a new Quote is created. All quote update logic from 'Set Values Quote' Process Builder has been moved in here.
    This Method is called from 'Before Insert' Event on SBQQ__Quote__c Object </T06>*/ 
    private static void setValuesForAmendQuote(List<SBQQ__Quote__c> lstTriggerNew){
        
        //<T21> Query Contract starts
        Set<Id> contractIds = new Set<Id>();
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__MasterContract__c != null){
                contractIds.add(oSBQQ_Quote.SBQQ__MasterContract__c);
            }
        }
        Map<Id,Contract> masterContracts = new Map<Id,Contract>([Select Id,Annual_Recurring_Revenue1__c,Software_Annual_Recurring_Revenue1__c,Support_Annual_Recurring_Revenue1__c
                                                                 //SBQQ__Quote__r.Secondary_Partner__c //<SALESRT-13387><SALESRT-13635>
                                                                 from Contract where Id In: contractIds ]);
        //<T21> Query Contract End
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            //setValuesForAllQuoteTypes(oSBQQ_Quote, mapOpportunity);
            
            oSBQQ_Quote.RecordTypeId = Label.Draft_Amendment_Quote_Record_Type; //Set Record type to Draft_Renewal_Quote_Record_Type
            oSBQQ_Quote.EditLinesFieldSetName__c = 'Amendment';
            system.debug('SBQQ__MasterContract__c:'+oSBQQ_Quote.SBQQ__MasterContract__c);
            
            //<T21> Start Updating Amendment ARR fields from MasterContract.
            if(oSBQQ_Quote.SBQQ__MasterContract__c != null && masterContracts.containsKey(oSBQQ_Quote.SBQQ__MasterContract__c)){
                oSBQQ_Quote.Amendment_Original_ARR__c = masterContracts.get(oSBQQ_Quote.SBQQ__MasterContract__c).Annual_Recurring_Revenue1__c;
                oSBQQ_Quote.Amendment_Original_Software_ARR__c = masterContracts.get(oSBQQ_Quote.SBQQ__MasterContract__c).Software_Annual_Recurring_Revenue1__c;
                oSBQQ_Quote.Amendment_Original_Support_ARR__c = masterContracts.get(oSBQQ_Quote.SBQQ__MasterContract__c).Support_Annual_Recurring_Revenue1__c;
                //oSBQQ_Quote.Secondary_Partner__c = masterContracts.get(oSBQQ_Quote.SBQQ__MasterContract__c).SBQQ__Quote__r.Secondary_Partner__c;//<SALESRT-13387><SALESRT-13635>
            }
            //<T21> END
            
            //<T32>
            //SBQQ__PriceBook__c population based on SBQQ__PricebookId__c until CPQ is upgraded to version 214 or higher
            system.debug('Price Book'+oSBQQ_Quote.SBQQ__PriceBook__c+ '= Pricebook ID' +oSBQQ_Quote.SBQQ__PricebookId__c);
            if(oSBQQ_Quote.SBQQ__PriceBook__c == null) {
                oSBQQ_Quote.SBQQ__PriceBook__c = oSBQQ_Quote.SBQQ__PricebookId__c;
            }
            //<T32> 
            GAM.CreateLogs('QuoteTriggerHandler.setValuesForAmendQuote', oSBQQ_Quote, 'Amendment Quote Values on Insert:');
        }
        GAM.InsertDebugLogs();
    }
    
    /*
    Method Name : setValuesForAllQuoteTypes
    * @param SBQQ__Quote__c sbqq_quote, Opportunity opp
    * @return return-void
    * @throws exception - NA
    */
    /*<T06>Method to Set few Values on All Types of Quote, when a new Quote is created. All quote update logic from 'Set Values Quote' Process Builder has been moved in here.
    This Method is called from 'Before Insert' Event on Quote object </T06>*/ 
    
    private static void setValuesForAllQuoteTypes(List<SBQQ__Quote__c> lstTriggerNew){
        Set<Id> setOpportunityIds = new Set<Id>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__Opportunity2__c != null){
                setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);   
            }
        }
        
        if(setOpportunityIds.size() > 0){
            //Query values from Opportunity to be populated on Quote
            mapOpportunity = queryOpportunity(setOpportunityIds);
        }
        
        for(SBQQ__Quote__c sbqq_quote : lstTriggerNew){
            sbqq_quote.SBQQ__WatermarkShown__c = True;
            
            if(sbqq_quote.SBQQ__Opportunity2__c != null && mapOpportunity.containskey(sbqq_quote.SBQQ__Opportunity2__c)){
                if(!sbqq_quote.isSelfService__c) //Added for SALESRT-15481 Ability for Reps to Self Quote - override expiration date from Flow
                sbqq_quote.SBQQ__ExpirationDate__c = mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).CloseDate;
                sbqq_quote.SBQQ__SalesRep__c = mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).OwnerId;
                sbqq_quote.Quote_Description__c = mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).Name;
                //<T41>
                if(mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).Admin__c) {
                    sbqq_quote.Sub_Type__c = Label.RevisionLabel;
                    sbqq_quote.OwnerId = mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).OwnerId;
                }
                //</T41>
                //<T46>
                sbqq_quote.Compliance_Settlement__c = mapOpportunity.get(sbqq_quote.SBQQ__Opportunity2__c).PT_INFA_License_Compliance__c;
                //</T46>
            }
            
            system.debug('End_Date_Output__c:'+sbqq_quote.End_Date_Output__c);
            if(sbqq_quote.End_Date_Output__c != null){
                if(sbqq_quote.End_Date_Output__c.day() == 31 && (sbqq_quote.End_Date_Output__c.month() == 01 || sbqq_quote.End_Date_Output__c.month() == 03 || sbqq_quote.End_Date_Output__c.month() == 05
                                                                 || sbqq_quote.End_Date_Output__c.month() == 07 || sbqq_quote.End_Date_Output__c.month() == 08 || sbqq_quote.End_Date_Output__c.month() == 10 || sbqq_quote.End_Date_Output__c.month() == 12)){
                                                                     sbqq_quote.End_Date_Equals_30__c = False;
                                                                     sbqq_quote.End_Date_Equals_31__c = True;
                                                                 }else if(sbqq_quote.End_Date_Output__c.day() == 30 && (sbqq_quote.End_Date_Output__c.month() == 04 || sbqq_quote.End_Date_Output__c.month() == 06 || sbqq_quote.End_Date_Output__c.month() == 09
                                                                                                                        || sbqq_quote.End_Date_Output__c.month() == 11)){
                                                                                                                            sbqq_quote.End_Date_Equals_30__c = True;
                                                                                                                            sbqq_quote.End_Date_Equals_31__c = False;
                                                                                                                        }
            }            
        } 
         setESApprovalValues(lstTriggerNew,mapOpportunity);//<F2A-370>
    }
    //---------------------------------------------------------------------------<F2A-370>  
    /*Method Name : setESApprovalValues
    * @param List<SBQQ__Quote__c> lstTriggerNew, Map<Id, Opportunity> mapOpportunity
    * @return return-void
    * @throws exception - NA
    */  
    private static void setESApprovalValues(List<SBQQ__Quote__c> lstTriggerNew,Map<Id, Opportunity> mapOpportunity){
        Map<Id,String> mapOptySubRegion= new Map<Id,String>();
        Map<String,Id> mapSubregionISR= new Map<String,Id>();
        Map<String,Id> mapSubregionAM= new Map<String,Id>();
        
        //get list of subregions
        for(Opportunity Op: mapOpportunity.values()){
            if(Op.Territory2!= null && Op.Territory2.Sub_region__c!= null)
                mapOptySubRegion.put(Op.Id, Op.Territory2.Sub_region__c);
        } 
        //Get Approvers based on subregion from custom metatdata
        for( ES_Approver_Matrix__c approver : [Select Id, Sub_Region__c, SubRegion_ISR__c, SubRegion_AM__c from ES_Approver_Matrix__c where Sub_Region__c in :mapOptySubRegion.values()]){
            if(approver.Sub_Region__c != null && approver.SubRegion_ISR__c!= null)
                mapSubregionISR.put(approver.Sub_Region__c,approver.SubRegion_ISR__c);
            if(approver.Sub_Region__c != null && approver.SubRegion_AM__c!= null)
                mapSubregionAM.put(approver.Sub_Region__c,approver.SubRegion_AM__c);
        }
        
        //Update Quote fields with approvers
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
            if(oSBQQ_Quote.SBQQ__Opportunity2__c!=null && mapOptySubRegion.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && mapSubregionISR.containskey(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c))){
                oSBQQ_Quote.ES_SubRegion_ISR__c = mapSubregionISR.get(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c));
            }
            if(oSBQQ_Quote.SBQQ__Opportunity2__c!=null && mapOptySubRegion.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && mapSubregionAM.containskey(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c))){
                oSBQQ_Quote.ES_SubRegion_AM__c= mapSubregionAM.get(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c));
            }
        }
    }
    //------------------------------------------------------------------------------</F2A-370>      
    
    /*
    Method Name : updateQuoteValues
    * @param List<SBQQ__Quote__c> lstQuotes, Map<Id, SBQQ__Quote__c> mapOld
    * @return return-void
    * @throws exception - NA
    */
    /*<T07>Method to Update Quote Values if following fields are changed. Update Logic from 'Update Quote values' Process Builder has been moved here.
    1. Bill To Account
    2. End User Account
    3. Price Book 2
    4. End date Output
    5. Approval Status
    6. Create CMS Request Enagement Record is required
    This Method is called from 'Before Update' Event on SBQQ__Quote__c Object
    </T07>*/
    private static void updateQuoteValues(List<SBQQ__Quote__c> lstQuotes, Map<Id, SBQQ__Quote__c> mapOld){

        Set<id> setAccountIds = new Set<Id>();
        Map<Id, Account> mapAccount = new Map<Id, Account>();
        List<SBQQ__Quote__c> lstQuotesCMSRequest = new List<SBQQ__Quote__c>(); //<T50>
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuotes){
            if(oSBQQ_Quote.BillToAccount__c != null && oSBQQ_Quote.BillToAccount__c != mapOld.get(oSBQQ_Quote.Id).BillToAccount__c){
                setAccountIds.add(oSBQQ_Quote.BillToAccount__c); //get set of Bill To Account Ids related to Quotes
            } 
            if(oSBQQ_Quote.EndUserAccount__c != null && oSBQQ_Quote.EndUserAccount__c != mapOld.get(oSBQQ_Quote.Id).EndUserAccount__c){
                setAccountIds.add(oSBQQ_Quote.EndUserAccount__c);//get set of EndUSer Account Ids related to Quotes
            }

            //-------------------------------------------------------------------------------------------------<T50>
            if((oSBQQ_Quote.SBQQ__Type__c == 'Quote' || oSBQQ_Quote.SBQQ__Type__c == 'Renewal') && oSBQQ_Quote.Business_Unit__c == 'US001' && oSBQQ_Quote.SBQQ__Opportunity2__c != null && (oSBQQ_Quote.SoldToAccount__c != null || oSBQQ_Quote.BillToAccount__c != null) && oSBQQ_Quote.SBQQ__ShippingCountry__c != null
            && (oSBQQ_Quote.SoldToAccount__c != mapOld.get(oSBQQ_Quote.Id).SoldToAccount__c || oSBQQ_Quote.BillToAccount__c != mapOld.get(oSBQQ_Quote.Id).BillToAccount__c || oSBQQ_Quote.SBQQ__ShippingCountry__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__ShippingCountry__c)){
                lstQuotesCMSRequest.add(oSBQQ_Quote);
            }  
            //-------------------------------------------------------------------------------------------------</T50>          
        }
        
        if(setAccountIds.size() > 0){
            //Query on Account to get Account Name
            mapAccount = new Map<Id, Account>([select Id, Name from Account where Id in : setAccountIds]);
        }
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuotes){
            //Update 'Bill to Account Output' if Bill To Account is changed
            if(oSBQQ_Quote.BillToAccount__c != null && oSBQQ_Quote.BillToAccount__c != mapOld.get(oSBQQ_Quote.Id).BillToAccount__c){
                oSBQQ_Quote.Bill_to_account_Text__c = mapAccount.get(oSBQQ_Quote.BillToAccount__c).Name;
            }
            
            //Update 'End User Account Text' if End User Account is changed.
            if(oSBQQ_Quote.EndUserAccount__c != null && oSBQQ_Quote.EndUserAccount__c != mapOld.get(oSBQQ_Quote.Id).EndUserAccount__c){
                oSBQQ_Quote.End_User_Account_Text__c = mapAccount.get(oSBQQ_Quote.EndUserAccount__c).Name;
            }
            /*<T30>
            //Update SBQQ PricebookId if Price_book_2__c is updated.
            if(oSBQQ_Quote.Price_book_2__c != null && oSBQQ_Quote.Price_book_2__c != mapOld.get(oSBQQ_Quote.Id).Price_book_2__c){
            oSBQQ_Quote.SBQQ__PricebookId__c = oSBQQ_Quote.Price_book_2__c;
            }</T30>*/
            
            system.debug('oSBQQ_Quote.End_Date_Output__c:'+oSBQQ_Quote.End_Date_Output__c);
            //update 'End_Date_Equals_30__c' and 'End_Date_Equals_31__c' if End_Date_Output__c is changed
            if(oSBQQ_Quote.End_Date_Output__c != null && oSBQQ_Quote.End_Date_Output__c != mapOld.get(oSBQQ_Quote.Id).End_Date_Output__c){
                if(oSBQQ_Quote.End_Date_Output__c.day() == 31 && (oSBQQ_Quote.End_Date_Output__c.month() == 01 || oSBQQ_Quote.End_Date_Output__c.month() == 03 || oSBQQ_Quote.End_Date_Output__c.month() == 05
                                                                  || oSBQQ_Quote.End_Date_Output__c.month() == 07 || oSBQQ_Quote.End_Date_Output__c.month() == 08 || oSBQQ_Quote.End_Date_Output__c.month() == 10 || oSBQQ_Quote.End_Date_Output__c.month() == 12)){
                                                                      oSBQQ_Quote.End_Date_Equals_30__c = False;
                                                                      oSBQQ_Quote.End_Date_Equals_31__c = True;
                                                                  }else if(oSBQQ_Quote.End_Date_Output__c.day() == 30 && (oSBQQ_Quote.End_Date_Output__c.month() == 04 || oSBQQ_Quote.End_Date_Output__c.month() == 06 || oSBQQ_Quote.End_Date_Output__c.month() == 09
                                                                                                                          || oSBQQ_Quote.End_Date_Output__c.month() == 11)){
                                                                                                                              oSBQQ_Quote.End_Date_Equals_30__c = True;
                                                                                                                              oSBQQ_Quote.End_Date_Equals_31__c = False;
                                                                                                                          }
            }
            
            
            //update RecordtypeId, Status and WaterMark Shown, if Approval Status is changed.
            if(oSBQQ_Quote.ApprovalStatus__c != null && oSBQQ_Quote.ApprovalStatus__c != mapOld.get(oSBQQ_Quote.Id).ApprovalStatus__c){
                if(oSBQQ_Quote.ApprovalStatus__c == 'Pending'){
                    oSBQQ_Quote.SBQQ__Status__c = 'In Review';
                    oSBQQ_Quote.SBQQ__WatermarkShown__c = True;
                    oSBQQ_Quote.RecordTypeId = Label.Pending_Quote_Record_Type;
                }else if(oSBQQ_Quote.ApprovalStatus__c == 'Approved'){
                    oSBQQ_Quote.SBQQ__Status__c = 'Approved';
                    oSBQQ_Quote.SBQQ__WatermarkShown__c = False;
                    oSBQQ_Quote.RecordTypeId = Label.Approved_Quote_Record_Type;
                }else if(oSBQQ_Quote.ApprovalStatus__c == 'Rejected' || oSBQQ_Quote.ApprovalStatus__c == 'Recalled'){
                    if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_New){
                        oSBQQ_Quote.RecordTypeId = Label.Draft_Quote_Record_Type;
                    }else if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Renewal){
                        oSBQQ_Quote.RecordTypeId = Label.Draft_Renewal_Quote_Record_Type;
                    }else if(oSBQQ_Quote.SBQQ__Type__c == Label.Quote_Type_Amendment){
                        oSBQQ_Quote.RecordTypeId = Label.Draft_Amendment_Quote_Record_Type;
                    }
                    if(oSBQQ_Quote.ApprovalStatus__c == 'Rejected'){
                        oSBQQ_Quote.SBQQ__Status__c = 'Denied';
                        oSBQQ_Quote.SBQQ__WatermarkShown__c = True;
                        
                    }else if(oSBQQ_Quote.ApprovalStatus__c == 'Recalled'){
                        oSBQQ_Quote.SBQQ__Status__c = 'Draft';
                        oSBQQ_Quote.SBQQ__WatermarkShown__c = True;
                        
                    }
                }
            }
            
            //<T19>
            oSBQQ_Quote.DEV_Override_Default_is_Null__c = oSBQQ_Quote.Override_Default_Language__c != null && oSBQQ_Quote.Override_Default_Language__c.length() > 0 ? False : True;
            oSBQQ_Quote.DEV_Partner_Override_Default_is_Null__c = oSBQQ_Quote.Partner_Override_Default_Language__c != null && oSBQQ_Quote.Partner_Override_Default_Language__c.length() > 0 ? False : True;
            //</T19>
            
            //<T25>
            oSBQQ_Quote.DEV_Special_Remarks_Is_Null__c = oSBQQ_Quote.Special_Remarks1__c != null && oSBQQ_Quote.Special_Remarks1__c.length() > 0 ? False : True;
            oSBQQ_Quote.DEV_Partner_Special_Remarks_Is_Null__c = oSBQQ_Quote.Partner_Special_Remarks__c  != null && oSBQQ_Quote.Partner_Special_Remarks__c.length() > 0 ? False : True;
            //</T25>
            
            GAM.CreateLogs('QuoteTriggerHandler.updateQuoteValues', oSBQQ_Quote, 'Quote Values After update:');            
        }
        //--------------------------------------------------------------------------<T50>
        if(!lstQuotesCMSRequest.isEmpty()){
            createCMSRequest(lstQuotesCMSRequest);
        }
        //--------------------------------------------------------------------------</T50>
        GAM.InsertDebugLogs();        
    }
    
    /*
Method Name : setRenewalQuoteValuesFromContract
* @param List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> mapOld
* @return return-void
* @throws exception - NA
*/
    /*<T08>Method to Populate Update Related Contract Field on Quote from Opportunity 'RenewedContract' field, if Quote is generated through CPQ Renewal Opportunity and Renewal Quote generation process.
Method to Map Related Contract's parent Quote and Order Values to Renewal Quote on Create and Update(If Related Contract is changed).
This Method is called from 'Before Update' Event on SBQQ__Quote__c Object </T08>*/
    
    private static void setRenewalQuoteValuesFromContract(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> mapOld){
        Set<Id> setOpportunityIds = new Set<Id>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        //Set<Id> setContractIds = new Set<Id>();
        Map<Id, Contract> mapContracts = new Map<Id, Contract>();
        //<T17 Start> 
        //CODE ADDED FOR CM-6
        Set<Id> setContractIdsWithOrder = new Set<Id>();
        Set<Id> setContractIdsWithoutOrder = new Set<Id>();
        
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
            if(oSBQQ_Quote.Related_Contract__c == null && oSBQQ_Quote.SBQQ__Opportunity2__c != null){//For Insert
                setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);
            } else if(oSBQQ_Quote.Related_Contract__c != null && oSBQQ_Quote.Related_Contract__c != mapOld.get(oSBQQ_Quote.Id).Related_Contract__c){//For Update, if Related Contract value is changed
                if(oSBQQ_Quote.Related_Contract__r.SBQQ__Order__c != null){
                    setContractIdsWithOrder.add(oSBQQ_Quote.Related_Contract__r.Id);
                }
                else{
                    setContractIdsWithoutOrder.add(oSBQQ_Quote.Related_Contract__r.Id);
                }
            }
        }
        
        if(setOpportunityIds.size() > 0){
            //Query values from Opportunity to be populated on Quote
            mapOpportunity = queryOpportunity(setOpportunityIds);
        }
        
        //for new Renewal Quotes - Collect Contract Id from Opportunity SBQQ__RenewedContract__c field in setContractIds
        for(Opportunity opp : mapOpportunity.values()){
            if(opp.SBQQ__RenewedContract__c != null){ 
                //setContractIds.add(opp.SBQQ__RenewedContract__c);
                if(opp.SBQQ__RenewedContract__r.SBQQ__Order__c != null){
                    setContractIdsWithOrder.add(opp.SBQQ__RenewedContract__c);
                }
                else{
                    setContractIdsWithoutOrder.add(opp.SBQQ__RenewedContract__c);
                }
            } 
        }
        //system.debug('setContractIds1:'+setContractIds);
        
        Map<Id, Contract> mapContractWithoutOrder = new Map<Id, Contract>();
        
        //CODE ADDED FOR CM-6 - Updating the Map
        //Fetch Contract's Parent Order Fields and Parent Quote Fields 
        if(setContractIdsWithOrder.size() > 0){
            
            mapContracts = new Map<Id, Contract>([SELECT Id, SBQQ__Quote__r.Id, SBQQ__Quote__r.Additional_Customer_Signature_Blocks__c, SBQQ__Quote__r.Compliance_Settlement__c, SBQQ__Quote__r.Custom_Support_SLAs__c, SBQQ__Quote__r.ELA_Terms__c, SBQQ__Quote__r.INFA_Signature_Blocks__c, SBQQ__Quote__r.IPS_Custom_Travel_Policy__c, SBQQ__Quote__r.IPS_Price_Holds__c, SBQQ__Quote__r.Legal_Entity__c, SBQQ__Quote__r.License_Price_Protection__c, SBQQ__Quote__r.Max_License_Uplift_Term__c, SBQQ__Quote__r.Max_License_Uplift__c, SBQQ__Quote__r.Max_Subscription_Uplift_Term__c, SBQQ__Quote__r.Max_Subscription_Uplift__c, SBQQ__Quote__r.Max_Support_Uplift_Term__c, SBQQ__Quote__r.Max_Support_Uplift__c, 
                                                  SBQQ__Quote__r.Non_Standard_Acceptance_Clause__c, SBQQ__Quote__r.PDS_Text__c, SBQQ__Quote__r.Partner_Name_for_Signature_Block__c, SBQQ__Quote__r.Price_Holds__c, SBQQ__Quote__r.Product_Restrictions__c, SBQQ__Quote__r.Recovery_License__c, SBQQ__Quote__r.Regular_Total_of_Lines__c, SBQQ__Quote__r.Remote_Access__c, SBQQ__Quote__r.Reseller_Customer_Support_Fee__c, SBQQ__Quote__r.Reseller_Support_Level__c, SBQQ__Quote__r.Reseller_Support_Percent_of_Total__c, SBQQ__Quote__r.Security_Exhibits__c, SBQQ__Quote__r.Special_Remarks_Conditional_Print__c, SBQQ__Quote__r.Subscription_Price_Remix__c, SBQQ__Quote__r.Suppress_Included_Features__c, 
                                                  SBQQ__Quote__r.Use_Restriction_Description__c, SBQQ__Quote__r.Shipping_Email__c, SBQQ__Quote__r.Shipping_Preference__c, SBQQ__Quote__r.Override_Support_Level__c, SBQQ__Order__c, SBQQ__Order__r.BillingAddress_PSFTID__c, SBQQ__Order__r.BillingName_PSFTID__c, SBQQ__Order__r.EndUserAddress_PSFTID__c, SBQQ__Order__r.EndUserCity__c, SBQQ__Order__r.EndUserCountry__c, SBQQ__Order__r.EndUserPostalCode__c, SBQQ__Order__r.EndUserStateProvince__c, SBQQ__Order__r.EndUserStreet__c, SBQQ__Order__r.BillingCity, SBQQ__Order__r.BillingCountry, SBQQ__Order__r.BillingState, SBQQ__Order__r.BillingStreet, SBQQ__Order__r.BillingPostalCode, SBQQ__Order__r.ShippingCity, 
                                                  SBQQ__Order__r.ShippingCountry, SBQQ__Order__r.ShippingState, SBQQ__Order__r.ShippingStreet, SBQQ__Order__r.ShippingPostalCode, SBQQ__Order__r.ShippingAddress_PSFTID__c, SBQQ__Order__r.ShippingName_PSFTID__c, SBQQ__Order__r.Shipping_Email__c, SBQQ__Order__r.Shipping_Preference__c, SBQQ__Order__r.SoldAddress_PSFTID__c, SBQQ__Order__r.SoldCity__c, SBQQ__Order__r.SoldCountry__c, SBQQ__Order__r.SoldPostalCode__c, SBQQ__Order__r.SoldStateProvince__c, SBQQ__Order__r.SoldStreet__c, SBQQ__Order__r.BilltoAccount__c,SBQQ__Order__r.BilltoAccount__r.Name, SBQQ__Order__r.EndUserAccount__c,SBQQ__Order__r.EndUserAccount__r.Name, SBQQ__Order__r.ShipToAccount__c, SBQQ__Order__r.SoldToAccount__c, SBQQ__Order__r.BillToContactId, 
                                                  SBQQ__Quote__r.Uplift_Applied__c,Uplift_Notes__c, // T40
                                                  SBQQ__Order__r.EndUserContact__c, SBQQ__Order__r.ShipToContactId, SBQQ__Order__r.SoldToContact__c, SBQQ__Quote__r.Price_Book_2__c, SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__Quote__r.SBQQ__PricebookId__c, SBQQ__Quote__r.Coversheet_Checklist_Type__c, SBQQ__Quote__r.PO__c, SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.SBQQ__BillingFrequency__c, ContractTerm, SBQQ__Quote__r.Contracted_Uplift__c, Business_Model__c, SBQQ__Order__r.Sub_Type__c, SBQQ__Quote__r.Sub_Type__c,SBQQ__Order__r.Business_Model__c, SBQQ__Quote__r.Business_Model__c,Renewal_Quote_Owner__c
                                                  FROM Contract 
                                                  WHERE Id IN : setContractIdsWithOrder]);
            
            for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
                if(oSBQQ_Quote.Related_Contract__c == null && oSBQQ_Quote.SBQQ__Opportunity2__c != null && mapOpportunity.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c)){
                    system.debug('oSBQQ_Quote.Related_Contract__c is null');
                    if(mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null){
                        //Populate the Quote's Related Contract with the Quote's related Opportunity Renewed Contract
                        oSBQQ_Quote.Related_Contract__c = mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c;
                        if(mapContracts.containsKey(oSBQQ_Quote.Related_Contract__c)){
                            getValuesFromContract(oSBQQ_Quote, mapContracts, oSBQQ_Quote.Related_Contract__c);
                        }
                    }
                }else if(oSBQQ_Quote.Related_Contract__c != null && oSBQQ_Quote.Related_Contract__c != mapOld.get(oSBQQ_Quote.Id).Related_Contract__c && mapContracts.containsKey(oSBQQ_Quote.Related_Contract__c)){//For Update
                    system.debug('oSBQQ_Quote.Related_Contract__c is changed');
                    getValuesFromContract(oSBQQ_Quote, mapContracts, oSBQQ_Quote.Related_Contract__c);
                }
            }
        }
        //In case of Migrated Contract, Fetch Contracts Fields
        
        if(setContractIdsWithoutOrder.size() > 0){
            //<T37 - Added the Quote__r fields to the query which was missing>
            mapContractWithoutOrder = new Map<Id, Contract>([SELECT Id,SBQQ__Order__c,SBQQ__Quote__c,Pricebook2Id,Legal_Entity__c,SBQQ__RenewalTerm__c,Shipping_Email__c,SoldToAccount__c,ShipToAccount__c,EndUserContact__c,EndUserAccount__c,EndUserAccount__r.Name,BilltoAccount__c/*<T20>*/,BilltoAccount__r.Name/*</T20>*/,BillToContact__c,ShipToContact__c,SoldToContact__c,BillingAddress_PSFTID__c,BillingName_PSFTID__c,ShippingAddress_PSFTID__c,ShippingName_PSFTID__c,EndUserAddress_PSFTID__c,
                                                             SoldAddress_PSFTID__c,EndUserCity__c,EndUserCountry__c,EndUserPostalCode__c,EndUserStateProvince__c,EndUserStreet__c,SoldCity__c,
                                                             SoldCountry__c,SoldPostalCode__c,SoldStateProvince__c,SoldStreet__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, ContractTerm, Business_Model__c,
                                                             SBQQ__Quote__r.Additional_Customer_Signature_Blocks__c, SBQQ__Quote__r.Compliance_Settlement__c, SBQQ__Quote__r.Custom_Support_SLAs__c, SBQQ__Quote__r.ELA_Terms__c, SBQQ__Quote__r.INFA_Signature_Blocks__c, SBQQ__Quote__r.IPS_Custom_Travel_Policy__c, 
                                                             SBQQ__Quote__r.IPS_Price_Holds__c, SBQQ__Quote__r.Legal_Entity__c, SBQQ__Quote__r.License_Price_Protection__c, SBQQ__Quote__r.Max_License_Uplift_Term__c, SBQQ__Quote__r.Max_License_Uplift__c, SBQQ__Quote__r.Max_Subscription_Uplift_Term__c, 
                                                             SBQQ__Quote__r.Max_Subscription_Uplift__c,SBQQ__Quote__r.Max_Support_Uplift_Term__c, SBQQ__Quote__r.Max_Support_Uplift__c, 
                                                             SBQQ__Quote__r.Non_Standard_Acceptance_Clause__c, SBQQ__Quote__r.PDS_Text__c, SBQQ__Quote__r.Partner_Name_for_Signature_Block__c, SBQQ__Quote__r.Price_Holds__c, SBQQ__Quote__r.Product_Restrictions__c, SBQQ__Quote__r.Recovery_License__c, 
                                                             SBQQ__Quote__r.Regular_Total_of_Lines__c, SBQQ__Quote__r.Remote_Access__c, SBQQ__Quote__r.Reseller_Customer_Support_Fee__c, SBQQ__Quote__r.Reseller_Support_Level__c, SBQQ__Quote__r.Reseller_Support_Percent_of_Total__c, SBQQ__Quote__r.Security_Exhibits__c, 
                                                             SBQQ__Quote__r.Special_Remarks_Conditional_Print__c, SBQQ__Quote__r.Subscription_Price_Remix__c, SBQQ__Quote__r.Suppress_Included_Features__c, 
                                                             SBQQ__Quote__r.Use_Restriction_Description__c, SBQQ__Quote__r.Shipping_Email__c, SBQQ__Quote__r.Shipping_Preference__c, SBQQ__Quote__r.Override_Support_Level__c, SBQQ__Quote__r.Price_Book_2__c, SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__Quote__r.SBQQ__PricebookId__c,
                                                             SBQQ__Quote__r.Uplift_Applied__c,Uplift_Notes__c, // T40
                                                             SBQQ__Quote__r.Coversheet_Checklist_Type__c,  SBQQ__Quote__r.PO__c, SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.SBQQ__BillingFrequency__c, SBQQ__Quote__r.Contracted_Uplift__c, SBQQ__Quote__r.Sub_Type__c, SBQQ__Quote__r.Business_Model__c,Renewal_Quote_Owner__c
                                                             FROM Contract 
                                                             WHERE Id IN : setContractIdsWithoutOrder]);
            //<T37>                                  
            for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
                if(oSBQQ_Quote.Related_Contract__c == null && oSBQQ_Quote.SBQQ__Opportunity2__c != null && mapOpportunity.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c)){
                    system.debug('oSBQQ_Quote.Related_Contract__c is null');
                    if(mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null){
                        //Populate the Quote's Related Contract with the Quote's related Opportunity Renewed Contract
                        oSBQQ_Quote.Related_Contract__c = mapOpportunity.get(oSBQQ_Quote.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c;
                        if(mapContractWithoutOrder.containsKey(oSBQQ_Quote.Related_Contract__c)){
                            getValuesFromContract(oSBQQ_Quote, mapContractWithoutOrder, oSBQQ_Quote.Related_Contract__c);
                        }
                    }
                }else if(oSBQQ_Quote.Related_Contract__c != null && oSBQQ_Quote.Related_Contract__c != mapOld.get(oSBQQ_Quote.Id).Related_Contract__c && mapContracts.containsKey(oSBQQ_Quote.Related_Contract__c)){//For Update
                    system.debug('oSBQQ_Quote.Related_Contract__c is changed');
                    getValuesFromContract(oSBQQ_Quote, mapContractWithoutOrder, oSBQQ_Quote.Related_Contract__c);
                }
            }
        }
        
        //<T17> END
    }
    
    /*
Method Name : setAmendQuoteValuesFromContract
* @param List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> mapOld
* @return return-void
* @throws exception - NA
*/
    /*<T09>Map Master Contract's parent Quote and Order Values to Renewal Quote on Create and Update.
This Method is called from 'Before Update' Event on SBQQ__Quote__c Object </T09>*/
    
    private static void setAmendQuoteValuesFromContract(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> mapOld){
        //system.debug('setAmendQuoteValues:'+from_where);
        system.debug('IS_INSERT:'+IS_INSERT);
        //<T17> Start
        //CODE ADDED FOR CM-6
        //Map<Id, SBQQ__Quote__c> quotesToUpdateMap = new Map<Id, SBQQ__Quote__c>();
        Set<Id> setContractIds = new Set<Id>();
        //Set<Id> setContractIdsWithOrder = new Set<Id>();
        //Set<Id> setContractIdsWithoutOrder = new Set<Id>();
        Map<Id, Contract> mapContracts = new Map<Id, Contract>();
        //Map<Id, Contract> mapContractWithoutOrder = new Map<Id, Contract>();
        
        
        //START: Code Added to fix Amend Address fields issue for new and Migrated contracts<T27>
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){ 
            if(oSBQQ_Quote.SBQQ__MasterContract__c != null && (IS_INSERT == true || oSBQQ_Quote.SBQQ__MasterContract__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__MasterContract__c) ){
                setContractIds.add(oSBQQ_Quote.SBQQ__MasterContract__c);
            }
        }
        system.debug('setContractIds:'+setContractIds);
        if(setContractIds.size() > 0){
            mapContracts = new Map<Id, Contract>([SELECT Id, SBQQ__Quote__r.Id, SBQQ__Quote__r.Additional_Customer_Signature_Blocks__c, SBQQ__Quote__r.Compliance_Settlement__c, SBQQ__Quote__r.Custom_Support_SLAs__c, SBQQ__Quote__r.ELA_Terms__c, SBQQ__Quote__r.INFA_Signature_Blocks__c, SBQQ__Quote__r.IPS_Custom_Travel_Policy__c, SBQQ__Quote__r.IPS_Price_Holds__c, SBQQ__Quote__r.Legal_Entity__c, SBQQ__Quote__r.License_Price_Protection__c, SBQQ__Quote__r.Max_License_Uplift_Term__c, SBQQ__Quote__r.Max_License_Uplift__c, SBQQ__Quote__r.Max_Subscription_Uplift_Term__c, SBQQ__Quote__r.Max_Subscription_Uplift__c, SBQQ__Quote__r.Max_Support_Uplift_Term__c, SBQQ__Quote__r.Max_Support_Uplift__c, 
                                                  SBQQ__Quote__r.Non_Standard_Acceptance_Clause__c, SBQQ__Quote__r.PDS_Text__c, SBQQ__Quote__r.Partner_Name_for_Signature_Block__c, SBQQ__Quote__r.Price_Holds__c, SBQQ__Quote__r.Product_Restrictions__c, SBQQ__Quote__r.Recovery_License__c, SBQQ__Quote__r.Regular_Total_of_Lines__c, SBQQ__Quote__r.Remote_Access__c, SBQQ__Quote__r.Reseller_Customer_Support_Fee__c, SBQQ__Quote__r.Reseller_Support_Level__c, SBQQ__Quote__r.Reseller_Support_Percent_of_Total__c, SBQQ__Quote__r.Security_Exhibits__c, SBQQ__Quote__r.Special_Remarks_Conditional_Print__c, SBQQ__Quote__r.Subscription_Price_Remix__c, SBQQ__Quote__r.Suppress_Included_Features__c, 
                                                  SBQQ__Quote__r.Use_Restriction_Description__c, SBQQ__Quote__r.Shipping_Email__c, SBQQ__Quote__r.Shipping_Preference__c, SBQQ__Quote__r.Override_Support_Level__c, SBQQ__Order__c, SBQQ__Order__r.BillingAddress_PSFTID__c, SBQQ__Order__r.BillingName_PSFTID__c, SBQQ__Order__r.EndUserAddress_PSFTID__c, SBQQ__Order__r.EndUserCity__c, SBQQ__Order__r.EndUserCountry__c, SBQQ__Order__r.EndUserPostalCode__c, SBQQ__Order__r.EndUserStateProvince__c, SBQQ__Order__r.EndUserStreet__c, SBQQ__Order__r.BillingCity, SBQQ__Order__r.BillingCountry, SBQQ__Order__r.BillingState, SBQQ__Order__r.BillingStreet, SBQQ__Order__r.BillingPostalCode, SBQQ__Order__r.ShippingCity, 
                                                  SBQQ__Order__r.ShippingCountry, SBQQ__Order__r.ShippingState, SBQQ__Order__r.ShippingStreet, SBQQ__Order__r.ShippingPostalCode, SBQQ__Order__r.ShippingAddress_PSFTID__c, SBQQ__Order__r.ShippingName_PSFTID__c, SBQQ__Order__r.Shipping_Email__c, SBQQ__Order__r.Shipping_Preference__c, SBQQ__Order__r.SoldAddress_PSFTID__c, SBQQ__Order__r.SoldCity__c, SBQQ__Order__r.SoldCountry__c, SBQQ__Order__r.SoldPostalCode__c, SBQQ__Order__r.SoldStateProvince__c, SBQQ__Order__r.SoldStreet__c, SBQQ__Order__r.BilltoAccount__c,SBQQ__Order__r.BilltoAccount__r.Name, SBQQ__Order__r.EndUserAccount__c, SBQQ__Order__r.EndUserAccount__r.Name, SBQQ__Order__r.ShipToAccount__c, SBQQ__Order__r.SoldToAccount__c, SBQQ__Order__r.BillToContactId, 
                                                  SBQQ__Order__r.EndUserContact__c, SBQQ__Order__r.ShipToContactId, SBQQ__Order__r.SoldToContact__c, SBQQ__Quote__r.Price_Book_2__c, SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__Quote__r.SBQQ__PricebookId__c, SBQQ__Quote__r.Coversheet_Checklist_Type__c,  SBQQ__Quote__c,Pricebook2Id,Legal_Entity__c,SBQQ__RenewalTerm__c,Shipping_Email__c,SoldToAccount__c,ShipToAccount__c,EndUserContact__c,EndUserAccount__c,BilltoAccount__c,BillToContact__c,ShipToContact__c,SoldToContact__c,BillingAddress_PSFTID__c,BillingName_PSFTID__c,ShippingAddress_PSFTID__c,ShippingName_PSFTID__c,EndUserAddress_PSFTID__c,
                                                  SBQQ__Quote__r.Uplift_Applied__c,Uplift_Notes__c, // T40
                                                  SoldAddress_PSFTID__c,EndUserCity__c,EndUserCountry__c,EndUserPostalCode__c,EndUserStateProvince__c,EndUserStreet__c,SoldCity__c, SoldCountry__c,SoldPostalCode__c,SoldStateProvince__c,SoldStreet__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, SBQQ__Quote__r.PO__c, SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.SBQQ__BillingFrequency__c, ContractTerm, EndUserAccount__r.Name, BillToAccount__r.Name, SBQQ__Quote__r.Contracted_Uplift__c, Business_Model__c, SBQQ__Order__r.Sub_Type__c, SBQQ__Quote__r.Sub_Type__c,SBQQ__Order__r.Business_Model__c, SBQQ__Quote__r.Business_Model__c,
                                                  SBQQ__Order__r.SBQQ__PaymentTerm__c, SBQQ__Order__r.Id,Renewal_Quote_Owner__c                                 
                                                  FROM Contract WHERE Id IN : setContractIds]);
            
            
            for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
                if(oSBQQ_Quote.SBQQ__MasterContract__c != null && (IS_INSERT == true || oSBQQ_Quote.SBQQ__MasterContract__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__MasterContract__c)){
                    if(mapContracts.containsKey(oSBQQ_Quote.SBQQ__MasterContract__c)){
                        getValuesFromContract(oSBQQ_Quote, mapContracts, oSBQQ_Quote.SBQQ__MasterContract__c);
                    }
                }
            }
        }
        //END</T27>
        
        
        /* Commenting below block of code to fix Amend Address fields issue for new and Migrated contracts<T27>
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){ 
        if(oSBQQ_Quote.SBQQ__MasterContract__c != null && (IS_INSERT == true || oSBQQ_Quote.SBQQ__MasterContract__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__MasterContract__c) ){
        if(oSBQQ_Quote.SBQQ__MasterContract__r.SBQQ__Order__c != null){
        setContractIdsWithOrder.add(oSBQQ_Quote.SBQQ__MasterContract__r.Id);
        }
        else{
        setContractIdsWithoutOrder.add(oSBQQ_Quote.SBQQ__MasterContract__r.Id);
        }
        }
        }
        //system.debug('setContractIds:'+setContractIds);
        //CODE ADDED FOR CM-6 - Updating the Map
        //Fetch Contract's Parent Order Fields and Parent Quote Fields
        if(setContractIdsWithOrder.size() > 0){
        mapContracts = new Map<Id, Contract>([SELECT Id, SBQQ__Quote__r.Id, SBQQ__Quote__r.Additional_Customer_Signature_Blocks__c, SBQQ__Quote__r.Compliance_Settlement__c, SBQQ__Quote__r.Custom_Support_SLAs__c, SBQQ__Quote__r.ELA_Terms__c, SBQQ__Quote__r.INFA_Signature_Blocks__c, SBQQ__Quote__r.IPS_Custom_Travel_Policy__c, SBQQ__Quote__r.IPS_Price_Holds__c, SBQQ__Quote__r.Legal_Entity__c, SBQQ__Quote__r.License_Price_Protection__c, SBQQ__Quote__r.Max_License_Uplift_Term__c, SBQQ__Quote__r.Max_License_Uplift__c, SBQQ__Quote__r.Max_Subscription_Uplift_Term__c, SBQQ__Quote__r.Max_Subscription_Uplift__c, SBQQ__Quote__r.Max_Support_Uplift_Term__c, SBQQ__Quote__r.Max_Support_Uplift__c, 
        SBQQ__Quote__r.Non_Standard_Acceptance_Clause__c, SBQQ__Quote__r.PDS_Text__c, SBQQ__Quote__r.Partner_Name_for_Signature_Block__c, SBQQ__Quote__r.Price_Holds__c, SBQQ__Quote__r.Product_Restrictions__c, SBQQ__Quote__r.Recovery_License__c, SBQQ__Quote__r.Regular_Total_of_Lines__c, SBQQ__Quote__r.Remote_Access__c, SBQQ__Quote__r.Reseller_Customer_Support_Fee__c, SBQQ__Quote__r.Reseller_Support_Level__c, SBQQ__Quote__r.Reseller_Support_Percent_of_Total__c, SBQQ__Quote__r.Security_Exhibits__c, SBQQ__Quote__r.Special_Remarks_Conditional_Print__c, SBQQ__Quote__r.Subscription_Price_Remix__c, SBQQ__Quote__r.Suppress_Included_Features__c, 
        SBQQ__Quote__r.Use_Restriction_Description__c, SBQQ__Quote__r.Shipping_Email__c, SBQQ__Quote__r.Shipping_Preference__c, SBQQ__Quote__r.Override_Support_Level__c, SBQQ__Order__c, SBQQ__Order__r.BillingAddress_PSFTID__c, SBQQ__Order__r.BillingName_PSFTID__c, SBQQ__Order__r.EndUserAddress_PSFTID__c, SBQQ__Order__r.EndUserCity__c, SBQQ__Order__r.EndUserCountry__c, SBQQ__Order__r.EndUserPostalCode__c, SBQQ__Order__r.EndUserStateProvince__c, SBQQ__Order__r.EndUserStreet__c, SBQQ__Order__r.BillingCity, SBQQ__Order__r.BillingCountry, SBQQ__Order__r.BillingState, SBQQ__Order__r.BillingStreet, SBQQ__Order__r.BillingPostalCode, SBQQ__Order__r.ShippingCity, 
        SBQQ__Order__r.ShippingCountry, SBQQ__Order__r.ShippingState, SBQQ__Order__r.ShippingStreet, SBQQ__Order__r.ShippingPostalCode, SBQQ__Order__r.ShippingAddress_PSFTID__c, SBQQ__Order__r.ShippingName_PSFTID__c, SBQQ__Order__r.Shipping_Email__c, SBQQ__Order__r.Shipping_Preference__c, SBQQ__Order__r.SoldAddress_PSFTID__c, SBQQ__Order__r.SoldCity__c, SBQQ__Order__r.SoldCountry__c, SBQQ__Order__r.SoldPostalCode__c, SBQQ__Order__r.SoldStateProvince__c, SBQQ__Order__r.SoldStreet__c, SBQQ__Order__r.BilltoAccount__c,SBQQ__Order__r.BilltoAccount__r.Name, SBQQ__Order__r.EndUserAccount__c, SBQQ__Order__r.EndUserAccount__r.Name,SBQQ__Order__r.ShipToAccount__c, SBQQ__Order__r.SoldToAccount__c, SBQQ__Order__r.BillToContactId, 
        SBQQ__Order__r.EndUserContact__c, SBQQ__Order__r.ShipToContactId, SBQQ__Order__r.SoldToContact__c, SBQQ__Quote__r.Price_Book_2__c, SBQQ__Quote__r.SBQQ__PriceBook__c, SBQQ__Quote__r.SBQQ__PricebookId__c, SBQQ__Quote__r.Coversheet_Checklist_Type__c, SBQQ__Quote__r.Contracted_Uplift__c                                                
        FROM Contract 
        WHERE Id IN : setContractIdsWithOrder]);
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
        if(oSBQQ_Quote.SBQQ__MasterContract__c != null && (IS_INSERT == true || oSBQQ_Quote.SBQQ__MasterContract__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__MasterContract__c)){
        if(mapContracts.containsKey(oSBQQ_Quote.SBQQ__MasterContract__c)){
        getValuesFromContract(oSBQQ_Quote, mapContracts, oSBQQ_Quote.SBQQ__MasterContract__c);
        //quotesToUpdateMap.put(oSBQQ_Quote.Id, oSBQQ_Quote);
        }
        }
        }
        }
        //In case of Migrated Contract, Fetch Contract Fields
        if(setContractIdsWithoutOrder.size() > 0){
        mapContractWithoutOrder = new Map<Id, Contract>([SELECT Id,SBQQ__Order__c,SBQQ__Quote__c,Pricebook2Id,Legal_Entity__c,SBQQ__RenewalTerm__c,Shipping_Email__c,SoldToAccount__c,ShipToAccount__c,EndUserContact__c,EndUserAccount__c,BilltoAccount__c,BillToContact__c,ShipToContact__c,SoldToContact__c,BillingAddress_PSFTID__c,BillingName_PSFTID__c,ShippingAddress_PSFTID__c,ShippingName_PSFTID__c,EndUserAddress_PSFTID__c,
        SoldAddress_PSFTID__c,EndUserCity__c,EndUserCountry__c,EndUserPostalCode__c,EndUserStateProvince__c,EndUserStreet__c,SoldCity__c,
        SoldCountry__c,SoldPostalCode__c,SoldStateProvince__c,SoldStreet__c,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet
        FROM Contract 
        WHERE Id IN : setContractIdsWithoutOrder]);
        for(SBQQ__Quote__c oSBQQ_Quote : lstQuote){
        if(oSBQQ_Quote.SBQQ__MasterContract__c != null && (IS_INSERT == true || oSBQQ_Quote.SBQQ__MasterContract__c != mapOld.get(oSBQQ_Quote.Id).SBQQ__MasterContract__c)){
        if(mapContracts.containsKey(oSBQQ_Quote.SBQQ__MasterContract__c)){
        getValuesFromContract(oSBQQ_Quote, mapContractWithoutOrder, oSBQQ_Quote.SBQQ__MasterContract__c);
        //quotesToUpdateMap.put(oSBQQ_Quote.Id, oSBQQ_Quote);
        }
        }
        }
        } END</T27>*/
        //<T17> END
        
        IS_INSERT = false;
    }
    
    
    
    /*
Method Name : getValuesFromContract
* @param SBQQ__Quote__c sbqq_quote, Map<Id, Contract> mapContracts, Id parentContract
* @return return-void
* @throws exception - NA
*/
    public static void getValuesFromContract(SBQQ__Quote__c sbqq_quote, Map<Id, Contract> mapContracts, Id parentContract){        
        
        //set Quote to Quote
        
        if(mapContracts.get(parentContract).SBQQ__Order__c != null){
            sbqq_quote.BillToAccount__c = mapContracts.get(parentContract).SBQQ__Order__r.BillToAccount__c;
            sbqq_quote.ShiptToAccount__c = mapContracts.get(parentContract).SBQQ__Order__r.ShipToAccount__c;
            sbqq_quote.EndUserAccount__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserAccount__c;
            sbqq_quote.SoldToAccount__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldToAccount__c;
            sbqq_quote.BillToContact__c = mapContracts.get(parentContract).SBQQ__Order__r.BillToContactId;
            sbqq_quote.EndUserContact__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserContact__c;
            sbqq_quote.SoldToContact__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldToContact__c;
            sbqq_quote.SoldToContact__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldToContact__c;
            sbqq_quote.ShipToContact__c = mapContracts.get(parentContract).SBQQ__Order__r.ShipToContactId;
            sbqq_quote.BillingAddress_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingAddress_PSFTID__c;
            sbqq_quote.BillingName_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingName_PSFTID__c;
            sbqq_quote.ShippingAddress_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingAddress_PSFTID__c;
            sbqq_quote.ShippingName_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingName_PSFTID__c;
            sbqq_quote.EndUserAddress_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserAddress_PSFTID__c;
            sbqq_quote.SoldAddress_PSFTID__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldAddress_PSFTID__c;
            sbqq_quote.EndUserCity__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserCity__c;
            sbqq_quote.EndUserCountry__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserCountry__c;
            sbqq_quote.EndUserPostalCode__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserPostalCode__c;
            sbqq_quote.EndUserStateProvince__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserStateProvince__c;
            sbqq_quote.EndUserStreet__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserStreet__c;
            sbqq_quote.SoldCity__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldCity__c;
            sbqq_quote.SoldCountry__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldCountry__c;
            sbqq_quote.SoldPostalCode__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldPostalCode__c;
            sbqq_quote.SoldStateProvince__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldStateProvince__c;
            sbqq_quote.SoldStreet__c = mapContracts.get(parentContract).SBQQ__Order__r.SoldStreet__c;
            sbqq_quote.SBQQ__BillingCity__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingCity;
            sbqq_quote.SBQQ__BillingCountry__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingCountry;
            sbqq_quote.SBQQ__BillingPostalCode__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingPostalCode;
            sbqq_quote.SBQQ__BillingState__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingState;
            sbqq_quote.SBQQ__BillingStreet__c = mapContracts.get(parentContract).SBQQ__Order__r.BillingStreet;
            sbqq_quote.SBQQ__ShippingCity__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingCity;
            sbqq_quote.SBQQ__ShippingCountry__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingCountry;
            sbqq_quote.SBQQ__ShippingPostalCode__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingPostalCode;
            sbqq_quote.SBQQ__ShippingState__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingState;
            sbqq_quote.SBQQ__ShippingStreet__c = mapContracts.get(parentContract).SBQQ__Order__r.ShippingStreet;
            sbqq_quote.Business_Model__c = mapContracts.get(parentContract).SBQQ__Order__r.Business_Model__c;    //</T35>
            If(mapContracts.get(parentContract).SBQQ__Order__r.Sub_Type__c == 'Full Debook' && sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Amendment) {
                sbqq_quote.Sub_Type__c = mapContracts.get(parentContract).SBQQ__Order__r.Sub_Type__c;
            }//</T35>
             if(mapContracts.get(parentContract).SBQQ__Order__r.BillToAccount__c != null && sbqq_quote.Bill_to_Account_Text__c == null) //<T42>
                sbqq_quote.Bill_to_Account_Text__c = mapContracts.get(parentContract).SBQQ__Order__r.BillToAccount__r.Name; 
             if(mapContracts.get(parentContract).SBQQ__Order__r.EndUserAccount__c != null && sbqq_quote.End_User_Account_Text__c == null)
                sbqq_quote.End_User_Account_Text__c = mapContracts.get(parentContract).SBQQ__Order__r.EndUserAccount__r.Name; //</T42>
                //<SALESRT-12220>
             if(mapContracts.get(parentContract).Renewal_Quote_Owner__c != Null && sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Renewal)
              sbqq_quote.OwnerId = mapContracts.get(parentContract).Renewal_Quote_Owner__c;
            //</SALESRT-12220>
                
            
            
        }
        
        //<T17> Start : If there is no Order on Contract, Populate Quote Fields from Contract Fields 
        else{
            sbqq_quote.BillToAccount__c = mapContracts.get(parentContract).BillToAccount__c;
            sbqq_quote.ShiptToAccount__c = mapContracts.get(parentContract).ShipToAccount__c;
            sbqq_quote.EndUserAccount__c = mapContracts.get(parentContract).EndUserAccount__c;
            sbqq_quote.SoldToAccount__c = mapContracts.get(parentContract).SoldToAccount__c;
            sbqq_quote.BillToContact__c = mapContracts.get(parentContract).BillToContact__c;
            sbqq_quote.EndUserContact__c = mapContracts.get(parentContract).EndUserContact__c;
            sbqq_quote.SoldToContact__c = mapContracts.get(parentContract).SoldToContact__c;
            sbqq_quote.ShipToContact__c = mapContracts.get(parentContract).ShipToContact__c;
            sbqq_quote.BillingAddress_PSFTID__c = mapContracts.get(parentContract).BillingAddress_PSFTID__c;
            sbqq_quote.BillingName_PSFTID__c = mapContracts.get(parentContract).BillingName_PSFTID__c;
            sbqq_quote.ShippingAddress_PSFTID__c = mapContracts.get(parentContract).ShippingAddress_PSFTID__c;
            sbqq_quote.ShippingName_PSFTID__c = mapContracts.get(parentContract).ShippingName_PSFTID__c;
            sbqq_quote.EndUserAddress_PSFTID__c = mapContracts.get(parentContract).EndUserAddress_PSFTID__c;
            sbqq_quote.SoldAddress_PSFTID__c = mapContracts.get(parentContract).SoldAddress_PSFTID__c;
            sbqq_quote.EndUserCity__c = mapContracts.get(parentContract).EndUserCity__c;
            sbqq_quote.EndUserCountry__c = mapContracts.get(parentContract).EndUserCountry__c;
            sbqq_quote.EndUserPostalCode__c = mapContracts.get(parentContract).EndUserPostalCode__c;
            sbqq_quote.EndUserStateProvince__c = mapContracts.get(parentContract).EndUserStateProvince__c;
            sbqq_quote.EndUserStreet__c = mapContracts.get(parentContract).EndUserStreet__c;
            sbqq_quote.SoldCity__c = mapContracts.get(parentContract).SoldCity__c;
            sbqq_quote.SoldCountry__c = mapContracts.get(parentContract).SoldCountry__c;
            sbqq_quote.SoldPostalCode__c = mapContracts.get(parentContract).SoldPostalCode__c;
            sbqq_quote.SoldStateProvince__c = mapContracts.get(parentContract).SoldStateProvince__c;
            sbqq_quote.SoldStreet__c = mapContracts.get(parentContract).SoldStreet__c;
            sbqq_quote.SBQQ__BillingCity__c = mapContracts.get(parentContract).BillingCity;
            sbqq_quote.SBQQ__BillingCountry__c = mapContracts.get(parentContract).BillingCountry;
            sbqq_quote.SBQQ__BillingPostalCode__c = mapContracts.get(parentContract).BillingPostalCode;
            sbqq_quote.SBQQ__BillingState__c = mapContracts.get(parentContract).BillingState;
            sbqq_quote.SBQQ__BillingStreet__c = mapContracts.get(parentContract).BillingStreet;
            sbqq_quote.SBQQ__ShippingCity__c = mapContracts.get(parentContract).ShippingCity;
            sbqq_quote.SBQQ__ShippingCountry__c = mapContracts.get(parentContract).ShippingCountry;
            sbqq_quote.SBQQ__ShippingPostalCode__c = mapContracts.get(parentContract).ShippingPostalCode;
            sbqq_quote.SBQQ__ShippingState__c = mapContracts.get(parentContract).ShippingState;
            sbqq_quote.SBQQ__ShippingStreet__c = mapContracts.get(parentContract).ShippingStreet;
            sbqq_quote.Shipping_Email__c = mapContracts.get(parentContract).Shipping_Email__c;
            //sbqq_quote.SBQQ__SubscriptionTerm__c = mapContracts.get(parentContract).SBQQ__RenewalTerm__c;
            sbqq_quote.Legal_Entity__c = mapContracts.get(parentContract).Legal_Entity__c;
            //sbqq_quote.Price_Book_2__c = mapContracts.get(parentContract).Pricebook2Id;                //</T31> Commented all pricebook id fields to be carry forwarded from previous Quotes/Contract
            //sbqq_quote.SBQQ__PriceBook__c = mapContracts.get(parentContract).Pricebook2Id;
            //sbqq_quote.SBQQ__PricebookId__c = mapContracts.get(parentContract).Pricebook2Id;
            sbqq_quote.Business_Model__c = mapContracts.get(parentContract).Business_Model__c;    //</T35>
            if(mapContracts.get(parentContract).BillToAccount__c != null)
                sbqq_quote.Bill_to_Account_Text__c = mapContracts.get(parentContract).BillToAccount__r.Name; //<T20>
            else
                sbqq_quote.Bill_to_Account_Text__c = null;//<T20>
            if(mapContracts.get(parentContract).EndUserAccount__c != null && sbqq_quote.End_User_Account_Text__c == null) //<T42>
                sbqq_quote.End_User_Account_Text__c = mapContracts.get(parentContract).EndUserAccount__r.Name; //</T42>
             
            
            //<T27> 
            if(sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Amendment){
                sbqq_quote.SBQQ__SubscriptionTerm__c = mapContracts.get(parentContract).ContractTerm;
            }
            //</T27>
            //<T28>
            System.debug('Updating Billing Frequency. <T28>');
            sbqq_quote.SBQQ__BillingFrequency__c = 'Annual'; 
            if(sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Renewal)
                sbqq_quote.Show_Dates__c = true;
            //</T28>
            //<SALESRT-12220>
             if(mapContracts.get(parentContract).Renewal_Quote_Owner__c != Null && sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Renewal)
              sbqq_quote.OwnerId = mapContracts.get(parentContract).Renewal_Quote_Owner__c;
            //</SALESRT-12220>
        }
        //<T17> - END
        
        //set Order to Quote
        if(mapContracts.get(parentContract).SBQQ__Quote__c != null){
            //sbqq_quote.Additional_Customer_Signature_Blocks__c = mapContracts.get(parentContract).SBQQ__Quote__r.Additional_Customer_Signature_Blocks__c; <T47>
            //sbqq_quote.Compliance_Settlement__c = mapContracts.get(parentContract).SBQQ__Quote__r.Compliance_Settlement__c;  <T46>
            sbqq_quote.Custom_Support_SLAs__c = mapContracts.get(parentContract).SBQQ__Quote__r.Custom_Support_SLAs__c;
            sbqq_quote.ELA_Terms__c = mapContracts.get(parentContract).SBQQ__Quote__r.ELA_Terms__c;
            //sbqq_quote.INFA_Signature_Blocks__c = mapContracts.get(parentContract).SBQQ__Quote__r.INFA_Signature_Blocks__c; <T47>
            sbqq_quote.IPS_Custom_Travel_Policy__c = mapContracts.get(parentContract).SBQQ__Quote__r.IPS_Custom_Travel_Policy__c;
            sbqq_quote.IPS_Price_Holds__c = mapContracts.get(parentContract).SBQQ__Quote__r.IPS_Price_Holds__c;
            sbqq_quote.Legal_Entity__c = mapContracts.get(parentContract).SBQQ__Quote__r.Legal_Entity__c;
            sbqq_quote.License_Price_Protection__c = mapContracts.get(parentContract).SBQQ__Quote__r.License_Price_Protection__c;
            sbqq_quote.Max_License_Uplift__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_License_Uplift__c;
            sbqq_quote.Max_License_Uplift_Term__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_License_Uplift_Term__c;
            sbqq_quote.Max_Subscription_Uplift__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_Subscription_Uplift__c;
            sbqq_quote.Max_Subscription_Uplift_Term__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_Subscription_Uplift_Term__c;
            sbqq_quote.Max_Support_Uplift__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_Support_Uplift__c;
            sbqq_quote.Max_Support_Uplift_Term__c = mapContracts.get(parentContract).SBQQ__Quote__r.Max_Support_Uplift_Term__c;
            sbqq_quote.Non_Standard_Acceptance_Clause__c = mapContracts.get(parentContract).SBQQ__Quote__r.Non_Standard_Acceptance_Clause__c;
            //SALESRT-13885
            //sbqq_quote.Override_Support_Level__c = mapContracts.get(parentContract).SBQQ__Quote__r.Override_Support_Level__c;
            sbqq_quote.PDS_Text__c = mapContracts.get(parentContract).SBQQ__Quote__r.PDS_Text__c;
            sbqq_quote.Partner_Name_for_Signature_Block__c = mapContracts.get(parentContract).SBQQ__Quote__r.Partner_Name_for_Signature_Block__c;
            sbqq_quote.Price_Holds__c = mapContracts.get(parentContract).SBQQ__Quote__r.Price_Holds__c;
            sbqq_quote.Product_Restrictions__c = mapContracts.get(parentContract).SBQQ__Quote__r.Product_Restrictions__c;
            sbqq_quote.Recovery_License__c = mapContracts.get(parentContract).SBQQ__Quote__r.Recovery_License__c;
            sbqq_quote.Regular_Total_of_Lines__c = mapContracts.get(parentContract).SBQQ__Quote__r.Regular_Total_of_Lines__c;
            sbqq_quote.Remote_Access__c = mapContracts.get(parentContract).SBQQ__Quote__r.Remote_Access__c;
            sbqq_quote.Reseller_Customer_Support_Fee__c = mapContracts.get(parentContract).SBQQ__Quote__r.Reseller_Customer_Support_Fee__c;
            sbqq_quote.Reseller_Support_Level__c = mapContracts.get(parentContract).SBQQ__Quote__r.Reseller_Support_Level__c;
            sbqq_quote.Reseller_Support_Percent_of_Total__c = mapContracts.get(parentContract).SBQQ__Quote__r.Reseller_Support_Percent_of_Total__c;
            sbqq_quote.Security_Exhibits__c = mapContracts.get(parentContract).SBQQ__Quote__r.Security_Exhibits__c;
            sbqq_quote.Shipping_Email__c = mapContracts.get(parentContract).SBQQ__Quote__r.Shipping_Email__c;
            sbqq_quote.Shipping_Preference__c = mapContracts.get(parentContract).SBQQ__Quote__r.Shipping_Preference__c;
            sbqq_quote.Special_Remarks_Conditional_Print__c = mapContracts.get(parentContract).SBQQ__Quote__r.Special_Remarks_Conditional_Print__c;
            sbqq_quote.Subscription_Price_Remix__c = mapContracts.get(parentContract).SBQQ__Quote__r.Subscription_Price_Remix__c;
            sbqq_quote.Use_Restriction_Description__c = mapContracts.get(parentContract).SBQQ__Quote__r.Use_Restriction_Description__c; 
            //sbqq_quote.Price_Book_2__c = mapContracts.get(parentContract).SBQQ__Quote__r.Price_Book_2__c;
            //sbqq_quote.SBQQ__PriceBook__c = mapContracts.get(parentContract).SBQQ__Quote__r.SBQQ__PriceBook__c;
            //sbqq_quote.SBQQ__PricebookId__c = mapContracts.get(parentContract).SBQQ__Quote__r.SBQQ__PricebookId__c;
            sbqq_quote.Coversheet_Checklist_Type__c = mapContracts.get(parentContract).SBQQ__Quote__r.Coversheet_Checklist_Type__c;//<T24/>
            sbqq_quote.Contracted_Uplift__c = mapContracts.get(parentContract).SBQQ__Quote__r.Contracted_Uplift__c;                  //</T29>
            sbqq_quote.Business_Model__c =  mapContracts.get(parentContract).SBQQ__Quote__r.Business_Model__c;    //</T35>
            
            //------------------------------------------------------------<T40>         
            if(mapContracts.get(parentContract).SBQQ__Quote__r.Uplift_Applied__c!=null)
                sbqq_quote.Uplift_Applied__c = mapContracts.get(parentContract).SBQQ__Quote__r.Uplift_Applied__c;
                
            if(mapContracts.get(parentContract).Uplift_Notes__c !=null)
                sbqq_quote.Uplift_Notes__c = mapContracts.get(parentContract).Uplift_Notes__c;
            //-----------------------------------------------------------</T40>
            
            
            
            //Start: <T27>        
            if(sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Amendment){
                sbqq_quote.PO__c = mapContracts.get(parentContract).SBQQ__Quote__r.PO__c;
                sbqq_quote.Apply_PO_to_All_Lines__c = true;
                sbqq_quote.SBQQ__SubscriptionTerm__c = mapContracts.get(parentContract).SBQQ__Quote__r.SBQQ__SubscriptionTerm__c;
                sbqq_quote.SBQQ__BillingFrequency__c = mapContracts.get(parentContract).SBQQ__Quote__r.SBQQ__BillingFrequency__c;
                If(mapContracts.get(parentContract).SBQQ__Order__r.Sub_Type__c == 'Full Debook') {
                    sbqq_quote.Sub_Type__c = mapContracts.get(parentContract).SBQQ__Order__r.Sub_Type__c;
                }//</T35>
                
                if(mapContracts.get(parentContract).SBQQ__Order__r.SBQQ__PaymentTerm__c == 'Other') //<T43>
                {
                    sbqq_quote.SBQQ__PaymentTerms__c = mapContracts.get(parentContract).SBQQ__Order__r.SBQQ__PaymentTerm__c;
                    createPaymentTerms(sbqq_quote.Id,mapContracts.get(parentContract).SBQQ__Order__r.Id);
                }
            }
            //End: </T27> 
            //<T28>
            if(sbqq_quote.SBQQ__Type__c == Label.Quote_Type_Renewal){
                System.debug('Setting the Billing Frequency.');
                sbqq_quote.SBQQ__BillingFrequency__c = 'Annual'; //Writing in Update branch as the Quote gets updates right after Insert
                sbqq_quote.Show_Dates__c = true;
            } 
            //</T28>            
        }        
    }
    
    private static Map<Id, Opportunity> queryOpportunity(Set<Id> setOpportunityIds){
        //<T46> Added PT_INFA_License_Compliance__c  to Query
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([select Id, Name, CloseDate, OwnerId, CurrencyIsoCode, 
                                                                        Territory2Id,Territory2.Sub_Region__c, //<T49>
                                                                        SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.SBQQ__Order__c,
                                                                        Admin__c,PT_INFA_License_Compliance__c  
                                                                        from Opportunity 
                                                                        where Id in : setOpportunityIds]); 
        return mapOpportunity;
    }
    
    private static void createPaymentTerms(Id quoteId,Id orderId) //<T43>
    {
        List<Payment_Term__c> insertPTList = new List<Payment_Term__c> ();
        for(Payment_Term__c PT : [SELECT CurrencyIsoCode,End_Date__c,Id,Name,Order__c,Payment_Term__c,Quote__c,Start_Date__c FROM Payment_Term__c where Order__c =: orderId])
        {
            Payment_Term__c PTNew = new Payment_Term__c ();
            PTNew.CurrencyIsoCode = PT.CurrencyIsoCode;
            PTNew.End_Date__c = PT.End_Date__c;
            PTNew.Start_Date__c = PT.Start_Date__c;
            PTNew.Quote__c = quoteId;
            PTNew.Payment_Term__c = PT.Payment_Term__c;
            insertPTList.add(PTNew);
        }
            try
            {
                if(insertPTList.size() > 0)
                {
                    globalApexManager.avoidRecursion('payTermTriggerBeforeInsert');
                    insert insertPTList;
                }
            }
            catch(exception e)
            {
                GAM.CreateExceptionRecords('QuoteTriggerHandler -->', e.getMessage(), '-->' + 'error from creating Custom Payment Terms for Amend Quote' + quoteId);
            }    
    } //</T43>
    
    
    //<T05>
    private static void manageQuoteAddress(Map<Id,SBQQ__Quote__c> mapNew, Map<Id,SBQQ__Quote__c> mapOld){
        
        Map<Id,Contact> MapofContactIdstoContact = new Map<Id,Contact>();
        Map<Id,SBQQ__Quote__c> MapofQuoteIdtoQuote = new Map<Id, SBQQ__Quote__c>();
        Set<Id> SetofContactIds = new Set<Id>();
        
        for(SBQQ__Quote__c quote : mapNew.values()){
            /*if(quote.BillToContact__c != mapOld.get(quote.Id).BillToContact__c){
                SetofContactIds.add(quote.BillToContact__c);
            }*/
            if(quote.ShipToContact__c != mapOld.get(quote.Id).ShipToContact__c){
                SetofContactIds.add(quote.ShipToContact__c);
            }
            if(quote.SoldToContact__c != mapOld.get(quote.Id).SoldToContact__c){
                SetofContactIds.add(quote.SoldToContact__c);
            }
            /*if(quote.EndUserContact__c != mapOld.get(quote.Id).EndUserContact__c){
                SetofContactIds.add(quote.EndUserContact__c);
            }*/
        }
        
        system.debug('SetofContactIds:'+SetofContactIds);
        //Constructing a map to store all the contact details from newly added contacts on Quotes
        for(Contact cont : [SELECT Id, /*<T14>*/FirstName, LastName,/*<T14>*/ Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, AccountId, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry FROM Contact WHERE Id IN :SetofContactIds]){
            MapofContactIdstoContact.put(cont.Id, cont);
        }
        
        //Constructing a map to store all the account details 
        /*for(SBQQ__Quote__c q : [SELECT Id, BillToAccount__r.BillingStreet, BillToAccount__r.BillingCity, BillToAccount__r.BillingState, BillToAccount__r.BillingPostalCode, BillToAccount__r.BillingCountry, 
        EndUserAccount__r.BillingStreet, EndUserAccount__r.BillingCity, EndUserAccount__r.BillingState, EndUserAccount__r.BillingPostalCode, EndUserAccount__r.BillingCountry,
        ShiptToAccount__r.BillingStreet, ShiptToAccount__r.BillingCity, ShiptToAccount__r.BillingState, ShiptToAccount__r.BillingPostalCode, ShiptToAccount__r.BillingCountry,
        SoldToAccount__r.BillingStreet, SoldToAccount__r.BillingCity, SoldToAccount__r.BillingState, SoldToAccount__r.BillingPostalCode, SoldToAccount__r.BillingCountry 
        FROM SBQQ__Quote__c WHERE Id IN :mapNew.keySet()]){
        MapofQuoteIdtoQuote.put(q.Id,q);
        }*/
        
        for(SBQQ__Quote__c quote : mapNew.values()){
            /*if(quote.BillToContact__c != mapOld.get(quote.Id).BillToContact__c && quote.BillToContact__c != null){
                if(MapofContactIdstoContact.get(quote.BillToContact__c).MailingStreet != null && 
                   MapofContactIdstoContact.get(quote.BillToContact__c).MailingCity != null && 
                   MapofContactIdstoContact.get(quote.BillToContact__c).MailingPostalCode != null && 
                   MapofContactIdstoContact.get(quote.BillToContact__c).MailingCountry != null){
                       quote.SBQQ__BillingStreet__c = MapofContactIdstoContact.get(quote.BillToContact__c).MailingStreet; 
                       quote.SBQQ__BillingCity__c = MapofContactIdstoContact.get(quote.BillToContact__c).MailingCity;
                       quote.SBQQ__BillingState__c = MapofContactIdstoContact.get(quote.BillToContact__c).MailingState;
                       quote.SBQQ__BillingPostalCode__c = MapofContactIdstoContact.get(quote.BillToContact__c).MailingPostalCode;
                       quote.SBQQ__BillingCountry__c = MapofContactIdstoContact.get(quote.BillToContact__c).MailingCountry;
                   }
                else if(MapofContactIdstoContact.get(quote.BillToContact__c) != null){
                    quote.SBQQ__BillingStreet__c = MapofContactIdstoContact.get(quote.BillToContact__c).Account.BillingStreet;
                    quote.SBQQ__BillingCity__c = MapofContactIdstoContact.get(quote.BillToContact__c).Account.BillingCity;
                    quote.SBQQ__BillingState__c = MapofContactIdstoContact.get(quote.BillToContact__c).Account.BillingState;
                    quote.SBQQ__BillingPostalCode__c = MapofContactIdstoContact.get(quote.BillToContact__c).Account.BillingPostalCode;
                    quote.SBQQ__BillingCountry__c = MapofContactIdstoContact.get(quote.BillToContact__c).Account.BillingCountry;
                }
            }*/
            if(quote.ShipToContact__c != mapOld.get(quote.Id).ShipToContact__c && quote.ShipToContact__c != null){
                /*if(MapofContactIdstoContact.get(quote.ShipToContact__c).MailingStreet != null && 
                   MapofContactIdstoContact.get(quote.ShipToContact__c).MailingCity != null && 
                   MapofContactIdstoContact.get(quote.ShipToContact__c).MailingPostalCode != null && 
                   MapofContactIdstoContact.get(quote.ShipToContact__c).MailingCountry != null){
                       quote.SBQQ__ShippingStreet__c = MapofContactIdstoContact.get(quote.ShipToContact__c).MailingStreet;
                       quote.SBQQ__ShippingCity__c = MapofContactIdstoContact.get(quote.ShipToContact__c).MailingCity;
                       quote.SBQQ__ShippingState__c = MapofContactIdstoContact.get(quote.ShipToContact__c).MailingState;
                       quote.SBQQ__ShippingPostalCode__c = MapofContactIdstoContact.get(quote.ShipToContact__c).MailingPostalCode;
                       quote.SBQQ__ShippingCountry__c = MapofContactIdstoContact.get(quote.ShipToContact__c).MailingCountry; 
                   }
                else if(MapofContactIdstoContact.get(quote.ShipToContact__c) != null){
                    quote.SBQQ__ShippingStreet__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Account.BillingStreet;
                    quote.SBQQ__ShippingCity__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Account.BillingCity;
                    quote.SBQQ__ShippingState__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Account.BillingState;
                    quote.SBQQ__ShippingPostalCode__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Account.BillingPostalCode;
                    quote.SBQQ__ShippingCountry__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Account.BillingCountry;
                }*/
                quote.Shipping_Email__c = MapofContactIdstoContact.get(quote.ShipToContact__c).Email;
            }
            if(quote.SoldToContact__c != mapOld.get(quote.Id).SoldToContact__c && quote.SoldToContact__c != null){
                /*if(MapofContactIdstoContact.get(quote.SoldToContact__c).MailingStreet != null && 
                   MapofContactIdstoContact.get(quote.SoldToContact__c).MailingCity != null && 
                   MapofContactIdstoContact.get(quote.SoldToContact__c).MailingPostalCode != null && 
                   MapofContactIdstoContact.get(quote.SoldToContact__c).MailingCountry != null){
                       quote.SoldStreet__c = MapofContactIdstoContact.get(quote.SoldToContact__c).MailingStreet;
                       quote.SoldCity__c = MapofContactIdstoContact.get(quote.SoldToContact__c).MailingCity;
                       quote.SoldStateProvince__c = MapofContactIdstoContact.get(quote.SoldToContact__c).MailingState;
                       quote.SoldPostalCode__c = MapofContactIdstoContact.get(quote.SoldToContact__c).MailingPostalCode;
                       quote.SoldCountry__c = MapofContactIdstoContact.get(quote.SoldToContact__c).MailingCountry;
                   }
                else if(MapofContactIdstoContact.get(quote.SoldToContact__c) != null){
                    quote.SoldStreet__c = MapofContactIdstoContact.get(quote.SoldToContact__c).Account.BillingStreet;
                    quote.SoldCity__c = MapofContactIdstoContact.get(quote.SoldToContact__c).Account.BillingCity;
                    quote.SoldStateProvince__c = MapofContactIdstoContact.get(quote.SoldToContact__c).Account.BillingState;
                    quote.SoldPostalCode__c = MapofContactIdstoContact.get(quote.SoldToContact__c).Account.BillingPostalCode;
                    quote.SoldCountry__c = MapofContactIdstoContact.get(quote.SoldToContact__c).Account.BillingCountry;
                }*/
                quote.Sold_To_Contact_Name__c = MapofContactIdstoContact.get(quote.SoldToContact__c).FirstName + ' ' + MapofContactIdstoContact.get(quote.SoldToContact__c).LastName; //<T14>
            }
            /*if(quote.EndUserContact__c != mapOld.get(quote.Id).EndUserContact__c && quote.EndUserContact__c != null){
                if(MapofContactIdstoContact.get(quote.EndUserContact__c).MailingStreet != null && 
                   MapofContactIdstoContact.get(quote.EndUserContact__c).MailingCity != null && 
                   MapofContactIdstoContact.get(quote.EndUserContact__c).MailingPostalCode != null && 
                   MapofContactIdstoContact.get(quote.EndUserContact__c).MailingCountry != null){
                       quote.EndUserStreet__c = MapofContactIdstoContact.get(quote.EndUserContact__c).MailingStreet; 
                       quote.EndUserCity__c = MapofContactIdstoContact.get(quote.EndUserContact__c).MailingCity;
                       quote.EndUserStateProvince__c = MapofContactIdstoContact.get(quote.EndUserContact__c).MailingState;
                       quote.EndUserPostalCode__c = MapofContactIdstoContact.get(quote.EndUserContact__c).MailingPostalCode;
                       quote.EndUserCountry__c = MapofContactIdstoContact.get(quote.EndUserContact__c).MailingCountry;
                   }
                else if(MapofContactIdstoContact.get(quote.EndUserContact__c) != null){
                    quote.EndUserStreet__c = MapofContactIdstoContact.get(quote.EndUserContact__c).Account.BillingStreet;
                    quote.EndUserCity__c = MapofContactIdstoContact.get(quote.EndUserContact__c).Account.BillingCity;
                    quote.EndUserStateProvince__c = MapofContactIdstoContact.get(quote.EndUserContact__c).Account.BillingState;
                    quote.EndUserPostalCode__c = MapofContactIdstoContact.get(quote.EndUserContact__c).Account.BillingPostalCode;
                    quote.EndUserCountry__c = MapofContactIdstoContact.get(quote.EndUserContact__c).Account.BillingCountry;
                }
            }*/
        }
    }
    //</T05><SALESRT-14833>  
    //---------------------------------------------------------------------------<T49>
    
    private static void PSASetValuesForAllQuotes(List<SBQQ__Quote__c> lstTriggerNew){
            Set<Id> setOpportunityIds = new Set<Id>();
            Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
            Map<Id,String> mapOptySubRegion= new Map<Id,String>();
            Map<String,Id> mapSubregionRD= new Map<String,Id>();
            Map<String,Id> mapSubregionVP= new Map<String,Id>();
            //Get list of opportunities
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
                if(oSBQQ_Quote.SBQQ__Opportunity2__c != null){
                    setOpportunityIds.add(oSBQQ_Quote.SBQQ__Opportunity2__c);   
                }
            }
            
           //Query values from Opportunity to be populated on Quote
            if(setOpportunityIds.size() > 0){
                mapOpportunity = queryOpportunity(setOpportunityIds);
            }
            //get list of subregions
            for(Opportunity Op: mapOpportunity.values()){
                if(Op.Territory2!= null && Op.Territory2.Sub_region__c!= null)
                    mapOptySubRegion.put(Op.Id, Op.Territory2.Sub_region__c);
            } 
            //Get Approvers based on subregion from custom metatdata
            for( PSA_Approval_Matrix__c approver : [Select Id, Sub_Region__c, SubRegion_RD__c, SubRegion_VP__c from PSA_Approval_Matrix__c where Sub_Region__c in :mapOptySubRegion.values()]){
                if(approver.Sub_Region__c != null && approver.SubRegion_RD__c!= null)
                    mapSubregionRD.put(approver.Sub_Region__c,approver.SubRegion_RD__c);
                if(approver.Sub_Region__c != null && approver.SubRegion_VP__c!= null)
                    mapSubregionVP.put(approver.Sub_Region__c,approver.SubRegion_VP__c);
            }
            
            //Update Quote fields with approvers
            for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
                if(oSBQQ_Quote.SBQQ__Opportunity2__c!=null && mapOptySubRegion.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && mapSubregionRD.containskey(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c))){
                    oSBQQ_Quote.PSA_SubRegion_RD__c = mapSubregionRD.get(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c));
                }
                if(oSBQQ_Quote.SBQQ__Opportunity2__c!=null && mapOptySubRegion.containsKey(oSBQQ_Quote.SBQQ__Opportunity2__c) && mapSubregionVP.containskey(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c))){
                    oSBQQ_Quote.PSA_SubRegion_VP__c= mapSubregionVP.get(mapOptySubRegion.get(oSBQQ_Quote.SBQQ__Opportunity2__c));
                }
            }
 
    }
    //------------------------------------------------------------------------------</T49>
    /*<TAX-249>  
    Method Name : updateTaxApplicable,  
    * @param lstTriggerNew - list of new SBQQ__Quote__c  
    * @return return-void  
    This method call from 'QuoteBeforeInsert','QuoteBeforeUpdate' Trigger on SBQQ__Quote__c Object  
    Will auto populate the Tax Applicable field values based on Tax configuration  
    */     
    public static void updateTaxApplicable(List<SBQQ__Quote__c> lstTriggerNew){  
            
        //Geting the list of shipping countries for Tax Applicable         
        List<String> listShippingCountries = new List<String>();
        List<Id> listLegalEnt = new List<Id>();
        Map<Id, String> MapLegalEnt = new Map<Id, String>();
        for(Tax_Country__mdt taxmdt:[SELECT Id,MasterLabel FROM Tax_Country__mdt  Where Is_Taxable__c =true])  
        {  
            if(!(String.isBlank(taxmdt.MasterLabel)))  
            {  
                listShippingCountries.add(taxmdt.MasterLabel?.toUpperCase()); //Added toUpperCase <TAX-273>
            }  
        }
        
        //Getting List of Business Unit for Legal Entity
         for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){
             if(oSBQQ_Quote.Legal_Entity__c!=null) 
             listLegalEnt.add(oSBQQ_Quote.Legal_Entity__c);
         }
        for(blng__LegalEntity__c legalEnt:[Select id, Business_Unit_Code__c from blng__LegalEntity__c where Id =: listLegalEnt])
        {
            MapLegalEnt.put(legalEnt.Id, legalEnt.Business_Unit_Code__c);
        }        
     
        // starts Populating Tax_Applicable__c if shipping country is valid and legal entity is 'US001'  
        for(SBQQ__Quote__c oSBQQ_Quote : lstTriggerNew){           
            if(listShippingCountries.size() > 0   
               && listShippingCountries.contains(oSBQQ_Quote.SBQQ__ShippingCountry__c?.toUpperCase()) //Added toUpperCase <TAX-273>
               && MapLegalEnt.containsKey(oSBQQ_Quote.Legal_Entity__c) 
               && MapLegalEnt.get(oSBQQ_Quote.Legal_Entity__c)  == 'US001'
              )                              
            {    
                oSBQQ_Quote.Tax_Applicable__c = true;  
            }  
            else  
            {  
                oSBQQ_Quote.Tax_Applicable__c = false;  
            }  
        }  
            
    }  

    //<SALESRT-14838> Starts here
    /**
     * @description : this method recalculates the ipu warnings
     * 
     * @param : newList - List of quotes
     * @param : oldMap - map of quote
     * 
     * @return : void
     */
    public static void recalculateWarning(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap){

        Set<Id> oppIdSet = new Set<Id>();

        for(SBQQ__Quote__c quot : newList){

            if(quot.SBQQ__Opportunity2__c != null){
                oppIdSet.add(quot.SBQQ__Opportunity2__c);
            }
        }

        if(!oppIdSet.isEmpty() && !System.isFuture() && !System.isBatch()){
            InfaSalesUtility.recalculateIpuWarnings(new List<Id>(oppIdSet));
        }
    }
    //<SALESRT-14838> Ends here
  /*Method Name : setValuesForNewQuote
    * @param List<SBQQ__Quote__c> lstTriggerNew
    * SALESRT-13388
    * Description - to call the notification framework
    */
    private static void callNotificationService(list<SBQQ__Quote__c> lstTriggerNew, map<Id, SBQQ__Quote__c> oldMap) { 
        NotificationService.notify(trigger.new, oldMap);
    }
  
    /*<SALESRT-15482>
    Method Name : validateEndDateOnEarlyRenewal,  
    * @param lstTriggerNew - list of new SBQQ__Quote__c  
    * @return return-void  
    This method call from 'QuoteBeforeUpdate' Trigger on SBQQ__Quote__c Object  
    The Quote End Date to be greater than Master Contract's End Date - Else Throw Error.  
    */     
    public static void validateEndDateOnEarlyRenewal(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotes){  
        Map<Id, Date> approvedQuotesContractIds = new Map<Id, Date>();
        List<SBQQ__Quote__c> approvedQuotes = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c q : newQuotes){
            if(q.Amend_Type__c =='Early Renewal - Extend End Date' && q.SBQQ__Status__c <> oldQuotes.get(q.Id).SBQQ__Status__c && 
                (q.SBQQ__Status__c == 'Approved' || q.SBQQ__Status__c == 'In Review')){//added In Review status check per <SALESRT-16909>
                approvedQuotesContractIds.put(q.SBQQ__MasterContract__c, null);
                approvedQuotes.add(q);
            }
        }
        if(approvedQuotes.size() > 0){
            for(Contract c : [select EndDate, Id from Contract where Id in :approvedQuotesContractIds.keySet()]){
                approvedQuotesContractIds.put(c.Id, c.EndDate);
            }
            for(SBQQ__Quote__c q : approvedQuotes){
                if(q.SBQQ__EndDate__c <= approvedQuotesContractIds.get(q.SBQQ__MasterContract__c)){
                    q.addError(System.Label.QuoteEndDateCheckErrorMsg);
                }
            }
        }

    }//Ends <SALESRT-15482>
    
    /*<SALESRT-16984    >
    Method Name : handleBeforeDelete,  
    * @param oldMap - map of new SBQQ__Quote__c  
    * @return return-void  
    This method call from 'QuoteBeforeDelete' Trigger on SBQQ__Quote__c Object  
    Delete access has been enabled on CPQ User cloned PS. Throw error if user tries to delete primary or ordered Quotes  
    */
    public static void handleBeforeDelete(Map<Id, SBQQ__Quote__c> oldMap){
        if(!(FeatureManagement.checkPermission('SystemAdmin') || FeatureManagement.checkPermission('IntegrationUser') || FeatureManagement.checkPermission('Support_Team'))){
            for(SBQQ__Quote__c quoteRec:oldMap.values()){
                if(quoteRec.SBQQ__Primary__c || quoteRec.SBQQ__Ordered__c || quoteRec.Primary_Order__c != null){
                    quoteRec.addError('You do not have necessary permission to delete this Quote');
                }
            }
        }
    }    
}