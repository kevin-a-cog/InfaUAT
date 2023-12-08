import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkForFeedExist from '@salesforce/apex/IPUE_FormController.checkForFeedItemExist';
import fetchFormData from '@salesforce/apex/IPUE_FormController.fetchFormData';
import saveInput from '@salesforce/apex/IPUE_FormController.processInput';
import callIntegrations from '@salesforce/apex/IPUE_FormController.callIntegrations';
import updateTableRows from '@salesforce/apex/IPUE_FormController.updateElasticTableRows';
import { NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import openChatter from '@salesforce/messageChannel/openChatter__c';
import LOGO_URL from '@salesforce/contentAssetUrl/INFLogoHorFCRGBpng';

//export default class IpueEstimatorHost extends LightningElement {
export default class IpueEstimatorHost extends NavigationMixin(LightningElement) {

    // Api properties
    @api recordId;
    @api formId;

    // Private properties
    // Front-end things
    logoUrl = LOGO_URL;

    // Data
    @api formData = {};
    accountName;
    accountNumber;
    accountAddress;
    isClosed;
    totalEstimation;
    integrationCount;
    pageSectionIds = [];

    // State management
    formLoaded = false;
    accountLoaded = false;
    loadingRows = false;
    get fullyLoaded() {
        return this.formLoaded && this.accountLoaded;
    }
    //for chatter functionality
    summaryChatterIconClass;
    isInternalUser;
    // Debouncing
    pendingSectionUpdates;
    pendingUpdate;
    apexRunning = false;
    apexRunningMessage;

    pageIndex;
    frameIndex;
    sectionIndex;

    error = false;
    @api errorTitle;
    @api errorMessage;

    firstLoad = true;
    currentPageIndex;
    currentPage;
    get hasNextPage() {
        return this.currentPageIndex < this.formData?.pages?.length - 1;
    }
    get hasPrevPage() {
        return this.currentPageIndex > 0;
    }
    get requiredFieldsMissing() {

        let missingFieldCount = 0;

        if (!this.isClosed) {
            this.formData.pages[this.currentPageIndex].frames.forEach(frame => {
                frame.pageSections.forEach(section => {
                    section.sectionItems.forEach(sectionItem => {

                        // If the field is required, not calculated, and the input is blank, mark as missing
                        if (sectionItem.schedule !== undefined && sectionItem.schedule.isRequired && !sectionItem.schedule.isCalculated &&
                            (sectionItem.schedule.output.value == undefined || sectionItem.schedule.output.value === '')
                        ) {
                            missingFieldCount++;
                        }
                    });
                });
            });
        }

        return missingFieldCount > 0;
    }
    //handle message content for the lms
    @wire(MessageContext)
    messageContext;

    /************ Initialization *************/

    connectedCallback() {
        this.subsToMessageChannel();
        this.applyCssStyleSheet()
        this.loadForm();
    }

    //Encapsulate logic for LMS subscribe
    subsToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                openChatter,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    // Handler for message received by component
    handleMessage(message) {
        if (message.description == 'refreshSummary') {
            checkForFeedExist({ recordId: this.recordId, objectName: 'Estimation_Summary__c' })
                .then((result) => {
                    if (result) {
                        //if feed exist then we change the color of icon.       
                        this.summaryChatterIconClass = 'svgClass';
                    } else {
                        //if feed exist then we remove the color of icon.       
                        this.summaryChatterIconClass = '';
                    }
                })
                .catch((error) => {

                });
        }
    }
    //applying custom css
    applyCssStyleSheet() {
        document.styleSheets[0].insertRule(`.svgClass svg{
            fill:#f3f3f3;}`);

        document.styleSheets[0].insertRule(`.svgClass button{
            background:#0171d2;
        }`);
    }
    // Show the first page once the form is rendered for the first time
    renderedCallback() {
        if (this.firstLoad && this.fullyLoaded) {
            this.jumpToPage(0);
            this.firstLoad = false;
        }
    }

    loadForm() {

        fetchFormData({
            recordId: this.recordId
        })
            .then((result) => {

                if (result) {

                    this.formData = JSON.parse(JSON.stringify(result.form)); // Create deep clone
                    //storing attr req for chatter func.
                    this.summaryChatterIconClass = result.chatterIconClass;
                    this.isInternalUser = result.isUserInternal;
                    this.accountName = result.accountModel.name;
                    this.accountNumber = result.accountModel.accountNumber;
                    this.accountAddress = result.accountModel.address;
                    //Make the Estimator read Only if the opty is closed or if the current user has read only access to the estimation summary record
                    this.isClosed = result.hasReadOnlyAccess;
                    this.totalEstimation = result.totalEstimation ? result.totalEstimation : 0;
                    this.integrationCount = result.integrationCount;
                    this.pageSectionIds = result.pageSectionIds;
                    this.sDocButtons = result.sDocButtons;
                    this.formLoaded = true;
                    this.accountLoaded = true;

                    console.log('result: ', result);

                } else {
                    this.error = true;
                    this.errorMessage = 'This page is not available for manually uploaded estimations. Please navigate to the "Details" tab for the total IPU and the “Related” tab for the IPU estimated for each service.';
                }

            })
            .catch(error => {

                console.error('Error Loading IPU Estimator: ', error);
                let message = error;

                // If a more specific error can be found, return it
                if (error.body && error.body.message) {
                    message = error.body.message;
                }

                this.error = true;
                this.errorTitle = 'Error Loading IPU Estimator';
                this.errorMessage = message;

                this.showToast(
                    'Error Loading IPU Estimator',
                    'Form or related data is not setup correctly. Please contact your System Administrator. ',
                    'error',
                    'sticky'
                );
            });

    }

    /************ Handle Dispatched Events *************/

    handleUserInput(event) {

        this.pageIndex = this.formData.pages.findIndex(page => {
            return page.Id === event.detail.pageId;
        });

        this.frameIndex = event.detail.frameIndex;
        this.sectionIndex = event.detail.sectionIndex;

        // Using indexes, find the applicable section and update it
        this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections[this.sectionIndex] = { ...event.detail.section };
        this.formData = { ...this.formData };

        if (this.apexRunning) {

            this.pendingSectionUpdates = this.pendingSectionUpdates || [];
            let index = this.pendingSectionUpdates.findIndex((elem) => elem.Id === event.detail.section.Id);

            if (index >= 0) {
                this.pendingSectionUpdates[index] = JSON.parse(JSON.stringify(event.detail.section));
            } else {
                this.pendingSectionUpdates.push(JSON.parse(JSON.stringify(event.detail.section)));
            }

        } else if (!event.detail.section.inputMissing) {
            this.apexRunningMessage = 'Calculating Estimates...';
            this.handleSave(event.detail.section);
        }
    }

    handleNoteInput(event) {

        const pageIndex = this.formData.pages.findIndex(page => {
            return page.Id === event.detail.pageId;
        });

        const frameIndex = event.detail.frameIndex;
        const sectionIndex = event.detail.sectionIndex;
        const itemIndex = event.detail.itemIndex;
        const hasNotes = event.detail.hasNotes ? true : false;
        const notes = event.detail.notes;

        // Using indexes, find the applicable section and update it
        this.formData.pages[pageIndex].frames[frameIndex].pageSections[sectionIndex].sectionItems[itemIndex].schedule.output.hasNotes = hasNotes;
        this.formData.pages[pageIndex].frames[frameIndex].pageSections[sectionIndex].sectionItems[itemIndex].schedule.output.notes = notes;
        this.formData = { ...this.formData };
    }

    handleRowUpdate(event) {

        console.log('handle add row ipuehost!');

        this.pageIndex = this.formData.pages.findIndex(page => {
            return page.Id === event.detail.pageId;
        });
        this.frameIndex = event.detail.frameIndex;
        this.sectionIndex = event.detail.sectionIndex;
        const itemIndex = event.detail.itemIndex;

        updateTableRows({
            estimationSummaryId: this.formData.estimationSummaryId,
            tableId: event.detail.tableId,
            action: event.detail.action,
            numRows: event.detail.numRows,
            numColumns: event.detail.numColumns,
            rowIndex: event.detail.rowIndex
        })
            .then((result) => {

                let table = this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections[this.sectionIndex].sectionItems[itemIndex].table;

                if (event.detail.action == 'Add Row') {

                    let tableRow = result.rows[0];
                    let rowIndex = event.detail.numRows - 1;

                    table.rows.splice(
                        rowIndex,   // Index to insert element before
                        0,          // Remove 0 elements 
                        tableRow    // Row to Add
                    );

                } else if (event.detail.action == 'Remove Row') {
                    table = result;
                }

                this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections[this.sectionIndex].sectionItems[itemIndex].table = { ...table };
                this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections[this.sectionIndex].showSectionSpinner = true;
                this.formData = JSON.parse(JSON.stringify(this.formData));

                let pageSection = this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections[this.sectionIndex];
                this.apexRunningMessage = 'Re-Calculating Estimates...';
                this.handleSave(pageSection);

            })
            .catch(error => {

                console.error('Error Updating Table Row: ', error);
                let message = error;
                this.loadingRows = false;

                // If a more specific error can be found, return it
                if (error.body && error.body.message) {
                    message = error.body.message;
                }

                this.error = true;
                this.errorTitle = 'Error Updating Table Row';
                this.errorMessage = message;

                this.showToast(
                    'Error Updating Table Row',
                    'Please contact your System Administrator. ',
                    'error',
                    'sticky'
                );
            });

    }

    /************ Helper Methods *************/

    async handleSave(payload) {

        console.log('handleSave');

        // Indicate to child component that Apex is Running so loading spinners are shown
        this.apexRunning = true;

        try {

            let saveResult = await this.callApexSaveInput(payload);

            if (saveResult != null) {
                this.updateOutputValues(saveResult);
            }

            if (this.integrationCount > 0) {
                this.apexRunningMessage = 'Refreshing Integrations...';
                await this.getIntegrations();
            }

        } catch (error) {

            console.error('Error saving values: ', error);
            let message = error.body && error.body.message ? error.body.message : 'Unknown Error';
            this.apexRunning = false;

            this.showToast(
                'Error Saving/Calculating Values',
                message,
                'error',
                'sticky'
            );

        } finally {

            if (this.pendingSectionUpdates) {

                let payload = this.pendingSectionUpdates[0];
                payload.schedules = this.pendingSectionUpdates.reduce((prev, curr) => prev.concat(curr.schedules), []);
                this.pendingSectionUpdates = null;
                this.handleSave(payload);

            } else {

                // Using indexes, update all loading spinners to false
                this.formData.pages[this.pageIndex].frames[this.frameIndex].pageSections.forEach(section => {
                    section.showSectionSpinner = false;
                });

                this.formData = { ...this.formData };
                this.apexRunning = false;
                this.loadingRows = false;
            }

        }
    }

    async callApexSaveInput(payload) {

        // Call Apex Controller to calculate values
        let saveResult = await saveInput({
            formInputJSON: JSON.stringify(payload),
            formId: this.formData.Id,
            estimationId: this.formData.estimationSummaryId
        });

        // If there are updates in the UI pending apex callout, do those first
        if (this.pendingSectionUpdates) {

            let newPayload = this.pendingSectionUpdates[0];
            newPayload.schedules = this.pendingSectionUpdates.reduce((prev, curr) => prev.concat(curr.schedules), []);
            this.pendingSectionUpdates = null;

            let updatedValues = await this.callApexSaveInput(newPayload);

            // Update the return value with the fresher data
            saveResult = updatedValues;

        }

        return saveResult;
    }

    updateOutputValues(resultWrapper) {

        this.formData.pages.forEach(page => {
            page.frames.forEach(frame => {
                frame.pageSections.forEach(section => {

                    // Update Section Total Value
                    if (resultWrapper.pageSectionTotalMap[section.Id] != null) {
                        section.sectionTotal = resultWrapper.pageSectionTotalMap[section.Id];
                    }

                    // Update the calculated value shown to user in Estimation Output
                    section.sectionItems.forEach(item => {

                        if (item.isSchedule) {
                            let schedule = item.schedule;
                            if (resultWrapper.outputMap[schedule.output.Id] != null) {
                                schedule.output.value = resultWrapper.outputMap[schedule.output.Id].User_Value__c;
                            }
                        } else if (item.isTable) {

                            item.table.rows.forEach(row => {
                                row.cells.forEach(cell => {

                                    if (cell.output != null && resultWrapper.outputMap[cell.output.Id] != null) {
                                        cell.output.value = resultWrapper.outputMap[cell.output.Id].User_Value__c;
                                    }
                                });
                            });
                        }
                    })
                });
            });
        });

        this.totalEstimation = resultWrapper.totalEstimation ? resultWrapper.totalEstimation : 0;
        this.formData = JSON.parse(JSON.stringify(this.formData));
    }

    async getIntegrations() {

        try {
            let result = await callIntegrations({
                formId: this.formData.Id,
                estimationId: this.formData.estimationSummaryId,
                pageSectionIds: this.pageSectionIds
            })

            if (result != null) {
                this.updateIntegrationValues(result);
            }

        } catch (error) {
            console.error('Error saving values: ', error);
            let message = error.body && error.body.message ? error.body.message : 'Unknown Error';

            this.showToast(
                'Error Handling Integration Values',
                message,
                'error',
                'sticky'
            );
        }

    }

    updateIntegrationValues(returnMap) {

        this.formData.pages.forEach(page => {
            page.frames.forEach(frame => {
                frame.pageSections.forEach(section => {
                    section.sectionItems.forEach(item => {
                        if (item.isTemplate) {
                            let template = item.template;
                            // If the Template Id matches, update the Content shown to user
                            if (returnMap[template.templateId] != null) {
                                template.content = returnMap[template.templateId].content;
                                template.contentFound = true;
                            }
                        }
                    })
                })
            })
        })
        this.formData = JSON.parse(JSON.stringify(this.formData));
    }

    /************ Navigation *************/

    // Page navigation
    toPrevPage() {
        this.jumpToPage(this.currentPageIndex - 1);
    }

    toNextPage() {
        this.jumpToPage(this.currentPageIndex + 1);
    }

    jumpToPage(pageIndex) {
        if (pageIndex >= 0 && pageIndex < this.formData.pages.length) {
            this.hideCurrentPage();
            this.currentPageIndex = pageIndex;
            this.currentPage = this.formData.pages[pageIndex];
            this.showCurrentPage();
        }
    }

    hideCurrentPage() {
        let selector = '.pagesDiv .' + this.currentPage?.Id;
        let currentPageDiv = this.template.querySelector(selector);
        if (currentPageDiv) {
            currentPageDiv.style.display = 'none';
        }
    }

    showCurrentPage() {
        let selector = '.pagesDiv .' + this.currentPage?.Id;
        let currentPageDiv = this.template.querySelector(selector);
        if (currentPageDiv) {
            currentPageDiv.style.display = 'block';
        }
    }

    showToast(title, message, variant, modeOption) {

        let mode = modeOption ? modeOption : 'dismissible';

        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        }));
    }

    handleChatterClick() {
        const payload = { recordId: this.recordId, publisherContext: 'RECORD', feedType: 'Record', description: 'OpenChatter', isFeedEnabled: true, calledFrom: 'Summary' };
        publish(this.messageContext, openChatter, payload);
    }

}