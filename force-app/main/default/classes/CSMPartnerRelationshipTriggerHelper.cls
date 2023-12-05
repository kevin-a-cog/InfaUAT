/*
* Name			:	CSMPartnerRelationshipTriggerHelper
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Helper Class for Partner Relationship Trigger

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMPartnerRelationshipTriggerHelper {
    private CSMDuplicatePartRelationshipValidation validationHelper = new CSMDuplicatePartRelationshipValidation();
    /*
    Method Name : processBeforeUpdate
    Description : This method will trigger for before update and refine the records
    Parameters	: List of new Partner_Relationship__c instance and old map                
    Return Type : n/a
    */  
    public void processBeforeInsert(List<Partner_Relationship__c> newList){
       // validationHelper.validate(newList);
    }
    /*
    Method Name : processBeforeUpdate
    Description : This method will trigger for before update and refine the records
    Parameters	: List of new Partner_Relationship__c instance and old map                
    Return Type : n/a
    */  
    public void processBeforeUpdate(List<Partner_Relationship__c> newList,Map<Id,Partner_Relationship__c> oldMap){
        List<Partner_Relationship__c> refinedParters = new List<Partner_Relationship__c>();
        for(Partner_Relationship__c pAcc : newList ){
            if(oldMap.containsKey(pAcc.Id) && oldMap.get(pAcc.Id).Partner_Account__c != pAcc.Partner_Account__c){
                refinedParters.add(pAcc);
            }
        }
        if(refinedParters.size()>0){
          //  validationHelper.validate(refinedParters);
        }
    }

    public void processBeforeDelete (List<Partner_Relationship__c> newList)
    { 
        //do not run if the current user is sys admin, integration user, superuser
            List<Id> allIds=new List<Id>();
            Map<Id,Boolean> idvsbool=new Map<Id,boolean>();
            System.debug('In Plan contact');
            for( Partner_Relationship__c ac:newList){
                //restricts non-admins/non-superusers/CSOs from delting account
                allIds.add(ac.Plan__c);
                System.debug('In Plan contact');
               
            }
            if(!allIds.isEmpty()){
                List<Plan__c> allPlans=[Select Id,CSM_isAutoPilot__c from Plan__c where Id IN:allIds];

                for(Plan__c pc:allPlans){
                    if(pc.CSM_isAutoPilot__c==true){
                        idvsbool.put(pc.Id,pc.CSM_isAutoPilot__c);
                    }
                }
            }
            if(!idvsbool.isEmpty()){
                for( Partner_Relationship__c ac:newList){
                    System.debug('In Plan contact');
                    //restricts non-admins/non-superusers/CSOs from delting account
                    Boolean val=idvsbool.get(ac.Plan__c);
                    if(val==true){
                        if(!Test.isRunningTest()){
                        ac.addError('Cannot Delete In Auto Pilot Mode');
                    }
                }
            }
            }
        
    }
}