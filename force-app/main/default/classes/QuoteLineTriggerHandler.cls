/*
Class:          QuoteLineTriggerHandler
@Author:        Kendra Claiborne
@Created Date:  19 December 2017
@Description:   Handler class for SBQQ__QuoteLine__c Triggers
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Ticket No.          Requested By        Description
Kendra Claiborne    01/11/2018      TKT-001070          Prasanth Sagar      Moved After Insert logic to Before Insert Trigger Context
Kendra Claiborne    02/2/2018       TKT-001010          Sriram Gopalan      Modified logic to calculate the End Date Localized in a Leap Year scenario.
The logic takes the new date and subtractes one day, which will roll to the 
previous month if the date defined is at the beginning of the month 
(so rather than getting 2/0/19 you will see 1/31/19)
Vivek Warrier       27-Nov-2018     NA                  Prasanth Sagar      To use the handler to populate the PDS text in the QL instead of twinning the field <T1>
Sumit Mittal        04-Dec-2018     NA                  Q2C 2a              Update PDS_Is_Null__c field as it is used in the Exhibit A template to render the PDS text. <T2>
Vivek Warrier       08-Feb-2018     SALESRT-4010        Keerthana Shanmugam Checking for the QLI Term before considering the Quote term for End Date <T3>
Kiran G             09-Feb-2019     QCA-453             Reed A              Add the Forecast family of Product on Quote Line Item               <T4>
Ritika Gupta        14-Nov-2018     SALESRT-3871/
SALESRT-3867        Prasanth            Fixing condition which checks EA territory.                         <T5>
Anil Solanki        7-May-2019      SALESRT-4141        Post 2B Release Fix Added conditions to check Prior Value of End Date to Populate End Date Localized <T6> 
Anil Solanki        24 - June-2019  SALESRT-4252        August Build        Fix Quote Line End Date in correct format for all territories<T7>
Ritika Gupta        9-June-2019     SALESRT-4289        July Build          Fixed End date Localized for LATAM and updated contains to startsWith for checking territory<T8> 
Anil Solanki        16- JUL-2019     QCA-1328           2D Release          Moving logic from Quote Line Process Builder to QuoteLineTrigger.<T09> 
Kiran G            1-Oct-2019      SALESRT-11107       Oct Build            When new Amend Quote is created as part of the Debook , change the Quantity to 0 of QLI 
being inserted .                                                       <T10>
Kiran G            21-Oct-2019    INC0324845            OCT                 Updated the format for LATAM as DD/MM/YYYY instead of  MM/DD/YYYY   <T11>
Sumit Mittal       07-Nov-2019    SalesRT-11147         Nov Build           Added the logic to generate the Dynamic Part Number and Product Name for maintenance products <T12>
Chandana Gowda     08-Jan-2020    SALESRT-11075         Jan Build            Populating Substage instead of stage   <T13>
Vivek Warrier      08-Jan-2020    SALESRT-11353         Liz Matthews        Splitting the territory APJ to AP and JP <T14>
Ambica P           04-Mar-2020    SALESRT-11447         MR                  Bring prior uplift from previous quotelines <T15>           
Kiran G            11-Mar-2020    SALESRT-11766         Bhanu               Initial Start date on QUote line to update when the Start date is updated <T16> 
Kiran G            27-Jul-2020    SALESRT-12202        Rajesh B             Update the Cancel reason and cancellation Detail on the renewal Oppty when debooked <T17>
Kiran G            20-Aug-2020    SALESRT-11245        Liz                  Update the RT of Amend oppty to that of Prior Oppty                                 <T18>    
RamEsh M S         23-SEP-2020     I2C-1060            PSFT Retire          Update Original Quote Line Id with correct value when doing Clone With Related      <T19>
RamEsh M S         23-SEP-2020     I2C-1045            PSFT Retire          Update Start Date on Debook Amend Quote with Original Quote/Contract Start Date     <T20>
Chandana Gowda     05 Nov 2020    SALESRT 12290                             Added the logic to create the unrenewed junction Object on deletion of quote Line   <T21>
Chandana Gowda     05 Nov 2020    SALESRT 12290                             Removed the logic to copy the cancel reason from quote Line to Subscription         <T22>
Anil Solanki       19 Feb 2021    SALESRT-12534        March Build          Populate 'License_Value_Per_Unit__c' field for NNB Quote for Perpetual Products<T25>
Ramya Ravi       19-Feb 2021    SALESRT-12491       March Build       Pre-fill Quote Line's Start Date                          <T26>
Chandana Gowda     24 Feb 2021    TAX-18               Tax Project          Added logic to populate Tax category on Quote Line                                  <T27>
Chandana Gowda     01 Mar 2021    TAX-19               Tax Project          Added logic to upsert the ERP Site records                                          <T28>
Chandana Gowda     22-APR-2021    SALESRT-12736       May Build 21         End Date Localization for Territories FEDOPS Territories                <T12736>
Chandana Gowda     20-May-2021    SALESRT-12038       Jun Build 21         Added null check to fetch quote date only if the start, end date ot term is updated <SALESRT-12038>
Chandana Gowda     02-Jun-2021    SALESRT-13054       Jun Build 21         Removed the logic to update Dynamic Part Number and Dynamic Product Name <T27>
RamEsh M S         05-JUL-2021    SALESRT-13144       JUL Build 21         Updating CPQ Product Type from trigger as twin field is failed sometimes <SALESRT-13144>
Puneet             26-JUL-2021    SALESRT-13045       AUG Build 21         Updating Win/Loss Reason value from Order Debook to Full Debook <SALESRT-13045> 
Chandana Gowda     09-Aug-2021    SALESRT-12622       Aug Build 21         Remove the logic to copy PDS from Product                                <T12622>
Ramya Ravi        25-Aug-2021    SALESRT-12980       Sep Build 21         Auto delete the cancel reason record when same quoteline is added again to the renewal quote <SALESRT-12980>
Chandana Gowda     23 Sep 2021    SALESRT-13270        Oct Build 21      Removing the logic to update End date Localized field <T13270>
Wasim Akram         4-JAN-2022    SALESRT-13411       CPQ Upgrade 22        False update on Quote calculation for Full Debook <T30>
Nishit S           26 Feb 2022    TAX-227            March Build 22    Modify tax category derivation logic in SFDC and Oracle integration to accommodate wrapper SKUs    <TAX-227>
Nishit S           05 Sep 2022    TAX-289            March Build 22    Modify tax category derivation logic for wrapper and standalone support products   <TAX-289>
************************************************************************************************************************************************************
*/
public class QuoteLineTriggerHandler {
    
    public static globalApexManager GAM = new globalApexManager();    
    public static Integer beforeUpdateCount = 0;
    
    /*
* Method Name : handleBeforeInsert
* @param listTriggerNew - List of new SBQQ__QuoteLine__c
* @return return - void
* @throws exception - NA
* @description - Populate End_Date_Localized__c based on the Quote Line's Quote's Territory assignment
*/
    public static void handleBeforeInsert(List<SBQQ__QuoteLine__c> listTriggerNew){
        Set<Id> quoteIdss = new Set<Id>(); //Capture Quote Line associate Quote Id
        Set<Id> productIds = new Set<Id>();//<T1>
        Integer countqle = 0; //Just a count; Monitoring Purposes
        //<T26>
        SetStartDate(listTriggerNew);
        
        /**********************Monitoring Purposes**************************
System.debug('The following are the QLEs: ');
for(SBQQ__QuoteLine__c qle : listTriggerNew){
System.debug(qle.Name + '\n');
}
/*************************************************/
        
        for(SBQQ__QuoteLine__c qle : listTriggerNew){
            
            //Check that the QLE has a Quote
            if(qle.SBQQ__Quote__c != null){
                quoteIdss.add(qle.SBQQ__Quote__c);
                productIds.add(qle.SBQQ__Product__c); //<T1>
                GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeInsert', 'The Quote Line - ' + qle.Name + ' has a Quote');
                countqle++;
            }
        }
        
        //Query for all Quote's captured in quoteIdss //Commenting as part of <T13270>
        //Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Name, Territory__c, SBQQ__SubscriptionTerm__c, SBQQ__EndDate__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id IN :quoteIdss]);
        
        Map<Id, Product2> mapProducts = new Map<Id, Product2>([SELECT Id, Product_Description_Schedule_Text__c,Family,SKU_Sub_Sequence__c, Offering_ID__c,CPQ_Product_Type__c FROM Product2 WHERE Id IN :productIds]); //Map of Id and Product for Reusability //<T1>
        
        for(SBQQ__QuoteLine__c qle : listTriggerNew){  
            Integer thisTerm; //<T3>
            //qle.Product_Description_Schedule__c = mapProducts.get(qle.SBQQ__Product__c).Product_Description_Schedule_Text__c; //<T1> --- Commenting as part of <T12622>
            //<T2>
            qle.DEV_PDS_is_Null__c  = mapProducts.get(qle.SBQQ__Product__c).Product_Description_Schedule_Text__c != null && mapProducts.get(qle.SBQQ__Product__c).Product_Description_Schedule_Text__c.length() > 0 ? false : true;
            //</T2>
            //---------------------------------------------------------------------------<T4>            
            qle.Product_Forecast_Family__c = mapProducts.get(qle.SBQQ__Product__c).Family;
            //---------------------------------------------------------------------------<T4>
            
            //<SALESRT-13144> 
            qle.CPQ_Product_Type__c = mapProducts.get(qle.SBQQ__Product__c).CPQ_Product_Type__c;
            
            /* //Commenting as part of <T13270>
if(qle.SBQQ__Quote__c != null){ //Check that the Quote Line has an associated Quote
if(quoteMap.containsKey(qle.SBQQ__Quote__c)){ //Check that the Quote Map contains the Quote Line's Quote
if(quoteMap.get(qle.SBQQ__Quote__c).Territory__c != null){ //Check that the Quote Line's Quote has an associated Territory
//Assign End Date Localized format based on the Territory Name

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeInsert', 'The Quote Line - ' + qle.Name + ' has a Quote - ' + quoteMap.get(qle.SBQQ__Quote__c).Name + ' with a Territory - ' + quoteMap.get(qle.SBQQ__Quote__c).Territory__c);

String territoryName = quoteMap.get(qle.SBQQ__Quote__c).Territory__c;
//<T3> Checking if the QLE has Subsc Term in the first place
if(qle.SBQQ__SubscriptionTerm__c != null){
thisTerm = Integer.valueOf(qle.SBQQ__SubscriptionTerm__c);
} else{
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c != null){
thisTerm = Integer.valueOf(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c);
}
}//</T3>
/*--------------------------------------------------------------------------<T12736> - added as default else part
//Assign Date Format mm/dd/yyyy
if(territoryName.startsWith('NA')){//<T8> old value - territoryName.contains('LATAM')  <T11> Removed LATAM from here                         
if(qle.SBQQ__EndDate__c != null){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}
}
}                            
GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdat', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}
//--------------------------------------------------------------------------<T12736/>
//Assign Date Format yyyy/mm/dd
if(territoryName.startsWith('AP') || territoryName.startsWith('JP')){ //<T8>  //T14                         
if(qle.SBQQ__EndDate__c != null){ //Take the Quote Line's End Date
//<T7> : For APJ, Date format should be Year/Month/Day
// qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.year() + '/' +qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
//<T7> : For APJ, Date format should be Year/Month/Day
//qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year() + '/'+ quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day();
} else{
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = year + '/' + month + '/' + day; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = year + '/' + month + '/' + day; 
}     
}                                   
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Territory contains APJ. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}

//Assign Date Format dd/mm/yyyy
else if(territoryName.startsWith('EA')  || territoryName.startsWith('EA_S_LAT')){      //<T8>    <T11> Added LATAM here so as to have DD/MM/YYYY                   
if(qle.SBQQ__EndDate__c != null){ //Take the Quote Line's End Date
//<T7> : For APJ, Date format should be Day/Month/Year
//qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
//<T7> : For APJ, Date format should be Day/Month/Year
// qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();

qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
System.debug('Here');
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = day + '/' + month + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = day + '/' + month + '/' + year; 
}
}                                        
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Territory contains EA. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}

else{//--------------------------------------------------------------------------<T12736>
if(qle.SBQQ__EndDate__c != null){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}
}
}                            
GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdat', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);                            
}//--------------------------------------------------------------------------</T12736>
} else{
//If the Quote's Territory is not populated, default End Date Localized to the format for Territory that contains 'NA' - mm/dd/yyyy
if(qle.SBQQ__EndDate__c != null){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{                          
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1);
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}                                   
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeInsert', 'Quotes Territory is blank. Assigning End Date Localized based on NA format - ' + qle.End_Date_Localized__c);
}
}
}------*/
        }
        
        GAM.InsertDebugLogs();
    }
    
    /*<T26>
* Method Name : SetStartDate
* @param listTriggerNew - List of new SBQQ__QuoteLine__c
* @return return - void
* @throws exception - NA
* @description - Populate Start date based on the Quote Line's Renewed subsctiption end date
*/
    public static void SetStartDate(List<SBQQ__QuoteLine__c> listTriggerNew){
        List<id> renewedSubscription  = new  List<id>();
        Map<id,SBQQ__Subscription__c> renewedSubscriptionMap  = new  Map<id,SBQQ__Subscription__c>();
        for(SBQQ__QuoteLine__c li:listTriggerNew)
        {
            if(li.SBQQ__RenewedSubscription__c != null)
            {
                renewedSubscription.add(li.SBQQ__RenewedSubscription__c) ;
            }            
        }
        
        List<SBQQ__Subscription__c> renewedSubscriptionList = [Select id,SBQQ__EndDate__c from SBQQ__Subscription__c where id =:renewedSubscription ];
        
        for(SBQQ__Subscription__c li:renewedSubscriptionList)
        {
            if(li != null)
            {
                renewedSubscriptionMap.put(li.id, li) ;
            }    
        }
        
        for(SBQQ__QuoteLine__c li:listTriggerNew)
        {
            if(li.SBQQ__RenewedSubscription__c != null)
            {
                
                if(renewedSubscriptionMap.containsKey(li.SBQQ__RenewedSubscription__c) != null)
                {
                    SBQQ__Subscription__c subscriptionli = new SBQQ__Subscription__c();
                    subscriptionli = renewedSubscriptionMap.get(li.SBQQ__RenewedSubscription__c);
                    if(li.SBQQ__StartDate__c==null) li.SBQQ__StartDate__c = subscriptionli.SBQQ__EndDate__c + 1;
                }
            }            
        }
        
    }
    
    
    /*
* Method Name : handleBeforeUpdate
* @param mapNew - Map of new SBQQ__QuoteLine__c, mapOld - Map of old SBQQ__QuoteLine__c
* @return return - void
* @throws exception - NA
* @description - Populate End_Date_Localized__c based on updates on the Quote Line records
*/
    public static void handleBeforeUpdate(Map<Id, SBQQ__QuoteLine__c> mapNew, Map<Id, SBQQ__QuoteLine__c> mapOld){

        Set<Id> quoteIdss = new Set<Id>(); //Capture Quote Line associate Quote Id
        Map<Id,Id> mapQLTaxCategoryUpdate = new Map<Id,Id>();
        
        for(SBQQ__QuoteLine__c qle : mapNew.values()){
            //Check that the QLE has a Quote
            /* //Commenting as part of <T13270>
if(qle.SBQQ__Quote__c != null){                
//Check if the End Date, Start Date, or Subscription Term was modified
if(qle.SBQQ__StartDate__c != mapOld.get(qle.Id).SBQQ__StartDate__c || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c || qle.SBQQ__SubscriptionTerm__c != mapOld.get(qle.Id).SBQQ__SubscriptionTerm__c){
quoteIdss.add(qle.SBQQ__Quote__c); //Only capture the Quote Line's Quote if the above fields were modified meaning the End_Date_Localized__c needs to be updated
GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'The Quote Line - ' + qle.Name + ' has a Quote and its StartDate, EndDate, or SubscriptionTerm was modified');
}
}*/
            
            if(qle.SBQQ__UpgradedSubscription__c == null && qle.SBQQ__RenewedSubscription__c == null && qle.Id != qle.Original_Quote_Id__c) //<T19> 
            {
                qle.Original_Quote_Id__c = qle.Id;
            }
            //-----------------------------------------------------------------<T27>
            //Check if Tax Category is blank and RequiredBy is updated on the line
            if(String.isBlank(qle.Tax_Category__c) && qle.SBQQ__RequiredBy__c != null){
                mapQLTaxCategoryUpdate.put(qle.Id,qle.SBQQ__RequiredBy__c);
            }
            //-----------------------------------------------------------------</T27>
            
            //<T25> START : Populating License_Value_Per_Unit__c Field for NNB Quote and Product Family On prem Perpetual
            if((qle.SBQQ__UpgradedSubscription__c == NULL && qle.SBQQ__RenewedSubscription__c == NULL) && qle.SBQQ__ProductFamily__c == 'On-Premise Perpetual' && qle.License_Value_Per_Unit__c != qle.SBQQ__NetPrice__c){
                qle.License_Value_Per_Unit__c = qle.SBQQ__NetPrice__c;                                               
            }
            
            if(qle.SBQQ__StartDate__c != null){            
                if(qle.SBQQ__StartDate__c != mapOld.get(qle.Id).SBQQ__StartDate__c && qle.SBQQ__UpgradedSubscription__c == null && qle.SBQQ__RenewedSubscription__c == null){
                    qle.Initial_Start_Date__c = qle.SBQQ__StartDate__c;
                }            
            }
            if(qle.SBQQ__StartDate__c == null){
                if(qle.SBQQ__Group__r.SBQQ__StartDate__c == null && qle.SBQQ__Quote__r.SBQQ__StartDate__c != null && qle.SBQQ__UpgradedSubscription__c == null && qle.SBQQ__RenewedSubscription__c == null){
                    qle.Initial_Start_Date__c = qle.SBQQ__Quote__r.SBQQ__StartDate__c;
                }
                if(qle.Initial_Start_Date__c == mapOld.get(qle.Id).SBQQ__StartDate__c){
                    qle.Initial_Start_Date__c = qle.SBQQ__Group__r.SBQQ__StartDate__c;
                }
            }            
        }
        
        //-----------------------------------------------------------------<T27>
        if(!mapQLTaxCategoryUpdate.isEmpty())
            updateTaxCategory(mapQLTaxCategoryUpdate,mapNew);
        //-----------------------------------------------------------------</T27>      
        GAM.InsertDebugLogs();
        //-------------------------------------------<T16>-------------------------------------------------------------
        //Query for all Quote's captured in quoteIdss
        /*//Commenting as part of <T13270>
Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();
if(!quoteIdss.isEmpty()){ //<SALESRT-12038>-----------Added null check
quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT Id, Name, Territory__c, SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, SBQQ__EndDate__c
FROM SBQQ__Quote__c WHERE Id IN :quoteIdss]);

for(SBQQ__QuoteLine__c qle : mapNew.values()){
Integer thisTerm; //<T3>

if(qle.SBQQ__Quote__c != null){ //Check that the Quote Line has a Quote
if(quoteMap.containsKey(qle.SBQQ__Quote__c)){ //Check that the Quote Map contains the Quoe Line's Quote
if(quoteMap.get(qle.SBQQ__Quote__c).Territory__c != null){ //Check that the Quote Line's Quote has an associated Territory
//Assign End Date Localized format based on the Territory Name
String territoryName = quoteMap.get(qle.SBQQ__Quote__c).Territory__c;
//<T3> Checking if the QLE has Subsc Term in the first place
if(qle.SBQQ__SubscriptionTerm__c != null){
thisTerm = Integer.valueOf(qle.SBQQ__SubscriptionTerm__c);
} else{
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c != null){
thisTerm = Integer.valueOf(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__SubscriptionTerm__c);
}
}//</T3>

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'The Quote Line - ' + qle.Name + ' has a Quote - ' + quoteMap.get(qle.SBQQ__Quote__c).Name + ' with a Territory - ' + quoteMap.get(qle.SBQQ__Quote__c).Territory__c);
/*--------------------------------------------------------------------------<T12736> - added as default else part
//Assign Date Format mm/dd/yyyy
if(territoryName.startsWith('NA') ){ //<T8> old value - territoryName.contains('LATAM') <T11> Removed LATAM from here 
//<T6> : Added OR condition to check Prior value of End Date
if(qle.SBQQ__EndDate__c != null || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{                                     
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}
}
}                            
GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdat', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}
//--------------------------------------------------------------------------<T12736/>
//Assign Date Format yyyy/mm/dd
if(territoryName.startsWith('AP') || territoryName.startsWith('JP')){ //<T8> <T14>
//<T6> : Added OR condition to check Prior value of End Date.
if(qle.SBQQ__EndDate__c != null || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c){ //Take the Quote Line's End Date
//<T7> For APJ, format should be Year/Month/Day
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.year() + '/' + qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
//<T7> For APJ, format should be Year/Month/Day
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day();
} else{                                     
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = year + '/' + month + '/' + day; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = year + '/' + month + '/' + day; 
}
}
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Territory contains APJ. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}

//Assign Date Format dd/mm/yyyy
else if(territoryName.startsWith('EA') || territoryName.startsWith('EA_S_LAT')){    //<T8>      <T11> Added LATAM here so as to have DD/MM/YYYY                  
//<T6> : Added OR condition to check Prior value of End Date
if(qle.SBQQ__EndDate__c != null || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c){ //Take the Quote Line's End Date
//<T7> For APJ, format should be Day/Month/Year
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
//<T7> For APJ, format should be Day/Month/Year
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{                                     
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = day + '/' + month + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = day + '/' + month + '/' + year; 
}
}
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Territory contains EA. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}

else{//--------------------------------------------------------------------------<T12736>
if(qle.SBQQ__EndDate__c != null || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{                                     
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}
}
}                            
GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdat', 'Territory contains NA or LATAM. Assigning End Date Localized - ' + qle.End_Date_Localized__c);
}//--------------------------------------------------------------------------<T12736/>
} else{
//If the Quote's Territory is not populated, default End Date Localized to the format for Territory that contains 'NA' - mm/dd/yyyy                        
//<T6> : Added OR condition to check Prior value of End Date
if(qle.SBQQ__EndDate__c != null || qle.SBQQ__EndDate__c != mapOld.get(qle.Id).SBQQ__EndDate__c){ //Take the Quote Line's End Date
qle.End_Date_Localized__c = qle.End_Date_Output_QL__c.month() + '/' + qle.End_Date_Output_QL__c.day() + '/' + qle.End_Date_Output_QL__c.year();
} else{ //Take the Quote's End Date
if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c != null){
qle.End_Date_Localized__c = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.month() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.day() + '/' + quoteMap.get(qle.SBQQ__Quote__c).SBQQ__EndDate__c.year();
} else{                                 
if(thisTerm != null){
if(qle.SBQQ__StartDate__c != null){
Date temp = qle.SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
} else if(quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c != null){
Date temp = quoteMap.get(qle.SBQQ__Quote__c).SBQQ__StartDate__c.addMonths(thisTerm).addDays(-1); //<T3> thisTerm
Integer day = temp.day();
Integer month = temp.month();
Integer year = temp.year();
qle.End_Date_Localized__c = month + '/' + day + '/' + year; 
}
}
}
}

GAM.CreateLogs('QuoteLineTriggerHandler.handleBeforeUpdate', 'Quotes Territory is blank. Assigning End Date Localized based on NA format - ' + qle.End_Date_Localized__c);
}
}
}
} 
} ----------*/
    }
    /*-----------------------------------------------------------------<T27>
    * Method Name : updateTaxCategory
    * @param mapNew : mapQLTaxCategoryUpdate-Map of QuoteLine Ids(SupportProduct => ParentProduct),mapNew - Map of new SBQQ__QuoteLine__c
    * @return return : void
    * @throws exception : NA
    * @description : To update the tax category on Support products only, Added the logic in beforeupdate as RequiredBy is not populated on insert    
    */    
    public static void updateTaxCategory(Map<Id,Id> mapQLTaxCategoryUpdate,Map<Id,SBQQ__QuoteLine__c> mapNew){
        Set<Id> qleIds = new Set<Id>();
        qleIds.addAll(mapQLTaxCategoryUpdate.keySet());
        qleIds.addAll(mapQLTaxCategoryUpdate.values());
        
        Map<Id,SBQQ__QuoteLine__c> mapQuoteLine = new Map<Id,SBQQ__QuoteLine__c>([Select Id,Initial_Start_Date__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__RequiredBy__c,Tax_Category__c,
                                                                                  SBQQ__Product__c,SBQQ__Product__r.Forecast_Product__c,SBQQ__Product__r.Pricing_Business_Model__c,SBQQ__Product__r.Delivery_Method__c,SBQQ__Product__r.Edition__c,SBQQ__Product__r.Tax_Classification__c, SBQQ__Product__r.Product_Category__c 
                                                                                  from SBQQ__QuoteLine__c
                                                                                  where id IN: qleIds]);
        
        
        for(Id qlineId:mapQLTaxCategoryUpdate.keySet()){                       
            SBQQ__QuoteLine__c qle = mapQuoteLine.get(qlineId);
            SBQQ__QuoteLine__c parentLine = mapQuoteLine.get(mapQLTaxCategoryUpdate.get(qlineId));
            
            
            if((qle.SBQQ__Product__r.Forecast_Product__c == 'Support' || qle.SBQQ__Product__r.Forecast_Product__c == 'Subscription Support') && !String.valueOf(qle.SBQQ__Product__r.Edition__c).endsWithIgnoreCase('Pack') && !String.valueOf(qle.SBQQ__Product__r.Edition__c).startsWithIgnoreCase('Extended') && !String.valueOf(qle.SBQQ__Product__r.Edition__c).equalsIgnoreCase('VAS')){
                //<TAX-227> If the parent is a Wrapper, copy tax category from parent
                if(parentLine != null){
                    //<TAX-289> : Added additional condition for Wrapper SKUs
                    if(parentLine.SBQQ__Product__r.Product_Category__c == 'Wrapper' && String.isBlank(parentLine.SBQQ__Product__r.Pricing_Business_Model__c) && (String.isBlank(parentLine.SBQQ__Product__r.Delivery_Method__c) || parentLine.SBQQ__Product__r.Delivery_Method__c == 'NA')){
                        if(!String.isBlank(parentLine.Tax_Category__c)){
                            if(parentLine.Tax_Category__c == 'C'){
                                mapNew.get(qlineId).Tax_Category__c = 'C';
                            }else if(parentLine.Tax_Category__c == 'L'){
                                mapNew.get(qlineId).Tax_Category__c = 'M';
                            }else{
                                if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                                    mapNew.get(qlineId).Tax_Category__c = 'C'; //TAX-363 Update defaulting from L to C
                                }
                                else{
                                    mapNew.get(qlineId).Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                                }
                            }
                        }else{
                            if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                                mapNew.get(qlineId).Tax_Category__c = 'C'; //TAX-363 Updating from L to C
                            }
                            else{
                                mapNew.get(qlineId).Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                            }
                        }
                    }
                    else if(parentLine.SBQQ__Product__r.Delivery_Method__c == 'Hosted Multi Tenant' || parentLine.SBQQ__Product__r.Delivery_Method__c == 'Hosted Single Tenant' ||parentLine.SBQQ__Product__r.Delivery_Method__c == 'Hosted Other'){
                        mapNew.get(qlineId).Tax_Category__c = 'C';
                    }
                    else if(parentLine.SBQQ__Product__r.Delivery_Method__c == 'On Premise' && (parentLine.SBQQ__Product__r.Pricing_Business_Model__c == 'Fixed Term' || parentLine.SBQQ__Product__r.Pricing_Business_Model__c == 'Subscription')){
                        mapNew.get(qlineId).Tax_Category__c = 'M';
                    }
                    else if(parentLine.SBQQ__Product__r.Delivery_Method__c == 'On Premise' && parentLine.SBQQ__Product__r.Pricing_Business_Model__c == 'Perpetual'){
                        if(qle.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' || (qle.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' && qle.Initial_Start_Date__c < System.Today().addDays(-365))){
                            mapNew.get(qlineId).Tax_Category__c = 'R';
                        }else{
                            mapNew.get(qlineId).Tax_Category__c = 'M';
                        }
                    }else{
                        if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                            mapNew.get(qlineId).Tax_Category__c = 'C'; //TAX-363 Update defaulting from L to C
                        }
                        else{
                            mapNew.get(qlineId).Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                        }
                    } 
                }else{
                    if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                        mapNew.get(qlineId).Tax_Category__c = 'C'; //TAX-363 Update defaulting from L to C
                    }
                    else{
                        mapNew.get(qlineId).Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                    }
                }                
            }            
        }
    }
    //-----------------------------------------------------------------</T27>
    
    /*------------------------------------------------------------------------------------------------------<T28>
* Method Name : handleBeforeDelete
* @param mapNew : mapQuoteIdTaxExemptionNumber-Map of quote to Tax Exemption Number,mapQuoteIdTaxAmount-Map of quote to Amount,quoteMap-Quote Map
* @return return : void
* @throws exception : NA
* @description : To upsert the ERP Site record based on Sold to Address
*/
    public static void upsertErpSiteRecords(Map<Id, String> mapQuoteIdTaxExemptionNumber,Map<Id,Decimal> mapQuoteIdTaxAmount,Map<Id,SBQQ__Quote__c> quoteMap){
        
        Map<Id,Id> mapQuoteErpCompany = new Map<Id,Id>();
        Map<Id,List<ERP_Site__c>> mapErpCompanyErpSite = new Map<Id,List<ERP_Site__c>>();
        List<ERP_Site__c> lstErpSiteUpsert = new List<ERP_Site__c>();
        Map<Id,Id> mapQuoteNewErpSiteToUpdate = new Map<Id,Id>();
        List<SBQQ__Quote__c> lstQuoteToUpdate = new List<SBQQ__Quote__c>();
        
        //Createing a map of Quote,SoldtoAccount.ERPCompany 
        for(Id quoteId:mapQuoteIdTaxExemptionNumber.keySet()){
            if(quoteMap.get(quoteId).SoldToAccount__r.ERP_Company__c != null){
                mapQuoteErpCompany.put(quoteId,quoteMap.get(quoteId).SoldToAccount__r.ERP_Company__c);
                mapErpCompanyErpSite.put(quoteMap.get(quoteId).SoldToAccount__r.ERP_Company__c,new List<ERP_Site__c>());
            }
        }
        
        if(!mapQuoteErpCompany.isEmpty()){ //If the Sold to Account has ERP Company associatied to it
            
            Map<Id,ERP_Site__c> erpSiteMap = new Map<Id,ERP_Site__c>([SELECT Id,ERP_Company__c,Exempt_Status__c,Exemption_Expiry_Date__c,Exemption_On_File__c,State_Province__c,Country__c FROM ERP_Site__c WHERE ERP_Company__c IN :mapQuoteErpCompany.values()]);            
            
            //A map of ERPCompany and list of ERP Site Associated with it
            if(!erpSiteMap.isEmpty()){
                for(ERP_Site__c erpSite:erpSiteMap.values()){
                    List<ERP_Site__c> lstErpSite = mapErpCompanyErpSite.get(erpSite.ERP_Company__c);
                    lstErpSite.add(erpSite);
                    mapErpCompanyErpSite.put(erpSite.ERP_Company__c,lstErpSite);
                }
            }
            
            for(Id quoteId:mapQuoteIdTaxExemptionNumber.keySet()){ //Iterating throught the quotes from which the one source call was made
                List<ERP_Site__c> lstErpSite = mapErpCompanyErpSite.get(mapQuoteErpCompany.get(quoteId)); //Getting all the ERP Site associated with the SoldtoAccount.ERPCompany
                Boolean erpSitePresent = false;
                SBQQ__Quote__c quoteRec = quoteMap.get(quoteId);
                
                //Updating existing ERP Site Record
                if(!lstErpSite.isEmpty()){
                    for(ERP_Site__c erpSite:lstErpSite){
                        if(quoteRec.SBQQ__ShippingCountry__c == erpSite.Country__c && quoteRec.SBQQ__ShippingState__c == erpSite.State_Province__c){ //If quote's Shipto country and state match with the sites state and country 
                            erpSitePresent = true;
                            ERP_Site__c erpSiteRec = new ERP_Site__c(Id = erpSite.Id);
                            erpSiteRec.Dev_Quote_Id__c = quoteId; //populating the current Quote Id to refence in chatter notification
                            
                            if(mapQuoteIdTaxExemptionNumber.get(quoteId) != null){ //If exemption Number is not null, then set as Exempt
                                if(erpSite.Exemption_Expiry_Date__c < System.Today() || erpSite.Exempt_Status__c == 'Exempt'){ 
                                    if(quoteRec.SBQQ__StartDate__c < System.Today()){
                                        erpSiteRec.Exemption_Expiry_Date__c = System.Today();
                                    }else{ 
                                        erpSiteRec.Exemption_Expiry_Date__c = quoteRec.SBQQ__StartDate__c; //set the expiry date only if the existing date is in the past
                                    }
                                }                                    
                                erpSiteRec.Exempt_Status__c = 'Exempt';
                                erpSiteRec.Exemption_On_File__c = true;
                            }else{
                                if(mapQuoteIdTaxAmount.get(quoteId) == null || mapQuoteIdTaxAmount.get(quoteId) == 0){ //If the Tax amount is 0 and the Exempt Number is null set status as not applicable
                                    erpSiteRec.Exempt_Status__c = 'Not Applicable';
                                    erpSiteRec.Exemption_On_File__c = false;
                                }else if(erpSite.Exemption_Expiry_Date__c < System.Today() || (erpSite.Exemption_Expiry_Date__c >= System.Today() && (erpSite.Exempt_Status__c != 'Exempt' && erpSite.Exempt_Status__c != 'Not Exempt'))){
                                    erpSiteRec.Exempt_Status__c = 'Needs Validation';
                                    erpSiteRec.Exemption_On_File__c = false;
                                }
                            }                            
                            lstErpSiteUpsert.add(erpSiteRec);
                            lstQuoteToUpdate.add(new SBQQ__Quote__c(Id = quoteId,Sold_to_Account_ERP_Site__c = erpSite.Id));
                            break;
                        }            
                    }
                }
                //If not matching country,state combination found, Creating a new ERP Site Record
                if(!erpSitePresent){
                    ERP_Site__c erpSiteRec = new ERP_Site__c();
                    erpSiteRec.State_Province__c = quoteRec.SBQQ__ShippingState__c;
                    erpSiteRec.Country__c = quoteRec.SBQQ__ShippingCountry__c;
                    erpSiteRec.City__c = quoteRec.SBQQ__ShippingCity__c;
                    erpSiteRec.Address_Line_1__c = quoteRec.SBQQ__ShippingStreet__c;
                    erpSiteRec.ZIP_Code__c = quoteRec.SBQQ__ShippingPostalCode__c;
                    erpSiteRec.Name = quoteRec.SBQQ__ShippingCountry__c+'_'+quoteRec.SBQQ__ShippingState__c; //populating ERP Site Name as Country_State/Province
                    erpSiteRec.ERP_Company__c = quoteRec.SoldToAccount__r.ERP_Company__c;
                    if(quoteRec.SBQQ__StartDate__c < System.Today()){
                        erpSiteRec.Exemption_Expiry_Date__c = System.Today();
                    }else{ 
                        erpSiteRec.Exemption_Expiry_Date__c = quoteRec.SBQQ__StartDate__c; //set the expiry date only if the existing date is in the past
                    }
                    erpSiteRec.Dev_Quote_Id__c = quoteId;
                    //Setting Exempt Status
                    if(mapQuoteIdTaxExemptionNumber.get(quoteId) != null){
                        erpSiteRec.Exempt_Status__c = 'Exempt';
                        erpSiteRec.Exemption_On_File__c = true;
                    }else{
                        if(mapQuoteIdTaxAmount.get(quoteId) == null || mapQuoteIdTaxAmount.get(quoteId) == 0){
                            erpSiteRec.Exempt_Status__c = 'Not Applicable';
                        }else{
                            erpSiteRec.Exempt_Status__c = 'Needs Validation';
                        }
                        erpSiteRec.Exemption_On_File__c = false;
                    }
                    lstErpSiteUpsert.add(erpSiteRec);
                    mapQuoteNewErpSiteToUpdate.put(quoteId,quoteRec.SoldToAccount__r.ERP_Company__c);
                }
            }
            
            //Upserting the list of ERP Sites
            if(!lstErpSiteUpsert.isEmpty()){
                try{
                    upsert lstErpSiteUpsert;
                }        
                catch(DmlException e){
                    GAM.CreateExceptionRecords('QuoteTriggerHandler.upsertErpSiteRecords', 'Error while upserting the ERP Site records: ', e.getMessage());
                }
            }
            
            //Quotes for which new site is created
            if(!mapQuoteNewErpSiteToUpdate.isEmpty()){
                Map<Id,ERP_Site__c> newErpSiteMap = new Map<Id,ERP_Site__c>([SELECT Id,ERP_Company__c,Exempt_Status__c,Exemption_Expiry_Date__c,Exemption_On_File__c,State_Province__c,Country__c FROM ERP_Site__c WHERE ERP_Company__c IN :mapQuoteNewErpSiteToUpdate.values()]);
                for(Id quoteId:mapQuoteNewErpSiteToUpdate.keySet()){
                    SBQQ__Quote__c quoteRec = quoteMap.get(quoteId);
                    for(ERP_Site__c erpSite:newErpSiteMap.values()){
                        if(quoteRec.SBQQ__ShippingCountry__c == erpSite.Country__c && quoteRec.SBQQ__ShippingState__c == erpSite.State_Province__c && quoteRec.SoldToAccount__r.ERP_Company__c == erpSite.ERP_Company__c){
                            lstQuoteToUpdate.add(new SBQQ__Quote__c(Id = quoteId,Sold_to_Account_ERP_Site__c = erpSite.Id));
                        }
                    }
                }
            }
            
            //Muting CPQ Triggers and updating the Quote, updating with ErpSiteId and OneSourceLastCallTime
            if(!lstQuoteToUpdate.isEmpty()){
                SBQQ.TriggerControl.disable();
                try{
                    update lstQuoteToUpdate;
                }        
                catch(DmlException e){
                    GAM.CreateExceptionRecords('QuoteTriggerHandler.upsertErpSiteRecords', 'Error while updating the quote records: ', e.getMessage());
                }
                SBQQ.TriggerControl.enable();
            }
        }        
    }
    //----------------------------------------------------------------------------------------------------------</T28> 
    /*
* Method Name : handleBeforeDelete
* @param mapNew - mapOld - Map of old SBQQ__QuoteLine__c
* @return return - void
* @throws exception - NA
* @description - To create the Unrenewed Object records on Quote Line deletion
*/
    //-------------------------------------------------------------------------------------------------------<T21>
    public static void handleBeforeDelete(Map<Id, SBQQ__QuoteLine__c> mapOld){
        Map<Id,SBQQ__QuoteLine__c> quoteLinesWithSub = new Map<Id,SBQQ__QuoteLine__c>();
        List<Unrenewed__c> lstUnrenewedToInsert = new List<Unrenewed__c>();
        
        //Creating a map of Quote Lines, which have renewed Subscription
        for(SBQQ__QuoteLine__c quoteLineRec: mapOld.values()){
            if(quoteLineRec.SBQQ__RenewedSubscription__c != null){
                quoteLinesWithSub.put(quoteLineRec.Id,quoteLineRec);
            }
        }
        //Creating unrenewed records to insert
        if(!quoteLinesWithSub.isEmpty()){
            for(SBQQ__QuoteLine__c quoteLine : quoteLinesWithSub.values()){
                Unrenewed__c unrenewedRec = new Unrenewed__c();
                unrenewedRec.Subscription__c = quoteLine.SBQQ__RenewedSubscription__c;
                unrenewedRec.Product__c = quoteLine.SBQQ__Product__c;
                unrenewedRec.Quantity__c = quoteLine.SBQQ__Quantity__c;
                unrenewedRec.Net_Total__c = quoteLine.SBQQ__NetTotal__c;
                unrenewedRec.Quote__c = quoteLine.SBQQ__Quote__c;
                unrenewedRec.Name = quoteLine.Name; //Storing the Unrenewed Name as QuoteLine number, acts as a unique identifier
                
                //Set Is Parent to true only for Parent Products
                if(quoteLine.SBQQ__RequiredBy__c == null)
                    unrenewedRec.Is_Parent__c = true;
                //If child Product then Populating the Parent Product Name on unrenewed record
                else if(quoteLinesWithSub.keySet().contains(quoteLine.SBQQ__RequiredBy__c)){
                    SBQQ__QuoteLine__c parentLine = quoteLinesWithSub.get(quoteLine.SBQQ__RequiredBy__c);
                    while(parentLine.SBQQ__RequiredBy__c != null && quoteLinesWithSub.keySet().contains(parentLine.SBQQ__RequiredBy__c)){
                        parentLine = quoteLinesWithSub.get(parentLine.SBQQ__RequiredBy__c);
                    }
                    unrenewedRec.Parent_Product_Name__c = parentLine.Name;
                }
                lstUnrenewedToInsert.add(unrenewedRec);
            }
        }
        //Inserting Unrenewed records
        if(!lstUnrenewedToInsert.isEmpty()){
            try{
                Database.SaveResult[] insertResult = Database.insert(lstUnrenewedToInsert, false);
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.handleBeforeDelete', 'Error while creating the unrenewed: ', e.getMessage());
            }
        }
    }
    //-------------------------------------------------------------------------------------------------------</T21>     
    
    //<T09>
    /*
* Method Name : handleAfterInsert
* @param listTriggerNew - Map<Id, SBQQ__QuoteLine__c>
* @return return - void
* @throws exception - NA
* @description - handles operation on after insert of quote Line. Moved logic from QuoteLine Process Builder to Trigger
*/
    public static void handleAfterInsert(Map<Id,SBQQ__QuoteLine__c> mapNew, Map<Id, SBQQ__QuoteLine__c> mapOld){
        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesWithSubToCheck = new List<SBQQ__QuoteLine__c>(); //<SALESRT-12980>
        Set<Id> qleIds = new Set<Id>();
        for(SBQQ__QuoteLine__c qle : mapNew.values()){
            qleIds.add(qle.id);
        }
        
        //<T25> Added License_Value_Per_Unit__c, Product.Family, Net Price,Transaction Type Field  in the Query
        for(SBQQ__QuoteLine__c qle :  [Select Id,CPQ_Product_Type__c, Line_Level_uplift__c,Initial_Start_Date__c, Original_Quote_Id__c ,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__RenewedSubscription__c ,
                                       SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.Line_Level_uplift__c,
                                       SBQQ__UpgradedSubscription__c,SBQQ__Quantity__c,SBQQ__EffectiveStartDate__c, Forecast_Family__c, 
                                       SBQQ__RequiredBy__r.Offering_ID__c, SBQQ__Product__r.SKU_Sub_Sequence__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__ProductName__c,SBQQ__RequiredBy__c,
                                       SBQQ__Quote__r.SBQQ__Source__c,License_Value_Per_Unit__c,SBQQ__NetPrice__c,SBQQ__Product__r.Family,
                                       SBQQ__Product__c,SBQQ__Product__r.Forecast_Product__c,SBQQ__Product__r.Pricing_Business_Model__c,SBQQ__Product__r.Delivery_Method__c,SBQQ__Product__r.Edition__c,
                                       Transaction_Type__c,SBQQ__Product__r.Tax_Classification__c,SBQQ__Product__r.CPQ_Product_Type__c,SBQQ__Product__r.Product_Category__c,
                                       SBQQ__RequiredBy__r.SBQQ__Product__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Forecast_Product__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Pricing_Business_Model__c,
                                       SBQQ__RequiredBy__r.SBQQ__Product__r.Delivery_Method__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Edition__c,SBQQ__RequiredBy__r.Transaction_Type__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Tax_Classification__c,
                                       SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Category__c, SBQQ__RequiredBy__r.Tax_Category__c //<TAX-227> 
                                       from SBQQ__QuoteLine__c
                                       where id IN: qleIds ]){
                                           
                                           //system.debug('***qle'+qle);
                                           //system.debug('***qle.SOURCE'+qle.SBQQ__Quote__r.SBQQ__Source__c);
                                           //Boolean setUpdateQuoteLine = False;
                                           SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(Id = qle.id); 
                                           
                                           //<SALESRT-12980>
                                           if(qle.SBQQ__RenewedSubscription__c != null){
                                               quoteLinesWithSubToCheck.add(qle);
                                           }//<SALESRT-12980>
                                           
                                           //<SALESRT-13144> 
                                           if(qle.CPQ_Product_Type__c == null)
                                           {
                                               quoteLine.CPQ_Product_Type__c = qle.SBQQ__Product__r.CPQ_Product_Type__c;
                                               
                                           } //<SALESRT-13144> 
                                           
                                           //Moving PB logic to trigger.Setting Perpetual Prior Quantity
                                           if(qle.CPQ_Product_Type__c == 'Perpetual' && qle.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' && qle.SBQQ__RenewedSubscription__c != null){
                                               quoteLine.Perpetual_Prior_Quantity__c = qle.SBQQ__Quantity__c;
                                               //quoteLineToUpdate.add(quoteLine);
                                               //setUpdateQuoteLine = True; //<T27> Removing this check as Tax category will have to be populated for all the lines
                                           }
                                           
                                           //<T25> START : Populating License_Value_Per_Unit__c Field for NNB Quote and Product Family On prem Perpetual
                                           if((qle.SBQQ__UpgradedSubscription__c == NULL && qle.SBQQ__RenewedSubscription__c == NULL) && qle.SBQQ__Product__r.Family == 'On-Premise Perpetual' && qle.License_Value_Per_Unit__c == null){
                                               quoteLine.License_Value_Per_Unit__c = qle.SBQQ__NetPrice__c;
                                               //setUpdateQuoteLine = True; 
                                           }
                                           
                                           //Set Initial Start Date and Original quotelineId
                                           
                                           if(qle.Original_Quote_Id__c == null ){
                                               quoteLine.Original_Quote_Id__c = qle.Id;
                                               //setUpdateQuoteLine = True;
                                               
                                           }
                                           
                                           
                                           if(qle.Initial_Start_Date__c == null){
                                               quoteLine.Initial_Start_Date__c = qle.SBQQ__EffectiveStartDate__c;
                                               //setUpdateQuoteLine = True;
                                           }
                                           
                                           //<T12>
                                           /*---------------------------------<T27>
if(qle.SBQQ__RequiredBy__r.Offering_ID__c != Null && qle.SBQQ__Product__r.SKU_Sub_Sequence__c != Null && qle.Forecast_Family__c == 'Perpetual Support') {
quoteLine.Dynamic_Part_Number__c = qle.SBQQ__RequiredBy__r.Offering_ID__c.Left(10)+'-'+qle.SBQQ__Product__r.SKU_Sub_Sequence__c;
quoteLine.Dynamic_Product_Name__c = qle.SBQQ__RequiredBy__r.SBQQ__ProductName__c.removeEndIgnoreCase('License')+' '+qle.SBQQ__ProductName__c;
//setUpdateQuoteLine = True;
}//---------------------------------<T27>*/
                                           //---------------------------------------<T15>
                                           //Copy upplift from prior contract
                                           if(qle.SBQQ__RenewedSubscription__c != null && qle.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c!=null && qle.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.Line_Level_uplift__c!=null){
                                               quoteLine.Prior_Uplift__c = qle.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__r.Line_Level_uplift__c;
                                               //setUpdateQuoteLine = True;
                                           }
                                           //---------------------------------------</T15>
                                           //----------------------------------------------------------------------------------------------------------------<T27>
                                           //To populate the Tax Category
                                           //If the Product is Genereic Support SKU
                                           
                                           //<TAX-227> If the parent is a Wrapper, copy tax category from parent
                                           if(!((qle.SBQQ__Product__r.Forecast_Product__c == 'Support' || qle.SBQQ__Product__r.Forecast_Product__c == 'Subscription Support') 
                                           && !String.valueOf(qle.SBQQ__Product__r.Edition__c).endsWithIgnoreCase('Pack')
                                           && !String.valueOf(qle.SBQQ__Product__r.Edition__c).startsWithIgnoreCase('Extended')
                                           && !String.valueOf(qle.SBQQ__Product__r.Edition__c).equalsIgnoreCase('VAS'))){
                                               
                                               if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                                                   quoteLine.Tax_Category__c = 'C'; //TAX-363 Update defaulting from L to C
                                               }else{
                                                   quoteLine.Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                                               }
                               
                                           }else if(qle.SBQQ__Product__r.Product_Category__c == 'Parent'){ //<TAX-289> : Added to populates tax category for standalone support products
                                               
                                                if(String.isBlank(qle.SBQQ__Product__r.Tax_Classification__c)){
                                                    quoteLine.Tax_Category__c = 'C'; //TAX-363 Update defaulting from L to C
                                                }else{
                                                    quoteLine.Tax_Category__c = qle.SBQQ__Product__r.Tax_Classification__c;
                                                }
                                           }
                                           //---------------------------------------------------------------------------------------------------------------</T27>                                            
                                           
                                           //if(setUpdateQuoteLine) {
                                           quoteLineToUpdate.add(quoteLine);
                                           //}
                                       }
        
        try{
            if(quoteLineToUpdate.size() > 0){
                Database.SaveResult[] srList = Database.update(quoteLineToUpdate, false);
            }
        }
        catch(DmlException e){
            GAM.CreateExceptionRecords('QuoteLineTriggerHandler.handleAfterInsert', 'Error while updating Quote Lines: ', e.getMessage());
        }
        processAmendQuoteForDebookedOrder(qleIds);
        autoDeleteCancelReason(quoteLinesWithSubToCheck); // <SALESRT-12980>
    }
    
    //<T09>
    /*
* Method Name : handleAfterUpdate
* @param listTriggerNew - Map<Id, SBQQ__QuoteLine__c>
* @return return - void
* @throws exception - NA
* @description - handles operation on after update of quote Line. Moved logic from QuoteLine Process Builder to Trigger
*/
    
    public static void handleAfterUpdate(Map<Id,SBQQ__QuoteLine__c> mapNew, Map<Id, SBQQ__QuoteLine__c> mapOld){
        //-------------------------------------------------------------------------------------------------------<T22>        
        /*    List<SBQQ__Subscription__c> subscriptionLineToUpdate = new List<SBQQ__Subscription__c>();
List<SBQQ__QuoteLine__c > lstChildQLIToUpdate = new List<SBQQ__QuoteLine__c >();

Set<Id> qleIds = new Set<Id>();
for(SBQQ__QuoteLine__c qle : mapNew.values()){
qleIds.add(qle.id);
}

for(SBQQ__QuoteLine__c qle : [Select Id,Cancel_Reason__c,SBQQ__RenewedSubscription__c,SBQQ__Quote__r.SBQQ__Primary__c,SBQQ__RenewedSubscription__r.id ,
Initial_Start_Date__c,SBQQ__EffectiveStartDate__c,SBQQ__UpgradedSubscription__c
from SBQQ__QuoteLine__c where Id IN: qleIds]){            

if(qle.Cancel_Reason__c != mapOld.get(qle.Id).Cancel_Reason__c && qle.SBQQ__RenewedSubscription__c != null && qle.SBQQ__Quote__r.SBQQ__Primary__c == TRUE ){
SBQQ__Subscription__c subscriptionLine = new SBQQ__Subscription__c(Id = qle.SBQQ__RenewedSubscription__r.id);
subscriptionLine.Cancel_Reason__c = qle.Cancel_Reason__c;
subscriptionLineToUpdate.add(subscriptionLine);
}         
}   
try{
if(subscriptionLineToUpdate.size() > 0 ){
Database.SaveResult[] srList = Database.update(subscriptionLineToUpdate, false);
system.debug('srList::::::'+srList);
}            
}
catch(DmlException e){
GAM.CreateExceptionRecords('QuoteLineTriggerHandler.handleAfterUpdate', 'Error while updating Quote Lines: ', e.getMessage());
}  */ 
        //-------------------------------------------------------------------------------------------------------</T22>     
    }
    /* Method called when the Order is Debooked and the Amend Quote is created . 
This updates the Quote Lines Quantity to 0 and updates the Start and End Date as on Subscription Lines. */
    
    //--------------------------------------------------------------------T10------------------------------------------------------------------------------
    public static void processAmendQuoteForDebookedOrder(Set<Id> qleIds){
        Set<Id> setOfAmendQuoteDebooked = new Set<Id>();
        Set<Id> setOfAmendQuote = new Set<Id>();
        List<SBQQ__Quote__c> lstAmendQuote = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> lstQLIOfDebookAmendQuotes = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lstUpdateQLI = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> lstQuotesToUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> lstUpdateQuoteStatus = new List<SBQQ__Quote__c>(); 
        Set<Id> setOpptyId = new Set<Id>();
        Set<Id> setOfOrdersId = new Set<Id>();
        List<Opportunity> lstOpptyToClosedWon = new List<Opportunity>();
        List<Contract> lstContractsRenewalOppty = new List<Contract>();
        List<Opportunity> lstUpdateOpptyToClosedWon = new List<Opportunity>();
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        lstQuoteLines = [Select Id,CPQ_Product_Type__c, Initial_Start_Date__c, Original_Quote_Id__c     ,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__RenewedSubscription__c ,
                         SBQQ__UpgradedSubscription__c,SBQQ__Quantity__c,SBQQ__EffectiveStartDate__c 
                         FROM SBQQ__QuoteLine__c
                         WHERE id IN: qleIds ];
        //Get all the Amend Quotes 
        for(SBQQ__QuoteLine__c amendQuote : lstQuoteLines){
            if(amendQuote.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
                setOfAmendQuote.add(amendQuote.SBQQ__Quote__c);
            }
        }
        
        lstAmendQuote = [SELECT Id,Name,SBQQ__MasterContract__c,SBQQ__MasterContract__r.SBQQ__Order__r.Sub_Type__c ,Order_Number__c,
                         SBQQ__Opportunity2__c,SBQQ__Ordered__c,SBQQ__Status__c,SBQQ__Type__c,SBQQ__MasterContract__r.SBQQ__Order__c,SBQQ__MasterContract__r.StartDate
                         FROM SBQQ__Quote__c
                         WHERE Id =: setOfAmendQuote];
        //Get the Amend Quotes where the Order Associated are Debooked.         
        for(SBQQ__Quote__c amendQuotes : lstAmendQuote){
            if(amendQuotes.SBQQ__MasterContract__c != Null && amendQuotes.SBQQ__MasterContract__r.SBQQ__Order__r.Sub_Type__c == 'Full Debook'){
                setOfAmendQuoteDebooked.add(amendQuotes.Id);
                lstQuotesToUpdate.add(amendQuotes);
                setOpptyId.add(amendQuotes.SBQQ__Opportunity2__c);
                setOfOrdersId.add(amendQuotes.SBQQ__MasterContract__r.SBQQ__Order__c);
            }
        }
        //Get all the Quote Lines of the Debooked Amend QUotes to update hte Quantity to 0 
        lstQLIOfDebookAmendQuotes = [SELECT Id,Name,SBQQ__EffectiveEndDate__c,SBQQ__EffectiveStartDate__c,SBQQ__OriginalQuoteLineId__c,SBQQ__Quote__r.PO__c,
                                     SBQQ__Quantity__c,SBQQ__Quote__c,SBQQ__UpgradedSubscription__c,SBQQ__StartDate__c,
                                     SBQQ__UpgradedSubscription__r.SBQQ__StartDate__c,SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c                                  
                                     FROM SBQQ__QuoteLine__c
                                     WHERE SBQQ__Quote__c =: setOfAmendQuoteDebooked];
        
        lstOpptyToClosedWon = [SELECT AccountId,Id,Name,StageName,Status__c,Type,
                               SBQQ__AmendedContract__r.SBQQ__Opportunity__r.RecordType.Id
                               FROM Opportunity 
                               WHERE Id =: setOpptyId];
        
        //System.debug('List of QLI:' + lstQLIOfDebookAmendQuotes);
        //System.debug('List of QLI:' + lstQLIOfDebookAmendQuotes.size());
        //Update the QLI with 0 Quantity after lines are inserted . 
        for(SBQQ__QuoteLine__c qli : lstQLIOfDebookAmendQuotes){
            if(qli.SBQQ__Quantity__c != 0)
                qli.SBQQ__Quantity__c = 0;
            if(qli.SBQQ__UpgradedSubscription__r.SBQQ__StartDate__c != Null || qli.SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c != Null){
                qli.SBQQ__StartDate__c = qli.SBQQ__UpgradedSubscription__r.SBQQ__StartDate__c;
                qli.SBQQ__EndDate__c = qli.SBQQ__UpgradedSubscription__r.SBQQ__EndDate__c ;
            }
            //handled in beforeUpdate
            //qli.Tax_Category__c = qli.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.Tax_Category__c; //TAX-227 Fix for Full Debooks
            qli.Purchase_Order_PO_Number__c = qli.SBQQ__Quote__r.PO__c;
            
            lstUpdateQLI.add(qli);
        }
        
        //System.debug('Size of List' + lstUpdateQLI.size());
        if(!lstUpdateQLI.isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(lstUpdateQLI, false);
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.processAmendQuoteForDebookedOrder', 'Error while updating Quote Lines: ', e.getMessage());
            }
        }  
        //Insert Competitor Relationship on the Amend Oppty before making the Stage to Closed Won
        List<Account> lstCompetitorAcc = new List<Account>();
        List<Competitor_Relationship__c> lstCompetitorRel = new List<Competitor_Relationship__c>();
        lstCompetitorAcc = [SELECT Id,RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = 'Competitor_Account']; 
        
        for(Opportunity oppty : lstOpptyToClosedWon){
            Competitor_Relationship__c cr = new Competitor_Relationship__c();
            cr.Competitor_Account__c = lstCompetitorAcc[0].Id;
            cr.Opportunity__c = oppty.Id;
            lstCompetitorRel.add(cr);
        }
        
        insert lstCompetitorRel;
        //Update the staus of the Amend Opty to Closed Won and Stage Reason as Order Debook
        for(Opportunity oppty : lstOpptyToClosedWon){
            oppty.put('Substage__c','Sales Won'); //</T13>
            oppty.Stage_Reason__c = 'Full Debook'; //<SALESRT-13045>
            //-----------------------------------------------T18     
            oppty.StageName = 'Closed Won';  
            oppty.RecordTypeId = oppty.SBQQ__AmendedContract__r.SBQQ__Opportunity__r.RecordType.Id;  
            //-----------------------------------------------T18    
            lstUpdateOpptyToClosedWon.add(oppty);
        }
        
        //System.debug('Size of List to Udpate Oppty to Closed Won' + lstUpdateOpptyToClosedWon.size());
        if(!lstUpdateOpptyToClosedWon.isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(lstUpdateOpptyToClosedWon, false);
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.processAmendQuoteForDebookedOrder', 'Error while updating Oppty to Closed Won: ', e.getMessage());
            }
        }
        Set<Id> setQuoteId = new Set<Id>();//<T30>
        //Update the Amend Quote Status to Approved.
        for(SBQQ__Quote__c quote : lstQuotesToUpdate){
            quote.Apply_PO_to_All_Lines__c = True;
            quote.ApprovalStatus__c = 'Approved';
            quote.SBQQ__Status__c = 'Approved';
            quote.SBQQ__StartDate__c = quote.SBQQ__MasterContract__r.StartDate; //<T20>
            //quote.SBQQ__Ordered__c = True;
            setQuoteId.add(quote.Id);//<T30>
            lstUpdateQuoteStatus.add(quote);
        }
        
        //System.debug('Size of List To Update Quote Status Approved & Ordered True' + lstUpdateQuoteStatus.size());
        if(!lstUpdateQuoteStatus.isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(lstUpdateQuoteStatus, false);
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.processAmendQuoteForDebookedOrder', 'Error while updating Quote Status to Approved: ', e.getMessage());
            }
        } 
        //<T30>
        if(!lstQuotesToUpdate.isEmpty()){
            Integer maxSchRetry = 3;        
            Boolean isSuccess = false;
            isSuccess = recalcQuoteFullDebook(lstQuotesToUpdate,setQuoteId);
            //Retry 2 more times if Schedulable class failed
            if(!isSuccess){
                for(Integer countSchRun = 1; countSchRun < = maxSchRetry && !isSuccess; countSchRun++){                
                    isSuccess = recalcQuoteFullDebook(lstQuotesToUpdate,setQuoteId);
                    countSchRun++;
                }
                //If it fails even after three attempts, log an error
                if(!isSuccess)
                GAM.CreateLogs('primaryOrderedContRenewalSchedulable',lstQuotesToUpdate, 'Error during Quote recalculation on Full Debook');                    
            }            
        }
        //<T30>
        //Get all Contracts associated to Original Debooked order .
        lstContractsRenewalOppty = [SELECT AccountId,Id,Name,SBQQ__RenewalOpportunityStage__c,SBQQ__RenewalOpportunity__c,
                                    SBQQ__Order__c
                                    FROM Contract
                                    WHERE SBQQ__Order__c =: setOfOrdersId];
        
        Set<Id> setRenewalOpptyId = new Set<Id>();
        for(Contract con : lstContractsRenewalOppty){
            setRenewalOpptyId.add(con.SBQQ__RenewalOpportunity__c);
        }
        //Change the Contracts to No Oppty status
        List<Opportunity> lstRenewalOpptys = new List<Opportunity>();
        lstRenewalOpptys = [SELECT StageName,Id,Type 
                            FROM Opportunity
                            Where Id = : setRenewalOpptyId];
        List<Opportunity> lstUpdateRenewalOppty = new List<Opportunity>();                  
        for(Opportunity oppty : lstRenewalOpptys){
            oppty.StageName = 'No Opportunity';
            //-----------------------------------------------T17
            oppty.Renewal_Cancellation_Reason__c = 'One Time Project';
            oppty.Cancellation_Detail__c = 'Debook';
            //-----------------------------------------------T17
            lstUpdateRenewalOppty.add(oppty);     
        }
        
        //System.debug('Size of List Update Renewal Oppty' + lstUpdateRenewalOppty.size());
        if(!lstUpdateRenewalOppty.isEmpty()){
            try{
                Database.SaveResult[] updateResult = Database.update(lstUpdateRenewalOppty, false);
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.processAmendQuoteForDebookedOrder', 'Error while updating Renewal Oppty to No Opportunity ', e.getMessage());
            }
        }  
    }     
    //<T30>
    /*
     * Method name  : recalcQuoteFullDebook
     * Description  : false update the Caculate field on Quote to recalculate the Quote after some time delay - Full debook issue
     * Action Event : After Insert
     */
    public static Boolean recalcQuoteFullDebook(List<SBQQ__Quote__c> lstQuotesToUpdate, Set<Id> setQuoteId){        
        primaryOrderedContRenewalSchedulable s = new primaryOrderedContRenewalSchedulable('Full Debook Recalculation','Quote',setQuoteId); 
        DateTime newDateTime = DateTime.now().addMinutes(3);
        String hour = String.valueOf(newDateTime.hour());
        String min = String.valueOf(newDateTime.minute()); 
        String ss = String.valueOf(newDateTime.second());
        String month = String.valueOf(newDateTime.month());
        String day = String.valueOf(newDateTime.day());
        String year = String.valueOf(newDateTime.year());
        String quoteId = lstQuotesToUpdate[0].Id;
        Boolean returnVal = false;
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
        try{
            //Schedule a job for Quote recalculation - five minutes after the Amendment Quote is created
            System.schedule('primaryOrderedContRenewalSchedulable_' + quoteId + ' @: ' + String.valueOf(newDateTime), nextFireTime, s);              
            returnVal = true;
        }
        catch(Exception e){
            returnVal = false;
        }
        return returnVal;
    }
    //<T30>
    //--------------------------------------------------------------------T10------------------------------------------------------------------------------
    /*--------------------------------------------------------------------<SALESRT-12980>------------------------------------------------------------------------------
* Method name  : AutoDeleteCancelReason
* Description  : When the same subscription line is present as an active quote and also present in Cancel reason, the system should delete the Cancel reason record automatically. 
*                as a part of SALESRT-12980
* Action Event : After Insert
*/
    public static void autoDeleteCancelReason(List<SBQQ__QuoteLine__c> mapNew)
    {
        //Variable Declaration
        List<Unrenewed__c> lstUnrenewedToDelete = new List<Unrenewed__c>();
        List<Unrenewed__c> lstUnrenewed = new List<Unrenewed__c>();
        Map<Id, Id> quoteSubscriptionMap = new Map<Id, Id>();
        //create values for Map
        for(SBQQ__QuoteLine__c li:mapNew)
        {                      
            quoteSubscriptionMap.put(li.SBQQ__RenewedSubscription__c, li.SBQQ__Quote__c) ;
        }
        //Get cancel reason record associated with the Quote
        lstUnrenewed = [Select id,Quote__c,Subscription__c  from Unrenewed__c where Subscription__c in : quoteSubscriptionMap.keySet()] ;
        //Compare if the quote and subscription of QL matches with the cancel reason record and store it in lstUnrenewedToDelete list
        for(Unrenewed__c li:lstUnrenewed)
        {
            if( quoteSubscriptionMap.containsKey(li.Subscription__c) )
            {
                Id Quoteid = quoteSubscriptionMap.get(li.Subscription__c);               
                if(li.Quote__c == Quoteid )
                    lstUnrenewedToDelete.add(li);                  
                
            }
        }
        // Action to delete lstUnrenewedToDelete list
        if(!lstUnrenewedToDelete.isEmpty()){
            try{
                delete lstUnrenewedToDelete;
            }        
            catch(DmlException e){
                GAM.CreateExceptionRecords('QuoteTriggerHandler.autoDeleteCancelReason', 'Error while deleting cancel reason: ', e.getMessage());
            }
        } 
    }
    //--------------------------------------------------------------------<SALESRT-12980>------------------------------------------------------------------------------    
}