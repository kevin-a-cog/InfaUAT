/*
 * Name			:	GlobalPaginator
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/21/2021
 * Description	:	This LWC exposes the generica Paginator component created for Global.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/21/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api} from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import Records_Per_Page from '@salesforce/label/c.Records_Per_Page';
import Page from '@salesforce/label/c.Page';
import Go_To_Page from '@salesforce/label/c.Go_To_Page';
import Previous_Page from '@salesforce/label/c.Previous_Page';
import Next_Page from '@salesforce/label/c.Next_Page';
import Of from '@salesforce/label/c.Of';

//Class body.
export default class GlobalPaginator extends LightningElement {

	//API variables.
    @api intTotalRecords;
	@api objParameters;
    @api lstRecords;

	//Private variables.
	boolLayoutFull;
	boolLayoutSimplified;
	intMaximumNumberOfPages = 25;
	intPageSize;
    intTotalPages;
	intPageNumber = 1;
	strStyleClassPreviousIcon;
	strStyleClassNextIcon;
	objPageSizeOptions = [
		{
			boolIsDefault: false,
			intNumber: 5
		},{
			boolIsDefault: false,
			intNumber: 10
		},{
			boolIsDefault: true,
			intNumber: 25
		},{
			boolIsDefault: false,
			intNumber: 50
		},{
			boolIsDefault: false,
			intNumber: 100
		}
	];
	lstRecordsToDisplay;
	lstPages;

	//Labels.
	label = {
		Records_Per_Page,
		Page,
		Go_To_Page,
		Previous_Page,
		Next_Page,
		Of
	}
    
	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback() {

		//First we set the default values.
		this.initializeData();
    }

	/*
	 Method Name : initializeData
	 Description : This method initializes the data for page size and paginator.
	 Parameters	 : None
	 Return Type : None
	 */
	initializeData() {

		//If we received custom parameters.
		if(objUtilities.isNotNull(this.objParameters)) {

			//First we define the layout.
			switch(this.objParameters.intPaginatorType) {
				case 1:

					//Full layout.
					this.boolLayoutFull = true;
				break;
				case 2:

					//Simplified layout.
					this.boolLayoutSimplified = true;
				break;
				default:

					//Full layout.
					this.boolLayoutFull = true;
			}
		} else {
			this.boolLayoutFull = true;
		}

		//If we received records.
        if(objUtilities.isNotNull(this.lstRecords)) {

			//Now we determine the page size and pagination.
			if(objUtilities.isNotNull(this.objParameters) && objUtilities.isNotNull(this.objParameters.intPageSize)) {
				this.intPageSize = this.objParameters.intPageSize;
			} else if(this.objPageSizeOptions && this.objPageSizeOptions.length > 0) {
				this.objPageSizeOptions.forEach(objPageSize => {
					if(objPageSize.boolIsDefault) {
						this.intPageSize = objPageSize.intNumber;
					}
				});
				if(objUtilities.isNull(this.intPageSize)) {
					this.intPageSize = this.objPageSizeOptions[0].intNumber;
				}
			} else{
                this.intPageSize = this.intTotalRecords;
            }

			//Finally we set the records to display.
            this.setRecordsToDisplay();
        }
	}

	/*
	 Method Name : initializeData
	 Description : This method resets the default values.
	 Parameters	 : List, called from resetTheData, lstRecords List of records.
	 Return Type : None
	 */
    @api
    resetTheData(lstRecords) {

		//First we set the records.
        this.lstRecords = lstRecords;
		if(objUtilities.isNotNull(this.lstRecords)) {
			this.intTotalRecords = this.lstRecords.length;
		}

		//Now we reset the parameters.
		this.initializeData();
    }

	/*
	 Method Name : configureSimplifiedLayout
	 Description : This method configures the simplified layout with the current status.
	 Parameters	 : None
	 Return Type : None
	 */
    configureSimplifiedLayout() {
		let intStartPage;
		let intCurrentPage = parseInt(this.intPageNumber);
		let intTotalPages = this.intTotalPages;
		let strStyleClassPageNumber;

		//First we calculate the start page.
		if([1, 2, 3].includes(intCurrentPage)) {
			intStartPage = 1;
		} else if([intTotalPages, intTotalPages - 1, intTotalPages - 2].includes(intCurrentPage)) {
			intStartPage = intTotalPages - 4;
		} else {
			intStartPage = intCurrentPage - 2;
		}

		//Now we define which navitation controls to display.
		this.strStyleClassPreviousIcon = "pageIndicator_NavigationControl disableTextSelection";
		this.strStyleClassNextIcon = "pageIndicator_NavigationControl disableTextSelection";
		if(intCurrentPage !== 1) {
			this.strStyleClassPreviousIcon += " pageIndicator_NavigationControl_Visible";
		}
		if(intCurrentPage !== intTotalPages) {
			this.strStyleClassNextIcon += " pageIndicator_NavigationControl_Visible";
		}

		//We create the pages.
		this.lstPages = new Array();
		for(let intIndex = intStartPage; intIndex <= (intStartPage -1 + this.intMaximumNumberOfPages); intIndex++) {
			strStyleClassPageNumber = "slds-col pageIndicator disableTextSelection";

			//If the current page is the active one.
			if(intIndex === intCurrentPage) {
				strStyleClassPageNumber = 'slds-col pageIndicator_Active disableTextSelection';
			}

			//Now we insert the record in the list.
			if(intIndex <= intTotalPages) {
				this.lstPages.push({
					intNumber: intIndex,
					strStyleClass: strStyleClassPageNumber
				});
			}
		}
    }

	/*
	 Method Name : handlePageNumberChangeSimplified
	 Description : This method changes the page number.
	 Parameters	 : Object, called from handlePageNumberChangeSimplified, objEvent Click event.
	 Return Type : None
	 */
    handlePageNumberChangeSimplified(objEvent) {
		this.intPageNumber = objEvent.currentTarget.dataset.pageNumber;
		this.setRecordsToDisplay();
    }

	/*
	 Method Name : handleRecordsPerPage
	 Description : This method changes the page size.
	 Parameters	 : Object, called from handleRecordsPerPage, objEvent Change event.
	 Return Type : None
	 */
    handleRecordsPerPage(objEvent) {
        this.intPageSize = objEvent.target.value;
        this.setRecordsToDisplay();
    }

	/*
	 Method Name : handlePageNumberChange
	 Description : This method changes the page number.
	 Parameters	 : Object, called from handlePageNumberChange, objEvent Key press event.
	 Return Type : None
	 */
    handlePageNumberChange(objEvent) {

		//If the user presses Enter.
        if(objEvent.keyCode === 13) {
            this.intPageNumber = parseInt(objEvent.target.value);
            this.setRecordsToDisplay();
        }
    }

	/*
	 Method Name : previousPage
	 Description : This method changes the page to the previous one.
	 Parameters	 : None
	 Return Type : None
	 */
    previousPage() {
        this.intPageNumber = parseInt(this.intPageNumber) - 1;
        this.setRecordsToDisplay();
    }

	/*
	 Method Name : nextPage
	 Description : This method changes the page to the next one.
	 Parameters	 : None
	 Return Type : None
	 */
    nextPage() {
        this.intPageNumber = parseInt(this.intPageNumber) + 1;
        this.setRecordsToDisplay();
    }

	/*
	 Method Name : setRecordsToDisplay
	 Description : This method sets the records to display.
	 Parameters	 : None
	 Return Type : None
	 */
    setRecordsToDisplay() {
        this.lstRecordsToDisplay = [];

		//If we don't have a page size, we set the total of records.
        if(objUtilities.isNull(this.intPageSize)) {
            this.intPageSize = this.intTotalRecords;
		}

		//Now we calculate the total of pages.
        this.intTotalPages = Math.ceil(this.intTotalRecords / this.intPageSize);

        //Now we set the boundaries of the page numbers.
        if(this.intPageNumber <= 1) {
            this.intPageNumber = 1;
        }else if(this.intPageNumber >= this.intTotalPages) {
            this.intPageNumber = this.intTotalPages;
        }

		//Now we define the records to display.
        for(let intIndex = (this.intPageNumber - 1) * this.intPageSize; intIndex < this.intPageNumber * this.intPageSize; intIndex++) {
            if(intIndex === this.intTotalRecords) {
				break;
			}
			if(objUtilities.isNotNull(this.lstRecords[intIndex])) {
				this.lstRecordsToDisplay.push(this.lstRecords[intIndex]);
			}
        }

		//Now we configure the simplified layout.
		if(this.boolLayoutSimplified) {
			this.configureSimplifiedLayout();
		}

		//Finally, we send the records to display to the parent.
        this.dispatchEvent(new CustomEvent('paginatorchange', {
			detail: this.lstRecordsToDisplay
		}));
    }
}