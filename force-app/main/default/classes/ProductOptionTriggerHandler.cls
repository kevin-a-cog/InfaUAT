/*
Class:          ProductOptionTriggerHandler
@Author:        Ramya Ravi
@Created Date:  27/10/2020
@Description:   Handler class for SBQQ__ProductOption__c triggers
As a part of jira PNP-176
*/

public with sharing class ProductOptionTriggerHandler {
    
    public static void handleAfterInsert (List<SBQQ__ProductOption__c> mapNew){
        checkSumOfPercentageAllocation(mapNew, false);     
    }
    public static void handleAfterUpdate (List<SBQQ__ProductOption__c> mapNew){
        checkSumOfPercentageAllocation(mapNew, false);     
    }
    public static void handleBeforeDelete (List<SBQQ__ProductOption__c> mapOld){
        checkSumOfPercentageAllocation( mapOld , true );     
    }
    /**
* this method checks if the sum of the Percentage allocated field on Product Option is equal to 100% 
* else throws Error  
* @param parameter- mapNew - map of new Opportunities Line Item
* @param parameter- mapOld - map of old Opportunities Line Item
* @return return- void
* @throws Error
*/
    static void checkSumOfPercentageAllocation(List<SBQQ__ProductOption__c> mapNew, Boolean IsDelete){
        
        Set<Id> prodIdSet = new Set<Id>();
        List<Product2> productList= new list<Product2>();
        List<AggregateResult> AggregatePOList = new LIST<AggregateResult> (); 
        Map<Id, Decimal> POMap = new  Map<Id, Decimal>();
        Decimal TotalValue ;
        
        //iterate through the line items in the transaction and populate the map 
        for(SBQQ__ProductOption__c trigvalue : mapNew)
        {  
            if(trigvalue.SBQQ__ConfiguredSKU__c!=null) prodIdSet.add(trigvalue.SBQQ__ConfiguredSKU__c); 
            system.debug('prodIdSet>>'+prodIdSet);
        }  
        AggregatePOList  = [select SBQQ__ConfiguredSKU__c  , sum(Percentage_Allocation__c) Res from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c =:prodIdSet and SBQQ__ConfiguredSKU__r.package__c = true  and is_child__c = true and SBQQ__Feature__r.name='Allocation' and Percentage_Allocation__c!=null group by SBQQ__ConfiguredSKU__c  ] ;   
        system.debug('AggregatePOList>>'+AggregatePOList);
        if(AggregatePOList.size()>0){
            for(AggregateResult aggregateval : AggregatePOList)
            {  
                Id ConfiguredSKU = (Id) aggregateval.get('SBQQ__ConfiguredSKU__c');
                Decimal Res = (Decimal) aggregateval.get('Res');  
                
                  if(Res==null)
                {
                    POMap.put(ConfiguredSKU, (Decimal) 0);  
                }
                else {POMap.put(ConfiguredSKU, Res);    }  
            }
        }
        
        for(SBQQ__ProductOption__c trigval : mapNew)
        {
            if(POMap.containsKey(trigval.SBQQ__ConfiguredSKU__c) )
            {
                if(!IsDelete && Integer.valueOf(POMap.get(trigval.SBQQ__ConfiguredSKU__c)) > 100) 
                {
                    trigval.addError('Sum of the percentage allocation on Child SKUs of the product must be equal to 100%');
                }
                else
                {
                    Product2 ProductUpdate = new Product2(id= trigval.SBQQ__ConfiguredSKU__c , Check_Allocation1__c	 = Integer.valueOf(POMap.get(trigval.SBQQ__ConfiguredSKU__c)));
                    productlist.add(ProductUpdate);   
                }
            }
            
             if(AggregatePOList.size()==0)
        {
              Product2 ProductUpdate = new Product2(id= trigval.SBQQ__ConfiguredSKU__c , Check_Allocation1__c	 = null );
                    productlist.add(ProductUpdate);  
        }
        }
        
        
        
        system.debug('productlist'+productlist);
        Set<Product2> myset = new Set<Product2>();
        List<Product2> result = new List<Product2>();
        myset.addAll(productlist);
        result.addAll(myset);
        system.debug(result);
        
       
        Database.SaveResult[] srListOpptyLI = Database.update(result,false);          
        system.debug('srListProductList>>'+srListOpptyLI);
        if(productList.size()>0){
            globalApexManager GAM = new globalApexManager();
            GAM.CreateLogs('ProductUpdate',result,'ProductUpdate');
            try{ 
                GAM.InsertDebugLogs();
                
            }
            Catch(Exception e){
                for(Product2 prd :result){
                    GAM.CreateExceptionRecords('ProductUpdate', e.GetMessage(),prd.Id);
                }
            }
        }        
    }
  
}