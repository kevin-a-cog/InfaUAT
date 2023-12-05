/*
 * Name:   globalApexManager
 * Author: Kiran Kumar A
 * Date:   27-Nov-2012
 * Description: The main purpose of the class is used to create Checks for Recursion and future calls from batches or another future methods.
 

Change History
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.                         Description                                Tag
*********************************************************************************************************************************************
 A B H I                  AUG-06-2016      SS-7651               Case Record Type Not changing after case closure      T01
 Prasanth                 May-03-2017      SalesRT-61            Error Handling/Debugging Framework                    SalesRT-61  
 RamEsh M S               Feb-22-2020      SALESRT-11351          Allow recursion on Order Product Triggers             T02
 RamEsh M S               Jun-2-2020       SALESRT-12104         Audit Usage of SOG Admin button                        T03
 Ambica                   Feb-2-2021       I2RT phase 2          Added avoid Recusion methods with event & type as params T04
*/

public class globalApexManager {
    // Static set that is used to check the recursion
    private static set<string>  setTriggers =   new set<string>(); 
   // This static function checks the condition for recursion and returns the boolean value.  
   //Returns true to say if the trigger is not supposed to run
   //Returns false if the trigger is expected to run. 
    public static boolean   avoidRecursion(String   sTriggerName)   {
    
        Boolean bStatus = false;
        if(sTriggerName != null) //<T02>
        {
        bStatus         =   setTriggers.contains(sTriggerName)?true:false;
        setTriggers.Add(sTriggerName);
        }
        bStatus         =   bStatus || (Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null 
                                && Global_Config__c.getInstance().Mute_Triggers__c == true)?true:false;
        
        return bStatus;
    }

    //-------------------------------------------------------------------------------------------<T04>


    // This static function checks the condition for recursion for the event and type passed and returns the boolean value.  
   //Returns true to say if the trigger is not supposed to run
   //Returns false if the trigger is expected to run. 
   public static boolean   avoidRecursion(String   sTriggerName, String BeforeAfter, String Eventname)   {
    
    String recursioncheck = sTriggerName+BeforeAfter+Eventname;
    Boolean bStatus = false;
    if(recursioncheck != null) 
    {
    bStatus         =   setTriggers.contains(recursioncheck.toLowerCase())?true:false;
    setTriggers.Add(recursioncheck.toLowerCase());
    }
    bStatus         =   bStatus || (Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null 
                            && Global_Config__c.getInstance().Mute_Triggers__c == true)?true:false;
    
    return bStatus;
}



    // Method to control execution of classes and triggers more than Once for the event and type passed
    public static void allowRun(String   sTriggerName,String BeforeAfter, String Eventname){

        String recursioncheck = sTriggerName+BeforeAfter+Eventname;

        if(setTriggers.contains(recursioncheck.toLowerCase()))
              setTriggers.remove(recursioncheck.toLowerCase());
      }
    //-------------------------------------------------------------------------------------------</T04>


    //-------------------------------------------------------------------------------------------<T01>
    // Method to control execution of classes and triggers more than Once
    public static void allowRun(String   sTriggerName){
      if(setTriggers.contains(sTriggerName))
            setTriggers.remove(sTriggerName);
    }
    //-------------------------------------------------------------------------------------------</T01>
    // This static function checks if the call is from batch or future method or a scheduled class and return the boolean value
    public static boolean checkRunFuture() { 
        return (System.isFuture() || system.IsBatch() || System.IsScheduled());
    }
    
  
  
  //<SalesRT-61>---------------------------------------------------------------------------------------------------------
      
       // Public static list of Exceptions_log__c to insert records
       Public Static List<Exceptions_log__c> lstExpLog= new List<Exceptions_log__c>();       
       
       
        // This static function checks if the Debug log switch is active on the global config custom settings.
        Public Static Boolean checkDebugLogSwitch(){
             Boolean bSwitch =  Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Enable_Debug_Logs__c != null 
                                 && Global_Config__c.getInstance().Enable_Debug_Logs__c == True? True: False;
             return bSwitch; 
        }   
        
     
        //Method Name :    CreateLogs 
        //Parameters  :    List of SObject, Called from Which Class, Variable name for System.Debug
        
        // The void method which takes the parameters like details of Source class, list of records to be tracked.
        // THe method creates a record of Exceptions_log__c record with the stack trace filled with the data.
            Public Void CreateLogs(String CausedFrom, List<SoBJECT> lstStackTrace, String VariableName){
                try{
                    String StackTrace ='';
                    // Append the list of Sobject to StackTrace
                    if(lstStackTrace != null && lstStackTrace.size()>0){
                        for(integer i=0; i< lstStackTrace.size(); i++){
                            StackTrace += lstStackTrace[i] + '\n';
                        }
                    }
                    
                    // Create excpetion log record
                     Exceptions_Log__c ls = new Exceptions_Log__c();
                        ls.Stack_Trace__c   = StackTrace != null ? StackTrace : '';
                        ls.Caused_From__c   = CausedFrom != null ? CausedFrom : '';
                        ls.Exception_Debug__c = 'Debug';
                     // Add the exception log record to the public static list
                     lstExpLog.add(ls);
                     
                     //Add the system.debug log for the variable passed.
                     if(lstStackTrace != null){
                         system.debug('\''+VariableName+'\'' +  lstStackTrace);
                     }
                }
                Catch(Exception e){ }
            }
       
        
        //Method Name :    CreateLogs 
        //Parameters  :    SObject, Called from Which Class, Variable name for System.Debug
       
        // The void method which takes the parameters like details of Source class, Sobject of record to be tracked.
        // THe method creates a record of Exceptions_log__c record with the stack trace filled with the data. 
            Public Void CreateLogs(String CausedFrom, SoBJECT Object1, String VariableName){
                try{
                    String StackTrace ='';
                    // Append the Variable name and the sObject
                    StackTrace = VariableName + ':' + '\n';
                    StackTrace += Object1;
                    
                    //Create Exception Log record.
                    Exceptions_Log__c ls = new Exceptions_Log__c();
                        ls.Stack_Trace__c   = StackTrace != null ? StackTrace : '';
                        ls.Caused_From__c   = CausedFrom != null ? CausedFrom : '';
                        ls.Exception_Debug__c = 'Debug';
                     lstExpLog.add(ls);
    
                      //Add the system.debug log for the variable passed.
                     if(Object1 != null){
                         system.debug('\''+VariableName+'\'' +  Object1 );
                     }
                }
                Catch (Exception e){ }
            }
        
        //Method Name :    CreateLogs 
        //Parameters  :    Field Details, Called from Which Class, Variable name for System.Debug
       
        // The void method which takes the parameters like details of Source class, Details of a particular field of record to be tracked.
        // THe method creates a record of Exceptions_log__c record with the stack trace filled with the data. 
            Public Void CreateLogs(String CausedFrom, String RecordId, String APIName, String Value){
                try{
                    String StackTrace ='';
                    // Append the Field Lable and the Field Value
                    StackTrace = RecordId + ':' + APINAME + ':' + Value;
                    
                    //Create Exception Log record
                    Exceptions_Log__c ls = new Exceptions_Log__c();
                        ls.Stack_Trace__c   = StackTrace != null ? StackTrace : '';
                        ls.Caused_From__c   = CausedFrom != null ? CausedFrom : '';
                        ls.Exception_Debug__c = 'Debug';
                     lstExpLog.add(ls);
                     
                     //Add the system.debug log for the variable passed.
                     if(ls.Stack_Trace__c != null){
                         system.debug(ls.Stack_Trace__c);
                     }    
                }
                Catch (Exception e){ }
            }
        
        //Method Name :    CreateLogs 
        //Parameters  :    Generic statements, Called from Which Class
       
        // The void method which takes the parameters like details of Source class, Generic statements that need to be called. 
        // THe method creates a record of Exceptions_log__c record with the stack trace filled with the data. 
       
            Public Void CreateLogs(String CausedFrom, String staticValue){
                try{
                    String StackTrace ='';
                    StackTrace = staticValue;
                    
                    //Create Exception Log record
                    Exceptions_Log__c ls = new Exceptions_Log__c();
                        ls.Stack_Trace__c   = StackTrace != null ? StackTrace : '';
                        ls.Caused_From__c   = CausedFrom != null ? CausedFrom : '';
                        ls.Exception_Debug__c = 'Debug';
                     lstExpLog.add(ls);
                     
                     //Add the system.debug log for the variable passed.
                     if(staticValue != null){
                         system.debug(staticValue);
                     }
                }
                Catch (Exception e){ }
            }
                        
        //Method to Insert the list of Debug log records. This method will be called at the end, after all the CreateLogs methods are called.
            Public Void InsertDebugLogs(){
                try{
                    If(globalApexManager.checkDebugLogSwitch()){
                        If(lstExpLog != null && lstExpLog.size()>0){
                            Database.Insert(lstExpLog, false);
                        }
                    }    
                }catch(Exception e){ }
            }  
        
        // Void method called from trigger/class which will create a record in Exception log record. It accepts the parameters 
        // of CausedFrom class/trigger, Eror message from Catch, Record id
            Public Void CreateExceptionRecords(String CausedFrom, String ErrorMessage, String RecordId){
                try{
                Exceptions_Log__c ls = new Exceptions_Log__c();
                        ls.System_Message__c     = ErrorMessage != null ? ErrorMessage : '';
                        ls.Caused_From__c        = CausedFrom != null ? CausedFrom : '';
                        ls.Record_Id__c          = RecordId != null ? RecordId : '';
                        ls.Exception_Debug__c    = 'Exception';
                Database.Insert(ls, False);
                }Catch(Exception e){}
            }
        
        // Method that is called from class/trigger that will be used to send customized error messages instead of system messages.
        // The customized messages are derived from Exception log matrix that needs to be created with Custom message and the module name
            Public String DisplayErrorMessage(String ObjectName){
                try{
                    Map<String,Exception_Log_Matrix__c> ELM = Exception_Log_Matrix__c.getall();
                    String strMessage = ELM.get(ObjectName) != null ?ELM.get(ObjectName).Error_Message__c: '';
                    
                    return strMessage;
                }Catch(Exception e){return null;}
            }
 
//---------------------------------------------------------------------------------------------------------------</SalesRT-61> 
 public void CreateAudit(String JobName,String CausedFrom,String RecordId,String CustomMessage,String Type) //<T03>
 {
     Exceptions_Log__c ls = new Exceptions_Log__c();
     ls.Job_Name__c = JobName;
     ls.Caused_From__c = CausedFrom;
     ls.Record_Id__c = RecordId;
     ls.Custom_Message__c = CustomMessage;
     ls.Type__c = Type;
     Database.Insert(ls, False);
 }//</T03>
        
}