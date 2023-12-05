/***************************************************************************
*        Name        :        OrderTriggerHandler
*        Author      :        Kendra Claiborne
*        Date        :        28 August 2017
*        Description :        Handler class for Order 
****************************************************************************
Change History
**********************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                           Tag
**********************************************************************************************************************************************                      
Kendra              10/11/2017  Prasanth            Added handleAfterInsert model to populate
the Order's related Quote with the Primary Order
as the newly inserted Order created from a Quote
based on the Quote's Ordered field being checked
Kendra              10/17/2017  Elena Merill        Added logic for aligning the “bill day of the month” on the Order Item.
Kendra              11/06/2017  Anil Solanki        Modified logic for determining to change the End User Record Type
Vivek               2-Mar-2018  Shobhit Sharma      Added logic to keep the Order Start Date and Billing Day of Month in sync           <T1>
Venkata Sabbella     09/19      F2A                 Create on Premise Assets. 
Ambica              11/27/2019  F2A-201             Update non-provisionable order products to povisioning complete                     <T02>
Ambica              4/13/2020   SALESRT-11834       Adde check for admin order to create assets                                         <T03>
RamEsh M S          1-Jun-2020  SALESRT-11973       Setting Invoice Batch for Custom Payment Term                                       <T04>
RamEsh M S          2-Jun-2020  SALESRT-12105       Remove Renewal Term on Order as it twins on Contract creation                       <T05>
Ramya Ravi          09/06/2020      F2A             F2A-237 Ability to track provisioning/shipping completed date                       <T06>
RamEsh M S          17-Jun-2020  SALESRT-12125      Setting Invoice Batch for Debook Order                                              <T07> 
Anil Solanki        6-Jun-2020   I2C-659            Create Junction Record for Revenue Agreement on Order Activation.                   <T08> 
RamEsh M S          8-AUG-2020    I2C-789           To handle Cancel/Debook on Revenue Agreement                                        <T09>
Anil Solanki        4-AUG-2020    I2C-726           Order Stages Change                                                                 <T10>
RamEsh M S          7-AUG-2020                      Add Dated Conversion Rate on Exchange_Rate__c based on Generate_Date__c             <T11>
RamEsh M S          11-AUG-2020    I2C-728          Added check for Revision Opportunity and Enable Downstream to create Revenue Agreement <T12>
Vignesh D           05-Oct-2020    F2A              Update Asset_Creation_Status__c to Intiated to create Asset & Entitlements          <T13>
RamEsh M S          28-OCT-2020    I2C-1082         Bypassing CMS Approval for Revision Orders                                          <T14>
RamEsh M S          02-NOV-2020    SALESRT-12519    Move Record Type change logic from Trigger to Contract PB                           <T15>
Chandana Gowda      26-Nov-2020    I2C-1083         Added the logic to create Invoice Group and Invoice Group Dates rec                 <T16>
RamEsh M S          17-DEC-2020    I2C-1109         Recalculate Booking when Exchange Rate is changed                                   <T17>
Pavithra V          16-DEC-2020    F2A-329          To update the Ship date on the order product to be in line with                     <T18>
                                                    order generation date for all the non-provisionable products
RamEsh M S          28-JAN-2021    SALESRT-12761    Order Products activation when Direct Order is activated.                           <T19>
Ramya Ravi          20-FEB-2021    I2C-1172         Ability to Enter/Update PO# on Multi-Year Quote/Order-Extra functionality of one PO for the whole quote  <T20>
Ramya Ravi          01-MAR-2021    SALESRT-12555    Need the ability to store the PO Amount on the Quote for reporting purposes         <T21>
Kiran G             1 Mar 2021     TAX-19          Put Invoice Generation on Hold if TAX Exempt Status is Exempt                       <T22>
                                                    and Exemption on File is false.              
RamEsh M S          18-MAR-2021    SALESRT-12659    Set Do_Not_Send_Invoices_to_Customer__c to TRUE if order is debooked.               <T23>
RamEsh M S          27-APR-2021    I2C-1125         Populate Finance Period based on Generate Date                                      <T24>
RamEsh M S          04-MAY-2021    I2C-1271         Querying only the Order Products which gets Ship Date as Generate Date              <T25>
Nishit S            22 JUN 2021     I2C-1306        Product Fund Amendment Order Automation                                             <T27>
Nishit S            22 JUN 2021     I2C-1317        Update the Logic for Product Fund Revenue Agreement update                          <T28>
Puneet Lohia        22-Jun-2021     SALESRT-12123   Substage mapping for renewal opptys                                                 <T12123>
Nishit S            20-AUG-2021     I2C-1345        Finance Period object moving future order's generate date to current active Period  <I2C-1345>
Nishit S            22-AUG-2021     I2C-1336        Allow a way for suppressing specific invoice from bursting to Customer              <I2C-1336>
Nishit S            17 AUG 2021     I2C-1311        The Order Source should be populated to 'PS' for Professional Services              <I2C-1311>
                                                    Prepaid Orders
Wasim               20 SEP 2021     SALESRT-13309   Moving the logic to update Substage to Booked from OrderTriggerHanlder to           <SALESRT-13309>
                                                    revenueAgreementBatch
RamEsh M S          30-SEP-2021     I2C-1412        Check for Quote's Net Amount > 0                                           <I2C-1412>
Nishit S            22-DEC-2021     F2A-437         Ability to update the Account on Org Object as part of fulfillment                  <F2A-437>
Wasim               3-JAN-2022      CPQ Upgrade '22 Commenting out the code for Activating the Order Item for Direct Orders - this is taken care by Salesforce Billing in Spring '21(Refer Release Notes) <T29>
Wasim               3-JAN-2022      CPQ Upgrade '22 Adding logic to generate ROC for Revision Order and then deleting it in revenueAgreementBatch to create Contract by deployment master when Downstream = Fulfillment <T30>
Wasim               25-FEB-2022     I2C-1506        CPQ Invoice Acceleration automation & Default Bill Feq='Invoice Plan' for Order with products having different dates <T31>
Nishit S            27-FEB-2022     I2C-1513        INC0612394 : 0$ Orders Source is getting defaulted to 'ES'                  <I2C-1513>
RamEsh M S          29-AUG-2022     I2C-1701        Added tolerance of 0.5 on Total Amount to handle 0$ Amendments <I2C-1701>
Narpavi Prabu       28-SEP-2022     F2A-471         Replace the provisionable formula field ('Provisionable__c) with new checkbox field in Product ('Provisionable_New__c') 
Jiju N              07-MAR-2023     I2C-1869        Update Shipping Email on Order Ship To Block on shipping contact change
Nishit S            18-APR-2023     I2C-1729        Multi Contract Swaps - Update the Related Revenue Order Field for Amendment Orders                      <I2C-1729> 
Nishit S            25-MAY-2023     I2C-1936        ERP ID default on Amendments/Renewals                                                                   <I2C-1936>
Nishit S			20-JUL-2023		I2C-1983		Default "Do Not Send Invoices to Customer"=S on Order for Market Place Orders							<I2C-1983>
Sreerekha			20-JUL-2023     I2C-1916 		Introduce additional Ship to Contact & Email on the Order												<I2C-1916>
Nishit S 			09-18-2023	I2C-1791			To create Invoice scheduler button on the order 														<I2C-1791>
***************************************************************************************************************************************************************************************************************/
  
public class OrderTriggerHandler {
    public static globalApexManager GAM = new globalApexManager();
    public static List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SObjectType = 'Order' AND DeveloperName =: Label.Activated_Order_Developer_Name];
    private final static string OPP_RENEWAL_RT = Label.Renewal_Opportunity; //<T12123>
    /*
* When an Order is created from a Quote (Quote Ordered field is checked)
* the Quote's Primary Order is updated with a referenced to the newly
* created Order if that relationship does not already exist
* 
* If the Order being created Type = Amendment, align the billing day of the month
* with the Original Order's Start Date
* 
* @param lstTriggerNew - List of new Orders
* @return return - void
* @throws exception - NA
*/
    public static void handleAfterInsert(List<Order> lstTriggerNew){
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        Set<String> originalOrderNumberSet = new Set<String>();
        Set<Id> amendedOrderIds = new Set<Id>();
        Map<Id, Order> ordersToUpdateMap = new Map<Id, Order>();
        Set<Id> orderIds = new Set<Id> ();
        Map<Id,String> ordCurrMap = new Map<Id,String> ();
        Map<Id,Order> ordGDMap = new Map<Id,Order> ();
        
        for(Order o : [SELECT Id, Name, Type, SBQQ__Quote__c, Original_Order__c,SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Primary_Order__c, 
                       SBQQ__Quote__r.BillToAccount__c, SBQQ__Quote__r.ShiptToAccount__c, SBQQ__Quote__r.SoldToAccount__c, SBQQ__Quote__r.EndUserAccount__c,
                       SBQQ__Quote__r.BilltoContact__c, SBQQ__Quote__r.ShipToContact__c, SBQQ__Quote__r.SoldToContact__c, SBQQ__Quote__r.EndUserContact__c,
                       SBQQ__Quote__r.Legal_Entity__c, SBQQ__Quote__r.SBQQ__BillingName__c, SBQQ__Quote__r.SBQQ__ShippingName__c, SBQQ__Quote__r.Shipping_Email__c, 
                       SBQQ__Quote__r.Shipping_Preference__c, SBQQ__Quote__r.PO__c, SBQQ__Quote__r.SBQQ__PaymentTerms__c,SBQQ__RenewalTerm__c,SBQQ__PaymentTerm__c,blng__InvoiceBatch__c,
                       Sub_Type__c,TotalAmount,Generate_Date__c,CurrencyIsoCode,Exchange_Rate__c,Do_Not_Send_Invoices_to_Customer__c, Exempt_Status__c,Exemption_On_File__c, SBQQ__Quote__r.SBQQ__NetAmount__c,
                       SBQQ__Quote__r.Quote_Summary__c, SBQQ__Quote__r.Quote_Summary__r.Net_Amount__c, SBQQ__Quote__r.Quote_Summary__r.Professional_Services_Revenue__c, SBQQ__Quote__r.Quote_Summary__r.Education_Services_Revenue__c, //<I2C-1311>
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillingAddress_PSFTID__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShippingAddress_PSFTID__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldAddress_PSFTID__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAddress_PSFTID__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillingName_PSFTID__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShippingName_PSFTID__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillTo_ERP_Account_ID__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShipTo_ERP_Account_ID__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldTo_ERP_Account_ID__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUser_ERP_Account_ID__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BilltoAccount__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShipToAccount__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldToAccount__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAccount__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.Billing_Address__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.Shipping_Address__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldAddress__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAddress__c, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillToContactId, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShipToContactId, 
                       SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldToContact__c, SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserContact__c,
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillingAddress_PSFTID__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShippingAddress_PSFTID__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldAddress_PSFTID__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAddress_PSFTID__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillingName_PSFTID__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShippingName_PSFTID__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillTo_ERP_Account_ID__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShipTo_ERP_Account_ID__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldTo_ERP_Account_ID__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUser_ERP_Account_ID__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BilltoAccount__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShipToAccount__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldToAccount__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAccount__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.Billing_Address__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.Shipping_Address__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldAddress__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAddress__c, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillToContactId, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShipToContactId, 
                       SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldToContact__c, SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserContact__c,
                       BilltoAccount__c, Billing_Address__c, BillTo_ERP_Account_ID__c,BillingAddress_PSFTID__c, BillToContactId, ShipToContactId, ShipToAccount__c, Shipping_Address__c, 
                       ShippingAddress_PSFTID__c, ShippingName_PSFTID__c, SoldToAccount__c, SoldAddress__c, SoldAddress_PSFTID__c, EndUserAccount__c, EndUserAddress__c,
                       EndUserAddress_PSFTID__c,Additional_Ship_to_Contact__c, Additional_Shipping_Email__c, SBQQ__Quote__r.Additional_Ship_to_Contact__c, SBQQ__Quote__r.Additional_Shipping_Email__c, Route_To_Market__c //<I2C-1916>
                       FROM Order WHERE Id IN :lstTriggerNew]) {
                           
                           //<I2C-1916> Introduce additional Ship to Contact & Email on the Order
                           if(o.SBQQ__Quote__r.Additional_Ship_to_Contact__c != null){
                               o.Additional_Ship_to_Contact__c = o.SBQQ__Quote__r.Additional_Ship_to_Contact__c;
                           }
                           
                           if(o.SBQQ__Quote__r.Additional_Shipping_Email__c != null){
                               o.Additional_Shipping_Email__c = o.SBQQ__Quote__r.Additional_Shipping_Email__c;
                           }
                           //<I2C-1916> ends
                           
                           if(o.SBQQ__Quote__r.BillToAccount__c != null){
                               o.BilltoAccount__c = o.SBQQ__Quote__r.BillToAccount__c;
                           }
                           
                           if(o.SBQQ__Quote__r.ShiptToAccount__c != null){
                               o.ShipToAccount__c = o.SBQQ__Quote__r.ShiptToAccount__c;
                           }
                           
                           if(o.SBQQ__Quote__r.SoldToAccount__c != null){
                               o.SoldToAccount__c = o.SBQQ__Quote__r.SoldToAccount__c;
                           }
                           
                           if(o.SBQQ__Quote__r.EndUserAccount__c != null){
                               o.EndUserAccount__c = o.SBQQ__Quote__r.EndUserAccount__c;
                           }
                           
                           if(o.SBQQ__Quote__r.BilltoContact__c != null){
                               o.BillToContactId = o.SBQQ__Quote__r.BilltoContact__c;
                           }
                           
                           if(o.SBQQ__Quote__r.ShipToContact__c != null){
                               o.ShipToContactId = o.SBQQ__Quote__r.ShipToContact__c;
                           }
                           
                           if(o.SBQQ__Quote__r.SoldToContact__c != null){
                               o.SoldToContact__c = o.SBQQ__Quote__r.SoldToContact__c;
                           }
                           
                           if(o.SBQQ__Quote__r.EndUserContact__c != null){
                               o.EndUserContact__c = o.SBQQ__Quote__r.EndUserContact__c;
                           }
                           
                           if(o.SBQQ__Quote__r.BillToAccount__c != null){
                               o.blng__BillingAccount__c = o.SBQQ__Quote__r.BillToAccount__c;
                           }
                           
                           if(o.SBQQ__Quote__r.Legal_Entity__c != null){
                               o.Legal_Entity__c = o.SBQQ__Quote__r.Legal_Entity__c;
                           }
                           
                           if(o.SBQQ__Quote__r.SBQQ__BillingName__c != null){
                               o.BillingName__c = o.SBQQ__Quote__r.SBQQ__BillingName__c;
                           }
                           
                           if(o.SBQQ__Quote__r.SBQQ__ShippingName__c != null){
                               o.ShippingName__c = o.SBQQ__Quote__r.SBQQ__ShippingName__c;
                           }
                           
                           if(o.SBQQ__Quote__r.Shipping_Email__c != null){
                               o.Shipping_Email__c = o.SBQQ__Quote__r.Shipping_Email__c;
                           }
                           
                           if(o.SBQQ__Quote__r.Shipping_Preference__c != null){
                               o.Shipping_Preference__c = o.SBQQ__Quote__r.Shipping_Preference__c;
                           }
                           
                           if(o.SBQQ__Quote__r.PO__c != null){
                               o.PONumber = o.SBQQ__Quote__r.PO__c;
                           }
                           
                           if(o.SBQQ__Quote__r.SBQQ__PaymentTerms__c != null){
                               o.SBQQ__PaymentTerm__c = o.SBQQ__Quote__r.SBQQ__PaymentTerms__c;
                           }
                           if(o.SBQQ__PaymentTerm__c == 'Other' || o.SBQQ__Quote__r.SBQQ__PaymentTerms__c == 'Other'){ //<T04>
                               //o.blng__InvoiceBatch__c = Label.Custom_Payment_Term; //<T10>
                               orderIds.add(o.Id);
                           }
                          /* if(o.SBQQ__RenewalTerm__c != null) //<T05>
                               o.SBQQ__RenewalTerm__c = null;*/
                               
                            //o.blng__InvoiceBatch__c = Label.DoNotInvocie; //<T10>
                           
                           //<T22> START SBQQ__Quote__r.Sold_to_Account_ERP_Site__c,SBQQ__Quote__r.Sold_to_Account_ERP_Site__r.Exempt_Status__c
                           if(o.Exempt_Status__c != null && o.Exempt_Status__c == 'Exempt' && o.Exemption_On_File__c == false)
                              o.blng__InvoiceBatch__c = Label.LabelInvoiceHold;
                           else
                               o.blng__InvoiceBatch__c = Label.DoNotInvocie;  //<T10>
                           //<T22> END
                           
                           if((o.Sub_Type__c == 'Full Debook' && o.SBQQ__Quote__c != null) || (o.Route_To_Market__c == 'Market Place Private')) //<T23> <I2C-1336 > <I2C-1983>
                               o.Do_Not_Send_Invoices_to_Customer__c = 'Do Not Send All Invoices to Customer(S)'; //<I2C-1336>
                           //<I2C1311>
                           if(o.SBQQ__Quote__r.Quote_Summary__c != null && o.SBQQ__Quote__c != null){
                               if(Math.round(o.SBQQ__Quote__r.SBQQ__NetAmount__c)  == o.SBQQ__Quote__r.Quote_Summary__r.Professional_Services_Revenue__c && Math.round(Math.abs(o.SBQQ__Quote__r.SBQQ__NetAmount__c)) > 0) //<I2C-1412> & <I2C-1513>- Round 
                                   o.Source__c = 'PS';
                           }
                           
                           if(o.SBQQ__Quote__r.Quote_Summary__c != null){
                               if(Math.round(o.SBQQ__Quote__r.SBQQ__NetAmount__c)  == o.SBQQ__Quote__r.Quote_Summary__r.Education_Services_Revenue__c && Math.round(Math.abs(o.SBQQ__Quote__r.SBQQ__NetAmount__c)) > 0) //<I2C-1412> & <I2C-1513>- Round
                                   o.Source__c = 'ES';
                           }
                           //</I2C1311>
                           
                           //I2C-1936 START
                           if(o.Type == 'Renewal'){
                               if(o.BilltoAccount__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BilltoAccount__c && o.Billing_Address__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.Billing_Address__c)
                               {
                                     o.BillingAddress_PSFTID__c = o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillingAddress_PSFTID__c;
                                     o.BillingName_PSFTID__c = o.BillToContactId == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillToContactId ? o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.BillingName_PSFTID__c : '00000';
                               }
                               else{
                                   o.BillingAddress_PSFTID__c = NULL;
                                   o.BillingName_PSFTID__c = '00000';}
                               if(o.ShipToAccount__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShipToAccount__c && o.Shipping_Address__c== o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.Shipping_Address__c)
                               {
                                     o.ShippingAddress_PSFTID__c = o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShippingAddress_PSFTID__c;
                                     o.ShippingName_PSFTID__c = o.ShipToContactId == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShipToContactId ? o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.ShippingName_PSFTID__c : '00000';
                               }
                               else{
                                   o.ShippingAddress_PSFTID__c = NULL;
                                   o.ShippingName_PSFTID__c = '00000';}
                               
                               o.SoldAddress_PSFTID__c = o.SoldToAccount__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldToAccount__c && o.SoldAddress__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldAddress__c ? o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.SoldAddress_PSFTID__c : NULL;
                               o.EndUserAddress_PSFTID__c = o.EndUserAccount__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAccount__c && o.EndUserAddress__c == o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAddress__c ? o.SBQQ__Quote__r.Related_Contract__r.SBQQ__Order__r.EndUserAddress_PSFTID__c : NULL;
                              
                           }
                           
                           if(o.Type == 'Amendment'){
                               if(o.BilltoAccount__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BilltoAccount__c && o.Billing_Address__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.Billing_Address__c)
                                 {
                                     o.BillingAddress_PSFTID__c = o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillingAddress_PSFTID__c;
                                     o.BillingName_PSFTID__c = o.BillToContactId == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillToContactId ? o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.BillingName_PSFTID__c : '00000';
                                 }
                               else{
                                   o.BillingAddress_PSFTID__c = NULL;
                                   o.BillingName_PSFTID__c = '00000';}
                               
                               if(o.ShipToAccount__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShipToAccount__c && o.Shipping_Address__c== o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.Shipping_Address__c)
                                  {
                                     o.ShippingAddress_PSFTID__c = o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShippingAddress_PSFTID__c;
                                     o.ShippingName_PSFTID__c = o.ShipToContactId == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShipToContactId ? o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.ShippingName_PSFTID__c : '00000';
                                 }
                               else{
                                   o.ShippingAddress_PSFTID__c = NULL;
                                   o.ShippingName_PSFTID__c = '00000';}
                               
                               o.SoldAddress_PSFTID__c = o.SoldToAccount__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldToAccount__c && o.SoldAddress__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldAddress__c ? o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.SoldAddress_PSFTID__c : NULL;
                               o.EndUserAddress_PSFTID__c = o.EndUserAccount__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAccount__c && o.EndUserAddress__c == o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAddress__c ? o.SBQQ__Quote__r.SBQQ__MasterContract__r.SBQQ__Order__r.EndUserAddress_PSFTID__c : NULL;
                              
                           }
                           
                           //I2C-1936 ENDS
                               
                           ordersToUpdateMap.put(o.Id, o);
                           
                           //Verify if the Order is of Type Amendment
                           if(o.Type == Label.Order_Type_Amendment){
                               originalOrderNumberSet.add(o.Original_Order__c);
                               amendedOrderIds.add(o.Id);
                           }
                           
                           //Verify that the Order was created from a Quote
                           if(o.SBQQ__Quote__c != null){                 
                               //Check that the related Quote's Primary Order is not related to the current Order
                               if(o.SBQQ__Quote__r.Primary_Order__c != o.Id){ 
                                   quoteMap.put(o.SBQQ__Quote__c, new SBQQ__Quote__c(Id = o.SBQQ__Quote__c, Primary_Order__c = o.Id));               
                               }               
                           }
                           
                           
                       }
        
       
            //Query for Original Order records from the set of Order Numbers retrieved in originalOrderNumberSet
            List<Order> originalOrderList = [SELECT Id, OrderNumber, Original_Order__c, EffectiveDate FROM Order WHERE OrderNumber IN :originalOrderNumberSet];
            Map<String, Order> originalOrderMap = new Map<String, Order>();
            
            for(Order o : originalOrderList){
                //Populate the originalOrderMap with the Order Number and the Order record details
                originalOrderMap.put(o.OrderNumber, o);
            }
    
            
            for(Order o : [SELECT Id, Original_Order__c, blng__BillingDayOfMonth__c FROM Order WHERE Id IN :amendedOrderIds]){
            if(Test.isRunningTest()) {
                if(ordersToUpdateMap.containsKey(o.Id)){
                    Order temp = ordersToUpdateMap.get(o.Id);
                    ordersToUpdateMap.put(temp.Id, temp);
                } else{
                    ordersToUpdateMap.put(o.Id, o);
                }
            }
            
            if(originalOrderMap != null) {
                if(o.Original_Order__c != null) {
                    Integer day = originalOrderMap.get(o.Original_Order__c).EffectiveDate.day();
                    
                    if(ordersToUpdateMap.containsKey(o.Id)){
                        Order temp = ordersToUpdateMap.get(o.Id);
                        
                        //Populate the Amended Order Billing Day of Month with it's Original Order's Start Date
                        temp.blng__BillingDayOfMonth__c = String.valueOf(day);
                        
                        ordersToUpdateMap.put(temp.Id, temp);
                    } else{
                        //Populate the Amended Order Billing Day of Month with it's Original Order's Start Date
                        o.blng__BillingDayOfMonth__c = String.valueOf(day);
                        
                        ordersToUpdateMap.put(o.Id, o);
                    }
                }
            }
        }
        
        if(ordersToUpdateMap.size() > 0 && ordersToUpdateMap != null){
            try{
                Database.update(ordersToUpdateMap.values(), true);
            } catch(Exception e){
                GAM.CreateLogs('OrderProductTriggerHandler', ordersToUpdateMap.values(), 'ordersToUpdateMap');
            }
            
            GAM.InsertDebugLogs();
        }
        
        if(quoteMap != null && quoteMap.size() > 0){
            try{
                Database.update(quoteMap.values(), false);
            } catch(Exception e){
                GAM.CreateLogs('OrderTriggerHandler.handleAfterInsert() -> ' + e.getCause(), quoteMap.values(), 'quoteMap');
            }
        }
        
        GAM.InsertDebugLogs();
        
        if(orderIds.size () > 0) //<T04>
            updateOrderOnPT(orderIds);
            
        
    }
    
    /*
* Process for Order Activation:
* 1 .Order will be activated manually(Status set to Review & Fulfill)  and, Price Calculation Status = Completed, and the Order is not currently in an Activated state
* If the related End User Account is populated and the End User Account Type field is not populated, 
* the End User Account Record Type is set to Customer and Type is set to Customer
* 
* @param lstTriggerNew - List of new Orders, mapTriggerOld - Map of Order Id and previous state of the Order record
* @return return - void
* @throws exception - NA
*/
    public static void handleAfterUpdate(List<Order> lstTriggerNew, Map<Id, Order> mapTriggerOld){
    
        //List<Task> tskList = new List<Task>();
        Map<Id, Order> orderMap = new Map<Id, Order>();
        //Set<Id> oppIds = new Set<Id> (); //Commented for <SALESRT-13309>
        Set<Id> orderIds = new Set<Id> ();
        Map<Id,Id> orderIdEnt = new Map<Id,Id> ();
        Map<Id, Order> orderIdMap = new Map<Id, Order>();/**<T18>**/
        Set<String> orderIdSet = new Set<String>();/**<T18>**/
        Set<Id> fulFilmentCompletedOrderIdSet = new Set<Id>();//<F2A-437>
        Decimal ordAmtTol = Decimal.valueOf(Label.OrdAmtToleranceComp); //I2C-1701
        
        /*for(Order ORD : lstTriggerNew)
    {
        if(ORD.SBQQ__Contracted__c && ORD.Contract_Generated__c && ORD.Asset_Creation_Status__c == 'Completed' && ORD.Plan_Products_Created__c && ORD.Status == 'Bill & Contract' && ((math.ABS(ORD.blng__TotalBilling__c) > 0 && ORD.TotalAmount != 0) || ORD.TotalAmount == 0 || Label.RevisionLabel.equals(ORD.Sub_Type__c)))
            orderIds.add(ORD.Id);
    }
    if(orderIds.size() > 0)
    {
        for(Contract con : [Select Id,SBQQ__Order__c from Contract where Entitlement_Creation_Status__c =: 'Completed' AND SBQQ__Order__c =: orderIds])
        {
            orderIdEnt.put(con.SBQQ__Order__c,con.SBQQ__Order__c);
        }
    }*/
    
        for(Order o : [SELECT Id,OpportunityId,Opportunity.RecordType.Name,Sub_Type__c, SBQQ__Quote__c,Name,Status,Asset_Creation_Status__c,
                       SBQQ__Contracted__c,blng__TotalBilling__c,OrderNumber,OwnerId,Contract_Generated__c,CMS_Approved__c,Revenue_Agreement_Processed__c,
                       Provisioning_Complete_Date__c,TotalAmount,Plan_Products_Created__c,Generate_Date__c,blng__BilledAmountwithouttax__c, blng__InvoiceBatch__c
                       FROM Order WHERE Id IN :lstTriggerNew]){
                           System.debug('OLD value'+ mapTriggerOld.get(o.Id).blng__TotalBilling__c + 'New Value'+ o.blng__TotalBilling__c);
                           System.debug('OLD value Status'+ mapTriggerOld.get(o.Id).Status + 'New Value Status'+ o.Status);
                           
                           /*if(o.CMS_Approved__c && o.Revenue_Agreement_Processed__c && o.Provisioning_Complete_Date__c != null && o.SBQQ__Contracted__c && mapTriggerOld.get(o.Id).Contract_Generated__c != o.Contract_Generated__c && o.Contract_Generated__c && o.Status == 'Activated')
        {
            orderMap.put(o.Id, new Order(Id = o.Id, Status = 'Bill & Contract'));
        }*/
        //Commented for <SALESRT-13309>
        //<T12123> updated condition to include renewal opptys
        //if(o.Revenue_Agreement_Processed__c && o.Revenue_Agreement_Processed__c != mapTriggerOld.get(o.Id).Revenue_Agreement_Processed__c && o.OpportunityId != null && (Label.New_Sales_Opportunity_Record_Type.equals(o.Opportunity.RecordType.Name) || Label.Channel_Record_Type.equals(o.Opportunity.RecordType.Name) || Label.DirectOrder.equals(o.Sub_Type__c) || OPP_RENEWAL_RT.equals(o.Opportunity.RecordType.Name)) && !Label.RevisionLabel.equals(o.Sub_Type__c))
        //    oppIds.add(o.OpportunityId);
        //Commented for <SALESRT-13309>
                           if((mapTriggerOld.get(o.Id).blng__TotalBilling__c != o.blng__TotalBilling__c || mapTriggerOld.get(o.Id).Asset_Creation_Status__c  != o.Asset_Creation_Status__c || Math.ABS(o.TotalAmount) <= ordAmtTol || o.Plan_Products_Created__c != mapTriggerOld.get(o.Id).Plan_Products_Created__c) && 
                              o.Status == 'Bill & Contract' && o.Asset_Creation_Status__c == 'Completed' /*&& (orderIdEnt.get(o.Id) != null || o.SBQQ__Quote__c == null) && o.SBQQ__Contracted__c*/ && o.Contract_Generated__c && o.Plan_Products_Created__c && ((math.ABS(o.blng__TotalBilling__c) > 0 && o.TotalAmount != 0) || Math.ABS(o.TotalAmount) <= ordAmtTol || Label.RevisionLabel.equals(o.Sub_Type__c))){ //I2C-1701 Added tolerance of 0.5 on Total Amount
                                  orderMap.put(o.Id, new Order(Id = o.Id, Status = 'Completed')); 
                              }
                           
                           /**<T18> STARTS**/
                           if(o.Generate_Date__c != null && mapTriggerOld.get(o.Id).Generate_Date__c  != o.Generate_Date__c && (o.Status == 'Draft' || o.Status == 'Activated')){
                               orderIdMap.put(o.Id, o);           
                           }  
                           if(mapTriggerOld.get(o.Id).Status  != o.Status && o.Status == 'Activated'){
                               orderIdSet.add(o.Id);
                           }
                           
                           /**<T18> ENDS**/
                           //<F2A-437> START
                           if(o.Provisioning_Complete_Date__c!=null && mapTriggerOld.get(o.Id).Provisioning_Complete_Date__c  != o.Provisioning_Complete_Date__c){
                               fulFilmentCompletedOrderIdSet.add(o.Id); // 
                           }    
                           //<F2A-437> END
                           
                       }
    
        /**<T18> STARTS**/
        if(orderIdMap != null && orderIdMap.size()>0){
         
        /*<T25>
        List<Related_Fulfillment_Line__c> lRelateffLines = new List<Related_Fulfillment_Line__c>();
         Set<Id> OPwithFFLines = new Set<Id>();
         
         lRelateffLines =[Select Id,Order_Product__c from Related_Fulfillment_Line__c where Fullfillment_Line__r.Fullfillment__r.Order__c in:orderIdMap.keySet()];
         
         if(lRelateffLines.size()>0){
             for(Related_Fulfillment_Line__c rffl : lRelateffLines){
                 OPwithFFLines.add(rffl.Order_Product__c);
             }
         }
         
          List<OrderItem> lOrderItem = [SELECT Id,Order.Generate_Date__c,Ship_Date__c,Product2.Provisionable_New__c,OrderId 
                                          FROM OrderItem 
                                          WHERE OrderId IN:orderIdMap.keySet() 
                                          AND Id NOT IN :OPwithFFLines]; 
                                          <T25>*/
            //<T25> Adding revised QUERY
            List<OrderItem> lOrderItem = [SELECT Id,Order.Generate_Date__c,Ship_Date__c,Product2.Provisionable_New__c,OrderId 
                                          FROM OrderItem WHERE OrderId IN:orderIdMap.keySet() 
                                          AND (Product2.Provisionable_New__c = FALSE OR Order.Sub_Type__c ='Direct Order' OR (Order.Sub_Type__c = 'Full Debook' AND Order.Type = 'Amendment') 
                                               OR (TotalPrice <= 0 AND Quantity < 0) OR (Order.Sub_Type__c='Revision' AND Order.Opportunity.Enable_Downstream__c INCLUDES('Fulfillment')) OR 
                                               ((Product2.Offering_Type__c = 'On-Premise Perpetual License' OR Product2.Offering_Type__c = 'On-Premise One Time Term License') AND 
                                                SBQQ__QuoteLine__r.Transaction_Type__c = 'Renewal'))]; 
            
            for(OrderItem oItem : lOrderItem){
                oItem.Ship_Date__c = orderIdMap.get(oItem.OrderId).Generate_Date__c;
            }   
            
            if(lOrderItem != null && lOrderItem.size()>0){
                update lOrderItem;
            }
        }
        
        if(orderIdSet.size()>0){
            OrderProductTriggerHandler.updateOrderStatus(orderIdSet);
        }  
    /**<T18> ENDS**/    
    /* Commented for <SALESRT-13309>   
    if(oppIds.size() > 0)
    {
        revenueAgreementCancelFulfillDate updateJob = new revenueAgreementCancelFulfillDate(oppIds,'Oppty_Booked');
            ID jobID = System.enqueueJob(updateJob);
    }   
    Commented for <SALESRT-13309> */ 
        
        //<F2A-437> START
        if(fulFilmentCompletedOrderIdSet != NULL && fulFilmentCompletedOrderIdSet.size()>0){
            List<Org__c> updateOrgList = new List<Org__c>();
            for(Fulfillment_Line__c fLine : [SELECT Id, Org__c, Org__r.Account__c, Fullfillment__r.Order__r.Id, Fullfillment__r.Order__r.EndUserAccount__c FROM Fulfillment_Line__c  WHERE Org__c != NULL AND Fullfillment__r.Order__r.Id IN: fulFilmentCompletedOrderIdSet]){
                if(fLine.Org__r.Account__c != fLine.Fullfillment__r.Order__r.EndUserAccount__c){
                    updateOrgList.add(new Org__c(Id = fLine.Org__r.Id, Account__c = fLine.Fullfillment__r.Order__r.EndUserAccount__c));
                        }
                
            }
            if(updateOrgList.size()>0){
                try{
                    update updateOrgList;
                } catch(Exception e){
                    GAM.CreateLogs('OrderTriggerHandler.handleAfterUpdate() Update Orgs Account-> ' + e.getCause(), updateOrgList, 'updateOrgList');
                }
            }
        }  
        //<F2A-437> END
        if(orderMap != null && orderMap.size() > 0) {
            try{
                Database.update(orderMap.values(), false);
                System.debug('$$$$$$$$$$$$');
                
            } catch(Exception e){
                GAM.CreateLogs('OrderTriggerHandler.handleAfterUpdate() -> ' + e.getCause(), orderMap.values(), 'orderMap');
            }
        }
        
    }
    
    //<T1>
    public static void handleBeforeUpdate(Map<Id, Order> mapTriggerNew,Map<Id, Order> mapTriggerOld){
        //code updated : Anil - START
        //Set<Id> setReadyForProvisioningOrderIds = new set<Id>(); // Use this to update order products  <T02>/** <T18> COMMENTED THIS LINE **/
        Set<Id> setActivateOrderIds = new Set<Id>(); //Use this to update Orders Asynchronously
        Map<Id, Order> orderMap = new Map<Id, Order>();
        List<Account> endUserAccountList = new List<Account>();
        List<Order> ordersForOnPremiseAssetCreation= new List<Order>();
        List<OrderItem> LstOrderProductsProvisoningComplete =  new List <OrderItem>();
        Map<Id,Boolean> mapOrderIdandType = new Map<Id,Boolean>(); // <T08>
        //code updated : Anil - END
        Map<Id, String> MapForBillingDay = new Map<Id, String>();
        Set<Id> revAgrCancelIds = new Set<Id> ();
        Map<Id,String> ordCurrMap = new Map<Id,String> ();
        Map<Id,Order> ordGDMap = new Map<Id,Order> ();
        List<Task> tskList = new List<Task>();
        Map<Id,Id> setFCD = new Map<Id,Id> ();
        Set<Id> ordIDB = new Set<Id> ();
        Set<Id> directOrderIds = new Set<Id> ();
        List<Id> ordFP = new List<Id> ();
        Set<Id> orderStatusActivated = new Set<Id>();//<T31>
        Set<Id> shipToContactUpdatedSet = new Set<Id>();
        Set<Id> shipToContactSet = new Set<Id>();
        Map<Id,Id> mapContactOrder = new Map<Id,Id>(); //<I2C-1916>
        
        for(Order od : [Select Id,OpportunityId,Opportunity.Enable_Downstream__c,EndUserAccount__r.RecordType.Name,ShipToContactId,ShipToContact.Email,Additional_Ship_to_Contact__c,Additional_Ship_to_Contact__r.Email,Additional_Shipping_Email__c 
                        from Order where Id =: mapTriggerNew.keySet()]){ //<I2C-1916>
            Order o = mapTriggerNew.get(od.Id);
            //<I2C-1916>
            if(o.Additional_Ship_to_Contact__c != null && o.Additional_Ship_to_Contact__c != mapTriggerOld.get(o.Id).Additional_Ship_to_Contact__c){
                mapContactOrder.put(o.Id,o.Additional_Ship_to_Contact__c);
            }
            //<I2C-1869>
            if(o.ShipToContactId != null && o.ShipToContactId != mapTriggerOld.get(o.Id).ShipToContactId){
                shipToContactUpdatedSet.add(o.Id);
                shipToContactSet.add(o.ShipToContactId);
                //o.Shipping_Email__c = od.ShipToContact.Email;
            }
            //<I2C-1869>
            if(o.EffectiveDate != null){ //Even though the Order Start Date is mandatory
                System.debug('Day: ' + o.EffectiveDate.day());
                o.blng__BillingDayOfMonth__c = String.valueOf(o.EffectiveDate.day());
            }
            
            String Enable_Downstream = 'TEST' + od.Opportunity.Enable_Downstream__c;
            
            //<T22> Update only if the Invoice is not on Hold 
            
            if(o.blng__InvoiceBatch__c != Label.LabelInvoiceHold){
                system.debug('++KG'+o.blng__InvoiceBatch__c);
                if((mapTriggerOld.get(o.Id).Status != o.Status) || (mapTriggerOld.get(o.Id).blng__InvoiceBatch__c != o.blng__InvoiceBatch__c) || (mapTriggerOld.get(o.Id).SBQQ__PaymentTerm__c!= o.SBQQ__PaymentTerm__c)) //<T10>
                {
                    o.blng__InvoiceBatch__c = (mapTriggerOld.get(o.Id).Status != o.Status && o.Status == 'Bill & Contract') ? null : o.blng__InvoiceBatch__c;
                    
                    o.blng__InvoiceBatch__c = o.SBQQ__PaymentTerm__c == 'Other' ? Label.Custom_Payment_Term : ((o.blng__InvoiceBatch__c != Label.Custom_Payment_Term && o.blng__InvoiceBatch__c != Label.Debook_Other_Label && o.blng__InvoiceBatch__c != Label.Debook_Label) ? o.blng__InvoiceBatch__c : null); //<T04> <T07>  
                        
                        o.blng__InvoiceBatch__c = (o.Sub_Type__c == 'Full Debook' && o.Type == 'Amendment' && o.TotalAmount <= 0) ? (o.SBQQ__PaymentTerm__c != 'Other' ? Label.Debook_Label : Label.Debook_Other_Label) : o.blng__InvoiceBatch__c; //<T07>  
                    
                    o.blng__InvoiceBatch__c = (o.Status == 'Draft' || o.Status == 'Activated' || o.Status == 'Cancelled') ? Label.DoNotInvocie : o.blng__InvoiceBatch__c;
                    
                } //</T10>
            }
            //Code Updated ANIL :
            
            if(mapTriggerOld.get(o.Id).Status == 'Draft' && o.Status == 'Activated' && (o.SBQQ__PriceCalcStatus__c == 'Completed' || o.SBQQ__PriceCalcStatus__c == 'Not Needed'))
            {
                //Creating Task 
                /* Task tsk = new Task();
                tsk.Subject = 'CMS Approval for Order' + o.OrderNumber;
                tsk.Status = 'Open';
                tsk.Priority = 'Normal';
                tsk.WhatId = o.ID;
                tsk.OwnerId = o.OwnerId;
                tskList.add(tsk);*/
                
                //setReadyForProvisioningOrderIds.add(o.Id);/** <T18> COMMENTED THIS LINE **/
                //orderMap.put(o.Id, new Order(Id = o.Id, RecordTypeId = rtList[0].Id, StatusCode = 'A'));
                o.RecordTypeId = rtList[0].Id;
                o.StatusCode = 'A';
                //<T08>
                Boolean b = False; 
                //<T30> - Commented the below if condition to create ROC for all Types of Order - CPQ Upgrade '22
                //if( !Label.RevisionLabel.equals(o.Sub_Type__c) || (Label.RevisionLabel.equals(o.Sub_Type__c) && Enable_Downstream.contains('Revenue Agreement'))) //<T12>
                //{
                if(!(o.Source__c == Label.PRM_Order_Type_Partner_Fee && o.SBQQ__Quote__c == null)){
                    if(o.Type != 'Amendment'){
                        b= True;
                        mapOrderIdandType.put(o.Id,b);
                    }
                    //if(o.Type == 'Amendment' && o.Business_Model__c != 'Product Fund' && o.Business_Model__c != 'Product Fund EVAL') Nishit Edit I2C-1317
                    //if(o.Type ==  'Amendment'  &&  !(o.Business_Model__c == 'Product Fund' && o.Sub_Type__c == 'Remix')) // <T28> <I2C-1335> Commented to create contract for Product Fund Remix Amend Orders
                    if(o.Type ==  'Amendment')
                    {
                        System.debug('@@@@Amend Boolean' + b);    
                        mapOrderIdandType.put(o.Id,b);//<T08>
                    }
                }
                //}     
                /*<T15> if(!String.isBlank(o.EndUserAccount__c) && od.EndUserAccount__r.RecordType.Name == Label.Prospect_Account_Record_Type){
                endUserAccountList.add(new Account(Id = o.EndUserAccount__c, RecordTypeId = Label.Customer_Account_Record_Type, Type = 'Customer'));
                } </T15>*/
                
                if(o.Source__c == Label.PRM_Order_Type_Partner_Fee && o.SBQQ__Quote__c == null)
                    o.Revenue_Agreement_Processed__c = TRUE;
                //<T19>     
                if(o.SBQQ__Quote__c == null)
                    directOrderIds.add(o.Id);
                
                orderStatusActivated.add(o.Id);//<T31>  
            }
            
            if(o.Type ==  'Amendment' && o.CMS_Approved__c && o.Provisioning_Complete_Date__c != null && o.Business_Model__c == 'Product Fund' && o.Sub_Type__c == 'Remix') // <T28> <I2C-1335>
                o.Revenue_Agreement_Processed__c = TRUE;
            
            if((o.Type ==  'New' || o.Type ==  'Renewal' || o.Source__c == 'Ecommerce - Paygo') && o.Related_Revenue_Orders__c == NULL) // <I2C-1729>
                o.Related_Revenue_Orders__c = Integer.valueOf(o.OrderNumber) + '';
            
            if(mapTriggerOld.get(o.Id).Status != o.Status && (o.Status == 'Cancelled' || o.Status == 'Debook')) // <T09>
            {
                revAgrCancelIds.add(o.Id);
            }
            
            if((mapTriggerOld.get(o.Id).Generate_Date__c != o.Generate_Date__c || (mapTriggerOld.get(o.Id).Status != o.Status && o.Status == 'Activated')) && o.Generate_Date__c != null && o.Status != 'Draft')//<T11>
            {
                ordCurrMap.put(o.Id,o.CurrencyIsoCode);
                ordGDMap.put(o.Id,o);
            }
            //<T24> If Generate Date is changed by Revenue Team to validate and populate FP
            if(mapTriggerOld.get(o.Id).Generate_Date__c != o.Generate_Date__c /*&& mapTriggerOld.get(o.Id).Generate_Date__c.month() != o.Generate_Date__c.month()*/)
                ordFP.add(o.Id);
            
            if(mapTriggerOld.get(o.Id).Exchange_Rate__c != o.Exchange_Rate__c) //<T017>
                ordIDB.add(o.Id);
            
            //<T12>
            if(Label.RevisionLabel.equals(o.Sub_Type__c) && !Enable_Downstream.contains('Revenue Agreement') && o.Status != 'Draft' && o.Status != 'Cancelled' && !o.Revenue_Agreement_Processed__c){
                o.Revenue_Agreement_Processed__c = TRUE;
                //<T14>
                o.SoldAddress_PSFTID__c = 'TBF';
                o.ShippingAddress_PSFTID__c = 'TBF';
                o.EndUserAddress_PSFTID__c = 'TBF';
                o.BillingAddress_PSFTID__c = 'TBF';
                o.CMS_Approved__c = TRUE;//</T14>
            }
            if(Label.RevisionLabel.equals(o.Sub_Type__c) && !Enable_Downstream.contains('Assets & Entitlements') && o.Status == 'Bill & Contract' && o.Asset_Creation_Status__c != 'Completed')
                o.Asset_Creation_Status__c = 'Completed';
            if(Label.RevisionLabel.equals(o.Sub_Type__c) && !Enable_Downstream.contains('Fulfillment') && o.Status != 'Draft' && o.Status != 'Cancelled' && o.Provisioning_Complete_Date__c == null)
                o.Provisioning_Complete_Date__c = Date.Today();//<T12>
            
            if(o.Status == 'Bill & Contract' && (!Label.RevisionLabel.equals(o.Sub_Type__c) || (Label.RevisionLabel.equals(o.Sub_Type__c) && Enable_Downstream.contains('Assets & Entitlements'))) && o.Asset_Creation_Status__c != 'Completed' && o.Asset_Creation_Status__c != 'Failed')
                o.Asset_Creation_Status__c = 'Initiated';//<T13> 
            
            //<I2C-1791> START
            if(o.blng__BilledAmountwithouttax__c != mapTriggerOld.get(o.Id).blng__BilledAmountwithouttax__c && o.blng__InvoiceBatch__c == 'Adhoc'){
                o.blng__InvoiceBatch__c = NULL;
            }
            //<I2C-1791> END
            
        } 
        //<T31> - Start
        if(orderStatusActivated.size() > 0){
            DateTime newDateTime = DateTime.now().addMinutes(1);
            String hour = String.valueOf(newDateTime.hour());
            String min = String.valueOf(newDateTime.minute()); 
            String ss = String.valueOf(newDateTime.second());
            String month = String.valueOf(newDateTime.month());
            String day = String.valueOf(newDateTime.day());
            String year = String.valueOf(newDateTime.year());
            //parse to cron expression
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
            
            // schedule a job to update the Billing Frequency to Invoice Plan and update the Orders with earliest start date and latest end date to execute after one minute 
            primaryOrderedContRenewalSchedulable s = new primaryOrderedContRenewalSchedulable('Set Order Date and Custom Bill Plan', 'Order', orderStatusActivated);                  
            Id ordNum = new List<Id>(orderStatusActivated)[0];
            System.schedule('SetOrderDateAndCustomBillPlan_' + ordNum + ' @: ' + String.valueOf(newDateTime), nextFireTime, s);
        }
        //<T31> - End
        //<I2C-1916>
        if(mapContactOrder.size()>0){
            Map<Id,Contact> mapContactEmail = new Map<Id,Contact>([Select id,Email from Contact where  ID IN :mapContactOrder.values()]); 
            for(Id orderId : mapContactOrder.keySet()){
                 Order o = mapTriggerNew.get(orderId);
                if(mapContactEmail.containsKey(mapContactOrder.get(orderId)) && mapContactEmail.get(mapContactOrder.get(orderId)).Email !=null){
                    o.Additional_Shipping_Email__c = mapContactEmail.get(mapContactOrder.get(orderId)).Email;
                }
            }
              		
          }
        //<I2C-1916>
        //<I2C-1869>
        if(shipToContactUpdatedSet.size() > 0){
            Map<Id, Contact> mapIdByContact = new Map<Id, Contact>([SELECT Id,Email FROM Contact WHERE Id IN :shipToContactSet]);
            for(Id orderId : shipToContactUpdatedSet){
                Order o = mapTriggerNew.get(orderId);
                if(mapIdByContact.containsKey(o.ShipToContactId) && mapIdByContact.get(o.ShipToContactId).Email != null){
                    o.Shipping_Email__c = mapIdByContact.get(o.ShipToContactId).Email;
                }
            }
        }
        //<I2C-1869>
        
        
        /*if(tskList != null && tskList.size() > 0) {
        try{
        Database.insert(tskList, false);
        
        } catch(Exception e){
        GAM.CreateLogs('OrderTriggerHandler.handleAfterUpdate() -> ' + e.getCause(), tskList, 'tskList');
        }
        }*/
        
        if(mapOrderIdandType.size() > 0) //<T08>
            createRevenueAgreementJunction(mapOrderIdandType);          
        
        if(revAgrCancelIds.size() > 0) // <T09>
        {
            revenueAgreementCancelFulfillDate updateJob = new revenueAgreementCancelFulfillDate(revAgrCancelIds,'Cancel_Debook');
            ID jobID = System.enqueueJob(updateJob);
        }   
        
        //<T11> 
        if(ordCurrMap.size() > 0)
        {
            for(DatedConversionRate DCR : [SELECT Id,ConversionRate,IsoCode,NextStartDate,StartDate FROM DatedConversionRate WHERE IsoCode =: ordCurrMap.values() ORDER BY StartDate DESC ])
            {
                for(Id ordId : ordGDMap.keySet())
                {
                    Date BookedDate = ordGDMap.get(ordId).Generate_Date__c;
                    if(DCR.IsoCode == ordCurrMap.get(ordId) && DCR.StartDate <= BookedDate && DCR.NextStartDate > BookedDate)
                    {
                        ordGDMap.get(ordId).Exchange_Rate__c = DCR.ConversionRate != null ? 1/DCR.ConversionRate : ordGDMap.get(ordId).Exchange_Rate__c;
                        
                        if(ordGDMap.get(ordId).Exchange_Rate__c != mapTriggerOld.get(ordId).Exchange_Rate__c && mapTriggerNew.get(ordId).Generate_Date__c != mapTriggerOld.get(ordId).Generate_Date__c) //<T17>
                            ordIDB.add(ordId);
                    }
                }
            }
        } //</T11>
        
        /*<T15>if(endUserAccountList != null && endUserAccountList.size() > 0){
        try{
        Database.update(endUserAccountList, false);
        } catch(Exception e){
        GAM.CreateLogs('OrderTriggerHandler.handleAfterUpdate() -> ' + e.getCause(), endUserAccountList, 'endUserAccountList');
        }
        }</T15>*/
        
        /** <T18> **/
        /**
        if(setReadyForProvisioningOrderIds !=null && setReadyForProvisioningOrderIds.size()> 0 ){            
        For(OrderItem oi : [Select id,orderId,Ship_Date__c,ServiceDate,SBQQ__Status__c,Product2.Provisionable_New__c,Order.EffectiveDate,Order.Opportunity.Enable_Downstream__c,Order.Sub_Type__c,Order.Type,TotalPrice,Quantity,SBQQ__ContractAction__c from orderitem where orderid in :setReadyForProvisioningOrderIds]){         
        if(!oi.Product2.Provisionable_New__c || (oi.Order.Sub_Type__c == 'Full Debook' && oi.Order.Type == 'Amendment') || (oi.TotalPrice <= 0 && oi.Quantity < 0))
        {
        //Do Nothing
        }
        else
        setFCD.put(oi.orderId,oi.orderId);
        
        }
        
        for(Id oid : setReadyForProvisioningOrderIds)
        {
        if(setFCD.get(oid) == null)
        mapTriggerNew.get(oid).Provisioning_Complete_Date__c = Date.Today();
        }
        
        }**/
        /** <T18> **/
        
        if(ordIDB.size() > 0)
            revSchTriggerHandler.createUpdateBookings(ordIDB,'Order');
        //<T19> <T29> - Removing the Order Item activation logic  
        //if(directOrderIds.size() > 0)
        //    primaryOrderedContractedRenewal.directOrderAct('Direct_Order_Activation','Order',directOrderIds);
        
        //<T24> Call CalculateFP()
        if(ordFP.size() > 0)
            calculateFP(ordFP,mapTriggerNew);
        
        /* if(LstOrderProductsProvisoningComplete != null && LstOrderProductsProvisoningComplete.size() > 0){
        try{
        Database.update(LstOrderProductsProvisoningComplete, false);
        } catch(Exception e){
        GAM.CreateLogs('OrderTriggerHandler.handleAfterUpdate() -> ' + e.getCause(), LstOrderProductsProvisoningComplete, 'LstOrderProductsProvisoningComplete');
        }
        }*/
        
        
    }  
    //</T1>
    
    @future
    public static void updateOrderOnPT(Set<Id> orderIds)
    {
        Map<Id,Id> OrderQuoteMap = new Map<Id,Id> ();
        List<Payment_Term__c> PTList = new List<Payment_Term__c> ();
        for(Order ORD : [Select Id,SBQQ__Quote__c from Order where Id =: orderIds])
        {
            OrderQuoteMap.put(ORD.SBQQ__Quote__c,ORD.Id);
        }
        for(Payment_Term__c PT : [Select Id,Order__c,Quote__c,Order__r.Status from Payment_Term__c where Quote__c =: OrderQuoteMap.keyset()])
        {
            if(PT.Order__c == null || PT.Order__r.Status == 'Cancelled')
            {
                PT.Order__c = OrderQuoteMap.get(PT.Quote__c);
                PTList.add(PT);
            }
        }
        if(PTList.size() > 0)
        {
            try{
                update PTList;
            } catch(Exception e){
                GAM.CreateLogs('OrderTriggerHandler', PTList, 'updateOrderOnPT');
            }
            
            GAM.InsertDebugLogs();
        }
    }
    
     
    //<T08>
        /*
* Create related order and Contract record when an Order is activated.
*If Order is Amendment, then initial order = False, else true.
* @param mapOrderIdandType - map of Order Id and a Boolean 
* @return return - void
* @throws exception - NA
*/
    
    public static void createRevenueAgreementJunction(Map<Id,Boolean> mapOrderIdandType){
        List<Related_Order_and_Contract__c> listRelatedRA = new List<Related_Order_and_Contract__c>();
        System.debug('INSIDE create');
        System.debug('@@@@@mapOrderIdandType'+ mapOrderIdandType.values());
        for(Id orderId : mapOrderIdandType.keySet()){
            System.debug('Inside for loop');
            Related_Order_and_Contract__c relatedRA = new Related_Order_and_Contract__c(Order__c = orderId,Original_Order__c = mapOrderIdandType.get(orderId),Unique_ID__c = orderId );
            listRelatedRA.add(relatedRA);
            
        }
        
        if(listRelatedRA.size() > 0){
            try{
                System.debug('INSIDE Insert');
                insert listRelatedRA;
            }
            catch(Exception e){
                GAM.CreateLogs('OrderTriggerHandler', listRelatedRA, 'createRevenueAgreementJunction');
            }
        }
    }
    //------------------------------------------------------<T16>
    @InvocableMethod(label='createInvoiceGroup')
    public static void createInvoiceGroup(List<Id> orderIds){
        //Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem>([SELECT Id,OrderId,Purchase_Order_PO_Number__c,ServiceDate,EndDate FROM OrderItem WHERE Id IN :lstOrderProductIds]);
        Map<Id,OrderItem> mapOrderItem = new Map<Id,OrderItem> ([SELECT Id,OrderId,Order.SBQQ__Quote__c,Purchase_Order_PO_Number__c,ServiceDate,EndDate,Order.Finance_Period__c,Order.BilltoAccount__c,Order.BilltoAccount__r.PO_Required__c FROM OrderItem WHERE OrderId IN :orderIds]);
        Map<Id,Set<String>> mapOrderIdPONumbers = new Map<Id,Set<String>>();
        Map<Id,Map<String,Date>> mapOrderIdStartDate = new Map<Id,Map<String,Date>> ();
        Map<Id,Map<String,Date>> mapOrderIdEndDate = new Map<Id,Map<String,Date>> ();
        Map<Id,Date> mapOrderIdCreatedDate = new Map<Id,Date> ();
        Map<Id,Integer> maporderIdPOCount = new Map<Id,Integer> ();
        Integer InvoiceGroupToCreate = 0;
        List<Id> invoiceGroupIds = new List<Id>();   
        
        //<T20> starts
        Map<Id, Boolean > mapOrderIdPONumberChecked = new  Map<Id, Boolean >();   
        Map<Id, SBQQ__Quote__c > mapOrderIdPOAmount = new  Map<Id, SBQQ__Quote__c >();   //<T21>     
        
         for(SBQQ__Quote__c li : [SELECT id,Primary_Order__c , Single_PO_Number__c , PO_Amount__c,PO__c FROM SBQQ__Quote__c WHERE Primary_Order__c IN:OrderIds ])
        {
            mapOrderIdPONumberChecked.put(li.Primary_Order__c, li.Single_PO_Number__c );           
            mapOrderIdPOAmount.put(li.Primary_Order__c,  li);//<T21>
        }
         //<T20> ends   
           
            for(AggregateResult res : [SELECT max(EndDate) maxEDate,min(ServiceDate) minSDate,min(CreatedDate) minCreatedDate,COUNT_DISTINCT(SBQQ__QuoteLine__r.Purchase_Order_PO_Number__c) PO_Count,Purchase_Order_PO_Number__c PONUM, OrderId orderId FROM OrderItem WHERE OrderId IN:OrderIds AND SBQQ__QuoteLine__c != NULL AND Order.Sub_Type__c != 'Revision' AND Order.BilltoAccount__r.PO_Required__c = TRUE GROUP BY OrderId,Purchase_Order_PO_Number__c])
        {
            Date maxEndDate = Date.valueOf(res.get('maxEDate'));
            Date minStartDate = Date.valueOf(res.get('minSDate'));
            Date minCreatedDate = DateTime.valueOf(res.get('minCreatedDate')).Date();
            String orderId = String.ValueOf(res.get('orderId'));   
            String PONUM = String.ValueOf(res.get('PONUM'));   
            Integer POCount = Integer.valueOf(res.get('PO_Count'));   //COUNT_DISTINCT() function returns the number of distinct non-null field values, on Order creation all lines have PO                     
            InvoiceGroupToCreate = InvoiceGroupToCreate + POCount;
           
            if(!mapOrderIdPONumbers.keySet().contains(OrderId))
            {
                mapOrderIdPONumbers.put(orderId,new Set<String>{PONUM});
                mapOrderIdStartDate.put(orderId, new Map<String,Date>{PONUM => minStartDate}); 
                mapOrderIdEndDate.put(orderId, new Map<String,Date>{PONUM => maxEndDate});   
                maporderIdPOCount.put(orderId,POCount);
            }
            else
            {
                mapOrderIdPONumbers.get(orderId).add(PONUM);
                mapOrderIdStartDate.get(orderId).put(PONUM,minStartDate); 
                mapOrderIdEndDate.get(orderId).put(PONUM,maxEndDate);  
                Integer getOrdCount = maporderIdPOCount.get(orderId);
                maporderIdPOCount.put(orderId,getOrdCount + POCount);
            }
            mapOrderIdCreatedDate.put(orderId,minCreatedDate);
        }
       
        //Creating a list of Invoice Groups to insert
        List<Invoice_Group__c> lstInvoiceGroupToCreate = new List<Invoice_Group__c>();
        for(Integer i=0;i<InvoiceGroupToCreate;i++){
            Invoice_Group__c igObj = new Invoice_Group__c();
            lstInvoiceGroupToCreate.add(igObj);
        }
        //Inserting the Invoice Groups 
        if(lstInvoiceGroupToCreate != null && lstInvoiceGroupToCreate.size() > 0)
        {
            try{
                Database.SaveResult[] srList = Database.insert(lstInvoiceGroupToCreate,false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        invoiceGroupIds.add(sr.getId());
                    }
                }            
            } catch(DmlException e){
                GAM.CreateExceptionRecords('OrderProductTriggerHandler --> createInvoiceGroup', e.getMessage(), 'error from OrderProductTriggerHandler.createInvoiceGroup');
            }
        }
        Map<Id,Invoice_Group__c> mapInvoiceGroup = new Map<Id,Invoice_Group__c>([SELECT Id,Name FROM Invoice_Group__c WHERE Id IN :invoiceGroupIds]);
        //Creating a map of OrderId,PO Number and Invoice Group
        Map<Id,Map<String,Id>> mapOrderPOInvoiceGroup = new Map<Id,Map<String,Id>>();
        
        if(invoiceGroupIds != null && invoiceGroupIds.size() > 0)
        {
            for(Id orderId:mapOrderIdPONumbers.keySet()){
                Set<String> poNumbers = mapOrderIdPONumbers.get(orderId);                
                Map<String,Id> mapPoIg = new Map<String,Id>();
                for(String PoNumber:poNumbers){
                    mapPoIg.put(PoNumber,invoiceGroupIds.remove(0));
                }
                mapOrderPOInvoiceGroup.put(orderId, mapPoIg);                
            }
        }
        
         
        //Creating the Invoice Group Date records
        List<Invoice_Group_Date__c> lstIgdToInsert = new List<Invoice_Group_Date__c>();
        for(Id orderId:mapOrderPOInvoiceGroup.keySet()){
                Boolean PONumberCheckedFlag ;//<T20>
                Set<String> POnumberset = new  Set<String>();//<T20>
             Map<String,Id> mapPoIg = mapOrderPOInvoiceGroup.get(orderId);
             for(String poNumber:mapPoIg.keySet()){
                Date startDate = mapOrderIdStartDate.get(orderId).get(poNumber);
                Date endDate = startDate.addMonths(12).addDays(-1);
                Date CreateDate = mapOrderIdCreatedDate.get(orderId);
            //<T20> starts
            if( mapOrderIdPONumberChecked.containsKey(orderId) && mapOrderIdPONumbers.containsKey(orderId) )
            {                
                PONumberCheckedFlag = mapOrderIdPONumberChecked.get(orderId);               
                POnumberset = mapOrderIdPONumbers.get(orderId);
                
               if(PONumberCheckedFlag == true) 
               {
                    endDate   = mapOrderIdEndDate.get(orderId).get(poNumber);    
               }
            }
            //<T20> ends
                Invoice_Group_Date__c igdObj = new Invoice_Group_Date__c();
                igdObj.Invoice_Group__c = mapPoIg.get(poNumber);
                igdObj.Invoices_Created_Within_Start_Date__c = CreateDate < startDate ? CreateDate : startDate;
                igdObj.Invoices_Created_Within_End_Date__c = endDate;                
                igdObj.PO_Number__c = poNumber;
                igdObj.Order__c = orderId;
                if(mapOrderIdPOAmount.get(orderId).PO__c == poNumber) //<T21>
                    igdObj.PO_Amount__c = mapOrderIdPOAmount.get(orderId).PO_Amount__c;
                lstIgdToInsert.add(igdObj);                 
                while(endDate < mapOrderIdEndDate.get(orderId).get(poNumber) && (PONumberCheckedFlag == false )){ //<T20>
                    startDate = startDate.addMonths(12); 
                    endDate = startDate.addMonths(12).addDays(-1);
                    igdObj = new Invoice_Group_Date__c();
                    igdObj.Invoice_Group__c = mapPoIg.get(poNumber);
                    igdObj.Invoices_Created_Within_Start_Date__c = startDate;
                    igdObj.Invoices_Created_Within_End_Date__c = endDate;
                    igdObj.Order__c = orderId;
                    lstIgdToInsert.add(igdObj);                  
                }
            }
        }
        if(lstIgdToInsert != null && lstIgdToInsert.size() > 0)
        {
            try{
                Database.SaveResult[] srList = Database.insert(lstIgdToInsert,false);
            } catch(DmlException e){
                GAM.CreateExceptionRecords('OrderProductTriggerHandler --> createInvoiceGroup', e.getMessage(), 'error from createInvoiceGroup');
            }
        }        
        //Updating the OrderItem with Invoice Group
        List<OrderItem> lstOrderItemToUpdate = new List<OrderItem>();
        for(OrderItem oli:mapOrderItem.values()){
            if(mapOrderPOInvoiceGroup.get(oli.OrderId) != null)
            {
                OrderItem orderItemObj = new OrderItem(Id =oli.Id);
                orderItemObj.Invoice_Group__c = mapOrderPOInvoiceGroup.get(oli.OrderId).get(oli.Purchase_Order_PO_Number__c);
                orderItemObj.blng__InvoiceGroupId__c = String.valueOf(mapOrderPOInvoiceGroup.get(oli.OrderId).get(oli.Purchase_Order_PO_Number__c));
                lstOrderItemToUpdate.add(orderItemObj);
            }
        }
        if(lstOrderItemToUpdate != null && lstOrderItemToUpdate.size() > 0)
        {
            try{
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] srList = Database.update(lstOrderItemToUpdate,false);
                SBQQ.TriggerControl.enable();
            } catch(DmlException e){
                GAM.CreateExceptionRecords('OrderProductTriggerHandler --> createInvoiceGroup', e.getMessage(), 'error from createInvoiceGroup');
            }
        }
        //<T24> When an Order is created, call calculateFP() to update Finance Period based on Generate Date
        calculateFP(orderIds,null);
        
        
    }     
    //------------------------------------------------------<T16/>    
    
    /*
    Method to calculate and populate FP
    For new Order (from Quote or Direct Order) it always take open & Active Finance Period
    Existing Order when Generate Date is updated, it validates and then update Finance Period
    Updating Generate Date is allowed when Order is in Draft or RA is in DRAFT or Pre-Allocate
    */
    public static void calculateFP(List<Id> orderIds,Map<Id,Order> orderMap)
    {
        Map<Id,Order> orderDateMap = new Map<Id,Order> ();
        List<Order> orderListToUpdate = new List<Order> ();
        blng__FinancePeriod__c ActiveFPId = new blng__FinancePeriod__c ();
        blng__FinancePeriod__c FutureFPId = new blng__FinancePeriod__c ();
        Map<Id,Related_Order_and_Contract__c> ROCMap = new Map<Id,Related_Order_and_Contract__c> ();
        
        // Query Orders whose Finance Period is NULL
        for(Order o : [Select Id,Generate_Date__c,Finance_Period__c from Order where Id =: orderIds AND Finance_Period__c = null AND Generate_Date__c != null])
        {
            orderDateMap.put(o.Id,o);
        }
        
        if(orderMap != null)
        {
            orderDateMap = null;
            orderDateMap = orderMap;
        }
            
        
        if(orderDateMap != null)
        {
            if(orderDateMap.values() != null)
            {
                
                //QUERY Open Finance Periods
                for(blng__FinancePeriod__c FP : [Select Id,Active__c,blng__PeriodStartDate__c,blng__PeriodEndDate__c from blng__FinancePeriod__c where blng__PeriodStatus__c = 'Open' AND blng__FinanceBook__r.Name = 'Booking' AND RecordType.Name = 'Booking' ORDER BY blng__PeriodStartDate__c ASC])
                {
                    if(FP.Active__c)
                        ActiveFPId = FP;
                    else
                        FutureFPId = FP;
                }
                
                if(orderMap != null)
                {
                    for(Related_Order_and_Contract__c ROC : [Select Id,Order__c,Revenue_Agreement__c,Revenue_Agreement__r.Stage__c from Related_Order_and_Contract__c where Order__c =: orderIds])
                    {
                        ROCMap.put(ROC.Order__c,ROC);
                    }
                }
                
                for(Id orderId : orderDateMap.keyset())
                {
                        Date GenerateDate = orderDateMap.get(orderId).Generate_Date__c;
                        if(GenerateDate >= ActiveFPId.blng__PeriodStartDate__c && GenerateDate <= ActiveFPId.blng__PeriodEndDate__c)
                        {
                            orderDateMap.get(orderId).Finance_Period__c = ActiveFPId.Id;
                        }
                        else if(orderMap == null)
                        {

                            orderDateMap.get(orderId).Finance_Period__c = ActiveFPId.Id;
                            if(orderDateMap.get(orderId).Generate_Date__c < ActiveFPId.blng__PeriodStartDate__c) //<I2C-1345>   
                            orderDateMap.get(orderId).Generate_Date__c = ActiveFPId.blng__PeriodEndDate__c;
                        }
                        
                        if(orderMap != null)
                        {
                            if(GenerateDate >= FutureFPId.blng__PeriodStartDate__c)
                            {
                                if(GenerateDate > FutureFPId.blng__PeriodEndDate__c) //<I2C-1345>
                                    orderDateMap.get(orderId).addError('You cannot move the Generate Date to Finance Period that is not yet opened.'); //<I2C-1345>
                                orderDateMap.get(orderId).Finance_Period__c = FutureFPId.Id;
                                   
                            }
                            if(GenerateDate < ActiveFPId.blng__PeriodStartDate__c)
                                orderDateMap.get(orderId).addError('You cannot move the Generate Date to Closed Period.');
                                
                            if(ROCMap.get(orderId) != null)
                            {
                                if(ROCMap.get(orderId).Revenue_Agreement__r.Stage__c != null && ROCMap.get(orderId).Revenue_Agreement__r.Stage__c != 'Draft' && ROCMap.get(orderId).Revenue_Agreement__r.Stage__c != 'Pre-Allocate')
                                    orderDateMap.get(orderId).addError('You can update Generate Date only when Revenue Agreement is in Draft or Pre-Allocate stage.');
                            }

                        }
                }
            }
        
            if(orderMap == null)
                update orderDateMap.values();
        
        }
    }
}