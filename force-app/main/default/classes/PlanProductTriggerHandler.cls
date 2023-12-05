/*
* Class :        PlanProductTriggerHandler
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for Plan Product Triggers
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/

public class PlanProductTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    public static void handlerBeforeUpdate(List<Related_Account_Plan__c> lstNewPlanProducts, Map<id,Related_Account_Plan__c> mapOldPlanProducts){
        
        List<Related_Account_Plan__c> lstUnassignPlanProducts = new List<Related_Account_Plan__c>();
        
        for ( Related_Account_Plan__c planproduct : lstNewPlanProducts){
            if(planproduct.Account_Plan__c!= mapOldPlanProducts.get(planproduct.Id).Account_Plan__c){
                lstUnassignPlanProducts.add(planproduct);
            }
        }
        
        system.debug('**lstUnassignPlanProducts'+lstUnassignPlanProducts);
        if(lstUnassignPlanProducts!=null && lstUnassignPlanProducts.size()>0){
            unassignPlanProducts(lstUnassignPlanProducts,mapOldPlanProducts);
        }
        
    }
    
    
    
    public static void handlerAfterUpdate(List<Related_Account_Plan__c> lstNewPlanProducts, Map<id,Related_Account_Plan__c> mapOldPlanProducts){
        
        List<Related_Account_Plan__c> lstMergePlanProducts = new List<Related_Account_Plan__c>();
        List<Related_Account_Plan__c> lstRenewalTypeProducts = new List<Related_Account_Plan__c>();
        
        for ( Related_Account_Plan__c planproduct : lstNewPlanProducts){
            if(planproduct.Account_Plan__c !=null &&  planproduct.Account_Plan__c!= mapOldPlanProducts.get(planproduct.Id).Account_Plan__c){
                lstMergePlanProducts.add(planproduct);
        	system.debug('** First Condition'+ planproduct.Account_Plan__c);
            }
            
            if(planproduct.Contract__c !=null &&  planproduct.Contract__c!= mapOldPlanProducts.get(planproduct.Id).Contract__c){
                lstMergePlanProducts.add(planproduct);
        		system.debug('** second Condition Plan Contract'+ planproduct.Contract__c);
            }
            
            if(planproduct.Account_Plan__c!= mapOldPlanProducts.get(planproduct.Id).Account_Plan__c || planproduct.ROR__c != mapOldPlanProducts.get(planproduct.Id).ROR__c || planproduct.FTR__c != mapOldPlanProducts.get(planproduct.Id).FTR__c){
                lstRenewalTypeProducts.add(planproduct);
            }
        }
        
        system.debug('**lstMergePlanProducts'+lstMergePlanProducts);
        if(lstMergePlanProducts!=null && lstMergePlanProducts.size()>0){
            mergePlanProduct(lstMergePlanProducts);
            system.debug('**mapNewPlanContract'+lstMergePlanProducts);
			createPlanContract(lstMergePlanProducts);
            
        }
        
        system.debug('**lstRenewalTypeProducts'+lstRenewalTypeProducts);
        if(lstRenewalTypeProducts!=null && lstRenewalTypeProducts.size()>0){
            UpdatePlanRenewalType(lstRenewalTypeProducts,mapOldPlanProducts);
        }
        
        createInterlock(lstNewPlanProducts,mapOldPlanProducts);
    }
    
    public static void mergePlanProduct(List<Related_Account_Plan__c> lstNewPlanProducts){
        
        map<String, id> mapNewPlanProducts = new map<String,id>();
        map<String, id> mapOldPlanProducts = new map<String,id>();
        set<Id> planIds= new set<Id>();
        set<Id> contractIds = new set<Id>();
        map<Id,Id> mapNewOldPlanProduct = new map<id,id>();
        List<Subscription_Line__c> lstUpdateSubscriptionLine = new List<Subscription_Line__c>();
        List<Related_Risk_Product__c> lstUpdateRiskProduct = new List<Related_Risk_Product__c>();
        List<Engagement_Product__c> lstUpdateInterlockProduct = new List<Engagement_Product__c>();
        
        for(Related_Account_Plan__c newPlanproduct :lstNewPlanProducts ){ 
            string UniqueKey =  newPlanproduct.Account_Plan__c+';'+newPlanproduct.Contract__c+';'+newPlanproduct.Forecast_Product__c +';'+  newPlanproduct.Delivery_Method__c + ';'+ newPlanproduct.Pricing_Business_Model__c +';'+ newPlanproduct.Offering_Type__c  ;
            if(mapNewPlanProducts.containskey(UniqueKey)){
              mapNewOldPlanProduct.put(newPlanproduct.id,mapNewPlanProducts.get(uniqueKey));
            }else{
            mapNewPlanProducts.put(UniqueKey,newPlanproduct.id);
            }
            if(newPlanproduct.Account_Plan__c !=null){
                system.debug('***Merge Account plan'+newPlanproduct.Account_Plan__c);
                planIds.add(newPlanproduct.Account_Plan__c);
            } 
            if(newPlanproduct.Contract__c !=null){
                system.debug('***Merge Contract plan'+newPlanproduct.Contract__c);
            contractIds.add(newPlanproduct.Contract__c);
        }
        
        }
        if(planIds.size()>0 || contractIds.size()>0){
        	for (Related_Account_Plan__c oldplanproduct : [Select id,Contract__c,Account_Plan__c,Forecast_Product__c,Offering_Type__c,Delivery_Method__c,Pricing_Business_Model__c from Related_Account_Plan__c where (Account_Plan__c in :planIds Or Contract__c in :contractIds) and Id not in :lstNewPlanProducts]){
            string UniqueKey =  oldplanproduct.Account_Plan__c+';'+oldplanproduct.Contract__c+';'+oldplanproduct.Forecast_Product__c +';'+  oldplanproduct.Delivery_Method__c + ';'+ oldplanproduct.Pricing_Business_Model__c +';'+ oldplanproduct.Offering_Type__c  ;
            mapOldPlanProducts.put(UniqueKey,oldplanproduct.id);
        } 
        }  
        
        for(String uniqueKey : mapNewPlanProducts.keyset()){
            if(mapOldPlanProducts.containskey(uniqueKey)){               
                  mapNewOldPlanProduct.put(mapNewPlanProducts.get(uniqueKey),mapOldPlanProducts.get(UniqueKey));
            }
        }   
        
        for(id newPlanProduct : mapNewOldPlanProduct.keyset()){
            if(mapNewOldPlanProduct.containskey(mapNewOldPlanProduct.get(newPlanProduct))){
                mapNewOldPlanProduct.put(newPlanProduct,mapNewOldPlanProduct.get(newPlanProduct));
            }
        }
        
        //Merge Subscription Lines
        for( Subscription_Line__c subLine : [select id, plan_product__c from Subscription_Line__c where plan_product__c in :mapNewOldPlanProduct.keyset()]){
            system.debug('**subLine'+subLine);
            lstUpdateSubscriptionLine.add(new Subscription_Line__c(id = subLine.id,plan_product__c = mapNewOldPlanProduct.get(subLine.plan_product__c)));
        }
        //Merge Risk Products
        for( Related_Risk_Product__c riskProduct : [select id, plan_product__c from Related_Risk_Product__c where plan_product__c in :mapNewOldPlanProduct.keyset()]){
            system.debug('**riskProduct'+riskProduct);
            lstUpdateRiskProduct.add(new Related_Risk_Product__c(id=riskProduct.id,plan_product__c= mapNewOldPlanProduct.get(riskProduct.plan_product__c)));
        } 
        //Merge Interlock Products
        for( Engagement_Product__c interlockProduct : [select id, plan_product__c from Engagement_Product__c where plan_product__c in:mapNewOldPlanProduct.keyset()]){
            system.debug('**interlockProduct'+interlockProduct);
            lstUpdateInterlockProduct.add(new Engagement_Product__c(id=interlockProduct.id,plan_product__c= mapNewOldPlanProduct.get(interlockProduct.plan_product__c)));
        } 
        
        system.debug('**lstUpdateSubscriptionLine'+lstUpdateSubscriptionLine);
        if(lstUpdateSubscriptionLine!=null && lstUpdateSubscriptionLine.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateSubscriptionLine, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->mergePlanProduct-->Update Subscription Lines failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        system.debug('**lstUpdateRiskProduct'+lstUpdateRiskProduct);
        if(lstUpdateRiskProduct!=null && lstUpdateRiskProduct.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateRiskProduct, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->mergePlanProduct-->Update Risk Products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        system.debug('**lstUpdateInterlockProduct'+lstUpdateInterlockProduct);
        if(lstUpdateInterlockProduct!=null && lstUpdateInterlockProduct.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateInterlockProduct, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->mergePlanProduct-->Update Interlock Products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
        system.debug('**to delete mapNewOldPlanProduct'+ mapNewOldPlanProduct);
        if(mapNewOldPlanProduct !=null && mapNewOldPlanProduct.keyset()!=null){   
            deleteDuplicatePlanProducts(mapNewOldPlanProduct.keyset());
        } 
        system.debug('** to recalculate ARR for Products'+ mapNewOldPlanProduct);
        if(mapNewOldPlanProduct !=null && mapNewOldPlanProduct.values()!=null){
            System.debug('Batch class for ARR Update');
            PlanProductARRCalculation.updatePlanProducts(new Set<Id> (mapNewOldPlanProduct.values()));
        }  
    }
    
    public static void createPlanContract(List<Related_Account_Plan__c> lstNewPlanProducts){
        
        map<id,set<id>> mapOldPlanContract = new map<id,set<id>>();
        map<id,set<id>> mapNewPlanContract = new map<id,set<id>>();
        map<id,id> mapContractOpportunity = new map<id,id>();
        List<Plan_Contract__c> lstCreatePlanContract = new List<Plan_Contract__c>();
        
        
        for(Related_Account_Plan__c newPlanProduct : lstNewPlanProducts){ 
            if(newPlanProduct.Contract__c!=null){
                if(!mapNewPlanContract.containskey(newPlanProduct.Account_Plan__c)){
                    set<Id> contractIds = new set<id>();
                    contractIds.add(newPlanProduct.Contract__c);
                    mapNewPlanContract.put(newPlanProduct.Account_Plan__c, contractIds);
                }else {
                    mapNewPlanContract.get(newPlanProduct.Account_Plan__c).add(newPlanProduct.Contract__c);
                }
            }
        }
        
        system.debug('**mapNewPlanContract'+mapNewPlanContract);
        
        for( Plan_Contract__c oldPlanContract : [select id, plan__c, opportunity__c, contract__c from Plan_Contract__c where Plan__c in : mapNewPlanContract.keySet() ]){
            if(oldPlanContract.contract__c !=null){
                system.debug('**Plan Contract'+oldPlanContract.contract__c);
                if(!mapOldPlanContract.containskey(oldPlanContract.plan__c)){
                    set<id> contractIds = new set<id>();
                    contractIds.add(oldPlanContract.contract__c);
                    mapOldPlanContract.put(oldPlanContract.plan__c,contractIds);
                }else{
                    mapOldPlanContract.get(oldPlanContract.plan__c).add(oldPlanContract.contract__c);
                }
            }  
        }
        
        system.debug('**mapOldPlanContract'+mapOldPlanContract);
        
        for(Id planId :mapNewPlanContract.keyset()){
            for( Id conId : mapNewPlanContract.get(planId)){
                if(!mapOldPlanContract.containskey(planId) || (mapOldPlanContract.get(planId)!=null &&!mapOldPlanContract.get(planId).contains(conId))){
                    Plan_Contract__c newPlanContract = new Plan_Contract__c();
                    newPlanContract.Plan__c= planId;
                    newPlanContract.Contract__c= ConId ;
                    lstCreatePlanContract.add(newPlanContract);
                }
                
                
            }
        }
        
        system.debug('**lstCreatePlanContract'+lstCreatePlanContract);
        if(lstCreatePlanContract!=null && lstCreatePlanContract.size()>0){
            Database.SaveResult[] srList = Database.insert(lstCreatePlanContract, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->CreatePlanContract-->Insert of Plan Contracts failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
    
    
    public static void deleteDuplicatePlanProducts(Set<Id> planproductIds){
        
        List<Related_Account_Plan__c> lstDeletePlanProducts = new List<Related_Account_Plan__c>();
        
        //check if no child record exist
        for(Related_Account_Plan__c planProduct : [ Select id, (select id from Related_Risk_Products__r),(select id from Subscription_Lines__r),(Select id from Interlock_Products__r) from Related_Account_Plan__c where id in :planproductIds ]){
            if(planProduct.Related_Risk_Products__r.size()==0 && planProduct.Subscription_Lines__r.size()==0 && planProduct.Interlock_Products__r.size() == 0){
                lstDeletePlanProducts.add(planProduct);
            }
        }
        system.debug('**lstDeletePlanProducts '+lstDeletePlanProducts);
        if(lstDeletePlanProducts!=null && lstDeletePlanProducts.size()>0){
            Database.DeleteResult[] srList = Database.delete(lstDeletePlanProducts, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->deleteDuplicatePlanProducts-->Delete Plan Products failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
    
     
      
    public static void unassignPlanProducts(List<Related_Account_Plan__c> lstNewPlanProducts, map<id,Related_Account_Plan__c> mapOldPlanProducts){
        
        Set<Id> contractIds = new Set<Id>();
        Map<Id,Id> mapContractAccount = new Map<Id,Id>();
        //  List<Related_Account_Plan__c> lstUpdatePlanProducts = new List<Related_Account_Plan__c>();
        
        //Get Contracts
        for ( Related_Account_Plan__c planproduct : lstNewPlanProducts){
            if( mapOldPlanProducts.get(planproduct.Id).Account_Plan__c!=null && planproduct.Account_Plan__c ==null && planproduct.Contract__c!=null ){
                contractIds.add(planproduct.Contract__c);
            }
        }
        
        //Get Account from Contract        
        for( Contract  con : [Select id, AccountId from Contract where id in :contractIds]){
            if(con.AccountId!=null)
                mapContractAccount.put(con.id,con.AccountId);
        }
        
        
        for ( Related_Account_Plan__c planproduct : lstNewPlanProducts){
            Try{
                //Assigned Products
                if(planproduct.Account_Plan__c !=null &&  planproduct.Account_Plan__c!= mapOldPlanProducts.get(planproduct.Id).Account_Plan__c){
                    planproduct.Unassigned_Contract__c=null;
                    planproduct.Account__c =null;
                }
                //Unassigned Products
                else if(mapOldPlanProducts.get(planproduct.Id).Account_Plan__c!=null && planproduct.Account_Plan__c ==null && planproduct.Contract__c!=null ){          
                    planproduct.Unassigned_Contract__c =planproduct.Contract__c;
                    planproduct.Account__c = mapContractAccount.get(planproduct.Contract__c);
                    
                }
            }
            Catch(Exception e){
                GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->unassignPlanProducts-->Update of Plan product failed', e.getMessage(), planproduct.id);
            }
        }
        
        
    }
    
    public static void UpdatePlanRenewalType(List<Related_Account_Plan__c> lstNewPlanProducts, map<id,Related_Account_Plan__c> mapOldPlanProducts){
  
        Set<Id> planIds = new set<Id>();
        Map<id,Set<Related_Account_Plan__c>> mapPlanPlanProduct= new Map<id,Set<Related_Account_Plan__c>>();
        List<Plan__c> lstUpdatePlans = new List<Plan__c>();
        Set<String> ALLOWED_OFFERING_TYPES = new Set<String>{'Cloud Hosted Subscription','On-Premise Subscription'};
        
        //Fetch plan Ids        
        for(Related_Account_Plan__c PlanProduct : lstNewPlanProducts){
            
            if(PlanProduct.Account_Plan__c!=null){
                planIds.add(PlanProduct.Account_Plan__c);
                
            }
            
            if(mapOldPlanProducts <> null && mapOldPlanProducts.get(PlanProduct.id)?.Account_Plan__c!=null){
                planIds.add(mapOldPlanProducts.get(PlanProduct.id).Account_Plan__c);           
            }
        }
        
        //Get the plan map to check the renewal type
        Map<Id,Plan__c> planMap = new Map<Id,Plan__c>([Select Id,Renewal_Type__c from Plan__c where Id in: planIds]);
        
        
        //Group products by plan
        for(Related_Account_Plan__c PlanProduct : [Select id,ROR__c, Account_Plan__c,FTR__c, Status__c,Offering_Type__c from Related_Account_Plan__c where Status__c= 'Active' and Account_plan__r.Status__c='Active' and Account_plan__c in :planIds and Offering_Type__c IN :ALLOWED_OFFERING_TYPES]){
            
            if(!mapPlanPlanProduct.containskey(PlanProduct.Account_Plan__c)){
                Set<Related_Account_Plan__c> setPlanProducts = new set<Related_Account_Plan__c>();
                setPlanProducts.add(PlanProduct);
                mapPlanPlanProduct.put(PlanProduct.Account_Plan__c, setPlanProducts);
            }
            else if(!mapPlanPlanProduct.get(PlanProduct.Account_Plan__c).contains(PlanProduct)){
                mapPlanPlanProduct.get(PlanProduct.Account_Plan__c).add(PlanProduct);
            }
        }
        system.debug('**mapPlanPlanProduct'+mapPlanPlanProduct);
        //Calculate renewal type for each plan
        for( Id PlanId : planIds ){
            
            Integer Count_ROR=0;
            Integer Count_FTR=0;
            
            //Count ROR vs FTR products per palan
            if(mapPlanPlanProduct.size()>0 && mapPlanPlanProduct.containsKey(PlanId)){
                for( Related_Account_Plan__c PlanProduct : mapPlanPlanProduct.get(PlanId)){
                    if(PlanProduct.ROR__c){
                        Count_ROR++; 
                    }
                    else if(PlanProduct.FTR__c){
                        Count_FTR++; 
                    }
                }
            }
            //Update Renewal type of plan 
            Plan__c UpdatePlan = new Plan__c (id= PlanId);
            
                if(Count_ROR>0 && Count_FTR>0 ){
                    UpdatePlan.Renewal_Type__c = 'FTR/ROR';
                }
                else if(Count_ROR >0 && Count_FTR ==0){
                    UpdatePlan.Renewal_Type__c = 'ROR';
                }
                else if(Count_FTR >0 && Count_ROR ==0){
                    UpdatePlan.Renewal_Type__c = 'FTR';
                }else{
                    UpdatePlan.Renewal_Type__c = null;
                }
            if(UpdatePlan.Renewal_Type__c <> planMap.get(UpdatePlan.Id).Renewal_Type__c){
                lstUpdatePlans.add(UpdatePlan);
            }
        }
        
        system.debug('**lstUpdatePlans'+lstUpdatePlans);
        if(lstUpdatePlans!=null && lstUpdatePlans.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdatePlans, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->UpdatePlanRenewalType-->Update of Plan failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
    
    /** Interlock Creation on assigning the PlanProducts to Plan **/
    public static void createInterlock(List<Related_Account_Plan__c> lstNewPlanProducts , map<id,Related_Account_Plan__c> mapOldPlanProducts){
        Id InterlockRecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();
        
        Set<Id> planIdSet = new Set<Id>();
        Map<String,List<Related_Account_Plan__c>> planProductsMap = new Map<String,List<Related_Account_Plan__c>>();
        Map<String,List<Related_Opportunity_Plan__c>> existingInterlockMap = new Map<String,List<Related_Opportunity_Plan__c>>();
        
        List<Related_Opportunity_Plan__c> interlocksToInsert = new List<Related_Opportunity_Plan__c>();
        
        
        for(Related_Account_Plan__c planproduct :[Select Id,Name,Account_Plan__r.Account__c,Account_Plan__c,Contract__c,Opportunity__c,Contract__r.SBQQ__Opportunity__c,Forecast_Product__c,Delivery_Method__c,Pricing_Business_Model__c,Offering_Type__c from Related_Account_Plan__c where Id in:lstNewPlanProducts]){
            //When the Plan is assigned to the Plan Product or Contract is changed (ROR), then check the combinations and create interlock
           if((planproduct.Account_Plan__c !=null &&  planproduct.Account_Plan__c!= mapOldPlanProducts.get(planproduct.Id).Account_Plan__c) ||(planproduct.Contract__c !=null &&  planproduct.Contract__c!= mapOldPlanProducts.get(planproduct.Id).Contract__c)){
               string UniqueKey =  planproduct.Account_Plan__c+';'+planproduct.Contract__c+';'+planproduct.Opportunity__c+';'+planproduct.Contract__r.SBQQ__Opportunity__c;
               if(planProductsMap.containsKey(UniqueKey)){
                   List<Related_Account_Plan__c> tempList = planProductsMap.get(UniqueKey);
                   tempList.add(planproduct);
                   planProductsMap.put(UniqueKey,tempList);
               }else{
                   planProductsMap.put(UniqueKey,new List<Related_Account_Plan__c>{planproduct});
               }
           } 
            
            //Get the Plan Id to check existing interlock
            if(planproduct.Account_Plan__c <> null){
                planIdSet.add(planproduct.Account_Plan__c);
            }
        }
        
        //Get the existing interlocks
        for(Related_Opportunity_Plan__c interlock : [Select Id,Original_Opportunity__c,Opportunity__c,Plan__c,Contract__c from Related_Opportunity_Plan__c where Plan__c in:planIdSet and RecordTypeId =:InterlockRecordTypeId]){ // AND RecordType = newRecordtype/Master- TBD
            string UniqueKey =  interlock.Plan__c+';'+interlock.Contract__c+';'+interlock.Opportunity__c+';'+interlock.Original_Opportunity__c;
            if(existingInterlockMap.containsKey(UniqueKey)){
                   List<Related_Opportunity_Plan__c> tempList = existingInterlockMap.get(UniqueKey);
                   tempList.add(interlock);
                   existingInterlockMap.put(UniqueKey,tempList);
               }else{
                   existingInterlockMap.put(UniqueKey,new List<Related_Opportunity_Plan__c>{interlock});
               }
        }
        
        //Interate the planProductMap and create new interlocks if not already present (Need to change to @future method)
        for(String UniqueKey : planProductsMap.keySet()){
            if(!existingInterlockMap.keySet().contains(UniqueKey)){
                Related_Opportunity_Plan__c interlock = new Related_Opportunity_Plan__c();
                interlock.Is_Automated__c = true;
                interlock.Automation_Source__c = 'Plan Products';
                interlock.Plan__c = planProductsMap.get(UniqueKey)[0].Account_Plan__c;
                interlock.Account__c = planProductsMap.get(UniqueKey)[0].Account_Plan__r.Account__c;
                interlock.Contract__c = planProductsMap.get(UniqueKey)[0].Contract__c;
                interlock.Opportunity__c = planProductsMap.get(UniqueKey)[0].Opportunity__c;
                interlock.Original_Opportunity__c = planProductsMap.get(UniqueKey)[0].Contract__r.SBQQ__Opportunity__c;
                interlock.RecordTypeId = InterlockRecordTypeId;
                interlocksToInsert.add(interlock);
            }
        }
        
        if(interlocksToInsert?.size() >0){
            Database.SaveResult[] srList = Database.insert(interlocksToInsert, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()) {          
                        GAM.CreateExceptionRecords('PlanProductTriggerHanlder-->createInterlock-->Insert of Interlock failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
    }
    
    /*
   Method Name : afterInsert
   Description : This method gets executed on After Insert.
   Parameters   : List, called from afterInsert, lstNewRecords New records.
   Return Type : None
   */
  public static void afterInsert(List<Related_Account_Plan__c> lstNewRecords) {

    //We send the Plan Products to generate their conrresponding aliases.
 	PlanProductTriggerHelper.createPlanProductAliasRecords(lstNewRecords);
      
    
  }
  
    /*
   Method Name : afterUpdate
   Description : This method gets executed on After Update.
   Parameters   : List, called from afterUpdate, lstNewRecords New records.
            List, called from afterUpdate, mapOldRecords Old records.
   Return Type : None
   */
  public static void afterUpdate(List<Related_Account_Plan__c> lstNewRecords, Map<Id, Related_Account_Plan__c> mapOldRecords) {

    //We send the Plan Products to generate their conrresponding aliases.
    PlanProductTriggerHelper.createPlanProductAliasRecords(lstNewRecords, mapOldRecords);
        
  }
  
    /*
   Method Name : afterDelete
   Description : This method gets executed on After Delete.
   Parameters   : List, called from afterDelete, lstOldRecords Old records.
   Return Type : None
   */
  public static void afterDelete(List<Related_Account_Plan__c> lstOldRecords) {

    //We send the Plan Products to eliminate their conrresponding aliases.
    PlanProductTriggerHelper.cleanUpAliasRecords(lstOldRecords);
  }
}