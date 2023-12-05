global class BillingEventBatch implements Database.Batchable<Sobject>{
         
    global BillingEventBatch(){
        System.debug('@Developer --> BillingEventBatch -->');
    }
         
    global Database.queryLocator start(Database.BatchableContext bc){
        System.debug('@Developer --> BillingEventBatch --> start --> timestamp:' + system.now());
        integer nHour = integer.valueof(Label.BillingEventInterval);
        Datetime dtProcessingDate = system.now().addHours(nHour*-1);
        String sSOQL = 'select Id,PSA_BE_Ready_For_Finance__c,PSA_BM_PO_Number_Current__c,pse__Project__c,pse__Billing_Event_Batch__c,(Select Id,pse__Billing_Event__c,PSA_OM_PO_Number__c From pse__Billing_Event_Items__r) From pse__Billing_Event__c Where pse__Is_Released__c =true and lastmodifieddate>=:dtProcessingDate';      
        if(test.isRunningTest()){
            sSOQL += ' limit 5 ';
        }
        System.debug('@Developer --> sSOQL:' + sSOQL);   
        return Database.getQueryLocator(sSOQL);
    }
        
    global void execute(Database.BatchableContext bc, List<pse__Billing_Event__c> scope){
        System.debug('@Developer --> BillingEventBatch --> execute --> timestamp:' + system.now());
        
        set<string> setProjectId = new set<string>();
        set<string> setBillingItem = new set<string>();
        map<string,string> mapProjectPoNumberWiseBillingEventId = new map<string,string>();
        for(pse__Billing_Event__c oBillingEvent:scope){
            setProjectId.add(oBillingEvent.pse__Project__c);
            setBillingItem.add(oBillingEvent.Id);
        }
        for(pse__Billing_Event__c oBillingEvent :[select Id,PSA_BE_Ready_For_Finance__c,PSA_BM_PO_Number_Current__c,pse__Project__c,pse__Is_Released__c From pse__Billing_Event__c Where pse__Project__c in :setProjectId and pse__Is_Released__c = true and Id not in :setBillingItem]){
            if(oBillingEvent.PSA_BM_PO_Number_Current__c!=null){
                string sKey=oBillingEvent.pse__Project__c+'-'+oBillingEvent.PSA_BM_PO_Number_Current__c;
                mapProjectPoNumberWiseBillingEventId.put(sKey,oBillingEvent.Id);
            }
        }
        list<pse__Billing_Event_Item__c> lstBillingItemReparented = new list<pse__Billing_Event_Item__c>();
        list<pse__Billing_Event__c> lstBillingEventToUpdate = new list<pse__Billing_Event__c>();
        map<string,pse__Billing_Event__c> mapNewProjectPoNumber = new map<string,pse__Billing_Event__c>();
        map<string,List<pse__Billing_Event_Item__c>> mapNewProjectPoNumberWiseItems = new map<string,List<pse__Billing_Event_Item__c>>();
        for(pse__Billing_Event__c oBillingEvent:scope){
            if(oBillingEvent.pse__Billing_Event_Items__r!=null){
                list<pse__Billing_Event_Item__c> lstBillingItemNotMatched = new list<pse__Billing_Event_Item__c>();
                for(pse__Billing_Event_Item__c oItem:oBillingEvent.pse__Billing_Event_Items__r){
                    string sKey =oBillingEvent.pse__Project__c +'-'+oItem.PSA_OM_PO_Number__c;
                    if(mapProjectPoNumberWiseBillingEventId.containsKey(sKey)){
                        string sNewBillingEventId = mapProjectPoNumberWiseBillingEventId.get(sKey);
                        if(sNewBillingEventId!=oItem.pse__Billing_Event__c){
                            oItem.pse__Billing_Event__c = sNewBillingEventId;
                            lstBillingItemReparented.add(oItem);
                        }
                    }
                    else{
                        if(oBillingEvent.PSA_BM_PO_Number_Current__c!=null){
                            if(oBillingEvent.PSA_BM_PO_Number_Current__c==oItem.PSA_OM_PO_Number__c){
                                oBillingEvent.PSA_BE_Ready_For_Finance__c = true;
                                lstBillingEventToUpdate.add(oBillingEvent);
                            }
                            else{
                                lstBillingItemNotMatched.add(oItem);
                            }
                        }
                        else{
                            oBillingEvent.PSA_BM_PO_Number_Current__c = oItem.PSA_OM_PO_Number__c;
                            oBillingEvent.PSA_BE_Ready_For_Finance__c = true;
                            mapProjectPoNumberWiseBillingEventId.put(sKey,oBillingEvent.Id);
                            lstBillingEventToUpdate.add(oBillingEvent);
                        }
                    }
                }
                if(lstBillingItemNotMatched.size()>0){
                    for(pse__Billing_Event_Item__c oItem:lstBillingItemNotMatched){
                        string sKey =oBillingEvent.pse__Project__c +'-'+oItem.PSA_OM_PO_Number__c;
                        List<pse__Billing_Event_Item__c> lstBillingItemToReparent;
                        if(!mapNewProjectPoNumber.containsKey(sKey)){
                            pse__Billing_Event__c oNewBillingEvent = oBillingEvent.clone(false,false,false,false);
                            oNewBillingEvent.Id=null;
                            oNewBillingEVent.pse__Billing_Event_Batch__c = oBillingEvent.pse__Billing_Event_Batch__c;
                            oNewBillingEvent.pse__Is_Released__c = true;
                            oNewBillingEvent.PSA_BE_Parent_Billing_Event__c = oBillingEvent.Id;
                            oNewBillingEvent.PSA_BM_PO_Number_Current__c = oItem.PSA_OM_PO_Number__c;
                            oNewBillingEvent.PSA_BE_Ready_For_Finance__c = true;
                            oNewBillingEvent.pse__Date__c = Date.today();                        
                            mapNewProjectPoNumber.put(sKey,oNewBillingEvent);
                        }
                        if(mapNewProjectPoNumberWiseItems.containsKey(sKey)){
                            lstBillingItemToReparent = mapNewProjectPoNumberWiseItems.get(sKey);
                        }
                        else{
                            lstBillingItemToReparent = new List<pse__Billing_Event_Item__c>();
                        }
                        lstBillingItemToReparent.add(oItem);
                        mapNewProjectPoNumberWiseItems.put(sKey,lstBillingItemToReparent);
                    }
                }
            }
        }
        if(mapNewProjectPoNumber.size()>0){
            insert mapNewProjectPoNumber.values();
            for(string sKey:mapNewProjectPoNumber.keySet()){
                pse__Billing_Event__c oNewBillingEvent = mapNewProjectPoNumber.get(sKey);
                if(mapNewProjectPoNumberWiseItems.containsKey(sKey)){
                    List<pse__Billing_Event_Item__c> lstBillingItemToReparent = mapNewProjectPoNumberWiseItems.get(sKey);
                    for(pse__Billing_Event_Item__c oItem:lstBillingItemToReparent){
                        oItem.pse__Billing_Event__c = oNewBillingEvent.Id;
                        lstBillingItemReparented.add(oItem);
                    }
                }
            }
        }
        if(lstBillingItemReparented.size()>0){
            update lstBillingItemReparented;
        }
        if(lstBillingEventToUpdate.size()>0){
            update lstBillingEventToUpdate;
        }
    }      
        
    global void finish(Database.BatchableContext bc){
        System.debug('@Developer --> BillingEventBatch --> finish --> timestamp:' + system.now());   
                  
    }
}