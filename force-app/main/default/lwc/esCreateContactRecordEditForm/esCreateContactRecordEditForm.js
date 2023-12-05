/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
Amit Garg      	    21/06/2022	    I2RT-5996	        eSupport - Reduce Timezone selection list to                 T01
                                                            avoid incorrect selections
Amit Garg      	    08/08/2022	    I2RT-6736	        Admin: Primary Contact not able to create                  T02
                                                        new contact who is already part of another customer account
Amit Garg      	      26/10/2022	    I2RT-7326	        update the code to display the error messages fomr apex     T03
 */
import { LightningElement, api, wire, track } from 'lwc';
import CreateNewContact from "@salesforce/apex/ManageCaseContacts.CreateNewContact";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import locationAndRegionValues from "@salesforce/apex/SupportAccountController.getPicklistValuesforRegionAndLocation";//<T01>
//Custom Labels
//import POTENTIAL_DUPLICATE from '@salesforce/label/c.Potential_Duplicate_Lead_Validation_Message';//<T02>

//const RW_CONTACTLIMIT = 'Max Read/Write contacts limit reached';//<T02>
//const DEFAULT_ERR_MESSAGE = 'An error occurred while creating contact.';//<T02>
//const DUPLICATEERRMSG = 'Contact already exist in the system'; //KG//<T02>
const DUPLICATECASECON = 'Contact is added to case already';

export default class EsCreateContactRecordEditForm extends LightningElement {
    @track isCreateNewContact;
    @api suppAccId;
    @api caserecId;
    ContactDetail;
    @track isLoadingSpinner;
    //<T01> starts
    conTimezoneRegion;
    conTimezoneLocation;
    RegionAndLocations;
    regionOptions;
    locationOptions;
    //<T01> ends
    connectedCallback() {
        console.log('EsRecordEditForm-->connected');
        console.log('EsRecordEditForm-->connected-->caseId' + this.caserecId);
        console.log('EsRecordEditForm-->connected-->suppAccId' + this.suppAccId);
        // this.caserecId = '500g000000WbolS';
        // this.suppAccId = '001g000002TRd3h';
        this.isCreateNewContact = true;
    }
        //<T01> starts
    @wire(locationAndRegionValues)
    user({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.RegionAndLocations = data;
            var regions = [];
            for(var i=0;i<this.RegionAndLocations.length;i++){
                var val = this.RegionAndLocations[i].Region;
                regions.push({label:val,value:val})
            }
            this.regionOptions = regions;
            console.log('@@----region and location-->>',data);
        }
    } 
    handleLocationChange(event){
        this.acrChanged = true;
        this.conTimezoneLocation = event.detail.value;
        this.validateContactConfirmButton();
        //alert(this.conTimezoneLocation);
    }
    handleRegionChange(event){
    this.acrChanged = true;
    this.conTimezoneRegion = event.detail.value;
    this.locationOptions = [];
    for(var i=0;i<this.RegionAndLocations.length;i++){
        if(this.conTimezoneRegion == this.RegionAndLocations[i].Region){
            for(var j=0;j<this.RegionAndLocations[i].location.length;j++){
                //console.log('@@--->>',this.RegionAndLocations[i].location[j]);
                var val = this.RegionAndLocations[i].location[j].Loc;
                //console.log('@@@--->>>',val);
                this.locationOptions.push({label:val,value:val});
            }
        }
        
    }
    this.validateContactConfirmButton();
    }
//<T01> ends

    //Handle Submit for ACR/Contact Creation
    handleSubmit(event) {
        event.preventDefault();
        this.isLoadingSpinner = true;
        // this.isCreateNewContact = false;
        console.log('handleSubmit: ' + JSON.stringify(event.detail.fields));
        const fields = event.detail.fields;
        this.ContactDetail = JSON.stringify(fields);
        console.log('contact fields -->'+JSON.stringify(this.ContactDetail));
        CreateNewContact({ ContactRec: this.ContactDetail, SupportAccountId: this.suppAccId, CaseId: this.caserecId,Region: this.conTimezoneRegion, Location:this.conTimezoneLocation })//<T01>
            .then((result) => {                
                var str1 = 'CONTACTPRESENT';
                var str2 = 'DUPLICATE';
                console.log('result ' + JSON.stringify(result));
                var res = JSON.stringify(result) ;                      
                var compareOne = result.localeCompare(str1);
                var compareTwo = result.localeCompare(str2)
                console.log('compareOne ' + result.localeCompare(str1));
                console.log('compareTwo ' + result.localeCompare(str2));
                if(compareOne === 0 ||compareTwo === 0 || res.includes("DUPLICATES_DETECTED")){                    
                    const event = new ShowToastEvent({
                        title : 'Error',
                        message : 'Contact already exist in the system',
                        variant : 'error',
                        mode : 'dismissable'
                    });
                    this.dispatchEvent(event);
                }             
                if(res.includes(DUPLICATECASECON)){
                    const event = new ShowToastEvent({
                        title : 'Error',
                        message : 'Contact already exist on the case',
                        variant : 'error',
                        mode : 'dismissable'
                    });
                    this.dispatchEvent(event);
                }           
                this.dispatchEvent(new CustomEvent('addnewcontact', { detail: this.result })); //Send records to display on table to the parent component
                this.isCreateNewContact = false;
                document.body.classList -= ' modal-open';

            })
            .catch((error) => {
                console.log(JSON.stringify(error));  
                this.isLoadingSpinner = false;
                let errorMessage;
                //<T02> added comment
                /*if(error.body.message != undefined && error.body.message.includes(RW_CONTACTLIMIT)){
                    errorMessage = RW_CONTACTLIMIT;
                }
                else if(error.body.message != undefined && error.body.message.includes(DUPLICATEERRMSG)){
                    errorMessage = DUPLICATEERRMSG;
                }
                else if(error.body.message != undefined && error.body.message.includes("Please Enter valid Email")){
                    errorMessage = error.body.message;
                }
                else if(error.body.message != undefined && error.body.message.includes(POTENTIAL_DUPLICATE)){
                    errorMessage = POTENTIAL_DUPLICATE;
                }
                else{
                    errorMessage = DEFAULT_ERR_MESSAGE;
                }*/
                errorMessage = error.body.message;
                const event = new ShowToastEvent({
                    title : 'Error',
                    message : error.body.message,
                    variant : 'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            })
    }
}