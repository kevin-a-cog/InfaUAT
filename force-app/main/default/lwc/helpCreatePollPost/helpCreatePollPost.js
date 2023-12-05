/*
 * Name			:	helpCreatePoll
 * Author		:	Narpavi Prabu
 * Created Date	: 	21/03/2022	
 * Description	:	This LWC is used to create polls.
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							                                      Tag
 **********************************************************************************************************
 Narpavi Prabu	  21/03/2022		 		            Initial version.					                                       N/A
 Deeksha Shetty   2/09/2022            I2RT-7428        Poll : Not able to create a poll in User group                             T1
 Deeksha Shetty   18/01/2023           I2RT-7545        Spammed words are getting posted in product community                      T2
 Deeksha Shetty   19/01/2023           I2RT-7462        Poll: Error message in create a poll                                       T3
 Deeksha Shetty   28 Mar,2023		   I2RT-7800        IN site is not loading in iPhone device and Safari browser 3               T4
                                                        in Mac.
 Deeksha Shetty   13/06/2023           I2RT-8423        Provision to create poll in product community                              T5
                                                        
 */


import { LightningElement, wire, api, track } from 'lwc';
import { objUtilities } from 'c/globalUtilities';
import createPoll from '@salesforce/apex/helpGroupsController.createPoll';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import blockedKeywordMsg from '@salesforce/label/c.IN_BlockedKeyword';
import getAllCommunityOptions from "@salesforce/apex/helpCommunityController.getAllCommunityOptions";
import communityId from "@salesforce/community/Id";

export default class HelpCreatePollPost extends LightningElement {
    @api recordId;
    @api objectApiName;
    heading = 'Create a Poll';
    choicelabel = 'Choices';
    choicelabel1 = 'Choice';
    choicecount = 2;
    choicenewlabel = this.choicelabel1 + this.choicecount;
    choicecount1;
    isLoading = false; //T1

    //T5 starts
    isRendered = true;
    selectedValue;
    showPollAction = false;
    //T5 ends

    bodyVal;
    choiceVal;
    showEditModal;
    @api selectedpostto;
    @track allOptions = [];

    @track listofChoice;
    filterList = [];

    @track error;

    //T2 starts
    badword;
    spammedErrorMsg;
    showSpamMessage = false;
    //T2 ends


    connectedCallback() {
        this.initData();
        /* T5 starts */
        if (window.location.pathname.includes('/s/topic/')) {
            this.showPollAction = true;
        }
         /* T5 ends */
    }

    @wire(getAllCommunityOptions, { networId: communityId })
    getoptions({ data, error }) {
        if (data) {
            this.allOptions = data;
        } else if (error) {
            console.error("error", error);
        }
    }

    get options() {
        if (this.selectedpostto != '' && this.selectedpostto != null && this.selectedpostto != undefined) {
            this.selectedValue = this.selectedpostto;
        }
        if (this.allOptions.length > 0 && this.allOptions.filter(e => e.value == this.selectedpostto).length == 0) {
            this.selectedpostto = "";
        } else if (this.selectedValue == undefined) {
            this.selectedpostto = "";
        }
        return this.allOptions;
    }

    /* T5 starts */

    handlePostChange(event) {
        this.selectedValue = event.detail.value;
        this.dispatchEvent(
            new CustomEvent("gettopicid", {
                detail: {
                    topicId: event.detail.value
                },
            })
        );
    }

    /* T5 ends */

    //title 
    handleChoice(event) {
        this.choiceVal = event.target.value;
    }

    //description
    handleBody(event) {
        this.bodyVal = event.detail.value;
    }

    handleCreatePoll() {
        let objParent = this;
        this.testcustomValidity(); //T2
        //T3 starts here
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-textarea')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        //T3 ends here
        if (isValidValue) {
            objParent.isLoading = true;
            createPoll({ grpId: this.selectedpostto, choice1: this.choiceVal, body: this.bodyVal, jsonOfListOfChoice: (this.listofChoice) })
                .then((result) => {
                    if (result) {
                        objUtilities.showToast("Success", 'Created a poll', "success", objParent);
                        objParent.isLoading = false;
                        this.handleModalClose();
                        window.open(CommunityURL + 'feed/' + result, "_self");
                    }
                })
                .catch((error) => {
                    objParent.isLoading = false;
                    /* T2 starts */
                    if (error.body.message.includes('data value too large')) {
                        this.testcustomValidity();
                    }
                    else if (error.body.message.includes(blockedKeywordMsg.split('%BLOCKED_KEYWORD%')[1])) {
                        console.log('error polll msg=', error.body.message)
                        this.badword = this.extractAllText(error.body.message); //T4
                        this.spammedErrorMsg = error.body.message.split(':')[1];
                        this.testcustomValidity();
                    }
                    else {
                        objUtilities.showToast("Error", error.body.message, "Error", objParent);
                    }
                    /* T2 ends */
                });

        }

    }

    /* T4 Starts */
    extractAllText(str) {
        const re = /"(.*?)"/g;
        const result = [];
        let current;
        while (current = re.exec(str)) {
            result.push(current.pop());
        }
        return result.length > 0 ? result : [str];
    }
    /* T4 Ends */


    //T2 starts
    testcustomValidity() {
        let searchCmp = this.template.querySelector(".pollQuesCmp");
        let searchvalue = searchCmp.value;

        let choice1Cmp = this.template.querySelector(".choiceOneCmp");
        let c1value = choice1Cmp.value;

        let choice2Cmp = this.template.querySelectorAll(".choiceMultipleCmp");

        if (!this.badword) {
            if (c1value.length > 100) {
                choice1Cmp.setCustomValidity('Max character limit is 100 for choices.');
            } else {
                choice1Cmp.setCustomValidity("");
            }
            choice1Cmp.reportValidity();

            choice2Cmp.forEach(element => {
                if (element.value.length > 100) {
                    element.setCustomValidity('Max character limit is 100 for choices.');
                }
                else {
                    element.setCustomValidity("");
                }
                element.reportValidity();
            });

        }
        else {

            let boolval1 = this.badword.some(item => searchvalue.toLowerCase().includes(item.toLowerCase()));
            let boolval2 = this.badword.some(item => c1value.toLowerCase().includes(item.toLowerCase()));

            choice2Cmp.forEach(ele => {
                let boolval3 = this.badword.some(item => (ele.value.toLowerCase()).includes(item.toLowerCase()));
                if (boolval1 || boolval2 || boolval3) {
                    this.showSpamMessage = true;
                }
                else {
                    this.showSpamMessage = false;
                }
            });
        }

    }

    //T2 ends

    initData() {
        let listofChoice = [];
        this.createRow(listofChoice);
        this.listofChoice = listofChoice;
    }

    addNewRow() {
        this.createRow(this.listofChoice);
        this.choicenewlabel = this.choicelabel1 + ++this.choicecount;
    }

    createRow(listofChoice) {
        let feedpollchoice = {};
        let counter = 2;
        if (listofChoice.length > 0) {
            feedpollchoice.index = listofChoice[listofChoice.length - 1].index + 1;
            feedpollchoice.label = 'Choice' + (counter + 1);
        } else {
            feedpollchoice.index = 1;
            feedpollchoice.label = 'Choice' + counter++;
        }
        feedpollchoice.Choice = null;
        listofChoice.push(feedpollchoice);
    }


    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;

        for (let i = 0; i < this.listofChoice.length; i++) {
            if (this.listofChoice[i].index === parseInt(index)) {
                this.listofChoice[i][fieldName] = value;
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


}