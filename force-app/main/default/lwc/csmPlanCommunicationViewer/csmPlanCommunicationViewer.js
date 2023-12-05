/*
 * Name			    :	CsmPlanCommunicationViewer
 * Author		    :	Deva M
 * Created Date	    :   22/10/2021
 * Description	    :	Csm Plan Communication Viewer controller.

 Change History
 **************************************************************************************************************************
 Modified By			Date			    Jira No.		Description					                   Tag
 **************************************************************************************************************************
 Deva M		        22/10/2021		        N/A				Initial version.			                  N/A
 Karthi G           09/02/2023              AR-3091         Unread comment count refresh issue fix        <T01>
 */

//Core imports.
import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import Loading from '@salesforce/label/c.Loading';
import Error from '@salesforce/label/c.Error';
import Success from '@salesforce/label/c.Success';
// Import message service features required for publishing and the message channel
import { subscribe,publish, MessageContext,unsubscribe } from 'lightning/messageService';
import PLAN_COMMS from '@salesforce/messageChannel/csmPlanCommunication__c';
//Apex Imports
import getPlanTeamRecords from '@salesforce/apex/CSMPlanCommunicationController.getPlanTeamRecords';
import updatePlanTeamRecord from '@salesforce/apex/CSMPlanCommunicationController.updatePlanTeamRecord';
import fetchTabs from '@salesforce/apex/CSMCommunicaitonTabHelper.fetchTabs';

//Plan Comment Fields
import SUB_TYPE from '@salesforce/schema/Plan_Comment__c.Sub_Type__c';
import PLAN_COMMENT_OBJECT from '@salesforce/schema/Plan_Comment__c';

export default class CsmPlanCommunicationViewer extends LightningElement {

	//Track variables.
	@track strCurrentParentTab = "All";
	@track strCurrentChildTab = "All";

     //API variables.
    @api recordId;
    @api isPoppedOut = false;
    @api strDefaultTab;
    //Private variables.
	boolInitialLoad = false;
    showEditCommentForm;
    @track
    commentType;
    @track
    commentSubType;
    subscription=null;
    objPlanTeamRecord;
    //Labels.
    label = {
    Refresh_Button,    
    Loading,
    Error,
    Success	
    }
    @wire(MessageContext)
    messageContext; 
    boolDisplaySpinner;
    //Get plan comment object
    @wire(getObjectInfo, { objectApiName: PLAN_COMMENT_OBJECT })
    planCommentObject;
    //Dynamically pull picklist values from fiels
   /* @wire(getPicklistValues,{recordTypeId: '$planCommentObject.data.defaultRecordTypeId',fieldApiName: SUB_TYPE})
    subTypePicklist({error, data}) {
        if (error) {
            //Process Error
        } else if (data) {
            let picklistValues = data.values;
            this.objConfiguration.lstTabs.forEach(objTab => {
                if(objUtilities.isNotNull(objTab.lstSubTabs)){
                    objTab.lstSubTabs=[
                        {
                            strLabel: "All",
                            strTitle: "All",
                            strTabValue: "All",
                            strObjectName: "Plan_Comment__c",  
                            boolCommentTab: true
                        }];
                        if(objUtilities.isNotNull(picklistValues)){
                            picklistValues.forEach(objPick => {
                                objTab.lstSubTabs = [...objTab.lstSubTabs,
                                                        {
                                                            strLabel: objPick.label,
                                                            strTitle: objPick.label,
                                                            strTabValue: objPick.value,
                                                            strObjectName: "Plan_Comment__c",  
                                                            boolCommentTab: true
                                                        }
                                                    ];
                            });
                        }
                }
           });
        }
    }*/
    //Feature Configuration.
    @track
    objConfiguration = {
        strIconName: "standard:live_chat",
        strCardTitle: "Plan Communication",     
        strDefaultTab:'All', 
        boolDisplayUnreadCounter:false, 
      /* lstTabs: [ 
            {
                strLabel: "All",
                strTitle: "All",
                strTabValue: "All",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            },   
            {
                strLabel: "Inbound",
                strTitle: "Inbound",
                strTabValue: "Inbound",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            },   
            {
                strLabel: "Attention Request",
                strTitle: "Attention Request",
                strTabValue: "Attention Request",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            },
            {
                strLabel: "External",
                strTitle: "External",
                strTabValue: "External",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            },         
            {
                strLabel: "Internal",
                strTitle: "Internal",
                strTabValue: "Internal",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false,
                lstSubTabs:[
                    {
                        strLabel: "All",
                        strTitle: "All",
                        strTabValue: "All",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },
                    {
                        strLabel: "General",
                        strTitle: "General",
                        strTabValue: "General",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },
                    {
                        strLabel: "CSM Manager",
                        strTitle: "CSM Manager",
                        strTabValue: "CSM Manager",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },
                    {
                        strLabel: "PAF Update",
                        strTitle: "PAF Update",
                        strTabValue: "PAF Update",
                        strObjectName: "Plan_Comment__c", 
                        boolCommentTab: true
                    },
                    {
                        strLabel: "Risk",
                        strTitle: "Risk",
                        strTabValue: "Risk",
                        strObjectName: "Plan_Comment__c",
                        boolCommentTab: true  
                    },
                    {
                        strLabel: "Engagement",
                        strTitle: "Engagement",
                        strTabValue: "Engagement",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },
                    {
                        strLabel: "Objectives & Milestone",
                        strTitle: "Objectives & Milestone",
                        strTabValue: "Objectives & Milestone",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },
                    {
                        strLabel: "Closing Notes",
                        strTitle: "Closing Notes",
                        strTabValue: "Closing Notes",
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true
                    },

                ]
            },
            {
                strLabel: "Private",
                strTitle: "Private",
                strTabValue: "Private",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            },
            {
                strLabel: "JIRA",
                strTitle: "JIRA",
                strTabValue: "JIRA",
                strObjectName: "Plan_Comment__c",
                boolCommentTab: true,
                strClass:"slds-m-right_small",
                strCounterValue:0,
                boolDisplayUnreadCounter:false
            }                
        ]    */          
    }

     /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
        this.showEditCommentForm = false;
        this.boolDisplaySpinner = false; 
		//First we load the list of records.
        this.subscribeToMessageChannel();
        this.loadTabs();
		this.loadRecords();
	}

    r
    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {       
        if(!this.subscription){
            this.subscription = subscribe(
            this.messageContext,
            PLAN_COMMS,
            ( message ) => {
                this.handleMessage( message );
            });
        }     
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
    // Handler for message received by component
    handleMessage(message) {
        let objParent = this;
        objParent.recordId = objUtilities.isNotNull(message.recordId)?message.recordId:'';
        if(objUtilities.isNotNull(message.commentType) && message.commentType === objParent.commentType ||
            objUtilities.isNotNull(message.commentSubType) && message.commentType === objParent.commentSubType
        ){ 
            objParent.commentType = message.commentType;
            objParent.commentSubType = message.commentSubType;
            //objParent.loadRecords();      
            objParent.template.querySelectorAll(`[data-id="${this.commentType}"]`).forEach(objComp => {
                if(objUtilities.isNotNull(objComp)){  
                    objComp.commentType=this.commentType; 
                    objComp.commentSubType=this.commentSubType;
                    objParent.strCurrentParentTab = objComp.commentType;
                    objParent.strCurrentChildTab = objComp.commentSubType;
                    objComp.refreshCard();   
                }
            });      
        }else if( (objUtilities.isNotNull(objParent.commentType) &&  objParent.commentType === "All") || 
                (objUtilities.isNotNull(objParent.commentSubType)  && objParent.commentSubType === "All")){                    
                objParent.template.querySelectorAll('[data-id=All]').forEach(objComp => {
                    if(objUtilities.isNotNull(objComp)){
                        objComp.commentType="All"; 
                        objComp.commentSubType="All";
                        objParent.strCurrentParentTab = "All";
                        objParent.strCurrentChildTab = "All";
                        objComp.refreshCard();   
                    }
                }); 
        }
    }
	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

	/*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding record.
	 Parameters	 : None
	 Return Type : None
	 */
    loadRecords(){
        let objParent = this;            
        let objComp= this.template.querySelector('c-csm-plan-communication-timeline-viewer');
        if(objUtilities.isNotNull(objComp)){   
            objComp.commentType=this.commentType; 
            objComp.commentSubType=this.commentSubType;
			objParent.strCurrentParentTab = objComp.commentType;
			objParent.strCurrentChildTab = objComp.commentSubType;
            objComp.refreshCard();   
        }
    } 

    renderedCallback() {        
		this.loadCounter();
    }

    captureLevelOneActiveTabValue(objEvent){
        let objParent = this;        
        let objTabValue = objEvent.target.value;
        objParent.resetLabels();
        objParent.commentType = objTabValue;    
       
        objParent.commentSubType='';
        /*const payload = { recordId: objParent.recordId,
            commentType: objParent.commentType,
            commentSubType:objParent.commentSubType,
            channelOrigin:'TabChange'                    
        };
        publish(objParent.messageContext, PLAN_COMMS, payload);*/
     this.template.querySelectorAll('.parentTabClass').forEach(objComp => {
            if(objUtilities.isNotNull(objComp)){  
                objComp.commentType=objParent.commentType; 
                objComp.commentSubType='';
                objComp.refreshCard();   
            }
        });  
       /* const objChild = this.template.querySelector('c-csm-plan-communication-timeline-viewer');       
        if(objUtilities.isNotNull(objChild)){
            objParent.strCurrentParentTab = objTabValue;
            objChild.commentType=objParent.commentType;
            objChild.commentSubType = objParent.commentSubType;
            objChild.refreshCard();
        }*/
       
    }
    captureLevelTwoActiveTabValue(objEvent){
        let objParent = this;
        let objTabValue = objEvent.target.value;
        objParent.commentSubType= objTabValue;
        objParent.strCurrentChildTab = objTabValue;
        const payload = { recordId: objParent.recordId,
            commentType: objParent.commentType,
            commentSubType:objParent.commentSubType,
            channelOrigin:'TabChange'                    
        };
        publish(objParent.messageContext, PLAN_COMMS, payload);
       /* const objChild = this.template.querySelector('c-csm-plan-communication-timeline-viewer');
       
        if(objUtilities.isNotNull(objChild)){
            objChild.commentType=objParent.commentType;
            objChild.commentSubType = objParent.commentSubType;
            objChild.refreshCard();
        }*/
    }
 
    	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
     handleClick(objEvent) {
         
        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'addComment':
                this.showEditCommentForm = true;
                break;
            case 'close':
                this.showEditCommentForm=false;
                break;
        }
    }
    
    handleClose(objEvent){  
        this.showEditCommentForm=false;
    }
    handleCommentData(objEvent){
        let objParent = this;
        objParent.objPlanTeamRecord=undefined;
        let objClonedConfig=objParent.objConfiguration;

        let lstFullcommentlist = objEvent.detail.fullcommentlist;
        if(lstFullcommentlist && lstFullcommentlist.length > 0){
            
            objParent.boolDisplaySpinner=true;
            getPlanTeamRecords({ strPlanId: objParent.recordId})
            .then((result) => {            
                if(objUtilities.isNotNull(result) && result.length>0){ 
                    objParent.objPlanTeamRecord=result[0];
                    //<T01>
                    objClonedConfig.lstTabs.forEach(objTab => {
                        if(objTab.strCounterValue && objTab.strCounterValue>0){
                            objTab.strCounterValue=0;
                        }                                                
                    });
                    //</T01>
                    lstFullcommentlist.forEach(comment => {
                        if (objUtilities.isNull(result[0].Last_Read_TimeStamp__c) || 
                            (objUtilities.isNotNull(result[0].Last_Read_TimeStamp__c) 
                            && comment.CreatedDate >  result[0].Last_Read_TimeStamp__c) && objClonedConfig.lstTabs) {
                            
                            objClonedConfig.lstTabs.forEach(objTab => {
                                if(objTab.strTabValue=='All'){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true; 
                                }else if(objTab.strTabValue=='Inbound' && comment.Inbound){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true; 
                                }else if(objTab.strTabValue==comment.Type){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true; 
                                }/*else if(objTab.strTabValue=='Internal' && comment.Type=='Internal'){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true; 
                                }else if(objTab.strTabValue=='Private' && comment.Type=='Private'){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true;  
                                }else if(objTab.strTabValue=='JIRA' && comment.Type=='JIRA'){
                                    objTab.strCounterValue++;
                                    objTab.boolDisplayUnreadCounter=true; 
                                }  */                              
                            });
                        }else{
                            objParent.objConfiguration.lstTabs.forEach(objTab => {
                                objTab.strCounterValue=0;
                                objTab.boolDisplayUnreadCounter=false; 
                                objTab.strCounterValueIndicatorIcon="";
                                objTab.strCounterValueIndicator = 0;
                            });
                        }
                    });
                    objParent.objConfiguration={};
                    objParent.objConfiguration=Object.assign(objClonedConfig);   
                } 
                //Load counter css
                objParent.boolInitialLoad=false;
                objParent.loadCounter();               
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                //Finally, we hide the spinner.
                objParent.boolDisplaySpinner = false;               
            });
            
        }
    }    
        
    resetLabels(){
        let objParent = this;
        if(objUtilities.isNotNull(objParent.objPlanTeamRecord)){
            objParent.objConfiguration.lstTabs.forEach(objTab => {
                objTab.strCounterValue=0;
                objTab.boolDisplayUnreadCounter=false;  
                objTab.strCounterValueIndicator=0;
                objTab.strCounterValueIndicatorIcon="";
            });
            objParent.boolDisplaySpinner = true;  
            updatePlanTeamRecord({ strPlanId: objParent.recordId})
            .then((result) => { 
            }).catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                //Finally, we hide the spinner.
                objParent.boolDisplaySpinner = false;               
            });  
        }         
    }

    /*
	 Method Name : loadCounter
	 Description : This method will load the counter Value css 
	 Parameters	 : none
	 Return Type : None
	 */
    loadCounter(){
        let intCentered;
		let strStyle = "";
		let objParent = this;

		//We apply custom styling.
		if(!objParent.boolInitialLoad) {
			objParent.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
                if(objUtilities.isNotNull(objParent.objConfiguration.lstTabs)){
                    objParent.objConfiguration.lstTabs.forEach(objTab => {
                        if(objTab.boolDisplayUnreadCounter) {
                            objParent.boolInitialLoad = true;
                            objTab.strCounterValueIndicator = objTab.strCounterValue;
                            objTab.strCounterValueIndicatorIcon = "utility:activity";
                            switch(("" + objTab.strCounterValue).length) {
                                case 1:
                                    intCentered = 15;
                                break;
                                case 2:
                                    intCentered = 18;
                                break;
                                case 3:
                                    intCentered = 22;
                                break;
                                default:
                                    intCentered = 15;
                                break;
                            }
                            strStyle += " c-csm-plan-communication-viewer lightning-tabset.parentTab li[title='" + objTab.strTitle + "'] lightning-icon.slds-icon-utility-activity lightning-primitive-icon svg {" + 
                                    "	border-radius: 50%;" + 
                                    "	background: red;" + 
                                    "	fill: transparent;" + 
                                    "} c-csm-plan-communication-viewer lightning-tabset.parentTab li[title='" + objTab.strTitle + "'] lightning-icon.slds-icon-utility-activity span.slds-assistive-text {" + 
                                    "	margin-left: -" + intCentered + "px !important;" + 
                                    "	margin-right: 10px !important;" + 
                                    "	position: relative !important;" + 
                                    "	color: white;" + 
                                    "	font-weight: bold;" + 
                                    "	font-size: var(--lwc-fontSize1,0.625rem);" + 
                                    "} "+
                                    " c-csm-plan-communication-viewer lightning-tabset.parentTab li[title='" + objTab.strTitle + "'] lightning-icon {"+
                                    "   position: absolute;"+
                                    "   right: -9px;"+
                                    "   top: -5px;"+
                                    "}";
                        }
                    });
                }
				if(objParent.boolInitialLoad) {
					objElement.innerHTML = "<style> " + strStyle + " </style>";
				}
			});
		}

    }
	/*
	 Method Name : loadTabs
	 Description : This method will load the tabs 
	 Parameters	 : none
	 Return Type : None
	 */
    loadTabs(){
        let objParent = this;
        objParent.boolDisplaySpinner = true;  
        fetchTabs()
        .then((objResult) => { 
            if(objUtilities.isNotNull(objResult.parentTabList) && objResult.parentTabList.length>0){
                objParent.objConfiguration.lstTabs = new Array(); 
                objResult.parentTabList.forEach(objTab => {
                    let parentTabObj= {
                        strLabel: objTab.Tab_Label__c,
                        strTitle: objTab.Tab_Title__c,
                        strTabValue: objTab.Tab_Value__c,
                        strObjectName: "Plan_Comment__c",  
                        boolCommentTab: true,
                        strClass:"parentTabClass",
                        strCounterValue:0,
                        boolDisplayUnreadCounter:false
                    }
                    if(objUtilities.isNotNull(objTab.Communication_Child_Tab_Settings__r) && objTab.Communication_Child_Tab_Settings__r.length>0){
                        parentTabObj.lstSubTabs=new Array();  
                        objTab.Communication_Child_Tab_Settings__r.forEach(objChildTab => {
                            parentTabObj.lstSubTabs.push(
                                {
                                    strLabel: objChildTab.Tab_Label__c,
                                    strTitle: objChildTab.Tab_Title__c,
                                    strTabValue: objChildTab.Tab_Value__c,
                                    strObjectName: "Plan_Comment__c",  
                                    boolCommentTab: true,
                                    strClass:"childTabClass",
                                    strCounterValue:0,
                                    boolDisplayUnreadCounter:false
                                }
                            );
                        });
                     
                    } 
                    objParent.objConfiguration.lstTabs.push(parentTabObj);
                })
            }
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            //Finally, we hide the spinner.
            objParent.boolDisplaySpinner = false;               
        }); 
    }
}