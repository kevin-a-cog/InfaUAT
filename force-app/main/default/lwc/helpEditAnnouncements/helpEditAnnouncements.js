/*
 * Name         :   HelpEditAnnouncements
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used editing the announcemnts on details page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           16-JUN-2022     I2RT-6422            Bringing Announcements on Community Page                  NA
 */

import getAllCommunityOptions from '@salesforce/apex/helpCommunityController.getAllCommunityOptions';
import { LightningElement,api,track,wire } from 'lwc';

export default class HelpEditAnnouncements extends LightningElement {
    @api heading;
	@api groupId;
	@api announcements;

	@track allOptions = [];
	@track selectedValue;
	@track title;
	@track desc;
	@track startDate;
	@track endDate;
	@track errorMessage = "Links should starts with https://";
	@track validity = true;
	@track showAnnouncements = true;
	@track showAnnouncementDetail = false;
	@track localAnnouncements = [];
	@track editAnnouncement;
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

	get announcementLst(){
		return  this.localAnnouncements.length > 0 ? this.localAnnouncements : this.announcements;
	}

	@wire(getAllCommunityOptions)
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

	saveAnnouncement() {
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
					Id: this.editAnnouncement.Id,
					title: this.title == null ? this.editAnnouncement.Name :  this.title,
					desc: this.desc == null ? this.editAnnouncement.AnnouncementDescription__c :  this.desc,
                    startDate:this.startDate == null ? this.editAnnouncement.Start_Date__c :  this.startDate,
                    endDate: this.endDate == null ? this.editAnnouncement.End_Date__c :  this.endDate,
					communities: this.selectedfilters,
				},
			})
		);
		this.editAnnouncement = {};
	}

	validateInputField(){
        var isValidValue = [...this.template.querySelectorAll('lightning-input','lightning-input-rich-text')]
							.reduce((validSoFar, inputField) => {
								inputField.reportValidity();
								return validSoFar && inputField.checkValidity();
							}, true);
        return isValidValue;
    }

	handleEditMode(event){
		try{
			let announcementId = event.target.dataset.id;
			this.localAnnouncements = [...this.announcements].map(ann =>{
				let announcement = JSON.parse(JSON.stringify(ann));
				if(announcement.Id == announcementId){
					announcement.showEditMode = true;
					if(announcement.Community__c != null)
						this.selectedfilters = announcement.Community__c.split(';');				
					this.editAnnouncement = announcement;
				}else{
					announcement.showEditMode = false;
				}
				return announcement;
			});
			if(this.localAnnouncements.length > 0){
				this.showAnnouncementDetail = true;
				this.showAnnouncements = false;
			}else{
				this.showAnnouncementDetail = false;
				this.showAnnouncements = true;
			}
		}catch(error){
			console.log(error);
		}
	}
}