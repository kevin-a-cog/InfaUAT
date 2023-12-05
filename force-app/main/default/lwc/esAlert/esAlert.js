import { LightningElement, api, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsAlert extends LightningElement {

    alertImage = ESUPPORT_RESOURCE + '/alert-notification.svg';
    @api alertMessage;
    @api serviceDetails;
    @track isAlertOpen = true;
    @track icon_name = "utility:chevrondown";
    @track icon_title = "icon_down";
    @track service_pods = "content-justified content-pods es-hide";

    closeAlert() {
        // to close modal set isModalOpen tarck value as false
        this.isAlertOpen = false;
    }

    handleOutageDisplay() {
        if (this.icon_name == "utility:chevrondown") {
            this.icon_name = "utility:chevronup";
            this.icon_title = "icon_up";
            this.service_pods = "content-justified content-pods es-block";
        }
        else {
            this.icon_name = "utility:chevrondown";
            this.icon_title = "icon_down";
            this.service_pods = "content-justified content-pods es-hide";
        }
    }
}