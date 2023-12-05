import {api, LightningElement, track, wire} from 'lwc';
import getFileList from "@salesforce/apex/psa_om_InterlockFileController.getEngagementFiles";

export default class PsaOMInterlockFiles extends LightningElement {

    @api recordId;
    @track relatedFilesList;
    error;
    filesCount = 0;
    hasFiles = false;

    get getFilesLength() {
        return `ENGAGEMENT FILES (${this.filesCount})`;
    }
    get getHasFileCheck() {       
        return this.hasFiles;
    }
    connectedCallback() {
        getFileList({ projId: this.recordId })
            .then(result => {
                this.relatedFilesList = result;
                this.filesCount = result.length;
                if(this.filesCount > 0){
                    this.hasFiles = true;
                }
                this.error = undefined;

            })
            .catch(error => {
                this.error = error;
                this.relatedFilesList = undefined;       
            })
    }
}