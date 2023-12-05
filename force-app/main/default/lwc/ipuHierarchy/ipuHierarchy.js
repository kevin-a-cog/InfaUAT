/*
 * Name			:	IpuHierarchyContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	1/24/2023
 * Description	:	This component allows users to see the IPU Hierarchy related to a Fulfillment record.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		1/24/2023		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { subscribe, createMessageContext, APPLICATION_SCOPE } from "lightning/messageService";

//Messaging.
import objMessagingChannel from "@salesforce/messageChannel/refreshFulfilments__c";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/IPUHierarchyController.getRecords";

//Custom Labels.
import IPU_Hierarchy_Title from '@salesforce/label/c.IPU_Hierarchy_Title';

//Class body.
export default class IpuHierarchy extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;

	//Private variables.
	boolInitialLoad = true;
	boolCollapseAll = false;
	boolDisplaySpinner;
	objContext = createMessageContext();
	objParameters = {
		boolEnableTreeView: true,
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolEnablePopOver: false,
		boolHideCheckboxColumn: true,
		strTableId: "1",
		lstCustomCSS: [
			{
				strSelector: ".datatable-height",
				strCSS: "padding: 15px;"
			}
		]
	};
	label = {
		IPU_Hierarchy_Title: IPU_Hierarchy_Title
	};

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		//We subscribe to the refresh messages.
		subscribe(objParent.objContext, objMessagingChannel, () => {
			objParent.refreshCard();
		}, {
			scope: APPLICATION_SCOPE
		});

		//Now we load the list of records.
		objParent.loadRecords();
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objParent = this;
		if(objParent.boolInitialLoad) {
			objParent.boolInitialLoad = false;

			//Now we insert the CSS code.
			objParent.template.querySelectorAll('.customCSS').forEach(objElement => {
				objElement.innerHTML = "<style> .overflow > article { overflow-x: auto; } </style>";
			});
		}
	}

	/*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let objParent = this;

		//We set the initial values.
		objParent.boolDisplaySpinner = true;

		//Now we fetch the data.
		getRecords({
			boolShowAllLevels: true,
			idRecord: this.recordId
		}).then(objResult => {
			
			//We prepare the data table.
			objParent.objParameters.lstColumns = objResult.lstColumns;
			objParent.objParameters.lstRecords = objResult.lstRecordsCustomStructure;
			objParent.objParameters.mapParentChildRelationship = objResult.mapParentChildRelationship;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from refreshCard, objEvent click event.
	 Return Type : None
	 */
	refreshCard(objEvent) {

		//We prevent the default action.
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}

		//We refresh the table.
		this.loadRecords();
		return false;
	}

	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch(objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

	/*
	 Method Name : expandAll
	 Description : This method expands all the rows.
	 Parameters	 : None
	 Return Type : None
	 */
	toggleRows() {
		this.boolCollapseAll = !this.boolCollapseAll;
		this.template.querySelector("c-global-data-table").toggleRows(this.boolCollapseAll);
	}
}