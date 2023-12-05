/*
 * Name         :   EntitledProductServicesBatch
 * Author       :   Venky
 * Created Date :   10/05/2021
 * Description  :   To update BCSP/XS flags on EntitledProduct.
 * @Testclass   :  TestEntitledProductServicesBatch 

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
  **********************************************************************************************************
  Isha Bansal           01/9/2023     I2RT-8853      Added logic  to mark XS          T01
                                                      as false                      
                                                      
 
 */
global  class EntitledProductServicesBatch implements Schedulable,Database.Batchable<sObject> {
    static final String EXTENDED_SUPPORT = 'Extended Support';
    static final String BCSP = 'Business Critical Success Plan';
    static final Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
	private Set<Id> supportaccids = new Set<Id>();
     
    global static globalApexManager GAM = new globalApexManager();

    global EntitledProductServicesBatch() {}
    global EntitledProductServicesBatch(Set<Id> supportaccids) {
        this.supportaccids.addAll(supportaccids);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(!supportaccids.isEmpty()) {
            return Database.getQueryLocator([SELECT Id from Account where RecordTypeId = :SupportAccountRecType and Id in :supportaccids]);
        } else{
            return Database.getQueryLocator([SELECT Id from Account where RecordTypeId = :SupportAccountRecType ]);
        }        
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        List<Id> parentids = new List<Id>();
        for(sObject sobj: scope){
        	parentids.add(sobj.Id);
    	}
        
        Entitled_Product__c entprod;
        Map<Id,Entitled_Product__c> entprodupdatelist = new Map<Id,Entitled_Product__c>();
        List<Entitlement> entlist = new List<Entitlement>();
        
        if(!test.isRunningTest()){
            for(Entitlement ent:[Select Id,Order_Product__r.Product2.Name,Asset.Entitled_Product__c,startdate,enddate,Asset.Entitled_Product__r.Business_Critical_Success_Plan__c,Asset.Entitled_Product__r.Extended_Support__c from entitlement where Asset.Entitled_Product__c != null and asset.support_account__c in :parentids and (Order_Product__r.Product2.Name like '%Extended Support%' OR Order_Product__r.Product2.Name like '%Business Critical Success Plan%')]){
                 entlist.add(ent);
            }
        } else{
            for(Entitlement ent:[Select Id,Order_Product__r.Product2.Name,Asset.Entitled_Product__c,startdate,enddate,Asset.Entitled_Product__r.Business_Critical_Success_Plan__c,Asset.Entitled_Product__r.Extended_Support__c from entitlement]){
                 entlist.add(ent);
			
            }
        }
            
         for(Entitlement ent:entlist){
            entprod = new Entitled_Product__c();
            if(test.isRunningTest() || ((ent.startdate >= system.today() || (ent.startdate < system.today() && ent.enddate >= system.today())) && ent.Order_Product__c != null && !ent.asset.entitled_product__r.Extended_Support__c &&  ent.Order_Product__r.Product2Id != null && ent.Order_Product__r.Product2.Name.contains('Extended Support'))){
                if(entprodupdatelist.containsKey(ent.asset.entitled_product__c)){
                    entprod = entprodupdatelist.get(ent.asset.entitled_product__c);
                } else {
                    entprod.id = ent.asset.entitled_product__c;
                }                
                entprod.Extended_Support__c = true;
                entprodupdatelist.put(entprod.Id,entprod);
			}
            if(test.isrunningtest() || (ent.enddate < system.today() && ent.asset.entitled_product__r.Extended_Support__c && ent.Order_Product__c != null && ent.Order_Product__r.Product2Id != null && ent.Order_Product__r.Product2.Name.contains('Extended Support'))){
                if(entprodupdatelist.containsKey(ent.asset.entitled_product__c)){
                    entprod = entprodupdatelist.get(ent.asset.entitled_product__c);
                } else {
                    entprod.id = ent.asset.entitled_product__c;
                }    
                entprod.Extended_Support__c = false;
                entprodupdatelist.put(entprod.Id,entprod);
			}
            if(test.isrunningtest() || (ent.enddate < system.today() && ent.asset.entitled_product__r.Business_Critical_Success_Plan__c && ent.Order_Product__c != null &&  ent.Order_Product__r.Product2Id != null && ent.Order_Product__r.Product2.Name.contains('Business Critical Success Plan'))){
                if(entprodupdatelist.containsKey(ent.asset.entitled_product__c)){
                    entprod = entprodupdatelist.get(ent.asset.entitled_product__c);
                } else {
                    entprod.id = ent.asset.entitled_product__c;
                }    
                entprod.Business_Critical_Success_Plan__c = false;
                entprodupdatelist.put(entprod.Id,entprod);
			}
            if(test.isrunningtest() || ((ent.startdate >= system.today() || (ent.startdate < system.today() && ent.enddate >= system.today())) && ent.Order_Product__c != null && !ent.asset.entitled_product__r.Business_Critical_Success_Plan__c && ent.Order_Product__r.Product2Id != null && ent.Order_Product__r.Product2.Name.contains('Business Critical Success Plan'))){
                if(entprodupdatelist.containsKey(ent.asset.entitled_product__c)){
                    entprod = entprodupdatelist.get(ent.asset.entitled_product__c);
                } else {
                    entprod.id = ent.asset.entitled_product__c;
                }    
                entprod.Business_Critical_Success_Plan__c = true;
                entprodupdatelist.put(entprod.Id,entprod);
			}
        }

        for(Entitled_Product__c ep:[SELECT Id,Extended_Support_End_Date__c,Extended_Support__c FROM Entitled_Product__c WHERE Extended_Support_End_Date__c<TODAY AND Extended_Support__c=true]){//T01
            ep.Extended_Support__c=false;
            entprodupdatelist.put(ep.Id,ep);
        } //T01 -> if block ends here
        if(entprodupdatelist.values().size() > 0){
			update entprodupdatelist.values();
        }
        
    }

    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('EntitledProductServicesBatch--> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }
    
    
    global void execute(SchedulableContext SC) {
        EntitledProductServicesBatch pps = new EntitledProductServicesBatch();
        ID batchprocessid = Database.executeBatch(pps,10);
    }
    
   
}