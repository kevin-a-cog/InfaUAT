/*
    @created by       : balajip
    @created on       : 12/04/2020
    @Purpose          : 
    @Testclass        : 
    @JIRA             : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 */
global without sharing class psa_HelpController {
    
    @AuraEnabled
    public static List<Help_Item__mdt> getHelpItems(){
        List<Help_Item__mdt> lstHelpItem = [Select Id, Item_Label__c, URL__c, Item_Order__c
                                                From Help_Item__mdt
                                                Where Pertains_To__c = 'PSA' And Active__c=true
                                                Order By Item_Order__c];
        return lstHelpItem;
    }
}