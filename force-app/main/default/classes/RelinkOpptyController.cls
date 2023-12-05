/*
Class:          RelinkOpptyController
@Author:        Anusha Akella
@Created Date:  25-Aug-2021
@Description:   RelinkOpptyController Class gets triggered by the button on quote "Relink Opportunity"
*/
/*
Change History
*******************************************************************************************************************************************************************************
ModifiedBy              Date             JIRA Ticket                  Description                                                                                      Tag
*******************************************************************************************************************************************************************************
Anusha Akella          27-Aug-2021       SALESRT-13088            Initial request
Saurabh Khandelwal     28-March-2022     SALESRT-13668            Added sales rep populate with new opporutnity owner for Amendment
                                                                  quote.
Chandana Gowda         27-Jul-2023       SALESRT-17160            Check opty name length before update                                                              <T1>
*/
public class RelinkOpptyController {
    
    public static globalApexManager GAM = new globalApexManager(); 
    public static String amendType;
    public static String groupValue;

    //added below method for elevate
    public static String submitQuoteDetails(String quoteId, String newOpptyId, String amendTypeParam, String groupParam){
        amendType = amendTypeParam;
        groupValue = groupParam;
        return submitQuoteDetails(quoteId, newOpptyId);
    }

    @AuraEnabled
    public static String submitQuoteDetails(String quoteId, String newOpptyId){
        Savepoint sp = Database.setSavepoint();
        
            if(newOpptyId == ''){
                return 'Opportunity not selected, Please select to proceed';
            }
            SBQQ__Quote__c qt = [SELECT Id, SBQQ__Type__c,Quote_Description__c, SBQQ__Primary__c, SBQQ__Opportunity2__c, SBQQ__MasterContract__c, SBQQ__MasterContract__r.ContractNumber
                                 FROM SBQQ__Quote__c 
                                 WHERE Id = :quoteId];
            set<Id> opportunityIds = new Set<Id>();
            String oldOpptyId;
            String amdContractId;
            String amdContractName;
            String quoteDesc;
        try{
            List<Opportunity> updateOpptys = new List<Opportunity>();
            //List<SBQQ__Quote__c> updateQteRec = new List<SBQQ__Quote__c>();
            opportunityIds.add(newOpptyId);
            if(qt!=null && qt.SBQQ__Type__c == 'Amendment' && qt.SBQQ__MasterContract__c != null) {
                if(qt.SBQQ__Opportunity2__c != Null) {
                    oldOpptyId = qt.SBQQ__Opportunity2__c;
                    opportunityIds.add(qt.SBQQ__Opportunity2__c);
                    if(qt.SBQQ__Opportunity2__c != newOpptyId) {
                        qt.SBQQ__Opportunity2__c = newOpptyId;   
                    } else {
                        return 'Please select a different Opportunity';
                    }
                    amdContractId = qt.SBQQ__MasterContract__c;
                    amdContractName = qt.SBQQ__MasterContract__r.ContractNumber;
                    //update qt;
                    if(!opportunityIds.isEmpty()) {
                        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity> ([SELECT Id, AccountId, Account.OwnerId, Name, Related_Opportunity__c, Duplicate_Opportunity__c,OwnerId, SBQQ__PrimaryQuote__c, 
                                                                                    SBQQ__AmendedContract__r.ContractNumber, SBQQ__AmendedContract__c FROM Opportunity 
                                                                                    WHERE Id IN :opportunityIds]);
                        
                        String strAccMngr = Label.DA_Field_Sales_Rep;                                  
                        String setOppOwner;
                        
                        // get the team member roles for the opportunity                    
                        List<OpportunityTeamMember> lstOppTeamMem = [Select id, OpportunityId, TeamMemberRole, UserId from OpportunityTeamMember where opportunityId =: oldOpptyId and TeamMemberRole =:strAccMngr];
                        
                        if (lstOppTeamMem.size() >= 2 || lstOppTeamMem.size() == 0) {
                           setOppOwner = opptyMap.get(oldOpptyId).Account.OwnerId;
                        } else if(lstOppTeamMem!= null && lstOppTeamMem.size() == 1) {
                           setOppOwner = lstOppTeamMem[0].userId;                       
                        } 
                        
                        system.debug('opptyMap'+opptyMap);
                        if(!opptyMap.values().isEmpty()) {
                            for(Opportunity opp : opptyMap.values()) {
                                //Original opportunity Update
                                if(opp.Id != newOpptyId) {
                                    opp.OwnerId = setOppOwner;
                                    opp.Duplicate_Opportunity__c = newOpptyId;
                                    opp.SBQQ__PrimaryQuote__c = null;
                                    opp.StageName = 'Duplicate';
                                    opp.Substage__c = 'Duplicate';
                                    opp.Stage_Reason__c = 'Upside Placeholder';
                                    updateOpptys.add(opp);
                                } 
                                // surviving opportunity Update
                                if(opp.Id == newOpptyId) { 
                                    //opp.SBQQ__PrimaryQuote__c = qt.Id;
                                    //updating owner for the ammended quote of the new opportunity SALESRT-13668
                                    qt.SBQQ__SalesRep__c=opp.ownerId;
                                    //-------------------------------------------------------------------<T1>
                                    String opptyName = opp.Name;
                                    if(opp.SBQQ__AmendedContract__c <> NULL && opp.Name.contains(opp.SBQQ__AmendedContract__r.ContractNumber)){ 
                                        if(amdcontractId <> opp.SBQQ__AmendedContract__c){
                                            opptyName = opp.Name.replace(opp.SBQQ__AmendedContract__r.ContractNumber, amdContractName);
                                        }
                                    }
                                    else{
                                        opptyName = opp.Name+' '+amdContractName+ ' Amend';
                                    }
                                    opp.Name = opptyName.length() <= 120 ? opptyName: opp.Name;
                                    //-------------------------------------------------------------------<T1/>
                                    opp.SBQQ__AmendedContract__c = amdcontractId;
                                    quoteDesc = opp.Name;
                                    updateOpptys.add(opp);
                                }
                            }
                            if(!updateOpptys.isEmpty()){                            
                                    qt.SBQQ__Primary__c = false;
                                    qt.Quote_Description__c = quoteDesc; 
                                    //added for Elevate
                                    if(String.isNotBlank(amendType))
                                        qt.Amend_Type__c = amendType;
                                    if(String.isNotBlank(groupValue))
                                        qt.Group__c = groupValue;//ends -Elevate changes
                                    SBQQ.TriggerControl.disable(); //Muting CPQ Triggers so that the products added on surving Oppty doesn't wipe off as Quote is Non-Primary
                                        update qt;
                                        update updateOpptys;

                                    SBQQ.TriggerControl.enable();
                            }
                        }
                        return 'true';
                    }
                } else {
                    return 'There is no related Opportunity';
                }  
            } else {
                return 'This is not an Amendment Quote';
            }
            return null;    
        } catch(Exception e) {
            database.rollback(sp);
            GAM.CreateLogs('RelinkOpptyController.submitQuoteDetails', qt, 'QuoteDetails');
            return 'Unable to update Quote '+e.getMessage();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name,New_Org_Opportunity_Number__c,stageName from '+myObject+' Where (Name Like  \'%' + searchTerm + '%\' OR New_Org_Opportunity_Number__c = \''+ searchTerm +'\') AND '+filter+' LIMIT  5'; 
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name,New_Org_Opportunity_Number__c,stageName from '+myObject+' Where LastViewedDate != NULL AND '+filter+' ORDER BY LastViewedDate DESC LIMIT  5'; 
            }
            else {
                myQuery = 'Select Id, Name,New_Org_Opportunity_Number__c,stageName from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;  
    }

}