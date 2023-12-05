import { LightningElement , track, api, wire } from 'lwc';
import validateSelectedUsers from '@salesforce/apex/licenseManagementHandler.validateSelectedUsers';
export default class LicenseRequestReviewGrid extends LightningElement {

assignmentNeededUserIds = [];
@track permissionRequests = [];

@api userIds;
@api businessRole;

prColumns = [
    { columnName: 'prName', label: 'Name', fieldName: 'prName'}, 
    { columnName: 'prUserName', label: 'User Name', fieldName: 'prUserName'}, 
    { columnName: 'prBusinessRole', label: 'Business Role', fieldName: 'prBusinessRole'},
    { columnName: 'allLicencesExists', label: 'License already Exists?', fieldName: 'allLicencesExists'} 
    
];

connectedCallback() {
    validateSelectedUsers({selectedUsers: this.userIds,BusinessRole: this.businessRole})
                .then(result => {
                    if(result && result.length > 0){
                        let tPermissionRequests = JSON.parse(JSON.stringify(result));
                        this.preparepermissionRequests(tPermissionRequests);
                        
                        }
                })
                .catch(error => {
                    console.log('validatePermissionRequests is failed ' , error);
                });

}

preparepermissionRequests(tPermissionRequests)
{
    if(tPermissionRequests && tPermissionRequests.length > 0)
    {
        let cmp = this;
        tPermissionRequests.forEach(function(tPR, i) {
            
            if(tPR.isAllLicensesAvailable)
            {
                tPR.allLicencesExists = 'Yes';
            }
            else
            {
                cmp.assignmentNeededUserIds.push(tPR.prId);
                tPR.allLicencesExists = 'No';
            }
        });
    }

    this.permissionRequests = tPermissionRequests;

        let tAssignmentNeededUserIds = this.assignmentNeededUserIds;
     var cEvent = new CustomEvent('getassignmentuserids', { detail:        
                              {assignmentNeededUserIds : tAssignmentNeededUserIds}});
       // Dispatches the event.
       this.dispatchEvent(cEvent);
}




}