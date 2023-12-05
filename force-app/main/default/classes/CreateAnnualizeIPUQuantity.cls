/***************************************************************************************************************************************************************
 *  @Class Name: CreateAnnualizeIPUQuantity
 *  @Date: 27 JULY 2023
 *  @Description:    
 **********************************************************************************************************************/

public class CreateAnnualizeIPUQuantity {
    @InvocableMethod(label='Process Quote' description='Process a Quote')
    public static void processQuote(List<QuoteInput> quoteInputs) {
        if(quoteInputs.size() > 0){
            AnnualizeIPUQuantitiesCls ipuAnnualize = new AnnualizeIPUQuantitiesCls();
            ipuAnnualize.createAnnualCommitments(quoteInputs[0].quoteId);
        }
    }
    
    public class QuoteInput {
        @InvocableVariable(label='Quote Id' description='The ID of the Quote' required=true)
        public Id quoteId;
    }
}