/*
Class:          OpportunityTriggerHandler
@Author:        Vishal Negandhi
@Test Classes:  OpportunityTriggerHandlerTest, PRM_OpportunityTriggerHandlerTest, LegalAgreementHandlerTest, QuoteTriggerHandlerTest
@Created Date:  10/31/2016
@Description:   handler class for Opportunity triggers
*/
/*
Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By            Description                                                                             Tag
**********************************************************************************************************************************************************
Gaurav Sadhwani         14/11/2016  Prasanth            OpportunityProductUpdate 
Thejaswini Sattenapalli 14/08/2017                      Sync Seondary Opportunity [Hybird Deal case]
Lokesh Kumar            13/11/2017  Prasanth            Sync Secondary Opportunity [Hybrid Deal case],                                          T02
Stage Name.
Lokesh Kumar            18/11/2017  Prasanth            Remove opportunity record type condition to assign                                      T03   
assignTerritory 
Kendra Claiborne        12/19/2017  Prasanth P.         Added logic to populate QLE's End Date Localized based on the related Quote's Territory
Ambica                  1/31/2017   Bhanu               Do not sync Primary to secondary when secondary is no opportunity                       T05
Ritika                  3/15/2018   Prasanth            Removed (oppNew.OrderableIn__c == NULL || oppNew.OrderableIn__c == '' ) from 
the if condition to allow the logic run for Renewal opps, as OrderableIn__c will 
now not be null for  Renewals Opps. Also, as per the use case given, it should 
run for New Sales opps being created in old org.                                        T06
Ritika                  3/15/2018   Prasanth            Added logic to Populate Transaction Type on OpportunityLineItems created for 
integration fields                                                                      T07
Vivek Warrier           04-Apr-2018                     Adding error when Opportunity is moved to higher 
stages without a Opp Contact roles                                                      T08
Deloitte                2/26/2018   PRM                 When Lead is converted to opportunity, process for PRM
Kiran G                 10/22/2018  Richard L           PRMRT-83 and PRMRT-86 While converting the Deal,adding the Deal Id on the Oppty partner T09
Kiran G                 10/22/2018  Richard L           PRMRT-88 Updated the logic of setting the Partner Sourced on the Oppty Partner using
Primary Role in Sales Field.                                                            T10 
Deloitte                2/20/2019   Q2C                 Add Renewal Recordtype to Territory and Opportunity Team assignments                    T11
Chandana Gowda          02/11/2019  Prasanth            Added the null checking condition on the set of opportunity Id's                        T12 
Ambica Pyati            03/04/2019   Prasanth          PRMRT-201 Nullify the dev lead identifier field on Oppty after  lead/deal is converted   T16
so the next lead/deal converted to existing opppty can map the value on it. 
Chandana Gowda          03-May-2019  Prasanth          SALESRT-4116 Added Logic to throw error when the opty is updated 
without a Opp Contact roles                                                             T17
Chandana Gowda          07-May-2019  Prasanth          SALESRT-4128 Updated the logic of updating the opty record products for making the 
integration fields 0 when no opty products exits                                        T18
Kiran G                 17-May-2019  Liz               While the Deal is converted to Oppty set the Transaction Type . If type is Direct/
Indirect = New and if Type is Renewal/Upsell then Upsell.                                T19
Vivek Warrier           24-May-2019  Liz                Commenting out the method syncToSecondaryOpportunity - Secondary Opportunity            T20
Sumit Mittal            05-Jun-2019  QCA-1229,QCA-1272  Q2C 2d: As part of QCA-1229 added the method 'pricebookAssignmentMethod' to update      T21
the pricebookid as per mapping.  Also updated the method for PRM to remove the
Standard pricebook logic during DR conversion and use the existing pricebook.
Kiran G              28-Aug-2019    PrasanthG            Update the OOB PartnerAccountId with custom Lookup field Partner_Account__c            T22
Chandana Gowda       09-Oct-2019    SALESRT-4312         Updated the addition of members to Opty Sales team to include Account Manger           T23
and BDM,CSM or CFR if they are the creators of the Opty                               
Vivek Warrier        10-Dec-2019    Tech Debt            Moving PB logic to Trigger                                                             T24                                                                      
Chandana Gowda      02-Dec-2019     SALESRT-11075        Added methods to update the probability and modified the logic for checking the        T25
contact role on addition  
Chandana Gowda      10-Dec-2019     SALESRT-11367       Added method ot keep the competetior picklist in sync with the related competetiors     T26   
Vivek Warrier       08-Jan-2020     SALESRT-11353       Splitting the territory from APJ to AP and JP                                           T27
Sumit Mittal        10-Apr-2020     SALESRT-11830       Disable the Territory assignment, remove ownership, StageReason for the 
Admin/Revision Flow process                                                             T28
Sumit Mittal        21-May-2020     SalesRT-12070       Fix for the old org renewal opportunity creation pricebook assingment                   T29
Ramya Ravi          16-Jul-2020     PRMRT-942           Enhance Deal Registration submission to a one step process                              T30
Chandana Gowda      27-Jul-2020     SALESRT-11867       Enabling Territory assignment for Indirect Optys                                        T31
Kiran G             27-Jul-2020     PRMRT-304           Creating the Partner Relationship for Ecosystem DR                                      T32
RamEsh M S          11-AUG-2020    I2C-728              Default "Revenue Agreement" on Enable Downstream for Revision Opportunity. For Amend,   T33
"Revenue Agreement" should not be defaulted and it is handled on "AdminAmendOnContract"
Anil Solanki        24- AUG-2020    SALESRT-12342       Updated conditions checking Territory Name  to update End Date Localized<T44>    
RamEsh M S          11-AUG-2020    I2C-1082             Remove Defaulted "Revenue Agreement" on Enable Downstream for Revision Opportunity.     <T46>
Anil Solanki        5-NOV-2020     SALESRT-12316        Copy Infa Compliance from Opportunity to Primary Quote<T47>
Kiran G             26-Oct-2020    PRMRT-1008           Add teh check for hte FIELD_FILTER_VALIDATION_EXCEPTION while creating PR . This will stop
                                                        converting the deals on Inactive Partner Account.                                        T34 
Chandana Gowda      11/2/2020       SALESRT-12290       Updated the subscription status when renewal Opty is closed Lost<T45>    
Ramya Ravi       28/12/2020    SALESRT-12126    Auto Update Opportunity Close Date to today’s date when Stage is updated to Closed Won, Closed Lost, No Opportunity, Duplicate <T48>
Mahesh Ganti        22-DEC-2020     PSA-111             Populate FF Project on Amend Opportunity                                                <T49>
Mahesh Ganti        23-DEC-2020     PSA-111             Project existance check Validation on opportunity Closure                               <T50>
Anil Solanki    05/02/2020      SALESRT-12583   Update 'Last Oppty Progress Update' if Description is changed                                   <T51>
RamEsh M S      19-FEB-2021     SALESRT-12449   Capture owner change Time Stamp on all Opportunity Types                                        <T52>
Chandana Gowda  23 Feb 2021     Tax-21                  Create CMS Request Engagement Record when stage = Final Negotiation/Committed           <T53>
Uday Kumar      01-APR-2021     SALESRT-12900   To create Bill to, Ship to, Sold to, End User contact records from Primary Quote on the Opportunity Contact Role <T54>
Chandana Gowda  22-APR-2021     SALESRT-12736   End Date Localization for Territories FEDOPS Territories                                        <T12736>
Puneet Lohia    18-Jun-2021        SALESRT-13075    Clari: Changing the API name on Competitor picklist field                                        <T13075>
Puneet Lohia    21-Jun-2021        SALESRT-13007    Automatically update Opportunity Price book and Currency                                        <T13007>
Puneet Lohia    22-Jun-2021        SALESRT-12123    Substage mapping for renewal opptys                                                                   <T12123>
Wasim Akram    16-JUN-2021    PRMRT-1050      Ability for VADs to submit a DR and establish a partner relationship as 1-Tier Reseller Partners <T55>
Chandana Gowda  24 Aug 2021     TAX-197                 CMS notification is trigger when Opportunity Stage is at 50% or higher <TAX-197>
Wasim Akram     09-Aug-2021     SALESRT-13090       Sync the Route to Market values from Previous Quote to Oppty                                <T56>
Chandana Gowda  31-Aug-2021     SALESRT-12317       Update Compliance approver on Discount Approver                                             <T12317>
Vivek Warrier   01-Sep-2021     PSA-1904            Timestamp for Region and Sales Journey sync with Project                                    <T57>
Anusha Akella   13-Sep-2021     SALESRT-13240       Updated the Meddicc fields in the opty update <T13240>
Chandana Gowda  23 Sep 2021     SALESRT-13270       Removing the logic to update End date Localized field                                       <T13270>
Wasim Akram     28-10-2021      SALESRT-13456       Default the RTM Detail field to Field Sales on Opportunity creation                         <T58>
Anusha Akella   Feb 16th 2021    IPUE-213           Ability to attach primary IPU Estimator into Opportunity                                      <T60>
Deva M          08-Feb-20222    AR-1734              To create Plan Comments                                                                     <T59>
Chandana Gowda   25-Apr-2022    SALESRT-13820       Remove logic to update primary Estimate on closed won                                    <SALESRT-13820>
Puneet Lohia     20-May-2022    SALESRT-13728       New LOGO SPIFF Changes                                                                   <SALESRT-13728>
Puneet Lohia    20-April-2022   SALESRT-13669       RTM values onCreate of Renewal Opportunity                                               <SALESRT-13669>
Chandana Gowda  17-May-2022     SALESRT-13870       Add SDR to sales Team, if SDR creates the opty                                           <SALESRT-13870>
Anusha Akella   20-Jun-2022     SALESRT-13988       Validation on Primary IPU Estimation for Channel Oppty                          <T13988>  
Narpavi Prabu   29-Aug-2022      AR-2771            Trigger Notification Subscription for Opportunity                                           <AR-2771>
Narpavi Prabu   22-Sep-2022      AR-2949            Trigger notficiation subscription for opportunity Afetr Insert                               <AR-2949>
Nikhil Mane     14-Oct-2022     SALESRT-14351       Primary IPU Estimator should be required when a Renewal Opportunity has Upsell on IPU Lines     <SALESRT-14351>
KAPIL TILWANI  1-Nov-2022    SALESRT-14444    New Text Field on Deal Registration & Partner Relationship to track Campaign Codes for Partners
Narpavi Prabu   27-Feb-2023    AR-2866             To update the Account in plan and interlock when Account changed in Opportunity                  <AR-2866>
Puneet Lohia    3/3/2023        SALESRT-14838   Validate IPUs between Quote and IPU Estimator   <SALESRT-14838>
Narpavi Prabu   4/04/2023        AR-3141              To Invoke the tracker method when the Opty is inser/update                         <AR-3141>     
VENKATESH BALLA 4/27/2023       SALESRT-15556       Added custompermission (Bypass_Opportunity_Validations) check to bypass opportunity 
                                                    object validation rules/data update restrictions                                            <SALESRT-15556>               
Nishant Bansal  19/6/2023       SALESRT-15083     Require IPU Estimator on Amendment Quote
Nishant Bansal  5/7/2023       SALESRT-15212       Check if stage is changed to recalculate
Chandana Gowda  7/28/2023      SALESRT-17160       Check opty name length before update                                                              <T17160>
Puneet          23/08/2023     SALESRT-17084        IPU Validation for all oppty & quote types                                                       <SALESRT-17084>
Chaitanya T     22/09/2023     <AR-3350>            Cloud Assurance Operational Activity Asks                                                        <AR-3350>
VENKATESH BALLA 10/12/203       SALESRT-16900       COMMENTED METHOD CALL validateCompetitorFields AS PART OF JIRA SALESRT-16900                     <SALESRT-16900> 
                                                    - TO MOVE APEX VALIDATIONS INTO STANDARD VALIDATION RULES.
*************************************************************************************************************************************************************
*/
/*
------------------------------------------------------------------------------< T01>
//Changes done
//Anil Solanki : Update opportunityProductUpdate Method :   
Added 'if' condition to limit the logic to run only for Renewal Opportunities.
------------------------------------------------------------------------------</T01>
*/
public class OpportunityTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    //Commented out as part of opty clean up  
    //Public static Boolean FlagOpportunityInsert = false;
    
    Public static Boolean LineItemUpdateFlag = false;
    Public static Boolean OpportunityUpdateFlag = false;
    Public static Boolean OpportunityInsertFlag = false;
    private final static string OPP_SKIP_TYPE = Label.Indirect; // Opp type to be skipped for territory assignment
    private final static string OPP_DIRECT_TYPE = 'Direct'; // Opp type to be checked for contact role validation <T17>
    private final static string OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; // new sales record type name on Opportunity
    private final static string OPP_CHANNEL_RT = Label.Channel_Opportunity; // Channel type name on Opportunity
    private final static string OPP_PROBABILITY_CHECK = Label.Probability_Update_Stage_Check;
    private final static string OPP_CONTACT_ROLE_CHECK = Label.Contact_Role_Stage_Check;
    private final static string OPP_STAGE_CHANGE_CHECK = Label.Cannot_Change_Stage_to_Identify;
    public static Boolean pricebookFlag = true; // <T13007> Flag for recursion control
    //<T59>
    public final static String OPP_CLOSED_WON = 'Closed Won';
    public final static String OPP_CLOSED_LOST = 'Closed Lost';
    public final static String renewalOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();    
    //<T59>
    public final static String RENEW_OPPTY_IPU_REQUIRED_ERROR = 'IPU Estimator is required for Stages of Committed or Closed Won. Please attach the IPU Estimator to the Renewal Opportunity.';
    //<SALESRT-16900>
    public static Map<String, String> oppStageMapping;
    /*
------------------------------------------------------------------------------< T01>
//Anil Solanki : Added Static String
*/
    private final static string OPP_RENEWAL_RT = Label.Renewal_Opportunity; // Renewal Opportunity record type name on Opportunity 
    /**
* this method is invoked from after insert event of Opportunity(bypass Integration Profile)
*
* @param lstNew - list of new opportunities
* @return return-void
* @throws exception - NA
*/
    
    public static void handleAfterInsert(List<Opportunity> lstNew){
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        string type = rtMap.get(lstNew[0].RecordTypeId).getName();
        addSalesTeamMembers(lstNew);
        //<AR-2949> - Start
        NotificationService.notify(lstNew, null);
        //</AR-2949> - End
    }
    
    /**
* this method is invoked from after insert event of Opportunity(all profiles)
*
* @param mapNew - map of new opportunities
* @return return-void
* @throws exception - NA
*/
    
    public static void handleAfterInsert(Map<Id,Opportunity> mapNew){
        string triggerType = 'AfterInsert';        
        //Commenting addEndUser and opportunityProductUpdate as part of opty cleanup
        //addEndUser(null, mapNew);
        //opportunityProductUpdate(null, mapNew);
        PRMLeadConversion(null, mapNew, null, triggerType);
        opportunityStampsAfterInsert(mapNew); //<T24>
        addCompetitorRecords(null,mapNew);  
        //<AR-3141>
        TrackerUtility.trackChanges(null,mapNew);
        OpportunityInsertFlag = true;
    }
    


    /**
* this method is invoked from before insert event of Opportunity
*
* @param lstNew - list of new opportunities
* @return return-void
* @throws exception - NA
*/
    
    public static void handleBeforeInsert(List<Opportunity> lstNew){
        // FlagOpportunityInsert=True; //---<T17>
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        string type = rtMap.get(lstNew[0].RecordTypeId).getName();
        string triggerType = 'BeforeInsert';
        assignTerritory(lstNew);
        OpportunityTriggerHandlerHelper.pricebookAssignmentMethod(lstNew, (Map<Id,Opportunity>)Trigger.newMap, (Map<Id,Opportunity>)Trigger.oldMap); // <T13007>
        PRMLeadConversion(null, null, lstNew, triggerType);
        opportunityStampsBeforeInsert(lstNew); //<T24>
        updateRTMFields(lstNew); //<T56>
        //psa_om_AmmendOpportunityHandler.populateProjectOnAmendOpportunity(lstNew); //<T49>
        //<SALESRT-13728> start
        OpportunityTriggerHandlerHelper.newLogoSpiffCalculator(lstNew);
        //<SALESRT-13728> end
        //<SALESRT-14320> start  
        //<SALESRT-16900>
        //OpportunityTriggerHandlerHelper.validateCompetitorFields(lstNew, (Map<Id,Opportunity>)Trigger.oldMap, (Map<Id,Opportunity>)Trigger.newMap);  
        //<SALESRT-14320> end
    }
    //<T56> Added the below method for SALESRT-13090
        /**
* this method is invoked from before insert event of Opportunity
* @param parameter- oppList - list of new Opportunities
* @return return-void
* @throws exception - NA
*/
    public static void updateRTMFields(List<Opportunity> listOpp){
        Set<Id> setContractId = new Set<Id>();
        for(Opportunity opp : listOpp){
            //Default the RTM Detail field to Field Sales on NNB Opportunity creation <T58>
            if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId()
              && opp.Route_To_Market__c == Label.Direct && String.isBlank(opp.Detail_RTM__c)){
                opp.Detail_RTM__c = Label.FieldSales;
            }
            //</T58>
            // If the Opportunity is of Renewal or Amendment
            if(opp.SBQQ__RenewedContract__c != null){
                setContractId.add(opp.SBQQ__RenewedContract__c);
            }
            else if(opp.SBQQ__AmendedContract__c != null){
                setContractId.add(opp.SBQQ__AmendedContract__c);
            }
        }
        //<SALESRT-13669> - Update to query
        if(setContractId.size() > 0){
            Map<Id,Contract> mapContract = new Map<Id,Contract>([SELECT Id, Detail_RTM__c,SBQQ__Order__c,SBQQ__Order__r.Route_To_Market__c,
                                                                 Route_To_Market__c,SBQQ__Order__r.Detail_RTM__c 
                                                                 FROM Contract
                                                                 WHERE Id IN :setContractId]);
            for(Opportunity opp : listOpp){
                //For Renewal Opportunity
                if(opp.SBQQ__RenewedContract__c != null && mapContract.get(opp.SBQQ__RenewedContract__c) != null){
                    //<SALESRT-13669> : added condition to check for prior order
                    if(mapContract.get(opp.SBQQ__RenewedContract__c).SBQQ__Order__c != null){
                        opp.Route_To_Market__c = mapContract.get(opp.SBQQ__RenewedContract__c).SBQQ__Order__r.Route_To_Market__c;
                        opp.Detail_RTM__c = mapContract.get(opp.SBQQ__RenewedContract__c).SBQQ__Order__r.Detail_RTM__c;
                    }
                    else{
                        opp.Route_To_Market__c = mapContract.get(opp.SBQQ__RenewedContract__c).Route_To_Market__c;
                        opp.Detail_RTM__c = mapContract.get(opp.SBQQ__RenewedContract__c).Detail_RTM__c;
                    }                
                }
                //For Amendment Opportunity
                else if(opp.SBQQ__AmendedContract__c != null && mapContract.get(opp.SBQQ__AmendedContract__c) != null){
                    //<SALESRT-13669> : added condition to check for prior order
                    if(mapContract.get(opp.SBQQ__AmendedContract__c).SBQQ__Order__c != null){
                        opp.Route_To_Market__c = mapContract.get(opp.SBQQ__AmendedContract__c).SBQQ__Order__r.Route_To_Market__c;
                        opp.Detail_RTM__c = mapContract.get(opp.SBQQ__AmendedContract__c).SBQQ__Order__r.Detail_RTM__c;
                    }
                    else{
                    opp.Route_To_Market__c = mapContract.get(opp.SBQQ__AmendedContract__c).Route_To_Market__c;
                    opp.Detail_RTM__c = mapContract.get(opp.SBQQ__AmendedContract__c).Detail_RTM__c;                
                }
            }
        }
    }
    }
    //</T56>
    /**
* this method is invoked from after update event of Opportunity
*
* @param parameter- mapOld - map of old Opportunities
* @param parameter- mapNew - map of new Opportunities
* @return return-void
* @throws exception - NA
*/
    
    public static void handleAfterUpdate(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        string triggerType = 'AfterUpdate';
        //Commenting addEndUser and opportunityProductUpdate as part of opty cleanup
        //addEndUser(mapOld, mapNew);
        //opportunityProductUpdate(mapOld, mapNew);
        //updateQuoteLineItem(mapOld, mapNew); //Update the Quote Line's field - End_Date_Localized__c if the Opportunity Territory has been modified //Commenting as part of <T13270>
        PRMLeadConversion(mapOld, mapNew, null, triggerType);
        PRMafterUpdateSharing(mapOld,mapNew);
        retainPrevOwnerEditAccess(mapOld,mapNew);
        addCompetitorRecords(mapOld,mapNew);
        removeSalesTeamMembers(mapOld,mapNew);  //</T28>
        updateQuote(mapOld,mapNew);  //<T47>
        updateSubscriptionStatus(mapOld,mapNew); //<T45> 
        createCMSRequest(mapOld,mapNew); //<T53>
        updateDiscountApproval(mapOld,mapNew); //<T12317>
        OpportunityTriggerHandlerHelper.updateOCR(mapOld,mapNew); //<T54>
        //<T13007> start
        if(pricebookFlag){
            OpportunityTriggerHandlerHelper.pricebookAssignmentMethod(Trigger.new, mapNew, mapOld);   
        }
        // <T13007> end
        //<T59> Start
        checkOpportunityStage(mapNew.values(), mapOld);
        //<T59> End
        //<AR-2771> Start
        NotificationService.notify(mapNew.values(), mapOld);
        //<AR-2771> End
        //<AR-2866>
        CheckAccountChange(mapNew.values(), mapOld);
        recalculateWarning(mapNew.values(),mapOld);
        //<AR-3141>
        TrackerUtility.trackChanges(mapOld,mapNew);
        //<AR-3350>
        createChatterPostOnClosedWon(mapNew,mapOld);
    }

    //<T59> start
    /*
    Method Name : checkOpportunityStage
    Description : This method will create internal plan comments for Opportuniry Records
    Parameters   : List<Opportunity> lstnewOpportunity, 
                        Map<Id,Opportunity> mapOldOpportunity
    Return Type : NA
    */
    public static void checkOpportunityStage(List<Opportunity> lstnewOpportunity, Map<Id,Opportunity> mapOldOpportunity){
        Set<Id> setOpportunity = new Set<Id>();
        for(Opportunity objOpp:lstnewOpportunity){
            if(mapOldOpportunity != null && mapOldOpportunity.get(objOpp.Id) != null){
                Opportunity oldOpp = mapOldOpportunity.get(objOpp.Id) ;
                if(objOpp.RecordTypeId==renewalOpportunity && objOpp.StageName  != oldOpp.StageName && 
                    (objOpp.StageName.equalsIgnoreCase(OPP_CLOSED_WON) || objOpp.StageName.equalsIgnoreCase(OPP_CLOSED_LOST))){
                        setOpportunity.add(objOpp.Id);
                }
            }
        }
        if(setOpportunity.size()>0){
            //AR-1734  
            System.enqueueJob(new CSMCreateOpportunityCommentsQueueable(setOpportunity));
        }
    }
    //<T59> End

    /**
    * this method is invoked from after update event of Opportunity
    * if the INFA License Compliance is changed then update the list of Associated DA's accordingly
    * @param parameter- oldList - list of old Opportunities
    * @param parameter- newMap - map of new Opportunities
    * @return return-void
    * @throws exception - NA
    */  
    //----------------------------------------------------------------------------------------------<T12317>
    public static void updateDiscountApproval(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        Set<Id> lstOppIdUpdate = new Set<Id>();
        
        for(Opportunity oppRec: mapNew.values()){
            if(mapNew.get(oppRec.Id).PT_INFA_License_Compliance__c != mapOld.get(oppRec.Id).PT_INFA_License_Compliance__c){
                lstOppIdUpdate.add(oppRec.Id);
            }
        }
        if(!lstOppIdUpdate.isEmpty()){
            updateDiscountApprovalFuture(lstOppIdUpdate);
        }
    }    
    @future
    public static void updateDiscountApprovalFuture(Set<Id> lstOppIdUpdate){
        Map<Id,Opportunity> optyMap = new Map<Id,Opportunity>([Select Id,PT_INFA_License_Compliance__c,(SELECT Id,Compliance_Approver__c FROM Discount_Approvals__r WHERE Status__c = 'New') FROM Opportunity WHERE Id IN :lstOppIdUpdate]);
        List<DiscountApproval__c> lstDAToUpdate = new List<DiscountApproval__c>();
        String complianceApprover = Label.Compliance_Approver;
        for(Opportunity oppRec:optyMap.values()){
            if(oppRec.Discount_Approvals__r.size() != 0){
                for(DiscountApproval__c daRec:oppRec.Discount_Approvals__r){
                    if(oppRec.PT_INFA_License_Compliance__c && daRec.Compliance_Approver__c == null){
                        daRec.Compliance_Approver__c = complianceApprover;
                        lstDAToUpdate.add(daRec);
                    }else if(!oppRec.PT_INFA_License_Compliance__c){
                        daRec.Compliance_Approver__c = null;
                        lstDAToUpdate.add(daRec);
                    }
                }                
            }
        }
        
        if(!lstDAToUpdate.isEmpty()){
            try{
                Database.SaveResult[] srList = Database.update(lstDAToUpdate, true);
            } catch(Exception e){
                GAM.CreateLogs('OpportunityTriggerHandler.updateDiscountApprovalFuture', lstDAToUpdate, 'lstDAToUpdate');
            }            
        }        
    }
    
    //-----------------------------------------------------------------------------------------------</T12317>
    /**
    * this method is invoked from after update event of Opportunity
    * if the stage is changed to closed lost Update the status of subscriptions of related contrcts to cancelled
    * @param parameter- oldList - list of old Opportunities
    * @param parameter- newMap - map of new Opportunities
    * @return return-void
    * @throws exception - NA
    */  
    //----------------------------------------------------------------------------------------------<T45>
    public static void updateSubscriptionStatus(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        Set<Id> lstOppIdUpdate = new Set<Id>();
        List<Contract> lstContractUpdate = new List<Contract>();
        
        for(Opportunity oppRec: mapNew.values()){
            if(oppRec.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId()){
                if(oppRec.StageName == 'Closed Lost' && mapNew.get(oppRec.Id).StageName != mapOld.get(oppRec.Id).StageName){
                    lstOppIdUpdate.add(oppRec.Id);
                }
            }
        }
        if(!lstOppIdUpdate.isEmpty()){
            Map<Id,Contract> mapContractToUpdate = new Map<Id,Contract>([SELECT Id FROM Contract WHERE SBQQ__RenewalOpportunity__c IN :lstOppIdUpdate]);            
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
                     GAM.CreateLogs('OpportunityTriggerHandler.updateSubscriptionStatus', lstContractUpdate, 'lstContractUpdate');
                }
            }
        }
    }
    //-----------------------------------------------------------------------------------------------</T45>
    
    /**
    * this method is invoked from after update event of Opportunity
    * if the stage is changed to closed lost,Final Negotiation,Committed OR if the probbility is greater than 70% 
    * CMS Request Engagement record is created
    * @param parameter- oldList - list of old Opportunities
    * @param parameter- newMap - map of new Opportunities
    * @return return-void
    * @throws exception - NA
    */  
    //----------------------------------------------------------------------------------------------<T53>
    public static void createCMSRequest(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        Set<Id> setOppIds = new Set<Id>();
        Decimal Early_CMS_Oppty_Probability = Decimal.valueOf(Label.Early_CMS_Oppty_Probability); //<TAX-197>
                
        //Get New and Renewal Opportunity with Stage = Final Negotiaion/Committed or Probability > 70
        for(Opportunity oppRec: mapNew.values()){
            if(mapNew.get(oppRec.Id).Type != 'Upsell'){
                if(mapNew.get(oppRec.Id).Probability != mapOld.get(oppRec.Id).Probability && oppRec.Probability >= Early_CMS_Oppty_Probability){ //<TAX-197>
                    setOppIds.add(oppRec.Id);
                }                
            }
        }
        
        if(!setOppIds.isEmpty()){
            //Get the Quote,Quote's sold To and Bill to Account Data Where ERP Company Id is not populated
            Map<Id,Opportunity> mapOppById = new Map<Id,Opportunity>([SELECT Id,(SELECT Id,SoldToAccount__c,BillToAccount__c,SoldToAccount__r.Peoplesoft_External_ID__c,BillToAccount__r.Peoplesoft_External_ID__c,SBQQ__ShippingCountry__c FROM SBQQ__Quotes2__r WHERE (SoldToAccount__r.Peoplesoft_External_ID__c = null OR BillToAccount__r.Peoplesoft_External_ID__c = null) AND Business_Unit__c = 'US001') FROM Opportunity WHERE Id IN :setOppIds]);
            Map<Id,Id> mapAccountOpp = new Map<Id,Id>(); //Map of Account to Opty
            Map<String,Id> mapOppAccQuoute = new Map<String,Id>(); //Map of Opty+Account and Quote, Opty+Account to avoid duplicates 
            Map<Id,String> mapAccountShippingCountry = new Map<Id,String>(); //Map of Account and Quotes Shipping country 
            Map<Id,String> mapAccountCMSRequestType = new Map<Id,String>(); //Map of Account and CMS Request Type                     
            for(Opportunity opp:mapOppById.values()){
                if(!opp.SBQQ__Quotes2__r.isEmpty()){
                    for(SBQQ__Quote__c quoteRec: opp.SBQQ__Quotes2__r){
                        if(quoteRec.SoldToAccount__c != null && quoteRec.SoldToAccount__r.Peoplesoft_External_ID__c == null){
                            mapAccountOpp.put(quoteRec.SoldToAccount__c,opp.Id);
                            mapAccountShippingCountry.put(quoteRec.SoldToAccount__c,quoteRec.SBQQ__ShippingCountry__c);
                            mapOppAccQuoute.put(String.valueOf(opp.Id)+String.valueOf(quoteRec.SoldToAccount__c),quoteRec.Id);
                            mapAccountCMSRequestType.put(quoteRec.SoldToAccount__c,'SoldTo');
                        }
                        if(quoteRec.BillToAccount__c != null && quoteRec.BillToAccount__r.Peoplesoft_External_ID__c == null){
                            mapAccountOpp.put(quoteRec.BillToAccount__c,opp.Id);
                            mapAccountShippingCountry.put(quoteRec.BillToAccount__c,quoteRec.SBQQ__ShippingCountry__c);
                            mapOppAccQuoute.put(String.valueOf(opp.Id)+String.valueOf(quoteRec.BillToAccount__c),quoteRec.Id);
                            mapAccountCMSRequestType.put(quoteRec.BillToAccount__c,'BillTo');
                        }
                    }
                }
            }    
        
            if(!mapAccountOpp.isEmpty()){
                //Geting the list of countries for which CMS team has to be notified
                Map<Id,Tax_Country__mdt> mapTaxCountries = new Map<Id,Tax_Country__mdt>([SELECT MasterLabel,CMS_Chatter_Group__c,CMS_Queue_Id__c FROM Tax_Country__mdt WHERE MasterLabel IN :mapAccountShippingCountry.values() AND CMS_Chatter_Group__c != null]);
                if(!mapTaxCountries.isEmpty()){
                    //Creating a map of country,CMS group
                    Map<String,List<String>> mapCountryCMSInfo = new Map<String,List<String>>();
                    for(Tax_Country__mdt countryRec:mapTaxCountries.values()){
                        mapCountryCMSInfo.put(countryRec.MasterLabel,new List<String>{countryRec.CMS_Chatter_Group__c,countryRec.CMS_Queue_Id__c});
                    }
                    //Removing the Accounts from the map for which Tax_Country__mdt entry does not exists
                    for(Id accId:mapAccountShippingCountry.keySet()){
                        if(!mapCountryCMSInfo.containsKey(mapAccountShippingCountry.get(accId))){
                            mapAccountShippingCountry.remove(accId);
                        }
                    }
                    if(!mapAccountShippingCountry.isEmpty()){
                        String ENGMNT_CMS_REQUEST = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('CMS Request').getRecordTypeId();
                        //Getting the count of Existing CMS Request Engagement Record associated with the Sold to Accounts
                        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id,Name,(SELECT Id FROM Sales_Support_Requests__r WHERE RecordTypeId =:ENGMNT_CMS_REQUEST) FROM Account WHERE Id IN:mapAccountShippingCountry.keySet()]);
                        //Creating a map of Account, CMS Request Engagement Record count
                        Map<Id,Integer> mapAccCMSRequestCount = new Map<Id,Integer>();
                        for(Account Acc:mapAccount.values()){
                            mapAccCMSRequestCount.put(Acc.Id,Acc.Sales_Support_Requests__r.size());
                        }
                        
                        //List of CMS Request Engagement records to insert
                        List<Engagement__c> lstEngagementToInsert = new List<Engagement__c>();
                        for(Id accId:mapAccountShippingCountry.keySet()){
                            //Create new Enagement record only for the Accounts without any existing CMS Request Engagement records
                            if(mapAccCMSRequestCount.get(accId) < 1){
                                Engagement__c engagementRec = new Engagement__c();
                                if(mapAccountCMSRequestType.get(accId) == 'SoldTo'){
                                    engagementRec.Title__c = 'Process CMS for the Sold to Account';
                                }else{
                                    engagementRec.Title__c = 'Process CMS for the Bill to Account';
                                }
                                engagementRec.RecordTypeId = ENGMNT_CMS_REQUEST;
                                engagementRec.OwnerId = mapCountryCMSInfo.get(mapAccountShippingCountry.get(accId))[1];
                                engagementRec.Dev_CMS_Group_Id__c = mapCountryCMSInfo.get(mapAccountShippingCountry.get(accId))[0];
                                engagementRec.Name = 'CMS Request for '+mapAccount.get(accId).Name;
                                engagementRec.Opportunity__c = mapAccountOpp.get(accId);
                                engagementRec.Quote__c = mapOppAccQuoute.get(String.valueOf(mapAccountOpp.get(accId))+String.valueOf(accId));
                                engagementRec.Account__c = accId;
                                lstEngagementToInsert.add(engagementRec);
                            }
                        }
                        if(!lstEngagementToInsert.isEmpty()){
                            try{
                                Database.SaveResult[] srList = Database.insert(lstEngagementToInsert, false);
                            } catch(Exception e){
                                GAM.CreateLogs('OpportunityTriggerHandler.createCMSRequest', lstEngagementToInsert, 'lstEngagementToInsert');
                            }
                        }
                    }                    
                }
            }
        }        
    }
    //-----------------------------------------------------------------------------------------------</T53>    
    
    /**
* this method is invoked from after update event of Opportunity
* if ownership changes, manage opportunity sharing
* @param parameter- oldList - list of old Opportunities
* @param parameter- newMap - map of new Opportunities
* @return return-void
* @throws exception - NA
*/
    public static void PRMafterUpdateSharing(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        //flag to be set during ownership change
        boolean oppOwnerChange = true;
        //set of Opportunity
        set<Id> oppSet = new set<Id>();
        //list of Partner_Relationship__c
        list<Partner_Relationship__c> partnerRelList = new List<Partner_Relationship__c>();
        
        for(Opportunity oppNew : mapNew.values()){
            //check if there has been change in ownership
            if(null != oppNew.OwnerId && oppNew.OwnerId != mapOld.get(oppNew.Id).OwnerId)
            {
                oppSet.add(oppNew.Id);
            }
        }
        
        //fetch all Partner Relationships for the Opportunity
        //----------------------------------------------------------------------------------------------<T12>
        if(oppSet!= null && !oppSet.isEmpty()){
            //----------------------------------------------------------------------------------------------</ T12>
            for(Opportunity opp :[select id,(select id,Opportunity__c,Partner_Account__c,Status__c from Partner_Relationships__r) from Opportunity where id in :oppSet])
            {
                List<Partner_Relationship__c> existingPartnerRelList = opp.Partner_Relationships__r;
                if(null != existingPartnerRelList && !existingPartnerRelList.isEmpty())
                    partnerRelList.addAll(existingPartnerRelList);
            }
        }
        
        //call method: afterUpdateSharing of class: PartnerRelationshipTriggerHandler to manage opportunity sharing using PartnerRelationship
        if(null != partnerRelList && !partnerRelList.isEmpty())
        {
            PartnerRelationshipTriggerHandler.afterUpdateSharing(partnerRelList, null, null, null, true);
        }
        
    }
    
    /**
* this method is invoked from after update event of Opportunity
*
* @param parameter- oldList - list of old Opportunities
* @param parameter- newMap - map of new Opportunities
* @return return-void
* @throws exception - NA
*/
    
    public static void handleAfterUpdate(List<Opportunity> oldList, map<Id,Opportunity> newMap){
        
        try
        {
            List<Opportunity>listToUpdate = new List<Opportunity>();
            if(!oldList.isEmpty() && oldList!=null && !newMap.isEmpty()){
                for(Opportunity opr: oldList){
                    if(newMap.containsKey(opr.id) && newMap.get(opr.Id)!=null){
                        GAM.CreateLogs('OpportunityTriggerHandler->handleAfterUpdate','New Map OPR ID ' + opr.id + ' and its value is ' + newMap.get(opr.Id));
                        GAM.CreateLogs('OpportunityTriggerHandler->handleAfterUpdate','OPR Territory ID is ' + opr.Territory2Id + '. New Map Ter ID ' + newMap.get(opr.Id).Territory2Id);
                        if(opr.Territory2Id!= newMap.get(opr.id).Territory2Id 
                           && newMap.get(opr.id).Territory2Id != Null){             //</T28> : Added a null check
                               listToUpdate.add(newMap.get(opr.id));
                           }
                    }
                }
            }
            
            if(!listToUpdate.isEmpty()){
                addSalesTeamMembers(listToUpdate);
            } 
        }
        
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'Exception in handleAfterUpdate',ex.getMessage());
        } 
        GAM.InsertDebugLogs();
        
    }
    
    /*
<T08>
* This method is invoked from before update event of Opportunity
* @param parameter- oldMap - map of old Opportunities being updated
* @param parameter- newMap - map of new Opportunities being updated
* @return return-void
* @throws exception - NA
*/
    public static void handlerBeforeUpdate(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){

        
        updatePrimaryESOnOpportunity(oldMap,newMap);
        updateProbability(oldMap,newMap);
        opportunityStampsUpdate(oldMap,newMap); //<T24> 
        checkStageChange(oldMap,newMap);
        syncStageSubstage(oldMap,newMap);  
        checkContactRole(oldMap,newMap);
        UpdateCloseDate(oldMap,newMap);//<T48>
        //updateCloseDateOnES(oldMap,newMap);//<T60>
        psa_om_AmmendOpportunityHandler.populateProjectOnAmendOpportunity(newMap.values()); //<T49>
        psa_om_AmmendOpportunityHandler.checkIfProjectExistsForPSOpps(oldMap,newMap); //<T50>
         //<SALESRT-14320> start  
        //<SALESRT-16900>
        //OpportunityTriggerHandlerHelper.validateCompetitorFields(newMap.values(),oldMap,newMap);  
        //<SALESRT-14320> end
        
    }
     /*
<T48>
Method to update close date for stages moved to Close lost, no oppoty and duplicate
*/
    public static void UpdateCloseDate(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
          if(!oldMap.isEmpty() && oldMap != null){
            for(Opportunity opp : newMap.values()){
                if((
                    opp.Substage__c != oldMap.get(opp.id).Substage__c && 
                   (opp.Substage__c =='Sales Won' || opp.Substage__c =='Closed Lost' || opp.Substage__c =='Duplicate' || opp.Substage__c =='No Opportunity'  )
                   )
                    ||
                    (
                    opp.StageName != oldMap.get(opp.id).StageName && 
                   (opp.StageName =='Closed Won'  || opp.StageName =='Closed Lost' || opp.StageName =='Duplicate' || opp.StageName =='No Opportunity'  )
                   )
                   )
                {
                    opp.CloseDate = Date.today();   
                }
            }
          }
    }
     
    /*
<T24>
Intended for the purpose of moving the logic in Process Builder Opportunity - Update to Trigger/handler
*/
    public static void opportunityStampsUpdate(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        
        Map<Id,String> RecordTypeMap = new Map<Id,String>();
        for(Opportunity opp : [SELECT Id, Recordtype.DeveloperName FROM Opportunity WHERE Id IN :newMap.keySet()]){
            RecordTypeMap.put(opp.Id,opp.Recordtype.DeveloperName);
        }
        //<T51> Added Description field in condition
        if(!oldMap.isEmpty() && oldMap != null){
            System.debug('oldMap: ' + oldMap);
            for(Opportunity opp : newMap.values()){
                 if(((opp.Delivery__c != oldMap.get(opp.Id).Delivery__c) ||
                    (opp.Red_Flags__c != oldMap.get(opp.Id).Red_Flags__c) ||
                    (opp.Current_Status__c != oldMap.get(opp.Id).Current_Status__c) ||
                    (opp.BANT_Qualification__c != oldMap.get(opp.Id).BANT_Qualification__c) ||
                    (opp.Technology_Ecosystem__c != oldMap.get(opp.Id).Technology_Ecosystem__c) ||
                    (opp.Solutions__c != oldMap.get(opp.Id).Solutions__c) ||
                    (opp.Next_Steps__c != oldMap.get(opp.Id).Next_Steps__c) ||
                    (opp.Description != oldMap.get(opp.Id).Description) ||
                    (opp.NextStep != oldMap.get(opp.Id).NextStep) ||
                    (opp.Competitors__c != oldMap.get(opp.Id).Competitors__c) ||
                    (opp.Metrics__c != oldMap.get(opp.Id).Metrics__c) ||                      //T13240
                    (opp.Economic_Buyer__c != oldMap.get(opp.Id).Economic_Buyer__c) ||        //T13240
                    (opp.Decision_Criteria__c != oldMap.get(opp.Id).Decision_Criteria__c) ||   //T13240
                    (opp.Decision_Process__c != oldMap.get(opp.Id).Decision_Process__c) ||     //T13240
                    (opp.Champion__c != oldMap.get(opp.Id).Champion__c) )&&                 //T13240
                   opp.isClosed == false)     
                    opp.Last_Opportunity_Progress_Update__c = DateTime.now();
                
                if(opp.Territory2Id != oldMap.get(opp.Id).Territory2Id)
                    opp.Territory_Change_Timestamp__c = DateTime.now();
                
                if(opp.OwnerId != oldMap.get(opp.Id).OwnerId &&
                   //(RecordTypeMap.get(opp.Id) == 'New_Sales_Opportunity' || <T52>
                    //RecordTypeMap.get(opp.Id) == 'Channel_Opportunity') &&  <T52>
                   opp.isClosed == false &&
                   UserInfo.getUserId() != (Id)Label.Integration_User_Id)
                    opp.Owner_Change_Timestamp__c = DateTime.now();    
                
                if(opp.StageName != oldMap.get(opp.Id).StageName &&
                   opp.StageName != '' &&
                   (opp.StageName == 'Identify' ||
                    opp.StageName == 'Validate' ||
                    opp.StageName == 'Qualified' ||
                    opp.StageName == 'Final Negotiation'
                   ))
                    opp.DEV_Oppty_Stage_Changed_Date__c = DateTime.now(); 
                //T28>
                if(opp.Remove_Ownership__c != oldMap.get(opp.Id).Remove_Ownership__c && opp.Remove_Ownership__c) {
                    opp.OwnerId = Label.AdminFlowOwnerId ;
                    opp.Territory2Id = Null;
                }//</T28

                //<T57>
                if(opp.pse__Region__c != oldMap.get(opp.Id).pse__Region__c || opp.Sales_Journey__c != oldMap.get(opp.Id).Sales_Journey__c){
                    opp.PSA_Field_Change_Timestamp__c = DateTime.now();
                }
                //</T57>                
            }
        }
    }
    
    public static void opportunityStampsBeforeInsert(List<Opportunity> newList){
        
        Map<Id,String> RecordTypeMap = new Map<Id,String>();
        for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Opportunity']){
            RecordTypeMap.put(rt.Id,rt.DeveloperName);
        }
        
        for(Opportunity opp : newList){
            opp.Territory_Change_Timestamp__c = DateTime.now();
            
            if(UserInfo.getUserId() != (Id)Label.Integration_User_Id &&
            //(RecordTypeMap.get(opp.RecordTypeId) == 'New_Sales_Opportunity' ||  <T52>
            // RecordTypeMap.get(opp.RecordTypeId) == 'Channel_Opportunity') &&   <T52>
               opp.isClosed == false)
                opp.Owner_Change_Timestamp__c = DateTime.now();  
            
            //<T28>
            if(opp.Admin__c) {
                opp.StageName = 'No Opportunity';
                opp.Substage__c = 'No Opportunity';
                opp.Stage_Reason__c = 'Revision Opportunity';
                opp.Enable_Downstream__c = 'Assets & Entitlements';//<T46>Revenue Agreement'; //<T33>
            }
            if(opp.Remove_Ownership__c){
                opp.OwnerId = Label.AdminFlowOwnerId ;
                opp.Territory2Id = Null;
            }//<T28>
        }
    }
    
    public static void opportunityStampsAfterInsert(Map<Id, Opportunity> newMap){
        
        Map<Id, Opportunity> OptyDetailMap = new Map<Id, Opportunity>();
        List<Opportunity> ListOppUpdate = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, Name, Type, Account.Name, SBQQ__RenewedContract__r.ContractNumber, SBQQ__RenewedContract__r.EndDate, SBQQ__AmendedContract__r.ContractNumber, 
                               Admin__c,Remove_Ownership__c,StageName,Substage__c,Stage_Reason__c,SBQQ__AmendedContract__r.Admin_Contract__c
                               FROM Opportunity 
                               WHERE Id IN :newMap.keySet()]){
                                   OptyDetailMap.put(opp.Id, opp);
                               }
        
        for(Opportunity opp : OptyDetailMap.values()){
            //--------------------------------------------------------------------------------------------------------------------------<T17160> : Opty name length check
            String opptyName;
            
            if(opp.Name == 'Renewal Opportunity'){
                opptyName = opp.Account.Name.length() <=120 ? opp.Account.Name : opp.Account.Name.left(120);
                opptyName = (opptyName + ' ' + opp.SBQQ__RenewedContract__r.ContractNumber + ' ' + opp.SBQQ__RenewedContract__r.EndDate.year() + ' ' + 'Renew').length() <=120 ? (opptyName + ' ' + opp.SBQQ__RenewedContract__r.ContractNumber + ' ' + opp.SBQQ__RenewedContract__r.EndDate.year() + ' ' + 'Renew'): opptyName;
                opp.Name = opptyName;
                ListOppUpdate.add(opp);
            }
            
            if(opp.SBQQ__AmendedContract__c != null){
                opptyName = opp.Account.Name.length() <=120 ? opp.Account.Name : opp.Account.Name.left(120);
                opptyName = (opptyName + ' ' + opp.SBQQ__AmendedContract__r.ContractNumber + ' ' + 'Amend').length() <=120 ? (opptyName + ' ' + opp.SBQQ__AmendedContract__r.ContractNumber + ' ' + 'Amend'): opptyName;
                opp.Name = opptyName;
                opp.Type = 'Upsell';
                ListOppUpdate.add(opp);
            }
            //--------------------------------------------------------------------------------------------------------------------------</T17160> : Opty name length check
        }
        Database.SaveResult[] results = Database.update(ListOppUpdate,false); //DML
        
        for(Database.Saveresult res : results){
            if(res.isSuccess()){
                System.debug('Transaction was successful.');
            }
            else{
                for(Database.Error err : res.getErrors()){
                    System.debug('Error Message:\n' + err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    //</T24> 
    
    //-----------------------------------------------------------------------------------------------------<T25>
    /*
* Update the Probability based on the Value of forecast category
* @param parameter- oldMap - map of old Opportunities being updated
* @param parameter- newMap - map of new Opportunities being updated
* @return return- void
*/
    public static void updateProbability(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
        for(Opportunity opp:newMap.values()){
            if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId()){
                if((OPP_PROBABILITY_CHECK.contains(opp.StageName)) && opp.get('ForecastCategoryName') != oldMap.get(opp.Id).get('ForecastCategoryName')){
                    if(opp.get('ForecastCategoryName') == 'Best Case')
                        opp.put('Probability', 50);
                    if(opp.get('ForecastCategoryName') == 'Commit')
                        opp.put('Probability', 75);
                }
            }
        }
    }
    
    /*
* If the opportunity is past the Substage Discovery check for additon of 
* contact role of update of Opty
* @param parameter- lstNew - list of new opportunities
* @return return- void
*/
    public static void checkContactRole(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
        
        User_Exemptions__c ue = User_Exemptions__c.getInstance(UserInfo.getProfileId()); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission
        Boolean IsExemptUser = (cpr.hasPermission('SystemAdmin') || cpr.hasPermission('IntegrationUser') || cpr.hasPermission('SalesSuperUser') || cpr.hasPermission('Bypass_Opportunity_Validations') || ue.Ignore_Validation_Rules__c);  /*<SALESRT-15556>*/
        
        if(!IsExemptUser && !OpportunityInsertFlag){
            List<Id> ListofOpps = new List<Id>();
            Set<Id> SetofErrOpps = new Set<Id>();
            Boolean fieldChanged = false;
            
            //Getting all the (Ids of the) Opportunities that have been changed to Validate/Qualified/Final Negotiation/Closed Won
            for(Opportunity opp : newMap.values()){
                if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId()){                
                    if(OPP_CONTACT_ROLE_CHECK.contains((String)opp.get('Substage__c')) && opp.Dev_Lead_Identifier__c == null){
                        for(Schema.FieldSetMember fsm:SObjectType.Opportunity.FieldSets.Contact_Role_Check.getFields()){
                            if(opp.get(fsm.getFieldPath()) != oldMap.get(opp.Id).get(fsm.getFieldPath())){
                                fieldChanged=true;
                                break;
                            }
                        }
                        if(fieldChanged){
                            ListofOpps.add(opp.Id);
                            fieldChanged = false;
                        }
                    }
                }
            } 
            
            //Flitering out the (Ids of the) Opportunities that have no Contact Roles
            if(ListofOpps.size() > 0 ){
                Set<Id> lstOppWithConRole = new Set<Id>();
                for(OpportunityContactRole oppCon:[SELECT Id,OpportunityId from OpportunityContactRole WHERE OpportunityId IN:ListofOpps]){
                    lstOppWithConRole.add(oppCon.OpportunityId);
                }
                for(Id op :ListofOpps){
                    if(!lstOppWithConRole.contains(op)){
                        SetofErrOpps.add(op);
                    }
                }                
            }         
            
            //Looping through the trigger variable and throwing error where there is no Opportunity Contact Role
            if(SetofErrOpps.size() > 0){
                for(Opportunity Opp : newMap.values()){
                    if(SetofErrOpps.contains(Opp.Id)){
                        Opp.addError(Label.OppContRole_Error); //Find the custom label OppContRole_Error to change the message
                    }
                }
            }
        }
    }
    public static void checkStageChange(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
        
        User_Exemptions__c ue = User_Exemptions__c.getInstance(UserInfo.getProfileId()); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission
        Boolean IsExemptUser = (cpr.hasPermission('SystemAdmin') || cpr.hasPermission('IntegrationUser') || cpr.hasPermission('SalesSuperUser') || cpr.hasPermission('Bypass_Opportunity_Validations') || ue.Ignore_Validation_Rules__c);  /*<SALESRT-15556>*/
        //Boolean IsExemptUser = cpr.hasPermission('IntegrationUser');
        
        if(!IsExemptUser && !OpportunityInsertFlag){
            List<Id> ListofOpps = new List<Id>();
            Set<Id> SetofErrOpps = new Set<Id>();
            Boolean fieldChanged = false;
            
            //Getting all the (Ids of the) Opportunities that have been changed to Validate/Qualified/Final Negotiation/Closed Won
            for(Opportunity opp : newMap.values()){
                if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId()){                
                    if(opp.StageName == 'Identify' && OPP_STAGE_CHANGE_CHECK.contains((String)oldMap.get(opp.Id).get('StageName'))||
                        (opp.StageName == 'Validate' && oldMap.get(opp.Id).get('StageName')=='Final Negotiation'))
                        SetofErrOpps.add(opp.Id);
                }
            }         
            
            //Looping through the trigger variable and throwing error where there is no Opportunity Contact Role
            if(SetofErrOpps.size() > 0){
                getStageMapping();//<SALESRT-16900>
                for(Opportunity Opp : newMap.values()){
                    if(SetofErrOpps.contains(Opp.Id)){
                        //<SALESRT-16900> - to show new stage labels on error message.
                        //Opp.addError('Stage cannot be changed to '+Opp.StageName+' from current stage'); //Find the custom label OppContRole_Error to change the message
                        Opp.addError('Stage cannot be changed to '+ oppStageMapping.get(Opp.StageName)+' from current stage'); //Find the custom label OppContRole_Error to change the message
                    }
                }
            }
        }
    }
    public static void syncStageSubstage(Map<Id, Opportunity> oldMap, Map<Id,Opportunity> newMap){
        if(!OpportunityInsertFlag){
            for(Opportunity opp : newMap.values()){
                if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId()){
                    if(oldMap.get(opp.Id).get('StageName')!=newMap.get(opp.Id).get('StageName') && oldMap.get(opp.Id).get('Substage__c')== newMap.get(opp.Id).get('Substage__c')){
                        if(opp.StageName == 'Identify')
                            opp.put('Substage__c','Qualification');
                        else if(opp.StageName == 'Validate')
                            opp.put('Substage__c','Intro Meeting');
                        else if(opp.StageName == 'Qualified')
                            opp.put('Substage__c','Evaluation');
                        else if(opp.StageName == 'Final Negotiation')
                            opp.put('Substage__c','Selected');
                        else if(opp.StageName == 'Closed Won')
                            opp.put('Substage__c','Sales Won');
                        else if(opp.StageName == 'Closed Lost')
                            opp.put('Substage__c','Closed Lost');
                        else if(opp.StageName == 'No Opportunity')
                            opp.put('Substage__c','No Opportunity');
                        else if(opp.StageName == 'Duplicate')
                            opp.put('Substage__c','Duplicate');                                                                                                                                                                        
                    }
                }
                //<T12123> starts here
                if(opp.RecordtypeId== Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId()){
                    if(oldMap.get(opp.Id).get('StageName')!=newMap.get(opp.Id).get('StageName') && oldMap.get(opp.Id).get('Substage__c')== newMap.get(opp.Id).get('Substage__c')){
                        if(opp.StageName == 'Renewal At-Risk')
                            opp.put('Substage__c','Open Renewal');
                        else if(opp.StageName == 'Initiated')
                            opp.put('Substage__c','Open Renewal');
                        else if(opp.StageName == 'Working')
                            opp.put('Substage__c','Open Renewal');
                        else if(opp.StageName == 'Committed')
                            opp.put('Substage__c','Open Renewal');
                        else if(opp.StageName == 'Closed Won')
                            opp.put('Substage__c','Sales Won');
                        else if(opp.StageName == 'Closed Lost')
                            opp.put('Substage__c','Closed Lost');
                        else if(opp.StageName == 'No Opportunity')
                            opp.put('Substage__c','No Opportunity');
                        else if(opp.StageName == 'Duplicate')
                            opp.put('Substage__c','Duplicate');                                                                                                                                                                        
                    }
                }
                //<T12123> ends here
            }
            
        }
    }                
    //-------------------------------------------------------------------------------------</T25>
    //-------------------------------------------------------------------------------------<T26>
    public static void addCompetitorRecords(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        List<Competitor_Relationship__c> competitorsToInsert = new List<Competitor_Relationship__c>();
        Map<String,Id> mapCompAccNumId = new Map<String,Id>();
        Map<Id,List<String>> mapOppComp = new Map<Id,List<String>>();
        Map<Id,List<String>> mapOppIncumbentComp = new Map<Id,List<String>>();
        Map<Id,List<String>> mapOppLostComp = new Map<Id,List<String>>();
        Map<Id,Set<String>> mapOppAllComp = new Map<Id,Set<String>>();
        Set<String> allComp = new Set<String>();
        
        for(Opportunity opp:newMap.values()){
            if(oldMap==null || (oldMap.get(opp.ID).get('Competitors__c') != newMap.get(opp.Id).get('Competitors__c') || oldMap.get(opp.ID).get('Incumbent_Competitors__c') != newMap.get(opp.Id).get('Incumbent_Competitors__c') || oldMap.get(opp.ID).get('Lost_To_Competitors__c') != newMap.get(opp.Id).get('Lost_To_Competitors__c'))){
                Set<String> allOppComp = new Set<String>();
                if(newMap.get(opp.Id).get('Competitors__c') != null){
                    mapOppComp.put(opp.Id,((String)opp.get('Competitors__c')).split(';'));
                    allOppComp.addAll(((String)opp.get('Competitors__c')).split(';'));
                }
                if(newMap.get(opp.Id).get('Incumbent_Competitors__c') != null){
                    mapOppIncumbentComp.put(opp.Id,((String)opp.get('Incumbent_Competitors__c')).split(';'));
                    allOppComp.addAll(((String)opp.get('Incumbent_Competitors__c')).split(';'));
                }
                if(newMap.get(opp.Id).get('Lost_To_Competitors__c') != null){
                    mapOppLostComp.put(opp.Id,((String)opp.get('Lost_To_Competitors__c')).split(';'));
                    allOppComp.addAll(((String)opp.get('Lost_To_Competitors__c')).split(';'));
                }
                mapOppAllComp.put(opp.Id,allOppComp);
                allComp.addAll(allOppComp);
            }
        }
        
        //System.debug('$$$...mapOppAllComp'+mapOppAllComp);
        //<T13075> Update start here
        if(allComp.size() >0 ){
            for(Account compAcc:[SELECT Id,New_Org_Account_Number__c,AccountNumber  FROM Account WHERE AccountNumber IN :allComp]){
                mapCompAccNumId.put((String)compAcc.AccountNumber,compAcc.Id);
            }
        }
        // <T13075> Update end here
        if(!mapOppAllComp.isEmpty()){
            for(Opportunity opp:newMap.values()){    
                for(String comp:mapOppAllComp.get(opp.Id)){
                    Competitor_Relationship__c compRel = new Competitor_Relationship__c();
                    compRel.put('Opportunity__c',opp.Id);
                    compRel.put('Competitor_Account__c',mapCompAccNumId.get(comp));
                    if(mapOppComp.get(opp.Id) != null && mapOppComp.get(opp.Id).contains(comp))
                        compRel.put('Competitor__c',true);
                    if(mapOppIncumbentComp.get(opp.Id) != null && mapOppIncumbentComp.get(opp.Id).contains(comp))
                        compRel.put('Incumbent__c',true);
                    if(mapOppLostComp.get(opp.Id) != null && mapOppLostComp.get(opp.Id).contains(comp))
                        compRel.put('Won__c',true); 
                    competitorsToInsert.add(compRel);                              
                }
            } 
        }   
        
        try{
            if(!mapOppAllComp.isEmpty()){
                List<Competitor_Relationship__c> lstExistingCompetitor = [SELECT Id,Competitor_Account__c,Opportunity__c FROM Competitor_Relationship__c WHERE Opportunity__c IN :mapOppAllComp.keySet()];
                if(lstExistingCompetitor!= null)
                    Database.DeleteResult[] lsrd = Database.delete(lstExistingCompetitor, false);
            }
            Database.SaveResult[] lsr = Database.insert(competitorsToInsert, false);
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in addCompetitorRecords on Opportunity',ex.getMessage());
        }    
    }
    
    //-------------------------------------------------------------------------------------</T26> 
    //
    //-------------------------------------------------------------------------------------<T28>
    public static void removeSalesTeamMembers(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        try{
            set<id> newOppIdsToRemoveSalesTeam = new Set<id>();
            for(Opportunity opp : newMap.values()) {
                if(opp.Remove_Ownership__c != oldMap.get(opp.Id).Remove_Ownership__c 
                   && opp.Remove_Ownership__c) {
                       newOppIdsToRemoveSalesTeam.add(opp.Id);
                   }
            }
            List<OpportunityTeamMember> listToDeleteOTM = new List<OpportunityTeamMember>([Select id, OpportunityId 
                                                                                           from OpportunityTeamMember 
                                                                                           where OpportunityId IN: newOppIdsToRemoveSalesTeam ]);
            If(!listToDeleteOTM.isEmpty() && listToDeleteOTM != Null) {
                Delete listToDeleteOTM;
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in removeSalesTeamMembers on Opportunity',ex.getMessage());
        }    
    }
    
    //-------------------------------------------------------------------------------------</T28>     
    
    /*
* If the Opportunity Territory is modified, update the Quote Line's field - End_Date_Localized__c 
* based on the Quote Line's Quote's Territory assignment
* @param parameter- newOpps - list of new opportunities
* @return return- void
* @throws exception-captures exception in a debug log
* <T13270> Commenting the method
*/
    
    /*static void updateQuoteLineItem(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Map<Id, SBQQ__QuoteLine__c> qleToUpdateMap = new Map<Id, SBQQ__QuoteLine__c>(); //Map of Quote Line records to be udpated
        Set<Id> oppIds = new Set<Id>(); //Gather all Opportunity Id's whose Territory has changed
        
        for(Opportunity opp : newMap.values()){
            if(opp.Territory2Id != oldMap.get(opp.Id).Territory2Id){
                //Gather all Opportunity Id's whose Territory has changed
                oppIds.add(opp.Id);
            }
        }
        
        //Query for Quote Lines whose related Quote's Opportunity was captured in oppIds
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Territory__c, End_Date_Localized__c, End_Date_Output_QL__c
                                                                                    FROM SBQQ__QuoteLine__c
                                                                                    WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c IN :oppIds]);
        
        for(SBQQ__QuoteLine__c qle : quoteLineMap.values()){
            if(qle.SBQQ__Quote__c != null){ //Check that the Quote Line has an associated Quote
                if(qle.SBQQ__Quote__r.Territory__c != null){ //Check that the Quote Line's Quote has an associated Territory           
                    //Assign End Date Localized format based on the Territory Name
                    
                    String territoryName = qle.SBQQ__Quote__r.Territory__c;
                    
                    /*--------------------------------------------------------------------------<T12736> - added as default else part
                    //Assign Date Format mm/dd/yyyy
                    //if(territoryName.contains('NA') || territoryName.contains('LATAM')){//<T44> Updated condition to use STARTSWITH instead of CONTAINS.Moved LATAM in below condition, to keep the conditions in synced with Quote / Quote Line Trigger logic.
                    if(territoryName.startsWith('NA')){
                        qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
                        GAM.CreateLogs('OpportunityTriggerHandler.updateQuoteLineItem', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
                        
                        qleToUpdateMap.put(qle.Id, qle);
                    }
                    //--------------------------------------------------------------------------<T12736/>
                    //Assign Date Format dd/mm/yyyy
                    //if(territoryName.contains('EA') ){ //<T44> Updated condition to use STARTSWITH instead of CONTAINS.
                    if(territoryName.startsWith('EA') || territoryName.startsWith('EA_S_LAT')){
                        qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.year();
                        GAM.CreateLogs('OpportunityTriggerHandler.updateQuoteLineItem', 'Territory contains EA. Assigning End Date Localized - ' + qle.End_Date_Localized__c);                        
                        qleToUpdateMap.put(qle.Id, qle);
                    }
                    
                    //Assign Date Format yyyy/mm/dd
                    else if(territoryName.startsWith('AP') || territoryName.startsWith('JP')){//changed the condition from contains('APJ') //<T27>
                        qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.year() + '/' + qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day();
                        GAM.CreateLogs('OpportunityTriggerHandler.updateQuoteLineItem', 'Territory contains APJ. Assigning End Date Localized - ' + qle.End_Date_Localized__c);                        
                        qleToUpdateMap.put(qle.Id, qle);
                    }else{//--------------------------------------------------------------------------<T12736>
                        qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
                        GAM.CreateLogs('OpportunityTriggerHandler.updateQuoteLineItem', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);                        
                        qleToUpdateMap.put(qle.Id, qle);                        
                    }//--------------------------------------------------------------------------<T12736/>
                } else{
                    //If the Quote's Territory is not populated, default End Date Localized to the format for Territory that contains 'NA'
                    qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
                    GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Quotes Territory is blank. Assigning End Date Localized based on NA format - ' + qle.End_Date_Localized__c);
                }
            }
        }
        
        //DML Update call on the Quote Line Map to update the field - End_Date_Localized__c 
        if(qleToUpdateMap.size() > 0 && qleToUpdateMap != null){
            try{
                globalApexManager.avoidRecursion('QuoteLineBeforeUpdate'); //Stop the QuoteLineBeforeUpdate Trigger from running to avoid recursion
                Database.SaveResult[] srList = Database.update(qleToUpdateMap.values(), true);
            } catch(Exception e){
                GAM.CreateLogs('QuoteLineTriggerHandler.handleAfterInsert', qleToUpdateMap.values(), 'qleToUpdateMap');
            }
        }        
        GAM.InsertDebugLogs();
    }*/
    
    /**
    * this method assigns a territory to Opportunity based on territories assigned to its related Account. 
    * if account has only 1 territory assigned, that is assigned to Opp. If it has more than 1, any one is assigned (since currently we don't have any assignment criteria/rules)
    * @param parameter- newOpps - list of new opportunities
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
    
    static void assignTerritory(List<Opportunity> newOpps){
        try{
            Set<Id> setAccountIds = new Set<Id>();
            Map<Id, Id> mapAccountToTerritoryId = new Map<Id, Id>();
            for(Opportunity opp : newOpps){
                /* <T03><T11>-------------------------------------------------------------------------------------------------------------------
                if((opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId())
                && opp.Type != OPP_SKIP_TYPE){ */
                //if(opp.Type != OPP_SKIP_TYPE && !opp.Remove_Ownership__c) {   //-----</T03>, </T28>, <T31/>:Enabling Territory assignment for Indirect Optys
                if(!opp.Remove_Ownership__c) {
                    setAccountIds.add(opp.AccountId);   
                }   
            }
            if(setAccountIds != null && !setAccountIds.isEmpty()){
                for(ObjectTerritory2Association objectTerritoryAssociation : [Select Territory2Id, ObjectId From ObjectTerritory2Association
                                                                              WHERE ObjectId IN :setAccountIds
                                                                              ORDER BY Territory2.Priority__c ASC]){
                                                                                  if(!mapAccountToTerritoryId.containsKey(objectTerritoryAssociation.ObjectId))
                                                                                      mapAccountToTerritoryId.put(objectTerritoryAssociation.ObjectId, objectTerritoryAssociation.Territory2Id);                                                                  
                                                                              }
                
                for(Opportunity opp : newOpps){
                    if(mapAccountToTerritoryId.containsKey(opp.AccountId) && mapAccountToTerritoryId.get(opp.AccountId) != NULL){
                        // assign a territory based on Account Territories
                        opp.Territory2Id =  mapAccountToTerritoryId.get(opp.AccountId);
                    }
                }
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'Exception in assignTerritory method',ex.getMessage());
        }       
    }
    
    /**
* this method assigns Sales Team Members to Opportunities based on the Territory. All members part of the Opportunity Territory are added as 
* sales team members on an Opportunity with the same role and Edit access.  
* @param parameter- newOpps - list of new Opportunities
* @return return- void
* @throws exception-captures exception in a debug log
*/
    
    static void addSalesTeamMembers(List<Opportunity> newOpps){
        
        try{
            Set<Id> setTerritoryIds = new Set<Id>();
            Map<Id,UserTerritory2Association> mapTerritoryToAccManager = new Map<Id,UserTerritory2Association>();
            List<OpportunityTeamMember> lstOppTeamMembers = new List<OpportunityTeamMember>();
            Set<Id> setExistingUserIds = new Set<Id>();
            Map<Id,String> createduserRoleMap = new Map<Id,String>();
            List<Id> oppsCreatedById = new List<Id>();
            
            for(Opportunity opp : newOpps){
                oppsCreatedById.add(opp.CreatedById);
                if((opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() || opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId()) && opp.Territory2Id != null){           
                    setTerritoryIds.add(opp.Territory2Id);
                }
            }            
            
            //<SALESRT-13870> : Added RoleInTerritory2 = 'SDR' to the query
            for(UserTerritory2Association createdUser:[SELECT RoleInTerritory2,UserId FROM UserTerritory2Association WHERE UserId IN :oppsCreatedById AND (RoleInTerritory2 = 'BDM' OR RoleInTerritory2 = 'CFR' OR RoleInTerritory2 = 'CSM' OR RoleInTerritory2 = 'SDR')]){
                createduserRoleMap.put(createdUser.UserId,createdUser.RoleInTerritory2);
            }
            
            if(setTerritoryIds!=null && !setTerritoryIds.isEmpty()){
                for(UserTerritory2Association userTerrAsso : [Select UserId, Territory2Id, RoleInTerritory2 FROM UserTerritory2Association WHERE Territory2Id IN :setTerritoryIds AND RoleInTerritory2 = 'Account Manager']){
                    mapTerritoryToAccManager.put(userTerrAsso.Territory2Id,userTerrAsso);
                }
            }
            
            // iterate through the list of new opportunities and add one sales team member for each user belonging to the territory
            // and copy the role. Access level for Sales Team Members is set to Edit. 
            for(Opportunity opp : newOpps){        
                
                List<Id> territoryMembers = new List<Id>();
                
                if(opp.Territory2Id != null && mapTerritoryToAccManager.containsKey(opp.Territory2Id) && mapTerritoryToAccManager.get(opp.Territory2Id) != null){
                    
                    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                    oppTeamMember.OpportunityId = opp.Id;
                    oppTeamMember.UserId = mapTerritoryToAccManager.get(opp.Territory2Id).UserId;
                    oppTeamMember.OpportunityAccessLevel = Label.Edit;
                    oppTeamMember.TeamMemberRole = mapTerritoryToAccManager.get(opp.Territory2Id).RoleInTerritory2;
                    lstOppTeamMembers.add(oppTeamMember);  
                }
                
                if(createduserRoleMap.containsKey(opp.CreatedById) && createduserRoleMap.get(opp.CreatedById) != null)
                {
                    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                    oppTeamMember.OpportunityId = opp.Id;
                    oppTeamMember.UserId = opp.CreatedById;
                    if(createduserRoleMap.get(opp.CreatedById) == 'CFR'){
                        oppTeamMember.TeamMemberRole = 'Cloud First Response'; 
                    }
                    else{
                        oppTeamMember.TeamMemberRole = createduserRoleMap.get(opp.CreatedById); 
                    }   
                    oppTeamMember.OpportunityAccessLevel = Label.Edit;
                    oppTeamMember.Driven_By__c = true;
                    lstOppTeamMembers.add(oppTeamMember);                    
                }
            }
            
            if(lstOppTeamMembers!=null && !lstOppTeamMembers.isEmpty())
                insert lstOppTeamMembers;
        }
        
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in addSalesTeamMembers',ex.getMessage());
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------------------------<T23>
    /**
* this method checks if the Owner of an Opportunity is being changed. If yes, change the access level
* of the previous owner to Read/Write.
* @param mapOld Map of Old Opportunities
* @param mapNew Map of New Opportunities
* @return void
* @throws exception captures exception in a debug log
*/
    public static void retainPrevOwnerEditAccess(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        
        List<OpportunityTeamMember> lstOppTeamMembers = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> existingOptyTeam =[SELECT OpportunityId,TeamMemberRole,UserId,Opportunity.OwnerId,Opportunity.CreatedById FROM OpportunityTeamMember WHERE OpportunityId IN :newMap.keySet()];
        try{
            
            for(OpportunityTeamMember member:existingOptyTeam){
                
                if(member.Opportunity.OwnerId != oldMap.get(member.OpportunityId).OwnerId){
                    member.OpportunityAccessLevel=Label.Edit;
                    lstOppTeamMembers.add(member);
                }
            }
            
            if(lstOppTeamMembers!=null && !lstOppTeamMembers.isEmpty())
                upsert lstOppTeamMembers;
        }    
        catch(Exception e){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in retainPrevOwnerEditAccess',e.getMessage());
        }
    }
    //-----------------------------------------------------------------------------------------------------------------------------------------------</T23>
    
    /**
* this method assigns new Contact Role to Opportunity   
* @param parameter- mapOld - map of old Opportunities
* @param parameter- mapNew - map of new Opportunities
* @return return- void
* @throws exception-captures exception in a debug log
*/
    
    /*static void addEndUser(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        try{
            Map<Id,OpportunityContactRole> oppIdToContactRoleMap = new Map<Id,OpportunityContactRole>();
            Set<Id> setOppId = new Set<Id>();
            Boolean contactRoleRepeatFlag = false;
            List<OpportunityContactRole> listOppContactRole;
            Map<Id,List<OpportunityContactRole>> OppIdToContactRoleListMap = new Map<Id,List<OpportunityContactRole>>();
            List<OpportunityContactRole> contactRoleToUpdateList = new List<OpportunityContactRole>();
            String endUser = Label.End_User;    
            
            for(Opportunity opp :mapNew.values()){
                if((mapOld != null && opp.End_User__c != mapOld.get(opp.Id).End_User__c)) {
                    setOppId.add(opp.Id);
                }
            }
            //fetching contact roles for all modified opportunities
            if(!setOppId.isEmpty()) {
                listOppContactRole = [SELECT Id, OpportunityId, ContactId, IsPrimary, Role
                                      FROM OpportunityContactRole WHERE OpportunityId IN :setOppId];
            }
            
            if(listOppContactRole != null && listOppContactRole.size() > 0) {
                for(OpportunityContactRole role :listOppContactRole) {
                    if(OppIdToContactRoleListMap.containsKey(role.OpportunityId))
                        OppIdToContactRoleListMap.get(role.OpportunityId).add(role);
                    else
                        OppIdToContactRoleListMap.put(role.OpportunityId, new List<OpportunityContactRole>{role});
                }
            }
            
            //Iterate throught the map of new opportunities and check if contact role already exist in opportunity. If not create new
            //contact role and assign it to opportunity else update the contact role
            for(Opportunity opp :mapNew.values()){
                contactRoleRepeatFlag = false;
                if( Trigger.isInsert || (mapOld != null && opp.End_User__c != mapOld.get(opp.Id).End_User__c)) {
                    if(OppIdToContactRoleListMap.containsKey(opp.Id) && OppIdToContactRoleListMap.get(opp.Id) != null) {
                        For(OpportunityContactRole role :OppIdToContactRoleListMap.get(opp.Id) ) {
                            if(role.ContactId !=null && opp.End_User__c != null && role.Role!=null && role.Role!='') {
                                if(role.ContactId == opp.End_User__c && role.Role == endUser) {
                                    contactRoleRepeatFlag = true;
                                    role.IsPrimary = true;
                                    oppIdToContactRoleMap.put(opp.Id, role);
                                    break;
                                }
                            }
                        }
                    }
                    if(!contactRoleRepeatFlag && opp.End_User__c != null) {
                        OpportunityContactRole oppContactRole = new OpportunityContactRole();
                        oppContactRole.OpportunityId=opp.Id;
                        oppContactRole.ContactId = opp.End_User__c;
                        oppContactRole.Role = endUser;
                        oppContactRole.IsPrimary = true;
                        oppIdToContactRoleMap.put(opp.Id, oppContactRole);
                    }
                }
            }
            if(oppIdToContactRoleMap.size() > 0){
                upsert oppIdToContactRoleMap.values();
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in addEndUser on Opportunity',ex.getMessage());
        }
    }*/
    
    /*
------------------------------------------------------------------------------< T01>
//Anil Solanki : Updated Existing Method conditions to run the logic only for Renewal Opportunity 
and only if there is no Forecastable Product added on the Opporutnity.
*/
    
            /**
        * this method captures modification done on 'Only for Integration Use' fields on Opportunity   
        * @param parameter- mapOld - map of old Opportunities
        * @param parameter- mapNew - map of new Opportunities
        * @return return- void
        * @throws exception-captures exception in a debug log
        */
    /*static void opportunityProductUpdate(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew){
        try{
            
            Map<id,List<OpportunityLineItem>> mapOppIdWiseLineItems = new Map<id,List<OpportunityLineItem>>();
            set<id> setOfOpportunityId = new set<id>();
            
            List<Opportunity> listCloudSubsOpp = new List<Opportunity>();
            List<Opportunity> listDaasSubsOpp = new List<Opportunity>();
            List<Opportunity> listPremPerpOpp = new List<Opportunity>();
            List<Opportunity> listPremSubsOpp = new List<Opportunity>();
            String productNameLabel = Label.Opportunity_Product_Name;
            List<String> lstproductName = productNameLabel.split('==');
            
            system.debug('***************new map size      '+ mapNew.values().size());
            for(Opportunity oppNew : mapNew.values()){
                setOfOpportunityId.add(oppNew.Id);
            }
            
            /*
------------------------------------------------------------------------------< T01>
//Anil Solanki : Getting Existing OpportunityLineItems on the opportunity in transaction
*/
            /*system.debug('***************Set of oppty IDS      '+ setOfOpportunityId);
            if(setOfOpportunityId.size() > 0){
                for(opportunity opp: [select id,Name,(select id,Name,Product2Id,Product2.Name,PricebookEntryId from OpportunityLineItems) from opportunity where Id IN :setOfOpportunityId ]){
                    mapOppIdWiseLineItems.put(opp.Id, opp.OpportunityLineItems);
                }
            }
            
            Boolean Flag = False;
            List<OpportunityLineItem> existingProducts ;
            List<String> ProductNames  ;
            Set<String> setProductNames = new Set<String>();
            setProductNames.addAll(lstproductName);
            
            for(Opportunity oppNew : mapNew.values()){
                
                ProductNames = new List<String>();
                existingProducts = new List<OpportunityLineItem>();
                if(mapOppIdWiseLineItems.containsKey(oppNew.Id)){
                    existingProducts.addAll(mapOppIdWiseLineItems.get(oppNew.Id));
                }
                
                for(OpportunityLineItem opprtunityProduct : existingProducts){
                    ProductNames.add(opprtunityProduct.Product2.Name);
                }
                
                if(ProductNames.size() > 0 && !ProductNames.IsEmpty()){
                    for(String oliName : ProductNames){
                        if(!setProductNames.contains(OLIName)){
                            flag = true;
                        }
                    }
                    
                }
                
                /*
------------------------------------------------------------------------------< T01>
//Anil Solanki : Added extra IF condition to run the logic only for Renewals
*/
                //Check if the Opportunity Record Type is 'Renewal Opportunity'.This logic should run only for Renewal Opportunities with no forecast product added.
                //if((oppNew.OrderableIn__c == NULL || oppNew.OrderableIn__c == '' ) && !flag){ //commenting this line<T06>
                //if(!flag){ //uncommenting this line<T06>
                    //checking if Integration feild is zero before updating the opty products record
                    //------------------------------------------------------------------------------------------------------------<T18>
                    /*if(((mapOld == null && oppNew.Cloud_Subscription__c != Null) || (mapOld != null && oppNew.Cloud_Subscription__c != mapOld.get(oppNew.Id).Cloud_Subscription__c))&& oppNew.Cloud_Subscription__c != 0){
                        listCloudSubsOpp.add(oppNew);
                    }
                    if(((mapOld == null && oppNew.DaaS_Subscription__c != Null) || (mapOld != null && oppNew.DaaS_Subscription__c != mapOld.get(oppNew.Id).DaaS_Subscription__c))&& oppNew.DaaS_Subscription__c != 0){
                        listDaasSubsOpp.add(oppNew);
                    }
                    if(((mapOld == null && oppNew.On_Prem_Perpetual__c != Null) || (mapOld != null && oppNew.On_Prem_Perpetual__c != mapOld.get(oppNew.Id).On_Prem_Perpetual__c))&& oppNew.On_Prem_Perpetual__c != 0){
                        listPremPerpOpp.add(oppNew);
                    }
                    if(((mapOld == null && oppNew.On_Prem_Subscription__c != Null) || (mapOld != null && oppNew.On_Prem_Subscription__c != mapOld.get(oppNew.Id).On_Prem_Subscription__c))&& oppNew.On_Prem_Subscription__c != 0){
                        listPremSubsOpp.add(oppNew);
                    }
                    //------------------------------------------------------------------------------------------------------------</T18>
                }
            }
            
            
            
            if(listCloudSubsOpp!=null && listCloudSubsOpp.size()>0){
                opportunityProductRecordUpdate(listCloudSubsOpp,lstproductName[1], lstproductName);
            }
            if(listDaasSubsOpp!=null && listDaasSubsOpp.size()>0){
                opportunityProductRecordUpdate(listDaasSubsOpp,lstproductName[0], lstproductName);
            }
            if(listPremPerpOpp!=null && listPremPerpOpp.size()>0){
                opportunityProductRecordUpdate(listPremPerpOpp,lstproductName[2], lstproductName);
            }
            if(listPremSubsOpp!=null && listPremSubsOpp.size()>0){
                opportunityProductRecordUpdate(listPremSubsOpp,lstproductName[3], lstproductName);
            }  
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in opportunityProductUpdate',ex.getMessage());
        }
    }*/
    
    /**
* this method updates respective records on Opportunity Product   
* @param parameter- listOpp - list of Opportunities
* @param parameter- oppLineItemName - Name of Opportunity product
* @return return- void
* @throws exception-captures exception in a debug log
*/
   /* static void opportunityProductRecordUpdate(List<Opportunity> listOpp, String oppLineItemName, List<String> lstproductName){
        
        try{
            Map<Id,Opportunity> mapOppById = new Map<Id,Opportunity>();
            Map<Id,OpportunityLineItem> mapLineItemByOppId = new Map<Id,OpportunityLineItem>();
            List<OpportunityLineItem> listOppLine = new List<OpportunityLineItem>();
            Set<Id> opptyPricebookID = new Set<id>();       //</T29>
            
            List<OpportunityLineItem> OLIlist = new List<OpportunitylineItem>();
            OpportunityLineItem oppLineItem2;          
            List<PricebookEntry> pbEntryList;
            Map<String,PricebookEntry> mapCurrencyToPBE = new Map<String,PricebookEntry>();
            
            for(Opportunity opp :listOpp){
                mapOppById.put(opp.Id, opp);
                opptyPricebookID.add(opp.Pricebook2Id);
            }
            if(oppLineItemName != null && oppLineItemName != '') {
                String str = '%' + oppLineItemName;
                //fetching Opportunity Line Item
                listOppLine = [SELECT Id, OpportunityId, Name, UnitPrice, Quantity 
                               FROM OpportunityLineItem 
                               WHERE OpportunityId IN :listOpp AND Name LIKE :str];
                
                for(OpportunityLineItem opp :listOppLine){
                    mapLineItemByOppId.put(opp.OpportunityId, opp);
                }
                //fetching Price Book Entry
                pbEntryList = [select id, name, Pricebook2Id, Product2Id, Product2.Name, CurrencyIsoCode from PricebookEntry WHERE Name=:oppLineItemName AND Pricebook2Id IN: opptyPricebookID]; //</T29>
                
                for(PricebookEntry pbe : pbEntryList) {
                    mapCurrencyToPBE.put(pbe.CurrencyIsoCode, pbe);
                }
            }
            
            //Iterate throught the map of new opportunities and check if Opportunity Line Item exist, update it. 
            //Else create a new Opportunity Line Item and associate it with Opportunity
            if(pbEntryList!=null && !pbEntryList.isEmpty() && lstproductName!=null && !lstproductName.isEmpty()) {
                for(Opportunity opp :mapOppById.values()){
                    //-----------------------------------------------------<T07>
                    String transactionType;
                    if(opp.Type == 'Renewal'){
                        transactionType = 'Renewal';
                    }else if(opp.Type == 'Upsell'){
                        transactionType = 'Upsell';
                    }else{
                        transactionType = 'New';
                    }
                    //-----------------------------------------------------</T07>
                    if( mapLineItemByOppId.containsKey(opp.Id) && mapLineItemByOppId.get(opp.Id).Name.contains(lstproductName[0]) && listOppLine.size() > 0 ){
                        mapLineItemByOppId.get(opp.Id).UnitPrice = opp.DaaS_Subscription__c/mapLineItemByOppId.get(opp.Id).Quantity;
                        OLIlist.add(mapLineItemByOppId.get(opp.Id));
                    }
                    else if(opp.DaaS_Subscription__c != null && oppLineItemName == lstproductName[0] && mapCurrencyToPBE.containsKey(opp.CurrencyIsoCode)) {
                        oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,Quantity = 1,PricebookEntryId = mapCurrencyToPBE.get(opp.CurrencyIsoCode).Id, UnitPrice = opp.DaaS_Subscription__c, Transaction_Type__c = transactionType);//<T07> Addded Transaction type
                        OLIlist.add(oppLineItem2);
                    }
                    else if( mapLineItemByOppId.containsKey(opp.Id) && mapLineItemByOppId.get(opp.Id).Name.contains(lstproductName[1]) && listOppLine.size() > 0 ){
                        mapLineItemByOppId.get(opp.Id).UnitPrice = opp.Cloud_Subscription__c/mapLineItemByOppId.get(opp.Id).Quantity;
                        OLIlist.add(mapLineItemByOppId.get(opp.Id));
                    }   
                    else if(opp.Cloud_Subscription__c != null && oppLineItemName == lstproductName[1] && mapCurrencyToPBE.containsKey(opp.CurrencyIsoCode)) {
                        oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,Quantity = 1,PricebookEntryId = mapCurrencyToPBE.get(opp.CurrencyIsoCode).Id, UnitPrice = opp.Cloud_Subscription__c, Transaction_Type__c = transactionType);//<T07> Addded Transaction type
                        OLIlist.add(oppLineItem2);
                    }
                    else if( mapLineItemByOppId.containsKey(opp.Id) && mapLineItemByOppId.get(opp.Id).Name.contains(lstproductName[2]) && listOppLine.size() > 0 ){
                        mapLineItemByOppId.get(opp.Id).UnitPrice = opp.On_Prem_Perpetual__c/mapLineItemByOppId.get(opp.Id).Quantity;
                        OLIlist.add(mapLineItemByOppId.get(opp.Id));
                    }
                    else if(opp.On_Prem_Perpetual__c != null && oppLineItemName == lstproductName[2] && mapCurrencyToPBE.containsKey(opp.CurrencyIsoCode)) {
                        oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,Quantity = 1,PricebookEntryId = mapCurrencyToPBE.get(opp.CurrencyIsoCode).Id,  UnitPrice = opp.On_Prem_Perpetual__c, Transaction_Type__c = transactionType);//<T07> Addded Transaction type
                        OLIlist.add(oppLineItem2);
                    }
                    else if( mapLineItemByOppId.containsKey(opp.Id) && mapLineItemByOppId.get(opp.Id).Name.contains(lstproductName[3]) && listOppLine.size() > 0 ){
                        mapLineItemByOppId.get(opp.Id).UnitPrice = opp.On_Prem_Subscription__c/mapLineItemByOppId.get(opp.Id).Quantity;
                        OLIlist.add(mapLineItemByOppId.get(opp.Id));
                    }
                    else if(opp.On_Prem_Subscription__c != null && oppLineItemName == lstproductName[3] && mapCurrencyToPBE.containsKey(opp.CurrencyIsoCode)) {
                        oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id,Quantity = 1,PricebookEntryId = mapCurrencyToPBE.get(opp.CurrencyIsoCode).Id, UnitPrice = opp.On_Prem_Subscription__c, Transaction_Type__c = transactionType);//<T07> Addded Transaction type
                        OLIlist.add(oppLineItem2);
                    }
                }
            }
            if(OLIlist!=null && OLIlist.size()>0)
                upsert OLIlist;         
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in opportunityProductRecordUpdate',ex.getMessage());
        }
    }*/
    
    /**
* Thejaswini Sattenapalli 14 August 2017
* this method updates sync/update secondary opportunity on hybird deal case 
* @param parameter- triggernew - list of Opportunities from trigger.new
* @return return- void
* @throws exception-captures exception in handleError method by create exception record in object
*/
    //<T20> 
    /*public static void syncToSecondaryOpportunity(List<opportunity> triggernew, Map<Id, Opportunity> triggerOldMap){
// create a set for store secondary opportynity Id 
set<Id> setOfSecondaryOppId = new set<Id>();
// create a map of opportunity Id [String] and secondary opportunity   
map<string,opportunity> mapIdWiseSecOpportunity = new map<String,opportunity>();
// play a for loop on trigger.new values   
for(opportunity oOpportunity : triggernew){
// check if related opp not equal to null and primary or secondary field is set to primary
// then add the Related_Opportunity__c [secondary opp Id] to the set       
if(oOpportunity.Related_Opportunity__c != null && oOpportunity.Primary_or_Secondary__c == 'Primary'){
setOfSecondaryOppId.add(oOpportunity.Related_Opportunity__c);
}
}
//---------------------------------<T05>
// play a for loop on opportunity where opportunity id in 'setOfSecondaryOppId' and stage not equal to 'No Opportunity'   
for(opportunity opp : [select id,Name,OrderableIn__c,External_ID__c,Old_Org_Opportunity_Number__c,Primary_or_Secondary__c,Related_Opportunity__c,RecordTypeId,Cloud_Subscription__c,DaaS_Subscription__c,On_Prem_Perpetual__c,On_Prem_Subscription__c from opportunity where StageName != 'No Opportunity' AND ID IN :setOfSecondaryOppId]){
// for(opportunity opp : [select id,Name,OrderableIn__c,External_ID__c,Old_Org_Opportunity_Number__c,Primary_or_Secondary__c,Related_Opportunity__c,RecordTypeId,Cloud_Subscription__c,DaaS_Subscription__c,On_Prem_Perpetual__c,On_Prem_Subscription__c,(select id from OpportunityLineItems) from opportunity WHERE ID IN :setOfSecondaryOppId ]){
//   if(opp.OpportunityLineItems.Size() > 0){
// put the values in map 
mapIdWiseSecOpportunity.put(opp.Id,opp);  
// }          
}
//-----------------------------</T05>
// create a list of opportunity type for update the secondary opportunity      
List<opportunity> lstOpportunityForUpdate = new List<opportunity>();  
// play a for loop on trigger.new opportunity list  
for(opportunity oOpportunity : triggernew){
// check if Related_Opportunity__c not equal to null and  Primary_or_Secondary__c is Primary
// and mapIdWiseSecOpportunity contains 'Related Opportunity Id' as a key
if(oOpportunity.Related_Opportunity__c != null &&
oOpportunity.Primary_or_Secondary__c == 'Primary' &&
mapIdWiseSecOpportunity.containsKey(oOpportunity.Related_Opportunity__c)){
// get the secondary Opportunity from map by Related_Opportunity__c Id  
opportunity secOpp = mapIdWiseSecOpportunity.get(oOpportunity.Related_Opportunity__c);
// clone the primary Opportunity fields for secondary opportunity  
opportunity cloneSecOpp = oOpportunity.clone(false, true, false, false);
// set the secondary opportunity id and secondary opportunity actual fields which should not be sync    
cloneSecOpp.Id = oOpportunity.Related_Opportunity__c;
cloneSecOpp.Name = secOpp.Name;                   
cloneSecOpp.OrderableIn__c = secOpp.OrderableIn__c;
cloneSecOpp.RecordTypeId = secOpp.RecordTypeId;
cloneSecOpp.Primary_or_Secondary__c = secOpp.Primary_or_Secondary__c;
cloneSecOpp.Related_Opportunity__c = secOpp.Related_Opportunity__c;
//update product family fields- start
cloneSecOpp.Cloud_Subscription__c = secOpp.Cloud_Subscription__c;
cloneSecOpp.DaaS_Subscription__c = secOpp.DaaS_Subscription__c;
cloneSecOpp.On_Prem_Perpetual__c = secOpp.On_Prem_Perpetual__c;
cloneSecOpp.On_Prem_Subscription__c = secOpp.On_Prem_Subscription__c;
//update product family fields- end
cloneSecOpp.External_ID__c = secOpp.External_ID__c;
cloneSecOpp.Old_Org_Opportunity_Number__c = secOpp.Old_Org_Opportunity_Number__c;
//----------------------------------------------------------------------- <T02>
cloneSecOpp.SBQQ__PrimaryQuote__c =  NULL;
//------------------------------------------------------------------------</T02>
lstOpportunityForUpdate.add(cloneSecOpp);
}  
}
// if 'lstOpportunityForUpdate' greater then 0 then update the lstOpportunityForUpdate 
// if exception came then store the exception to custom object by calling the handleError method   
if(lstOpportunityForUpdate.size() > 0){
Database.SaveResult[] updateSecOpp = Database.update(lstOpportunityForUpdate, false);
if(updateSecOpp.size()>0){
handleError(updateSecOpp);
} 
}  
}*
//</T20>
/**
* Thejaswini Sattenapalli 14 August 2017
* this method handel the exception for DML Operations
* @param parameter - saveResult - list of Database.Saveresult
* @return return- void
* @throws exception-N/A
*/
    
    public static void handleError(List<Database.Saveresult> saveResult){
        string error;
        for (Database.SaveResult sr : saveResult) {
            if (!sr.isSuccess()){
                
                for(Database.Error err : sr.getErrors()){
                    error = error + err.getMessage();
                }
            }
            
        } 
        GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'Error while saving: ' ,error);
    } 
    /*
------------------------------------------------------------------------------< T01>
//Deloitte : When Lead is converted to opportunity, process for PRM Start here 
------------------------------------------------------------------------------</T01>
*/    
    /**
* PRM: this method call method based on proper conditions to create partner relationship and related objects, 
* and perform the validations on lead conversion   
* @param parameter- mapOld - map of old Opportunities
* @param parameter- mapNew - map of new Opportunities
* @param parameter- triggerType - string to determine which trigger invoked the method
* @return return- void
*/
    static void PRMLeadConversion(Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew, List<Opportunity> lstNew, string triggerType){        
        set<Id> setOfOpportunityId = new set<Id>();
        set<Id> setOfLeadId = new set<Id>();
        set<Id> setOfLeadOpportunitIds = new set<Id>();//T16
        
        Boolean OpptyInsert = False;
        
        map<Id,opportunity> mapLeadIdWiseOppty = new map<Id,opportunity>();
        map<Id,Lead> mapLeadIdWiseLead = new map<Id,Lead>();
        
        List<Opportunity> listOppty = new List<Opportunity>();
        if(lstNew!=null && !lstNew.isEmpty())
        {
            listOppty.addAll(lstNew);
        }
        else
        {
            for(Opportunity oppNew: mapNew.values()) {
                listOppty.add(oppNew);
            }
        }
        String[] leadDetails;
        string leadRecordType;
        if(mapOld == null)
        {
            OpptyInsert = True;
        }
        if(listOppty!=null && !listOppty.isEmpty())
        {
            for(Opportunity oppNew: listOppty)
            {
                If(oppNew.Dev_Lead_Identifier__c != null)
                {
                    If(OpptyInsert == True || (OpptyInsert == False && oppNew.Dev_Lead_Identifier__c != mapOld.get(oppNew.Id).Dev_Lead_Identifier__c))
                    {
                        leadDetails = oppNew.Dev_Lead_Identifier__c.split(':');
                        
                        if(leadDetails[1]!=null)
                        {
                            leadRecordType = leadDetails[1];
                            
                            if(oppNew.Dev_Lead_Identifier__c !=NULL && leadRecordType =='Deal_Registration')
                            {
                                mapLeadIdWiseOppty.put(Id.valueOf(leadDetails[0]),oppNew);
                                setOfOpportunityId.add(oppNew.Id);
                                setOfLeadId.add(Id.valueOf(leadDetails[0]));
                            }
                            //----------------------------------<T16>
                            else if(oppNew.Dev_Lead_Identifier__c !=NULL && leadRecordType =='Lead')
                            {
                                setOfLeadOpportunitIds.add(oppNew.Id);  
                            }
                            //------------------------------------</T16>
                        }
                    }
                }
            }
        }
        
        If(setOfLeadId!=null && !setOfLeadId.isEmpty())
        {
             mapLeadIdWiseLead = fetchLeadDetails(setOfLeadId);
            //Lead is Converted to a new Opportunity here
            If(setOfOpportunityId!=null && !setOfOpportunityId.isEmpty() && mapLeadIdWiseOppty!=null && !mapLeadIdWiseOppty.isEmpty() 
               && mapLeadIdWiseLead!=null && !mapLeadIdWiseLead.isEmpty() && OpptyInsert == True && triggerType =='AfterInsert')
            {
                createPartnerRelationship(mapLeadIdWiseOppty,mapLeadIdWiseLead,True);
                // createOpptyPrdctFrmDealRegPrdct(setOfLeadId,setOfOpportunityId, OpptyInsert); //changed as a part of T30
                
                list<OpportunityTeamMember> OTMtoInsertList = PRMAddPartnerLeadOwnerToSalesTeam(setOfLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead);
                PRMAddPSMToSalesTeam(setOfLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead, OTMtoInsertList);
            }
            
            //Lead is Converted to an Existing Opportunity here
            Else If(setOfOpportunityId!=null && !setOfOpportunityId.isEmpty() && mapLeadIdWiseOppty!=null && !mapLeadIdWiseOppty.isEmpty() 
                    && mapLeadIdWiseLead!=null && !mapLeadIdWiseLead.isEmpty() && OpptyInsert == False && triggerType =='AfterUpdate')
            {
                createPartnerRelationship(mapLeadIdWiseOppty,mapLeadIdWiseLead,True);
                // createOpptyPrdctFrmDealRegPrdct(setOfLeadId,setOfOpportunityId, OpptyInsert);//changed as a part of T30
                
                set<Id> setOfOpptyTeamInsertLeadId = returnOpptyTeamToInsert(setOfLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead,'lead creator');
                list<OpportunityTeamMember> OTMtoInsertList = new list<OpportunityTeamMember>();
                if(setOfOpptyTeamInsertLeadId != null && !setOfOpptyTeamInsertLeadId.isEmpty())
                {
                    OTMtoInsertList = PRMAddPartnerLeadOwnerToSalesTeam(setOfOpptyTeamInsertLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead);
                }
                set<Id> setOfOpptyTeamPSMInsertLeadId = returnOpptyTeamToInsert(setOfLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead,'PSM');
                if(setOfOpptyTeamPSMInsertLeadId != null && !setOfOpptyTeamPSMInsertLeadId.isEmpty())
                {
                    PRMAddPSMToSalesTeam(setOfOpptyTeamPSMInsertLeadId, setOfOpportunityId, mapLeadIdWiseOppty, mapLeadIdWiseLead, OTMtoInsertList);
                }
            }
            
            //When lead is converted set the record type of opportunity here
            Else If(mapLeadIdWiseOppty!=null && !mapLeadIdWiseOppty.isEmpty() 
                    && mapLeadIdWiseLead!=null && !mapLeadIdWiseLead.isEmpty() && OpptyInsert == True && triggerType =='BeforeInsert')
            {
                PRMSetOpptyVal(setOfLeadId, mapLeadIdWiseLead, mapLeadIdWiseOppty);
            }
        }
        if(setOfOpportunityId!=null && !setOfOpportunityId.isEmpty())
        {
            setOpptyDevFieldNull(setOfOpportunityId);
        }
        //----------------------------------<T16>
        if(setOfLeadOpportunitIds!=null && !setOfLeadOpportunitIds.isEmpty())
        {
            setOpptyDevFieldNull(setOfLeadOpportunitIds);
        }
        //----------------------------------</T16>
    }
    
    /**
* PRM: this method sets Opportunity record type and other values on lead conversion.
* @param parameter- setOfLeadId - set of Lead ID
* @param parameter- mapLeadIdWiseLead - map of Lead ID with Lead
* @param parameter- mapLeadIdWiseOppty - map of Lead ID with Opportunity
* @return return- void
*/
    static void PRMSetOpptyVal(set<Id> setOfLeadId, Map<Id,Lead> mapLeadIdWiseLead, map<Id,opportunity> mapLeadIdWiseOppty){
        
        List<Opportunity> opptyToUpdate = new List<Opportunity>();
        Map<String,Id> mapOpptyRecordTypeId = recordTypeMap('Opportunity');
        If(mapOpptyRecordTypeId!=null && !mapOpptyRecordTypeId.isEmpty())
        {
            for(Id lead: setOfLeadId)
            {
                //mapLeadIdWiseOppty.get(lead).StageName = 'Validate';
                mapLeadIdWiseOppty.get(lead).put('Substage__c','Intro Meeting');
                mapLeadIdWiseOppty.get(lead).OwnerId = UserInfo.getUserId();
                
                if(null !=  mapLeadIdWiseLead.get(lead).Primary_Role_in_Sale__c && mapLeadIdWiseLead.get(lead).Primary_Role_in_Sale__c.equalsIgnoreCase('Partner Sourced/Partner Driven'))
                {
                    mapLeadIdWiseOppty.get(lead).RecordTypeId = mapOpptyRecordTypeId.get('Channel Opportunity');
                    mapLeadIdWiseOppty.get(lead).Type = 'Indirect';
                }
                else
                {
                    mapLeadIdWiseOppty.get(lead).RecordTypeId = mapOpptyRecordTypeId.get('New Sales Opportunity');
                    mapLeadIdWiseOppty.get(lead).Type = 'Direct';
                }
                //<T56>
                //Added for SALESRT-13090 : Populate RTM Field to Reseller/Distributor when 'Deal Registration Type' = "Resell" 
                if(mapLeadIdWiseLead.get(lead).Deal_Registration_Type__c == Label.PRM_Deal_Reg_Type_Resell_Value){
                    mapLeadIdWiseOppty.get(lead).Route_To_Market__c = Label.ResellerDistributor;
                    mapLeadIdWiseOppty.get(lead).Detail_RTM__c = '';
                }
            }
        }
    }
    /**
* PRM: this method is used to insert list of Oppty sales team
* @param parameter- OTMtoInsertList - List of Oppty team member to insert.
* @throws exception-captures exception in a debug log
*/
    static void PRMInsertOpptyTeam(List<OpportunityTeamMember> OTMtoInsertList){
        if(OTMtoInsertList != null && !OTMtoInsertList.isEmpty() && Schema.getGlobalDescribe().get('OpportunityTeamMember').getDescribe().isCreateable())
        {
            try
            {
                insert OTMtoInsertList;
            }
            catch (System.DmlException e) 
            {                
                GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in PRMInsetOpptyTeam',e.getMessage());
            }
        }
    }
    /**
* PRM: this method is used to add lead creator user to Oppty sales team
* @param parameter- setOfLeadId - set of lead ID
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @param parameter- mapLeadIdWiseOppty - Map of lead Id and oppty
* @param parameter- mapLeadIdWiseLead - Map of lead Id and lead
* @return return- OTMtoInsertList - List of Oppty team member to insert.
* @throws exception-captures exception in a debug log
*/
    static list<OpportunityTeamMember> PRMAddPartnerLeadOwnerToSalesTeam(set<Id> setOfLeadId, set<Id> setOfOpportunityId, map<Id,opportunity> mapLeadIdWiseOppty, Map<Id,Lead> mapLeadIdWiseLead){
        Map<Id,String> mapLeadIdWisePAType = fetchLeadPartnerAccountDetails(setOfLeadId);
        list<OpportunityTeamMember> OTMtoInsertList = new list<OpportunityTeamMember>();
        for(Id leadId:setOfLeadId)
        {
            Id PartnerAccId = mapLeadIdWiseLead.get(leadId).Partner_Account__c;     //T22
            if(PartnerAccId != null)
            {
                Id Opp =  mapLeadIdWiseOppty.get(leadId).Id;
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.opportunityid = opp;
                //Inorder for the opportunity to be editable these conditions must be satisfied.
                //US-2264, US-2250
                if((mapLeadIdWisePAType.get(leadId) == 'Software Reseller' 
                    || mapLeadIdWisePAType.get(leadId) == 'Software Reseller & Systems Integrator'
                    || mapLeadIdWisePAType.get(leadId) == 'Distributor') && (mapLeadIdWiseLead.get(leadId).Solicitation_RFP_or_Public_Tender__c == False)
                   && mapLeadIdWiseLead.get(leadId).Primary_Role_in_Sale__c.equalsIgnoreCase('Partner Sourced/Partner Driven'))
                {
                    otm.OpportunityAccessLevel = 'Edit';
                }
                else
                {
                    otm.OpportunityAccessLevel = 'Read';
                }
                otm.TeamMemberRole = 'Partner';
                otm.UserId = mapLeadIdWiseLead.get(leadID).CreatedById;
                OTMtoInsertList.add(otm);
            }
        }
        return OTMtoInsertList;
    }
    /**
* PRM: this method is used to add PSM user to Oppty sales team
* @param parameter- setOfLeadId - set of lead ID
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @param parameter- mapLeadIdWiseOppty - Map of lead Id and oppty
* @param parameter- mapLeadIdWiseLead - Map of lead Id and lead
* @param parameter - OTMtoInsertList - List of Oppty team member to insert.
* @return return- OTMtoInsertList - List of Oppty team member to insert.
* @throws exception-captures exception in a debug log
*/
    static void PRMAddPSMToSalesTeam(set<Id> setOfLeadId, set<Id> setOfOpportunityId, map<Id,opportunity> mapLeadIdWiseOppty, Map<Id,Lead> mapLeadIdWiseLead, list<OpportunityTeamMember> OTMtoInsertList){
        for(Id leadId:setOfLeadId)
        {
            if(mapLeadIdWiseLead.get(leadID).PSM__c != null)
            {
                Id Opp =  mapLeadIdWiseOppty.get(leadId).Id;
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.opportunityid = opp;
                otm.OpportunityAccessLevel = 'Edit';
                otm.TeamMemberRole = 'PSM';
                otm.UserId = mapLeadIdWiseLead.get(leadID).PSM__c;
                OTMtoInsertList.add(otm);
            }
        }
        PRMInsertOpptyTeam(OTMtoInsertList);
    }
    
    /**
* PRM: this method is used to check if the PSM user or Lead Creator user are already added to opportunity
* and return lead Id if they are not added. This is to avoid adding duplicate oppty sales team members
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @return return- setOfLeadIdToInsertOpptyTeam - set of lead ID, whose users can be added to sales team
* @throws exception-captures exception in a debug log
*/
    static set<Id> returnOpptyTeamToInsert(set<Id> setOfLeadId, set<Id> setOfOpportunityId,map<Id,opportunity> mapLeadIdWiseOppty, Map<Id,Lead> mapLeadIdWiseLead, string forUser){
        set<Id> setOfLeadIdToInsertOpptyTeam = new set<Id>();
        Map<Id,list<OpportunityTeamMember>> mapOppIdWiseOppTeam = fetchCurrentOpptySalesTeamDeatils(setOfOpportunityId);
        
        for(Id lId : setOfLeadId )
        {
            
            Id leadCreator = mapLeadIdWiseLead.get(lId).CreatedById;
            Id leadPSM = mapLeadIdWiseLead.get(lId).PSM__c;
            Id PartnerAccId = mapLeadIdWiseLead.get(lId).Partner_Account__c;       //T22
            Id OpptyId = mapLeadIdWiseLead.get(lId).ConvertedOpportunityId;
            
            if(forUser == 'lead creator' && PartnerAccId !=null)
            {
                if(mapOppIdWiseOppTeam.get(OpptyId) != null)
                {
                    for(OpportunityTeamMember optyTeamMembr : mapOppIdWiseOppTeam.get(OpptyId))
                    {
                        if(leadCreator != optyTeamMembr.UserId)
                        {
                            setOfLeadIdToInsertOpptyTeam.add(lId);
                        }
                    }
                }
                else
                {
                    setOfLeadIdToInsertOpptyTeam.add(lId);
                }
            }
            else if(forUser == 'PSM')
            {
                if(mapOppIdWiseOppTeam.get(OpptyId) != null)
                {
                    for(OpportunityTeamMember optyTeamMembr : mapOppIdWiseOppTeam.get(OpptyId))
                    {
                        if(leadPSM != optyTeamMembr.UserId)
                        {
                            setOfLeadIdToInsertOpptyTeam.add(lId);
                        }
                    }
                }
                else
                {
                    setOfLeadIdToInsertOpptyTeam.add(lId);
                }
            }
        }
        
        return setOfLeadIdToInsertOpptyTeam;
    }
    /**
* PRM: this method is used to fetch Opportunity sales team records details.
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @return return- mapOppIdWiseOppTeam - Map of Oppty Id and Oppty sales team
* @throws exception-captures exception in a debug log
*/
    static Map<Id,list<OpportunityTeamMember>> fetchCurrentOpptySalesTeamDeatils(set<Id> setOfOpportunityId){
        Map<Id,list<OpportunityTeamMember>> mapOppIdWiseOppTeam = new map<Id,list<OpportunityTeamMember>>();
        try
        {
            list<OpportunityTeamMember> OppTeamDetails =  new list<OpportunityTeamMember>();
            
            if(setOfOpportunityId != null && !setOfOpportunityId.isEmpty())
            {  
                for(opportunity opp: [Select Id,(Select UserId From OpportunityTeamMembers) 
                                      From Opportunity Where Id In :setOfOpportunityId])
                {
                    mapOppIdWiseOppTeam.put(opp.Id,opp.OpportunityTeamMembers);
                }  
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in fetchCurrentOpptySalesTeamDeatils',ex.getMessage());
        }
        return mapOppIdWiseOppTeam;
    }
    
    /**
* PRM: this method is used to fetch Lead Partner Account record details.
* @param parameter- setOfLeadId - set of Lead ID
* @return return- mapLeadIdWisePAType - Map of Lead Id and Partner Account record
* @throws exception-captures exception in a debug log
*/
    static Map<Id,String> fetchLeadPartnerAccountDetails(set<Id> setLeadId){
        Map<Id,String> mapLeadIdWisePAType = new map<Id,String>();
        Map<Id,Account> mapAccIdWisePAType = new map<Id,Account>();
        set<Id> setLeadPartnerId = new set<Id>();      
        try{    
            if(setLeadId != null && !setLeadId.isEmpty())
            {  
                Map<Id,Lead> mapLeadIdWiseLead = fetchLeadDetails(setLeadId);
                for(Lead nl:mapLeadIdWiseLead.values())
                {
                    setLeadPartnerId.add(nl.Partner_Account__c);      //T22
                }
                for(Account Acc: [Select Id,Partner_Type__c From Account Where ID In : setLeadPartnerId ])
                {
                    mapAccIdWisePAType.put(Acc.ID,Acc);
                }
                for(Lead nl:mapLeadIdWiseLead.values())
                {
                    //T22
                    if(mapAccIdWisePAType.get(nl.Partner_Account__c) != null )      
                    {
                        mapLeadIdWisePAType.put(nl.Id,mapAccIdWisePAType.get(nl.Partner_Account__c).Partner_Type__c);
                    }
                }
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in fetchLeadPartnerAccountDetails',ex.getMessage());
        }
        return mapLeadIdWisePAType;
    }
    /**
* PRM: this method is used to fetch Lead record details.
* @param parameter- setOfLeadId - set of Lead ID
* @return return- mapLeadIdWiseLead - Map of Lead Id and Lead record
* @throws exception-captures exception in a debug log
*/
    static Map<Id,Lead> fetchLeadDetails(set<Id> setLeadId){
        Map<Id,Lead> mapLeadIdWiseLead = new map<Id,Lead>();
        try
        {
            list<Lead> listLeadDetails =  new list<Lead>();
            
            if(setLeadId != null && !setLeadId.isEmpty())
            {  
                //T22
               listLeadDetails = [SELECT Id,Partner_Campaign_Code__c,Role_of_Distributor__c,Partner_Account__c,
                                      Deal_Registration_Type__c,PSM__c,CreatedById,Solicitation_RFP_or_Public_Tender__c, 
                                      Reseller_SI_Partner__c,Deal_Registration_Name__c,Distributor__c,
                                      IsConverted,ConvertedOpportunityId,Primary_Role_in_Sale__c
                                      FROM Lead 
                                      WHERE Lead.Id IN : setLeadId];
            }
            for(Lead newLead : listLeadDetails){
                mapLeadIdWiseLead.put(newLead.Id,newLead);
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in fetchLeadDetails',ex.getMessage());
        }
        return mapLeadIdWiseLead;
    }
    
    /**
* PRM: this re-usable PRM method used to fetch record type of objects.
* @param parameter- obj - name of object
* @return return- recTypeNameWithIdMap - Map of record type name and ID
* @throws exception-N/A
*/
    static Map<String,Id> recordTypeMap(string obj){
        Map<String,Id> recTypeNameWithIdMap=new Map<String,Id>();
        if(obj!= null){
            for(Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()){
                recTypeNameWithIdMap.put(recInfo.getName(),recInfo.getRecordTypeId());
            }
        }
        return recTypeNameWithIdMap;
    } 
    
    /**
* PRM: this method is used to fetch Lead product record details.
* @param parameter- setOfLeadId - set of Lead ID
* @return return- mapLeadIdWiseLead - Map of Lead Id and Lead record
* @throws exception-captures exception in a debug log
*/
    /*
    static set<Id> fetchLeadProductDetails(set<Id> setLeadId){
        set<Id> setLeadPrdctId =  new set<Id>();
        if(setLeadId != null && !setLeadId.isEmpty())
        {
            for(Deal_Registration_Products__c drp : [SELECT Product__c FROM Deal_Registration_Products__c WHERE Lead__c In : setLeadId])
            {
                setLeadPrdctId.add(drp.Product__c);
            }
        }
        return setLeadPrdctId;
    }
    */
    /**
* PRM: this method is used to reset the Dev Lead Identifier field in Opportunity,
* Once the lead conversion process is completed.
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @throws exception-captures exception in a debug log
*/
    @future
    public static void setOpptyDevFieldNull(set<Id> setOfOpportunityId){
        try
        {
            list<Opportunity> newOpptyUpdateList = new list<Opportunity>();
            
            for(Id opp: setOfOpportunityId)
            {
                Opportunity opptyUpdate = new Opportunity();
                opptyUpdate.Id = opp;
                opptyUpdate.Dev_Lead_Identifier__c = null;
                
                newOpptyUpdateList.add(opptyUpdate);
            }
            if(newOpptyUpdateList != null && newOpptyUpdateList.size()>0 &&
               Schema.getGlobalDescribe().get('Opportunity').getDescribe().isUpdateable()){
                   Database.SaveResult[] OpptyUpdateList = Database.Update(newOpptyUpdateList, false);
                   if(OpptyUpdateList.size()>0){
                       handleError(OpptyUpdateList);
                   }
               }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in setOpptyDevFieldNull',ex.getMessage());
        }
    }
    
    /**
* PRM: this method is used to fetch opportunity product details.
* @param parameter- setOfOpportunityId - set of Opportunity ID
* @return- mapOpptyIdWithPrdct - map of oppty Id with Oppty products
* @throws exception-n/a
*/
    /*
    static set<Id> fetchOpptyProductDetails(set<Id> setOfOpportunityId){
        set<Id> setOpptyPrdctId =  new set<Id>();
        if(setOfOpportunityId != null && !setOfOpportunityId.isEmpty())
        {  
            for(OpportunityLineItem oli :   [SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId In : setOfOpportunityId])
            {
                setOpptyPrdctId.add(oli.Product2Id);
            }
        }
        return setOpptyPrdctId;
    }
    */
    /**
* PRM: This method checks if lead is of type: Resell and tagged to an existing Opportunity, 
* then the lead cannot be converted to this opportunity
* @param parameter- mapLeadIdWiseOppty - map of Lead Id and Opportunity
* @param parameter- mapLeadIdWiseLead -  map of Lead Id and Lead
* @throws exception-captures exception in a Exception log record
*/
    public static void validateOppty(Map<Id,Opportunity> mapLeadIdWiseOppty,Map<Id,Lead> mapLeadIdWiseLead){
        //set of Opportunity Id
        set<Id> oppSet = new Set<Id>();
        //set or Opportunity Ids that cannot be tagged to the Lead
        set<Id> errorOppSet = new Set<Id>();
        
        For(Lead L: mapLeadIdWiseLead.values()){
            //Fetch the Opportunity Id for Resell type Lead
            if(null != L.Deal_Registration_Type__c && L.Deal_Registration_Type__c.equalsIgnoreCase('Resell'))
            {
                //populate oppSet
                oppSet.add(mapLeadIdWiseOppty.get(L.id).Id);
            }
        }
        
        //check if the Opportunity has existing Partner Relationship
        for(Opportunity opp : [select id,Solicitation_RFP_or_Public_Tender__c,(select id,Partner_Role__c from Partner_Relationships__r) from Opportunity where id in :oppSet])
        {
            //check if opp is not RFP
            if(null != opp && null != opp.Partner_Relationships__r && !opp.Partner_Relationships__r.isEmpty() && opp.Solicitation_RFP_or_Public_Tender__c !=  TRUE)
            {
                for(Partner_Relationship__c oPrtnrRel : opp.Partner_Relationships__r)
                {
                    //check if partner Role is Resell
                    if(null != oPrtnrRel.Partner_Role__c && (oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_Resell_Fulfillment_Value) || oPrtnrRel.Partner_Role__c.equalsIgnoreCase(label.PRM_Partner_Role_One_Time_Resell_Value)))
                    {
                        errorOppSet.add(opp.id);
                    }
                }
            }
        }
        For(Lead L: mapLeadIdWiseLead.values()){
            //If opportunity has existing Partner Relationship with type: Resell/Resell - Fulfillment, throw error
            if(!errorOppSet.isEmpty() && errorOppSet.contains(mapLeadIdWiseOppty.get(L.id).Id))
            {
                Opportunity currentOpportunity  = mapLeadIdWiseOppty.get(L.id);
                currentOpportunity.addError('A reseller partner already exists with this opportunity');
            }
        }
    }
    
    /**
* PRM: this method is used to create partner relationship,
* when a lead is converted to an opportunity
* @param parameter- mapLeadIdWiseOppty - Map of Lead Id and Opportunity record
* @param parameter- mapLeadIdWiseLead - Map of Lead Id and Lead record
* @param parameter- isNew - Boolean value to denote opportunity is insert/update.
* @throws exception-captures exception in a debug log
*/    
    public static void createPartnerRelationship(Map<Id,Opportunity> mapLeadIdWiseOppty,Map<Id,Lead> mapLeadIdWiseLead,boolean isNew){
        
        //Map of Partner Relationship Id and Custom Validation error message if any on Partner Relationship
        Map<Id,String> errorOppMap = new Map<Id,String>();
        //set of Partner Relationship Id to be inserted
        set<Partner_Relationship__c> setPRList=new set<Partner_Relationship__c>();
        try
        {
            
            //checks if lead is of type: Resell and is tagged to an existing Opportunity with multiple Resell Opportunity Partners
            if(null != mapLeadIdWiseLead && !mapLeadIdWiseLead.isEmpty())
                validateOppty(mapLeadIdWiseOppty,mapLeadIdWiseLead);
            
            for(Id Lead: mapLeadIdWiseOppty.keySet())
            {
                Partner_Relationship__c newPR = new Partner_Relationship__c();
                newPR.Opportunity__c = mapLeadIdWiseOppty.get(Lead).Id;
                newPR.DEV_PRM_IsConverted__c = TRUE;
                newPR.Partner_Campaign_Code__c  = mapLeadIdWiseLead.get(Lead).Partner_Campaign_Code__c ;
                //------------------------------------------------------------------------------<T09>
                        newPR.Deal_Registration__c = mapLeadIdWiseLead.get(Lead).Id;
                //------------------------------------------------------------------------------</T09>
                //if DR type is Resell, create 2 partner relationships
                if(null != mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c && mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c == 'Resell')
                {
                    if(mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c !=null)
                    {
                        newPR.Partner_Account__c = mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c;
                        newPR.Partner_Role__c = 'Resell';
                        
                        //while 2 partner relationship creation, Partner_Sourced__c to be set for resell opty only 
                        //updated the condition for Resell deals. Partner Sourced Yes: If DR's Primary Role in Sale is "Partner //Sourced/Partner Driven" or "Partner Sourced/Informatica Assists" and No : If DR's Primary Role in Sales is //"Informatica Sourced/Partner Assists" or "Fulfillment"
                        //------------------------------------------------------------------------------<T10>
                        if(null != mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c && ( mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c == 'Partner Sourced/Partner Driven' || mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c == 'Partner Sourced/Informatica Field Assists'))
                            //------------------------------------------------------------------------------</T10>
                        {
                            newPR.Partner_Sourced__c = 'Yes';
                        }
                        else
                        {
                            newPR.Partner_Sourced__c = 'No';
                            newPR.New_Logo__c = 'No';
                        }
                    }
                    //Check if we need to create a secondary partner relationship
                    if(mapLeadIdWiseLead.get(Lead).Distributor__c !=null)
                    {
                        Partner_Relationship__c newSecPR = newPR.clone();
                        newSecPR.Partner_Account__c = mapLeadIdWiseLead.get(Lead).Distributor__c;
                        newSecPR.Partner_Role__c = 'Distributor';
                        newSecPR.Partner_Sourced__c = 'No';
                        newSecPR.New_Logo__c = 'No';
                        setPRList.add(newSecPR);    
                    }
                }
                else if(null != mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c && mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c == 'Referral')
                {
                    if(mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c !=null)
                    {
                        newPR.Partner_Account__c = mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c;
                        newPR.Partner_Role__c = 'Referral';
                        //------------------------------------------------------------------------------<T09>
                        newPR.Deal_Registration__c = mapLeadIdWiseLead.get(Lead).Id;
                        //------------------------------------------------------------------------------</T09>
                        //updated the condition for Referral deals . Partner Sourced Yes: If DR's Primary Role in Sale is "Partner //Sourced (Referred to Informatica)" and No: If DR's Primary Role in Sale is "Informatica Sales Sourced/Partner //Assists"
                        //------------------------------------------------------------------------------<T10>
                        if(null != mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c && mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c == 'Partner Sourced (Referred to Informatica)')
                            //------------------------------------------------------------------------------<T10>
                        {
                            newPR.Partner_Sourced__c = 'Yes';
                        }
                        else
                        {
                            newPR.Partner_Sourced__c = 'No';
                            newPR.New_Logo__c = 'No';
                        }
                    }
                }
                //-------------------------T32--------------------------------------------
                //Partner Sourced Yes: If DR's Primary Role in Sale is "Partner //Sourced (Referred to Informatica)" and No: If DR's Primary Role in Sale is "Informatica Sales Sourced/Partner //Assists"
                else if(null != mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c && mapLeadIdWiseLead.get(Lead).Deal_Registration_Type__c == 'Ecosystem')
                {
                    if(mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c !=null)
                    {
                        newPR.Partner_Account__c = mapLeadIdWiseLead.get(Lead).Reseller_SI_Partner__c;
                        newPR.Partner_Role__c = 'Ecosystem';                        
                        newPR.Deal_Registration__c = mapLeadIdWiseLead.get(Lead).Id;                                                                     
                        if(null != mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c && mapLeadIdWiseLead.get(Lead).Primary_Role_in_Sale__c == 'Partner Sourced (Referred to Informatica)')
                        {
                            newPR.Partner_Sourced__c = 'Yes';
                        }
                        else
                        {
                            newPR.Partner_Sourced__c = 'No';
                            newPR.New_Logo__c = 'No';
                        }
                    }
                }                
                //-------------------------T32--------------------------------------------
        //PRMRT 1050 - Added the below if condition
                //<T55> If the Distributor chooses 1-Tier Role, Opportunity created will have 1 Partner Relationship for Distributor                   
                if(mapLeadIdWiseLead.get(Lead).Role_of_Distributor__c != label.PRM_DealRegistration_1TierReseller){
          setPRList.add(newPR);
        }
            }
            
            if(setPRList!=null && !setPRList.isEmpty())
            {
                list<Partner_Relationship__c> insertPRList=new list<Partner_Relationship__c>(setPRList);
                //insert insertPRList;
                Database.SaveResult[] results = Database.insert(insertPRList, false);
                
                //if there are any validation rules on Partner Relationship, do not create new Partner Relationship
                for(integer i=0; i < insertPRList.size(); i++)
                {
                    Database.SaveResult result = results[i];
                    if (!result.isSuccess()) {
                        for(Database.Error err : result.getErrors()) {
                            if(String.valueOf(err.getStatusCode()).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                            {
                                errorOppMap.put(insertPRList[i].Opportunity__c,err.getMessage());
                            }
                            if(String.valueOf(err.getStatusCode()).contains('FIELD_FILTER_VALIDATION_EXCEPTION')) //T34
                            {
                                errorOppMap.put(insertPRList[i].Opportunity__c,Label.PRM_DR_Conversion_on_Inactive_Acc);
                            }
                        }
                    }
                }
            }
            //throw the validation error of partner relationship if any
            For(Lead L: mapLeadIdWiseLead.values()){
                if(!errorOppMap.isEmpty() && null != errorOppMap.get(mapLeadIdWiseOppty.get(L.id).Id))
                {
                    Opportunity currentOpportunity  = mapLeadIdWiseOppty.get(L.id);
                    currentOpportunity.addError('Partner Relationship creation failed due to validation exception: '+errorOppMap.get(mapLeadIdWiseOppty.get(L.id).Id));
                }
                
            }
        }
        catch(Exception ex){
            GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in addSalesTeamMembers',ex.getMessage());
        }
    }
    
    /**
* PRM: this method is used to create opportunity products from lead products,
* when a lead is converted to an opportunity
* @param parameter- setLeadId - Set of Lead Id
* @param parameter- setOfOpptyId - Set of Opportunity Id
* @param parameter- OpptyInsert - Boolean value denote insert/update
* @throws exception-captures exception in a debug log
*/  //changed as a part of T30
    /*public static void createOpptyPrdctFrmDealRegPrdct(set<Id> setLeadId, set<Id> setOfOpptyId, Boolean OpptyInsert){
set<id> setOfOpportunityId = new set<id>();
set<string> setOFOpptyCurrency = new set<string>();
//Pricebook2 stdPriceBook;   //</T21>
list<Opportunity> PROpportunity =  new list<Opportunity>();
//fetch Lead product details.
set<Id> setLeadProductId =  fetchLeadProductDetails(setLeadId);
//If opportunity is updated, check if there are duplicate opportunity products being added here and then remove duplicate.
if(OpptyInsert == false && setLeadProductId != null && !setLeadProductId.isEmpty())
{
set<Id> setOpptyPrdctId =  fetchOpptyProductDetails(setOfOpptyId);
if(setOpptyPrdctId != null && !setOpptyPrdctId.isEmpty())
{
for(Id OPId : setOpptyPrdctId)
{
setLeadProductId.remove(OPId);   
}
}
}
if(setOfOpptyId != null && !setOfOpptyId.isEmpty())
{
PROpportunity = [Select Id,CurrencyIsoCode,Type, Pricebook2Id From Opportunity Where Opportunity.Id In : setOfOpptyId];
}
if(setLeadProductId != null && !setLeadProductId.isEmpty() && PROpportunity != null && !PROpportunity.isEmpty())
{
/* <T21>
List<Pricebook2> listPriceBook = [select id, name from Pricebook2 where isStandard = true limit 1];
if (listPriceBook.size() > 0)
{
stdPriceBook = listPriceBook.get(0);
}</T21>*/
    
    /*  map<String, pricebookentry> productIdPriceBook = new map<String, pricebookentry>();
map<Id, Opportunity> opptyIdCurrency = new map<Id, Opportunity>();
set<Id> setPricebookId = new set<Id>();                 //</T21>
for(Opportunity opp : PROpportunity){
opptyIdCurrency.put(opp.Id,opp);
setOFOpptyCurrency.add(opp.CurrencyIsoCode);
setPricebookId.add(opp.Pricebook2Id);               //</T21>
}
if(setLeadProductId != null && !setLeadProductId.isEmpty() && setOFOpptyCurrency != null && !setOFOpptyCurrency.isEmpty() 
&& setPricebookId != null)
{
for(PricebookEntry record:[select id,product2id,product2.name,CurrencyIsoCode,pricebook2id  
from pricebookentry 
where product2id in :setLeadProductId 
and pricebook2id in :setPricebookId                                  //</T21>
and CurrencyIsoCode in :setOFOpptyCurrency])
{
productIdPriceBook.put(record.product2id+','+record.CurrencyIsoCode, record);
}
}
if (!productIdPriceBook.isEmpty())
{
set<OpportunityLineItem> OLItoInsert = new set<OpportunityLineItem>();
for(Opportunity opp : PROpportunity)
{
string currentOpptyIdCurrency = opptyIdCurrency.get(opp.Id).CurrencyIsoCode;
for(Id oDealRegId : setLeadProductId) 
{
if(productIdPriceBook.containsKey(oDealRegId+','+currentOpptyIdCurrency) && 
(opptyIdCurrency.containsKey(opp.Id)))
{
if( (opptyIdCurrency.get(opp.Id).CurrencyIsoCode == productIdPriceBook.get(oDealRegId+','+currentOpptyIdCurrency).CurrencyIsoCode) &&
opp.Pricebook2Id == productIdPriceBook.get(oDealRegId+','+currentOpptyIdCurrency).Pricebook2Id)     //</T21>
{
//create opportunity line items and add them to list of oppty line item
//Set teh Transaction Type depending on Oppty Type . Type = Direct/Indirect then New or Upsell
OpportunityLineItem oli = new OpportunityLineItem();
oli.opportunityid = opp.Id;
oli.pricebookentryid = productIdPriceBook.get(oDealRegId+','+currentOpptyIdCurrency).id;         
//-------------------------------------------------------------<T19>                       
if(opp.Type == 'Direct' || opp.Type == 'Indirect')
oli.Transaction_Type__c = 'New';                                
else
oli.Transaction_Type__c = 'Upsell';
//-------------------------------------------------------------</T19>
OLItoInsert.add(oli);
}
}
}
}
List<OpportunityLineItem>OLItoInsertList = new list<OpportunityLineItem>(OLItoInsert);
if(OLItoInsertList != null && !OLItoInsert.isEmpty() && 
Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().isCreateable())
{
try
{
insert OLItoInsertList;  
}
catch (System.DmlException e) 
{
GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'exception in createOpptyPrdctFrmDealRegPrdct',e.getMessage());
}
}
}
}
} 
*/
    //<T47>
    /*
    * If the INFA Compliance is updated on Opportunity , update the Compliance Settlement on Quote
    * @param parameter- newOpps - list of new opportunities
    * @return return- void
    * @throws exception-captures exception in a debug log
    */    
    static void updateQuote(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        Map<Id, SBQQ__Quote__c> quoteToUpdateMap = new Map<Id, SBQQ__Quote__c>(); //Map of Quote records to be udpated
        Set<Id> oppIds = new Set<Id>(); //Gather all Opportunity Id's where INFA Compliance Flag is updated
        Set<Id> primaryQuoteId = new Set<Id>();
        for(Opportunity opp : newMap.values()){
            if(opp.PT_INFA_License_Compliance__c != oldMap.get(opp.Id).PT_INFA_License_Compliance__c){
                //Gather all Opportunity Id's whose Territory has changed
                oppIds.add(opp.Id);
                if(opp.SBQQ__PrimaryQuote__c != NULL){
                    primaryQuoteId.add(opp.SBQQ__PrimaryQuote__c);
                }
            }
        }
        
        //Query for Quot
        if (primaryQuoteId.isEmpty()) {
            return;
        }
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Compliance_Settlement__c, SBQQ__Opportunity2__r.PT_INFA_License_Compliance__c
                                                                                    FROM SBQQ__Quote__c
                                                                                    WHERE ID IN :primaryQuoteId]);
        
        for(SBQQ__Quote__c quote : quoteMap.values()){
            quote.Compliance_Settlement__c = quote.SBQQ__Opportunity2__r.PT_INFA_License_Compliance__c;
                        
                        quoteToUpdateMap.put(quote.Id, quote);
        }
        //DML Update call on the Quote  
        if(quoteToUpdateMap.size() > 0 && quoteToUpdateMap != null){
            try{
                globalApexManager.avoidRecursion('QuoteBeforeUpdate');
                globalApexManager.avoidRecursion('QuoteAfterUpdate');               //Stop the QuoteBeforeUpdate and QuoteAfterUpdate Trigger from running to avoid recursion
                Database.SaveResult[] srList = Database.update(quoteToUpdateMap.values(), false);
            } catch(Exception e){
                GAM.CreateLogs('OpportunityTriggerHandler.UpdateQuote Compliance Flag', quoteToUpdateMap.values(), 'quoteToUpdateMap');
            }
        }
    }

   static void updatePrimaryESOnOpportunity(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){            

        User_Exemptions__c ue = User_Exemptions__c.getInstance(UserInfo.getProfileId()); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission 
        Boolean IsExemptUser = (cpr.hasPermission('SystemAdmin') || cpr.hasPermission('IntegrationUser') || cpr.hasPermission('SalesSuperUser') || cpr.hasPermission('Bypass_Opportunity_Validations') || ue.Ignore_Validation_Rules__c); /*<SALESRT-15556>*/
        Set<Id> setOppIds = new Set<Id>();
    
        for (Opportunity opp: newMap.values()) {  

            if((opp.ForecastCategoryName != oldMap.get(opp.Id).ForecastCategoryName && (opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Closed')) || (opp.Substage__c != oldMap.get(opp.Id).Substage__c && (opp.Substage__c == 'Selected' || opp.Substage__c == 'Contract' || opp.Substage__c == 'Sales Won'))){
                setOppIds.add(opp.Id);
            }
        }
        
        if(!setOppIds.isEmpty()){
            
            Map<Id,Opportunity> mapOppToUpdate = new Map<Id,Opportunity>([SELECT Id,(SELECT Id FROM Estimation_Summaries__r WHERE Primary__c = true),(SELECT Id FROM OpportunityLineItems WHERE (Product2.Product_Family__c = 'IPU' OR Product2.Name LIKE '%IPU%') AND (Upsell_ACV__c > 0 OR New_ACV__c > 0 OR Offset_ACV__c > 0) ) FROM Opportunity WHERE Id IN :setOppIds]); 
            for(Opportunity opp: mapOppToUpdate.values()){
                if(!IsExemptUser && opp.Estimation_Summaries__r.isEmpty() && !opp.OpportunityLineItems.isEmpty()){
                    setOppIds.remove(opp.Id);
                    newMap.get(opp.Id).addError(system.label.RequireIPUEstimatorMessage);                    
                }
            }
        }
    }

    //<AR-2866>
    /*
    Method Name : CheckAccountChange 
    Description : This method will update the account in Interlock and Plan when Account changed in Opportunity
    Parameters  : List<Opportunity> lstnewOpportunity, 
                  Map<Id,Opportunity> mapOldOpportunity
    Return Type : NA
    */
    public static void CheckAccountChange(List<Opportunity> lstnewOpportunity, Map<Id,Opportunity> mapOldOpportunity){
        Set<Id> setOpportunity = new Set<Id>();

        for(Opportunity objOpp:lstnewOpportunity){
            Opportunity oldOpp = mapOldOpportunity.get(objOpp.Id);
            if(objOpp.AccountId  != oldOpp.AccountId)
            {             
                setOpportunity.add(objOpp.Id);
            }
        }
        if(setOpportunity.size()>0){
            //<AR-2866>  
            System.enqueueJob(new CSMUpdateInterlockPlanAccountQueueable(setOpportunity));
        }
    }
    //</AR-2866>

    //<SALESRT-14838> Starts here
    /**
     * @description : this method recalculates the ipu warnings
     * 
     * @param : newList - List of Opportunities
     * @param : oldMap - map of Opportunities
     * 
     * update - SALESRT-15212
     * @return : void
     */
    public static void recalculateWarning(list<Opportunity> newList, map<Id, Opportunity> oldMap){

        Set<Id> oppIdSet = new Set<Id>();

        for(Opportunity opp : newList){
            
            if(oldMap != null && (oldMap.get(opp.Id).Primary_IPU_Estimator__c != opp.Primary_IPU_Estimator__c || oldMap.get(opp.Id).SubStage__c != opp.SubStage__c || oldMap.get(opp.Id).StageName != opp.StageName) && opp.Primary_IPU_Estimator__c != null){
                oppIdSet.add(opp.Id);
            }
        }

        if(!oppIdSet.isEmpty() && !System.isFuture() && !System.isBatch()){
            InfaSalesUtility.recalculateIpuWarnings(new List<Id>(oppIdSet));
        }
    }
    //<SALESRT-14838> Ends here

    //<AR-3350>
    /*
    Method Name : createChatterPostOnClosedWon 
    Description : This method will create chatter post on opportunity when it is moved to closed won and the opportunity line items has Assurance package product
    Parameters  : Map<Id,Opportunity> newMap
    Return Type : NA
    */
    public static void createChatterPostOnClosedWon(Map<Id, Opportunity> newMap,Map<Id, Opportunity> oldMap){
        List<Id> matchedOpptyIds = new List<Id>();
        CSM_Static_Value__mdt csmProductName = [SELECT Id, Value__c FROM CSM_Static_Value__mdt WHERE DeveloperName = 'CSMAssuranceProductsOppty'];
        List<String> productsList = csmProductName.Value__c.split(',');
        for(Opportunity opp:newMap.values()){
            if(opp.StageName <> oldMap.get(opp.Id).StageName && opp.StageName =='Closed Won'){
                matchedOpptyIds.add(opp.Id);
            }
        }
        if(matchedOpptyIds?.size()>0){
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Name,AccountId, Account.Name,owner.Name,Fulfillment_Information__c,StageName,
                                            (SELECT Id, Product2.Name FROM OpportunityLineItems WHERE Product2.Name IN :productsList) 
                                            FROM Opportunity WHERE Id IN :matchedOpptyIds]);
        
            Set<Id> oppIdSetForChatter = new Set<Id>();
            Set<Id> oppAccIdSet = new Set<Id>();
            for(Opportunity oppty:oppMap.values()){
                if(oppty.OpportunityLineItems?.size()>0){
                    oppIdSetForChatter.add(oppty.Id);
                    oppAccIdSet.add(oppty.AccountId);
                }
            }
            if(oppIdSetForChatter?.size()>0){
                OpportunityTriggerHandlerHelper.createChatterPostForCloudAssurance(oppMap,oppIdSetForChatter,oppAccIdSet);
            }
        }
    }
    //</AR-3350>
    //<SALESRT-16900>
    //gets map of lable and api value pair mapping for Stage Values
    private static Map<String, String> getStageMapping(){
        if(oppStageMapping == NULL || oppStageMapping.size() == 0){
            oppStageMapping = new Map<String, String>();
            String stageMappingStr = Label.Opportunity_Stage_Mapping;
            List<String> tempKeyVal;
            for(String keyVal : stageMappingStr.split(';')){
                tempKeyVal = keyVal.split(':');
                if(tempKeyVal.size() == 2){
                    oppStageMapping.put(tempKeyVal[0], tempKeyVal[1]);
                }
            }
        }
        return oppStageMapping;
    }
}