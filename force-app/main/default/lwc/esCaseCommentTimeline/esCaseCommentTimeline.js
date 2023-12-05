import { api, LightningElement, track } from 'lwc';
import Icons from '@salesforce/resourceUrl/icons';
import { NavigationMixin } from 'lightning/navigation';

export default class EsCaseCommentTimeline extends LightningElement {
    @api commentList;
    @api access;
    @api caseRecordId;

    isEdit = false;
    isReply = false;
    @track
    caseCommentToEdit;
    recordId;
    parentCommentId;
    imageURL = {
        draft: Icons + '/sketching-24.png',
        calendar: Icons + '/clock-32.png',
        submitted: Icons + '/verification-24.png',
        draft_16: Icons + '/sketching-16.png',
        calendar_16: Icons + '/clock-16.png',
        submitted_16: Icons + '/verification-16.png',
    };

    get isPrivate() {
        return this.access === 'Private';
    }

    get showModal() {
        return this.isEdit || this.isReply;
    }

    get modalHeader() {
        return this.isEdit ? 'Edit Comment' : (this.isReply ? 'Reply' : '');
    }

    connectedCallback() {
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
         .timelineAttachments .slds-pill__remove {
            display: none !important;
        }
        
        .timelineAttachments .slds-pill_container {
            border: none !important;
        }
        
        .fill_brand svg {
            fill: #0070d2;
        }`;
        document.head.appendChild(globalStyle);
    }

    handleClick(event) {
        switch (event.target.name) {
            case 'edit':
                this.recordId = event.target.dataset.id;
                console.log('comms>>', JSON.parse(JSON.stringify(this.commentList)));
                this.commentList.forEach(commWrap => commWrap.comments.forEach(element => {
                    if (element.Id == this.recordId) {
                        this.caseCommentToEdit = element;
                    }
                }));
                this.isEdit = true;
                break;
            case 'close':
                this.recordId = null;
                this.caseCommentToEdit = null;
                this.isEdit = false;
                this.isReply = false;
                this.parentCommentId = null;
                break;

            case 'reply':
                this.isReply = true;
                this.recordId = null;
                this.caseCommentToEdit = null;
                this.isEdit = false;
                this.parentCommentId = event.target.dataset.id;

                break;
            case 'showReply':
                event.stopPropagation()
                this.dispatchEvent(new CustomEvent("showreply", {
                    detail: event.target.dataset.id
                }));
                break;
            case 'hideReply':
                event.stopPropagation()
                this.dispatchEvent(new CustomEvent("hidereply", {
                    detail: event.target.dataset.id
                }));
                break;
            default:
                break;
        }
    }

    handleSuccess(event) {
        this.recordId = null;
        this.caseCommentToEdit = null;
        this.isEdit = false;
        this.isReply = false;
        this.parentCommentId = null;
    }

    handleWheel(event) {
        console.log('HERE');
    }
}