/***************************************************************************************************************************************************************
 *  @Class Name: CustomLeadConvert
 *  @Author: Jiju N
 *  @Date: 10 AUG 2022
 *  @Description: Convert Leads to Account and Contact passed via rest api
 ****************************************************************************************************************************************************************
*/
@RestResource(urlMapping='/CustomLeadConvert/*')
global class CustomLeadConvert{
    public static globalApexManager GAM = new globalApexManager();
    private static String dealRegistration = 'Deal Registration'; // SALESRT-13356 
    @HttpPost
    @AuraEnabled(cacheable = false)
    global static Map<String,String> convertLead(string leadId, String contactId, String accountId,String opportunityId, Boolean doNotCreateOpportunity, String opportunityName) //SALESRT-13356
    {
       Map<String,String> responseMap = new Map<String,String>();
        Database.LeadConvert lc = new Database.LeadConvert();
        // SALESRT-13356 start
        LeadStatus convertStatus;
        Lead leadRecord = [SELECT Id, RecordType.Name FROM Lead WHERE Id =: leadId LIMIT 1];
        if(leadRecord.RecordType.Name == dealRegistration){
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel='Approved' LIMIT 1];      
        } else {
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND MasterLabel='Qualified' LIMIT 1];
        }
        //
        lc.setLeadId(leadId);
        if(accountId != null && accountId != '') {
            lc.setAccountId(accountId);
        }
        if(contactId != null && contactId != '') {
            lc.setContactId(contactId);
        }
        // SALESRT-13356 start
        if(opportunityId != null && opportunityId != '') {
            lc.setOpportunityId(opportunityId);      
        }   
        if((opportunityName != null && opportunityName != '') || (doNotCreateOpportunity == true && opportunityName == null)){
            lc.setOpportunityName(opportunityName);
        }
        //
        lc.setDoNotCreateOpportunity(doNotCreateOpportunity);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        try {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.LeadConvertResult lcr = Database.convertLead(lc,dml);
            String response = lcr.isSuccess() ? 'success' : 'failed' ;
            if(lcr.isSuccess()){
                responseMap.put('accountId',lcr.getAccountId());
                responseMap.put('contactId',lcr.getContactId());
                responseMap.put('opportunityId',lcr.getOpportunityId()); //SALESRT-13356
            } else {
                responseMap.put('accountId','');
                responseMap.put('contactId','');
                //SALESRT-13356
                responseMap.put('opportunityId','');
                responseMap.put('error',lcr.getErrors()[0].getMessage());
                //
            }
            responseMap.put('response',response);
        } catch(Exception e) {
            GAM.CreateExceptionRecords('CustomLeadConvert', e.getStackTraceString()+ e.getMessage(), 'error from CustomLeadConvert Apex Rest API');
            responseMap.put('response','failed');
            responseMap.put('error',e.getMessage());
            return responseMap;
        }
        return responseMap;
    }
}