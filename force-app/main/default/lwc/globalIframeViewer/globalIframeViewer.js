/*
 * Name			:	GlobalIframeViewer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/6/2021
 * Description	:	This LWC allows developers to display iframe content.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/6/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecordValues from "@salesforce/apex/GlobalIframeViewerController.getRecordValues";

//Class body.
export default class GlobalIframeViewer extends LightningElement {

	//API variables.
	@api recordId;
	@api strURL;
	@api strEndpointType;
	@api strFrameBorder;
	@api strMarginHeight;
	@api strMarginWidth;
	@api strStyle;
	@api strHeader;

	//Track variables.
	@track objProperties;

	//Private variables.
	boolAlreadyLoaded = false;
	boolDisplayHeader = false;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.objProperties = new Object();

		//First we assign the API variables to variables we can manipulate.
		this.updateLocalVariable("strURL", this.strURL);
		this.updateLocalVariable("strFrameBorder", this.strFrameBorder);
		this.updateLocalVariable("strMarginHeight", this.strMarginHeight);
		this.updateLocalVariable("strMarginWidth", this.strMarginWidth);
		this.updateLocalVariable("strStyle", this.strStyle);
		this.updateLocalVariable("strHeader", this.strHeader);
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		if(!this.boolAlreadyLoaded) {
			this.boolAlreadyLoaded = true;

			//Now we insert the CSS code.
			this.template.querySelector("iframe").style = this.objProperties.strStyle;
		}
	}

	/*
	 Method Name : replaceRecordVariables
	 Description : This method replaces the provided variables and fetches the data.
	 Parameters	 : None
	 Return Type : None
	 */
	replaceRecordVariables() {
		let objParent = this;
		let objRecordLowerCase = new Object();
		let objUserLowerCase = new Object();
		let lstFields = new Array();

		//First we check if we received a URL.
		if(objUtilities.isNotBlank(this.objProperties.strURL) && objUtilities.isNotBlank(this.recordId) && this.objProperties.strURL.includes("{{")) {

			//First we extract the variables.
			this.objProperties.strURL.match(/{{(.*?)}}/g).forEach(objVariable => {
				lstFields.push(objVariable.replace("{{", "").replace("}}", ""));
			});

			//Now we send the details to the backend.
			getRecordValues({
				strRecordId: this.recordId,
				lstFields: lstFields
			}).then(objResult => {

				//First we create a new object with everything as lower case.
				if(objUtilities.isNotNull(objResult.objRecord)) {
					Object.entries(objResult.objRecord).map(objElement => {
						objRecordLowerCase[objElement[0].toLowerCase()] = objElement[1];
					});
				}
				if(objUtilities.isNotNull(objResult.objUser)) {
					Object.entries(objResult.objUser).map(objElement => {
						objUserLowerCase[objElement[0].toLowerCase()] = objElement[1];
					});
				}

				//Now we replace the values in the URL.
				lstFields.forEach(strField => {
					if(strField.toLowerCase().startsWith("user.")) {
						objParent.objProperties.strURL = objParent.objProperties.strURL.replace("{{" + strField + "}}", encodeURIComponent(objUserLowerCase[strField.toLowerCase().replace("user.", "")]));
					} else {
						objParent.objProperties.strURL = objParent.objProperties.strURL.replace("{{" + strField + "}}", encodeURIComponent(objRecordLowerCase[strField.toLowerCase()]));
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}

	/*
	 Method Name : reload
	 Description : This method reloads the URL.
	 Parameters	 : None
	 			   None
	 Return Type : None
	 */
	@api
	reload() {
		let objParent = this;
		this.objProperties.strURLCurrent = this.objProperties.strURL;
		this.objProperties.strURL = "";
		setTimeout(function() {
			objParent.objProperties.strURL = objParent.objProperties.strURLCurrent;
			objParent.objProperties.strURLCurrent = "";
		}, 1000);
	}

	/*
	 Method Name : updateLocalVariable
	 Description : This method sets the API variables as local variables.
	 Parameters	 : String, called from updateLocalVariable, strVariableName Variable name.
	 			   String, called from updateLocalVariable, strValue Variable value.
	 Return Type : None
	 */
	@api
	updateLocalVariable(strVariableName, strValue) {
		this.objProperties[strVariableName] = strValue;

		//If what we changed was the style, we apply it.
		if(strVariableName === "strStyle" && this.boolAlreadyLoaded) {
			this.template.querySelector("iframe").style = this.objProperties.strStyle;
		} else if(strVariableName === "strURL") {
			
			//If we are updating the URL.
			this.replaceRecordVariables();
		} else if(strVariableName === "strHeader") {
			
			//If we are updating the Header.
			if(objUtilities.isNotBlank(strValue)) {
				this.boolDisplayHeader = true;
			} else {
				this.boolDisplayHeader = false;
			}
		}
	}
}