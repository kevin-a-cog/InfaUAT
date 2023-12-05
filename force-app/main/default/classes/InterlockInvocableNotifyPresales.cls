/****************************************************************************************************************
Class:          InterlockInvocableNotifyPresales 
@Author:        Apyati 
@Created Date:  07/11/2019.
@Description:   AR-927 Notify Presales and change Interlock owner to unassigned

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date           Requested By        Description                              				Tag
Ambica            10/9/2019        mpatil          AR-1000 Modified to handle method to handle all recordtypes 

*/
public class InterlockInvocableNotifyPresales {
    
    @InvocableMethod(label='Notify On Interlcok' description='Notify and change owner to unassigned')
    public static void invokeAction(List<ID> ids) {
        
        globalApexManager GAM = new globalApexManager();
        try{
            
            
            User UnassignedUser =[Select id from user where FederationIdentifier =:Label.Unassigned_User_Id];           
            Group CSTGroup =  [Select Id from Group where type='Queue' and Name=: Label.INFA_CST_Queue] ;
            
            List<Related_Opportunity_Plan__c> LstInterlocks = [Select Id,Count_Of_SMG_Notification__c,RecordtypeId,RecordType.DeveloperName,opportunity__c
                                                               FROM Related_Opportunity_Plan__c
                                                               WHERE Id = :Ids];                                                                  
            
            for ( Related_Opportunity_Plan__c recInterlock : LstInterlocks){
                
                if(recInterlock.RecordType.DeveloperName == Label.InterlockRecTypePresales){
                    recInterlock.ownerId = UnassignedUser.id ;
                }
                
                if(recInterlock.RecordType.DeveloperName == Label.InterlockRecTypeCST){
                  recInterlock.ownerId = CSTGroup.id ;
                }
                
                //Increase chatterpost count for interlocks 
                recInterlock.Count_Of_SMG_Notification__c =  recInterlock.Count_Of_SMG_Notification__c==null?1:recInterlock.Count_Of_SMG_Notification__c+1;
                
            }
            
            update LstInterlocks;
            
            //make chatterpost on interlock
            A2RUtils.NotifyUsers(ids);
            
            
        }catch(Exception ex){
            GAM.CreateExceptionRecords('InterlockInvocableNotifyPresales', 'Exception in Notify Presales invoke action',ex.getMessage());
        }
        GAM.InsertDebugLogs();
        
    }
    
}