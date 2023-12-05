/*
* Name : IdeaTriggerHandler
* Author : Deeksha Shetty
* Created Date : February 1,2022
* Description : Controller for Idea Trigger
Change History
********************************************************************************************************************************
Modified By            Date                 Jira No.              Description                                            Tag
Deeksha Shetty         7/7/2022             I2RT-6502            Notification email for CRT/User group/Events/Ideas       T1
Deeksha Shetty         13/09/2023           I2RT-9074            Change Request Detail Page Enhancement                   T2
Deeksha Shetty         18-OCT-2023     I2RT-9269                 CR enhancement on list/tile view - Introducing Product   T3
                                                                 /Reported version/Fixed version/Current status

***********************************************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

public without sharing class IdeaTriggerHandler {
    
    /*
     * this method is invoked from Before insert event of Idea
     * @param newCrs - list of new Ideas
     * @return return-void
     */
    
    public void onBeforeInsert(List<Idea> newCrs){
        if(newCrs.size() > 0){
            manipulateBody(newCrs);
        }        
    }
    
    
    
    /**
    * this method is invoked from After Update event of Idea
    *
    * @param oldmap - map of Old Idea ,newMap - Map of New Idea, newIdeas - list of new Ideas
    * @return return-void
    */
    
    public void onAfterUpdate(Map<Id,Idea> oldmap,Map<Id,Idea> newMap,List <Idea> newIdeas){
        String sitelabel = System.Label.IN_CommunityName;
        Map<Id,Idea> oldstatusMap = new Map<Id,Idea>();
        Map<Id,Idea> newstatusMap = new Map<Id,Idea>();        
        set<Id> ownerMailIds = new Set<Id>();
        List<Id> ideaDrafttoNew = new List<Id>();
        Map<Id,String> CreatedByIdEmail = new Map<Id,String>();
        List<Id> newIdeaSet = new List<Id>();
        List<Id> newCRSet = new List<Id>();
        List<Id> allIdeaSet = new List<Id>();
        Map<Id,String> idoldstatus = new Map<Id,String>();
        Map<Id,String> idnewstatus = new Map<Id,String>();
        Map<Id,Idea> newIdeaMap = new Map<Id,Idea>();
        
        Map<Id,Community_Interactions__c> commuserIdemail = new Map<Id,Community_Interactions__c>();
        String Category;
        
        //for CR Body Manipulation
        Map<Id,Idea> newCRMap = new Map<Id,Idea>();
        List<Idea> updatedCrList = new List<Idea>();
        
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@informatica.com'];
        
        //Change Request Status change commnents
        for(Idea id1 : newIdeas){
            if(newMap.get(id1.Id) !=null &&(newMap.get(id1.Id).Categories=='Change Request' || newMap.get(id1.Id).Categories.contains('Change Request')) && newMap.get(id1.Id).Status != oldmap.get(id1.Id).Status){
                oldstatusMap.put(id1.Id,oldmap.get(id1.Id));
                newstatusMap.put(id1.Id,newMap.get(id1.Id)); 
            }
        }
        
        List<IdeaComment> ideaCommentList = new List<IdeaComment>();
        Map<Feed_Meta__c,Id> feedMetaMap = new Map<Feed_Meta__c,Id>();
        List<Feed_Meta__c> feedMetaList = new List<Feed_Meta__c>();
        List<Feed_Meta__c> feedMetaListtoInsert = new List<Feed_Meta__c>();
        List<FeedItem> FeedItemList = new List<FeedItem>();
        
        if(newstatusMap.size()>0){
            feedMetaList = [select Id, Name, Reference__c from Feed_Meta__c where Reference__c =:newstatusMap.keyset()];
            
            if(feedMetaList.size()>0){
                for(Feed_Meta__c fm : feedMetaList){
                    FeedItem fitem = new FeedItem();                    
                    fitem.Body = 'Status changed From'+' '+ oldstatusMap.get(fm.Reference__c).Status+' '+ 'to'+ ' '+ newstatusMap.get(fm.Reference__c).Status ;
                    fitem.ParentId = fm.Id;
                    fitem.Visibility = 'AllUsers' ;  
                    FeedItemList.add(fitem);
                }
                
                if(FeedItemList.size()>0)
                    insert FeedItemList;
                
            }
            else{
                for(Id idd : newstatusMap.keyset()){
                    Feed_Meta__c feeditem = new Feed_Meta__c();
                    feeditem.Reference_Type__c = 'Ideas';
                    feeditem.Reference__c = idd;                    
                    feedMetaListtoInsert.add(feeditem);
                    
                }
                if(feedMetaListtoInsert.size()>0)
                    insert feedMetaListtoInsert;
                
                for(Feed_Meta__c fm : feedMetaListtoInsert){
                    FeedItem fitem = new FeedItem();
                    fitem.Visibility = 'AllUsers' ;
                    fitem.Body = 'Status changed From'+' '+ oldstatusMap.get(fm.Reference__c).Status+' '+ 'to'+ ' '+ newstatusMap.get(fm.Reference__c).Status ;
                    fitem.ParentId = fm.Id;
                    FeedItemList.add(fitem);
                }
                if(FeedItemList.size()>0)
                    insert FeedItemList;
                
            }       
        }
        
        
        //added this for send mail part to the Idea Author when Idea status changes from Draft to New
        for(Idea id1 : newIdeas){
            if(newMap.get(id1.Id) !=null && newMap.get(id1.Id).Status != oldmap.get(id1.Id).Status
               && newMap.get(id1.Id).Status == 'New' && oldmap.get(id1.Id).Status =='Draft' ){
                   ownerMailIds.add(id1.CreatedById);
                   ideaDrafttoNew.add(id1.Id);                                    
               }
        }
        if(Global_Config__c.getInstance().Mute_Notifications__c != null && Global_Config__c.getInstance().Mute_Notifications__c != true)
        ideaStatusChangeMail(ownerMailIds,ideaDrafttoNew,idoldstatus,idnewstatus);  
        
        //added this for send email to Idea followers when Idea status changes from new to active or vice versa
        for(Idea id1 : newIdeas){
            if(newMap.get(id1.Id) !=null && newMap.get(id1.Id).Status != oldmap.get(id1.Id).Status &&
               oldmap.get(id1.Id).Status !='Draft'){
                   ownerMailIds.add(id1.CreatedById);
                   allIdeaSet.add(id1.Id);
                   newIdeaMap.put(id1.Id,id1);
                   idoldstatus.put(id1.Id,oldmap.get(id1.Id).Status);
                   idnewstatus.put(id1.Id,newMap.get(id1.Id).Status);
                   if(id1.Categories == 'Change Request' || id1.Categories.contains('Change Request')){
                       newCRSet.add(id1.Id);
                   }else{
                       newIdeaSet.add(id1.Id);
                   }
               }
        }
        
        
        
        if(allIdeaSet.size()>0){
            if(newIdeaSet.Size() > 0){
                if(Global_Config__c.getInstance().Mute_Notifications__c != null && Global_Config__c.getInstance().Mute_Notifications__c != true)
                ideaStatusChangeMail(ownerMailIds,newIdeaSet,idoldstatus,idnewstatus);    
            }
            List<Community_Interactions__c> cominteracList = [Select Id__c,Vote__c,User__c,Follow__c,Type__c from Community_Interactions__c where (Type__c='Idea' 
                                                                                                                                                   OR Type__c='CRT' )
                                                              AND Id__c IN:allIdeaSet AND Follow__c=true AND User__c NOT IN:ownerMailIds ];
            System.debug('cominteracList='+cominteracList);
            if(cominteracList.size()>0){
                for(Community_Interactions__c crec :  cominteracList){
                    commuserIdemail.put(crec.User__c,crec);
                }           
            }
        }
        
        if(commuserIdemail.size()>0){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();                   
            List<String> sendTo = getUserEmails(commuserIdemail.keyset());
            if(sendTo.size()>0) mail.setBccAddresses(sendTo);
            
            for(id usrId : commuserIdemail.keyset()){
                String url = sitelabel+'ideadetail?id='+commuserIdemail.get(usrId).Id__c;
                if(commuserIdemail.get(usrId).Type__c == 'Idea'){
                    mail.setSubject('Idea Status Change');
                    mail.setHtmlBody('Hello, <br/><br/>The Idea status has changed from '+idoldstatus.get(commuserIdemail.get(usrId).Id__c)+ ' to ' +idnewstatus.get(commuserIdemail.get(usrId).Id__c)+ '<br/>Please redirect to this Idea for more info :'+url+'<br/><br/>Thanks,<br/> Team Informatica');                                         
                }
                else{
                    // T1 starts here
                    
                    mail.setSubject('CR Status Change');
                    EmailTemplate emailTemplate = [SELECT Id,HtmlValue, Body, Subject, Description FROM EmailTemplate where name = 'CR Status Custom Template'];
                    String htmlBody = emailTemplate.HtmlValue;
                    String plainBody = emailTemplate.Body;
                    
                    htmlBody = htmlBody.replace('oldval', idoldstatus.get(commuserIdemail.get(usrId).Id__c));
                    htmlBody = htmlBody.replace('newval', idnewstatus.get(commuserIdemail.get(usrId).Id__c));
                    Idea templateIdea = newIdeaMap.get(commuserIdemail.get(usrId).Id__c);
                    if(templateIdea.Categories.contains(';')){
                        List<String> Categorylist = templateIdea.Categories.split(';');                   
                        Categorylist.remove(Categorylist.indexOf('Change Request'));
                        Category = (Categorylist[0]=='Change Request') ? Categorylist[1] : Categorylist[0];
                    }
                    
                    htmlBody = htmlBody.replace('ideatitle',templateIdea.Title);
                    
                    if(Category!=null) htmlBody = htmlBody.replace('prod',Category);
                    else htmlBody = htmlBody.replace('<b> Product :</b> prod <br/>','');
                    
                    if(templateIdea.Reported_Version__c!=null) htmlBody = htmlBody.replace('rv', templateIdea.Reported_Version__c);
                    else htmlBody = htmlBody.replace('<b>Reported Version:</b>rv<br/>', '');
                    
                    if(templateIdea.To_be_Fixed_in_version__c !=null){
                        htmlBody = htmlBody.replace('fv', templateIdea.To_be_Fixed_in_version__c);
                        plainBody = plainBody.replace('fv', templateIdea.To_be_Fixed_in_version__c);
                    }
                    else{
                        htmlBody = htmlBody.replace('<b>To be fixed Version: </b> fv<br/>', '');
                        plainBody = plainBody.replace('To be fixed Version: fv', '');
                    }
                    
                    htmlBody = htmlBody.replace('link',url);
                    
                    plainBody = plainBody.replace('oldval', idoldstatus.get(commuserIdemail.get(usrId).Id__c));
                    plainBody = plainBody.replace('newval', idnewstatus.get(commuserIdemail.get(usrId).Id__c));                    
                    plainBody = plainBody.replace('ideatitle',templateIdea.Title);
                    
                    if(Category!=null) plainBody = plainBody.replace('prod',Category);
                    else plainBody = plainBody.replace('Product : prod','');
                    
                    if(templateIdea.Reported_Version__c!=null) plainBody = plainBody.replace('rv', templateIdea.Reported_Version__c);
                    else plainBody = plainBody.replace('Reported Version:rv','');
                    
                    plainBody = plainBody.replace('here',url);                    
                    mail.setHtmlBody(htmlBody);
                    mail.setPlainTextBody(plainBody);
                    mail.setTemplateID(emailTemplate.Id);
                    mail.setSaveAsActivity(false);
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    // T1 ends here
                }                                        
            }
            
            try{
                if(Global_Config__c.getInstance().Mute_Notifications__c != null && Global_Config__c.getInstance().Mute_Notifications__c != true)
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }catch(exception e){
                apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
            }            
        }                       
        
        
        //if status/title/categories/Reported_Version__c/Bug_Enhancement_Number__c of CR changes,CR Body should be updated
        
        for(Idea id1 : newIdeas){
            if(newMap.get(id1.Id) !=null &&(newMap.get(id1.Id).Categories=='Change Request' || newMap.get(id1.Id).Categories.contains('Change Request')) && 
               ( (newMap.get(id1.Id).Status != oldmap.get(id1.Id).Status) || (newMap.get(id1.Id).Categories != oldmap.get(id1.Id).Categories) ||
                (newMap.get(id1.Id).Title != oldmap.get(id1.Id).Title) ||(newMap.get(id1.Id).Bug_Enhancement_Number__c != oldmap.get(id1.Id).Bug_Enhancement_Number__c) ||
                (newMap.get(id1.Id).Reported_Version__c != oldmap.get(id1.Id).Reported_Version__c) || (newMap.get(id1.Id).Body != oldmap.get(id1.Id).Body)||
                (newMap.get(id1.Id).To_be_Fixed_in_version__c != oldmap.get(id1.Id).To_be_Fixed_in_version__c) ||
                (newMap.get(id1.Id).Issue_Type__c  != oldmap.get(id1.Id).Issue_Type__c ) ||
                (newMap.get(id1.Id).Customer_Communication__c   != oldmap.get(id1.Id).Customer_Communication__c )               
               ) ){
                   newCRMap.put(id1.Id,id1);
               }
        }
        
        List<Idea> toManipulateCrList =[SELECT Id,Body,Title,Categories,Status, Bug_Enhancement_Number__c,Reported_Version__c,Issue_Type__c,  
                                        Customer_Communication__c,To_be_Fixed_in_version__c from Idea where Id IN:newCRMap.keyset()];
        
        if(toManipulateCrList.size()>0){
            updatedCrList = manipulateBody(toManipulateCrList);
        }        
        
        if(updatedCrList.size()>0) update updatedCrList;
        
    }
    
    /*
     * this method is invoked from Before insert and After Update event of Idea to Manipulate Body Field
     * @param newCrs - list of new Ideas
     * @return return- List<Idea>
     */
    
    public static List<Idea> manipulateBody(List<Idea> newCrs){
        String Category;
        List<Idea> updatedCrList = new List<Idea>();
        
        /* T2 starts - Rename the column name from 'Bug / Enhancement Number' to 'Change Request Number'
         * Add 'Change Request Type' field next to Change Request Number. Type field should be mapped to 'Issue Type' field from Jira
         * Rename the 'Current Status' field to 'Status'
         * Add Comment field at the Bottom of the table after field To be Fixed in version. Comment field should be mapped to 'Customer Communication' field from Jira
         * Table should show the field ONLY if there is value, else do not show the field*/
        
        if(newCrs.size()>0){
            for(Idea id1: newCrs){
                if(id1.Categories.contains(';')){
                    List<String> Categorylist = id1.Categories.split(';');                   
                    Categorylist.remove(Categorylist.indexOf('Change Request'));
                    Category = (Categorylist[0]=='Change Request') ? Categorylist[1] : Categorylist[0];
                }
                
                id1.Body = '<table border="1" cellpadding="5" cellspacing="0" style="width: 100%;"><tbody><tr><td colspan="2" rowspan="1" style="color: black; font-weight: bold;">Change Request Information</td></tr><tr valign="bottom"><td style="white-space: nowrap" colspan="1" rowspan="1"><strong>Change Request Number</strong></td><td colspan="1" rowspan="1">'+id1.Bug_Enhancement_Number__c +'</td></tr>CHANGEREQUESTTYPE<tr valign="top"><td colspan="1" rowspan="1" style=""><strong>Title</strong></td><td colspan="1" rowspan="1">'+id1.Title+'</td></tr>CATEGORY*REPORTEDVERSION*<tr valign="top"><td colspan="1" rowspan="1"><strong>Status</strong></td><td colspan="1" rowspan="1">'+id1.Status+'</td></tr>TOBEFIXEDINVERSION';
                
                //T3 - to include Reported Version is Null or not
                if(id1.Reported_Version__c  !=null){
                    id1.Body = id1.Body.replace('*REPORTEDVERSION*','<tr valign="top"><td colspan="1" rowspan="1"><strong>Reported Version</strong></td><td colspan="1" rowspan="1">'+id1.Reported_Version__c  +'</td></tr>');
                }
                else id1.Body = id1.Body.replace('*REPORTEDVERSION*','');
                                
                if(id1.To_be_Fixed_in_version__c !=null){
                    id1.Body = id1.Body.replace('TOBEFIXEDINVERSION','<tr valign="top"><td colspan="1" rowspan="1"><strong>To be Fixed in version</strong></td><td colspan="1" rowspan="1">'+id1.To_be_Fixed_in_version__c +'</td></tr>');
                }
                else id1.Body = id1.Body.replace('TOBEFIXEDINVERSION','');
                
                if(Category !=null){
                    id1.Body = id1.Body.replace('CATEGORY','<tr valign="top"><td colspan="1" rowspan="1"><strong>Product</strong></td><td colspan="1" rowspan="1">'+Category+'</td></tr>');
                }
                else id1.Body = id1.Body.replace('CATEGORY','');
                
                if(id1.Issue_Type__c!=null){
                    id1.Body = id1.Body.replace('CHANGEREQUESTTYPE','<tr valign="bottom"><td colspan="1" rowspan="1"><strong>Change Request Type</strong></td><td colspan="1" rowspan="1">'+id1.Issue_Type__c  +'</td></tr>');
                }
                else id1.Body = id1.Body.replace('CHANGEREQUESTTYPE','');
                
                /*if(id1.Customer_Communication__c!=null){
                    id1.Body = id1.Body.replace('<CUSTOMERCOM','<tr valign="top"><td colspan="1" rowspan="1"><strong>Comment</strong></td><td colspan="1" rowspan="1">'+id1.Customer_Communication__c +'</td></tr>');
                }
                else id1.Body = id1.Body.replace('<CUSTOMERCOM','');*/
                
                System.debug('Id1 Body>'+id1.Body);                
                
                updatedCrList.add(id1);
            }
        }
        /* T2 ends*/
        return updatedCrList;        
    }
    
    
    //this common method is used to send email to the authors when Status changes
    public static void ideaStatusChangeMail(Set<Id> ownerIds,List<Id> newStatusChangeIds,Map<Id,String> oldstatus,Map<Id,String> newstatus){
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();                   
        List<String> sendTo = getUserEmails(ownerIds);                   
        mail.setToAddresses(sendTo);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@informatica.com'];
        mail.setOrgWideEmailAddressId(owea.Id);
        for(Id id1 : newStatusChangeIds){       
            mail.setSubject('Idea Status Change');
            String sitelabel = System.Label.IN_CommunityName;
            String url = sitelabel+'ideadetail?id='+id1;
            if(oldstatus.size()>0 && newstatus.size()>0){
                mail.setHtmlBody('Hello, <br/><br/>The Idea status has changed from '+ oldstatus.get(id1) +' to '+ newstatus.get(id1)+ '<br/>Please redirect to this Idea for more info :'+url+'<br/><br/>Thanks,<br/> Team Informatica');                            
            }
            else{
                mail.setHtmlBody('Hello, <br/><br/>The Idea status has changed From Draft to New <br/>Please redirect to this Idea for more info :'+url+'<br/><br/>Thanks,<br/> Team Informatica');            
            }
        }        
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(exception e){
            System.debug('e='+e.getMessage()+'exception in--'+e.getStackTraceString());
        }
    }
    
    //this method gets the emails for the users
    public static List<String> getUserEmails(Set<id> usrIds){
        List<String> userEmails = new List<String>();
        for(User u : [select email from user where Id=:usrIds]){
            userEmails.add(u.email);        
        }
        if(userEmails.size()>0){
            return userEmails;
        }
        else return null;        
    }
    
}