/*
 * Name         :   HelpCreateAnnouncement
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used create new announcemnts on details page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           16-JUN-2022     I2RT-6422            Bringing Announcements on Community Page                  NA
 */

import { LightningElement,api,track,wire } from 'lwc';
import getAllCommunityOptions from '@salesforce/apex/helpCommunityController.getAllCommunityOptions';
import communityId from '@salesforce/community/Id';

export default class HelpCreateAnnouncement extends LightningElement {
    @api heading;
	@api groupId;
	@api recordId;
	@track allOptions = [];
	@track selectedValue;
	@track title;
	@track desc;
	@track startDate;
	@track endDate;
	@track errorMessage = "Links should starts with https://";
	@track validity = true;
	@track selectedfilters = [];

	@track formats = [
        'bold',
        'italic',
        'underline',
        'strike',
        'clean',
        'list',
        'link',
        'table',
        'header'
    ];


	
	@wire(getAllCommunityOptions, {networId: communityId})
    getoptions({ data, error }){
        if(data){
            this.allOptions = data.map(this.mapOptions);
        }else if(error){
            console.log("error", error);
        }
    } 

	mapOptions(option){
		let newOption = {
			label : option.label,
			value : option.label
		}
		return newOption;
	}

	handlefirstChange(event) {
        this.selectedfilters = event.detail;
    }

	get options(){
		this.selectedValue = this.selectedpostto;
        return this.allOptions;
    }

	handlePostChange(event) {
		this.selectedValue = event.detail.value;
	}
	onTitleChange(event) {
		this.title = event.detail.value;
	}
	onStartDateChange(event) {
		this.startDate = event.detail.value;
	}
	onEndDateChange(event) {
		this.endDate = event.detail.value;
	}
	onDescChange(event) {
		this.desc = event.detail.value;
	}

	closeAnnouncementModal() {
		this.dispatchEvent(
			new CustomEvent("closepopup", {
				detail: true,
			})
		);
	}

	createAnnouncement() {
		var isValidValue = this.validateInputField();
		if(isValidValue){
			if(this.desc == undefined || !this.desc.includes('<a href=')){
				this.validity = true;
				this.saveValues();

			}else if(this.desc != undefined && this.desc.includes('<a href=') && this.desc.includes('<a href="https://')){
				this.validity = true;
				this.saveValues();

			}else{
				this.validity = false;
			}
		}
	}

	saveValues(){
		this.dispatchEvent(
			new CustomEvent("save", {
				detail: {
					title: this.title,
					desc: this.desc,
                    startDate:this.startDate,
                    endDate: this.endDate,
					commuities: this.selectedfilters
				},
			})
		);
	}

	validateInputField(){
        var isValidValue = [...this.template.querySelectorAll('lightning-input','lightning-input-rich-text')]
							.reduce((validSoFar, inputField) => {
								inputField.reportValidity();
								return validSoFar && inputField.checkValidity();
							}, true);
        return isValidValue;
    }
}