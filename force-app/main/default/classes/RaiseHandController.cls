/*
    @created by       : balajip
    @created on       : 01/12/2020
    @Purpose          : Controller class for Raise Hand Lightning components
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************************
 ModifiedBy         Date        Jira No.    Tag                         Description										Tag no
 Tejasvi Royal      31/5/2021   I2RT-2682   Case Handoff & Monitoring   Method for Case Handoff & Monitoring
 Tejasvi Royal      21/6/2021   I2RT-3074   Case Handoff & Monitoring   Lookup Results increased from 5 to 10
 Tejasvi Royal      23/7/2021               Case Handoff & Monitoring   Internal Demo Feedback/Enhancement Items
 Tejasvi Royal      29/7/2021               Case Handoff & Monitoring   Business Demo Feedback/Enhancement Items
Amit Garg			26/05/2022 I2RT-6251	Handoff User Filtering		Added user type = Standard in where condtion	T05
Isha Bansal        22/02/2023   I2RT-7258   Join a customer meeting-PS  Have a join a customer meeting option for Product specialists T06
Isha Bansal       29/03/2023    I2RT-6727   Add email, title, gcs user id in the user lookup for change owner T07
Isha Bansal       29/03/2023    I2RT-6727   Add isusersearchonly parameter to drive search results for  T08

 ****************************************************************************************************************

 */
public with sharing class RaiseHandController {
    public RaiseHandController() {

    }
    
    @AuraEnabled
    public static void raiseHandRequest(String caseId, String type, String subtype, String productName, String question, String urgency, String typeOfIssue, String description, String reproExpectation){
        Raise_Hand__c raiseHand = new Raise_Hand__c();
        raiseHand.Case__c = caseId;
        raiseHand.Type__c = type;
        raiseHand.Subtype__c = subtype;
        raiseHand.Skill__c = productName;
        raiseHand.Question__c = question;
        raiseHand.Urgency__c = urgency;
        raiseHand.Type_Of_Issue__c = typeOfIssue;
        raiseHand.Description__c = description;
        raiseHand.Repro_Expectation__c = reproExpectation;

        RaiseHandService.raiseRequest(raiseHand);
    }

    //create a raise hand request
    @AuraEnabled
    public static Id createRaiseHand(Raise_Hand__c raiseHand){
        System.debug('raiseHand - ' + raiseHand);
        //I2RT-4427
        String productName = raiseHand.Product__c;
        if(String.isEmpty(raiseHand.Skill__c)){
            String skillType = '';
            if(RaiseHandService.TYPE_REPRO_ENV_SETUP.equals(raiseHand.Type__c)){
                skillType = SkillService.TYPE_PRODUCT_ENGINEER;
            }else if(RaiseHandService.TYPE_CUSTOMER_MEETING.equals(raiseHand.Type__c)){ // T06 
                if(RaiseHandService.SUBTYPE_SUPPORTENGINEER.equals(raiseHand.Subtype__c)){// T06 
                    skillType = SkillService.TYPE_PRODUCT_ENGINEER;// T06 
                }else if(RaiseHandService.SUBTYPE_PSREVIEW.equals(raiseHand.Subtype__c)){// T06 
                    skillType = SkillService.TYPE_PRODUCT_SPECIALIST;// T06 
                } 
             }else if(RaiseHandService.TYPE_CO_OWN.equals(raiseHand.Type__c)){
                if(RaiseHandService.SUBTYPE_MULTIPRODUCT.equals(raiseHand.Subtype__c)){
                    skillType = SkillService.TYPE_PRODUCT_ENGINEER;
                }else if(RaiseHandService.SUBTYPE_PSREVIEW.equals(raiseHand.Subtype__c)){
                    skillType = SkillService.TYPE_PRODUCT_SPECIALIST;
                }else if(RaiseHandService.SUBTYPE_OPERATIONS.equals(raiseHand.Subtype__c)){
                    skillType = SkillService.TYPE_OPERATIONS;
                    productName = ''; //I2RT-4427
                }
            }else if(RaiseHandService.TYPE_GET_HELP.equals(raiseHand.Type__c)){
                skillType = SkillService.TYPE_PRODUCT_ENG_SPEC;
            } // TYPE_CUSTOMER_MEETING 
            List<String> lstSkillName = SkillService.getSkillNames(skillType, productName); //  I2RT-4427
            raiseHand.Skill__c = lstSkillName.get(0);
        }
        Id raiseHandId = RaiseHandService.raiseRequest(raiseHand);
        return raiseHandId;
    }
    
    //close a raise hand request
    @AuraEnabled
    public static void closeRequest(String raiseHandId){
        List<Raise_Hand__c> lstRaiseHand = [Select Id, Status__c From Raise_Hand__c Where Id=:raiseHandId];

        if(!lstRaiseHand.isEmpty()){
            Raise_Hand__c raiseHand = lstRaiseHand.get(0);
            raiseHand.Status__c = RaiseHandService.STATUS_CLOSED;
            update raiseHand;
        }
    }

    //get skills for a raise hand request
    @AuraEnabled
    public static List<String> getSkills(String type, String subtype, String productName){
        String skillType;
        Boolean isProductSpecific=false;
        System.debug('type - ' + type);
        System.debug('subtype - ' + subtype);
        System.debug('productName - ' + productName);
        if(RaiseHandService.TYPE_CO_OWN.equals(type)){
          /*  if(RaiseHandService.SUBTYPE_OPERATIONS.equals(subtype)){
                skillType = SkillService.TYPE_OPERATIONS;
            }*/
        }

        List<String> lstSkill;
        if(String.isNotEmpty(skillType)){
            lstSkill = SkillService.getSkillNames(skillType);
        }else{
            lstSkill = SkillService.getProductNames('Service Cloud');
        }
        
        return lstSkill;
    }

    // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    // Last Modified Date: 2 June 2021
    // Last Modified By: Tejasvi Royal
    // Search Method for Custom Lookup Component
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupQueueSearch(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters
        searchTerm += '*';

        // Set for GroupIds (QueueId)
        Set<Id> setOfGroupIds = new Set<Id>();

        // Adding GroupIds (QueueId) from QueueSobject to above Set
        for(QueueSobject q : [SELECT QueueId FROM QueueSobject WHERE SobjectType = 'Case']) {
            setOfGroupIds.add(q.QueueId);
        }

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                Group(Id, Name WHERE Type = 'Queue' AND Id IN :setOfGroupIds AND Id NOT IN :selectedIds)
            LIMIT 10
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Groups & convert them into LookupSearchResult
        String icon = 'standard:orders';
        Group[] groups = (List<Group>) searchResults[0];
        for (Group g : groups) {
            results.add(new LookupSearchResult(g.Id, 'Group', icon, g.Name, ''));
        }

        // Sort all results on title
        results.sort();

        return results;
    }

    // Tejasvi Royal -> Feedback/Enhancement through Demo
    // Last Modified Date: 23 July 2021
    // Last Modified By: Tejasvi Royal
    // Search Method for Custom Lookup Component
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupCombinedSearch(String searchTerm, List<String> selectedIds,string sobjectapiname,boolean isusersearchonly) { //T07 added parameter sobjectapiname
        // Prepare query parameters
        searchTerm += '*';
        // Set for GroupIds (QueueId)
        Set<Id> setOfGroupIds = new Set<Id>();

        String sobjectname=(sobjectapiname!=null)?sobjectapiname:'Case'; //T07  assign sobject 
        Boolean isusersearch=(isusersearchonly!=null)?isusersearchonly:false; //T08 default is both user and group search
        // Adding GroupIds (QueueId) from QueueSobject to above Set
        for(QueueSobject q : [SELECT QueueId FROM QueueSobject WHERE SobjectType= :sobjectname]) {
            setOfGroupIds.add(q.QueueId);
        }

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                User (Id, Name,Email, GCS_Team__c,Title WHERE usertype = 'Standard' /*and UserPermissionsSupportUser=true */and Id NOT IN :selectedIds),//<T07> //isha changes for email and team
            	Group (Id, Name WHERE Type = 'Queue' AND Id IN :setOfGroupIds AND Id NOT IN :selectedIds)
            LIMIT 10
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Users & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User u : users) {
            String subtitle = u.Title == null ? '' : + u.Title ; // T07- I2RT-6727 
            subtitle+=u.email==null?'':+', '+u.email; // T07  -I2RT-6727
            subtitle+=u.GCS_Team__c==null?'':+', '+u.GCS_Team__c; //T07 -I2RT-6727

            results.add(new LookupSearchResult(u.Id, 'User', userIcon, u.Name, subtitle));
        }
        
        if(!isusersearch){ //T08 - I2RT-6727
            // Extract Groups & convert them into LookupSearchResult
            String icon = 'standard:orders';
            Group[] groups = (List<Group>) searchResults[1];
            for (Group g : groups) {
                results.add(new LookupSearchResult(g.Id, 'Group', icon, g.Name, ''));
            }
        }
        // Sort all results on title
        results.sort();

        return results;
    }

    // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    // Last Modified Date: 2 June 2021
    // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    // Last Modified Date: 8 July 2021
    // Tejasvi Royal -> I2RT-3072: Raise hand record creation w/ Handoff
    // Last Modified Date: 8 July 2021
    // Tejasvi Royal -> Feedback/Enhancement through Demo
    // Last Modified Date: 23 July 2021
    // Last Modified By: Tejasvi Royal
    // Update Case with Handoff/Monitoring
    @AuraEnabled
    public static void updateCase(String recordId, String handoffType, String selectedOwnerId, String selectedQueueId, 
                                String handoffComments, String handoffSteps, String supportStartDateTime, String supportEndDateTime) {

        // Query the Case with reqd. fields to Update (Current Case)
        Case caseToUpdate = [SELECT Id, OwnerId, isDirectHandoff__c, Owner.Name, CaseNumber, Monitoring_Enabled__c, 
                            Product_Queue_ID__c, Product_Queues__c, Follow_Sun_Model_Support__c, Inbound_comment__c, 
                            Escalation_Attention__c, Weekend_Holiday_Support__c, Support_Start_DateTime__c, Support_End_DateTime__c 
                            FROM Case 
                            WHERE Id = :recordId];
 
        // Updating the relevant Case fields based on the Handoff Type
        switch on handoffType {
            when 'Live/Queue Handoff' {
                caseToUpdate.OwnerId = selectedOwnerId;

                caseToUpdate.isDirectHandoff__c = true;
                caseToUpdate.Follow_Sun_Model_Support__c = false;
                caseToUpdate.Monitoring_Enabled__c = false;
                caseToUpdate.Product_Queue_ID__c = null;
                caseToUpdate.Product_Queues__c = null;

                UPDATE caseToUpdate;
            }
            when 'Follow the Sun Monitoring' {
                QueueSobject selectedQueue = [SELECT Id, Queue.Name 
                                                FROM QueueSobject 
                                                WHERE SobjectType = 'Case' 
                                                AND QueueId = :selectedQueueId];
                // Tejasvi -> I2RT-4547 --> Queue vs Picklist Value Disparity
                //--------------------------------------------------------------
                // GET DESCRIBE --> Monitoring Queue Picklist Field
                Schema.DescribeFieldResult monitoringQueueField = Case.Product_Queues__c.getDescribe();
                // GET PICKLIST VALUES --> Monitoring Queue Picklist Field Values
                List<Schema.PicklistEntry> monitoringQueuePicklistValues = monitoringQueueField.getPicklistValues();
                // List of Picklist Labels
                List<String> monitoringQueuePicklistLabels = new List<String>();
                // FOR EACH: Picklist Value, add its Label to the List of Picklist Labels above
                for(Schema.PicklistEntry pickListVal : monitoringQueuePicklistValues) {
                    monitoringQueuePicklistLabels.add(pickListVal.getLabel());
                }
                // IF List of Picklist Labels CONTAINS Queue Name THEN assign to field ELSE assign 'null'
                caseToUpdate.Product_Queues__c = monitoringQueuePicklistLabels.contains(selectedQueue.Queue.Name) ? selectedQueue.Queue.Name : null;
                //--------------------------------------------------------------
                caseToUpdate.Product_Queue_ID__c = selectedQueueId;
                caseToUpdate.isDirectHandoff__c = false;
                caseToUpdate.Follow_Sun_Model_Support__c = true;
                caseToUpdate.Inbound_comment__c = false;
                caseToUpdate.Escalation_Attention__c = false; // Tejasvi -> I2RT-4568: Change in Inbound Activity on Escalation and Attention Request
                caseToUpdate.Monitoring_Enabled__c = true; // Transferred from Case Main Process (Process Builder)
                caseToUpdate.Monitoring_Start_Time__c = System.now(); //I2RT-4787
                UPDATE caseToUpdate;
            }
            when 'Weekend/Holiday Monitoring' {
                caseToUpdate.Weekend_Holiday_Support__c = true;

                caseToUpdate.isDirectHandoff__c = false;
                caseToUpdate.Follow_Sun_Model_Support__c = false;
                caseToUpdate.Monitoring_Enabled__c = false;
                caseToUpdate.Product_Queue_ID__c = null;
                caseToUpdate.Product_Queues__c = null;

                // Save Support Start & End Date/Times
                supportStartDateTime = supportStartDateTime.replace('T', ' ');
                supportStartDateTime = supportStartDateTime.removeEnd('Z');
                caseToUpdate.Support_Start_DateTime__c = Datetime.valueOfGmt(supportStartDateTime); //SAVE AS 'GMT' ONLY!
                
                supportEndDateTime = supportEndDateTime.replace('T', ' ');
                supportEndDateTime = supportEndDateTime.removeEnd('Z');
                caseToUpdate.Support_End_DateTime__c = Datetime.valueOfGmt(supportEndDateTime); //SAVE AS 'GMT' ONLY!
                
                UPDATE caseToUpdate;
            }
        }
        //==== DEPRECATED ====
        /* switch on handoffType {
            when 'Live Handoff' {
                caseToUpdate.OwnerId = selectedUserId;
                UPDATE caseToUpdate;
            }
            when 'Queue Handoff' {
                caseToUpdate.OwnerId = selectedId;
                UPDATE caseToUpdate;
            }
            when 'Monitor Case' {
                caseToUpdate.Product_Queue_ID__c = selectedQueueId;
                caseToUpdate.Follow_Sun_Model_Support__c = true;
                caseToUpdate.Inbound_comment__c = false;
                UPDATE caseToUpdate;
            }
            when 'Holiday Monitoring' {
                caseToUpdate.Holiday_Support__c = true;
                
                // Save Holiday Start & End Date/Times
                holidayStartDateTime = holidayStartDateTime.replace('T', ' ');
                holidayStartDateTime = holidayStartDateTime.removeEnd('Z');
                caseToUpdate.Holiday_Start_DateTime__c = Datetime.valueOfGmt(holidayStartDateTime); //SAVE AS 'GMT' ONLY!
                
                holidayEndDateTime = holidayEndDateTime.replace('T', ' ');
                holidayEndDateTime = holidayEndDateTime.removeEnd('Z');
                caseToUpdate.Holiday_End_DateTime__c = Datetime.valueOfGmt(holidayEndDateTime); //SAVE AS 'GMT' ONLY!
                UPDATE caseToUpdate;
            }
            when 'Weekend Monitoring' {
                caseToUpdate.Weekend_Support__c = true;
                
                // Save Weekend Start & End Date/Times
                weekendStartDateTime = weekendStartDateTime.replace('T', ' ');
                weekendStartDateTime = weekendStartDateTime.removeEnd('Z');
                caseToUpdate.Weekend_Start_DateTime__c = Datetime.valueOfGmt(weekendStartDateTime); //SAVE AS 'GMT' ONLY!
                
                weekendEndDateTime = weekendEndDateTime.replace('T', ' ');
                weekendEndDateTime = weekendEndDateTime.removeEnd('Z');
                caseToUpdate.Weekend_End_DateTime__c = Datetime.valueOfGmt(weekendEndDateTime); //SAVE AS 'GMT' ONLY!
                UPDATE caseToUpdate;
            }
        } */

        // Create a Raise Hand Record for Handoffs
        Raise_Hand__c raiseHand = new Raise_Hand__c();
        raiseHand.Name = handoffType + '-' + caseToUpdate.CaseNumber;
        raiseHand.Case__c = recordId;
        raiseHand.Type__c = 'Handoff';
        raiseHand.Urgency__c = 'High';
        raiseHand.Description__c = handoffType + ' has been initiated for Case ' + caseToUpdate.CaseNumber;
        raiseHand.Status__c = (handoffType == 'Live/Queue Handoff') ? 'Closed' : 'In Progress'; // Tejasvi -> I2RT-4292: Close Collaborations after Handoff/Monitoring is completed
        INSERT raiseHand;

        // Adding a Case Comment as Handoff Summary (Category)      
        Case_Comment__c cc = new Case_Comment__c();
        cc.Case__c = recordId;
        cc.Inbound__c = false;
        cc.Status__c = 'Submitted';
        cc.Type__c = 'Raise Hand';
        cc.Visibility__c = 'Internal';
        cc.Comment_Category__c = 'Handoff Summary';
        cc.Comment__c = 'Steps Taken: ' + handoffSteps + '<br />' + 'Handoff Comments: ' + handoffComments;
        //cc.Comment_to_Search__c = 'Steps Taken: ' + handoffSteps + ' Handoff Comments: ' + handoffComments;
        INSERT cc;
    }
    
    // Tejasvi Royal -> Feedback/Enhancement through Business Demo (29 July 2021)
    // Last Modified Date: 29 July 2021
    // Last Modified By: Tejasvi Royal
    // Calculate and show Weekend/Holiday Support Date/Times, by adding 'n' days to Start Date
    @AuraEnabled
    public static List<String> calculateWHSupportDateTimes(String daysToAddStr) {     

        // Querying the 'Weekend_Holiday_Support_Settings' Metadata Record
        Service_Cloud_General_Setting__mdt mdtWeekendSupport = [SELECT Weekend_Holiday_Support_Start_Time__c, Weekend_Holiday_Support_End_Time__c 
                                                                FROM Service_Cloud_General_Setting__mdt 
                                                                WHERE DeveloperName = 'Weekend_Holiday_Support_Settings'
                                                                LIMIT 1];
        
        // Extracting & Storing the Metadata Record values in Variables
        String mdtStartTime = mdtWeekendSupport?.Weekend_Holiday_Support_Start_Time__c;
        mdtStartTime = mdtStartTime <> null ? mdtStartTime : '18:00:00';
        System.debug('mdtStartTime --> ' + mdtStartTime);
        String mdtEndTime = mdtWeekendSupport?.Weekend_Holiday_Support_End_Time__c;
        mdtEndTime = mdtEndTime <> null ? mdtEndTime : '08:00:00';
        System.debug('mdtEndTime --> ' + mdtEndTime);
        
        // Getting current Date/Time
        Datetime userDT = Datetime.now(); // System.now(); // Making GMT as standard for User Date/Time
        System.debug('userDT --> ' + userDT);
        
        // Converting String to Date/Time, preserving User Timezone
        userDT = Datetime.valueOf(userDT.format('yyyy-MM-dd') + ' ' +  mdtStartTime);
        System.debug('userDT for Start --> ' + userDT);
        
        // Creating string for Start of Upcoming Weekend -> Returning GMT for correct display
        String supportWHStartDTStr = userDT.formatGmt('yyyy-MM-dd') + 'T' + userDT.formatGmt('HH:mm:ss') + 'Z'; 
        
        // Converting Custom String to Date/Time, preserving User Timezone
        userDT = Datetime.valueOf(userDT.format('yyyy-MM-dd') + ' ' +  mdtEndTime);
        System.debug('userDT for End --> ' + userDT);
        
        Integer daysToAdd = Integer.valueof(daysToAddStr);
        userDT = userDT.addDays(daysToAdd);

        // Creating string for End of Upcoming Weekend -> Returning GMT for correct display
        String supportWHEndDTStr = userDT.formatGmt('yyyy-MM-dd') + 'T' + userDT.formatGmt('HH:mm:ss') + 'Z'; 

        // Creating a List of values and returning it
        List<String> supportWHDateTimes = new List<String>();
        supportWHDateTimes.add(supportWHStartDTStr);
        supportWHDateTimes.add(supportWHEndDTStr);
        
        return supportWHDateTimes;
    }

    //==== DEPRECATED FUNCTIONS ====
    //------------------------------------------------------------------------------
    // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    // Last Modified Date: 31 May 2021
    // Last Modified By: Tejasvi Royal
    // Search Method for Custom Lookup Component
    /*
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> lookupUserSearch(String searchTerm, List<String> selectedIds) {
        // Prepare query parameters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN NAME FIELDS
            RETURNING
                User(Id, Name, Title WHERE Id NOT IN :selectedIds)
            LIMIT 10
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Users & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User u : users) {
            String subtitle = u.Title == null ? '' : + u.Title;
            results.add(new LookupSearchResult(u.Id, 'User', userIcon, u.Name, subtitle));
        }

        // Sort all results on title
        results.sort();

        return results;
    }
    */

    // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Notifications
    // Last Modified Date: 8 July 2021
    // Last Modified By: Tejasvi Royal
    // Calculate and show upcoming Weekend Date/Times
    /*
    @AuraEnabled
    public static List<String> upcomingWeekendDateTimes() {     

        // Querying the 'Weekend_Holiday_Support_Settings' Metadata Record
        Service_Cloud_General_Setting__mdt mdtWeekendSupport = [SELECT Weekend_Support_Start_Day__c, Weekend_Support_End_Day__c, 
                                                                Weekend_Support_Start_Time__c, Weekend_Support_End_Time__c 
                                                                FROM Service_Cloud_General_Setting__mdt 
                                                                WHERE DeveloperName = 'Weekend_Holiday_Support_Settings'
                                                                LIMIT 1];
        
        // Extracting & Storing the Metadata Record values in Variables
        String mdtStartDay = mdtWeekendSupport.Weekend_Support_Start_Day__c;
        System.debug('mdtStartDay --> ' + mdtStartDay);
        String mdtEndDay = mdtWeekendSupport.Weekend_Support_End_Day__c;
        System.debug('mdtEndDay --> ' + mdtEndDay);
        String mdtStartTime = mdtWeekendSupport.Weekend_Support_Start_Time__c;
        System.debug('mdtStartTime --> ' + mdtStartTime);
        String mdtEndTime = mdtWeekendSupport.Weekend_Support_End_Time__c;
        System.debug('mdtEndTime --> ' + mdtEndTime);
        
        // Getting current Date/Time
        Datetime nowDT = Datetime.now(); // System.now();
        System.debug('nowDT --> ' + nowDT);      
        //DEPRECATED:
        // Formatting it as String, according to User Timezone
        //String userDTStr = nowDT.format('yyyy-MM-dd HH:mm:ss');
        //System.debug('userDTStr --> ' + userDTStr);  
        // Converting String to Date/Time, preserving User Timezone
        //Datetime userDT = Datetime.valueOfGmt(userDTStr);
        //System.debug('userDT --> ' + userDT);    

        Datetime userDT = nowDT; // Making GMT as standard for User Date/Time
        System.debug('userDT --> ' + userDT);
        // Extracting 'Day', from Date/Time in User Timezone
        String dayTodayStr = nowDT.format('EEEE');
        System.debug('dayTodayStr --> ' + dayTodayStr);
 
        // Execute loop till Weekend Support Start Date
        while (!dayTodayStr.equals(mdtStartDay)) {
            userDT = userDT.addDays(1);
            System.debug('userDT in loop 1 --> ' + userDT);
            dayTodayStr = userDT.format('EEEE');
            System.debug('dayTodayStr in loop 1 --> ' + dayTodayStr);
        }
        
        // Converting String to Date/Time, preserving User Timezone
        userDT = Datetime.valueOf(userDT.format('yyyy-MM-dd') + ' ' +  mdtStartTime);
        System.debug('userDT after Opr 1 --> ' + userDT);
        
        // Creating string for Start of Upcoming Weekend -> Returning GMT for correct display
        String upcomingWeekendStart = userDT.formatGmt('yyyy-MM-dd') + 'T' + userDT.formatGmt('HH:mm:ss') + 'Z'; 
        
        // Execute loop till Weekend Support End Date
        while (!dayTodayStr.equals(mdtEndDay)) {
            userDT = userDT.addDays(1);
            System.debug('userDT in loop 2 --> ' + userDT);
            dayTodayStr = userDT.format('EEEE'); 
            System.debug('dayTodayStr in loop 1 --> ' + dayTodayStr);
        }
        
        // Converting Custom String to Date/Time, preserving User Timezone
        userDT = Datetime.valueOf(userDT.format('yyyy-MM-dd') + ' ' +  mdtEndTime);
        System.debug('userDT after Opr 2 --> ' + userDT);
        
        // Creating string for End of Upcoming Weekend -> Returning GMT for correct display
        String upcomingWeekendEnd = userDT.formatGmt('yyyy-MM-dd') + 'T' + userDT.formatGmt('HH:mm:ss') + 'Z'; 

        // Creating a List of values and returning it
        List<String> weekendDateTimes = new List<String>();
        //weekendDateTimes.add(upcomingWeekendStart);
        //weekendDateTimes.add(upcomingWeekendEnd);
        
        return weekendDateTimes;
    }
    */

    // Tejasvi Royal -> Feedback/Enhancement through Demo
    // Last Modified Date: 23 July 2021
    // Last Modified By: Tejasvi Royal
    // Calculate and show current Datetime
    /*
    private static String currentUserDateTime() {
        
        Datetime nowDT = Datetime.now(); // System.now();

        String currentUserDT = nowDT.formatGmt('yyyy-MM-dd') + 'T' + nowDT.formatGmt('HH:mm:ss') + 'Z';

        return currentUserDT;
    }
    */

    // Tejasvi Royal -> Feedback/Enhancement through Demo
    // Last Modified Date: 23 July 2021
    // Last Modified By: Tejasvi Royal
    // Calculate and show Datetime by adding 'n' days
    /*
    private static String addDaysToDateTime(String userDTStr, String daysToAddStr) {

        userDTStr = userDTStr.replace('T', ' ');
        userDTStr = userDTStr.removeEnd('Z');
        
        Datetime userDT = Datetime.valueOfGmt(userDTStr);
        Integer daysToAdd = Integer.valueof(daysToAddStr);
        Datetime nowDT = userDT.addDays(daysToAdd);
        String currentDTStr = nowDT.formatGmt('yyyy-MM-dd') + 'T' + nowDT.formatGmt('HH:mm:ss') + 'Z';

        return currentDTStr;
    }
    */
}