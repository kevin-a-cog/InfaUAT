/*
    @created by       : Venky K
    @created on       : 01/17/2022
    @Purpose          : CaseWeightageTriggerHandler class to populate weightage on case weightage record
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 */


Public Class CaseWeightageTriggerHandler{
    Public Static Void updateWeightage(List<Case_Weightage__c> TriggerNew){
        for(Case_Weightage__c cw : TriggerNew){
            CW.Final_Case_Weightage__c = Integer.valueOf(CW.Name.split('%')[0]);
            String body = '<div style="background-color: #ebeeea;"><table><tbody>';
            if(CW.Band__c == 'S1'){
                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Base Severity: Very High (75%)</td></tr>';
            }else if(CW.Band__c == 'S2'){                body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Base Severity: High (50%)</td></tr>';            }else{
                body = body + '<tr><td style="background-color: #1F9C1F;">&nbsp;</td><td>&nbsp;Base Severity: Normal (25%)</td></tr>';
            }
            if(CW.Web_Escalation_with_Manager_Callback__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Web Escalation with Manager Callback: ' +CW.Web_Escalation_with_Manager_Callback__c+'%</td></tr>';            }
            if(CW.GEMS_Escalation__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Gems Escalation: ' +CW.GEMS_Escalation__c+'%</td></tr>';            }
            if(CW.Live_Handoff__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Live Handoff: ' +CW.Live_Handoff__c+'%</td></tr>';            }
            if(CW.Web_Escalation_other_than_manager_call__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Web Escalation (other than manager call): ' +CW.Web_Escalation_other_than_manager_call__c+'%</td></tr>';            }
            if(CW.CSM_Escalated__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Csm Escalated: ' +CW.CSM_Escalated__c+'%</td></tr>';            }
            if(CW.Predictive_Escalation_P1__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Predictive Escalated P1: ' +CW.Predictive_Escalation_P1__c+'%</td></tr>';            }
            if(CW.P1_Priority__c > 0){   
                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;P1 Priority: ' +CW.P1_Priority__c+'%</td></tr>';
            }
             if(CW.P0_Flag__c > 0){                body = body + '<tr><td style="background-color: red;">&nbsp;</td><td>&nbsp;Flagged As P0: ' +CW.P0_Flag__c+'%</td></tr>';            }
            if(CW.BCSP_Within_IR_SLA__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;BCSP Within IR SLA: '+CW.BCSP_Within_IR_SLA__c+'%</td></tr>';            }
            if(CW.Multiple_active_P1s_on_the_project__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Multiple Active P1S On The Project: '+ CW.Multiple_active_P1s_on_the_project__c +'%</td></tr>';            }
            if(CW.GEMS_escalation_on_account__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Gems Escalation On Account: '+CW.GEMS_escalation_on_account__c+'%</td></tr>';            }
            if(CW.Predictive_Escalation_Non_P1__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Predictive Escalation (Non-P1): '+CW.Predictive_Escalation_Non_P1__c+'%</td></tr>';            }
            if(CW.Inactive_case__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Inactive Case: '+CW.Inactive_case__c+'%</td></tr>';            }
            if(CW.Re_opened_case__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Re-Opened Case: '+CW.Re_opened_case__c+'%</td></tr>';            }
            if(CW.Strategic_customers_Same_Timezone__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Strategic Same Timezone: '+CW.Strategic_customers_Same_Timezone__c+'%</td></tr>';            }
            
            
            if(CW.Subscription_Beyond_120_Days__c > 0){ body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;Subscription Beyond 120 Days: '+CW.Subscription_Beyond_120_Days__c+'%</td></tr>';            }
            if(CW.P2_Priority__c > 0){   body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;P2 Priority: '+CW.P2_Priority__c+'%</td></tr>';            }
            if(CW.P3_Priority__c > 0){   body = body + '<tr><td style="background-color: #D7AB15;">&nbsp;</td><td>&nbsp;P3 Priority: '+CW.P3_Priority__c+'%</td></tr>';            }
            
            if(CW.Waiting_on_customer__c != 0){
                body = body + '<tr><td style="background-color: #C1C8C1;">&nbsp;</td><td>&nbsp;Case Is Waiting On Customer: '+CW.Waiting_on_customer__c+'%</td></tr>';
            }
            if(CW.Waiting_on_Third_Party__c != 0){
                body = body + '<tr><td style="background-color: #C1C8C1;">&nbsp;</td><td>&nbsp;Case Is Waiting On Third Party: '+CW.Waiting_on_Third_Party__c+'%</td></tr>';
            }
            if(CW.Waiting_on_Case_Team_R_D__c != 0){
                body = body + '<tr><td style="background-color: #C1C8C1;">&nbsp;</td><td>&nbsp;Case Is Waiting On Case Team, R&D: '+ CW.Waiting_on_Case_Team_R_D__c +'%</td></tr>';
            }
            if(CW.Non_Customer_Timezone_For_p2_and_p3__c != 0){
                body = body + '<tr><td style="background-color: #C1C8C1;">&nbsp;</td><td>&nbsp;Non Customer Timezone For P2 And P3: '+CW.Non_Customer_Timezone_For_p2_and_p3__c+'%</td></tr>';
            }
            if(CW.Non_strategic_P2_And_P3__c != 0){
                body = body + '<tr><td style="background-color: #C1C8C1;">&nbsp;</td><td>&nbsp;Non-Strategic P2 And P3: '+CW.Non_strategic_P2_And_P3__c+'%</td></tr>';
            }
            
            
            body = body + '</tbody></table></div>';
            CW.Weightage__c = body;
        }
    }
}