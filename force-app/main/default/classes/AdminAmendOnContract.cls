/****************************************************************************************************************************
*  @Class Name: AdminAmendOnContract
*  @Author: Kiran
*  @Date: 13 Apr 2020
*  @Description: Revision Amend
*****************************************************************************************************************************
Change History     
****************************************************************************************************************************/

public class AdminAmendOnContract
{   
    public static globalApexManager GAM = new globalApexManager();
    
    // Allow to use Admin Amend button if the user has "Admin Flow Permission Set" permission set permission set 
    @AuraEnabled
    public static boolean currentUser()
    {
        boolean isAdminUser = false;
        String PSIds = Label.AdminPermissionSet;
        List<String> PSId = PSIds.split(';');
        List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment> ();
        listPSA  = [SELECT AssigneeId,Id,PermissionSetGroupId,PermissionSetId FROM PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() AND PermissionSetId =: PSId];
        if(listPSA.size()>0){
            System.debug('TRUE' + listPSA.size());
            return TRUE;
        }
        else{
            System.debug('FALSE' + listPSA.size());
            return FALSE;
            
        }
    }
    
    // Set Admin Contract checkbox to TRUE on COntract and make API call to Amend in FUTURE
    @AuraEnabled
    public static void adminAmend(String contractId){
        List<Contract> lstContract = new List<Contract>();
        
        if(String.isNotBlank(contractId))
        {            
            lstContract = [Select Id, Admin_Contract__c from Contract where Id =: contractId Limit 1];
            lstContract[0].Admin_Contract__c = true;
            
            try{
                update lstContract;
            }
            Catch(Exception e){
                GAM.CreateExceptionRecords('Revision Amend', 'adminAmend',e.getMessage());            
            } 
            asyncAdminAmend(contractId);
        }   
    }
    
    @future(callout=true)
    public static void asyncAdminAmend(String contractId){
        //Call Amend API 
        QuoteModel quote = load(contractId);
        System.debug(quote);
        System.debug('KG - QuoteId '+quote.record.Id); 
        
        Id QuoteId = quote.record.Id;
        Id OpportunityId = quote.record.SBQQ__Opportunity2__c;
        
        //Update the Oppty and Quote
        List<Opportunity> lstOppty = new List<Opportunity>();
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        
        if(QuoteId != null && OpportunityId != null){
            lstOppty = [SELECT Id, Name, Type, Account.Name, SBQQ__RenewedContract__r.ContractNumber, SBQQ__RenewedContract__r.EndDate, 
                        SBQQ__AmendedContract__r.ContractNumber, OwnerId, Territory2Id,
                        Admin__c,Remove_Ownership__c,StageName,Substage__c,Stage_Reason__c,SBQQ__AmendedContract__r.Admin_Contract__c
                        FROM Opportunity 
                        WHERE Id =: OpportunityId LIMIT 1];

            lstQuote = [SELECT Id,Sub_Type__c,OwnerId 
                        FROM SBQQ__Quote__c 
                        WHERE Id =: QuoteId LIMIT 1];

            String Name = 'Revision : ' + lstOppty[0].Name;
            
            lstOppty[0].Name = Name;
            lstOppty[0].Admin__c = True;
            lstOppty[0].StageName = 'No Opportunity';
            lstOppty[0].Substage__c = 'No Opportunity';
            lstOppty[0].Stage_Reason__c = 'Revision Opportunity';
            lstOppty[0].Remove_Ownership__c = True;
            lstOppty[0].Enable_Downstream__c = 'Assets & Entitlements';
            lstOppty[0].OwnerId = Label.AdminFlowOwnerId ;
            lstOppty[0].Territory2Id = Null;

            lstQuote[0].Sub_Type__c = Label.RevisionLabel;
            lstQuote[0].OwnerId = Label.AdminFlowOwnerId ;
            lstQuote[0].SBQQ__SalesRep__c = Label.AdminFlowOwnerId ;
            
            try{
                update lstOppty;
                update lstQuote;
            }
            Catch(Exception e){
                GAM.CreateExceptionRecords('Asychronous Revision Amend', 'asyncAdminAmend',e.getMessage());            
            } 
        }
    }
    
    // Quote Model, QuoteLine Model and Quote Line Group Model are mandatory classes for below to run as expected.     
    public static QuoteModel load(String contractId) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, null);
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }
    
}