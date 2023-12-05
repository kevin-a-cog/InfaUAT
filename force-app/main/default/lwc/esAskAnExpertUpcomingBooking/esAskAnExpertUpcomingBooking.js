/*
 Change History
 *************************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                          Tag
 *************************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                                     NA
 Vignesh Divakaran      9/20/2023       I2RT-9063           Updated column and data format to show the AAE case details			 T01
 Vignesh Divakaran      10/03/2023      I2RT-9216           Updated case detail page URL										 T02
 Shashikanth			10/19/2023		I2RT-7702		    Formatting Session Start & End Times to 12hrs                        T03
 */
 import { LightningElement,wire,api, track} from 'lwc';
 import TIME_ZONE from '@salesforce/i18n/timeZone';     //<T03>
 import fetchSupportAccountAppoinmentBookings from '@salesforce/apex/esAskAnExpertUpcomingBookingController.fetchSupportAccountAppoinmentBookings'; 
 import { CurrentPageReference } from 'lightning/navigation';
 import Id from '@salesforce/user/Id';
 import getContactTimezone from "@salesforce/apex/GlobalSchedulerController.getContactTimezone";			//<T03>
 
 //Custom Labels.
 import Esupport_Base_URL from '@salesforce/label/c.eSupport'; //<T02>
 
 //Utilities.
 import { objUtilities } from 'c/globalUtilities'; //<T01>
 
 export default class EsAskAnExpertUpcomingBooking extends LightningElement {
     columns;
     data = [];
     @api parentRecordId = '' ;
     userTimeZone = '';
     userId = Id;
     @track upcomingBooking = false;
 
 
     @api
     getFiredFromAura() {
         this.fetchBookingData();
     }
 
     @wire(getContactTimezone)                      //<T03>
     user({ error, data }) {
        this.userTimeZone = !!data ? data : TIME_ZONE;      //<T03>
        this.columns = [
            { label: 'Session ID', fieldName: 'strSessionLink' , type: 'url', typeAttributes: {label: { fieldName: 'strSessionName' }} },
            
            { label: 'Session Title', fieldName: 'strSubject' },
            { label: 'Case Number', fieldName: 'strCaseNumber' },
            { label: 'Product', fieldName: 'strCaseProduct' },
            { label: 'Status', fieldName: 'strCaseStatus' },
            { label: 'Session Start Date', fieldName: 'datTSessionStartDate', type: 'date', typeAttributes:{
            month: "short",
            day: "2-digit",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            timeZone : this.userTimeZone
            } },
            { label: 'Session End Date', fieldName: 'datTSessionEndDate' ,type: 'date', typeAttributes:{
            month: "short",
            day: "2-digit",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            timeZone : this.userTimeZone
            }},
        ]; //<T01>
     };
 
     @wire(CurrentPageReference) pageRef;
 
 
     connectedCallback(){
         var accId = this.pageRef ? this.pageRef.state.supportaccountid : '';
         this.parentRecordId = accId;
         this.fetchBookingData();
     }
 
 
     fetchBookingData(){
         fetchSupportAccountAppoinmentBookings({ sParentRecordId: this.parentRecordId})
         .then(lstCases => { //<T01>
             if(!objUtilities.isEmpty(lstCases)){
                 lstCases.forEach(objCase => {
                     objCase.strSessionName = objCase.Service_Appointment__r.Name;
                     objCase.strSessionLink = Esupport_Base_URL + '/casedetails?caseId=' + objCase.Id; //<T02>
                     objCase.strSubject = objCase.Subject;
                     objCase.strCaseNumber = objCase.CaseNumber;
                     objCase.strCaseProduct = objCase.Forecast_Product__c;
                     objCase.strCaseStatus = objCase.Status;
                     objCase.datTSessionStartDate = objCase.Service_Appointment__r?.Time_Slot_AAE__r?.Start_Time__c;
                     objCase.datTSessionEndDate = objCase.Service_Appointment__r?.Time_Slot_AAE__r?.End_Time__c;
                 });
                 this.upcomingBooking = true;
             }
             else{
                 this.upcomingBooking = false;
             }
             this.data = lstCases;
         })
         .catch(error => {
             this.error = error;
         });
     }
 }