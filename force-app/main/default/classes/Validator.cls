public with sharing class Validator{

   public List<String> validate(QuoteModel quote) {
      String res=SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteValidator', null, JSON.serialize(quote));
      return (List<String>) JSON.deserialize(res, List<String>.class);
   }
}