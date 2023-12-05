import { api, LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getGEMSData from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getGEMSData';
import getGEMSDataRefresh from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getGEMSDataRefresh';
import getListViewId from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getListViewId';
import getAllListViewId from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getAllListViewId';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Imports.
import getUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.getUserPreferences';
import setUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.setUserPreferences';

//Class body.
export default class ManagerWorkspaceEngagementsV2 extends NavigationMixin(LightningElement) {

	//API variables.
	@api strFieldSetName;

	//User preferences variable.
	objUserPreferences = new Object();

	//Private variables.
	boolIsUpdatingUserPreferences = false;
	boolIsPoppedOut = false;
	boolIsInitialLoadAll = true;
	boolIsInitialLoadTeam = true;
	boolIsAllLoading = true;
	boolIsMyLoading = true;
	objAllTable = new Object();
	objMyTable = new Object();
	lstGEMSColumns;

	/*
	 Method Name : updateQueueData
	 Description : This method sets the Queue data.
	 Parameters	 : None
	 Return Type : None
	 */
	updateAllData() {
		let objParent = this;
		objParent.objAllTable.lstRecords = new Array();
		objParent.objAllTable.lstColumns = this.allGEMSColumns;

		//First we set all the queues data.
        if (this.rawAllGEMSData && Object.keys(this.rawAllGEMSData).length && this.lstGEMSColumns && this.lstGEMSColumns.length) {
			let row = {
				Id: "All GEMS",
				listview: this.allGEMSpageReference ? this.allGEMSpageReference : '/'
			};
			this.lstGEMSColumns.forEach(col => {
				if (this.rawAllGEMSData[col.label]) {
					row[col.label] = JSON.stringify({
						strValue: this.rawAllGEMSData[col.label].intResult,
						strRow: userId,
						strColumn: col.value,
						intQuery: this.rawAllGEMSData[col.label].intQuery,
						strFieldSetName: objParent.strFieldSetName
					});
				} else {
					row[col.label] = JSON.stringify({
						strValue: 0,
						strRow: userId,
						strColumn: col.value,
						intQuery: -4,
						strFieldSetName: objParent.strFieldSetName
					});
				}
			});
			objParent.objAllTable.lstRecords.push(row);
        }

		//Now we get all the Queue links.
		getAllListViewId({
			queueList: objParent.gemsListViews
		}).then(mapResults => {

			//Now we update the links.
			if(objUtilities.isNotNull(mapResults)) {
				objParent.objAllTable.lstRecords.forEach(objRow => {
					if(objUtilities.isNotBlank(mapResults[objParent.gemsListViewsMapping[objRow.Id] + "...Engagement__c"]) && objRow.listview === "/") {
						objRow.listview = "/lightning/o/Engagement__c/list?filterName=" + mapResults[objParent.gemsListViewsMapping[objRow.Id] + "...Engagement__c"];
					}
				});
			}
	
			//Now we sort the data based on the stored value, if any.
			if(objParent.boolIsInitialLoadAll) {
				objParent.boolIsInitialLoadAll = false;
				objParent.initialSort(objParent.objAllTable.strTableId);
			}
		}).finally(() => {
			objParent.boolIsAllLoading = false;
		});
	}

	/*
	 Method Name : updateTeamData
	 Description : This method sets the Team data.
	 Parameters	 : None
	 Return Type : None
	 */
	updateMyData() {
		let objParent = this;
		objParent.objMyTable.lstRecords = new Array();
		objParent.objMyTable.lstColumns = this.myGEMSColumns;

		//First we set all the Teams data.
        if (this.rawMyGEMSData && Object.keys(this.rawMyGEMSData).length && this.lstGEMSColumns && this.lstGEMSColumns.length) {
			let row = {
				Id: "My GEMS",
				listview: this.myGEMSpageReference ? this.myGEMSpageReference : '/'
			};
			this.lstGEMSColumns.forEach(col => {
				if (this.rawMyGEMSData[col.label]) {
					row[col.label] = JSON.stringify({
						strValue: this.rawMyGEMSData[col.label].intResult,
						strRow: userId,
						strColumn: col.value,
						intQuery: this.rawMyGEMSData[col.label].intQuery,
						strFieldSetName: objParent.strFieldSetName
					});
				} else {
					row[col.label] = JSON.stringify({
						strValue: 0,
						strRow: userId,
						strColumn: col.value,
						intQuery: -4,
						strFieldSetName: objParent.strFieldSetName
					});
				}
			});
			objParent.objMyTable.lstRecords.push(row);
        }

		//Now we get all the Queue links.
		getAllListViewId({
			queueList: objParent.gemsListViews
		}).then(mapResults => {

			//Now we update the links.
			if(objUtilities.isNotNull(mapResults)) {
				objParent.objMyTable.lstRecords.forEach(objRow => {
					if(objUtilities.isNotBlank(mapResults[objParent.gemsListViewsMapping[objRow.Id] + "...Engagement__c"]) && objRow.listview === "/") {
						objRow.listview = "/lightning/o/Engagement__c/list?filterName=" + mapResults[objParent.gemsListViewsMapping[objRow.Id] + "...Engagement__c"];
					}
				});
			}
	
			//Now we sort the data based on the stored value, if any.
			if(objParent.boolIsInitialLoadTeam) {
				objParent.boolIsInitialLoadTeam = false;
				objParent.initialSort(objParent.objMyTable.strTableId);
			}
		}).finally(() => {
			objParent.boolIsMyLoading = false;
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
		objParent.objAllTable.lstRecords = new Array();
		objParent.boolIsAllLoading = true;
		objParent.objMyTable.lstRecords = new Array();
		objParent.boolIsMyLoading = true;
		getGEMSDataRefresh({ 
			myGems: true
		}).then(objResponse => {
			objParent.rawMyGEMSData = objResponse;
			objParent.updateMyData();
		});
		getGEMSDataRefresh({ 
			myGems: false
		}).then(objResult => {
			objParent.rawAllGEMSData = objResult;
			objParent.updateAllData();
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strComponentName = "c-manager-workspace-engagements-v2";

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

    @api isRaiseHand = false;
    isConfigureQueues = false;
    isConfigureColumns = false;
    isConfigureAllColumns = false;
    isGEMSEngagement = true;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    queueList = [];
    gemsListViews = ["My GEMS Engagement", "All GEMS Engagement"];
	gemsListViewsMapping = new Array();
    rawGEMSData;
    rawMyGEMSData;
    rawAllGEMSData;
    isAllData = false;
    isAllQueueCols = false;
    gemsWiredData;
    allGEMSpageReference;
    myGEMSpageReference

    get modalHeader() {
        return this.isConfigureQueues
            ? 'Configure Queues'
            : (this.isConfigureColumns || this.isConfigureAllColumns)
                ? 'Configure Columns'
                : '';
    }

    get showModal() {
        return this.isConfigureColumns || this.isConfigureAllColumns;
    }

    get myGEMSColumns() {
        let _columns = [
            {
                label: 'ListView',
                fieldName: 'listview',
                type: 'url',
				sortable: true,
                typeAttributes: {
                    label: { fieldName: 'Id' },
                    target: '_self'
                }
            }
        ];
        if (this.myColumnList.length > 0) {
			this.myColumnList.forEach(col => {
				_columns.push({
					label: col,
					fieldName: col,
					type: 'custom',
					typeAttributes: {
						subtype: "fireEvent"
					},
					sortable: true,
					cellAttributes: { alignment: 'left' }
				});
			});
		} else if (this.lstGEMSColumns && this.lstGEMSColumns.length) {
            this.lstGEMSColumns.forEach(col => {
                _columns.push({
                    label: col.label,
                    fieldName: col.label,
                    type: 'custom',
					typeAttributes: {
						subtype: "fireEvent"
					},
                    sortable: true,
                    cellAttributes: { alignment: 'left' }
                });
            });
        }
        return _columns;
    }

    get allGEMSColumns() {
        let _columns = [
            {
            label: 'ListView',
            fieldName: 'listview',
            type: 'url',
			sortable: true,
            typeAttributes: {
                label: { fieldName: 'Id' },
                target: '_self'
            }
            }
        ];
        if (this.allColumnList.length > 0) {
			this.allColumnList.forEach(col => {
				_columns.push({
					label: col,
					fieldName: col,
					type: 'custom',
					typeAttributes: {
						subtype: "fireEvent"
					},
					sortable: true,
					cellAttributes: { alignment: 'left' }
				});
			});
		} else if (this.lstGEMSColumns && this.lstGEMSColumns.length) {
            this.lstGEMSColumns.forEach(col => {
                _columns.push({
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
        return _columns;
    }

    get myColumnList() {
		let objParent = this;
		let lstFinalRecords = new Array();
		if(objUtilities.isNotNull(objParent.objUserPreferences) && objUtilities.isNotNull(objParent.objUserPreferences.mapDataTablesFields) && 
				objUtilities.isNotNull(objParent.objMyTable.strTableId) && objUtilities.isNotNull(objParent.objUserPreferences.mapDataTablesFields[objParent.objMyTable.strTableId])) {
			objParent.objUserPreferences.mapDataTablesFields[objParent.objMyTable.strTableId].forEach(strValue => {
				objParent.lstGEMSColumns.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    get allColumnList() {
		let objParent = this;
		let lstFinalRecords = new Array();
		if(objUtilities.isNotNull(objParent.objUserPreferences) && objUtilities.isNotNull(objParent.objUserPreferences.mapDataTablesFields) && 
				objUtilities.isNotNull(objParent.objAllTable.strTableId) && objUtilities.isNotNull(objParent.objUserPreferences.mapDataTablesFields[objParent.objAllTable.strTableId])) {
			objParent.objUserPreferences.mapDataTablesFields[objParent.objAllTable.strTableId].forEach(strValue => {
				objParent.lstGEMSColumns.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    @track
    picklistValueProvider = {};
	
    @wire(getListViewId, { queueList: '$gemsListViews', isEngagement: "true" })
    getQueueListViewMap({ error, data }) {
        if (error) {
            console.log('getListViewId error>>>', JSON.stringify(error));
        }
        if (data) {
            console.log('getListViewId data>>', JSON.stringify(data));
            Object.keys(data).forEach(name => {

                this[NavigationMixin.GenerateUrl]({
                    "type": "standard__objectPage",
                    "attributes": {
                        "objectApiName": 'Engagement__c',
                        "actionName": "list"
                    },
                    "state": {
                        "filterName": data[name]
                    }
                }).then(url => {

                    if(name === this.gemsListViews[0]){
                        this.myGEMSpageReference= url;
                    }
                    else{
                        this.allGEMSpageReference =url;
                    }
                });
            });
        }
    }

    @wire(getGEMSData, { myGems: true })
    getMyGEMS(response) {
        let objParent = this;
        this.gemsWiredData = response;
        if (response.error) {
            console.log('My GEMS Error>>>', JSON.stringify(response.error));
        } else if (response.data) {
            this.rawMyGEMSData = response.data;
			objParent.objMyTable.lstRecords = new Array();
			objParent.boolIsMyLoading = true;
			this.updateMyData();
        }
    }

    @wire(getGEMSData, { myGems: false })
    getAllGEMS(response) {
        let objParent = this;
        this.gemsWiredData = response;
        if (response.error) {
            console.log('GEMS Error>>>', JSON.stringify(response.error));
        } else if (response.data) {
            this.rawAllGEMSData =response.data;
			objParent.objAllTable.lstRecords = new Array();
			objParent.boolIsAllLoading = true;
			this.updateAllData();
        }
    }

    connectedCallback() {
		let objParent = this;
		this.gemsListViewsMapping["My GEMS"] = "My GEMS Engagement";
		this.gemsListViewsMapping["All GEMS"] = "All GEMS Engagement";

		//We initialize the data tables.
		objParent.objAllTable.boolForceRefreshOnSorting = true;
		objParent.objAllTable.boolEnablePopOver = false;
		objParent.objAllTable.boolDisplayActions = false;
		objParent.objAllTable.boolDisplayPaginator = false;
		objParent.objAllTable.boolHideCheckboxColumn = true;
		objParent.objAllTable.boolAddTotalRow = true;
		objParent.objAllTable.strTableId = "Engagements_All";
		objParent.objAllTable.objCountRow = {
			Id: "Total",
			listview: "#"
		};
		objParent.objMyTable.boolForceRefreshOnSorting = true;
		objParent.objMyTable.boolEnablePopOver = false;
		objParent.objMyTable.boolDisplayActions = false;
		objParent.objMyTable.boolDisplayPaginator = false;
		objParent.objMyTable.boolHideCheckboxColumn = true;
		objParent.objMyTable.boolAddTotalRow = true;
		objParent.objMyTable.strTableId = "Engagements_My";
		objParent.objMyTable.objCountRow = {
			Id: "Total",
			listview: "#"
		};

		//First we get the subscription record.
		getUserPreferences().then(objResult => {

			//We set the column options.
			objParent.lstGEMSColumns = objResult.lstGEMSColumns;

			//We store the user preferences.
			objParent.objUserPreferences = objResult;
		});
    }

    handleMenuSelect(event) {
        switch (event.detail.value) {
            case 'configureColumns':
                this.isConfigureColumns = true;
                break;
            case 'configureAllColumns':
                this.isConfigureAllColumns = true;
                break;
            default:
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
		let strTable;
		let objParent = this;
        switch (event.currentTarget.name) {
            case 'cancel':
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
                let lstSelectedColumns = this.template.querySelector('lightning-dual-listbox').value;
                if (this.isConfigureAllColumns) {
					strTable = objParent.objAllTable.strTableId;
                }
                if (this.isConfigureColumns) {
					strTable = objParent.objMyTable.strTableId;
                }
                this.isConfigureColumns = false;
                this.isConfigureAllColumns = false;

				//Finally we save the selection.
				if(objUtilities.isNotBlank(strTable)) {

					//Now we save the user selection, fetching first the current data.
					objParent.boolIsAllLoading = true;
					objParent.boolIsMyLoading = true;
					objParent.boolIsUpdatingUserPreferences = true;
					getUserPreferences().then(objResult => {
						objResult.mapDataTablesFields[strTable] = JSON.parse(JSON.stringify(lstSelectedColumns));
			
						//Now we save the new changes.
						objParent.objUserPreferences = objResult;
						setUserPreferences({
							objRecord: objParent.objUserPreferences
						}).finally(() => {
							objParent.boolIsUpdatingUserPreferences = false;
							objParent.boolIsAllLoading = false;
							objParent.boolIsMyLoading = false;
							objParent.objAllTable.lstColumns = objParent.allGEMSColumns;
							objParent.objMyTable.lstColumns = objParent.myGEMSColumns;
							objParent.boolIsInitialLoadAll = true;
							objParent.boolIsInitialLoadTeam = true;
							objParent.refreshTable();
						});
					});
				}
            break;
        }
    }

    @api
    refreshData() {
        this.refreshTable();
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
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