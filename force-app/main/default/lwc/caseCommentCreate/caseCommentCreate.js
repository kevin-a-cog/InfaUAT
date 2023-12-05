/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                           NA
 Amarender              29-Nov-2021     I2RT-4782           Pre Draft - typed Comments disappear from draft section    T01
                                                            when the component is popped out and popped in           
 Amarender              06-Dec-2021     I2RT-5112           Cannot post External case comments - Also I don't see      T02
                                                            ' Customer' option under Next Action
 Amit                   01-Feb-2022     I2RT-5202           When user changes font for any selected item, cursor       T03
                                                            moves to the home
 Amit                   03-Feb-2022     I2RT-5329           Allow user to choose Customer in case of INternal          T04
                                                            comments as well
 Vignesh Divakaran      22-Mar-2022     I2RT-5608           Populate Scheduled Case Next Action for scheduled          T05
                                                            Case Comment
 balajip                05-Apr-2022     I2RT-5459           Added feature to tag users in a Case Comment               T06
 Amit Garg              27-Apr-2022     I2RT-5999           To make sure quick text templates works perfectly          T07
 balajip                29-Apr-2022     I2RT-6141           Fixed the bug                                              T08
 Vignesh Divakaran      02-May-2022     I2RT-6120           Refactoring to refer TimeZoneSIDKey on timezone object     T09
 Vignesh Divakaran      02-May-2022     I2RT-6016           Display appended eOGR text back in UI                      T10

 Amit Garg              31-May-2022     I2RT-6100           Fixing the Bug                                             T11
 Amit Garg              31-May-2022     I2RT-6267           Need changes in the case communication box in case         T12
                                           
 Amit Garg              05-Oct-2022     I2RT-7207           make sure commnication box be blank after submit           T13
 balajip                21-Nov-2022     I2RT-7508           to pass the Case Id in the message                         T14   
 Isha Bansal            01-Jan-2023     I2RT-7491           Display banner for Jira Login on the Jire related replies  T15                                                                     
 Isha Bansal            02-Jan-2023     I2RT-7609           Mark case category default to blank and mandatory          T16
                                                           except for NBA T14   
Isha Bansal             09-March-2023   I2RT-7610         converting to external comment from Intrnal comment should remove the tagged users T17  
Shashikanth             23-Aug-2023     I2RT-8627           The attachments are persisted in the case after submit     T18
 Vignesh Divakaran      02-Nov-2023     I2RT-9265           Refresh quick text email template wired data               T19
*/

import {api,LightningElement,track,wire} from 'lwc';
import {deleteRecord,getRecord,getRecordNotifyChange} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getPicklistValues,getObjectInfo} from 'lightning/uiObjectInfoApi';
import CASE from '@salesforce/schema/Case';
import CASE_COMMENT_OBJECT from '@salesforce/schema/Case_Comment__c';
import CASE_COMMENT_CATEGORY from '@salesforce/schema/Case_Comment__c.Comment_Category__c';
import CASE_COMMENT_IMPORTANCE from '@salesforce/schema/Case_Comment__c.Importance__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_TIMEZONE from '@salesforce/schema/Case.Case_Timezone__r.Name'; //
import CASE_TIMEZONE_SIDKEY from '@salesforce/schema/Case.Case_Timezone__r.TimeZoneSidKey__c'; // <T09>
import EOGR_IN_MINS from '@salesforce/schema/Case.eOGR_in_Mins__c';
import NEXT_ACTION from '@salesforce/schema/Case.Next_Action__c';
import SCHEDULED_CASE_NEXT_ACTION from '@salesforce/schema/Case_Comment__c.Scheduled_Case_Next_Action__c'; // <T05>
import INTERNAL_CASE from '@salesforce/schema/Case.Is_Internal_Or_External_Case__c';
import OWNERID from '@salesforce/schema/Case.OwnerId';

import loggedinId from '@salesforce/user/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import global_styles from '@salesforce/resourceUrl/gcsSrc';
import jirabannermsg from '@salesforce/label/c.Jira_Sign_in_Banner'; // <T15>
import saveComment from '@salesforce/apex/CaseCommentController.saveComment';
import getQuickActionConfiguration from '@salesforce/apex/CaseCommentController.getQuickActionConfiguration';
import getDocuments from '@salesforce/apex/CaseCommentController.getDocuments';
import fetchMergedQuickText from '@salesforce/apex/CaseCommentController.fetchMergedQuickText';
import calculateeOGRinMins from '@salesforce/apex/CaseController.calculateeOGRinMins';
import updateNextAction from '@salesforce/apex/CaseController.updateNextAction';
import updateeOGR from '@salesforce/apex/CaseController.updateeOGR';
import seteOGRVisibility from '@salesforce/apex/CaseController.seteOGRVisibility';
import {refreshApex} from '@salesforce/apex';
 import {NavigationMixin} from 'lightning/navigation';
 import {publish,MessageContext} from 'lightning/messageService'
 import CASE_COMM_MC from "@salesforce/messageChannel/CaseCommunicationMessageChannel__c";
 import usrTimeZoneSidKey from "@salesforce/i18n/timeZone";

 //Custom Labels.
import refreshTimout from '@salesforce/label/c.refreshTimout'; 
import Insert_Meeting from '@salesforce/label/c.Insert_Meeting'; 
import Insert_Availability from '@salesforce/label/c.Insert_Availability';

//Utilities.   
import { objUtilities } from 'c/globalUtilities';
 
 const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search
 
 //@Akhilesh Updated search delay as suggested by Mahesh Patil 2 Oct 2021 moved to custom label as 20000
 const SEARCH_DELAY = refreshTimout; //500; // Wait 500 ms after user stops typing then, peform search

 const fields = [CASE_STATUS, CASE_TIMEZONE,CASE_TIMEZONE_SIDKEY, EOGR_IN_MINS,NEXT_ACTION, INTERNAL_CASE,OWNERID]; // <T09>
 
 export default class CaseCommentCreate extends NavigationMixin(LightningElement) {
    @api
    recordId;
    @api
    popout;
    @api
    isEdit = false;

    @api isZIssueLinked=false; // I2RT-7491
    jiraurl=''; // I2RT-7491
    @api parentCommentId;
    @track currentStatus;
    @track currentCaseTimezone;
    @track eOGRVisible = false;
    @track eOGROptions = [];
    @track iseOgrSelected = false;
    @track showeOGRDropdown = false;
    @track eOGRActions = [];
    @track commentCategories = [];
    @track showDatePickerForeOGR = false;
    @track selectedeOGRAction;
    @track selectedeCommentCategory;
    @track eOGRDateTime;
    @track eOGRInMins;
    @track eOGRfromCase;
    //@track jiraupdatecheckbox = false;
    @track disableResetButton = false;
    @track eOGRText;
    @track orginalCommentValue;
    @track showwarningtime = false;
    //  @track nottype = ['Customer Action','Information Only','Extend OGR']; 
    @track nottype = '';
    @track isinternal = false;
    
    @track lstNextAction = [];
    @track lstNextActionPkValues = [];    //<T01>
    @track selectedNextAction = '';
    @track uploadedAttachments = false;
    @track commentBody; //<T03>
    strCaseTimezoneSidKey = ''; // <T09>
    @api
    get commentRecord() {
       return this._preDraftCaseComment;
    }

    @api hideZissueReplyVal;

	 //Private variables.
	 boolOpenScheduler = false;
	 boolIsSendSchedule = false;
	 boolIsCreateInvite = false;
    commentCheckChange =false;//<T11>
    //T06
    boolDisplayMultiSelectLookup = true;
	 @track objMultiSelectLookupRequest = {
		 intMaximumNumberOfSelectedResults: 5,
		 intLimitResults: 10,
       strLabel: "Tag users",
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

	 //Labels.
	 label = {
		 Insert_Meeting,
		 Insert_Availability,
       jirabannermsg

	 };
    
    set commentRecord(value) {
       try{       //<T01>
         if (value) {
            this._preDraftCaseComment = value;
            delete this.caseCommentObj['apiName'];
            this.caseCommentObj.fields.Id = value.Id;            
            //Deva : Start : I2RT-2630 :  removing the styles passed along with comment, to make consistant across screen
            if(value.Comment__c != '' && value.Comment__c != null && value.Comment__c != undefined){
              //<T11>
              this.caseCommentObj.fields.Comment__c = value.Comment__c;//.replace(/style=\"[^\"]*\"/gm,'');
              this.commentBody = value.Comment__c;
              //<T11>
            }
            //To map the eOGRDateTime from exisitng record
            if(value.Extend_OGR_By__c){
              this.eOGRDateTime=value.Extend_OGR_By__c;
            }
              //Deva : End : I2RT-2630 :
            //this.orginalCommentValue=value.Comment__c;
            this.caseCommentObj.fields.Status__c = value.Status__c;
            this.caseCommentObj.fields.Visibility__c = value.Visibility__c;         
            this.caseCommentObj.fields.Type__c = value.Type__c;
            console.log(JSON.stringify(value));
            console.log('@Log=> value.Visibility__c :' + value.Visibility__c);
            console.log('@Log=> value.Comment_Category__c :' + value.Comment_Category__c);
          
          if (value.Visibility__c == 'Internal'){
              this.notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype));
              this.notificationtype = this.notificationtype.filter(item => item.value !== 'Engineer OGR');                
          }
          else if (value.Visibility__c == 'External'){
              this.notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype));
              
          }
          if (value.Visibility__c == 'Internal' || value.Visibility__c == 'External') {
               if (this.isNextBestActionType(value.Type__c)  &&(value.Comment_Category__c == '' || value.Comment_Category__c == undefined)) { //I2RT-7609 - added condition for type 
                  this.selectedeCommentCategory = 'General Comments'; //I2RT-7609||
               } else if( value.Status__c==='Pre Draft' || value.Status__c==='Draft' || (this.isNextBestActionType(value.Type__c) && value.Status__c!=='Submitted' && value.Status__c!=='Scheduled' && value.Comment_Category__c != '' &&  value.Comment_Category__c != undefined)){
                  this.selectedeCommentCategory =value.Comment_Category__c; //I2RT-7609                  
               }else{
                  this.selectedeCommentCategory = '';  //I2RT-7609
               }
               this.caseCommentObj.fields.Comment_Category__c = this.selectedeCommentCategory;
               // <T01>
               if(value.Next_Action__c == null || value.Next_Action__c == '' || value.Next_Action__c == undefined){
                 this.selectedNextAction = 'Case Owner';
               }else{
                 this.selectedNextAction = value.Next_Action__c;
               }
               this.caseCommentObj.fields.Next_Action__c = this.selectedNextAction;
            } else {
               this.caseCommentObj.fields.Comment_Category__c = '';
               this.selectedeCommentCategory = '';
               this.caseCommentObj.fields.Next_Action__c = '';
               this.selectedNextAction = '';
            }
            // </T01>
            console.log('value.attachments :: commentRecord Setter ::  ' + JSON.stringify(value.attachments));
            if(value.attachments != undefined && value.attachments.length > 0 ){         
              this.attachments = JSON.parse(JSON.stringify(value.attachments));
              this.uploadedFilesIdList = JSON.parse(JSON.stringify(value.uploadedFilesIdList));
              this.caseCommentObj.fields.attachments = JSON.parse(JSON.stringify(value.attachments));
              this.caseCommentObj.fields.uploadedFilesIdList = JSON.parse(JSON.stringify(value.uploadedFilesIdList));
              this.uploadedAttachments = true;
            }
            // </T01>
            this.caseCommentObj.fields.Importance__c = value.Importance__c;
            this.caseCommentObj.fields.Date_Time_Scheduled__c = value.Date_Time_Scheduled__c;
            this.caseCommentObj.fields.Case__c = value.Case__c;
            this.sharingOptions.forEach(opt => {
               if (opt.value == value.Visibility__c) {
                  opt.variant = "brand";
               } else {
                  opt.variant = "";
               }
            });

            //T06
            console.log('@Log=> value.Tagged_User_1__c :' + value.Tagged_User_1__c);
            if(objUtilities.isNotNull(value.Tagged_User_1__r)) {
					this.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: value.Tagged_User_1__r.Name,
						value: value.Tagged_User_1__r.Id
					});
				}
				if(objUtilities.isNotNull(value.Tagged_User_2__r)) {
					this.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: value.Tagged_User_2__r.Name,
						value: value.Tagged_User_2__r.Id
					});
				}
				if(objUtilities.isNotNull(value.Tagged_User_3__r)) {
					this.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: value.Tagged_User_3__r.Name,
						value: value.Tagged_User_3__r.Id
					});
				}
				if(objUtilities.isNotNull(value.Tagged_User_4__r)) {
					this.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: value.Tagged_User_4__r.Name,
						value: value.Tagged_User_4__r.Id
					});
				}
				if(objUtilities.isNotNull(value.Tagged_User_5__r)) {
					this.objMultiSelectLookupRequest.lstPreloadedPills.push({
						label: value.Tagged_User_5__r.Name,
						value: value.Tagged_User_5__r.Id
					});
				}
         }
         //<T01>
       }catch(objError){          
          objUtilities.processException(objError, this);
       }
      //</T01>
    }
    
    get parentId() {
       return this.caseCommentObj.fields.Id ? this.caseCommentObj.fields.Id : this.recordId;
    }

    get visibility(){

        return this.caseCommentObj.fields.Visibility__c;
    }
    
    get isExternalAccess() {
      
       return this.caseCommentObj.fields.Visibility__c == 'External';
    }

    get isnotPrivate() {
      return (this.caseCommentObj.fields.Visibility__c == 'External' || this.caseCommentObj.fields.Visibility__c == 'Internal');
   }
    
    get isInternalAccess() {
       return this.caseCommentObj.fields.Visibility__c == 'Internal';
    }

   // <T02>
   get nextActionValues() {
      if(this.lstNextActionPkValues ){
         let visibility = this.caseCommentObj.fields.Visibility__c;
         let actions = [];
         if(visibility == 'Internal'){
            actions = this.lstNextActionPkValues.filter(function(option, index, arr){ 
               //if(option.value != 'Customer'){//<T04>
                     return option;
               //}//<T04>
            });
         }else if(visibility == 'External'){
            actions = this.lstNextActionPkValues;
         }
         this.lstNextAction = actions;
      };
      return this.lstNextAction;
   }
   // </T02>

    get isEOGRVisible(){
        console.log("@Log=> isEOGRVisible :")

        var showEOGRTip = false;

        this.notificationtype.forEach(opt => {    
            if (opt.value == 'Engineer OGR') {
                showEOGRTip = true;
            } 
         });
        console.log("@Log=> showEOGRTip :" + showEOGRTip)

         if(showEOGRTip == false){
            this.eOGRDateTime = null;
            this.eOGRVisible = false; 

            console.log('@Log=> this.nottype :' + this.nottype); 
            this.nottype = 'Customer Action';

            /*this.notificationtype.forEach(opt => {
                console.log("@Log=> opt.value :" + opt.value);
                if (opt.value == 'Customer Action') {
                   this.nottype = 'Customer Action'; 
                } 
             });*/
         }

         return showEOGRTip;
    }
    
    //@Akhilesh 21 Apr 2021 - start
    get isPrivateAccess() {
       return this.caseCommentObj.fields.Visibility__c == 'Private';
    }
    //@Akhilesh 21 Apr 2021 - end
    
    get btnschedule() {
       if (this.caseCommentObj.fields.Visibility__c == 'Private') {
          return 'Remind Me';
       } else {
          return 'Schedule';
       }
    }
    
    get isShowDraftButton() {
       return this.caseCommentObj.fields.Visibility__c != 'Private';
    }
    
    get isShowscheduleButton() {
       return this.caseCommentObj.fields.Visibility__c == 'Private' || this.caseCommentObj.fields.Visibility__c == 'External';
    }
    
    get showFloatingActionButton() {
       return this.floatingActions && this.floatingActions.length;
    }
    
    get showCaseUpdate() {
       return true;
    }
    
    get todayDate() {
       return new Date();
    }

    // <T01>
    /* get uploadedAttachments() {
       return this.attachments.length > 0;
    } */
    // </T01>

    get isId() {
       return this.caseCommentObj.fields.Id ? true : false;
    }
    
    get parentFileId() {
       return this.caseCommentObj.fields.Id ? this.caseCommentObj.fields.Id : this.uploadedFilesIdList.join(',');
    }
    
    get floatingActions() {
       let tmp = [];
       if (this.quickActionConfiguration && 
           this.quickActionConfiguration.data && 
           this.quickActionConfiguration.data.quickUpdateFieldList && 
           this.quickActionConfiguration.data.quickUpdateFieldList.length) {
          tmp.push({
             title: 'Quick Update',
             name: 'quickUpdate',
             iconName: 'utility:record_update',
             className: 'icon-fill-white'
          });
       }
       
       if (this.isQuickTextAvailable) {
          tmp.push({
             title: 'Quick Text',
             name: 'quickText',
             iconName: 'utility:quick_text',
             className: 'icon-fill-white'
          });
       }
       return tmp;
    }
    
    get modalHeader() {
       return this.isQuickUpdate ? 'Quick Update' : this.isQuickText ? 'Quick Text' : '';
    }
    
    get isQuickTextAvailable() {
       return this.quickActionConfiguration && 
              this.quickActionConfiguration.data && 
              this.quickActionConfiguration.data.emailTemplateList && 
              this.quickActionConfiguration.data.emailTemplateList.length;
    }
    
    get showFloatingActionModal() {
       return this.isQuickText || this.isQuickUpdate;
    }
    
    AllSharingOptions = [{
        label: 'Private',
        value: 'Private',
        class: 'private',
        variant: ''
     },
     {
        label: 'Internal',
        value: 'Internal',
        class: 'internal',
        variant: ''
     },
     {
        label: 'External',
        value: 'External',
        class: 'external',
        variant: ''
     }
  ];

    @track
    sharingOptions = JSON.parse(JSON.stringify(this.AllSharingOptions));
    
    /* @track
    notificationtype = [{ label: 'Information Only', value: 'Information Only', class: 'private', variant: '' },
    { label: 'Extend OGR', value: 'Extend OGR', class: 'internal', variant: '' },
    { label: 'Customer Action', value: 'Customer Action', class: 'external', variant: 'brand' }];
    */
    
    allNotificationtype = [{
          label: 'Engineer OGR',
          value: 'Engineer OGR',
          class: 'internal',
          variant: ''
       },
       {
          label: 'Customer Action',
          value: 'Customer Action',
          class: 'external',
          variant: 'brand'
       }
    ];

    @track
    notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype));
    
    @track
    notificeogrokationtype = [{
       label: 'Ok',
       value: 'Ok',
       class: 'private',
       variant: ''
    }];
    
    @track
    caseCommentObj = {
       apiName: "Case_Comment__c",
       fields: {
          Comment__c: '',
          Status__c: 'Pre Draft',
          Visibility__c: 'External',
          Type__c: '',
          Importance__c: false,
          Inbound__c: false,
          Is_eOGR_comment: false,
          Comment_Action_Type__c: 'Customer Action',
          Sub_Type__c: 'General Response',
          Comment_Category__c: '',           // </T01>
          Next_Action__c: '',           // </T01>
          attachments: [],                   // </T01>
          uploadedFilesIdList: []            // </T01>
       }
    };
    
    @wire(getRecord, {
       recordId: '$recordId',
       fields
    })
    CaseDetails({
       data,
       error
    }) {
       console.log('entry--> case details');
       if (data) {
          console.log('Data= ' + JSON.stringify(data));
          console.log("@Log=> data.fields.Is_Internal_Or_External_Case__c.value :" + data.fields.Is_Internal_Or_External_Case__c.value)
          //console.log("@Log=> loggedinId :" + loggedinId)
          //console.log("@Log=> data.fields.OwnerId.value :" + data.fields.OwnerId.value)
          //console.log("@Log=> this.caseCommentObj.fields.Visibility__c :" + this.caseCommentObj.fields.Visibility__c)

          this.currentStatus = data.fields.Status.value;
         //  this.selectedNextAction = data.fields.Next_Action__c.value;
          //
          if (data.fields.Case_Timezone__r.value != null && data.fields.Case_Timezone__r.value != undefined) {
             this.currentCaseTimezone = data.fields.Case_Timezone__r.value.fields.Name.value;
          }
          this.strCaseTimezoneSidKey = data?.fields?.Case_Timezone__r?.value?.fields?.TimeZoneSidKey__c?.value; // <T09>
          let eogrInMins = data.fields.eOGR_in_Mins__c.value;          
          console.log('eOGRActions-->' + JSON.stringify(this.eOGRActions));
          this.notificationtype.forEach(opt => {
             
             if (opt.value == 'Customer Action') {
                console.log('optvalue' + opt.value);
                this.nottype = 'Customer Action';
                opt.variant = "brand";
             } else {
                opt.variant = "";
             }
          });

          if(data.fields.Is_Internal_Or_External_Case__c.value == 'Internal'){
            this.isinternal = true;
            console.log('interncase:'+JSON.stringify(this.sharingOptions));
            //const index = this.sharingOptions.indexOf('External');
            //if (index > -1) {
               this.sharingOptions.splice(2, 1);
               console.log('removed external:');
               this.caseCommentObj.fields.Visibility__c = 'Internal';
            //}
          }
          this.seteOGRButtonVisibility();

          if(loggedinId != data.fields.OwnerId.value){
            console.log("@Log=> loggedinId :" + loggedinId)
            console.log("@Log=> data.fields.OwnerId.value :" + data.fields.OwnerId.value)
            console.log("@Log=> this.caseCommentObj.fields.Visibility__c :" + this.caseCommentObj.fields.Visibility__c)
            this.caseCommentObj.fields.Visibility__c = 'Internal';
          }


          // developer 
          //@Akhilesh 25 Sept 2021 -- start
          //if (this.caseCommentObj.fields.Visibility__c == 'Internal'){
          if (this.caseCommentObj.fields.Visibility__c == 'Internal' || this.caseCommentObj.fields.Visibility__c == 'External') {
            if (this.caseCommentObj.fields.Comment_Category__c == ''  || this.caseCommentObj.fields.Comment_Category__c == undefined) {
              // this.selectedeCommentCategory = 'General Comments'; //I2RT-7609
            } else {
              // this.selectedeCommentCategory = this.caseCommentObj.fields.Comment_Category__c; //I2RT-7609
            }
           // this.caseCommentObj.fields.Comment_Category__c = this.selectedeCommentCategory; //I2RT-7609
            // <T01>
            if(this.caseCommentObj.fields.Next_Action__c == '' && (this.selectedNextAction == '' || this.selectedNextAction == undefined)){
               this.selectedNextAction = 'Case Owner';
            }else if(this.caseCommentObj.fields.Next_Action__c == 'Customer' && this.caseCommentObj.fields.Visibility__c == 'Internal'){
               this.selectedNextAction = undefined;
            }else{
               this.selectedNextAction = this.caseCommentObj.fields.Next_Action__c;
             }
             this.caseCommentObj.fields.Next_Action__c = this.selectedNextAction;
             // </T01>
          }
          
          this.sharingOptions.forEach(opt => {
            if (opt.value == this.caseCommentObj.fields.Visibility__c) {
               opt.variant = "brand";
            } else {
               opt.variant = "";
            }
          });   

          if (this.caseCommentObj.fields.Visibility__c == 'Internal'){
            this.notificationtype = this.notificationtype.filter(item => item.value !== 'Engineer OGR');                
         }
         
         else if (this.caseCommentObj.fields.Visibility__c == 'External'){    
            this.notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype));
         }

          //@Akhilesh 25 Sept 2021 -- end
         //<T12> starts
          if(this.caseCommentObj.fields.Visibility__c == 'External'){
            this.toggleButtonColor(true);
          }else{
            this.toggleButtonColor(false);
          }
          //<T12> ends
         refreshApex(this.quickActionConfiguration); //<T19>
       } else if (error) {
          console.log('Error-->' + JSON.stringify(error));
       }
    }
    
    seteOGRButtonVisibility() {

       //query whether running ogr milestone is present for the case
       console.log('entry seteOGRButtonVisibility');
       seteOGRVisibility({
             caseId: this.recordId
          })
          .then(result => {
             if (result) {
                if (this.nottype == 'Engineer OGR') {
                   this.eOGRVisible = true;
                   // this.showeOGRDropdown=true;
                   this.selectedeOGRAction = 'Customer Action';
                } else {
                   this.eOGRVisible = false;
                }
             } else {
                this.eOGRVisible = false;
                this.allNotificationtype = this.allNotificationtype.filter(item => item.value !== 'Engineer OGR');
                this.notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype))
             }
          })
          .catch(error => {
             console.log('error entry-->' + JSON.stringify(error));
             objUtilities.processException(error, this);
          });
       
       /*   if(this.currentStatus == 'Research' ||this.currentStatus == 'Solution'){
              this.eOGRVisible=true;
          }else
          {
              this.eOGRVisible=false;
          }*/
    }
    
    @wire(getDocuments, {
       linkedEntityId: '$recordId',
       parentId: '$parentFileId',
       isId: '$isId'
    })
    getDocumentDetails(result) {
       this.wiredDocuments = result;
       if (result.error) {
          console.log('error>>', {
             ...result.error
          });
       } else if (result.data) {
          this.contentDocumentLinkList = result.data;
          let tmpArr = [];
          console.log('contentDocumentLinkList : ' + JSON.stringify(this.contentDocumentLinkList));
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
                tmpArr.push({
                   type: 'icon',
                   label: att.ContentDocument.Title + '.' + att.ContentDocument.FileExtension,
                   name: att.ContentDocumentId,
                   iconName: 'doctype:' + att.ContentDocument.FileExtension,
                   alternativeText: att.ContentDocument.Title,
                   href: url
                });
               
             });
          });
          console.log('tmpArr>>', tmpArr);
          // <T01>
          setTimeout(() => {
            let oldAttachments = JSON.parse(JSON.stringify(this.attachments));
            let newAttachments = JSON.parse(JSON.stringify(tmpArr));
            if(oldAttachments.length != newAttachments.length){
               this.attachments = tmpArr;
               this.caseCommentObj.fields.attachments = tmpArr;
               this.caseCommentObj.fields.uploadedFilesIdList = this.uploadedFilesIdList;
               this.uploadedAttachments = this.attachments.length >0;
               this.sendCaseCommentToParent();
               this.showSpinner = false;
            }
            
          }, 2000);
          // </T01>
       }
    }
    
    @wire(MessageContext)
    messageContext;
    
    attachments = [];
    _throttlingTimeout;
    _preDraftCaseComment;
    //importanceOptions = [];
    formats = ['font', 'size', 'bold', 'italic', 'underline',
       'strike', 'list', 'indent', 'align', 'link',
       'image', 'clean', 'table', 'header', 'color'
    ];
    showSpinner = false;
    isQuickText = false;
    isQuickUpdate = false;
    isSchedule = false;
    contentDocumentLinkList = [];
    wiredDocuments;
    uploadedFilesIdList = [];
    hasNext = false;
    quickActionConfiguration;
    eogrtimebutton = " ";
    @track emailTemplateList = [];
    mdt = '';
    
   

    @wire(getObjectInfo, {
        objectApiName: CASE
     }) caseObjectInfo;

    @wire(getObjectInfo, {
       objectApiName: CASE_COMMENT_OBJECT
    }) caseCommentObjectInfo;
    
    @wire(getPicklistValues, {
       recordTypeId: '$caseCommentObjectInfo.data.defaultRecordTypeId',
       fieldApiName: CASE_COMMENT_CATEGORY
    }) getCommentCategory({error,data}) {
       if (error) {
          console.log('error>>>', {
             ...error
          });
       } else if (data) {
          this.commentCategories = [...data.values];
         //  this.selectedeCommentCategory = 'General Comments';
          console.log('this.commentCategories' + ':' + JSON.stringify(this.commentCategories));
         
       }
    }
        
    @wire(getPicklistValues, {
        recordTypeId: "$caseObjectInfo.data.defaultRecordTypeId",
        fieldApiName: NEXT_ACTION
      }) 
      fetchNextActionPickList({ error, data }) {
        if (data) {
          console.log("fetchNextActionPickList.start=>");
         //<T01>
         this.lstNextAction = [...data.values];
         this.lstNextActionPkValues = [...data.values];
          // </T01>

          //this.selectedNextAction = 'Customer';
          console.log("fetchNextActionPickList.end=>");
        }
        else {
          console.log("@Log=>error:" + JSON.stringify(error));
        }
    }

    @wire(getQuickActionConfiguration, {
       caseId: '$recordId'
    })
    getQuickActionConfiguration(response) {
       this.quickActionConfiguration = response;
       console.log('quickActionConfiguration --> '+JSON.stringify(this.quickActionConfiguration));
       if (response.data) {
          let tmp = [];
          
          if (this.isQuickTextAvailable) {
             response.data.emailTemplateList.forEach(tmpl => {
                tmp.push(Object.assign({
                   isSelected: false
                }, tmpl));
             });
          }
          
          this.emailTemplateList = tmp;
          console.log('emailTemplateList --> '+JSON.stringify(this.emailTemplateList));
       }
    }

   renderedCallback() {
      Promise.all([
      loadStyle(this, global_styles + '/global.css'),
      ])
      .then(() => {
          console.log("CSS loaded.");
          
      })
      .catch(() => {
          console.log("CSS not loaded");
          
      });
  }
    
    connectedCallback() {
        console.log("@Log=>connectedCallback");
       let globalStyle = document.createElement('style');
       //-----------Venki to popout with more height----------
       if(this.popout != 'undefined' && this.popout == 'true'){
          console.log('popout');
         this.richtextheight = 'popoutclass'
       } else {
         console.log('popoutfalse');
         this.richtextheight = 'lwcrichtext';
       }
       //-----------------end-------------------------

       globalStyle.innerHTML = `
         .private svg {
             fill: #ffa500;
           }
 
           .private {
             color: #ffa500;
           }
           
           .internal svg {
               fill:#e6e600;
           }
 
           .internal {
             color:#e6e600;
         }
 
           .external svg {
             fill:#00EE00;
         }
 
         .external {
             color:#00EE00;
         }

         .slds-popover {
            left:30px;
         }

                                         `;
       document.head.appendChild(globalStyle);

       console.log('CaseCinnebtCreate -- hideZissueReplyVal --- > ' + this.hideZissueReplyVal);
       
       this.sharingOptions = JSON.parse(JSON.stringify(this.AllSharingOptions));
       if(this.hideZissueReplyVal == 'true'){
         this.sharingOptions.splice(2, 1);
         this.caseCommentObj.fields.Visibility__c = 'Internal';
       }
       //@Akhilesh 25 Sept 2021 -- start
       this.sharingOptions.forEach(opt => {
        if (opt.value == this.caseCommentObj.fields.Visibility__c) {
           opt.variant = "brand";
        } else {
           opt.variant = "";
        }
       });   
     //@Akhilesh 25 Sept 2021 -- end
    }
    
    handleNextActionChange(event) {
        console.log("@Log=>handleNextAction");
        this.selectedNextAction = event.detail.value;
        console.log('@Log=> this.selectedNextAction:' + this.selectedNextAction);
    }

    handleFabClick(event) {

       switch (event.detail) {
          case 'quickText':
             if (this.quickActionConfiguration.data.emailTemplateList.length > 1) {
                this.isQuickText = true;
             } else {
                //this.getProcessedEmailTemplateBody();
                this.isQuickText = true;
             }
             break;
             
          case 'quickUpdate':
             this.showSpinner = true;
             this.isQuickUpdate = true;
             break;
             
          default:
             break;
       }
    }
    
    getProcessedEmailTemplateBody(isMuiltiple = false) {
       this.mdt = isMuiltiple ? this.emailTemplateList.filter(tmpl => tmpl.isSelected)[0].customMetadataName : this.quickActionConfiguration.data.emailTemplateList[0].customMetadataName;
       fetchMergedQuickText({
          recordId: this.recordId,
          templateName: isMuiltiple ? this.emailTemplateList.filter(tmpl => tmpl.isSelected)[0].emailTemplateLabel : this.quickActionConfiguration.data.emailTemplateList[0].emailTemplateLabel
       }).then(resp => {
          console.log('resp>>', JSON.parse(JSON.stringify(resp)));
          this.caseCommentObj.fields.Comment__c = resp;
          this.commentBody = resp;//<T07>
          this.caseCommentObj.fields.Visibility__c = 'External';
          this.orginalCommentValue = resp;
          this.showSpinner = false;
          this.toggleButtonColor(true);//<T12>
          this.sendCaseCommentToParent();    // <T01>
       }).catch(err => {
          console.log('err>>', JSON.parse(JSON.stringify(err)));
          objUtilities.processException(err, this);
          this.showSpinner = false;
       })
    }
    //<T12> starts
   toggleButtonColor(boolAddExternalCss){
      let strStyle = "";
    let objParent = this;
      //We apply custom styling.		
      objParent.template.querySelectorAll('.customExternalRadioButtonCSS').forEach(objElement => {
          strStyle += "c-case-comment-create lightning-radio-group.visibilityClass .slds-radio_button [type=radio]:checked+.slds-radio_button__label{"+
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
   //<T12> ends
    handleChange(event) {
        console.log('@Log=> handleChange:' );
        console.log('@Log=> event.currentTarget.name:' + event.currentTarget.name);
        this.commentCheckChange =false;//<T11>
       switch (event.currentTarget.name) {
          case 'comment':
            this.commentCheckChange =true;//<T11>
             this.throttleUserInputIntoCommentBody(event.currentTarget.value);
             break;
             
          case 'accessType':
             this.caseCommentObj.fields.Visibility__c = event.currentTarget.value;
             //<T12> starts
             if(event.currentTarget.value == 'External'){
                  this.toggleButtonColor(true);
                  this.caseCommentObj.fields.Tagged_User_1__c = null;//T17
                  this.caseCommentObj.fields.Tagged_User_2__c = null;//T17
                  this.caseCommentObj.fields.Tagged_User_3__c = null;//T17
                  this.caseCommentObj.fields.Tagged_User_4__c = null;//T17
                  this.caseCommentObj.fields.Tagged_User_5__c = null;//T17
             }else{
                  this.toggleButtonColor(false);
             }//<T12> ends             
             if (this.caseCommentObj.fields.Visibility__c == 'Internal' || this.caseCommentObj.fields.Visibility__c == 'External') {
                //@Akhilesh 25 Sept 2021 -- start
                if(this.selectedeCommentCategory == '' || this.selectedeCommentCategory == undefined ){
                 /*   this.selectedeCommentCategory = 'General Comments';
                    this.caseCommentObj.fields.Comment_Category__c = this.selectedeCommentCategory;*/ //I2RT-7609
                }
                //@Akhilesh 25 Sept 2021 -- end
             } 

             //@Akhilesh 25 Sept 2021 -- start
             if (this.caseCommentObj.fields.Visibility__c == 'Internal'){
                this.nottype = 'Customer Action'
                this.notificationtype = this.notificationtype.filter(item => item.value !== 'Engineer OGR');  
             }
             else if (this.caseCommentObj.fields.Visibility__c == 'External'){
                this.notificationtype = JSON.parse(JSON.stringify(this.allNotificationtype));
             }

             //@Akhilesh 25 Sept 2021 -- end

             break;
             
          case 'importance':
             console.log('value >>', event.currentTarget.value);
             console.log('checked >>', event.currentTarget.checked);
             this.caseCommentObj.fields.Importance__c = event.currentTarget.checked;
             break;
             
             /*case 'jiraupdate':
                 console.log('value >>',event.currentTarget.value);
                 console.log('checked >>',event.currentTarget.checked);
                 this.caseCommentObj.fields.Type__c = 'JIRA Request';
                 this.jiraupdatecheckbox = true;
                 break;*/
             
          case 'eOGRRequired':
             console.log('eOGRRequired entry');
             this.iseOgrSelected = event.currentTarget.checked;
             this.caseCommentObj.fields.Is_eOGR_comment__c = event.currentTarget.checked;
             this.handleeOGRswitch();
             break;
          
          case 'notificationstype':
             console.log('eOGRRequired entry');
             //@Akhilesh 2 Oct 2021 --start
             this.nottype = event.currentTarget.value ;
             //@Akhilesh 2 Oct 2021 --end
             if (event.currentTarget.value == 'Engineer OGR') {
                this.iseOgrSelected = true;
                this.caseCommentObj.fields.Is_eOGR_comment__c = true;
                this.caseCommentObj.fields.Comment_Action_Type__c = 'Engineer OGR';
                this.showDatePickerForeOGR = true;
                this.eOGRVisible = true;
                this.handleeOGRswitch();
             } else if (event.currentTarget.value == 'Customer Action') {
                this.showDatePickerForeOGR = false;
                this.iseOgrSelected = false;
                this.caseCommentObj.fields.Sub_Type__c = 'General Response';
                this.caseCommentObj.fields.Comment_Action_Type__c = 'Customer Action';
                this.eOGRVisible = false;
             }
             /* else {
                                 this.showDatePickerForeOGR=false;
                                 this.caseCommentObj.fields.Sub_Type__c = 'Information Only';
                                 this.caseCommentObj.fields.Comment_Action_Type__c='Information Only';
                                 this.eOGRVisible = false;
                             }*/
             break;
             
          case 'eOGRActionCombobox':
             console.log('eOGRActionCombobox entry--' + event.currentTarget.value);
             this.selectedeOGRAction = event.currentTarget.value;
             if (event.currentTarget.value == 'InformationOnly') {
                this.showDatePickerForeOGR = true;
             } else {
                this.showDatePickerForeOGR = false;               
                this.saveeOGR();
             }
             
             break;
          case 'eOGRDateTimeField':
             console.log('eOGRDateTimeField entry--' + event.currentTarget.value);
             this.eOGRDateTime = event.currentTarget.value;
             var eOGRdt = new Date(this.eOGRDateTime);
             
             //@Akhilesh 13 Apr 2021 -- start [I2RT-1829]
             /*
             
             var hours = eOGRdt.getHours();
             console.log('hours'+hours);
             if(hours > 17 || hours < 8){
                 console.log('showwarningtime'+this.showwarningtime);
                 this.showwarningtime = true;
             } else {
                 this.showwarningtime = false;
             }
             */
             
             console.log('usrTimeZoneSidKey-->' + usrTimeZoneSidKey);
             var userDateTime = eOGRdt.toLocaleString('en-US', {
                timeZone: usrTimeZoneSidKey
             });
             console.log('userDateTime-->' + userDateTime);
             let lstUserDateTime = userDateTime.split(', ');
             let lstDetail = lstUserDateTime[1].split(' ');
             let lstTimeDetail = lstDetail[0].split(':');
             var hours = parseInt(lstTimeDetail[0]);
             console.log('hours->' + hours);
             console.log('AM/PM->' + lstDetail[1]);
             
             if (hours == 12 && lstDetail[1] == 'AM') {
                hours = 0;
             }
             
             if (hours != 12 && lstDetail[1] == 'PM') {
                hours += 12;
             }
             
             hours += parseFloat(lstTimeDetail[1]) / 60;
             console.log('updated hours->' + hours);

             this.showwarningtime = false;
             if (hours > 17.5 || hours < 9) {
                this.showwarningtime = true;
             } 

             //@Akhilesh 24 May 2021 -- start [I2RT-2589]
             let weekday = new Date(lstUserDateTime[0]).toLocaleString('en-us', {weekday:'long'});
             console.log('@Log=> weekday:' + weekday);
             if(weekday == 'Saturday' || weekday == 'Sunday'){
                this.showwarningtime = true;
             }
             //@Akhilesh 24 May 2021 -- end [I2RT-2589]
             
             //@Akhilesh 13 Apr 2021 -- end [I2RT-1829]
             
             //this.parseeOGRDateTime();
             
             this.saveeOGR();

             break;
          case 'commentCategory':
             this.caseCommentObj.fields.Comment_Category__c =  event.currentTarget.value; 
             this.selectedeCommentCategory =  event.currentTarget.value; //I2RT-7609
             break;
          case 'nextaction':
             this.selectedNextAction = event.currentTarget.value;
             this.caseCommentObj.fields.Next_Action__c =  event.currentTarget.value; 
             break;
          //T06
          case 'taggedUsers':
             this.tagSelectionChanged(event);
             break;
          default:
             break;
       }

       this.sendCaseCommentToParent();    // <T01>
    }

    // <T01>
    sendCaseCommentToParent(){
      // Creates the event with the caseCommentObj data.
      //<T11>
      if(this.commentCheckChange ==false){
         this.commentBody = this.caseCommentObj.fields.Comment__c;
      }//<T11>
      this.caseCommentObj.fields.Comment__c = this.commentBody;
      //console.log('sendCaseeCommentToParent.. caseCommentdata >> ', JSON.stringify(this.caseCommentObj.fields));
      let caseCommentdata = JSON.parse(JSON.stringify(this.caseCommentObj));
      //console.log('sendCaseeCommentToParent.. caseCommentdata >> ', JSON.stringify(caseCommentdata));
      const casecommentupdate = new CustomEvent('casecommentupdate', {detail : {'caseCommentdata' : caseCommentdata}});
      // Dispatches the event.
      this.dispatchEvent(casecommentupdate);
    }
    // </T01>
    
    handleeOGRswitch() {
       console.log('this.iseOgrSelected-->' + this.iseOgrSelected);
       if (this.iseOgrSelected == true) {
          this.selectedeOGRAction = 'InformationOnly';
          this.showDatePickerForeOGR = true;
          
       } else {
          console.log('this.iseOgrSelected  OFF');
          this.selectedeOGRAction = 'Customer Action';
          this.showDatePickerForeOGR = false;
          
       }
       
    }
    
    saveeOGR() {
        console.log('@Log=> saveeOGR:' +this.selectedeCommentCategory);
        this.caseCommentObj.fields.Comment_Category__c=this.selectedeCommentCategory?this.selectedeCommentCategory:null; //I2RT-7760
       console.log('saveeOGR Entry-->' + this.selectedeOGRAction);
       let rslt;
       var tz;
       
       calculateeOGRinMins({
             eOGRTime: this.eOGRDateTime,
             caseId: this.recordId
          })
          .then(result => {
             console.log('success entry-->' + JSON.stringify(result));
             // this.eOGRInMins=JSON.stringify(result);
             this.eOGRInMins = result;
             console.log('eogr in long-->' + this.eOGRInMins);
             rslt = result;
             console.log('Is update successful? ' + JSON.stringify(rslt));
             
          })
          .catch(error => {
             console.log('error entry');
             objUtilities.processException(error, this);
          });
       
       /*   const evt = new ShowToastEvent({
              title: 'Success!',
              message: 'OGR is extended  Successfully',
              variant: 'success',
              mode: 'dismissable'
          });
          this.dispatchEvent(evt);*/
       this.showeOGRDropdown = false;
       ///load the comment into comment window
       var eOGRdt = new Date(this.eOGRDateTime);
       console.log('dd -->' + eOGRdt.getDate());
       console.log('eOGRdt getMonth-->' + eOGRdt.getMonth());
       console.log('eOGRdt getFullYear-->' + eOGRdt.getFullYear());
       
       const monthNames = ["January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December"
       ];
       
       console.log('timezone- America/Los_Angeles->' + eOGRdt.toLocaleString('en-US', {
          timeZone: 'America/Los_Angeles'
       }));
       console.log('TZ from js-->' + this.currentCaseTimezone);
       
       //  format the timzone to pass it to the locale function
       /*if (this.currentCaseTimezone != null && this.currentCaseTimezone != undefined && this.currentCaseTimezone != '') {
          if (this.currentCaseTimezone.includes('(') && this.currentCaseTimezone.includes(')')) {
             var first = this.currentCaseTimezone.indexOf("(");
             var second = this.currentCaseTimezone.indexOf("(", first + 1);
             tz = this.currentCaseTimezone.substring(second + 1, this.currentCaseTimezone.length - 1);
          }
       }*/ //Commented as part of <T09>
       console.log('timezone-->' + eOGRdt.toLocaleString('en-US', {
          timeZone: this.strCaseTimezoneSidKey
       }));
       
       if (this.strCaseTimezoneSidKey != null && this.strCaseTimezoneSidKey != undefined && this.strCaseTimezoneSidKey != '') { // <T09>
          this.eOGRText = '';
          let sTmpTimZone = eOGRdt.toLocaleString('en-US', {
             timeZone: this.strCaseTimezoneSidKey
          });
          console.log('sTmpTimZone-->' + sTmpTimZone);
          
          let lstTmpDate = sTmpTimZone.split(', ');
          let lstDateDetail = lstTmpDate[0].split('/');
          let dtFinal = new Date(lstDateDetail[2], lstDateDetail[0] - 1, lstDateDetail[1]);
          this.eOGRText = ' Please expect the next update from Informatica by ' + dtFinal.getDate() + ', ' + monthNames[dtFinal.getMonth()] + ', ' + eOGRdt.toLocaleString('en-US', {
             timeZone: this.strCaseTimezoneSidKey
          }) +' '+this.currentCaseTimezone;
          //this.eOGRText='Next update will be sent on '+eOGRdt.getDate()+', '+monthNames[eOGRdt.getMonth()] +', '+eOGRdt.toLocaleString('en-US', { timeZone: tz }) + this.currentCaseTimezone;
          //  this.caseCommentObj.fields.Comment__c='the next update will be sent on '+eOGRdt.getDate()+', '+monthNames[eOGRdt.getMonth()] +', '+eOGRdt.toLocaleString('en-US', { timeZone: tz }) + this.currentCaseTimezone;
          
       } else {
          this.eOGRText = '';
          // this.caseCommentObj.fields.Comment__c='the next update will be sent on '+eOGRdt.getDate()+', '+monthNames[eOGRdt.getMonth()];
          this.eOGRText = ' Please expect the next update from Informatica by ' + eOGRdt.getDate() + ', ' + monthNames[eOGRdt.getMonth()];
       }
       
       this.caseCommentObj.fields.Inbound__c = false;
       this.caseCommentObj.fields.Status__c = 'Draft';
       
       //publish the comment along with eogr text here
       
       var ccomment = this.getCommentFromUI(); /*this.caseCommentObj.fields.Comment__c;*/ // <T10>
      /*  Amarender - I2RT-4524 - Changed Verbiage from 
                                 "Next update will be sent on" to 
                               "Please expect the next update from Informatica by" */
       if (ccomment.includes("Please expect the next update from Informatica by")) {
          //@Akhilesh 6 Apr 2021 -- start
          /*var indexvalue = ccomment.indexOf("Next update will be sent on");
          var tempvalue = ccomment.length;
          tempvalue = tempvalue - indexvalue;
          tempvalue = tempvalue + 34;
          console.log('tempvalue'+tempvalue);
          ccomment = ccomment.substring(0,tempvalue);
          console.log('tempvalue2'+ccomment);
          ccomment = ccomment + this.eOGRText;
          console.log('tempvalue3'+ccomment);
          */
         /*  Amarender - I2RT-4524 - Changed Verbiage from 
                                 "Next update will be sent on" to 
                               "Please expect the next update from Informatica by" */
          var indxNextUpdateFound = ccomment.indexOf("Please expect the next update from Informatica by");
          var txtVal = ccomment.substring(0, indxNextUpdateFound);
          ccomment = txtVal + this.eOGRText;
          this.populateCommentInUI(ccomment, true); // <T10>;
          console.log('@Log-->ccomment:' + ccomment);
          //@Akhilesh 6 Apr 2021 -- end
          
          /* console.log('publish the comment along with eogr text here');
                 //console.log('this.messageContext-->'+this.messageContext);
                 //let txtFinal=this.caseCommentObj.fields.Comment__c+this.eOGRText;
                 let txtFinal=this.orginalCommentValue+this.eOGRText;
                 this.caseCommentObj.fields.Comment__c=txtFinal;
                 txtFinal='';
 console.log('this.caseCommentObj.fields.Comment__c-->'+this.caseCommentObj.fields.Comment__c);
                // this.caseCommentObj.fields.Comment__c=txtFinal;
                // txtFinal='';
               //this.caseCommentObj.fields.Comment__c=this.caseCommentObj.fields.Comment__c+this.eOGRText;
               publish(this.messageContext, CASE_COMM_MC, this.caseCommentObj.fields.Comment__c);*/
       } else {
          // ccomment = ccomment + this.eOGRText; Commente as part of <T10>
          this.populateCommentInUI(this.eOGRText, false); // <T10>
       }
       
       this.caseCommentObj.fields.Comment__c = ccomment;
       publish(this.messageContext, CASE_COMM_MC, {caseId: this.recordId}); //T14
       
       //@Akhilesh 12 Aug 2021 -- start             
       if(this.caseCommentObj.fields.Status__c == 'Submitted'){

         //stop the running ogr's and update the next action to customer.
         updateNextAction({
             caseId: this.recordId,
             nextAction:this.selectedNextAction,
             isExternal: this.caseCommentObj.fields.Visibility__c == 'External' ? true : false //Vignesh D
          })
          .then(result => {
             console.log('success entry-->' + JSON.stringify(result));
             if (result) {
                /* const evt = new ShowToastEvent({
                     title: 'Success!',
                     message: 'Next Action is on Customer !',
                     variant: 'success',
                     mode: 'dismissable'
                 });
                 this.dispatchEvent(evt);*/
                this.showeOGRDropdown = false;
             } else {
                /* const evt = new ShowToastEvent({
                    title: 'Error!',
                    message: 'Technical glitch! Please retry after sometime  or contact the system Adminstrator',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);*/
                this.showeOGRDropdown = false;
             }
             
          })
          .catch(error => {
             console.log('error entry');
          });
        }
        //@Akhilesh 12 Aug 2021 -- end 
       
    }
    closeModal() {
       this.showeOGRDropdown = false;
    }
    
    handleEmailTemplateClick(event) {
       this.emailTemplateList.forEach(tmpl => {
          if (tmpl.customMetadataName == event.currentTarget.dataset.recordid) {
             tmpl.isSelected = !tmpl.isSelected;
          } else {
             tmpl.isSelected = false;
          }
       });
    }
    
    handleClick(event) {
        console.log('@Log=> handleClick:' );
        console.log('@Log=> event.currentTarget.name:' + event.currentTarget.name);
        this.caseCommentObj.fields.Comment__c = this.commentBody; //<T03>
       switch (event.currentTarget.name) {
          case 'saveAsDraft':
            if(!this.validateCommentBody()){
               return;
            }
            if(!this.validateInput()){ // I2RT-7609
               return;
            }
            
             this.caseCommentObj.fields.Status__c = 'Draft';
            // Deva : start : I2RT-2630 :To capture the eOGRDateTime on the record
            if(this.eOGRDateTime){
               this.caseCommentObj.fields.Extend_OGR_By__c = this.eOGRDateTime;
            }
            //Deva : End : I2RT-2630 :
            
            let cmtTextbox = this.template.querySelector("[data-name='commentBody']");
            this.caseCommentObj.fields.Comment__c = cmtTextbox.value.trim();

             this.upsertCaseComment(true);

             //<T18>
             this.caseCommentObj.fields.Comment__c = '';
             this.commentBody = '';
             this.attachments = [];
             this.caseCommentObj.fields.attachments = [];
             this.sendCaseCommentToParent();
             //</T18>
             
             break;
             
          case 'schedule':
            if(!this.validateInput()){ // I2RT-7609
               return;
            }
             this.isSchedule = true;
             break;
             
          case 'scheduleConfirm': 
            this.showSpinner = true; //<T05>
             if(!this.validateCommentBody()){
               this.showSpinner = false; //<T05>
               return;
             }
             const scommentBody = this.template.querySelector("[data-name='commentBody']");
            //@Akhilesh 19 Oct 2021 -- start
             //const sCleanBody = scommentBody.value.trim().replace(/\*/g, '');
             //this.caseCommentObj.fields.Comment__c = sCleanBody;
             this.caseCommentObj.fields.Comment__c = scommentBody.value.trim();
             //@Akhilesh 19 Oct 2021 -- end

             let dateTimeElement = this.template.querySelector('[data-field="Date_Time_Scheduled__c"]');
             if (dateTimeElement && dateTimeElement.value && Date.parse(dateTimeElement.value) > new Date().getTime()) {
                this.isSchedule = false;
                this.caseCommentObj.fields["Date_Time_Scheduled__c"] = dateTimeElement.value;
                this.caseCommentObj.fields["Scheduled_Case_Next_Action__c"] = this.selectedNextAction; // <T05>
                this.caseCommentObj.fields["Status__c"] = 'Scheduled';
                this.upsertCaseComment();
               //<T18>
               this.caseCommentObj.fields.Comment__c = '';
               this.commentBody = '';
               this.attachments = [];
               this.caseCommentObj.fields.attachments = [];
               this.sendCaseCommentToParent();
               //</T18>
             } else {
                this.dispatchEvent(new ShowToastEvent({
                   title: '',
                   message: 'Please provide a valid time in future',
                   variant: 'error'
                }));
                this.showSpinner = false; //<T05>
             }
             
             break;
             
          case 'cancelSchedule':
             this.isSchedule = false;
             break;

          case 'submit':
               if(!this.validateInput()){ // I2RT-7609
                  return;
               }

            /*  console.log('Submit button entry');
             console.log('sub type' + this.caseCommentObj.fields.sub_type__c);
             console.log('sub type' + this.caseCommentObj.fields.type__c);
             console.log('Comment_Category__c' + this.caseCommentObj.fields.Comment_Category__c); */
            // if(this.caseCommentObj.fields.Comment_Category__c == null || this.caseCommentObj.fields.Comment_Category__c == ''|| this.caseCommentObj.fields.Comment_Category__c == undefined){ //commented if block //I2RT-7609
              // this.caseCommentObj.fields.Comment_Category__c = this.selectedeCommentCategory; //I2RT-7609
            // }
             
             this.showSpinner = true; //Vignesh D

             if(!this.validateCommentBody()){
                this.showSpinner = false; //Vignesh D
                return;
             }

             //@Akhilesh --> 24 Aug 2021 -- start
             const commentBody = this.template.querySelector("[data-name='commentBody']");
             
             //@Akhilesh --> 19 Oct 2021 -- start
             //const newCleanSearchTerm = commentBody.value.trim().replace(/\*/g, '');
             //this.caseCommentObj.fields.Comment__c = newCleanSearchTerm;
             this.caseCommentObj.fields.Comment__c = commentBody.value.trim();
             //@Akhilesh --> 19 Oct 2021 -- end 
            //@Akhilesh --> 24 Aug 2021 -- end

             if(this.eOGRVisible){
                console.log('@Log=> this.eOGRDateTime:' + this.eOGRDateTime);
                if(this.eOGRDateTime == undefined || this.eOGRDateTime == null){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Select eOGR DateTime',
                        variant: 'error'
                    }));
                    this.showSpinner = false; //Vignesh D
                    return;
                }
            }
            
             //@Akhilesh 4 June 2021 -- start
            console.log('@Log=> this.selectedNextAction:' + this.selectedNextAction);
            if(this.isExternalAccess){
                if(this.selectedNextAction == ''){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Select Next Action',
                        variant: 'error'
                    }));
                    this.showSpinner = false; //Vignesh D
                    return;
                }
            }
            //@Akhilesh 4 June 2021 -- end
            
             console.log('@Log=> this.caseCommentObj.fields.Status__c:' + this.caseCommentObj.fields.Status__c);
             this.caseCommentObj.fields.Status__c = 'Submitted';
             this.upsertCaseComment();
             
             console.log('this.selectedNextAction'+this.selectedNextAction);
             //<T13> starts
             this.caseCommentObj.fields.Comment__c = '';
             this.commentBody = '';
             //<T18>
             this.attachments = [];
             this.caseCommentObj.fields.attachments = [];
             //</T18>
             this.sendCaseCommentToParent();
             //<T13> ends
             //@Akhilesh 12 Aug 2021 -- start
             updateNextAction({
                caseId: this.recordId,
                nextAction:this.selectedNextAction,
                isExternal: this.caseCommentObj.fields.Visibility__c == 'External' ? true : false //Vignesh D

             })
             .then(result => {
                console.log('success entry-->' + JSON.stringify(result));
             })
             .catch(error => {
                console.log('error-->' + JSON.stringify(error));
             });
             //@Akhilesh 12 Aug 2021 -- end 
             
             break;
             
          case 'cancelModal':
             this.isQuickText = false;
             this.isQuickUpdate = false;
             this.hasNext = false;
             break;
             
          case 'nextModal':
             const quickUpdateSubmitButton = this.template.querySelector("[data-name='quickUpdateSubmit']");
             if (quickUpdateSubmitButton) {
                this.hasNext = true;
                this.showSpinner = true;
                quickUpdateSubmitButton.click();
             }
             break;
             
          case 'saveModal':
             if (this.isQuickUpdate) {
                const quickUpdateSubmitButton1 = this.template.querySelector("[data-name='quickUpdateSubmit']");
                if (quickUpdateSubmitButton1) {
                   this.showSpinner = true;
                   quickUpdateSubmitButton1.click();
                }
             }
             
             if (this.isQuickText) {
                this.showSpinner = true;
                let selectedTemplates = [];
                selectedTemplates = this.emailTemplateList.filter(tmpl => tmpl.isSelected);
                console.log('quicktexttemplate');
                if (selectedTemplates && selectedTemplates.length > 0) {
                  console.log('quicktexttemplateinside'+selectedTemplates);
                   this.getProcessedEmailTemplateBody(true);
                   this.isQuickText = false;
                } else {
                   this.dispatchEvent(new ShowToastEvent({
                      title: '',
                      message: 'Please select a template!',
                      variant: 'error'
                   }));
                }
             }
             console.log('updated emailTemplateList --> '+JSON.stringify(this.emailTemplateList));
             break;
             
          case 'accessType':
             this.caseCommentObj.fields.Visibility__c = event.target.dataset.value;
             this.sharingOptions.forEach(opt => {
                if (opt.value == event.target.dataset.value) {
                   opt.variant = "brand";
                } else {
                   opt.variant = "";
                }
             });             

             break;
             
          case 'notificationstype':
             //this.caseCommentObj.fields.Visibility__c = event.target.dataset.value;
             this.notificationtype.forEach(opt => {
                if (opt.value == event.target.dataset.value) {
                   opt.variant = "brand";
                } else {
                   opt.variant = "";
                }
             });
             break;
             
          case 'reseteOGR':
             
             this.reseteOGR();
             break;
             
          default:
             break;
       }
       
    }

    

    validateCommentBody(){
      console.log('@Log=> validateCommentBody:' );
      
      const commentBody = this.template.querySelector("[data-name='commentBody']");
      let commentBodyValue = commentBody.value;
      let sCommentData = '';
      console.log('@Log=> validateCommentBody=>commentBodyValue:' + commentBodyValue);
      
      if(commentBodyValue != '' && commentBodyValue != null && commentBodyValue != undefined){
         let content = '';
         if(commentBodyValue.includes('<p>')){
            const parser = new DOMParser();
            let commentRichText = parser.parseFromString(commentBodyValue,"text/html");
            content = commentRichText.body.getElementsByTagName("p").item(0).innerHTML.trim();
         }else{
            content = commentBodyValue.trim();
         }
         
         sCommentData = (content != null && content != undefined && content != "") ? commentBodyValue : content;
      }
      
       
       console.log('@Log=> sCommentData:' + sCommentData);
       
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

      //  <T02>
       if((this.caseCommentObj.fields.Visibility__c == 'External' || this.caseCommentObj.fields.Visibility__c == 'Internal') && (this.selectedNextAction == null  || this.selectedNextAction == '' || this.selectedNextAction == undefined)){
         this.showSpinner = false;
         const nextaction = this.template.querySelector("[data-name='nextaction']");
         if (!nextaction.value) {
            nextaction.setCustomValidity("Next Action is required");
         } else {
            nextaction.setCustomValidity("");
         }
         nextaction.reportValidity();
         return false;
       }
      //  </T02>

       if (this.iseOgrSelected && this.eOGRDateTime &&  Date.parse(this.eOGRDateTime) < new Date().getTime()) {
         this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Please Enter future time for Engineer OGR!',
            variant: 'error'
         }));
         return false;
       }

       return true;
    }
    
    reseteOGR() {
       console.log('reset ogr');
       
       resetExistingeOGR({
             caseId: this.recordId
          })
          .then(result => {
             console.log('success entry-->' + JSON.stringify(result));
             if (JSON.stringify(result) != null && JSON.stringify(result) != undefined && JSON.stringify(result) != '') {
                if (result) {
                   const evt = new ShowToastEvent({
                      title: 'Success!',
                      message: 'e-OGR reset is successful',
                      variant: 'success',
                      mode: 'dismissable'
                   });
                   this.dispatchEvent(evt);
                   this.disableResetButton = true;
                } else {
                   const evt = new ShowToastEvent({
                      title: 'Success!',
                      message: 'Failed to reset e-OGR. Please try again after sometime! ',
                      variant: 'error',
                      mode: 'dismissable'
                   });
                   this.dispatchEvent(evt);
                }
                
             }
             
          })
          .catch(error => {
             console.log('error entry');
          });
       
    }
    handleLoad(event) {
       this.showSpinner = false;
    }
    
    handleSuccess(event) {
       this.showSpinner = false;
       if (this.hasNext) {
          this.isQuickText = true;
       } else {
          this.isQuickText = false;
       }
       this.isQuickUpdate = false;
    }

    handleSuccessrich(event){
      console.log('submitted');
    }
    
    deleteFile(event) {
       this.showSpinner = true;  // <T01>
       deleteRecord(event.detail.item.name).then(() => {
          const index = this.uploadedFilesIdList.indexOf(event.detail.item.name);
          if (index > -1) {
             this.uploadedFilesIdList.splice(index, 1);
          }
          this.dispatchEvent(new ShowToastEvent({
             title: '',
             message: 'File removed successfully!',
             variant: 'success'
          }));
          refreshApex(this.wiredDocuments);
          
       }).catch((error) => {
          console.log('error>>', error);
          objUtilities.processException(error, this);
          this.showSpinner = false; // <T01>
         });
    }
    
    throttleUserInputIntoCommentBody(newComment) {
        console.log('@Log=> throttleUserInputIntoCommentBody:' );
        console.log('@Log=> newComment:' + newComment);

       //const newCleanSearchTerm = newComment.trim().replace(/\*/g, '');
       const newCleanSearchTerm = newComment.trim();
       console.log('@Log=> newCleanSearchTerm:' + newCleanSearchTerm);
       console.log('@Log=> this.caseCommentObj.fields.Comment__c:' + this.caseCommentObj.fields.Comment__c);
       
       /*if (newCleanSearchTerm == '') {
          return;
       }*/
       
       if (this.caseCommentObj.fields.Comment__c === newCleanSearchTerm) {
        console.log('@Log=> no change found in comment:');
          return;
       }
       this.commentBody = newCleanSearchTerm;//<T03>
       //this.caseCommentObj.fields.Comment__c = newCleanSearchTerm;//<T03>
         
       
       
       if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
        console.log('@Log=> less than minimum length:');
          return;
       }
       
       if (this._throttlingTimeout) {
          clearTimeout(this._throttlingTimeout);
       }
       console.log('@Log=> SEARCH_DELAY:' + SEARCH_DELAY);
       
       this._throttlingTimeout = setTimeout(() => {
            console.log('@Log=> this.caseCommentObj.fields.Comment__c:' + this.caseCommentObj.fields.Comment__c);

             if (this.commentBody.length >= MINIMAL_SEARCH_TERM_LENGTH && this.isShowDraftButton) {//<T03>
                //this.loading = true;
                console.log('@Log=> this.isEdit:' + this.isEdit);
                console.log('@Log=> this.parentCommentId:' + this.parentCommentId);

                if (!this.isEdit) {
                   if (!this.parentCommentId) {
                     // this.upsertCaseComment(true);
                   }
                }
             }
             this._throttlingTimeout = null;
          },
          SEARCH_DELAY);
    }
    
    upsertCaseComment(isDraftSave = false) {
       console.log('upsert comment entry');
       console.log('Comment__c' + this.caseCommentObj.fields.Comment__c);
       console.log('eOGRText-->' + this.eOGRText);
       console.log('isDraftSave-->' + isDraftSave);
       console.log('this.caseCommentObj.fields.Id-->' + this.caseCommentObj.fields.Id);
       console.log('@Log=> this.caseCommentObj.fields.Status__c:' + this.caseCommentObj.fields.Status__c);
       
       //this.showSpinner = false;

       if (!this.caseCommentObj.fields.Case__c) {
          this.caseCommentObj.fields.Case__c = this.recordId;
       }     
       if (this.mdt) {
          this.caseCommentObj.fields.Post_Update_Metadata_Name__c = this.mdt;
       }
       
       //if (!isDraftSave) {
        if(this.caseCommentObj.fields.Status__c != 'Pre Draft'){   
         // this.showSpinner = true;
       }
              
       let callback;
       if (!this.caseCommentObj.fields.Id) {
          callback = comment => {
             //console.log('with case comment Id : after Save Comment '+':' + new Date());
             console.log('isDraftSave-->' + isDraftSave);
             this.updateEOGRTimeStamp();
             
             try {
                this.caseCommentObj.fields.Id = comment.Id;
                delete this.caseCommentObj['apiName']
                this.showSpinner = false;

                if (!isDraftSave) {
                   this.dispatchEvent(new CustomEvent('save'));
                   
                   getRecordNotifyChange([{ recordId: this.recordId }]);
                   publish(this.messageContext, CASE_COMM_MC, {caseId: this.recordId}); //T14
                }
                else{
                 //@akhilesh--> to close save as draft popup
                 if(this.caseCommentObj.fields.Status__c != 'Pre Draft'){
                  this.dispatchEvent(new CustomEvent('save'));
                 }
                }
                
             } catch (error) {
                console.log('error' + JSON.stringify(error));
                objUtilities.processException(error, this);
             }
          };
       }
        else {
          callback = comment => {
             //console.log('without case comment Id : after Save Comment '+':' + new Date());
             console.log('isDraftSave-->' + isDraftSave);
             this.updateEOGRTimeStamp();
             
             try {
                this.showSpinner = false;
                if (!isDraftSave) {
                   this.dispatchEvent(new CustomEvent('save'));
                   
                   publish(this.messageContext, CASE_COMM_MC, {caseId: this.recordId}); //T14
                }
                else{
                  //@akhilesh--> to close save as draft popup
                  if(this.caseCommentObj.fields.Status__c != 'Pre Draft'){
                    this.dispatchEvent(new CustomEvent('save'));
                   }
                }                                
             } catch (error) {
               objUtilities.processException(error, this);
                console.log('error' + JSON.stringify(error));
             }
          };
       }
       
       if (this.parentCommentId) {
          this.caseCommentObj.fields.Parent_Comment__c = this.parentCommentId;
       }
       /*if(this.iseOgrSelected)
       {
           this.caseCommentObj.fields.Is_eOGR_comment__c = true;
       }*/
       if (this.caseCommentObj.fields.Comment__c.length > 0 && this.iseOgrSelected && (this.eOGRText == undefined || this.eOGRText.length > 0)) {
          console.log('line 832 include the existing text');
          
          //@Akhilesh 6 Apr 2021 -- start
          //following statement is not needed comment__c is already having what it should have
          
          //this.caseCommentObj.fields.Comment__c=this.caseCommentObj.fields.Comment__c + this.eOGRText;
          
          //@Akhilesh 6 Apr 2021 -- end
          
          this.eOGRText = '';
          
       }

       let params = {
          comment: Object.assign({
             'sobjectType': 'Case_Comment__c'
          }, this.caseCommentObj.fields)
       };
       if (this.uploadedFilesIdList && this.uploadedFilesIdList.length) {
          params.fileIdList = this.uploadedFilesIdList;
       }
       
       //console.log('before Save Comment'+':' + new Date());
       console.log('params>>', JSON.stringify(params));
       saveComment(params)
          .then(callback).catch(error => {
             console.log(' upd error>>>', JSON.parse(JSON.stringify(error)));
             objUtilities.processException(error, this);
             this.showSpinner = false;
          });
       //once case comment is submitted/upserted
       //oce saved, make eogr in mins=0;
       
       //console.log('before updateeOGR'+':' + new Date());
       console.log('this.eOGRInMins' + ':' + this.eOGRInMins);
       //<TO7> starts
       if(isDraftSave == false){
         this.commentBody ='';
         this.sendCaseCommentToParent();
       }
       //<TO7> ends

       //@Akhilesh 14 apr 2021 -- start
       /*
       if(this.caseCommentObj.fields.Status__c=='Submitted')
       { 
           if(this.eOGRInMins!=null && this.eOGRInMins!=undefined && this.eOGRInMins!='')
           {
               if(this.eOGRInMins>0 && this.iseOgrSelected)
               {
                   updateeOGR({ caseId:this.recordId, eOGRinMins:this.eOGRInMins})
                   .then(result => {
                       console.log('success entry-->'+JSON.stringify(result));
                       console.log('after updateeOGR'+':' + new Date());
 
                       if(JSON.stringify(result)!=null && JSON.stringify(result)!=undefined && JSON.stringify(result)!='')
                       {
                           if(result)
                           {
                               this.eOGRInMins=0;
                           }else
                           {
                               this.eOGRInMins=0;
                           }
           
                       }
                       
                   })
                   .catch(error => {
                       console.log('error entry');
                   });
               }
           }
       }*/
       //@Akhilesh 14 apr 2021 -- end
    }
    
    //@Akhilesh 14 apr 2021 -- start
    updateEOGRTimeStamp() {
       console.log('this.caseCommentObj.fields.Status__c' + this.caseCommentObj.fields.Status__c);
       console.log('this.eOGRInMins' + this.eOGRInMins);
       console.log('this.iseOgrSelected' + this.iseOgrSelected);
       
       if (this.caseCommentObj.fields.Status__c == 'Submitted') {
          if (this.eOGRInMins != null && this.eOGRInMins != undefined && this.eOGRInMins != '') {
             if (this.eOGRInMins > 0 && this.iseOgrSelected) {
                updateeOGR({
                      caseId: this.recordId,
                      eOGRinMins: this.eOGRInMins
                   })
                   .then(result => {
                      console.log('success entry-->' + JSON.stringify(result));
                      //console.log('after updateeOGR'+':' + new Date());
                      
                      if (JSON.stringify(result) != null && JSON.stringify(result) != undefined && JSON.stringify(result) != '') {
                         if (result) {
                            this.eOGRInMins = 0;
                         } else {
                            this.eOGRInMins = 0;
                         }
                         //@Akhilesh 19 apr 2021 -- start
                         //publish(this.messageContext, CASE_COMM_MC, {});
                         //@Akhilesh 19 apr 2021 -- end
                      }
                   })
                   .catch(error => {
                      console.log('error entry');
                   });
             }
          }
       }
    }
    //@Akhilesh 14 apr 2021 -- end
    
    decodeSharingMode(value) {
       if (value == 'Private') {
          this.sharingModeValue = 0;
       }
       if (value == 'Internal') {
          this.sharingModeValue = 50;
       }
       if (value == 'External') {
          this.sharingModeValue = 100;
       }
    }
    
    encodeSharingMode(value) {
       if (value == 0) {
          this.caseCommentObj.fields.Visibility__c = 'Private';
       }
       
       if (value == 50) {
          this.caseCommentObj.fields.Visibility__c = 'Internal';
       }
       
       if (value == 100) {
          this.caseCommentObj.fields.Visibility__c = 'External';
          this.toggleButtonColor(true);
       }
    }
    
    filePreview(event) {
       event.preventDefault();
       window.open(location.origin + '/' + basePath.replace('/s', '') + '/sfc/servlet.shepherd/document/download/' + event.currentTarget.dataset.id + '?operationContext=S1', '_blank');
    }
    
    handleUploadFinished(event) {
       this.showSpinner = true;     // <T01>
       const uploadedFiles = event.detail.files;
       console.log('uploadedFiles>>>', JSON.stringify(uploadedFiles));
       this.uploadedFilesIdList = [...this.uploadedFilesIdList, ...uploadedFiles.map(a => a.documentId)];
       console.log('this.uploadedFilesIdList>>', JSON.stringify(this.uploadedFilesIdList));
       refreshApex(this.wiredDocuments);
    }

	/*
	 Method Name : setComment
	 Description : This method sets a given string in the Comment field.
	 Parameters	 : String, called from setComment, strComment Comment.
	 Return Type : None
	 */
	@api
	setComment(strComment) {
		this.caseCommentObj.fields.Comment__c = strComment;
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
      let cleanedStrHTMLBody = strHTMLBody;
      const regexPatterns = [
         {regexTarget: /<html[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<\/html[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<head[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<\/head[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<title[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<\/title[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<body[^>]*>/gm, replaceStr: ''},
         {regexTarget: /<\/body[^>]*>/gm, replaceStr: ''},
         {regexTarget: /\n/gm, replaceStr: ''},
         {regexTarget: /\t/gm, replaceStr: ''}
      ];
      console.log('this.caseCommentObj.fields.Comment__c: '+this.caseCommentObj.fields.Comment__c);
      console.log('cleanedStrHTMLBody: '+cleanedStrHTMLBody);
      regexPatterns.forEach(regexPatternObj => { cleanedStrHTMLBody = cleanedStrHTMLBody.replace(regexPatternObj.regexTarget, regexPatternObj.replaceStr); });
      const commentBody = this.template.querySelector("[data-name='commentBody']");
      commentBody.value = commentBody.value.trim() + cleanedStrHTMLBody.trim();
      commentBody.focus();
      console.log('Comment Body: '+this.template.querySelector("[data-name='commentBody']")?.value);
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


   //T06
	/*
	 Method Name : tagSelectionChanged
	 Description : This method receives the latest selected users to be tagged.
	 Parameters	 : Object, called from tagSelectionChanged, objEvent Event reference.
	 Return Type : None
	 */
	tagSelectionChanged(objEvent) {
      console.log('tagSelectionChanged.. objEvent.detail.lstSelectedItems = ' + JSON.stringify(objEvent.detail.lstSelectedItems));
		
		//First we remove the current values.
		this.caseCommentObj.fields.Tagged_User_1__c = null;
		this.caseCommentObj.fields.Tagged_User_2__c = null;
		this.caseCommentObj.fields.Tagged_User_3__c = null;
		this.caseCommentObj.fields.Tagged_User_4__c = null;
		this.caseCommentObj.fields.Tagged_User_5__c = null;

      console.log('tagSelectionChanged.. user values reset!');

		//Now we fill the fields.
		if(objUtilities.isNotNull(objEvent.detail.lstSelectedItems)) {
         console.log('tagSelectionChanged.. selected items present!');
			objEvent.detail.lstSelectedItems.forEach(objUser => {
            console.log('tagSelectionChanged.. objUser = ' + JSON.stringify(objUser));

				if(objUtilities.isNull(this.caseCommentObj.fields.Tagged_User_1__c)) {
					this.caseCommentObj.fields.Tagged_User_1__c = objUser.value;
					this.caseCommentObj.fields.Tagged_User_1__r = {'Id' : objUser.value, 'Name' : objUser.label};
				} else if(objUtilities.isNull(this.caseCommentObj.fields.Tagged_User_2__c)) {
					this.caseCommentObj.fields.Tagged_User_2__c = objUser.value;
					this.caseCommentObj.fields.Tagged_User_2__r = {'Id' : objUser.value, 'Name' : objUser.label};
				} else if(objUtilities.isNull(this.caseCommentObj.fields.Tagged_User_3__c)) {
					this.caseCommentObj.fields.Tagged_User_3__c = objUser.value;
					this.caseCommentObj.fields.Tagged_User_3__r = {'Id' : objUser.value, 'Name' : objUser.label};
				} else if(objUtilities.isNull(this.caseCommentObj.fields.Tagged_User_4__c)) {
					this.caseCommentObj.fields.Tagged_User_4__c = objUser.value;
					this.caseCommentObj.fields.Tagged_User_4__r = {'Id' : objUser.value, 'Name' : objUser.label};
				} else if(objUtilities.isNull(this.caseCommentObj.fields.Tagged_User_5__c)) {
					this.caseCommentObj.fields.Tagged_User_5__c = objUser.value;
					this.caseCommentObj.fields.Tagged_User_5__r = {'Id' : objUser.value, 'Name' : objUser.label};
				}
			});
		}
      console.log('tagSelectionChanged.. this.caseCommentObj.fields = ' + JSON.stringify(this.caseCommentObj.fields));

	}
  
  /*
	 Method Name : populateCommentInUI
	 Description : This method appends the given input text to the comment and focuses the comment field.
	 Parameters	 : (String,Boolean), called from populateCommentInUI, strInput String & boolOverwriteComment Boolean.
	 Return Type : None
	 */
   populateCommentInUI(strInput, boolOverwriteComment) { // <T10>
      const commentBody = this.template.querySelector("[data-name='commentBody']");
      if(strInput && strInput != '' && !boolOverwriteComment){
         commentBody.value = commentBody.value.trim() + strInput.trim();
      }
      else if(strInput && strInput != '' && boolOverwriteComment){
         commentBody.value = strInput.trim();
      }
      commentBody.focus();
   }

   /*
	 Method Name : getCommentFromUI
	 Description : This method gets and returns the comment from component in UI.
	 Parameters	 : None
	 Return Type : None
	 */
   getCommentFromUI(){ // <T10>
      const commentBody = this.template.querySelector("[data-name='commentBody']");
      return commentBody.value.trim();
   }

   validateInput(){ //I2RT-7609
      let isvalid=true;
      let inputFields=this.template.querySelectorAll('.validate');
      inputFields.forEach(inputField => {
         if(!inputField.checkValidity()){
            inputField.reportValidity();
            isvalid=false;
         }
      });
      return isvalid;
   }

   isNextBestActionType(type){ ////I2RT-7609
      if(type==='Request More Info' ||type==='Provide Solution' ||type==='Delay Close' || type==='Send RCA' ||type==='Close Case'){
         return true;
      }else{
         return false;
      }
   }
 }