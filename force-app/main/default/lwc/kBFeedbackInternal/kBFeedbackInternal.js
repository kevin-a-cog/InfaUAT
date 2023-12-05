/*
    @created by       : VenkyK
    @created on       : 08/02/2020
    @Purpose          : Knowledge Feedback for internal users.
    @Testclass        : 
    @JIRA             : 
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 */

import { LightningElement, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { getRecord  } from 'lightning/uiRecordApi';
import getLastFeedback from '@salesforce/apex/KBLWCHandler.getLastFeedback'; 
import getArticle from '@salesforce/apex/KBLWCHandler.getArticle'; 
import updatefeedback from '@salesforce/apex/KBLWCHandler.updatefeedback'; 




//import KBARTICLENO from '@salesforce/schema/Knowledge__kav.ArticleNumber';
//import KBARTICLEITLE from '@salesforce/schema/Knowledge__kav.Title';

import KB_OBJECT from '@salesforce/schema/afl__afl_Article_Feedback__c';
import KBID from '@salesforce/schema/afl__afl_Article_Feedback__c.Knowledge__c';
import KBIDTEXT from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Knowledge_Article_Version_Id__c';
import ARTICLELINK from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Link__c';
import KBARTICLENUMBER from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Number__c';
import KBTITLE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Title__c';
import STATUS from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Status__c';
import LIKEDISLIKE from '@salesforce/schema/afl__afl_Article_Feedback__c.Like_Dislike__c';
import COMMENTS from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Vote_Description__c';
import ACTIONTAKEN from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Action_Taken__c';
import EXTENSIONMONTHS from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_Extesion_Period__c';
import SOURCE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Feedback_Source__c';
import FDUSER from '@salesforce/schema/afl__afl_Article_Feedback__c.Feedback_User__c';
import FEEDBACKNAME from '@salesforce/schema/afl__afl_Article_Feedback__c.Name';
import FDOWNER from '@salesforce/schema/afl__afl_Article_Feedback__c.OwnerId';
import ARTICLEVERSION from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Version__c';
import ARTICLERECTYPE from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Record_Type__c';
import ARTICLECREATEDDT from '@salesforce/schema/afl__afl_Article_Feedback__c.afl__Article_Created_Date__c';
import USER_ID from '@salesforce/user/Id'; 
import INREASON from '@salesforce/schema/afl__afl_Article_Feedback__c.Internal_Feedback_Reason__c';
import ARTICLE_AUTHOR from '@salesforce/schema/afl__afl_Article_Feedback__c.Article_Author__c';

import KBURL from '@salesforce/label/c.KB_URL';
import OWNERID from '@salesforce/label/c.Feedback_Queue';



const KBFIELDS = [
    'Knowledge__kav.ArticleNumber',
    'Knowledge__kav.Title',
    //'Knowledge__kav.VersionNumber',
    'Knowledge__kav.RecordTypeId',
    'Knowledge__kav.ArticleCreatedDate',
    'Knowledge__kav.is_Current_User_the_Author__c'
];



export default class KBFeedbackInternal extends LightningElement {

    label = {
        KBURL,OWNERID
    };

    @api recordId;

    likevariant ="border-filled";
    dislikevariant ="border-filled";        
    title;
    articleno;
    articleAuthor;
    currentUserAuthor;
    like;
    versionNumber;
    recordTypeId;
    articleCreatedDate;
    descrip;
    feedbackreason = '';    
    feedback = 'false';    
    errormessage;
    error;
    feedbackrec;
    
    

   /* @wire(getRecord, { recordId: '$recordId',  fields: KBFIELDS})
    kbrecord({ error, data }) {
        console.log('inside kb record', this.recordId)
        if (error) {
            this.error = error;
            console.log('error msg',error)
        } else if (data) {
            console.log('inside data')
            this.title = data.fields.Title.value;
            this.articleno = data.fields.ArticleNumber.value;
            //this.articleAuthor = data.fields.ArticleCreatedById.value;
            //this.versionNumber = data.fields.VersionNumber.value;
            this.recordTypeId = data.recordTypeInfo.name;
            this.articleCreatedDate = data.fields.ArticleCreatedDate.value;
            this.currentUserAuthor =  data.fields.is_Current_User_the_Author__c.value;
            console.log('current user is author',this.currentUserAuthor) 
        }
    } */
     
    

    connectedCallback(){
        
        // get last feedback provided by the user
        getLastFeedback({                     
            recid: this.recordId             
        })
        .then(result => {
            console.log('result obtained is connected call back',JSON.stringify(result));
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
        // get article field values
        getArticle({                     
            articleId: this.recordId             
        })
        .then(result => {
           
            console.log('result value',result); 
            console.log('Result title',result.Title);
            this.title = result.Title;
            this.articleno = result.ArticleNumber;
            this.recordTypeId = result.RecordType.Name;
            this.articleCreatedDate = result.ArticleCreatedDate;
            this.currentUserAuthor =  result.is_Current_User_the_Author__c;
           
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
        console.log('current author in like',this.currentUserAuthor)
        if(!this.currentUserAuthor){
        this.likevariant = "brand";
        this.dislikevariant = "border-filled";
        this.feedback = 'false';       
        this.like= 'Like';                
        this.template.querySelector("textarea").value=''; 
        this.feedbackreason=''; 
        this.template.querySelector('[data-id="feedbacksec"]').className='slds-is-expanded slds-m-around--small';
        this.template.querySelector('[data-id="submitbt"]').className='slds-is-expanded slds-align_absolute-center slds-m-around--medium'; 
        this.template.querySelector('[data-id="descriptionblock"]').className='slds-form-element slds-visible';  
        this.template.querySelector('[data-id="descripstar"]').className='slds-hidden slds-is-collapsed';         
        this.template.querySelector('[data-id="feedbackreason"]').className='slds-hidden slds-is-collapsed'; 
        this.template.querySelector('[data-id="likebutton"]').className='green-background'; 
        }else{
            this.errormessage = 'You cannot rate your own article';
            this.showErrorToast();
        }
        
    }    
        
        
       
    

    handledislike() {
        console.log('current author in dislike',this.currentUserAuthor)
        if(!this.currentUserAuthor){
        this.dislikevariant = "brand";
        this.likevariant = "border-filled";
        this.feedback = 'true';        
        this.like= 'Dislike';       
        
        this.template.querySelector("textarea").value=''; 
        this.feedbackreason='';
        this.template.querySelector('[data-id="feedbacksec"]').className='slds-is-expanded slds-m-around--small';
        this.template.querySelector('[data-id="submitbt"]').className='slds-is-expanded slds-align_absolute-center slds-m-left_x-small';
        this.template.querySelector('[data-id="descriptionblock"]').className='slds-visible';
        this.template.querySelector('[data-id="descripstar"]').className='slds-required slds-visible';
        this.template.querySelector('[data-id="feedbackreason"]').className='slds-form-element slds-visible slds-is-expanded';
    }else{
        this.errormessage = 'You cannot rate your own article';
        this.showErrorToast();
    }
          
    }

       

    get reasonoptions() {
        return [
            { label: 'Article is Inaccurate', value: 'Article is Inaccurate' },
            { label: 'Article is Incomplete', value: 'Article is Incomplete' },
            { label: 'Outdated Information', value: 'Outdated Information' },
            { label: 'Other', value: 'Other' },
        ];
    }

    handlereason(event) {
        this.feedbackreason = event.detail.value;
    }

    updateRecord(){
        console.log('feedback reason',this.feedbackreason)
        console.log('Inside update')
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
            this.error = error;
            console.log('connectedcallback error:'+this.error);
            this.likevariant ="border-filled";
            this.dislikevariant ="border-filled"; 
        });
        this.feedbackreason='';
    }
    createRecord(recordInput){
        console.log('Inside Create')
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
                console.log('error '+error)
                console.log('error object',JSON.stringify(error))
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
            this.feedbackreason='';   
    }

    createFeedback() {
        const fields = {};
        
        fields[KBID.fieldApiName] = this.recordId;
        fields[ARTICLELINK.fieldApiName] =  KBURL +'/'+ this.recordId + '/view';
        fields[KBIDTEXT.fieldApiName] = this.recordId;
        fields[KBARTICLENUMBER.fieldApiName] = this.articleno;
        fields[KBTITLE.fieldApiName] = this.title;
        //fields[ARTICLE_AUTHOR.fieldApiName] = this.articleAuthor;
        fields[LIKEDISLIKE.fieldApiName] = this.like;
        fields[COMMENTS.fieldApiName] = this.descrip;
        fields[SOURCE.fieldApiName] = 'Internal';
        fields[STATUS.fieldApiName] = 'New';
        fields[FDUSER.fieldApiName] = USER_ID;
        fields[FEEDBACKNAME.fieldApiName] = this.title.substring(0,80);
        fields[FDOWNER.fieldApiName] = OWNERID;
        fields[ARTICLEVERSION.fieldApiName] = this.versionNumber;
        fields[ARTICLERECTYPE.fieldApiName] =  this.recordTypeId ;
        fields[ARTICLECREATEDDT.fieldApiName] = this.articleCreatedDate;
        fields[INREASON.fieldApiName] = this.feedbackreason; 

        
        
        console.log(fields);
        const recordInput = { apiName: KB_OBJECT.objectApiName, fields };
        
        this.feedbackrec='';
        getLastFeedback({                     
            recid: this.recordId             
        })
        .then(result => {
           console.log('result obtained is',JSON.stringify(result));
            this.feedbackrec = result;    
            console.log('udpate feedback'+this.feedbackrec);       
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

        if(this.feedbackreason.length === 0 && this.like == 'Dislike'){           
            this.errormessage = 'Please Choose reason';
            this.showErrorToast();
        }
        else if(inp.value.length === 0 && this.like == 'Dislike'){            
            this.errormessage = 'Please enter your comments';
            this.showErrorToast();
        } 
        else {
            if(inp.value.length === 0){
                this.descrip = ' ';
            }else {
                this.descrip = inp.value;
            }
            this.createFeedback();
            this.template.querySelector("textarea").value=''; 
            
            this.template.querySelector('[data-id="feedbacksec"]').className='slds-m-around--small slds-is-collapsed';
            this.template.querySelector('[data-id="submitbt"]').className='slds-align_absolute-center slds-m-around--medium slds-is-collapsed'; 
        
        }
    
    }
}