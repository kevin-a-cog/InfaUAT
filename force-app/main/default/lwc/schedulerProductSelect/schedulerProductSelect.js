/*
 * Name			:	schedulerProductSelect
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/12/2023
 * Description	:	This LWC shows Ask An Expert products available for selection.

 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description					                        Tag
 ****************************************************************************************************************
 Vignesh Divakaran	    9/12/2023		I2RT-9063		Initial version.			                        N/A
*/

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class SchedulerProductSelect extends LightningElement {

    //API variables
    @api lstAAEProducts;
    @api strProductSelected;

    //Track variables
    @track lstProducts = [];
    @track strSelectedKey;


    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	*/
	connectedCallback() {
        let objParent = this;

        //Now, we get all the ask an expert products from the custom metadata.
        if(!objUtilities.isEmpty(objParent.lstAAEProducts)){

            objParent.lstAAEProducts.forEach((objAAEProduct, index) => {
                objParent.lstProducts.push({
                    strKey: `option-${index + 1}`,
                    strOption: objAAEProduct.Product__c
                });
            });

            //Now, we set the pre-selected product
            if(objUtilities.isNotBlank(objParent.strProductSelected)){
                objParent.strSelectedKey = objParent.lstProducts.find(objOption => objOption.strOption == objParent.strProductSelected)?.strKey;
            }
        }
    }

    /*
	 Method Name : select
	 Description : This method stores the selected product and its key.
	 Parameters	 : Object, called from select, objEvent on select custom event.
	 Return Type : None
	*/
    select(objEvent){
        this.strSelectedKey = objEvent.detail.strKey;
        this.strProductSelected = objEvent.detail.strOption;
    }

    //Getter methods
    get showProducts(){
        return !objUtilities.isEmpty(this.lstProducts);
    }
}