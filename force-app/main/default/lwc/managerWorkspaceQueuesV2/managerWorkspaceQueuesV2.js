/*

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								 Tag
 **********************************************************************************************************
 NA						NA				N/A				Initial version.						 N/A
 Vignesh D              7/21/2022       I2RT-6689       Exclude Escalation Managers queue from   T01
 														displaying in Attention Request
 Vignesh D              8/3/2022        I2RT-6875       Set a default width for Name Column		 T02	 
 */

import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllListViewId from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getAllListViewId';
import getAllQueuesDataRefresh from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getAllQueuesDataRefresh';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Imports.
import getUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.getUserPreferences';
import setUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.setUserPreferences';

//Class body.
export default class ManagerWorkspaceQueuesV2 extends NavigationMixin(LightningElement) {

	//API variables.
	@api strFieldSetName;

	//Count row variables.
	boolInitialLoad = false;

	//User preferences variable.
	objUserPreferences = new Object();

	//Private variables.
	boolIsUpdatingUserPreferences = false;
	boolGlobalSpinnerShown = true;
	boolIsPoppedOut = false;
	boolIsInitialLoad = true;
	objAllTable = new Object();
	objMyTable = new Object();

	//Old variables.
	@api isRaiseHand = false;
    @api isUrgentRequest = false;
    @track pageReferenceMap = {};
    @track picklistValueProvider = {};
    isConfigureQueues = false;
    isConfigureColumns = false;
    isConfigureAllColumns = false;
    queueList = [];
    rawQueueData;

	/*
	 Method Name : updateQueuesData
	 Description : This method sets the My Queue and All Queues data.
	 Parameters	 : None
	 Return Type : None
	 */
	updateQueuesData() {
		let objParent = this;
		objParent.objAllTable.lstRecords = new Array();
		objParent.objAllTable.lstColumns = objParent.getTableColumns(objParent.objAllTable.strTableId);
		objParent.objMyTable.lstRecords = new Array();
		objParent.objMyTable.lstColumns = objParent.getTableColumns(objParent.objMyTable.strTableId);

		//First we set all the queues data.
        if(this.rawQueueData && Object.keys(this.rawQueueData).length) {
            Object.keys(this.rawQueueData).forEach(key => {
                let row = {
                    queueName: key,
                    queueLink: objParent.pageReferenceMap[key] ? objParent.pageReferenceMap[key] : '/'
                };
                objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(col => {
					if (objParent.rawQueueData[key] && objParent.rawQueueData[key][col.label]) {
						row[col.label] = JSON.stringify({
							strValue: objParent.rawQueueData[key][col.label].intResult,
							strRow: key,
							strColumn: col.value,
							intQuery: objParent.rawQueueData[key][col.label].intQuery,
							strFieldSetName: objParent.strFieldSetName
						});
					} else {
						row[col.label] = JSON.stringify({
							strValue: 0,
							strRow: key,
							strColumn: col.value,
							intQuery: -4,
							strFieldSetName: objParent.strFieldSetName
						});
					}
                });
                objParent.objAllTable.lstRecords.push(row);
            });
        }

		//Now we get all the Queue links.
		getAllListViewId({
			queueList: objParent.queueList
		}).then(mapResults => {

			//Now we update the links.
			if(objUtilities.isNotNull(mapResults)) {
				objParent.objAllTable.lstRecords.forEach(objRow => {
					if(objUtilities.isNotBlank(mapResults[objRow.queueName + "..." + (objParent.isRaiseHand ? 'Raise_Hand__c' : (objParent.isUrgentRequest ? 'Case_Comment__c': "Case"))]) && 
							objRow.queueLink === "/") {
						objRow.queueLink = "/lightning/o/" + (objParent.isRaiseHand ? 'Raise_Hand__c' : (objParent.isUrgentRequest ? 'Case_Comment__c': "Case")) + "/list?filterName=" + 
								mapResults[objRow.queueName + "..." + (objParent.isRaiseHand ? 'Raise_Hand__c' : (objParent.isUrgentRequest ? 'Case_Comment__c': "Case"))];
					}
				});
			}

			//Now we set the My Queue data.
			if(objParent.objAllTable.lstRecords && objParent.objAllTable.lstRecords.length && objParent.myQueueList) {
				objParent.myQueueList.forEach(objColumn => {
					objParent.objAllTable.lstRecords.forEach(objRow => {
						if(objColumn == objRow.queueName) {
							objParent.objMyTable.lstRecords.push(objRow);
						}
					});
				});
			}
	
			//Now we sort the data based on the stored value, if any.
			if(objParent.boolIsInitialLoad) {
				objParent.boolIsInitialLoad = false;
				objParent.initialSort(objParent.objAllTable.strTableId);
				objParent.initialSort(objParent.objMyTable.strTableId);
			}
		}).finally(() => {
			objParent.boolGlobalSpinnerShown = false;
		});
	}
	
	/*
	 Method Name : initialSort
	 Description : This method sets the initial sorting of the given table.
	 Parameters	 : String, called from initialSort, strTableName Table name.
	 Return Type : None
	 */
	initialSort(strTableName) {
		let objResult;
		let objParent = this;

		//We execute this only if it is the first time loading.
		if(objUtilities.isNotNull(objParent.objUserPreferences) && objUtilities.isNotNull(objParent.objUserPreferences.mapDataTablesSorting)) {
			objResult = objParent.objUserPreferences.mapDataTablesSorting[strTableName];

			//Now we ensure the parameters are correct.
			if(objUtilities.isNotNull(objResult)) {
						
				//Depending on the table, we store the initial sorting.
				if(strTableName === objParent.objAllTable.strTableId) {
					objParent.objAllTable.strSortDirection = objResult.strSortDirection;
					objParent.objAllTable.strSortedBy = objResult.strFieldName;
				} else {
					objParent.objMyTable.strSortDirection = objResult.strSortDirection;
					objParent.objMyTable.strSortedBy = objResult.strFieldName;
				}
			}
		}
	}
	
	/*
	 Method Name : refreshTable
	 Description : This method refreshes the tables of the component.
	 Parameters	 : None
	 Return Type : None
	 */
	refreshTable() {
		let objParent = this;
		objParent.boolGlobalSpinnerShown = true;
		objParent.objAllTable.lstRecords = new Array();
		objParent.objMyTable.lstRecords = new Array();
		getAllQueuesDataRefresh({ 
			queueList: this.queueList, 
			isRaiseHand: this.isRaiseHand,
			isUrgentRequest: this.isUrgentRequest
		}).then(objResponse => {
			objParent.rawQueueData = objResponse;
			objParent.updateQueuesData();
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strComponentName = "c-manager-workspace-queues-v2";

		//Now we set the custom CSS.
		if(!this.boolInitialLoad) {
			this.boolInitialLoad = true;
			this.template.querySelector('.customGeneralCSS').innerHTML = "<style> " + 
					strComponentName + " tr[data-row-key-value=Total] {" + 
					"	background-color: aliceblue;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type .slds-truncate {" + 
					"	width: 100%;" + 
					"	text-align: right;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a:hover, " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a:focus {" + 
					"	text-decoration: none;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a {" + 
					"	color: black;" + 
					"	cursor: default;" + 
					"} </style>";
		}
	}

    get modalHeader() {
        return this.isConfigureQueues
            ? 'Configure Queues'
            : (this.isConfigureColumns || this.isConfigureAllColumns)
                ? 'Configure Columns'
                : '';
    }

    get showModal() {
        return this.isConfigureQueues || this.isConfigureColumns || this.isConfigureAllColumns;
    }

	/*
	 Method Name : getTableColumns
	 Description : This method returns the columns based on the given table name.
	 Parameters	 : String, called from getTableColumns, strTable Table name.
	 Return Type : List
	 */
	getTableColumns(strTable) {
		let objParent = this;
		let lstColumns;
		let lstFinalColumns;

		//We check if it is Raise Hand.
		if(objParent.isRaiseHand) {
			strTable = strTable + "_RaiseHand";
		} else if(objParent.isRaiseHand) {
			strTable = strTable + "_UrgentRequest";
		}

		//We prepare the default values.
		lstFinalColumns = [
			{
				label: 'Name',
				fieldName: 'queueLink',
				type: 'url',
				sortable:true,
				typeAttributes: {
					label: { fieldName: 'queueName' },
					target: '_self'
				},
				initialWidth: 160 //<T02>
			}
		];

		//Now we get the columns.
		lstColumns = objParent.objUserPreferences.mapDataTablesFields[strTable];
		if(objUtilities.isNull(lstColumns)) {
			lstColumns = objParent.picklistValueProvider.lstAvailableQueueColumns;
			if(objUtilities.isNotNull(lstColumns)) {
				lstColumns.forEach(col => {
					lstFinalColumns.push({
						label: col.value,
						fieldName: col.value,
						type: 'custom',
						typeAttributes: {
							subtype: "fireEvent"
						},
						sortable: true,
						cellAttributes: { alignment: 'left' }
					});
				});
			}
		} else {
			lstColumns.forEach(strValue => {
				objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalColumns.push({
							label: strValue,
							fieldName: strValue,
							type: 'custom',
							typeAttributes: {
								subtype: "fireEvent"
							},
							sortable: true,
							cellAttributes: { alignment: 'left' }
						});
					}
				});
			});
		}
		return lstFinalColumns;
	}

    get myQueueList() {
		let objParent = this;
        let lstRecords;
		let lstFinalRecords = new Array();

		//We calculate the table name.
		if(objParent.isRaiseHand) {
			lstRecords = objParent.objUserPreferences.objManagerWorkspace.lstQueuesRaiseHand;
		} else if(objParent.isUrgentRequest) {
			lstRecords = objParent.objUserPreferences.objManagerWorkspace.lstQueuesUrgentRequest;
		} else {
			lstRecords = objParent.objUserPreferences.objManagerWorkspace.lstQueues;
		}
		if(objUtilities.isNull(lstRecords) || lstRecords.length === 0) {
			objParent.picklistValueProvider.queuesPicklistValues.forEach(objValue => {
				lstFinalRecords.push(objValue.value);
			});
		} else {
			lstRecords.forEach(strValue => {
				objParent.picklistValueProvider.queuesPicklistValues.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    get myColumnList() {
		let strTable = this.objMyTable.strTableId;
		let objParent = this;
        let lstRecords;
		let lstFinalRecords = new Array();

		//We calculate the table name.
		if(objParent.isRaiseHand) {
			strTable = strTable + "_RaiseHand";
		} else if(objParent.isRaiseHand) {
			strTable = strTable + "_UrgentRequest";
		}
		lstRecords = objParent.objUserPreferences.mapDataTablesFields[strTable];
		if(objUtilities.isNull(lstRecords) || lstRecords.length === 0) {
			objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(objValue => {
				lstFinalRecords.push(objValue.value);
			});
		} else {
			lstRecords.forEach(strValue => {
				objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    get allColumnList() {
		let strTable = this.objAllTable.strTableId;
		let objParent = this;
        let lstRecords;
		let lstFinalRecords = new Array();

		//We calculate the table name.
		if(objParent.isRaiseHand) {
			strTable = strTable + "_RaiseHand";
		} else if(objParent.isRaiseHand) {
			strTable = strTable + "_UrgentRequest";
		}
		lstRecords = objParent.objUserPreferences.mapDataTablesFields[strTable];
		if(objUtilities.isNull(lstRecords) || lstRecords.length === 0) {
			objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(objValue => {
				lstFinalRecords.push(objValue.value);
			});
		} else {
			lstRecords.forEach(strValue => {
				objParent.picklistValueProvider.lstAvailableQueueColumns.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    connectedCallback() {
		let objParent = this;

		//We display the spinner.
		objParent.boolGlobalSpinnerShown = true;

		//We initialize the data tables.
		objParent.objAllTable.boolForceRefreshOnSorting = true;
		objParent.objAllTable.boolEnablePopOver = false;
		objParent.objAllTable.boolDisplayActions = false;
		objParent.objAllTable.boolDisplayPaginator = false;
		objParent.objAllTable.boolHideCheckboxColumn = true;
		objParent.objAllTable.boolAddTotalRow = true;
		objParent.objAllTable.strTableId = objParent.strFieldSetName + "Queues_All";
		objParent.objAllTable.objCountRow = {
			queueName: "Total",
			queueLink: "#"
		};
		objParent.objMyTable.boolForceRefreshOnSorting = true;
		objParent.objMyTable.boolEnablePopOver = false;
		objParent.objMyTable.boolDisplayActions = false;
		objParent.objMyTable.boolDisplayPaginator = false;
		objParent.objMyTable.boolHideCheckboxColumn = true;
		objParent.objMyTable.boolAddTotalRow = true;
		objParent.objMyTable.strTableId = objParent.strFieldSetName + "Queues_My";
		objParent.objMyTable.objCountRow = {
			queueName: "Total",
			queueLink: "#"
		};

		//Now we get the subscription record.
		getUserPreferences().then(objResult => {
			objParent.queueList = new Array();

			//We store the user preferences.
			objParent.objUserPreferences = objResult;

			//Now we set the picklist values.
			if(objParent.isRaiseHand) {
				objParent.picklistValueProvider.lstAvailableQueueColumns = objParent.objUserPreferences.lstQueueColumnsRaiseHand;
				objParent.picklistValueProvider.queuesPicklistValues = objParent.objUserPreferences.lstQueuesRaiseAndUrgent;
			} else if(objParent.isUrgentRequest) {
				objParent.picklistValueProvider.lstAvailableQueueColumns = objParent.objUserPreferences.lstQueueColumnsUrgentRequest;
				objParent.picklistValueProvider.queuesPicklistValues = objParent.objUserPreferences.lstQueuesRaiseAndUrgent?.filter(obj => obj.value !== 'Escalation Managers'); //<T01>
			} else {
				objParent.picklistValueProvider.lstAvailableQueueColumns = objParent.objUserPreferences.lstQueueColumns;
				objParent.picklistValueProvider.queuesPicklistValues = objParent.objUserPreferences.lstQueues;
			}
			objParent.picklistValueProvider.queuesPicklistValues.forEach(objQueue => {
                objParent.queueList.push(objQueue.value);
            });

			//Now we get the mapping for the list view Ids.
			return getUserPreferences({ 
				queueList: objParent.queueList,
				isRaiseHand: objParent.isRaiseHand,
				isUrgentRequest: objParent.isUrgentRequest
			});
		}).then(mapResults => {
			Object.keys(mapResults).forEach(queue => {
				objParent[NavigationMixin.GenerateUrl]({
					"type": "standard__objectPage",
					"attributes": {
						"objectApiName": objParent.isRaiseHand ? 'Raise_Hand__c' : (objParent.isUrgentRequest ? 'Case_Comment__c': "Case"),
						"actionName": "list"
					},
					"state": {
						"filterName": mapResults[queue]
					}
				}).then(url => {
					objParent.pageReferenceMap[queue] = url;
				});
			});
		}).finally(() => {
			objParent.refreshTable();
		});
    }

    handleMenuSelect(event) {
        switch (event.detail.value) {
            case 'configureQueues':
                this.isConfigureQueues = true;
                break;

            case 'configureColumns':
                this.isConfigureColumns = true;
                break;

            case 'configureAllColumns':
                this.isConfigureAllColumns = true;
                break;
        }

		//Now we send the message to the parent to stop the Autorefresh, if the user is configuring the card.
		this.dispatchEvent(new CustomEvent('childconfiguration', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: 1
		}));
    }

    handleClick(event) {
		let strTable = "";
		let objParent = this;
		let lstSelectedValues;
        switch (event.currentTarget.name) {
            case 'cancel':
                this.isConfigureQueues = false;
                this.isConfigureColumns = false;
                this.isConfigureAllColumns = false;

				//Now we send the message to the parent to start the Autorefresh, if needed.
				this.dispatchEvent(new CustomEvent('childconfiguration', {
					composed: true,
					bubbles: true,
					cancelable: true,
					detail: 2
				}));
            break;
            case 'save':
				objParent.boolGlobalSpinnerShown = true;
				objParent.boolIsUpdatingUserPreferences = true;
				lstSelectedValues = objParent.template.querySelector('lightning-dual-listbox').value;

				//Now we save the user selection, fetching first the current data.
				getUserPreferences().then(objResult => {
					
					//Configuring Queues.
					if(objParent.isConfigureQueues) {
						if(objParent.isRaiseHand) {
							objResult.objManagerWorkspace.lstQueuesRaiseHand = JSON.parse(JSON.stringify(lstSelectedValues));
						} else if(objParent.isUrgentRequest) {
							objResult.objManagerWorkspace.lstQueuesUrgentRequest = JSON.parse(JSON.stringify(lstSelectedValues));
						} else {
							objResult.objManagerWorkspace.lstQueues = JSON.parse(JSON.stringify(lstSelectedValues));
						}
					} else {
					
						//Configuring columns.
						if(objParent.isConfigureAllColumns) {
							strTable = objParent.objAllTable.strTableId;
						} else {
							strTable = objParent.objMyTable.strTableId;
						}
						if(objParent.isRaiseHand) {
							strTable = strTable + "_RaiseHand";
						} else if(objParent.isRaiseHand) {
							strTable = strTable + "_UrgentRequest";
						}
						objResult.mapDataTablesFields[strTable] = JSON.parse(JSON.stringify(lstSelectedValues));
					}
		
					//Now we save the new changes.
					objParent.objUserPreferences = objResult;
					setUserPreferences({
						objRecord: objParent.objUserPreferences
					}).finally(() => {
						objParent.boolIsUpdatingUserPreferences = false;
						objParent.isConfigureQueues = false;
						objParent.isConfigureColumns = false;
						objParent.isConfigureAllColumns = false;
						objParent.objAllTable.lstColumns = objParent.getTableColumns(objParent.objAllTable.strTableId);
						objParent.objMyTable.lstColumns = objParent.getTableColumns(objParent.objMyTable.strTableId);
						objParent.boolIsInitialLoad = true;
						objParent.refreshTable();
					});
				});
        	break;
        }
    }

    @api
    refreshData() {
        this.refreshTable();
    }

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, strTableId, objPayload } = objEvent.detail;
		let objParent = this;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 100:

				//Now we save the user selection, fetching first the current data.
				if(!objParent.boolIsUpdatingUserPreferences) {
					getUserPreferences().then(objResult => {
		
						//Now we update the sorting.
						objResult.mapDataTablesSorting[strTableId] = {
							strFieldName: objPayload.strFieldName,
							strSortDirection: objPayload.strSortDirection
						};
			
						//Now we save the new changes.
						objParent.objUserPreferences = objResult;
						setUserPreferences({
							objRecord: objParent.objUserPreferences
						});
					});
				}
			break;
			case 101:
				
				//The user has clicked in a link on a custom cell, so we send the message to the container, to open the modal.
				this.dispatchEvent(new CustomEvent('openmodal', {
					composed: true,
					bubbles: true,
					cancelable: true,
					detail: objPayload
				}));
			break;
		}
    }

	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : None
	 Return Type : None
	 */
	popOut() {
		this.boolIsPoppedOut = !this.boolIsPoppedOut;
		this.dispatchEvent(new CustomEvent('popout', {
			composed: true,
			bubbles: true,
			cancelable: true
		}));
    }

	/*
	 Method Name : closeModal
	 Description : This method changes the pop out icon to closed.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	closeModal() {
		this.boolIsPoppedOut = false;
    }
}