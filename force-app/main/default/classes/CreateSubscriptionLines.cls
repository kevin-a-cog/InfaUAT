/*
* Class :        CreateSubscriptionLines
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for SubscriptionLine Creation 
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************

*/
public class CreateSubscriptionLines {
    
    public static globalApexManager GAM = new globalApexManager();

    
    public static void CreateNewSubscriptionLines(List<SBQQ__Subscription__c> lstNewSubscriptions){
        //Map of Quote Line Id with Subscription Id
        Map<Id,Id> mapQuoteLineSubscription =  new Map<Id,Id> ();
        //Map of Subscription Id with Renewed Subscription Id
        Map<Id,Id> mapRenewedSubscription = new  Map<Id,Id> ();
        //Map of Subscription Id with Upgraded Subscription Id
        Map<Id,Id> mapUpgradedSubscription = new  Map<Id,Id>();
        //Map of Subscription Id with Related Subscription Line Id
        Map<Id,Id> mapRelatedSubLine = new Map<Id,Id>();
        //List of Subscription lines to be inserted
        List<Subscription_Line__c> lstInsertSubscriptionLine = new List<Subscription_Line__c>();
        //Map of Subscriptions
        Map<Id,SBQQ__Subscription__c> mapNewSubscription= new map<Id,SBQQ__Subscription__c>(lstNewSubscriptions);
       
        //Get related QuoteLines
        for(SBQQ__Subscription__c sub : lstNewSubscriptions){
            
            if(sub.SBQQ__QuoteLine__c!= null){
                mapQuoteLineSubscription.put(sub.SBQQ__QuoteLine__c,sub.id);
            }
            
        }
        
        //Get Renewed/Upgraded subscription for each subscription using quote line
        for(SBQQ__QuoteLine__c QL : [Select Id, SBQQ__RenewedSubscription__c,SBQQ__UpgradedSubscription__c from SBQQ__Quoteline__c where id in: mapQuoteLineSubscription.keyset()]){
            
            if( QL.SBQQ__RenewedSubscription__c != null){
                mapRenewedSubscription.put(mapQuoteLineSubscription.get(QL.Id),QL.SBQQ__RenewedSubscription__c);
            }
            
            if( QL.SBQQ__UpgradedSubscription__c != null){
                mapUpgradedSubscription.put(mapQuoteLineSubscription.get(QL.Id),QL.SBQQ__UpgradedSubscription__c);
            }
        }
         
        //get related Subscription Line for Renewed or Upgraded Subscriptions
        for(Subscription_Line__c subline : [Select Id, Subscription__c from Subscription_Line__c where Subscription__c in :mapRenewedSubscription.values() or Subscription__c in :mapUpgradedSubscription.values() or Subscription__c in :mapNewSubscription.keyset() ]){
            mapRelatedSubLine.put(subline.Subscription__c,subline.Id);
        }
        
        
        for(SBQQ__Subscription__c sub : lstNewSubscriptions){
            
            if(!mapRelatedSubLine.containskey(Sub.id)){
                
            Subscription_Line__c subLine = new Subscription_Line__c();
            subLine.Subscription__c = sub.id;
            subLine.Contract__c = sub.SBQQ__Contract__c;
            subLine.Product__c = sub.SBQQ__Product__c;
            subLine.Start_Date__c = sub.SBQQ__StartDate__c;
            subLine.End_Date__c = sub.SBQQ__EndDate__c;
            subLine.Quantity__c = sub.SBQQ__Quantity__c;
            subLine.CurrencyIsoCode = sub.CurrencyIsoCode;  
            subLine.ARR__c = (sub.SBQQ__QuoteLine__c!=null && sub.SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c!=null)? sub.SBQQ__QuoteLine__r.Annual_Recurring_Revenue__c: (sub.Amendment_ARR__c!=null?sub.Amendment_ARR__c:0);
            
            if(mapRenewedSubscription.containsKey(sub.Id) && mapRelatedSubLine.containsKey(mapRenewedSubscription.get(sub.Id)))
                subLine.Renewed_Subscription_Line__c = mapRelatedSubLine.get(mapRenewedSubscription.get(sub.Id));
            
            if(mapUpgradedSubscription.containsKey(sub.Id) && mapRelatedSubLine.containsKey(mapUpgradedSubscription.get(sub.Id)))
                subLine.Upgraded_Subscription_Line__c = mapRelatedSubLine.get(mapUpgradedSubscription.get(sub.Id));
            
            lstInsertSubscriptionLine.add(subLine);
            
            }
        }
        
        system.debug('lstInsertSubscriptionLine'+lstInsertSubscriptionLine);        
        if(lstInsertSubscriptionLine!= null && lstInsertSubscriptionLine.size()>0){
             Database.SaveResult[] srList = Database.insert(lstInsertSubscriptionLine, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {					
                        GAM.CreateExceptionRecords('CreateSubscriptionLines-->CreateNewSubscriptionLines-->Insert of Subscription Lines failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        
    }
    
    public static void UpdateOrders(List<Id> OrderIds){
        
        List<Order> lstUpdateOrder = new List<order>();
        for(Id orderid : OrderIds){
            Order updateOrder = new Order (Id=orderid, Plan_Products_Created__c= true);
            lstUpdateOrder.add(updateOrder);
        }
        
        system.debug('lstUpdateOrder'+lstUpdateOrder);
        if(lstUpdateOrder!=null && lstUpdateOrder.size()>0){
            Database.SaveResult[] srList = Database.Update(lstUpdateOrder, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {					
                        GAM.CreateExceptionRecords('CreateSubscriptionLines-->updateOrders-->Order Update failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
}