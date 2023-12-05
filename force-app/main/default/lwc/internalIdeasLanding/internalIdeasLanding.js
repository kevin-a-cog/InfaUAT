/*
* Name : InternalIdeasLanding
* Author : Deeksha Shetty
* Created Date :  Feb 1 2022
* Description : This Component displays Ideas List for Internal Users.
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

import { LightningElement, wire, api } from 'lwc';
import ideasDisplay from '@salesforce/apex/helpInternalIdeaDetails.ideasDisplay';
import createIdea from '@salesforce/apex/helpInternalIdeaDetails.createIdea';
import { refreshApex } from '@salesforce/apex';
import fetchFilterValues from '@salesforce/apex/helpInternalIdeaDetails.fetchFilterValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleIdeaStatusChange from '@salesforce/apex/helpInternalIdeaDetails.handleIdeaStatusChange';



const columns = [
    { label: 'Title', fieldName: 'URL', type: 'url', typeAttributes: { label: { fieldName: 'Title' } ,target: '_blank' }, hideDefaultActions: true },
    { label: 'Status', fieldName: 'Status', editable: true, hideDefaultActions: true },
    { label: 'Upvote Count', fieldName: 'upvoteCount', hideDefaultActions: true },
    { label: 'Description', fieldName: 'Body', hideDefaultActions: true },
    { label: 'Category', fieldName: 'Category', hideDefaultActions: true },
    { label: 'Created Date', fieldName: 'CreatedDate', hideDefaultActions: true },
    { label: 'Created By', fieldName: 'CreatorName', hideDefaultActions: true },
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', hideDefaultActions: true },
];


export default class InternalIdeasLanding extends LightningElement {
    records;
    error;
    sampleUrl = " ";
    titleValue;
    categoryValue;
    Body;
    value = 'Data Engineering Integration';
    filtervalue = 'All'
    statusvalue = 'Draft';
    titleval="";
    bodyval="";
    showEditModal = false;
    wiredResults;
    ideaData;
    draftValues;
    selectedfilters;

    data;
    columns = columns;
    alldata;
    listOptions;
    defaultOptions;
    requiredOptions =[];

    statusOptions;
    statusFilterOptions;
    validity = true;





    //wire that fetches First Filters and second filters
    @wire(fetchFilterValues)
    IdeaWiring(result) {
        if (result.data) {
            let firstFilter = result.data.statusFilter;
            this.statusOptions = firstFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });
            let categoryFilter = result.data.categoriesFilter;
            this.listOptions = categoryFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });

            let statusFilterIdeas = result.data.statusIdeasLanding;
            this.statusFilterOptions = statusFilterIdeas.map(item => {
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


    @wire(ideasDisplay)
    imperativeWiring(result) {
        this.wiredResults = result;
        if (result.data) {
            this.data = result.data;
            this.alldata = [...result.data];
           
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }



    // handleIdeaView(event) {
    //     console.log('Current Id---' + event.currentTarget.dataset.id);
    //     this.sampleUrl = '/lightning/cmp/c__internalIdeasLandingWrapper?c__crecordId=' + event.currentTarget.dataset.id;   //aura name
    // }

    createIdea() {
        this.showEditModal = true;
    }

    handleFilterChange(event) {
        this.data = this.alldata;
        this.filtervalue = event.detail.value;
        if (this.filtervalue == 'All') {
            this.data = this.alldata;
        }
        else {
            let resultset = JSON.parse(JSON.stringify(this.data));
            const finaldata = resultset.filter(element => element.Status == this.filtervalue);
            this.data = finaldata;

        }

    }

    handleSave(event) {
        let updatedFields = event.detail.draftValues;
        let isvalidstatus = false;
        this.statusFilterOptions.forEach(element => {
            if (element.value.toLowerCase() == updatedFields[0].Status.toLowerCase()) {
                isvalidstatus = true;
            }
        });
       
        if (isvalidstatus == true) {
            handleIdeaStatusChange({ status: updatedFields[0].Status, IdeaId: updatedFields[0].ideaId })
                .then((result) => {
                    if (result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Idea Updated Successfully',
                                variant: 'success',
                            }),
                        );
                        return refreshApex(this.wiredResults).then(() => {
                            // Clear all draft values in the datatable
                            this.draftValues = [];
                            this.filtervalue = 'All'

                        });


                    }

                })
                .catch((error) => {
                    console.log(error.body);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: error.body,
                            variant: 'error',
                        }),
                    );
                });

        }
        else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error : ',
                    message: 'Enter Valid Idea Status',
                    variant: 'error',
                }),
            );

        }
    }

    handleTitle(event) {
        this.titleValue = event.target.value;
        console.log(this.titleValue);
    }

    handleBody(event) {
        this.Body = event.target.value;
        console.log(this.Body)
    }


    handleChange(event) {
        this.requiredOptions = event.detail.value;
        
    }

    handleStatusChange(event) {
        this.statusvalue = event.detail.value;
        console.log(this.statusvalue);
    }



    saveIdea() {
        if (this.Body== undefined || !this.Body) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }
        if (this.validity == true && this.titleValue && this.requiredOptions.length>0) {
            createIdea({ title: this.titleValue, category: this.requiredOptions, body: this.Body, status: this.statusvalue })
                .then((result) => {
                    if (result) {
                        refreshApex(this.wiredResults);
                        this.handleModalClose();
                        window.open('/lightning/cmp/c__internalIdeasLandingWrapper?c__crecordId='+result);
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });

        }

    }

    handleModalClose() {
        this.showEditModal = false;
    }

}