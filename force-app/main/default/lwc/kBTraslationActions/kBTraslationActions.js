import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import publishTranslation from '@salesforce/apex/KBLWCHandler.publishTranslation';

import { NavigationMixin } from 'lightning/navigation';

export default class KBTranslationActions extends NavigationMixin(LightningElement) {
    @api recordId;

    @track article;
    @track isTranslation=false;
    @track publishStatus;

    handlepublish(){
        publishTranslation({
            articleId: this.recordId
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'The translated version of the article is published.',
                    variant: 'success',
                }),
            );
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }

}