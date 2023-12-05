import { LightningElement, api, wire, track } from 'lwc';

import NAME_FIELD from '@salesforce/schema/Related_KB__c.Referred_In__r.UrlName';
import getRelatedArticles from '@salesforce/apex/KBLWCHandler.getRelatedArticles';
import getloggedinprofile from '@salesforce/apex/KBLWCHandler.getloggedinprofile';

import KBPreviewurl from '@salesforce/label/c.KBPreviewurl'; 

export default class kbRelatedArticles extends LightningElement {
    // The record page provides recordId and objectApiName
    
    label = {
        KBPreviewurl
    };
    @api error;
    @api recordId;
    @track kbrecords=[]; // Array to hold key value pairs   
    

    //wire method is not used as we need to get article urlname
    /*@wire (getKBRelatedrec , { urlname: urlvalue }) getrecs({ error, data }) {
        console.log('hello'+window.location.origin);
        if (data) {
            var i;
            for(i = 0; i < data.length; i++){
                console.log('hello'+i);
                var urlval = window.location.origin + 'customersupport/s/article/' +data[i].Referred_Article_Name__c;

                this.kbrecords.push({value:urlval, key:data[i].Id}); //Here we are creating the array to show on UI.
            }               
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.kbrecords = undefined;
        }
    }*/

   /* getarticleURL(urlval){
        console.log('urlvalue'+urlval);
        
        return urlval.substring(urlval.lastIndexOf('/')+1)
        //return urlval.substring(64, (urlval.length));
    } */


    connectedCallback() {      
        console.log('Inside connected call back')
      /*  var paramValue = this.getarticleURL(window.location.href);       
        console.log('paramValue'+paramValue); */
        //paramValue = '000001030'; 
        getloggedinprofile()
        .then(result => {
        console.log('Internal User? ',result);
        getRelatedArticles({ articleId: this.recordId,
            externalUser : result})
        .then(result => {
            var i;       
            console.log('RecordId',this.recordId);     
            for(i = 0; i < result.length; i++){
                var urlval = KBPreviewurl+ 'article/' +result[i].Referred_Article__r.UrlName+'?language='+result[i].Referred_Article__r.Language;
                this.kbrecords.push({value:urlval, key:result[i].Referred_Article__r.Title}); //Populating array of key value pairs.
            }     
            console.log('related article', result.length);
        })
        .catch(error => {
            this.error = error;
            console.log('error while getting related Article records'+this.error);
        });

        })
        .catch(error => {
            this.error = error;
            console.log('error while performing Profile Id check'+this.error);
        });
    }

   
}