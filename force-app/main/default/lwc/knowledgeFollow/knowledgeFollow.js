import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, createRecord } from 'lightning/uiRecordApi';

import KB_FOLLOW_OBJECT from '@salesforce/schema/KB_Follow__c';

import ID_FIELD from '@salesforce/schema/KB_Follow__c.Id';
import FOLLOWER_FIELD from '@salesforce/schema/KB_Follow__c.Follower__c';
import ARTICLE_FIELD from '@salesforce/schema/KB_Follow__c.Knowledge_Id__c';
import ARTICLE_VERSION_FIELD from '@salesforce/schema/KB_Follow__c.Knowledge__c';
import IS_FOLLOWED_FIELD from '@salesforce/schema/KB_Follow__c.Is_Followed__c';

import USER_ID from '@salesforce/user/Id';
import IS_GUEST from '@salesforce/user/isGuest';

import getKBFollow from '@salesforce/apex/KBLWCHandler.getKBFollow';
import logInURL from '@salesforce/label/c.CustomerSupportLoginURL';

const ARTICLE_FIELDS = [
    'Knowledge__kav.Id',
    'Knowledge__kav.KnowledgeArticleId'
];

const KBFOLLOW_FIELDS = [
    'KB_Follow__c.Id',
    'KB_Follow__c.Is_Followed__c'
];

export default class KnowledgeFollow extends LightningElement {
    @api recordId;

    userId = USER_ID;
    isGuest = IS_GUEST;

    articleId;

    kbFollowExists=false;
    isFollowed=false;

    kbFollow={};

    //@wire(getRecord, {recordId:'$recordId', ARTICLE_FIELDS}) article;
    @wire(getRecord, { recordId: '$recordId', fields: ARTICLE_FIELDS })
    article({ error, data }) {
        if (error) {
            console.log("error - " + JSON.stringify(error));
        } else if (data) {
            this.articleId = data.fields.KnowledgeArticleId.value;
            getKBFollow({articleId : this.articleId, userId : this.userId})
            .then(result => {
                if(result){
                    this.kbFollow = result;
                    this.isFollowed=this.kbFollow.Is_Followed__c;
                    this.kbFollowExists=true;
                    this.rerenderFollowButton();
                }
            })
            .catch(error => {
                console.log("error - " + JSON.stringify(error));
            });
        }
    }

    //@wire(getKBFollow, {"articleId":this.recordId}) kbFollow;

    
    connectedCallback(){

    }

    showLoginToastMsg(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Information',
                mode: 'dismissable',
                message: 'Please login to be able to follow an article!',
                variant: 'error',
            }),
        );
    }

    rerenderFollowButton(){
        if(this.isFollowed){
            this.template.querySelector('[data-id="btnFollow"]').classList.add('slds-is-pressed');
        }else{
            this.template.querySelector('[data-id="btnFollow"]').classList.remove('slds-is-pressed');
        }
    }

    followArticle(event){

        if(this.isGuest){
            let loginLink = logInURL + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(window.location.href));
            
            window.location.assign(loginLink);
        }else{
            this.isFollowed = !this.isFollowed;
            this.rerenderFollowButton();
            var fields = {};
            fields[IS_FOLLOWED_FIELD.fieldApiName] = this.isFollowed;
            fields[FOLLOWER_FIELD.fieldApiName] = this.userId;
            fields[ARTICLE_VERSION_FIELD.fieldApiName] = this.recordId;
            fields[ARTICLE_FIELD.fieldApiName] = this.articleId;
            
            if(this.kbFollowExists){
                fields[ID_FIELD.fieldApiName] = this.kbFollow.Id;
                var recordInput = { fields };    
                updateRecord(recordInput)
                .then(result => {
                    console.log("result - " + JSON.stringify(result));
                })
                .catch(error => {
                    console.log("error - " + JSON.stringify(error));
                });
                
            }else{
                var recordInput = { apiName: KB_FOLLOW_OBJECT.objectApiName, fields };    
                createRecord(recordInput)
                .then(result => {
                    console.log("result - " + JSON.stringify(result));
                })
                .catch(error => {
                    console.log("error - " + JSON.stringify(error));
                });
            }
            try {
                util.trackFollow();
            }
            catch(ex) {
                console.log(ex.message);
            }
        }
    }
}