import { LightningElement, api, track, wire } from 'lwc';
export default class IpueEstimatorPageDoc extends LightningElement {

    @track frames = [];
    @api totalEstimation;
    @api apexRunning;
    @api apexRunningMessage;
    @api loadingRows;
    @api estimationSummaryId;
    @api isInternalUser;

    pageInstance;
    showNoteModal = false;
    sDocButtons;
    disableInputs;
    estOutputLayoutSize = 7;

    currentFrameIndex;
    currentSectionIndex;
    currentItemIndex;
    currentNotes;

    /**************** Getter/Setter Methods *****************/

    @api get page() {
        this.frames = [...this.pageInstance.frames];
        return this.pageInstance;
    }
    set page(value) {
        this.setAttribute("page", value);
        this.pageInstance = value;
        this.frames = [...this.pageInstance.frames];
    }

    //standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        this.disableInputs = true;

    }
}