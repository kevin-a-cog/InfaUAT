/****************************************************************************************************************
Class:          EngagementInvocableNotifyCSM 
@Author:        Apyati 
@Created Date:  03/20/2020.
@Description:   AR-1096 Notify CSM queue on when Digital CSM hand off engagement is created

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date           Requested By        Description                              				Tag

*/

public class EngagementInvocableNotifyCSM {
     
    @InvocableMethod(label='Notify CSM queue On engagement' description='Notify CSM queue')
    public static void invokeAction(List<ID> ids) {
        
        globalApexManager GAM = new globalApexManager();
        try{
            
          //make chatterpost on engagement
            A2RUtils.NotifyUsers(ids);
            
            
        }catch(Exception ex){
            GAM.CreateExceptionRecords('EngagementInvocableNotifyCSM', 'Exception in Notify CSM invoke action',ex.getMessage());
        }
        GAM.InsertDebugLogs();
    }
}