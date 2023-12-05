//Core imports.
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
			}
		} else if(objException.message) {
			strDescription = objException.message;
		}
	}
	showToast(strTitle, strDescription, strType, objParent);
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

//Class body.
const objUtilities = {
	isBlank: isBlank,
	isNotBlank: isNotBlank,
	isNull: isNull,
	isNotNull: isNotNull,
	showToast: showToast,
	processException: processException,
	isObject: isObject
}
export { objUtilities };