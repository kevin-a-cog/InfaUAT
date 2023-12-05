/*
    @created by       : balajip
    @created on       : 
    @Purpose          : 
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         07/11/2022  I2RT-6637   T01     Added option to be able to specify a list of 
                                                    Notification Subscription record Ids to be processed 

*/

public without sharing class NotificationServiceQueue implements Queueable {
    private List<SObject> newList;
    private Map<Id, SObject> oldMap; 
    private List<Id> lstCriteriaId; //T01
    private Integer index;

    public NotificationServiceQueue(List<SObject> newList, Map<Id, SObject> oldMap) {
        init(newList, oldMap, null, 0); 
    }

    //T01
    public NotificationServiceQueue(List<SObject> newList, Map<Id, SObject> oldMap, List<Id> lstCriteriaId) {
        init(newList, oldMap, lstCriteriaId, 0); 
    }

    public NotificationServiceQueue(List<SObject> newList, Map<Id, SObject> oldMap, List<Id> lstCriteriaId, Integer index) { //T01
        init(newList, oldMap, lstCriteriaId, index); 
    }

    private void init(List<SObject> newList, Map<Id, SObject> oldMap, List<Id> lstCriteriaId, Integer index){ //T01
        this.newList = newList;
        this.oldMap = oldMap;
        this.lstCriteriaId = lstCriteriaId;
        this.index = index; //T01
    }

    public void execute(QueueableContext context) {
        if(index < newList.size()){
            SObject obj = newList.get(index);
            SObject objOld;
            if(oldMap != null){
                objOld = oldMap.get(obj.Id);
            }
            NotificationService.notify(obj, objOld, lstCriteriaId); //T01
    
            if(index < newList.size() - 1){
                NotificationServiceQueue serviceQueue = new NotificationServiceQueue(newList, oldMap, lstCriteriaId, ++index);
                if(!Test.isRunningTest()){
                Id jobId = System.enqueueJob(serviceQueue);        
                }
                
            }
        }
    }
}