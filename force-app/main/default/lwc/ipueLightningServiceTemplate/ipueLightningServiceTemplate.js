import { LightningElement, api } from 'lwc';

export default class IpueLightningServiceTemplate extends LightningElement {

    @api templates;
    @api showSpinner = false;

    // @wire(fetchIntegrationWrapper, {pageSectionId: '$pageSectionId' })
    //     returnedResults(existingData) {

    //     }
}