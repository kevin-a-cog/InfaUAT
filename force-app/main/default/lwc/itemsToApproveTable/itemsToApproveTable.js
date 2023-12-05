/* eslint-disable no-console */
import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getProcessItemData from '@salesforce/apex/GetProcessInstanceData.getProcessItemData';
import process from '@salesforce/apex/GetProcessInstanceData.process';


import USER_ID from '@salesforce/user/Id'; //venky 

export default class ItemsToApproveTable extends LightningElement {

    @api actorId;
    @api disableReassignment;
    //@api contextObjectType; //venky
    //@api fieldNames; //venky //field names provided by called to be rendered as columns

    totalitems;
    
    rowData;
    columns;
    fieldDescribes;
    fieldNames = 'Document_Priority__c,VersionNumber,ArticleNumber,Article_Type__c,Content_Review_Date__c,Last_Modified_Date__c,Primary_Product__c';
    fieldNames1 = 'Document_Priority__c,VersionNumber';
    fieldNames2 = 'ArticleNumber,Article_Type__c,Content_Review_Date__c,Last_Modified_Date__c,Primary_Product__c';
    contextObjectType = 'Knowledge__kav';
    spinnerload = false;

    settings = {
        reactionOk: {label: 'Ok', variant: 'brand', value: 'Ok'},
        actionApprove: 'Approve',
        actionReject: 'Reject',
        actionReassign: 'Reassign',
        stringDataType: 'String',
        referenceDataType: 'reference',
        singleMode: 'single',
        mixedMode: 'mixed',
        fieldNameSubmitter: '__Submitter',
        fieldNameSubmitterURL: '__SubmitterURL',
        fieldNameLastActor: '__LastActor',
        fieldNameLastActorURL: '__LastActorURL',
        fieldNameType: '__Type',
        fieldNameRecordName: '__Name',
        fieldNameRecordURL: '__RecordURL',
        fieldNameRecentApproverURL: '__RecentApproverUrl',
        defaultDateAttributes: {weekday: "long", year: "numeric", month: "long", day: "2-digit"},
        defaultDateTimeAttributes: {year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}
    };

    apActions = [
        {label: this.settings.actionApprove, value: this.settings.actionApprove, name: this.settings.actionApprove},
        {label: this.settings.actionReject, value: this.settings.actionReject, name: this.settings.actionReject},
        {label: this.settings.actionReassign, value: this.settings.actionReassign, name: this.settings.actionReassign}
    ];

    mandatoryColumnDescriptors = [
        {
            label: "Date Submitted",
            fieldName: 'dateSubmitted',
            type: "date",
            sortable: true,
            typeAttributes: this.settings.defaultDateTimeAttributes
        },
        {
            label: "Submitter",
            fieldName: this.settings.fieldNameSubmitterURL,
            type: "url",
            sortable: true,
            typeAttributes: {label: {fieldName: this.settings.fieldNameSubmitter}, target: "_self"}
        },
        {
            label: "Assigned To",
            fieldName: this.settings.fieldNameLastActorURL,
            type: "url",
            sortable: true,
            typeAttributes: {label: {fieldName: this.settings.fieldNameLastActor}, target: "_self"}
        },
        {
            label: "Article Title",
            fieldName: this.settings.fieldNameRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: {label: {fieldName: this.settings.fieldNameRecordName}, target: "_self"}
        }
    ];

    getActionMenuItems() {
        return {
            type: "action",
            typeAttributes: {rowActions: this.allowedActions}
        };
    }

    currentAction = this.settings.actionApprove;
    errorApex;
    errorJavascript;
    selectedRows;
    apCount;
    commentVal = '';
    reassignActorId;

    connectedCallback() {
        console.log('hi');
        this.getServerData();
    }

    getServerData() {
        getProcessItemData({
            actorId: USER_ID,
            objectName: this.contextObjectType,
            fieldNames: this.fieldNames,
            mode: this.mode
        }).then(result => {
            let processData = JSON.parse(result);
            this.fieldDescribes = processData.fieldDescribes;
            this.createColumns();
            console.log('result'+this.columns);
            this.rowData = this.generateRowData(processData.processInstanceData);
            this.totalitems = this.rowData.length;
        }).catch(error => {
            console.log('error is: ' + JSON.stringify(error));
        });
    }

    createColumns() {
        this.columns = [
            ...this.getCustomFieldColumns(this.fieldNames1), 
            ...this.mandatoryColumnDescriptors.filter(curDescriptor => {
                return this.mode !== this.settings.singleMode || !(this.mode === this.settings.singleMode && curDescriptor.fieldName === this.settings.fieldNameType)
            }), 
            ...this.getCustomFieldColumns(this.fieldNames2), 
            this.getActionMenuItems()
        ];
        
        for(var i=0;i< this.columns.length; i++){
            console.log('each col'+this.columns[i].fieldName);
        }
    }

    getCustomFieldColumns(fieldNames) {
        let resultFields = [];
        if (fieldNames) {
            fieldNames.replace(/\s+/g, '').split(',').forEach(curFieldName => {
                console.log('current field'+curFieldName);
                let fieldDescribe = this.getFieldDescribe(this.contextObjectType, curFieldName);
                console.log('fieldlabel'+fieldDescribe);
                if (fieldDescribe) {
                    resultFields.push({
                            ...{
                                label: fieldDescribe.label,
                                fieldName: curFieldName,
                                sortable: true
                            }, ...this.getDefaultTypeAttributes(fieldDescribe.type)
                        }
                    );
                }
            });
        }
        return resultFields;
    }

    getDefaultTypeAttributes(type) {
        if (type.includes('date')) {
            return {
                type: "date",
                typeAttributes: this.settings.defaultDateTimeAttributes
            };
        } else {
            return {type: 'text'};
        }
    }

    getFieldDescribe(objectName, fieldName) {
        console.log('objectname'+objectName);
        console.log('obj name'+ this.fieldDescribes[objectName]);
        if (this.fieldDescribes && this.fieldDescribes[objectName]) {
            let fieldDescribe = this.fieldDescribes[objectName].find(curFieldDescribe => curFieldDescribe.name.toLowerCase() === fieldName.toLowerCase());
            console.log('field value'+fieldDescribe);
            return fieldDescribe;
        }
    }

    get actionReassign() {
        return this.currentAction === this.settings.actionReassign;
    }

    get allowedActions() {
        if (this.apActions && this.apActions.length) {
            if (this.disableReassignment) {
                return this.apActions.filter(curAction => curAction.value != this.settings.actionReassign);
            } else {
                return this.apActions;
            }
        }
        return [];
    }

    get mode() {
        if (this.contextObjectType && this.fieldNames)
            return this.settings.singleMode; //display items to approve for a single type of object, enabling additional fields to be displayed
        else if (!this.contextObjectType && this.fieldNames) {
            this.errorJavascript = 'Flow Configuration error: You have specified fields without providing the name of an object type.';
        } else {
            return this.settings.mixedMode;
        }
    }

    updateSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
        this.apCount = event.detail.selectedRows.length;
        console.log('selectedrows'+this.selectedRows);
    }

    handleRowAction(event) {
        console.log('event - ' + JSON.stringify(event));
        this.currentAction = event.detail.action.value;
        console.log('action selected - ' + this.currentAction);
        if (this.currentAction === this.settings.actionApprove || this.currentAction === this.settings.actionReject) {
            this.processApprovalAction(event.detail.row);
        } else {
            this.modalAction(true);
        }
    }

    handleModalBatch() {
        this.processApprovalAction();
    }

    processApprovalAction(curRow) {
        if ((curRow || (this.selectedRows && this.selectedRows.length)) && this.currentAction) {
            process({
                reassignActorId: this.reassignActorId,
                action: this.currentAction,
                workItemIds: curRow ? [curRow.WorkItemId] : this.selectedRows.map(curRow => curRow.WorkItemId),
                comment: this.commentVal
            })
                .then(result => {
                    this.spinnerload = false;
                    this.showToast('Approval Management','Article(s) '+this.currentAction+'ed Successfully',  'success', true);
                    this.getServerData();
                })
                .catch(error => {
                    this.spinnerload = false;
                    this.showToast('Approval Management','Article(s) could not be' +  this.currentAction+'ed', 'error', true);
                    console.log('error returning from process work item apex call is: ' + JSON.stringify(error));
                });
            
        }
    }

    showToast(title, message, variant, autoClose) {
        /*this.template.querySelector('c-toast-message').showCustomNotice({
            detail: {
                title: title, message: message, variant: variant, autoClose: autoClose
            }
        });*/
        const evt = new ShowToastEvent({           
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    
    getRecordURL(sObject) {
        return '/lightning/r/' + sObject.attributes.type + '/' + sObject.Id + '/view';
    }

    getObjectUrl(objectTypeName, recordId) {
        return '/lightning/r/' + objectTypeName + '/' + recordId + '/view';
    }

    generateRowData(rowData) {
        return rowData.map(curRow => {
            console.log('row data - ' + JSON.stringify(curRow));
            let resultData = {
                ...{
                    WorkItemId: curRow.workItem.Id,
                    ActorId: curRow.workItem.ActorId,
                    TargetObjectId: curRow.sObj.Id,
                    dateSubmitted: curRow.processInstance.CreatedDate
                }, ...curRow.sObj
            };
            console.log('resultval'+curRow.Currentappgroup);
            resultData[this.settings.fieldNameSubmitter] = curRow.createdByUser.Name;
            resultData[this.settings.fieldNameSubmitterURL] = this.getObjectUrl('User', curRow.createdByUser.Id);
            if (curRow.lastActorUser) {
                resultData[this.settings.fieldNameLastActor] = curRow.lastActorUser.Name;
                resultData[this.settings.fieldNameLastActorURL] = this.getObjectUrl('User', curRow.lastActorUser.Id);
            } else if(curRow.Currentappgroup){
                console.log('resultval2'+curRow.Currentappgroup);
                resultData[this.settings.fieldNameLastActor] = curRow.Currentappgroup;
                resultData[this.settings.fieldNameLastActorURL] = '/lightning/n/Items_to_Approve_Knowledge';

               
            }
            resultData[this.settings.fieldNameType] = curRow.sObj.attributes.type;
            resultData[this.settings.fieldNameRecordName] = curRow.sObj[curRow.nameField];
            resultData[this.settings.fieldNameRecordURL] = this.getRecordURL(curRow.sObj);
            
            return resultData;
        });
    }

    get modalReactions() {
        return [this.settings.reactionOk];
    }

    handleModalReactionButtonClick(event) {
        this.handleModalBatch();
    }

    handleApprove(event) {
        console.log('button clicked');
        this.currentAction = 'Approve';
        this.currentAction = this.settings.actionApprove;
        this.spinnerload = true;
        this.processApprovalAction();
        //this.modalAction(true);
    }

    handleReject(event) {
        console.log('button clicked');
        this.currentAction = 'Reject';   
        this.spinnerload = true;     
        this.processApprovalAction();
        //this.modalAction(true);
    }

    handleComment(event) {
        this.commentVal = event.detail.value;
    }

    modalAction(isOpen) {
        const existing = this.template.querySelector('c-uc-modal');

        if (existing) {
            if (isOpen) {
                existing.openModal(this.selectedRows);
            } else {
                existing.closeModal();
            }
        }
    }

    handleSelectionChange(event) {
        this.reassignActorId = event.detail.value;
    }

    handleActionChange(event) {
        this.currentAction = event.detail.value;
    }

    get isManageDisabled() {
        return (!this.selectedRows || this.selectedRows.length === 0);
    }
}