/*
Class:          ReportsController
@Author:        Amit Garg
@Created Date:  11-Apr-2022
@Description:   To show the reports in the community.  

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
public with sharing class ReportsController{
    @AuraEnabled
    public static caseData CasesInfo(string supportaccount, string opendatestart, string opendateend,string closedatestart,string closedateend){
        string query = 'select id,createddate,Engagement__r.createdby.isPortalEnabled, closeddate, isclosed, Days_to_Close_Date__c,Isescalated, (select id from case_comments__r where type__c = \'Escalation\' ),(select id, Overall_Satisfaction_Score__c from Clicktools_Case_CSAT_Results__r) from case  ';
        account acc = new account();
        system.debug('@@--supportaccount --->>'+supportaccount );
        if (Schema.sObjectType.Account.fields.Name.isAccessible()){
            acc = [select id, name from account where id=:supportaccount limit 1];
        }
        
        string filter = createFilterQuery(opendatestart, opendateend,closedatestart,closedateend);
        /* if(filter != ''){
query = query + filter;
}*/
        caseData cd = new caseData();
        cd.AccountName = acc.name;
        cd.totalCases = 0;
        cd.ClosedCases = 0;
        cd.OpenCases = 0;
        cd.AvgDays = 0.0;
        cd.Escalations = 0.0;
        cd.CSAT = 0;
        decimal closeDays = 0.0;
        integer totalSurvey = 0;
        decimal surveyScore = 0;
        //system.debug('query-->>'+query);
        list<case> allcases = CaseControllerWithoutSharing.GetAllCases(query, supportAccount, filter);
        for(case c: allcases){            
            if(c.closeddate != null){
                Integer noOfDays = date.valueOf(c.createddate).daysBetween(date.valueOf(c.closeddate));
                closeDays = closeDays + noOfDays;
            }
            //if(c.Engagement__r.createdby.isPortalEnabled){cd.Escalations ++;
            //}
            if(c.case_comments__r.size() > 0){cd.Escalations ++;
                                             }
            cd.totalCases ++;
            if(c.IsClosed){cd.ClosedCases++;
                          }else{cd.OpenCases++;
                               }
            // system.debug('surveys-->>'+c.Clicktools_Case_CSAT_Results__r);
            if(c.Clicktools_Case_CSAT_Results__r.size() > 0){
                system.debug(c.Clicktools_Case_CSAT_Results__r);
            }
            for(GCS_Survey_Response__c sur:c.Clicktools_Case_CSAT_Results__r){
                //   system.debug('@@->>'+sur);
                surveyScore = surveyScore + sur.Overall_Satisfaction_Score__c;
                totalSurvey++;
            }
        }
        
        if(surveyScore > 0){cd.CSAT = (surveyScore/totalSurvey).setScale(2);
                           }
        if(cd.Escalations > 0){cd.Escalations = ((cd.Escalations/cd.totalCAses)*100).setScale(2);
                              }
        
        if(closeDays > 0){cd.AvgDays = (closeDays/cd.ClosedCases).setScale(2);
                         }
        
        return cd;
    }
    public static string createFilterQuery(string opendatestart, string opendateend,string closedatestart,string closedateend){
        string filter = '';
        if(opendatestart != null){
            
            date d = date.valueOf(opendatestart); 
            opendatestart = string.valueOf(d)+ 'T00:00:00.000+0000';
            filter = ' and createddate >=' +String.escapeSingleQuotes(opendatestart);
        }
        if(opendateend != null){
            date d = date.valueOf(opendateend); 
            opendateend = string.valueOf(d)+ 'T23:59:59.000+0000';            
            filter += ' and createddate <=' +String.escapeSingleQuotes(opendateend);
        }
        
        if(closedatestart!= null){
            date d = date.valueOf(closedatestart); 
            closedatestart = string.valueOf(d)+ 'T00:00:00.000+0000'; 
            filter += ' and Closeddate >=' +String.escapeSingleQuotes(closedatestart);
        }
        if(closedateend!= null){
            date d = date.valueOf(closedateend); 
            closedateend = string.valueOf(d)+ 'T23:59:59.000+0000'; 
            filter += ' and Closeddate <=' + String.escapeSingleQuotes(closedateend);
        }
        return filter;
    }
    @AuraEnabled
    public static chartWrapper casesByGroupFilter(string supportaccount,string fieldfilter, string opendatestart, string opendateend,string closedatestart,string closedateend){
        system.debug('@@-->>'+ fieldfilter);
        fieldfilter = String.escapeSingleQuotes(fieldfilter);
        string query = 'select count(id) cnt, '+fieldfilter+' from case where '+fieldfilter +'!=null and support_account__c =:supportaccount  and Is_Internal_Or_External_Case__c =\'External\'';
        string filter = createFilterQuery(opendatestart, opendateend,closedatestart,closedateend);
        
        if(filter != ''){
            query = query + filter;
        }
        query += 'group by '+fieldfilter;
        chartWrapper cw = new chartWrapper();
        cw.labels = new list<string>();
        cw.values = new list<integer>();
        for(AggregateResult ar:database.query(query)){
            string st = (string)ar.get(fieldfilter);
            if(st == null)st = '-';
            if(fieldfilter == 'Status' && (st == 'Booked' || st == 'Scheduled' || st == 'Cancelled')){
                st = 'AAE - '+st;
            }
            cw.labels.add(st);
            cw.values.add((Integer)ar.get('cnt'));
        }
        system.debug('@@-->>'+ cw);
        return cw;
    }
    @AuraEnabled
    public static chartWrapper AverageDaysToClose(string supportaccount,string opendatestart, string opendateend,string closedatestart,string closedateend){
        string query = 'select id, createddate, closeddate, ContactId,contact.name,createdby.contactId, createdbyId from case where contactId !=null  and support_account__c =:supportaccount  and Is_Internal_Or_External_Case__c =\'External\'';
        string filter = createFilterQuery(opendatestart, opendateend,closedatestart,closedateend);
        
        if(filter != ''){
            query = query + filter;
        }
        
        chartWrapper cw = new chartWrapper();
        cw.labels = new list<string>();
        cw.values = new list<integer>();
        map<string, integer> daysMap = new map<string, integer>();
        map<string, string> contactNameMap = new map<string, string>();
        
        for(case c:database.query(query)){
            //if(c.contactId == c.createdby.contactId){
            if(daysMap.containsKey(c.contactId)){
                integer count = daysMap.get(c.contactId) + 1;
                daysMap.put(c.contactId,count);
            }else{
                daysMap.put(c.contactId,1);
                contactNameMap.put(c.contactId,c.Contact.Name);
            }
            
        }
        system.debug(contactNameMap.values());
        cw.labels.addAll(contactNameMap.values());
        cw.values = daysMap.values();
        return cw;
    }
    @AuraEnabled
    public static chartWrapper MonthlyCases(string supportaccount,string opendatestart, string opendateend,string closedatestart,string closedateend){
        string query = 'select CALENDAR_YEAR(CreatedDate) yr,calendar_month(CreatedDate) mn, count(Id) cnt from case where contactId !=null  and support_account__c =:supportaccount  and Is_Internal_Or_External_Case__c =\'External\'';
        string filter = createFilterQuery(opendatestart, opendateend,closedatestart,closedateend);
        
        if(filter != ''){
            query = query + filter;
        }
        query += 'group by CALENDAR_YEAR(CreatedDate),calendar_month(CreatedDate)  ORDER BY CALENDAR_YEAR(CreatedDate),calendar_month(CreatedDate)';
        chartWrapper cw = new chartWrapper();
        cw.labels = new list<string>();
        cw.values = new list<integer>();
        map<string, integer> daysMap = new map<string, integer>();
        map<string, string> contactNameMap = new map<string, string>();
        
        for(AggregateResult ar:database.query(query)){
            //if(c.contactId == c.createdby.contactId){
            string st = getMonth((Integer)ar.get('mn')) + ' - ' + (Integer)ar.get('yr');
            cw.labels.add(string.valueOf(st));
            cw.values.add((Integer)ar.get('cnt'));
            
        }
        return cw;
    }
    public class chartWrapper{
        @AuraEnabled
        public list<string> labels{get;set;}
        @AuraEnabled
        public list<integer> values{get;set;}
    }
    public static string getMonth(integer no){
        if(no == 1)return 'Jan';
        if(no == 2)return 'Feb';
        if(no == 3)return 'Mar';
        if(no == 4)return 'Apr';
        if(no == 5)return 'May';
        if(no == 6)return 'Jun';
        if(no == 7)return 'Jul';
        if(no == 8)return 'Aug';
        if(no == 9)return 'Sep';
        if(no == 10)return 'Oct';
        if(no == 11)return 'Nov';
        if(no == 12)return 'Dec';
        return null;
    }
    public class caseData{
        @AuraEnabled
        public string AccountName{get;set;}
        @AuraEnabled
        public integer totalCases{get;set;}
        @AuraEnabled
        public integer OpenCases{get;set;}
        @AuraEnabled
        public integer ClosedCases{get;set;}
        @AuraEnabled
        public Decimal Escalations{get;set;}
        @AuraEnabled
        public Decimal AvgDays{get;set;}
        @AuraEnabled
        public Decimal CSAT{get;set;}
    }
}