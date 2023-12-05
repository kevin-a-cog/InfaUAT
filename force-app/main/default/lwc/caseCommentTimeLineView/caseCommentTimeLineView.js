/*
Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
balajip                05-Apr-2022     I2RT-5459           Added subtab My Tagged user the tab Internal              T01
Karthi G               27-May-2022     I2RT-6196           Added code to handle platform event subscription          T02
Vignesh Divakaran      07-Nov-2022     I2RT-7445           Removed case comment subscription & unsubscription logic  T03
                                                        along with all changes done on T02

Isha Bansal            23-Mar-2023     I2RT-7615         Added condition for collaboration unread message count      T04
*/
import { api, track, LightningElement } from 'lwc';
import Icons from '@salesforce/resourceUrl/icons';
import getCaseTeamMember from '@salesforce/apex/CaseCommentController.getCaseTeamMember';
import updateCaseTeamMember from '@salesforce/apex/CaseCommentController.updateCaseTeamMember';
//Utilities.
import { objUtilities } from 'c/informaticaUtilities';
//T01
import USER_ID from "@salesforce/user/Id";

export default class CaseCommentTimeLineView extends LightningElement {
    @api recordId;
    @api isFullScreen;
    //Deva: add parameter to catpure data
    @api commentCounterFlag=false;
    @track isPopoutTerm = false;

    @track curUserId = USER_ID; //T01

    showSpinner=false;
    fullcommentlist;    
    allLabelText='';
    inboundLabelText='';
    attentionRequestLabelText=''
    externalLabelText='';
    internalLabelText='';
    privateLabelText='';
    raiseHandLabelText='';
    jiraLabelText='';

    showAllIcon=false;
    showInboundIcon=false;
    showAttReqIcon=false;
    showExternalIcon=false;
    showInternalIcon=false;
    showPrivateIcon=false;
    showRaiseHandIcon=false;
    showJiraIcon=false;

    caseTeamRecordId;


    get isAllTimelineView() {
        let tabset = this.template.querySelector('lightning-tabset');
        return tabset ? tabset.activeTabValue == 'All' : false;
    }
    
    imageURL = {
        draft: Icons + '/sketching-24.png',
        calendar: Icons + '/clock-32.png',
        submitted: Icons + '/verification-24.png',
        draft_16: Icons + '/sketching-16.png',
        calendar_16: Icons + '/clock-16.png',
        submitted_16: Icons + '/verification-16.png',
    };

    get isPopout(){
        if (this.isFullScreen){
            this.isPopoutTerm = false;
        }
        return this.isPopoutTerm;
    }

    get isCCFullScreen(){
        return this.isFullScreen;
    }

    handleClick(event){
        //Deva ITRT 2636 : Add to reset labels of tabs
        this.resetLabels(event);
        switch (event.currentTarget.name) {
            case 'popout':
                console.log("called1");
                this.isPopoutTerm = true;
                break;

            case 'popin':
                console.log("called2");
                this.isPopoutTerm = false;
                break;

            default:
                break;
        }      
    }
    //Deva ITRT 2636 - To handle unread counter
    resetLabels(event){
        this.allLabelText='';
        this.inboundLabelText='';
        this.attentionRequestLabelText='';
        this.externalLabelText='';
        this.internalLabelText='';
        this.privateLabelText='';
        this.raiseHandLabelText='';
        this.jiraLabelText='';
        this.showAllIcon=false;
        this.showInboundIcon=false;
        this.showAttReqIcon=false;
        this.showExternalIcon=false;
        this.showInternalIcon=false;
        this.showPrivateIcon=false;
        this.showRaiseHandIcon=false;
        this.showJiraIcon=false;
        if(this.caseTeamRecordId){
            this.showSpinner=true;  
            console.log('caseTeamRecordId>>', JSON.stringify(this.caseTeamRecordId));
            updateCaseTeamMember({caseTeamRecordId: this.caseTeamRecordId}).then(response => {
                this.caseTeamRecordId=undefined;      
            }).catch(err => {
                console.log('ERROR>>', JSON.stringify(err));
                this.showSpinner=false;   
            }).finally(() => {     
                this.showSpinner=false;                   
            });
        }
    }
    handleCommentData(event){
        this.caseTeamRecordId=undefined;
        var allCounter=0;
        var inboundCounter=0;
        var attentionRequestCounter=0;
        var internalCounter=0;
        var externalCounter=0;
        var privateCounter=0;
        var raiseHandCounter=0;
        var jiraCounter=0;
        this.fullcommentlist = event.detail.fullcommentlist;        
        let checkCounterLogic=objUtilities.isNotNull(this.commentCounterFlag) && this.commentCounterFlag?false:true;
        if(this.fullcommentlist && this.fullcommentlist.length > 0 && checkCounterLogic){ 
            this.showSpinner=true;        
            getCaseTeamMember({caseRecordId: this.recordId}).then(response => {
                if(response.length > 0){
                    this.fullcommentlist.forEach(commWrap => commWrap.comments.forEach(element => {      
                        if(objUtilities.isNotNull(element.Case__c)){                
                            if (objUtilities.isNull(response[0].Last_Read_TimeStamp__c) || (objUtilities.isNotNull(response[0].Last_Read_TimeStamp__c) && element.CreatedDate > response[0].Last_Read_TimeStamp__c)) {                          
                                allCounter++;                             
                                if(element.Inbound__c==true){
                                    inboundCounter++;                                    
                                }
                                if(element.Type__c=='Escalation' || element.Type__c=='Callback' || element.Type__c=='Revise Priority' || element.Type__c=='Live Assistance'){
                                    attentionRequestCounter++; 
                                }
                                /*if(element.Type__c=='Callback'){
                                    callbackCounter++;
                                }
                                if(element.Type__c=='Revise Priority'){
                                    rpCounter++;
                                }*/
                                if(element.Visibility__c=='Internal'){
                                    internalCounter++;
                                }
                                if(element.Visibility__c=='External'){
                                    externalCounter++;
                                }
                                if(element.Visibility__c=='Private'){
                                    privateCounter++;   
                                }
                                if(element.Type__c=='Raise Hand' || element.Comment_Category__c=='Collaboration'){ // T04 
                                    console.log('--element.Comment_Category__c--'+element.Comment_Category__c);
                                    raiseHandCounter++;                                    
                                    this.showRaiseHandIcon=true;
                                }
                                if(element.Type__c=='JIRA Request'){
                                    jiraCounter++; 
                                }
                                this.caseTeamRecordId=response[0].Id;
                                //To Do count the replies if required
                                if(element.replies){
                                
                                }
                            }
                        }
                        
                    }));

                    if( allCounter>0){                         
                        this.showAllIcon=true;
                        this.allLabelText=allCounter;
                    }
                    if( inboundCounter>0){                        
                        this.showInboundIcon=true;
                        this.inboundLabelText=inboundCounter;
                    }
                    if( attentionRequestCounter>0){                                                           
                        this.showAttReqIcon=true;
                        this.attentionRequestLabelText=attentionRequestCounter;
                    }
                    if( externalCounter>0){                        
                        this.showExternalIcon=true;
                        this.externalLabelText=externalCounter;
                    }
                    if( internalCounter >0){                        
                        this.showInternalIcon=true;
                        this.internalLabelText=internalCounter;
                    }
                    if( privateCounter>0){                                                         
                        this.showPrivateIcon=true;
                        this.privateLabelText=privateCounter;
                    }
                    if( raiseHandCounter>0){
                        this.showRaiseHandIcon=true;
                       this.raiseHandLabelText=raiseHandCounter;
                    }
                    if( jiraCounter>0){
                        this.showJiraIcon=true;
                        this.jiraLabelText=jiraCounter;
                    }
                }                
            }).catch(err => {
                console.log('ERROR>>', JSON.stringify(err));
                this.showSpinner=false;    
            }).finally(() => {           
                this.showSpinner=false;    
            });
            
        }
        
    }
    //Deva ITRT 2636 : End
    onActive(event){
        let commentCategory = '';
        let visibility = '';
        let tabValue = event.target.value;
        console.log('@Log=> commentCategory:' + commentCategory);

        if(tabValue != null && tabValue != ''){
            let tabDetails = tabValue.split('-');
            console.log('@Log=> tabDetails:' + tabDetails);
            
            if(tabDetails.length > 1){
                visibility = tabDetails[0];
                commentCategory = tabDetails [1];
            }
        }
        console.log('@Log=> visibility:' + visibility);
        console.log('@Log=> commentCategory:' + commentCategory);

        //I2RT-4607 - commented below statement
        //this.template.querySelector('c-case-comment-list-view').refresh(visibility,commentCategory); 
    }
}