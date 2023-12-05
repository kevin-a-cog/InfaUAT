import { LightningElement,api } from 'lwc';
	
import MDM_LOGO from '@salesforce/resourceUrl/mdm_logo';

export default class SearchAccountCard extends LightningElement {
    @api address;
    @api city;
    @api country;
    @api gduns;
    @api idnumber;
    @api index;
    @api isClicked = false;
    @api isSalesforceRecord;
    @api name;
    @api postalCode;
    @api salesforceId;
    @api score;
    @api state;
    @api phoneNumber;
    @api website;
    @api accountType; //SALESRT-13356

    get mdmLogo(){
        return MDM_LOGO;
    }

    get isDunsAvailable(){
        return this.gduns ? true : false;
    }
    //SALESRT-13356
    get isAccTypeAvailable(){
        return this.accountType ? true : false;
    }
    //
    handleClick(){
        const selectEvent = new CustomEvent('selected', {
            detail: this.index
            });
        this.dispatchEvent(selectEvent);
    }

}