/*
Class:          psa_em_ExpenseRollupFixBatch
@Author:        Vivek Warrier
@Created Date:  19-Jul-2021
@Description:   Batch class to correct Total Non-Billable and Total Reimwbursement Amounts on Expense Report.
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Requested By        Description                                                         Jira No.       Tag
Wasim			    12-Jul-2023							Removing the hardcoded email id										                T1
Rohit Niranjanamath 09-Sept-2023    Sept Build '23      For Expense report submitted in JPY round off the Total reimbursement amount  PSA-3118       T2
************************************************************************************************************************************************************
*/	
global class psa_em_ExpenseRollupFixBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Label: ' + Label.psa_ExpensePickDays);
        string query = 'SELECT Id, CreatedDate, CurrencyISOCode, pse__Total_Reimbursement_Amount__c, pse__Total_Non_Billable_Amount__c, pse__Reimbursement_Currency__c, (SELECT Id, CurrencyISOCode, pse__Reimbursement_Amount__c, pse__Non_Billable_Amount__c, pse__Reimbursement_Currency__c FROM pse__Expense_Lines__r WHERE pse__Reimbursement_Amount__c > 0 OR pse__Non_Billable_Amount__c > 0) FROM pse__Expense_Report__c WHERE psa_External_Id__c = null AND LastModifiedDate = LAST_N_DAYS:' + Label.psa_ExpensePickDays + ' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<pse__Expense_Report__c> scope){
        Decimal totalReimbursementAmount = 0;
        Decimal totalNonBillableAmount = 0;
        Map<String,Decimal> mapCurrencyExRate = new Map<String,Decimal>();//Query the dated exchange rates here
        for(DatedConversionRate dcr : [SELECT Id,ConversionRate,IsoCode,NextStartDate FROM DatedConversionRate WHERE NextStartDate > TODAY]){
            mapCurrencyExRate.put(dcr.IsoCode,dcr.ConversionRate);
        }
        System.debug('mapCurrencyExRate: ' + mapCurrencyExRate);
        List<pse__Expense_Report__c> listExpenseReportUpdate = new List<pse__Expense_Report__c>();
        for(pse__Expense_Report__c er : scope){
            totalReimbursementAmount = 0;
            totalNonBillableAmount = 0;
            for(pse__Expense__c e : er.pse__Expense_Lines__r){
                if(e.pse__Reimbursement_Amount__c != 0){
                    if(e.pse__Reimbursement_Currency__c == er.pse__Reimbursement_Currency__c){
                        totalReimbursementAmount += e.pse__Reimbursement_Amount__c;
                    }
                    else{
                        Decimal convertedReimbursementAmount = ((mapCurrencyExRate.get(er.CurrencyISOCode)/mapCurrencyExRate.get(e.CurrencyISOCode))*e.pse__Reimbursement_Amount__c);
                        System.debug('convertedNonBillableAmount: ' + convertedReimbursementAmount);
                        totalReimbursementAmount += convertedReimbursementAmount;
                    }
                }
                if(e.pse__Non_Billable_Amount__c != 0){
                    if(e.CurrencyISOCode == er.CurrencyISOCode){
                        totalNonBillableAmount += e.pse__Non_Billable_Amount__c;
                    }
                    else{
                        Decimal convertedNonBillableAmount = ((mapCurrencyExRate.get(er.CurrencyISOCode)/mapCurrencyExRate.get(e.CurrencyISOCode))*e.pse__Non_Billable_Amount__c);
                        System.debug('convertedNonBillableAmount: ' + convertedNonBillableAmount);
                        totalNonBillableAmount += convertedNonBillableAmount;
                    }
                }
            }
            //<T2> - Start
            //Check if the Expense report reimbursement currency is JPY, If true convert the total reimbursement amount to the nearest value
            if(er.pse__Reimbursement_Currency__c  == 'JPY'){
                Decimal nearestValue = totalReimbursementAmount;
                er.pse__Total_Reimbursement_Amount__c = nearestValue.round(RoundingMode.HALF_UP);
            //<T2> - End
            }else{
            er.pse__Total_Reimbursement_Amount__c = totalReimbursementAmount;
            }
            er.pse__Total_Non_Billable_Amount__c = totalNonBillableAmount;
            if(totalReimbursementAmount != 0 || totalNonBillableAmount!= 0)
                listExpenseReportUpdate.add(er);
        }
        update listExpenseReportUpdate;//Expense Report, with the fields Total Reimbursement Amount and Total Non-billable Amount updated.
    }
    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id,Status,JobType,NumberOfErrors,JobItemsProcessed,TotalJobItems,CompletedDate,ExtendedStatus FROM AsyncApexJob WHERE Id =:BC.getJobId()];          
    
        List<User> userList = new List<User>();
        //String emailRecipients = 'vwarrier@informatica.com';//<T1>
        String emailRecipients = Label.DLIPSIT_Email;//<T1>
        List<String> toAddresses = new List<String>(); 
        toAddresses = emailRecipients.split(',');
        List<User> activeUsers = [SELECT Id,Email FROM User WHERE IsActive = True AND Profile.UserLicense.Name = 'Salesforce' AND Email IN :toAddresses];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        if(!activeUsers.isEmpty()){
            for(User u : activeUsers){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(u.Id);
        mail.setSubject('Expense Rollup Fix Batch - ' + a.Status);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody
        ('Hi Team,\n\nThe batch to rollup Reimbursement Amounts and Non-Billable Amounts from Expenses to Expense Reports has completed its run for ' + a.CompletedDate + ' for the last ' + Label.psa_ExpensePickDays + ' (incl. today).\nPlease find the details below:\n\n' +
        'Job Status : ' + a.Status + '\n'+
        'Total Job Items processed : ' + a.TotalJobItems + '\n'+
        'Number of Job Items processed : ' + a.JobItemsProcessed + '\n' +
        'Number of Failures : '+ a.NumberOfErrors);
                mailList.add(mail);
            }
            Messaging.sendEmail(mailList);
        }
        //<T2> - End
    }
}