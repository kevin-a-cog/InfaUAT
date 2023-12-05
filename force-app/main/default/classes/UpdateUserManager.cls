/*Class:          UpdateUserManager with @InvokableMethod is Used in Process Builder User_Update
        
        @Created Date: Apr-20-2017
        @Description:   To Update ManagerId field on User Object.
        
        Updated By       :- Ramya 
        Updated On       :- Apr-21-2017
        Purpose          :- SALESRT:54 Modification of Flow for Bulk User Updates
        
 Change History
        ******************************************************************
            ModifiedBy          Date        Requested By        Description                 
            Ramya D         26/05/2017      SALESRT-79          Remove system.debug and Include Error handling Framework 
                                                                <SALESRT-61:Error Handling FrameWork>
                                                                  
        ******************************************************************    */
           
        

public class UpdateUserManager{
 
@InvocableMethod
 
public static void UpdateUserManager(List<User> Userslist)
{
    
Set<Id> userIds = new Set<Id> ();
set<string>ManagerEmpNo = New set<string>();

//Loop-UsersList from Process Builder :User_Update
for(User userId : Userslist ){

  userIds.add(userId.Id);
  ManagerEmpNo.add(userId.ManagerEmployeeNumber__c);
  
 }
 
    map<String,User> map_manager = new Map<String, user> ();
    List<User> update_Usr = new List<User>();
  
    list<Exceptions_Log__c>exceptionList = new list<Exceptions_Log__c>();
    
   //Query to get ManagerDetails
   List<user> mgruserlist = [SELECT Id,ManagerId,EmployeeNumber,ManagerEmployeeNumber__c  FROM User where EmployeeNumber in:ManagerEmpNo];
  
   //Loop through ManagerList and populate MangerEmployeeNumber+User
    for(User user :mgruserlist)
    {
    map_manager.put(user.EmployeeNumber,user);
    }

    for(User updateMgr : [SELECT Id,ManagerId,EmployeeNumber,ManagerEmployeeNumber__c  FROM User where Id in:userIds])
    {
    //check if map contains ManagerEmployeeNumber
     if(map_manager.keyset().contains(updateMgr.ManagerEmployeeNumber__c)){
    updateMgr.ManagerId = map_manager.get(updateMgr.ManagerEmployeeNumber__c).Id;
    update_Usr.add(updateMgr);
    }
    }
  
     //Update the user list to populate ManagerId
     Database.SaveResult[] srList = Database.update(update_Usr, false);
     
    //<SALESRT-61--Error Handling FrameWork> 
    if(!update_Usr.IsEmpty()){
    globalApexManager GAM = new globalApexManager();
    GAM.CreateLogs('UpdateUserManager_User',update_Usr,'UsersList');
    
     //Creates Exception Log records if User is enabled for Debug Logs in Global Config Custom Setting. 
     try{ 
       GAM.InsertDebugLogs();
    
       }
       //Executed in case of any failure.
       Catch(Exception e){
       
         for(User u :update_Usr){
          GAM.CreateExceptionRecords('UpdateUserManager', e.GetMessage(),u.Id);
           }
       }
       }
      
     //<!--SALESRT-61-->
    
  
 
}

}