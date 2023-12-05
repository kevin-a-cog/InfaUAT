/*
Class:          NextActionRecommendation 

@Author:        Ambica P
@Created Date:  30 May 2020
@Description:   Controller class for LWC nextActionRecommendation
*/


public with sharing class NextActionRecommendation {

    @AuraEnabled(cacheable=true)

    public static List< Next_Action_Recommendation__c> getRecommendation( Id riskId){


        

        //Get Risk Fields
        List<Risk_Issue__c> lstriskRecord = new List<Risk_Issue__c>();
        lstriskRecord = [Select id,Type__c,Risk_Reason__c,Risk_Reason_Secondary__c from Risk_Issue__c where id= :riskId limit 1];


        if(lstriskRecord !=null && lstriskRecord.size()>0){

            Risk_Issue__c riskRecord= lstriskRecord[0];

            //Get all Risk Reason
            List<String> lstRiskReason = new List<String>();

            if (riskRecord.Risk_Reason__c!=null){
                lstRiskReason.add(riskRecord.Risk_Reason__c);
            }

            if (riskRecord.Risk_Reason_Secondary__c!=null){
                lstRiskReason.addall(riskRecord.Risk_Reason_Secondary__c.split(';'));
            }



            List <Next_Action_Recommendation__c> lstRecommendation = [Select Id,Name,Type__c,Next_Action_Summary__c from Next_Action_Recommendation__c 
            where Risk_Type__c = : riskRecord.Type__c and Risk_Reason__c in : lstRiskReason] ;

            

            return lstRecommendation;
        }
        else {


            return null;
        }
    
    }

}