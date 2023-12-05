/***************************************************************************************************************************************************************
 *  @Class Name: psa_pm_CalculateProjectActualsJob
 *  @Author: Wasim Akram
 *  @Date: 01 AUG 2022
 *  @Description: PSA-2391 : Batch Class to calculate Project actual fields for Customer Billable Projects without rolling up the child projects.  
 ****************************************************************************************************************************************************************
 ChangeHistory
    
ModifiedBy              Date                       Requested By            Description                       Tag   
Wasim Akram             26-Sep-2022                                        Conversion rate issue fix         <T1>
 ***************************************************************************************************************************************************************/

public class psa_pm_CalculateProjectActualsJob implements Schedulable, Database.Batchable<SObject>{
    public static globalApexManager GAM = new globalApexManager();
    
    public psa_pm_CalculateProjectActualsJob() {

    }
    public Database.queryLocator start(Database.BatchableContext bc)
    {
        String query = 'SELECT Id,CurrencyIsoCode FROM pse__Proj__c WHERE (Run_Actuals_Job__c = TRUE OR pse__Actuals_Need_Recalc__c = TRUE) AND pse__Is_Active__c = TRUE AND pse__Is_Billable__c = TRUE';
        return Database.getQueryLocator(query);
    }
    public void execute(SchedulableContext ctx)
    {
        psa_pm_CalculateProjectActualsJob batch = new psa_pm_CalculateProjectActualsJob();
        database.executebatch(batch,1);
    }
    public void execute(Database.BatchableContext bc, List<pse__Proj__c> scope)
    {       
        if(!scope.isEmpty())
        {   
            //Take one project at a time and calculate the fields
            pse__Proj__c proj = scope[0];
            try
            {
                //Assign the variables for Actual fields
                Decimal billableHoursExternal = 0;
                Decimal billableHoursInternal = 0;
                Decimal billed = 0;
                Decimal billings = 0;
                Decimal bookings = 0;
                Decimal creditedHours = 0;
                Decimal excludedHours = 0;
                Decimal expenseBudget = 0;
                Decimal expenseCosts = 0;
                Decimal externalCosts = 0;
                Decimal internalBudget = 0;
                Decimal internalCosts = 0;
                Decimal invoiced = 0;
                Decimal nonBillableHoursExternal = 0;
                Decimal nonBillableHoursInternal = 0;
                Decimal otherCosts = 0;
                Decimal passThroughBillings = 0;
                Decimal preBilled= 0;
                Decimal totalAssignedHours = 0;
                Decimal totalProjRevenueFromAsgmt = 0;
                //<T1> - Code for currency exchange rate
                Decimal conversionRate = 1;
                Map<String,Decimal> mapCurrencyExcRate = new Map<String,Decimal>();
                 //Get the Conversion Rate for the Currencies - Current Year and Last Year
                for(DatedConversionRate DCR : [SELECT Id,StartDate,ConversionRate,IsoCode FROM DatedConversionRate WHERE StartDate = THIS_YEAR OR StartDate = LAST_N_YEARS:1]){
                    mapCurrencyExcRate.put(String.valueOf(DCR.StartDate.Month())+'-'+String.valueOf(DCR.StartDate.Year())+'-'+DCR.IsoCode, DCR.ConversionRate);
                }
                //</T1>

                //Loop through the "Budgets"
                for(pse__Budget__c bgt : [SELECT Id,CurrencyIsoCode,pse__Type__c,pse__Amount__c,pse__Expense_Amount__c,pse__Pre_Billed_Amount__c FROM pse__Budget__c 
                                          WHERE pse__Project__c = :proj.Id AND pse__Approved__c = TRUE 
                                          AND pse__Include_In_Financials__c = TRUE]){
                    
                    //Expense Budget is calculated for all types of Budget
                    if(bgt.pse__Expense_Amount__c > 0)
                        expenseBudget = expenseBudget + bgt.pse__Expense_Amount__c;
                    if(bgt.pse__Amount__c > 0){  
                        if(bgt.pse__Type__c == 'Customer Purchase Order' || bgt.pse__Type__c == 'Customer Purchase Order Change Request'){
                            bookings = bookings + bgt.pse__Amount__c;
                        }
                        else{
                            internalBudget = internalBudget + bgt.pse__Amount__c;
                        }
                    }
                    if(bgt.pse__Pre_Billed_Amount__c > 0 && (bgt.pse__Type__c == 'Customer Purchase Order' || bgt.pse__Type__c == 'Customer Purchase Order Change Request'))                      
                    	preBilled = preBilled + bgt.pse__Pre_Billed_Amount__c;
                }
                //Loop through the "Expenses"
                for(pse__Expense__c exp : [SELECT Id,CurrencyIsoCode,pse__Billed__c,pse__Invoiced__c,pse__Amount__c,pse__Billable_Amount__c,Createddate FROM pse__Expense__c 
                                           WHERE pse__Project__c = :proj.Id AND pse__Approved__c = TRUE 
                                           AND pse__Include_In_Financials__c = TRUE]){

                    //<T1>                        
                    conversionRate = 1;
                    //Getting the Currency Exchange rates based on the Expense Created date
                    String expISOCode = String.valueOf(exp.CreatedDate.Month()) + '-' + String.valueOf(exp.CreatedDate.Year()) + '-' + exp.CurrencyIsoCode;
                    String projISOCode = String.valueOf(exp.CreatedDate.Month()) + '-' + String.valueOf(exp.CreatedDate.Year()) + '-' + proj.CurrencyIsoCode;
                    //Get the currency values in the correct Exchange rates
                    //Conversion rate will be 1 if the Expense and Project currency code is same. Covering the other scenarios below.
                    if(exp.CurrencyIsoCode != proj.CurrencyIsoCode && proj.CurrencyIsoCode == 'USD' && mapCurrencyExcRate.get(expISOCode) != null){
                        conversionRate = 1/mapCurrencyExcRate.get(expISOCode);
                    }
                    else if(exp.CurrencyIsoCode != proj.CurrencyIsoCode && exp.CurrencyIsoCode == 'USD' && mapCurrencyExcRate.get(projISOCode) != null){
                        conversionRate = mapCurrencyExcRate.get(projISOCode);
                    }
                    else if(exp.CurrencyIsoCode != proj.CurrencyIsoCode && mapCurrencyExcRate.get(projISOCode) != null && mapCurrencyExcRate.get(expISOCode) != null){
                        conversionRate = mapCurrencyExcRate.get(projISOCode)/mapCurrencyExcRate.get(expISOCode);
                    }
                    //</T1>

                	if(exp.pse__Billable_Amount__c > 0)
                    passThroughBillings = passThroughBillings + (exp.pse__Billable_Amount__c * conversionRate);//<T1>
                    if(exp.pse__Amount__c > 0){
                        expenseCosts = expenseCosts + (exp.pse__Amount__c * conversionRate);//<T1>
                        if(exp.pse__Billed__c){
                            billed = billed + (exp.pse__Amount__c * conversionRate);//<T1>
                        }
                        if(exp.pse__Invoiced__c){
                            invoiced = invoiced + (exp.pse__Amount__c * conversionRate);//<T1>
                        }
                	}
                }
                //Loop through the "Timecards"
                for(pse__Timecard__c tc : [SELECT Id,CurrencyIsoCode,pse__Total_Cost__c,pse__Total_Hours__c,pse__Billed__c,pse__Invoiced__c,pse__Billable__c,pse__External_Resource__c,pse__Time_Credited__c,pse__Time_Excluded__c,pse__Total_Billable_Amount__c FROM pse__Timecard__c 
                                           WHERE pse__Project__c = :proj.Id  AND pse__Approved__c = TRUE 
                                           AND pse__Include_In_Financials__c = TRUE]){

                    if(tc.pse__Total_Billable_Amount__c > 0){                          
                        billings = billings + tc.pse__Total_Billable_Amount__c;
                        if(tc.pse__Billed__c){
                            billed = billed + tc.pse__Total_Billable_Amount__c;
                        }
                        if(tc.pse__Invoiced__c){
                            invoiced = invoiced + tc.pse__Total_Billable_Amount__c;
                        }
                    }
                    if(tc.pse__Total_Cost__c > 0){
                        if(!tc.pse__External_Resource__c){
                            internalCosts =  internalCosts + tc.pse__Total_Cost__c;
                        }
                        else{
                            externalCosts = externalCosts + tc.pse__Total_Cost__c;
                        }
                    }
                    //Populate the Time Actuals Section fields - Start
                    //If the timecard is billable and for Internal Resource
                    if(tc.pse__Total_Hours__c > 0){
                        if(tc.pse__Billable__c && !tc.pse__External_Resource__c){
                            billableHoursInternal = billableHoursInternal + tc.pse__Total_Hours__c;                        
                        }
                        //If the timecard is billable and for External Resource
                        else if(tc.pse__Billable__c && tc.pse__External_Resource__c){
                            billableHoursExternal = billableHoursExternal + tc.pse__Total_Hours__c;
                        }
                        //If the timecard is non-billable and for Internal Resource
                        else if(!tc.pse__Billable__c && !tc.pse__External_Resource__c){
                            nonBillableHoursInternal = nonBillableHoursInternal + tc.pse__Total_Hours__c;
                        }
                        //If the timecard is non-billable and for External Resource
                        else if(!tc.pse__Billable__c && tc.pse__External_Resource__c){
                            nonBillableHoursExternal = nonBillableHoursExternal + tc.pse__Total_Hours__c;
                        }
                        //If the Time Credited is marked as True
                        if(tc.pse__Time_Credited__c){
                            creditedHours = creditedHours + tc.pse__Total_Hours__c;
                        }
                        //If the Time Excluded is marked as True
                        if(tc.pse__Time_Excluded__c){
                            excludedHours = excludedHours + tc.pse__Total_Hours__c;
                        }
                    }
                    //Populate the Time Actuals Section fields - End
                }
               
                //Loop through the "Milestones"
                for(pse__Milestone__c mil : [SELECT Id,CurrencyIsoCode,psa_pm_Record_Type__c,pse__Milestone_Amount__c,pse__Milestone_Cost__c,pse__Billed__c,pse__Invoiced__c FROM pse__Milestone__c 
                                             WHERE pse__Project__c = :proj.Id AND pse__Approved__c = TRUE 
                                             AND pse__Include_In_Financials__c = TRUE]){
                    
                    if(mil.psa_pm_Record_Type__c == 'Billing'){
                        if(mil.pse__Milestone_Cost__c > 0)
                        externalCosts = externalCosts + mil.pse__Milestone_Cost__c;
                        if(mil.pse__Milestone_Amount__c > 0){
                            billings = billings + mil.pse__Milestone_Amount__c;
                            if(mil.pse__Billed__c){
                                billed = billed + mil.pse__Milestone_Amount__c;
                            }
                            if(mil.pse__Invoiced__c){
                                invoiced = invoiced + mil.pse__Milestone_Amount__c;
                            }
                        }
                    }
                }
                //Loop through the "Miscellaneous Adjustments"
                for(pse__Miscellaneous_Adjustment__c misc : [SELECT Id,CurrencyIsoCode,pse__Transaction_Category__c,pse__Amount__c,pse__Billed__c,pse__Invoiced__c FROM pse__Miscellaneous_Adjustment__c 
                                                             WHERE pse__Project__c = :proj.Id AND  pse__Approved__c = TRUE 
                                                             AND pse__Include_In_Financials__c = TRUE]){

                    if(misc.pse__Amount__c > 0 || misc.pse__Amount__c < 0){
                        if(misc.pse__Transaction_Category__c == 'Internal Budget'){
                            internalBudget = internalBudget + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'Expense Budget'){
                            expenseBudget = expenseBudget + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'Expense Cost'){
                            expenseCosts = expenseCosts + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'Other Cost'){
                            otherCosts = otherCosts + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'Internal Cost'){
                            internalCosts = internalCosts + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'External Cost'){
                            externalCosts = externalCosts + misc.pse__Amount__c;
                        }                       
                        else if(misc.pse__Transaction_Category__c == 'Pre-Billed Revenue'){
                            preBilled = preBilled + misc.pse__Amount__c;
                        }
                        else if(misc.pse__Transaction_Category__c == 'Ready-to-Bill Revenue' || misc.pse__Transaction_Category__c == 'Pass-Through Ready-to-Bill Revenue'){
                            if(misc.pse__Transaction_Category__c == 'Ready-to-Bill Revenue')
                            billings = billings + misc.pse__Amount__c;
                            if(misc.pse__Transaction_Category__c == 'Pass-Through Ready-to-Bill Revenue')
                            passThroughBillings = passThroughBillings + misc.pse__Amount__c;
                            
                            if(misc.pse__Billed__c){
                                billed = billed + misc.pse__Amount__c;
                            }
                            if(misc.pse__Invoiced__c){
                                invoiced = invoiced + misc.pse__Amount__c;
                            }
                        }
                        else if(misc.pse__Transaction_Category__c == 'Booked Revenue'){
                            bookings = bookings + misc.pse__Amount__c;
                        }
                    }
                }
                 //Loop through the "Assignments"
                for(pse__Assignment__c asmt : [SELECT Id,CurrencyIsoCode,pse__Scheduled_Hours__c,pse__Projected_Revenue__c,CreatedDate FROM pse__Assignment__c 
                                               WHERE pse__Project__c = :proj.Id]){

                    //<T1>                            
                    conversionRate = 1;
                    String asmtISOCode = String.valueOf(asmt.CreatedDate.Month()) + '-' + String.valueOf(asmt.CreatedDate.Year()) + '-' + asmt.CurrencyIsoCode;
                    String projISOCode = String.valueOf(asmt.CreatedDate.Month()) + '-' + String.valueOf(asmt.CreatedDate.Year()) + '-' + proj.CurrencyIsoCode;
                    //Get the currency values in the correct Exchange rates
                    //Conversion rate will be 1 if the Expense and Project currency code is same. Covering the other scenarios below.
                    if(asmt.CurrencyIsoCode != proj.CurrencyIsoCode && proj.CurrencyIsoCode == 'USD' && mapCurrencyExcRate.get(asmtISOCode) != null){
                        conversionRate = 1/mapCurrencyExcRate.get(asmtISOCode);
                    }
                    else if(asmt.CurrencyIsoCode != proj.CurrencyIsoCode && asmt.CurrencyIsoCode == 'USD' && mapCurrencyExcRate.get(projISOCode) != null){
                        conversionRate = mapCurrencyExcRate.get(projISOCode);
                    }
                    else if(asmt.CurrencyIsoCode != proj.CurrencyIsoCode && mapCurrencyExcRate.get(projISOCode) != null && mapCurrencyExcRate.get(asmtISOCode) != null){
                        conversionRate = mapCurrencyExcRate.get(projISOCode)/mapCurrencyExcRate.get(asmtISOCode);
                    } 
                    //</T1>

                    //Populate the Project Monitor Section fields - Start
                    if(asmt.pse__Scheduled_Hours__c > 0)
                    totalAssignedHours = totalAssignedHours + asmt.pse__Scheduled_Hours__c;
                    if(asmt.pse__Projected_Revenue__c > 0)
                    totalProjRevenueFromAsgmt = totalProjRevenueFromAsgmt + (asmt.pse__Projected_Revenue__c * conversionRate);//<T1>
                    //Populate the Project Monitor Section fields - End
                }
                //Assign the local variables to the project fields
                proj.psa_Billable_Hours_External_Calc__c = billableHoursExternal;
                proj.psa_Billable_Hours_Internal_Calc__c = billableHoursInternal;
                proj.psa_Billed_Calc__c = billed;
                proj.psa_Billings_Calc__c = billings;
                proj.psa_Bookings_Calc__c = bookings;
                proj.psa_Credited_Hours_Calc__c = creditedHours;
                proj.psa_Excluded_Hours_Calc__c = excludedHours;
                proj.psa_Expense_Budget_Calc__c = expenseBudget;
                proj.psa_Expense_Costs_Calc__c = expenseCosts;
                proj.psa_External_Costs_Calc__c = externalCosts;
                proj.psa_Internal_Budget_Calc__c = internalBudget;
                proj.psa_Internal_Costs_Calc__c = internalCosts;
                proj.psa_Invoiced_Calc__c = invoiced;
                proj.psa_Non_Billable_Hours_External_Calc__c = nonBillableHoursExternal;
                proj.psa_Non_Billable_Hours_Internal_Calc__c = nonBillableHoursInternal;
                proj.psa_Other_Costs_Calc__c = otherCosts;
                proj.psa_PassThrough_Billings_Calc__c = passThroughBillings;
                proj.psa_PreBilled_Calc__c = preBilled;
                proj.psa_Total_Assigned_Hours_Calc__c = totalAssignedHours;
                proj.psa_Total_Proj_Revenue_From_Asgmt_Calc__c = totalProjRevenueFromAsgmt;
                proj.Run_Actuals_Job__c = false;
                update proj;
            }
            catch(Exception e){
                GAM.CreateExceptionRecords('Error from psa_pm_CalculateProjectActualsJob batch', e.getMessage(), proj.Id);
            }
        }
    }
    public void finish(Database.BatchableContext bc)
    {
    }
}