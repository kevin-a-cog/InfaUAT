/*
* Class :        CreatePlanProducts
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for Plan Product Creation Batch
*/

/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
Pavithra 		15-11-2021 	                                    Automate Plan Products                                      T01
Pavithra 		14-12-2021                                      Add Product Name from technical product lines               T02
*/
public class CreatePlanProducts {
    
    public static globalApexManager GAM = new globalApexManager();
    
    public static void processSubscriptionLines(List<Subscription_Line__c> lstNewSubscriptionLine) {
        
        
        // Convert new Subscription Lines list to map 
        Map<Id,Subscription_Line__c> mapNewSubscriptionLines= new map<Id,Subscription_Line__c>(lstNewSubscriptionLine);
    
        
        List<Subscription_Line__c> lstSubscriptionLineDeatils = new List<Subscription_Line__c>();
        List<Subscription_Line__c> lstMergeSubcriptionLines = new List<Subscription_Line__c>();
        List<Subscription_Line__c> lstNewSubcriptionLines = new List<Subscription_Line__c>();
        List<Subscription_Line__c> lstUpdateSubscriptionLines = new List<Subscription_Line__c>();
 
        
        lstSubscriptionLineDeatils = [SELECT Id,
                                      Subscription__r.Transaction_Type__c,
                                      Start_Date__c,End_Date__c,ARR__c,
                                      Contract__c, Contract__r.AccountId,Contract__r.SBQQ__RenewalOpportunity__c,
                                      Plan_Product__c,Plan_Product__r.Account_Plan__c,
                                      Renewed_Subscription_Line__c,Renewed_Subscription_Line__r.Plan_Product__c,
                                      Upgraded_Subscription_Line__c,Upgraded_Subscription_Line__r.Plan_Product__c,
                                      Product__c,Product__r.Offering_Type__c,Product__r.Forecast_Product__c,Product__r.Delivery_Method__c,Product__r.Pricing_Business_Model__c
                                      FROM Subscription_Line__c where id in :mapNewSubscriptionLines.keyset()];
        

        for(Subscription_Line__c sub : lstSubscriptionLineDeatils){
                     
            if(sub.Plan_Product__c == null && sub.Renewed_Subscription_Line__c!=null && sub.Renewed_Subscription_Line__r.Plan_Product__c!=null){
                lstUpdateSubscriptionLines.add( new Subscription_Line__c (id = sub.id,Plan_Product__c = sub.Renewed_Subscription_Line__r.Plan_Product__c));     
            }
            else if(sub.Plan_Product__c == null && sub.Upgraded_Subscription_Line__c!=null && sub.Upgraded_Subscription_Line__r.Plan_Product__c!=null){
                lstUpdateSubscriptionLines.add(new Subscription_Line__c (id = sub.id,Plan_Product__c = sub.Upgraded_Subscription_Line__r.Plan_Product__c));
            }
            else if(sub.Plan_Product__c == null ){
                lstNewSubcriptionLines.add(sub);
            }

        }
         
        
        lstUpdateSubscriptionLines.addall(createNewPlanProducts(lstNewSubcriptionLines));
        
        if(lstUpdateSubscriptionLines != null && lstUpdateSubscriptionLines.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateSubscriptionLines, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {					
                        GAM.CreateExceptionRecords('CreatePlanProducts-->processSubscriptionLines-->Update of Subscription Lines failed', err.getMessage(), sr.getId());
                    }
                }
            }
        }
        
    }
    
    public static List<Subscription_Line__c> createNewPlanProducts(List<Subscription_Line__c> lstNewSubcriptionLines ){
                
        // List of Plan products to be inserted
        List <Related_Account_Plan__c> lstInsertPlanProducts = new List<Related_Account_Plan__c>();
         
        //List of subscription to be updated with new plan product id
        List<Subscription_Line__c> lstUpdateSubcriptionLines = new List<Subscription_Line__c>();
        
        //List of offering types to mark as Not Applicable
        List<string> lstIncludeOfferingType = new List<String>();
        lstIncludeOfferingType= Label.A2RIncludeOfferingTypes.split(';');
         
        //Map of Contarct Id with its Subcription Lines
        Map<Id,List<Subscription_Line__c>> mapContractSubscriptionLines = new Map<Id,List<Subscription_Line__c>>();              
           
        //Map of Unique key with Subscription Lines
        Map<String,List<Subscription_Line__c>> mapUniqueSuscriptionLines = new Map<String,List<Subscription_Line__c>>();

        //Map of Plan Products Inserted
        Map<String,Id> newPlanProducts = new map<String,Id>();
        
        Set<Id> newPlanProductSet = new Set<Id>();
            
        //Loop through all subscription lines within a contract to identify unique combination
        for(Subscription_Line__c subline : lstNewSubcriptionLines){

            if(subline.Contract__c!=null && subline.Product__c!=null && 
                   subline.Product__r.Forecast_Product__c!=null && subline.Product__r.Delivery_Method__c!=null &&
                   subline.Product__r.Pricing_Business_Model__c!=null  && subline.Product__r.Offering_Type__c!= null){
                       
                    String UniqueKey =  subline.Contract__c+';'+ subline.Product__r.Forecast_Product__c +';'+ subline.Product__r.Delivery_Method__c + ';'+ subline.Product__r.Pricing_Business_Model__c +';'+ subline.Product__r.Offering_Type__c  ;
                       
                    system.debug('Subline unique key'+ UniqueKey);
                       // Unique products per contract
                       if( mapUniqueSuscriptionLines.containskey(UniqueKey)){
                           mapUniqueSuscriptionLines.get(UniqueKey).add(subline);
                       }
                       else{
                           List<Subscription_Line__c> lstSubline = new List<Subscription_Line__c>(); 
                           lstSubline.add(subline);
                           mapUniqueSuscriptionLines.put(UniqueKey,lstSubline);
                       }
                       //Subscriotionlines per Contract
                        if(mapContractSubscriptionLines.containskey(subline.Contract__c)){
                            mapContractSubscriptionLines.get(subline.Contract__c).add(subline);
                        }else{
                            List<Subscription_Line__c> lstSubline = new List<Subscription_Line__c>(); 
                            lstSubline.add(subline);
                            mapContractSubscriptionLines.put(subline.Contract__c,lstSubline);
                        } 
            }
        }
            
        system.debug('mapUniqueSuscriptionLines'+mapUniqueSuscriptionLines);
        system.debug('mapContractSubscriptionLines'+mapContractSubscriptionLines);

            
        //Get Contract Deatils
        map<Id,Contract> mapContracts= new Map<Id,Contract>([select id,AccountId,SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c from contract where id in : mapContractSubscriptionLines.keyset()]);
        System.debug('mapContracts'+mapContracts);
        
        //Get Existing Products per Contract
        set<String> setUnassignedPlanProducts = new Set<String>();
        for(Related_Account_Plan__c planproduct : [Select id,Account_plan__c,Unassigned_Contract__c,Account__c,Contract__c, Forecast_Product__c,Offering_Type__c,Delivery_Method__c,Pricing_Business_Model__c from Related_Account_Plan__c where Unassigned_Contract__c in : mapContractSubscriptionLines.keyset()]){
            String UniqueKey = planproduct.Unassigned_Contract__c +';'+planproduct.Forecast_Product__c +';'+ planproduct.Delivery_Method__c + ';'+ planproduct.Pricing_Business_Model__c+ ';'+ planproduct.Offering_Type__c ;
            setUnassignedPlanProducts.add(UniqueKey);
        }

        /**<T02>**/
        Map<String,Technical_Product_Line__c> mapForecastProductAlias = new Map<String,Technical_Product_Line__c>();
        for(Technical_Product_Line__c tp :[select Id,Name,Forecast_Product__c,Delivery_method__c,Alias__c from Technical_Product_Line__c where Forecast_Product__c <> null]){
            if(!String.isEmpty( tp.Alias__c)){
                if(tp.Alias__c.contains(';')){ 
                    List<string> lstFP = tp.Alias__c.split(';');
                    if(lstFP != null && lstFP.size()>0){
                        for(String fp: lstFP){
                            mapForecastProductAlias.put(fp,tp);
                        }
                    }
                }
                else{
                    mapForecastProductAlias.put(tp.Alias__c,tp);
                }
            }
            else{
                mapForecastProductAlias.put(tp.Name,tp);
            }
		}
		/**<T02>**/
        
        //Create Plan products per contract  for each unique combination  
        for(String UniqueKey :mapUniqueSuscriptionLines.keyset() ){

            //if this product doesnt exist under the contract then create new 
            if(!setUnassignedPlanProducts.contains(UniqueKey)){

                Related_Account_Plan__c PlanProduct = new Related_Account_Plan__c();
               
                List<String> UniqueFields = UniqueKey.split(';');
                String contractID = UniqueFields[0];
                PlanProduct.Unassigned_Contract__c = UniqueFields[0];
                PlanProduct.Forecast_Product__c = UniqueFields[1];
                PlanProduct.Delivery_Method__c = UniqueFields[2];
                PlanProduct.Pricing_Business_Model__c = UniqueFields[3];
                PlanProduct.Offering_Type__c = UniqueFields[4];
                PlanProduct.ARR__c =0;
                PlanProduct.Previous_ARR__c =0;
                PlanProduct.ARR_To_Acquire__c =0;
                PlanProduct.OwnerID =Label.AdminFlowOwnerId;    
                PlanProduct.Contract__c = contractID;         
                PlanProduct.Account__c = mapContracts.get(contractID).AccountId; 
                if( mapContracts.get(contractID).SBQQ__RenewalOpportunity__c!=null )
                     PlanProduct.Opportunity__c =mapContracts.get(contractID).SBQQ__RenewalOpportunity__c ;  
                    
                if(!lstIncludeOfferingType.contains(PlanProduct.Offering_Type__c)){
                    PlanProduct.Stage__c ='Not Applicable';
                }
                
                /**<T02>**/
                if(UniqueFields[1] <> null && mapForecastProductAlias?.keySet().contains(UniqueFields[1]) && mapForecastProductAlias?.get(UniqueFields[1])?.Delivery_method__c.split(';')?.contains(UniqueFields[2]) ){
                    PlanProduct.Product_Name__c = mapForecastProductAlias?.get(UniqueFields[1]).Name ;
                }else{
                    PlanProduct.Product_Name__c = UniqueFields[1];
                }
                /**<T02>**/
                
                //List of plan products to be inserted
                lstInsertPlanProducts.add (PlanProduct);
            }    
        }

        system.debug('lstInsertPlanProducts'+lstInsertPlanProducts);
        
        if( lstInsertPlanProducts!= null && lstInsertPlanProducts.size()>0){
            Database.SaveResult[] srList = Database.Insert(lstInsertPlanProducts, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors  
                    system.debug('**Operation failed');              
                    for(Database.Error err : sr.getErrors()) {					
                        GAM.CreateExceptionRecords('CreatePlanProducts-->createNewPlanProducts-->insert of Plan products failed', err.getMessage(), sr.getId());
                    }
                }else if(sr.isSuccess()){
                    newPlanProductSet.add(sr.getId());
                }
            }
        }   

    
        //Get plan products Inserted
        for (Related_Account_Plan__c planproduct : [Select id,Account_plan__c,Unassigned_Contract__c,Account__c,Opportunity__c,Contract__c, Forecast_Product__c,Offering_Type__c,Delivery_Method__c,Pricing_Business_Model__c from Related_Account_Plan__c where unassigned_contract__c in :mapContracts.keyset() ]){      
            system.debug('**ambica planproduct'+planproduct);
            if(planproduct.Contract__c !=null && planproduct.Forecast_Product__c !=null && planproduct.Delivery_Method__c !=null && planproduct.Pricing_Business_Model__c!=null && planproduct.Offering_Type__c!=null){
            String UniqueKey = planproduct.Contract__c +';'+planproduct.Forecast_Product__c +';'+ planproduct.Delivery_Method__c + ';'+ planproduct.Pricing_Business_Model__c+ ';'+ planproduct.Offering_Type__c ;
            newPlanProducts.put(UniqueKey,planproduct.id);
            }
        }
        system.debug('**ambica newPlanProducts'+newPlanProducts);

        
        //Update subscription lines with plan product lookup 
        for(String UniqueKey : newPlanProducts.keySet()){
                    system.debug('**ambica UniqueKey'+UniqueKey);
            if(mapUniqueSuscriptionLines.get(UniqueKey)!=null){
                for(Subscription_Line__c subline : mapUniqueSuscriptionLines.get(UniqueKey)){                     
                    system.debug('**ambica subline'+subline);
                    lstUpdateSubcriptionLines.add( new Subscription_Line__c (Id = subline.Id,Plan_Product__c = newPlanProducts.get(UniqueKey)));        
                }
            }
        }
    	//-------------------------------------<T01>
        if(newPlanProductSet?.size()>0){
            CSMAutomatePlanProducts.associatePlanToPlanProducts(newPlanProductSet);
        }
        //-------------------------------------<T01>
        system.debug('lstUpdateSubcriptionLines'+lstUpdateSubcriptionLines);
        return lstUpdateSubcriptionLines;
    }
}