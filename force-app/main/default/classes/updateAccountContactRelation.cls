public class updateAccountContactRelation{

    @InvocableMethod     
    public static void setContactUpdatedOnACR(List<Id> conIds){

        //globalApexManager GAM = new globalApexManager();
        Map<Id,AccountContactRelation> mapConACR = new Map<Id,AccountContactRelation>();
        List<AccountContactRelation> lstUpdateACR = new List<AccountContactRelation>();
        set<id> setACRUpdated = new set<Id>();
        //Get only one ACR per contact 
        if(conIds != null && !conIds.isEmpty()){
            for(AccountContactRelation acr : [Select Id,Contact_Updated__c,ContactId from AccountContactRelation where ContactId IN :conIds AND IsDirect = FALSE]){
                mapConACR.put(acr.ContactId,acr);
            }
        }
        //Update the ACR Contact Updated field with TODAY date.This will trigger the Outbound message to ICRT process
        for(AccountContactRelation updateAcr: mapConACR.values()){
            updateAcr.Contact_Updated__c = System.TODAY();
            lstUpdateACR.add(updateAcr);
        }

        if(lstUpdateACR!=null && lstUpdateACR.size()>0){
            Database.SaveResult[] srList = Database.update(lstUpdateACR);
            for (Database.SaveResult sr : srList) {
                if(sr.isSuccess()){
                    setACRUpdated.add(sr.getId());
                }else{
                    for(Database.Error err : sr.getErrors()) {          
                        //GAM.CreateExceptionRecords('UpdateAccountContactRelation-setContactUpdatedOnACR - Failed to update teh ACR when Email on Contact is updated', err.getMessage(), sr.getId());
                    }
                }
            }
        }
    }
}