/*
 * Name			:	GlobalCustomCell
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/4/2021
 * Description	:	Custom Type Link Cell controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/4/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Class body.
export default class GlobalCustomCell extends NavigationMixin(LightningElement) {

	//API variables.
	@api boolIsName;
	@api boolIsEditable;
	@api strColumnLabel;
	@api strTableId;
	@api strFieldType;
	@api strValue;
	@api strRowId;
	@api strRecordLabel;
	@api strRecordObjectAPIName;
	@api strRecordFieldAPIName;
	@api strRecordParentObjectAPIName;
	@api objAdditionalAttributes;
	@api mapIds;
	@api booldisplaycopy;// Display only for specific Parent component
	@api boolShowPreviewIcon;
	@api minRange;
    @api maxRange;
    @api stepRange;
	@api viewMode;
	//@api boolEnableEditFrmParent;
	//Slider Values
	get sliderValueIcon() {
		if(this.strRecordFieldAPIName === 'Score'){
			if(this.strValue === '1'){
				return 'utility:like';
			}
			if(this.strValue === '2'){
				return 'utility:like';
			}
			if(this.strValue === '3'){
				return 'utility:dislike';
			}
		}
	}

	get sliderVariantType(){
		if(this.strRecordFieldAPIName === 'Score'){
			if(this.strValue === '1'){
				return 'success';
			}
			if(this.strValue === '2'){
				return 'warning';
			}
			if(this.strValue === '3'){
				return 'error';
			}
		}
	}

	get sliderClassType() {
		if(this.strRecordFieldAPIName === 'Score'){
			if(this.strValue === '2'){
				return 'rotate-like-icon';
			}
		}
	}

	get displaySliderIcons() {
		return this.maxRange === '3' ? true : false;
	}
	// this is to edit using utilityEdit Icon
	@api 
	get boolEditScreen() {
		return this.getAttribute('boolEditScreen');
	}

	set boolEditScreen(value) {
		if(value) {
			this.boolEditingInProgress = true;
		} else {
			this.boolEditingInProgress = false;
		}
	}

	@api
	get boolEnableEditFrmParent() {
		return this.getAttribute('boolEnableEditFrmParent');
	}

	set boolEnableEditFrmParent(value) {
		if(value) {
			this.boolEditingInProgress = true;
			this.booldisplaycopy = true;
		} else {
			this.boolEditingInProgress = false;
		}
	}

	//Set Values from Parent to child for Text Copy activity
	@api
	get strDisplayValue() {
		return this.getAttribute('strDisplayValue');
	};

	//Copy Functionality Implementation.
	set strDisplayValue(value) {
		if(this.booldisplaycopy) {
		 if(value.rowId && this.strRowId === value.rowId) {
			this.boolHighlightIcon = false;
			this.boolIsDataAvail = true;
			this.previousStrFld1TextLabel = value.fieldAPIFld1_Label;
			} 
		}
	}
	
	

	//Track variables.
	@track lstIcons;

	//pafAssessment
	//@api category;

	//Private variables.
	boolIsURL;
	boolIsIcons;
	boolIsBadges;
	boolIsExpandable;
	boolIsRequired;
	boolIsUndefined;
	boolIsHTML;
	boolIsPicklist;

	//AA Changes
	boolIsText;
	boolIsCopyText;
	boolIsSlider;
	//AA Changes

	boolIsLink;
	boolIsFireEventLink;
	boolIsPlain;
	boolIsCheckboxRowSelection;
	boolIsBoolean;
	boolIsEditableLocal;
	boolIsExpanded = false;
	boolIsChecked = false;
	boolIsStandardField;
	boolIsEditableFieldNameEmpty = true;
	boolIsDisabled = false;
	boolIsRecordLabelEmpty = false;
	boolHasError = false;
	boolEditableFieldIsStandard;
	boolEditableFieldIsPicklist;
	boolInitialLoad = false;
	boolBehaveAsNewRecord = false;
	boolEditingInProgress = false;
	boolDisplayEditIcon = false;
	boolDisplayMoreIcon = false;
	boolRenderAll = true;
	intGlobalAction;
	intPosition;
	strUniqueId = "" + ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c => (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
	strValueEditable;
	strRecordLabelEditable;
	strFinalRecordId;
	strEditableFieldName;
	strSelectedValue;
	objListener;
	objFireEventData;
	objCustomStructure;
	boolIsDataAvail;
	boolHighlightIcon = true;
	previousStrFld1TextValue;
	previousStrFld2TextValue;
	previousStrFld1TextLabel;
	previousStrFld2TextLabel;
	boolnestedParent;
	lstBadges;
	lstPicklistOptions = new Array();
	
	//AA Changes
	//@api parentId;
	//@api superParentId;
	//fieldName;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
		
		//this eenables default edit screen
		/* if(objParent.boolEditScreen) {
			this.boolEditingInProgress = true;
		} */
		//First we make the value manipulable.
		this.strValueEditable = this.strValue;
		this.strSelectedValue = this.strValueEditable;
		this.strRecordLabelEditable = this.strRecordLabel;
		if(objUtilities.isBlank(this.strRecordLabelEditable)) {
			this.boolIsRecordLabelEmpty = true;
		}
		if(objUtilities.isBlank(this.strValueEditable)) {
			this.boolIsUndefined = true;
		} else {
			this.boolIsUndefined = false;
		}
		this.boolIsEditableLocal = this.boolIsEditable;

		if(objUtilities.isNotNull(this.strFieldType) && objUtilities.isNotNull(this.strValue) && objUtilities.isNotNull(this.strRecordObjectAPIName) && this.strRecordObjectAPIName==='User' && this.strValue.startsWith('00G') && this.strFieldType==='link'){
			this.strFieldType = 'text';
			this.strValueEditable = this.strRecordLabel;
		}

		
		//We remove the Edit option, if the cell belongs to a parent record. -- AA
		if(objUtilities.isNotNull(this.objAdditionalAttributes) && objUtilities.isNotNull(this.objAdditionalAttributes.boolIsTreeView) && 
				this.objAdditionalAttributes.boolIsTreeView && (objUtilities.isBlank(this.objAdditionalAttributes.strParentId) || this.objAdditionalAttributes.boolIsChildAParent)) {
					if(this.objAdditionalAttributes.boolIsChildAParent) {
						this.boolnestedParent = this.objAdditionalAttributes.boolIsChildAParent;
					}
				//this.objAdditionalAttributes.boolIsTreeView && (objUtilities.isBlank(this.objAdditionalAttributes.storeMultiLevelParentId) || objUtilities.isBlank(this.objAdditionalAttributes.storeMultiLevelParentId))) {
			this.boolIsEditableLocal = false;
		}

		//If we have additional attributes.
		if(objUtilities.isNotNull(objParent.objAdditionalAttributes)) {

			//We check if the custom Editable Name field is present.
			if(objUtilities.isNotBlank(objParent.objAdditionalAttributes.strEditableFieldName)) {
				objParent.boolIsEditableFieldNameEmpty = false;
				objParent.strEditableFieldName = objParent.objAdditionalAttributes.strEditableFieldName;
	
				//Now we decide the type of field.
				switch(objParent.objAdditionalAttributes.strEditableFieldType) {
					case "standard":
						objParent.boolEditableFieldIsStandard = true;
					break;
					case "picklist":
						objParent.boolEditableFieldIsPicklist = true;
						objParent.lstPicklistOptions = objParent.objAdditionalAttributes.lstPicklistOptions;
						if(objUtilities.isNotBlank(objParent.objAdditionalAttributes.strSelectedValue)) {
							objParent.strSelectedValue = objParent.objAdditionalAttributes.strSelectedValue;
						}
					break;
					case "standarddate":
						objParent.boolEditableFieldIsStandard = true;
						if(objUtilities.isNotBlank(objParent.objAdditionalAttributes.strSelectedValue)) {
							objParent.strSelectedValue = objParent.objAdditionalAttributes.strSelectedValue;
						}
					break;
				}
			}

			//We check if the field must be disabled.
			if(objUtilities.isNotNull(objParent.objAdditionalAttributes.boolIsDisabled)) {
				objParent.boolIsDisabled = objParent.objAdditionalAttributes.boolIsDisabled;
			}
	
			//We save the row position.
			if(objUtilities.isNotBlank(objParent.objAdditionalAttributes.intPosition)) {
				objParent.intPosition = objParent.objAdditionalAttributes.intPosition;
			}
		}

		//Now we set the Record Id.
		if(this.boolIsName) {
			this.strFinalRecordId = this.strRowId;
		} else {
			this.strFinalRecordId = this.strValueEditable;
		}

		//Now we set the listener, to receive the parent messages.
        this.objListener = function (objEvent) {

            //First we make sure the message is for us.
            if(objEvent.data && objEvent.data.strTableId === objParent.strTableId) {
				switch(objEvent.data.intOperation) {

					//Cancel Inline editing.
					case 1:
						objParent.cancelInlineChanges();
					break;
				}
            }
        };
        window.addEventListener("message", this.objListener);
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let boolContinueAdding = true;
		//let boolPreview = true;
		let intCounter = 0;
		let strStyle;
		let objCSSDiv;
		let objParent = this;
		
		//Now we set the custom CSS.
		if(!objParent.boolInitialLoad) {
			objParent.boolInitialLoad = true;

			//Now we decide the field type.
			switch(objParent.strFieldType) {
				case "html":
					objParent.boolIsHTML = true;
					objCSSDiv = objParent.template.querySelector('.htmlContainer');
					if(objUtilities.isNotNull(objCSSDiv)) {
						if(objUtilities.isNotNull(objParent.strValueEditable)) {
							objCSSDiv.innerHTML = objParent.strValueEditable;
						} else {
							objCSSDiv.innerHTML = "";
						}
					}
				break;
				case "link":
					objParent.boolIsLink = true;

					//Now we check if the value is an object.
					if(objUtilities.isObject(objParent.strValueEditable)) {
						objParent.objCustomStructure = objParent.strValueEditable;
						objParent.strValueEditable = objParent.objCustomStructure.strValue;
						objParent.strSelectedValue = objParent.strValueEditable;
						objParent.strRecordLabelEditable = objParent.strValueEditable;
					}
				break;
				case "picklist":
					objParent.boolIsPicklist = true;
				break;
				case "customText":
					objParent.boolIsText = true;
				break;
				case "customCopyText":
					objParent.boolIsCopyText = true;
				break;
				case "slider":
					objParent.boolIsSlider = true;
				break;
				case "fireEvent":
					try {
						if(isNaN(objParent.strValueEditable)) {
							objParent.objFireEventData = JSON.parse(objParent.strValueEditable);
							objParent.strValueEditable = objParent.objFireEventData.strValue;
							objParent.strSelectedValue = objParent.strValueEditable;
							objParent.boolIsFireEventLink = true;
						} else {
							objParent.boolIsPlain = true;
						}
					} catch(objException) {
						objParent.boolIsPlain = true;
					}
				break;
				case "required":
					if(objUtilities.isBlank(objParent.strValue)) {
						objParent.boolIsRequired = true;
					} 
				case "expandable":

					//We display the chevron only if the cell is empty.
					if(objUtilities.isBlank(objParent.strValue)) {
						objParent.boolIsExpandable = true;
					} else if(objUtilities.isNotBlank(objParent.strValue) && objUtilities.isNotNull(objParent.objAdditionalAttributes) && 
							objUtilities.isNotNull(objParent.objAdditionalAttributes.boolDisplayCheckbox)) {

						//Now we display the checkbox, if requested.
						objParent.boolIsCheckboxRowSelection = objParent.objAdditionalAttributes.boolDisplayCheckbox;
					}
				break;
				case "text":
					objParent.boolIsPlain = true;

					//Now we check if the given text is a URL.
					if(objUtilities.isURL(objParent.strValueEditable)) {
						objParent.boolIsURL = true;
					}
				break;
				case "boolean":
					objParent.boolIsBoolean = true;
				break;
				case "badges":
					objParent.boolIsBadges = true;
					objParent.lstBadges = new Array();
					if(objUtilities.isNotNull(objParent.strValueEditable)) {

						//If the value is an array.
						if(Array.isArray(objParent.strValueEditable)) {
							objParent.strValueEditable.forEach(objBadge => {
								if(boolContinueAdding) {
									strStyle = "";
									if(objUtilities.isNotBlank(objBadge.strColor)) {
										strStyle += "background-color: " + objBadge.strColor + "; ";
									}
									if(objUtilities.isNotBlank(objBadge.strStyle)) {
										strStyle += " " + objBadge.strStyle;
									}
									objParent.lstBadges.push({
										strValue: objBadge.strValue,
										strStyle: strStyle,
										strClasses: objBadge.strClasses
									});
									intCounter++;
									objParent.intGlobalAction = objBadge.intAction;
	
									//Now we check the special conditions.
									if(objUtilities.isNotNull(objParent.objAdditionalAttributes)) {

										//Limit.
										if(objUtilities.isNotNull(objParent.objAdditionalAttributes.intListLimit)) {
											if(objParent.objAdditionalAttributes.intListLimit === intCounter) {
												boolContinueAdding = false;
												objParent.boolDisplayMoreIcon = true;
											}
										}
									}
								}
							});
						} else if(typeof objParent.strValueEditable === "object") {

							//If the value is an object.
							strStyle = "";
							if(objUtilities.isNotBlank(objParent.strValueEditable.strColor)) {
								strStyle += "background-color: " + objParent.strValueEditable.strColor + "; ";
							}
							if(objUtilities.isNotBlank(objParent.strValueEditable.strStyle)) {
								strStyle += " " + objParent.strValueEditable.strStyle;
							}
							objParent.lstBadges.push({
								strValue: objParent.strValueEditable.strValue,
								strStyle: strStyle,
								strClasses: objParent.strValueEditable.strClasses
							});
							objParent.intGlobalAction = objParent.strValueEditable.intAction;
						}
					}
				break;
				case "icons":
					objParent.boolIsIcons = true;
					objParent.lstIcons = new Array();
					if(objUtilities.isNotNull(objParent.strValueEditable)) {

						//If the value is an array.
						if(Array.isArray(objParent.strValueEditable)) {
							objParent.strValueEditable.forEach(objIcon => {
								if(boolContinueAdding) {
									objParent.lstIcons.push({
										boolAddSpace: true,
										boolIsStaticResource: objIcon.boolIsStaticResource,
										boolHasSubactions: objIcon.boolHasSubactions,
										boolHasLabel: objUtilities.isNotBlank(objIcon.strLabel),
										intIndex: intCounter,
										intAction: objIcon.intAction,
										intWidth: objIcon.intWidth,
										strIcon: objIcon.strIcon,
										strInverseIcon: objIcon.strInverseIcon,
										strDisplayedIcon: objIcon.strIcon,
										strHelpText: objIcon.strHelpText,
										strLabel: objIcon.strLabel,
										strTitle: objIcon.strTitle,
										strURL: objIcon.strURL,
										strInverseURL: objIcon.strInverseURL,
										strDisplayedURL: objIcon.strURL,
										lstSubactions: objIcon.lstSubactions
									});
									intCounter++;
								}
							});
						} else if(typeof objParent.strValueEditable === "object") {

							//If the value is an object.
							objParent.lstIcons.push({
								boolAddSpace: true,
								boolIsStaticResource: objParent.strValueEditable.boolIsStaticResource,
								boolHasSubactions: objParent.strValueEditable.boolHasSubactions,
								boolHasLabel: objUtilities.isNotBlank(objParent.strValueEditable.strLabel),
								intIndex: intCounter,
								intAction: objParent.strValueEditable.intAction,
								intWidth: objParent.strValueEditable.intWidth,
								strIcon: objParent.strValueEditable.strIcon,
								strInverseIcon: objParent.strValueEditable.strInverseIcon,
								strDisplayedIcon: objParent.strValueEditable.strIcon,
								strHelpText: objParent.strValueEditable.strHelpText,
								strLabel: objParent.strValueEditable.strLabel,
								strURL: objParent.strValueEditable.strURL,
								strInverseURL: objParent.strValueEditable.strInverseURL,
								strDisplayedURL: objParent.strValueEditable.strURL,
								lstSubactions: objParent.strValueEditable.lstSubactions
							});
						}

						//Now we remove the last nbsp.
						if(objParent.lstIcons.length > 0) {
							objParent.lstIcons[objParent.lstIcons.length - 1].boolAddSpace = false;
						}
					}
				break;
			}

			//Now we check if we need to behave as a new record.
			if(objUtilities.isBlank(objParent.strRowId) && objUtilities.isNotNull(objParent.objAdditionalAttributes) && 
					objUtilities.isNotNull(objParent.objAdditionalAttributes.boolBehaveAsNewRecord)) {
				objParent.boolBehaveAsNewRecord = objParent.objAdditionalAttributes.boolBehaveAsNewRecord;

				//We check if the field is required.
				if(objParent.boolBehaveAsNewRecord && objUtilities.isNotNull(objParent.objAdditionalAttributes.boolIsRequired)) {
					objParent.boolIsRequired = objParent.objAdditionalAttributes.boolIsRequired;
				}

				//Now we check the type of field.
				objParent.boolIsStandardField = false;
				objParent.boolIsPicklist = false;
				switch(objParent.objAdditionalAttributes.intFieldType) {

					//Picklist field.
					case 1:
						objParent.boolIsPicklist = true;
						objParent.lstPicklistOptions = objParent.objAdditionalAttributes.lstPicklistOptions;
					break;

					//Standard field.
					case 0:
					default:
						objParent.boolIsStandardField = true;
					break;
				}
			}

			//Now we include the CSS.
			objCSSDiv = objParent.template.querySelector('.customGeneralCSS');
			if(objUtilities.isNotNull(objCSSDiv)) {
				objCSSDiv.innerHTML = "c-global-custom-cell .slds-listbox {" + 
						"	position: fixed !important;" + 
						"	width: auto;" + 
						"} " +
						"c-global-custom-cell .editableCheckbox lightning-helptext, c-global-custom-cell .newRecord lightning-helptext {" +
						"	display: none !important;" + 
						"} c-global-custom-cell [data-has-error=true] .slds-combobox__input, c-global-custom-cell [data-has-error=true] .slds-input, " + 
						"c-global-custom-cell [data-has-error=true] textarea {" +
						"	border-color: red;" + 
						"}";
				
				//If we have custom CSS to apply.
				if(objUtilities.isNotNull(objParent.objAdditionalAttributes) && objUtilities.isNotBlank(objParent.objAdditionalAttributes.lstCSS)) {
					objParent.objAdditionalAttributes.lstCSS.forEach(strCSS => {
						objCSSDiv.innerHTML += " c-global-custom-cell div[data-unique-id='" + objParent.strUniqueId + "'] " + strCSS;
					});
				}

				//We close the tag.
				objCSSDiv.innerHTML = "<style> " + objCSSDiv.innerHTML + " </style>";
			}
		}
	}

    /*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
    disconnectedCallback() {

        //We remove the listener we opened.
        window.removeEventListener("message", this.objListener);
    }

	/*
	 Method Name : previewContent
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	previewContent() {
		this.dispatchEvent(new CustomEvent('previewcontent', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				rowId: this.strRowId
				//fieldAPINameComment: this.strRecordFieldAPIName,xyz[comment,actions]
				//fieldAPINameAction: 
			}
		}));
	}

	/*
	 Method Name : copyContent
	 Description : This method copies the text to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
	copyContent(event) {
		let objInputField = this.template.querySelector('.clipboard');
		this.boolIsDataAvail = false;
		this.boolHighlightIcon = true;
		if(this.template.querySelector('.actionIcon').classList.contains('previewSummary')) {
			this.template.querySelector('.actionIcon').classList.remove('previewSummary');
		}
		if(event.target.dataset.name === 'copyfield1') {
			objInputField.value = this.previousStrFld1TextValue;
			objInputField.select();
			document.execCommand('copy', false, this.previousStrFld1TextValue);
		} 
		
	}

	/*
	 Method Name : closeAction
	 Description : This method is used to close the pop over.
	 Parameters	 : None
	 Return Type : None
	 */
	closeAction() {
		this.boolIsDataAvail = false;
		this.boolHighlightIcon = true;
		if(this.template.querySelector('.actionIcon').classList.contains('previewSummary')) {
			this.template.querySelector('.actionIcon').classList.remove('previewSummary');
		}
	}
	/*
	 Method Name : mouseOver
	 Description : This method catches the Mouse Over event on the link.
	 Parameters	 : None.
	 Return Type : None
	 */
	mouseOver() {
		this.dispatchEvent(new CustomEvent('linkcellmouseover', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				strLinkCellId: this.strFinalRecordId,
				strLinkCellObjectName: this.strRecordObjectAPIName,
				objCoordinates: this.getLinkAbsolutePosition(),
				objCustomStructure: this.objCustomStructure
			}
		}));
	}

	/*
	 Method Name : mouseOut
	 Description : This method catches the Mouse Out event on the link.
	 Parameters	 : None.
	 Return Type : None
	 */
	mouseOut() {
		this.dispatchEvent(new CustomEvent('linkcellmouseout', {
			composed: true,
			bubbles: true,
			cancelable: true,
		}));
	}

	/*
	 Method Name : getLinkAbsolutePosition
	 Description : This method returns the absolute position of the link.
	 Parameters	 : None.
	 Return Type : None
	 */
	getLinkAbsolutePosition() {
		let objPosition = this.template.querySelector("a").getBoundingClientRect();
		let objResult = {
			x: objPosition.left,
			y: objPosition.top
		}
		return objResult;
	}

	cellValueRequired() {
		this.dispatchEvent(new CustomEvent('cellvaluerequired', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: this.boolIsRequired,
		}));
	}

	/*
	 Method Name : openRecord
	 Description : This method opens the record.
	 Parameters	 : None.
	 Return Type : None
	 */
	openRecord() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: this.strFinalRecordId,
				actionName: 'view'
			}
		});
	}

	/*
	 Method Name : mouseOverEdit
	 Description : This method catches the Mouse Over event on the cell.
	 Parameters	 : None.
	 Return Type : None
	 */
	mouseOverEdit() {
		//this.boolDisplayEditIcon = false;
		if(!this.viewMode) {
			this.boolDisplayEditIcon = true;;
		}
	}

	
	/*
	 Method Name : mouseOutEdit
	 Description : This method catches the Mouse Out event on the cell.
	 Parameters	 : None.
	 Return Type : None
	 */
	mouseOutEdit() {

		if(!this.viewMode) {
			this.boolDisplayEditIcon = false;
		}
	}

	/*
	 Method Name : startEditing
	 Description : This method shows the lookup field for inline editing.
	 Parameters	 : None.
	 Return Type : None
	 */
	@api
	startEditing() {
		let objParent = this;
		this.boolEditingInProgress = true;
	// Added for checkMarx Scan fix 
		let dstyle = document.createElement('style');
		dstyle.innerHTML="tr[data-row-key-value='" + objParent.strRowId + "'] td[data-label='" + objParent.strColumnLabel + "'], " + 
		"tr[data-row-key-value='" + objParent.strRowId + "'] th[data-label='" + objParent.strColumnLabel + "'] {" + 
		"	background: var(--lwc-colorBackgroundHighlight,rgb(250, 255, 189));"+
		"}";
		this.template.querySelector('.customInlineCSS').appendChild(dstyle);

		//Commented for Checkmarx scan
		//Now we include the CSS.
	/*	this.template.querySelector('.customInlineCSS').innerHTML = "<style> " + 
				"tr[data-row-key-value='" + objParent.strRowId + "'] td[data-label='" + objParent.strColumnLabel + "'], " + 
				"tr[data-row-key-value='" + objParent.strRowId + "'] th[data-label='" + objParent.strColumnLabel + "'] {" + 
				"	background: var(--lwc-colorBackgroundHighlight,rgb(250, 255, 189));" + 
				"} </style>"; */
	}

	/*
	Method Name : initiateEditing
	Description : This method removes editing.
	Parameters	 : None
	Return Type : None AA Changes not in use
	*/
	initiateEditing(objEvent) {
		this.boolEditingInProgress = false
	}

	/*
	 Method Name : stopEditing
	 Description : This method hides the lookup field for inline editing.
	 Parameters	 : Event, called from stopEditing, objEvent click event.
	 Return Type : None
	 */
	stopEditing(objEvent) {
		let objParent = this;
		//this.hangleRangeChange(objEvent);
		
		this.strValueEditable = objEvent.currentTarget.value;
		objParent.strSelectedValue = objParent.strValueEditable;
		//console.log('typeOf(this.strValueEditable)',typeof this.strValueEditable);
		if(objUtilities.isBlank(this.strValueEditable)) {
			this.boolIsUndefined = true;
		} else {
			this.boolIsUndefined = false;
		}

		
		//Only if there's an actual change on the value, we send the message to the parent.
		if(this.strValueEditable !== this.strValue) {
			this.dispatchEvent(new CustomEvent('customcellchange', {
				composed: true,
				bubbles: true,
				cancelable: true,
				detail: {
					strRecordId: objParent.strRowId,
					strFieldName: objParent.strRecordFieldAPIName,
					//strValue: eventValue
					strValue: objEvent.currentTarget.value
				}
			}));
	
			//If we are seeing a picklist, we return to the read mode.
			if(objParent.boolIsPicklist || objParent.boolEditableFieldIsPicklist) {
				objParent.boolEditingInProgress = false;

				//We update the Label of Editable Field Picklist.
				if(objParent.boolEditableFieldIsPicklist) {
					objParent.lstPicklistOptions.forEach(objPicklistValue => {
						if(objParent.strValueEditable === objPicklistValue.value) {
							objParent.strRecordLabelEditable = objPicklistValue.label;
						}
					});
					objParent.strSelectedValue = objParent.strValueEditable;
					objParent.strValueEditable = objParent.strRecordLabelEditable;
				}
			}

			if(objParent.boolIsText) {
				objParent.boolEditingInProgress = true;
			}
		}

		//We execute also the On Changed method.
		objParent.changed(objEvent);
	}
	

	/*
	 Method Name : cancelInlineChanges
	 Description : This method cleans up the Draft values and cancels the inline editing.
	 Parameters	 : None
	 Return Type : None
	 */
	cancelInlineChanges() {
		this.boolEditingInProgress = false;
		this.template.querySelector('.customInlineCSS').innerHTML = "";
		this.strValueEditable = this.strValue;
		this.strSelectedValue = this.strValueEditable;
		if(objUtilities.isBlank(this.strValueEditable)) {
			this.boolIsUndefined = true;
		} else {
			this.boolIsUndefined = false;
		}
	}

	/*
	 Method Name : fireEvent
	 Description : This method fires an event back to the parent.
	 Parameters	 : None.
	 Return Type : None
	 */
	fireEvent() {
		this.dispatchEvent(new CustomEvent('customcellfiredevent', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: this.objFireEventData
		}));
	}

	/*
	 Method Name : toggleParentRow
	 Description : This method expands / colapses the parent row.
	 Parameters	 : None.
	 Return Type : None
	 */
	@api
	toggleParentRow() {
		let objParent = this;

		//We switch the variable.
		objParent.boolIsExpanded = !objParent.boolIsExpanded;

		//Now we ask the parent show/hide the child rows.
		objParent.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: false,
			cancelable: true,
			detail: {
				objEvent: {
					target: {
						dataset: {
							action: "12",
							target: objParent.strRowId,
							expanded: objParent.boolIsExpanded
						}
					}
				}
			}
		}));
	}

	/*
	 Method Name : sendEventToParent
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from sendEventToParent, objEvent Event.
	 Return Type : None
	 */
	sendEventToParent(objEvent) {
		let intAction;
		let objParent = this;
		if(objUtilities.isNull(objEvent.currentTarget.dataset.action)) {
			intAction = parseInt(objEvent.detail.value);
		} else {
			intAction = parseInt(objEvent.currentTarget.dataset.action);
		}
		this.dispatchEvent(new CustomEvent('sendeventtoparent', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				strRecordId: objEvent.currentTarget.dataset.recordId,
				intAction: intAction,
				objAdditionalAttributes: {
					... objParent.objAdditionalAttributes,
					intPosition: objParent.intPosition
				}
			}
		}));

		//Finally, we switch icons, if needed.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.index) && objUtilities.isNotNull(objParent.lstIcons)) {
			objParent.lstIcons.forEach(objIcon => {
				if((objIcon.intIndex + "") === objEvent.currentTarget.dataset.index) {
					if(objIcon.boolIsStaticResource && objUtilities.isNotBlank(objIcon.strInverseURL)) {
						if(objEvent.currentTarget.dataset.currentValue === objIcon.strURL) {
							objIcon.strDisplayedURL = objIcon.strInverseURL;
						} else {
							objIcon.strDisplayedURL = objIcon.strURL;
						}
					} else if(!objIcon.boolIsStaticResource && objUtilities.isNotBlank(objIcon.strInverseIcon)) {
						if(objEvent.currentTarget.dataset.currentValue === objIcon.strIcon) {
							objIcon.strDisplayedIcon = objIcon.strInverseIcon;
						} else {
							objIcon.strDisplayedIcon = objIcon.strIcon;
						}
					}
				}
			});
		}
	}

	/*
	 Method Name : changeRowSelection
	 Description : This method sends to the parent the row selection/unselection.
	 Parameters	 : Event, called from changeRowSelection, objEvent click event.
	 Return Type : None
	 */
	changeRowSelection(objEvent) {
		let objParent = this;
		objParent.boolIsChecked = objEvent.target.checked;
		objParent.dispatchEvent(new CustomEvent('customrowselection', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				boolIsSelected: objEvent.target.checked,
				strRecordId: objParent.strRowId
			}
		}));
	}

	/*
	 Method Name : getRowExpandedCollapsed
	 Description : This method expandes or collapses rows on a tree-view layout.
	 Parameters	 : Boolean, called from getRowExpandedCollapsed, boolShouldExpand If TRUE, the rows gets expanded, if FALSE, the row gets collapsed, if NULL, the rows toggles.
	 Return Type : None
	 */
	@api
	getRowExpandedCollapsed(boolShouldExpand) {
		this.boolIsExpanded = !boolShouldExpand;
		this.toggleParentRow();
	}

	/*
	 Method Name : isChecked
	 Description : This method returns if the current cell is checked and the row id.
	 Parameters	 : None
	 Return Type : Boolean
	 */
	@api
	isChecked() {
		return {
			boolIsSelected: this.boolIsChecked,
			strRecordId: this.strRowId
		};
	}

	/*
	 Method Name : updateCheckboxSelection
	 Description : This method checks / unchecks the row selection checkbox.
	 Parameters	 : Boolean, called from updateCheckboxSelection, boolIsChecked If TRUE, the checkbox gets checked, otherwise it gets unchecked.
	 Return Type : None
	 */
	@api
	updateCheckboxSelection(boolIsChecked) {
		this.boolIsChecked = boolIsChecked;
		this.template.querySelectorAll('.checkboxRowSelection').forEach(objCheckbox => {
			objCheckbox.checked = boolIsChecked;
		});
	}

	/*
	 Method Name : updateToggleIcons
	 Description : This method changes the image source of the icons to either the Default one or the Inverse one.
	 Parameters	 : Boolean, called from updateToggleIcons, boolDefaultSource If TRUE, the source is the default one, otherwise Inverse one.
	 Return Type : None
	 */
	@api
	updateToggleIcons(boolDefaultSource) {
		if(objUtilities.isNotNull(this.lstIcons)) {
			this.lstIcons.forEach(objIcon => {
				if(objIcon.boolIsStaticResource && objUtilities.isNotBlank(objIcon.strInverseURL)) {
					if(boolDefaultSource) {
						objIcon.strDisplayedURL = objIcon.strURL;
					} else {
						objIcon.strDisplayedURL = objIcon.strInverseURL;
					}
				} else if(!objIcon.boolIsStaticResource && objUtilities.isNotBlank(objIcon.strInverseIcon)) {
					if(boolDefaultSource) {
						objIcon.strDisplayedIcon = objIcon.strIcon;
					} else {
						objIcon.strDisplayedIcon = objIcon.strInverseIcon;
					}
				}
			});
		}
	}

	/*
	 Method Name : expandParentRow
	 Description : This method expands / colapses the parent row.
	 Parameters	 : None.
	 Return Type : None
	 */
	@api
	expandParentRow() {
		let objParent = this;

		//We switch the variable.
		objParent.boolIsExpanded = true;

		//Now we ask the parent show/hide the child rows.
		objParent.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: false,
			cancelable: true,
			detail: {
				objEvent: {
					target: {
						dataset: {
							action: "12",
							target: objParent.strRowId,
							expanded: objParent.boolIsExpanded
						}
					}
				}
			}
		}));
	}

	/*
	 Method Name : collapseParentRow
	 Description : This method expands / colapses the parent row.
	 Parameters	 : None.
	 Return Type : None
	 */
	@api
	collapseParentRow() {
		let objParent = this;

		//We switch the variable.
		objParent.boolIsExpanded = false;

		//Now we ask the parent show/hide the child rows.
		objParent.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: false,
			cancelable: true,
			detail: {
				objEvent: {
					target: {
						dataset: {
							action: "12",
							target: objParent.strRowId,
							expanded: objParent.boolIsExpanded
						}
					}
				}
			}
		}));
	}

	/*
	 Method Name : collapseParentRow
	 Description : This method expands / colapses the parent row.
	 Parameters	 : None.
	 Return Type : None
	 */
	@api
	setIsExpanded(boolIsExpanded) {
		this.boolIsExpanded = boolIsExpanded;
	}

	/*
	 Method Name : validate
	 Description : This method validates the current field.
	 Parameters	 : None.
	 Return Type : Boolean
	 */
	@api
	validate() {
		let boolResult = true;
		if(this.boolBehaveAsNewRecord) {
			boolResult = [ ...this.template.querySelectorAll(".validate")].reduce((boolValidSoFar, objField) => {
				return (boolValidSoFar && objField.reportValidity());
			}, true);
		}
		return boolResult;
	}

	/*
	 Method Name : getValueNewRecord
	 Description : This method returns the input field value.
	 Parameters	 : None.
	 Return Type : Object
	 */
	@api
	getValueNewRecord() {
		let strFieldName;
		let objResult = new Object();

		//We look for the API Name.
		if(objUtilities.isNotBlank(this.strEditableFieldName)) {
			strFieldName = this.strEditableFieldName;
		} else {
			strFieldName = this.strRecordFieldAPIName;
		}

		//We save the value.
		if(objUtilities.isNotBlank(strFieldName)) {
			objResult[strFieldName] = this.template.querySelector(".newRecord").value;
		}
		return objResult;
	}

	/*
	 Method Name : getValue
	 Description : This method returns the current value.
	 Parameters	 : None.
	 Return Type : Object
	 */
	@api
	getValue() {
		return this.strValueEditable;
	}

	/*
	 Method Name : isNewRecord
	 Description : This method returns if the current cells belongs to a New record.
	 Parameters	 : None.
	 Return Type : Boolean
	 */
	@api
	isNewRecord() {
		return this.boolBehaveAsNewRecord;
	}

	/*
	 Method Name : getValueInlineUpdatedRecord
	 Description : This method returns the input field value.
	 Parameters	 : None.
	 Return Type : Object
	 */
	@api
	getValueInlineUpdatedRecord() {
		let strFieldName;
		let objResult = new Object();
		let objParent = this;

		//We look for the API Name.
		if(objUtilities.isNotBlank(objParent.strEditableFieldName)) {
			strFieldName = objParent.strEditableFieldName;
		} else {
			strFieldName = objParent.strRecordFieldAPIName;
		}

		//We save the value.
		if(objUtilities.isNotBlank(strFieldName)) {
			if(objParent.boolEditableFieldIsPicklist) {
				objResult[strFieldName] = {
					value: objParent.strSelectedValue,
					label: objParent.strValueEditable
				}
			} else {
				objResult[strFieldName] = objParent.strValueEditable;
			}
		}
		return objResult;
	}

	/*
	 Method Name : updatePosition
	 Description : This method updates the row position.
	 Parameters	 : Integer, called from updatePosition, intPosition New Position.
	 Return Type : None.
	 */
	@api
	updatePosition(intPosition) {
		this.intPosition = intPosition;
	}

	/*
	 Method Name : setFocus
	 Description : This method sets the focus to the field.
	 Parameters	 : None.
	 Return Type : None.
	 */
	@api
	setFocus() {
		this.template.querySelectorAll("lightning-input-field").forEach(objElement => {
			objElement.focus();
		});
	}

	/*
	 Method Name : getFieldAPIName
	 Description : This method returns the field API Name.
	 Parameters	 : None.
	 Return Type : None.
	 */
	@api
	getFieldAPIName() {
		return this.strRecordFieldAPIName;
	}

	/*
	 Method Name : setFieldValue
	 Description : This method sets the field value.
	 Parameters	 : Object, called from setFieldValue, objValue Value.
	 Return Type : None.
	 */
	@api
	setFieldValue(objValue) {
		let objParent = this;

		//We set the value.
		objParent.strValue = objValue;
		objParent.strValueEditable = objValue;
		objParent.strSelectedValue = objParent.strValueEditable;

		//If the field is editable, we activate it.
		if(objParent.boolIsEditable) {
			objParent.startEditing();
		}

		//Now we rerender the field.
		objParent.boolRenderAll = false;
		setTimeout(() => {
			objParent.boolRenderAll = true;
		}, 10);
	}

	/*
	 Method Name : setFieldDisabled
	 Description : This method sets the field value.
	 Parameters	 : Object, called from setFieldDisabled, boolIsDisabled If TRUE the field will be disabled.
	 Return Type : None.
	 */
	@api
	setFieldDisabled(boolIsDisabled) {
		this.boolIsDisabled = boolIsDisabled;
	}

	/*
	 Method Name : setFieldError
	 Description : This method sets the field value.
	 Parameters	 : Object, called from setFieldError, boolHasError If TRUE the field will be highlighted with red.
	 Return Type : None.
	 */
	@api
	setFieldError(boolHasError) {
		this.boolHasError = boolHasError;
	}

	/*
	 Method Name : keyDown
	 Description : This method gets executed on Key Down.
	 Parameters	 : Object, called from keyDown, objEvent Event.
	 Return Type : None.
	 */
	keyDown(objEvent) {
		let intKeyCode = objEvent.keyCode ? objEvent.keyCode : objEvent.which ? objEvent.which : objEvent.charCode;
		let objParent = this;
		if(intKeyCode === 13 && objUtilities.isNotNull(objParent.objAdditionalAttributes) && objUtilities.isNotNull(objParent.objAdditionalAttributes.boolPreventEnter) && 
					objParent.objAdditionalAttributes.boolPreventEnter) {
			objEvent.preventDefault();
		}

		//Now we alert the parent about the key down.
		objParent.dispatchEvent(new CustomEvent('customcellkeydown', {
			composed: true,
			bubbles: false,
			cancelable: true,
			detail: {
				intKeyCode: intKeyCode,
				intPosition: objParent.intPosition,
				strFieldAPIName: objParent.strRecordFieldAPIName,
				strRowId: objParent.strRowId
			}
		}));
	}

	/*
	 Method Name : changed
	 Description : This method sends to the parent the notification that a field has changed.
	 Parameters	 : Object, called from changed, objEvent Event.
	 Return Type : None.
	 */
	changed(objEvent) {
		this.setFieldError(false);
		this.dispatchEvent(new CustomEvent('customcellchanged', {
			composed: true,
			bubbles: false,
			cancelable: true,
			detail: {
				intPosition: this.intPosition,
				strFieldAPIName: this.strRecordFieldAPIName,
				strRowId: this.strRowId,
				objValue: objEvent.currentTarget.value
			}
		}));
	}	
}