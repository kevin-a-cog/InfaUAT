import { LightningElement, api, wire, track } from 'lwc';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';
import fetchPlanComment from '@salesforce/apex/SpCaseCommentsCtrl.fetchPlanComment'; 
import fetchPlanCommentNoCache from '@salesforce/apex/SpCaseCommentsCtrl.fetchPlanCommentNoCache'; 
import createNewPlanComment from '@salesforce/apex/SpCaseCommentsCtrl.createNewPlanComment'; 
import tagFilestoComments from '@salesforce/apex/SpCaseCommentsCtrl.tagFilestoComments'; 
 
//Core imports.
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
//Core libraries.
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Controllers.
import fetchPlanFiles from '@salesforce/apex/SpFileDataTableController.fetchPlanFiles';


export default class SpPlanComments extends NavigationMixin(LightningElement) {

	//Track variables.
	@track boolRenderPaginator = true;
	@track boolHasRecords = true;
	@track lstRecords;

	//Private variables.
	boolConfirmButtonDisabled = false;
    strCurrentUserTimezone = TIME_ZONE;

    @track showComments = false;
    avatar = sp_resource + '/spResource/images/avatar_01.png';
    case_icon = sp_resource + '/spResource/icons/new_case.png';
    informatica_dp = sp_resource + '/spResource/images/infa_dp.svg';
    @api planRecordId;
	@track bShowSignOff ;
    @track dataPlanUpdates = [];
    isSortedByEarliest = false;
    sortDirection = 'DESC';
    searchTxt = '';
    refreshdata = false;
    showSpinner = false;
    @track uploadComments;
    @track tsftpLocationUrl; 
 
    get sortedBy() {
        return (this.isSortedByEarliest === false) ? 'Sorted by Latest' : 'Sorted by Earliest';
    }

    get userTimeZone(){ // <T01>
       // return new Intl.DateTimeFormat().resolvedOptions().timeZone;
        return this.strCurrentUserTimezone;
        
    }

    renderedCallback() {    
        if (this.dataPlanUpdates != undefined && this.dataPlanUpdates.length == 0){
            this.showComments = false;
        }
    }

    //Private variables.
	intRowNumberOffsetRecords;
	@track lstOriginalRecords;

	/*
	 Method Name : changeTablePage
	 Description : This method changes the page on the Table.
	 Parameters	 : Object, called from sortBy, objEvent Change event.
	 Return Type : None
	 */
	changeTablePage(objEvent) {          
		let recordByDate = [];
		recordByDate = objEvent.detail.reduce((recordByDateAcc, value) => {			
			const options = { year: 'numeric', month: 'long', day: 'numeric',timeZone:this.strCurrentUserTimezone,hour12:false };
			const date = new Date(value.CreatedDate).toLocaleDateString(undefined, options);
			  if (!recordByDateAcc[date]) {
				  recordByDateAcc[date] = [];
			  }
			  recordByDateAcc[date].push(value);
			  return recordByDateAcc;
		  }, {});
		  
		  let recordByDateFinal = [];
		  recordByDateFinal = Object.keys(recordByDate).map((date) => {
			  return {
				  key: date,
				  value: recordByDate[date]
			  };
		  });
		  this.showComments = true;
		  this.dataPlanUpdates = recordByDateFinal;
		  this.showComments = true;
		if(typeof this.dataPlanUpdates[0] !== "undefined") {
			this.intRowNumberOffsetRecords = this.dataPlanUpdates[0].rowNumber;
		}
	}

    @wire(fetchPlanComment, { planId: '$planRecordId', 'sortDirection' : '$sortDirection', 'cmtSearchText' : '$searchTxt', 'bRefreshData' : '$refreshdata'  })
    lstcomments({error,data}){
		this.processPlanComments(data, error);  
    }



    handleCommentSearch(event){        
       var text = event.target.value;
      // console.log(text);
       this.searchTxt = text;
       this.refreshPlanComments();
    }
    handleCommentSort(event){        
        const sortBy = event.detail.value;
        //console.log('Comment SortBy Selection -> ' + sortBy);
        if (sortBy === 'Latest') {
            this.isSortedByEarliest = false;
            this.sortDirection = 'DESC';            
            //this.dispatchEvent(new CustomEvent('commentsortselection', { detail: 'LastModifiedDate DESC' }));
        }
        if (sortBy === 'Earliest') {
            this.isSortedByEarliest = true;
            this.sortDirection = 'ASC';
            //this.dispatchEvent(new CustomEvent('commentsortselection', { detail: 'LastModifiedDate ASC' }));
        }
        this.refreshPlanComments();
    }
    
    @track isAddCommentsModalOpen = false;
    openAddCommentsModal() {
        this.isAddCommentsModalOpen = true;
        document.body.classList += ' modal-open';
        this.uploadComments = '';
    }
    closeAddCommentsModal() {
        this.isAddCommentsModalOpen = false;
        document.body.classList -= ' modal-open';
    }
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }


    @track uploadedFiles = [];
    @track deleteDocumentId;
    @track myNewFile;
    handleUploadFinished(event) {
        //console.log('Entered');
        //console.log('No. of files uploaded : ' + this.uploadedFiles.length);
        //console.log('Event',event.detail.files);
        if(this.uploadedFiles.length > 0){
            //console.log('Entered multiple file');
            for(var i=0;i<event.detail.files.length;i++){
                this.uploadedFiles.push(event.detail.files[i]); 
                
            }
            //console.log('uploadedFiles'+JSON.stringify(this.uploadedFiles));
            //this.uploadedFiles = event.detail.files.map(item => item.name);
        }else{
            this.uploadedFiles = event.detail.files;
        }
    }
    handleRemove(event) {
        //this.showSpinner = true;
        //console.log('Handle Remove Entered');
        let deleteDocumentId = event.target.name;
        this.uploadedFiles = this.uploadedFiles.filter(item => item.name !== deleteDocumentId);
    }


    updateFileDetails() {
       
       // var isValidValue = this.validateInputField();
        let isCommentAvailable = this.validateCommentBody();
       
        // if (isValidValue && isCommentAvailable){
        console.log('isCommentAvailable====> ' + isCommentAvailable);
        if (isCommentAvailable){
            this.updateDoc();
           /// this.isAddUpdateAttachment = false;
           /// document.body.classList -= ' modal-open';
        }
    }
	
    handleCommentsChange(event) {
        
        this.uploadComments = event.detail.value;
        ////this.docComments=event.detail.value;
    }

    updateDoc() {
      let objParent = this;
	  objParent.boolConfirmButtonDisabled = true;
      createNewPlanComment({ 'sComment': this.uploadComments, 'planid' : this.planRecordId })
            .then((result) => {  
                    this.isLoadingSpinner = false;
                    var planCommentId = result;
                    this.uploadComments = '';
                    //console.log('planCommentId---> ' + planCommentId);
                    //console.log('uploadedFiles---> ' + JSON.stringify(this.uploadedFiles));
                    this.refreshdata = !this.refreshdata;
                    if(this.uploadedFiles.length > 0){
                        this.tagFilestoCommentsHelper(planCommentId, this.uploadedFiles);
                    }else{
                        this.closeAddCommentsModal();
                    }
                    
            })
            .catch((error) => {                                      
                const event = new ShowToastEvent({
                  title : 'Error',
                  message : JSON.stringify(error),
                  variant : 'error',
                  mode : 'dismissable'
            });
            this.dispatchEvent(event);
            }).finally(() => {
				objParent.boolConfirmButtonDisabled = false;
			}); 
    }



    /*
	 Method Name : tagFilestoComments
	 Description : This method create contentlink to comemnt created if uploaded a file
	 Parameters	 : None
	 Return Type : None
	 */
     tagFilestoCommentsHelper(commentRecordId,uploadedFilesIdList){
      
         var lstFileId = [];
         for(var i=0; i<uploadedFilesIdList.length;i++){    
            lstFileId.push(uploadedFilesIdList[i].documentId);
         }
         //console.log('lstFileId===> ' + JSON.stringify(lstFileId));
        let objParent = this;     
        //get plan comment on success
        tagFilestoComments({ 'strPlanId': objParent.planRecordId,'strCommentId': commentRecordId ,'fileIdList':lstFileId})
        .then((result) => {  
            this.uploadedFiles = [];
            setTimeout(() => {   
                objParent.dispatchEvent(new CustomEvent('refresh', { detail: 'refresh' }));
            }, 
                500);

            
            objParent.closeAddCommentsModal();
            
        })
        .catch((objError) => {
            console.log('objError===> ' + JSON.stringify(objError));
           /// objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            ///objParent.boolDisplaySpinner = false;
            
        });
    }
    
	
	
	validateInputField(){
        var isValidValue = [...this.template.querySelectorAll('lightning-input-rich-text')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        return isValidValue;
    }
	
	
	 validateCommentBody(){
        const commentBody = this.template.querySelector("[data-name='commentBody']");
        let commentBodyValue = commentBody.value;
        let sCommentData = '';
       //('commentBodyValue : ' + commentBodyValue);
        if(commentBodyValue != '' && commentBodyValue != null && commentBodyValue != undefined){
           let content = '';
           if(commentBodyValue.includes('<p>')){
           // console.log('Rich Text');
              const parser = new DOMParser();
              let commentRichText = parser.parseFromString(commentBodyValue,"text/html");
              //content = commentRichText.body.getElementsByTagName("p").item(0).innerHTML.trim();
              content = commentRichText.body.getElementsByTagName("p").item(0).textContent.trim(); // Checkmarx fix
           }else{
              content = commentBodyValue.trim();
           }
           sCommentData = (content != null && content != undefined && content != "") ? commentBodyValue : content;
        }
         if (sCommentData == '' || sCommentData == undefined || sCommentData == null) {
            if (commentBody != undefined) {
               commentBody.focus();
            }
            this.dispatchEvent(new ShowToastEvent({
               title: 'Error',
               message: 'Comment Body required!',
               variant: 'error'
            }));
            return false;
         }
         return true;
      }

    handlerefresh(){
      this.refreshPlanComments();
    }

      @api refreshPlanComments(){
		  let objParent = this;
       // console.log('refreshPlanComments==> calling  ');
		objParent.boolRenderPaginator = false;
        fetchPlanCommentNoCache({ 
			planId: objParent.planRecordId, 
			sortDirection: objParent.sortDirection, 
			cmtSearchText: objParent.searchTxt, 
			bRefreshData: objParent.refreshdata
		}).then(data => {
			objParent.processPlanComments(data, null);
		});
      }


	/*
	 Method Name : processPlanComments
	 Description : This method processes the plan records to be displayed.
	 Parameters	 : List, called from processPlanComments, data Plan comments.
	 Return Type : None
	 */
	processPlanComments(data, error) {
		let strURL = "https://" + location.hostname + (objUtilities.isNotBlank(basePath) ? (basePath.endsWith("/s") ? basePath.replace(new RegExp("/s$"), "") : basePath) : "") + 
				"/sfc/servlet.shepherd/version/download/";
		let objCSSDiv;
		let objParent = this;
		let lstAttachments = new Array();
		let lstAllAttachments;
        objParent.allRecords = [];

		//If we received data.
		if(data){  
	
			//Now we include the CSS.
			objCSSDiv = objParent.template.querySelector('.customGeneralCSS');
			if(objUtilities.isNotNull(objCSSDiv)) {
				objCSSDiv.innerHTML = "<style> " + 
						".csmPlanCommunicationTimeline-attachments[data-id=" + objParent.planRecordId + "] lightning-primitive-icon.slds-pill__remove {" + 
						"	display: none !important;" + 
						"} </style>";
			}

			//Now we fetch all the files.
			fetchPlanFiles({
				'planId': this.planRecordId
			}).then((result) => {
				lstAllAttachments = result;
			}).finally(() => {

				//Now we process the comments.
				objParent.showComments = false;
				objParent.lstOriginalRecords = new Array();
				var parsedata = JSON.parse(JSON.stringify(data));
				for(let i=0; i<parsedata.length; i++){                
					let record = {};
					record.id = ''+(i+1);
					record.recordId = parsedata[i].Id;
					record.iconName = sp_resource + '/spResource/icons/new_case.png';
					record.className ="sp-timeline__icon sp-timeline__icon--regular";
					record.sName = objUtilities.isNotBlank(parsedata[i].CreatedByName) ? parsedata[i].CreatedByName : parsedata[i].CreatedBy.Name.toLowerCase() == 'deployment master' ? 
							'Informatica Support' : parsedata[i].CreatedBy.FirstName + ' ' + parsedata[i].CreatedBy.LastName;      
					record.userPhoto = objUtilities.isNotBlank(parsedata[i].CreatedByName) ? "/profilephoto/005/T" : parsedata[i].CreatedBy.FullPhotoUrl;
					record.boolRequestSignOff = parsedata[i].Request_Sign_Off;
					record.hasSignOffAccess = parsedata[i].hasSignOffAccess;//added as part of AR-2817
                    record.hasSignOffRecords = parsedata[i].hasSignOffRecords;//added as part of AR-2817
					//console.log('signoff>>>'+parsedata[i].needToSignOff);
					record.needToSignOff = parsedata[i].needToSignOff;//added as part of AR-2840 
					//We define if the current record is a Plan Comment.
					if(objUtilities.isNotNull(parsedata[i].objPlanComment)) {
						record.boolIsPlanComment = true;
					} else {
						record.boolIsPlanComment = false;
					}

					//We format the attachments.
					lstAttachments = new Array();
					if(objUtilities.isNotNull(parsedata[i].ContentDocumentLinks) && parsedata[i].ContentDocumentLinks.length > 0 && objUtilities.isNotNull(lstAllAttachments) && 
							lstAllAttachments.length > 0) {
						parsedata[i].ContentDocumentLinks.forEach(objAttachment => {
							lstAllAttachments.forEach(objAllAttachment => {
								if(objUtilities.isNotNull(objAllAttachment.objDocument) && objAllAttachment.objDocument.Id === objAttachment.Id) {
									lstAttachments.push({
										type: 'icon',
										label: objAttachment.ContentDocument.Title + '.' + objAttachment.ContentDocument.FileExtension,
										name: objAttachment.ContentDocumentId,
										iconName: 'doctype:' + objAttachment.ContentDocument.FileExtension,
										alternativeText: objAttachment.ContentDocument.Title,
										href: strURL + objAllAttachment.idLatestVersion
									});
								}
							});
						});
					}
					record.attachments = lstAttachments;
					record.attachmentCount = parsedata[i].ContentDocumentLinks ? parsedata[i].ContentDocumentLinks.length : 0;
					record.hasAttachments = parsedata[i].ContentDocumentLinks && parsedata[i].ContentDocumentLinks.length;
					record.boolIsAttentionRequest = (parsedata[i].Type === 'Inbound' && parsedata[i].Sub_Type === "Attention Request");
					record.objAttentionRequest = {
						objCase: {
							Id: objUtilities.isNotNull(parsedata[i].objPlanComment) && objUtilities.isNotBlank(parsedata[i].objPlanComment.Case__c) ? parsedata[i].objPlanComment.Case__c : "",
							CaseNumber: objUtilities.isNotNull(parsedata[i].objPlanComment) && objUtilities.isNotBlank(parsedata[i].objPlanComment.Case__c) ? parsedata[i].objPlanComment.Case__r.CaseNumber : ""
						},
						strCustomerRiskReason: objUtilities.isNotNull(parsedata[i].objPlanComment) ? parsedata[i].objPlanComment.Customer_Risk_Reason__c : "",
					};

					//We add the record to the list.
					record = Object.assign(record, parsedata[i]);  
							
					//We add the record.
					objParent.lstOriginalRecords.push(record);
				}
				objParent.showComments = true;
				objParent.boolRenderPaginator = true;
			});
		}else{
			objParent.error = error;
		}
    }

	/*
	 Method Name : openRecord
	 Description : This method opens a record.
	 Parameters	 : Object, called from openRecord, objEvent Event.
	 Return Type : None
	 */
	openRecord(objEvent) {
		this[NavigationMixin.Navigate]({
			type:'standard__recordPage',
			attributes:{
				"recordId": objEvent.currentTarget.dataset.recordId,
				"actionName": "view"
			}
		});
	}

	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		//console.log("searching");
		let strKeyword = objEvent.target.value;
		let objParent = this;
		let objPaginator = objParent.template.querySelector("c-global-paginator");
		let lstRecords;
		let lstClonedRecords;

		//We set the default values.
		objParent.boolHasRecords = false;

		//If the keyword is blank, we refresh the data only.
		if(typeof strKeyword === "undefined" || strKeyword === null || strKeyword === "") {
			lstRecords = [...objParent.lstOriginalRecords];
		} else {
			strKeyword = strKeyword.toLowerCase();

			//Otherwise we filter by the keyword.
			lstClonedRecords = [...objParent.lstOriginalRecords];
			lstRecords = new Array();
			lstClonedRecords.forEach(objRecord => {
				if(JSON.stringify(objRecord.Comment).toLowerCase().includes(strKeyword)) {
					lstRecords.push(objRecord);
				}
			});
		}

		//Finally we display the records.
		if(typeof lstRecords !== "undefined" && lstRecords !== null && lstRecords.length > 0) {
			objParent.boolHasRecords = true;
			objPaginator.resetTheData(lstRecords);
		}
	}

	/*
	 Method Name : openSignOffComponent
	 Description : This method sends the notification to the parent to open the Sign Off component.
	 Parameters	 : None
	 Return Type : None
	 */
	openSignOffComponent() {
		this.dispatchEvent(new CustomEvent("signoff", null));
	}
}