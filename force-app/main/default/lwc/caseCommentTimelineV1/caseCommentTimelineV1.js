/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh D              01-Dec-2021     I2RT-5028           Specify 'UTC' format for grouped Date and 
                                                            convert Case Comments DateTime to user's device timezone  T01

 */

import { LightningElement, api, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class CaseCommentTimeline extends LightningElement {
    Avatar = ESUPPORT_RESOURCE + '/avatar01.png';

    @api caseUpdates;
    @api isSortedByEarliest = false;        // Tejasvi Royal -> eSupport Feedback Enhancements
    @api showAddComment = false;            // Vignesh -> I2RT-482: show add comment only for read/write contact 

    // UNUSED: @api isAttachmentPresent;
    // UNUSED: @api caseComments;
    // UNUSED: @api notification;   

    @track isExpanded = true;
    @track buttonClicked = true;
    @track isExpanded = true;
    @track iconName = 'utility:down';
    @track className = 'slds-media slds-media_center es-slds-media slds-show';
    // @track inboundimgsrc = ESUPPORT_RESOURCE + '/inbound.svg';
    // @track outboundimgsrc = ESUPPORT_RESOURCE + '/outbound.svg';
    @track inboundImgSrc = ESUPPORT_RESOURCE + '/next_action_infa.svg';

    // DEPRECATED (Getter used instead): @track sortedBy = 'Sorted by Latest';
    // DEPRECATED (Getter used instead): @track noCaseComment = false;

    get noCaseComment() {
        return (this.caseUpdates.length === 0) ? true : false;
    }
    get sortedBy() {
        return (this.isSortedByEarliest === false) ? 'Sorted by Latest' : 'Sorted by Earliest';
    }

    get userTimeZone(){ // <T01>
        return new Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
    
    connectedCallback() {
        // console.log('@@caseComments= '+JSON.stringify(this.caseComments.comment));
        // console.log('caseUpdates --> ' + JSON.stringify(this.caseUpdates));
    }

    renderedCallback() {
        // $(this.template.querySelectorAll('.es-slds-media__content')).attr("style", "background-color:yellow");
    }

    // UNUSED:
    /*
    handleToggle(event) {
        let currentDiv = event.target;
        let targetIdentity = event.target.dataset.targetId;
        let targetDiv = this.template.querySelector(`[data-id="${targetIdentity}"]`);
        targetDiv.buttonClicked = !targetDiv.buttonClicked;
        targetDiv.className = targetDiv.buttonClicked ? 'slds-media slds-media_center es-slds-media slds-hide' : 'slds-media slds-media_center es-slds-media slds-show';
        currentDiv.iconName = targetDiv.buttonClicked ? 'utility:right' : 'utility:down';
    }*/
   
    handleClick(event) {
        const buttonName = event.currentTarget.name;
        console.log( 'Button Name is ' + buttonName );

        switch(buttonName) {
            case 'Collapse':
                this.isExpanded = false;
                this.className = this.buttonClicked ? 'slds-hide' : 'slds-media slds-media_center es-slds-media slds-show';
                this.iconName = this.buttonClicked ? 'utility:right' : 'utility:down';
                break;   
            case 'Expand':
                this.isExpanded = true;
                this.className = this.buttonClicked ? 'slds-media slds-media_center es-slds-media slds-show' : 'slds-hide';
                this.iconName = this.buttonClicked ? 'utility:down' : 'utility:right';
                break;
            case 'Add Updates/Files':           // Amarender - I2RT-3151 - Modified Add Comment  to Add Updates/Files 
                // Amarender - I2RT-3151 - Modified addcomment to addfiles
                this.dispatchEvent(new CustomEvent('addfiles')); // Tejasvi Royal -> eSupport Feedback Enhancements
            default:
                break;
        }
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    handleCommentSearch(event) {
        const searchKey = event.detail.value;
        console.log('Comment SearchKey -> ' + searchKey);
        if (searchKey.length >= 2) {
            this.dispatchEvent(new CustomEvent('commentsearchchange', { detail: searchKey }));
        }
        if (searchKey.length === 0) {
            this.dispatchEvent(new CustomEvent('commentsearchchange', { detail: searchKey }));
        }
    }

    // Tejasvi Royal -> eSupport Feedback Enhancements
    handleCommentSort(event) {
        const sortBy = event.detail.value;
        console.log('Comment SortBy Selection -> ' + sortBy);
        if (sortBy === 'Latest') {
            this.isSortedByEarliest = false;
            this.dispatchEvent(new CustomEvent('commentsortselection', { detail: 'LastModifiedDate DESC' }));
        }
        if (sortBy === 'Earliest') {
            this.isSortedByEarliest = true;
            this.dispatchEvent(new CustomEvent('commentsortselection', { detail: 'LastModifiedDate ASC' }));
        }
    }
}