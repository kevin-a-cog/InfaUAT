/*
        Class:          ActivityTriggerHandler
        @Author:        Ambica Pyati
        @Created Date:  06 June 2017
        @Description:   handles all logic on the Task and Event Triggers



    Change History
*****************************************************************************************************************************
    ModifiedBy          Date        Requested By        Description                                             Tag
    Ambica Pyati       6/15/2017      Brian             Marketo US-1312- #attempts to 
                                                        include call, emails and events    
    VENKATESH BALLA    5/20/2022      SALESRT-13807     To Include notification subscription method call.
******************************************************************************************************************************
*/

Public Class ActivityTriggerHandler{

    public static String LeadKeyprefix;//Key Prefix of lead
    public static String ContactKeyPrefix;//Key Prefix of Contact
    public static globalApexManager GAM = new globalApexManager();// To create debug logs and exception logs


    /**
    * this method is invoked from aftr insert of Tasks
    * @param lstNew - list of new Tasks
    * @return return-void
    * @throws exception - NA
    */
    Public Static void TaskAfterInsert(list<Task> LstNewTasks){
        //Call method to count call and email activities
        TaskActivtyCount(LstNewTasks);
    }
    /**
    * this method is invoked from aftr update of Tasks from TaskTrigger
    * @param newTasks - list of new Tasks
             oldMapTasks - map of old Tasks data.
    * @return return-void
    * @throws exception - NA
    */
    Public Static void taskAfterUpdate(list<Task> newTasks, Map<Id, Task> oldMapTasks){
        TaskTriggerHelper.afterUpdate(newTasks, oldMapTasks);//added for SALESRT-13807
    }
    
    
    
    /**
    * this method is invoked from aftr insert of events
    * @param lstNew - list of new events
    * @return return-void
    * @throws exception - NA
    */
    Public Static void EventAfterInsert(list<Event> LstNewEvents){
        //call method to count event activities
        EventActivtyCount(LstNewEvents);
    
    }
    
    
    
    /**
    * This method to capture te keyprefix of objects(Lead,contact)
    * @param - NA
    * @return return-void
    * @throws exception - NA
    */ 
     public static void setKeyPefix(){
        LeadKeyprefix = Lead.sobjecttype.getDescribe().getKeyPrefix();
        ContactKeyPrefix= Contact.sobjecttype.getDescribe().getKeyPrefix();    
     }
     
     
     
     
     
    /**
    * Method to calculate number of emails and call logs on lead and conatct(Marketo US-1312) 
    * @param - LstNewTasks- List of new tasks
    * @return return-void
    * @throws exception - NA
    */     
    public static void  TaskActivtyCount(List<Task> LstNewTasks) {
    
    
    
        

        Map<Id,integer>LeadCountMap= new Map<Id,integer>();
        Map<Id,integer>ContactCountMap= new Map<Id,integer>();
        
        //Call the method to set the keyprefix of lead and contact 
        setKeyPefix();
        
            for(Task T : LstNewTasks){
            
                 if(T.WhoID!=null){
            
                 //do not run for task type activity - email and call only 
                    if(T.TaskSubtype!='Task'){
                
                    String ParentIDString = T.WhoID;
                    
                   //checkif the parent is lead
                    If(ParentIDString.substring(0,3).equals(LeadKeyprefix) )   { 
                    
                        if(LeadCountMap.keyset().contains(T.whoId)){
                              LeadCountMap.put(T.whoID,LeadCountMap.get(T.whoID)+1);
                        }
                        else{
                            LeadCountMap.put(T.whoID,1);                       
                        }
                    } 
                    //checkif the parent is Contact
                    Else If((ParentIDString.substring(0,3)).equals( ContactKeyPrefix) )   {
                    
                        if(ContactCountMap.keyset().contains(T.whoId)){
                              ContactCountMap.put(T.whoID,ContactCountMap.get(T.whoID)+1);
                        }
                        else{
                               ContactCountMap.put(T.WhoID,1);
                        }
                    }
                   
                   } 
                 }
            
              }
          //Call method to update lead and contacts with activity count
          IncrementActivityCount(ContactCountMap, LeadCountMap);
            
      }  
      
      
      
      
      
      
    /**
    * Marketo US-1312- calculate number of events on lead and conatct 
    * @param - LstNewEvents - list of new events
    * @return return-void
    * @throws exception - NA
    */
     public static void  EventActivtyCount(List<Event> LstNewEvents) {
   
        Map<Id,integer>  LeadCountMap= new Map<Id,integer>();
        Map<Id,integer>  ContactCountMap= new Map<Id,integer>();
        
        //Call the method to set the keyprefix of lead and contact 
        setKeyPefix();


            for(Event E : LstNewEvents){
            
                if(E.WhoID!=null){
            
                    String ParentIDString = E.WhoID;
                    
                   //checkif the parent is lead
                    If(ParentIDString.substring(0,3).equals(LeadKeyprefix) )   {        
                        if(LeadCountMap.keyset().contains(E.whoId)){
                              LeadCountMap.put(E.whoID,LeadCountMap.get(E.whoID)+1);
                        }
                        LeadCountMap.put(E.whoID,1);
                    } 
                    //checkif the parent is Contact
                    Else If((ParentIDString.substring(0,3)).equals( ContactKeyPrefix) )   {
                    
                        if(ContactCountMap.keyset().contains(E.whoId)){
                              ContactCountMap.put(E.whoID,ContactCountMap.get(E.whoID)+1);
                        }
                       ContactCountMap.put(E.WhoID,1);
                    }
                 }   
              }
            

        //Call method to update lead and contacts with activity count
        IncrementActivityCount(ContactCountMap, LeadCountMap);
            
    }  

         
   
   
   
     /**
    * Method to increase the #attempts counter on lead/contact
    * @param  ContactCountMap-  Map of contact and actvities  
    * @param -LeadCountMap- Map of leads and actvities 
    * @return return-void
    * @throws exception - NA
    */      
         
     
    public static void   IncrementActivityCount(Map<Id,Integer> ContactCountMap,Map<Id, Integer> LeadCountMap){
    

        List<Lead> LstUpdateLead = new list<lead>(); //List of leads to be updated with new count
        List<Contact> LstUpdateContact=new list<contact>();//List of contacts to be updated with new count

                If(ContactCountMap.keyset()!=null &&ContactCountMap.keyset().size()>0){
                
                        For( Contact C : [Select id, No_of_Attempts__c from Contact where Id in : ContactCountMap.keyset()])
                        {   
                            //increase the activity count by number of activities created under contact
                       c.No_of_Attempts__c = ContactCountMap.get(c.id)!=null?(C.No_of_Attempts__c!=null?c.No_of_Attempts__c+ContactCountMap.get(c.id):ContactCountMap.get(c.id)):(C.No_of_Attempts__c!=null? C.No_of_Attempts__c: 0);

                        lstupdateContact.add(C);
                        }
                        
                        //Create debug logs
                        GAM.Createlogs('Activitytriggerhandler',lstupdateContact,'lstupdateContact');
              
                       try{
                            if(lstupdateContact!=null && lstupdateContact.size()>0){
                            
                                 //update contacts with new count
                                 database.Update(lstupdateContact);
                            }
                        }Catch(Exception ex){
                            GAM.CreateExceptionRecords( 'Activitytriggerhandler', 'exception in contactsattemptsUpdate', ex.getMessage());

                        }
                } 
                
                
                If(LeadCountMap.keyset()!=null &&LeadCountMap.keyset().size()>0){
                

                        For( Lead L : [Select id,No_of_Attempts__c from Lead where Id in : LeadCountMap.keyset()])
                        {   
                            L.No_of_Attempts__c= LeadCountMap.get(L.id)!=null ? ( L.No_of_Attempts__c!=null ? L.No_of_Attempts__c+LeadCountMap.get(L.id): LeadCountMap.get(L.id)):( L.No_of_Attempts__c!=null ? L.No_of_Attempts__c:0);

                            lstUpdateLead.add(L );
                        }
                          
                        //Create debug logs
                        GAM.Createlogs('Activitytriggerhandler',lstUpdateLead,'lstUpdateLead');

                        try{  
                            if(lstUpdateLead!=null && lstUpdateLead.size()>0){
                                 //update leads with new count              
                               database.Update(lstUpdateLead);
                               
                            }
                        }Catch(Exception ex){
                            GAM.CreateExceptionRecords( 'Activitytriggerhandler', 'exception in leadattemptsUpdate', ex.getMessage());
                        }
                }
               
                 
            //Insert debug Logs
            GAM.Insertdebuglogs();
               
    }
                 
    /*
	 Method Name : afterInsert
	 Description : This method gets executed on After Insert.
	 Parameters	 : List, called from afterInsert, lstNewRecords New records.
	 Return Type : None
	 */
	public static void afterInsert(List<Event> lstNewRecords) {

		//We send the new events to be analyzed by the Zoom Utility Class.
		GlobalZoomUtilitiesClass.generateMeetingAndSendInvites(lstNewRecords);
	}
                 
    /*
	 Method Name : afterUpdate
	 Description : This method gets executed on After Update.
	 Parameters	 : List, called from afterUpdate, lstNewRecords New records.
	 			   Map, called from afterUpdate, mapOldRecords Old records.
	 Return Type : None
	 */
	public static void afterUpdate(List<Event> lstNewRecords, Map<Id, Event> mapOldRecords) {

		//We send the new events to be analyzed by the Zoom Utility Class.
		GlobalZoomUtilitiesClass.generateMeetingAndSendInvites(lstNewRecords, mapOldRecords);
	}
}