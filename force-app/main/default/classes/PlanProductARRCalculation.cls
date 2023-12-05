/*
* Class :        PlanProductARRCalculation
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for PlanProductARRCalculationBatch 
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
Narpavi Prabu    4-07-2022    AR-2797           Fixed the ARR value is Zero in Plan Products for Active Contract            T01
*/
public class PlanProductARRCalculation {
    
    public static globalApexManager GAM = new globalApexManager();
    
    public static void updatePlanProducts(Set<Id> planproductIds){
        
        
        Map<id,Related_Account_Plan__c> mapPlanProducts = new map<id, Related_Account_Plan__c>();
        Map<id,Related_Account_Plan__c> mapUpdatePlanProduct = new map<id,Related_Account_Plan__c>();
        Map<id,Set<Subscription_Line__c>>  mapPlanProductSublines = new Map<Id,Set<Subscription_Line__c>>();
        List<Related_Account_Plan__c> lStUpdatePlanProduct = new List<Related_Account_Plan__c>();
        
        if(planproductIds!=null && planproductIds.size()>0){

            
            try{
                
                mapPlanProducts = new map<id,Related_Account_Plan__c>([Select id, Account_Plan__c,Unassigned_Contract__c,Start_Date__c,End_Date__c,CurrencyIsoCode,Account__c,Contract__c,Opportunity__c,ARR__c, ARR_to_Acquire__c,Previous_ARR__c,FTR__c,ROR__c from Related_Account_Plan__c where id in :planproductIds]);
               
             //<T01> - Removed the Last modified condition check from the query   
            for(SubScription_Line__c subline : [SELECT Id,CurrencyISOCode,Plan_Product__c,Start_Date__c,End_Date__c,ARR__c,Contract__c,Contract__r.SBQQ__RenewalOpportunity__c,Contract__r.SBQQ__Opportunity__c,Contract__r.SBQQ__Opportunity__r.RecordtypeId FROM Subscription_Line__c WHERE  Plan_Product__c in :planproductIds]){
                
                if(!mapPlanProductSublines.containsKey(subline.Plan_Product__c)){
                    Set<Subscription_Line__c> setSubline = new set<Subscription_Line__c>();
                    setSubline.add(subline);
                    mapPlanProductSublines.put(subline.Plan_Product__c, setSubline);
                }else{
                    mapPlanProductSublines.get(subline.Plan_Product__c).add(subline);
                }
                               
            }
                
            }Catch(Exception e){

                String linenumber = String.valueOf(e.getLineNumber());
                GAM.CreateLogs('PlanProductARRCalculation--> Query Exception-->', e.getMessage(),'Query',linenumber );
                
            }            
                        
            for (Id planproductId : mapPlanProductSublines.keySet()){
                
                Related_Account_Plan__c PlanProduct = mapPlanProducts.get(planproductId);
                
                Double tempARR =PlanProduct.ARR__c; 
                PlanProduct.ARR__c=0;
                PlanProduct.ARR_to_Acquire__c =0;
                PlanProduct.ROR__c=False;
                PlanProduct.FTR__c=False;
                PlanProduct.Start_Date__c= mapPlanProducts.get(planproductId).Start_Date__c;
                PlanProduct.End_Date__c= mapPlanProducts.get(planproductId).End_Date__c;
                
                
                for(SubScription_Line__c subline : mapPlanProductSublines.get(planproductId)){
                    
                    //Active Subscription Lines
                    If(subline.ARR__c!=null && subline.Start_Date__c <= Date.today() && subline.End_Date__c >=Date.today()){ 
                        PlanProduct.Contract__c = subline.Contract__c;
                        if(PlanProduct.Account_Plan__c == null){
                            PlanProduct.Unassigned_Contract__c = subline.Contract__c; 
                        } 
                        if(PlanProduct.Account_Plan__c !=null &&  planproduct.Unassigned_Contract__c != null){
                             planproduct.Unassigned_Contract__c=null;
                    		 planproduct.Account__c =null;
                        }
                        PlanProduct.Opportunity__c = subline.Contract__r.SBQQ__RenewalOpportunity__c!=null ? subline.Contract__r.SBQQ__RenewalOpportunity__c : null ;  
                        PlanProduct.CurrencyIsoCode = subline.CurrencyIsoCode;                              
                        PlanProduct.ARR__c +=subline.ARR__c;
                        PlanProduct.Start_Date__c = (PlanProduct.Start_Date__c==null ||PlanProduct.Start_Date__c >subline.Start_Date__c)? subline.Start_Date__c: PlanProduct.Start_Date__c;
                        PlanProduct.End_Date__c  = (PlanProduct.End_Date__c==null || PlanProduct.End_Date__c <subline.End_Date__c)? subline.End_Date__c: PlanProduct.End_Date__c;                        
                        
                        //ROR If Opportunity type is renewal 
                        if(subline.Contract__r.SBQQ__Opportunity__c!=null && subline.Contract__r.SBQQ__Opportunity__r.RecordtypeId != null && subline.Contract__r.SBQQ__Opportunity__r.RecordtypeId.equals( Label.Opportunity_Renewal_Record_Type_Id)){
                            PlanProduct.ROR__c = True; 
                        }
                        //FTR IF Opportunity type is new sales 
                        else if(!PlanProduct.ROR__c && subline.Contract__r.SBQQ__Opportunity__c!=null && subline.Contract__r.SBQQ__Opportunity__r.RecordtypeId != null && ! subline.Contract__r.SBQQ__Opportunity__r.RecordtypeId.equals( Label.Opportunity_Renewal_Record_Type_Id)){
                            PlanProduct.FTR__c = True;
                        }
                    }
                    
                    //Future Subscription Lines
                    else If(subline.ARR__c!=null && subline.Start_Date__c > Date.today() )
                    {
                        
                        //System.debug('subline.Startdate-->'+subline.Start_Date__c);
                        PlanProduct.ARR_to_Acquire__c +=subline.ARR__c;
                        PlanProduct.Contract__c = PlanProduct.Contract__c==null ?subline.Contract__c:PlanProduct.Contract__c;
                        if(PlanProduct.Account_Plan__c == null && PlanProduct.Unassigned_Contract__c == null){
                            PlanProduct.Unassigned_Contract__c = subline.Contract__c; 
                        }
                        if(PlanProduct.Account_Plan__c !=null &&  planproduct.Unassigned_Contract__c != null){
                             planproduct.Unassigned_Contract__c=null;
                    		 planproduct.Account__c =null;
                        }
                        PlanProduct.Opportunity__c = PlanProduct.Opportunity__c==null ?(subline.Contract__r.SBQQ__RenewalOpportunity__c!=null ? subline.Contract__r.SBQQ__RenewalOpportunity__c : null):PlanProduct.Opportunity__c;
                        PlanProduct.Start_Date__c = (PlanProduct.Start_Date__c==null || PlanProduct.Start_Date__c >subline.Start_Date__c)? subline.Start_Date__c: PlanProduct.Start_Date__c;
                        PlanProduct.End_Date__c  =(PlanProduct.End_Date__c ==null ||  PlanProduct.End_Date__c <subline.End_Date__c)? subline.End_Date__c: PlanProduct.End_Date__c;
                        
                    }
                                 
                }
                
                //Update Previous ARR when ARR is changed 
                PlanProduct.Previous_ARR__c = PlanProduct.ARR__c != tempARR ? tempARR : PlanProduct.Previous_ARR__c; 
                
                lstUpdatePlanProduct.add(PlanProduct);
                
            }  
            
            if(lstUpdatePlanProduct!=null && lstUpdatePlanProduct.size()>0){
                Database.SaveResult[] srList = Database.update(lstUpdatePlanProduct, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()){
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {					
                            GAM.CreateExceptionRecords('PlanProductARRCalculation--> updateARR--> Update failed', err.getMessage(), sr.getId());
                        }
                    }
                }
            }   
        }
    }
}