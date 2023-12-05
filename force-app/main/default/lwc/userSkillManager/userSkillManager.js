import { LightningElement, track, wire,api } from 'lwc';
import fetchProfileSkills from '@salesforce/apex/UserSkillManagerCtrl.fetchProfileSkills';
import removeSkill from '@salesforce/apex/UserSkillManagerCtrl.removeSkill';
import fetchMultiPicklist from '@salesforce/apex/UserSkillManagerCtrl.getselectOptions';
import addNewProfileSkillUser from '@salesforce/apex/UserSkillManagerCtrl.addNewProfileSkillUser';

import ismanager from '@salesforce/customPermission/GCS_Manager';

export default class UserSkillManager extends LightningElement {
    @api recordId;
    searchKey = '';
	@track lstProfileSkillData = [];
	@track lstProfileSkill = [];

	@track timezoneOpts = [];
	@track PriorityOpts = [];
	@track ComponentOpts = [];
	@track ProductOpts = [];
	@track SupportLevelOpts = [];
	@track TimezoneRegionOpts = [];
	@track roleskills = [];
	selectedSkillRecId = '';
	bShowSpinner = false;
	bShowStepOne = true;
	bShowStepTwo = false;
	engineercheck = false;
	sortedDirection = 'asc';
	isAsc = true;
	isDsc = false;
	
	bShowModal = false;
	bDisableNextBtn = true;

	profileSkillUserObj = {};

	selectedComponent = [];
	selectedPriority = [];
	selectedProduct = [];
	selectedSupportLevel = [];
	selectedTimezone = [];
	selectedTimezoneRegion = [];
	hasApprovalNeededForSkill = false;
	userQuestionValue = 'No';

	prodSkillTypeSettings = new Map([
		['Product Engineer', {showSkill : true, sortOrder : 1}],
		['Product Specialist', {showSkill : true, sortOrder : 2}],
		['KB Technical Reviewer', {showSkill : true, sortOrder : 3}],
		['Product Manager', {showSkill : true, sortOrder : 4}],
		['Product Engineer/Specialist', {showSkill : false, sortOrder : 5}],
	]);

	get hasUserQuestion(){
		if(this.userQuestionValue == 'No'){
			return false;
		}else{
			return true; 
			//return false;
		}
	}

	get showbackBtn(){
		if(this.bShowStepTwo == true){
			return true;
		}else{
			return false;
		}
    }

    get bShowSubmitBtn(){
		if(this.hasApprovalNeededForSkill == true){
			return false;
		}else{
			return true;
		}
    }
    
    get ismanager() {
		console.log('manager ps:'+ismanager);
		return ismanager;
    }

	connectedCallback(){
		this.fetchskills();
		this.profileSkillUserObj['sobjectType'] = 'ProfileSkillUser';
		this.profileSkillUserObj['UserId'] = this.recordId;
		fetchMultiPicklist({'fld' : 'Timezone__c'}).then(result => {this.timezoneOpts = result}).catch(error => {});
		fetchMultiPicklist({'fld' : 'Priority__c'}).then(result => {this.PriorityOpts = result}).catch(error => {});
		fetchMultiPicklist({'fld' : 'Component__c'}).then(result => {this.ComponentOpts = result}).catch(error => {});
		fetchMultiPicklist({'fld' : 'Product__c'}).then(result => {this.ProductOpts = result}).catch(error => {});
		fetchMultiPicklist({'fld' : 'Support_Level__c'}).then(result => {this.SupportLevelOpts = result}).catch(error => {});
		fetchMultiPicklist({'fld' : 'Timezone_Region__c'}).then(result => {this.TimezoneRegionOpts = result}).catch(error => {});
	}

	searchSkillHandler(event){
		this.searchKey = event.target.value;
		this.fetchskills();
	}

	fetchskills(){
		console.log('recid'+this.recordId);
		this.bShowSpinner = true;
		fetchProfileSkills({
			'sUserId': this.recordId, 
			'sSearch': this.searchKey
		}).then(result => {
			console.log('data2==> ' + JSON.stringify(result));
			let oData = JSON.parse(JSON.stringify(result));
			console.log('length'+oData.length);

			this.lstProfileSkillData = result.lstUserSkill;    

			var skilllist = [];
			result.lstSkill.forEach(skill => {
				var skillval = {};
				skillval['name'] = skill['skillName'];
				skillval['roleBased'] = skill['roleBased'];

				let skillTypes = [];
				if(skillval['roleBased']){
					skill['lstSkillType'].forEach(skillTypeDetail => {
						let skillTypeVal = {};
						skillTypeVal['keyval'] = skill['skillName'] + '-' + skillTypeDetail['type'];
						skillTypeVal['type'] = skillTypeDetail['type'];
						skillTypeVal['assigned'] = skillTypeDetail['assigned'];
						skillTypeVal['profileSkillId'] = skillTypeDetail['profileSkillId'];
						//skillTypeVal['orderNumber'] = this.productSkillTypes.get(skillTypeDetail['type']);
						skillTypeVal['showSkill'] = true;
						skillTypeVal['disabled'] = false;
						skillTypes.push(skillTypeVal);	
					});	
				}else{
					this.prodSkillTypeSettings.forEach((settings, productSkillType) => {
						let skillTypeVal = {};
						skillTypeVal['keyval'] = skill['skillName'] + '-' + productSkillType;
						skillTypeVal['type'] = productSkillType;
						skillTypeVal['orderNumber'] = settings.sortOrder;
						skillTypeVal['showSkill'] = settings.showSkill;
						skillTypeVal['disabled'] = true;
						skillTypeVal['assigned'] = false;
						skill['lstSkillType'].forEach(skillTypeDetail => {
							if(productSkillType == skillTypeDetail['type']){
								skillTypeVal['disabled'] = false;
								skillTypeVal['assigned'] = skillTypeDetail['assigned'];
								skillTypeVal['profileSkillId'] = skillTypeDetail['profileSkillId'];
							}
						});	
						skillTypes.push(skillTypeVal);		
					})
				}

				console.log('skillTypes 2 ===> ', skillTypes);
				skillval['lstSkillType'] = skillTypes.sort((a, b) => {
					return a.orderNumber - b.orderNumber;
				});

				skilllist.push(skillval);        
			});
			
			console.log('skilllist===> ' + JSON.stringify(skilllist));
			this.lstProfileSkill = skilllist;    
			console.log(this.lstProfileSkill[0]);
			console.log(this.lstProfileSkill[0]['name']);
			let sortcol = 'name';
			let table = JSON.parse(JSON.stringify(this.lstProfileSkill));
			var reverse = this.sortedDirection === 'asc' ? 1 : -1;
			table.sort((a,b) => 
				{return a[sortcol] > b[sortcol] ? 1 * reverse : -1 * reverse}
			);
			this.lstProfileSkill = table;
			this.bShowSpinner = false;
		}).catch(error => {
			this.bShowSpinner = false;
			console.log('error===> ' + JSON.stringify(error));
		});
	}

	sort(event){
		//console.log('col'+event.currentTarget.dataset.id);
		this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
		if(this.sortedDirection == 'asc'){
			this.isAsc = true;
			this.isDsc = false;
		}else  {
			this.isAsc = false;
			this.isDsc = true;
		}
		//let sortcol = event.target.getAttribute("data-id");
		let sortcol = event.currentTarget.dataset.id;
		console.log('sortcol:'+sortcol);
		let table = JSON.parse(JSON.stringify(this.lstProfileSkill));
		var reverse = this.sortedDirection === 'asc' ? 1 : -1;
		table.sort((a,b) => {
			return a[sortcol] > b[sortcol] ? 1 * reverse : -1 * reverse;
		});
		this.lstProfileSkill = table;
	}

	navigateToProfileSkill(event){
		var recId = event.target.getAttribute('data-recid');
		window.open('/' + recId , '_blank' ); 
	}

	deleteSkill(event){
        let sRecId = event.target.name;
        let skillname = event.currentTarget.dataset.id;
        console.log('sRes---> ' +  skillname);   
        if(window.confirm('Are you sure to delete this item?')){
			this.bShowSpinner = true;

			removeSkill({'sRecId' : sRecId})
			.then(result => {      
				this.searchKey = '';
				this.bShowSpinner = false;  
				this.fetchskills();
			}).catch(error => {
				this.bShowSpinner = false;          
				console.log('error in catch of removeSkill');
			});
        }   
	}

	closeModal() {    
		// to close modal window set 'bShowModal' tarck value as false
		this.bShowModal = false;
		this.bDisableNextBtn = true;
	}
      
	addNewValue(){
		this.bShowModal = true;
	}

	addNewSkill(event){
        this.bShowSpinner = true;
        event.target.disabled = true;

        let inputvar =  JSON.stringify(this.lstProfileSkill);
        console.log('=====>>>>123 ' +inputvar);
        
        addNewProfileSkillUser({'inputresponse' : inputvar , 'hasApprovalNeeded' : false, 'sUserId':this.recordId})
        .then(result => {
			console.log('entering');
			this.bShowSpinner = false;
			this.fetchskills();
			this.closeModal();
        }).catch(error => {
			this.bShowSpinner = false;
			this.closeModal();
			console.log('error in catch of addNewSkill');
        });
	}
        
	submitSkillForApproval(event){
        this.bShowSpinner = true;
        event.target.disabled = true;
        console.log('=====>>>> ' + JSON.stringify(this.profileSkillUserObj));
        addNewProfileSkillUser({'oProfileSkillUserData' : this.profileSkillUserObj , 'hasApprovalNeeded' : true,'sUserId':this.recordId})
        .then(result => {
            location.reload();
        })
        .catch(error => {

        });
	}

	goBack(){
        this.bShowStepOne = true;
        this.bShowStepTwo = false;
        this.bDisableNextBtn = true;
	}

	NextStep(){
		this.bShowStepOne = false;
		this.bShowStepTwo = true;
	}

	onSkillSelection(event){
        this.bDisableNextBtn = false;
        var selectedRecId = event.target.value;
        this.hasApprovalNeededForSkill = (event.target.getAttribute('data-approvalneeded') === 'Yes');
        console.log('approval needed'+event.target.getAttribute('data-approvalneeded'));
        this.userQuestionValue =  event.target.getAttribute('data-userquestion');
        this.selectedSkillRecId = selectedRecId;
        this.profileSkillUserObj['ProfileSkillId'] = selectedRecId;

	}

	handleChange(event) {
        this.bDisableNextBtn = false;

        let skillname = event.target.getAttribute("data-name");
        let skillTypeSelected = event.target.getAttribute("data-id");
		console.log('skillname-'+skillname);
		console.log('skilltype-'+skillTypeSelected);
		this.lstProfileSkill.forEach(skill => {
			if(skill['name'] == skillname){
				let engSpecialistSkill;
				let engSpecialistSelected = false;
				skill['lstSkillType'].forEach(skillType => {
					if(skillType['type'] == skillTypeSelected){
						skillType['assigned'] = event.target.checked;
					}
					if(skillType['type'] == 'Product Engineer/Specialist'){
						engSpecialistSkill = skillType;
					}else if(skillType['assigned'] && (skillType['type'] == 'Product Engineer' || skillType['type'] == 'Product Specialist')){
						engSpecialistSelected = true;
					}
				});
				if(engSpecialistSkill){
					engSpecialistSkill['assigned'] = engSpecialistSelected;
				}
			}
		});
        console.log('this.lstProfileSkill===> ' + JSON.stringify(this.lstProfileSkill));
    }

	handleMultiplicklistChange(event){
        const whichField = event.target.name;
        const value = event.detail.value;
        let mulPickListValue = '';
        for(var i=0; i < value.length; i++){
			mulPickListValue += value[i] ;
			if(i != (value.length - 1)){
				mulPickListValue += ';';
			}
        }

        switch(whichField) {
			case 'Priority':
				this.profileSkillUserObj.Priority__c = mulPickListValue;
				break;

			case 'Component':
				this.profileSkillUserObj.Component__c = mulPickListValue;
				break;

			case 'Timezone':
				this.profileSkillUserObj.Timezone__c = mulPickListValue;
				break;

			case 'Success Offering':
				this.profileSkillUserObj.Support_Level__c = mulPickListValue;
				break;

			case 'Timezone Region':
				this.profileSkillUserObj.Timezone_Region__c = mulPickListValue;
				break;

			case 'Product':
				this.profileSkillUserObj.Product__c = mulPickListValue;
				break;

			default:
			// code block
        }
        console.log('final result of question'  + JSON.stringify(this.profileSkillUserObj));
	}

}