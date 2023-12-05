import { LightningElement, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';

export default class EsCollapsible extends LightningElement {
    renderedCallback() {
        Promise.all([
            loadScript(this, bootstrap + '/bootstrap-4.5.3-dist/js/jquery-3.5.1.slim.min.js'),
            loadScript(this, bootstrap + '/bootstrap-4.5.3-dist/js/bootstrap.min.js')
        ])
        .then(() => {
            console.log("All scripts and CSS are loaded. 2.");
            //data attribute support to be checked
            //$(this.template.querySelector('.collapse')).collapse('toggle');
        })
        .catch(error => {
            console.log("failed to load the scripts");
        });
    }
    handleClick() {       
        $(this.template.querySelector('.collapse')).collapse('toggle');
    }

}