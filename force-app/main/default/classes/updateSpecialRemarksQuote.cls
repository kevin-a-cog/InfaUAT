/*
Class:          updateSpecialRemarksQuote
@Author:        Nishit S
@Created Date:  07/28/2023
@Description:   handler class for SBQQ__Quote__c triggers
*/
/*
Change History
*********************************************************************************************************************************************************
ModifiedBy          Date        Ticket No.          Description                                                                              Tag
Chandana Gowda    21-Sept-23    SALESRT-17301       Moving from SDocs to Conga for Self Quote QOD,added logic to bypass Tax call             <T1>
**********************************************************************************************************************************************************
*/
    
public class updateSpecialRemarksQuote {
    public static globalApexManager GAM = new globalApexManager();
    private static List<Schema.SObjectType> MY_SOBJECTS = new Schema.SObjectType[] {SBQQ__Quote__c.SObjectType};
    /*
    Method Name : updateSpecialRemarksQuote
    * @param lstTriggerNew - list of QuoteInput
    * @return return-void
    * @throws exception - NA
    This method call from 'Self Service Quote Summary - After ' flow 
    */
    @InvocableMethod(label='Update Special Remarks on Quote' description='Update Special Remarks on Quote') 
    public static void processQuote(List<QuoteInput> quoteInputs) {
        
    	UnitOfWork uow = new UnitOfWork(MY_SOBJECTS);
        
        if(quoteInputs.size() > 0){
            SBQQ__Quote__c quote = [select Id, Quote_Language__c, Special_Remarks1__c, SBQQ__SubscriptionTerm__c, New_ABV__c, CurrencyIsoCode  from SBQQ__Quote__c where Id = :quoteInputs[0].quoteId];

            String specialRemarks;

            if(quote.SBQQ__SubscriptionTerm__c == 24){
                specialRemarks = Label.translationExists(null, 'Self_Service_Special_Remarks_24', quote.Quote_Language__c) ? 
                    System.Label.get(null,'Self_Service_Special_Remarks_24',quote.Quote_Language__c).replace('{newABV}', quote.CurrencyIsoCode + ' ' + formatCurrency(quote.New_ABV__c)) 
                    :  + System.Label.get(null,'Self_Service_Special_Remarks_24','en_US');
            }
            
            else if(quote.SBQQ__SubscriptionTerm__c == 36){
                specialRemarks = Label.translationExists(null, 'Self_Service_Special_Remarks_36', quote.Quote_Language__c) ? 
                    System.Label.get(null,'Self_Service_Special_Remarks_36',quote.Quote_Language__c).replace('{newABV}', quote.CurrencyIsoCode + ' ' + formatCurrency(quote.New_ABV__c)) 
                    : System.Label.get(null,'Self_Service_Special_Remarks_36','en_US');
            }
            
            SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(Id = quote.Id,Tax_Update_Status__c = 'Success'/*<T1> : Added logic to bypass Tax*/,Special_Remarks1__c = specialRemarks);
            uow.registerDirty(quoteToUpdate);

           if(quote.SBQQ__SubscriptionTerm__c == 36 || quote.SBQQ__SubscriptionTerm__c == 24){
                SBQQ.TriggerControl.disable();
                globalApexManager.avoidRecursion('QuoteAfterUpdate');
                globalApexManager.avoidRecursion('QuoteBeforeUpdate');                
                try{
                    uow.commitWork();//</T02>
                }
                catch(Exception e){
                    GAM.CreateExceptionRecords('Error caused from updateSpecialRemarksQuote class in processQuote method', e.getMessage(),quote.Id);
                }
            }
        }
    }
    
    public class QuoteInput {
        @InvocableVariable(label='Quote Id' description='The ID of the Quote' required=true)
        public Id quoteId;
    }
    
    private static String formatCurrency(Decimal amount){
        String result = '';
        if (Amount >= 1000000) 
            result += String.valueOf(Math.floor(Amount / 1000000)) + ',';
        if (Amount >= 1000) 
            result += String.valueOf(Math.floor(Amount / 1000)).right(3) + ',';
        result += String.valueOf(Math.floor(Amount)).right(3) + '.';
        Decimal fractionalPart = Math.round((Amount - Integer.valueOf(amount)) * 100);
        if (fractionalPart * 100 < 10) 
            result += '0' + String.valueOf(fractionalPart);
        else 
            result += String.valueOf(Math.min(fractionalPart, 99));
        return result;
    }    
}