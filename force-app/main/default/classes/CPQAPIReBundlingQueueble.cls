public with sharing class CPQAPIReBundlingQueueble implements Queueable,Database.AllowsCallouts{
    QuoteModel quoteWithProducts = new QuoteModel();
    Set<Id> qleDeleteIds = new Set<Id>();

    public CPQAPIReBundlingQueueble(QuoteModel quoteWithProducts,Set<Id> qleDeleteIds) {
        this.quoteWithProducts.record = quoteWithProducts.record;
        this.quoteWithProducts.lineItems = quoteWithProducts.lineItems;
        this.quoteWithProducts.lineItemGroups = quoteWithProducts.lineItemGroups;
        this.quoteWithProducts.nextKey = quoteWithProducts.nextKey;
        this.quoteWithProducts.applyAdditionalDiscountLast = quoteWithProducts.applyAdditionalDiscountLast;
        this.quoteWithProducts.applyPartnerDiscountFirst = quoteWithProducts.applyPartnerDiscountFirst;
        this.quoteWithProducts.channelDiscountsOffList = quoteWithProducts.channelDiscountsOffList;
        this.quoteWithProducts.customerTotal = quoteWithProducts.customerTotal;
        this.quoteWithProducts.netTotal = quoteWithProducts.netTotal;
        this.quoteWithProducts.netNonSegmentTotal = quoteWithProducts.netNonSegmentTotal;
        this.qleDeleteIds = qleDeleteIds;
        system.debug('quoteWithProducts'+quoteWithProducts);
    }
    
    public void execute(QueueableContext context) {

        //List<SBQQ__Quoteline__c> qlDeleteList = new List<SBQQ__QuoteLine__c>();

        system.debug('entering the Loop'+quoteWithProducts);
        //SAVE AND CALCULATE the final quote
        try{
            QuoteCalculator calculator = new QuoteCalculator();
            calculator.calculate(quoteWithProducts, 'MyCallback');
            System.debug('entering the qleDeleteIds'+qleDeleteIds);
            system.debug('after calculate'+quoteWithProducts);
            CPQAPIReBundlingWebService.deleteQuoteLines(qleDeleteIds);
        } catch(Exception e){
            sendErrroMail(e.getMessage()); 
        }
        
    }

    public static void sendErrroMail(String errorMessage){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserInfo.getUserEmail()};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}