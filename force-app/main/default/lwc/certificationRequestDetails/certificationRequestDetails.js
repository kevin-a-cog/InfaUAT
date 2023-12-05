/*
 * Name			:	certificationRequestDetails
 * Author		:	Vignesh Divakaran
 * Created Date	: 	26/05/2022
 * Description	:	This LWC diplays details of Certification Request.

 Change History
 ************************************************************************************************************************
 Modified By			Date			Jira No.		Description							                        Tag
 ************************************************************************************************************************
 Vignesh Divakaran		26/05/2022		I2RT-6149		Initial version.					                        N/A
 Vignesh Divakaran		26/07/2023		I2RT-8640		Updated logic to show active certification request info     T01
                                                        for all active segmentation types.
 Vignesh Divakaran		14/08/2023		I2RT-8852		Show business justification for Preferred certification     T02
                                                        request
 */

//Core imports.
import { LightningElement,api,track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Schema
/* Certification Request */ //<T01>
import CERTIFICATION_REQUEST from '@salesforce/schema/Certification_Request__c';
import REQUEST_TYPE from '@salesforce/schema/Certification_Request__c.Request_Type__c';
import CERTIFICATION_TYPE from '@salesforce/schema/Certification_Request__c.Certification_Type__c';
import PRODUCT from '@salesforce/schema/Certification_Request__c.Product__c';
import BUSINESS_JUSTIFICATION from '@salesforce/schema/Certification_Request__c.Business_Justification__c';
import START_DATE from '@salesforce/schema/Certification_Request__c.Start_Date__c';
import END_DATE from '@salesforce/schema/Certification_Request__c.End_Date__c';
import BUSINESS_OWNER from '@salesforce/schema/Certification_Request__c.Owner__c';
import STATUS from '@salesforce/schema/Certification_Request__c.Status__c';
import SUPPORT_ACCOUNT from '@salesforce/schema/Certification_Request__c.Support_Account__c';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getCertificationRequest from "@salesforce/apex/SupportAccountController.getCertificationRequest";

export default class CertificationRequestDetails extends LightningElement {

    //API variables.
    @api recordId;
    @api strSectionName = 'Section Name';

    //Track variables
    @track toggle;
    @track lstRecords = []; //<T01>


    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters  : None
     Return Type : None
    */
    connectedCallback() {
        
        //We initialize the components.
        this.initializeComponent();
    }

    /*
	 Method Name : initializeComponent
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	*/
    initializeComponent() {
        let objParent = this;

        //Now, we get certification request under support account
        getCertificationRequest({ strSupportAccountId: objParent.recordId })
            .then((objResponse) => {
                objParent.parseData(objResponse);  //<T01>
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            });
    }

    /*
	 Method Name : parseData
	 Description : This method parses the data from apex and creates a structure for the data in UI
	 Parameters	 : Object, called from initializeComponent, objData
	 Return Type : None
	*/
    parseData(objData) {  //<T01>
        let objParent = this;

        if (typeof objData === 'object' && Object.keys(objData)?.length) {
            
            let lstRecords = [];

            Object.keys(objData).forEach(strKey => {

                let strRequestType = strKey;
                let lstFields = [];
                let lstObjWrapper = objData[strRequestType];
                lstObjWrapper.forEach(objWrapper => {

                    let { objCertificationRequest, objProcessInstance } = objWrapper;

                    //Clean the certification request data
                    objCertificationRequest.ownerLink = objParent.getRecordLink(objParent.obj?.Owner__c);
                    objCertificationRequest.startDateFormatted = objParent.dateFormatter(objCertificationRequest?.Start_Date__c, { year: 'numeric', month: 'numeric', day: 'numeric' });
                    objCertificationRequest.endDateFormatted = objParent.dateFormatter(objCertificationRequest?.End_Date__c, { year: 'numeric', month: 'numeric', day: 'numeric' });

                    //Now, we store the approval history from certification request
                    if (objProcessInstance.hasOwnProperty('StepsAndWorkitems')) {
                        objCertificationRequest.ApprovalHistory = {};

                        objProcessInstance.StepsAndWorkitems.forEach(objStepsAndWorkitem => {
                            if (objStepsAndWorkitem.StepStatus === 'Started') {
                                objCertificationRequest.ApprovalHistory.RequesterId = objParent.getRecordLink(objStepsAndWorkitem?.Actor?.Id);
                                objCertificationRequest.ApprovalHistory.RequesterName = objStepsAndWorkitem?.Actor?.Name;
                                objCertificationRequest.ApprovalHistory.RequestDate = objParent.dateFormatter(objStepsAndWorkitem?.CreatedDate, { year: 'numeric', month: 'numeric', day: 'numeric' });
                            }
                            else if (objStepsAndWorkitem.StepStatus === 'Approved') {
                                objCertificationRequest.ApprovalHistory.ApproverId = objParent.getRecordLink(objStepsAndWorkitem?.Actor?.Id);
                                objCertificationRequest.ApprovalHistory.ApproverName = objStepsAndWorkitem?.Actor?.Name;
                                objCertificationRequest.ApprovalHistory.ApprovedDate = objParent.dateFormatter(objStepsAndWorkitem?.CreatedDate, { year: 'numeric', month: 'numeric', day: 'numeric' });
                                objCertificationRequest.ApprovalHistory.ApproverComments = objStepsAndWorkitem?.Comments;
                            }
                        });
                    }

                    //Now, we create structure for the data in UI based on the request type
                    if (strRequestType === "Hypercare") {
                        lstFields = [
                            {label: 'Request Type', fieldValue: objCertificationRequest['Request_Type__c'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Product', fieldValue: objCertificationRequest['Product__c'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Start Date', fieldValue: objCertificationRequest['startDateFormatted'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'End Date', fieldValue: objCertificationRequest['endDateFormatted'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Business Owner', fieldValue: objCertificationRequest['Owner__r']['Name'], type: {isTypeReference: true}, fieldReference: objCertificationRequest['ownerLink'], isTwoColumn: true },
                            {label: 'Status', fieldValue: objCertificationRequest['Status__c'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Business Justification', fieldValue: objCertificationRequest['Business_Justification__c'], type: {isTypeText: true}, isTwoColumn: false },
                            {label: 'Requester Name', fieldValue: objCertificationRequest.ApprovalHistory['RequesterName'], type: {isTypeReference: true}, fieldReference: objCertificationRequest.ApprovalHistory['RequesterId'], isTwoColumn: true },
                            {label: 'Request Date', fieldValue: objCertificationRequest.ApprovalHistory['RequestDate'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Approver Name', fieldValue: objCertificationRequest.ApprovalHistory['ApproverName'], type: {isTypeReference: true}, fieldReference: objCertificationRequest.ApprovalHistory['ApproverId'], isTwoColumn: true },
                            {label: 'Approved Date', fieldValue: objCertificationRequest.ApprovalHistory['ApprovedDate'], type: {isTypeText: true}, isTwoColumn: true },
                            {label: 'Approver Comments', fieldValue: objCertificationRequest.ApprovalHistory['ApproverComments'], type: {isTypeText: true}, isTwoColumn: false }
                        ];
                    }
                    else if (strRequestType === "Preferred" || strRequestType !== "Preferred") {
                        lstFields.push({ label: 'Product', fieldValue: objCertificationRequest['Product__c'], type: { isTypeText: true }, isTwoColumn: true });
                        lstFields.push({ label: 'End Date', fieldValue: objCertificationRequest['endDateFormatted'], type: {isTypeText: true}, isTwoColumn: true });
                        lstFields.push({ label: 'Business Justification', fieldValue: objCertificationRequest['Business_Justification__c'], type: {isTypeText: true}, isTwoColumn: false }); //<T02>
                    } 
                });
                
                lstRecords.push({
                    strSectionName: strRequestType,
                    lstFields: lstFields
                });
            });

            //We sort the certification request based on the precedence order.
            lstRecords.sort((a, b) => {
                if (objParent.getPrecedence(a['strSectionName']) < objParent.getPrecedence(b['strSectionName']))
                    return -1;
                else if (objParent.getPrecedence(a['strSectionName']) > objParent.getPrecedence(b['strSectionName']))
                    return 1;
                return 0;
            });

            objParent.lstRecords = lstRecords;
        }
    }

    /*
	 Method Name : getPrecedence
	 Description : This method return the precedence order for the given request type.
	 Parameters	 : String, called from parseData, strRequestType
	 Return Type : Number
	*/
    getPrecedence(strRequestType) { //<T01>
        if (strRequestType === 'Hypercare')
            return 1;
        else if (strRequestType === 'Preferred')
            return 2;
        else
            return 3;
    }

    /*
	 Method Name : toggleSection
	 Description : This method constructs record link for the given recordid.
	 Parameters	 : String, called from initializeComponent, strRecordId
	 Return Type : String
	*/
    getRecordLink(strRecordId) {
        return objUtilities.isNotBlank(strRecordId) ? '/lightning/r/'+strRecordId+'/view' : '';
    }

    /*
	 Method Name : dateFormatter
	 Description : This method returns the formatted date.
	 Parameters	 : (Date, Object), called from initializeComponent, (strDate, objFormat)
	 Return Type : String
	*/
    dateFormatter(strDate, objFormat){
        let strFormmatedDate = '';
        if(objUtilities.isNotBlank(strDate)){
            let newDate = new Date(strDate);
            //Use timezone from salesforce user
            objFormat.timezone = TIME_ZONE;
            strFormmatedDate = strDate.includes('T') ? new Intl.DateTimeFormat(LOCALE, objFormat).format(newDate) : new Intl.DateTimeFormat(LOCALE).format(newDate);
        }

        return strFormmatedDate; 
    }

    /*
	 Method Name : toggleSection
	 Description : This method collapses and displays the section.
	 Parameters	 : None
	 Return Type : None
	*/
    toggleSection() {
        this.toggle = !this.toggle;
    }

    /* Getter Methods */
    get chevronIcon() {
        return this.toggle ? 'utility:chevronright' : 'utility:chevrondown';
    }

    get className() {
        return this.toggle ? 'slds-section slds-hide' : 'slds-section slds-show pad'; //<T01>
    }

    get showDetails() {
        return !objUtilities.isEmpty(this.lstRecords); //<T01>
    }

}