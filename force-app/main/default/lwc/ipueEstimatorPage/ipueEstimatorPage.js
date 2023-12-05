import { LightningElement, api, track, wire } from 'lwc';
import integrationMessage from '@salesforce/label/c.IPUE_Integrations_not_yet_run';
import checkForFeedExist from '@salesforce/apex/IPUE_FormController.checkForFeedItemExist';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import openChatter from '@salesforce/messageChannel/openChatter__c';
export default class IpueEstimatorPage extends LightningElement {

    INTEGRATION_MESSAGE = integrationMessage;

    @track frames = [];
    @api totalEstimation;
    @api apexRunning;
    @api apexRunningMessage;
    @api loadingRows;
    @api estimationSummaryId;
    @api isInternalUser;

    apexRunningSection = false;
    pageInstance;
    showNoteModal = false;
    sDocButtons;
    disableInputs;
    isClosedValue;
    estOutputLayoutSize = 7;

    currentFrameIndex;
    currentSectionIndex;
    currentItemIndex;
    currentNotes;

    /**************** Getter/Setter Methods *****************/

    @api get page() {
        this.frames = [...this.pageInstance.frames]
        return this.pageInstance;
    }
    set page(value) {
        this.setAttribute("page", value);
        this.pageInstance = value;
        this.frames = [...this.pageInstance.frames];
    }

    @api get titleClass() {
        return 'title';
    }

    @api get isClosed() {
        return this.isClosedValue;
    }
    set isClosed(value) {
        this.disableInputs = value;
    }

    get hasSDocButtons() {

        let buttonGroup = {};
        buttonGroup.mainButtons = [];
        buttonGroup.menuButtons = [];

        if (this.pageInstance.sDocButtons !== undefined && this.pageInstance.sDocButtons.length > 0) {

            this.pageInstance.sDocButtons.forEach(button => {
                if (button.isDefault) {
                    buttonGroup.mainButtons.push(button);
                } else {
                    buttonGroup.menuButtons.push(button);
                }

            });

        }

        this.sDocButtons = buttonGroup;

        return this.pageInstance.sDocButtons.length > 0 && this.isInternalUser ? true : false;
    }

    //handle message content for the lms
    @wire(MessageContext)
    messageContext;

    //standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        if (!this.isInternalUser) {
            this.estOutputLayoutSize = 10;
        }
        this.subsToMessageChannel();

        const inputAligncenter = document.createElement('style');
        inputAligncenter.innerText = `.input-text-align_right input{ text-align: right!important; }`;
        document.body.appendChild(inputAligncenter);
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
        if (message.description == 'refreshOutput') {
            var indexObj = this.indexObj;
            if (indexObj) {
                checkForFeedExist({ recordId: indexObj['recordId'], objectName: 'Estimation_Output__c' })
                    .then((result) => {
                        var frames = JSON.parse(JSON.stringify(this.frames));
                        var pageSection = frames[indexObj.frameindex].pageSections;
                        var secItems = pageSection[indexObj.secindex].sectionItems;
                        //if feed exist then we change the color of icon. 
                        if (result) {
                            secItems[indexObj.secitemindex].schedule.output.chatterIconClass = "svgClass";
                        } else {
                            secItems[indexObj.secitemindex].schedule.output.chatterIconClass = "";
                        }

                        this.frames = frames;
                    })
                    .catch((error) => {

                    });
            }

        }
    }

    /**************** Handle User Inputs *****************/

    // Handle User toggling Section checkbox
    toggleSection(event) {

        let copiedPage = JSON.parse(JSON.stringify(this.page));
        let frameIndex = event.target.dataset.frameIndex;
        let sectionIndex = event.target.dataset.sectionIndex;

        copiedPage.frames[frameIndex].pageSections[sectionIndex].showSection = event.target.checked;
        let copiedSection = { ...copiedPage.frames[frameIndex].pageSections[sectionIndex] };

        this.updateParent(copiedPage.Id, frameIndex, sectionIndex, copiedSection);

    }

    // Handle User opening Note Modal
    handleOpenNoteModal(event) {

        // Capture Current Place so values can be referenced when child component closes
        this.currentOutputId = event.target.dataset.output;
        this.currentFrameIndex = event.target.dataset.frameIndex;
        this.currentSectionIndex = event.target.dataset.sectionIndex;
        this.currentItemIndex = event.target.dataset.itemIndex;
        this.showNoteModal = true;
    }

    // Close Quote Modal Popup and refresh variables
    handleCloseNoteModal() {
        this.showNoteModal = false;
    }

    // Close Quote Modal Popup and refresh variables
    handleSaveNoteModal(event) {

        let copiedPage = JSON.parse(JSON.stringify(this.page));
        let updatedNotes = event.detail.notes.value; // Get Notes from Notes Modal
        let existingNotes = this.page.frames[this.currentFrameIndex].pageSections[this.currentSectionIndex].sectionItems[this.currentItemIndex].schedule.output.notes; // Get existing Notes

        if (updatedNotes != existingNotes) {

            let hasNotes;

            if (this.isEmpty(updatedNotes)) {
                hasNotes = false;
            } else {
                hasNotes = true;
            }

            this.updateParentWithNotes(copiedPage.Id, this.currentFrameIndex, this.currentSectionIndex, this.currentItemIndex, hasNotes, updatedNotes);

        }

        this.handleCloseNoteModal();

    }

    // Handle User Input from Questions on Page
    handleInput(event) {

        this.getValuesAndUpdateParent(
            event.target.dataset.frameIndex,
            event.target.dataset.sectionIndex,
            event.target.dataset.itemIndex,
            event.target.value
        );
    }

    // Handle User Input from updates to Table Cells
    handleInputFromTable(event) {

        this.getValuesAndUpdateParent(
            event.detail.frameIndex,
            event.detail.sectionIndex,
            event.detail.itemIndex,
            event.detail.value,
            event.detail.rowIndex,
            event.detail.cellIndex
        );
    }

    handleAddRowToTable(event) {

        this.updateParentWithRowChange(
            this.page.Id,               // Page Id
            event.detail.frameIndex,    // Frame Index
            event.detail.sectionIndex,  // Page Section Index
            event.detail.itemIndex,     // Section Item Index
            event.detail.tableId,       // Table Id
            event.detail.action,        // Action Type (i.e. Add Row)
            event.detail.numRows,       // Number of Rows (do not count header)
            event.detail.numColumns,    // Number of Columns
            null                        // Row Index
        );

    }

    handleRemoveRowFromTable(event) {

        this.updateParentWithRowChange(
            this.page.Id,               // Page Id
            event.detail.frameIndex,    // Frame Index
            event.detail.sectionIndex,  // Page Section Index
            event.detail.itemIndex,     // Section Item Index
            event.detail.tableId,       // Table Id
            event.detail.action,        // Action Type (i.e. Add Row)
            null,                       // Number of Rows (do not count header)
            null,                       // Number of Columns
            event.detail.rowIndex       // Row Index
        );

    }

    // Handle User clicking sDoc Button
    handleSDocButtonClick(event) {

        let templateId = event.target.value;

        let link = '/apex/SDOC__SDCreate1?' +
            'id=' + this.estimationSummaryId + '&' +
            'docList=' + templateId + '&' +
            'object=Estimation_Summary__c' + '&' +
            'autodownload=True';

        window.open(link);

    }

    /**************** Helper Methods *****************/

    getValuesAndUpdateParent(frameIndex, sectionIndex, itemIndex, value, rowIndex, cellIndex) {

        let copiedPage = JSON.parse(JSON.stringify(this.page));
        let item = copiedPage.frames[frameIndex].pageSections[sectionIndex].sectionItems[itemIndex];

        if (item.isSchedule || item.isTable) {

            let copiedSection = { ...copiedPage.frames[frameIndex].pageSections[sectionIndex] };

            if (item.isSchedule) {
                this.updateSchedule(item, copiedSection, value);
            } else if (item.isTable) {
                this.updateTableCell(item, copiedSection, value, rowIndex, cellIndex);
            }

            copiedSection.sectionItems[itemIndex] = item;
            this.updateParent(copiedPage.Id, frameIndex, sectionIndex, copiedSection);

        }

    }

    updateSchedule(item, copiedSection, value) {
        let oldValue = item.schedule.output.value;
        switch (item.schedule.type) {
            case "Number":
                item.schedule.output.value = value > 0 ? value : 0;
                break;
            case "Picklist":
                item.schedule.output.value = item.schedule.picklistValues.find(option => option.value === value).label;
                item.schedule.output.picklistValue = value;
                break;
            default:
                item.schedule.output.value = value;
                break;
        }

        let scheduleCount = 0;
        let inputCount = 0;

        if (!item.schedule.isCalculated) {

            scheduleCount++;

            // If the field has a value populated, increate input count
            if ((item.schedule.type == 'Number' && item.schedule.output.value >= 0) ||
                item.schedule.output.value
            ) {
                inputCount++;
            }

        }
        if (oldValue === undefined) {
            copiedSection.numerator += 1;
        }
        copiedSection.progress = inputCount > 0 ? (copiedSection.numerator / copiedSection.denominator) * 100 : 0;
        copiedSection.inputMissing = inputCount != scheduleCount ? true : false;
        copiedSection.showSectionSpinner = !copiedSection.inputMissing ? true : false;

    }

    updateTableCell(item, copiedSection, value, rowIndex, cellIndex) {

        let tempCell = item.table.rows[rowIndex].cells[cellIndex];

        switch (tempCell.datatype) {
            case "Number":
                tempCell.output.value = value > 0 ? value : 0;
                break;
            case "Picklist":
                tempCell.output.value = tempCell.picklistValues.find(option => option.value === value).label;
                tempCell.output.picklistValue = value;
                break;
            default:
                tempCell.output.value = value;
                break;
        }

        item.table.rows[rowIndex].cells[cellIndex] = tempCell;

        copiedSection.inputMissing = false;
        copiedSection.showSectionSpinner = true;

    }

    isEmpty(str) {
        return (!str || str.length === 0);
    }

    /**************** Dispatch Events (Send to Parent) *****************/

    updateParent(pageId, frameIndex, sectionIndex, copiedSection) {

        // Update Parent with new values
        const updateEvent = new CustomEvent("update", {
            detail: {
                pageId: pageId,
                frameIndex: frameIndex,
                sectionIndex: sectionIndex,
                section: copiedSection,
            }
        });

        this.dispatchEvent(updateEvent);
    }

    updateParentWithNotes(pageId, frameIndex, sectionIndex, itemIndex, hasNotes, notes) {

        // Update Parent with new values
        const updateEvent = new CustomEvent("updatenotes", {
            detail: {
                pageId: pageId,
                frameIndex: frameIndex,
                sectionIndex: sectionIndex,
                itemIndex: itemIndex,
                hasNotes: hasNotes,
                notes: notes
            }
        });

        this.dispatchEvent(updateEvent);
    }

    updateParentWithRowChange(pageId, frameIndex, sectionIndex, itemIndex, tableId, action, numRows, numColumns, rowIndex) {

        // Update Parent with new values
        const updateEvent = new CustomEvent("updaterow", {
            detail: {
                pageId: pageId,
                frameIndex: frameIndex,
                sectionIndex: sectionIndex,
                itemIndex: itemIndex,
                tableId: tableId,
                action: action,
                numRows: numRows,
                numColumns: numColumns,
                rowIndex: rowIndex
            }
        });

        this.dispatchEvent(updateEvent);
    }
    handleChatterClick(event) {
        var recordId = event.target.dataset.id;
        var indexObj = {};
        indexObj['recordId'] = recordId;
        indexObj['frameindex'] = parseInt(event.target.dataset.frameindex);
        indexObj['secindex'] = parseInt(event.target.dataset.secindex);
        indexObj['secitemindex'] = parseInt(event.target.dataset.secitemindex);
        this.indexObj = indexObj;
        //sending message to open chatter via message channel
        const payload = { recordId: recordId, publisherContext: 'RECORD', feedType: 'Record', description: 'OpenChatter', isFeedEnabled: true, calledFrom: 'Output' };
        publish(this.messageContext, openChatter, payload);
    }

}