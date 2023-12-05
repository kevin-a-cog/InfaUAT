/*
Trigger:        AssetAfterInsert
@Author:        Thejaswini Sattenapalli
@Created Date:  5 August 2017
@Description:   Trigger on Asset After Insert Operations
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
Ritika Gupta     3/29/2019      QCA-768       Prasanth         Removing recurssion logic, since for perpetual more then 200 assets get created,
                                                                we need the trigger logix to run for all assets.<T01>
Ambica Pyati    5/21/19        SALESRT-4229    Prasanth Sagar    Added Mute Check                                           <T02>
Ambica Pyati    9/5/19         AR-957          Mahesh Patil      Populate service account on Account Product from           <T03>
                                                                Asset's Service account                                                     
Anil Solanki    08/06/20        I2C-726        Anil Solanki     Commenting handleAfterInsert Method<T04>
Vignesh D        10/22/2020       F2A                           Asset Revamp commenting code                                <T05>
********************************************************************************************************************************************

*/
trigger AssetAfterInsert on Asset (after insert) {
    /*if(globalApexManager.avoidRecursion('AssetAfterInsert') ) {
        return;
    }<T01>*/

    //------------------------------------------------------------<T02>
   //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true ){
        Return;
    }
   //-------------------------------------------------------------</T02>

   // AssetTriggerHandler.handleAfterInsert(trigger.new); <T04>
    //<T05>AssetTriggerHandler.updateRelatedIntacct(trigger.new);
    //<T05>AssetTriggerHandler.UpdateServiceAccountOnAccountProduct(trigger.new,null);//<T03>

}