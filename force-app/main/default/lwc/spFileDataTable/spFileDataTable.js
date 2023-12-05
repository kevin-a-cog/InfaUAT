import { LightningElement, wire, track, api } from 'lwc';
import fetchPlanFiles from '@salesforce/apex/SpFileDataTableController.fetchPlanFiles';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import user_id from '@salesforce/user/Id';

//Core imports.
import basePath from '@salesforce/community/basePath';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
 
//Apex Controllers.
import deleteFile from "@salesforce/apex/SpFileDataTableController.deleteFile";
import updateFileDescription from "@salesforce/apex/SpFileDataTableController.updateFileDescription";
import tagFilestoComments from '@salesforce/apex/SpCaseCommentsCtrl.tagFilestoComments';
//Uncommented Delete action as it required

//Constants
const actionsTest = [
    //{ label: 'Edit', iconName: 'utility:edit', name: 'edit' },
    { label: 'Delete', iconName: 'utility:delete', name: 'delete' }
];

export default class SpFileDataTable extends LightningElement {

	//Track variables.
	@track uploadedFiles = [];
	@track lstFileId = [];

	//Private variables.
	boolIsEditModalOpen = false;
	boolDisplaySpinner = true;
	boolDisableButtons = false;
	strFileDescription;
	strFileToDelete;
	strCommentId;

    error;
    columns;
    allRecords; //All data available for data table    
    showTable = false; //Used to render table after we get the data from apex controller    
    recordsToDisplay = []; //Records to be displayed on the page
    rowNumberOffset; //Row number
    preSelected = [];
    selectedRows;
    @api planRecordId;
    filesNotAvailable = false;
    @track columns = [
        {
			label: 'File Name',
			fieldName: 'url',
			type: 'url',
			typeAttributes: {
				label: { 
					fieldName: 'fileTitle' 
				}, 
			target: '_blank'},
			sortable: true,
            hideDefaultActions: true
		},
		{ label: 'Description', fieldName: 'fileDescription', sortable : true, hideDefaultActions: true },
        { label: 'Owner', fieldName: 'owner', sortable: true, hideDefaultActions: true, },
        {
            label: 'Size',
            fieldName: 'size',
            sortable: true,
            hideDefaultActions: true,
            cellAttributes: { alignment: 'left' },
        },
        { label: 'Modified Date', fieldName: 'modifiedDate', type : 'date', sortable: true, hideDefaultActions: true, typeAttributes:{
            year: "numeric",
            month: "long",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        } },
		{
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions }
        }
        // {
        //     type: 'button-icon',
        //     typeAttributes:
        //     {
        //         iconName: 'utility:delete',
        //         name: 'delete'
        //     }
        // }
    ];
      
    connectedCallback(){
        console.log('spFileDataTable planRecordId ==> ' + this.planRecordId);
        //
        setTimeout(() => {   
            this.filesDataHelper();
        }, 
            2000);

    }
    renderedCallback() {
        console.log('this.allRecords==> :' + this.allRecords) 
     //   console.log('FileCount:' + this.allRecords.length)
        
        if (this.allRecords != undefined && this.allRecords.length == 0){
            this.showTable = false;
            //this.filesNotAvailable = true;
        }
    }

    getRowActions(row, doneCallback) {
            const actions = [];
            //console.log('row data',row);
            if (row.objDocument.ContentDocument.Owner.Id == user_id) {
                actions.push({
                    label: 'Delete', iconName: 'utility:delete', name: 'delete', disabled: false
                });
                
            } else {
                actions.push({
                    label: 'Delete', name: 'disabled', disabled: true
                });
            }
            // simulate a trip to the server
            setTimeout(() => {
                doneCallback(actions);
            }, 400);
    }
    
    @api filesDataHelper(){
		let strURL = (objUtilities.isNotBlank(basePath) ? (basePath.endsWith("/s") ? basePath.replace(new RegExp("/s$"), "") : basePath) : "") + "/sfc/servlet.shepherd/version/download/";
		let objParent = this;
        this.allRecords = [];
        this.showTable = false;
        fetchPlanFiles({'planId': this.planRecordId})
        .then((result) => {  
            console.log('file data ===> ' + JSON.stringify(result));
            var objFileData = JSON.parse(JSON.stringify(result));
            for(var i=0; i < objFileData.length;i++){
                objFileData[i].fileTitle = objFileData[i].objDocument.ContentDocument.Title;
				objFileData[i].fileDescription = objFileData[i].objDocument.ContentDocument.Description;
                objFileData[i].owner = objFileData[i].objDocument.ContentDocument.Owner.Name;
                objFileData[i].size = objFileData[i].objDocument.ContentDocument.ContentSize;
                objFileData[i].modifiedDate = objFileData[i].objDocument.ContentDocument.CreatedDate; 
				objFileData[i].url = strURL + objFileData[i].idLatestVersion;
            }
            this.allRecords = objFileData;
            this.showTable = true;

        })
        .catch((error) => {
            console.log(JSON.stringify(error));  
            let errorMessage;            
            errorMessage = error.body.message != undefined ? error.body.message : 'Something went wrong.';            
            const event = new ShowToastEvent({
                title : 'Error',
                message : errorMessage,
                variant : 'error',
                mode : 'dismissable'
            });
            this.dispatchEvent(event);
        }).finally(() => {
			objParent.boolDisplaySpinner = false;
		});
    }
   


 /*   @wire(fetchPlanFiles, { planId: '$planRecordId' })
    filesData({error,data}){
       
        if(data){     
            
        }else{
            console.log('error from file method ====> ' + JSON.stringify(error));
            this.error = error;
        }       
    }*/

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail.recordsToDisplay;
        this.preSelected = event.detail.preSelected;
        if(this.recordsToDisplay && this.recordsToDisplay > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        }else{
            this.rowNumberOffset = 0;
        } 
    }    

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        let selectedRecordIds = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            console.log(selectedRows[i].Id);
            selectedRecordIds.push(selectedRows[i].Id);
        }     
        this.template.querySelector('c-lwc-datatable-utility').handelRowsSelected(selectedRecordIds);        
    }  
 
    handleAllSelectedRows(event) {
        this.selectedRows = [];
        const selectedItems = event.detail;          
        let items = [];
        selectedItems.forEach((item) => {
            this.showActionButton = true;
            console.log(item);
            items.push(item);
        });
        this.selectedRows = items;  
        console.log(this.selectedRows);        
    } 

	/*
	 Method Name : handleRowActions
	 Description : This method handles the actions of the table.
	 Parameters	 : Object, called from handleRowActions, objEvent Event.
	 Return Type : None
	 */
	handleRowActions(objEvent) {
		let objParent = this;
		if(objUtilities.isNotNull(objEvent) && 
            objUtilities.isNotNull(objEvent.detail) && 
            objUtilities.isNotNull(objEvent.detail.rowValue) && 
			objUtilities.isNotBlank(objEvent.detail.rowValue.objDocument) && 
            objUtilities.isNotBlank(objEvent.detail.rowValue.objDocument.ContentDocumentId) && 
            objUtilities.isNotNull(objEvent.detail.actionValue) &&
			objUtilities.isNotBlank(objEvent.detail.actionValue.name)) {
			//Depending on the action, we execute the process.
			switch(objEvent.detail.actionValue.name) {
				case "delete":
					objParent.boolDisplaySpinner = true;
                    console.log('CurrentUser==FileUploadUser',user_id,objEvent.detail.rowValue.objDocument.ContentDocument.Owner.Id)
                    //if(objEvent.detail.rowValue.objDocument.ContentDocument.Owner.Id === user_id) {
                        deleteFile({
                            'idRecord': objEvent.detail.rowValue.objDocument.ContentDocumentId
                        }).then(() => {  
                            objParent.filesDataHelper();
                        }).catch((objError) => {
                            objUtilities.processException(objError, objParent);
                        }).finally(() => {
                            //Finally, we hide the spinner.
                            objParent.boolDisplaySpinner = false;
                        });
                    //}
				break;
				case "edit":
					objParent.uploadedFiles = [];
                    //remapped contennt document
					objParent.strFileToDelete = objEvent.detail.rowValue.objDocument.ContentDocumentId;
					objParent.strCommentId = objEvent.detail.rowValue.objDocument.LinkedEntityId;
					objParent.boolIsEditModalOpen = true;
        			document.body.classList += ' modal-open';
				break;
			}
		}
	}

	/*
	 Method Name : closeEditModal
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
    closeEditModal() {
        this.boolIsEditModalOpen = false;
		this.lstFileId = [];
        document.body.classList -= ' modal-open';
    }

	/*
	 Method Name : valueChangeHandler
	 Description : This method saves the new File Description.
	 Parameters	 : Object, called from valueChangeHandler, objEvent Event.
	 Return Type : None
	 */
	valueChangeHandler(objEvent) {
		this.strFileDescription = objEvent.target.value;
	}

	/*
	 Method Name : saveNewFileAndDeleteExistingOne
	 Description : This method deletes the existing File and creates the new one.
	 Parameters	 : None
	 Return Type : None
	 */
	saveNewFileAndDeleteExistingOne() {
		let objParent = this;
		if(objUtilities.isNotBlank(objParent.strFileDescription)) {
			objParent.boolDisableButtons = true;
            objParent.boolDisplaySpinner = true;

			//If the user wants to replace the existing attachment.
			if(objUtilities.isNotNull(objParent.lstFileId) && objParent.lstFileId.length > 0 && objUtilities.isNotBlank(objParent.lstFileId[0])) {
				deleteFile({
					'idRecord': objParent.strFileToDelete
				}).then(() => {  
					return tagFilestoComments({
						'strPlanId': objParent.planRecordId,
						'strCommentId': objParent.strCommentId,
						'fileIdList': objParent.lstFileId
					});
				}).then(() => {
					return updateFileDescription({
						'idRecord': objParent.lstFileId[0],
						'strDescription': objParent.strFileDescription
					});
				}).then(() => {
					objParent.filesDataHelper();
					objParent.closeEditModal();
					objUtilities.showToast('Success!', 'File has been updated successfully.', 'success', objParent);
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {
					objParent.boolDisableButtons = false;
					
					//Turn off spinner
					objParent.boolDisplaySpinner = false;
				});
			} else {

				//We only update the attachment description.
				updateFileDescription({
					'idRecord': objParent.strFileToDelete,
					'strDescription': objParent.strFileDescription
				}).then(() => {
					objParent.filesDataHelper();
					objParent.closeEditModal();
					objUtilities.showToast('Success!', 'File has been updated successfully.', 'success', objParent);
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {
					objParent.boolDisableButtons = false;

					//Turn off spinner
					objParent.boolDisplaySpinner = false;
				});
			}
		} else if(objUtilities.isBlank(objParent.strFileDescription)) {
			objUtilities.showToast('Missing required field', 'Description field is required.', 'error', objParent);
            objParent.boolDisplaySpinner = false ;
		} else {
			objUtilities.showToast('Missing file', 'Please upload a new file.', 'error', objParent);
		}
	}

	/*
	 Method Name : acceptedFormats
	 Description : This method defines the accepted file formats.
	 Parameters	 : None
	 Return Type : None
	 */
	get acceptedFormats() {
        return ['.pdf', '.png'];
    }
	
	/*
	 Method Name : handleUploadFinished
	 Description : This method saves the uploaded files.
	 Parameters	 : Object, called from valueChangeHandler, objEvent Event.
	 Return Type : None
	 */
    handleUploadFinished(objEvent) {
		this.lstFileId = [];
        if(this.uploadedFiles.length > 0) {
            for(var i = 0; i < objEvent.detail.files.length; i++) {
                this.uploadedFiles.push(objEvent.detail.files[i]);
            }
        } else {
            this.uploadedFiles = objEvent.detail.files;
        }
		for(var i = 0; i < this.uploadedFiles.length; i++) {    
		   this.lstFileId.push(this.uploadedFiles[i].documentId);
		}
    }

	/*
	 Method Name : handleRemove
	 Description : This method removes uploaded files.
	 Parameters	 : Object, called from valueChangeHandler, objEvent Event.
	 Return Type : None
	 */
    handleRemove(objEvent) {
        this.uploadedFiles = this.uploadedFiles.filter(item => item.name !== objEvent.target.name);
		this.lstFileId = [];
		for(var i = 0; i < this.uploadedFiles.length; i++) {    
		   this.lstFileId.push(this.uploadedFiles[i].documentId);
		}
    }
}