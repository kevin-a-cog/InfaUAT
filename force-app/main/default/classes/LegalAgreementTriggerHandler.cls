/*
        Trigger: LegalAgreementBeforeUpdate
        @Author: Conga Services
        @Created Date: 8/20/2018
        @Description: Handles the Approval Required logic for threshhold validation of Third Party Paper contract negotiation. 
*/

//Conga Contracts Phase 2 Project: Conga Services - 9/29/2020 - Comment out the logic in the code. Left method stubs in order for test code to still cover the class at 100 percent to move into production.
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Requested By        Description
************************************************************************************************************************************************************
Nishit S            9-22-2021       CLM-310         Auto populate fields on Legal Agreement Page When Quote Number is Linked
Nishit S            4-27-2023       SALESRT-15523   Rename and Increase Character Limit & Remove the payments terms automation                    <SALESRT-15523>
Chandana Gowda      7-26-2023       SALESRT-16821   Ability to Create an Exhibit-A LAR from Quote                                                 <SALESRT-16821>
*/
public class LegalAgreementTriggerHandler extends ManagedClauseCreationTriggerHandler{

    private static globalApexManager GAM = new globalApexManager();

    public LegalAgreementTriggerHandler(String sObjectName) {
        super(sObjectName);
    }

    // //Gather related Quotes via the Account relationship
    // private static Map<Id,SBQQ__Quote__c> relatedQuotes = new Map<Id,SBQQ__Quote__c>();
    // private static Map<Id,Set<String>> relatedQuoteLines = new Map<Id,Set<String>>();
    // private static List<Id> accountIds = new List<Id>();
    // private static Set<String> qlrefs = new Set<String>();
    // //Add the Account Id to the List
    Public static void LegalAgreementBeforeUpdate (List<Legal_Agreement__c> ListNew)
    { 
        quoteDataSync(ListNew,true);
    }
    
    Public static void LegalAgreementBeforeInsert (List<Legal_Agreement__c> ListNew)
    { 
        quoteDataSync(ListNew,false);
    }

    public static void LegalAgreementAfterInsert (List<Legal_Agreement__c> listNew)
    { 
        updateLarNumberonQuote(listNew);
    }


    
    /*SALESRT-16821
    Method Name : updateLarNumberonQuote,  
    * @param listNew - list of new Legal_Agreement__c  
    * @return return-void  
    This method call from 'LegalAgreementAfterInsert' Trigger on Legal_Agreement__c Object  
    Used to update LAR# on Quote
    */    
    
    private static void updateLarNumberonQuote(List<Legal_Agreement__c> listNew){
        
        Map<Id,String> mapQuotetoLAR = new Map<Id,String>();
        Set<String> setQuoteNumber = new Set<String>();

        for(Legal_Agreement__c lar: listNew){
            if(!String.isBlank(lar.Quote_Number__c)){
                setQuoteNumber.add(lar.Quote_Number__c);
            }
        }

        Map<String, SBQQ__Quote__c> quoteDataMap = new Map<String, SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : [SELECT Id,Name FROM SBQQ__Quote__c WHERE  Name IN :setQuoteNumber])
        {
            quoteDataMap.put(quote.Name, quote);  
        }


        for(Legal_Agreement__c legalAgreement : listNew){
            if(quoteDataMap.containsKey(legalAgreement.Quote_Number__c)){
                mapQuotetoLAR.put(quoteDataMap.get(legalAgreement.Quote_Number__c).Id,legalAgreement.Name);
            }
        }        

        if(!mapQuotetoLAR.isEmpty()){
            updateLARonQuote(mapQuotetoLAR);
        }
    }
        //for(Legal_Agreement__c agreement :  newMap.values())
            //{
            ///   if(agreement.Account__c != null)    
            //   {
            //       accountIds.add(agreement.Account__c);
            //    }
            //}

    //     //Query Quote fields to be written to Legal Agreement
    //     for(SBQQ__Quote__c quote : [Select Id,SBQQ__NetAmount__c,SBQQ__Opportunity2__r.AccountId,SBQQ__ShippingCountry__c, SBQQ__PaymentTerms__c, SBQQ__BillingFrequency__c from SBQQ__Quote__c where SBQQ__Opportunity2__r.AccountId in :accountIds Order By CreatedDate DESC])
    //     {
    //         if(!relatedQuotes.containsKey(quote.SBQQ__Opportunity2__r.AccountId))
    //         {
    //             relatedQuotes.put(quote.SBQQ__Opportunity2__r.AccountId,quote);
    //         }
    //     }

    //     //Check if there are Quote Lines and add them to the Map with their Product Family
    //     for(SBQQ__QuoteLine__c  quoteLine : [Select Id,SBQQ__Product__r.Family,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :relatedQuotes.values()])
    //     {
    //         if(!relatedQuoteLines.containsKey(quoteLine.SBQQ__Quote__c))
    //         {
    //             relatedQuoteLines.put(quoteLine.SBQQ__Quote__c, new Set<String>());
    //         }
    //         relatedQuoteLines.get(quoteLine.SBQQ__Quote__c).add(quoteLine.SBQQ__Product__r.Family);
    //     }
        
    //     //Write the Quote fields to the Legal Agreement and preform validation logic for deal threshold based on Products in Product Family
    //     for(Legal_Agreement__c agreement :  ListNew){
    //         if(relatedQuotes.size() != 0 && relatedQuotes.containsKey(agreement.Account__c)) //Need to have a seperate IF to check when there is no Quote and Quote Lines and check this Map accordingly so that a Legal Agreement with a Quote and a Legal Agrrement without a Quote will both be added
    //         //Create three Records, Legal Agreement with a Quote and Quote Lines, Legal Agreement with a Quote but no Quote Lines, third a Legal Agreement with no Quote
    //         {
    //             system.debug('This is the I have a quote record Id ' + agreement.Id);
    //             agreement.Net_Amount__c = relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c;
    //             agreement.Payment_Terms__c = relatedQuotes.get(agreement.Account__c).SBQQ__PaymentTerms__c;
    //             agreement.Billing_Frequency__c = relatedQuotes.get(agreement.Account__c).SBQQ__BillingFrequency__c;
    //         }
    //         else if(agreement.SVP_Approved__c <> 'Yes' && !relatedQuotes.containsKey(agreement.Account__c) && agreement.Use_Third_Party_Paper__c == 'Yes')
    //         {
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'Yes';
    //             agreement.Contains_DaaS_or_Cloud_Products__c = FALSE;
    //             agreement.Deal_Threshold_Met__c = FALSE;
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 1';
    //             continue; 
    //         }
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.SVP_Approved__c == 'Yes' && agreement.Legal_Counsel_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes')
    //         {
    //             agreement.Deal_Threshold_Met__c = TRUE;
    //             agreement.Approval_Needed__c = 'No';
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 2';
    //             continue;
    //         }
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.SVP_Approved__c == 'Yes' && agreement.Deal_Strategy_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes')
    //         {
    //             agreement.Deal_Threshold_Met__c = TRUE;
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'No';
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 3';
    //             continue;
    //         } 
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.Use_Third_Party_Paper__c == 'Yes')
    //         {
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'Yes';
    //             agreement.Deal_Threshold_Met__c = FALSE;
    //             agreement.Small_Deal__c = TRUE;
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 4';
    //             continue;
    //         }
    //         else if(agreement.SVP_Approved__c <> 'Yes' && !relatedQuotes.containsKey(agreement.Account__c) && agreement.Use_Third_Party_Paper__c == 'No')
    //         {
    //             system.debug('This is the record Id ' + agreement.Id);
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'Yes';
    //             agreement.Contains_DaaS_or_Cloud_Products__c = FALSE;
    //             agreement.Deal_Threshold_Met__c = FALSE;
    //             agreement.Small_Deal__c = TRUE;
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 1a';
    //             continue; 
    //         }
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.SVP_Approved__c == 'Yes' && agreement.Legal_Counsel_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No')
    //         {
    //             agreement.Deal_Threshold_Met__c = TRUE;
    //             agreement.Approval_Needed__c = 'No';
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 2a';
    //             continue;
    //         }
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.SVP_Approved__c == 'Yes' && agreement.Deal_Strategy_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No')
    //         {
    //             agreement.Deal_Threshold_Met__c = TRUE;
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'No';
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 3a';
    //             continue;
    //         } 
    //         else if(!relatedQuotes.containsKey(agreement.Account__c) && agreement.Use_Third_Party_Paper__c == 'No')
    //         {
    //             agreement.Legal_Review_Needed__c = 'Yes';
    //             agreement.Approval_Needed__c = 'Yes';
    //             agreement.Deal_Threshold_Met__c = FALSE;
    //             agreement.Small_Deal__c = TRUE;
    //             //agreement.Contract_Purpose__c = 'Im entering No Quote Criteria 4a';
    //             continue;
    //         }

    //         Set<String> qlrefs = relatedQuotes.containsKey(agreement.Account__c) ? relatedQuoteLines.get(relatedQuotes.get(agreement.Account__c).Id) : null;
    //         System.debug('qlrefs'+ qlrefs);

    //         //Check to see TPP is used and run approvals accordingly
    //         if(qlrefs != null){
    //             if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Threshold_Amount) && 
    //                 !qlrefs.contains('Cloud Subscription') && !qlrefs.contains('DaaS Subscription'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Contains_DaaS_or_Cloud_Products__c = FALSE;
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 1';
    //             }
    //             //Checks to see if this is ONLY Cloud Subscription or DaaS
    //             else if(agreement.Use_Third_Party_Paper__c == 'Yes' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Threshold_Amount) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('DaaS Subscription')) && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual')))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Never';
    //                 agreement.Approval_Needed__c = 'Never';
    //                 agreement.Contains_DaaS_or_Cloud_Products__c = TRUE;
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 2' + qlrefs;
    //             }
    //             //Checks if there are also On-Prem Products
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Threshold_Amount) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('DaaS Subscription') && (qlrefs.contains('On-Premise Subscription') || qlrefs.contains('On-Premise Perpetual'))))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Contains_DaaS_or_Cloud_Products__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 3' + qlrefs;
    //             }
    //             //If deal is greater then 1MIL and Contains On-Prem no approval is needed
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Threshold_Amount) && 
    //                 (qlrefs.contains('On-Premise Subscription') || qlrefs.contains('On-Premise Perpetual')))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Contains_DaaS_or_Cloud_Products__c = FALSE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 4';
    //             }
    //             //Checks if deal is only Cloud or DaaS
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Threshold_Amount) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('DaaS Subscription')) && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual')))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Never';
    //                 agreement.Approval_Needed__c = 'Never';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 agreement.Contains_DaaS_or_Cloud_Products__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 5';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Legal_Counsel_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes')
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 6';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Deal_Strategy_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'Yes')
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 7';
    //             }
    //             //Begin processing Legal Agreements not using Third Party Paper for North America
    //             //Checks if the deal has On-Prem Perpetual
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_On_Prem) && 
    //                 qlrefs.contains('On-Premise Perpetual') && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 8';
    //                 agreement.Small_Deal__c = TRUE;
    //             }
    //             //Checks if deal is large enough to warrant negotiation for NA On-Prem Perpetual
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_On_Prem) && 
    //                 qlrefs.contains('On-Premise Perpetual') && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 9';
    //             }
    //             //Checks if deal is large enough to warrent negotiation for NA On-Prem Subscription or Cloud and does not contain On=Prem Perpetual
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_On_Prem_Sub_or_Cloud) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('On-Premise Subscription')) && !qlrefs.contains('On-Premise Perpetual') && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 agreement.Small_Deal__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 10';
    //             }
    //             //Checks if deal is large enough to be allowed to Legal without Approvals for NA On-Prem Subscription or Cloud and does not contain On=Prem Perpetual
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_On_Prem_Sub_or_Cloud) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('On-Premise Subscription')) && !qlrefs.contains('On-Premise Perpetual') && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 11';
    //             }
    //             //Check if deal is large enough for DaaS negotiation and contains no other products
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_DaaS) && 
    //                 qlrefs.contains('DaaS Subscription') && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual') || !qlrefs.contains('Cloud Subscription')) && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 agreement.Small_Deal__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 12';
    //             }
    //             //Checks to see if DaaS is big enough to not require approval and contains no other products
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_NA_DaaS) && 
    //                 qlrefs.contains('DaaS Subscription') && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual') || !qlrefs.contains('Cloud Subscription')) && agreement.Contract_Group__c == 'Sales - NA')
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 13';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Legal_Counsel_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && agreement.Small_Deal__c == TRUE)
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 14';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Deal_Strategy_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && agreement.Small_Deal__c == TRUE)
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 15';
    //             }
    //             //Begin processing Legal Agreements not using Third Party Paper for EMEA and APJ
    //             //Checks if the deal has On-Prem Perpetual
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_On_Prem_perpetual) && 
    //                 qlrefs.contains('On-Premise Perpetual') && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 16';
    //                 agreement.Small_Deal__c = TRUE;
    //             }
    //             //Checks if deal is large enough to warrant negotiation for EMEA/APJ On-Prem Perpetual
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_On_Prem_perpetual) && 
    //                 qlrefs.contains('On-Premise Perpetual') && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 17';
    //             }
    //             //Checks if deal is large enough to warrent negotiation for EMEA/APJ On-Prem Subscription or Cloud and does not contain On=Prem Perpetual
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_All_Others) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('On-Premise Subscription')) && !qlrefs.contains('On-Premise Perpetual') && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 agreement.Small_Deal__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 18';
    //             }
    //             //Checks if deal is large enough to be allowed to Legal without Approvals for EMEA/APJ On-Prem Subscription or Cloud and does not contain On=Prem Perpetual
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_All_Others) && 
    //                 (qlrefs.contains('Cloud Subscription') || qlrefs.contains('On-Premise Subscription')) && !qlrefs.contains('On-Premise Perpetual') && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 19';
    //             }
    //             //Check if deal is large enough for DaaS negotiation and contains no other products for EMEA/APJ
    //             else if(agreement.SVP_Approved__c != 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c < Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_All_Others) && 
    //                 qlrefs.contains('DaaS Subscription') && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual') || !qlrefs.contains('Cloud Subscription')) && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'Yes';
    //                 agreement.Deal_Threshold_Met__c = FALSE;
    //                 agreement.Small_Deal__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 20';
    //             }
    //             //Checks to see if DaaS is big enough to not require approval and contains no other products for EMEA/APJ
    //             else if(agreement.Use_Third_Party_Paper__c == 'No' && relatedQuotes.get(agreement.Account__c).SBQQ__NetAmount__c > Decimal.valueOf(Label.Legal_Agreement_Small_Deal_Threshold_EMA_and_APJ_All_Others) && 
    //                 qlrefs.contains('DaaS Subscription') && (!qlrefs.contains('On-Premise Subscription') || !qlrefs.contains('On-Premise Perpetual') || !qlrefs.contains('Cloud Subscription')) && (agreement.Contract_Group__c == 'Sales - EMEA/LA' || agreement.Contract_Group__c == 'Sales - APJ'))
    //             {
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 21';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Legal_Counsel_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && agreement.Small_Deal__c == TRUE)
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Approval_Needed__c = 'No';
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 22';
    //             }
    //             else if(agreement.SVP_Approved__c == 'Yes' && agreement.Deal_Strategy_Approved__c == 'Yes' && agreement.Use_Third_Party_Paper__c == 'No' && agreement.Small_Deal__c == TRUE)
    //             {
    //                 agreement.Deal_Threshold_Met__c = TRUE;
    //                 agreement.Legal_Review_Needed__c = 'Yes';
    //                 agreement.Approval_Needed__c = 'No';
    //                 //agreement.Contract_Purpose__c = 'Im entering Criteria 23';
    //             }
    //         }
    //         //else if(!qlrefs.contains('DaaS Subscription') && !qlrefs.contains('On-Premise Subscription') && !qlrefs.contains('On-Premise Perpetual') && !qlrefs.contains('Cloud Subscription')
    //         //    && agreement.Requires_Negotiation__c == FALSE){
    //         //    //agreement.Contract_Purpose__c = 'This Quote has no product family' + qlrefs;
    //         //    agreement.Legal_Review_Needed__c = 'No';
    //         //}
    //     }
    //}
    
    private static void quoteDataSync(List<Legal_Agreement__c> ListNew,Boolean onUpdate){
        List<String> quoteNumbers = new List<String>();
        Map<Id,String> mapQuotetoLAR = new Map<Id,String>();
        for(Legal_Agreement__c legalAgreement :  ListNew)
        {
            if(!String.isBlank(legalAgreement.Quote_Number__c))
                quoteNumbers.add(legalAgreement.Quote_Number__c);
        }
        Map<String, SBQQ__Quote__c> quoteDataMap = new Map<String, SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : [SELECT id, Name,SBQQ__Opportunity2__c, SBQQ__NetAmount__c, SBQQ__PaymentTerms__c, SBQQ__BillingFrequency__c, Override_Billing_Frequency__c, CurrencyIsoCode
                                    FROM SBQQ__Quote__c WHERE  Name IN :quoteNumbers])
        {
            quoteDataMap.put(quote.Name, quote);  
        }
        for(Legal_Agreement__c legalAgreement : ListNew){
            if(quoteDataMap.containsKey(legalAgreement.Quote_Number__c)){
                legalAgreement.Opportunity__c = quoteDataMap.get(legalAgreement.Quote_Number__c).SBQQ__Opportunity2__c;
                legalAgreement.Net_Amount__c = quoteDataMap.get(legalAgreement.Quote_Number__c).SBQQ__NetAmount__c;
                //legalAgreement.Payment_Terms__c = quoteDataMap.get(legalAgreement.Quote_Number__c).SBQQ__PaymentTerms__c; SALESRT-15523- disabling population of the payments terms field 
                legalAgreement.Billing_Frequency__c = quoteDataMap.get(legalAgreement.Quote_Number__c).SBQQ__BillingFrequency__c;
                legalAgreement.Override_Billing_Frequency__c = quoteDataMap.get(legalAgreement.Quote_Number__c).Override_Billing_Frequency__c;
                legalAgreement.CurrencyIsoCode = quoteDataMap.get(legalAgreement.Quote_Number__c).CurrencyIsoCode;

                mapQuotetoLAR.put(quoteDataMap.get(legalAgreement.Quote_Number__c).Id,legalAgreement.Name);
            }
        }

        if(onUpdate && !mapQuotetoLAR.isEmpty()){
            updateLARonQuote(mapQuotetoLAR);
        }
    }

    /*SALESRT-16821
    Method Name : updateLARonQuote,  
    * @param mapQuotetoLAR - Map<Id,String>, map of quote id and LAR name  
    * @return return-void  
    * logic to update the LAR# on quote  
    */ 
    
    private static void updateLARonQuote(Map<Id,String> mapQuotetoLAR){
        List<SBQQ__Quote__c> lstQuoteUpdate = new List<SBQQ__Quote__c>();
        
        for(Id quoteId:mapQuotetoLAR.keyset()){
            SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(Id = quoteId);
            quoteRec.Exhibit_A_Legal_Agreement_Reference__c = mapQuotetoLAR.get(quoteId);
            lstQuoteUpdate.add(quoteRec);
        }

        SBQQ.TriggerControl.disable();
        try{
            Database.SaveResult[] lstSaveResult = Database.update(lstQuoteUpdate, false);
            for(Integer i = 0; i<lstSaveResult.size() ;i++){
                Database.SaveResult saveRes = lstSaveResult[i];
                if(!saveRes.isSuccess()){
                    GAM.CreateExceptionRecords('LegalAgreementTriggerHandler - Error updating Quote Record: '+lstQuoteUpdate[i].Id, saveRes.getErrors()[0].getMessage(), lstQuoteUpdate[i].Exhibit_A_Legal_Agreement_Reference__c);
                }
            }
        }
        catch(Exception e){
            GAM.CreateExceptionRecords('LegalAgreementTriggerHandler',e.getMessage(),'Exception in updateLARonQuote: ');
        }
        SBQQ.TriggerControl.enable();
    }
}