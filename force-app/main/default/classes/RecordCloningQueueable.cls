/*
Class:          RecordCloneWithChildController 
@Author:        Saurabh Khandelwal 
@Description:   Queueable class to clone the records of given Sobjectype by chaining of jobs for
                each sObjectType.
@TestClass :    RecordCloneWithChildControllerTest

    Change History
*************************************************************************************************************************************
    ModifiedBy                  Date            Requested By        Description                                         Tag
 Saurabh  Khandelwal			25-May-2022                         Made the class queueable to clone the record     SALESRT-13277
                                                                    of related child objects                                                                           
*************************************************************************************************************************************
*/


public class RecordCloningQueueable implements Queueable
{
    
    public static globalApexManager GAM = new globalApexManager();
    public Map<Schema.SObjectType, Schema.sObjectField[]> childRelationships;
    private Static final String NOTIFICATION_TITLE = Label.QuoteCloneNotificationTitle;
    private Static final String NOTIFICATION_BODY = Label.QuoteCloneNotificationBody;
    private Static final String NOTIFICATION_NAME = 'Notification_Service_Desktop';
    public List<Schema.SObjectType>childSobjectsList;
    public Integer childObjCountIndex;
    public String oldRecordId;
    public String newRecordId;
    public RecordCloningQueueable(){
        
    }
    public RecordCloningQueueable(Map<Schema.SObjectType, Schema.sObjectField[]> childRelationships,Integer childObjCountIndex,String oldRecordId ,String newRecordId,List<Schema.SObjectType>childSobjectsList){
                                     
        this.childRelationships=childRelationships;
        this.childObjCountIndex=childObjCountIndex;
        this.oldRecordId=oldRecordId;
        this.newRecordId=newRecordId;
        this.childSobjectsList=childSobjectsList;
                                     
    }
    
    public void execute(QueueableContext context) {
        // Your processing logic here 
        try{
            Schema.SObjectType childSobj=childSobjectsList[childObjCountIndex];
            Schema.DescribeSObjectResult objTypeDescribe=childSobj.getDescribe();
            
            String[] pFieldNames = new String[]{};
                
            //Get a List of Fields related to Parent Object
            for (Schema.SObjectField pFld : childRelationships.get(childSobj)){
                Schema.DescribeFieldResult dfr = pFld.getDescribe();
                //ignore Unique fields. They will have to be filled in manually
                    if (!dfr.isUnique() && (dfr.isCreateable() || dfr.isUpdateable()) ) {
                        pFieldNames.add(dfr.getName());
                    }
            }
        
            //build the where clause - Just in case there are multiple fields related to the same SObjectType
            String pFieldWhere = '';
            for (String pFld : pFieldNames) {
                if (pFieldWhere != ''){
                    pFieldWhere += ' OR ';
                }
                pFieldWhere += pFld + ' IN : rIds';
            }
            //Query for values - using rIds in the Where clause as the method uses that variable name for pIds here
            Map<ID, sObject> childRecords = New Map<ID, SObject>(RecordCloneWithChildController.queryForRecords(childSobj, new Set<Id>{oldRecordId}, pFieldWhere)); 
            if (!childRecords.isEmpty()) {
                
                List<sObject>newChildren = cloneObjects(childRecords.values());
                for(sObject newChild : newChildren){
                    for (String pField : pFieldNames) {
                        newChild.put(pField, newRecordId); 
                    }
                }
                Database.SaveResult[] srList = Database.insert(newChildren, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                          // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            GAM.CreateLogs('Cloning process of '+ childSobj+' object record failed in RecordCloningQueueable process.',err.getMessage());
                        }
                    }
                }
                GAM.InsertDebugLogs();
            }
            //scheduling another job to clone other child obj record
            if((childObjCountIndex+1)<childSobjectsList.size()){
                System.enqueueJob(new RecordCloningQueueable(childRelationships,childObjCountIndex+1,oldRecordId,newRecordId,childSobjectsList));
            }
            else{
                //sending notification when cloninng is completed
                sendNotification();

            }
        }
        catch(Exception ex){
            //scheduling another job to clone other child obj record.
            if((childObjCountIndex+1)<childSobjectsList.size()){
                System.enqueueJob(new RecordCloningQueueable(childRelationships,childObjCountIndex+1,oldRecordId,newRecordId,childSobjectsList));
            }
        }
    }

    /*Method to send notification to user. 
    */ 
    private void sendNotification(){

        Id loggedInUserId=Userinfo.getUserId();
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(NOTIFICATION_TITLE);
        notification.setBody(NOTIFICATION_BODY);
        notification.setSenderId(loggedInUserId);
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = : NOTIFICATION_NAME];
        notification.setNotificationTypeId(type.id);
        notification.setTargetId(newRecordId); // target object id
        notification.send(new Set<String> { loggedInUserId });

    }
    
    /*Method to get list of cloned sObjects. 
    * @param oObjs - contains list of sObjects that needs to be cloned
    */ 
    private List<sObject> cloneObjects(sObject[] oObjs) {

    	List<sObject>clonedSobjs=new List<sObject>();
        //For each record for this sObjectType
        for (sObject oldObj : oObjs) { 
            //Create a new Object
            sObject newObj = oldObj.clone(false, true);
			clonedSobjs.add(newObj);
        }
        return clonedSobjs;
    }

}