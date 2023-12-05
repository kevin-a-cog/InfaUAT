/*
        Class:          LinkToRenewalContractController 
        @Author:        Ramya Ravi
        @Created Date:  11/03/2021
        @Description:   Controller for the CustomLookup lightning component
*/

public class LinkToRenewalContractController {
    public static globalApexManager GAM = new globalApexManager();
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String recordId) {
        List < sObject > returnList = new List < sObject > ();
        Set<id> contractID = new Set<id>();
        String sQuery ; 
        // Query the oppty to get primary quote
        List <Opportunity> lstOpportunity = [Select Id, SBQQ__PrimaryQuote__c From Opportunity where Id =: recordId];
        List<SBQQ__Quoteline__c> lstQuoteln = [Select id,SBQQ__RenewedSubscription__r.SBQQ__Contract__c from SBQQ__Quoteline__c  where SBQQ__Quote__c =:  lstOpportunity[0].SBQQ__PrimaryQuote__c ];
       
        for(SBQQ__Quoteline__c li:lstQuoteln)
        {contractID.add(li.SBQQ__RenewedSubscription__r.SBQQ__Contract__c);}
        //For cancelled contracts
        List<Unrenewed__c> lstUnrenewed = [Select id,Subscription__r.SBQQ__Contract__c from Unrenewed__c  where Quote__c =:  lstOpportunity[0].SBQQ__PrimaryQuote__c ];
       
        for(Unrenewed__c li:lstUnrenewed)
        {contractID.add(li.Subscription__r.SBQQ__Contract__c);}
         sQuery =  'select id, ContractNumber, Name , Status, StartDate, EndDate, Annual_Recurring_Revenue1__c, CurrencyIsoCode,  SBQQ__RenewalOpportunity__r.StageName, SBQQ__RenewalOpportunity__r.New_Org_Opportunity_Number__c  from Contract where id in : contractID  and SBQQ__RenewalOpportunity__c != : recordId '  ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        //Create a list to be returned and displayed at component level 
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        GAM.InsertDebugLogs();
        return returnList;
    }
      @AuraEnabled
    public static List < sObject > fetchLookUpValuesofCanceledcontract(String recordId) {
        List < sObject > returnList = new List < sObject > ();
        Set<id> contractID = new Set<id>();
        String sQuery ; 
        // Query the oppty to get primary quote
        List <Opportunity> lstOpportunity = [Select Id, SBQQ__PrimaryQuote__c From Opportunity where Id =: recordId];
        List<Unrenewed__c> lstUnrenewed = [Select id,Subscription__r.SBQQ__Contract__c from Unrenewed__c  where Quote__c =:  lstOpportunity[0].SBQQ__PrimaryQuote__c ];
       
        for(Unrenewed__c li:lstUnrenewed)
        {contractID.add(li.Subscription__r.SBQQ__Contract__c);}
         sQuery =  'select id, ContractNumber, Name , Status, StartDate, EndDate, Annual_Recurring_Revenue1__c ,CurrencyIsoCode,  SBQQ__RenewalOpportunity__r.StageName,  SBQQ__RenewalOpportunity__r.New_Org_Opportunity_Number__c from Contract where id in : contractID  and SBQQ__RenewalOpportunity__c != : recordId '  ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        //Create a list to be returned and displayed at component level 
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        GAM.InsertDebugLogs();
        return returnList;
    }
    @AuraEnabled
    public static List < sObject > fetchContract(String recordId, String contractNumber) {
        List < sObject > returnList = new List < sObject > ();
     
        String sQuery ; 
        
         sQuery =  'select id, ContractNumber, Name , Status, StartDate, EndDate, Annual_Recurring_Revenue1__c,CurrencyIsoCode,  SBQQ__RenewalOpportunity__r.StageName, SBQQ__RenewalOpportunity__r.New_Org_Opportunity_Number__c from Contract where ContractNumber = : contractNumber '  ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        //Create a list to be returned and displayed at component level 
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        GAM.InsertDebugLogs();
        return returnList;
    }
   
    
    // Associate the renewal oppty to the contract and update duplicate oppty
    @AuraEnabled
    public static String setRenewalOppty(string OpptyRecordId, string ContractNumber, string checkbx){  
        List<Opportunity> opptyToUpdate = new  List<Opportunity>();
        List<Id> opptyIDs = new List<Id>();
        string message;    
        Boolean repeatedflag = true;
        Boolean checkbox = Boolean.valueOf(checkbx);
        // deserialize the ContractNumber
        Type idArrType = Type.forName('List<string>');
        List<string> wrapperList = (List<string>) JSON.deserialize(ContractNumber, idArrType);        
        List <Contract> lstContract = [Select Id, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.Stage_Comment__c  From Contract where ContractNumber =: wrapperList];
        // get renewal oppty IDs
        for(Contract li:lstContract)
        {          
            // Update duplicate oppty
            if(li.SBQQ__RenewalOpportunity__c!=null && li.SBQQ__RenewalOpportunity__c != OpptyRecordId && checkbox == true)
            { Opportunity opptytemp = new Opportunity(id = li.SBQQ__RenewalOpportunity__c );            
             opptytemp.StageName = 'Duplicate' ;
             opptytemp.Stage_Comment__c = li.SBQQ__RenewalOpportunity__r.Stage_Comment__c == null ? Label.LinkToRenewalStageComment : li.SBQQ__RenewalOpportunity__r.Stage_Comment__c + '\n' + Label.LinkToRenewalStageComment;
             //SALESRT-16822
             opptytemp.Duplicate_Opportunity__c = Id.valueOf(OpptyRecordId);
             opptytemp.Renewal_Cancellation_Reason__c = 'One Time Project' ;
             opptytemp.Cancellation_Detail__c = 'Co-Term';
             if(!opptyToUpdate.contains(opptytemp))
             opptyToUpdate.add(opptytemp);}
              //link the renewal oppty to the contracts
            if(li.SBQQ__RenewalOpportunity__c!=OpptyRecordId)
            {
                li.SBQQ__RenewalOpportunity__c = OpptyRecordId;
                repeatedflag = false;
            }
        }
        
        if( repeatedflag == true)
        {
             message = 'LINKEDALREADY';   
              return message;
        }
        
        
           if(lstContract!= null && lstContract.size() > 0){
       try{
           SBQQ.TriggerControl.disable();             
           update lstContract;
           if(opptyToUpdate!= null && opptyToUpdate.size() > 0)
           {
               update opptyToUpdate;  
          }
           SBQQ.TriggerControl.enable();  
              message = 'SUCCESS' ;
             } catch(DmlException e){
                GAM.CreateExceptionRecords('LinkToRenewalContract --> updateContract', e.getMessage(), 'error from LinkToRenewalContract');
                 message = e.getMessage();
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        system.debug('message>>>>'+message);
        return message;
    }          
}