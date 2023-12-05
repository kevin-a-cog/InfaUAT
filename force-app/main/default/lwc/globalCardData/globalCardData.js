/*
 * Name			:	GlobalCardData
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/22/2021
 * Description	:	This LWC exposes the generica Card Data controller created for Global.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/22/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';
import strCustomStylesheet from '@salesforce/resourceUrl/globalCardDataStyles';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import No_Records_Found from '@salesforce/label/c.No_Records_Found';

//Class body.
export default class GlobalCardData extends NavigationMixin(LightningElement) {

	//API variables.
	@api objParameters;

	//Private variable.
	boolDisplayNoRecordsFound;
	boolHasRecords;
	boolDisplayPaginator;
	strPaginatorStyleClasses;
	strPaginatorComponent = '.globalDataTableIdentifier';
	objPaginatorParameters;
	lstActionButtons;
	lstRecords;
	lstOriginalRecords;
	lstRowsLayout;

	//Labels.
	label = {
		No_Records_Found
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
		loadStyle(this, strCustomStylesheet);

		//We define the configuration parameters.
		this.loadRecords(this.objParameters);
	}

	/*
	 Method Name : changeComponentPage
	 Description : This method changes the page on the component.
	 Parameters	 : Object, called from sortBy, objEvent Change event.
	 Return Type : None
	 */
	changeComponentPage(objEvent) {
		this.lstRecords = objEvent.detail;
	}

	/*
	 Method Name : mouseOverCard
	 Description : This method displays the Action buttons of a row.
	 Parameters	 : Object, called from sortBy, objEvent Mouse Over event.
	 Return Type : None
	 */
	mouseOverCard(objEvent) {
		let lstRecords = new Array();
		if(objUtilities.isNotNull(this.lstRecords)) {
			this.lstRecords.forEach((objRecord) => {
				if(objEvent.currentTarget.dataset.id === objRecord.strId) {
					objRecord.boolDisplayActionButtons = true;
				} else {
					objRecord.boolDisplayActionButtons = false;
				}
				lstRecords.push(objRecord);
			});
		}
		this.lstRecords = new Array();
		this.lstRecords.push(... lstRecords);
	}

	/*
	 Method Name : mouseOutCard
	 Description : This method displays the Action buttons of a row.
	 Parameters	 : None
	 Return Type : None
	 */
	mouseOutCard() {
		let lstRecords = new Array();
		if(objUtilities.isNotNull(this.lstRecords)) {
			this.lstRecords.forEach((objRecord) => {
				objRecord.boolDisplayActionButtons = false;
				lstRecords.push(objRecord);
			});
		}
		this.lstRecords = new Array();
		this.lstRecords.push(... lstRecords);
	}

	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	@api
	searchRecord(objEvent) {
		let strKeyword = objEvent.target.value;
		let objParent = this;
		let objPaginator = this.template.querySelector(this.strPaginatorComponent);
		let lstClonedRecords;

		//If the keyword is blank, we refresh the data only.
		if(typeof strKeyword === "undefined" || strKeyword === null || strKeyword === "") {
			this.boolHasRecords = false;
			this.lstRecords = [...this.lstOriginalRecords];
		} else {
			strKeyword = strKeyword.toLowerCase();

			//Otherwise we filter by the keyword.
			this.boolHasRecords = false;
			lstClonedRecords = [...this.lstOriginalRecords];
			this.lstRecords = new Array();
			lstClonedRecords.forEach(objRecord => {
				if(JSON.stringify(objRecord).toLowerCase().includes(strKeyword)) {
					objParent.lstRecords.push(objRecord);
				}
			});
		}

		//Finally we display the records.
		if(typeof this.lstRecords !== "undefined" && this.lstRecords !== null && this.lstRecords.length > 0) {
			this.boolHasRecords = true;

			//We update the paginator.
			if(this.boolDisplayPaginator && typeof objPaginator !== "undefined" && objPaginator !== null) {
				objPaginator.resetTheData(this.lstRecords);
			}
		}
	}

	/*
	 Method Name : filterFields
	 Description : This method searches for records based on a list of filters.
	 Parameters	 : Array, called from filterFields, lstFilters List of filters.
	 Return Type : None
	 */
	@api
	filterFields(lstFilters) {
		let boolShouldInclude;
		let strCellValue;
		let strFilterValue;
		let objParent = this;
		let objPaginator = this.template.querySelector(this.strPaginatorComponent);
		let lstClonedRecords;

		//If the list doesn't have filters, we refresh the data only.
		if(objUtilities.isNull(lstFilters) || lstFilters.length === 0) {
			this.boolHasRecords = false;
			this.lstRecords = [...this.lstOriginalRecords];
		} else {

			//Otherwise we apply the filters.
			this.boolHasRecords = false;
			lstClonedRecords = [...this.lstOriginalRecords];
			this.lstRecords = new Array();

			//We check record by record.
			lstClonedRecords.forEach(objRecord => {
				boolShouldInclude = true;

				//For each record, we check the filters.
				lstFilters.forEach((objFilter) => {
					if(boolShouldInclude && objUtilities.isNotBlank(objFilter.strFieldName) && objUtilities.isNotBlank(objFilter.strValue)) {
						strCellValue = ("" + objRecord[objFilter.strFieldName]).toLowerCase();
						strFilterValue = ("" + objFilter.strValue).toLowerCase();
						if((objFilter.boolIsExactMatch && strCellValue !== strFilterValue) || (!objFilter.boolIsExactMatch && !strCellValue.includes(strFilterValue))) {
							boolShouldInclude = false;
						}
					}
				});

				//If the value passed the test, we include it.
				if(boolShouldInclude) {
					objParent.lstRecords.push(objRecord);
				}
			});
		}

		//Finally we display the records.
		if(typeof this.lstRecords !== "undefined" && this.lstRecords !== null && this.lstRecords.length > 0) {
			this.boolHasRecords = true;

			//We update the paginator.
			if(this.boolDisplayPaginator && typeof objPaginator !== "undefined" && objPaginator !== null) {
				objPaginator.resetTheData(this.lstRecords);
			}
		}
	}

	/*
	 Method Name : loadRecords
	 Description : This method loadss the data.
	 Parameters	 : Object, called from loadRecords, objParameters Data records.
	 Return Type : None
	 */
	@api
	loadRecords(objParameters) {
		this.boolHasRecords = false;
		this.boolDisplayNoRecordsFound = true;
		this.objPaginatorParameters = new Object();

		//If we received parameters to process.
		if(objUtilities.isNotNull(objParameters)) {

			//Now we assign the received values.
			this.boolDisplayPaginator = objParameters.boolDisplayPaginator;
			this.lstRecords = JSON.parse(JSON.stringify(objParameters.lstRecords));
			this.lstActionButtons = JSON.parse(JSON.stringify(objParameters.lstActionButtons));

			//Now we add the Action buttons to each record.
			this.lstRecords.forEach((objRecord) => {
				objRecord.boolDisplayActionButtons = objParameters.boolDisplayActionButtons;
			});

			//Now we set values depending on certain conditions.
			if(objParameters.objPaginator) {
				this.objPaginatorParameters = objParameters.objPaginator;
			}

			//If we received the layout structure.
			if(objUtilities.isNotNull(objParameters.objLayout)) {
				this.lstRowsLayout = objParameters.objLayout.lstRows;
			}
		} else {

			//Other we default the values.
			this.lstRecords = new Array();
		}

		//If values are not present, we set the defaults.
		if(objUtilities.isNull(this.boolDisplayPaginator)) {
			this.boolDisplayPaginator = true;
		}
		if(objUtilities.isBlank(this.strPaginatorStyleClasses)) {
			this.strPaginatorStyleClasses = "";
		}

		//Now we display the "No records found" message, if needed.
		if(this.lstRecords.length > 0) {
			this.boolHasRecords = true;
		}

		//We add the identifier for the paginator.
		this.strPaginatorStyleClasses = this.strPaginatorStyleClasses + " globalDataTableIdentifier";

		//Now, we clone the provided data for the paginator component.
		this.lstOriginalRecords = [... this.lstRecords];
	}
}