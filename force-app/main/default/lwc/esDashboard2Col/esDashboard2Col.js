/*
 Change History
 **********************************************************************************************************
 Modified By		  Date			Jira No.	Description				                          Tag
 **********************************************************************************************************
 NA                   NA            UTOPIA      Initial version.                                  NA
 Vignesh Divakaran	  23/02/2022	I2RT-5185	Add Signature Select for view guide and icon      T01
 */
import { LightningElement, wire, track, api } from 'lwc';
import { registerListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getSupportAccountInfo from '@salesforce/apex/CaseController.getSupportAccountInfo';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsDashboard2Col extends LightningElement {
    selectedaccount;
    @track supportAccountId;
    @track accountMembers = [];
    @track accountMembersWrp = [];
    @track supportguide = [];
    @track primaryContacts = [];
    @track openCases = [];
    @track allOpenCases = [];
    @track allClosedCases = [];
    @track successOffering;
    @track signatureSuccesssIcon;
    @track flagIndicatingDataHasBeenLoaded = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
       
        var supAcccid = window.sessionStorage.getItem('supportAccountId');
         //event listener for rendering all the related fulfillment lines corresponding to the Active Tab on "fulfillmentLines" component
       registerListener('getAccountDetails', this.handleResponse, this);
            
      var  siteURL = window.location.href;      
        console.log(' Dashboard AccountId= '+this.supportAccountId);
        var firstTime = localStorage.getItem("first_timeVal");
       // alert('first '+firstTime); 
if(firstTime!=null) {
    console.log(' first time AccountId= '+this.supportAccountId);
   // alert('loader');
   //alert(testURL+' Dashboard AccountId= '+document.referrer);
    // first time loaded!
    getSupportAccountInfo({accountId :supAcccid})
    .then(result => {
        console.log('AccountInfo= '+JSON.stringify(result));
        this.accountMembersWrp = result.accountMembersWrp;
        console.log('AccountInfo==> '+JSON.stringify(this.accountMembersWrp));
        this.accountMembers = result.accountMembers;
        this.supportguide = result.supportguide;
        this.primaryContacts = result.primaryContacts;
        this.openCases = result.myOpenCases;
        this.allClosedCases = result.allClosedCases;
        console.log('Open Cases= '+this.openCases.length);
        console.log('caseLength= '+this.allClosedCases.length);
        this.allOpenCases = result.allOpenCases;
        this.successOffering = result.successOffering;

        if(this.successOffering == 'Basic Success'){
            this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';//license_icons-01.svg'
        } else if(this.successOffering == 'Signature Success' || this.successOffering == 'Signature Select') { //<T01>
            this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-03.svg';//license_icons-02.svg
        } else if(this.successOffering == 'Premium Success') {
            this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-02.svg';//license_icons-03.svg
        }else{
            this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg'; 
        }
        this.flagIndicatingDataHasBeenLoaded = true;
    });
  // window.open(siteURL,'_self');
} else{
    localStorage.setItem("first_timeVal","2");
}
      // handleResponse1(secid); 
       // alert(this.supportAccountId);      
    }
     
    handleResponse(supportAccountId){ 
        this.selectedaccount = supportAccountId;       
        getSupportAccountInfo({accountId :supportAccountId})
        .then(result => {
            console.log('AccountInfo= '+JSON.stringify(result));
            this.accountMembersWrp = result.accountMembersWrp;
            this.accountMembers = result.accountMembers;
            this.primaryContacts = result.primaryContacts;
            this.openCases = result.myOpenCases;
            this.allClosedCases = result.allClosedCases;
            console.log('caseLength= '+this.allClosedCases.length);
            this.allOpenCases = result.allOpenCases;
            this.successOffering = result.successOffering;

            if(this.successOffering == 'Basic Success'){
                this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';//license_icons-01.svg
            } else if(this.successOffering == 'Signature Success' || this.successOffering == 'Signature Select') { //<T01>
                this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-03.svg';
            } else if(this.successOffering == 'Premium Success') {
                this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-02.svg';
            }else{
                this.signatureSuccesssIcon = ESUPPORT_RESOURCE + '/license_icons-01.svg';
            }
            this.flagIndicatingDataHasBeenLoaded = true;
        });
    }
}