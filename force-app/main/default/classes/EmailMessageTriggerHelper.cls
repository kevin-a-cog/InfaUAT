/*
Class:          EmailMessageTriggerHelper
@Author:        
@Created Date:  
@Description:   Helper class for Email Message Trigger
*/
public class EmailMessageTriggerHelper { 
    //I2RT-4422
    public void afterInsert(List<EmailMessage> lstEmailMessage){
        Set<Id> setEngagementId = new Set<Id>(); //I2RT-4422
        //Set<Id> setTaskIdToDelete = new Set<Id>(); //I2RT-4807

        list<string> lstEngagementIdOutgoing = new list<string>();    
        for(EmailMessage em : lstEmailMessage){
            if(em.RelatedToId != null && string.valueOf(em.RelatedToId.getsobjecttype()) == 'Engagement__c'){            
                setEngagementId.add(em.RelatedToId); //I2RT-4422
                //setTaskIdToDelete.add(em.ActivityId); //I2RT-4807
                if(em.Incoming == false){
                    lstEngagementIdOutgoing.add(em.RelatedToId);
                }
            }    
        }

        //I2RT-4422
        EngagementService.updateLastActivity(setEngagementId);

        //I2RT-4807
        //reverted the changes per request from BA
        /*if(!setTaskIdToDelete.isEmpty()){
            List<Task> lstTaskToDelete = new List<Task>();
            for(Id taskId : setTaskIdToDelete){
                Task tsk = new Task();
                tsk.Id = taskId;
                lstTaskToDelete.add(tsk);
            }
            Database.delete(lstTaskToDelete, false);
        }*/

        list<Engagement__c> lstEngagementToUpdate = new list<Engagement__c>();  
        for(Engagement__c oEng : [Select id,Status__c,Dev_Active_Engaged_Start_Time__c From Engagement__c Where Id IN :lstEngagementIdOutgoing]){
            if(oEng.Status__c == 'Active Engaged'){
                oEng.Dev_Active_Engaged_Start_Time__c = system.now();
                lstEngagementToUpdate.add(oEng);
            }
                
        }
        
        if(lstEngagementToUpdate.size() > 0){
            UPDATE lstEngagementToUpdate;
        }
    }
}