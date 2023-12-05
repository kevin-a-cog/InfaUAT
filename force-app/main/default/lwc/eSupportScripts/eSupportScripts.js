import { LightningElement, track, wire} from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import global_styles from '@salesforce/resourceUrl/eSupportRrc';
import analytics_script from '@salesforce/label/c.adobe_analytics'; 
import { getRecord } from 'lightning/uiRecordApi';
import FEDERATION_FIELD from '@salesforce/schema/User.FederationIdentifier';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.


export default class ESupportScripts extends LightningElement {
    @track fedId;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [FEDERATION_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.fedId = data.fields.FederationIdentifier.value;
            window.liveUser = this.fedId;
        }
    }
    connectedCallback(){
        document.title = 'Informatica Support';  
        document.body.setAttribute('style', 'display: none;');
        Promise.all([
            loadScript(this, 'https://code.jquery.com/jquery-3.6.0.min.js'),
            loadStyle(this, bootstrap + '/bootstrap-4.5.3-dist/css/bootstrap.min.css'),
            loadStyle(this, global_styles + '/css/fonts.css'),
            loadStyle(this, global_styles + '/css/global.css'),
            loadStyle(this, global_styles + '/css/sldsException.css'),
            loadStyle(this, global_styles + '/css/form.css'),
            loadStyle(this, global_styles + '/css/componentCustomisation.css'),
            loadStyle(this, global_styles + '/css/caseCreation.css'),
            loadStyle(this, global_styles + '/css/utility.css'),
            loadStyle(this, global_styles + '/css/media.css'),
            loadStyle(this, global_styles + '/css/aemOverride.css'),
            loadStyle(this, global_styles + '/css/fontawesome.min.css'),
            loadScript(this, global_styles + '/js/fontawesome.min.js'),
            loadScript(this, global_styles + '/js/header.js')
        ])
        .then(() => {
            console.log("All scripts and CSS are loaded.")
            console.log('disabling spinner');
            document.body.setAttribute('style', 'display: block;');

            this.showSpinner = false;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            document.body.setAttribute('style', 'display: block;');

        });

        if (analytics_script != ""){
            Promise.all([
                loadScript(this, analytics_script)
            ])
            .then(() => {
                console.log("Adobe analytics script loaded.")
                Promise.all([
                    loadScript(this, global_styles + '/js/analytics/custom.js')
                ])
                .then(() => {
                   /** START-- adobe analytics */
                    try {
                        console.log("FEDID ", this.fedId);
                        util.setOktaUserID(this.fedId);
                    }
                    catch(ex) {
                        console.log(ex.message);
                    }
                    /** END-- adobe analytics*/
                });

            })
            .catch(() => {
                console.log(JSON.stringify(error));
            }); 
        }
        if (window.location.href.indexOf('support.informatica.com') > 1){
            Promise.all([
                loadScript(this, global_styles + '/js/walkme-tracking.js')
            ])
            .then(() => {
                console.log("Walkme script loaded");
            })
            .catch(() => {
                console.log(JSON.stringify(error));
            }); 
        }
        if (window.location.href.indexOf('support.informatica.com') < 1){
            Promise.all([
                loadScript(this, global_styles + '/js/walkme-tracking-test.js')
            ])
            .then(() => {
                console.log("Walkme script loaded in test");
            })
            .catch(() => {
                console.log(JSON.stringify(error));
            }); 
        }
    }
}