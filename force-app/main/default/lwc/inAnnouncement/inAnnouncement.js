import { LightningElement, track, wire } from 'lwc';
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import getAnnouncementList from '@salesforce/apex/InAnnouncementBanner.getAnnouncementList';
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import IN_StaticResource2 from '@salesforce/resourceUrl/InformaticaNetwork2';

export default class InAnnouncement extends LightningElement {
    anouncementLogo = IN_StaticResource + '/announcement.png';
    closeLogo = IN_StaticResource + '/close.png';
    @track announcementMessage = "";
    @track inAnnouncementContainer = 'd-none';

    connectedCallback() {
        Promise.all([
            loadStyle(this, IN_StaticResource2 + "/css/inannouncement.css")
        ])
    }

    @wire(getAnnouncementList)
    AnnouncementList({ error, data }) {
        if (data) {
            console.log('getAnnouncementList result => ' + JSON.stringify(data));
            this.announcementMessage = data;
            this.inAnnouncementContainer = data.length > 0 ? "d-block" : "d-none";
        }
        else if (error) {
            console.log('getAnnouncementList Error => ' + JSON.stringify(error));
        }
    }

    hideAnnouncement(event) {
        let targetSection = event.currentTarget.dataset.id;
        this.template.querySelector(`[data-id="${targetSection}"]`).style = "display: none;";
    }
}