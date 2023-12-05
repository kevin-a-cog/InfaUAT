/*
On the server side, the Apex controller includes
Aura-enabled methods that accept a list of emails as parameters.
*/

public class OutlookEmailController {
    
    
    /*
This method searches for Account contacts and and opty owners
of the plans and interlocks respectively.  
*/
    /**
*————————————————————————————————————————————————————
* @Description: To show the emails in the UI for the outlook integration component
* @author Aishwarya | 08-10-2020
*————————————————————————————————————————————————————
* @param ref id and subject
* @return JSON wrapper
*————————————————————————————————————————————————————
**/
    
    @AuraEnabled 
    public static String fetchContacts(List<String> refid, String subj) { 
        System.debug('Entry fetchContacts--RefId-->'+refid);
        System.debug(refid);
        
        System.debug('subj-->'+subj);
        String returnString='';
        EmailWrapper ew= new EmailWrapper();
        EmailWrapper ew1= new EmailWrapper();
        List<EmailWrapper> wrapperList= new List<EmailWrapper>();
        if(refid != null && refid.size() > 0){
            
            List<Plan__c> plns = [SELECT Id,Account__c,Name from Plan__c where Thread_Id__c in :refid LIMIT 1];
            System.debug('plns-->'+plns);
            if(plns!=null && plns.size()>0)
            {
                List<Contact> conlist = [Select Id,Email,Name from Contact where AccountId = :plns[0].Account__c];
                system.debug('conlist:'+conlist);
                
                wrapperList= new List<EmailWrapper>();
                if(conlist!=null && conlist.size()>0)
                {
                    for(Contact c :conlist)
                    {
                        ew= new EmailWrapper();
                        if(c.Name!=null)
                            ew.Name=c.Name;
                        if(c.Email!=null)
                            ew.Email=c.Email;
                        ew.Type='Account Contact(s)';
                        wrapperList.add(ew);
                    }
                }
                
                System.debug('wrapperList-->'+wrapperList);   
                if(wrapperList!=null && wrapperList.size()>0)
                {
                    returnString=JSON.serialize(wrapperList);
                }
                
                //Customer_Success_Email
            }else 
            {
                
                if(subj!=null && subj.containsIgnoreCase(System.Label.SMGHandOff))//SMG Hand Off
                {
                    List<Related_Opportunity_Plan__c> interlockItems=[select Id,Name,Account__c,Opportunity__c,Opportunity__r.OwnerId from Related_Opportunity_Plan__c where Thread_Id__c in :refid limit 1];
                    if(interlockItems!=null && interlockItems.size()>0 && interlockItems[0].Opportunity__c!=null && interlockItems[0].Opportunity__r.OwnerId!=null)
                    {
                        List<User> usr=[select Id,Email,Name from User where Id=:interlockItems[0].Opportunity__r.OwnerId];
                        System.debug('usr-->'+usr);
                        ew= new EmailWrapper();
                        ew1= new EmailWrapper();
                        wrapperList= new List<EmailWrapper>();
                        if(usr!=null && usr.size()>0)
                        {
                            ew.Name=usr[0].Name;
                            ew.Email=usr[0].Email;
                        }
                        
                        ew.Type='Email Address(s)';
                        ew1.Name='Customer Success';
                        ew1.Email=System.Label.Customer_Success_Email;
                        ew1.Type='Email Address(s)';
                        wrapperList.add(ew);
                        wrapperList.add(ew1);
                        returnString=JSON.serialize(wrapperList);
                    }
                    
                }
                else if(subj!=null && subj.containsIgnoreCase(System.Label.CSMRequestRegion) )//CSM Request – Region
                {
                    System.debug('Renewal Rescue Information and Adoption Services Engagement Request	-->');
                    ew= new EmailWrapper();
                    ew.Name='Adoption Services';
                    //ew.Email='adoptionsvcsapprove@informatica.com';
                    ew.Email=System.Label.Adoption_Email;
                    ew.Type='Email Address(s)';
                    ew1= new EmailWrapper();
                    ew1.Name='Customer Success';
                    ew1.Email=System.Label.Customer_Success_Email;
                    ew1.Type='Email Address(s)';
                    
                    wrapperList.add(ew);
                    wrapperList.add(ew1);
                    returnString=JSON.serialize(wrapperList);
                }
            }
        } else {
            return null;
        }
        System.debug('returnString-->'+returnString);
        return returnString;
        
    }   
    
    /**
* @description To retrieve Email Message
* @author Venky | 08-10-2020 
* @param emailids 
* @return List<Wrapperobj> 
**/
    
    @AuraEnabled  
    public static List<Wrapperobj> fetchemails(List<Id> emailids) {          
        system.debug(emailids);
        List<EmailMessage> emailsToBeUpdated= new List<EmailMessage>();
        List<EmailMessage> emails = 
            [SELECT Id,Subject,FromAddress,TextBody,ToAddress,HtmlBody,CcAddress,MessageDate  FROM EmailMessage 
             WHERE Id  IN :emailids ];
        
        
        User sentfrom = new User();
        for(User u: [Select Id,Name,Email from user where Email = :emails[0].FromAddress LIMIT 1]){
            sentfrom = u;   
        }
        List<Wrapperobj> wrobjlist = new List<Wrapperobj>();
        if(emails!=null && emails.size()>0)
        {
            for(EmailMessage em: emails){
                Wrapperobj wr = new Wrapperobj();
                if(sentfrom.Id != null)
                    wr.u = sentfrom;
                wr.em = em;
                wrobjlist.add(wr);
                em.Status__c='Read';
                em.Last_Modified_Date__c=System.now();
                emailsToBeUpdated.add(em);
            }
        }
        try
        {
            if(emailsToBeUpdated!=null && emailsToBeUpdated.size()>0)
            {
                update emailsToBeUpdated;
            }  
        }catch(Exception e)
        {
            System.debug('ERROR at -->'+e.getLineNumber()+'MESSAGE==>'+e.getMessage());
        }
        
        
        return wrobjlist;
        
    }      
    /**
* @description To retrieve Attachment
* @author Aishwarya | 09-17-2020 
* @param emailids 
* @return List<ContentVersion> 
**/
    @AuraEnabled
    public static List<ContentVersion> fetchAttachments(String emessageId) {  
        System.debug('Fetch Attachments Entry-->'+emessageId);
        List<ContentVersion> contents=new List<ContentVersion>();
        Set<Id> attachmentIds=new Set<Id>();
        
        List<Attachment> attachments=[SELECT Id,Name,Body,ParentId FROM Attachment WHERE ParentId =:emessageId];
        if(attachments!=null && attachments.size()>0)
        {
            for(Attachment att : attachments){
                System.debug('att-->'+att);   
                attachmentIds.add(att.Id);
                ContentVersion cont = new ContentVersion();
                cont.Title = att.Name;
                cont.PathOnClient =  att.Name;
                cont.VersionData = att.Body;
                contents.add(cont);
            }
        }
        
        try
        {
            if(contents!=null && contents.size()>0)
            {
                insert contents;
            }
            
        }catch(DMLException dml)
        {
            System.debug('DML Exception-->'+dml.getMessage());
        }catch(Exception e)
        {
            System.debug('DML Exception-->'+e.getMessage()+'--line number--'+e.getLineNumber());
        }
        System.debug('contentVersions-->'+contents);
        
        return contents;
        
    }
    
    /**
* @description To retrieve Email Message
* @author Venky | 08-10-2020 
* @param emailids 
* @return List<Wrapperobj> 
**/
    
    @AuraEnabled  
    public static InterlockWrapper fetchInterlock(Id interlockid) {         
        System.debug('Fetch Interlock Entry-->'+interlockid);
        
        Related_Opportunity_Plan__c interlock = [Select Id,Interlock_Type__c,Account__c,Account__r.Name,Solution_Type__c,Project_Name__c,IPS_Project__c,IPS_Package__c,Products__c,Expected_Start_Date__c,
                                                 First_Value__c,Implementation_Owner__c,Support_Level__c,Success_Pack__c,Original_Opportunity__c,Original_Opportunity__r.Name,Technical_Use_Case__c,Adopted_Products__c,Non_Adopted__c,
                                                 Original_Opportunity_Number__c,Opportunity__c,Contract_StartDate__c,Contract_EndDate__c,Opportunity_ARR__c,Comments__c,Thread_Id__c,Account_Region_formula__c,Interested_products__c,
                                                 IPS_Project_Manager_Email__c,CreatedBy.Name,Opportunity_Owner_Email__c,Plan_Owner_Email_Address__c,Old_Org_Opportunity_Number__c,Renewal_Likelihood__c,Do_We_have_renewal_commitment__c,
                                                 Is_First_Year_Renewal__c,Last_Contact_Date__c,Contact__c,Contact__r.Name,Owner.FirstName,Owner.LastName,Highest_Role_Engaged_With__c,Business_Use_Case__c,Adoption_Challenges__c,CSM_Summary__c,Additional_Information__c,
                                                 Renewal_Date_formula__c,Partner_name_if_any__c,Level_of_Risk__c,Key_customer_contact__c,Primary_challenge_s__c,Opportunity_Number__c FROM Related_Opportunity_Plan__c where id = :interlockid];
        
        InterlockWrapper wrapper=new InterlockWrapper();
        if(interlock!=null)
        {
            wrapper.Id=interlock.Id;
            if(interlock.Interlock_Type__c!=null)
                wrapper.InterlockType=interlock.Interlock_Type__c;
            if(interlock.Account__c!=null)
                wrapper.AccountId=interlock.Account__c;
            //public String Account__r.Name;
            if(interlock.Account__c!=null && interlock.Account__r.Name!=null)
                wrapper.AccountName=interlock.Account__r.Name;
            if(interlock.Account_Region_formula__c!=null)
                wrapper.AccountRegion=interlock.Account_Region_formula__c;
            if(interlock.Opportunity_Number__c!=null)
                wrapper.OpportunityNumber=interlock.Opportunity_Number__c;
            if(interlock.Products__c!=null)
                wrapper.Products=interlock.Products__c;
            if(interlock.Solution_Type__c!=null)
                wrapper.SolutionType=interlock.Solution_Type__c;
            if(interlock.Expected_Start_Date__c!=null)
                wrapper.ExpectedStartDate=String.valueOf(interlock.Expected_Start_Date__c);
            if(interlock.First_Value__c!=null)
                wrapper.FirstValue=interlock.First_Value__c;
            if(interlock.Implementation_Owner__c!=null)
                wrapper.ImplementationOwner=interlock.Implementation_Owner__c;
            if(interlock.Support_Level__c!=null)
                wrapper.SupportLevel=interlock.Support_Level__c;
            if(interlock.Success_Pack__c!=null)
                wrapper.SuccessPack=interlock.Success_Pack__c;
            if(interlock.Original_Opportunity__c!=null)
                wrapper.OriginalOpportunity=interlock.Original_Opportunity__c;
            if(interlock.Original_Opportunity__c!=null && interlock.Original_Opportunity__r.Name!=null)
                wrapper.OriginalOpportunityName=interlock.Original_Opportunity__r.Name;
            System.debug('OriginalOpportunityName-->'+wrapper.OriginalOpportunityName);
            if(interlock.Original_Opportunity_Number__c!=null)
                wrapper.OriginalOpportunityNumber=interlock.Original_Opportunity_Number__c;
            if(interlock.Contract_StartDate__c!=null)
                wrapper.ContractStartDate=String.valueof(interlock.Contract_StartDate__c);
            if(interlock.Contract_EndDate__c!=null)
                wrapper.ContractEndDate=String.valueof(interlock.Contract_EndDate__c);
            if(interlock.Opportunity_ARR__c!=null)
                wrapper.OpportunityARR=String.valueof(interlock.Opportunity_ARR__c);
            if(interlock.Comments__c!=null)
                wrapper.Comments=interlock.Comments__c;
            if(interlock.Thread_Id__c!=null)
                wrapper.ThreadId=interlock.Thread_Id__c;
            if(interlock.Owner!=null)
            {
                if(interlock.Owner.FirstName!=null)
                    wrapper.OwnerFirstName=interlock.Owner.FirstName;
                if(interlock.Owner.LastName!=null)
                    wrapper.OwnerLastName=interlock.Owner.LastName;
            }
            if(interlock.Project_Name__c!=null)
                wrapper.ProjectName=interlock.Project_Name__c;
            if(interlock.IPS_Project__c!=null)
                wrapper.IPSProject=interlock.IPS_Project__c;
            if(interlock.IPS_Package__c!=null)
                wrapper.IPSPackage=interlock.IPS_Package__c;
            if(interlock.Opportunity__c!=null)
                wrapper.Opportunity=interlock.Opportunity__c;
            if(interlock.Opportunity_Owner_Email__c!=null)
                wrapper.OpportunityOwnerEmail=interlock.Opportunity_Owner_Email__c;
            if(interlock.Old_Org_Opportunity_Number__c!=null)
                wrapper.OldOrgOpportunityNumber=interlock.Old_Org_Opportunity_Number__c;
            if(interlock.Level_of_Risk__c!=null)
                wrapper.LevelofRisk=interlock.Level_of_Risk__c;
            if(interlock.Renewal_Likelihood__c!=null)
                wrapper.RenewalLikelihood=interlock.Renewal_Likelihood__c;
            if(interlock.Do_We_have_renewal_commitment__c!=null)
                wrapper.DoWehaverenewalcommitment=String.valueOf(interlock.Do_We_have_renewal_commitment__c);
            if(interlock.Is_First_Year_Renewal__c!=null )
                wrapper.IsFirstYearRenewal=String.valueof(interlock.Is_First_Year_Renewal__c);
            if(interlock.Last_Contact_Date__c!=null)
                wrapper.LastContactDate=String.valueOf(interlock.Last_Contact_Date__c);
            if(interlock.Contact__c!=null)
                wrapper.Contact=interlock.Contact__c;
            if(interlock.Contact__c!=null && interlock.Contact__r.Name!=null)
                wrapper.ContactName=interlock.Contact__r.Name;
            if(interlock.Highest_Role_Engaged_With__c!=null)
                wrapper.HighestRoleEngagedWith=interlock.Highest_Role_Engaged_With__c;
            if(interlock.Business_Use_Case__c!=null)
                wrapper.BusinessUseCase=interlock.Business_Use_Case__c; 
            if(interlock.Technical_Use_Case__c!=null)
                wrapper.TechnicalUseCase=interlock.Technical_Use_Case__c;
            if(interlock.Non_Adopted__c!=null)
                wrapper.NonAdopted=interlock.Non_Adopted__c;
            if(interlock.Interested_products__c!=null)
                wrapper.Interested_products=interlock.Interested_products__c;
            if(interlock.Adoption_Challenges__c!=null)
                wrapper.Adoption_Challenges=interlock.Adoption_Challenges__c;
            if(interlock.CSM_Summary__c!=null)
                wrapper.CSMSummary=interlock.CSM_Summary__c;
            if(interlock.Additional_Information__c!=null)
                wrapper.AdditionalInformation=interlock.Additional_Information__c;
            if(interlock.Renewal_Date_formula__c!=null)
                wrapper.RenewalDateformula=String.valueOf(interlock.Renewal_Date_formula__c);
            if(interlock.Partner_name_if_any__c!=null)
                wrapper.Partnernameifany=interlock.Partner_name_if_any__c;
            if(interlock.Key_customer_contact__c!=null)
                wrapper.Keycustomercontact=interlock.Key_customer_contact__c;
            if(interlock.Primary_challenge_s__c!=null)
                wrapper.Primarychallenges=interlock.Primary_challenge_s__c;
            if(interlock.IPS_Project_Manager_Email__c!=null)
                wrapper.IPSProjectManagerEmail=interlock.IPS_Project_Manager_Email__c;
            if(interlock.Adopted_Products__c!=null)
                wrapper.AdoptedProducts=interlock.Adopted_Products__c;
             if(interlock.Plan_Owner_Email_Address__c!= null)
                wrapper.PlanOwnerEmail = interlock.Plan_Owner_Email_Address__c;
            //public String CreatedByName=;        
            
            System.debug('wrapper-->'+JSON.serialize(wrapper));
            
        }
        return wrapper;
        
    }      
    
    /**
* @description To retrieve Email Template
* @author Venky | 09-20-2020 
* @param emailids 
* @return List<Wrapperobj> 
**/
    
    @AuraEnabled  
    public static EmailTemplate fetchTemplate(String interlocktype,String interlockId) { 
        System.debug('fetchTemplate entry --INTERLOCK TYPE-->'+interlocktype);
        System.debug('fetchTemplate entry --interlockId-->'+interlockId);
        String recType='';
        EmailTemplate et =new EmailTemplate();
        if(interlockId!=null && interlockId!='undefined' &&  interlockId!='')
        {
            Related_Opportunity_Plan__c interlock = [Select Id,RecordType.Name,Interlock_Type__c,Account__c,Account__r.Name,Solution_Type__c,Project_Name__c,IPS_Project__c,IPS_Package__c,Products__c,Expected_Start_Date__c,First_Value__c,Implementation_Owner__c,Support_Level__c,Success_Pack__c,Original_Opportunity__c,Original_Opportunity__r.Name,Original_Opportunity_Number__c,Contract_StartDate__c,Contract_EndDate__c,Opportunity_ARR__c,Comments__c,Thread_Id__c,Account_Region_formula__c,IPS_Project_Manager_Email__c,CreatedBy.Name FROM Related_Opportunity_Plan__c where id = :interlockid];
            System.debug('interlock-->'+interlock);
            if(interlock!=null && interlock.RecordType.Name!=null)
            {
                recType=interlock.RecordType.Name;
            }
            System.debug('recType-->'+recType);
        }
        if(recType!='')
        {
            System.debug('recType!=nnull');
            if(recType=='Renewal(SMG)')
            {
                System.debug('recType=Renewal (SMG)');
                et= [Select id,Subject,Body,HtmlValue,DeveloperName from EmailTemplate where  DeveloperName = 'SMG_HandOff_New' LIMIT 1];
                
            }else if(recType=='Professional Services')
            {
                System.debug('recType=Professional Services');
                if(interlocktype == 'JumpStart' || interlocktype == 'Checkup')
                    et= [Select id,Subject,Body,HtmlValue,DeveloperName from EmailTemplate where  DeveloperName = 'Adoption_Services_Engagement_Request_AS' LIMIT 1];
                else if(interlocktype == 'Renewal Rescue')
                    et= [Select id,Subject,Body,HtmlValue,DeveloperName from EmailTemplate where  DeveloperName = 'Renewal_Rescue_Information_AS' LIMIT 1]; 
                else 
                    et= null;
            }
        }
        System.debug('et-->'+et);
        return et;  
        
    }     
    
    /**
* @description Send Email
* @author Aishwarya Badri | 10-01-2020 
* @param interlock ID 
* @return void 
**/
    @AuraEnabled
    public static String notifyViaEmail(String interlockId)
    {
        System.debug('sendEmail Entry-->'+interlockId);
        String response=null;
        
        if(interlockId!=null && interlockId!='' && interlockId!='undefined')
        {
            //Related_Opportunity_Plan__c interlock = [Select Id,RecordType.Name,RecordTypeId,Interlock_Type__c,Opportunity_Owner_Email__c,IPS_Project_Manager_Email__c,CreatedBy.Name FROM Related_Opportunity_Plan__c where id = :interlockId];
            Related_Opportunity_Plan__c interlock =new Related_Opportunity_Plan__c(Id=interlockId);
            if(interlock!=null)
            {
                try {
                    interlock.Send_Email_Alert__c=true;
                    
                    update interlock;
                    response='Notified successfully.';
                    System.debug('Interlock updated successfully-->'+interlock);
                } catch(DmlException dmle) {
                    System.debug('Exception-->'+dmle.getMessage());
                    response='Failed to Notify. Please contact your system Administrator';
                }catch(Exception e)
                {
                    System.debug('Exception-->'+e.getLineNumber()+'--message--'+e.getMessage());
                    response='Failed to Notify. Please contact your system Administrator';
                }
            }
        }
        return response;
    }
    
    
    /**
* @description Chatterpost creation
* @author Aishwarya Badri | 09-25-2020 
* @param emailids 
* @return void 
**/
    
    @InvocableMethod(label='Chatter Post Creation'
                     description='Chatter Post Creation')
    public static void invokableSMGHandoffPostonEM(List<ID> ids) {
        System.debug('invokableSMGHandoffPostonEM--Entry');
        System.debug('ids-->'+ids);
        // Id emId=ids[0];
        globalApexManager GAM = new globalApexManager();
        String Objectname='';
        try{
            System.debug('Email id 284-->'+ids);
            if(ids!=null && ids.size()>0)
            {
                EmailMessage emailMsg = [select id,Interlock__c,Incoming,FromAddress,Subject
                                         from EmailMessage  
                                         where Id = :ids[0]];
                System.debug('emailMsg==>'+emailMsg);
                if(emailMsg!=null && !emailMsg.Incoming &&
                   !String.isBlank(emailMsg.Subject)
                   && !(emailMsg.Subject.startsWith('RE:')
                        || emailMsg.Subject.startsWith('FW:')
                       )
                  ){
                      System.debug('Inside if 243==>');
                      String response = A2R_Controller.invokeNotification( emailMsg.Interlock__c);
                      System.debug('response-->'+response);
                  } 
            }
            
        }
        catch(Exception Ex){
            System.debug(LoggingLevel.ERROR, Ex.getMessage());
            GAM.CreateExceptionRecords('OutlookEmailController ', 'Exception in invokableSMGHandoffPostonEM',ex.getMessage());
        }
        return;
        
    }   
    
    
    /**
* @description validate interock
* @param Interlock Id 
* @return Boolean 
**/
    
    
    @AuraEnabled
    public static String validateInterlock(String interlockId)
    {
        system.debug('***validateInterlock entered'+ interlockId);
        String errMessage;
        List<Related_Opportunity_Plan__c> interlocks= new List<Related_Opportunity_Plan__c>([ SELECT Id,Do_We_have_renewal_commitment__c,
                                                                                             CSM_Summary__c, RecordtypeId, RecordType.developername FROM Related_Opportunity_Plan__c where Id = :interlockId]);
        system.debug('String.isBlank(interlocks[0].CSM_Summary__c)'+String.isBlank(interlocks[0].CSM_Summary__c));
        if(interlocks!=null && interlocks.size()>0 &&
           interlocks[0].RecordTypeId !=null && interlocks[0].RecordType.developername.equals('Renewal')){
               string fields;
               if(String.isBlank(interlocks[0].CSM_Summary__c))
                   fields ='CSM Summary';
               if(String.isBlank(interlocks[0].Do_We_have_renewal_commitment__c))
                   fields = fields !=null ? fields+',Renewal Commitment':'Renewal Commitment';
               if(!String.isBlank(fields))  
                   errMessage= 'Please fill in '+fields+ ' before Notify.';
           }
        system.debug('***errMessage'+errMessage);
        return errMessage;  
    }
    
    /**
* @description query renewal optty close date
* @author Aishwarya Badri | 10-07-2020 
* @param Interlock Id 
* @return Boolean 
**/
    
    @AuraEnabled
    public static Boolean getRenewalOpptycloseDate(String interlockId)
    {
        boolean bl=false;
        
        System.debug('getRecordTypeOfInterlock Entry');
        List<Related_Opportunity_Plan__c> interlocks= new List<Related_Opportunity_Plan__c>([ SELECT Id, RecordtypeId, RecordType.name,Opportunity__c,Opportunity__r.CloseDate FROM Related_Opportunity_Plan__c where Id = :interlockId]);
        
        if(interlocks!=null && interlocks.size()>0)
        {
            if(interlocks[0].RecordType.name!=null && interlocks[0].RecordType.name.contains('SMG'))
            {
                if(interlocks[0].Opportunity__r.CloseDate!=null)
                {
                    Integer daysBetween =System.today().daysBetween(interlocks[0].Opportunity__r.CloseDate);
                    System.debug('daysBetween-->'+daysBetween);
                    if(daysBetween>=0 && daysBetween<=130)
                    {
                        System.debug('show banner');
                        bl=true;
                    }
                }  
            }
        }
        return bl;  
    }
    
    
    
    public class Wrapperobj{
        @AuraEnabled public  User u;
        @AuraEnabled public EmailMessage em;
    }
    
    
    
    public class EmailWrapper
    {
        public String Name;
        public String Email;
        public String Type;
        public void EmailWrapper(){}
    }
    
    
    public class InterlockWrapper
    {
        @AuraEnabled public String Id;
        @AuraEnabled public String InterlockType;
        @AuraEnabled public String AccountId;
        //public String Account__r.Name;
        @AuraEnabled public String AccountName;
        @AuraEnabled  public String AccountRegion;
        @AuraEnabled public String  OpportunityNumber;
        @AuraEnabled public String  Products;
        @AuraEnabled  public String SolutionType;
        @AuraEnabled  public String ExpectedStartDate;
        @AuraEnabled  public String FirstValue;
        @AuraEnabled  public String ImplementationOwner;
        @AuraEnabled  public String SupportLevel;
        @AuraEnabled   public String SuccessPack;
        @AuraEnabled  public String OriginalOpportunity;
        @AuraEnabled  public String OriginalOpportunityName;
        @AuraEnabled public String OriginalOpportunityNumber;
        @AuraEnabled public String ContractStartDate;
        @AuraEnabled  public String ContractEndDate;
        @AuraEnabled public String OpportunityARR;
        @AuraEnabled  public String Comments;
        @AuraEnabled public String ThreadId;
        @AuraEnabled  public String OwnerFirstName;
        @AuraEnabled public String OwnerLastName;
        @AuraEnabled public String ProjectName;
        @AuraEnabled public String IPSProject;
        @AuraEnabled public String IPSPackage;
        @AuraEnabled public String Opportunity;
        @AuraEnabled public String OpportunityOwnerEmail;
        @AuraEnabled public String OldOrgOpportunityNumber;
        @AuraEnabled  public String  LevelofRisk;
        @AuraEnabled  public String RenewalLikelihood;
        @AuraEnabled  public String DoWehaverenewalcommitment;
        @AuraEnabled  public String IsFirstYearRenewal;
        @AuraEnabled  public String LastContactDate;
        @AuraEnabled public String Contact;
        @AuraEnabled public String ContactName;
        @AuraEnabled public String HighestRoleEngagedWith;
        @AuraEnabled public String BusinessUseCase; 
        @AuraEnabled public String TechnicalUseCase;
        @AuraEnabled public String NonAdopted;
        @AuraEnabled  public String Interested_products;
        @AuraEnabled public String Adoption_Challenges;
        @AuraEnabled public String CSMSummary;
        @AuraEnabled  public String AdditionalInformation;
        @AuraEnabled  public String RenewalDateformula;
        @AuraEnabled  public String  Partnernameifany;
        
        @AuraEnabled public String  Keycustomercontact;
        @AuraEnabled  public String  Primarychallenges;
        
        @AuraEnabled public String AdoptedProducts;
        @AuraEnabled public String CreatedByName;
        @AuraEnabled  public String IPSProjectManagerEmail;
        @AuraEnabled public String PlanOwnerEmail;
        public void InterlockWrapper(){}
        
    }
    
}