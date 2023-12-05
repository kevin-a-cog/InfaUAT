/****************************************************************************************************************************
 *  @Class Name: PRM_EmailWrapper
 *  @Author: Puneet
 *  @Date: 
 *  @Description: This is wrapper being used in flow
 *****************************************************************************************************************************
ChangeHistory      
****************************************************************************************************************************/
public without sharing class PRM_EmailWrapper {
    
    @AuraEnabled @InvocableVariable public String recordId;
    @AuraEnabled @InvocableVariable public String userId;
    @AuraEnabled @InvocableVariable public String templateId;
    @AuraEnabled @InvocableVariable public String subject;
    @AuraEnabled @InvocableVariable public String ccEmails;
    
    public PRM_EmailWrapper(){
        this.recordId = '';
        this.userId = '';
        this.templateId = '';
        this.subject = '';
        this.ccEmails = '';
    }
}