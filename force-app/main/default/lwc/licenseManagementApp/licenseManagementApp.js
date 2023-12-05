import { LightningElement , track, api, wire } from 'lwc';
import fetchLicensesAssigned from '@salesforce/apex/licenseManagementHandler.fetchLicensesAssigned';
import fetchBusinessRoles from '@salesforce/apex/licenseManagementHandler.fetchBusinessRoles';
import fetchUsersList from '@salesforce/apex/licenseManagementHandler.fetchUsersList';
import fetchAllUsersList from '@salesforce/apex/licenseManagementHandler.fetchAllUsersList';
import getFieldLableAndFieldAPI from '@salesforce/apex/licenseManagementHandler.getFieldLableAndFieldAPI';
import createUserProvisioningRemovalReq from '@salesforce/apex/licenseManagementHandler.createUserProvisioningRemovalReq';
import createUserProvisioningAddReq from '@salesforce/apex/licenseManagementHandler.createUserProvisioningAddReq';
import getRemovalLicenseReport from '@salesforce/apex/licenseManagementHandler.getRemovalLicenseReport';
import getAssignLicenseReport from '@salesforce/apex/licenseManagementHandler.getAssignLicenseReport';
import searchUsers from '@salesforce/apex/licenseManagementHandler.searchUsers';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id'; 
import UserName from '@salesforce/schema/User.Username';
import FullName from '@salesforce/schema/User.Name';
import LightningConfirm from "lightning/confirm";

const PAGE_SIZE = 10; // Number of records to display per page

export default class LicenseManagementApp extends LightningElement {
    selectedAction = '';
    
    
    isLicenseSelected = false;
    isRoleSelected = false;
    @track isLicenseAssignmentReview = false;
    @track isLicenseRemovalReview = false;

    error;
    username;
    userFullName;
    notApprover;
    userID = USER_ID;
    licenseOptions = [];
    selectedLicense ='';
    RoleOptions = [];
    selectedRole ='';
    allSelectedUserIds=[];
    pageWiseSelectedUserIds = [];//{"pageNumber":0;selectedUserids:[]};

    @track userColumns =[];
    @track userData = [];
    totalRecords = [];
    @track reviewGridBindDataType = null;
    @track removalReviewData = null;

    @track currentPage = 1;
    @track totalPages = 0;
    selectedIds=[];
    noUserList=false;

    data;
    @track userOptions;
    selectedAssignmentUserIds = [];
    allAssignmentUsers = [];
    assignmentUserIds = null;

    assignLicenseAvailability=[];
    removeLicenseAvailability=[];
    selectedRemovalUsersCount = 0;
    //prop: totalFilteredRecords
    _totalFilteredRecords = [];
    get totalFilteredRecords() {
        return this._totalFilteredRecords;
    }
    set totalFilteredRecords(value) {
       this._totalFilteredRecords = value;
       this.totalPages = Math.ceil(value.length / PAGE_SIZE);
       this.currentPage = 1;
       this.pageWiseSelectedUserIds = [];
       this.selectedUserIds = [];
       this.setGridPageData();
    }
    
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    reviewsortedBy;

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.totalFilteredRecords];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.totalFilteredRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.paginateData();
    }

    onHandleReviewSort(event) {
        const { fieldName: reviewsortedBy, sortDirection } = event.detail;
        const cloneData = [...this.removalReviewData];
        cloneData.sort(this.sortBy(reviewsortedBy, sortDirection === 'asc' ? 1 : -1));
        this.removalReviewData = cloneData;
        this.sortDirection = sortDirection;
        this.reviewsortedBy = reviewsortedBy;
    }
   

    //prop: isLicenseAssignment
    _isLicenseAssignment = false;
    get isLicenseAssignment() {
        return this._isLicenseAssignment;
    }
    set isLicenseAssignment(value) {
       this._isLicenseAssignment = value;

        this.isLicenseAssignmentSelection = value;
        this.isLicenseAssignmentReview = false;
    }

    //prop: isLicenseRemoval
    _isLicenseRemoval = false;
    get isLicenseRemoval() {
        return this._isLicenseRemoval;
    }
    set isLicenseRemoval(value) {
       this._isLicenseRemoval = value;

        this.isLicenseRemovalSelection = value;
        this.isLicenseRemovalReview = false;
    }

    get isUserSelectionVisible()
    {
        return ((this.isLicenseRemoval && this.totalRecords && this.totalRecords.length > 0 )
                || (this.isLicenseAssignment && this.allAssignmentUsers &&this.allAssignmentUsers.length > 0 ));
    }

    //prop: isLicenseAssignmentSelection
    _isLicenseAssignmentSelection = false;
    get isLicenseAssignmentSelection() {
        return this._isLicenseAssignmentSelection;
    }
    set isLicenseAssignmentSelection(value) {
       this._isLicenseAssignmentSelection = value;
      if(value)
       {
           this.prepareUserOptions(null);
       }
    }

     //prop: isLicenseRemovalSelection
    _isLicenseRemovalSelection = false;
    get isLicenseRemovalSelection() {
        return this._isLicenseRemovalSelection;
    }
    set isLicenseRemovalSelection(value) {
       this._isLicenseRemovalSelection = value;
      if(value)
       {
          this.currentPage = 1;
          this.setGridPageData();
       }
    }

    

    get isSearchVisible() {
         return (!this.isLicenseAssignmentReview && !this.isLicenseRemovalReview);
    }

     get gridTitle() {
         if(this.isLicenseAssignmentReview || this.isLicenseRemovalReview)
         {
             return 'Selected User(s)';
         }
         return 'User(s) List';
    }
  
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.setGridPageData();
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
           this.setGridPageData();
        }
    }

    setGridPageData()
    {
        this.userData = this.paginateData();
        this.setGridSelectedUsers();
    }

    get disablePrevious(){ 
        return this.currentPage<=1;
    }

    get disableNext(){ 
        return this.currentPage>=this.totalPages;
    }

    paginateData() {
        const startIndex = (this.currentPage - 1) * PAGE_SIZE;
        const endIndex = startIndex + PAGE_SIZE;
        return this.totalFilteredRecords.slice(startIndex, endIndex);
    }

    resetDropdowns()
    {
        this.selectedLicense ='';
        this.selectedRole ='';
    }

    clearGridAndPaginator()
    {
        this.userData = [];
        this.currentPage = 1;
        this.totalPages = 0;

        this.selectedIdsArray = [];
        this.selectedUserIds = [];
        this.totalRecords = [];
        this.totalFilteredRecords = [];
        this.noUserList = false;

        this.selectedAssignmentUserIds = [];

    }

    handleUserSearch(event) {
        
        this.searchKey = event.target.value.toLowerCase();
        
        if(this.isLicenseAssignment)
        {
            this.searchAssignmentUsers(this.searchKey);
        }
        else if(this.isLicenseRemoval)
        {
             this.searchRemovalUsers(this.searchKey);
        }
    }

    searchRemovalUsers(pSearchKey)
    {
        let filteredUsers = [];

        if(this.totalRecords && this.totalRecords.length > 0)
        {
            this.totalRecords.forEach(currentItem => {
                if(!pSearchKey)
                {
                    filteredUsers.push(currentItem);
                }
                else if(currentItem.Name.toLowerCase().indexOf(pSearchKey) > -1)
                {
                    filteredUsers.push(currentItem);
                }
            });
        }

        this.totalFilteredRecords = filteredUsers;
    }

    searchAssignmentUsers(pSearchKey)
    {
        let filteredUserids = [];

        if(this.allAssignmentUsers && this.allAssignmentUsers.length > 0)
        {
            this.allAssignmentUsers.forEach(currentItem => {

                if(!pSearchKey)
                {
                    filteredUserids.push(currentItem.Id);
                }
                else if(currentItem.Name.toLowerCase().indexOf(pSearchKey) > -1)
                {
                    filteredUserids.push(currentItem.Id);
                }
            });
        }
        this.prepareUserOptions(filteredUserids);
    }

    getFieldNamesForDatatable(){
        getFieldLableAndFieldAPI()
        .then((data) =>{
            let fieldSet = JSON.parse(data);      
            this.userColumns = [];      
            fieldSet.forEach((element)=>{
                let lab=element.label;
                if(lab=='Last Login'){
                    lab='Salesforce Last Login';
                }
                this.userColumns.push({label:lab, fieldName:element.fieldPath ,sortable: true});
            });
         })
        .catch((error) => {
            this.showError(error);
           });
    }

    showError(error){
        let event = new ShowToastEvent({
            title: 'Unable to submit users for License removal.',
            message: error,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    get actionOptions() {
        return [
            { label: 'Remove License', value: 'License_Removal' },
            { label: 'Assign License', value: 'License_Assignment' },
        ];
    };

    handleActionChange(event){
        this.resetDropdowns();
        this.clearGridAndPaginator();
        this.selectedAction = event.detail.value;
        this.isLicenseRemoval = (this.selectedAction === 'License_Removal' );
        this.isLicenseAssignment = (this.selectedAction === 'License_Assignment' );

    }

    handleLicenseChange(event){
        this.clearGridAndPaginator();
        this.selectedLicense = event.detail.value;
        this.isLicenseSelected = (this.selectedAction === 'License_Removal' && this.selectedLicense != null );
        this.isLicenseRemoval = (this.selectedAction === 'License_Removal' );
        this.getLicensedUsers(this.selectedLicense,this.userID);
        this.getLicensesAvailability();
    }

    handleRoleChange(event){
        this.clearGridAndPaginator();
        this.selectedRole = event.detail.value;
        this.isRoleSelected = (this.selectedAction === 'License_Assignment' && this.selectedRole != null );
        this.getActiveUsers();
        this.getRoleAvailability();
    }

    @wire(getRecord, {recordId: USER_ID,fields: [UserName,FullName]}) 
    wireuser({error,data}) {
        if (error) {
        this.error = error ; 
        } else if (data) {
            this.username = data.fields.Username.value;
            this.userFullName = data.fields.Name.value;
            
        }
    };

    @wire(fetchLicensesAssigned, {
        userId: '$userFullName'
    }) 
    wireAssignedLicenses({error,data}) {
        if (error) {
        this.error = error ; 
        } else if (data) {        
        this.prepareLicenseOptions(data);
        }
    };

    prepareLicenseOptions(licensesList)
    {
        this.licenseOptions = [];
       if(!!licensesList && licensesList.length > 0)
        {
            this.getFieldNamesForDatatable();
            licensesList.forEach(currentItem => {
                let licenseItem = {};
                licenseItem.label = currentItem;
                licenseItem.value = currentItem;
                this.licenseOptions.push(licenseItem);
            });
        }else{
            this.notApprover = true;
        }
    }

    @wire(fetchBusinessRoles, {
        userId: '$userFullName'        
    }) 
    wireBusinessRoles({error,data}) {
        if (error) {
        this.error = error ; 
        } else if (data) {
        this.prepareRoleOptions(data);
        }
    };

    prepareRoleOptions(roleList)
    {
        this.roleOptions = [];
        if(!!roleList && roleList.length > 0)
        {
            roleList.forEach(currentItem => {
                let roleItem = {};
                roleItem.label = currentItem;
                roleItem.value = currentItem;
                this.roleOptions.push(roleItem);
            });
        }
    }

    getLicensedUsers(licenseName,userId){
        fetchUsersList({'License':licenseName,'userId':userId})
                .then(result => {
                    if(result && result.length > 0){
                    this.totalPages = Math.ceil(result.length / PAGE_SIZE);
                    this.totalRecords = result;
                    this.totalFilteredRecords = result;
                    this.userData = this.paginateData();
                    }else{
                        this.noUserList = true;
                    }
                })
                .catch(error => {
                    console.log('Error fectching licensed users list ' , error);
                });
    }

    getActiveUsers(){
        if(this.allAssignmentUsers==null || (this.allAssignmentUsers!=null && this.allAssignmentUsers.length == 0))
        {
            fetchAllUsersList({userId:this.userFullName})            
                    .then(result => {
                        this.allAssignmentUsers = result;
                        this.prepareUserOptions(null);
                    })
                    .catch(error => {
                        console.log('Error fetching active users list ' , error);
                    });
        }
    }

    prepareUserOptions(filteredUserIds)
    {
        let considerUserIds = null;

        if(filteredUserIds != null)
        {
            considerUserIds = [...new Set([...filteredUserIds, ...this.selectedAssignmentUserIds])];
        }

       this.userOptions = [];
        if(this.allAssignmentUsers && this.allAssignmentUsers.length > 0)
        {
            let tUserOptionList = [];
            this.allAssignmentUsers.forEach(currentItem => {

                let tCurrentItem = null;
                if(considerUserIds == null)
                {
                    tCurrentItem = currentItem;
                }
                else if(considerUserIds.includes(currentItem.Id))
                {
                    tCurrentItem = currentItem;
                }

                if(tCurrentItem!=null)
                {
                    let tUserOption = {};
                    tUserOption.label = currentItem.Name + ' (' + currentItem.Email + ')';
                    tUserOption.value = currentItem.Id;
                    tUserOptionList.push(tUserOption);
                }
            });
            this.userOptions = tUserOptionList;
            }
    }

    handleAssignmentUserChange(event)
    {
        this.selectedAssignmentUserIds = event.detail.value;
    }

    getRoleAvailability(){
        this.assignLicenseAvailability = [];
        getAssignLicenseReport({Role: this.selectedRole,userId:this.userFullName})
        .then((result)=> {
            this.assignLicenseAvailability = result;
        })
        .catch((error) =>{
            console.log('unable to read getAssignLicenseReport ' , error);
        });
    }

    getLicensesAvailability(){

        this.removeLicenseAvailability = [];
        getRemovalLicenseReport({License: this.selectedLicense})
        .then((result)=> {
            this.removeLicenseAvailability = result;
        })
        .catch((error) =>{
            console.log('unable to read getRemovalLicenseReport ', error);
        }); 
    }

    handleLicenseRemove() {
        var IdList = this.selectedIdsArray;
        if(IdList.length > 0)
        {
            this.removeSelectedUserLicense(IdList);
        }
        else
        {
            this.showToastMessage('Error','Please select atleast one user','error','dismissable');
        }

    }

    
    selectedIdsArray = [];
    handleUserSelection(event){
        console.log('event.detail.config ' , event.detail.config.action);
        if(event.detail.config.action == 'rowSelect'){
            const index = this.selectedIdsArray.indexOf(event.detail.config.value);
            if(index == -1){
                this.selectedIdsArray.push(event.detail.config.value);
            }
            console.log('after adding ', this.selectedIdsArray);
        }else if(event.detail.config.action == 'rowDeselect'){
            const index = this.selectedIdsArray.indexOf(event.detail.config.value);
            if (index > -1) {
                this.selectedIdsArray.splice(index, 1); 
            }
            console.log('after removing ', this.selectedIdsArray);
        }
    }

    
    setGridSelectedUsers()
    {
        const commonUserItem = this.userData.filter(userItem => this.selectedIdsArray.includes(userItem.Id));
        let commUserIds = [];
        commonUserItem.forEach((usr) => {
            commUserIds.push(usr.Id);
        });
        this.selectedUserIds = commUserIds;
        console.log('this.selectedUserIds ' , this.selectedUserIds);
    }

    handleLicenseAssignmentClick() {
        var IdList = this.assignmentUserIds;// this.selectedAssignmentUserIds;
        if(IdList.length > 0)
        {
            this.addSelectedUserLicense(IdList);
        }else
        {
            this.showToastMessage('Error','Users selected already have the selected License','error','dismissable');
        }
    }

    removeSelectedUserLicense(IdList){
       createUserProvisioningRemovalReq({ userIds: IdList,License: this.selectedLicense, Action:this.selectedAction,Owner : this.userID})
        .then((data) =>{
                            let event = new ShowToastEvent({
                            title: 'Success',
                            message: data,
                            variant: 'success',
                            mode: 'dismissable'
                            });
                            this.dispatchEvent(event);

                            this.isLicenseRemovalReview = false;
                            this.isLicenseRemovalSelection = true;
                            this.clearGridAndPaginator();
                            this.selectedLicense = '';

                    })
        .catch((error) => {
            this.showError(error);
        });
    }

    addSelectedUserLicense(IdList){
        createUserProvisioningAddReq({ userIds: IdList,License: this.selectedLicense,Role:this.selectedRole, Action:this.selectedAction,Owner : this.userID})
        .then((data) =>{

            this.isLicenseAssignmentReview = false;
            this.isLicenseAssignmentSelection = true;
            this.selectedRole = '';
            this.allSelectedUserIds = [];
            this.selectedAssignmentUserIds = [];
            this.prepareUserOptions(null);

            let event = new ShowToastEvent({
            title: 'Successfully submitted users for License Assignment.',
            message: data,
            variant: 'success',
            mode: 'dismissable'
            });
            this.dispatchEvent(event);
          
         })
        .catch((error) => {
            this.showError(error);
        });
    }

    
    handleAssignmentBackClick()
    {
        this.isLicenseAssignmentSelection = true;
        this.isLicenseAssignmentReview = false;
    }

    handleAssignmentNextClick()
    {
        if(!this.selectedRole)
        {
             this.showToastMessage('Error','Please select License','error','dismissable');
             return;
        }

        this.allSelectedUserIds = this.selectedAssignmentUserIds;
        if(!!this.allSelectedUserIds && this.allSelectedUserIds.length > 0)
        {
           this.isLicenseAssignmentReview = true;
           this.isLicenseAssignmentSelection = false;
        }
        else
        {
            this.showToastMessage('Error','Please select atleast one user','error','dismissable');
        }
    }

    handleRemovalBackClick()
    {
        this.isLicenseRemovalSelection = true;
        this.isLicenseRemovalReview = false;
    }

    handleRemovalNextClick()
    {
        var IdList = this.selectedIdsArray;
        
        if(IdList.length > 0){
            this.selectedRemovalUsersCount = IdList.length;
            this.isLicenseRemovalReview = true;
            this.isLicenseRemovalSelection = false;
            this.removalReviewData = this.getUsersByUserIds(IdList);
        }else
        {
            this.showToastMessage('Error','Please select atleast one user','error','dismissable');
        }
    }

     getUsersByUserIds(userids)
     {
        let filteredUsers = [];

        if(this.totalRecords && this.totalRecords.length > 0)
        {
            this.totalRecords.forEach(currentItem => {
                if(userids.indexOf(currentItem.Id) > -1)
                {
                    filteredUsers.push(currentItem);
                }
            });
        }

        return filteredUsers;
     }

   
    getAssignmentUserIds(event)
    {
        this.assignmentUserIds = event.detail.assignmentNeededUserIds;
    }

    showToastMessage(pTitle,pMessage,pVariant,pMode)
    {
         let event = new ShowToastEvent({
            title: pTitle,  //ex: 'Error', 'Success'
            message: pMessage,  //success/failure message,
            variant: pVariant,  //'success','error',
            mode: pMode     //'dismissable'
            });
            this.dispatchEvent(event);
    }
}