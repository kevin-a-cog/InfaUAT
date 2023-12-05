/**************************************************************************
JS file Name: INFAKBInternal.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 01-October-2016
Purpose: Holds all the function required across the application for the Omniture DTM Reports.
Version: 1.0


Modificaiton History

Date      |  Modified by    |  Jira reference      |ChangesMade     

1/6/2017    Sathish Rajalingam      JIRA: KB-2129        UAT base URL update

***************************************************************************/


/*Global variable used across the application
 
*/

//call to  set digitaldata varialbe not to tracked
function fnUpdateLabelAsReadable() {

    try {
        for (i = 0; i < $$('span.test-id__field-label').length; i++)
            $$('span.test-id__field-label')[5].innerText = $$('span.test-id__field-label')[5].innerText.replace('INFA_KB_', '').replace('_', ' ')

    } catch (ex) {
        console.log("Method : fnUpdateLabelAsReadable; Error :" + ex.description);
    }

}

function updateArticleBorder() {
	try {
		let lastChildCount = $(".slds-form.slds-form_stacked").last().children().children().length;
		for(let i=0; i<lastChildCount; i++) {
			$($(".slds-form.slds-form_stacked").last().children().children()[i]).children().css('border', 'none');
		}
	} catch (ex) {
        console.log("Method : updateArticleBorder; Error :" + ex.description);
    }
}

document.addEventListener('DOMContentLoaded', function () {
    fnUpdateLabelAsReadable();
	updateArticleBorder();
});