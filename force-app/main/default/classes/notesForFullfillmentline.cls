/****************************************************************************************************************
Class:          notesForFullfillmentline
@Author:        chandana gowda
@Created Date:  9/4/2019.
@Description:   Class for consolidating the PDS of all the products associated with the fullfillment Line
******************************************************************************************************************
Change History 
*******************************************************************************************************************/
public with sharing class notesForFullfillmentline {
    @InvocableMethod(label='Create PDS' description='Creates PDS on fulfillmentLine creation') 
    public static void createPDS(List<Id> relatedfflineIdList){
        System.enqueueJob(new notesForFullfillmentlineQueueable(relatedfflineIdList));
    }
}