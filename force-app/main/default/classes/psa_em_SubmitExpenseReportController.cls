/*
@created by       : Mahesh Ganti
@created on       : 
@Purpose          : Controller for SubmitExpenseReport Lightning Component

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Pavithra V     25-02-2021							Populate fields on submitting Empty Expense Report	  PSA-918        <T01>

Ranjan	       19-05-2021						   	Place a if block code outside while loop			  PSA-1587       <T02>

*/
public without sharing class psa_em_SubmitExpenseReportController {
    public static List<String> endOfWeeks;
    public static List<String> selectedDates;
    public static Date toSubmit;
    public static String toSubmitString;
    
    public static globalApexManager GAM = new globalApexManager();
    // Get Date Logic
    @AuraEnabled(cacheable=true)
    public static List<String> fetchRequiredDates(){
        string errorMessage;
        endOfWeeks = new List<String>();
        selectedDates = new List<String>();
        Id userId = UserInfo.getUserID();
        
        List<Contact> conRec = new List<Contact>([SELECT Id,Name,pse__Salesforce_User__c FROM Contact WHERE pse__Salesforce_User__c = :UserInfo.getUserId() LIMIT 1]);
        if(conRec.isEmpty()){              
            throw new AuraHandledException('Error: A Contact Record does not exist for the current user');                            
        }
        //Contact c = cs.get(0); 
        
        Date sunday = Date.newInstance(1900, 1, 7);
        Date twoMonths = Date.today().addDays(-60);
        Integer daysBetween = Math.mod(sunday.daysBetween(twoMonths), 7);
        twoMonths = twoMonths.addDays(0 - daysBetween);
        System.debug('IS IT SUNDAY: '+(Math.mod(sunday.daysBetween(twoMonths), 7) == 0));
        Map<Date, Boolean> hasReport = new Map<Date, Boolean>();
        List<pse__Expense_Report__c> existingReports = [SELECT Id,pse__Last_Expense_Date__c,pse__First_Expense_Date__c FROM pse__Expense_Report__c 
                                                        WHERE pse__Resource__c IN :conRec AND pse__Last_Expense_Date__c >= :twoMonths ORDER BY pse__Last_Expense_Date__c];
        for(pse__Expense_Report__c er : existingReports){
            hasReport.put(er.pse__Last_Expense_Date__c, true);
            hasReport.put(er.pse__First_Expense_Date__c, true);
        }
        System.debug(hasReport);
        Integer numWeeks = 0;
        Date currentDate = twoMonths;
        
        while(currentDate <= Date.today()){
            Date dv = Date.newInstance(currentDate.year(),currentDate.month(),currentdate.day());
            DateTime dt = DateTime.newInstance(currentDate.year(),currentDate.month(),currentdate.day(), 12, 0, 0);
            if(Math.mod(sunday.daysBetween(dv), 7) == 0){
                numWeeks ++;
            }
            currentDate = currentDate.addDays(1);
        }
        currentDate = twoMonths;
        
        Integer countWeeks = 0;
        while(countWeeks < numWeeks){
            Date startWeek = null;
            Date endWeek = null;              
            while(startWeek == null || endWeek == null){
                Date curDate = Date.newInstance(currentDate.year(),currentDate.month(),currentdate.day());
                if(Math.mod(sunday.daysBetween(curDate), 7) == 0){
                    startWeek = currentDate;
                }
                if(Math.mod(sunday.daysBetween(curDate), 7) == 6){
                    endWeek = currentDate;
                }
                currentDate = currentDate.addDays(1);
            }
            countWeeks ++;
            Date weekStartCount = startWeek;
            Boolean foundReport = false;
            while(weekStartCount <= endWeek && foundReport == false){
                if(hasReport.get(weekStartCount) != null && hasReport.get(weekStartCount) == true){
                    foundReport = true;
                }
                weekStartCount = weekStartCount.addDays(1);
            }
            if(!foundReport){
                Datetime formatted = Datetime.newInstance(endWeek.year(), endWeek.month(),endWeek.day());
                String dateFormatted = formatted.format('MM/dd/yyyy');
                selectedDates.add(dateFormatted);
                //endOfWeeks.add(dateFormatted);                   
            }
            /*if(selectedDates.isEmpty()){
throw new AuraHandledException('Error: There are no dates returned'); // very rare scenario
}*/
            
        }
        if(selectedDates.isEmpty()){  // <T02>
            throw new AuraHandledException('Error: There are no dates returned'); // very rare scenario
        }
        return selectedDates;
    }
    
    @AuraEnabled
    public static String insertExpenseReports(List<String> datesFromUI){
        
        List<Date> datesToprocess = new List<Date>();
        for(String so : datesFromUI){
            String dateString = so;
            String[] divided = dateString.split('/');
            Integer month = integer.ValueOf(divided[0]);
            Integer day = integer.ValueOf(divided[1]);
            Integer year = integer.ValueOf(divided[2]);
            Date newDate = Date.newInstance(year, month, day);
            datesToprocess.add(newDate);
        }
        string uiMessage;
        //String uiMessage = 'SOME ISSUE OCCURED,PLEASE REACH OUT TO SYSTEM ADMIN';
        List<pse__Expense_Report__c> expenseReportsToCreate = new List<pse__Expense_Report__c>();
        List<pse__Expense_Report__c> expenseReportsToUpdate = new List<pse__Expense_Report__c>();
        List<pse__Expense__c> expensesToCreate = new List<pse__Expense__c>();
        String expReportNameList;
        //try{
        Contact conRec = [SELECT Id,Name,pse__Salesforce_User__c FROM Contact WHERE pse__Salesforce_User__c = :UserInfo.getUserId() LIMIT 1];
        if(conRec == null){
            throw new AuraHandledException('Error: A Contact Record does not exist for the current user');              
        }
        
        List<pse__Proj__c> exProjRec = new List<pse__Proj__c>([SELECT Id,Name FROM pse__Proj__c WHERE Name = :Label.psa_em_Empty_Expense_Report_Project LIMIT 1]);
        if(exProjRec.isEmpty()){
            throw new AuraHandledException('Error: The Default Expense Project does not exist, Please reach out to PS Ops to create one');              
        }
        // Create Parent Expesnse Report
        if(datesToProcess.size()>0){
            for(Date endDate : datesToProcess){
                Datetime endformat = Datetime.newInstance(endDate.year(), endDate.month(),endDate.day());
                String endDateFormat = endformat.format('MM/dd/yy');
                pse__Expense_Report__c exRep = new pse__Expense_Report__c();
                exRep.pse__Last_Expense_Date__c = Date.valueOf(endDate);
                exRep.Name = 'No Expense -'+endDateFormat;
                exRep.pse__Resource__c = conRec.Id;
                exRep.pse__Project__c = exProjRec[0].Id;
                exRep.pse__Exclude_from_Billing__c = true;/**<T01>**/
                exRep.pse__Description__c = 'No Expense';
                expenseReportsToCreate.add(exRep);
            }
        }
        if(expenseReportsToCreate.size()>0){
            try{
                insert expenseReportsToCreate;
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_em_SubmitExpenseReportController | METHOD: insertExpenseReports', expenseReportsToCreate , 'expenseReportsToCreate- ExpenseReport-Create');
                throw new AuraHandledException('Error:' +e.getMessage());                         
            }               
        }
        // Create child Expesnse records
        for(pse__Expense_Report__c ex : expenseReportsToCreate){
            pse__Expense__c exp = new pse__Expense__c();
            exp.pse__Expense_Report__c = ex.Id;
            exp.pse__Project__c = exProjRec[0].Id;
            //exp.pse__Status__c = 'Submitted';
            exp.pse__Resource__c = conRec.Id;
            exp.pse__Amount__c = 0;
            exp.pse__Expense_Date__c = ex.pse__Last_Expense_Date__c;
            exp.pse__Billable__c = false;
            exp.pse__Type__c = 'No Expense';
            //exp.pse__Approved__c = true;
            expensesToCreate.add(exp);            
        }
        System.debug('expensesToCreate '+expensesToCreate);
        if(expensesToCreate.size()>0){
            try{
                insert expensesToCreate;
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_em_SubmitExpenseReportController | METHOD: insertExpenseReports', expensesToCreate , 'expensesToCreate- Expenses-Create');
                throw new AuraHandledException('Error:' +e.getMessage());                        
            }     
        }
        
        // may be due to package functionality, we are updating again - need to validate if we can populate the values during insert.
        for(pse__Expense_Report__c ex : expenseReportsToCreate){ 
            ex.pse__Submitted__c = true;
            ex.pse__Approved__c = true;
            ex.pse__Include_In_Financials__c = true;
            ex.pse__Status__c = 'Approved';
            ex.PSA_EM_Approved_Date__c = System.today();/**<T01>**/
            ex.pse__Action_Check_Include_In_Financials__c = true;/**<T01>**/
            if(String.isBlank(expReportNameList)){
              expReportNameList = '\n'+ex.name + '\n';  
            }else{
              expReportNameList += ex.name + '\n';  
            }
            expenseReportsToUpdate.add(ex);
        }
        if(expenseReportsToUpdate.size()>0){               
            try{
                update expenseReportsToUpdate;
                uiMessage = 'Success: The following Expense reports are created:'+expReportNameList;
            }catch(Exception e){
                GAM.CreateLogs('CLASS: psa_em_SubmitExpenseReportController | METHOD: insertExpenseReports', expenseReportsToUpdate , 'expenseReportsToUpdate- ExpensesREPORT updat');
                throw new AuraHandledException('Error:' +e.getMessage());
                
            }  
        }
        System.debug('uiMessage '+uiMessage);
        return uiMessage;
    } 
}