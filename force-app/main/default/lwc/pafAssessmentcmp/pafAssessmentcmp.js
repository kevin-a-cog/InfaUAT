//Core imports.
import { LightningElement, api } from 'lwc';

//Apex Controllers.
import getPAFData from '@salesforce/apex/RiskAssessmentController.generatePAFRecordData';
import copyData from '@salesforce/apex/RiskAssessmentController.getParentRecValues';
import dataGovESLlines from '@salesforce/apex/RiskAssessmentController.getEstimatorRec';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { loadStyle } from "lightning/platformResourceLoader";
import hideSlidercss from "@salesforce/resourceUrl/HideSliderLabel";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PFAAssessmentComponent extends LightningElement {


	//Private variables
    error;
    boolDisplaySpinner;
    showModal;
	boolExpandAll=false;
	payloadData;
	boolshowDT = true;
	copyObjParameters;
	currentObjectName;
	fieldAPINameValue = {};
	boolshowCopyBtn;
	boolShowPreviewIcon = false;
	boolisPageLoad = true;
	//AdoptionFactor
	boolEnableEditing = false;
	isDataAvailble = false;

	_journey;
	_boolprimaryEstimator;
	_parentid;
	_loadnewform;

    @api boolHideActions;
    @api isPoppedOut = false;
	@api boolIsEditable;
	@api boolHasRecords;
	@api planid;
	@api boolclonedisplay;
	@api booldisplaycopy;
	@api boolEnableEditFrmParent;
	@api viewMode;

	@api 
	get journey(){
		return this._journey;
	}

	set journey(value){
		this._journey = value;
		this.isDataAvailble = false;
		
		if(value !== undefined && this._parentid !== undefined && this._boolprimaryEstimator !== undefined){
			this.loadRecords();
		} else if(this._loadnewform && value !== undefined && this._boolprimaryEstimator !== undefined) {
			this.loadRecords();
		}
	}

	@api 
	get parentid() {
		return this._parentid;
	}
	set parentid(value){
		this._parentid = value;
		if(this.value !== undefined && this._boolprimaryEstimator !== undefined && this._journey !== undefined){
			this.loadRecords();
		}
	}
	@api 
	get boolprimaryEstimator(){
		return this._boolprimaryEstimator;
	}

	set boolprimaryEstimator(value) {
		
		this._boolprimaryEstimator = value;
		if(this._journey !== undefined && this._parentid !== undefined) {
			this.loadRecords();
		} else if(this._loadnewform && value !== undefined && this._journey !== undefined ) {
			
			this.loadRecords();
		}
		console.log('this.boolprimaryEstimator 1',value);
	}

	//Load new form without checking for ESL Lines or Parent id
	@api 
	get loadnewform(){
		return this._loadnewform;
	}

	set loadnewform(value) {
		this._loadnewform = value;
		if(this._loadnewform && this._journey !== undefined && this._boolprimaryEstimator !== undefined) {
			this.loadRecords();
		}
	}
    //@api enableEditingScreen;

	
	//Connected Callback
    connectedCallback() {
		
        let objParent = this;
        this.boolDisplaySpinner = true;
        this.showModal = true;
		loadStyle(
			this,
			hideSlidercss
		).then(() => {
			console.log('style loaded successfully');
		}).catch((error) => {
			console.log('error', 'Method : loadStyle - loadStyle; Error :' + error.message + " : " + error.stack);
		});	
	}  

	// This is for Copy Prior button functionality for Adoptin factor level Implementation
	renderedCallback() {
		if(this.boolclonedisplay){
			//if(this.booldisplaycopy){
				copyData({parentId: this._parentid, planId: this.planid })
				.then((objResult) => {
					console.log('objResult',JSON.stringify(objResult));
					if(objResult){
						this.boolshowCopyBtn = true;
						this.boolShowPreviewIcon = true;
					}
					
				}).catch((error) => {
					console.log('check Error in copyAllValues',error);
				})
			}
	}
	

    /*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */

	loadRecords() {
		console.log('recordId ---123 load record',this._parentid);
		console.log('boolprimaryEstimator 2',this._boolprimaryEstimator);
        let objParent = this;
		let nestedParentIds = [];
		getPAFData({parentId: this._parentid, planId: this.planid})
        .then((objResult) => {

            objParent.objParameters.lstRecords = objResult.lstRecordsCustomStructure;
			objParent.objParameters.mapParentChildRelationship = objResult.mapParentChildRelationship;
			console.log('objParent.objParameters.lstRecords',objParent.objParameters.lstRecords);
			Object.keys(objResult.mapParentChildRelationship).forEach(item=>{
				Object.values(objResult.mapParentChildRelationship).forEach(parent=>{
					if(item === parent){
						nestedParentIds.push(parent);
					}
				})
			})
			
			let filterArea = [];
			let subCategoryIds = [];
			objResult.lstRecordsCustomStructure.forEach(areaRec => {				
				if(!areaRec.ipuServices) {
					filterArea.push(areaRec);
				} else if(this._journey && areaRec.ipuServices.includes(this._journey)) {
					subCategoryIds.push(areaRec.SubCategoryId);
					filterArea.push(areaRec);
					this.isDataAvailble = true;
				}

				if(this._journey === null) {
					if(this._boolprimaryEstimator) {
						if(areaRec.ipuServices === 'Data Governance and Privacy') {
							subCategoryIds.push(areaRec.SubCategoryId);
							this.isDataAvailble = true;
							filterArea.push(areaRec);
						} 
					} 
				} else if(this._boolprimaryEstimator && this._journey !== undefined && !this._journey.includes('Data Governance')){
					if(areaRec.ipuServices === 'Data Governance and Privacy') {
						subCategoryIds.push(areaRec.SubCategoryId);
						this.isDataAvailble = true;
						filterArea.push(areaRec);
					}
				}
			});

			//to get only Category(s) with childs or Parent with childs
			let parents = [];
			filterArea.forEach(ParentwithNochilds => {
				if(nestedParentIds.includes(ParentwithNochilds.Id)) {
						parents.push(ParentwithNochilds.categoryParentId);
				}
			});
			this.dispatchEvent(new CustomEvent('viewcompfiredevent', {
				composed: true,
				bubbles: true,
				cancelable: true,
				detail: this.isDataAvailble 
			}));
			let allData = [];
			filterArea.forEach(filterRec => {
				if(filterRec.isSecondLevelParent) {
					if(nestedParentIds.includes(filterRec.Id) && subCategoryIds.includes(filterRec.Id)) {
						allData.push(filterRec);
					}
				} else if(filterRec.ipuServices){
					allData.push(filterRec);
				} else if(parents.includes(filterRec.Id)) {
					allData.push(filterRec);
				}
			});

			//console.log('objParent.objParameters.allData[i].Score',allData);
            //allData = JSON.parse(JSON.stringify(filterArea));
            for(let i  = 0; i <  allData.length; i++) {
				allData[i].Text_Area_Comment__c = allData[i].Comment;
				if(allData[i].Score === 'HIGH') {
					allData[i].Score = '3';
				} 
				if(allData[i].Score === 'MEDIUM') {
					allData[i].Score = '2';
				}
				if(allData[i].Score === 'LOW') {
					allData[i].Score = '1';
				}
            }

						
			/* if(objUtilities.isNull(objParent.boolHideActions) || objUtilities.isBlank(objParent.boolHideActions) || objParent.boolHideActions.toLowerCase() === "false" || !objParent.boolHideActions) {
				objParent.objParameters.lstColumns.push({
					label: "Actions",
					fieldName: "lstActions",
					strFieldName: "lstActions",
					type: "custom",
					typeAttributes: {
						subtype: "icons"
					}
				});
			} */

			objParent.objParameters.lstRecords = allData;
			
			objParent.objParameters = JSON.parse(JSON.stringify(objParent.objParameters));
			console.log('Loadrecord end',objParent.objParameters.lstRecords);
			
        })
        .catch((error) => {
            console.log('check Error in pafAssessmentcmp Connectedcallback',error);
        }).finally(() => {
			//Finally, we hide the spinner.
			this.boolDisplaySpinner = false;
		});
	}
	
	
	//GDT Table
    objParameters = {
		boolEnableTreeView: true,
		boolDisplayActions: true,
		boolDisplayTableActions: true,
		boolDisplayTableActionsCustom: true,
		boolDisplayPaginator: false,
		boolEnablePopOver: false,
		boolHideCheckboxColumn: true,
		strTableId: "1",
		strTableClass: "RiskAssessmentTable2",
		lstColumnsSpecificConfigurations: {
            1: [
				{
					fieldName: "Green",
					label: "GREEN (1 POINTS)",
					strFieldName: "Green",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "Green"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "Yellow",
					label: "YELLOW (2 POINTS)",
					strFieldName: "Yellow",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "Yellow"
						},
						subtype: "text"
					}
				},
				{
					fieldName: "Red",
					label: "RED (3 POINTS)",
					strFieldName: "Red",
					subtype: "text",
					type: "text",
					typeAttributes: {
						label: {
							fieldName: "Red"
						},
						subtype: "text"
					}
				}
            ]
        },
        lstColumns: [
            {
				fieldName: "Area",
				label: "Area",
				fixedWidth: 400,
				strFieldName: "Area",
				type: "text",
				typeAttributes: {
					label: {
						fieldName: "Area"
					},
					subtype: "text",
				}
			},
		    {
				fieldName: "Score",
				label: "Score",
				fixedWidth: 200,
				strFieldName: "Score",
				subtype: "slider",
				type: "custom",
				required: true,
				typeAttributes: {
					label: {
						fieldName: "Score"
					},
					subtype: "slider",
					editable: true
				}
			},
			{
				fieldName: "Text_Area_Comment__c",
				label: "Comment",
				fixedWidth: 400,
				strFieldName: "Text_Area_Comment__c",
				strParentObject: "Risk_Assessment__c",
				type: "custom",
				subtype: "customText",
				required: true,
				typeAttributes: {
					label: {
						fieldName: "Text_Area_Comment__c"
					},
					subtype: "customText",
					editable: true,
				}
			},
			/* {
				fieldName: "Text_Area_Action__c",
				label: "Recommended Action",
				//fixedWidth: 400,
				strFieldName: "Text_Area_Action__c",
				strParentObject: "Risk_Assessment__c",
				subtype: "customText",
				type: "custom",
				typeAttributes: {
					label: {
						fieldName: "Text_Area_Action__c"
					},
					subtype: "customText",
					editable: true,
				}
			}, */
			{
				label: "Actions",
				fieldName: "lstActions",
				strFieldName: "lstActions",
				fixedWidth: 100,
				type: "custom",
				typeAttributes: {
					subtype: "icons"
				}
			}
        ],
        lstCustomCSS: [
			{
				strSelector: "lightning-button-menu lightning-primitive-icon:last-of-type",
				strCSS: "display: none;"
			},
			{
				strSelector: "lightning-button-menu button.slds-button",
				strCSS: "border-width: 0px; background-color: transparent;"
			}
		]
    }

    /*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {

		if(objEvent.detail.detail) {
			
			let { intAction, strRecordId, objAdditionalAttributes} = objEvent.detail.detail;
			//this.strSelectedRecord = strRecordId;

			switch(parseInt(intAction)) {
				case 1:

					//The user wants to open/close the details section of the selected row.
					this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
						objTable.getAdditionalInformationExpandedCollapsed(objAdditionalAttributes);
					});
				break;
			}
		} else if (objEvent.detail.intAction === 3) {
			let { intAction, objPayload } = objEvent.detail;	
			let mdtIds = [];
			let storeCommentIds = [];

			this.objParameters.lstRecords.forEach(areaRec => {

				if(areaRec.ipuServices) {
					//mdtIds.push(areaRec.Id);
					if(!areaRec.Comment) {
						storeCommentIds.push(areaRec.Id);
					}
				}
			});
			let objpayLoadIds =[];
			if(objPayload) {
				objPayload.forEach(payLoad => {
					if(payLoad.Text_Area_Comment__c) {
						objpayLoadIds.push(payLoad.Id);
					}  else if(payLoad.Text_Area_Comment__c !== undefined && payLoad.Text_Area_Comment__c === ''){
						mdtIds.push(payLoad.Id);
					} 
				});
			}
			let checkforEmptyFields;
			console.log('mdtIds',mdtIds);
			if(storeCommentIds.length != 0){
				storeCommentIds.forEach(commentId => {
					if(!objpayLoadIds.includes(commentId)) {
						mdtIds.push(commentId);
					}
				});
			}
			console.log('mdtIds2',mdtIds);
			if(mdtIds.length !== 0) {
				checkforEmptyFields = true;
				/* const event = new ShowToastEvent({
					title: 'Error!',
					message: 'Please fill all the fields on Risk Assessment Form',
					variant: 'error',
				});
				this.dispatchEvent(event); */
				
			} else {
				checkforEmptyFields = false;
			}
			let modifiedPayLoadLst = [];		
			let outputValue;
			//Manipulate slider values based on category
			if(objPayload) {
				objPayload.forEach(sliderValue => {
					this.objParameters.lstRecords.forEach(recData => {
						if (sliderValue.Id === recData.Id) {
							if(sliderValue.Score){
								outputValue = this.getSliderRangeValue(sliderValue.Score, recData.Category);
								sliderValue.Score = outputValue;
							} /* else if (!recData.Score) {
								outputValue = this.getSliderRangeValue('1', recData.Category);
								sliderValue.Score = outputValue;
							} */
							
							console.log('outputValue',outputValue);
						}
					});
				});
			}

			//populate Copy Prior button values functionality
			if(!this.boolshowDT) {
				this.objParameters.lstRecords.forEach(cloneData => {
					
					if (!objPayload) {
						console.log('2nd if',cloneData);
						modifiedPayLoadLst.push({Id:cloneData.Id,Score:cloneData.Score,Text_Area_Comment__c:cloneData.Text_Area_Comment__c});
					} else {
						objPayload.forEach(item => {

							let obj = {Id:cloneData.Id,Score:cloneData.Score,Text_Area_Comment__c:cloneData.Text_Area_Comment__c};
							if(cloneData.Id == item.Id) {
								if (item.Score) {
									obj.Score = item.Score;
								} if (item.Text_Area_Comment__c) {
									obj.Text_Area_Comment__c = item.Text_Area_Comment__c;
								} /* if(item.Text_Area_Action__c) {
									obj.Text_Area_Action__c = item.Text_Area_Action__c;
								} */
								modifiedPayLoadLst.push(obj);
							} else {
								modifiedPayLoadLst.push(obj);
							}
						});
					}
				});
	
				objPayload = modifiedPayLoadLst;
			}
			console.log('objPayload 650****',JSON.stringify(objPayload))
			//Custom Event to access save from Parent component
			const submitEvent = new CustomEvent('dealsubmit', {
				bubbles: true,
				composed: true,
				detail: {payloadData: objPayload, checkdata: checkforEmptyFields}
			});
			
			this.dispatchEvent(submitEvent);
		//}

		}
    }


	/*
	 Method Name : getSliderRangeValue
	 Description : This method assigns values based on the slider selection.
	 Parameters	 : strValueEditable stores values selected on UI.
	 Return Type : strValue value to store in database.
	 */

	getSliderRangeValue(strValueEditable, strRowCategory) {

		//event.preventDefault();
		var strValue = '';
		if(strRowCategory === 'STRATEGIC') {	
			if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '1'){
				strValue = '1';
			} else if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '2'){
				strValue = '2';
			} else if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '3'){
				strValue = '3';
			} else {
				strValue = '1';
			}
		} else if(strRowCategory === 'IMPLEMENTATION') {
			if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '1'){
				strValue = 'LOW';
			} else if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '2'){
				strValue = 'MEDIUM';
			} else if(objUtilities.isNotNull(strValueEditable) && strValueEditable == '3'){
				strValue = 'HIGH';
			} else {
				strValue = 'LOW';
			}
		}
		return strValue;
	}


	/*
	 Method Name : copyAllValues
	 Description : This gets all the values from Parent
	 Parameters	 : None
	 Return Type : None
	 */
	copyAllValues() {
		let objParent = this;
		copyData({parentId: this._parentid, planId: this.planid })
        .then((objResult) => {
			this.boolshowDT= false;
			console.log('entering',objResult.lstRecordsCustomStructure);
			objParent.objParameters.lstRecords = objResult.lstRecordsCustomStructure;

			let filterArea = [];
			objResult.lstRecordsCustomStructure.forEach(areaRec => {
			
				if(!areaRec.ipuServices) {
					
					filterArea.push(areaRec);
				} else if(areaRec.ipuServices.includes(this._journey)){
					filterArea.push(areaRec);
				}

				if(this._boolprimaryEstimator && !this._journey.includes('Data Governance')) {
					if(areaRec.ipuServices.includes('Data Governance')){
						filterArea.push(areaRec);
					}
				}
			});

			let allData = JSON.parse(JSON.stringify(filterArea));
			console.log('alldata --- 509',allData);
            for(let i  = 0; i <  allData.length; i++) {
				allData[i].Text_Area_Comment__c = allData[i].Comment;
				allData[i].Text_Area_Action__c = allData[i].Action;
				if(allData[i].Score === 'HIGH') {
					allData[i].Score = '3';
				} 
				if(allData[i].Score === 'MEDIUM') {
					allData[i].Score = '2';
				}
				if(allData[i].Score === 'LOW') {
					allData[i].Score = '1';
				}
            }
			objParent.objParameters.lstRecords = allData;
			objParent.copyObjParameters = Object.assign({},this.objParameters);
			//objParent.copyObjParameters = Object.assign({},this.objParameters);
		}).catch((error) => {
            console.log('check Error in copyAllValues',error);
        })
	}

	/*
	 Method Name : prevRecData
	 Description : This method returns the row level data to the child component.
	 Parameters	 : event
	 Return Type : object
	 */
	prevRecData(event) {
		copyData({parentId: this._parentid, planId: this.planid}) 
		.then((objResult) => {
			if(objResult){
				objResult.lstRecordsCustomStructure.forEach(lineItem => {
					 if(lineItem.Id === event.detail.rowId) {
						this.fieldAPINameValue = {rowId:event.detail.rowId, fieldAPIFld1_Label: 'Comment', fieldAPIFld1Value: lineItem.Comment};
					}
				})
			}

		}).catch((error) => {
            console.log('check Error in copyAllValues',error);
        })
	}
    /*
	 Method Name : handletoggleCollapse
	 Description : This method Expands All/Collapses All the child rows and detail records.
	 Parameters	 : None
	 Return Type : None
	 */
	handletoggleCollapse(){
		if(this.boolExpandAll){
			this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
				objTable.getAllRowsExpandedCollapsed(false);
			});
			this.boolExpandAll=false;
		}
		else{
			this.template.querySelectorAll("c-global-data-table").forEach(objTable => {
				objTable.getAllRowsExpandedCollapsed(true);
			});
			this.boolExpandAll=true;
		}
	}

	handleenableEdit() {
		this.boolEnableEditing = true;
	}

	handleenableClose() {
		this.boolEnableEditing = false;
	}
}