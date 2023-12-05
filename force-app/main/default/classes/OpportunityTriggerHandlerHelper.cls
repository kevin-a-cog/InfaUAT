/*
Class:          OpportunityTriggerHandlerHelper
@Author:        Uday Kumar
@Created Date:  01-APR-2021
@Description:   Helper class for OpportunityTriggerHandler Class.
*/
/*
Change History
************************************************************************************************************************************************************************
ModifiedBy          Date            JIRA Ticket                  Description                                                                                      Tag
************************************************************************************************************************************************************************
Uday Kumar         01-APR-2021     SALESRT-12900            To Create OCR's using Bill to, Sold to, End user, Ship to contacts from Primary Quote of Oppty.       T<01>
Uday Kumar         27-Apr-2021     SALESRT-12981             To fix the error while closing the Opportunity to Closed Won. Added Null check for Quote's Contacts   T<02>
Puneet Lohia     21-Jun-2021     SALESRT-13007          Automatically update Opportunity Price book and Currency                           <T13007>
Puneet Lohia     20-May-2022        SALESRT-13728           New LOGO SPIFF Changes                                                                                <SALESRT-13728>
Nikhil Mane      22-Nov-2022   SALESRT-14320      Validate Competitive Replacement,Competitor Commentary.      <SALESRT-14320>
VENKATESH BALLA 4/27/2023       SALESRT-15556       Added custompermission (Bypass_Opportunity_Validations) check to bypass opportunity 
                                                    object validation rules/data update restrictions                                                              <SALESRT-15556>   
Chaitanya T     22/09/2023     <AR-3350>            Cloud Assurance Operational Activity Asks                                                        <AR-3350>
VENKATESH BALLA    10/12/203       SALESRT-16900       COMMENTED METHOD CALL validateCompetitorFields AS PART OF JIRA SALESRT-16900                <SALESRT-16900> 
                                                       - TO MOVE APEX VALIDATIONS INTO STANDARD VALIDATION RULES.
*/



public class OpportunityTriggerHandlerHelper {
    
    public static globalApexManager GAM = new globalApexManager(); 
    
    private final static string OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; // new sales record type name on Opportunity
    private final static string OPP_RENEWAL_RT = Label.Renewal_Opportunity; // Renewal Opportunity record type name on Opportunity
    private final static string OPP_CHANNEL_RT = Label.Channel_Record_Type; // channel record type name on Opportunity <T13007>
    /**
    * this method is invoked from after Update of Opportunities
    *
    * @param mapOld - list of old Opportunities 
    * @param mapNew - list of new Opportunities
    * @return return-void
    * @throws exception - NA
    */
    public static void updateOCR (Map<Id,Opportunity> mapOld, Map<Id,Opportunity> mapNew) { 
        Set<Id> lstOppId = new Set<Id>();
        Set<Id> primaryQuoteIds = new Set<Id>();
        Map<Id,List<String>> opptyContactMap = new Map<Id,List<String>>();
        Map<Id,list<OpportunityContactRole>> mapOpptyOCR = new Map<Id,list<OpportunityContactRole>>();
        List<OpportunityContactRole> listOCRUpsert = new List<OpportunityContactRole>();
        for(Opportunity oppRec: mapNew.values()) {
            if(oppRec.StageName == 'Closed Won' && mapNew.get(oppRec.Id).StageName != mapOld.get(oppRec.Id).StageName){                          
                lstOppId.add(oppRec.Id);
                if(oppRec.SBQQ__PrimaryQuote__c != null){
                    primaryQuoteIds.add(oppRec.SBQQ__PrimaryQuote__c);
                }
            }
        }
        
        for(SBQQ__Quote__c quote : [Select Id,SBQQ__Opportunity2__c, BillToContact__c,ShipToContact__c,EndUserContact__c,SoldToContact__c from SBQQ__Quote__c where Id  IN :primaryQuoteIds]){  // QuoteIds.add(opp.SBQQ__PrimaryQuote__c);
            List<String> contacts = new List<String>{quote.BillToContact__c + ';'+ 'Billing Contact',quote.ShipToContact__c + ';'+ 'Shipping Contact',quote.EndUserContact__c + ';'+ 'End User',quote.SoldToContact__c + ';'+ 'Sold To'};
            opptyContactMap.put(quote.SBQQ__Opportunity2__c,contacts);
        }         
         
        for(OpportunityContactRole oppCon:[SELECT Id,OpportunityId,ContactId,Role,Sourced_from_Quote_Order__c from OpportunityContactRole WHERE OpportunityId IN:lstOppId]) {
            if(mapOpptyOCR.keyset().contains(oppCon.OpportunityId)) {
                list<OpportunityContactRole> tempList = new list<OpportunityContactRole>();
                tempList=mapOpptyOCR.get(oppCon.OpportunityId);
                tempList.add(oppCon);
                mapOpptyOCR.put(oppCon.OpportunityId,tempList);
            }
            else{
                list<OpportunityContactRole> newocr = new list<OpportunityContactRole>();
                newocr.add(oppCon);
                mapOpptyOCR.put(oppCon.OpportunityId,newocr);
            }
        }
        
        for(Id opptyId : lstOppId){
        if(opptyContactMap.keyset().contains(opptyId)){   //<T02> Added Null Check
            for(String contact :opptyContactMap.get(opptyId)){
                boolean isExist=false;
                if(mapOpptyOCR.keyset().contains(opptyId) && contact.split(';')[0]!='null'){   //<T02> Added Null Check
                    for(OpportunityContactRole ocrr:mapOpptyOCR.get(opptyId)) {
                    // Below condition will check if the OCR record is present with the same role for the contact. It will update the Sourced_from_Quote_Order__c to true for the existing OCR records.
                        if(ocrr.ContactId== contact.split(';')[0] && ocrr.Role==contact.split(';')[1]) {
                            OpportunityContactRole ocr = new OpportunityContactRole(Id = ocrr.Id,Sourced_from_Quote_Order__c= true);
                            listOCRUpsert.add(ocr);
                            isexist=true;
                            break;
                        }
                    }
                }
                //Create OCR from Quote
                if(isExist==false && contact.split(';')[0]!='null'){   //<T02> Added Null Check
                OpportunityContactRole ocrInsert = new OpportunityContactRole();
                ocrInsert.OpportunityId = opptyId;
                ocrInsert.ContactId = contact.split(';')[0];
                ocrInsert.Role = contact.split(';')[1];
                ocrInsert.Sourced_from_Quote_Order__c = true;
                listOCRUpsert.add(ocrInsert);
                
                }
            }
           }
        }
                
        if(!listOCRUpsert.isEmpty()){       
            try{
                upsert listOCRUpsert;
                //Database.SaveResult[] srList = Database.upsert(listOCRUpsert, false);
            }catch(Exception e) {
                GAM.CreateLogs('OpportunityTriggerHandlerHelper.updateOCR', listOCRUpsert, 'listOCRUpsert');
            }
        }
    } //<T01>


    /** <T13007> starts here
    * this method assigns a pricebook to Opportunity based on mapping to its related Account. 
    * @param parameter- newOpps - list of new opportunities, newMap - Map of new opportunities, oldMap - trigger.oldMap for opportunities
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
    public static void pricebookAssignmentMethod(List<Opportunity> newOpps, Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
            List<Opportunity> opportunitiesToIterate = new List<Opportunity>();
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> priceBookIds = new Set<Id>();
            Set<Id> contractIds = new Set<Id>();
            Pricebook_Assignment_Mapping__mdt defaultMapping ; 
            Map<String, Pricebook_Assignment_Mapping__mdt> mapCountryToMetadata = new Map<String, Pricebook_Assignment_Mapping__mdt>();
            for(Pricebook_Assignment_Mapping__mdt countryBasedPricebook : [SELECT DeveloperName, Pricebook_Name__c, MasterLabel, 
                                                                                    Pricebook_Id__c, Currency_ISO_Code__c 
                                                                                FROM Pricebook_Assignment_Mapping__mdt]) {
                String mappingKey = countryBasedPricebook.MasterLabel;
                if(!mapCountryToMetadata.containsKey(mappingKey)) {
                    mapCountryToMetadata.put(mappingKey,countryBasedPricebook);
                }
                if(countryBasedPricebook.MasterLabel == 'Default'){
                    defaultMapping = countryBasedPricebook;
                }
            }
            for(Opportunity opp : newOpps){
                if((opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() 
                        || opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId() 
                        || opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId())         //     && (opp.SBQQ__RenewedContract__c == Null)   && !opp.Name.contains('Amendment'))
                    && (oldMap == null || 
                            ( oldMap != null && (opp.CurrencyIsoCode != oldMap.get(opp.Id).CurrencyIsoCode || opp.Pricebook2Id != oldMap.get(opp.Id).Pricebook2Id)))) {      
                        setAccountIds.add(opp.AccountId);  
                        opportunitiesToIterate.add(opp);
                        if(opp.Pricebook2Id != null){
                          priceBookIds.add(opp.Pricebook2Id);            
                        }
                         if(oldMap != null && oldMap.get(opp.Id).Pricebook2Id !=null){
                           priceBookIds.add(oldMap.get(opp.Id).Pricebook2Id);           
                        }
                        if(opp.SBQQ__RenewedContract__c != null)
                            contractIds.add(opp.SBQQ__RenewedContract__c);
                        if(opp.SBQQ__AmendedContract__c != null)
                            contractIds.add(opp.SBQQ__AmendedContract__c);
                 } 
            }
            if(!opportunitiesToIterate.isEmpty()){
                Map<Id,Pricebook2> priceBookMap = new Map<Id,Pricebook2>([SELECT Id,IsStandard FROM Pricebook2 WHERE Id IN :priceBookIds]);
                Map<Id, Account> mapAcntIdAccountRecord = new Map<Id, Account>([SELECT Id, Name, BillingCountry FROM Account Where id IN :setAccountIds]);
                List<Opportunity> oppListToUpdate = new List<Opportunity>();
                for(Opportunity opp : opportunitiesToIterate){
                    if(!Test.isRunningTest() && priceBookMap != null && priceBookMap.containsKey(opp.Pricebook2Id) && priceBookMap.get(opp.Pricebook2Id).IsStandard){
                        opp.addError('Standard pricebook is not allowed. Please select another pricebook!');
                    }
                    else if(opp.SBQQ__RenewedContract__c != null || opp.SBQQ__AmendedContract__c != null){
                            if(Trigger.isUpdate){
                                Opportunity oppInstance = new Opportunity();
                                oppInstance.Id = opp.Id;
                                oppInstance.PriceBook2Id = oldMap.containsKey(opp.Id) && oldMap.get(opp.Id).PriceBook2Id != opp.PriceBook2Id && opp.PriceBook2Id != null ?  opp.PriceBook2Id : oldMap.get(opp.Id).PriceBook2Id;
                                oppListToUpdate.add(oppInstance);
                            }
                    }
                    else if(mapAcntIdAccountRecord.get(opp.AccountId) != NULL 
                       && mapAcntIdAccountRecord.containsKey(opp.AccountId) 
                       && mapAcntIdAccountRecord.get(opp.AccountId).BillingCountry != Null
                       && mapAcntIdAccountRecord.get(opp.AccountId).BillingCountry != '' ) {
                           if(mapCountryToMetadata.containsKey(mapAcntIdAccountRecord.get(opp.AccountId).BillingCountry)) {
                               Pricebook_Assignment_Mapping__mdt pam = mapCountryToMetadata.get(mapAcntIdAccountRecord.get(opp.AccountId).BillingCountry);
                               if(Trigger.isInsert){
                                    opp.Pricebook2Id = pam.Pricebook_Id__c;
                                    opp.CurrencyIsoCode = pam.Currency_ISO_Code__c;
                               }
                               else{
                                   Opportunity oppInstance = new Opportunity();
                                   oppInstance.Id = opp.Id;
                                   oppInstance.PriceBook2Id = oldMap.containsKey(opp.Id) && oldMap.get(opp.Id).PriceBook2Id != opp.PriceBook2Id && opp.PriceBook2Id != null ?  opp.PriceBook2Id : oldMap.get(opp.Id).PriceBook2Id;
                                   oppListToUpdate.add(oppInstance);
                               }
                               
                           }
                           else if(defaultMapping != null){
                               if(Trigger.isInsert){
                                    opp.Pricebook2Id = defaultMapping.Pricebook_Id__c;
                                    opp.CurrencyIsoCode = defaultMapping.Currency_ISO_Code__c;
                               }
                               else{
                                   Opportunity oppInstance = new Opportunity();
                                   oppInstance.Id = opp.Id;
                                   oppInstance.PriceBook2Id = oldMap.containsKey(opp.Id) && oldMap.get(opp.Id).PriceBook2Id != opp.PriceBook2Id && opp.PriceBook2Id != null ?  opp.PriceBook2Id : oldMap.get(opp.Id).PriceBook2Id;
                                   oppListToUpdate.add(oppInstance);
                               }
                           }
                       }
                }
                try{
                    if(Trigger.isUpdate && !oppListToUpdate.isEmpty()){
                        OpportunityTriggerHandler.pricebookFlag = false;
                        update oppListToUpdate;
                    }
                }
                catch(Exception e){
                    GAM.CreateExceptionRecords('OpportunityTriggerHandler', 'Exception in pricebookAssignmentMethod method',e.getMessage());
                }
            }   
    }
    //<T13007> ends here

    //<SALESRT-13728> start
    /*
    * this method calculates and populates New logo spiff checkbox on opportunity
    * @param parameter- newOpps - list of new opportunities
    * @return return- void
    * @throws exception-captures exception in a debug log
    */
    public static void newLogoSpiffCalculator(List<Opportunity> newOpps){
        String eligible = System.Label.Spiff_Eligible;
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opp : newOpps){
           if(opp.AccountId != null){
               accountIdSet.add(opp.AccountId);
           }
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,New_Logo_SPIFF__c FROM Account WHERE Id IN :accountIdSet]);
        for(Opportunity opp : newOpps){
            if(opp.AccountId != null && accountMap != null && accountMap.containsKey(opp.AccountId) && accountMap.get(opp.AccountId).New_Logo_SPIFF__c != null && accountMap.get(opp.AccountId).New_Logo_SPIFF__c.containsIgnoreCase(eligible)){
                opp.New_Logo_SPIFF__c = true;
            }
        }
    }
    //<SALESRT-13728> end
       //<SALESRT-14320>
     /**
    * this method is invoked from before Insert and Before Update of Opportunities
    *
    * @param oldMap - map of old Opportunities 
    * @param newMap - map of new Opportunities
    * @return return-void
    * @throws exception - NA
    */
    /*COMMENTED AS PART OF JIRA SALESRT-16900 - TO MOVE APEX VALIDATIONS INTO STANDARD VALIDATION RULES.*/
    /*public static void validateCompetitorFields (List<Opportunity> newOpps,Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){ 
        User_Exemptions__c ue = User_Exemptions__c.getInstance(UserInfo.getProfileId()); 
        CustomPermissionsReader cpr = new CustomPermissionsReader();// to check the user permission
        Boolean IsExemptUser = (cpr.hasPermission('SalesSuperUser') ||cpr.hasPermission('PSA_Operations') || cpr.hasPermission('PSA_Deal_Desk') || cpr.hasPermission('PSA_Sales') || cpr.hasPermission('Bypass_Opportunity_Validations')  || ue.Ignore_Validation_Rules__c); //<SALESRT-15556>
         List<Opportunity> reqOppties = new List<Opportunity>();
            for(Opportunity opp : newOpps){
                if((opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId() 
                    || opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_CHANNEL_RT).getRecordTypeId())
                    && (listContains(label.CompetitiveReplacementSubstages, opp.Substage__c) || (listContains(label.CompetitorCommentarySubstages, opp.Substage__c)) )
                    && opp.Split_From__c == null)
                    {
                        reqOppties.add(opp);
                    }
            }          
         if(!IsExemptUser && !reqOppties.isEmpty()){
            for(Opportunity opp : reqOppties){
                if(opp.Competitive_Replacement__c == null || opp.Notes_to_Competitive_Team__c == null){
                    String Competitors = opp.Competitors__c;
                    Boolean isOtherValue;
                    if(!(String.isBlank(Competitors))){
                    isOtherValue = CompareCompValues(Competitors);
                    }else{
                           isOtherValue = true;
                    }
                    if(isOtherValue == true){
                        if(opp.Competitive_Replacement__c == null && (listContains(label.CompetitiveReplacementSubstages, opp.Substage__c))){
                            opp.addError('Please add Competitive Replacement value.');
                        } 
                        if(opp.Notes_to_Competitive_Team__c == null && (listContains(label.CompetitorCommentarySubstages, opp.Substage__c))){
                            opp.addError('Please add Competitor Commentary value.');
                        }  
                    }
                }  
            }
         }
    }

    static Boolean CompareCompValues(String Competitors){
            List<String> lstCompValues = Competitors.split(';');
            List<String> lstDefaultCompValues = (label.CompetitorsValidationValues).split(';');
            Set<String> setCompValues = new Set<String>(lstCompValues);
            Set<String> setDefaultCompValues = new Set<String>(lstDefaultCompValues);
            setCompValues.removeAll(setDefaultCompValues);
            return (setCompValues.size()>0);
    }
    static Boolean listContains(String reqSubstages, String substage) {
     List<String> lstSubstageValues = reqSubstages.split(';');
    return (new Set<String>(lstSubstageValues)).contains(substage);
    }*/
    //<SALESRT-14320> end

    //<AR-3350> start
    /*
    Method Name : createChatterPostForCloudAssurance 
    Description : This method will create chatter post on opportunity when it is moved to closed won and the opportunity line items has Assurance package product
    Parameters  : Map<Id,Opportunity> newMap
    Return Type : NA
    */
    public static void createChatterPostForCloudAssurance(Map<Id,Opportunity> oppMap, Set<Id> oppIdSetForChatter, Set<Id> oppAccIdSet){
        Map<Id,String> accTeamMap = new Map<Id,String>();
        List<AccountTeamMember> accTeamList = [SELECT Id,UserId,User.Name,AccountId FROM AccountTeamMember WHERE TeamMemberRole = 'CSM' AND AccountId IN :oppAccIdSet ORDER BY CreatedDate DESC];
        for(AccountTeamMember accTeam:accTeamList){
            if(accTeamMap.containsKey(accTeam.AccountId) == false){
                accTeamMap.put(accTeam.AccountId,accTeam.User.Name);
            }
        }
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Opportunity oppty : oppMap.values()){
            if(oppIdSetForChatter.contains(oppty.Id)){
                String message ='';
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                String recordLink =  System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Opportunity/'+ oppty.Id + '/view';
                String recordAccLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Account/'+ oppty.AccountId + '/view';
                //Get the Target ID
                input.subjectId = oppty.Id; 
                
                //Get the chatter message
                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                message = 'A new Cloud Assurance Pack opportunity has been closed for this account. Please onboard and verify the metadata as needed for the Org(s) listed in the note below. Kindly close the loop with CSM and the Opportunity Owner once completed. \n\n';
            
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentMainTxt;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentMainTxt;
                
                markupBeginSegmentMainTxt= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentMainTxt.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentMainTxt);
                
                ConnectApi.TextSegmentInput textSegmentMainTxt = new ConnectApi.TextSegmentInput();
                textSegmentMainTxt.text = message;
                body.messageSegments.add(textSegmentMainTxt);
                
                markupEndSegmentMainTxt= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentMainTxt.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentMainTxt);

                message = 'Account Name : ';
                
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph1;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph1;
                
                markupBeginSegmentParagraph1 = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParagraph1);
                
                ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
                textSegment1.text = message;
                body.messageSegments.add(textSegment1);

                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentAccLink;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentAccLink;
                
                markupBeginSegmentAccLink= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
                markupBeginSegmentAccLink.url=recordAccLink;
                markupBeginSegmentAccLink.altText=recordAccLink;
                body.messageSegments.add(markupBeginSegmentAccLink);
                
                ConnectApi.TextSegmentInput textSegmenthyperlinkAccount = new ConnectApi.TextSegmentInput();
                textSegmenthyperlinkAccount.text = oppty.Account.Name;
                body.messageSegments.add(textSegmenthyperlinkAccount);
                
                markupEndSegmentAccLink= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentAccLink.markupType = ConnectApi.MarkupType.Hyperlink;
                body.messageSegments.add(markupEndSegmentAccLink);

                markupEndSegmentParagraph1 = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParagraph1.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParagraph1);

                message = 'Opportunity Name : ';
                
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph2;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph2;
                
                markupBeginSegmentParagraph2 = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParagraph2);
                
                ConnectApi.TextSegmentInput textSegment2 = new ConnectApi.TextSegmentInput();
                textSegment2.text = message;
                body.messageSegments.add(textSegment2);

                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentOpptyLink;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentOpptyLink;
                
                markupBeginSegmentOpptyLink= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentOpptyLink.markupType = ConnectApi.MarkupType.Hyperlink;
                markupBeginSegmentOpptyLink.url=recordLink;
                markupBeginSegmentOpptyLink.altText=recordLink;
                body.messageSegments.add(markupBeginSegmentOpptyLink);
                
                ConnectApi.TextSegmentInput textSegmentHyperlinkOppty = new ConnectApi.TextSegmentInput();
                textSegmentHyperlinkOppty.text = oppty.Name;
                body.messageSegments.add(textSegmentHyperlinkOppty);
                
                markupEndSegmentOpptyLink= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentOpptyLink.markupType = ConnectApi.MarkupType.Hyperlink;
                body.messageSegments.add(markupEndSegmentOpptyLink);

                markupEndSegmentParagraph2 = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParagraph2.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParagraph2);

                message = 'Opportunity Owner : '+ oppty.owner.Name +'\n';
            
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph3;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph3;
                
                markupBeginSegmentParagraph3= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParagraph3.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParagraph3);
                
                ConnectApi.TextSegmentInput textSegment3 = new ConnectApi.TextSegmentInput();
                textSegment3.text = message;
                body.messageSegments.add(textSegment3);
                
                markupEndSegmentParagraph3= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParagraph3.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParagraph3);

                if(oppty.Fulfillment_Information__c!=null){
                    message = 'Fulfillment Information : '+ oppty.Fulfillment_Information__c +'\n';
                }else{
                    message = 'Fulfillment Information : \n';
                }
            
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph6;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph6;
                
                markupBeginSegmentParagraph6= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParagraph6.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParagraph6);
                
                ConnectApi.TextSegmentInput textSegment6 = new ConnectApi.TextSegmentInput();
                textSegment6.text = message;
                body.messageSegments.add(textSegment6);
                
                markupEndSegmentParagraph6= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParagraph6.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParagraph6);

                message = 'Opportunity Status : '+ oppty.StageName +'\n';
            
                ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph4;
                ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph4;
                
                markupBeginSegmentParagraph4= new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegmentParagraph4.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupBeginSegmentParagraph4);
                
                ConnectApi.TextSegmentInput textSegment4 = new ConnectApi.TextSegmentInput();
                textSegment4.text = message;
                body.messageSegments.add(textSegment4);
                
                markupEndSegmentParagraph4= new ConnectApi.MarkupEndSegmentInput();
                markupEndSegmentParagraph4.markupType = ConnectApi.MarkupType.Paragraph;
                body.messageSegments.add(markupEndSegmentParagraph4);

                if(accTeamMap.containsKey(oppty.AccountId)){
                    message = 'CSM Name : '+ accTeamMap.get(oppty.AccountId) +'\n';
            
                    ConnectApi.MarkupBeginSegmentInput markupBeginSegmentParagraph5;
                    ConnectApi.MarkupEndSegmentInput markupEndSegmentParagraph5;
                    
                    markupBeginSegmentParagraph5= new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegmentParagraph5.markupType = ConnectApi.MarkupType.Paragraph;
                    body.messageSegments.add(markupBeginSegmentParagraph5);
                    
                    ConnectApi.TextSegmentInput textSegment5 = new ConnectApi.TextSegmentInput();
                    textSegment5.text = message;
                    body.messageSegments.add(textSegment5);
                    
                    markupEndSegmentParagraph5= new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegmentParagraph5.markupType = ConnectApi.MarkupType.Paragraph;
                    body.messageSegments.add(markupEndSegmentParagraph5);
                }
                
                //Get the mention Users
                for (CollaborationGroupMember gm: [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroup.Name ='AssurancePackChatterGrp']) {
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput.id = gm.MemberId;
                    body.messageSegments.add(mentionSegmentInput);
                }
                input.body = body;

                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input); 

                batchInputs.add(batchInput);
            }   
        }
        if(!Test.isRunningTest()){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);  
        }
    }
    //<AR-3350> end
}