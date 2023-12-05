/*
* Name : HelpModerationItemDetail
* Author : Deeksha Shetty
* Created Date :  March 30,2022
* Description : This Component displays Moderation Items
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                 Tag
 **************************************************************************************************************************
 Deeksha Shetty        1-Feb-2022     I2RT-5249            Initial version.                                              NA
 Deeksha Shetty       25-Jul-2023     I2RT-8306            Moderator functionality - enhancement                         T1
                                                         
*/

import { LightningElement, api, wire } from 'lwc';
import ModerationDetailDisplayOnId from '@salesforce/apex/helpNetworkModerationController.ModerationDetailDisplayOnId';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedFilesByRecordId from '@salesforce/apex/helpNetworkModerationController.getRelatedFilesByRecordId';
import ApproveAction from '@salesforce/apex/helpNetworkModerationController.ApproveAction';
import RejectAction from '@salesforce/apex/helpNetworkModerationController.RejectAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class HelpModerationItemDetail extends NavigationMixin(LightningElement) {
    @api recordId;
    records;
    //T1 starts
    filesList = []
    excelFileList = []
    imageFileList = []
    hideImageTag;
    showSpinner = false;
     //T1 ends


    connectedCallback() {
        this.getModerationDetails();
    }


    @wire(getRelatedFilesByRecordId, { feedEntityID: '$recordId' })
    wiredResult({ data, error }) {
        if (data) {
            /* T1 Starts */
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`,
                "iconName": 'value'
            }))
            this.filesList.forEach(item => {
                if ((item.label.includes('png')) || (item.label.includes('jpeg')) || (item.label.includes('jpg'))) {
                    this.imageFileList.push(item);
                } else {
                    if (item.label.includes('csv')) item.iconName = "doctype:csv";
                    else if (item.label.includes('xls')) item.iconName = "doctype:excel";
                    else if (item.label.includes('pdf')) item.iconName = "doctype:pdf";
                    else if (item.label.includes('doc')) item.iconName = "doctype:word";
                    else if (item.label.includes('zip')) item.iconName = "doctype:zip";
                    else item.iconName = "doctype:unknown";
                    this.excelFileList.push(item);
                }
            });
        }
        if (error) {
            console.log(error)
        }
    }

    previewHandler(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }


    getModerationDetails() {
        ModerationDetailDisplayOnId({ recId: this.recordId })
            .then((result) => {
                if (result) {
                    this.records = result;
                    console.log('RECORDS=' + JSON.stringify(this.records));
                    console.log('imageURLLIST...'+this.records.imageUrlList)
                }

            })
            .catch((error) => {
                console.log('ERROR+++++' + JSON.stringify(error.body));
            });
    }

    handleApprove() {
        this.showSpinner = true;
        ApproveAction({ entityId: this.recordId })
            .then((result) => {
                console.log('Status Res=' + JSON.stringify(result));
                if (result == 'Published') {
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: 'Content Approved.',
                            variant: 'success',
                        }),
                    );
                }
            })
            .catch((error) => {
                console.log(error.body);
            })

        window.open('/lightning/n/Moderation_Action', "_self")
    }

    handleReject() {
        this.showSpinner = true;
        RejectAction({ entityId: this.recordId })
            .then((result) => {
                console.log('Status Res=' + JSON.stringify(result));
                if (result) {
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: 'Content Rejected.',
                            variant: 'success',
                        }),
                    );
                }
            })
            .catch((error) => {
                console.log(error.body);
            });

        window.open('/lightning/n/Moderation_Action', "_self")
    }
    /**T1 Ends */

}