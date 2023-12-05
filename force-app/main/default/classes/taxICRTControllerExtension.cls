/***************************************************************************************************************************************************************
 *  @Class Name: taxICRTControllerExtension
 *  @Author: Chandana Gowda
 *  @Date: 22 Jun 2021
 *  @Description: TAX-141 : Controller for vf page displayed on update Tax
                            
 ******************************************************************************************************************************************************************
 ModifiedBy          Date          Requested By          Description                            Tag  
 Dayanidhee Singh         22 Sep 2021                TAX-196                      Condition to Allow for call to OneSource to complete             <TAX-196>
                                                                                  successfully when Quote Lines has all $0 lines
 Nishit S           9-21-2021        TAX-200              Invoke ONESOURCE only when generating Output Documents       <TAX-200>
                                          upon initial Quote creation or after editing Quotes 
                                          based on criteria 
 Dayanidhee Singh         27 Oct 2021                TAX-167                    Selecting Update Tax on Non-US001 or Non-US/CA Quotes only           <TAX-167>
                                                                                display a warning message on the Quote rather than redirect 
                                                                                and display the warning message on the tax integration “splash screen.”             
VENKATESH BALLA     07 DEC 2022                       added for SALESRT-14435   added a line to call IPU Commitment annualization logic.                                                                                       
 ******************************************************************************************************************************************************************/
public class taxICRTControllerExtension {
    public SBQQ__Quote__c quoteObj {get;set;}
    //Error message to be displayed when update is not called
    //public String status {get;set;} --<TAX-167>
    //To determine if update tax has to be called from Generate Document and Generate Partner Document
    public Boolean isTaxAppicable {get;set;}
    {isTaxAppicable = false;} //<TAX-196>
    //To determine if it need to update the exempt status when all Quote Line has $0 Lines
    public Boolean isUpdateStatusOverride {get;set;}
    {isUpdateStatusOverride = false;} //<TAX-196>
    //Flag to display error/Icrt Guide
    //public Boolean renderOnLoadError {get;set;} --<TAX-167>
    //Flag to control the visibiliy of buttons
    public Boolean renderButtons {get;set;}
    {renderButtons = false;} //--<TAX-167>
    //To identify from where the page was invoked
    public String calledFrom {get;set;}
    //To identify the tax update Status
    public String taxUpdateStatus {get;set;}
    
    /* Method Name : taxICRTControllerExtension
    * @description - Constructor of the class, to check if the tax is applicable, Error conditions
    */ 
    public taxICRTControllerExtension(ApexPages.StandardController stdController) {
        this.quoteObj = (SBQQ__Quote__c)stdController.getRecord();
        //<TAX-196> - fetching quote line data
        SBQQ__Quote__c quoteList = [SELECT OneSource_Last_Call_Time__c,Tax_Update_Status__c,Exempt_Status__c,SBQQ__LineItemCount__c,SBQQ__ShippingCountry__c,Business_Unit__c,SBQQ__Ordered__c,(SELECT SBQQ__NetTotal__c FROM SBQQ__LineItems__r WHERE SBQQ__NetTotal__c != 0)
                                    FROM SBQQ__Quote__c WHERE Id = :quoteObj.Id];
        List<Tax_Country__mdt> taxmdt = [SELECT MasterLabel,CMS_Chatter_Group__c,CMS_Queue_Id__c FROM Tax_Country__mdt
                                         WHERE MasterLabel  = :quoteList.SBQQ__ShippingCountry__c AND Is_Taxable__c =true];
        
        //<TAX-196> - Updating the expemt status to override
        if(quoteList.SBQQ__LineItems__r.size() == 0 && quoteList.Exempt_Status__c != 'Override'){
            isUpdateStatusOverride = true;
        }
        
        //Check if the Tax Processig is Appicable
        //<TAX-196> - Added quote line check
        //<TAX-200> - Added Conditions for Compute Tax, failed and Last call time
        if(quoteList.SBQQ__LineItems__r.size() != 0 && quoteList.Business_Unit__c == 'US001' && taxmdt.size() > 0 && quoteList.Exempt_Status__c != 'Override' && quoteList.SBQQ__LineItemCount__c != 0 
           && !quoteList.SBQQ__Ordered__c && (quoteList.Tax_Update_Status__c == 'Compute Tax' || quoteList.Tax_Update_Status__c == 'Failed' || (quoteList.OneSource_Last_Call_Time__c !=NULL && (quoteList.OneSource_Last_Call_Time__c.month()!= System.today().month() || quoteList.OneSource_Last_Call_Time__c.year()!= System.today().year())))){
            isTaxAppicable = true;
            taxUpdateStatus = 'Running'; //--<TAX-167>
        }        
       
        //Set only if called from Update Tax button
        if(String.isBlank(calledFrom)){
            calledFrom = 'updateTax'; 
            taxUpdateStatus = 'Running'; //--<TAX-167>           
        }
        
        //<TAX-167> - Removed the loading error message from vf page        
        //Setting appropriate error message when clicked on Update Tax Button
        // if(!(quoteList.Business_Unit__c == 'US001' && taxmdt.size() > 0)){
        //     status = Label.TaxBUShipCountryError;
        // }else if(quoteList.Exempt_Status__c == 'Override'){ 
        //     status = Label.TaxExemptOverrideError;
        // }else if(quoteList.SBQQ__LineItemCount__c == 0 || quoteList.SBQQ__LineItems__r.size() == 0 || quoteList.SBQQ__Ordered__c ){ //<TAX-196>
        //     status = Label.TaxNoQuoteLinesError;
        // }
        //Display Guide if the no error - status is blank when clicked on update tax button        
        //if(!(String.isNotBlank(status))){
        //    taxUpdateStatus = 'Running';
        //}
        // if(String.isNotBlank(status)){
        //     renderOnLoadError = true;  
        //     renderButtons = true;          
        //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, status)); 
        // }else{
        //     renderOnLoadError = false;
        //     renderButtons = false;
        //     taxUpdateStatus = 'Running';
        // }
    }

    //<TAX-167> - Method to check for different errors on quote and display proper error message based on error
    /* Method Name : CheckTaxApplicableAndErrorMessage
    * @param mapNew - quoteId - Quote RecordId
    * @return return - String
    * @throws exception - NA
    * @description - Return string with proper error message for why tax is not applicable and why document can't be generated
    */    
    @AuraEnabled
    public static String CheckTaxApplicableAndErrorMessage(Id quoteId){
        String res = 'False';
        SBQQ__Quote__c quoteList = [SELECT OneSource_Last_Call_Time__c,Tax_Update_Status__c,Exempt_Status__c,SBQQ__LineItemCount__c,SBQQ__ShippingCountry__c,Business_Unit__c,SBQQ__Ordered__c,(SELECT SBQQ__NetTotal__c FROM SBQQ__LineItems__r WHERE SBQQ__NetTotal__c != 0)
                                    FROM SBQQ__Quote__c WHERE Id = :quoteId];
        List<Tax_Country__mdt> taxmdt = [SELECT MasterLabel,CMS_Chatter_Group__c,CMS_Queue_Id__c FROM Tax_Country__mdt
                                         WHERE MasterLabel  = :quoteList.SBQQ__ShippingCountry__c AND Is_Taxable__c =true];
        if(quoteList.Business_Unit__c == 'US001' && taxmdt.size() > 0){
            if(quoteList.Exempt_Status__c == 'Override'){ 
                res = 'exemptError';
            } else if(quoteList.SBQQ__LineItemCount__c == 0){ 
                res = 'generalError';
              
            }else if(quoteList.SBQQ__LineItems__r.size() == 0){
                  res = 'generalError';
                  setExemptStatusToNotApplicable(quoteId);
            }
             //else if(quoteList.SBQQ__Ordered__c){
               //   res = 'orderError';
            //}
            else{
                res = 'True';
            }
        }
        return res;
    }
    
    /* Method Name : setExemptStatusToNotApplicable
    * @param mapNew - quoteId - Quote RecordId
    * @return return - String
    * @throws exception - NA
    * @description - Return true if Tax Exempt status is set to override, else returns false
    */
    public static void setExemptStatusToNotApplicable(Id quoteId){
        
        SBQQ__Quote__c quoteRec = [SELECT Id,Business_Unit__c,SoldToAccount__c,SoldToAccount__r.ERP_Company__c,Sold_to_Account_ERP_Site__c,SBQQ__ShippingCountry__c,SBQQ__ShippingState__c,SBQQ__ShippingCity__c,SBQQ__ShippingPostalCode__c,SBQQ__ShippingStreet__c FROM SBQQ__Quote__c WHERE Id = :quoteId];
        
        ERP_Site__c erpSitetoUpsert = new ERP_Site__c();
        //If ERP Site exists on Quote update the Exempt Status
        if(quoteRec.Sold_to_Account_ERP_Site__c != null){
            erpSitetoUpsert.Id = quoteRec.Sold_to_Account_ERP_Site__c;
            erpSitetoUpsert.Exempt_Status__c = 'Not Applicable';
        }else{
            Map<Id,ERP_Site__c> erpSiteMap = new Map<Id,ERP_Site__c>([SELECT Id,ERP_Company__c,State_Province__c,Country__c FROM ERP_Site__c WHERE ERP_Company__c = :quoteRec.SoldToAccount__r.ERP_Company__c]);
            Boolean erpSitePresent = false;
            for(ERP_Site__c erpSite:erpSiteMap.values()){
                if(quoteRec.SBQQ__ShippingCountry__c == erpSite.Country__c && quoteRec.SBQQ__ShippingState__c == erpSite.State_Province__c){
                    erpSitePresent = true;
                    erpSitetoUpsert.Id = erpSite.Id;
                    erpSitetoUpsert.Exempt_Status__c = 'Not Applicable';
                    break;
                }
            }
            if(!erpSitePresent){
                erpSitetoUpsert.State_Province__c = quoteRec.SBQQ__ShippingState__c;
                erpSitetoUpsert.Country__c = quoteRec.SBQQ__ShippingCountry__c;
                erpSitetoUpsert.City__c = quoteRec.SBQQ__ShippingCity__c;
                erpSitetoUpsert.Address_Line_1__c = quoteRec.SBQQ__ShippingStreet__c;
                erpSitetoUpsert.ZIP_Code__c = quoteRec.SBQQ__ShippingPostalCode__c;
                erpSitetoUpsert.Name = quoteRec.SBQQ__ShippingCountry__c+'_'+quoteRec.SBQQ__ShippingState__c; //populating ERP Site Name as Country_State/Province
                erpSitetoUpsert.ERP_Company__c = quoteRec.SoldToAccount__r.ERP_Company__c;
                erpSitetoUpsert.Dev_Quote_Id__c = quoteId;
                erpSitetoUpsert.Exempt_Status__c = 'Not Applicable';
            }
        }                
        
        try{
            Database.UpsertResult upRes = Database.upsert(erpSitetoUpsert,false);    
            if(quoteRec.Sold_to_Account_ERP_Site__c == null){
                SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(Id = quoteRec.Id,Sold_to_Account_ERP_Site__c = upRes.getId());
                SBQQ.TriggerControl.disable();
                update quoteToUpdate;
                SBQQ.TriggerControl.enable();
            }
        }catch(DmlException e){
            System.debug('Error setting exempt status to Not applicable');
        }
    }
    /* Method Name : updateQuote
    * @param - NA
    * @return return - NA
    * @throws exception - NA
    * @description - Update the Tax Run Status to Running when updateTaxICRT VF Page is renedered
    */     
    public void updateQuote(){
        //<TAX-196> - Updating the expemt status to override
        if(isUpdateStatusOverride){
            setExemptStatusToNotApplicable(quoteObj.Id);
        }
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c quoteRec = new SBQQ__QUote__c(Id=quoteObj.Id,Tax_Update_Status__c='Running');
        update quoteRec;
        SBQQ.TriggerControl.enable();        
    }
    
    /* Method Name : getTaxStatus
    * @param - NA
    * @return return - NA
    * @throws exception - NA
    * @description - Method used to poll the Tax Run status
    */    
    public void getTaxStatus(){        
        String taxStatus = [SELECT Id,Tax_Update_Status__c FROM SBQQ__Quote__c WHERE Id=:quoteObj.Id LIMIT 1]?.Tax_Update_Status__c;
        taxUpdateStatus = taxStatus;
        if(taxStatus == 'Success' && calledFrom == 'updateTax'){
            renderButtons = true;
        }else if(taxStatus == 'Failed'){
            renderButtons = true;
        }
    }
    
    /* Method Name : fromGenerateDocumentQuoteVF
    * @param - NA
    * @return PageReference
    * @throws exception - NA
    * @description - invoked when Generate Document button is pressed on Quote, call update Tax if necessay else redirect to conga document generation page
    */
    public pageReference fromGenerateDocumentQuoteVF(){
        PageReference pageRef;
        calledFrom = 'generateDoc';
        if(isUpdateStatusOverride){//<TAX-196>
            setExemptStatusToNotApplicable(quoteObj.Id);
        }
        new AnnualizeIPUQuantitiesCls().createAnnualCommitments(quoteObj.Id);//added for SALESRT-14435
        if(isTaxAppicable){
            pageRef = new pageReference('/apex/UpdateTaxIcrt');
            pageRef.setRedirect(false);
        }else{
            pageRef = null;
        }
        return pageRef;            
    }
    
    /* Method Name : fromGeneratePartnerDocumentQuoteVF
    * @param - NA
    * @return PageReference
    * @throws exception - NA
    * @description - invoked when Generate Partner Document button is pressed on Quote, call update Tax if necessay else redirect to conga document generation page
    */    
    public pageReference fromGeneratePartnerDocumentQuoteVF(){
        PageReference pageRef;
        calledFrom = 'generatePartnerDoc';
        if(isUpdateStatusOverride){//<TAX-196>
            setExemptStatusToNotApplicable(quoteObj.Id);
        }
        new AnnualizeIPUQuantitiesCls().createAnnualCommitments(quoteObj.Id);//added for SALESRT-14435
        if(isTaxAppicable){
            pageRef = new pageReference('/apex/UpdateTaxIcrt');
            pageRef.setRedirect(false);
        }else{
            pageRef = null;
        }
        return pageRef;            
    }  
    
    /* Method Name : onReturnToQuote
    * @param - NA
    * @return PageReference
    * @throws exception - NA
    * @description - invoked when Return to Quote button is clicked on UpdateTax VF Page, redirects to Quote page
    */    
    public pageReference onReturnToQuote(){
        PageReference pg = new PageReference('/'+quoteObj.Id);
        pg.setRedirect(true);
        return pg;            
    }  
    
    /* Method Name : getGenerateDocURL
    * @param - NA
    * @return String
    * @throws exception - NA
    * @description - returns the required URL to redirect to conga document generation page
    
    public static String getGenerateDocURL(String QuoteId, string methodName){     
        String congaURL = '';
        String quoteApprovalStatus = '';
        String partnerServerURL = ApexPages.currentPage().getHeaders().get('Host');
        String sessionID = Userinfo.getSessionId();
        
        List<SBQQ__Quote__c> lstQuoteDetails = new List<SBQQ__Quote__c>();

        if(String.isNotBlank(QuoteId))
        {
            lstQuoteDetails = [ Select Id,ApprovalStatus__c,Bill_to_account_Text__c,
                                Name,DEV_Current_User_Initials__c,DEV_Conga_Locale__c,
                                DEV_Conga_Template_ID__c
                                FROM SBQQ__Quote__c
                                WHERE Id =: QuoteId
                              ];
            if(lstQuoteDetails[0].ApprovalStatus__c == 'Approved')
                quoteApprovalStatus = '';
            else
                quoteApprovalStatus = 'DRAFT';
                                
            if(methodName == 'onGenerateDoc')
            congaURL = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl='+partnerServerURL+'&sessionId='+sessionID+'&Id='+lstQuoteDetails[0].Id+'&QueryId='+Label.Generate_Document_Ids+Label.Generate_Document_Ids_2+'&DV0='+quoteApprovalStatus+'&DS7=3&DefaultPDF=1&OFN='+lstQuoteDetails[0].Bill_to_account_Text__c+'_'+lstQuoteDetails[0].Name+'_'+System.Today()+'_'+lstQuoteDetails[0].DEV_Current_User_Initials__c+'&DV1=FALSE&CurrencyCulture='+lstQuoteDetails[0].DEV_Conga_Locale__c+'&TemplateID='+lstQuoteDetails[0].DEV_Conga_Template_ID__c+'&LRTF=1';
            else
            congaURL = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl='+partnerServerURL+'&sessionId='+sessionID+'&Id='+lstQuoteDetails[0].Id+'&QueryId='+Label.Generate_Document_Ids+Label.Generate_Document_Ids_2+'&DV0='+quoteApprovalStatus+'&DS7=3&DefaultPDF=1&OFN='+lstQuoteDetails[0].Bill_to_account_Text__c+'_'+lstQuoteDetails[0].Name+'_'+System.Today()+'_'+lstQuoteDetails[0].DEV_Current_User_Initials__c+'&DV1=TRUE&CurrencyCulture='+lstQuoteDetails[0].DEV_Conga_Locale__c+'&TemplateID='+lstQuoteDetails[0].DEV_Conga_Template_ID__c+'&LRTF=1';
        }
        return congaURL ;
    }
    /* Method Name : onGenerateDoc
    * @param - NA
    * @return PageReference
    * @throws exception - NA
    * @description - invoked when Generate Document button is clicked on UpdateTax VF Page, redirects to conga document generation page
    
    public PageReference onGenerateDoc(){
        String url = getGenerateDocURL(quoteObj.Id, 'onGenerateDoc');
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /* Method Name : onGeneratePartnerDoc
    * @param - NA
    * @return PageReference
    * @throws exception - NA
    * @description - invoked when Generate Partner Document button is clicked on UpdateTax VF Page, redirects to conga document generation page
    
    public PageReference onGeneratePartnerDoc(){
        String url = getGenerateDocURL(quoteObj.Id, 'onGeneratePartnerDoc');
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }*/    
}