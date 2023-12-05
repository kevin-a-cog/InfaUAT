import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord ,getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import isGuestUser from '@salesforce/user/isGuest';

import KB_OBJECT from '@salesforce/schema/afl__afl_Article_Feedback__c';
import KBID from '@salesforce/schema/afl__afl_Article_Feedback__c.Knowledge__c';
import KBIDTEXT from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Knowledge_Article_Version_Id__c';
import ARTICLELINK from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Link__c';
import ARTICLENUMBER from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Number__c';
import ARTICLE_AUTHOR from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_Author__c';
import KBTITLE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Title__c';
import STATUS from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Status__c';
import LIKEDISLIKE from '@salesforce/schema/afl__afl_Article_Feedback__c.Like_Dislike__c';
import FDOWNER from '@salesforce/schema/afl__afl_Article_Feedback__c.OwnerId';
import COMMENTS from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Vote_Description__c';
import ACTIONTAKEN from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Action_Taken__c';
import ARTICLEVERSION from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Version__c';
import ARTICLERECTYPE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Record_Type__c';
import ARTICLECREATEDDT from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Created_Date__c';
import FEEDBACKUSER from '@salesforce/schema/afl__afl_Article_Feedback__c.Feedback_User__c';
import FEEDBACKNAME from '@salesforce/schema/afl__afl_Article_Feedback__c.Name';




import SOURCE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Source__c';
import KBURL from '@salesforce/label/c.KB_URL';
import logInURL from '@salesforce/label/c.CustomerSupportLoginURL';
import USER_ID from '@salesforce/user/Id';
import OWNERID from '@salesforce/label/c.Feedback_Queue';
import getLastFeedback from '@salesforce/apex/KBLWCHandler.getLastFeedback'; 
import updatefeedback from '@salesforce/apex/KBLWCHandler.updatefeedback'; 



//import EXTENSIONMONTHS from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_Extesion_Period__c';

const KBFIELDS = [
    'Knowledge__kav.ArticleNumber',
    'Knowledge__kav.Title',
    //'Knowledge__kav.VersionNumber',
    'Knowledge__kav.RecordTypeId',
    'Knowledge__kav.ArticleCreatedDate',
    //'Knowledge__kav.CreatedById'
];


export default class ArticleFeedbackExternal extends NavigationMixin(LightningElement) {
    isGuest = isGuestUser;
    userId = USER_ID;

    label = {
        KBURL,
        logInURL,
        OWNERID
    };
    @api likevariant ="border-filled";
    @api dislikevariant ="border-filled";        
    @api recordId;
    title;
    articleNo;
    versionNumber;
    recTypeId;
    articleCreatedDt;
    articleAuthor;
    like;
    descrip; 
    version; 
    error;  
    feedback = 'false';    
    errormessage;
    
    feedbackrec;
    feedbackreason;

    
    @wire(getRecord, { recordId: '$recordId', fields: KBFIELDS })
    
    kbrecord({ error, data }) {
        if (error) {
            this.error = error;
            console.log('error',JSON.stringify(error))
        } else if (data) {
            this.title = data.fields.Title.value;
            this.articleNo  = data.fields.ArticleNumber.value;
           // this.versionNumber  = data.fields.VersionNumber.value;
            this.recTypeId  = data.recordTypeInfo.name;
            this.articleCreatedDt  = data.fields.ArticleCreatedDate.value;
            
           console.log('data from external feedback',JSON.stringify(data));   
        }
    }
     connectedCallback(){  
         console.log('recid'+this.recordId);
        getLastFeedback({                     
            recid: this.recordId             
        })
        .then(result => {
           
            this.feedbackrec = result;
            console.log('feedback response',this.feedbackrec);
            if(this.feedbackrec.Like_Dislike__c == 'Dislike'){
                this.dislikevariant = "brand";                
                this.feedback = 'true';        
                this.like= 'Dislike';  
            } else if(this.feedbackrec.Like_Dislike__c == 'Like'){
                this.likevariant = "brand";                
                this.feedback = 'false';       
                this.like= 'Like';
            }
            
           
        })
        .catch(error => {
            this.error = error;
            console.log('connectedcallback error:'+this.error);
        });
    }    

    showErrorToast() {
        const showError = new ShowToastEvent({
            title: 'Error!!',
            message: this.errormessage,
            variant: 'error',
        });
        this.dispatchEvent(showError);
    }   

     handlelike(){
        if(this.isGuest) {
            let loginLink = logInURL + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(window.location.href));
            window.location.assign(loginLink);
       } else {
           
            this.likevariant = "brand";
            this.dislikevariant = "border-filled";
            this.feedback = 'false';        
            this.like= 'Like';
            this.template.querySelector('[data-id="feedbacksec"]').className='slds-is-expanded slds-m-around--small';              
            this.template.querySelector('[data-id="descripstar"]').className='slds-hidden slds-is-collapsed';     
            this.template.querySelector('[data-id="submitbt"]').className='slds-align_absolute-center slds-m-around--medium';        
           
        }
       
    }

    handledislike(){
        if(this.isGuest) {
            let loginLink = logInURL + "?RelayState=" + window.location.href;
            window.location.assign(loginLink);
        } else {
            
                this.dislikevariant = "brand";
                this.likevariant = "border-filled";
                this.feedback = 'true';        
                this.like= 'Dislike';       
                this.template.querySelector('[data-id="feedbacksec"]').className='slds-is-expanded slds-m-around--small';            
                this.template.querySelector('[data-id="descripstar"]').className='slds-required slds-visible';         
                this.template.querySelector('[data-id="submitbt"]').className='slds-align_absolute-center slds-m-around--medium';    
           
        }
    }
    
    createRecord(recordInput){

        createRecord(recordInput)
            .then(afl__afl_Article_Feedback__c => {
                if(this.like == 'Like') {          
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            mode: 'sticky',
                            message: 'Thank you for your feedback! Feel free to explore for a variety of content within our {1}, \n and peak your learning curve with free courses and certifications offered on {3}',
                            "messageData": [
                                'Knowledge Base',
                                {
                                    url: 'https://search.informatica.com/KBHome',
                                    label: 'Knowledge Base'
                                },
                                'Success Portal',
                                {
                                    url: 'https://success.informatica.com/',
                                    label: 'Success Portal'
                                }
                            ],
                            variant: 'success',
                        }),
                    );
                }else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            mode: 'dismissable',
                            title: 'Success',
                            message: 'Thank you for your feedback. We appreciate the time you took to help us improve this document. \n Our content team will review and get back to you with an update shortly',
                            variant: 'success',
                        }),
                    );
                }
            })
            .catch(error => {
                console.log('Error',JSON.stringify(error))
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.likevariant ="border-filled";
                this.dislikevariant ="border-filled"; 
            });
    }
    updateRecord(){

        updatefeedback({                      
            fdid:  this.feedbackrec.Id,
            likevalue: this.like,
            fdreason: this.feedbackreason,
            fdcomments: this.descrip

        })
        .then(result => {
           
            if(this.like == 'Like') {          
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        mode: 'sticky',
                        message: 'Thank you for your feedback! Feel free to explore for a variety of content within our {1}, \n and peak your learning curve with free courses and certifications offered on {3}',
                        "messageData": [
                            'Knowledge Base',
                            {
                                url: 'https://search.informatica.com/KBHome',
                                label: 'Knowledge Base'
                            },
                            'Success Portal',
                            {
                                url: 'https://success.informatica.com/',
                                label: 'Success Portal'
                            }
                        ],
                        variant: 'success',
                    }),
                );
            }else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        mode: 'dismissable',
                        title: 'Success',
                        message: 'Thank you for your feedback. We appreciate the time you took to help us improve this document. \n Our content team will review and get back to you with an update shortly',
                        variant: 'success',
                    }),
                );
            } 
           })
        .catch(error => {
            console.log('Error',JSON.stringify(error))
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.likevariant ="border-filled";
            this.dislikevariant ="border-filled"; 
        });
    }

    createFeedback() {
        const fields = {};
        fields[KBID.fieldApiName] = this.recordId;
        fields[ARTICLELINK.fieldApiName] = KBURL +'/' + this.recordId + '/view';
        fields[KBIDTEXT.fieldApiName] = this.recordId;
        fields[ARTICLENUMBER.fieldApiName] = this.articleNo;
        fields[KBTITLE.fieldApiName] = this.title;
        fields[FEEDBACKNAME.fieldApiName] = this.title.substring(0,80);
        fields[STATUS.fieldApiName] = 'New';       
        fields[LIKEDISLIKE.fieldApiName] = this.like;
        fields[COMMENTS.fieldApiName] = this.descrip;        
        fields[SOURCE.fieldApiName] = 'External'; 
        fields[FDOWNER.fieldApiName] = OWNERID;
        //fields[ARTICLEVERSION.fieldApiName] = this.versionNumber;
        fields[ARTICLERECTYPE.fieldApiName] =  this.recTypeId;
        fields[ARTICLECREATEDDT.fieldApiName] = this.articleCreatedDt; 
        fields[FEEDBACKUSER.fieldApiName] = this.userId; 

        const recordInput = { apiName: KB_OBJECT.objectApiName, fields };

        getLastFeedback({                     
            recid: this.recordId             
        })
        .then(result => {
           
            this.feedbackrec = result;    
            console.log('udpate feedback'+this.feedbackrec.afl__Feedback_Status__c);       
            if(this.feedbackrec.afl__Feedback_Status__c == 'New'){
               
                this.updateRecord();
            }else{
                this.createRecord(recordInput);
            }
           
        })
        .catch(error => {
            this.error = error;
            console.log('connectedcallback error:'+this.error);
        });
    }
    

    handlesubmit(event){
        
        var inp = this.template.querySelector("textarea"); 
               
        if(inp.value.length === 0 && this.like == 'Dislike' ){
            console.log('error logging');
            this.errormessage = 'Please enter your comments';
            this.showErrorToast();
        } else {
            this.template.querySelector('[data-id="feedbacksec"]').className='slds-is-collapsed slds-m-around--small';            
            this.template.querySelector('[data-id="submitbt"]').className='slds-align_absolute-center slds-m-around--medium slds-is-collapsed';    

            this.descrip = inp.value;
            this.createFeedback();
            this.template.querySelector("textarea").value='';
            console.log('inp', this.like)
            try {
            util.trackExternalFeedback(this.like, this.descrip);
            }
            catch(ex) {
                console.log(ex.message);
            }
        }
        
        
    
    }
}