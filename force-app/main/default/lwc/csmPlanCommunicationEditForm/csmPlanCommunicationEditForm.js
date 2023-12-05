/*
 * Name			    :	CsmPlanCommunicationEditForm
 * Author		    :	Deva M
 * Created Date	    :   25/10/2021
 * Description	    :	CsmPlanCommunicationEditForm controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M		            25/10/2021		    N/A				Initial version.			N/A
 Deva M		            15/02/2022		    AR-2174			Hide External button for 
                                                            Internal plans. 			N/A
Deva M		            04-May-2022		    AR-2653			Hide External cateogory on
                                                            Sign off Request 			
 */

//Core imports.
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord,getFieldValue,deleteRecord, updateRecord  } from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
//import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import Loading from '@salesforce/label/c.Loading';
import Error from '@salesforce/label/c.Error';
import Success from '@salesforce/label/c.Success';
import Insert_Meeting from '@salesforce/label/c.Insert_Meeting'; 
import Insert_Availability from '@salesforce/label/c.Insert_Availability';
import CSM_PAF_Health_Reason_Template from '@salesforce/label/c.CSM_PAF_Health_Reason_Template';
import Tagged_Users from '@salesforce/label/c.Tagged_Users';
import CSM_Plan_Comment_Category from '@salesforce/label/c.CSM_Plan_Comment_Category';
import CassiniDefaultReply from '@salesforce/label/c.CassiniDefaultReply';
import ClosingNotesError from '@salesforce/label/c.ClosingNotesError';


//Apex methods
import getEmailTemplates from '@salesforce/apex/CSMPlanCommunicationController.getEmailTemplates';
import closeInboundAttentionRequestParent from '@salesforce/apex/CSMPlanCommunicationController.closeInboundAttentionRequestParent';
import fetchMergedQuickText from '@salesforce/apex/CSMPlanCommunicationController.fetchMergedQuickText';
import tagFilestoComments from '@salesforce/apex/CSMPlanCommunicationController.tagFilestoComments';
import getDocuments from '@salesforce/apex/CSMPlanCommunicationController.getDocuments';
import createJiraCommentFromPlanComment from '@salesforce/apex/CSMPlanCommunicationController.createJiraCommentFromPlanComment';
import updateSignoffObjectives from '@salesforce/apex/CSMObjectivesSignoffController.updateSignoffObjectives';
import sendEmail from '@salesforce/apex/CSMSendGridPlanController.sendEmail';
import getTaggedUsers from '@salesforce/apex/CSMPlanCommunicationController.getTaggedUsers';

//Fields
import COMMENT_FIELD from '@salesforce/schema/Plan_Comment__c.Comment__c';
import STATUS_FIELD from '@salesforce/schema/Plan_Comment__c.Status__c';
import VISIBILITY_FIELD from '@salesforce/schema/Plan_Comment__c.Visibility__c';
import TYPE_FIELD from '@salesforce/schema/Plan_Comment__c.Type__c';
import IMPORTANCE_FIELD from '@salesforce/schema/Plan_Comment__c.Importance__c';
import SUB_TYPE_FIELD from '@salesforce/schema/Plan_Comment__c.Sub_Type__c';
const fields = [COMMENT_FIELD,STATUS_FIELD,VISIBILITY_FIELD,
                TYPE_FIELD,IMPORTANCE_FIELD,
                SUB_TYPE_FIELD];
//Plan Fields
import INTERNAL_FIELD from '@salesforce/schema/Plan__c.Is_Internal__c';
const PLAN_FIELDS = [INTERNAL_FIELD];
//Plan Comment Fields
/*import SUB_TYPE from '@salesforce/schema/Plan_Comment__c.Sub_Type__c';
import PLAN_COMMENT_OBJECT from '@salesforce/schema/Plan_Comment__c';*/
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import PLAN_COMMS from '@salesforce/messageChannel/csmPlanCommunication__c';
export default class CsmPlanCommunicationEditForm  extends NavigationMixin(LightningElement) {
    //Public variables
    @api isPoppedOut;
    @api recordId;
    @api commentRecordId;
    @api strParentCommentId;
    @api isEditForm;
    @api isReplyForm;
	@api alternateId;
    @api parentTabValue;
    @api childTabValue;
    //Private Variables.
	boolRequestSignOff = false;
	boolOpenScheduler = false;
	boolIsSendSchedule = false;
	boolIsCreateInvite = false;
	boolDisplayMultiSelectLookup = false;
	@track objMultiSelectLookupRequest = {
		intMaximumNumberOfSelectedResults: 5,
		intLimitResults: 10,
    	strObjectApiName: "User",
    	strIconName: "standard:user",
		strAdditionalFilters: "AND UserType = 'Standard' AND IsActive = TRUE",
		strValueFormat: "{!Name} - {!Email}",
		lstPreloadedPills: new Array(),
		lstFilterFieldAPINames: [
			"Name",
			"Alias"
		]
	}
	strTaggedUser1;
	strTaggedUser2;
	strTaggedUser3;
	strTaggedUser4;
	strTaggedUser5;
    planCommentText;
    boolDisplaySpinner;
    buttonActionType;
    emailTemplateList;
    quickActionConfiguration;
    showFloatingActionModal;
    showFloatingActionButton;
    isSchedule;
    scheduleDateValue;
    @wire(MessageContext)
    messageContext;
    fileData;
    boolPostJiraComment;
    contentDocumentLinkList = [];
    wiredDocuments;
    uploadedFilesIdList = [];
    attachments=[];
    objParentCommentRecord;
    //Objective Sign off Params
    strSignoffContact;
    lstSelectedObjectives;
    strCommentBody;
    boolPAFTemplate;
    boolInternalPlan;
    boolIsCassiniParent = false;
    get uploadedAttachments() {
        return this.attachments.length > 0;
     }
    get richTextHeightClass(){
        return (objUtilities.isNotNull(this.isPoppedOut) &&  this.isPoppedOut==true)? 'popoutclass' :'lwcrichtext';
    }
    get parentFileId() {
        return objUtilities.isNotNull(this.commentRecordId)  ?  this.commentRecordId: this.uploadedFilesIdList.join(',');
    }
    get acceptedFormats() {
        return ['.pdf', '.jpg', '.png','.xlsx','.xls','.csv','.doc','.docx','.txt','.jpeg'];
    }
    get parentId() {
        return objUtilities.isNotNull(this.commentRecordId)? this.commentRecordId : this.recordId;
     }

    get isId() {
        return objUtilities.isNotNull(this.commentRecordId) ? true : false;
     }
     //Labels.
     label = {   
        Loading,
        Error,
        Success,
        CSM_PAF_Health_Reason_Template,
        CSM_Plan_Comment_Category,
		Tagged_Users
    }

    //Feature Configuration.   
    objConfiguration = {
        apiName: "Plan_Comment__c",
        allowedRichTxtFormats : ['font', 'size', 'bold', 'italic', 'underline',
            'strike', 'list', 'indent', 'align', 'link',
            'image', 'clean', 'table', 'header', 'color'
            ],
        fields: {
           comment: {
               fieldApi:"Comment__c",
               showField:true,
               fieldValue:""
           },
           dateTimeScheduled: {
                fieldApi:"Date_Time_Scheduled__c",
                showField:true,
                fieldValue:""
            },
            comment: {
                fieldApi:"Comment__c",
                showField:true,
                fieldValue:""
            },
           status:{
                fieldApi:"Status__c",
                showField:true,
                fieldValue:"Pre Draft"
            },
            scheduledTime:{
                fieldApi:"Date_Time_Scheduled__c",
                showField:true,
                fieldValue:undefined
            },
            visibility:{
                fieldApi:"Visibility__c",
                showField:true,
                fieldValue:"Internal",
                options:[{
                    label: 'Private',
                    value: 'Private'
                },
                {
                    label: 'Internal',
                    value: 'Internal'
                }]
            },
            type:{
                fieldApi:"Type__c",
                showField:true,
                fieldValue:""
            },
            importance:{
                fieldApi:"Importance__c",
                showField:false,
                fieldValue:false
            },
            internalCategory:{
                fieldApi:"Sub_Type__c",
                showField:true,
                fieldValue:"",
                options:[
                    /*{ label: 'General', value: 'General' },
                    { label: 'CSM Manager', value: 'CSM Manager' },
                    { label: 'PAF Update', value: 'PAF Update' },
                    { label: 'Risk', value: 'Risk' },
                    { label: 'Engagement', value: 'Engagement' },
                    { label: 'Objectives & Milestone', value: 'Objectives & Milestone' },
                    { label: 'Closing Notes', value: 'Closing Notes' }*/
                ]
            },
            inbound:{
                fieldApi:"Inbound__c",
                showField:true,
                fieldValue:false
            },
            subType:{
                fieldApi:"Sub_Type__c",
                showField:true,
                fieldValue:"General Response"
            }
        },
        lstButtons:[
            {
                keyValue: "1",
                label: Insert_Meeting,
                variant: '',
                title: Insert_Meeting,
                iconName: 'utility:event',
                iconPosition: 'left',
                styleClass: 'slds-m-horizontal_x-small',
                name: 'insert_meeting',
				showButton: true
            },
            {
                keyValue: "2",
                label: Insert_Availability,
                variant: '',
                title: Insert_Availability,
                iconName: 'utility:shift_scheduling_operation',
                iconPosition: 'left',
                styleClass: 'slds-m-horizontal_x-small',
                name: 'insert_availability',
				showButton: true
            },
            {
                keyValue:"3",
                label:'Save as Draft',
                variant:'',
                title:'Save as Draft',
                iconName:'utility:note',
                iconPosition:'left',
                styleClass:'slds-m-horizontal_x-small',
                name:'saveAsDraft'
            },
            {
                keyValue:"4",
                label: '',
                variant:'',
                title:'',
                iconName:'utility:reminder',
                iconPosition:'left',
                styleClass:'slds-m-horizontal_x-small',
                name:'schedule'
            },
            {
                keyValue:"5",
                label:'Submit',
                variant:'brand',
                title:'Submit',
                iconName:'utility:save',
                iconPosition:'left',
                styleClass:'slds-m-horizontal_x-small',
                name:'submit'
            }
        ]
    }
    //Retruns today's data
    get todayDate() {
        return new Date();
    }
   /* //Get plan comment object
    @wire(getObjectInfo, { objectApiName: PLAN_COMMENT_OBJECT })
    planCommentObject;
    //Dynamically pull picklist values from fiels
    @wire(getPicklistValues,{recordTypeId: '$planCommentObject.data.defaultRecordTypeId',fieldApiName: SUB_TYPE})
    subTypePicklist({error, data}) {
        if (error) {
            //Process Error
        } else if (data) {
            this.objConfiguration.fields.internalCategory.options=data.values;
        }
    }*/


    
    /*
    Method Name : planRecord
    Description : This wired method gets plan and set properties.
    Parameters	 : None
    Return Type : None
    */
    @wire(getRecord, { recordId: "$recordId", fields: PLAN_FIELDS })
    planRecord({error, data}) {
        this.boolDisplaySpinner = true;
        if (error) {
            //Process Error
        } else if (data) {
            const internalPlan =  getFieldValue(data, INTERNAL_FIELD);  
            this.boolInternalPlan =  internalPlan;         
            if(objUtilities.isNotNull(internalPlan) && internalPlan===true){
                this.objConfiguration.fields.visibility.options=new Array();
                this.objConfiguration.fields.visibility.options.push({
                    label: 'Private',
                    value: 'Private'
                },
                {
                    label: 'Internal',
                    value: 'Internal'
                });
            }else{ 
                this.objConfiguration.fields.visibility.options=new Array();
                this.objConfiguration.fields.visibility.options.push({
                    label: 'Private',
                    value: 'Private'
                },
                {
                    label: 'Internal',
                    value: 'Internal'
                },
                {
                    label: 'External',
                    value: 'External'
                });
            }
            this.boolDisplaySpinner = false;
        }
    }
    /*
	 Method Name : wiredCommentRecord
	 Description : This wired method gets comment for edit.
	 Parameters	 : None
	 Return Type : None
	 */
    @wire(getRecord, { recordId: '$commentRecordId', fields })
    wiredCommentRecord({error, data}) {
        this.boolDisplaySpinner = true;
        if (error) {
            //Process Error
        } else if (data) {
            if(this.commentRecordId){ 
                this.objConfiguration.fields.comment.fieldValue=getFieldValue(data, COMMENT_FIELD);
                this.objConfiguration.fields.status.fieldValue=getFieldValue(data, STATUS_FIELD);
                this.objConfiguration.fields.visibility.fieldValue=getFieldValue(data, VISIBILITY_FIELD);
                this.objConfiguration.fields.type.fieldValue=getFieldValue(data, TYPE_FIELD);
                this.objConfiguration.fields.importance.fieldValue=getFieldValue(data, IMPORTANCE_FIELD);
                this.objConfiguration.fields.internalCategory.fieldValue=getFieldValue(data, SUB_TYPE_FIELD);
                this.objConfiguration.fields.internalCategory.showField = (getFieldValue(data, TYPE_FIELD) == 'Internal');
                this.objConfiguration.fields.importance.fieldValue=(objUtilities.isNotNull(getFieldValue(data, IMPORTANCE_FIELD)) && getFieldValue(data, IMPORTANCE_FIELD))=='High'?true:false;
                this.setButtonProperties();
                this.boolDisplaySpinner = false;
            }
        }
    }

    @wire(getRecord, { recordId: '$strParentCommentId', fields })
    wiredParentCommentRecord(objResponse) {
        this.boolDisplaySpinner = true;
        this.objParentCommentRecord = objResponse;
        if (objResponse.error) {
            //Process Error
        } else if (objResponse.data) {
            if(this.strParentCommentId){ 
                let commentType=getFieldValue(objResponse.data, TYPE_FIELD);
                let commentSubType=getFieldValue(objResponse.data, SUB_TYPE_FIELD);
                if(objUtilities.isNotNull(commentType) && commentType=='JIRA') {
                    this.boolPostJiraComment=true;
                }
                else if(objUtilities.isNotNull(commentType) && commentType=='Cassini' && objUtilities.isNotNull(commentSubType) && commentSubType == 'Auto Pilot'){
                    this.boolIsCassiniParent = true;
                }
                else{
                    this.boolPostJiraComment = false;
                }
                this.boolDisplaySpinner = false;
            }
        }
    }
    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback() {
		let objParent = this;
		this.boolDisplaySpinner = true;
        this.isSchedule=false;
        this.boolPostJiraComment = false;
        this.showFloatingActionModal=false;  
        this.boolPAFTemplate=false;
        this.boolInternalPlan = false;
        this.setButtonProperties();
        //set the internal category picklist from custom label values on create plan comment 
        if(objUtilities.isNotBlank(objParent.label.CSM_Plan_Comment_Category)){
            let lstCategoryOptions = new Array();
            objParent.label.CSM_Plan_Comment_Category.split(',').sort().forEach(objOption => {
                lstCategoryOptions.push( { label: objOption, value: objOption } );
            });
            objParent.objConfiguration.fields.internalCategory.options= lstCategoryOptions;
        }
		//Now we get the tagged users.
		if(objUtilities.isNotBlank(objParent.commentRecordId) || objUtilities.isNotBlank(objParent.alternateId)) {
			getTaggedUsers({
				strRecordId: objUtilities.isNotBlank(objParent.commentRecordId) ? objParent.commentRecordId : objParent.alternateId
			}).then(objResult => {
				
				//Now we set the users.
				if(objUtilities.isNotNull(objResult.Tagged_User_1__r)) {
					objParent.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: objResult.Tagged_User_1__r.Name,
						value: objResult.Tagged_User_1__r.Id
					});
					objParent.strTaggedUser1 = objResult.Tagged_User_1__r.Id;
				}
				if(objUtilities.isNotNull(objResult.Tagged_User_2__r)) {
					objParent.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: objResult.Tagged_User_2__r.Name,
						value: objResult.Tagged_User_2__r.Id
					});
					objParent.strTaggedUser1 = objResult.Tagged_User_2__r.Id;
				}
				if(objUtilities.isNotNull(objResult.Tagged_User_3__r)) {
					objParent.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: objResult.Tagged_User_3__r.Name,
						value: objResult.Tagged_User_3__r.Id
					});
					objParent.strTaggedUser1 = objResult.Tagged_User_3__r.Id;
				}
				if(objUtilities.isNotNull(objResult.Tagged_User_4__r)) {
					objParent.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: objResult.Tagged_User_4__r.Name,
						value: objResult.Tagged_User_4__r.Id
					});
					objParent.strTaggedUser1 = objResult.Tagged_User_4__r.Id;
				}
				if(objUtilities.isNotNull(objResult.Tagged_User_5__r)) {
					objParent.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: objResult.Tagged_User_5__r.Name,
						value: objResult.Tagged_User_5__r.Id
					});
					objParent.strTaggedUser1 = objResult.Tagged_User_5__r.Id;
				}
            }).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				objParent.boolDisplayMultiSelectLookup = true;
			});
		} else {
			objParent.boolDisplayMultiSelectLookup = true;
		}
	}

      /*
	 Method Name : deleteFile
	 Description : This wire method get files and update pill
     Parameters	 : None
	 Return Type : None
	 */
    @wire(getDocuments, {
    linkedEntityId: '$recordId',
       parentId: '$parentFileId',
       isId: '$isId'
     })
     getDocumentDetails(result) {

        this.wiredDocuments = result;
        if (result.error) {
        } else if (result.data) {
           this.contentDocumentLinkList = result.data;
           let attachArray = [];           
           this.contentDocumentLinkList.forEach(att => {
              this[NavigationMixin.GenerateUrl]({
                 type: 'standard__namedPage',
                 attributes: {
                    pageName: 'filePreview'
                 },
                 state: {
                    selectedRecordId: att.ContentDocumentId
                 }
              }).then(url => {
                attachArray.push({
                    type: 'icon',
                    label: att.ContentDocument.Title + '.' + att.ContentDocument.FileExtension,
                    name: att.ContentDocumentId,
                    iconName: 'doctype:' + att.ContentDocument.FileExtension,
                    alternativeText: att.ContentDocument.Title,
                    href: url
                 });
              });
           });
           this.attachments = attachArray;
           this.boolDisplaySpinner=false;
        }
     }
       /*
	 Method Name : deleteFile
	 Description : This wire method delete field and refresh pill
	 Parameters	 : None
	 Return Type : None
	 */
     deleteFile(event) {
         let objParent = this;
         objParent.boolDisplaySpinner = true;
        deleteRecord(event.detail.item.name).then(() => {
           const index = this.uploadedFilesIdList.indexOf(event.detail.item.name);
           if (index > -1) {
              this.uploadedFilesIdList.splice(index, 1);
           }
            //Show success toast to user
            objUtilities.showToast(objParent.label.Success,'File removed successfully!','success',objParent);          
           refreshApex(this.wiredDocuments);
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        });
     }


     /*
	 Method Name : tagFilestoComments
	 Description : This method create contentlink to comemnt created if uploaded a file
	 Parameters	 : Object, called from tagFilestoComments, objRequest Request.
	 Return Type : None
	 */
    tagFilestoComments(objRequest){
        let objParent = this;   
        objParent.boolDisplaySpinner=true;  
        //get plan comment on success
        tagFilestoComments({ strPlanId: objParent.recordId,        
            strCommentId: objParent.commentRecordId,
            fileIdList:objParent.uploadedFilesIdList
        })
        .then((result) => {  
            objParent.publishAndCloseModal();
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;

			//We send the sendgrid email.
			objParent.sendSendGridEmail(objRequest);
        });
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;        
        this.uploadedFilesIdList = [...this.uploadedFilesIdList, ...uploadedFiles.map(a => a.documentId)];
        this.boolDisplaySpinner=true;
        refreshApex(this.wiredDocuments);
    }
    /*
	 Method Name : handleLoad
	 Description : This method gets executed on load of record-edit-form.
	 Parameters	 : None
	 Return Type : None
	 */
    handleLoad(){
        this.boolDisplaySpinner=false;
    }
    /*
	 Method Name : setButtonProperties
	 Description : This method will set the button properties of HTML.
	 Parameters	 : None
	 Return Type : None
	 */
    setButtonProperties(){
        let objParent = this;
        this.boolDisplaySpinner = true;
        //Set button visibility properties
        objParent.objConfiguration.lstButtons.forEach(objButton => {
            if(objButton.keyValue=="3") {
                objButton.showButton = ( objParent.objConfiguration.fields.visibility.fieldValue == 'Internal' ||
                                         objParent.objConfiguration.fields.visibility.fieldValue == 'External'
                                        );
            }
            if(objButton.keyValue=="4") {
                objButton.showButton = (objParent.objConfiguration.fields.visibility.fieldValue == 'Private' ||                     
                                        objParent.objConfiguration.fields.visibility.fieldValue == 'External');
                var buttonScheduleLabel=(objParent.objConfiguration.fields.visibility.fieldValue == 'Private') ? 'Remind Me' : 'Schedule';
                objButton.label = buttonScheduleLabel;
                objButton.title = buttonScheduleLabel;
            }
            if(objButton.keyValue=="5") {
                objButton.showButton = objUtilities.isNotNull(objParent.objConfiguration.fields.visibility.fieldValue);
            }
            //Hide Send Meetings and Share availability for internal comment
            if( objParent.objConfiguration.fields.visibility.fieldValue !== 'External' && (objButton.keyValue=="1" || objButton.keyValue=="2")){
                objButton.showButton = false;
            }else{
                objButton.showButton = true;
            }
        });
        this.boolDisplaySpinner=false;
    }

    /*
	 Method Name : handleChange
	 Description : This method gets executed on change.
	 Parameters	 : None
	 Return Type : None
	 */
    handleChange(objEvent) {   
        let objParent = this;   
        switch (objEvent.currentTarget.name) {
            case 'plancomment':
                objParent.objConfiguration.fields.comment.fieldValue = objEvent.detail.value;
             break;
             case 'accessType':
                objParent.objConfiguration.fields.visibility.fieldValue = objEvent.detail.value;
                objParent.objConfiguration.fields.internalCategory.showField = (objEvent.detail.value == 'Internal');
                objParent.objConfiguration.fields.importance.showField = (objEvent.detail.value == 'External');
                //Toggle Red color background for external button
                if(objEvent.detail.value == 'External'){
                    objParent.toggleButtonColor(true);
                }else{
                    objParent.toggleButtonColor(false);
                }
                //Resetting the values to blank for edit form
                this.objConfiguration.fields.importance.fieldValue=false;
                this.objConfiguration.fields.internalCategory.fieldValue='';
                this.objConfiguration.fields.status.fieldValue='';
                this.objConfiguration.fields.type.fieldValue='';
                this.setButtonProperties();

				//Now we clear the user tagging.
				objParent.strTaggedUser1 = null;
				objParent.strTaggedUser2 = null;
				objParent.strTaggedUser3 = null;
				objParent.strTaggedUser4 = null;
				objParent.strTaggedUser5 = null;
                break;
            case 'scheduleTime':
                objParent.objConfiguration.fields.scheduledTime.fieldValue = objEvent.detail.value;
                break;
             default:
                break;
        }
    }

    /*
	 Method Name : handleScheuleClick
	 Description : This method gets executed on click.
	 Parameters	 : None
	 Return Type : None
	 */
     handleScheuleClick(objEvent){
        let objParent = this; 
        switch (objEvent.currentTarget.name) {
            case 'scheduleConfirm':
                objParent.buttonActionType='schedule';
                if(objUtilities.isNull(objParent.objConfiguration.fields.scheduledTime.fieldValue) || (new Date(objParent.objConfiguration.fields.scheduledTime.fieldValue) < this.todayDate)){  
                    objParent.isSchedule=true;    
                    objUtilities.showToast(objParent.label.Error,'Please select valid date','error',objParent);  
                }else{
                    objParent.isSchedule=false;
                    objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
                }
                break;  
            case 'cancelSchedule':
                this.isSchedule=false;
                break;
            default:
                break;
        }
     }

    /*
	 Method Name : handleClick
	 Description : This method gets executed on click.
	 Parameters	 : None
	 Return Type : None
	 */
    handleClick(objEvent){
        let objParent = this; 
        //Validate the internal category selected for internal comments
        let accesValue =objParent.objConfiguration.fields.visibility.fieldValue;
        let categoryValue =objParent.objConfiguration.fields.internalCategory.fieldValue;      
        let modcomment = objParent.objConfiguration.fields.comment.fieldValue.toString().replaceAll(/\s/g,'').replace( /(<([^>]+)>)/ig, ''); 
        let defaultval = CassiniDefaultReply.toString().replaceAll(/\s/g,'').replace( /(<([^>]+)>)/ig, ''); 
            switch (objEvent.currentTarget.name) {
                case 'submit':
                    objParent.buttonActionType='submit';
                    if(objUtilities.isBlank(objParent.objConfiguration.fields.comment.fieldValue)){
                        objUtilities.showToast(objParent.label.Error,'Please Enter Comment','error',objParent);
                    }else if(objUtilities.isNotBlank(modcomment) && this.boolIsCassiniParent && modcomment == defaultval){
                        objUtilities.showToast(objParent.label.Error,ClosingNotesError,'error',objParent);
                    }else if(objUtilities.isNotBlank(accesValue) && accesValue==="Internal" && objUtilities.isBlank(categoryValue) ){
                        objUtilities.showToast(objParent.label.Error,'Please select Category','error',objParent);
                    }else{
                        objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
                    }
                    break;
                case 'saveAsDraft':
                    objParent.buttonActionType='saveAsDraft';
                    if(objUtilities.isBlank(objParent.objConfiguration.fields.comment.fieldValue)){
                        objUtilities.showToast(objParent.label.Error,'Please Enter Comment','error',objParent);
                    }else if(objUtilities.isNotBlank(modcomment) && this.boolIsCassiniParent && modcomment == defaultval){
                        objUtilities.showToast(objParent.label.Error,ClosingNotesError,'error',objParent);
                    }else if(objUtilities.isNotBlank(accesValue) && accesValue==="Internal" && objUtilities.isBlank(categoryValue) ){
                        objUtilities.showToast(objParent.label.Error,'Please select Category','error',objParent);
                    }else{
                        objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
                    }
                    break;
                case 'schedule':                
                    if(objUtilities.isBlank(objParent.objConfiguration.fields.comment.fieldValue)){
                        objUtilities.showToast(objParent.label.Error,'Please Enter Comment','error',objParent);
                    }else if(objUtilities.isNotBlank(modcomment) && this.boolIsCassiniParent && modcomment == defaultval){
                        objUtilities.showToast(objParent.label.Error,ClosingNotesError,'error',objParent);
                    }else if(objUtilities.isNotBlank(accesValue) && accesValue==="Internal" && objUtilities.isBlank(categoryValue) ){
                        objUtilities.showToast(objParent.label.Error,'Please select Category','error',objParent);
                    }else{
                        objParent.isSchedule=true;
                        objParent.showFloatingActionModal = false;
                    }
                    //objParent.template.querySelector('[data-name="recordFormSubmitButton"]').click();
                break;

                case 'fab-click':
                    objParent.emailTemplateList=[];
                    objParent.fetchEmailTemplates();                
                break;

            

                case 'cancelQuickModal':
                    objParent.showFloatingActionModal = false;
                break;
                
                case 'saveQuickModal':
                    let selectedTemplates = [];
                    selectedTemplates = this.emailTemplateList.filter(objEmail => objEmail.isSelected);
                    if (selectedTemplates && selectedTemplates.length > 0) {
                        objParent.getProcessedEmailTemplateBody();
                    }else {
                        objUtilities.showToast(objParent.label.Error,'Please select a template!','error',this);
                    }
                break;

            
                //Schedule buttons.
                case 'insert_meeting':
                    objParent.getEventCreated();
                break;
                case 'insert_availability':
                    objParent.getScheduleShared();
                break;
                
            }
        
    }

    /*  
	 Method Name : handleSubmit
	 Description : This method gets executed on submmit of record-edit-form.
	 Parameters	 : None
	 Return Type : None
	 */
    handleSubmit(event){   
        let objParent = this;        
        let formFields = objParent.objConfiguration.fields;
        let strStatus='';         
        objParent.boolDisplaySpinner = true;

        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        //Set the field values that are captured
        fields.Comment__c   = formFields.comment.fieldValue;
        fields.Visibility__c = formFields.visibility.fieldValue;
        if(objParent.buttonActionType =='submit'){
            strStatus='Submitted';
        }
        if(objParent.buttonActionType =='saveAsDraft'){
            strStatus='Draft';
        }
        if(objParent.buttonActionType =='schedule'){
            strStatus='Scheduled';
        }
        fields.Status__c = strStatus;
        fields.Plan__c = objParent.recordId;
        fields.Type__c = objParent.objConfiguration.fields.visibility.fieldValue;
        if(objUtilities.isNotNull(objParent.strParentCommentId)){
            fields.Parent_Comment__c = objParent.strParentCommentId;
        }
        if(objUtilities.isNotNull(objParent.objConfiguration.fields.scheduledTime.fieldValue)){
            fields.Date_Time_Scheduled__c = objParent.objConfiguration.fields.scheduledTime.fieldValue;
        }
        if(this.objConfiguration.fields.importance.fieldValue==true){
            fields.Importance__c='High';
        }else{
            fields.Importance__c='Low';
        }
        fields.Sub_Type__c=objParent.objConfiguration.fields.internalCategory.fieldValue;
		fields.Request_Sign_Off__c = objParent.boolRequestSignOff;
        //submit the form
        let formObj=this.template.querySelector('lightning-record-edit-form');
        if(objUtilities.isNotNull(formObj)){
            formObj.submit(fields);
        }
     }

    /*
	 Method Name : handleError
	 Description : This method gets executed on error of record-edit-form.
	 Parameters	 : None
	 Return Type : None
	 */
    handleError() {
        this.boolDisplaySpinner = false;
    }
    handleCheckboxChange(event){
        this.objConfiguration.fields.importance.fieldValue=event.target.checked
    }
    handleCategoryChange(event) {        
        this.boolPAFTemplate=false;
        let categoryValue = event.detail.value
        this.objConfiguration.fields.internalCategory.fieldValue = event.detail.value;
        if(objUtilities.isNotBlank(categoryValue) && categoryValue==='Plan Health Reason'){
            this.boolPAFTemplate = true;
        }
    }
    /*
	 Method Name : handleSuccess
	 Description : This method gets executed on success of record-edit-form.
	 Parameters	 : None
	 Return Type : None
	 */
    handleSuccess(objEvent) {
        let objParent = this;
        let thisRecordId = objEvent.detail.id;
		let objRequest = {
			boolIsPriority: true,
			strPlanCommentId: thisRecordId,
			strUseCase: 'General Response'
		};

        if(objUtilities.isNotNull(thisRecordId)){
            refreshApex(this.objParentCommentRecord);
            objParent.commentRecordId = thisRecordId;
            if(objParent.boolPostJiraComment){
                objParent.postJiraComment(thisRecordId);
            }
            //Update objectives if the sign off request on behalf
            if(objUtilities.isNotNull(objParent.lstSelectedObjectives) && objParent.lstSelectedObjectives.length>0){
                objParent.updateSelectedObjectives();
            }
            if(objUtilities.isNotNull(objParent.uploadedFilesIdList) && objParent.uploadedFilesIdList.length>0){                
                objParent.tagFilestoComments(objRequest);
            }else{
                objParent.publishAndCloseModal();
            }     
            //Update Plan Health reason if PAF chicklet selected from quick text selected
            if(objParent.boolPAFTemplate===true){
                objParent.updatePlanHealthReason();  
            }    
            objParent.boolDisplaySpinner = false;

			//If the parent Plan Comment is and Inbound Attention Request, we close it.
			closeInboundAttentionRequestParent({
				strChildPlanCommentId: thisRecordId
			});
			
			//Finally, we send the email using SendGrid.
			if(!(objUtilities.isNotNull(objParent.uploadedFilesIdList) && objParent.uploadedFilesIdList.length>0)){
				objParent.sendSendGridEmail(objRequest);
			}
        }
    }

	/*
	 Method Name : sendSendGridEmail
	 Description : This method sends the SendGrid email.
	 Parameters	 : Object, called from sendSendGridEmail, objRequest Request.
	 Return Type : None
	 */
	sendSendGridEmail(objRequest) {
		setTimeout(function() {
			sendEmail(objRequest).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}, 10);
	}

    postJiraComment(thisRecordId){       
        let objParent = this;
        objParent.boolDisplaySpinner=true;        
         createJiraCommentFromPlanComment({strRecordId: thisRecordId})
        .then((objResponse) => {
            if(objUtilities.isNotNull(objResponse) && objResponse){
                 //Show success toast to user
                objUtilities.showToast(objParent.label.Success,'Posted Jira comment','success',objParent);
            }else{
                //Show success toast to user
                objUtilities.showToast(objParent.label.Error,'Failed to send comment to Jira','error',objParent); 
            }                           
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;
        }); 
    }
    /*
	 Method Name : publishAndCloseModal
	 Description : This methodwill publish Communication channel and dispatch close custom event
	 Parameters	 : None
	 Return Type : None
	 */
    publishAndCloseModal(){
        let objParent = this;
        if(!objParent.isEditForm){
            const payload = { recordId: objParent.recordId,
                commentType:objParent.objConfiguration.fields.visibility.fieldValue,
                commentSubType:objParent.objConfiguration.fields.internalCategory.fieldValue,
                channelOrigin:'CreateComment'                    
            };
            publish(objParent.messageContext, PLAN_COMMS, payload);
        }
        //Now we send the event.
        objParent.dispatchEvent(new CustomEvent('close', {
            detail: {
                boolShowEditForm: false
            }
        }));  
    }

    subscribeToMessageChannel() {       
        if(!this.subscription){
        this.subscription = subscribe(
            this.messageContext,
            PLAN_COMMS,
            ( message ) => {
                this.handleMessage( message );
            });
        }     
    }
   
    fetchEmailTemplates(){
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        //Now we get the email templates.
        getEmailTemplates({
                strPlanId: this.recordId
		}).then((response) => {
            this.quickActionConfiguration = response;
            if (objUtilities.isNotNull(response) && 
                objUtilities.isNotNull(response.emailTemplateList) &&
                response.emailTemplateList.length>0) {  
                    objParent.showFloatingActionButton= true; 
                  response.emailTemplateList.forEach(objEmailTemp => {
                    objParent.emailTemplateList.push(Object.assign({
                        isSelected: false
                     }, objEmailTemp));
                  }); 
                objParent.showFloatingActionModal = true;                  
            }
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
    }
    
     get floatingActions() {
        let objIcon = [];
        objIcon.push({
            title: 'Quick Text',
            name: 'quickText',
            iconName: 'utility:quick_text',
            className: 'icon-fill-white'
         });
         return objIcon;        
     }


     getProcessedEmailTemplateBody() {
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        fetchMergedQuickText({            
           templateName: objParent.emailTemplateList.filter(objEmail => objEmail.isSelected)[0].emailTemplateLabel,
           strPlanId: objParent.recordId, 
        }).then(resp => {
            objParent.showFloatingActionButton=false;
            objParent.showFloatingActionModal = false;
            objParent.objConfiguration.fields.comment.fieldValue=resp;
            objParent.objConfiguration.fields.visibility.fieldValue= (objParent.boolInternalPlan === true)?'Internal':'External';
            objParent.objConfiguration.fields.internalCategory.showField = (objParent.boolInternalPlan === true);
            objParent.objConfiguration.fields.importance.showField = (objParent.boolInternalPlan !== true);
            //Roll up the comment value to plan healht reason when paf template selected 
            if(objParent.emailTemplateList.filter(objEmail => objEmail.isSelected)[0].emailTemplateLabel === objParent.label.CSM_PAF_Health_Reason_Template){
                objParent.boolPAFTemplate=true;
                objParent.objConfiguration.fields.visibility.fieldValue='Internal';
                objParent.objConfiguration.fields.internalCategory.showField = true;
                objParent.objConfiguration.fields.importance.showField = false;
                objParent.objConfiguration.fields.internalCategory.fieldValue = 'Plan Health Reason';
            }else{
                objParent.boolPAFTemplate=false;
            }
        }).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
    
     }
   

     handleEmailTemplateClick(event) {
        let objParent = this;
        let objEmailTemplates = objParent.emailTemplateList;
        objParent.emailTemplateList=[]; 
         objEmailTemplates.forEach(objEmail => {
           if (objEmail.customMetadataName == event.currentTarget.dataset.recordid) {
                objEmail.isSelected = !objEmail.isSelected;
           } else {
                objEmail.isSelected = false; 
           }
        });
        objParent.emailTemplateList=objEmailTemplates;   
     }
    /*
    Method Name : updatePlanHealthReason
    Description : This method will update the comment text to plan when the paf chiclet selected from quick actions
    Parameters	 : None
    Return Type : None
    */  
    updatePlanHealthReason(){
        let objParent = this;
        objParent.boolDisplaySpinner=true;
        let formFields = objParent.objConfiguration.fields;
        let fields = {
            Id: this.recordId,
            Plan_Status_Reason__c: formFields.comment.fieldValue
        };
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {})
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
            objParent.boolPAFTemplate = false;
		});
    }
   
/*
Method Name : createPlanCommentRecord
Description : This method create plan comment record using LDS(This can be reused to create predraft comment)
Parameters	 : None
Return Type : None
*/  
  createPlanCommentRecord() {
    let objParent = this;
    this.boolDisplaySpinner = true;
    this.isEdit = false;
    // Creating mapping of fields of Plan_Comment__c with values    
    let fields = {
      Plan__c: this.recordId,
      Parent_Comment__c : objParent.strParentCommentId,
      Status__c:'Pre Draft',
      Type__c:'Private'
    };
    // Record details to pass to create method with api name of Object.
    let objRecordInput = { apiName: "Plan_Comment__c", fields };
    // LDS method to create record.
    createRecord(objRecordInput)
      .then((response) => {
        if (
          objUtilities.isNotNull(response) &&
          objUtilities.isNotNull(response.id)
        ) {
          this.commentRecordId = response.id;
        }        
      })
      .catch((objError) => {
        objUtilities.processException(objError, objParent);
      })
      .finally(() => {
        //Finally, we hide the spinner.
        objParent.boolDisplaySpinner = false;
      });
  }

  /*
	 Method Name : setSignOffParams
	 Description : This method sets a given values ofobjective Sign off parameters.
	 Parameters	 : String, called from setSignOffParams, strComment Comment.
                   String, called from setSignOffParams, strSignoffContact Contact.
                   String, called from setSignOffParams, lstSelectedObjectives list of Objectives.
	 Return Type : None
	 */
	@api
	setSignOffParams(strComment,strSignoffContact,lstSelectedObjectives) {
        let objParent = this;
		objParent.objConfiguration.fields.comment.fieldValue = strComment;
        //if(strSignoffContact!==undefined && strSignoffContact!=null){
            objParent.strSignoffContact=strSignoffContact;
            objParent.lstSelectedObjectives=lstSelectedObjectives;
            objParent.objConfiguration.fields.visibility.fieldValue = 'External';
            objParent.objConfiguration.fields.internalCategory.showField = false;
            objParent.objConfiguration.fields.importance.showField = true;
            //Toggle Red color background for external button        
            objParent.toggleButtonColor(true);
            
            //Resetting the values to blank for edit form
            objParent.objConfiguration.fields.importance.fieldValue=false;
            objParent.objConfiguration.fields.internalCategory.fieldValue='';
            objParent.objConfiguration.fields.status.fieldValue='';
            objParent.objConfiguration.fields.type.fieldValue='';
            objParent.setButtonProperties();

            //Now we clear the user tagging.
            objParent.strTaggedUser1 = null;
            objParent.strTaggedUser2 = null;
            objParent.strTaggedUser3 = null;
            objParent.strTaggedUser4 = null;
            objParent.strTaggedUser5 = null;
            
            //Now we set the sign off flag to true.
            objParent.boolRequestSignOff = true;
       // }
	}
    
    /*
    Method Name : updateSelectedObjectives
    Description : This method will update selected objevtives on sing off screen with sign off date on contact
    Parameters	: None
    Return Type : None
    */
    updateSelectedObjectives(){
        let objParent = this;
        objParent.boolDisplaySpinner = true;
        //Create plan comment on success
        updateSignoffObjectives({ 
            strContactId: objParent.strSignoffContact,
            lstSelectedObjectives : objParent.lstSelectedObjectives
        })
        .then((result) => {            
            //Show success toast to user
            objUtilities.showToast(objParent.label.Success,'Successfully Updated Objectives','success',objParent); 
        })
        .catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;            
        });
    }
     

	/*
	 Method Name : setComment
	 Description : This method sets a given string in the Comment field.
	 Parameters	 : String, called from setComment, strComment Comment.
	 Return Type : None
	 */
	@api
	setComment(strComment) {
		this.objConfiguration.fields.comment.fieldValue = strComment;
	}

	/*
	 Method Name : getScheduleShared
	 Description : This method opens the Scheduler and gets it ready to return the shared schedule.
	 Parameters	 : Object, called from getScheduleShared, objComponent Component reference.
	 Return Type : None
	 */
	getScheduleShared() {
		this.boolOpenScheduler = true;
		this.boolIsSendSchedule = true;
		this.boolIsCreateInvite = false;
	}

	/*
	 Method Name : getEventCreated
	 Description : This method opens the Scheduler and gets it ready to return the created event.
	 Parameters	 : Object, called from getEventCreated, objComponent Component reference.
	 Return Type : None
	 */
	getEventCreated() {
		this.boolOpenScheduler = true;
		this.boolIsSendSchedule = false;
		this.boolIsCreateInvite = true;
	}

	/*
	 Method Name : closeModal
	 Description : This method closes the Scheduler modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeModal() {
		this.boolOpenScheduler = false;
	}

	/*
	 Method Name : populateCommentField
	 Description : This method populates the Comment field, based on the data received from the Scheduler.
	 Parameters	 : Object, called from getEventCreated, objEvent Event reference.
	 Return Type : None
	 */
	populateCommentField(objEvent) {
		const { strHTMLBody } = objEvent.detail;
		this.boolOpenScheduler = false;
		this.objConfiguration.fields.comment.fieldValue = strHTMLBody;
	}

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
		this.template.querySelectorAll(".schedulerModal").forEach(objElement => {
			if(objElement.classList.contains("slds-modal__container")) {
				if(objEvent.detail.boolIsPopingOut) {
					objElement.classList.add("fullyExpanded-container");
				} else {
					objElement.classList.remove("fullyExpanded-container");
				}
			} else if(objElement.classList.contains("slds-modal__content")) {
				if(objEvent.detail.boolIsPopingOut) {
					objElement.classList.add("fullyExpanded-content");
				} else {
					objElement.classList.remove("fullyExpanded-content");
				}
			}
		});
    }

	/*
	 Method Name : tagSelectionChanged
	 Description : This method receives the latest selected users to be tagged.
	 Parameters	 : Object, called from tagSelectionChanged, objEvent Event reference.
	 Return Type : None
	 */
	tagSelectionChanged(objEvent) {
		let objParent = this;

		//First we remove the current values.
		objParent.strTaggedUser1 = null;
		objParent.strTaggedUser2 = null;
		objParent.strTaggedUser3 = null;
		objParent.strTaggedUser4 = null;
		objParent.strTaggedUser5 = null;

		//Now we fill the fields.
		if(objUtilities.isNotNull(objEvent.detail.lstSelectedItems)) {
			objEvent.detail.lstSelectedItems.forEach(objUser => {
				if(objUtilities.isNull(objParent.strTaggedUser1)) {
					objParent.strTaggedUser1 = objUser.value;
				} else if(objUtilities.isNull(objParent.strTaggedUser2)) {
					objParent.strTaggedUser2 = objUser.value;
				} else if(objUtilities.isNull(objParent.strTaggedUser3)) {
					objParent.strTaggedUser3 = objUser.value;
				} else if(objUtilities.isNull(objParent.strTaggedUser4)) {
					objParent.strTaggedUser4 = objUser.value;
				} else if(objUtilities.isNull(objParent.strTaggedUser5)) {
					objParent.strTaggedUser5 = objUser.value;
				}
			});
		}
	}

   /*
	 Method Name : toggleButtonColor
	 Description : This method called on change and update the css properties of external button, since we can't diretly apply css properties to Radio button
	 Parameters	 : boolAddExternalCss,boolean variable passed when external button selected
	 Return Type : None
	 */
    toggleButtonColor(boolAddExternalCss){
        let strStyle = "";
		let objParent = this;
        //We apply custom styling.		
        objParent.template.querySelectorAll('.customExternalRadioButtonCSS').forEach(objElement => {
            strStyle += "c-csm-plan-communication-edit-form lightning-radio-group.visibilityClass .slds-radio_button [type=radio]:checked+.slds-radio_button__label{"+
            "  background-color: red;"+
            "  color: white;"+
            "}";
            if(boolAddExternalCss) {
                objElement.innerHTML = "<style> " + strStyle + " </style>";
            }else{
                //Remove CSS when Radio button changed
                strStyle="";
                objElement.innerHTML = "<style> " +strStyle+ " </style>";
            }
        });
    }
}