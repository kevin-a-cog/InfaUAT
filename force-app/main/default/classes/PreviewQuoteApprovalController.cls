/*
        Trigger:        PreviewQuoteApprovalController
        @Author:        Kiran G
        @Created Date:  22 April 2020
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description         
                                                    
    ******************************************************************************************************************************************* */
public with sharing class PreviewQuoteApprovalController{

    private Id quoteId;
    private SBQQ__Quote__c sbqqQuote;
    String revisionLabel = Label.RevisionLabel;
    
    public PreviewQuoteApprovalController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        this.sbqqQuote = [select id, Sub_Type__c from SBQQ__Quote__c where id = :quoteId limit 1];      
    }
    
    public PageReference redirect() {
        if (quoteId != null && sbqqQuote.Sub_Type__c != revisionLabel) {
            PageReference pageRef = new PageReference('/apex/sbaa__PreviewApprovals?Id='+quoteId);
            return pageRef;
          }
      else {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Revision Quote connot be Submitted for Approval.Change the status manually to Approved.');
        ApexPages.addMessage(msg);
        return null;
      }
    }
    
    /*
    Method Name : onReturn,
    * @param 
    * @return PageReference
    * @throws exception - NA
    This method call for Return to Quote button
    */
    public PageReference onReturn() {

        return new PageReference('/' + quoteId);
    }
}