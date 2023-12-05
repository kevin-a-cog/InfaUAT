/*
    @created by       : balajip
    @created on       : 03/02/2020
    @Purpose          : To call Microsoft PowerAutomate flow that sends out Teams and SMS notifications.
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag         Description
Nishit S		05/20/2022  TAX-255		<TAX-255>	Need a notification for when CMS team populates the ERP Id's for Account on Quote
balajip         07/01/2022	I2RT-6152   T02		    To include Account/case team members in the email address list
Narpavi prabu   13/10/2022  AR-2924     T03         To Include Plan team in the email address list
Narpavi Prabu   22/12/2022  AR-3008     T04         Include the condition to send  notification only for primary CSM and CSM Manager 
                                                    role is selected in Plan Team
                                                    Fix the chatter post message format for group
Nishant         07/03/2023  SALESRT-14945           To include the Opportunity team members 
Isha B          05/07/2023  I2RT-8616    T06        Fix code for power automate notifications. 
                                                    Notification user id logic in the parent class - NotificationService
****************************************************************************************************

*/
public class NotificationPowerAutomate extends Notification{

    public NotificationPowerAutomate(){

    }

    public class PARequest{
        Set<Id> CriteraId;
        String Title;
        String Message;
        String EmailMessage;
        String MessageForChatter;
        Set<String> allUserIds;
        Set<String> EmailAddresses;
    }

    public override void send(){
        for (CriteriaInfo criteriaInfo : setCriteriaInfo){
                //starts
            List<String> setNotifType = criteriaInfo.criteria.Notification_Type__c.split(';');
           // Map<String, Set<String>> mapNotifTypeToUsers = new Map<String, Set<String>>();
          
            Set<String> tagUsersId = new Set<String>();
            Set<String> emailFieldSet = new Set<String>();
            tagUsersId.addAll(criteriaInfo.setUserId);//T06            

            /* commented as part of T06

            for(Notification_User__c notifUser : criteriaInfo.criteria.Notification_Users__r){   
                 
                if(notifUser.User_Type__c == 'Account Team' || notifUser.User_Type__c == 'Case Team' || notifUser.User_Type__c == 'Plan Team' || notifUser.User_Type__c == 'Opportunity Team'){                    
                    Set<Id> accountSet = new Set<Id>();
                    Set<Id> caseSet = new Set<Id>();
                    Set<Id> planteamset = new Set<Id>();
                    Set<Id> oppIdSet = new Set<Id>();
                    
                    List<String> teamMemberRole = new List<String>();
                    if(notifUser.Team_Member_Role__c <> null){
                        teamMemberRole = notifUser.Team_Member_Role__c.split(',');
                    }
                    String query;
                    if(notifUser.User_Type__c == 'Account Team' || (notifUser.User_Type__c == 'Opportunity Team' &&  criteriaInfo.criteria.Object__c != 'Opportunity')){
                        query = 'SELECT Id,';
                        query += notifUser.Account_Case_Fields__c;
                        query += ' FROM ';
                        query += criteriaInfo.criteria.Object__c;
                        query += ' WHERE Id=\'';
                        query +=  recordId +'\'';   

                        for (sObject record : Database.query(query)){
                            if(notifUser.User_Type__c == 'Account Team') {
                                accountSet.add((Id)record.get(notifUser.Account_Case_Fields__c));
                            } else if(notifUser.User_Type__c == 'Opportunity Team') {
                                oppIdSet.add((Id)record.get(notifUser.Account_Case_Fields__c));
                            }
                            
                            //caseSet.add((Id)record.get(notifUser.Account_Case_Fields__c));
                        }
                    } else if (notifUser.User_Type__c == 'Opportunity Team' &&  criteriaInfo.criteria.Object__c == 'Opportunity') {
                        oppIdSet.add(recordId);
                    }
                                                                            
                    if(notifUser.User_Type__c == 'Account Team'){
                        String accQueryStr = 'SELECT AccountId,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId IN :accountSet';
                        for(AccountTeamMember member : Database.query(accQueryStr)){
                            if((teamMemberRole <> null && teamMemberRole.size() > 0 && teamMemberRole.contains(member.TeamMemberRole)) || (teamMemberRole.size() == 0)){
                                tagUsersId.add(member.UserId); 
                            }
                            
                        }   
                    }else if(notifUser.User_Type__c == 'Case Team'){
                        system.debug('---caseSet 87---'+caseSet);
                        //Deva : converted below commented logic to fit for custom case team logic
                        if(caseSet.size()>0){
                            for(Case_Team__c caseTM:[SELECT Id, User__c, Role__c FROM Case_Team__c WHERE Case__c IN : caseSet]){
                                if(caseTM.User__c!=null && ((teamMemberRole <> null && teamMemberRole.size() > 0 && String.isNotBlank(caseTM.Role__c) && teamMemberRole.contains(caseTM.Role__c))
                                                                || (teamMemberRole.size() == 0))){
                                    tagUsersId.add(caseTM.User__c); 
                                }
                            }
                        }
                    }
                    //<T03> - Included query and condition for the plan team in email- <START> 
                    else if(notifUser.User_Type__c == 'Plan Team'){                                              
                       query = 'SELECT Id';
                      if(criteriaInfo.criteria.Object__c != 'Plan__c' && !Test.isRunningTest()){                      
                        query +=  ',Plan__c';
                        }                     
                        query += ' FROM ';
                        query += criteriaInfo.criteria.Object__c;
                        query += ' WHERE Id=\'';
                        query +=  recordId +'\'';  
                        
                        for (sObject record : Database.query(query)){                          
                            if(criteriaInfo.criteria.Object__c == 'Plan__c')
                              {
                                planteamset.add(recordId);
                                system.debug('PlanTeam User--->'+planteamset);
                              }  
                            else if( criteriaInfo.criteria.Object__c != 'Plan__c' && !Test.isRunningTest())
                             {
                                planteamset.add((Id)record.get('Plan__c')); 
                                system.debug('PlanTeam User for Other CSP--->'+planteamset);
                             }         
                        }

                        if(planteamset.size()>0){
                            for(Plan_Team__c planTM:[SELECT Id, User__c, Role__c,Primary__c FROM Plan_Team__c WHERE Plan__c IN : planteamset]){
                                if(planTM.User__c!=null && ((teamMemberRole <> null && teamMemberRole.size() > 0 && String.isNotBlank(planTM.Role__c) && teamMemberRole.contains(planTM.Role__c))
                                                            || (teamMemberRole.size() == 0)))
                                {
                                   //<T04>
                                   if((planTM.Role__c == 'CSM' || planTM.Role__c == 'CSM Manager') )
                                   {                                                                                                                                                   
                                        if((planTM.Primary__c))
                                        {
                                            tagUsersId.add(planTM.User__c); 
                                        }    
                                   }else if(planTM.Role__c !='CSM' || planTM.Role__c !='CSM Manager'){
                                      tagUsersId.add(planTM.User__c); 

                                   }
                                  //</T04>                             
                                                               
                                }
                            }
                        }
                    } else if(notifUser.User_Type__c == 'Opportunity Team') {
                        for(OpportunityTeamMember member : [SELECT Id, OpportunityId, TeamMemberRole, UserId FROM OpportunityTeamMember WHERE OpportunityId IN: oppIdSet]) {
                            if((teamMemberRole <> null && teamMemberRole.size() > 0 && teamMemberRole.contains(member.TeamMemberRole)) || (teamMemberRole.size() == 0)){
                                tagUsersId.add(member.UserId);
                            }
                            
                        }
                    }   
                    //</T03> -<END>                                     
                }
                //<TAX-255> START
                else if(notifUser.User_Type__c == 'Related User'){ //TAX-255
                    String[] relatedFields = notifUser.Related_Fields__c?.split(',');
                    String query = 'SELECT Id';
                    for(String relatedField : relatedFields){
                        query += ', ' + relatedField ;
                    }
                    query += ' FROM ';
                    query += criteriaInfo.criteria.Object__c;
                    query += ' WHERE Id=\'';
                    query +=  recordId +'\'';    
                    List<sObject> resultList = Database.query(query);
                    for(sObject record : resultList){   
                        for(String field : relatedFields){
                            sObject recordTemp = record;
                            system.debug('NotificationPowerAutomate, field = '+field);

                            while(field.contains('.')){
                                recordTemp = (sObject)recordTemp.getSObject(field.substringBefore('.'));
                                //record = (sObject)record.get(field.substringBefore('.').replace('__r', '__c'));
                                system.debug('NotificationPowerAutomate, recordTemp = '+recordTemp);
                                field = field.substringAfter('.');
                                system.debug('NotificationPowerAutomate, field 2 = '+field);
                            }    
                            if(recordTemp.isSet(field) && recordTemp.get(field) != null){
                                if(String.valueOf(recordTemp.get(field))?.startsWithIgnoreCase('005')){
                                    tagUsersId.add(String.valueOf(recordTemp.get(field))); //T02
                                }
                            }
                        }
                    }
                }
                else if(notifUser.User_Type__c == 'Queue'){ //TAX-255
                    if(notifUser.Queue_Name__c != NULL){
                        for(GroupMember gm : [SELECT UserOrGroupId from GroupMember where GroupId = :notifUser.Queue_Name__c]){
                            if(((String)gm.UserOrGroupId)?.startsWithIgnoreCase('005')){
                                tagUsersId.add(gm.UserOrGroupId); //T02
                            }
                        }
                    }
                }
            }
            
            */
            system.debug('-tagUsersId--'+tagUsersId); //T06
            //T02
            if(!tagUsersId.isEmpty()){
                for(User usr : [SELECT Email FROM User WHERE Id IN :tagUsersId]){
                    emailFieldSet.add(usr.Email);
                }    
            }
            system.debug('--emailFieldSet--'+emailFieldSet); //T06
            //<TAX-255> END

            PARequest request = new PARequest();
            request.CriteraId = new Set<Id>{criteriaInfo.criteria.Id};
            request.Title = criteriaInfo.message.title;
            request.Message = criteriaInfo.message.bodyText.replaceAll('\n', '\n\n');
            //<T04>
            request.MessageForChatter = criteriaInfo.message.bodyText.replaceAll('\n', '<br/>'); 
            //</T04>
            request.EmailMessage = criteriaInfo.message.bodyHTML;
            request.EmailAddresses = emailFieldSet;
            User u = [select id from User Where id=:UserInfo.getUserId()];
            tagUsersId.add(u.Id);
            if(!tagUsersId.isEmpty()){
                request.allUserIds = tagUsersId;
            }

            String requestBody = JSON.serialize(request);
            System.debug('requestBody - ' + requestBody);
            doCallout(requestBody);
        }
    }

    @future(callout=true)
    public static void doCallout(String body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.Notification_MS_PA_Endpoint);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setBody(body);
        System.debug('body---:'+body);
        if(!Test.isRunningTest()){
            HTTPResponse res = new Http().send(req);
            //System.debug('response code = ' + res.getStatusCode());
            //System.debug('status = ' + res.getStatus());
            //System.debug('body = ' + res.getBody());    
        }
    }
}