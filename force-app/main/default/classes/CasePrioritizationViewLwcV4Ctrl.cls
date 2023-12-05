/*
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4953   T01     added I am On/Off it functionalities
Vignesh D       11/24/2021  I2RT-4417   T02     Update Target Close Datetime format shown in SALT View
Sandeep Duggi   Feb 12 2022 I2RT-5101   T03     SALT - Add additional color coding for Case waiting on Case Team
Amit Garg		09/20/2022  I2RT-7109   T04     SALT - Add additional color coding for Customer Next action with p1 priority
Sandeep Duggi   Nov 1 2022  I2RT-6980   T05     SALT Updates for Collaborators and CREs
balajip         01/09/2023  I2RT-7628   T06     To include the Cases Co-owned as a result of the Swap Ownership use case.
balajip         01/12/2023  I2RT-7282   T07     To include two more fields in the Collaboration table.
Sandeep Duggi   Oct 17 '23  I2RT-9219   T08     P0 Flag - SALT enhancements

*/

public without sharing class CasePrioritizationViewLwcV4Ctrl {

    //Legend.
        public static Decimal transparency = 0.2;
    public static Map<String, String> mapColorCodes = new Map<String, String> {
        'Escalation' => '255, 0, 0',
        'P1 Priority' => '255, 131, 131',
        'Inactive Case' => '0, 18, 255',
        'Missed Milestone' => '175, 181, 255',
        'Waiting on Case Owner' => '244, 255, 58',
        'Waiting on Customer' => '49, 190, 65',
        'Waiting on Case Team' => '238, 232, 170'
    };
    public String strHTMLCode {
        get {
            return getColorLegend();
        }
    }
    
    /*
     Method Name : getColorLegend
     Description : This method returns the Color Legend, in RGB format.
     Parameters  : None
     Return Type : Map
     */
    @AuraEnabled(cacheable = true)
    public static String getColorLegend() {
        String strHTMLCode = '';
        strHTMLCode += '';
        strHTMLCode += '<table>';
        strHTMLCode += '    <thead>';
        strHTMLCode += '        <tr>';
        strHTMLCode += '            <th>Case Prioritization Code</th>';
        strHTMLCode += '            <th>Representation</th>';
        strHTMLCode += '        </tr>';
        strHTMLCode += '    </thead>';
        strHTMLCode += '    <tbody>';
        for(String strCode : mapColorCodes.keySet()) {
            strHTMLCode += '        <tr>';
            strHTMLCode += '            <td style="background-color: rgb(' + mapColorCodes.get(strCode) + ', ' + transparency + ');"></td>';
            strHTMLCode += '            <td>' + strCode + '</td>';
            strHTMLCode += '        </tr>';
        }
        strHTMLCode += '    </tbody>';
        strHTMLCode += '</table>';
        strHTMLCode += '<style type="text/css">';
        strHTMLCode += '    .legendHTML td, .legendHTML th {';
        strHTMLCode += '        font-family: Arial, sans-serif;';
        strHTMLCode += '        padding: 10px 17px;';
        strHTMLCode += '    }';
        strHTMLCode += '    .legendHTML th {';
        strHTMLCode += '        font-weight: bold;';
        strHTMLCode += '    }';
        strHTMLCode += '</style>';
        return strHTMLCode;
    }

    public static DataResultWrapper oDataResultWrapper;

    @AuraEnabled(cacheable=true)
    public static ViewInfoWrap  fetchListView(){
        ViewInfoWrap vi = new ViewInfoWrap();
        vi.AllViews= [SELECT Id, Name, DeveloperName, SobjectType FROM ListView WHERE sobjectType ='Case' ORDER by DeveloperName Asc];
        string pinnedView = 'RecentlyViewedCases';
        list<string> selectedViews = new list<string>();
        list<GCS_Subscription__c> info =[select id, Pinned_View__c, Case_Views__c, Engineering_Workspace_List_View_Sort__c from GCS_Subscription__c where createdbyid =: userinfo.getUserId() and 
                (Pinned_View__c != null OR Case_Views__c != null) limit 1];
        if(!info.isEmpty()){
            if(info[0].Pinned_View__c != null){
                pinnedView = info[0].Pinned_View__c;
            }
            if(String.isNotBlank(info[0].Engineering_Workspace_List_View_Sort__c)) {
                selectedViews = info[0].Engineering_Workspace_List_View_Sort__c.split(';');
            } else if(info[0].Case_Views__c != null){
                selectedViews = info[0].Case_Views__c.split(';');
            }
        }
        vi.UserViews = new list<listView>();
        if(selectedViews.size() == 0){
            selectedViews.add('RecentlyViewedCases');
        }
        for(listView lv : vi.AllViews ){
            if(selectedViews.contains(lv.developername)){
                vi.UserViews.add(lv);
            }
        }
        vi.pinnedPost = pinnedView ;
        vi.selectedValues = selectedViews;
        return vi;
    }
    
   @AuraEnabled(cacheable=false)
     public static DataResultWrapper Caseview(string sUserId){
          oDataResultWrapper = new DataResultWrapper();
           string idval = (sUserId != null ? sUserId : UserInfo.getUserId());
           oDataResultWrapper.showloggedinas = false;
    
           oDataResultWrapper.caseWrapper = new List<CaseWrapper>();
           
           oDataResultWrapper.caseIds = new List<Id>();
 
           oDataResultWrapper.egList = new List<EngineerGradient>();
 
        
         oDataResultWrapper.casePosition = 0;
         User usr = [Select Id, Profile.Name,Name, Email, GCS_Team__c from User where Id =:idval];
        // User loggeduser = [Select Id,Profile.Name from User where Id = :UserInfo.getUserId()];
       // System.debug('usr-->'+usr);
        oDataResultWrapper.selectedusername = usr.Name;
         /*if(loggeduser.Profile.Name == Label.INFA_GCS_Admin || loggeduser.Profile.Name == Label.INFA_GCS_Management){
             ismanager = true;
         }*/
         
         oDataResultWrapper.userName = usr.Name ;
         oDataResultWrapper.userTeam = usr.GCS_Team__c;
         oDataResultWrapper.userEmail = usr.Email;
         oDataResultWrapper.bh = [SELECT SundayStartTime, MondayStartTime, TuesdayStartTime,WednesdayStartTime, ThursdayStartTime, FridayStartTime,SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
                                 FROM BusinessHours
                                 WHERE Name = :Label.GMT_Business_hours ];//T02
         oDataResultWrapper.bdc = new BusinessDaysCalculation(null,false,oDataResultWrapper.bh); //T02
         oDataResultWrapper.todaydateGMT = date.newinstance(system.now().dateGMT().year(), system.now().dateGMT().month(), system.now().dateGMT().day());            
         //------------------------------------------------------------------<T01 Added 'Complete' in condition>
         // T08 added new field in query 
         Map<Id, Case> csList = new Map<Id, Case>([Select Id,Is_Internal_Or_External_Case__c, Last_activity_time__c,OwnerId,Owner.Name,LastModifiedById,CaseNumber, Priority, RecordType.Name, Subject,
                                                   Case_InActive__c, Expert_Assistance_Requested_Date__c, IsEscalated, Days_to_Close_Date__c, Case_Last_Activity__c,
                                                   GCS_AAE_Session_Time__c,Forecast_Product__c, Case_Weightage_Calc__c, Case_Timezone__r.Name, Next_Action__c, Status,
                                                   Account.Name, Contact.Name,   DateTime_to_Close__c, Case_Weightage__c, Case_Weightage__r.Name,
                                                   Case_Weightage__r.Weightage__c,Product.Name,contactId,contact.Email,contact.Phone,Case_Timezone__c,Resolution_Target_DateTime__c,Case_Weightage__r.Full_Case_Weightage__c,P0_Enabled_By__c
                                                   From Case
                                                   WHERE OwnerId =: idval 
                                                   AND Status NOT IN ('Resolved','Closed', 'Cancelled', 'Delivered','Complete')
                                                   ORDER BY Case_Weightage_Calc__c DESC NULLS LAST, Case_Weightage__r.Full_Case_Weightage__c DESC NULLS LAST]);
         
         //system.debug('@@results from query '+Json.serializePretty(csList));
         //system.debug('@@results from query  '+Json.serializePretty(csList.size()));
         //T05 starts
         List<SortCasesWithWeightages> records = new List<SortCasesWithWeightages>();
         decimal totalweightage;
         for(Id c : csList.keySet()){
             if((csList.get(c).Next_Action__c == 'PS Team' || csList.get(c).Next_Action__c == 'Case Team' ||csList.get(c).Next_Action__c == 'Multi Team' || csList.get(c).Next_Action__c == 'Operations Team') && csList.get(c).Case_Weightage__r.Full_Case_Weightage__c != null){ 
               csList.get(c).Case_Weightage__r.Full_Case_Weightage__c = Math.round(csList.get(c)?.Case_Weightage__r.Full_Case_Weightage__c * .5) ;  
               totalweightage = csList.get(c).Case_Weightage__r.Full_Case_Weightage__c;
               records.add(new SortCasesWithWeightages(csList.get(c),totalweightage));
             }
             else if(csList.get(c).Case_Weightage__r.Full_Case_Weightage__c == null || csList.get(c).Case_Weightage__r == null ){
                 totalweightage = 0;
                 records.add(new SortCasesWithWeightages(csList.get(c),totalweightage));
             }
             else{
                  totalweightage = csList.get(c).Case_Weightage__r.Full_Case_Weightage__c;
                  records.add(new SortCasesWithWeightages(csList.get(c),totalweightage));
             }
             
         }
        // system.debug('@@records size after logic and before sort  '+Json.serializePretty(records.size()));
        // system.debug('@@records before sort  '+Json.serializePretty(records));
         records.sort();
        //  system.debug('@@records after sort  '+Json.serializePretty(records));
         csList.clear();
         for (SortCasesWithWeightages rec : records){
              //system.debug('@@ sorted individual weightgae  '+Json.SerializePretty(rec.cs.Case_Weightage__r.Full_Case_Weightage__c));
              //system.debug('@@ sorted case Numbers  '+Json.SerializePretty(rec.cs.CaseNumber));
              csList.put(rec.cs.id, rec.cs);
             
         }
        // system.debug('@@cslist after sort  '+Json.serializePretty(csList));
         //T05 ends
         //Deva Commented to Exclude CaseTeamMember         
        /* map<string,CaseTeamMember> caseWiseCaseTeamMember = new map<string,CaseTeamMember>();
         set<string> setCaseIdFromCaseTeam = new set<string>();
             for(CaseTeamMember ctm : [Select id,parentId,MemberId,Member.Name,TeamRole.Name 
                                       From CaseTeamMember 
                                       WHERE MemberId =: idval AND parent.ownerId != :idval]){
               setCaseIdFromCaseTeam.add(ctm.parentId);   
               caseWiseCaseTeamMember.put(ctm.parentId ,ctm);        
         }*/

         //Deva convert above commented logic to accomdate custom case team logic
         Map<String,Case_Team__c> caseWiseCaseTeamMember = new Map<String,Case_Team__c>();
         set<string> setCaseIdFromCaseTeam = new set<string>();
         for(Case_Team__c ctm : [Select id,Case__c,User__c ,User__r.Name,Role__c 
                                       From Case_Team__c 
                                       WHERE User__c =: idval AND Case__r.ownerId != :idval  and Role__c != 'Owner']){
                                        setCaseIdFromCaseTeam.add(ctm.Case__c);   
                                        caseWiseCaseTeamMember.put(ctm.Case__c ,ctm);   
                                       }
         //T05 starts 
         List<SortCasesWithWeightages> coownRecords = new List<SortCasesWithWeightages>();
         Map<Id, Case> csListAsTeamMemeber = new Map<Id, Case>([Select Id,Is_Internal_Or_External_Case__c, Last_activity_time__c,OwnerId,Owner.Name,LastModifiedById,CaseNumber, Priority, RecordType.Name, Subject,
                                                                    Case_InActive__c, Expert_Assistance_Requested_Date__c, IsEscalated, Days_to_Close_Date__c, Case_Last_Activity__c,
                                                                    GCS_AAE_Session_Time__c,Forecast_Product__c, Case_Weightage_Calc__c, Case_Timezone__r.Name,Next_Action__c, Status,
                                                                    Account.Name, Contact.Name,   DateTime_to_Close__c, Case_Weightage__c, Case_Weightage__r.Name,Case_Weightage__r.Full_Case_Weightage__c,
                                                                    Case_Weightage__r.Weightage__c,Product.Name,contactId,contact.Email,contact.Phone,Case_Timezone__c,Resolution_Target_DateTime__c,P0_Enabled_By__c
                                                                    From Case
                                                                    WHERE Id IN : setCaseIdFromCaseTeam  
                                                                    AND Status NOT IN ('Resolved','Closed', 'Cancelled', 'Delivered','Complete')
                                                                    ORDER BY Case_Weightage_Calc__c DESC NULLS LAST, Case_Weightage__r.Full_Case_Weightage__c DESC NULLS LAST]);
         //system.debug('@@from query results'+Json.SerializePretty(csListAsTeamMemeber));
         Map<Id, Raise_Hand__c> collabCasesMap = new Map<Id, Raise_Hand__c>();
         List<Raise_Hand__c> collabCases = [SELECT Subtype__c, Type__c , Accepted_By__c,Case__c,Skill__c  FROM Raise_Hand__c WHERE Accepted_By__c =: idval];
         for(Raise_Hand__c o : collabCases)
         {
            collabCasesMap.put(o.Case__c, o);
         }
         // system.debug('@@ collabCasesMap'+Json.SerializePretty(collabCasesMap));
         // comparing if raisehand record is present for the case which are not owned by current user  
         //T06 refactored the code
         for (Id caseId : csListAsTeamMemeber.keySet()) {
            //system.debug('@@ caseId'+Json.SerializePretty(csListAsTeamMemeber.get(caseId)));
            Case cse = csListAsTeamMemeber.get(caseId);
            totalweightage = 0;
            if(cse.Case_Weightage__r != null && cse.Case_Weightage__r.Full_Case_Weightage__c != null){
                totalweightage = cse.Case_Weightage__r.Full_Case_Weightage__c;
                if(collabCasesMap.containsKey(caseId)){
                    Raise_Hand__c collabRec = collabCasesMap.get(caseId) ; 
                    system.debug('@@csListAsTeamMemeber'+cse.Next_Action__c);

                    if((cse.Next_Action__c != 'PS Team' && collabRec.Subtype__c == 'PS Review')
                        || (cse.Next_Action__c != 'Multi Team' && collabRec.Subtype__c == 'Multi Product')
                        || (cse.Next_Action__c != 'Operations Team' && collabRec.Subtype__c == 'Operations')){

                        totalweightage = Math.round(totalweightage * 0.5);
                    }
                //T06 no collab request found. the user became co-owner as a result of Swap Ownership
                }else{
                    //apply weightage multiplier of 0.5
                    totalweightage = Math.round(totalweightage * 0.5);
                }
            }

            coownRecords.add(new SortCasesWithWeightages(cse, totalweightage));
         }
         coownRecords.sort();
         csListAsTeamMemeber.clear();
         for (SortCasesWithWeightages rec : coownRecords){
             //system.debug('@@rec'+Json.SerializePretty(rec));
              csListAsTeamMemeber.put(rec.cs.Id, rec.cs);
         }
         
         //T05 ends 
         csList.putAll(csListAsTeamMemeber);
       
         List<CaseMilestone> cmList = [Select Id, CaseId, MilestoneType.Name,TargetDate, TimeRemainingInMins, IsCompleted, IsViolated
                                       FROM CaseMilestone
                                       WHERE CaseId IN: csList.keySet()
                                       AND IsCompleted = False 
                                       ORDER BY TargetDate DESC];
         Map<Id, CaseMilestone> cmMap = new Map<Id, CaseMilestone>();
         for(CaseMilestone cm : cmList){
             if(cmMap == null || cmMap.get(cm.CaseId) == null){
                cmMap.put(cm.CaseId, cm);
             }
             else if(cmMap.get(cm.CaseId) != null && cmMap.get(cm.CaseId).TargetDate > cm.TargetDate){
                 cmMap.put(cm.CaseId, cm); 
             }
         }
         
         if(csList.IsEmpty() && !Test.isRunningTest()){
             oDataResultWrapper.hasCases = False;
         }else{
             oDataResultWrapper.hasCases = True;
             List<Case> egCase = new List<Case>();
             for(Case cs : csList.values()){
                 //system.debug('@@ cs'+Json.serializePretty(CS));
                 oDataResultWrapper.casePosition = oDataResultWrapper.casePosition + 1;
                 CaseWrapper cw = new CaseWrapper();
                 cw.position = oDataResultWrapper.casePosition;
                 cw.cs = cs;
                 cw.hasOwnedCase = cs.OwnerId == idval ? true : false;
                 if(cs.OwnerId != idval){
                     if(caseWiseCaseTeamMember.containskey(cs.Id) && caseWiseCaseTeamMember.get(cs.Id)!=null 
                        && String.isNotBlank(caseWiseCaseTeamMember.get(cs.Id).Role__c)){
                        //Deva Commented to Exclude CaseTeamMember
                        //cw.caseTeamMemberRole = caseWiseCaseTeamMember.get(cs.Id).TeamRole.Name;
                        //Deva convert above commented logic to accomdate custom case team logic
                        cw.caseTeamMemberRole = caseWiseCaseTeamMember.get(cs.Id).Role__c;
                     }
                 }
                
                 if(cs.Subject == null){
                    cw.Subject = '';
                 }
                 else{
                    list<string> lstSubjectText = cs.Subject.split(' ');
                    if(lstSubjectText.size() > 0){ 
                           System.debug('===> ' + lstSubjectText[0].length());
                        if(lstSubjectText[0].length() > 20){
                            cw.Subject = lstSubjectText[0].left(20) + '...';
                        }else{
                            cw.Subject = cs.Subject == null ? '' : cs.Subject.length() > 60 ? cs.Subject.substring(0, 60) + '...' : cs.Subject;
                        }
                    }
                 }
                //// cw.Subject = cs.Subject == null ? '' : cs.Subject.length() > 60 ? cs.Subject.substring(0, 60) + '...' : cs.Subject;
                 cw.AccountName = cs.Account == null ? '' : cs.Account.Name.length() > 15 ? cs.Account.Name.substring(0, 15) + '...' : cs.Account.Name;
                 cw.ContactName = cs.Contact == null ? '' : cs.Contact.Name.length() > 10 ? cs.Contact.Name.substring(0, 10) + '...' : cs.Contact.Name;
                 //cw.ProjectName = cs.Project__c == null ? '' : cs.Project__r.Name.length() > 15 ? cs.Project__r.Name.substring(0, 15) + '...' : cs.Project__r.Name;
                 cw.Timezone = cs.Case_Timezone__c == null ? '' : cs.Case_Timezone__r.Name.length() > 35 ? cs.Case_Timezone__r.Name.substring(0, 35) + '...' : cs.Case_Timezone__r.Name;
                 cw.Product = cs.Forecast_Product__c == null ? '' : cs.Forecast_Product__c.length() > 20 ? cs.Forecast_Product__c.substring(0, 20) + '...' : cs.Forecast_Product__c;
                 cw.NextAction =  cs.Next_Action__c == null ? '' : cs.Next_Action__c;
                 cw.P0Enabled =  cs.P0_Enabled_By__c == null ? false : true;
                 // 24 may 2021 start
                 String stTargetCloseDate='';
                if(cs!=null && cs.Resolution_Target_DateTime__c!=null)
                {
                    Integer min=cs.Resolution_Target_DateTime__c.minute();
                    Integer hour=cs.Resolution_Target_DateTime__c.hour();
            // stTargetCloseDate= cs.Resolution_Target_DateTime__c.monthGmt()+'/'+cs.Resolution_Target_DateTime__c.dayGmt()+' '+cs.Resolution_Target_DateTime__c.hourGmt()+':'+cs.Resolution_Target_DateTime__c.minuteGmt();
           if(min!=null && String.valueOf(min)!=null  )
                     {
                         if((String.valueOf(min)).length() ==1)
                         {
                             if(hour!=null && String.valueOf(hour)!=null && (String.valueOf(hour)).length() ==1)
                             {
                                 stTargetCloseDate= cs.Resolution_Target_DateTime__c.format('dd')+'-'+cs.Resolution_Target_DateTime__c.format('MMM').toUpperCase()+' 0'+cs.Resolution_Target_DateTime__c.hour()+':0'+cs.Resolution_Target_DateTime__c.minute(); // <T02>
                             }else
                             {
                                 stTargetCloseDate= cs.Resolution_Target_DateTime__c.format('dd')+'-'+cs.Resolution_Target_DateTime__c.format('MMM').toUpperCase()+' '+cs.Resolution_Target_DateTime__c.hour()+':0'+cs.Resolution_Target_DateTime__c.minute(); // <T02>
                             }
                             
                         }else
                         {
                             if(hour!=null && String.valueOf(hour)!=null && (String.valueOf(hour)).length() ==1)
                             {
                                 stTargetCloseDate= cs.Resolution_Target_DateTime__c.format('dd')+'-'+cs.Resolution_Target_DateTime__c.format('MMM').toUpperCase()+' 0'+cs.Resolution_Target_DateTime__c.hour()+':'+cs.Resolution_Target_DateTime__c.minute(); // <T02>
                             }else
                             {
                                 stTargetCloseDate= cs.Resolution_Target_DateTime__c.format('dd')+'-'+cs.Resolution_Target_DateTime__c.format('MMM').toUpperCase()+' '+cs.Resolution_Target_DateTime__c.hour()+':'+cs.Resolution_Target_DateTime__c.minute(); // <T02>
                             }
                           // stTargetCloseDate= cs.Resolution_Target_DateTime__c.month()+'/'+cs.Resolution_Target_DateTime__c.day()+' '+cs.Resolution_Target_DateTime__c.hour()+':'+cs.Resolution_Target_DateTime__c.minute(); 
                         }
                     }
                    
             
                  //  System.debug('stTargetCloseDate-->'+stTargetCloseDate);
                      cw.TargetCloseDate=stTargetCloseDate;
                  //   System.debug('cw.TargetCloseDate-->'+cw.TargetCloseDate);
                }
                 // 24 may 2021 end 


                 //----------------------------------------------<T01 Replaced with datetime>
                 //Integer lastActivityDays = cs.Case_Last_Activity__c == null ? 0 : date.newinstance(cs.Case_Last_Activity__c.year(), cs.Case_Last_Activity__c.month(), cs.Case_Last_Activity__c.day()).daysBetween(System.Today());
                 //cw.LastActivityDateTime = lastActivityDays == 0 ? 'Today' : lastActivityDays == 1 ? 'Yesterday' : lastActivityDays + ' Days Ago';   //.format('MM/dd/yyyy, HH:mm', UserInfo.getTimeZone().getID());                               
                 
                 List<String> res = new List<String>();
                 String temp;
                 Boolean csinactive = FALSE; //T02
                 if(cs.Last_activity_time__c != null) {
                     System.debug('case last activity'+cs.Last_activity_time__c);
                     res = cs.Last_activity_time__c.split(' ');                   
                     if(integer.valueof(res[0]) > 0)
                         if(integer.valueof(res[0]) == 1) 
                         temp = res[0] + ' ' + 'day ago';                                                     
                     else {
                         temp = res[0] + ' ' + 'days ago';                         
                      }   
                     else if(integer.valueof(res[2]) > 0)    
                         if(integer.valueof(res[2]) == 1){
                             temp = res[2]  + ' ' + 'hour ago'; 
                            // cw.alertcolor = true;    
                         }                        
                         else 
                             temp = res[2]  + ' ' + 'hours ago';                                                   
                     else {
                         temp = res[4]  + ' ' + 'minutes ago';
                      //   
                     }
                 } else {
                     temp = ' ';                    
                 }  
              //<T03> 
                 if(cs.OwnerId!=null && cs.LastModifiedById!=null) 
                 { 
                     if(cs.caseNumber == '00001044'){
                        //System.debug('cs.OwnerId ' + cs.OwnerId + '<===>' + cs.LastModifiedById);
                     }
                     if(cs.OwnerId==cs.LastModifiedById)
                     {
                         //Last Activity is from case owner
                         cw.alertcolor = false;
                         
                     }else
                     {
                         cw.alertcolor = true;
                     }
                 }
                 
                 //</T03>
                 if(cs.Priority!=null && cs.Case_Last_Activity__c!=null){
                 if((cs.Priority == 'P1' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 2) < oDataResultWrapper.todaydateGMT) || (cs.Priority == 'P2' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 3) < oDataResultWrapper.todaydateGMT) || (cs.Priority == 'P3' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 4) < oDataResultWrapper.todaydateGMT)){
                     csinactive = TRUE; //T02
                 }
                 }
 
                 cw.LastActivityDateTime = temp;
                 //----------------------------------------------</T01>
                 cw.daysToCloseMessage = cs.Days_to_Close_Date__c == null ? '' : cs.Days_to_Close_Date__c != 'Expired' ? cs.Days_to_Close_Date__c +' Days more' : cs.Days_to_Close_Date__c;
                 cw.aaeSessionTime = cs.GCS_AAE_Session_Time__c == null ? '' : cs.GCS_AAE_Session_Time__c.substring(0, 35)+'...';
                 cw.isInactive = csinactive;//cs.Case_InActive__c;
                 //cw.RType = cs.RecordType.Name.contains('Collab') ? 'Collab' : cs.RecordType.Name == 'Technical' ? 'Technical' : cs.RecordType.Name == 'Administrative' ? 'Administrative' : 'Other';
                 cw.RType = cs.RecordType.Name;
                 cw.aaeDaysToGo = cs.Expert_Assistance_Requested_Date__c == null ? '' : System.Today().daysBetween(date.newinstance(cs.Expert_Assistance_Requested_Date__c.year(), cs.Expert_Assistance_Requested_Date__c.month(), cs.Expert_Assistance_Requested_Date__c.day())) > 1 ? System.Today().daysBetween(date.newinstance(cs.Expert_Assistance_Requested_Date__c.year(), cs.Expert_Assistance_Requested_Date__c.month(), cs.Expert_Assistance_Requested_Date__c.day())) + ' days to go' : System.Today().daysBetween(date.newinstance(cs.Expert_Assistance_Requested_Date__c.year(), cs.Expert_Assistance_Requested_Date__c.month(), cs.Expert_Assistance_Requested_Date__c.day())) == 1 ? 'Tomorrow' : System.Today().daysBetween(date.newinstance(cs.Expert_Assistance_Requested_Date__c.year(), cs.Expert_Assistance_Requested_Date__c.month(), cs.Expert_Assistance_Requested_Date__c.day())) < 0 ? 'Overdue' : 'Today';
                 if(cmMap.get(cs.Id) == null){
                     cw.activeMilestone = False;
                 }else{ 
                     cw.activeMilestone = True;
                     cw.timeRemaining = cmMap.get(cs.Id).TimeRemainingInMins;
                     cw.milestoneViolated = cmMap.get(cs.Id).IsViolated;
                     if(cw.milestoneViolated){
                         cw.milestoneMessage = 'Milestone Violated';
                     }else{
                         cw.milestoneMessage = cmMap.get(cs.Id).MilestoneType.Name == 'Initial Response' ? 'IR' : cmMap.get(cs.Id).MilestoneType.Name == 'Ongoing Response' ? 'OGR' : cmMap.get(cs.Id).MilestoneType.Name == 'Target Service Restoration' ? 'TSR' : cmMap.get(cs.Id).MilestoneType.Name == 'Case Resolution' ? 'CR' : '';
                         string message = '';
                         string timeValue = cmMap.get(cs.Id).TimeRemainingInMins.split(':')[0];
                         integer timeremaining = integer.valueOf(timeValue );
                         if(timeremaining >1440){
                             message = timeremaining/1440 + ' days ';
                         }
                         if(math.mod(timeremaining,1440) > 60){
                             message = message + (math.mod(timeremaining,1440))/60 + ' hours ';
                         }
                         message = message + math.mod(math.mod(timeremaining,1440),60);
                         cw.milestoneMessage = cw.milestoneMessage + ' Due in '+message+' minutes';
                     }
                 }
                 
                
                 
                 if(cs.Priority == 'P1'){
                     cw.showP1 = True;
                 }else if(cs.Priority == 'P2'){
                     cw.showP2 = True;
                 }else{
                     cw.showP3 = True;
                 }
                // System.debug('Calculating gradients for ' + cs.CaseNumber);
                 egCase.clear();
                 egCase.add(cs);
                 cw.egList = calculateGradients(egCase, cmList);
                 cw.lastGradientColor = oDataResultWrapper.lastGradientColor;
                 cw.lastGradientWidth = oDataResultWrapper.lastGradientWidth;
                 cw.lastGradientTitle = oDataResultWrapper.lastGradientTitle;
                 cw.bandChangeWidth =   oDataResultWrapper.bandChangeWidth;
                 System.debug('Gradient Size '+cw.egList.size());
                 oDataResultWrapper.caseWrapper.add(cw);
                 oDataResultWrapper.caseIds.add(cs.Id);
             }
             //calculateGradients(csList.values(), cmList);
         }
         return oDataResultWrapper;
     } 
       
    
     public class QueueRecordsWrapper{
         @AuraEnabled public list<case> lstQueueCase{get;set;}
         @AuraEnabled public list<case> lstQueueCaseWithoutFilter{get;set;}
         @AuraEnabled public list<Raise_Hand__c> lstQueueRaiseHand{get;set;}
         @AuraEnabled public list<Case_Comment__c> lstCaseComments{get;set;}        
         public QueueRecordsWrapper(){
             this.lstQueueCase = new list<case>();
             this.lstQueueCaseWithoutFilter = new list<case>();
             this.lstQueueRaiseHand = new list<Raise_Hand__c>();
             this.lstCaseComments = new list<Case_Comment__c>();
         }
      }     
 
      public class fetchCasesGroupByQueueWrapperResult{
        @AuraEnabled public map<id,QueueRecordsWrapper> mapGrpIdWiseRecordsData{get;set;}
        @AuraEnabled public boolean hasManagerPermission{get;set;}
        @AuraEnabled public String strUserId {get;set;}
         

      }
         @AuraEnabled(cacheable=false)
         Public static fetchCasesGroupByQueueWrapperResult  fetchCasesGroupByQueue(string sUserId){    
             
            fetchCasesGroupByQueueWrapperResult ofetchCasesGroupByQueueWrapperResult = new fetchCasesGroupByQueueWrapperResult();
             //system.debug('sUserId--> ' + sUserId);
             ofetchCasesGroupByQueueWrapperResult.strUserId = sUserId;
            
            set<string> setQueueDeveloperName = new set<string>();
            Set<String> setUserProfileSkillName  = new Set<String>();
            Set<String> setManagedProductName  = new Set<String>();//Deva : I2RT-3244 : to hold actual skill name
            map<string,string> mapQueueNameWiseProfileSkillName = new map<string,string>();
            map<string,ProfileSkillUser> mapQueueWiseProfileSkillUser = new map<string,ProfileSkillUser>();
            string sUId = sUserId != null ? sUserId : userinfo.getUserId() ;
            System.debug('sUId-->'+sUId);
             for(ProfileSkillUser oProfileSkillUser : [SELECT Id,Name,ProfileSkillId,
                                                            ProfileSkill.Name,ProfileSkill.Queue_Name__c,ProfileSkill.User_Questions__c,
                                                            ProfileSkill.Type__c, ProfileSkill.Product_Name__c,
                                                            Priority__c, Component__c, Timezone__c, Support_Level__c, Timezone_Region__c, Product__c
                                                       FROM ProfileSkillUser 
                                                       WHERE UserId =  : sUId
                                                       AND (Status__c = null OR Status__c = 'Approved')    
                                                       AND ProfileSkill.Queue_Name__c != null]){
                 setQueueDeveloperName.add(oProfileSkillUser.ProfileSkill.Queue_Name__c);
                 mapQueueNameWiseProfileSkillName.put(oProfileSkillUser.ProfileSkill.Queue_Name__c, oProfileSkillUser.ProfileSkill.Name);
                // System.debug('#$#$#$==> ' + oProfileSkillUser.ProfileSkill.User_Questions__c);
                 if(oProfileSkillUser.ProfileSkill.User_Questions__c != 'No'){
                     mapQueueWiseProfileSkillUser.put(oProfileSkillUser.ProfileSkill.Queue_Name__c , oProfileSkillUser);
                 }                
                 setUserProfileSkillName.add(oProfileSkillUser.ProfileSkill.Name);                    
                  //Deva : I2RT-3244 : To hold actual Skill Name to be used to filter the case comments.
                  if(oProfileSkillUser.ProfileSkill.Type__c == 'Product Manager'){
                    setManagedProductName.add(oProfileSkillUser.ProfileSkill.Product_Name__c);
                  }
             }
    
            // system.debug('setQueueDeveloperName---> ' + setQueueDeveloperName);
 
             set<string> setGroupId = new set<string>();
             map<Id,string> mapQueueIdWiseDevName = new map<Id,string>();
             for(Group oGroup :[select id,Name,developerName from Group where group.type = 'Queue' AND developerName IN : setQueueDeveloperName] ){
                 setGroupId.add(oGroup.Id);
                 mapQueueIdWiseDevName.put(oGroup.Id , oGroup.developerName);
             }
 
             //system.debug('setGroupId---> ' + setGroupId);
 
             map<id,QueueRecordsWrapper> mapGrpIdWiseRecords = new map<id,QueueRecordsWrapper>();
             
             for(Case oCase : [Select Id,Is_Internal_Or_External_Case__c,Component__c,Success_Offering__c, Last_activity_time__c,OwnerId,Owner.Name,LastModifiedById,CaseNumber, Priority, RecordType.Name, Subject,
             Case_InActive__c, Expert_Assistance_Requested_Date__c, IsEscalated, Days_to_Close_Date__c, Case_Last_Activity__c,
             GCS_AAE_Session_Time__c,Forecast_Product__c, Case_Weightage_Calc__c, Case_Timezone__r.Name,Next_Action__c, Status,
             Account.Name, Contact.Name,   DateTime_to_Close__c, Case_Weightage__c, Case_Weightage__r.Name,
             Case_Weightage__r.Weightage__c,Product.Name,contactId,contact.Email,contact.Phone,Case_Timezone__c
             From Case Where OwnerId IN : setGroupId and Status <> 'Closed']){
                 
                 ProfileSkillUser oTempProfileSkillUser;
                 system.debug('mapQueueIdWiseDevName.get(oCase.OwnerId)---> ' + mapQueueIdWiseDevName.get(oCase.OwnerId));
                 if(mapQueueIdWiseDevName.containskey(oCase.OwnerId)){
                  if(mapQueueWiseProfileSkillUser.containskey(mapQueueIdWiseDevName.get(oCase.OwnerId))){
                     oTempProfileSkillUser = mapQueueWiseProfileSkillUser.get(mapQueueIdWiseDevName.get(oCase.OwnerId)); 
                    // system.debug('oTempProfileSkillUser 1===> ' + oTempProfileSkillUser);
                  }
                 } 
 
                
                 system.debug('oTempProfileSkillUser---> ' + oTempProfileSkillUser);
 
                 if(oTempProfileSkillUser != null){ // if user has questions , 
                    // system.debug('oTempProfileSkillUser===> ' + oTempProfileSkillUser);
                     if(oTempProfileSkillUser.Priority__c != null || oTempProfileSkillUser.Support_Level__c != null || oTempProfileSkillUser.Component__c != null){
                        
                         boolean hasPriority = false;
                         boolean hasSupportLevel = false;
                         boolean hasComponent = false;
 
                         if(oTempProfileSkillUser.Priority__c != null && oCase.Priority != null && oTempProfileSkillUser.Priority__c.contains(oCase.Priority)){
                             hasPriority = true;
                         }
 
                         if(oTempProfileSkillUser.Support_Level__c != null && oCase.Success_Offering__c != null && oTempProfileSkillUser.Support_Level__c.contains(oCase.Success_Offering__c)){
                             hasSupportLevel = true;
                         }
 
                         if(oTempProfileSkillUser.Component__c != null && oCase.Component__c != null && oTempProfileSkillUser.Component__c.contains(oCase.Component__c)){
                             hasComponent = true;
                         }
 
                        // system.debug('hasPriority---> ' + hasPriority);
                        // system.debug('hasSupportLevel---> ' + hasSupportLevel);
                        // system.debug('hasComponent---> ' + hasComponent); 
 
                         if(hasPriority && hasSupportLevel && hasComponent){
                             if(mapGrpIdWiseRecords.containsKey(oCase.OwnerId)){
                                 QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oCase.OwnerId);
                                 oExistingQueueRecordsWrapper.lstQueueCase.add(oCase);
                             }else{
                                 QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                                 oQueueRecordsWrapper.lstQueueCase = new List<case>{oCase};
                                 mapGrpIdWiseRecords.put(oCase.OwnerId, oQueueRecordsWrapper);
                             }
                         }
 
                     }else{ // if all questions are null then add case to list 
                         if(mapGrpIdWiseRecords.containsKey(oCase.OwnerId)){
                             QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oCase.OwnerId);
                             oExistingQueueRecordsWrapper.lstQueueCase.add(oCase);
                         }else{
                             QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                             oQueueRecordsWrapper.lstQueueCase = new List<case>{oCase};
                             mapGrpIdWiseRecords.put(oCase.OwnerId, oQueueRecordsWrapper);
                         }
                     }
                     
                 }
                 else{                    
                      // if user has no questions add all record
                     if(mapGrpIdWiseRecords.containsKey(oCase.OwnerId)){
                         QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oCase.OwnerId);
                         oExistingQueueRecordsWrapper.lstQueueCase.add(oCase);
                     }else{
                         QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                         oQueueRecordsWrapper.lstQueueCase = new List<case>{oCase};
                         mapGrpIdWiseRecords.put(oCase.OwnerId, oQueueRecordsWrapper);
                     }
                 }
                 
 
                 if(mapGrpIdWiseRecords.containsKey(oCase.OwnerId)){
                     QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oCase.OwnerId);
                     oExistingQueueRecordsWrapper.lstQueueCaseWithoutFilter.add(oCase);
                 }else{
                     QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                     oQueueRecordsWrapper.lstQueueCaseWithoutFilter = new List<case>{oCase};
                     mapGrpIdWiseRecords.put(oCase.OwnerId, oQueueRecordsWrapper);
                 } 
 
             }
 
             
 
             for(Raise_Hand__c oRH : [Select Id,Type__c,SubType__c,CreatedDate,Name,Case__c,Case__r.CaseNumber,Reason__c,Product__c,Skill__c,ownerId,owner.Name,Time_Since_Raise_Hand__c,
                    Case__r.Priority, Case__r.Forecast_Product__c,Case__r.Component__c, Case__r.Support_Account__r.Name, Title__c, Case_Product__c, case_priority__c, Next_Action__c,
                                    Case__r.Case_Timezone_Name__c, Case__r.Case_Owner_Team__c, Case__r.Owner_Name__c, Collaborator_Team__c, Case_Owner__c, Case_Component__c, 
                                    Case__r.Case_Timezone__c, Case__r.Record_Type_Name__c, Support_Account__c, Case__r.Case_Timezone__r.Name, Case_Owner_Manager__c //T07
                                      From Raise_Hand__c 
                                      Where Skill__c in :setUserProfileSkillName//OwnerId IN : setGroupId 
                                        and status__c='Open'  and Case__r.Status <> 'Closed'  
                                        and (type__c='Co-own' or type__c='Get Help' OR type__c = 'Join a Customer Meeting' OR type__c = 'Repro Environment Setup') order by Name]){                                       
                if(oRH.SubType__c == 'PS' && oRH.owner.Name == 'B2B'){
                 if(mapQueueNameWiseProfileSkillName.get(mapQueueIdWiseDevName.get(oRH.ownerId)) == 'B2B PS'){
                     if(mapGrpIdWiseRecords.containsKey(oRH.OwnerId)){
                         QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oRH.OwnerId);
                         if(oExistingQueueRecordsWrapper.lstQueueRaiseHand != null){
                             oExistingQueueRecordsWrapper.lstQueueRaiseHand.add(oRH);
                         }else{
                             oExistingQueueRecordsWrapper.lstQueueRaiseHand = new List<Raise_Hand__c>{oRH};
                         }
                         }else{
                             QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                             oQueueRecordsWrapper.lstQueueRaiseHand = new List<Raise_Hand__c>{oRH};
                          //   oQueueRecordsWrapper.lstQueueCase = new List<Case>();
                             mapGrpIdWiseRecords.put(oRH.OwnerId, oQueueRecordsWrapper); 
                        }
                 }
                }else{
                 if(mapGrpIdWiseRecords.containsKey(oRH.OwnerId)){
                     QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(oRH.OwnerId);
                     if(oExistingQueueRecordsWrapper.lstQueueRaiseHand != null){
                         oExistingQueueRecordsWrapper.lstQueueRaiseHand.add(oRH);
                     }else{
                         oExistingQueueRecordsWrapper.lstQueueRaiseHand = new List<Raise_Hand__c>{oRH};
                     }
                     }else{
                         QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                         oQueueRecordsWrapper.lstQueueRaiseHand = new List<Raise_Hand__c>{oRH};
                      //   oQueueRecordsWrapper.lstQueueCase = new List<Case>();
                         mapGrpIdWiseRecords.put(oRH.OwnerId, oQueueRecordsWrapper); 
                    }
                }
             }  
	             System.debug('mapGrpIdWiseRecords = '+mapGrpIdWiseRecords);            
             //Deva : I2RT-3244 :  Commented this code as to remove query and use custom permission instead using feature managment.
             /*Integer GCS_ManagerCount = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'GCS_Manager2'];
             boolean hasManagerPermissionSet = false;
              if(GCS_ManagerCount == 1){
                 hasManagerPermissionSet = true;
              }
              ofetchCasesGroupByQueueWrapperResult.hasManagerPermission = hasManagerPermissionSet;*/
              //Deva : I2RT-3244  :
              Boolean hasManagerPermissionSet = CaseCommentUtilities.isGCSManager();
              ofetchCasesGroupByQueueWrapperResult.hasManagerPermission = hasManagerPermissionSet;
         // if logged in user is having manager permission then dispaly all case comments that loggedin user is skilled at 
         // or if looged in user don't have manager permission and if he ownes then show those Escalation/Callback/Revise Priority case comments [Case__r.OwnerId = :sUId]       
         // if mager permission is not there then check count of case comments, if greater then 0 then only show case comment table section 
  
             string sCcQuery  = 'Select Id,Name,Case__c,Case__r.CaseNumber,Case__r.OwnerId,Type__c,Status__c,OwnerId,owner.Name, Comment__c, ' +  
                    'Case__r.Priority, Case__r.Status, CreatedDate, Case__r.Support_Account__r.Name, Case__r.Subject, Case__r.Forecast_Product__c From Case_Comment__c';
             sCcQuery += ' Where Case__r.Status <> \'Closed\' AND ';
            //Deva: I2RT-3566 Start : Added the Live Assistance fitler to pull case comments related to Live Assistance
             sCcQuery += ' (Type__c = \'Callback\' OR  Type__c=\'Revise Priority\' OR Type__c = \'Escalation\' OR Type__c = \'Live Assistance\') ';
             
             sCcQuery += ' AND Is_Replied_To__c = false AND '; 
              
             if(hasManagerPermissionSet == true){
                //Deva : I2RT-3244 : updated the query to fetch the case comments for the Product same as that of the Product (Skill) in that case  
                sCcQuery += '(Case__r.OwnerId = :sUId OR Case__r.Forecast_Product__c IN : setManagedProductName)';
             }
             else{
                sCcQuery += ' Case__r.OwnerId = :sUId'; 
             }
             //system.debug('sCcQuery====> ' + sCcQuery);
            //[Select Id,Name,Case__c,Case__r.CaseNumber,Type__c,Status__c,OwnerId,owner.Name From Case_Comment__c  Where OwnerId IN : setGroupId AND (Type__c = 'Callback' OR  Type__c='Revise Priority' OR Type__c = 'Escalation') AND Is_Replied_To__c=false]
             for(Case_Comment__c cc : Database.query(sCcQuery)){
                 if(mapGrpIdWiseRecords.containsKey(cc.OwnerId)){
                     QueueRecordsWrapper oExistingQueueRecordsWrapper = mapGrpIdWiseRecords.get(cc.OwnerId);
                     if(oExistingQueueRecordsWrapper.lstCaseComments != null){
                         oExistingQueueRecordsWrapper.lstCaseComments.add(cc);
                     }else{
                         oExistingQueueRecordsWrapper.lstCaseComments = new List<Case_Comment__c>{cc};
                     }
                     }else{
                         QueueRecordsWrapper oQueueRecordsWrapper = new QueueRecordsWrapper();  
                         oQueueRecordsWrapper.lstCaseComments = new List<Case_Comment__c>{cc};
                         mapGrpIdWiseRecords.put(cc.OwnerId, oQueueRecordsWrapper); 
                    }
             }
 
             
             
 
           //  system.debug('✋✋ >' +  ofetchCasesGroupByQueueWrapperResult);
             ofetchCasesGroupByQueueWrapperResult.mapGrpIdWiseRecordsData = mapGrpIdWiseRecords;
             
             
             return ofetchCasesGroupByQueueWrapperResult;
         }
         
       //  oDataResultWrapper.mapGrpIdWiseCases = mapGrpIdWiseCases;
 
 
     Public static List<EngineerGradient> calculateGradients(List<Case> casesList, List<CaseMilestone> milestonesList){
         List<EngineerGradient> egList = new List<EngineerGradient>();
         EngineerGradient eg;
         Map<Id, Boolean> violatedMilestoneMap = new Map<Id, Boolean>();
         
         oDataResultWrapper.otherCasesColor = 'rgb(' + mapColorCodes.get('Waiting on Customer') + ', '+transparency +')'; //Green
        oDataResultWrapper.caseOwnerColor = 'rgb(' + mapColorCodes.get('Waiting on Case Owner') + ', '+transparency +')'; //Yellow
        oDataResultWrapper.missedMilestonesColor = 'rgb(' + mapColorCodes.get('Missed Milestone') + ', '+transparency +')'; //Light blue
        oDataResultWrapper.inactiveCasesColor = 'rgb(' + mapColorCodes.get('Inactive Case') + ', '+transparency +')'; //Dark blue
        oDataResultWrapper.p1sCasesColor = 'rgb(' + mapColorCodes.get('P1 Priority') + ', '+transparency +')'; //Light red
        oDataResultWrapper.escalationColor = 'rgb(' + mapColorCodes.get('Escalation') + ', '+transparency +')'; //Dark red
         oDataResultWrapper.casesWaitingOnTeam = 'rgb(' + mapColorCodes.get('Waiting on Case Team') + ', '+transparency +')'; // palegoldenrod / Pale goldenrod 
         oDataResultWrapper.FirstGradientColor = '';
         oDataResultWrapper.lastGradientColor = '';
         
         for(CaseMilestone cm : milestonesList){
             if(cm.IsViolated){
                 violatedMilestoneMap.put(cm.CaseId, True);
             }
         }
         Decimal totalCases = casesList.size();
         Integer totalDivisions = 0;
         Integer OtherDivisions = 0;
         Integer escalatedCases = 0;
         Integer p1Cases = 0;
         Integer inactiveCases = 0;
         Integer missedMilestoneCases = 0;
         Integer caseOwnerCases = 0;
         Integer otherCases = 0;
         Integer caseTeamCases = 0; //T03
       
         
         for(Case cs : casesList){
             Boolean otherCase = True;            
             if(cs.IsEscalated){
                 escalatedCases++;
                 otherCase = False;
             }
             if(cs.Priority == 'P1'){
                 p1Cases++;
                 otherCase = False;
             }
             //------------------------------------------------<T02/>--------------------
              if(cs.Priority!=null && cs.Case_Last_Activity__c!=null){
             if((cs.Priority == 'P1' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 2) < oDataResultWrapper.todaydateGMT) || (cs.Priority == 'P2' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 3) < oDataResultWrapper.todaydateGMT) || (cs.Priority == 'P3' && oDataResultWrapper.bdc.addBusinessDays(cs.Case_Last_Activity__c.dateGMT(), 4) < oDataResultWrapper.todaydateGMT)){
                 inactiveCases++;
                 otherCase = False;
             }
              }
 
             if(violatedMilestoneMap.get(cs.Id) != null && violatedMilestoneMap.get(cs.Id)){
                 missedMilestoneCases++;
                 otherCase = False;
             }
             
             if(cs.Next_Action__c == 'Case Owner'){
                 caseOwnerCases++;
                 otherCase = False;
             }    
             if(cs.Next_Action__c == 'INFA R&D' || cs.Next_Action__c == 'PS Team' || cs.Next_Action__c == 'Operations Team' || cs.Next_Action__c == 'Multi Team'){
                caseTeamCases++;
                otherCase = False;
             }    
             //<T04> starts
             if(cs.Next_Action__c == 'Customer'){
                otherCase = true;
             }//<T04> ends
             if(otherCase){
                 otherCases++;
             }        
         }
         totalCases = escalatedCases + p1Cases + inactiveCases + caseOwnerCases + caseTeamCases + otherCases + missedMilestoneCases;
         System.debug('Total Cases: '+totalCases);
         System.debug('Escalated Cases: '+escalatedCases);
         System.debug('P1 Cases: '+p1Cases);
         System.debug('Inactive Cases: '+inactiveCases);
         System.debug('Missed Milestone Cases: '+missedMilestoneCases);
         System.debug('Case Owner Cases: '+caseOwnerCases);
         System.debug('Case Team Cases: '+caseTeamCases);
         System.debug('Other Cases: '+otherCases);
         
         
         if(otherCases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.otherCasesColor;
                 eg = new EngineerGradient();
                 eg.width = ((otherCases/totalCases)/2)*100;
                 eg.title = 'Other cases: '+otherCases;
                 eg.CurrentColor = oDataResultWrapper.otherCasesColor;
             }else{
                 eg.NextColor = oDataResultWrapper.otherCasesColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((otherCases/totalCases)/2)*100;
                 eg.title = 'Other cases: '+otherCases;
                 eg.CurrentColor = oDataResultWrapper.otherCasesColor;
             }
             //System.debug('otherCasesWidth: '+eg.width);
             totalDivisions = totalDivisions - 1;
             //egList.add(eg);
         }
         
         if(caseOwnerCases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.caseOwnerColor;
                 eg = new EngineerGradient();
                 eg.width = ((caseOwnerCases/totalCases)/2)*100;
                 eg.title = 'You own '+caseOwnerCases+' case(s) with Next Action as Case Owner';
                 eg.CurrentColor = oDataResultWrapper.caseOwnerColor;
             }else{
                 eg.NextColor = oDataResultWrapper.caseOwnerColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((caseOwnerCases/totalCases)/2)*100;
                 eg.title = 'You own '+caseOwnerCases+' case(s) with Next Action as Case Owner';
                 eg.CurrentColor = oDataResultWrapper.caseOwnerColor;
             }
            // System.debug('caseOwnerWidth: '+eg.width);
             totalDivisions = totalDivisions + 1;
             OtherDivisions = OtherDivisions + 1;
         }
         if(caseTeamCases > 0){
            if(oDataResultWrapper.FirstGradientColor == ''){
                oDataResultWrapper.FirstGradientColor = oDataResultWrapper.casesWaitingOnTeam;
                eg = new EngineerGradient();
                eg.width = ((caseTeamCases/totalCases)/2)*100;
                eg.title = 'You own '+caseTeamCases+' case(s) with Next Action as Case Team';
                eg.CurrentColor = oDataResultWrapper.casesWaitingOnTeam;
            }else{
                eg.NextColor = oDataResultWrapper.casesWaitingOnTeam;
                egList.add(eg);
                eg = new EngineerGradient();
                eg.width = ((caseTeamCases/totalCases)/2)*100;
                eg.title = 'You own '+caseTeamCases+' case(s) with Next Action as Case Team';
                eg.CurrentColor = oDataResultWrapper.casesWaitingOnTeam;
                
            }
            //System.debug('caseTeamWidth: '+eg.width);
            totalDivisions = totalDivisions + 1;
            OtherDivisions = OtherDivisions + 1;
         }
         if(missedMilestoneCases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.missedMilestonesColor;
                 eg = new EngineerGradient();
                 eg.width = ((missedMilestoneCases/totalCases)/2)*100;
                 eg.title = 'You have missed milestones for '+missedMilestoneCases+' case(s)';
                 eg.CurrentColor = oDataResultWrapper.missedMilestonesColor;
             }else{
                 eg.NextColor = oDataResultWrapper.missedMilestonesColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((missedMilestoneCases/totalCases)/2)*100;
                 eg.title = 'You have missed milestones for '+missedMilestoneCases+' Case(s)';
                 eg.CurrentColor = oDataResultWrapper.missedMilestonesColor;
             }
             //System.debug('missedMilestonesWidth: '+oDataResultWrapper.missedMilestonesWidth);
             totalDivisions = totalDivisions + 1;
             OtherDivisions = OtherDivisions + 1;
         }
         
         if(inactiveCases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.inactiveCasesColor;
                 eg = new EngineerGradient();
                 eg.width = ((inactiveCases/totalCases)/2)*100;
                 eg.title = 'You have '+inactiveCases+' inactive case(s)';
                 eg.CurrentColor = oDataResultWrapper.inactiveCasesColor;
             }else{
                 eg.NextColor = oDataResultWrapper.inactiveCasesColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((inactiveCases/totalCases)/2)*100;
                 eg.title = 'You have '+inactiveCases+' inactive case(s)';
                 eg.CurrentColor = oDataResultWrapper.inactiveCasesColor;
             }
            // System.debug('inactiveCasesWidth: '+eg.width);
             totalDivisions = totalDivisions + 1;
             OtherDivisions = OtherDivisions + 1;
         }
         
         if(p1Cases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.p1sCasesColor;
                 eg = new EngineerGradient();
                 eg.width = ((p1Cases/totalCases)/2)*100;
                 eg.title = 'You have '+p1Cases+' case(s) with priority P1';
                 eg.CurrentColor = oDataResultWrapper.p1sCasesColor;
             }else{
                 eg.NextColor = oDataResultWrapper.p1sCasesColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((p1Cases/totalCases)/2)*100;
                 eg.title = 'You have '+p1Cases+' case(s) with priority P1';
                 eg.CurrentColor = oDataResultWrapper.p1sCasesColor;
             }
             System.debug('p1sCasesWidth: '+eg.width);
             totalDivisions = totalDivisions + 1;
             OtherDivisions = OtherDivisions + 1;
         }
         
         if(escalatedCases > 0){
             if(oDataResultWrapper.FirstGradientColor == ''){
                 oDataResultWrapper.FirstGradientColor = oDataResultWrapper.escalationColor;
                 eg = new EngineerGradient();
                 eg.width = ((escalatedCases/totalCases)/2)*100;
                 eg.title = escalatedCases+' of your case(s) are escalated';
                 eg.CurrentColor = oDataResultWrapper.escalationColor;
             }else{
                 eg.NextColor = oDataResultWrapper.escalationColor;
                 egList.add(eg);
                 eg = new EngineerGradient();
                 eg.width = ((escalatedCases/totalCases)/2)*100;
                 eg.title = escalatedCases+' of your case(s) are escalated';
                 eg.CurrentColor = oDataResultWrapper.escalationColor;
             }
            // System.debug('escalationWidth: '+eg.width);
             totalDivisions = totalDivisions +1;
             OtherDivisions = OtherDivisions + 1;
         }
         system.debug('eg at 876'+Json.serializePretty(eg));
         oDataResultWrapper.lastGradientColor = eg.CurrentColor;
         oDataResultWrapper.lastGradientWidth = totalDivisions < 0 ? 100 : totalDivisions == 0 ? 25 : OtherDivisions == 1 ? 100 : eg.width;
         oDataResultWrapper.lastGradientTitle = eg.title;
         System.debug(totalDivisions);
         System.debug(OtherDivisions);
         oDataResultWrapper.bandChangeWidth = totalDivisions < 0 ? 100 : totalDivisions == 2 ? 50 : 101/(totalDivisions+1);
        // System.debug('bandChangeWidth: '+oDataResultWrapper.bandChangeWidth);
         oDataResultWrapper.egList = egList;
         return egList;
     }
 
     @AuraEnabled
     Public static void updateCaseOwner(list<string> lstCaseId, string sUserId){   
          list<case> lstCaseToUpdate = new list<case>();
          string currentUserId = sUserId != null ? sUserId : userinfo.getUserId();
         for(case oCase : [Select id,OwnerId,Product.Name From Case Where Id IN : lstCaseId]){
             oCase.ownerId = currentUserId;
             lstCaseToUpdate.add(oCase);
         } 
         UPDATE lstCaseToUpdate;
     }
     
    //T01
    //sets the given user as the Iam on it user on the given list of cases.
    @AuraEnabled
    public static void userOnIt(list<string> lstCaseId, string sUserId){   
        List<Case> lstCaseToUpdate = new List<Case>();
        String currentUserId = sUserId != null ? sUserId : userinfo.getUserId();

        for(case oCase : [Select Id, Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c 
                            From Case Where Id IN : lstCaseId And Case_claimed_by_user_weekend_holiday__c != :currentUserId]){
            oCase.Is_case_claimed_weekend_holiday__c = true;
            oCase.Case_claimed_by_user_weekend_holiday__c = currentUserId;
            lstCaseToUpdate.add(oCase);
        } 
        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;
        }
    }
    
    //T01
    //removes the given user as the Iam on it user on the given list of cases.
    @AuraEnabled
    public static void userOffIt(list<string> lstCaseId, string sUserId){   
        List<Case> lstCaseToUpdate = new List<Case>();
        String currentUserId = sUserId != null ? sUserId : userinfo.getUserId();

        for(case oCase : [Select Id, Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c 
                            From Case Where Id IN : lstCaseId]){
            oCase.Is_case_claimed_weekend_holiday__c = false;
            oCase.Case_claimed_by_user_weekend_holiday__c = null;
            lstCaseToUpdate.add(oCase);
        } 
        if(!lstCaseToUpdate.isEmpty()){
            update lstCaseToUpdate;
        }
    }

     @AuraEnabled
     Public static void acceptRaiseHand(list<string> lstCaseId, list<string> lstRHId , string sUserId){   
        string currentUserId = sUserId != null ? sUserId : userinfo.getUserId();

        Set<Id> setRaiseHandId = new Set<Id>();
        for(String raiseHandId : lstRHId){
            setRaiseHandId.add(raiseHandId);
        }
       // system.debug('Function to be called');
        RaiseHandService.onAssignment(setRaiseHandId, currentUserId);
     }

     @AuraEnabled
     Public static void acceptRaiseHand(String lstRHId){   
        string currentUserId = userinfo.getUserId();

        Set<Id> setRaiseHandId = new Set<Id>();
        setRaiseHandId.add(lstRHId);        
        RaiseHandService.onAssignment(setRaiseHandId, currentUserId);
     }


     /*@AuraEnabled
     Public static void acceptRaiseHand(list<string> lstCaseId, list<string> lstRHId , string sUserId){   
         // got to that case and  realted for now use standard object[ Case_Team__c] add user and role co-own , update the RH status to close  # New UPADTE 
         // RH owner should be logged in user 
        system.debug('lstCaseId===> ' + lstCaseId);
        system.debug('lstRHIdstring===> ' + lstRHId);
        system.debug('sUserId===> ' + sUserId);
        string currentUserId = sUserId != null ? sUserId : userinfo.getUserId();
        CaseTeamRole oCaseTeamRoleCoOwner = [select Id,Name from CaseTeamRole WHERE Name = 'CoOwner' LIMIT 1]; 
        
        map<string,caseTeamMember> mapCaseWiseTeamMember = new map<string,caseTeamMember>();

        for(CaseTeamMember member : [Select Id,ParentId,MemberId,TeamRoleId,TeamRole.Name From CaseTeamMember Where ParentId IN : lstCaseId]){                           
            if(member.MemberId == currentUserId){
                mapCaseWiseTeamMember.put(member.ParentId , member);
            }
        }

        system.debug('mapCaseWiseTeamMember====> ' + mapCaseWiseTeamMember);

        list<CaseTeamMember> lstCaseTeamMember = new  list<CaseTeamMember>();
        for(case oCase : [Select Id From Case Where Id IN : lstCaseId]){                           
            if(!mapCaseWiseTeamMember.containsKey(oCase.Id)){
                lstCaseTeamMember.add(new CaseTeamMember(ParentId = oCase.Id, MemberId = currentUserId, TeamRoleId = oCaseTeamRoleCoOwner.Id));
            }  
        }       
        system.debug('lstCaseTeamMember====> ' + lstCaseTeamMember);                 
         if(lstCaseTeamMember.size() > 0){
             INSERT lstCaseTeamMember;
         }

         list<Raise_Hand__c> lstRaiseHandsToUpdate = new list<Raise_Hand__c>();
         for(Raise_Hand__c oRH : [Select Id,Status__c from Raise_Hand__c WHERE id IN : lstRHId]){
            oRH.status__c = 'Closed';
            lstRaiseHandsToUpdate.add(oRH);
         }
         if(lstRaiseHandsToUpdate.size() > 0){
             Update lstRaiseHandsToUpdate;
         }
     }

     
     @AuraEnabled
     Public static void updateRaiseHandOwner(List<Id> lstRaiseHandId, string sUserId){   
         
     System.debug('setRaiseHandId->'+lstRaiseHandId);
     System.debug('sUserId->'+sUserId);
     Set<Id> setRaiseHandId=new Set<Id>(lstRaiseHandId);

        list<Raise_Hand__c> lstRaiseHandsToUpdate = new list<Raise_Hand__c>();
         string currentUserId = sUserId != null ? sUserId : userinfo.getUserId();
         for(Raise_Hand__c rh : [Select Id, OwnerId,Feed_Item_Id__c, Case__c, Case__r.OwnerId, Engagement__c, Skill__c, 
         Type__c, Subtype__c, Status__c, Question__c, Repro_Expectation__c,Time_Since_Raise_Hand__c 
                From Raise_Hand__c Where Id in :lstRaiseHandId]){
                rh.ownerId = currentUserId;
                lstRaiseHandsToUpdate.add(rh);
        }
        System.debug('lstRaiseHandsToUpdate->'+lstRaiseHandsToUpdate);
        update lstRaiseHandsToUpdate;

        System.debug('setRaiseHandId-->'+setRaiseHandId);
        ////   RaiseHandService.onAssignment(setRaiseHandId); // temp note : got error on servdev2
    
     }*/
 
 
 
     // method for case timeline 
     @AuraEnabled 
     public static wrapperCaseTimeLine buildTimeLine(string caseId, string blflag){
         wrapperCaseTimeLine oWrapperCaseTimeLine = new wrapperCaseTimeLine();
         oWrapperCaseTimeLine.cas = [select Id,Subject,CaseNumber,Description,Priority,LastModifiedDate,CreatedDate,Forecast_Product__c,Status,Contact.Name,Contact.Email,Contact.Phone,Case_Timezone__c,AccountId,Account.Name,Case_Timezone__r.Name,Resolution_Target_DateTime__c,Escalated_Date__c,Next_Action__c
                                      from Case where Id = :caseId];
         //--------------------------------------------------------------------------------------------------------T01,   </T04>
         oWrapperCaseTimeLine.data = new List<InternalCaseViewDataV1>();
 
 
         //// List<CaseComment> comments = [select CommentBody,CreatedDate from CaseComment where ParentId = :caseId];
         List<Case_Comment__c> comments = [select Comment__c,CreatedDate from Case_Comment__c where Case__c = :caseId];
         
         //T02 - Start - Filterd out survey email by subject pattern
         List<EmailMessage> emails = [select Subject,TextBody,HtmlBody,CreatedDate,Incoming from EmailMessage where ParentId = :caseId and (NOT Subject like '%Informatica requests your feedback%')];       
         //T02 - End
         List<Attachment> attachments = [SELECT Id,Name,CreatedDate from Attachment where ParentId = :caseId];
       //Commented as part of phase 2 migration
          // List<PSResponse__c> psResponses = [SELECT Id,Observations__c,CollabCase__c,CreatedDate,LastModifiedDate from PSResponse__c where ParentTechCase__c = :caseId];
         //end
          List<Case> webexes = [SELECT (SELECT Id,LastModifiedDate,Description,CreatedDate FROM ActivityHistories WHERE ActivityType='WebEx')FROM Case where Id = :caseId];
         List<Case> calls = [SELECT (SELECT Id,LastModifiedDate,Description,CreatedDate FROM ActivityHistories WHERE ActivityType='Call')FROM Case where Id = :caseId];
         List<Case> relatedcs = [SELECT Id,Subject,CreatedDate,Description,CaseNumber,RecordType.Name from Case where ParentId = :caseId];
         
         List<feeditem> feeds = [Select Id,Body,Type,ParentId,CreatedDate,Title,LinkUrl FROM feeditem where ParentId = :caseId and Type like '%Post%' order by CreatedDate desc];
        // System.debug('feeds--<'+feeds);
         
 
         for(Case_Comment__c c : comments) {
              InternalCaseViewDataV1 vo = new InternalCaseViewDataV1();
 
              vo.type = 'CaseComment';
              vo.commentBody = c.Comment__c;
              vo.CreatedAt = c.CreatedDate;
              vo.redId = c.Id;
              vo.bIsCaseComment = true;
              vo.bIsEmail = false;
              vo.bIsAttachment = false;
              vo.bIsWebex = false;
              vo.bIsCall = false;
              vo.bIsSubCase = false;
              vo.bIsFeedActivity = false;
              oWrapperCaseTimeLine.data.add(vo);
         }
         
         for(EmailMessage em : emails) {
  
           
            InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
            vo.type = 'Email';          
            vo.CreatedAt = em.CreatedDate;
            vo.msg = em;
            vo.bIsCaseComment = false;
              vo.bIsEmail = true;
              vo.bIsAttachment = false;
              vo.bIsWebex = false;
              vo.bIsCall = false;
              vo.bIsSubCase = false;
              vo.bIsFeedActivity = false;
            oWrapperCaseTimeLine.data.add(vo); 
            
         }
         
         for(Attachment a : attachments) {
            InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
            vo.type = 'Attachment';          
            vo.CreatedAt = a.CreatedDate;
            vo.attachment = a;
            vo.bIsCaseComment = false;
            vo.bIsEmail = false;
            vo.bIsAttachment = true;
            vo.bIsWebex = false;
            vo.bIsCall = false;
            vo.bIsSubCase = false;
            vo.bIsFeedActivity = false;
            oWrapperCaseTimeLine.data.add(vo); 
         }
          for(Case c : webexes){
              for(ActivityHistory webexlog : c.ActivityHistories) {
                  InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
                  vo.CreatedAt = webexlog.CreatedDate;
                  vo.type='Webex';
                  vo.webex = webexlog;  
                  vo.bIsCaseComment = false;
                  vo.bIsEmail = false;
                  vo.bIsAttachment = false;
                  vo.bIsWebex = true;
                  vo.bIsCall = false;
                  vo.bIsSubCase = false;
                  vo.bIsFeedActivity = false;              
                  oWrapperCaseTimeLine.data.add(vo);
             }  
          }
          
          for(Case c : calls){
              for(ActivityHistory callLog : c.ActivityHistories) {
                  InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
                  vo.createdAt = callLog.CreatedDate;
                  vo.type='Call';
                  vo.call = callLog;
                  vo.bIsCaseComment = false;
                  vo.bIsEmail = false;
                  vo.bIsAttachment = false;
                  vo.bIsWebex = false;
                  vo.bIsCall = true;
                  vo.bIsSubCase = false;
                  vo.bIsFeedActivity = false; 
                  oWrapperCaseTimeLine.data.add(vo);
             }  
          }
          //Commented as part of phase 2 migration
        /* for(PSResponse__c ps : psResponses) {
            InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
            vo.type = 'PSResponse';          
            vo.CreatedAt = ps.LastModifiedDate;
            vo.psResponse = ps;
            data.add(vo); 
         }
         *///end
         for(Case c : relatedcs) {
            InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
            vo.type = 'SubCase';          
            vo.CreatedAt = c.CreatedDate;
            vo.relatedCase = c;
            vo.bIsCaseComment = false;
                  vo.bIsEmail = false;
                  vo.bIsAttachment = false;
                  vo.bIsWebex = false;
                  vo.bIsCall = false;
                  vo.bIsSubCase = true;
                  vo.bIsFeedActivity = false; 
            oWrapperCaseTimeLine.data.add(vo);
         }
 
         for(feeditem f:feeds)
         {
            InternalCaseViewDataV1 vo = new InternalCaseViewDataV1(); 
            vo.type = 'Feed Activity';
            vo.redId = f.Id;
            vo.CreatedAt = f.CreatedDate;
            system.debug('Feed--'+f);
            vo.feed=f;
            vo.bIsCaseComment = false;
                  vo.bIsEmail = false;
                  vo.bIsAttachment = false;
                  vo.bIsWebex = false;
                  vo.bIsCall = false;
                  vo.bIsSubCase = false;
                  vo.bIsFeedActivity = true; 
 
            //<T05>
            
               if(vo.feed!=null && vo.feed.Type!=null && vo.feed.Type=='LinkPost')
               {
                  if(vo.feed.LinkUrl!=null && vo.feed.Title!=null )
                  {
                     vo.feed.Body=vo.feed.Title+ '\n'+'URL :'+vo.feed.LinkUrl;
                  }
                  else if(vo.feed.LinkUrl!=null && vo.feed.Title==null )
                  {
                     vo.feed.Body=vo.feed.LinkUrl;
                  }
            
                 
               }else if(vo.feed!=null && vo.feed.Type!=null && vo.feed.Type=='ContentPost')
               {
                  //System.debug('Inside contentPost');
                  vo.feed.Body='Attachment';
               }else
               {
                  if(vo.feed!=null && vo.feed.Body!=null)
                  {
                     String result = vo.feed.Body.substring(3,vo.feed.Body.length()-4);	
                     vo.feed.Body=result;	
                  }
               }
 
            
            //</T05>
            oWrapperCaseTimeLine.data.add(vo);
         }
         
         oWrapperCaseTimeLine.data.sort();
        //  <T06>
          System.debug('dATA-->'+oWrapperCaseTimeLine.data);
          // System.debug('blflag-->'+blflag);
           oWrapperCaseTimeLine.data1 = new List<InternalCaseViewDataV1>();
          if(blflag!=null && blflag.contains('true'))
          {
              System.debug('blflag=true entry');
              Integer count=0;
              Integer attCount=0;
              oWrapperCaseTimeLine.TotalRowcount=0;
              if(oWrapperCaseTimeLine.data!=null && oWrapperCaseTimeLine.data.size()>0){
                 // System.debug('data.size()>0');
                  for(InternalCaseViewDataV1 vo: oWrapperCaseTimeLine.data)
                  {
                     // System.debug('count-->'+count);
                      if(count< 3)
                      {
                         // System.debug('count< 3 entry');
                          if(vo.type!=null )
                          {
                             // System.debug('vo.type!=null');
                              if(vo.type != 'Attachment')
                              {
                                //  System.debug('nOT attachment');
                                  count=count+1;
                                  oWrapperCaseTimeLine.data1.add(vo);
                              }else if(vo.type == 'Attachment')
                              {
                                  attCount=attCount+1;
                                  // System.debug('Isattachment');
                                   oWrapperCaseTimeLine.data1.add(vo);
                                      
                              }
                          }
                      }
                      
                  }
                  oWrapperCaseTimeLine.TotalRowcount=count+attCount;
                //  System.debug('TotalRowcount-->'+oWrapperCaseTimeLine.TotalRowcount);
              }
             // System.debug('data1-->'+oWrapperCaseTimeLine.data1);
          }
        //  </T06>
 
 
         return oWrapperCaseTimeLine;
 
 
     }
 
 
     public class wrapperCaseTimeLine{
      @AuraEnabled public List<InternalCaseViewDataV1> data {get;set;}
      @AuraEnabled public List<InternalCaseViewDataV1> data1 {get;set;}
      @AuraEnabled public   Integer TotalRowcount{get;set;}
      @AuraEnabled public Case cas {get;set;}
     }
 
     @AuraEnabled
     public static string insertWeightageRating(string sComment,string cw,string rating,string weightage,string ocase){
         list<Weightage_Rating__c> lstWr = new list<Weightage_Rating__c>();
         Weightage_Rating__c wr = new Weightage_Rating__c();
         wr.Comments__c = sComment;
         wr.Case_Weightage__c = cw;
         wr.Rating__c=rating;
         wr.Weightage__c = weightage;
         wr.Case__c = ocase;
         insert wr;    
         return wr.Id;
     }
      
     @AuraEnabled
     public static boolean isGCSManagerPermission(){
          boolean hasPermissionSetAssignment = false;
          for(PermissionSetAssignment psa : [SELECT Id, PermissionSetId, PermissionSet.Name,
          PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name
          FROM PermissionSetAssignment
          WHERE Assignee.Id =: userInfo.getUserId() 
          AND PermissionSet.Name='GCS_Manager' LIMIT 1]){
             hasPermissionSetAssignment = true;
          }
          return hasPermissionSetAssignment;
     }
 
     Public class DataResultWrapper{
         @auraEnabled Public String userTeam { get; set; }
         @auraEnabled Public String userEmail { get; set; }
         @auraEnabled Public String userName { get; set; }
         @auraEnabled Public List<CaseWrapper> caseWrapper {get; set;}
         @auraEnabled Public List<Id> caseIds {get; set;}
         @auraEnabled Public List<EngineerGradient> egList {get; set;}
         @auraEnabled Public String firstGradientColor {get; set;}
         @auraEnabled Public String lastGradientColor {get; set;}
         @auraEnabled Public String lastGradientTitle {get; set;}
         @auraEnabled Public Decimal lastGradientWidth {get; set;}
         @auraEnabled Public Boolean hasCases {get; set;}
         @auraEnabled Public Decimal bandChangeWidth {get; set;}
         @auraEnabled Public Integer casePosition {get; set;}
         @auraEnabled Public Decimal otherCasesWidth {get; set;}
         @auraEnabled Public String otherCasesTitle {get; set;}
         @auraEnabled Public String otherCasesColor {get; set;}
         @auraEnabled Public Decimal caseOwnerWidth {get; set;}
         @auraEnabled Public String caseOwnerTitle {get; set;}
         @auraEnabled Public String caseOwnerColor {get; set;}
         @auraEnabled Public Decimal missedMilestonesWidth {get; set;}
         @auraEnabled Public String missedMilestonesTitle {get; set;}
         @auraEnabled Public String missedMilestonesColor {get; set;}
         @auraEnabled Public Decimal inactiveCasesWidth {get; set;}
         @auraEnabled Public String inactiveCasesTitle {get; set;}
         @auraEnabled Public String inactiveCasesColor {get; set;}
         @auraEnabled Public Decimal p1sCasesWidth {get; set;}
         @auraEnabled Public String p1sCasesTitle {get; set;}
         @auraEnabled Public String p1sCasesColor {get; set;}
         @auraEnabled Public Decimal escalationWidth {get; set;}
         @auraEnabled Public String escalationTitle {get; set;}
         @auraEnabled Public String escalationColor {get; set;}
         @auraEnabled Public BusinessHours bh;
         @auraEnabled Public Date todaydateGMT;
         @auraEnabled Public BusinessDaysCalculation bdc;
         @auraEnabled Public Boolean ismanager{get; set;}
         @auraEnabled Public Boolean showloggedinas{get; set;}
         @auraEnabled Public String selectedusername{get; set;}
          @auraEnabled Public String casesWaitingOnTeam {get; set;}
         
     }
 
 
 
     Public Class CaseWrapper{
         @AuraEnabled Public Case cs {get; set;}
         @AuraEnabled Public List<EngineerGradient> egList {get; set;}
         @AuraEnabled Public Integer position {get; set;}
         @AuraEnabled Public String AccountName {get; set;}
         @AuraEnabled Public String ContactName {get; set;}
         @AuraEnabled Public String NextAction {get; set;}
         @AuraEnabled Public String ProjectName {get; set;}
         @AuraEnabled Public String Timezone {get; set;}
         @AuraEnabled Public String Product {get; set;}
         @AuraEnabled Public String Subject {get; set;}
         @AuraEnabled Public String LastActivityDateTime {get; set;}
         @AuraEnabled Public Boolean alertcolor {get; set;}
         @AuraEnabled Public String milestoneMessage {get; set;}
         @AuraEnabled Public String aaeSessionTime {get; set;}
         @AuraEnabled Public String aaeDaysToGo {get; set;}
         @AuraEnabled Public String daysToCloseMessage {get; set;}
         @AuraEnabled Public String RType {get; set;}
         @AuraEnabled Public Boolean showP1 {get; set;}
         @AuraEnabled Public Boolean showP2 {get; set;}
         @AuraEnabled Public Boolean showP3 {get; set;}
         @AuraEnabled Public Boolean milestoneViolated {get; set;}
         @AuraEnabled Public Boolean activeMilestone {get; set;}
         @AuraEnabled Public Boolean isInactive {get; set;}
         @AuraEnabled Public String timeRemaining {get; set;}
         @AuraEnabled Public String firstGradientColor {get; set;}
         @AuraEnabled Public String lastGradientColor {get; set;}
         @AuraEnabled Public String lastGradientTitle {get; set;}
         @AuraEnabled Public Decimal lastGradientWidth {get; set;}
         @AuraEnabled Public Decimal bandChangeWidth {get; set;}
         @AuraEnabled public boolean hasOwnedCase{get;set;}
         @AuraEnabled public string caseTeamMemberRole{get;set;}
         @auraEnabled Public String TargetCloseDate{get; set;}
         @auraEnabled Public Boolean P0Enabled{get; set;}
         
         Public CaseWrapper(){
             cs = new Case();
             egList = new List<EngineerGradient>();
             AccountName = '';
             ContactName = '';
             ProjectName = '';
             NextAction = '';
             Timezone = '';
             Product = '';
             Subject = '';
             RType = '';
             aaeDaysToGo = '';
             LastActivityDateTime = '';
             alertcolor = false;
             milestoneMessage = '';
             aaeSessionTime = '';
             daysToCloseMessage = '';
             showP1 = False;
             showP2 = False;
             showP3 = False;
             isInactive = False;
             milestoneViolated = False; 
             activeMilestone = False;
             timeRemaining = '';
             position = 0;
             hasOwnedCase = False;
             caseTeamMemberRole = '';
             TargetCloseDate = '';
             P0Enabled = false ;
         }
     }
     @AuraEnabled(cacheable = false)
     public static CasesInfo fetchCasesBasedOnListView(string ListViewName, string columns){
         CasesInfo ci = new CasesInfo();
         if(ListViewName != null){
             if(!columns.contains('id,')){
                 columns = columns + 'id,';
             }
             integer count = 0;
             columns = columns.left(columns.length() - 1);
             list<listView> view = [select id from listView where sObjectType = 'Case' and developername =: ListViewName];
             string sessionId = CasePrioritizationViewLwcV4Ctrl.getSessionIdForLWC();
             String ep = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v52.0/ui-api/list-records/'  +view[0].id + '?pageSize=1000';
             HttpRequest req = new HttpRequest();
             req.setMethod('GET');
            
           //  system.debug(sessionId);
             req.setHeader('Authorization','Bearer ' + sessionId);
             req.setEndPoint(ep);
             HttpResponse res = new HTTP().send(req);
             map<string,Object> allResponse = (map<string,object>)JSON.deserializeUntyped(res.getBody());
             list<Object> allCasesJson = (list<Object>)allResponse.get('records');
             count = (integer)allResponse.get('count');
           //  system.debug('@@@--count----->>>>'+count);
             set<string> caseIds = new set<string>();
           //  system.debug('@@@--allCasesJson ----->>>>'+allCasesJson );
             for(object obj: allCasesJson){
                 string s = Json.serialize(Obj);
                 map<string,Object> JsonFields = (map<string,object>)JSON.deserializeUntyped(s);
                 s = Json.serialize(JsonFields.get('fields'));
                 JsonFields = (map<string,object>)JSON.deserializeUntyped(s);
                 s = Json.serialize(JsonFields.get('Id'));
                 JsonFields = (map<string,object>)JSON.deserializeUntyped(s);
                 caseIds.add((string)JsonFields.get('value'));
             }
             
           //  system.debug('@@@--caseIds--->>>>'+caseIds);
             string query = 'select ' + columns + ' from case where id in:caseIds AND Status <> \'Closed\' order by createddate desc';
          //   system.debug('@@@--query --->>>>'+query );
             list<case> caseList = database.query(query);
             
             ci.AllCases = caselist;
             ci.count = count;
             return ci;
             }
         return ci;
     }
     
     public static string getSessionIdForLWC(){
        pageReference pr = Page.GetSessionIdOnLWC;
        string content;
        if(Test.isRunningTest()) {
            content = 'Start_Of_Session_idEnd_Of_Session_Id';
        } else {
            content = pr.getContent().toString();
        }
        integer startp = content.indexOf('Start_Of_Session_id') + 'Start_Of_Session_id'.length();
        integer endP = content.indexOf('End_Of_Session_Id');
        string sessionId = content.substring(startp,endP);
        return sessionId;
     }
     @AuraEnabled
     public static string SavePinnedView(string ViewName){
         list<GCS_Subscription__c> info =[select id from GCS_Subscription__c where createdbyid =: userinfo.getUserId() and (Pinned_View__c != null OR Case_Views__c != null) limit 1];
         if(info.isEmpty()){
             GCS_Subscription__c newINfo = new GCS_Subscription__c(Pinned_View__c = ViewName);
             insert newINFo;
         }else{
             info[0].Pinned_View__c = ViewName;
             update info[0];
         }
        // system.debug(ViewName);
         return ViewName;
     }
     @AuraEnabled
     public static ViewInfoWrap SaveTheSelectedViews(List<String> ViewName){
         ViewInfoWrap vi = new ViewInfoWrap();
         if(ViewName != null) {
            vi.UserViews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView where developerName IN :ViewName and sObjectType = 'Case'];
         }
         return vi;
     }
     
    public class CasesInfo{
        @AuraEnabled
        public list<case> AllCases;
        @AuraEnabled
        public Integer count;
    }
    public class ViewInfoWrap{
        @AuraEnabled
        public list<ListView> AllViews;
        @AuraEnabled
        public string pinnedPost;
        @AuraEnabled
        public list<ListView> UserViews;
        @AuraEnabled
        public list<string> selectedValues;
    }
     Public Class EngineerGradient{
         @AuraEnabled Public String CurrentColor {get; set;}
         @AuraEnabled Public String NextColor {get; set;}
         @AuraEnabled Public String title {get; set;}
         @AuraEnabled Public Decimal width{get; set;}
     }   



    /*
     Method Name : getAttentionRecords
     Description : This method returns the fields related to the given object API name.
     Parameters  : String, called from getAttentionRecords, strProvidedUserId User Id.
     Return Type : List<Case_Comment__c>
     */
    @AuraEnabled(cacheable = false)
    public static List<Case_Comment__c> getAttentionRecords(String strProvidedUserId) {
        String strUserId = UserInfo.getUserId();
        String strQuery;
        Boolean boolHasManagerPermissionSet;
        Set<String> setManagedProductName = new Set<String>();
        List<Case_Comment__c> lstCaseComments = new List<Case_Comment__c>();

        //First we define if we have a permission set.
        boolHasManagerPermissionSet = CaseCommentUtilities.isGCSManager();

        //Now we check the user id.
        if(String.isNotBlank(strProvidedUserId)) {
            strUserId = strProvidedUserId;
        }

        //Now we query the Product Names.
        for(ProfileSkillUser oProfileSkillUser : [SELECT ProfileSkill.Product_Name__c FROM ProfileSkillUser WHERE UserId = :strUserId AND (Status__c = null OR 
                Status__c = 'Approved') AND ProfileSkill.Queue_Name__c != null AND ProfileSkill.Type__c = 'Product Manager']) {
            setManagedProductName.add(oProfileSkillUser.ProfileSkill.Product_Name__c);
        }

        //Now we prepare the query.
        strQuery  = 'Select Case_Number__c, Case_Priority__c, Case_Product__c,Case_Next_Action__c, Case_Owner__c, Case__r.Component__c, Case__r.Case_Timezone__c, Case__r.Case_Timezone__r.Name, ' + 
                'Case__r.Record_Type_Name__c, Id,Name,Case__c,Case__r.CaseNumber,Case__r.OwnerId,Type__c,Status__c,OwnerId,owner.Name, Comment__c, Case__r.Priority, Case__r.Status, CreatedDate, ' + 
                'Case__r.Support_Account__r.Name, Case__r.Subject, Case__r.Forecast_Product__c, Case__r.Case_Timezone_Name__c,Case_Owner_Team__c,Case__r.Case_Owner_Team__c, Case__r.Owner_Name__c ' + 
                ' From Case_Comment__c Where Case__r.Status <> \'Closed\' AND (Type__c = \'Callback\' OR  Type__c=\'Revise Priority\' OR Type__c = \'Escalation\' OR ' + 
                'Type__c = \'Live Assistance\') AND Is_Replied_To__c = false AND '; 
        if(boolHasManagerPermissionSet == true) {
            strQuery += '(Case__r.OwnerId = :strUserId OR Case__r.Forecast_Product__c IN : setManagedProductName)';
        } else {
            strQuery += ' Case__r.OwnerId = :strUserId'; 
        }

        //Now we execute the query.
        for(Case_Comment__c objCaseComment : Database.query(strQuery)){
            lstCaseComments.add(objCaseComment);
        }

        //Finally, we return the data.
        return lstCaseComments;
    }

    /*
     Method Name : getCurrentViewSaved
     Description : This method saves the current user view.
     Parameters  : String, called from getCurrentViewSaved, strSelection Latest user selection.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getCurrentViewSaved(String strSelection) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objRecord = new GCS_Subscription__c();
        List<GCS_Subscription__c> lstRecords = new List<GCS_Subscription__c>();

        //If we received data.
        if(String.isNotBlank(strSelection)) {

            //First we look for existing records.
            for(GCS_Subscription__c objExistingRecords : [SELECT Id FROM GCS_Subscription__c WHERE User__c = :strCurrentUserId WITH SECURITY_ENFORCED LIMIT 1000]) {
                objExistingRecords.Latest_Engineering_Workspace_View__c = strSelection;
                lstRecords.add(objExistingRecords);
            }

            //If no records found, we create a new one.
            if(lstRecords.isEmpty()) {
                objRecord.Latest_Engineering_Workspace_View__c = strSelection;
                lstRecords.add(objRecord);
            }

            //Now we upsert the records.
            upsert lstRecords;
        }
    }

    /*
     Method Name : getLatestViewSelected
     Description : This method returns the latest view selected by the user.
     Parameters  : None
     Return Type : String
     */
    @AuraEnabled(cacheable = false) 
    public static String getLatestViewSelected() {
        String strResult;
        String strCurrentUserId = UserInfo.getUserId();

        //We look for existing records.
        for(GCS_Subscription__c objExistingRecords : [SELECT Latest_Engineering_Workspace_View__c FROM GCS_Subscription__c WHERE User__c = :strCurrentUserId  
                 ORDER BY LastModifiedDate DESC LIMIT 1]) {
            strResult = objExistingRecords.Latest_Engineering_Workspace_View__c;
        }
        return strResult;
    }

    /*
     Method Name : getCurrentSplitterPositionSaved
     Description : This method saves the current splitter position.
     Parameters  : Integer, called from getCurrentSplitterPositionSaved, intPosition Latest splitter position.
     Return Type : None
     */
    @AuraEnabled(cacheable = false)
    public static void getCurrentSplitterPositionSaved(Integer intPosition) {
        String strCurrentUserId = UserInfo.getUserId();
        GCS_Subscription__c objRecord = new GCS_Subscription__c();
        List<GCS_Subscription__c> lstRecords = new List<GCS_Subscription__c>();

        //If we received data.
        if(intPosition != null) {

            //First we look for existing records.
            for(GCS_Subscription__c objExistingRecords : [SELECT Id FROM GCS_Subscription__c WHERE User__c = :strCurrentUserId WITH SECURITY_ENFORCED LIMIT 1000]) {
                objExistingRecords.Latest_Eng_Workspace_Splitter_Position__c = String.valueOf(intPosition);
                lstRecords.add(objExistingRecords);
            }

            //If no records found, we create a new one.
            if(lstRecords.isEmpty()) {
                objRecord.Latest_Eng_Workspace_Splitter_Position__c = String.valueOf(intPosition);
                lstRecords.add(objRecord);
            }

            //Now we upsert the records.
            upsert lstRecords;
        }
    }

    /*
     Method Name : getLatestViewSelected
     Description : This method returns the latest splitter position selected by the user.
     Parameters  : None
     Return Type : String 
     */
    @AuraEnabled(cacheable = false)
    public static Integer getLatestSplitterPositionSelected() {
        Integer intResult;
        String strCurrentUserId = UserInfo.getUserId();

        //We look for existing records.
        for(GCS_Subscription__c objExistingRecords : [SELECT Latest_Eng_Workspace_Splitter_Position__c FROM GCS_Subscription__c WHERE User__c = :strCurrentUserId  
                 ORDER BY LastModifiedDate DESC LIMIT 1]) {
            if(objExistingRecords.Latest_Eng_Workspace_Splitter_Position__c != null) {
                intResult = Integer.valueOf(objExistingRecords.Latest_Eng_Workspace_Splitter_Position__c);
            }   
        }
        return intResult;
    }
}