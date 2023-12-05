public class QuoteModel {
    public SBQQ__Quote__c record;
    public QuoteLineModel[] lineItems;
    public QuoteLineGroupModel[] lineItemGroups;
    public Integer nextKey;
    public Boolean applyAdditionalDiscountLast;
    public Boolean applyPartnerDiscountFirst;
    public Boolean channelDiscountsOffList;
    public Decimal customerTotal;
    public Decimal netTotal;
    public Decimal netNonSegmentTotal;

    public QuoteModel(){
        this.record = new SBQQ__Quote__c();
        this.lineItems = new QuoteLineModel[]{};
        this.lineItemGroups = new QuoteLineGroupModel[]{};
        this.applyAdditionalDiscountLast = false;
        this.applyPartnerDiscountFirst = false;
        this.channelDiscountsOffList = false;
        this.customerTotal = 0.0;
        this.netTotal = 0.0;
        this.netNonSegmentTotal = 0.0;
        this.nextKey = 0;
    }
}