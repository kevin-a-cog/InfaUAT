/* Name		    :	CsmMultiSelectCell
* Author		:	Deva M
* Created Date	: 	01/19/2022
* Description	:	custom cell celection for multi select

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description						Tag
**********************************************************************************************************
Deva M              10-01-2022     	AR-1751        
*/
//Core Imports
import { api, LightningElement, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class CsmMultiSelectCell extends LightningElement {
    //Public variables
    @api strMultiSelectValue;

    //Private Variables
    lstSelectedValues = new Array();;
    //Feature configuration
     @track objConfiguration = {
        columns : ["Project","Product","Engagement"],
        data : [
            {
                
                project:{ strLabel: "Schedule/Scope Changes", strId:"11",strState:"slds-button slds-button_neutral  slds-button_stretch" },
                product:{ strLabel: "Technical Issues", strId:"12",strState:"slds-button slds-button_neutral slds-button_stretch" },
                engagement:{ strLabel: "Unresponsive Customer", strId:"13",strState:"slds-button slds-button_neutral slds-button_stretch" },
                strStyleClasses:"",
            },
            {
                project:{ strLabel: "Partner/IPS Concerns", strId:"21",strState:"slds-button slds-button_neutral slds-button_stretch" },
                product:{ strLabel: "Feature/ Functionality Mismatch", strId:"22",strState:"slds-button slds-button_neutral slds-button_stretch" },
                engagement:{ strLabel: "Strategy / Org Changes", strId:"23",strState:"slds-button slds-button_neutral slds-button_stretch" },
                strStyleClasses:"",
            },
            {
                project:{ strLabel: "Budget Impact", strId:"31",strState:"slds-button slds-button_neutral slds-button_stretch" },
                product:{ strLabel: "Compatibility / Experience Concerns", strId:"32",strState:"slds-button slds-button_neutral slds-button_stretch" },
                engagement:{ strLabel: "Budget Concerns", strId:"33",strState:"slds-button slds-button_neutral slds-button_stretch" },
                strStyleClasses:"",
            },
            {
                project:{ strLabel: "Resource Unavailability", strId:"41",strState:"slds-button slds-button_neutral slds-button_stretch" },
                product:{ strLabel: "Use Case non-alignment", strId:"42",strState:"slds-button slds-button_neutral slds-button_stretch" },
                engagement:{ strLabel: "Competitor Presence", strId:"43",strState:"slds-button slds-button_neutral slds-button_stretch" },
                strStyleClasses:"",
            },
        ]
    }

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
        let objParent = this;
        if(objUtilities.isNotNull(objParent.strMultiSelectValue)){
            const lstMultiSelect = objParent.strMultiSelectValue.split(";");
            lstMultiSelect.forEach(strValue => {  
                 //Iterate over rows
                objParent.objConfiguration.data.forEach(objCellValue => {     
                    //Set the previously selected value over edit
                    if(strValue === objCellValue.project.strLabel) {
                        objCellValue.project.strState = "slds-button slds-button_brand slds-button_stretch";
                        objParent.lstSelectedValues.push(strValue);
                    }                     
                    if(strValue === objCellValue.product.strLabel) {
                        objCellValue.product.strState = "slds-button slds-button_brand slds-button_stretch";
                        objParent.lstSelectedValues.push(strValue);
                    }
                     if(strValue === objCellValue.engagement.strLabel) {
                        objCellValue.engagement.strState = "slds-button slds-button_brand slds-button_stretch";
                        objParent.lstSelectedValues.push(strValue);
                    }
                });
            });
        }
    }

      /*
	 Method Name : clickSlot
	 Description : This method gets executed on click.
	 Parameters	 : objEvent, event 
	 Return Type : None
	 */
    clickSlot(objEvent) {
        objEvent.preventDefault();
        let objParent = this;
        //Iterate over rows
        objParent.objConfiguration.data.forEach(objCellValue => {     
            //IF button cell matched set button ptoperties and pass values to list  
            if(objEvent.currentTarget.dataset.id === objCellValue.project.strId) {
                //Set property to button properties
                if(objCellValue.project.strState === "slds-button slds-button_brand slds-button_stretch") {
                    objCellValue.project.strState = "slds-button slds-button_neutral slds-button_stretch";
                    //Filter and remove the project unslected values from list
                    objParent.lstSelectedValues = objParent.lstSelectedValues.filter(strVal => strVal !== objCellValue.project.strLabel);
                }else{
                    //Add selected values to list
                    objCellValue.project.strState = "slds-button slds-button_brand slds-button_stretch";
                    objParent.lstSelectedValues.push(objCellValue.project.strLabel);
                }
            }
            if(objEvent.currentTarget.dataset.id === objCellValue.product.strId) {
                //Set property to button properties
                if(objCellValue.product.strState === "slds-button slds-button_brand slds-button_stretch") {
                    objCellValue.product.strState = "slds-button slds-button_neutral slds-button_stretch";
                    //Filter and remove the unslected product values from list
                    objParent.lstSelectedValues = objParent.lstSelectedValues.filter(strVal => strVal !== objCellValue.product.strLabel);
                }else{
                     //Add selected values to list
                    objCellValue.product.strState = "slds-button slds-button_brand slds-button_stretch";
                    objParent.lstSelectedValues.push(objCellValue.product.strLabel);
                }
            }
            if(objEvent.currentTarget.dataset.id === objCellValue.engagement.strId) {
                 //Set property to engagement button properties
                if(objCellValue.engagement.strState === "slds-button slds-button_brand slds-button_stretch") {
                    objCellValue.engagement.strState = "slds-button slds-button_neutral slds-button_stretch";
                    //Filter and remove the unslected engagement values from list
                    objParent.lstSelectedValues = objParent.lstSelectedValues.filter(strVal => strVal !== objCellValue.engagement.strLabel);
                }else{
                     //Add selected values to list
                    objCellValue.engagement.strState = "slds-button slds-button_brand slds-button_stretch";
                   objParent.lstSelectedValues.push(objCellValue.engagement.strLabel);
                }
            }
        });
        //Now send selected values to parent component
        if(objUtilities.isNotNull(objParent.lstSelectedValues) && objParent.lstSelectedValues.length>0){
            //Concatinate the selected values to get store in multiselect field
            objParent.dispatchEvent(new CustomEvent('cellselect', {
                detail: {
                    objPayload: objParent.lstSelectedValues.join(';')
                }
            }));
        }

    }
}