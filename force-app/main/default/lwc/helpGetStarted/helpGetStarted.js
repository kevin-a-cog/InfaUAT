import { LightningElement, track } from 'lwc';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";

export default class HelpGetStarted extends LightningElement {

    playicon = IN_StaticResource + '/playwhite.png';
    displaymodal = false;

    //For adding onclick event to close modal window on click
    constructor() {
        super();
        this.template.addEventListener("click", (event) => {
            if (event.target) {
                const classList = [...event.target.classList];
                if (classList.includes(OUTER_MODAL_CLASS)) {
                    this.closeModal();
                }
            }
        });
    }

   
    displayVideo(event) {
        console.log('Id captured='+JSON.stringify(event.currentTarget.dataset.id));
        let rowId = event.currentTarget.dataset.id;
        if (rowId) {
            this.embeddedhtmlmodal = 'https://www.youtube.com/embed/MCr1cNVHRCk';
            if(this.embeddedhtmlmodal) this.displaymodal = true;
        }

    }

    closeModal() {
        this.displaymodal = false;
    }
}