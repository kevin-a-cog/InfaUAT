/*
 * Name			:	GlobalUtilities
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	This LWC contains generic methods.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Monserrat Pedroza		07/09/2021		N/A				Initial version.								N/A
 Vignesh Divakaran		07/27/2022		I2RT-6687		Incorrect variable passed						T01
 Vignesh Divakaran		08/28/2022		I2RT-6880		Added method to check empty array   			T02
 balajip				11/25/2022		I2RT-7519		added method invokeWorkspaceAPI
														updated method openComponentInSubtab			T03
 Vignesh Divakaran		7/24/2023		I2RT-8640		Added utility class								T04
 */

//Core imports.
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';

/*
 Method Name : openComponentInSubtab
 Description : This method opens an Aura / LWC component in a subtab.
 Parameters	 : Object, called from openComponentInSubtab, Action properties.
 Return Type : None
 */
 const openComponentInSubtab = (objProperties) => {
	if(isNotNull(objProperties)) {
		objProperties.objParent[objProperties.objNavigation]({
			type: "standard__component",
			attributes: {
				componentName: "c__GlobalDynamicComponentLoader"
			},
			state: {
				uid: objProperties.strId + objProperties.strComponentName,
				c__strComponentName: objProperties.strComponentName,
				c__strCaseTabId: objProperties.strCaseTabId, //T03
				c__strSubtabLabel: objProperties.strSubtabLabel,
				c__objData: objProperties.objData
			}
		});
	}
}

/*
 Method Name : isBlank
 Description : This method returns if a variable is blank.
 Parameters	 : String, called from isBlank, strValue Value.
 Return Type : None
 */
const isBlank = (strValue) => {
	let boolResult = true;
	if(typeof strValue !== "undefined" && strValue !== null && strValue !== "") {
		boolResult = false;
	}
	return boolResult;
}

/*
 Method Name : isNotBlank
 Description : This method returns if a variable is not blank.
 Parameters	 : String, called from isNotBlank, strValue Value.
 Return Type : None
 */
const isNotBlank = (strValue) => {
	return !isBlank(strValue);
}

/*
 Method Name : isNull
 Description : This method returns if a variable is null.
 Parameters	 : String, called from isNull, objValue Value.
 Return Type : None
 */
const isNull = (objValue) => {
	let boolResult = true;
	if(typeof objValue !== "undefined" && objValue !== null) {
		boolResult = false;
	}
	return boolResult;
}

/*
 Method Name : isNotNull
 Description : This method returns if a variable is not null.
 Parameters	 : String, called from isNotNull, objValue Value.
 Return Type : None
 */
const isNotNull = (objValue) => {
	return !isNull(objValue);
}

/*
 Method Name : showToast
 Description : This method displays a Toast message.
 Parameters	 : String, called from showToast, strTitle Toast title. 
			   String, called from showToast, strMessage Toast message. 
			   String, called from showToast, strStyle Toast style.
			   Object, called from showToast, objParent Parent instance.
 Return Type : None
 */
const showToast = (strTitle, strMessage, strStyle, objParent) => {
	objParent.dispatchEvent(new ShowToastEvent({
		title: strTitle,
		message: strMessage,
		variant: strStyle
	}));
}

/*
 Method Name : processException
 Description : This method displays a Toast message, based on a thrown exception.
 Parameters	 : Object, called from processException, objException Exception.
			   Object, called from showToast, objParent Parent instance.
 Return Type : None
 */
const processException = (objException, objParent) => {
	let strType = "Error";
	let strTitle = strType;
	let strDescription = "";
	if(objException) {
		if(objException.body) {
			if(objException.body.exceptionType) {
				strTitle = objException.body.exceptionType;
			}
			if(objException.body.message) {
				strDescription = objException.body.message;
			} else if(objException.body.pageErrors && objException.body.pageErrors.length > 0) {
				objException.body.pageErrors.forEach(objError => {
					strDescription = objError.statusCode + ": " + objError.message;
				});
			} else if(objException.body.fieldErrors) {
				Object.entries(objException.body.fieldErrors).map(objError => {
					if(objError[1]) {
						objError[1].forEach(objField => {
							strDescription += objField.message + "\n";
						});
					}
				});
			}
		} else if(objException.message) {
			strDescription = objException.message;
		}
	}
	showToast(strTitle, strDescription, strType, objParent);
	console.error(objException);
}

/*
 Method Name : isObject
 Description : This method determines if a variable is an object.
 Parameters	 : Object, called from isObject, objItem Item to be analyzed.
 Return Type : Boolean
 */
const isObject = (objItem) => {
	return isNotNull(objItem) && typeof objItem === 'object';
}

/*
 Method Name : getPopOutCSSOpen
 Description : This method returns the CSS values for a popped out component.
 Parameters	 : None
 Return Type : Object
 */
const getPopOutCSSOpen = () => {
	return {
		strStyleContainer: "min-width: 100%; margin: 0;",
		strStyleContent: "min-height: 100vh; background-color: white;",
		strStyleFooter: "justify-content: right;",
		strClassesSection: "slds-modal slds-fade-in-open modalSection",
		strClassesContainer: "slds-modal__container",
		strClassesBody: "slds-p-around_small slds-m-top_small slds-m-bottom_small",
		strClassesFooter: "slds-modal__footer slds-docked-form-footer"
	};
}

/*
 Method Name : getPopOutCSSClosed
 Description : This method returns the CSS values for a popped in component.
 Parameters	 : None
 Return Type : Object
 */
const getPopOutCSSClosed = () => {
	return {
		strStyleContainer: "",
		strStyleContent: "background-color: white;",
		strStyleFooter: "",
		strClassesSection: "",
		strClassesContainer: "",
		strClassesBody: "",
		strClassesFooter: "slds-modal__footer"
	};
}

/*
 Method Name : log
 Description : This method prints console.log statements when the DEBUG flag is true.
 Parameters	 : Object, called from log, message to be analyzed.
 Return Type : NA
 */
const log = (message) => {
	if(DEBUG && DEBUG === 'true'){
        console.log(message);
    }
}

/*
 Method Name : isURL
 Description : This method defines if a given text is a URL.
 Parameters	 : String, called from isURL, strValue String to be analyzed.
 Return Type : Boolean
 */
const isURL = (strValue) => {
	let boolResult = false;
	let objURL;
	try {
		objURL = new URL(strValue);
		if(objURL.protocol === "http:" || objURL.protocol === "https:") {
			boolResult = true;
		}
	} catch(objException) {
		boolResult = false;
	}
	return boolResult;
}

/*
 Method Name : isJson
 Description : This method determines if a given string is a JSON structure.
 Parameters	 : String, called from isJson, strValue Value.
 Return Type : Boolean
 */
const isJson = (strValue) => {
	let boolResult = false;
	strValue = typeof strValue !== "string" ? JSON.stringify(strValue) : strValue;
	try {
		strValue = JSON.parse(strValue); //<T01>
		if(typeof strValue === "object" && strValue !== null) {
			boolResult = true;
		}
	} catch(objException) {}
	return boolResult;
}

/*
 Method Name : isEmpty
 Description : This method determines if the given array is an empty array.
 Parameters	 : Array, called from isEmpty, lstValues Value.
 Return Type : None
 */
const isEmpty = (lstValues) => { //<T02>
	let boolResult = false;
	if(typeof lstValues === "undefined" || lstValues === null || lstValues === "" || (Array.isArray(lstValues) && lstValues?.length === 0)) {
		boolResult = true;
	}
	return boolResult;
}

//T03
/*
 Method Name : invokeWorkspaceAPI
 Description : to invoke the Workspace API methods from a LWC
 Parameters	 : 
 Return Type : 
 */
const invokeWorkspaceAPI = (methodName, methodArgs) => {
	return new Promise((resolve, reject) => {
		const apiEvent = new CustomEvent("internalapievent", {
			bubbles: true,
			composed: true,
			cancelable: false,
			detail: {
				category: "workspaceAPI",
				methodName: methodName,
				methodArgs: methodArgs,
				callback: (err, response) => {
					if (err) {
						return reject(err);
					} else {
						return resolve(response);
					}
				}
			}
		});
	
		window.dispatchEvent(apiEvent);
	});
}

//Class body.
const objUtilities = {
	isBlank: isBlank,
	isNotBlank: isNotBlank,
	isNull: isNull,
	isNotNull: isNotNull,
	showToast: showToast,
	processException: processException,
	isObject: isObject,
	getPopOutCSSOpen: getPopOutCSSOpen,
	getPopOutCSSClosed: getPopOutCSSClosed,
	isURL: isURL,
	isJson: isJson,
	isEmpty: isEmpty,
	openComponentInSubtab: openComponentInSubtab,
	invokeWorkspaceAPI: invokeWorkspaceAPI //T03
}
export { objUtilities, log };
export { classSet } from './classSet'; //<T03>