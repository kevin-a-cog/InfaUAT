/*
 * Name         :   CSMPlanCommsInternalCommentHelper
 * Author       :   Deva M
 * Created Date :   24/01/2022
 * Description  :   Helper class for Plan Communication-  Internal Comments Automation module

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Deva M                 30/11/2021      AR-1734             Initial version.            N/A
 */
public with sharing class CSMPlanCommsInternalCommentHelper {   
    public static String PAF_IMPACT_ANALYSIS_COMPLETED_BY_MANAGER = 'PAF_Impact_Analysis_completed_by_Manager';
    public static String PAF_RISK_IMPACT_TEMPLATE = 'PAF_Risk_Impact_Template';
   /*
     Method Name : createEngagementInternalComment
     Description : This method will create internal plan comments for various engagement types
     Parameters  : Map<Id,Engagement__c> mapEnagement, Called from Engagement after update
     Return Type : NA
     */
    public static void createEngagementInternalComment(Map<Id,Engagement__c> mapEnagement){     
        if(mapEnagement.size()>0){
            System.enqueueJob(new CSMCreateEngagementCommentsQueueable(mapEnagement));
        }
    }
     
   /*
     Method Name : createObjectiveInternalComment
     Description : This method will create internal plan comments for Objecitve Records
     Parameters  : Map<Id,Objective__c> mapObjective, Called from Objective after update
     Return Type : NA
     */
    public static void createObjectiveInternalComment(Map<Id,Objective__c> mapObjective){
        if(mapObjective.size()>0){
            System.enqueueJob(new CSMCreateObjectiveCommentsQueueable(mapObjective));
        }        
    }
     /*
     Method Name : createPafManagerComment
     Description : This method will create internal plan comments for PAF when manager input the scalars
     Parameters  : String strPAFId, Called from PAF
     Return Type : NA
     */
    @AuraEnabled(cacheable=false)
    public static void createPafManagerComment(String strPAFId,String strPlanId){
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        String strCleanRecordId;
        String strCleanPlanId;
        if(String.isNotBlank(strPAFId) && String.isNotBlank(strPlanId)) {
            strCleanRecordId = String.escapeSingleQuotes(strPlanId);
            strCleanPlanId = String.escapeSingleQuotes(strPlanId);
            String  userTimeZoneName = CSMUtilities.getUserTimeZone();
            Map<String,EmailTemplate> mapEmailTemplates = CSMUtilities.getEmailTemplate();          
            //When the objecitve is signed
            if(mapEmailTemplates.get(PAF_IMPACT_ANALYSIS_COMPLETED_BY_MANAGER)!=null){               
                String mergedText = csmPlanQuickActionController.renderTemplate(strPAFId, mapEmailTemplates.get(PAF_IMPACT_ANALYSIS_COMPLETED_BY_MANAGER).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
               lstPlanComments.add(CSMUtilities.createPlanComment(strCleanPlanId,
                                                                    mergedText,
                                                                    CSMUtilities.STATUS_SUBMITTED,
                                                                    CSMUtilities.TYPE_INTERNAL,
                                                                    CSMUtilities.SUBTYPE_PLANHEALTHREASON,
                                                                    true
                                                                    )

                );
            }
           
            //Now insert plan comments
            if(lstPlanComments.size()>0){
                insert lstPlanComments;
            }
        }
    }



    /*
     Method Name : createRiskCommentFromPAF
     Description : This method will create internal plan comments for PAF when manager input the scalars
     Parameters  : String strRiskRecordId, Called from PAF
     Return Type : NA
     */
    @AuraEnabled(cacheable=false)
    public static void createRiskCommentFromPAF(String strRiskRecordId,String strRiskProductId){
        List<Plan_Comment__c> lstPlanComments = new List<Plan_Comment__c>();
        String strCleanRiskRecordId;
        String strCleanRiskProductRecordId;
        if(String.isNotBlank(strRiskRecordId)){
            strCleanRiskRecordId = String.escapeSingleQuotes(strRiskRecordId);
            strCleanRiskProductRecordId = String.escapeSingleQuotes(strRiskProductId);
            String  userTimeZoneName = CSMUtilities.getUserTimeZone();            
            Map<String,EmailTemplate> mapEmailTemplates = CSMUtilities.getEmailTemplate();    
            Risk_Issue__c objRisk=[SELECT Id, Plan__c FROM Risk_Issue__c WHERE Id=:strCleanRiskRecordId];  
            //When the objecitve is signed
            if(mapEmailTemplates.get(PAF_RISK_IMPACT_TEMPLATE)!=null && objRisk!=null && objRisk.Plan__c!=null){
                String mergedText = csmPlanQuickActionController.renderTemplate(strCleanRiskProductRecordId, mapEmailTemplates.get(PAF_RISK_IMPACT_TEMPLATE).HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
                lstPlanComments.add(CSMUtilities.createPlanComment(objRisk.Plan__c,
                                                                    mergedText,
                                                                    CSMUtilities.STATUS_SUBMITTED,
                                                                    CSMUtilities.TYPE_INTERNAL,
                                                                    CSMUtilities.SUBTYPE_RISK,
                                                                    true
                                                                    )

                );
            }
           
            //Now insert plan comments
            if(lstPlanComments.size()>0){
                insert lstPlanComments;
            }
        }
    }
}