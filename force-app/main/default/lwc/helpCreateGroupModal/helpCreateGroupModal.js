/*
* Name : HelpCreateGroupModal
* Author : Narpavi Prabu
* Created Date : 17/3/2022
* Description : This Component displays Create group Modal in Landing page
Change History
 ***********************************************************************************************************************
 Modified By			Date			Jira No.		Description							                    Tag
 ************************************************************************************************************************
 Narpavi Prabu	  21/03/2022		 		            Initial version.					                    N/A
 Deeksha Shetty   22/02/2023            I2RT-7347       User Group: Typo mistake Create user Group              T1
*/

import { LightningElement, wire, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import userId from '@salesforce/user/Id';
import createGroup from '@salesforce/apex/helpGroupsController.createGroup';
import fetchFilterValues from '@salesforce/apex/helpGroupsController.fetchFilterValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';

export default class HelpCreateGroupModal extends LightningElement {
    heading = 'Create a Group'; //T1
    bodyVal;
    titleVal;
    grouptype;
    firstFilterlist;
    showEditModal;
    @api selectedpostto;
    @track allOptions = [];
    isLoading = false; // T1


    @wire(fetchFilterValues)
    GroupWiring(result) {
        if (result.data) {
            let firstFilter = result.data.typeFilter;
            this.firstFilterlist = firstFilter.map(item => {
                let group = {};
                group.label = item;
                group.value = item;
                return group;
            });
        }
        else if (result.error) {
            console.log('Error>>>' + JSON.stringify(result.error));
        }
    }

    get options() {
        return this.firstFilterlist;
    }

    //title 
    handleTitle(event) {
        this.titleVal = event.target.value;
    }

    //description
    handleBody(event) {
        this.bodyVal = event.detail.value;
    }

    handleType(event) {
        this.grouptype = event.detail.value;
    }

    handleCreateGroup() {
        //T1 Starts
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
             //T1 ends

        if (isValidValue && this.titleVal && this.bodyVal) {
            this.isLoading = true;
            createGroup({ networkId: communityId, title: this.titleVal, type: this.grouptype, description: this.bodyVal })
                .then((result) => {
                    if (result) {
                        this.loading= false;
                        this.handleModalClose();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'User Group Created Successfully',
                                variant: 'success',
                            }),
                        );
                        window.open(CommunityURL + 'group/' + result, "_self");
                    }
                })
                .catch((error) => {
                    this.isLoading = false;
                    console.log('Error>>' + error.body);
                });


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













}