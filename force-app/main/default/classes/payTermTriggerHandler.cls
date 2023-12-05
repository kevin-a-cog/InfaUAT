/*
        Class:            payTermTriggerHandler
        @Author:          RamEsh M S
        @Created Date:    17 July 2020
        @Description:     SALESRT-12173
                          This handler class is to fire validation on Payment Term creation/update when the Start Date/End Date is overlapping with existing Payment Terms of QUOTE/ORDER. 
                          This handler class will not fire on Amendment when we copy Payment Terms (while creation of Amend Quote) as they will be intact with new Amend Quote/Order.
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                                      Tag

RamEsh M S                02-12-2020                                Tech Debt                    Bypass validation when recreating order for Cancelled one                        <T01>
                                                                                                 deactivated validation rule "Order_Cannot_be_Changed"
********************************************************************************************************************************************************************************************************************
*/
public class payTermTriggerHandler{
    public static globalApexManager GAM = new globalApexManager();
    
    
    public static void payTermTriggerBeforeInsert(List<Payment_Term__c > newList)
    {
        
            Set<Id> orderIds = new Set<Id> ();
            Set<Id> quoteIds = new Set<Id> ();
            for(Payment_Term__c PT : newList)
            {
                if(PT.Order__c != null)
                    orderIds.add(PT.Order__c);
                else if(PT.Quote__c != null)
                    quoteIds.add(PT.Quote__c);
            }
            
            //Iterate through existing Payment Terms associated with the Quote/Order of context Payment Term and check for overlapping of dates. Doing this in Before Insert to exclude context record.
               
            for(Payment_Term__c PTexist : [Select Id,End_Date__c,Order__c,Quote__c,Payment_Term__c,Start_Date__c from Payment_Term__c where Order__c =: orderIds OR Quote__c =: quoteIds])
            {
                for(Payment_Term__c PTnew : newList)
                {
                    if((PTnew.Order__c == PTexist.Order__c && PTnew.Order__c != null) || (PTnew.Quote__c == PTexist.Quote__c && PTnew.Quote__c != null))
                    {
                        if((PTnew.Start_Date__c >= PTexist.Start_Date__c && PTnew.Start_Date__c  <= PTexist.End_Date__c) || (PTnew.End_Date__c >= PTexist.Start_Date__c && PTnew.End_Date__c <= PTexist.End_Date__c) || (PTnew.Start_Date__c < PTexist.Start_Date__c && PTnew.End_Date__c > PTexist.End_Date__c))
                            PTnew.addError(Label.PaymentTermError);
                    }
                }
            }
        
    }
    
    public static void payTermTriggerBeforeUpdate(Map<Id,Payment_Term__c > newMap,Map<Id,Payment_Term__c > oldMap)
    {
        
            Set<Id> orderIds = new Set<Id> ();
            Set<Id> quoteIds = new Set<Id> ();
           
            for(Id PTId : newMap.keySet())
            {
                if(newMap.get(PTId).Order__c != null)
                    orderIds.add(newMap.get(PTId).Order__c);
                else if(newMap.get(PTId).Quote__c != null)
                    quoteIds.add(newMap.get(PTId).Quote__c);
                if(!system.isFuture()) //<T01>
                {
                        if((newMap.get(PTId).Order__c != oldMap.get(PTId).Order__c && oldMap.get(PTId).Order__c != null) || (newMap.get(PTId).Quote__c != oldMap.get(PTId).Quote__c && oldMap.get(PTId).Quote__c != null))
                            newMap.get(PTId).addError('Quote OR Order cannot be changed.');
                }
            }
            
            //Iterate through existing Payment Terms associated with the Quote/Order of context Payment Term and check for overlapping of dates. Doing this in Before Update if there is only change on Date(s) and excluding context record.
                
            for(Payment_Term__c PTexist : [Select Id,End_Date__c,Quote__c,Order__c,Payment_Term__c,Start_Date__c from Payment_Term__c where Order__c =: orderIds OR Quote__c =: quoteIds])
            {
                for(Id PTId : newMap.keySet())
                {
                    if(((newMap.get(PTId).Order__c == PTexist.Order__c && newMap.get(PTId).Order__c != null) || (newMap.get(PTId).Quote__c == PTexist.Quote__c && newMap.get(PTId).Quote__c != null)) && (newMap.get(PTId).Start_Date__c != oldMap.get(PTId).Start_Date__c || newMap.get(PTId).End_Date__c != oldMap.get(PTId).End_Date__c) && PTexist.Id != PTId)
                    {
                        if((newMap.get(PTId).Start_Date__c >= PTexist.Start_Date__c && newMap.get(PTId).Start_Date__c  <= PTexist.End_Date__c) || (newMap.get(PTId).End_Date__c >= PTexist.Start_Date__c && newMap.get(PTId).End_Date__c <= PTexist.End_Date__c) || (newMap.get(PTId).Start_Date__c < PTexist.Start_Date__c && newMap.get(PTId).End_Date__c > PTexist.End_Date__c))
                            newMap.get(PTId).addError(Label.PaymentTermError);
                    }
                    
                }
            }
    }
    
}