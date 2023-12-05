public class PartnerCertificateController {

    @AuraEnabled
    public static Boolean CurrentUser(){
        boolean isAdminUser = false;
        String PSIds = Label.PartnerSetIds;
        List<String> PSId = PSIds.split(';');
        
        List<PermissionSetAssignment> listPSA = new List<PermissionSetAssignment> ();
        listPSA= [SELECT AssigneeId,Id,PermissionSetGroupId,PermissionSetId FROM PermissionSetAssignment where AssigneeId =: UserInfo.getUserId() AND PermissionSetId =: PSId ];
        
        if(listPSA.size()>0){
            System.debug('TRUE'+listPSA.size());
            isAdminUser = TRUE;
        }
        else{
            System.debug('FALSE'+listPSA.size());
            isAdminUser = FALSE;
        }
        return isAdminUser;
    }
}