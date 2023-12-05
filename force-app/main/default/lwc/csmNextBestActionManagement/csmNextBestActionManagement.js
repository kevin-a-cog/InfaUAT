/*
 * Name			:	CsmNextBestActionManagement
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Next Best Action Management Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getSObjects from "@salesforce/apex/CSMNextBestActionManagementController.getSObjects";
import getRelatedFields from "@salesforce/apex/CSMNextBestActionManagementController.getRelatedFields";
import getActions from "@salesforce/apex/CSMNextBestActionManagementController.getActions";
import getRecordCreated from "@salesforce/apex/CSMNextBestActionManagementController.getRecordCreated";
import getFormulaVerified from "@salesforce/apex/GlobalNextBestActionController.getFormulaVerified";
import getQueryVerified from "@salesforce/apex/GlobalNextBestActionController.getQueryVerified";
import getLogicEvaluated from "@salesforce/apex/GlobalNextBestActionController.getLogicEvaluated";

//Custom Labels.
import Step_1 from '@salesforce/label/c.Step_1';
import Recommendation from '@salesforce/label/c.Recommendation';
import Object_Label from '@salesforce/label/c.Object_Label';
import Recurrence from '@salesforce/label/c.Recurrence';
import Interval from '@salesforce/label/c.Interval';
import Step_2 from '@salesforce/label/c.Step_2';
import Formula from '@salesforce/label/c.Formula';
import Comparison from '@salesforce/label/c.Comparison';
import Operator from '@salesforce/label/c.Operator';
import Values from '@salesforce/label/c.Values';
import Review from '@salesforce/label/c.Review';
import First_Field from '@salesforce/label/c.First_Field';
import Field_Type from '@salesforce/label/c.Field_Type';
import Value from '@salesforce/label/c.Value';
import Second_Field from '@salesforce/label/c.Second_Field';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import Copy_To_Clipboard from '@salesforce/label/c.Copy_To_Clipboard';
import Insert from '@salesforce/label/c.Insert';
import Logic from '@salesforce/label/c.Logic';
import AND from '@salesforce/label/c.AND';
import OR from '@salesforce/label/c.OR';
import NOT from '@salesforce/label/c.NOT';
import SOQL from '@salesforce/label/c.SOQL';
import Insert_Record_Id_Clause from '@salesforce/label/c.Insert_Record_Id_Clause';
import Query from '@salesforce/label/c.Query';
import Threshold_Criteria from '@salesforce/label/c.Threshold_Criteria';
import Threshold from '@salesforce/label/c.Threshold';
import Multiple_SOQL from '@salesforce/label/c.Multiple_SOQL';
import Queries from '@salesforce/label/c.Queries';
import Step_3 from '@salesforce/label/c.Step_3';
import Accept from '@salesforce/label/c.Accept';
import Reject from '@salesforce/label/c.Reject';
import Save from '@salesforce/label/c.Save';
import Verify from '@salesforce/label/c.Verify';
import Verifying from '@salesforce/label/c.Verifying';
import No_Issues from '@salesforce/label/c.No_Issues';
import Invalid_formula from '@salesforce/label/c.Invalid_formula';
import Select_Object from '@salesforce/label/c.Select_Object';
import Invalid_Logic from '@salesforce/label/c.Invalid_Logic';
import Invalid_Query from '@salesforce/label/c.Invalid_Query';
import Provide_Query_And_Threshold from '@salesforce/label/c.Provide_Query_And_Threshold';
import Provide_Formula from '@salesforce/label/c.Provide_Formula';
import Provide_Threshold from '@salesforce/label/c.Provide_Threshold';
import Provide_Query from '@salesforce/label/c.Provide_Query';
import Provide_Logic from '@salesforce/label/c.Provide_Logic';
import Provide_Interval from '@salesforce/label/c.Provide_Interval';
import Provide_Recommendation from '@salesforce/label/c.Provide_Recommendation';

//Class body.
export default class CsmNextBestActionManagement extends NavigationMixin(LightningElement) {

	//Labels.
	label = {
		Step_1,
		Recommendation,
		Object_Label,
		Recurrence,
		Interval,
		Step_2,
		Formula,
		Comparison,
		Operator,
		Values,
		Review,
		First_Field,
		Field_Type,
		Value,
		Second_Field,
		Back,
		Next,
		Copy_To_Clipboard,
		Insert,
		Logic,
		AND,
		OR,
		NOT,
		SOQL,
		Insert_Record_Id_Clause,
		Query,
		Threshold_Criteria,
		Threshold,
		Multiple_SOQL,
		Queries,
		Step_3,
		Accept,
		Reject,
		Save,
		Verify,
		Verifying,
		No_Issues,
		Invalid_formula,
		Select_Object,
		Invalid_Logic,
		Invalid_Query,
		Provide_Query_And_Threshold,
		Provide_Formula,
		Provide_Threshold,
		Provide_Query,
		Provide_Logic,
		Provide_Interval,
		Provide_Recommendation
	}

	//Track variables.
	@track intFormulaCurrentIndex;
	@track strRecommendation;
	@track strActionAccepted;
	@track strActionRejected;
	@track strLogic;
	@track strQuery;
	@track strThresholdCriteria;
	@track strThreshold;
	@track strFormula;
	@track strSelectedFieldOne;
	@track strSelectedFieldTwo;
	@track strSelectedObject;
	@track strSelectedFormattedValueOne;
	@track strSelectedFormattedValueTwo;
	@track strSelectedCustomValueOne;
	@track strSelectedCustomValueTwo;
	@track strSelectedNumber;
	@track strRecurrenceInterval;
	@track strGeneratedFormula;
	@track strFormulaCurrentIndex;
	@track strCurrentStep2Tab;
	@track lstAvailableObjects;
	@track lstRelatedFields;
	@track lstMultipleQueries;

	//Private variables.
	boolVerifyingLogic;
	boolVerifyingQuery;
	boolVerifyingFormula;
	boolIsRecurrence;
	boolIsOperatorStep;
	boolIsValuesStep;
	boolIsReviewStep;
	boolIsFieldValueOne;
	boolIsFieldValueTwo;
	boolIsFormattedValueOne;
	boolIsFormattedValueTwo;
	boolIsCustomValueOne;
	boolIsCustomValueTwo;
	boolDisplaySpinner;
	boolCustomCSSLoaded;
	strClipboard;
	strOperator;
	strRecurrence;
	strFieldTypeOne;
	strFieldTypeTwo;
	strVerifyFormulaVariant;
	strVerifyFormulaLabel;
	strVerifyQueryVariant;
	strVerifyQueryLabel;
	strVerifyLogicVariant;
	strVerifyLogicLabel;
	objMultiQueryTemplate = {
		strIndex: "1",
		boolDisplayRemoveQuery: false,
		boolVerifyingQuery: false,
		strQuery: "",
		strThresholdCriteria: "Equals",
		strThreshold: "",
		strVerifyQueryVariant: "brand",
		strVerifyQueryLabel: this.label.Verify
	};
	lstActions;
	lstActiveSections = ["Step 1", "Step 2", "Step 3"];
	lstRecurrences = [
		{
			label: "One time",
			value: "One time"
		},
		{
			label: "Recurring",
			value: "Recurring"
		}
	];
	lstValueType = [
		{
			label: "Object Field",
			value: "Object Field"
		},
		{
			label: "Formatted Value",
			value: "Formatted Value"
		},
		{
			label: "Custom Value",
			value: "Custom Value"
		}
	];
	lstOperators = [
		{
			label: "EQUALS",
			value: "EQUALS"
		},
		{
			label: "GREATER THAN",
			value: "GREATER_THAN"
		},
		{
			label: "LESS THAN",
			value: "LESS_THAN"
		},{
			label: "GREATER OR EQUAL",
			value: "GREATER_OR_EQUAL"
		},
		{
			label: "LESS OR EQUAL",
			value: "LESS_OR_EQUAL"
		},
		{
			label: "STARTS",
			value: "STARTS"
		},
		{
			label: "ENDS",
			value: "ENDS"
		},
		{
			label: "CONTAINS",
			value: "CONTAINS"
		}
	];
	lstThresholdCriterias = [
		{
			label: "Equals",
			value: "Equals"
		},
		{
			label: "Not equal to",
			value: "Not equal to"
		},
		{
			label: "Greater Than",
			value: "Greater Than"
		},{
			label: "Less Than",
			value: "Less Than"
		},
		{
			label: "Greater than or equal to",
			value: "Greater than or equal to"
		},
		{
			label: "Less than or equal to",
			value: "Less than or equal to"
		}
	];

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {

		//Now we load the records.
		this.loadRecords();
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strFullCustomCSS = "";
		let lstCustomCSS = new Array();
		if(!this.boolCustomCSSLoaded) {

			//First we define the Custom css items.
			lstCustomCSS.push(".minHeightContainer article { min-height: 100px; }");
			lstCustomCSS.push(".inlineField span, .inlineField label { display: none; }");
			lstCustomCSS.push(".inlineButtonMargin > button { margin-top: 23px; }");
			lstCustomCSS.push(".inlineButtonMargin { margin-top: 20px; cursor: pointer; }");
			lstCustomCSS.push(".addIcon svg { fill: var(--lwc-brandAccessible); }");
			lstCustomCSS.push(".addIcon { cursor: pointer; }");

			//Now we apply the css.
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				lstCustomCSS.forEach(strCustomCSS => {
					strFullCustomCSS += " c-csm-next-best-action-management " + strCustomCSS + " ";
				});
				objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			});
			this.boolCustomCSSLoaded = true;
		}
	}

	/*
	 Method Name : loadRecords
	 Description : This method loads the recommendations.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let intResult;
		let objParent = this;

		//We set the default values.
		objParent.boolDisplaySpinner = true;
		objParent.boolVerifyingLogic = false;
		objParent.boolVerifyingQuery = false;
		objParent.boolVerifyingFormula = false;
		objParent.boolIsRecurrence = false;
		objParent.boolIsOperatorStep = true;
		objParent.boolIsValuesStep = false;
		objParent.boolIsReviewStep = false;
		objParent.boolIsFieldValueOne = true;
		objParent.boolIsFieldValueTwo = true;
		objParent.boolIsFormattedValueOne = false;
		objParent.boolIsFormattedValueTwo = false;
		objParent.boolIsCustomValueOne = false;
		objParent.boolIsCustomValueTwo = false;
		objParent.intFormulaCurrentIndex = 1;
		objParent.strActionAccepted = "";
		objParent.strActionRejected = "";
		objParent.strThresholdCriteria = "Equals";
		objParent.strFormulaCurrentIndex = "S1";
		objParent.strCurrentStep2Tab = "Formula";
		objParent.strClipboard = "";
		objParent.strOperator = "EQUALS";
		objParent.strRecurrence = "One time";
		objParent.strFieldTypeOne = "Object Field";
		objParent.strFieldTypeTwo = "Object Field";
		objParent.strVerifyFormulaVariant = "brand";
		objParent.strVerifyFormulaLabel = objParent.label.Verify; 
		objParent.strVerifyQueryVariant = "brand";
		objParent.strVerifyQueryLabel = objParent.label.Verify;
		objParent.strVerifyLogicVariant = "brand";
		objParent.strVerifyLogicLabel = objParent.label.Verify;
		objParent.lstMultipleQueries = new Array();
		objParent.lstActions = new Array();
		objParent.lstAvailableObjects = new Array();
		objParent.lstMultipleQueries.push({... objParent.objMultiQueryTemplate});		

		//Now we load the SObjects.
		getSObjects().then(mapSObjects => {

			//Now we convert the result into the list of options for the combobox.
			if(objUtilities.isNotNull(mapSObjects)) {
				Object.entries(mapSObjects).map(objSObject => {
					objParent.lstAvailableObjects.push({
						value: objSObject[0],
						label: objSObject[1] + " (" + objSObject[0] + ")"
					});
				});
				objParent.lstAvailableObjects.sort(function(objRecordA, objRecordB) {
					intResult = -1;
					if(objRecordA.label > objRecordB.label) {
						intResult = 1;
					}
					return intResult;
				});
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});

		//We also load the available actions.
		getActions().then(lstRecords => {
			objParent.lstActions.push({
				label: "-- None --",
				value: ""
			});
			if(objUtilities.isNotNull(lstRecords)) {
				lstRecords.forEach(objRecord => {
					objParent.lstActions.push({
						label: objRecord.Title__c,
						value: objRecord.Id
					});
				});
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		})
	}

	/*
	 Method Name : selectObject
	 Description : This method handles the object selection and retrieves the related fields.
	 Parameters	 : Object, called from selectObject, objEvent Selection event.
	 Return Type : None
	 */
	selectObject(objEvent) {
		let intResult;
		let objParent = this;

		//We set the default values.
		objParent.strSelectedObject = objEvent.detail.value;
		objParent.lstRelatedFields = new Array();

		//Now we load the related fields.
		if(objUtilities.isNotBlank(this.strSelectedObject)) {
			getRelatedFields({
				strObjectAPIName: objParent.strSelectedObject
			}).then(mapFields => {

				//Now we convert the result into the list of options for the comboboxes.
				if(objUtilities.isNotNull(mapFields)) {
					Object.entries(mapFields).map(objField => {
						objParent.lstRelatedFields.push({
							value: objField[0],
							label: objField[1] + " (" + objField[0] + ")"
						});
					});
					objParent.lstRelatedFields.sort(function(objRecordA, objRecordB) {
						intResult = -1;
						if(objRecordA.label > objRecordB.label) {
							intResult = 1;
						}
						return intResult;
					});
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}

	/*
	 Method Name : nextStep
	 Description : This method moves the Formula progress to the next step.
	 Parameters	 : None
	 Return Type : None
	 */
	nextStep() {
        this.intFormulaCurrentIndex++;
		this.strFormulaCurrentIndex = "S" + this.intFormulaCurrentIndex;
		this.updateProcessStep();
    }

	/*
	 Method Name : previousStep
	 Description : This method moves the Formula progress to the previous step.
	 Parameters	 : None
	 Return Type : None
	 */
	previousStep() {
        this.intFormulaCurrentIndex--;
		this.strFormulaCurrentIndex = "S" + this.intFormulaCurrentIndex;
		this.updateProcessStep();
    }

	/*
	 Method Name : updateProcessStep
	 Description : This method updates the visible elements, depending on the Formula step.
	 Parameters	 : None
	 Return Type : None
	 */
	updateProcessStep() {
		let strValueOne = "";
		let strValueTwo = "";
        switch(this.intFormulaCurrentIndex) {
			case 1:
				this.boolIsOperatorStep = true;
				this.boolIsValuesStep = false;
				this.boolIsReviewStep = false;
			break;
			case 2:
				this.boolIsOperatorStep = false;
				this.boolIsValuesStep = true;
				this.boolIsReviewStep = false;
			break;
			case 3:
				this.boolIsOperatorStep = false;
				this.boolIsValuesStep = false;
				this.boolIsReviewStep = true;

				//We check the Value One field.
				switch(this.strFieldTypeOne) {
					case "Object Field":
						if(objUtilities.isNotBlank(this.strSelectedFieldOne)) {
							strValueOne = "{!" + this.strSelectedFieldOne + "}";
						}
					break;
					case "Formatted Value":
						if(objUtilities.isNotBlank(this.strSelectedFormattedValueOne)) {
							strValueOne = this.strSelectedFormattedValueOne;
						}

						//Now we add "", if the value is a string comparison.
						if(this.strOperator === "EQUALS" || this.strOperator === "STARTS" || this.strOperator === "ENDS" || this.strOperator === "CONTAINS") {
							strValueOne = '"' + strValueOne + '"';
						}
					break;
					case "Custom Value":
						if(objUtilities.isNotBlank(this.strSelectedCustomValueOne)) {
							strValueOne = this.strSelectedCustomValueOne;
						}

						//Now we add "", if the value is a string comparison.
						if(this.strOperator === "EQUALS" || this.strOperator === "STARTS" || this.strOperator === "ENDS" || this.strOperator === "CONTAINS") {
							strValueOne = '"' + strValueOne + '"';
						}
					break;
				}

				//We check the Value Two field.
				switch(this.strFieldTypeTwo) {
					case "Object Field":
						if(objUtilities.isNotBlank(this.strSelectedFieldTwo)) {
							strValueTwo = "{!" + this.strSelectedFieldTwo + "}";
						}
					break;
					case "Formatted Value":
						if(objUtilities.isNotBlank(this.strSelectedFormattedValueTwo)) {
							strValueTwo = this.strSelectedFormattedValueTwo;
						}

						//Now we add "", if the value is a string comparison.
						if(this.strOperator === "EQUALS" || this.strOperator === "STARTS" || this.strOperator === "ENDS" || this.strOperator === "CONTAINS") {
							strValueTwo = '"' + strValueTwo + '"';
						}
					break;
					case "Custom Value":
						if(objUtilities.isNotBlank(this.strSelectedCustomValueTwo)) {
							strValueTwo = this.strSelectedCustomValueTwo;
						}

						//Now we add "", if the value is a string comparison.
						if(this.strOperator === "EQUALS" || this.strOperator === "STARTS" || this.strOperator === "ENDS" || this.strOperator === "CONTAINS") {
							strValueTwo = '"' + strValueTwo + '"';
						}
					break;
				}

				//Now we build the Formula.
				this.strGeneratedFormula = this.strOperator + "(" + strValueOne + ", " + strValueTwo + ")";
			break;
		}
    }

	/*
	 Method Name : changeFormulaStep
	 Description : This method updates the visible elements, depending on the Formula step.
	 Parameters	 : Object, called from changeFormulaStep, objEvent On click event.
	 Return Type : None
	 */
	changeFormulaStep(objEvent) {
        this.intFormulaCurrentIndex = parseInt(objEvent.currentTarget.dataset.index);
		this.strFormulaCurrentIndex = "S" + this.intFormulaCurrentIndex;
		this.updateProcessStep();
    }

	/*
	 Method Name : selectFieldType
	 Description : This method defines the selected Field Type.
	 Parameters	 : Object, called from selectFieldType, objEvent On change event.
	 Return Type : None
	 */
	selectFieldType(objEvent) {
		if(objEvent.currentTarget.dataset.id === "1") {
			this.strFieldTypeOne = objEvent.currentTarget.value;
			switch(this.strFieldTypeOne) {
				case "Object Field":
					this.boolIsFieldValueOne = true;
					this.boolIsFormattedValueOne = false;
					this.boolIsCustomValueOne = false;
				break;
				case "Formatted Value":
					this.boolIsFieldValueOne = false;
					this.boolIsFormattedValueOne = true;
					this.boolIsCustomValueOne = false;
				break;
				case "Custom Value":
					this.boolIsFieldValueOne = false;
					this.boolIsFormattedValueOne = false;
					this.boolIsCustomValueOne = true;
				break;
			}
		} else {
			this.strFieldTypeTwo = objEvent.currentTarget.value;
			switch(this.strFieldTypeTwo) {
				case "Object Field":
					this.boolIsFieldValueTwo = true;
					this.boolIsFormattedValueTwo = false;
					this.boolIsCustomValueTwo = false;
				break;
				case "Formatted Value":
					this.boolIsFieldValueTwo = false;
					this.boolIsFormattedValueTwo = true;
					this.boolIsCustomValueTwo = false;
				break;
				case "Custom Value":
					this.boolIsFieldValueTwo = false;
					this.boolIsFormattedValueTwo = false;
					this.boolIsCustomValueTwo = true;
				break;
			}
		}
    }

	/*
	 Method Name : selectRecurrence
	 Description : This method defines the selected Recurrence.
	 Parameters	 : Object, called from selectRecurrence, objEvent On change event.
	 Return Type : None
	 */
	selectRecurrence(objEvent) {
        this.strRecurrence = objEvent.currentTarget.value;
		if(this.strRecurrence === "One time") {
			this.boolIsRecurrence = false;
		} else {
			this.boolIsRecurrence = true;
		}
    }

	/*
	 Method Name : selectInterval
	 Description : This method defines the selected Interval.
	 Parameters	 : Object, called from selectInterval, objEvent On change event.
	 Return Type : None
	 */
	selectInterval(objEvent) {
        this.strRecurrenceInterval = objEvent.currentTarget.value;
    }

	/*
	 Method Name : selectField
	 Description : This method defines the selected Field.
	 Parameters	 : Object, called from selectField, objEvent On change event.
	 Return Type : None
	 */
	selectField(objEvent) {
		if(objEvent.currentTarget.dataset.id === "1") {
			this.strSelectedFieldOne = objEvent.currentTarget.value;
		} else {
			this.strSelectedFieldTwo = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : selectFormattedValue
	 Description : This method defines the selected Formatted value.
	 Parameters	 : Object, called from selectFormattedValue, objEvent On change event.
	 Return Type : None
	 */
	selectFormattedValue(objEvent) {
		if(objEvent.currentTarget.dataset.id === "1") {
			this.strSelectedFormattedValueOne = objEvent.currentTarget.value;
		} else {
			this.strSelectedFormattedValueTwo = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : selectCustomValue
	 Description : This method defines the selected Custom value.
	 Parameters	 : Object, called from selectCustomValue, objEvent On change event.
	 Return Type : None
	 */
	selectCustomValue(objEvent) {
		if(objEvent.currentTarget.dataset.id === "1") {
			this.strSelectedCustomValueOne = objEvent.currentTarget.value;
		} else {
			this.strSelectedCustomValueTwo = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : selectOperator
	 Description : This method defines the selected Operator.
	 Parameters	 : Object, called from selectOperator, objEvent On change event.
	 Return Type : None
	 */
	selectOperator(objEvent) {
		this.strOperator = objEvent.currentTarget.value;
    }

	/*
	 Method Name : copyToClipboardFormula
	 Description : This method copies the generated formula to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
	copyToClipboardFormula() {
		this.copyToClipboard(this.strGeneratedFormula);
    }

	/*
	 Method Name : insertFormula
	 Description : This method inserts the generated formula to the Formula field.
	 Parameters	 : None
	 Return Type : None
	 */
	insertFormula() {
		if(objUtilities.isNull(this.strFormula)) {
			this.strFormula = "";
		}
		this.strFormula = this.strFormula + this.strGeneratedFormula;
    }

	/*
	 Method Name : copyToClipboardLogic
	 Description : This method copies the selected logic to the clipboard.
	 Parameters	 : Object, called from copyToClipboardLogic, objEvent On change event.
	 Return Type : None
	 */
	copyToClipboardLogic(objEvent) {
		this.copyToClipboard(objEvent.currentTarget.dataset.value);
    }

	/*
	 Method Name : insertLogic
	 Description : This method inserts the selected logic to the Formula field.
	 Parameters	 : Object, called from insertLogic, objEvent On change event.
	 Return Type : None
	 */
	insertLogic(objEvent) {
		if(objUtilities.isNull(this.strFormula)) {
			this.strFormula = "";
		}
		this.strFormula = this.strFormula + objEvent.currentTarget.dataset.value;
    }

	/*
	 Method Name : insertLogicMultipleQueries
	 Description : This method inserts the selected logic to the Logic field.
	 Parameters	 : Object, called from insertLogicMultipleQueries, objEvent On change event.
	 Return Type : None
	 */
	insertLogicMultipleQueries(objEvent) {
		if(objUtilities.isNull(this.strLogic)) {
			this.strLogic = "";
		}
		this.strLogic = this.strLogic + objEvent.currentTarget.dataset.value;
    }

	/*
	 Method Name : insertRecordIdClause
	 Description : This method inserts the record id clause on the query field.
	 Parameters	 : Object, called from insertRecordIdClause, objEvent On change event.
	 Return Type : None
	 */
	insertRecordIdClause(objEvent) {

		//If the request is coming from the Multi Query Section.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.id)) {
			this.lstMultipleQueries.forEach(objElement => {
				if(objElement.strIndex === objEvent.currentTarget.dataset.id) {
					if(objUtilities.isNull(objElement.strQuery)) {
						objElement.strQuery = "";
					}
					objElement.strQuery = objElement.strQuery + objEvent.currentTarget.dataset.value;
				}
			});
		} else {

			//Otherwise, we assume the request is coming from the Single Query section.
			if(objUtilities.isNull(this.strQuery)) {
				this.strQuery = "";
			}
			this.strQuery = this.strQuery + objEvent.currentTarget.dataset.value;
		}
    }

	/*
	 Method Name : insertIndex
	 Description : This method inserts the record index clause on the logic field.
	 Parameters	 : Object, called from insertIndex, objEvent On click event.
	 Return Type : None
	 */
	insertIndex(objEvent) {
		if(objUtilities.isNull(this.strLogic)) {
			this.strLogic = "";
		}
		this.strLogic = this.strLogic + "{!" + objEvent.currentTarget.dataset.value + "}";
    }

	/*
	 Method Name : updateFormula
	 Description : This method updates the Formula value.
	 Parameters	 : Object, called from updateFormula, objEvent On change event.
	 Return Type : None
	 */
	updateFormula(objEvent) {
		this.strFormula = objEvent.currentTarget.value;
    }

	/*
	 Method Name : updateLogic
	 Description : This method updates the Formula value.
	 Parameters	 : Object, called from updateLogic, objEvent On change event.
	 Return Type : None
	 */
	updateLogic(objEvent) {
		this.strLogic = objEvent.currentTarget.value;
    }

	/*
	 Method Name : updateQuery
	 Description : This method updates the Query value.
	 Parameters	 : Object, called from updateQuery, objEvent On change event.
	 Return Type : None
	 */
	updateQuery(objEvent) {

		//If the request is coming from the Multi Query Section.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.id)) {
			this.lstMultipleQueries.forEach(objElement => {
				if(objElement.strIndex === objEvent.currentTarget.dataset.id) {
					objElement.strQuery = objEvent.currentTarget.value;
				}
			});
		} else {

			//Otherwise, we assume the request is coming from the Single Query section.
			this.strQuery = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : copyToClipboard
	 Description : This method copies the given string to the clipboard.
	 Parameters	 : String, called from copyToClipboard, strText Text to be copied to the clipboard.
	 Return Type : None
	 */
	copyToClipboard(strText) {
		let objInputField = this.template.querySelector('.clipboard');
		objInputField.value = strText;
		objInputField.select();
		document.execCommand('copy');
	}

	/*
	 Method Name : verifyFormula
	 Description : This method evaluates the current formula.
	 Parameters	 : None
	 Return Type : None
	 */
	verifyFormula() {
		let objParent = this;

		//If there's no verification in progress currently.
		if(!objParent.boolVerifyingFormula) {

			//First we make sure we have selected an Object.
			if(objUtilities.isNotBlank(objParent.strSelectedObject)) {

				//Now we put the button "In Progress".
				objParent.strVerifyFormulaVariant = "brand-outline";
				objParent.strVerifyFormulaLabel = objParent.label.Verifying; 
				objParent.boolVerifyingFormula = true;

				//Now we evaluate the formula.
				getFormulaVerified({
					strObjectAPIName: objParent.strSelectedObject,
					strFormula: objParent.strFormula
				}).then(boolResult => {

					//Now we inform the result to the user.
					if(boolResult) {
						objParent.strVerifyFormulaVariant = "success";
						objParent.strVerifyFormulaLabel = objParent.label.No_Issues;
					} else {
						objParent.strVerifyFormulaVariant = "destructive";
						objParent.strVerifyFormulaLabel = objParent.label.Invalid_formula;
					}
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {

					//Finally, we restore the button.
					setTimeout(function() {
						objParent.strVerifyFormulaVariant = "brand";
						objParent.strVerifyFormulaLabel = objParent.label.Verify; 
						objParent.boolVerifyingFormula = false;
					}, 2000);
				});
			} else {
				objUtilities.showToast("Error", objParent.label.Select_Object, "error", objParent);
			}
		}		
	}

	/*
	 Method Name : verifyLogic
	 Description : This method evaluates the current logic in the multiple queries field.
	 Parameters	 : None
	 Return Type : None
	 */
	verifyLogic() {
		let objParent = this;
		let lstQueries = new Array();

		//If there's no verification in progress currently.
		if(!objParent.boolVerifyingLogic) {

			//First we make sure we have selected an Object.
			if(objUtilities.isNotBlank(objParent.strSelectedObject)) {

				//Now we put the button "In Progress".
				objParent.strVerifyLogicVariant = "brand-outline";
				objParent.strVerifyLogicLabel = objParent.label.Verifying; 
				objParent.boolVerifyingLogic = true;

				//Now we create the list of queries.
				objParent.lstMultipleQueries.forEach(objElement => {
					lstQueries.push({
						Identifier__c: objElement.strIndex,
						Query__c: objElement.strQuery,
						Threshold__c: parseInt(objElement.strThreshold),
						Threshold_Criteria__c: objElement.strThresholdCriteria
					});
				});

				//Now we evaluate the logic.
				getLogicEvaluated({
					strObjectAPIName: objParent.strSelectedObject,
					strLogic: objParent.strLogic,
					lstQueries: lstQueries
				}).then(boolResult => {

					//Now we inform the result to the user.
					if(boolResult) {
						objParent.strVerifyLogicVariant = "success";
						objParent.strVerifyLogicLabel = objParent.label.No_Issues;
					} else {
						objParent.strVerifyLogicVariant = "destructive";
						objParent.strVerifyLogicLabel = objParent.label.Invalid_Logic;
					}
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {

					//Finally, we restore the button.
					setTimeout(function() {
						objParent.strVerifyLogicVariant = "brand";
						objParent.strVerifyLogicLabel = objParent.label.Verify; 
						objParent.boolVerifyingLogic = false;
					}, 2000);
				});
			} else {
				objUtilities.showToast("Error", objParent.label.Select_Object, "error", objParent);
			}
		}		
	}

	/*
	 Method Name : verifyQuery
	 Description : This method evaluates the current query.
	 Parameters	 : Object, called from updateQuery, objEvent On change event.
	 Return Type : None
	 */
	verifyQuery(objEvent) {
		let objParent = this;

		//If the request is coming from the Multi Query Section.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.id)) {
			this.lstMultipleQueries.forEach(objElement => {
				if(objElement.strIndex === objEvent.currentTarget.dataset.id) {
					if(!objElement.boolVerifyingQuery) {

						//First we make sure we have selected an Object.
						if(objUtilities.isNotBlank(objParent.strSelectedObject) && objUtilities.isNotBlank(objElement.strQuery) && objUtilities.isNotBlank(objElement.strThreshold)) {
			
							//Now we put the button "In Progress".
							objElement.strVerifyQueryVariant = "brand-outline";
							objElement.strVerifyQueryLabel = objParent.label.Verifying; 
							objElement.boolVerifyingQuery = true;
			
							//Now we evaluate the formula.
							getQueryVerified({
								strObjectAPIName: objParent.strSelectedObject,
								strQuery: objElement.strQuery,
								strThreshold: objElement.strThreshold,
								strThresholdCriteria: objElement.strThresholdCriteria
							}).then(boolResult => {
			
								//Now we inform the result to the user.
								if(boolResult) {
									objElement.strVerifyQueryVariant = "success";
									objElement.strVerifyQueryLabel = objParent.label.No_Issues;
								} else {
									objElement.strVerifyQueryVariant = "destructive";
									objElement.strVerifyQueryLabel = objParent.label.Invalid_Query;
								}
							}).catch((objError) => {
								objUtilities.processException(objError, objParent);
							}).finally(() => {
			
								//Finally, we restore the button.
								setTimeout(function() {
									objElement.strVerifyQueryVariant = "brand";
									objElement.strVerifyQueryLabel = objParent.label.Verify; 
									objElement.boolVerifyingQuery = false;
								}, 2000);
							});
						} else {
							objUtilities.showToast("Error", objParent.label.Provide_Query_And_Threshold, "error", objParent);
						}
					}
				}
			});
		} else {

			//Otherwise, we assume the request is coming from the Single Query section.
			if(!objParent.boolVerifyingQuery) {

				//First we make sure we have selected an Object.
				if(objUtilities.isNotBlank(objParent.strSelectedObject) && objUtilities.isNotBlank(objParent.strQuery) && objUtilities.isNotBlank(objParent.strThreshold)) {
	
					//Now we put the button "In Progress".
					objParent.strVerifyQueryVariant = "brand-outline";
					objParent.strVerifyQueryLabel = objParent.label.Verifying; 
					objParent.boolVerifyingQuery = true;
	
					//Now we evaluate the formula.
					getQueryVerified({
						strObjectAPIName: objParent.strSelectedObject,
						strQuery: objParent.strQuery,
						strThreshold: objParent.strThreshold,
						strThresholdCriteria: objParent.strThresholdCriteria
					}).then(boolResult => {
	
						//Now we inform the result to the user.
						if(boolResult) {
							objParent.strVerifyQueryVariant = "success";
							objParent.strVerifyQueryLabel = objParent.label.No_Issues;
						} else {
							objParent.strVerifyQueryVariant = "destructive";
							objParent.strVerifyQueryLabel = objParent.label.Invalid_Query;
						}
					}).catch((objError) => {
						objUtilities.processException(objError, objParent);
					}).finally(() => {
	
						//Finally, we restore the button.
						setTimeout(function() {
							objParent.strVerifyQueryVariant = "brand";
							objParent.strVerifyQueryLabel = objParent.label.Verify; 
							objParent.boolVerifyingQuery = false;
						}, 2000);
					});
				} else {
					objUtilities.showToast("Error", objParent.label.Provide_Query_And_Threshold, "error", objParent);
				}
			}
		}
	}

	/*
	 Method Name : changeSecondStepTab
	 Description : This method updates the selected tab on the second step.
	 Parameters	 : Object, called from updateQuery, objEvent On active event.
	 Return Type : None
	 */
	changeSecondStepTab(objEvent) {
        this.strCurrentStep2Tab = objEvent.target.value;
    }

	/*
	 Method Name : selectThreshold
	 Description : This method defines the selected Threshold.
	 Parameters	 : Object, called from selectThreshold, objEvent On change event.
	 Return Type : None
	 */
	selectThreshold(objEvent) {

		//If the request is coming from the Multi Query Section.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.id)) {
			this.lstMultipleQueries.forEach(objElement => {
				if(objElement.strIndex === objEvent.currentTarget.dataset.id) {
					objElement.strThreshold = objEvent.currentTarget.value;
				}
			});
		} else {

			//Otherwise, we assume the request is coming from the Single Query section.
			this.strThreshold = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : selectThresholdCriteria
	 Description : This method defines the selected Threshold Criteria.
	 Parameters	 : Object, called from selectThresholdCriteria, objEvent On change event.
	 Return Type : None
	 */
	selectThresholdCriteria(objEvent) {

		//If the request is coming from the Multi Query Section.
		if(objUtilities.isNotBlank(objEvent.currentTarget.dataset.id)) {
			this.lstMultipleQueries.forEach(objElement => {
				if(objElement.strIndex === objEvent.currentTarget.dataset.id) {
					objElement.strThresholdCriteria = objEvent.currentTarget.value;
				}
			});
		} else {

			//Otherwise, we assume the request is coming from the Single Query section.
			this.strThresholdCriteria = objEvent.currentTarget.value;
		}
    }

	/*
	 Method Name : addQuery
	 Description : This method adds a new query row on the Multi Query section.
	 Parameters	 : None
	 Return Type : None
	 */
	addQuery() {
		let objParent = this;
		let objNewQuery = {... objParent.objMultiQueryTemplate};
		objNewQuery.strIndex = "" + (objParent.lstMultipleQueries.length + 1);
		objNewQuery.boolDisplayRemoveQuery = true;
        objParent.lstMultipleQueries.push(objNewQuery);
    }

	/*
	 Method Name : removeQuery
	 Description : This method removes a query row on the Multi Query section.
	 Parameters	 : Object, called from removeQuery, objEvent On click event.
	 Return Type : None
	 */
	removeQuery(objEvent) {
		let intIndex = 1;
		let objParent = this;
		let lstNewMultipleQueries = new Array();

		//Now we iterate over the exiting records, and remove the corresponding one, depending on the index.
		objParent.lstMultipleQueries.forEach(objElement => {
			if(objElement.strIndex !== objEvent.currentTarget.dataset.value) {
				lstNewMultipleQueries.push(objElement);
			}
		});

		//Now we update the index for all the new values.
		lstNewMultipleQueries.forEach(objElement => {
			objElement.strIndex = "" + intIndex;
			intIndex++;
		});

		//Now we assign the list to the front-end variable.
        objParent.lstMultipleQueries = lstNewMultipleQueries;
    }

	/*
	 Method Name : selectActionAccepted
	 Description : This method defines the selected action on Accept section.
	 Parameters	 : Object, called from selectActionAccepted, objEvent On change event.
	 Return Type : None
	 */
	selectActionAccepted(objEvent) {
		this.strActionAccepted = objEvent.currentTarget.value;
    }

	/*
	 Method Name : selectActionRejected
	 Description : This method defines the selected action on Reject section.
	 Parameters	 : Object, called from selectActionRejected, objEvent On change event.
	 Return Type : None
	 */
	selectActionRejected(objEvent) {
		this.strActionRejected = objEvent.currentTarget.value;
    }

	/*
	 Method Name : setRecommendation
	 Description : This method defines the selected action on Accept section.
	 Parameters	 : Object, called from setRecommendation, objEvent On change event.
	 Return Type : None
	 */
	setRecommendation(objEvent) {
		this.strRecommendation = objEvent.currentTarget.value;
    }

	/*
	 Method Name : selectActionAccepted
	 Description : This method defines the selected action on Accept section.
	 Parameters	 : Object, called from selectActionAccepted, objEvent On change event.
	 Return Type : None
	 */
	createRecord() {
		let boolReady = false;
		let objParent = this;
		let objRecord = new Object();
		let lstQueries = new Array();

		//We set the default values.
		objRecord.Active__c = true;
		objRecord.Criteria_Type__c = objParent.strCurrentStep2Tab;
		objRecord.Object__c = objParent.strSelectedObject;
		objRecord.Order__c = (new Date()).getTime();
		objRecord.Recommendation__c = objParent.strRecommendation;
		objRecord.Recurrence__c = objParent.strRecurrence;
		objRecord.Accepted_Action__c = objParent.strActionAccepted;
		objRecord.Rejected_Action__c = objParent.strActionRejected;
		if(objUtilities.isNotBlank(objParent.strRecurrenceInterval)) {
			objRecord.Recurring_Interval__c = parseInt(objParent.strRecurrenceInterval);
		}
		
		//First we execute all teh validations.
		if(objUtilities.isNotBlank(objParent.strRecommendation)) {
			if(objUtilities.isNotBlank(objParent.strSelectedObject)) {
				if(objParent.strRecurrence === "One time" || (objParent.strRecurrence === "Recurring" && objUtilities.isNotBlank(objParent.strRecurrenceInterval))) {
					switch(objParent.strCurrentStep2Tab) {
						case "Formula":
							if(objUtilities.isNotBlank(objParent.strFormula)) {
								boolReady = true;
								objRecord.Criteria__c = objParent.strFormula;
							} else {
								objUtilities.showToast("Error", objParent.label.Provide_Formula, "error", objParent);
							}
						break;
						case "SOQL":
							if(objUtilities.isNotBlank(objParent.strQuery)) {
								if(objUtilities.isNotBlank(objParent.strThreshold)) {
									boolReady = true;
									objRecord.Criteria__c = objParent.strQuery;
									objRecord.Threshold__c = parseInt(objParent.strThreshold);
									objRecord.Threshold_Criteria__c = objParent.strThresholdCriteria;
								} else {
									objUtilities.showToast("Error", objParent.label.Provide_Threshold + ".", "error", objParent);
								}
							} else {
								objUtilities.showToast("Error", objParent.label.Provide_Query + ".", "error", objParent);
							}
						break;
						case "Multiple SOQL":
							if(objUtilities.isNotBlank(objParent.strLogic)) {
								boolReady = true;
								objRecord.Criteria__c = objParent.strLogic;

								//Now we make sure each query contains all the required data.
								objParent.lstMultipleQueries.forEach(objElement => {
									if(boolReady) {
										if(objUtilities.isNotBlank(objElement.strQuery)) {
											if(objUtilities.isNotBlank(objElement.strThreshold)) {
												lstQueries.push({
													Active__c: true,
													Identifier__c: objElement.strIndex,
													Query__c: objElement.strQuery,
													Threshold__c: parseInt(objElement.strThreshold),
													Threshold_Criteria__c: objElement.strThresholdCriteria
												});
											} else {
												boolReady = false;
												objUtilities.showToast("Error", objParent.label.Provide_Threshold + " on row " + objElement.strIndex + ".", "error", objParent);
											}
										} else {
											boolReady = false;
											objUtilities.showToast("Error", objParent.label.Provide_Query + " on row " + objElement.strIndex + ".", "error", objParent);
										}
									}
								});
							} else {
								objUtilities.showToast("Error", objParent.label.Provide_Logic, "error", objParent);
							}
						break;
					}

					//If everything went well, we insert the record.
					if(boolReady) {
						objParent.boolDisplaySpinner = true;
						getRecordCreated({
							objNextBestAction: objRecord,
							lstQueries: lstQueries
						}).then(strNewRecordId => {
							this[NavigationMixin.Navigate]({
								type: 'standard__recordPage',
								attributes: {
									recordId: strNewRecordId,
									actionName: 'view'
								}
							});
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
						}).finally(() => {
				
							//Finally, we hide the spinner.
							objParent.boolDisplaySpinner = false;
						});
					}
				} else {
					objUtilities.showToast("Error", objParent.label.Provide_Interval, "error", objParent);
				}
			} else {
				objUtilities.showToast("Error", objParent.label.Select_Object, "error", objParent);
			}
		} else {
			objUtilities.showToast("Error", objParent.label.Provide_Recommendation, "error", objParent);
		}
    }
}