/*
        Trigger:        QuoteExtController
        @Author:        William Devich
        @Created Date:  7 Aug 2017
        @Description:   To redirect to SBAA.ApprovalAPI to recall/submit quote
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description         
    Kiran G          27 Dec 2018    SALESRT-3964  Liz M             Handled the validation in Try catch and display the proper error 
                                                                    and added the code to Return to Quote button.                      T01
    Kiran G         15 Apr 2020     SALESRT-11842  Sunil M          Added a condition to check if the Quote is Admin and not trigger
                                                                    approvals .                                                        T02
    ********************************************************************************************************************************************
*/
public with sharing class QuoteExtController {
    private Id quoteId;
    private SBQQ__Quote__c sbqqQuote;
    String revisionLabel = Label.RevisionLabel;

    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        this.sbqqQuote = [select id, Sub_Type__c from SBQQ__Quote__c where id = :quoteId limit 1]; //T02        
    }
    
    /*
    Method Name : onSubmit,
    * @param 
    * @return PageReference
    * @throws exception - NA
    
    This method call from Recall Quote Page
    */
    public PageReference onSubmit() {
        
        //-----------------------------------------------------------------------------<T01>
        try{
            if (quoteId != null && sbqqQuote.Sub_Type__c != revisionLabel) {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
                return new PageReference('/' + quoteId);
            }  
            //------------------------------------<T02>---------------------------------------
            if(sbqqQuote.Sub_Type__c == revisionLabel){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Revision Quote connot be Submitted for Approval.Change the status manually to Approved.'));
                return null;  
            }
            //------------------------------------<T02>---------------------------------------     
        }
        catch(Exception e){            
           ApexPages.addMessages(e);
        }
        return null;
        //-----------------------------------------------------------------------------</T01>
    }
    
    /*
    Method Name : onRecall,
    * @param 
    * @return PageReference
    * @throws exception - NA
    
    This method call from Submi Quote page
    */
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    //-----------------------------------------------------------------------------<T01>
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
    //-----------------------------------------------------------------------------</T01>
}