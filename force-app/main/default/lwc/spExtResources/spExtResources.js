import { LightningElement, track, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';
import analytics_script from '@salesforce/label/c.adobe_analytics'; 
//import coveo_resource from '@salesforce/resourceUrl/CoveoJsFrameworkOthers';
import { getRecord } from 'lightning/uiRecordApi';
import FEDERATION_FIELD from '@salesforce/schema/User.FederationIdentifier';
import USER_ID from '@salesforce/user/Id';

export default class SpExtResources extends LightningElement {
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
        document.title = 'Success Planner';  
        document.body.setAttribute('style', 'display: none;');
        Promise.all([
            //loadScript(this, 'https://code.jquery.com/jquery-3.6.0.min.js'),
            loadStyle(this, bootstrap + '/bootstrap-4.5.3-dist/css/bootstrap.min.css'),
            loadStyle(this, sp_resource + '/spResource/css/fonts.css'),
            loadStyle(this, sp_resource + '/spResource/css/global.css'),
            loadStyle(this, sp_resource + '/spResource/css/sldsException.css'),
            // loadStyle(this, coveo_resource + '/CoveoJsFrameworkOthers/css/CoveoFullSearch.css'),
            // loadStyle(this, sp_resource + '/spResource/css/coveoStyles.css'),
            loadStyle(this, sp_resource + '/spResource/css/form.css'),
            loadStyle(this, sp_resource + '/spResource/css/componentCustomisation.css'),
            loadStyle(this, sp_resource + '/spResource/css/detailInfo.css'),
            loadStyle(this, sp_resource + '/spResource/css/utility.css'),
            loadStyle(this, sp_resource + '/spResource/css/fontawesome.min.css'),
            loadScript(this, sp_resource + '/spResource/js/fontawesome.min.js')
        ])
        .then(() => {
            console.log("All scripts and CSS are loaded.");
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
                    console.log("Adobe analytics script loaded")
                    Promise.all([
                        loadScript(this, sp_resource + '/spResource/js/analytics.js')
                    ])
                    .then(() => {
                        try {
                            util.setOktaUserID(this.fedId);
                            console.log("Get Fed id",this.fedId);
                        }
                        catch(ex) {
                            console.log("Catch");
                        }
                    });
                })
                .catch(() => {
                    console.log(JSON.stringify(error));
            }); 
        }
        if (window.location.href.indexOf('experience.informatica.com') > 1){
            Promise.all([
                loadScript(this, sp_resource + '/spResource/js/walkme.js')
            ])
            .then(() => {
                console.log("Walkme script loaded");
            })
            .catch(() => {
                console.log(JSON.stringify(error));
            }); 
        }
        if (window.location.href.indexOf('experience.informatica.com') < 1){
            Promise.all([
                loadScript(this, sp_resource + '/spResource/js/walkme-test.js')
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