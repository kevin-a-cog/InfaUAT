/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         01/11/2022  I2RT-5259   T01     rewrote the code to handle the Account/Case Team fields
balajip         03/23/2022  I2RT-5706   T02     to have an empty user entry by default
balajip         05/24/2022  I2RT-6268   T03     Added feature to be able to configure Queue or Related Users for notification
Napavi Prabu    29/8/2022   AR-2771     T04     To get only the object in edit based on the app configuured in custom meta data
cgowda          08/08/2022  PAYGIT-2    T05     Added feature to be able to configure the notifcations to be sent to Platform
Isha Bansal     30/06/2023  I2RT-8234   T06     Includes new fields to be sent to  inputFielddynamic component  
Isha Bansal     03/10/2023  I2RT-8710   T07     Bug Fix to cater criteria conditions more than 9 
*/
import { LightningElement,track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getPicklistValues , getObjectInfo } from 'lightning/uiObjectInfoApi';

/** Edit changes */
import getrelatedRecords from '@salesforce/apex/NotificationSubscriptionController.getrelatedRecords';
/** Edit changes */

import getTemplatePreview from '@salesforce/apex/NotificationSubscriptionController.getTemplatePreview';
import getFieldInfo from '@salesforce/apex/NotificationSubscriptionController.getFieldInfo';
import getPicklistValue from '@salesforce/apex/NotificationSubscriptionController.getPicklistValues';
import getQueueNames from '@salesforce/apex/NotificationSubscriptionController.getQueueNames';
import getRecordTypes from '@salesforce/apex/NotificationSubscriptionController.getRecordTypes';
import getUserData from '@salesforce/apex/NotificationSubscriptionController.getUserData';
import saveNotificationCriteria from '@salesforce/apex/NotificationSubscriptionController.saveNotificationCriteria';
import getObjectNames from '@salesforce/apex/NotificationSubscriptionController.getObjectNames';
import getTemplates from '@salesforce/apex/NotificationSubscriptionController.getTemplates';
import allowNotificationAPI from '@salesforce/apex/NotificationSubscriptionController.allowNotificationAPI';

import OBJECT_NOTIFICATION_SUBSCRIPTION from '@salesforce/schema/Notification_Criteria__c';
import FIELD_OBJECT from '@salesforce/schema/Notification_Criteria__c.Object__c';
import FIELD_EVALUATION_TRIGGER from '@salesforce/schema/Notification_Criteria__c.Evaluation_Trigger__c';
import FIELD_NOTIFICATION_CHANNEL from '@salesforce/schema/Notification_Criteria__c.Notification_Type__c';

import USER_ID from '@salesforce/user/Id'; 
import USER_PHONE from '@salesforce/schema/User.Phone';
import USER_EMAIL from '@salesforce/schema/User.Email';

import VALID_EMAIL_DOMAINS from '@salesforce/label/c.Notification_Valid_Domains';
import USER_TYPE_FIELD from '@salesforce/schema/Notification_User__c.User_Type__c';
import getAccountCaseFields from '@salesforce/apex/NotificationSubscriptionController.getAccountCaseFields';

const FIELDS = ['Notification_Criteria__c.Name', 'Notification_Criteria__c.Object__c','Notification_Criteria__c.Notification_Type__c','Notification_Criteria__c.Evaluation_Trigger__c','Notification_Criteria__c.MS_Teams_Email__c','Notification_Criteria__c.SF_Chatter_Post_Email__c','Notification_Criteria__c.Active__c','Notification_Criteria__c.Custom_Logic__c','Notification_Criteria__c.Condition__c','Notification_Criteria__c.Template_Name__c'];

const DATATYPE_OPERATORS = {
    "STRING": [
      "equals",
      "not equal to",
      "contains",
      "does not contain",
      "starts with"
    ],
    "PICKLIST": [
      "equals",
      "not equal to"
    ],
    "MULTIPICKLIST": [
      "equals",
      "not equal to"
    ],
    "TEXTAREA": [
      "equals",
      "not equal to",
      "contains",
      "does not contain",
      "starts with"
    ],
    "REFERENCE": [
      "equals",
      "not equal to"
    ],
    "TIME": [
      "equals",
      "not equal to"
    ],
    "BOOLEAN": [
      "equals",
      "not equal to"
    ],
    "INTEGER": [
      "equals",
      "not equal to",
      "less than",
      "greater than",
      "less or equal",
      "greater or equal"
    ],
    "DOUBLE": [
      "equals",
      "not equal to",
      "less than",
      "greater than",
      "less or equal",
      "greater or equal"
    ],
    "PERCENT": [
      "equals",
      "not equal to",
      "less than",
      "greater than",
      "less or equal",
      "greater or equal"
    ],
    "ID": [
      "equals",
      "not equal to"
    ],
    "DATE": [
      "equals",
      "not equal to",
      "less than",
      "greater than",
      "less or equal",
      "greater or equal"
    ],
    "DATETIME": [
      "equals",
      "not equal to",
      "less than",
      "greater than",
      "less or equal",
      "greater or equal"
    ],
    "URL": [
      "equals",
      "not equal to"
    ],
    "EMAIL": [
      "equals",
      "not equal to",
      "contains",
      "does not contain",
      "starts with"
    ]
}

const CASE_COMMENT_DEFAULT_CRITERIA = {
    "id":0,
    "section":1,
    "allowDelete":false,
    "operatorsList":[{"label":"equals","value":"equals"},{"label":"not equal to","value":"not equal to"}],
    "multipicklistOptions":[{"label":"Draft","value":"Draft"},{"label":"Scheduled","value":"Scheduled"},{"label":"Submitted","value":"Submitted"},{"label":"Pre Draft","value":"Pre Draft","selected":true},{"label":"Escalated","value":"Escalated"}],
    "fieldLabel":"Status",
    "fieldAPIName":"Status__c",
    "fieldType":"PICKLIST",
    "objectName":"Case_Comment__c",
    "referredObjectName":"Case_Comment__c",
    "referredFieldAPIName":"Status__c",
    "operator":"not equal to",
    "fieldValue":"Pre Draft",
    "fieldValueNames":"Pre Draft",
    "showWarning":true
}

const NOTIFICATION_TYPE_OPTIONS=[
    {"value":"SMS","label":"Send SMS","selected":false},
    {"value":"Email","label":"Send Email","selected":false},
    {"value":"Salesforce Bell - Desktop","label":"Salesforce Bell - Desktop","selected":false},
    {"value":"Salesforce Bell - Mobile","label":"Salesforce Bell - Mobile","selected":false},
    {"value":"Salesforce Chatter Post","label":"Salesforce Chatter Post","selected":false},
    {"value":"Microsoft Teams Private message","label":"Microsoft Teams Private Message","selected":false},
    {"value":"Microsoft Teams Channel Email","label":"Microsoft Teams Channel Message","selected":false}
];

/** Added to Notification Type, only if the object supprts platform notification*/ //T05
const NOTIFICATION_TYPE_PLATFORM_OPTIONS = [
    {"value":"MESSAGE_BOX","label":"Notify Platform - Message Box","selected":false},
    {"value":"MESSAGE_BUBBLE","label":"Notify Platform - Message Bubble","selected":false},
    {"value":"BELL_NOTIFICATION","label":"Notify Platform - Bell Notification","selected":false},
    {"value":"BANNER","label":"Notify Platform - Banner","selected":false}
];

/** Added to Recipient type, only if the object supports platform notification*/ //T05
const PLATFORM_NOTIFICATION_RECIPIENT_TYPE = [
    {label: 'All Org Users', value: 'All Org Users'},
    {label: 'Specific User Role', value: 'Specific User Role'}
];

export default class NotificationSubscription extends NavigationMixin(LightningElement) {

    spinnerCounter = 0;
    get showSpinner(){
        return this.spinnerCounter > 0;
    }

    @track
    criteriaRecord = {
        apiName: "Notification_Criteria__c",
        types: [],
        fields: {
            Name: '',
            Notification_Type__c: '',
            MS_Teams_Email__c: '',
            Active__c: true
        }
    };

    @api recordId;
    isEditMode = false;

    /**Object Change variables */
    showConfirmationModal=false;
    objectValueOld;
    objectValueNew;

    @track showPreview = false;
    @track templatePreview = '';

    @track objectOptions=[];
    @track triggerOptions=[];
    @track templateOptions = [];
    @track notificationTypeOptions=[];

    @track fieldNameOptions = [];
    @track fieldInfo = {};

    @track errorMsg;

    @track criteriaList = [{
        id: 0,
        section:1,
        operatorsList:[],
        multipicklistOptions:[],
        allowDelete:false,
        fieldAPIName:''
    }];

    @track userValue = USER_ID;
    @track useritemList = [
        {
            id: 0,
            allowDelete: false
        }
    ];   
    
    currentUserItem;
    notificationDetailList = [];
    notificationUserList = [];
    notificationTeamUserList= [];
    AccountTeamMemberRoleOptions =[];
    CaseTeamMemberRoleOptions =[];
    planteamRoleOptions=[];
    userFieldOptions=[];
    OpportunityTeamMemberRoleOptions=[];
    @track queueOptions=[];
    dontCreateNew=true;

    //T03
    @track userTeamList = [
        {
            id: 0,
            allowDelete: false
        }
    ]
    currentUserTeam;

    recipientTypeOptions = [
        {label: 'User', value: 'User'},
        {label: 'Queue', value: 'Queue'},
        {label: 'Distribution List', value: 'Distribution List'}
    ];

    teamTypeOptions = [
        {label: 'Related User', value: 'Related User'},
        {label: 'Account Team', value: 'Account Team'},
        {label: 'Case Team', value: 'Case Team'},
        {label: 'Plan Team', value: 'Plan Team'},
        {label: 'Opportunity Team', value: 'Opportunity Team'}
    ];

    /** show Expiration Date if Notify Platform* is selected as the notification type */ //T05
    get showExpirationDate(){
        var platformNotifTypes = NOTIFICATION_TYPE_PLATFORM_OPTIONS.map(function(notifType){ return notifType.value});
        return this.criteriaRecord.types && this.criteriaRecord.types.some( notifType => platformNotifTypes.includes(notifType));
    }

    get showTeamsEmailField(){
        //console.log('showTeamsEmailField');
        return this.criteriaRecord.types && this.criteriaRecord.types.includes('Microsoft Teams Channel Email');
    }

    get showChatterGroupEmailField(){
        return this.criteriaRecord.types && this.criteriaRecord.types.includes('Salesforce Chatter Post');
    }

    get showUserPhoneColumn(){
        return this.criteriaRecord.types && this.criteriaRecord.types.includes('SMS');
    }

    get showUserEmailColumn(){
        return this.criteriaRecord.types && this.criteriaRecord.types.includes('Email');
    }

    get isCaseCommentObject(){
        return (this.criteriaRecord.fields.Object__c === 'Case_Comment__c');
    }

    @wire(getObjectInfo, { objectApiName: OBJECT_NOTIFICATION_SUBSCRIPTION })
    objectInfo;



    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FIELD_OBJECT
    })
    wiredObjectPickListValue({ data, error }){
        if(data){
            console.log(` Picklist values are `, data.values);
            this.objectOptions = data.values;
            this.error = undefined;
        }
        if(error){
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.objectOptions = [];
        }
    };

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: FIELD_EVALUATION_TRIGGER
    })
    wiredTriggerPickListValue({ data, error }){
        if(data){
            console.log(` Picklist values are `, data.values);
            this.triggerOptions = data.values;
            this.error = undefined;
        }
        if(error){
            console.log(` Error while fetching Picklist values  ${error}`);
            this.error = error;
            this.triggerOptions = [];
        }
    };

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [USER_PHONE,USER_EMAIL]
    }) wireuser({
        error,
        data
    }) {
        if (data) {
            if(!this.recordId){
                this.useritemList[0].User__c = this.userValue;
                this.useritemList[0].User_Phone__c = data.fields.Phone.value;
                this.useritemList[0].User_Email__c = data.fields.Email.value;
            }
        }
    }

    connectedCallback(){
        if(this.recordId){
            this.isEditMode = true;
            
            this.spinnerCounter++;
              //<T04>
              getObjectNames()
              .then(result => {
                  console.log('Object Edit mode picklist values are ', result);
                  var objectOptions = [];
                  result.forEach(element => {
                      console.log('Object edit mode picklist value - ', element);
                      var option = element.split(':');
                      objectOptions.push({label: option[0], value: option[1]});
                  });
                  this.objectOptions = objectOptions;
                  console.log('this.objectOptions - ', this.objectOptions);
                  this.spinnerCounter--;
              })
              .catch(error => {
                  this.spinnerCounter--;
                  console.log('ERROR IN getting the applicable objects list....' + JSON.stringify(error));
              })
              //</T04>
            getrelatedRecords({criteriaId : this.recordId})
            .then(result=>{
                this.criteriaRecord.fields.Id = this.recordId;
                this.criteriaRecord.fields.Name = result.notificationSubscription.Name;
                this.criteriaRecord.fields.Object__c = result.notificationSubscription.Object__c;
                this.criteriaRecord.fields.MS_Teams_Email__c = result.notificationSubscription.MS_Teams_Email__c;
                this.criteriaRecord.fields.SF_Chatter_Post_Email__c = result.notificationSubscription.SF_Chatter_Post_Email__c;
                this.criteriaRecord.fields.Evaluation_Trigger__c = result.notificationSubscription.Evaluation_Trigger__c;
                this.criteriaRecord.fields.Custom_Logic__c = result.notificationSubscription.Custom_Logic__c;
                this.criteriaRecord.fields.Condition__c	 = result.notificationSubscription.Condition__c;
                this.criteriaRecord.fields.Active__c = result.notificationSubscription.Active__c;
                this.criteriaRecord.fields.Template_Name__c = result.notificationSubscription.Template_Name__c;          
                this.criteriaRecord.fields.Notification_Type__c = result.notificationSubscription.Notification_Type__c;
                this.criteriaRecord.fields.Platform_Notification_Expiration__c = result.notificationSubscription.Platform_Notification_Expiration__c;
                this.criteriaRecord.types = result.notificationSubscription.Notification_Type__c.split(';');
                console.log('this.criteriaRecord >>', JSON.stringify(this.criteriaRecord));

                /**GET NOTIFICATION TYPES - add additional notification types if Platform notification is allowed for the object*/ //T05
                this.spinnerCounter++;
                var notificationTypeOptions = NOTIFICATION_TYPE_OPTIONS;
                allowNotificationAPI({objectAPIName: this.criteriaRecord.fields.Object__c})
                .then(result => {
                    //If Notification Platform Notification is allowed
                    if(result){
                        notificationTypeOptions = NOTIFICATION_TYPE_OPTIONS.concat(NOTIFICATION_TYPE_PLATFORM_OPTIONS);
                        this.recipientTypeOptions = this.recipientTypeOptions.concat(PLATFORM_NOTIFICATION_RECIPIENT_TYPE);
                    }
                    notificationTypeOptions.forEach(element => {
                        if(this.criteriaRecord.types.includes(element.value)){
                            element.selected = true;
                        }else{
                            element.selected = false;
                        }
                    });
                    this.notificationTypeOptions = [];
                    this.notificationTypeOptions = notificationTypeOptions;
                    console.log('this.notificationTypeOptions >>', JSON.stringify(this.notificationTypeOptions));
                    this.spinnerCounter--;                  
                })
                .catch(error => {
                    this.spinnerCounter--;
                    console.log('ERROR IN getting the value for allowNotificationAPI...' + JSON.stringify(error));
                })                

                this.notificationDetailList = result.notificationDetailList;
                this.notificationUserList = result.notificationUserList;
                console.log('this.notificationUserList >>', JSON.stringify(this.notificationUserList));
                
                /** Get the related field and Values */
                this.spinnerCounter++;
                getFieldInfo({objName : this.criteriaRecord.fields.Object__c})
                .then(result => {
                    console.log('result >> '+ JSON.stringify(result));       
                    this.fieldNameOptions = [];
                    this.fieldInfo = {};
                    result.forEach(fieldInfo => {
                               
                        if(fieldInfo.isActive){
                            this.fieldNameOptions.push({label : fieldInfo.label, value:fieldInfo.label, sortOrder:fieldInfo.sortOrder});
                        }
                        this.fieldInfo[fieldInfo.label] = {
                            apiName : fieldInfo.apiName,
                            datatype : fieldInfo.datatype, 
                            referredObjectName : fieldInfo.referredObjectName,
                            referredFieldAPIName : fieldInfo.referredFieldAPIName,
                            lookupRefObjectName : fieldInfo.lookupRefObjectName, //T06
							lookupFields: fieldInfo.lookupFields //T06
                        };
                    });
                    this.fieldNameOptions.sort(function(a, b){
                        return a.sortOrder - b.sortOrder;
                    });

                    console.log('this.fieldNameOptions >>> '+ JSON.stringify(this.fieldNameOptions));        
                    console.log('this.criteriaList >>> '+ JSON.stringify(this.criteriaList));  
                    this.criteriaList=[];

                    /** 1. Set the Notification Criteria records */
                    var count = 0;
                    this.notificationDetailList.forEach(exCriteria =>{
                        var showWarning = false;
                        if(count == 0 && this.criteriaRecord.fields.Object__c === 'Case_Comment__c'){
                            if(exCriteria.Field_API_Name__c === 'Status__c' && exCriteria.Operator__c === 'not equal to' && exCriteria.Value__c === 'Pre Draft'){
                                showWarning = true;
                            }
                        }
                        var fieldInfo = this.fieldInfo[exCriteria.Field_Name__c];
                        var newItem = { 
                            id: count, 
                            section : ++count, 
                            allowDelete : false,
                            operatorsList : [],
                            multipicklistOptions : [],
                            fieldAPIName : exCriteria.Field_API_Name__c,
                            fieldLabel : exCriteria.Field_Name__c,
                            operator : exCriteria.Operator__c,
                            fieldValue : exCriteria.Value__c,
                            fieldType : fieldInfo.datatype,
                            objectName : this.criteriaRecord.fields.Object__c,
                            referredObjectName : fieldInfo.referredObjectName, 
                            referredFieldAPIName : fieldInfo.referredFieldAPIName,
                            showWarning : showWarning,
                            lookupRefObjectName : fieldInfo.lookupRefObjectName,    //T06  
							lookupFields : fieldInfo.lookupFields,//T06
                            lookupRefRecName : exCriteria.Lookup_Record_Name__c//T06
                        };
                        this.criteriaList.push(newItem);
                    })
                    this.criteriaList[this.criteriaList.length-1].allowDelete = true;

                    console.log('this.criteriaList 2 >> '+ JSON.stringify(this.criteriaList));
                    
                    /** 2. Set the Notification User records */
                    this.useritemList = [];
                    var count = 0;
                    var allowDelete = false;

                    //T03
                    this.userTeamList = [];
                    var userTeamCount = 0;
                    var allowTeamDelete = false;

                    this.notificationUserList.forEach(exUser =>{
                        let userType = '';
                        if(exUser.User_Type__c){
                            userType = exUser.User_Type__c;
                        }

                        //T03
                        if(userType === '' || userType === 'User' || userType === 'Queue' || userType === 'Distribution List' || userType === 'All Org Users' || userType === 'Specific User Role'){
                            var newItem = { 
                                id : count++, 
                                allowDelete : allowDelete,
                                User_Type__c : exUser.User_Type__c,
                                User__c : exUser.User__c,
                                User_Phone__c : exUser.User_Phone__c,
                                User_Email__c : exUser.User_Email__c,
                                Queue_Name__c : exUser.Queue_Name__c,
                                Platform_Recipient_Role__c : exUser.Platform_Recipient_Role__c
                            };

                            //T03
                            newItem.isUser = false;
                            newItem.isQueue = false;
                            newItem.isDL = false;
                            if(userType === 'User'){
                                newItem.isUser = true;
                            }else if(userType === 'Queue'){
                                newItem.isQueue = true;
                            }else if(userType === 'Distribution List'){
                                newItem.isDL = true;
                            }else if(userType === 'All Org Users'){
                                newItem.isAllOrgUsers = true;
                            }else if(userType == 'Specific User Role'){
                                newItem.isSpecificUserRole = true;
                            }
            
                            this.useritemList.push(newItem);
                            allowDelete = true;
                        }else{
                            //T03
                            var userTeam = { 
                                id: userTeamCount++,
                                allowDelete : allowTeamDelete
                            };
                            userTeam.User_Type__c = exUser.User_Type__c;
                            if(exUser.Account_Case_Fields__c!==undefined && exUser.Account_Case_Fields__c!==""){
                                userTeam.Account_Case_Fields__c = exUser.Account_Case_Fields__c;
                            }
                            if(exUser.Team_Member_Role__c!==undefined && exUser.Team_Member_Role__c!==""){
                                userTeam.Team_Member_Role__c = exUser.Team_Member_Role__c;
                            }
                            //T03
                            if(exUser.Related_Fields__c!==undefined && exUser.Related_Fields__c!==""){
                                userTeam.Related_Fields__c = exUser.Related_Fields__c;
                            }
                            this.userTeamList.push(userTeam);
                            allowTeamDelete = true;
                        }
                    })
                    //T02 added empty item as default
                    if(this.useritemList.length == 0){
                        this.useritemList.push({id: 0, allowDelete: false});
                    }
                    
                    console.log('this.useritemList >> '+ JSON.stringify(this.useritemList));
                    console.log('this.userTeamList >> '+ JSON.stringify(this.userTeamList));
                    
                    /**3. Get the field type and Operators */
                    this.criteriaList.forEach(child =>{            
                        DATATYPE_OPERATORS[child.fieldType].forEach(operator =>{
                            child.operatorsList.push({label : operator, value : operator});
                        }); 
                            
                        if(child.fieldType ==='PICKLIST' || child.fieldType ==='MULTIPICKLIST'){
                            if(child.fieldAPIName.endsWith('RecordTypeId')){
                                this.spinnerCounter++;
                                getRecordTypes({
                                    objectAPIName : child.referredObjectName
                                })
                                .then(result => {
                                    var options = [];
                                    for(var key in result){
                                        let option = {label : key, value : result[key], selected:false};
                                        if(child.fieldValue.split(',').includes(result[key])){
                                            option.selected = true;
                                        }
                                        options.push(option);
                                    }
                                    child.multipicklistOptions = options;
                                    this.spinnerCounter--;
                                })
                                .catch(error => {
                                    this.spinnerCounter--;
                                    console.log('ERROR IN getRecordTypes ....' + JSON.stringify(error));
                                });
                            }else if(child.fieldAPIName.endsWith('OwnerId')){
                                this.spinnerCounter++;
                                getQueueNames({
                                    objectAPIName : this.criteriaRecord.fields.Object__c,
                                    fieldAPIName : child.fieldAPIName
                                })
                                .then(result => {
                                    var options = [];
                                    for(var key in result){
                                        let option = {label : key, value : result[key], selected:false};
                                        if(child.fieldValue.split(',').includes(result[key])){
                                            option.selected = true;
                                        }
                                        options.push(option);
                                    }
                                    child.multipicklistOptions = options;
                                    this.spinnerCounter--;
                                })
                                .catch(error => {
                                    this.spinnerCounter--;
                                    console.log('ERROR IN GETQUEUENAMES ....' + JSON.stringify(error));
                                });
                            }else{
                                this.spinnerCounter++;
                                getPicklistValue({
                                    objName: this.criteriaRecord.fields.Object__c, 
                                    fieldName : child.fieldAPIName 
                                })
                                .then(result => {
                                    console.log('picklistValue >> '+ JSON.stringify(result));
                                    var options = [];
                                    for(var key in result){
                                        let option = {label : key, value : result[key], selected:false};
                                        if(child.fieldValue.split(',').includes(result[key])){
                                            option.selected = true;
                                        }
                                        options.push(option);
                                    }
                                    child.multipicklistOptions = options;
                                    this.spinnerCounter--;
                                })
                                .catch(error => {
                                    this.spinnerCounter--;
                                    console.log('ERROR IN GETPICKLIST VALUE ....' + JSON.stringify(error));
                                });
                            }
                        }
                    }); 
                    
                    /** 2. get Account / Case / User fields for Account/CaseTeam */
                    getAccountCaseFields({objName: this.criteriaRecord.fields.Object__c})
                    .then(result =>{
                        /**Get Account Lookup fields from the selected Object */
                        this.accountFieldOptions =[];
                        // this.caseFieldOptions =[];
                        this.CaseTeamMemberRoleOptions =[];
                        this.AccountTeamMemberRoleOptions =[];
                        this.planteamRoleOptions=[];
                        this.userFieldOptions =[];
                        this.queueOptions=[];
                        this.OpportunityTeamMemberRoleOptions=[];
                        this.opportunityFieldOptions =[];
                        
                        result[0].split(',').forEach(element => {                            
                            this.accountFieldOptions.push({label:element,value:element});
                        })

                        result[1].split(',').forEach(element => {                            
                            this.AccountTeamMemberRoleOptions.push({label:element,value:element,selected:false});
                        })

                        result[2].split(',').forEach(element => {                            
                            this.CaseTeamMemberRoleOptions.push({label:element,value:element,selected:false});
                        })

                        result[3].split(',').forEach(element => {                            
                            this.planteamRoleOptions.push({label:element,value:element,selected:false});
                        })

                        //T03
                        result[4].split(',').forEach(element => {       
                            let namevalue = element.split('-');                     
                            this.userFieldOptions.push({label:namevalue[0],value:namevalue[1],selected:false});
                        })
                        //T03
                        result[5].split(',').forEach(element => {                          
                            let namevalue = element.split('-');                     
                            this.queueOptions.push({label:namevalue[0],value:namevalue[1],selected:false});
                        })

                        //T03
                        result[6].split(',').forEach(element => {                          
                            let namevalue = element.split('-');                     
                            this.OpportunityTeamMemberRoleOptions.push({label:element,value:element,selected:false});
                        })

                        result[7].split(',').forEach(element => {                            
                            this.opportunityFieldOptions.push({label:element,value:element});
                        })
                        this.opportunityFieldOptions.push({label:"Id",value:"Id"});

                        
                        console.log('Team Role '+ JSON.stringify(this.AccountTeamMemberRoleOptions));
                        
                        /** 3. Set the Notification User records */
                        //T03
                        if(this.userTeamList.length == 0){
                            this.userTeamList.push({
                                id: 0, 
                                allowDelete: true,
                                TeamMemberOptions: this.AccountTeamMemberRoleOptions,
                                TeamRoleOptions: this.CaseTeamMemberRoleOptions,
                                PlanTeamOptions: this.planteamRoleOptions,
                                userFieldOptions: this.userFieldOptions,
                                OpportunityTeamOptions: this.OpportunityTeamMemberRoleOptions
                            });
                        }
    
                        this.userTeamList.forEach(userTeam =>{
                            var Options = [];
                            if(userTeam.User_Type__c === 'Account Team'){
                                userTeam.isAccountTeam = true; //T03
                                this.AccountTeamMemberRoleOptions.forEach(key=>{
                                    let plabel = key.value;
                                    let pvalue = key.value;
                                    if(userTeam.Team_Member_Role__c && userTeam.Team_Member_Role__c.split(',').includes(pvalue)){
                                        Options.push({label:plabel,value:pvalue,selected:true});
                                    }else{
                                        Options.push({label:plabel,value:pvalue,selected:false});
                                    }
                                })
                                userTeam.TeamMemberOptions = Options;
                            }else if(userTeam.User_Type__c === 'Case Team'){
                                userTeam.isCaseTeam = true; //T03
                                this.CaseTeamMemberRoleOptions.forEach(key=>{
                                    let plabel = key.value;
                                    let pvalue = key.value;
                                    console.log('userTeam.Team_Member_Role__c:'+userTeam.Team_Member_Role__c);
                                   
                                    if(userTeam.Team_Member_Role__c && userTeam.Team_Member_Role__c.split(',').includes(pvalue)){
                                        Options.push({label:plabel,value:pvalue,selected:true});
                                    }else{
                                        Options.push({label:plabel,value:pvalue,selected:false});
                                    }
                                })
                                userTeam.TeamRoleOptions = Options;
                            }else if(userTeam.User_Type__c === 'Plan Team'){
                                userTeam.isPlanTeam = true; //T03
                                this.planteamRoleOptions.forEach(key=>{
                                    let plabel = key.value;
                                    let pvalue = key.value;
    
                                    if(userTeam.Team_Member_Role__c && userTeam.Team_Member_Role__c.split(',').includes(pvalue)){
                                        Options.push({label:plabel,value:pvalue,selected:true});
                                    }else{
                                        Options.push({label:plabel,value:pvalue,selected:false});
                                    }
                                })
                                userTeam.PlanTeamOptions = Options;
                            //T03
                            }else if(userTeam.User_Type__c === 'Related User'){
                                userTeam.isRelatedUser = true;
                                this.userFieldOptions.forEach(key=>{
                                    let plabel = key.label;
                                    let pvalue = key.value;
                                    
                                    if(userTeam.Related_Fields__c && userTeam.Related_Fields__c.split(',').includes(pvalue)){
                                        Options.push({label:plabel,value:pvalue,selected:true});
                                    }else{
                                        Options.push({label:plabel,value:pvalue,selected:false});
                                    }
                                })
                                userTeam.userFieldOptions = Options;
                            }else if(userTeam.User_Type__c === 'Opportunity Team'){
                                userTeam.isOpportunityTeam = true; //T03
                                this.OpportunityTeamMemberRoleOptions.forEach(key=>{
                                    let plabel = key.value;
                                    let pvalue = key.value;
    
                                    if(userTeam.Team_Member_Role__c && userTeam.Team_Member_Role__c.split(',').includes(pvalue)){
                                        Options.push({label:plabel,value:pvalue,selected:true});
                                    }else{
                                        Options.push({label:plabel,value:pvalue,selected:false});
                                    }
                                })
                                userTeam.OpportunityTeamOptions = Options;
                            }

                        });
                        console.log('this.userTeamList @@ '+ JSON.stringify(this.userTeamList));
                    })
                    .catch(error =>{
                        console.log('ERROR IN getting the list of Account/case fields....' + JSON.stringify(error));
                    })

                    /**4. get template options */
                    this.spinnerCounter++;
                    getTemplates({objName: this.criteriaRecord.fields.Object__c})
                    .then(result => {
                        console.log('Object picklist values are ', result);
                        var templateOptions = [];
                        result.forEach(element => {
                            console.log('Object picklist value - ', element);
                            var option = element.split(':');
                            templateOptions.push({label: option[0], value: option[1]});
                        });
                        this.templateOptions = templateOptions;
                        console.log('this.templateOptions - ', this.templateOptions);
                        this.spinnerCounter--;
                    })
                    .catch(error => {
                        this.spinnerCounter--;
                        console.log('ERROR IN getting the list of templates....' + JSON.stringify(error));
                    })

                    this.spinnerCounter--;
                })
                .catch(error => {
                    this.spinnerCounter--;

                    console.log('ERROR IN CONNECTED CALLBACK....' + JSON.stringify(error));
                });
                this.spinnerCounter--;
            })
            .catch(error=>{
                this.spinnerCounter--;
                console.log('Error in connectedCallBack : '+error);
            })
        }else{
            this.criteriaRecord.fields.Custom_Logic__c ='1';

            var notificationTypeOptions = NOTIFICATION_TYPE_OPTIONS;
            notificationTypeOptions.forEach(element => {
                element.selected = false;
            });
            this.notificationTypeOptions = [];
            this.notificationTypeOptions = notificationTypeOptions;

            this.spinnerCounter++;
            getObjectNames()
            .then(result => {
                console.log('Object picklist values are ', result);
                var objectOptions = [];
                result.forEach(element => {
                    console.log('Object picklist value - ', element);
                    var option = element.split(':');
                    objectOptions.push({label: option[0], value: option[1]});
                });
                this.objectOptions = objectOptions;
                console.log('this.objectOptions - ', this.objectOptions);
                this.spinnerCounter--;
            })
            .catch(error => {
                this.spinnerCounter--;
                console.log('ERROR IN getting the applicable objects list....' + JSON.stringify(error));
            })
        }
    }
    
    previewTemplate(event){        
        if(this.criteriaRecord.fields.Template_Name__c && this.criteriaRecord.fields.Object__c){
            this.spinnerCounter++;
            this.templatePreview = 'Loading the preview, please wait...';
            getTemplatePreview({
                templateName : this.criteriaRecord.fields.Template_Name__c, 
                objectAPIName : this.criteriaRecord.fields.Object__c
            })
            .then(result => {
                console.log('result >>', JSON.stringify(result));
                this.templatePreview = '<b>Title: </b>' + result.title + '<br/><br/><b>Body: </b></br>' + result.bodyHTML;
                this.spinnerCounter--;
                this.showPreview = true;
            })
            .catch(error => {
                console.log('error >>', error);
                this.spinnerCounter--;
            })    
        }else{
            var errorMsg = 'Please select the Object and then the Template to be previewed';
            if(this.criteriaRecord.fields.Object__c){
                errorMsg = 'Please select the Template to be previewed';
            }
            /** Show error message **/
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error : ',
                    message: errorMsg,
                    variant: 'error',
                }),
            );    
        }
    }

    closePreview(event){
        this.showPreview = false;
    }

    handleCriteriaLineValueChange(event){
        console.log('event.detail >>', event.detail);
        console.log('event.target.accessKey >>', event.target.accessKey);

        var fkey = event.target.accessKey; 
        var curItem = this.criteriaList[fkey];
        curItem.fieldValue = event.detail;
        if(event.detail=== undefined|| event.detail ==='' || event.detail===null){           
            curItem.lookupRefRecName='';
        }
        if(curItem.multipicklistOptions.length > 0){
            var fieldValueNames = [];
            var fieldValues = curItem.fieldValue.split(',');
            curItem.multipicklistOptions.forEach(element => {
                if(fieldValues.includes(element.value)){
                    fieldValueNames.push(element.label);
                }
            });
            curItem.fieldValueNames = fieldValueNames.join(',');
        }
        console.log('curItem >>', JSON.stringify(curItem));
    }

    /** To default the Custom Logic on row creation */
    setCustomLogic(){
        var sections = [];
        this.criteriaList.forEach(element => {
            sections.push(element.section);
        });
        var defaultLogic = sections.join(' AND ');
        
        this.criteriaRecord.fields.Custom_Logic__c = defaultLogic;
        //console.log('criteriaList setCustomLogic >>>'+ this.criteriaList);
    }

    /** To add a row */
    addRow() {
        this.criteriaList.forEach(element => {
            element.allowDelete = false;
        });

        let newItemId = this.criteriaList.length;
        var newItem = { 
            id: newItemId, 
            section : newItemId + 1, 
            allowDelete : true,
            operatorsList:[],
            multipicklistOptions:[]
        };

        this.criteriaList.push(newItem);

        this.setCustomLogic();

        console.log('criteriaList >>>'+ this.criteriaList);
    }

    /** To delete a row */
    removeRow(event) {
        this.criteriaList = this.criteriaList.filter(function (element) {
            return parseInt(element.id) !== parseInt(event.target.accessKey);
        });

        if(this.criteriaList.length > 1){
            this.criteriaList[this.criteriaList.length-1].allowDelete = true;
        }

        this.setCustomLogic();

        console.log('criteriaList >>>'+ this.criteriaList);
    }

    getfilterCriteriaFields(event){
        this.spinnerCounter++;
        getFieldInfo({objName : this.criteriaRecord.fields.Object__c})
        .then(result => {
            console.log('result >> '+ JSON.stringify(result));       
            this.fieldNameOptions = [];
            this.fieldInfo = {};
            result.forEach(fieldInfo => {
                //console.log('fieldInfo >>> '+ JSON.stringify(fieldInfo));        
                if(fieldInfo.isActive){
                    this.fieldNameOptions.push({label : fieldInfo.label, value:fieldInfo.label, sortOrder:fieldInfo.sortOrder});
                }
                this.fieldInfo[fieldInfo.label] = {
                    apiName : fieldInfo.apiName,
                    datatype : fieldInfo.datatype, 
                    referredObjectName : fieldInfo.referredObjectName,
                    referredFieldAPIName : fieldInfo.referredFieldAPIName,
                    lookupRefObjectName : fieldInfo.lookupRefObjectName,//T06
					lookupFields : fieldInfo.lookupFields //T06
                };
            });
            this.fieldNameOptions.sort(function(a, b){
                return a.sortOrder - b.sortOrder;
            });

            console.log('this.fieldNameOptions getfilterCriteriaFields>>> '+ JSON.stringify(this.fieldNameOptions));        
            console.log('this.criteriaList getfilterCriteriaFields>>> '+ JSON.stringify(this.criteriaList));        

            this.spinnerCounter--;
        })
        .catch(error => {
            this.spinnerCounter--;
            console.log('ERROR IN getfilterCriteriaFields...' + JSON.stringify(error));
        });
    }

    getOptionsFromMap(valueMap){
        console.log('values >> '+ JSON.stringify(valueMap));
        
        var options = []; 
        for(var key in valueMap){
            let label = key;
            let value = valueMap[key];
            options.push({label : label, value : value});
        }
        return options;
    }

    handlefieldNamechange(event){
        try{
            var fkey = event.target.accessKey; 
            console.log('fkey handlefieldNamechange >> '+ fkey);

            var curItem = this.criteriaList[fkey];
            console.log('curItem handlefieldNamechange>> '+ JSON.stringify(curItem));

            let fieldLabel = event.target.value;
            console.log('fieldLabel >> '+ fieldLabel);

            var fieldInfo = this.fieldInfo[fieldLabel];
            var fieldAPI = fieldInfo.apiName;
            console.log('fieldAPI >> '+ fieldAPI);
            var fieldType = fieldInfo.datatype;
            console.log('fieldType >> '+ fieldType);
            
            
            if(fieldAPI){
                curItem.fieldLabel = fieldLabel;
                curItem.fieldAPIName = fieldAPI;     
                curItem.fieldType = fieldType;
                curItem.objectName = this.criteriaRecord.fields.Object__c;
                curItem.referredObjectName = fieldInfo.referredObjectName; 
                curItem.referredFieldAPIName = fieldInfo.referredFieldAPIName;
                curItem.multipicklistOptions = [];
                curItem.lookupRefObjectName=fieldInfo.lookupRefObjectName; //T06
                curItem.lookupFields=fieldInfo.lookupFields;//T06 
                curItem.fieldValue=fieldInfo.fieldValue?fieldInfo.fieldValue:'';//T06
                curItem.lookupRefRecName=fieldInfo.lookupRefRecName?fieldInfo.lookupRefRecName:'';//T06
            }else{
                curItem.fieldAPIName =''; 
            }
            console.log('curItem >> '+ JSON.stringify(curItem));

            let operatorList = DATATYPE_OPERATORS[fieldType];
            console.log('operatorList >> '+ JSON.stringify(operatorList));

            this.template.querySelectorAll('lightning-combobox').forEach(comboBox => {
                if(comboBox.name === 'Operator' && comboBox.accessKey === fkey){
                    let optionArray =[];
                    operatorList.forEach( operator => {
                        optionArray.push({label:operator, value:operator});
                    });
                    comboBox.options = optionArray;            
                }
            });
            
            console.log('this.criteriaList  handlefieldNamechange>> '+ this.criteriaList + 'fieldAPI >>> '+ fieldAPI);

            if(fieldType==='PICKLIST' || fieldType==='MULTIPICKLIST'){
                if(fieldAPI.indexOf('RecordTypeId') !== -1){
                    this.spinnerCounter++;
                    getRecordTypes({
                        objectAPIName : curItem.referredObjectName
                    })
                    .then(result => {
                        curItem.multipicklistOptions = this.getOptionsFromMap(result);
                        this.spinnerCounter--;
                    })
                    .catch(error => {
                        this.spinnerCounter--;
                        console.log('ERROR IN getRecordTypes ....' + JSON.stringify(error));
                    });
                }else if(fieldAPI.indexOf('OwnerId') !== -1){
                    this.spinnerCounter++;
                    getQueueNames({
                        objectAPIName : this.criteriaRecord.fields.Object__c,
                        fieldAPIName : fieldAPI
                    })
                    .then(result => {
                        curItem.multipicklistOptions = this.getOptionsFromMap(result);
                        this.spinnerCounter--;
                    })
                    .catch(error => {
                        this.spinnerCounter--;
                        console.log('ERROR IN GETQUEUENAMES ....' + JSON.stringify(error));
                    });
                }else{
                    console.log('Inside the PICKLIST');  
                    this.spinnerCounter++;
                    getPicklistValue({objName: this.criteriaRecord.fields.Object__c , fieldName : fieldAPI})
                    .then(result => {
                        curItem.multipicklistOptions = this.getOptionsFromMap(result);
                        this.spinnerCounter--;
                    })
                    .catch(error => {
                        this.spinnerCounter--;
                        console.log('ERROR IN GETPICKLIST VALUE ....' + JSON.stringify(error));
                    });    
                }
            }else if(fieldType==='REFERENCE'){
                curItem.lookupRefRecName='';//T06 //lookupRefRecName
                curItem.fieldValue='';
            }
        } catch(error){
            this.spinnerCounter--;
            console.log('ERROR IN FIELDNAME CHANGE ....' + JSON.stringify(error));
        }
        console.log('this.criteriaList fin >>> '+ JSON.stringify(this.criteriaList));
    }

    handleoperatorChange(event){
        var fkey = event.target.accessKey; 

        if(event.target.value){
            this.criteriaList[fkey].operator = event.target.value;
        }else{
            this.criteriaList[fkey].operator = ''; 
        }
        console.log('this.criteriaList >>> '+ JSON.stringify(this.criteriaList));
    }

    handleCustomLogicChange(event){
        this.criteriaRecord.fields.Custom_Logic__c = event.target.value;
    }

    /**Generate Dynamic Condition based on user input and fieldType */
    generateFilterCondition(event){
        var result = [];

        this.criteriaList.forEach(criteria => {

            console.log('criteria >> ', JSON.stringify(criteria));

            var strCondition ='';
            var fieldAPI = criteria.fieldAPIName;
            var datatype = criteria.fieldType;

            if(criteria.operator === 'equals'){
                if(datatype==='STRING' || datatype==='REFERENCE' || datatype==='TEXTAREA' || datatype==='ID' || datatype==='EMAIL'){
                    strCondition+= fieldAPI;
                    strCondition+=  ' == ';
                    strCondition+= ' \'' +criteria.fieldValue +'\'';
                }
                else if(datatype==='PICKLIST' || datatype==='MULTIPICKLIST'){
                    if(criteria.fieldValue.indexOf(',') !== -1){
                        var valueList = criteria.fieldValue.split(',');
                        strCondition += '( ';  
                        valueList.forEach(str =>{
                        strCondition += fieldAPI;
                        strCondition += ' == ';
                        strCondition += '\'' + str + '\' || ';
                        })
                        strCondition = strCondition.substring(0, strCondition.length - 4);//remove the last occurance of ' || '
                        strCondition += ' ) ';
                    }else{
                        strCondition += fieldAPI;
                        strCondition += ' == ';
                        strCondition += ' \'' +criteria.fieldValue +'\'';
                    }
                }else if(datatype==='BOOLEAN'){
                    strCondition += fieldAPI;
                    strCondition += ' == ';
                    strCondition += criteria.fieldValue;
                }else{
                    strCondition += fieldAPI;
                    strCondition += ' == ';
                    strCondition += ' \'' +criteria.fieldValue +'\'';
                }
            }else if(criteria.operator === 'not equal to'){
                if(datatype==='STRING' || datatype==='REFERENCE' || datatype==='TEXTAREA' || datatype==='ID' || datatype==='EMAIL'){
                    strCondition+= fieldAPI;
                    strCondition+=  ' != ';
                    strCondition+= ' \'' +criteria.fieldValue +'\'';
                }
                else if(datatype==='PICKLIST' || datatype==='MULTIPICKLIST'){
                    if(criteria.fieldValue.indexOf(',') !== -1){
                        var valueList = criteria.fieldValue.split(',');
                        strCondition += '( ';  
                        valueList.forEach(str =>{
                            strCondition += criteria.fieldAPIName;
                            strCondition += ' != ';
                            strCondition += '\'' + str + '\' && ';
                        })
                        strCondition = strCondition.substring(0, strCondition.length - 4);//remove the last occurance of ' || '
                        strCondition += ' ) ';
                    }else{
                        strCondition += fieldAPI;
                        strCondition += ' != ';
                        strCondition += ' \'' +criteria.fieldValue +'\'';
                    }
                }else if(datatype==='BOOLEAN'){
                    strCondition += fieldAPI;
                    strCondition += ' != ';
                    strCondition += criteria.fieldValue;
                }else{
                    strCondition += fieldAPI;
                    strCondition += ' != ';
                    strCondition += ' \'' +criteria.fieldValue +'\'';
                }
            }else if(criteria.operator === 'contains'){
                strCondition += fieldAPI;
                strCondition += '.contains(\'';
                strCondition += criteria.fieldValue;
                strCondition += '\')';
            }else if(criteria.operator === 'does not contain'){
                strCondition += '(!';
                strCondition += fieldAPI;
                strCondition += '.contains(\'';
                strCondition += criteria.fieldValue;
                strCondition += '\'))';
            }else if(criteria.operator === 'starts with'){
                strCondition += '(!';
                strCondition += fieldAPI;
                strCondition += '.startsWith(\'';
                strCondition += criteria.fieldValue;
                strCondition += '\'))';
            }else if(criteria.operator === 'less than'){
                strCondition += fieldAPI;
                strCondition += ' < ';
                strCondition += criteria.fieldValue ;   
            }else if(criteria.operator === 'greater than'){
                strCondition += fieldAPI;
                strCondition += ' > ';
                strCondition += criteria.fieldValue ;
            }else if(criteria.operator === 'less or equal'){
                strCondition += fieldAPI;
                strCondition += ' <= ';
                strCondition += criteria.fieldValue ;
            }else if(criteria.operator === 'greater or equal'){
                strCondition += fieldAPI;
                strCondition += ' >= ';
                strCondition += criteria.fieldValue ;
            }
            result.push(strCondition);
        });

        
    
        var finalLogicString = this.criteriaRecord.fields.Custom_Logic__c;       
        /** Replace the logic numbers with filter condition */        
        for(var i=1 ; i<=this.criteriaList.length ; i++){
           // var regex = new RegExp('[' + i + ']', 'g');   
           var regex = new RegExp('\\b' + i + '\\b', 'g'); //T07
            var replaceStr = i + '####'; 
            finalLogicString = finalLogicString.replace(regex, replaceStr);           
        }
        finalLogicString = finalLogicString.replaceAll('AND' , '&&').replaceAll('OR' , '||').replaceAll('and','&&').replaceAll('or','||');

        
        for(var i=1 ; i<=this.criteriaList.length ; i++){
           // var regex = new RegExp(i + '####', 'g');
           var regex = new RegExp('\\b' + i + '\\b' + '####', 'g'); ////T07 will replace the standalone integer . It won't replace '1' in '11' or '12' because the regular expression only matches the digit '1' 
            finalLogicString = finalLogicString.replace(regex, result[i-1]);
        }
         finalLogicString = finalLogicString.replaceAll('  ' , ' ');  
        this.criteriaRecord.fields.Condition__c = finalLogicString;

    }

    handleCriteriaFieldChange(event) {
        switch (event.currentTarget.name) {
            case 'criteriaName':
                this.criteriaRecord.fields.Name = event.currentTarget.value;
                break;
            case 'criteriaActive':
                this.criteriaRecord.fields.Active__c = event.currentTarget.checked;
                console.log('Active : '+event.currentTarget.checked);
                break;
            case 'criteriaTeamsEmail':
                this.criteriaRecord.fields.MS_Teams_Email__c = event.currentTarget.value;
                break;
            case 'criteriaChatterEmail':
                this.criteriaRecord.fields.SF_Chatter_Post_Email__c = event.currentTarget.value;
                break;
            case 'criteriaExpiryDay': //T05 - capture the expiry date for platform notification
                this.criteriaRecord.fields.Platform_Notification_Expiration__c = event.currentTarget.value;
                break;
            case 'criteriaTrigger':
                this.criteriaRecord.fields.Evaluation_Trigger__c = event.currentTarget.value;
                break;
            case 'criteriaTemplate':
                this.criteriaRecord.fields.Template_Name__c = event.currentTarget.value;
                break;
            case 'criteriaObject':
                this.objectValueOld = this.criteriaRecord.fields.Object__c;
                this.objectValueNew = event.currentTarget.value;
                if(this.criteriaRecord.fields.Object__c){
                    /**Open the popup if the object value is Updated */    
                    this.showConfirmationModal = true;                
                }else{
                    this.criteriaRecord.fields.Object__c = this.objectValueNew;
                    this.handleObjectChange();
                }
                break;
            case 'criteriaNotifType':
                this.criteriaRecord.types = event.detail;
                this.criteriaRecord.fields.Notification_Type__c = this.criteriaRecord.types.join(';');

                var types = this.criteriaRecord.types;

                break;
        }
    }

    /**Object change */
    cancelObjectChange(){
        this.criteriaRecord.fields.Object__c = this.objectValueOld;
        console.log(this.criteriaRecord.fields.Object__c);
        this.template.querySelectorAll('lightning-combobox').forEach(comboBox => {
            if(comboBox.name === 'criteriaObject'){
                comboBox.value = this.objectValueOld;
            }
        });

        this.showConfirmationModal = false;
    }

    saveObjectChange(){
        this.criteriaRecord.fields.Object__c = this.objectValueNew;
        this.showConfirmationModal = false;
        this.handleObjectChange();
    }

    handleObjectChange(){
        this.fieldNameOptions = [];

        //reset the filter logic
        this.criteriaRecord.fields.Custom_Logic__c = '1';

        //Create new Item
        var newItem = { 
            id: 0, 
            section : 1, 
            allowDelete:false,
            operatorsList:[],
            multipicklistOptions:[]
        }; 

        /**GET NOTIFICATION TYPES - add additional notification types if Platform notification is allowed for the object*/ //T05                
        this.spinnerCounter++;                
        var notificationTypeOptions = NOTIFICATION_TYPE_OPTIONS;
        allowNotificationAPI({objectAPIName: this.criteriaRecord.fields.Object__c})
        .then(result => {
            //If Notification Platform Notification is allowed
            if(result){
                console.log('##Return NOTIFICATION_TYPE_OPTIONS + NOTIFICATION_TYPE_PLATFORM_OPTIONS');
                notificationTypeOptions = NOTIFICATION_TYPE_OPTIONS.concat(NOTIFICATION_TYPE_PLATFORM_OPTIONS);                
                this.recipientTypeOptions = this.recipientTypeOptions.concat(PLATFORM_NOTIFICATION_RECIPIENT_TYPE);
            }
            this.notificationTypeOptions = [];
            this.notificationTypeOptions = notificationTypeOptions;
            console.log('##this.notificationTypeOptions >>', JSON.stringify(this.notificationTypeOptions)); 
            this.spinnerCounter--;                   
        })
        .catch(error => {
            this.spinnerCounter--;
            console.log('ERROR IN getting the value for allowNotificationAPI...' + JSON.stringify(error));
        }) 

        this.criteriaList = [];
        if(this.criteriaRecord.fields.Object__c === 'Case_Comment__c'){
            this.criteriaRecord.fields.Evaluation_Trigger__c = 'Create/Edit';
            this.template.querySelectorAll('lightning-combobox').forEach(comboBox => {
                if(comboBox.name === 'criteriaTrigger'){
                    comboBox.value = this.criteriaRecord.fields.Evaluation_Trigger__c;
                }
            });
            
            this.criteriaList.push(CASE_COMMENT_DEFAULT_CRITERIA);
            this.criteriaRecord.fields.Custom_Logic__c = '1 AND 2';
            newItem.id = 1;
            newItem.section = 2;
            newItem.allowDelete = true;
        }

        this.criteriaList.push(newItem);
        
        this.getfilterCriteriaFields();

        this.spinnerCounter++;
        getTemplates({objName: this.criteriaRecord.fields.Object__c})
        .then(result => {
            console.log('Object picklist values are ', result);
            var templateOptions = [];
            result.forEach(element => {
                console.log('Object picklist value - ', element);
                var option = element.split(':');
                templateOptions.push({label: option[0], value: option[1]});
            });
            this.templateOptions = templateOptions;
            console.log('this.templateOptions - ', this.templateOptions);
            this.spinnerCounter--;
        })
        .catch(error => {
            this.spinnerCounter--;
            console.log('ERROR IN getting the list of templates....' + JSON.stringify(error));
        })

        /**get Account and Case Fields */
        getAccountCaseFields({objName: this.criteriaRecord.fields.Object__c})
        .then(result =>{
            /**Get Account Lookup fields from the selected Object */
            this.accountFieldOptions =[];
            this.userFieldOptions=[];
            this.AccountTeamMemberRoleOptions =[];
            this.CaseTeamMemberRoleOptions =[];
            this.planteamRoleOptions =[];
            this.queueOptions =[];
            this.OpportunityTeamMemberRoleOptions=[]
            this.opportunityFieldOptions =[];
            
            result[0].split(',').forEach(element => {                            
                this.accountFieldOptions.push({label:element,value:element});
            })

            result[1].split(',').forEach(element => {                            
                this.AccountTeamMemberRoleOptions.push({label:element,value:element,selected :false});
            })

            result[2].split(',').forEach(element => {                            
                this.CaseTeamMemberRoleOptions.push({label:element,value:element,selected :false});
            })

            result[3].split(',').forEach(element => {                          
                this.planteamRoleOptions.push({label:element,value:element,selected :false});
            })

            //T03
            result[4].split(',').forEach(element => {                         
                let namevalue = element.split('-');                     
                this.userFieldOptions.push({label:namevalue[0],value:namevalue[1],selected:false});
            })

            //T03
            result[5].split(',').forEach(element => {                          
                let namevalue = element.split('-');                     
                this.queueOptions.push({label:namevalue[0],value:namevalue[1],selected:false});
            })

            result[6].split(',').forEach(element => {                          
                let namevalue = element.split('-');                     
                this.OpportunityTeamMemberRoleOptions.push({label:element,value:element,selected :false});
            })

            result[7].split(',').forEach(element => {                          
                let namevalue = element.split('-');                     
                this.opportunityFieldOptions.push({label:element,value:element});
            })

            
            this.userTeamList = [];
            var newItem = { 
                id: 0, 
                allowDelete: false, 
                TeamMemberOptions: this.AccountTeamMemberRoleOptions,
                TeamRoleOptions: this.CaseTeamMemberRoleOptions,
                PlanTeamOptions: this.planteamRoleOptions,
                userFieldOptions: this.userFieldOptions,
                OpportunityTeamOptions: this.OpportunityTeamMemberRoleOptions
            };
            this.userTeamList.push(newItem);
    
        })
        .catch(error =>{
            console.log('ERROR IN getting the list of Account/case fields....' + JSON.stringify(error));
        })
    }
    
    addUserRow() {
        let newItemId = this.useritemList[this.useritemList.length - 1].id + 1;
        
        var newItem = { 
            id: newItemId, 
            allowDelete: true 
        };
        this.useritemList.push(newItem);
    }

    /** To delete a user row */
    removeUserRow(event) {
        console.log('useritemList >>> '+ JSON.stringify(this.useritemList));
        if (this.useritemList.length >= 1) {
            this.useritemList = this.useritemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
        console.log('useritemList >>> '+ JSON.stringify(this.useritemList));
    }

    //T03
    addUserTeamRow() {
        let newItemId = this.userTeamList[this.userTeamList.length - 1].id + 1;
        
        var newItem = { 
            id: newItemId, 
            allowDelete: true, 
            TeamMemberOptions: this.AccountTeamMemberRoleOptions,
            TeamRoleOptions: this.CaseTeamMemberRoleOptions,
            PlanTeamOptions: this.planteamRoleOptions,
            userFieldOptions: this.userFieldOptions,
            OpportunityTeamOptions: this.OpportunityTeamMemberRoleOptions
        };
        this.userTeamList.push(newItem);
    }

    //T03
    /** To delete a user team row */
    removeUserTeamRow(event) {
        console.log('userTeamList >>> '+ JSON.stringify(this.userTeamList));
        if (this.userTeamList.length >= 1) {
            this.userTeamList = this.userTeamList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
        console.log('userTeamList >>> '+ JSON.stringify(this.userTeamList));
    }

    handleUserFieldChange(event) {
        console.log('this.useritemList >>> '+ JSON.stringify(this.useritemList));
        var selectedRow = event.currentTarget;
        console.log('selectedRow >>> '+ JSON.stringify(selectedRow));
        var key = selectedRow.dataset.id;
        console.log('key >>> '+ key);
        //this.currentUserItem = this.useritemList[key];
        this.useritemList.forEach(element => {
            console.log('element >>> '+ JSON.stringify(element));
            if(element.id == key){
                this.currentUserItem = element;
            }
        });

        //T03
        this.userTeamList.forEach(element => {
            console.log('element >>> '+ JSON.stringify(element));
            if(element.id == key){
                this.currentUserTeam = element;
            }
        });

        var userValue = '';

        /**Get the selected user value */
        this.template.querySelectorAll('lightning-input-field').forEach(input => {
            if(input.dataset.id === key && input.fieldName === 'User__c'){
                userValue = input.value;
            }
        });
        
        switch (event.currentTarget.name){
            case 'User__c':
                if(userValue){
                    this.currentUserItem.User__c = event.target.value;
                    console.log('getting user details >>', this.currentUserItem.User__c);
                    this.spinnerCounter++;
                    getUserData({
                        userId: this.currentUserItem.User__c
                    })
                    .then(result => {
                        console.log('user details >>', result);
                        if (result) {
                            if(result.Phone){
                                this.currentUserItem.User_Phone__c = result.Phone;
                            }
                            this.currentUserItem.User_Email__c = result.Email;
                            this.currentUserItem.Queue_Name__c = result.Queue_Name__c; //T03
                        }
                        this.spinnerCounter--;
                    })
                    .catch(error => {
                        console.log('error >>', error);
                        this.spinnerCounter--;
                    })
                } else {
                    this.currentUserItem.User__c =''; 
                    this.currentUserItem.User_Email__c =''; 
                    this.currentUserItem.User_Phone__c ='';
                    this.currentUserItem.Queue_Name__c = ''; //T03
                }
                break;
            case 'User_Phone__c':
                if(event.target.value !== undefined){
                    this.currentUserItem.User_Phone__c = event.target.value;
                } else{
                    this.currentUserItem.User_Phone__c =''; 
                }                
                break;
            case 'User_Email__c':
                if(event.target.value !== undefined){
                    this.currentUserItem.User_Email__c = event.target.value;
                } else{
                    this.currentUserItem.User_Email__c =''; 
                }                
                break;
            //T03
            case 'Queue_Name__c':
                if(event.target.value !== undefined){
                    this.currentUserItem.Queue_Name__c = event.target.value;
                } else{
                    this.currentUserItem.Queue_Name__c =''; 
                }                
                break;
            //T03
            case 'Recipient_Type__c':
                if(event.target.value !== undefined){
                    if(this.currentUserItem){
                        this.currentUserItem.User_Type__c = event.target.value;
                        this.currentUserItem.isUser = false;
                        this.currentUserItem.isQueue = false;
                        this.currentUserItem.isDL = false;
                        if(event.target.value === 'User'){
                            this.currentUserItem.isUser = true;
                        }else if(event.target.value === 'Queue'){
                            this.currentUserItem.isQueue = true;
                        }else if(event.target.value === 'Distribution List'){
                            this.currentUserItem.isDL = true;
                        }
                        //T05 - handle additonal values for platform notification
                        else if(event.target.value === 'All Org Users'){
                            this.currentUserItem.isAllOrgUsers = true;
                        }else if(event.target.value == 'Specific User Role'){
                            this.currentUserItem.isSpecificUserRole = true;
                        }
                    }
                }
                break;
            case 'Platform_Recipient_Role__c': //T05 - capture the platform User ROle
                if(event.target.value !== undefined){
                    this.currentUserItem.Platform_Recipient_Role__c = event.target.value;
                } else{
                    this.currentUserItem.Platform_Recipient_Role__c =''; 
                }                
                break;
            case 'User_Type__c':
                if(event.target.value !== undefined){
                    console.log('handleUserFieldChange.. user type >> ', event.target.value);
                    if(this.currentUserTeam){
                        this.currentUserTeam.isAccountTeam = false;
                        this.currentUserTeam.isCaseTeam = false;
                        this.currentUserTeam.isPlanTeam = false;
                        this.currentUserTeam.isRelatedUser = false;
                        this.currentUserTeam.isOpportunityTeam = false;

                        this.currentUserTeam.TeamMemberOptions = this.AccountTeamMemberRoleOptions;
                        this.currentUserTeam.TeamRoleOptions = this.CaseTeamMemberRoleOptions;
                        this.currentUserTeam.PlanTeamOptions = this.planteamRoleOptions;
                        this.currentUserTeam.userFieldOptions = this.userFieldOptions;  
                        this.currentUserTeam.OpportunityTeamOptions = this.OpportunityTeamMemberRoleOptions;  

                        this.currentUserTeam.User_Type__c = event.target.value;
                        if(event.target.value === 'Account Team'){
                            this.currentUserTeam.isAccountTeam = true;
                        }else if(event.target.value === 'Case Team'){
                            this.currentUserTeam.isCaseTeam = true;
                        }else if(event.target.value === 'Plan Team'){
                            this.currentUserTeam.isPlanTeam = true;
                        }else if(event.target.value === 'Related User'){
                            this.currentUserTeam.isRelatedUser = true;
                        }else if(event.target.value === 'Opportunity Team'){
                            this.currentUserTeam.isOpportunityTeam = true;
                        }
                    }
                }else{
                    this.currentUserTeam.User_Type__c = ''; 
                }
                break;
            case 'Account_Case_Fields__c':
                if(event.target.value !== undefined){
                    this.currentUserTeam.Account_Case_Fields__c = event.target.value;
                }else{ 
                    this.currentUserTeam.Account_Case_Fields__c = '';
                }
                break;
            case 'Team_Member_Role__c':
                if(event.detail !== undefined){
                    console.log('Roles selected >> '+ JSON.stringify(event.detail));
                    this.currentUserTeam.Team_Member_Role__c =event.detail;
                }else{
                    this.currentUserTeam.Team_Member_Role__c = '';
                }
                break;
            //T03
            case 'Related_Fields__c':
                if(event.detail !== undefined){
                    console.log('fields selected >> '+ JSON.stringify(event.detail));
                    this.currentUserTeam.Related_Fields__c =event.detail;
                }else{
                    this.currentUserTeam.Related_Fields__c = '';
                }
                break;
        }
     }

    sendCloseEvent(recordId){
        const filters = [recordId];

        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: {filters}
        });
        this.dispatchEvent(closeclickedevt); 
    }

    closePage(recordId){
        console.log('closePage, recordId = ', recordId);
        this.sendCloseEvent(recordId);
    }

    handleCancel(event){
        this.closePage();
    }

    isValidEmailAddress(emailAddress){
        var validDomains = VALID_EMAIL_DOMAINS.split(',');

        var isValid = false;
        if(/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(emailAddress)){
            validDomains.forEach(element => {
                if(emailAddress.endsWith(element)){
                    isValid = true;
                }
            });
        }
        return isValid;
    }

    validateCustomLogic(){
        if(!this.criteriaRecord.fields.Custom_Logic__c){
            return false;
        }

        var customLogic = this.criteriaRecord.fields.Custom_Logic__c;

        var isValidCustomLogic = true;

        if(!(/^[a-zA-Z0-9 |&()]+$/.test(customLogic))){
            isValidCustomLogic = false;
        }

        if(isValidCustomLogic){
            var referencedCriteriaNumbers = [];
            referencedCriteriaNumbers = customLogic.match(/\d+/g);
            referencedCriteriaNumbers = new Set(referencedCriteriaNumbers);
            referencedCriteriaNumbers = Array.from(referencedCriteriaNumbers);
            referencedCriteriaNumbers.sort();
            console.log('referencedCriteriaNumbers >>', JSON.stringify(referencedCriteriaNumbers));

            var definedCriteriaNumbers = [];
            this.criteriaList.forEach(element => {
                definedCriteriaNumbers.push(element.section.toString());
            });
            definedCriteriaNumbers.sort();
            console.log('definedCriteriaNumbers >>', JSON.stringify(definedCriteriaNumbers));

            if(referencedCriteriaNumbers.join(',') != definedCriteriaNumbers.join(',')){
                isValidCustomLogic = false;
            }
        }

        if(isValidCustomLogic){
            var words = customLogic.split(' ');
            console.log('custom logic words >> ', JSON.stringify(words));

            var prevElement = 'a';
            words.forEach(element => {
                var trimmedElement = element.trim();
                trimmedElement = trimmedElement.replaceAll('(', '');
                trimmedElement = trimmedElement.replaceAll(')', '');
                trimmedElement = trimmedElement.trim();
                trimmedElement = trimmedElement.toLowerCase();
                console.log('trimmed element >> ', trimmedElement);
                if(trimmedElement.length > 0){
                    if(isNaN(trimmedElement)){
                        if(trimmedElement != 'and' && trimmedElement != 'or'){
                            console.log('invalid keyword found!');
                            isValidCustomLogic = false;
                        }
                    }else{
                        if(!isNaN(prevElement)){
                            console.log('two continous numbers found!');
                            isValidCustomLogic = false;
                        }
                    }
                    prevElement = trimmedElement;    
                }
            });
        }

        return isValidCustomLogic;
    }

    handleSave(event){       
        var notificationTypes = this.criteriaRecord.types;

        /** Check if all the values are populated for the filter criteria */
        var isValidFilterCriteria = true;
        this.criteriaList.forEach(child => {
            if(child.fieldAPIName === '' || child.fieldAPIName === null || child.fieldAPIName === undefined){
                isValidFilterCriteria = false;        
            }else if(child.operator === '' || child.operator === null || child.operator === undefined){
                isValidFilterCriteria = false;
            }else if(child.fieldValue === '' || child.fieldValue === null || child.fieldValue === undefined){
                isValidFilterCriteria = false;
            }
        });
        
        /** Check if all the required values are populated for the notification users */
        var isValidUserDetails = true;
        var isValidUserEmail = true;
        var invalidUserEmail = [];
        var recipientCount = 0; //T03
        this.useritemList.forEach(element => {
            console.log('validation user details >> ', JSON.stringify(element));
            recipientCount++; //T03
            if(element.User_Type__c === 'User'){
                if((!element.User__c || element.User__c === "") && (!element.User_Phone__c || element.User_Phone__c === "") && (!element.User_Email__c || element.User_Email__c === "")){
                    isValidUserDetails = false;
                }else if(element.User_Phone__c && element.User_Phone__c !== "" && (!element.User__c || element.User__c === "")){
                    isValidUserDetails = false;
                }
            }else if(element.User_Type__c === 'Queue'){
                if(!element.Queue_Name__c || element.Queue_Name__c === ""){
                    isValidUserDetails = false;
                }
            }else if(element.User_Type__c === 'Distribution List'){
                if(!element.User_Email__c || element.User_Email__c === ""){
                    isValidUserDetails = false;
                }
            }else if(element.User_Type__c === 'All Org Users'){

            }else if(element.User_Type__c === 'Specific User Role'){ //T05, Ensure the Role is populated if recipient type = Specific User Role
                if(!element.Platform_Recipient_Role__c){
                    isValidUserDetails = false;
                }
            }else{ //T03
                recipientCount--;
            }
            console.log('validation user details, isValidUserDetails >> ', isValidUserDetails);

            if(element.User_Email__c && element.User_Email__c !== ""){
                if(!this.isValidEmailAddress(element.User_Email__c)){
                    isValidUserEmail = false;
                    invalidUserEmail.push(element.User_Email__c);
                }
            }
        });

        //T03
        this.userTeamList.forEach(userTeam => {
            console.log('validation user team details >> ', JSON.stringify(userTeam));
            if( userTeam.User_Type__c === 'Account Team'){ 
                if(!userTeam.Account_Case_Fields__c || userTeam.Account_Case_Fields__c === ''){
                    isValidUserDetails = false;
                }
            }else if( userTeam.User_Type__c === 'Related User'){ 
                if(!Array.isArray(userTeam.Related_Fields__c) && (!userTeam.Related_Fields__c || userTeam.Related_Fields__c === '')){
                    isValidUserDetails = false;
                }
            }else if( userTeam.User_Type__c === 'Opportunity Team'){ 
                if(!userTeam.Account_Case_Fields__c || userTeam.Account_Case_Fields__c === ''){
                    isValidUserDetails = false;
                }
            }
            //T03
            if(userTeam.User_Type__c!==undefined && userTeam.User_Type__c!==""){
                recipientCount++;
            }
            console.log('validation user team details, isValidUserDetails >> ', isValidUserDetails);
        });

        var isValidCustomLogic = this.validateCustomLogic();
        
        this.errorMsg = ''
        if(this.criteriaRecord.fields.Name === undefined || this.criteriaRecord.fields.Name === '' || this.criteriaRecord.fields.Name === null){
            this.errorMsg = 'Please enter the Notification Name';
        }else if (this.criteriaRecord.fields.Object__c === undefined || this.criteriaRecord.fields.Object__c === '' || this.criteriaRecord.fields.Object__c === null){
            this.errorMsg = 'Please select the Object';
        }else if (this.criteriaRecord.fields.Evaluation_Trigger__c === undefined || this.criteriaRecord.fields.Evaluation_Trigger__c === '' || this.criteriaRecord.fields.Evaluation_Trigger__c === null){
            this.errorMsg = 'Please select the Evaluation Trigger';
        }else if(!isValidFilterCriteria){
            this.errorMsg = 'Please fill all the details for the filter criteria';
        }else if(!isValidCustomLogic){
            this.errorMsg = 'Please enter a valid custom logic';
        }else if (this.criteriaRecord.types.length == 0){
            this.errorMsg = 'Please select a Notification Channel';
        }else if(notificationTypes.includes('Microsoft Teams Channel Email') && !this.isValidEmailAddress(this.criteriaRecord.fields.MS_Teams_Email__c)){
            this.errorMsg = 'Please enter a valid Teams Channel Email address';
        //}else if(notificationTypes.includes('Salesforce Chatter Post') && !this.isValidEmailAddress(this.criteriaRecord.fields.SF_Chatter_Post_Email__c)){
        //    this.errorMsg = 'Please enter a valid Chatter Group Email address';
        }else if(recipientCount === 0){ //T03
            this.errorMsg = "Please select atleast one recipient details";
        }else if(!isValidUserDetails){
            this.errorMsg = 'Please fill all the required user details';
        }else if(!isValidUserEmail){
            this.errorMsg = 'Please enter valid Email address - ' + invalidUserEmail.join(',');
        }else if (this.criteriaRecord.fields.Template_Name__c === undefined || this.criteriaRecord.fields.Template_Name__c === '' || this.criteriaRecord.fields.Template_Name__c === null){
            this.errorMsg = 'Please select the Template';
        }
        //T05 - Ensure the expiration date is populated if the Notificatin Type is Notify Platform*
        else if (this.showExpirationDate && (this.criteriaRecord.fields.Platform_Notification_Expiration__c === undefined || this.criteriaRecord.fields.Platform_Notification_Expiration__c === '' || this.criteriaRecord.fields.Platform_Notification_Expiration__c === null)){
            this.errorMsg = 'Please fill Expiration Date for the Platform Notification';
        }
        
        console.log('Error message : '+ this.errorMsg);
        console.log('Error message debug');
        //else{
        if(this.errorMsg === ''){
            console.log('Inside if');
            this.spinnerCounter++;

            this.errorMsg='';
            this.generateFilterCondition(); //generate the filter condition logic

            var notificationUserList = [];
            this.useritemList.forEach(element => {
                if(element.User_Type__c!==undefined && element.User_Type__c!==""){
                    /**T02 Bypassing the population of user,email and phone for platform notification */
                    var userItem = {
                        User_Type__c:element.User_Type__c
                    };

                    if(element.isSpecificUserRole){
                        userItem.Platform_Recipient_Role__c = element.Platform_Recipient_Role__c;
                    }else{                        
                        userItem.User__c = element.User__c;

                        if(this.criteriaRecord.types.includes('SMS')){
                            userItem.User_Phone__c = element.User_Phone__c;
                        }
                        if(this.criteriaRecord.types.includes('Email')){
                            userItem.User_Email__c = element.User_Email__c;
                        }
                        userItem.Queue_Name__c = element.Queue_Name__c;
                    }


                    // notificationUserList.push({User__c : element.User__c,User_Phone__c : element.User_Phone__c, User_Email__c : element.User_Email__c, User_Type__c : element.User_Type__c,Account_Case_Fields__c:element.Account_Case_Fields__c,Team_Member_Role__c:element.Team_Member_Role__c});
                    userItem.Active__c = 1;
                    notificationUserList.push(userItem);
                }
            });

            this.userTeamList.forEach(userTeam => {
                
                if(userTeam.User_Type__c!==undefined && userTeam.User_Type__c!==""){
                    var teamMemberRole = '';
                    if(Array.isArray(userTeam.Team_Member_Role__c)){
                        teamMemberRole = userTeam.Team_Member_Role__c.join(',');
                    }else{
                        teamMemberRole = userTeam.Team_Member_Role__c;
                    }
                    //T03
                    var relatedFields = '';
                    if(Array.isArray(userTeam.Related_Fields__c)){
                        relatedFields = userTeam.Related_Fields__c.join(',');
                    }else{
                        relatedFields = userTeam.Related_Fields__c;
                    }
                    var userItem = {
                        User_Type__c:userTeam.User_Type__c,
                        Account_Case_Fields__c:userTeam.Account_Case_Fields__c,
                        Team_Member_Role__c:teamMemberRole,
                        Related_Fields__c:relatedFields //T03
                     };
                     userItem.Active__c = 1;
                     notificationUserList.push(userItem);
                }
                     
            });

            console.log('notificationUserList >> '+ JSON.stringify(notificationUserList));

            var detailList = [];
            this.criteriaList.forEach(element => {
                
                var fieldValueNames = '';
                if(element.multipicklistOptions.length > 0){
                    var fieldValueNameList = [];
                    var fieldValues = element.fieldValue.split(',');
                    element.multipicklistOptions.forEach(element => {
                        if(fieldValues.includes(element.value)){
                            fieldValueNameList.push(element.label);
                        }
                    });
                    fieldValueNames = fieldValueNameList.join(',');
                }
                detailList.push({
                    Field_API_Name__c : element.fieldAPIName,
                    Field_Name__c : element.fieldLabel,
                    Field_Data_Type__c: element.fieldType, 
                    Operator__c : element.operator, 
                    Value__c : element.fieldValue,
                    Value_Short__c : element.fieldValue.substr(0, 255),
                    Value_Names__c : fieldValueNames
                });
            });

            let params = {criteria : Object.assign({ 'SobjectType' : 'Notification_Criteria__c' }, this.criteriaRecord.fields)};
            params.userList = JSON.stringify(notificationUserList);
            params.detailList = JSON.stringify(detailList);
                        
            console.log('params>>', JSON.stringify(params));

            this.spinnerCounter++;
            saveNotificationCriteria(params)
            .then(result =>{
                this.spinnerCounter--;
                console.log('result : '+ result);

                let recordIdsToRefresh = [];
                result.forEach(element => {
                    recordIdsToRefresh.push({recordId: element});
                });
                console.log('recordIdsToRefresh : '+  JSON.stringify(recordIdsToRefresh));
                getRecordNotifyChange(recordIdsToRefresh);

                var successmessage = 'Notification Subscription created successfully!';
                if(this.recordId){
                    successmessage = 'Notification Subscription updated successfully!'
                }

                // Show toast message 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success : ',
                        message: successmessage,
                        variant: 'success',
                    }),
                );
                
                // Navigate to Notification Criteria record
                this.closePage(result);
            })
            .catch(error=>{
                this.spinnerCounter--;
                console.log('ERROR iIN SAVENOTIFICATIONCRITERIA >> '+ JSON.stringify(error));
            })
        }else{
            console.log('Error message 2 : '+ this.errorMsg);
            this.spinnerCounter--;

            /** Show errpr message **/
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error : ',
                    message: this.errorMsg,
                    variant: 'error',
                }),
            );
        }
    }
}