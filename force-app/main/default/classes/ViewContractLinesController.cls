/*
        Class:        ViewContractLinesController
        @Author:        Michael Bruch/Kiran G
        @Created Date:  15 May 2019
        @Description:   To view contract lines from a renewal quote
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                           Tag
    
    Kiran G        9 Jul 2019     QCA-153         Samyak        Added the logic to display the Original COntract details when toggeled 
    Ambica 			   2 feb 2020     SALESRT-11446   Ken			      Added PRIOR UPLIFT & RENEWAL NOTES to the wrapper
    Chandana      21 May 2020     SALESRT-11796                 Added Renewal Year,Offering Id,Description and Old Org Order Number        T01
    ********************************************************************************************************************************************
*/

 public with sharing class ViewContractLinesController{
    //public string quoteId {get;set;} 
    @AuraEnabled
    public static List<QuoteLinesWrapper> getQuoteLinesWrapper (String quoteID) {
        
        Id oquoteId = (Id)quoteID;
        //system.debug('--SBQQ__Quote ID' +oquoteId );
        List<QuoteLinesWrapper> qlWrapperList= new List<QuoteLinesWrapper>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
                          
        Set<Id> contractSet = new Set<Id>();                      
    
        //System.debug('paramID: '+paramID+'##oquoteId: '+oquoteId);
        if (oquoteId != null) {
            quoteLineList = [SELECT Id, Name, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__ProductName__c, SBQQ__ProductCode__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, SBQQ__EndDate__c,         SBQQ__ListPrice__c, SBQQ__Quantity__c, SBQQ__NetTotal__c,Original_Quote_Id__c,
                          SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,
                          SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.Name,SBQQ__RenewedSubscription__r.SBQQ__ProductName__c, SBQQ__RenewedSubscription__r.SBQQ__Contract__c, SBQQ__RenewedSubscription__r.SBQQ__Contract__r.ContractNumber,SBQQ__RenewedSubscription__r.Term__c,
                          SBQQ__RenewedSubscription__r.SBQQ__StartDate__c, SBQQ__RenewedSubscription__r.SBQQ__EndDate__c, SBQQ__RenewedSubscription__r.SBQQ__Quantity__c,SBQQ__RenewedSubscription__r.Net_Value__c,
                          SBQQ__RenewedSubscription__r.SBQQ__ListPrice__c, SBQQ__RenewedSubscription__r.SBQQ__NetPrice__c,SBQQ__RenewedSubscription__r.Old_Org_Order_Number__c,SBQQ__Number__c ,SBQQ__RequiredBy__c, Line_level_Uplift__c,Prior_Uplift__c, Uplift_Notes__c,Renewal_Year__c,Offering_ID__c,SBQQ__Description__c 
                          FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :oquoteId ORDER BY SBQQ__Number__c,SBQQ__OptionLevel__c];      
        }
        system.debug('quoteLineList '+ quoteLineList );
        List<SBQQ__QuoteLine__c> lstDelPriorOrigialQLI = new List<SBQQ__QuoteLine__c>();
        Id priorQuoteId ;
        Id originalQuoteId ;
        Id originalQuoteLineId ;
        Set<Id> setUniqueOriginalIds = new Set<Id>();
        Set<Id> setUniqueOriginalQuoteIds = new Set<Id>();
        //Get prior quote id and original quote id to display deleted QLE on renewal .        
        Set<Id> orginialQuoteLineIds = new Set<Id>();
        
        for(SBQQ__QuoteLine__c quoteLine:quoteLineList){            
            if(quoteLine.Original_Quote_Id__c != null){
                if(quoteLine.SBQQ__RenewedSubscription__c != null){
                    priorQuoteId = quoteLine.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c;
                }
                originalQuoteLineId = quoteLine.Original_Quote_Id__c ;
                //system.debug('--QuoteLineId' +originalQuoteLineId );
                
                setUniqueOriginalIds.add(originalQuoteLineId );
            }
        }  
        //system.debug('--setUniqueOriginalIds' +setUniqueOriginalIds);
        
        List<SBQQ__QuoteLine__c> originalQuote = new List<SBQQ__QuoteLine__c>();
        if(setUniqueOriginalIds != null){      
            originalQuote = [Select Id,SBQQ__Quote__c from SBQQ__QuoteLine__c where Original_Quote_Id__c =: setUniqueOriginalIds];             
        }
        system.debug('--SBQQ__Quote ID' +oquoteId );
        for(SBQQ__QuoteLine__c oriQuote : originalQuote ){
            if(oriQuote.SBQQ__Quote__c != oquoteId ){
                setUniqueOriginalQuoteIds.add(oriQuote.SBQQ__Quote__c);
            }
        }
        //system.debug('--setUniqueOriginalQuoteIds' +setUniqueOriginalQuoteIds);
        
        //originalQuoteId = originalQuote[0].SBQQ__Quote__c;
        
        // Add the Quote Id to set to query all the Quote LInes
        Set<Id> setPriorOriginalQLI = new Set<Id>();        
        setPriorOriginalQLI.add(priorQuoteId);
        setPriorOriginalQLI.addall(setUniqueOriginalQuoteIds);
        
        //system.debug('--setPriorOriginalQLI' +setPriorOriginalQLI);
        
        // Query all quote lines of Prior QUote and Original Quote
        if(setPriorOriginalQLI != null){
            lstDelPriorOrigialQLI = [SELECT Id, Name, SBQQ__Product__c, SBQQ__Product__r.Name,SBQQ__ProductName__c, SBQQ__ProductCode__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, SBQQ__EndDate__c,         SBQQ__ListPrice__c, SBQQ__Quantity__c, SBQQ__NetTotal__c,Original_Quote_Id__c,
                              SBQQ__Quote__r.SBQQ__SubscriptionTerm__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,
                              SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.Name,SBQQ__RenewedSubscription__r.SBQQ__ProductName__c, SBQQ__RenewedSubscription__r.SBQQ__Contract__c, SBQQ__RenewedSubscription__r.SBQQ__Contract__r.ContractNumber,SBQQ__RenewedSubscription__r.Term__c,
                              SBQQ__RenewedSubscription__r.SBQQ__StartDate__c, SBQQ__RenewedSubscription__r.SBQQ__EndDate__c, SBQQ__RenewedSubscription__r.SBQQ__Quantity__c,
                              SBQQ__RenewedSubscription__r.SBQQ__ListPrice__c, SBQQ__RenewedSubscription__r.SBQQ__NetPrice__c,SBQQ__RenewedSubscription__r.Old_Org_Order_Number__c,SBQQ__Number__c ,SBQQ__RequiredBy__c, Line_level_Uplift__c,Prior_Uplift__c, Uplift_Notes__c,Renewal_Year__c,Offering_ID__c,SBQQ__Description__c
                              FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :setPriorOriginalQLI ORDER BY SBQQ__Number__c ];
        }     
        //Create a map of Quote lines of current quote with Product Name as key            
        Map<String,SBQQ__QuoteLine__c> mapOfOriginalQLI = new Map<String,SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c lstQle : quoteLineList){
            mapOfOriginalQLI.put(lstQle.SBQQ__Product__r.Name,lstQle);
        }
        //Check if current quote contains the products of Prior Quote and Original QUote , if not add it to current quote list 
        for(SBQQ__QuoteLine__c delQLI:lstDelPriorOrigialQLI){
            if(!mapOfOriginalQLI.containsKey(delQLI.SBQQ__Product__r.Name)){
                system.debug('delQLI.SBQQ__Product__r.Name'+ delQLI.SBQQ__Product__r.Name);
                quoteLineList.add(delQLI);
            }
        }

        //Get all the twin field Id from Quote Lien
        for(SBQQ__QuoteLine__c quoteLine:quoteLineList){
            if(quoteLine.Original_Quote_Id__c != null)
                orginialQuoteLineIds.add(quoteLine.Original_Quote_Id__c);
        }
        
        //system.debug('orginialQuoteLineIds'+ orginialQuoteLineIds);
        
        //Query all hte subscriptions using the Twin field value         
        Map<String, SBQQ__Subscription__c> mapOfOriginalQLISubs = new Map<String, SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> lstOfSubscriptions =  new List<SBQQ__Subscription__c>();
        lstOfSubscriptions = [SELECT Id, Name, SBQQ__OriginalQuoteLine__c, SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__ProductName__c, SBQQ__Contract__c,Original_Quote_Id__c,
                                SBQQ__Contract__r.ContractNumber, SBQQ__Number__c, Term__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__ListPrice__c,
                                SBQQ__NetPrice__c, Net_Value__c,Old_Org_Order_Number__c                                
                                FROM SBQQ__Subscription__c where Original_Quote_Id__c IN :orginialQuoteLineIds ORDER BY SBQQ__QuoteLine__c DESC];
        
        for(SBQQ__Subscription__c subs : lstOfSubscriptions){
            mapOfOriginalQLISubs.put(subs.Original_Quote_Id__c,subs);
        }
        //system.debug('++++Subscriptions'+mapOfOriginalQLISubs);
        
        // Lop over all the quote lines and assing the values to wrapper class variables.
        //New lines will show up in the component with prior and orginal section blank
        //In case of deleted line prior/original section will show up the value with current section value as blank.
        
        //system.debug('quoteLineListbeforeloop '+ quoteLineList );
        
        for(SBQQ__QuoteLine__c quoteLine:quoteLineList)
        {
          QuoteLinesWrapper qlWrapper= new QuoteLinesWrapper();
          if(quoteLine.Id != null)
            qlWrapper.quoteLineId= quoteLine.Id;
            
          if(quoteLine.Name != null)
            qlWrapper.quoteLineName= quoteLine.Name;
            
          if(quoteLine.SBQQ__Product__c != null)    
            qlWrapper.productId= quoteLine.SBQQ__Product__c;
            
          if(quoteLine.SBQQ__Product__r.Name != null)
            qlWrapper.productName= quoteLine.SBQQ__Product__r.Name;
                        
          if(quoteLine.Line_level_Uplift__c != null)
            qlWrapper.uplift= quoteLine.Line_level_Uplift__c/100;
            
          if(quoteLine.Prior_Uplift__c != null)
            qlWrapper.priorUplift= quoteLine.Prior_Uplift__c/100;
            
          if(quoteLine.Uplift_Notes__c != null)
           qlWrapper.renewalNotes= quoteLine.Uplift_Notes__c;
            
          if(quoteLine.SBQQ__ProductCode__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c) )
            qlWrapper.productCode= quoteLine.SBQQ__ProductCode__c;
            
          if(quoteLine.SBQQ__SubscriptionTerm__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c) )
            qlWrapper.subscriptionTerm= String.valueOf(quoteLine.SBQQ__SubscriptionTerm__c);
            
          if(quoteLine.SBQQ__StartDate__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.startDate= String.valueOf(quoteLine.SBQQ__StartDate__c);
            
          if(quoteLine.SBQQ__EndDate__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.endDate= String.valueOf(quoteLine.SBQQ__EndDate__c);
            
          if(quoteLine.SBQQ__Quantity__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quantity= String.valueOf(quoteLine.SBQQ__Quantity__c);
            
          if(quoteLine.SBQQ__ListPrice__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.listPrice= String.valueOf(quoteLine.SBQQ__ListPrice__c);
            
          if(quoteLine.SBQQ__NetTotal__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId  && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.extendedPrice= String.valueOf(quoteLine.SBQQ__NetTotal__c);
            
          if(quoteLine.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quoteSubscriptionTerm= String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c);
            
          if(quoteLine.SBQQ__Quote__r.SBQQ__StartDate__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId  && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quoteStartDate= String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__StartDate__c);
          
          if(quoteLine.SBQQ__Quote__r.SBQQ__EndDate__c != null)
            qlWrapper.quoteEndDate= String.valueOf(quoteLine.SBQQ__Quote__r.SBQQ__EndDate__c);
          
          //---------------------------------------------------------------------------------------------------<T01>
          if(quoteLine.Offering_ID__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId  && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quoteLineOfferingID= String.valueOf(quoteLine.Offering_ID__c); 
            
          if(quoteLine.Renewal_Year__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId  && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quoteLineRenewalYear= String.valueOf(quoteLine.Renewal_Year__c); 
            
          if(quoteLine.SBQQ__Description__c != null && quoteLine.SBQQ__Quote__c != priorQuoteId  && !setUniqueOriginalQuoteIds.contains(quoteLine.SBQQ__Quote__c))
            qlWrapper.quoteLineDescription= String.valueOf(quoteLine.SBQQ__Description__c).stripHtmlTags();    
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorOldOrgOrderNumber= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.Old_Org_Order_Number__c);            
          //---------------------------------------------------------------------------------------------------<T01/>            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorContractId= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__Contract__c); 
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorContractName= quoteLine.SBQQ__RenewedSubscription__r.SBQQ__Contract__r.ContractNumber;
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorContractLineId= quoteLine.SBQQ__RenewedSubscription__c;
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorContractLineName= quoteLine.SBQQ__RenewedSubscription__r.Name;
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorProductName= quoteLine.SBQQ__RenewedSubscription__r.SBQQ__ProductName__c;
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorSubscriptionTerm= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.Term__c);
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorStartDate= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__StartDate__c);
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)      
            qlWrapper.priorEndDate= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__EndDate__c);
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorQuantity= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__Quantity__c);
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorListPrice= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__ListPrice__c);
            
          if(quoteLine.SBQQ__RenewedSubscription__c != null)
            qlWrapper.priorExtendedPrice= String.valueOf(quoteLine.SBQQ__RenewedSubscription__r.SBQQ__NetPrice__c);            
            
          if(mapOfOriginalQLISubs != null && mapOfOriginalQLISubs.size() > 0 && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c) != null){
            if(quoteLine.Original_Quote_Id__c != null  && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Contract__r.Id != null)
              qlWrapper.originalContractId=  mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Contract__r.Id;
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Contract__r.ContractNumber != null )     
              qlWrapper.originalContractName= mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Contract__r.ContractNumber;
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Id != null)
              qlWrapper.originalContractLineId= mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Id;
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Name != null)
              qlWrapper.originalContractLineName= mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Name;
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__ProductName__c != null)
              qlWrapper.originalProductName= mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__ProductName__c;
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Term__c != null)
              qlWrapper.originalSubscriptionTerm= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Term__c);
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__StartDate__c != null)
              qlWrapper.originalStartDate= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__StartDate__c);
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__EndDate__c != null)
              qlWrapper.originalEndDate= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__EndDate__c);
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Quantity__c != null)
              qlWrapper.originalQuantity= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__Quantity__c);
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__ListPrice__c != null)
              qlWrapper.originalListPrice= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__ListPrice__c);
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__NetPrice__c != null)
              qlWrapper.originalExtendedPrice= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).SBQQ__NetPrice__c);  
              
            if(quoteLine.Original_Quote_Id__c != null && mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Old_Org_Order_Number__c != null) //<T01/>
              qlWrapper.originalOldOrgOrderNumber= String.valueOf(mapOfOriginalQLISubs.get(quoteLine.Original_Quote_Id__c).Old_Org_Order_Number__c);               
          }
          if(quoteLine.SBQQ__RequiredBy__c != null)
              qlWrapper.requiredBy = String.valueOf(quoteLine.SBQQ__RequiredBy__c);                    
         
          System.debug('#####'+qlWrapper);
          qlWrapperList.add(qlWrapper);      
        }
        
        return qlWrapperList; 
    }

    public class QuoteLinesWrapper { 
                 
        @AuraEnabled public String quoteLineId {get; set;}
        @AuraEnabled public String quoteLineName {get; set;}
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String productCode {get; set;}
        @AuraEnabled public String subscriptionTerm {get; set;}
        @AuraEnabled public String startDate {get; set;}
        @AuraEnabled public String endDate {get; set;}
        @AuraEnabled public String quantity {get; set;}
        @AuraEnabled public String listPrice {get; set;}
        @AuraEnabled public String extendedPrice {get; set;}
        @AuraEnabled public String quoteSubscriptionTerm {get; set;}
        @AuraEnabled public String quoteStartDate {get; set;}
        @AuraEnabled public String quoteEndDate {get; set;}
        @AuraEnabled public String priorContractId {get; set;}
        @AuraEnabled public String priorContractName {get; set;}
        @AuraEnabled public String priorContractLineId {get; set;}
        @AuraEnabled public String priorContractLineName {get; set;}
        @AuraEnabled public String priorProductName{get; set;}        
        @AuraEnabled public String priorSubscriptionTerm {get; set;}
        @AuraEnabled public String priorStartDate {get; set;}
        @AuraEnabled public String priorEndDate {get; set;} 
        @AuraEnabled public String priorQuantity {get; set;} 
        @AuraEnabled public String priorListPrice {get; set;}
        @AuraEnabled public String priorExtendedPrice {get; set;}
        @AuraEnabled public String originalContractId {get; set;}
        @AuraEnabled public String originalContractName {get; set;}
        @AuraEnabled public String originalContractLineId {get; set;}
        @AuraEnabled public String originalContractLineName {get; set;}
        @AuraEnabled public String originalProductName{get; set;} 
        @AuraEnabled public String originalSubscriptionTerm {get; set;}
        @AuraEnabled public String originalStartDate {get; set;}
        @AuraEnabled public String originalEndDate {get; set;} 
        @AuraEnabled public String originalQuantity {get; set;} 
        @AuraEnabled public String originalListPrice {get; set;}
        @AuraEnabled public String originalExtendedPrice {get; set;}
        @AuraEnabled public String requiredBy{get; set;} 
        @AuraEnabled public double uplift{get; set;}      
        @AuraEnabled public double priorUplift{get; set;}      
        @AuraEnabled public String renewalNotes{get; set;}
        @AuraEnabled public String quoteLineRenewalYear {get; set;} //<T01/>
        @AuraEnabled public String quoteLineOfferingID {get; set;}
        @AuraEnabled public String quoteLineDescription {get; set;}  
        @AuraEnabled public String priorOldOrgOrderNumber {get; set;} 
        @AuraEnabled public String originalOldOrgOrderNumber {get; set;}     
    }  
}