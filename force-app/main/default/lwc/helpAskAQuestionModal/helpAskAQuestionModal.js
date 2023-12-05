/*
 * Name         :   HelpAskAQuestionModal
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is a base component for showing modal with fields for ask a question.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5249           Initial version.                                           NA
 Saumya Gaikwad         Sep 29,2022     I2RT-7170	        Fixed the Missing Product Community Name                   1
															tag when Image is added in description
 Deeksha Shetty         Dec 2,2022      I2RT-7545			Spammed words are getting posted in product community	   2
 Deeksha Shetty        	28 Mar,2023		I2RT-7800           IN site is not loading in iPhone device and Safari browser 3
															in Mac.					                                                            
 */
import { api, LightningElement, track, wire } from "lwc";

import communityId from "@salesforce/community/Id";
import getAllCommunityOptions from "@salesforce/apex/helpCommunityController.getAllCommunityOptions";
import blockedKeywordMsg from '@salesforce/label/c.IN_BlockedKeyword';

export default class HelpAskAQuestionModal extends LightningElement {
	@api heading;
	@api selectedpostto;
	@track isRendered = true;
	@track allOptions = [];
	@track selectedValue;
	@track title;
	@track desc;
	@track errorMessage;
	@track validity = false;

	@track formats = [
		'bold',
		'italic',
		'underline',
		'strike',
		'clean',
		'list',
		'link',
		'table',
		'header',
		'image'          //tag 1
	];

	@track fileData = [];
	@track fileNames = [];
	textFiles = [];
	imageList;
	@api isLoading; //tag 2
	badword;//tag 2
	globalErrMsg;//tag 2
	showSpamMessage = false; //tag 2

	@api
	showErrorMessage(message) {
		//tag 2 starts
		if (message.includes(blockedKeywordMsg.split('%BLOCKED_KEYWORD%')[1])) {
			this.globalErrMsg = message;
			this.badword = this.extractAllText(message); //Tag 3
			if (this.badword) this.testcustomValidity(this.badword);
		} //tag 2 ends
		else {
			this.errorMessage = message;
			this.validity = false;
		}
	}
	/* Tag 3 Starts */
	extractAllText(str) {
		const re = /"(.*?)"/g;
		const result = [];
		let current;
		while (current = re.exec(str)) {
			result.push(current.pop());
		}
		return result.length > 0 ? result : [str];
	}
	/* Tag 3 Ends */


	@wire(getAllCommunityOptions, { networId: communityId })
	getoptions({ data, error }) {
		if (data) {
			this.allOptions = data;
		} else if (error) {
			console.error("error", error);
		}
	}

	get options() {
		if (this.selectedpostto != '' && this.selectedpostto != null && this.selectedpostto != undefined && this.isRendered) {
			this.selectedValue = this.selectedpostto;
		}
		if (this.allOptions.length > 0 && this.allOptions.filter(e => e.value == this.selectedpostto).length == 0) {
			this.selectedpostto = "";
		} else if (this.selectedValue == undefined) {
			this.selectedpostto = "";
		}
		return this.allOptions;
	}

	handlePostChange(event) {
		this.selectedValue = event.detail.value;
		this.selectedLabel = event.target.options.find(opt => opt.value === event.detail.value).label
		this.isRendered = false;
	}
	onTitleChange(event) {
		this.title = event.detail.value;
	}
	onDescChange(event) {
		this.desc = event.detail.value;
	}

	closeAskQuestionModal() {
		this.isLoading = false;
		this.dispatchEvent(
			new CustomEvent("closepopup", {
				detail: true,
			})
		);
	}

	//tag 2 starts
	testcustomValidity(badword) {
		let searchCmp = this.template.querySelector(".quesCmp");
		let searchvalue = searchCmp.value;

		let choice1Cmp = this.template.querySelector(".descCmp");
		let c1value = choice1Cmp.value;
		c1value = c1value.replace(/(<([^>]+)>)/ig, '');

		let boolval1 = badword.some(item => searchvalue.toLowerCase().includes(item.toLowerCase()));
		let boolval2 = badword.some(item => c1value.toLowerCase().includes(item.toLowerCase()));

		if (boolval1 || boolval2) {
			this.showSpamMessage = true;
		}
		else {
			this.showSpamMessage = false;
		}
	}
	//tag 2 ends

	saveModal() {
		if (this.badword) this.testcustomValidity(this.badword); //tag 2 
		var isValidValue = this.validateInputField();
		if (!this.desc) {
			this.validity = false;
			this.errorMessage = "You haven't composed anything yet.";
		}
		if (isValidValue) {
			if (this.desc.length == 0) {
				this.validity = false;
				this.errorMessage = "You haven't composed anything yet.";

			} else if (!this.desc.includes('<a href=')) {
				this.validity = true;
				this.desc = this.desc.replaceAll('<br>', '<p>&nbsp;</p>');
				this.saveValues();

			} else if (this.desc.includes('<a href=') && this.desc.includes('<a href="https://')) {
				this.validity = true;
				this.desc = this.desc.replaceAll('<br>', '<p>&nbsp;</p>');
				this.saveValues();

			} else {
				this.validity = false;
				this.errorMessage = "Links should starts with https://";
			}
		}
	}


	saveValues() {
		this.dispatchEvent(
			new CustomEvent("save", {
				detail: {
					label: this.selectedLabel,
					comm: this.selectedValue,
					title: this.title,
					desc: this.desc,
					file: this.fileData
				},
			})
		);
	}

	validateInputField() {
		var isValidValue = [...this.template.querySelectorAll('lightning-combobox, lightning-input')]
			.reduce((validSoFar, inputField) => {
				inputField.reportValidity();
				return validSoFar && inputField.checkValidity();
			}, true);
		return isValidValue;
	}


	readFile(fileSource) {
		return new Promise((resolve, reject) => {
			const fileReader = new FileReader();
			const fileName = fileSource.name;
			fileReader.onerror = () => reject(fileReader.error);
			fileReader.onload = () => resolve(
				{ fileName, base64: fileReader.result.split(',')[1] }
			);
			fileReader.readAsDataURL(fileSource);
		});
	}

	async handleFileChange(event) {
		this.textFiles = await Promise.all(
			[...event.target.files].map(file => this.readFile(file))
		);

		for (let i in this.textFiles) {
			let fileEntity = {
				'filename': this.textFiles[i].fileName,
				'base64': this.textFiles[i].base64
			}
			this.fileData.push(fileEntity);
			this.fileNames.push(this.textFiles[i].fileName);
		}
	}

	removeFile(event) {
		let index = event.target.dataset.i;
		this.fileData.pop(index);
		this.fileNames.pop(index);
	}
}