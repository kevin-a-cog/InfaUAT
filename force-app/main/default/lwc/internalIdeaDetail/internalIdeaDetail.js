/*
* Name : InternalIdeaDetail
* Author : Deeksha Shetty
* Created Date :  Feb 1 2022
* Description : This Component displays Idea Details for Internal Users.
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

import { LightningElement, wire, api } from 'lwc';
import ideadisplayOnId from '@salesforce/apex/helpInternalIdeaDetails.ideadisplayOnId';
import fetchFilterValues from '@salesforce/apex/helpInternalIdeaDetails.fetchFilterValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import ideadisplayPostEdit from '@salesforce/apex/helpInternalIdeaDetails.ideadisplayPostEdit';

export default class InternalIdeaDetail extends LightningElement {
    @api recordId;

    records;
    error;

    titleVal = "";
    Statusval = "";
    Descriptionval = "";
    statusOptions;
    upvotecount = "";
    options;
    wiredResults;

    validity = true;
    createddate;
    lastmodifieddate;
    showButtons = false;
    showEdit = true;
    isInputReadOnly = true;
    isUpvoteCountReadOnly = true;
    values = [];
    
    showSpinner = false;

    //wire that fetches First Filters and second filters
    @wire(fetchFilterValues)
    IdeaWiring(result) {
        if (result.data) {
            let firstFilter = result.data.statusIdeasLanding;
            this.statusOptions = firstFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });

            let categoryFilter = result.data.categoriesFilter;
            this.options = categoryFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }




    @wire(ideadisplayOnId, { IdeaId: '$recordId' })
    imperativeWiring(result) {
        this.wiredResults = result;
        if (result.data) {
            this.records = result.data;
            console.log('RECORDS====' + JSON.stringify(this.records));
            this.values = [...this.records.CategoryList];
            this.titleVal = this.records.Title;
            this.Statusval = this.records.Status;
            this.upvotecount = this.records.upvoteCount;
            this.createddate = this.records.CreatedDate;
            this.lastmodifieddate = this.records.LastModifiedDate;
            if (this.records.Body) {
                this.Descriptionval = this.records.Body;
            }
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }

    handleEdit() {
        if (this.Statusval == 'Draft') {
            this.isUpvoteCountReadOnly = true;
            this.isInputReadOnly = false;
            this.showEdit = false;
            this.showButtons = true;
        }
        else {
            this.isInputReadOnly = false;
            this.isUpvoteCountReadOnly = false
            this.showEdit = false;
            this.showButtons = true;

        }

    }

    handleCategory(event) {
        this.values = event.detail.value;
        console.log('values='+JSON.stringify(this.values))
    }



    handleStatusChange(event) {
        this.Statusval = event.detail.value;

        if (this.Statusval == 'Draft') {
            this.isUpvoteCountReadOnly = true;
        }
        else {
            this.isUpvoteCountReadOnly = false;
        }
    }

    handleUpvoteCount(event) {
        if (this.Statusval == 'Draft') {
            this.isUpvoteCountReadOnly = true;
        }
        else {
            this.isUpvoteCountReadOnly = false;
            this.upvotecount = event.target.value;
        }

        console.log(this.upvotecount);
    }

    handleTitleval(event) {
        this.titleVal = event.target.value;
        console.log(this.titleVal)
    }

    handleDescription(event) {
        this.Descriptionval = event.target.value;
        console.log(this.Descriptionval)
    }


    handleCancel() {
        location.reload();
    }

    handleRedirection() {
        window.open('/lightning/n/All_Ideas', "_self");
    }

    handleSave() {
        if (this.Descriptionval == undefined || !this.Descriptionval) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }
        

        if (this.titleVal && this.validity && this.values.length > 0) {
            this.showSpinner = true;
            ideadisplayPostEdit({
                IdeaId: this.recordId, category: this.values, Status: this.Statusval, title: this.titleVal,
                Descrip: this.Descriptionval, Upvote: this.upvotecount
            })
                .then((result) => {
                    if (result) {

                        refreshApex(this.wiredResults);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Idea Updated Successfully',
                                variant: 'success',
                            }),
                        );
                        this.isInputReadOnly = true;
                        this.isUpvoteCountReadOnly = true;
                        this.showEdit = true;
                        this.showButtons = false;
                        this.showSpinner = false;
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log(error.body);
                });
        }
    }


}