import { LightningElement,wire,track,api } from 'lwc';
import { getPicklistValues , getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import retrieveUserDetails from '@salesforce/apex/GCSQueueAssignmentController.retrieveUserDetails';
import getGCSTeam from '@salesforce/apex/GCSQueueAssignmentController.getGCSTeam';
import deleteSelectedFilter from '@salesforce/apex/GCSQueueAssignmentController.deleteSelectedFilter';
import editSelectedFilter from '@salesforce/apex/GCSQueueAssignmentController.editSelectedFilter';
import cloneSelectedFilter from '@salesforce/apex/GCSQueueAssignmentController.cloneSelectedFilter';
import saveFilterCriteria from '@salesforce/apex/GCSQueueAssignmentController.saveFilterCriteria';

export default class GCS_QueueAssignment extends LightningElement {

@track gcsTeamOptions = [{label:'None', value :'None'}];
selectedGcsTeam = 'None';
selectedUserId;

@track showAddFilterScreen = false;
@track showfilterCriteriaList = false;
@track showSetSubsButton = true;

@track notificationFilterList = {
    Queue_Membership__c : '',
    Filter_Products__c : '',
    Filter_Product_Lines__c : '',
    Filter_Support_Levels__c : '',
    Filter_Regions__c :'',
    Filter_Priority__c:'',
    Filter_Timezone__c:''
};
@track filterCriteriaList = [];

filterQueuesOption = [];
filterProductsOptions = [];
filterCompOptions = [];
filterSuccOfferingOptions =[];
filterRegionOptions=[];
filterPriorityOptions = []; 
filterTimezoneOptions = [];

    connectedCallback(event){
        getGCSTeam()
        .then(result=>{
            console.log('result >> '+ JSON.stringify(result))
            result.gcsTeamPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.gcsTeamOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.queueMemberPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterQueuesOption.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.productsPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterProductsOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.componentsPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterCompOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.succOfferingPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterSuccOfferingOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.regionPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterRegionOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.priorityPicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterPriorityOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            result.timeZonePicklistValList.forEach(element =>{
                var picklistVal = element.split(';;');
                this.filterTimezoneOptions.push({label:picklistVal[0], value:picklistVal[1]});
            });

            this.gcsTeamOptions = JSON.parse(JSON.stringify(this.gcsTeamOptions));
            this.filterQueuesOption = JSON.parse(JSON.stringify(this.filterQueuesOption));
            this.filterProductsOptions = JSON.parse(JSON.stringify(this.filterProductsOptions));
            this.filterCompOptions = JSON.parse(JSON.stringify(this.filterCompOptions));
            this.filterSuccOfferingOptions = JSON.parse(JSON.stringify(this.filterSuccOfferingOptions));
            this.filterRegionOptions = JSON.parse(JSON.stringify(this.filterRegionOptions));
            this.filterPriorityOptions = JSON.parse(JSON.stringify(this.filterPriorityOptions));
            this.filterTimezoneOptions = JSON.parse(JSON.stringify(this.filterTimezoneOptions));
        })
        .catch(error => {
            console.log('Error in getGCSTeam ' + JSON.stringify(error));
        });
        console.log(`Connected Call Back.. `, JSON.stringify(this.notificationFilterList));
    }

    handleUserChange(event){
        this.selectedUserId = event.target.value;
        console.log('this.selectedUserId '+ this.selectedUserId);
    }

    handleGcsTeamChange(event){
        this.selectedGcsTeam = event.target.value;
        console.log('this.selectedGcsTeam '+ this.selectedGcsTeam);
    }

    handleSetSubscription(event){

        console.log('this.selectedGcsTeam - SetSub >> '+ this.selectedGcsTeam);
        console.log('this.selectedUserId - SetSub >> '+ this.selectedUserId);
        
        this.filterCriteriaList=[];        
        var errMessage = '';
        this.showSetSubsButton = false;

        if(this.selectedUserId && this.selectedGcsTeam !== 'None'){
            this.showAddFilterScreen = false;
            errMessage = 'Please select either an User or a GCS Team and not both.';
            this.showfilterCriteriaList = false;

        }else if(!this.selectedUserId && this.selectedGcsTeam === 'None'){
            this.showAddFilterScreen = false;
            errMessage = 'Please select either User or a GCS Team.';
            this.showfilterCriteriaList = false;
        }        
        else{
            this.retrieveUserDetails();   /**Retrieve the filter Criterias */ 
            this.showfilterCriteriaList = true;
            this.showSetSubsButton = false;
        }

        /** Show Error Message */
        if(errMessage){        
            this.showSetSubsButton = true;    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error : ',
                    message: errMessage,
                    variant: 'error',
                }),
            );
        }
    }

    retrieveUserDetails(){
        this.filterCriteriaList=[]; /** Reset the Filter Criterias */
        var GCSTeam ;
        var user ;

        if(this.selectedGcsTeam === 'None' || this.selectedGcsTeam === ''){
            GCSTeam = null;
        }else{
            GCSTeam = this.selectedGcsTeam;
        }

        if(this.selectedUserId === '' || this.selectedUserId === undefined || this.selectedUserId === null){
            user = null;
        }else{
            user = this.selectedUserId;
        }

        retrieveUserDetails({selectedUserId : user , selectedGCSTeam : GCSTeam})
                .then(result =>{
                    console.log('result >> '+ JSON.stringify(result));
                    if(result){
                    result.forEach(element => {
                        console.log('element 1>> '+ JSON.stringify(element.filterText));
                        console.log('element 2>> '+ JSON.stringify(element.usrFilterId));
                        
                        this.filterCriteriaList.push({filterText:element.filterText,usrFilterId:element.usrFilterId});
                        
                        console.log('element 3>> '+ JSON.stringify(this.filterCriteriaList));
                    });
                }else{
                    this.showAddFilterScreen = true;
                }

                })
                .catch(error => {
                    console.log('Error in retrieveUserDetails ' + JSON.stringify(error));
                });

        }

    handleFilterChange(event){
        console.log('event.Target.name >> ' + event.target.name);
        switch (event.currentTarget.name) {
            case 'FilterQueues':
                this.notificationFilterList.Queue_Membership__c = event.currentTarget.value;
            break;

            case 'FilterProducts':
                this.notificationFilterList.Filter_Product_Lines__c= event.currentTarget.value;
            break;

            case 'FilterComponents':
                this.notificationFilterList.Filter_Products__c = event.currentTarget.value;
            break;

            case 'FilterSuccessOffering':
                this.notificationFilterList.Filter_Support_Levels__c = event.currentTarget.value;
            break;

            case 'FilterRegions':
                this.notificationFilterList.Filter_Regions__c = event.currentTarget.value;
            break;

            case 'FilterPriority':
                this.notificationFilterList.Filter_Priority__c = event.currentTarget.value;
            break;

            case 'FilterTimezone':
                this.notificationFilterList.Filter_Timezone__c = event.currentTarget.value;
            break;

        }

        console.log('this.notificationFilterList >> '+ JSON.stringify(this.notificationFilterList));
    }

    handleChangeUser(event){
        this.notificationFilterList ={};
        this.showAddFilterScreen = false;
        this.showfilterCriteriaList = false;

        this.selectedGcsTeam = 'None';
        this.selectedUserId = null;
        this.showSetSubsButton = true;
}

    handleAddFilter(event){
        console.log('this.selectedGcsTeam' +this.selectedGcsTeam);

        this.notificationFilterList = {};
        if(this.selectedUserId){
            this.notificationFilterList.User__c = this.selectedUserId;
        }
        if(this.selectedGcsTeam !== 'None'){
            this.notificationFilterList.GCS_Team__c = this.selectedGcsTeam;
        }
        
        this.showAddFilterScreen = true;
        this.showfilterCriteriaList = false;
        console.log('ADD FILTER => notificationFilterList' + JSON.stringify(this.notificationFilterList));
    }

    handleCancel(){
        this.notificationFilterList ={};
        this.showAddFilterScreen = false;
        this.showfilterCriteriaList = true;
    }

    handleClearAll(){
        this.notificationFilterList = {};
    }

    handleSave(){
        /**Validation to fill all the values */
        console.log('this.notificationFilterList >> '+ JSON.stringify(this.notificationFilterList));
        console.log('this.notificationFilterList ID >> '+ JSON.stringify(this.notificationFilterList.Id));
        console.log('Queue Member Size'+this.notificationFilterList.Queue_Membership__c?.length);

        var errorMsg = '';
        if(this.notificationFilterList.Queue_Membership__c !== undefined && this.notificationFilterList.Queue_Membership__c.length >98){
            errorMsg = 'You can select a maximum of 98 products. Please reduce the selection size';
        }else if (this.notificationFilterList.Queue_Membership__c === undefined || (this.notificationFilterList.Queue_Membership__c !== undefined && this.notificationFilterList.Queue_Membership__c?.length <1)){
            errorMsg = 'User/Team needs to be subscribed to atleast one queue';
        }

        if(errorMsg){            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error : ',
                    message: errorMsg,
                    variant: 'error',
                }),
            );

        }else{

        let params = {filterCriteria : Object.assign({ 'SobjectType' : 'Custom_Notification_Filter__c' }, this.notificationFilterList)};

        saveFilterCriteria(params)
        .then(result=>{
            this.showAddFilterScreen = false;
            this.showfilterCriteriaList = true;

            /** Show success message **/
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success : ',
                    message: 'Fiter criteria saved successfuly',
                    variant: 'success',
                }),
            );

            this.retrieveUserDetails();   /**Retrieve the filter Criterias */ 
        })
        .catch(error =>{
            console.log('Error in retrieveUserDetails ' + JSON.stringify(error));
        })
    }

    }
    handlefCriteriaEdit(event){        
        let targetId = event.target.dataset.targetId;
        console.log('Target >> '+ targetId);

        editSelectedFilter({filterId : targetId})
        .then(result =>{
            console.log('result >> '+ JSON.stringify(result));
            this.notificationFilterList = {};
            this.notificationFilterList = {
                Id : result.Id,
                Queue_Membership__c : result.Queue_Membership__c?.split(';'),
                Filter_Products__c : result.Filter_Products__c?.split(';'),
                Filter_Product_Lines__c : result.Filter_Product_Lines__c?.split(';'),
                Filter_Support_Levels__c : result.Filter_Support_Levels__c?.split(';'),
                Filter_Regions__c :result.Filter_Regions__c?.split(';'),
                Filter_Priority__c:result.Filter_Priority__c?.split(';'),
                Filter_Timezone__c:result.Filter_Timezone__c?.split(';')
            };
            this.showAddFilterScreen = true;
            this.showfilterCriteriaList = false;
            console.log('this.notificationFilterList >> '+ JSON.stringify(this.notificationFilterList));

            this.retrieveUserDetails();   /**Retrieve the filter Criterias */ 
        })
        .catch(error=>{
            console.log('Error in handlefCriteriaEdit ' + JSON.stringify(error));
        })

        
    }
    handlefCriteriaClone(event){
        let targetId = event.target.dataset.targetId;
        console.log('Target >> '+ targetId);

        cloneSelectedFilter({filterId : targetId})
        .then(result =>{

            this.retrieveUserDetails();   /**Retrieve the filter Criterias */ 

            /** Show success message **/
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success : ',
                    message: 'Fiter criteria cloned successfuly',
                    variant: 'success',
                }),
            );

        })
        .catch(error=>{
            console.log('Error in retrieveUserDetails ' + JSON.stringify(error));
        })
    }
    handlefCriteriaDelete(event){
        let targetId = event.target.dataset.targetId;
        console.log('Target >> '+ targetId);

        deleteSelectedFilter({filterId : targetId})
        .then(result =>{

            this.retrieveUserDetails();   /**Retrieve the filter Criterias */ 

            /** Show success message **/
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success : ',
                    message: 'Fiter criteria deleted successfuly',
                    variant: 'success',
                }),
            );

        })
        .catch(error=>{
            console.log('Error in retrieveUserDetails ' + JSON.stringify(error));
        })
    }
    get checkDisableUserSelection(){
        return !this.showSetSubsButton;
    }
}