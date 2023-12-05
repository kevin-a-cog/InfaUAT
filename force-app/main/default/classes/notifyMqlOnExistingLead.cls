/*
Class:          notifyMqlOnExistingLead
@Author:        Chandana Gowda
@Created Date:  09-Oct-2019
@Description:   Class to notify BDM/CFR of New MQL on Existing Lead

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Jira No         Description                                                                             Tag
**********************************************************************************************************************************************************
Chandana Gowda      17-May-22   SALESRT-13870   Addition of a new Territory User Role 'SDR' to help route One B trials                  <T01>  
*************************************************************************************************************************************************************
*/
public with sharing class notifyMqlOnExistingLead {

    //public static notifyMqlOnNewLead postObj = new notifyMqlOnNewLead();
    public final static string UNASSIGNED_USER = Label.Unassigned_User_Id;
    public final static string PARTNER_USER = Label.Partner_User_Id;

    @InvocableMethod(label='Notify BDM/CFR of Mql on existing Lead' description='Notifying BDM and/or CFR of new MQL on Existing Lead')
    public static void notifyOnMql(List<Id> objIds){
        
        notifyMqlOnNewLead.init(objIds);
        Map<Id,String> mapObjIdtoMsg=new Map<Id,String>();

        for(sObject obj:notifyMqlOnNewLead.lstObj){
            String mentions='';
            String postContent=notifyMqlOnNewLead.getpostContent(obj);
            if(!mentions.contains(notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjBDM.get((Id)obj.Id))) && notifyMqlOnNewLead.mapObjBDM.get((Id)obj.Id)!=null){
                mentions+= notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjBDM.get((Id)obj.Id));
            }
            if(!mentions.contains(notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjCFR.get((Id)obj.Id))) && notifyMqlOnNewLead.mapObjCFR.get((Id)obj.Id)!=null){
                mentions+= notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjCFR.get((Id)obj.Id));
            }
            //------------------------------------------------------------------------------------------------------<T01>                                
            if(!mentions.contains(notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjSDR.get((Id)obj.Id))) && notifyMqlOnNewLead.mapObjSDR.get((Id)obj.Id)!=null){
                mentions+= notifyMqlOnNewLead.returnMentionFormat(notifyMqlOnNewLead.mapObjSDR.get((Id)obj.Id));
            }
            //------------------------------------------------------------------------------------------------------<T01/> 
            if(!mentions.contains(notifyMqlOnNewLead.returnMentionFormat((ID)obj.get('OwnerId'))) && (ID)obj.get('OwnerId')!=null && obj.get('OwnerId')!=UNASSIGNED_USER && obj.get('OwnerId')!=PARTNER_USER){
                mentions+= notifyMqlOnNewLead.returnMentionFormat((ID)obj.get('OwnerId'));
            }
            if(mentions!=null && !String.ISBLANK(mentions)){
                mapObjIdtoMsg.put(obj.Id,notifyMqlOnNewLead.getChatterFeedItem(postContent,mentions));
            }
        }

        List<ConnectApi.BatchInput> batchInputs = notifyMqlOnNewLead.getChatterFeed(mapObjIdtoMsg);

        if(!Test.isRunningTest() && batchInputs!=null && batchInputs.size()>0){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    } 
}