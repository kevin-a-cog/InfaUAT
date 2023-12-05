/*
* Name : HelpCreateIdeaModal
* Author : Deeksha Shetty
* Created Date : February 1, 2022
* Description : This Component displays Create Idea Modal in Landing page and Product Detail Page
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

import { LightningElement, wire, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import userId from '@salesforce/user/Id';
import createIdea from '@salesforce/apex/helpInternalIdeaDetails.createIdea';
import getAllCommunityOptions from "@salesforce/apex/helpCommunityController.getAllCommunityOptions";
import getCategoryPicklistValues from '@salesforce/apex/helpInternalIdeaDetails.getCategoryPicklistValues';
import getSelectedIdea from '@salesforce/apex/helpInternalIdeaDetails.getSelectedIdea';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';

export default class HelpCreateIdeaModal extends LightningElement {
    @api recordId;
    heading = 'Create an Idea';
    categoryOptions;
    selectedCategory="";
    bodyVal = "";
    titleVal = "";
    showEditModal;
    @api selectedpostto;
    @track allOptions = [];
    showSpinner = false;
    firstFilterlist;
    selectedfilters;
    validity = true;

    handleCategory(event) {
        this.selectedCategory = event.target.value;
    }

    //wire that fetches First Filters
    @wire(getCategoryPicklistValues)
    IdeaWiring(result) {
        if (result.data) {
            let firstFilter = result.data;
            firstFilter = firstFilter.filter((element) => {
                return element != 'Change Request'
            }, this);
            this.firstFilterlist = firstFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });
            if (this.selectedpostto) {
                this.handleCategoryValue();
            }
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }


    handleCategoryValue() {
        getSelectedIdea({ topicId: this.selectedpostto })
            .then((result) => {
                if (result) {
                    this.selectedCategory = result;
                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }

    handlefirstChange(event) {
        this.selectedfilters = event.detail;
    }

    handleTitle(event) {
        this.titleVal = event.target.value;
    }

    handleBody(event) {
        this.bodyVal = event.detail.value;
    }

    handleCreateIdea() {
        var isValidValue = this.validateInputField();
        if (!this.selectedpostto && this.titleVal) {
            if (this.selectedfilters == undefined || !this.selectedfilters || this.selectedfilters.length == 0) {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error : ',
                        message: 'Please Select Category.',
                        variant: 'error',
                    }),
                );

            }
            else if (this.bodyVal == undefined || !this.bodyVal) {
                this.validity = false;
            }
            else {
                this.validity = true;
            }
            

            if (this.titleVal!="" && this.selectedfilters.length>0 && this.bodyVal!="" && this.validity == true) {
                this.showSpinner = true;
                 /** START-- adobe analytics */
                 try {
                    util.trackButtonClick('Create - New Idea - Form Complete - ' + this.selectedfilters);
                }
                catch (ex) {
                    console.log(ex.message);
                }
                /** END-- adobe analytics*/
                createIdea({ title: this.titleVal, category: this.selectedfilters, body: this.bodyVal })
                    .then((result) => {
                        if (result) {
                            this.handleModalClose();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success : ',
                                    message: 'Idea Created Successfully',
                                    variant: 'success',
                                }),
                            );
                            this.showSpinner = false;
                            window.open(CommunityURL + 'ideadetail?id=' + result, "_self");
                        }
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        console.log(error.body);
                    });

            }


        }
        else {
            if (this.bodyVal == undefined || !this.bodyVal) {
                this.validity = false;
            }
            else {
                this.validity = true;
            }
            if (this.titleVal!="" && this.selectedCategory!="" && this.bodyVal!="" && isValidValue) {
                /** START-- adobe analytics */
                try {
                    util.trackButtonClick('Create - New Idea - Form Complete - ' + this.selectedCategory);
                }
                catch (ex) {
                    console.log(ex.message);
                }
                /** END-- adobe analytics*/
                createIdea({ title: this.titleVal, category: this.selectedCategory, body: this.bodyVal })
                    .then((result) => {
                        if (result) {
                            this.handleModalClose();
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success : ',
                                    message: 'Idea Created Successfully',
                                    variant: 'success',
                                }),
                            );
                            window.open(CommunityURL + 'ideadetail?id=' + result, "_self");
                        }
                    })
                    .catch((error) => {
                        console.log(error.body);
                    });
            }

        }

    }

    handleModalClose() {
        this.dispatchEvent(
            new CustomEvent("closemodal", {
                detail: true,
            })
        );
    }

    createIdea() {
        this.showEditModal = true;
    }



    validateInputField() {
        const isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        return isValidValue;
    }













}