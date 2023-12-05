/*
 * Name			:	CSMRiskTriggerHelper
 * Author		:	Deva M
 * Created Date	: 	07-Apr-2022
 * Description	:	Helper class for CSM Risk Trigger

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					                Tag
 **********************************************************************************************************
 Deva M					07-Apr-2022		N/A 			Initial version.			                N/A
 Narpavi Proabu         29-Aug-2022    AR-2771          Trigger Notification Subscription for Risk  T01
 */
public with sharing class CSMRiskTriggerHelper {
    private final String  RISK_UNRESOLVED_STATUS = 'Unresolved';
    private final String  RISK_RESOLVED_STATUS = 'Resolved';
    public static globalApexManager gamObj = new globalApexManager();
    /*
    Method Name : processBefoprocessAfterUpdatereUpdate
    Description : Methods will be called on after update
    */
    public void processAfterUpdate(List<Risk_Issue__c> newList,Map<Id,Risk_Issue__c> oldMap){
        //updateHasRiskAssociated(newList,oldMap);
        //<T01>
        NotificationService.notify(newList, oldMap);
    }
    /*
	 Method Name : updateHasRiskAssociated
	 Description : This method will be update all the plan product wiht Has_Risk_Associated__c if any risk product alias record created .
	 Parameters	 : List<Risk_Issue__c> newList,Map<Id,Risk_Issue__c> oldMap
	 Return Type : String
	 
    public void updateHasRiskAssociated(List<Risk_Issue__c> newList,Map<Id,Risk_Issue__c> oldMap){
        Set<Id> riskIdSet = new Set<Id>();
        Set<String> setPlanProductId =  new Set<String>();
        Set<String> setOpportunityId =  new Set<String>();
        Set<Id> setPlanId =  new Set<Id>();
        List<Related_Account_Plan__c> lstPlanProductRecords =  new List<Related_Account_Plan__c>();

        for(Risk_Issue__c objRisk:newList){
            if(oldMap!=null && oldMap.get(objRisk.Id)!=null){
                Risk_Issue__c oldRisk = oldMap.get(objRisk.Id);
                System.debug('-->'+oldRisk.Plan__c);
                //Check if Risk Closed
                if(objRisk.Risk_Stage__c != oldRisk.Risk_Stage__c && String.isNotBlank(objRisk.Risk_Stage__c) && (objRisk.Risk_Stage__c.equals(RISK_UNRESOLVED_STATUS) || objRisk.Risk_Stage__c.equals(RISK_RESOLVED_STATUS))){
                    if(objRisk.Plan__c!=null){
                        System.debug('-->'+oldRisk.Plan__c);
                        setPlanId.add(objRisk.Plan__c);
                    }
                } 
            }
        }         
        System.debug('-->'+setPlanId);  
        if(setPlanId.size()>0){
            //Query the risks associated to plan
            for(Risk_Issue__c objRisk:[SELECT Id,Plan__c,Status__c,Risk_Stage__c FROM Risk_Issue__c WHERE Plan__c=:setPlanId]){
                if(String.isNotBlank(objRisk.Risk_Stage__c) && !(objRisk.Risk_Stage__c.equals(RISK_UNRESOLVED_STATUS) || objRisk.Risk_Stage__c.equals(RISK_RESOLVED_STATUS))){
                    riskIdSet.add(objRisk.Id);
                }
            }
            if(riskIdSet.size()>0){
                //Query risk product alias to risks
                for(Risk_Product_Alias__c obj:[SELECT Plan_Product_Alias__c,Plan_Product_Alias__r.Name__c,Opportunity__c FROM Risk_Product_Alias__c WHERE Risk__c=:riskIdSet]){
                    if(obj.Plan_Product_Alias__c!=null && String.isNotBlank(obj.Plan_Product_Alias__r.Name__c)){
                        setPlanProductId.add(obj.Plan_Product_Alias__r.Name__c);
                    }
                    if(obj.Opportunity__c!=null){
                        setOpportunityId.add(obj.Opportunity__c);
                    }
                }
            }
            //Set the properties                
            for(Related_Account_Plan__c objPP:[SELECT Id, Plan_Product_Alias__c, Plan_Product_Alias__r.Name__c,Has_Risk_Associated__c,Opportunity__c FROM Related_Account_Plan__c WHERE Account_Plan__c=:setPlanId]){
                if(setOpportunityId.size()>0 && objPP.Opportunity__c!=null && setOpportunityId.contains(objPP.Opportunity__c)  && 
                    setPlanProductId.size()>0 && objPP.Plan_Product_Alias__r.Name__c!=null && setPlanProductId.contains(objPP.Plan_Product_Alias__r.Name__c) && !objpp.Has_Risk_Associated__c){
                    objpp.Has_Risk_Associated__c = true;
                    lstPlanProductRecords.add(objpp);
                }else if(objPP.Opportunity__c==null && setPlanProductId.size()>0 && objPP.Plan_Product_Alias__r.Name__c!=null && setPlanProductId.contains(objPP.Plan_Product_Alias__r.Name__c) && !objpp.Has_Risk_Associated__c){
                    objpp.Has_Risk_Associated__c = true;
                    lstPlanProductRecords.add(objpp);
                }else if(objpp.Has_Risk_Associated__c){
                    objpp.Has_Risk_Associated__c = false;
                    lstPlanProductRecords.add(objpp);
                }
            }
            //Finallly update recrods
            if(lstPlanProductRecords.size()>0){
                try{
                    update lstPlanProductRecords;
                }catch(Exception ex){
                    gamObj.CreateExceptionRecords('CSMRiskTriggerHelper', 'exception in Risk Trigger ',ex.getMessage());
                }
            } 
        }       
    }   */

    public void processBeforeDelete (List<Risk_Issue__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
            System.debug('In Plan contact');
            for( Risk_Issue__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
                System.debug('In Plan contact');
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];

                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                        System.debug('In Plan contact');
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Risk_Issue__c ac:newList){
                    System.debug('In Plan contact');
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                    }
                }
            }
        
    }

     /**
    Method Name : processAfterInsert
    Description : Methods will be called on after insert
    */
     //< T01> - Added to trigger notification subscription
    public void processAfterInsert(List<Risk_Issue__c> newList,Map<Id, Risk_Issue__c> oldMap)
    {
        NotificationService.notify(newList, oldMap);
    }

}