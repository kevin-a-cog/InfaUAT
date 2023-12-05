/*
 * Name         :   CSMCreateMapRiskProductsQueueable
 * Author       :   Deva M
 * Created Date :   21/02/2022
 * Description  :   Queuable class for mapping risk products to risk coloumn on plannned products table

 Change History
 ******************************************************************************************************************************
 Modified By            Date            Jira No.        Description                                                         Tag
 *******************************************************************************************************************************
 Deva M              21/02/2022     AR-2217             Initial version.                                                    N/A
 Narpavi Prabu       01/12/2023      AR-3051         Fix the bug to update when the risk product is removed from risk       T01
 */
public with sharing class CSMCreateMapRiskProductsQueueable implements Queueable{
    public static globalApexManager gamObj = new globalApexManager();
    List<Risk_Product_Alias__c> lstRiskProductAlias;
    Boolean deleteAction = false;
    //Constructor
    public CSMCreateMapRiskProductsQueueable(List<Risk_Product_Alias__c> lstRiskProductAlias, Boolean deleteAction) {
        this.lstRiskProductAlias = lstRiskProductAlias;
        this.deleteAction = deleteAction;
    }

    //Logic run here
    public void execute(System.QueueableContext qc) {
        if(lstRiskProductAlias!=null && lstRiskProductAlias.size()>0){
            List<Related_Account_Plan__c> lstPlanProductRecords =  new List<Related_Account_Plan__c>();
            Set<String> setPlanProductId =  new Set<String>();
            Set<String> setOpportunityId =  new Set<String>();
            Set<Id> setPlanId =  new Set<Id>();
            Set<Id> setRiskId =  new Set<Id>();
            //Get plan products aias of risk product alias
            for(Risk_Product_Alias__c obj:lstRiskProductAlias){
                if(obj.Plan_Product_Alias__c!=null){
                    setPlanProductId.add(obj.Plan_Product_Alias__c);
                }

                if(obj.Opportunity__c !=null ){
                    setOpportunityId.add(obj.Opportunity__c);
                }
            }
            if(setPlanProductId.size()>0){
                //On update or create of Risk product alias
                if(!deleteAction){
                    if(setPlanProductId.size()>0 && setOpportunityId.size()>0){
                        for(Related_Account_Plan__c objPP:[SELECT Id, Plan_Product_Alias__c, Has_Risk_Associated__c FROM Related_Account_Plan__c WHERE Plan_Product_Alias__c=:setPlanProductId and Opportunity__c=:setOpportunityId]){
                        if(!objpp.Has_Risk_Associated__c){
                            objpp.Has_Risk_Associated__c = true;
                            lstPlanProductRecords.add(objpp);
                        }
                    }
                    }
                }else{
                    //On delete
                    setPlanProductId.clear();
                    lstPlanProductRecords.clear();
                    setOpportunityId.clear();
                    Set<Id> riskIdSet = new Set<Id>();
                    for(Risk_Product_Alias__c rprObj:lstRiskProductAlias){
                        if(rprObj.Risk__c!=null){
                            riskIdSet.add(rprObj.Risk__c);
                            //<T01>
                            setPlanProductId.add(rprObj.Plan_Product_Alias__c);
                            setOpportunityId.add(rprObj.Opportunity__c);
                            //</T01>
                        }
                    }
                    if(riskIdSet.size()>0){
                        //Extract the plans associate to deleted risk product alias
                        for(Risk_Issue__c objRisk:[SELECT Id,Plan__c FROM Risk_Issue__c WHERE Id=:riskIdSet]){                           
                            if(objRisk.Plan__c!=null){
                                setPlanId.add(objRisk.Plan__c);
                            }
                        }
                         
                        if(setPlanId.size()>0){                      
                            //Query the risks associated to plan
                            for(Risk_Issue__c objRisk:[SELECT Id,Plan__c FROM Risk_Issue__c WHERE Plan__c=:setPlanId]){
                                setRiskId.add(objRisk.Id);
                            }
                            if(setRiskId.size()>0){                            
                                //Query risk product alias to risks
                                /*for(Risk_Product_Alias__c obj:[SELECT Plan_Product_Alias__c,Plan_Product_Alias__r.Name__c,Opportunity__c FROM Risk_Product_Alias__c WHERE Risk__c=:setRiskId]){
                                    setPlanProductId.add(obj.Plan_Product_Alias__c);
                                    setOpportunityId.add(obj.Opportunity__c);
                                }*/
                                //Set the properties
                                //<T01>
                                if(setPlanProductId.size()>0 && setOpportunityId.size()>0){
                                    for(Related_Account_Plan__c objPP:[SELECT Id, Plan_Product_Alias__c, Has_Risk_Associated__c FROM Related_Account_Plan__c WHERE Plan_Product_Alias__c=:setPlanProductId and Opportunity__c=:setOpportunityId]){
                                    if(objpp.Has_Risk_Associated__c){
                                        objpp.Has_Risk_Associated__c = false;
                                        lstPlanProductRecords.add(objpp);
                                    }
                                //</T01>
                                }
                                }else{
                                    for(Related_Account_Plan__c objPP:[SELECT Id, Plan_Product_Alias__c, Has_Risk_Associated__c FROM Related_Account_Plan__c WHERE Account_Plan__c=:setPlanId]){
                                        if(objpp.Has_Risk_Associated__c){
                                            objpp.Has_Risk_Associated__c = false;
                                            lstPlanProductRecords.add(objpp);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //Finallly update recrods
                if(lstPlanProductRecords.size()>0){
                    try{
                        update lstPlanProductRecords;
                    }catch(Exception ex){                   
                        gamObj.CreateExceptionRecords('CSMCreateMapRiskProductsQueueable', 'exception in execute queue',ex.getMessage());
                    }
                }
            }
        }
    }
}