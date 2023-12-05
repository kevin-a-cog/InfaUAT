import { LightningElement } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';

export default class EsCaseTabs extends LightningElement {

    renderedCallback() {
        Promise.all([
            loadScript(this, bootstrap + '/bootstrap-4.5.3-dist/js/jquery-3.5.1.slim.min.js'),
            loadScript(this, bootstrap + '/bootstrap-4.5.3-dist/js/bootstrap.min.js')
        ])
        .then(() => {
            console.log("All scripts and CSS are loaded. 3.");
            //data attribute support to be checked
            //$(this.template.querySelector('.collapse')).collapse('toggle');
        })
        .catch(error => {
            console.log("failed to load the scripts");
        });
    }
    handleClick() { 
        /* Not working */ 
        // $(this.template.querySelector('.myTab li:first-child a')).tab('show');
        $(this.template.querySelector('.myTab li:last-child a')).tab('show');   
    }

}