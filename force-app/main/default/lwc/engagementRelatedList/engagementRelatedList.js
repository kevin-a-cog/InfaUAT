import { LightningElement, track, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

import FIELD_ENGAGEMENT_NAME from '@salesforce/schema/Engagement__c.Name';
import FIELD_ENGAGEMENT_TITLE from '@salesforce/schema/Engagement__c.Title__c';
import FIELD_ENGAGEMENT_STATUS from '@salesforce/schema/Engagement__c.Status__c';
import FIELD_ENGAGEMENT_SUPPORT_ACCOUNT from '@salesforce/schema/Engagement__c.Support_Account__c';
import FIELD_ENGAGEMENT_CREATED_DATE from '@salesforce/schema/Engagement__c.CreatedDate';
import FIELD_ENGAGEMENT_PRIORITY from '@salesforce/schema/Engagement__c.Priority__c';
import FIELD_ENGAGEMENT_OWNER from '@salesforce/schema/Engagement__c.OwnerId';
//import FIELD_ENGAGEMENT_OWNER_NAME from '@salesforce/schema/Engagement__c.Owner.Name';
import FIELD_ENGAGEMENT_NUMBER from '@salesforce/schema/Engagement__c.Engagement_Number__c';

const ENGAGEMENT_FIELDS = [
    FIELD_ENGAGEMENT_NAME,
    FIELD_ENGAGEMENT_TITLE,
    FIELD_ENGAGEMENT_STATUS,
    FIELD_ENGAGEMENT_CREATED_DATE,
    FIELD_ENGAGEMENT_PRIORITY,
    FIELD_ENGAGEMENT_OWNER,
    FIELD_ENGAGEMENT_SUPPORT_ACCOUNT,
    FIELD_ENGAGEMENT_NUMBER
];

export default class EngagementRelatedList extends LightningElement {
    @track contactColumns = [
        { label: 'Name', fieldName: 'LinkName', type: 'url', typeAttributes: { label: { fieldName: 'Contact_Name' }, target: '_top' } },
        { label: 'Title', fieldName: 'Contact_Title', type: 'text' },
        { label: 'Email', fieldName: 'Contact_Email', type: 'email' },
        { label: 'Phone', fieldName: 'Contact_Phone', type: "phone" },
        { label: 'Roles', fieldName: 'Roles', type: "text" },
        { label: 'Primary__c', fieldName: 'Primary__c', type: "boolean" }
    ]

    @track engagementColumns = [
        { label: 'Engagement Number', fieldName: 'LinkName', type: 'url', typeAttributes: { label: { fieldName: 'Engagement_Number__c' }, target: '_top' } },
        { label: 'Contact Name', fieldName: 'Primary_Escalation_Contact__r_LinkName', type: 'url', typeAttributes: { label: { fieldName: 'Primary_Escalation_Contact__r_Name' }, target: '_top' } },
        { label: 'Title', fieldName: 'Title__c', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Priority', fieldName: 'Priority__c', type: 'text' },
        { label: 'Created On', fieldName: 'CreatedDate', type: 'date' },             
        //{ label: 'Owner Name', fieldName: 'OwnerId', type: 'text' }
        { label: 'Owner Name', fieldName: 'Owner_LinkName', type: 'url', typeAttributes: { label: { fieldName: 'Owner_Name' }, target: '_top' } }
    ]

    customActions = [{ label: 'Custom action', name: 'custom_action' }]

    @track accountId;
    
    @api
    customHandler() {
        alert("It's a custom action!")
    }

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ENGAGEMENT_FIELDS })
    engagement({ error, data }) {
        if (error) {
            console.log("error fetching engagement details - " + JSON.stringify(error));
        } else if (data) {
            console.log("data.fields - " + JSON.stringify(data.fields));
            this.accountId = getFieldValue(data, FIELD_ENGAGEMENT_SUPPORT_ACCOUNT);
            console.log("supportAccountId - " + this.accountId);
        }
    }
}