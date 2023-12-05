/*
Class:          ReinstateContractController 
@Author:        Chandana Gowda 
@Created Date:  20-Aug-2020
@Description:   SALESRT -12201
				Controller class for ReinstateContrct Lighting component
				This controller holds methods for reinstating the contract

Change History
*************************************************************************************************************************************
ModifiedBy			Date             Requested By        Description                                        				 Tag
Chandana Gowda      09-Nov-2020     SALESRT 12290       Added logic to remove cancel reason on Reinstating of contract        T1
*************************************************************************************************************************************
*/
public class ReinstateContractController {
    
    public static globalApexManager GAM = new globalApexManager();
    
    /*Method to check if the current User has SuperUser Permission set assigned.
* @param Name - n/a
* @throws exception -n/a
* @return Boolean - false: if user has SuperUser Permission Set Assigned, else true
*/     
    @AuraEnabled
    public static boolean hasSuperUserPermission()
    {
        boolean isSOG = false;
        String PSIds = Label.SOG_Admin;
        List<String> PSId = PSIds.split(';');
        List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment> ();
        listPSA  = [SELECT AssigneeId,Id,PermissionSetGroupId,PermissionSetId FROM PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() AND PermissionSetId =: PSId];
        return listPSA.size()>0;
    }    
    
    /*Method to check if any renewal Quote exists associated to the contract.
* @param Name - contractId: Id of the Contract
* @throws exception -n/a
* @return Boolean - false: if renwal quote exisits, true: if renewal Quote does not exist
*/    
    @AuraEnabled
    public static String checkRenewalQuote(Id contractId){
        
        List<Opportunity> existingRenewalOpty = [SELECT Id FROM Opportunity WHERE SBQQ__RenewedContract__c =:contractId];
        if(existingRenewalOpty.isEmpty()){
            return 'RENEWAL_QUOTE_NOT_CREATED';
        }
        
        List<SBQQ__Quote__c> existingRenewalQuote = [SELECT Id,Related_Contract__c,Primary_Order__c,Primary_Order__r.Sub_Type__c,SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Related_Contract__c =:contractId ORDER BY SBQQ__Primary__c DESC];
        if(existingRenewalQuote.isEmpty()){
            return 'RENEWAL_QUOTE_NOT_CREATED';
        }
        if(!existingRenewalQuote[0].SBQQ__Primary__c){
            return 'RENEWAL_QUOTE_NOT_PRIMARY';
        }
        if(existingRenewalQuote[0].Primary_Order__c == null){
            return 'RENEWAL_ORDER_NOT_CREATED';
        }
        if(existingRenewalQuote[0].Primary_Order__r.Sub_Type__c != 'Full Debook')
            return 'RENEWAL_ORDER_NOT_DEBOOKED';
        else if(existingRenewalQuote[0].Primary_Order__r.Sub_Type__c == 'Full Debook'){
            Contract masterContact = [SELECT Id FROM Contract WHERE SBQQ__Order__c =: existingRenewalQuote[0].Primary_Order__c ORDER BY StartDate ASC LIMIT 1];
            //Contract masterContact = [SELECT Id FROM Contract WHERE SBQQ__Quote__c =: existingRenewalQuote[0].Id ORDER BY StartDate ASC LIMIT 1];
            SBQQ__Quote__c debookAmendQuote = [SELECT Id,SBQQ__Ordered__c,Primary_Order__c,Primary_Order__r.SBQQ__Contracted__c FROM SBQQ__Quote__c WHERE Sub_Type__c = 'Full Debook' AND SBQQ__MasterContract__c =:masterContact.Id LIMIT 1];
            if(!debookAmendQuote.SBQQ__Ordered__c){
                return 'DEBOOK_NOT_COMPLETE';
            }
            else if(debookAmendQuote.Primary_Order__c != null && !debookAmendQuote.Primary_Order__r.SBQQ__Contracted__c){
                return 'DEBOOK_NOT_COMPLETE';
            }
        }
        return 'NO_ERROR';   
    }
    
    /*Method to update the contract to create new renewal quote
* @param Name - contractId: Id of the Contract
* @throws exception -n/a
* @return void
*/     
    @future
    public static void createNewRenewalQuote(Id contractId){
        //Updating the contract 
        Contract contractRec = [SELECT Id,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,SBQQ__RenewalOpportunity__c FROM Contract WHERE Id =: contractId]; 
        contractRec.put('SBQQ__RenewalQuoted__c',true);
        try {
            Database.SaveResult sContract = Database.update(contractRec,false); 
        } 
        catch(Exception e){
            GAM.CreateExceptionRecords('reinstateContract: Error in contract updation', e.GetMessage(), contractRec.Id);
        }
    }
    
    /*Method to update the existing renwal Opty, renewal quote, subscription lines and mark Renewal Forecasted and Quoted to False on contract.
* @param Name - contractId: Id of the Contract
* @throws exception -n/a
* @return void
*/         
    @AuraEnabled
    public static void reinstateContract(Id contractId){
        
        //Updating the existing renewal Optys to remove the reference
        List<Opportunity> existingRenewalOpty = [SELECT Id,SBQQ__RenewedContract__c FROM Opportunity WHERE SBQQ__RenewedContract__c =:contractId];
        for(Opportunity opp: existingRenewalOpty)
            opp.put('SBQQ__RenewedContract__c','');
        try {
            Database.SaveResult[] srList = Database.update(existingRenewalOpty , false);  
        } 
        catch(Exception e){
            for(sObject opty : existingRenewalOpty){
                GAM.CreateExceptionRecords('reinstateContract: Error in Opty Updation', e.GetMessage(), opty.Id);
            }
        }
        
        //Updating the exiting renewal Quote
        List<SBQQ__Quote__c> existingRenewalQuote = [SELECT Id,Related_Contract__c FROM SBQQ__Quote__c WHERE Related_Contract__c =:contractId];
        for(SBQQ__Quote__c quote: existingRenewalQuote)
            quote.put('Related_Contract__c','');
        try {
            Database.SaveResult[] srList = Database.update(existingRenewalQuote , false);  
        } 
        catch(Exception e){
            for(sObject quote : existingRenewalOpty){
                GAM.CreateExceptionRecords('reinstateContract: Error in Quote updation', e.GetMessage(), quote.Id);
            }
        }
        Set<Id> lstSubsId = new Set<Id>();
        //Updating the Subscriptions
        List<SBQQ__Subscription__c> subscriptionLst = [SELECT Id,SBQQ__RenewedDate__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =:contractId];
        for(SBQQ__Subscription__c subs: subscriptionLst){
            subs.put('SBQQ__RenewedDate__c',null);
            lstSubsId.add(subs.Id);
        }
        try {
            Database.SaveResult[] srList = Database.update(subscriptionLst, false); 
        } 
        catch(Exception e){
            for(sObject subs : subscriptionLst){
                GAM.CreateExceptionRecords('reinstateContract: Error in Subscriptions updation', e.GetMessage(), subs.Id);
            }
        } 
        //-------------------------------------------------------------------------<T1>
        if(lstSubsId != null){
            List<Unrenewed__c> lstUnrenewed = [SELECT Id FROM Unrenewed__c WHERE Subscription__c IN :lstSubsId];
            if(lstUnrenewed != null){
                for(Unrenewed__c unrenewedRec: lstUnrenewed){
                    unrenewedRec.put('Churn_Status__c',null);
                }
                try {
                    Database.SaveResult[] srList = Database.update(lstUnrenewed, false); 
                } 
                catch(Exception e){
                    for(sObject unrenewedRec : lstUnrenewed){
                        GAM.CreateExceptionRecords('reinstateContract: Error in Unrenewed updation', e.GetMessage(), unrenewedRec.Id);
                    }
                } 
            }
        }
        //-------------------------------------------------------------------------</T1>
        //Updating the contract 
        Contract contractRec = [SELECT Id,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,SBQQ__RenewalOpportunity__c FROM Contract WHERE Id =: contractId]; 
        contractRec.put('SBQQ__RenewalForecast__c',false);
        contractRec.put('SBQQ__RenewalQuoted__c',false);
        contractRec.put('SBQQ__RenewalOpportunity__c','');
        try {
            Database.SaveResult sContract = Database.update(contractRec,false);  
        } 
        catch(Exception e){
            GAM.CreateExceptionRecords('reinstateContract: Error in contract updation', e.GetMessage(), contractRec.Id);
        }
        createNewRenewalQuote(contractId);
    }    
}