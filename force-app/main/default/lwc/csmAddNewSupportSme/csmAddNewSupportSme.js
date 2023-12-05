/*
 * Name			:	CsmAddNewSupportSme
 * Author		:	Harshita Joshi
 * Created Date	: 	6/22/2022
 * Description	:	Make Account Team Record.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Harshita Joshi		    6/22/2022		I2RT-6474		Initial version.					N/A
 */

import { LightningElement, api } from 'lwc';
import AccountTeamMember_OBJECT from '@salesforce/schema/AccountTeamMember';
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
 
export default class CsmAddNewSupportSme extends LightningElement {
    @api recordId ;
    userId;
    teamProduct;
    teamMemberRole;
    accountid;
    accountTeamObject = AccountTeamMember_OBJECT;
    isLoading = false;
   
   handleDefault(){
    this.accountid = this.recordId;
    this.teamMemberRole = 'Support SME';
   }
   handleSubmit(){
    this.isLoading = true;
   }

   handleAccountCreated(){
    this.dispatchEvent(new CloseActionScreenEvent());
    objUtilities.showToast("Success", 'Record has been created successfully!', "success", this);
    this.isLoading = false;
   }

   handleError(objEvent){
    this.isLoading = false;
    let strError = '';
    if(objEvent.detail?.output?.errors?.length > 0){
       objEvent.detail.output.errors.forEach(objError =>{
         strError = objUtilities.isNotBlank(strError) ? `, ${objError.message.replace('.','')}` : `${objError.message.replace('.','')}`;
       });
    }
    else{
        strError = objEvent.detail.message;
    }
    objUtilities.showToast("Error", strError, "error", this);
   }
   
}