/*
 * Name			:	globalCustomCSSLWC
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/6/2022
 * Description	:	This LWC inserts custom CSS into the DOM.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/6/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Class Body.
export default class GlobalCustomCSSLWC extends LightningElement {

	/*
	 Method Name : setCSS
	 Description : This method sets the given CSS into the DOM.
	 Parameters	 : List, called from setCSS, objConfiguration Configuration.
	 Return Type : None
	 */
	@api
	setCSS(lstCustomCSS) {
		let strFullCustomCSS = "";
		let objParent = this;

		//If we received CSS.
		if(objUtilities.isNotNull(lstCustomCSS)) {
			objParent.template.querySelectorAll('.customCSS').forEach(objElement => {
				lstCustomCSS.forEach(strCustomCSS => {
					strFullCustomCSS += " " + strCustomCSS + " ";
				});
				objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			});
		}
	}
}