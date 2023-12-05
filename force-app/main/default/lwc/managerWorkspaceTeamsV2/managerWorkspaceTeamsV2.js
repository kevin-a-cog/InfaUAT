/*

 Change History
 **********************************************************************************************************
 Modified By		Date		Jira No.	Description													Tag
 **********************************************************************************************************
 NA					NA			N/A			Initial version.											N/A
 Vignesh D			07/28/2022	I2RT-6687	Changed fieldname from link to queueLink					T01
 Vignesh D			08/03/2022	I2RT-6875	Set a default width for Name Column							T02
 balajip			01/09/2022	I2RT-6993	Changed the reference to the latest Engineer Workspace		T03
 Vignesh D			03/28/2023	I2RT-7838	Add FTO column and set the classname based on the user FTO	T04
 */

import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyTeamDataRefresh from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getMyTeamDataRefresh';
import getAllTeamDataRefresh from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getAllTeamDataRefresh';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Imports.
import getUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.getUserPreferences';
import setUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.setUserPreferences';

export default class ManagerWorkspaceTeamsV2 extends NavigationMixin(LightningElement) {

	//API variables.
	@api strFieldSetName;

	//Track variables.
	@track lstTeamData;

	//User preferences variable.
	objUserPreferences = new Object();

	//Private variables.
	boolIsUpdatingUserPreferences = false;
	boolIsPoppedOut = false;
	boolGlobalSpinnerShown = true;
	boolIsInitialLoad = true;
	strSelectedTab;
	strTablePrefix = "Teams_";
	objAllTable = new Object();

	//Old variables.
    @api isRaiseHand = false;
    isConfigureAllColumns = false;
    isSelectTeams = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    rawQueueData;
    rawAllTeamData;
    isAllData = false;
    isAllQueueCols = false;

	/*
	 Method Name : updateQueueData
	 Description : This method sets the Queue data.
	 Parameters	 : None
	 Return Type : None
	 */
	updateQueueData() {
		let objParent = this;
		objParent.objAllTable.lstRecords = new Array();
		objParent.objAllTable.lstColumns = objParent.getTableColumns(objParent.objAllTable.strTableId);

		//First we set all the queues data.
        if (this.rawQueueData && Object.keys(this.rawQueueData).length && this.picklistValueProvider.myTeamColumnsPicklistValues && this.picklistValueProvider.myTeamColumnsPicklistValues.length) {
            Object.keys(this.rawQueueData).forEach(key => {
				let userIdStr = Object.keys(this.rawQueueData[key]).filter(k => k.includes('User>>Id~'))[0].split('~')[1];
				let isFTOToday = Object.keys(this.rawQueueData[key]).filter(k => k.includes('User>>Id~'))[0].split('~')[2]; //<T04>
                let row = {
                    queueName: key,
                    queueLink: `/lightning/r/${userIdStr}/view`, //<T01>
                    userId: userIdStr,
                    loginStatusIcon: this.rawQueueData[key]
                        && this.rawQueueData[key]['LoginStatus']
                        && this.rawQueueData[key]['LoginStatus'].intResult == 1 ? 'action:question_post_action' : 'action:close',
                    escalatedIcon: this.rawQueueData[key]
                        && this.rawQueueData[key]['HasEscalations']
						&& this.rawQueueData[key]['HasEscalations'].intResult == 1 ? 'utility:up' : '',
					ftoStatusIcon: isFTOToday == 'true' ? 'out-of-office' : ''	//<T04>
                };                
                this.picklistValueProvider.myTeamColumnsPicklistValues.forEach(col => {
                    if (this.rawQueueData[key] && this.rawQueueData[key][col.label]) {
                        row[col.label] = JSON.stringify({
							strValue: this.rawQueueData[key][col.label].intResult,
							strRow: userIdStr,
							strColumn: col.value,
							intQuery: this.rawQueueData[key][col.label].intQuery,
							strFieldSetName: objParent.strFieldSetName
						});
                    } else {
                        row[col.label] = JSON.stringify({
							strValue: 0,
							strRow: userIdStr,
							strColumn: col.value,
							intQuery: -4,
							strFieldSetName: objParent.strFieldSetName
						});
                    }
                });
				objParent.objAllTable.lstRecords.push(row);
            });
        }

		//Now we sort the data based on the stored value, if any.
		if(objParent.boolIsInitialLoad) {
			objParent.initialSort(objParent.objAllTable.strTableId);
		}
		objParent.boolGlobalSpinnerShown = false;
		objParent.boolIsInitialLoad = false;
	}

	/*
	 Method Name : updateTeamData
	 Description : This method sets the Team data.
	 Parameters	 : None
	 Return Type : None
	 */
	updateTeamData() {
		let objParent = this;
		this.lstTeamData = Array();

		//First we set all the Teams data.
        if(this.rawAllTeamData && Object.keys(this.rawAllTeamData).length) {
            Object.keys(this.rawAllTeamData).forEach(key => {
                let team = {
                    teamName: key
                };

				//Now we initialize the table.
				team.objTable = new Object();
				team.objTable.lstRecords = new Array();
				team.objTable.boolForceRefreshOnSorting = true;
				team.objTable.boolEnablePopOver = false;
				team.objTable.boolDisplayActions = false;
				team.objTable.boolDisplayPaginator = false;
				team.objTable.boolHideCheckboxColumn = true;
				team.objTable.boolAddTotalRow = true;
				team.objTable.strTableId = objParent.strTablePrefix + key;
				team.objTable.objCountRow = {
					queueName: "Total",
					queueLink: "#" //<T01>
				};
				team.objTable.lstColumns = objParent.getTableColumns(team.objTable.strTableId);

				//Now we iterate over the data.
                Object.keys(this.rawAllTeamData[key]).forEach(key1 => {
					let userIdStr = Object.keys(this.rawAllTeamData[key][key1]).filter(k => k.includes('User>>Id~'))[0].split('~')[1];
					let isFTOToday = Object.keys(this.rawAllTeamData[key][key1]).filter(k => k.includes('User>>Id~'))[0].split('~')[2]; //<T04>
                    let row = {
                        queueName: key1,
                        queueLink: `/lightning/r/${userIdStr}/view`, //<T01>
                        userId: userIdStr,
                        loginStatusIcon: this.rawAllTeamData[key][key1]
                            && this.rawAllTeamData[key][key1]['LoginStatus']
							&& this.rawAllTeamData[key][key1]['LoginStatus'].intResult == 1 ? 'action:question_post_action' : 'action:close',
						ftoStatusIcon: isFTOToday == 'true' ? 'out-of-office' : '' //<T04>
                    };
                    if (this.picklistValueProvider.myTeamColumnsPicklistValues && this.picklistValueProvider.myTeamColumnsPicklistValues.length)
                        this.picklistValueProvider.myTeamColumnsPicklistValues.forEach(col => {
                            if (this.rawAllTeamData[key][key1] && this.rawAllTeamData[key][key1][col.label]) {
								row[col.label] = JSON.stringify({
									strValue: this.rawAllTeamData[key][key1][col.label].intResult,
									strRow: userIdStr,
									strColumn: col.value,
									intQuery: this.rawAllTeamData[key][key1][col.label].intQuery,
									strFieldSetName: objParent.strFieldSetName
								});
                            } else {
								row[col.label] = JSON.stringify({
									strValue: 0,
									strRow: userIdStr,
									strColumn: col.value,
									intQuery: -4,
									strFieldSetName: objParent.strFieldSetName
								});
                            }
                        });
					team.objTable.lstRecords.push(row);
                });
				objParent.lstTeamData.push(team);

				//Now we sort the data based on the stored value, if any.
				if(objParent.boolIsInitialLoad) {
					objParent.initialSort(team.objTable.strTableId);
				}
            });
        }
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
				} else if(objUtilities.isNotNull(objParent.lstTeamData)) {
					objParent.lstTeamData.forEach(objTeam => {
						if(objUtilities.isNotNull(objTeam.objTable) && objTeam.objTable.strTableId === strTableName) {
							objTeam.objTable.strSortDirection = objResult.strSortDirection;
							objTeam.objTable.strSortedBy = objResult.strFieldName;
						}
					});
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
		objParent.lstTeamData = Array();
		objParent.objAllTable.lstRecords = new Array();
		getMyTeamDataRefresh({ 
			isRaiseHand: objParent.isRaiseHand
		}).then(objResponse => {
			objParent.rawQueueData = objResponse;
			if(objUtilities.isNotBlank(objParent.allTeamVal)) {
				getAllTeamDataRefresh({ 
					teams: objParent.allTeamVal, 
					isRaiseHand: objParent.isRaiseHand
				}).then(objResult => {
					objParent.rawAllTeamData = objResult;
					objParent.updateTeamData();
					objParent.updateQueueData();
				});
			} else {
				objParent.updateQueueData();
			}
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strComponentName = "c-manager-workspace-teams-v2";

		//Now we set the custom CSS.
		if(!this.boolInitialLoad) {
			this.boolInitialLoad = true;
			this.template.querySelector('.customGeneralCSS').innerHTML = "<style> " + 
					strComponentName + " tr[data-row-key-value=Total] {" + 
					"	background-color: aliceblue;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type .slds-truncate {" + 
					"	width: 100%;" + 
					"	text-align: right;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] td[data-label=Links] lightning-primitive-icon {" + 
					"	display: none;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a:hover, " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a:focus {" + 
					"	text-decoration: none;" + 
					"} " + strComponentName + " tr[data-row-key-value=Total] th:first-of-type a {" + 
					"	color: black;" + 
					"	cursor: default;" + 
					"} </style>";
		}
	}

	/*
	 Method Name : getTableColumns
	 Description : This method returns the columns based on the given table name.
	 Parameters	 : String, called from getTableColumns, strTable Table name.
	 Return Type : List
	 */
	getTableColumns(strTable) {
		let strRaiseHand = "";
		let objParent = this;
		let lstColumns;
		let lstFinalColumns = new Array();

		//We check if it is Raise Hand.
		if(objParent.isRaiseHand) {
			strRaiseHand = "_RaiseHand";
		}

		//We prepare the default values.
		lstFinalColumns = [
			{
				label: '',
				fieldName: '',
				typeAttributes: {
					iconPosition: 'left'
				},
				cellAttributes: {
					iconName: { fieldName: '' },
					class: { fieldName: 'ftoStatusIcon' },
					iconPosition: 'right'
				}
			}, //<T04>
			{
				label: 'Name', sortable: true, fieldName: 'queueLink', type: 'url', typeAttributes: { label: { fieldName: 'queueName' }, target: '_self' } //<T01>
				, cellAttributes:
					{ iconName: { fieldName: 'loginStatusIcon' }, iconPosition: 'left', class: 'login-status' }, class: 'login-status', initialWidth: 160 //<T02>
			}, {
				label: 'Links',
				sortable: true,
				type: 'button-icon',
				typeAttributes: {
					label: 'Actions',
					iconName: 'utility:ad_set',
					name: 'navigate_engineer_workspace',
					title: 'Engineer Workspace',
					value: 'navigate_engineer_workspace',
					variant: 'bare',
					alternativeText: 'Engineer Workspace',
					class: 'fillRed',
					disabled: false,
					iconPosition: 'left'
				},
				cellAttributes: {
					title: 'Engineer Escalations',
					class: 'comments-icn',
					class: 'fillRed',
					iconPosition: 'right'
				}
			}
		];

		//Now we get the columns.
		lstColumns = objParent.objUserPreferences.mapDataTablesFields[strTable + strRaiseHand];
		if(objUtilities.isNull(lstColumns)) {
			lstColumns = objParent.picklistValueProvider.myTeamColumnsPicklistValues;
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
				objParent.picklistValueProvider.myTeamColumnsPicklistValues.forEach(objValue => {
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

    get allColumnList() {
		let strRaiseHand = "";
		let objParent = this;
		let lstColumns;
		let lstFinalRecords = new Array();

		//We check if it is Raise Hand.
		if(objParent.isRaiseHand) {
			strRaiseHand = "_RaiseHand";
		}

		//Now we get the columns.
		lstColumns = objParent.objUserPreferences.mapDataTablesFields[objParent.strSelectedTab + strRaiseHand];
		if(objUtilities.isNotNull(lstColumns)) {
			lstColumns.forEach(strValue => {
				objParent.picklistValueProvider.myTeamColumnsPicklistValues.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
		}
        return lstFinalRecords;
    }

    get allTeams() {
		let objParent = this;
		let lstTeams;
		let lstFinalRecords = new Array();

		//We check if it is Raise Hand.
		if(objParent.isRaiseHand) {
			lstTeams = objParent.objUserPreferences.objManagerWorkspace.lstTeamsRaiseHand;
		} else {
			lstTeams = objParent.objUserPreferences.objManagerWorkspace.lstTeams;
		}

		//Now we get the columns.
		if(objUtilities.isNotNull(lstTeams)) {
			lstTeams.forEach(strValue => {
				objParent.picklistValueProvider.teamsPicklistValues.forEach(objValue => {
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

    get allTeamVal() {
		let strResult = "";
		let objParent = this;
		let lstTeams;
		let lstFinalRecords = new Array();

		//We check if it is Raise Hand.
		if(objParent.isRaiseHand) {
			lstTeams = objParent.objUserPreferences.objManagerWorkspace.lstTeamsRaiseHand;
		} else {
			lstTeams = objParent.objUserPreferences.objManagerWorkspace.lstTeams;
		}

		//We send the string.
		if(objUtilities.isNotNull(lstTeams) && lstTeams.length > 0) {
			lstTeams.forEach(strValue => {
				objParent.picklistValueProvider.teamsPicklistValues.forEach(objValue => {
					if(strValue === objValue.value) {
						lstFinalRecords.push(strValue);
					}
				});
			});
			strResult = lstFinalRecords.join(";");
		}
        return strResult;
    }

    connectedCallback() {
		let objParent = this;
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
		.slds-icon-action-question-post-action .slds-icon {
			display: none !important;
		  }

          .slds-icon-action-close .slds-icon {
			display: none !important;
		  }

          .fillRed svg {
              fill: #63B8FF	;
          }
                                        `;
        document.head.appendChild(globalStyle);

		//We initialize the data tables.
		objParent.objAllTable.boolForceRefreshOnSorting = true;
		objParent.objAllTable.boolEnablePopOver = false;
		objParent.objAllTable.boolDisplayActions = false;
		objParent.objAllTable.boolDisplayPaginator = false;
		objParent.objAllTable.boolHideCheckboxColumn = true;
		objParent.objAllTable.boolAddTotalRow = true;
		objParent.objAllTable.strTableId = "Teams_All";
		objParent.objAllTable.objCountRow = {
			queueName: "Total",
			queueLink: "#" //<T01>
		};

		//First we get the subscription record.
		getUserPreferences().then(objResult => {

			//We store the user preferences.
			objParent.objUserPreferences = objResult;

			//Now we set the columns.
			if(objParent.isRaiseHand) {
				objParent.picklistValueProvider.myTeamColumnsPicklistValues = objParent.objUserPreferences.lstTeamsColumnsRaiseHand;
			} else {
				objParent.picklistValueProvider.myTeamColumnsPicklistValues = objParent.objUserPreferences.lstTeamsColumns;
			}

			//Now we set the teams.
			objParent.picklistValueProvider.teamsPicklistValues = objParent.objUserPreferences.lstTeams;

			//We set the selected tab.
			if(objUtilities.isNotBlank(objResult.objManagerWorkspace.strTeamsSelectedTab)) {
				objParent.picklistValueProvider.teamsPicklistValues.forEach(objValue => {
					if((objParent.strTablePrefix + objValue.value) === objResult.objManagerWorkspace.strTeamsSelectedTab) {
						objParent.strSelectedTab = objResult.objManagerWorkspace.strTeamsSelectedTab;
					}
				});
			}
		}).finally(() => {

			//Now we fetch the data.
			objParent.refreshTable();
		});
    }

    handleMenuSelect(event) {
        switch (event.detail.value) {
            case 'configureAllColumns':
                this.isConfigureAllColumns = true;
                break;

            case 'selectTeams':
                this.isSelectTeams = true;
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
		let strTable = "";
		let objParent = this;
        switch (event.currentTarget.name) {
            case 'cancel':
                this.isConfigureAllColumns = false;
                this.isSelectTeams = false;

				//Now we send the message to the parent to start the Autorefresh, if needed.
				this.dispatchEvent(new CustomEvent('childconfiguration', {
					composed: true,
					bubbles: true,
					cancelable: true,
					detail: 2
				}));
                break;
            case 'save':
                let lstSelectedValues = objParent.template.querySelector('lightning-dual-listbox').value;
				objParent.boolGlobalSpinnerShown = true;
				objParent.boolIsUpdatingUserPreferences = true;
					
				//Now we save the user selection, fetching first the current data.
				getUserPreferences().then(objResult => {

					//We are configuring Columns
					if(objParent.isConfigureAllColumns) {
						strTable = objParent.strSelectedTab;
						if(objParent.isRaiseHand) {
							strTable = strTable + "_RaiseHand";
						}
						objResult.mapDataTablesFields[strTable] = JSON.parse(JSON.stringify(lstSelectedValues));
					} else if (objParent.isSelectTeams) {
						
						//We are configuring Teams.
						if(objParent.isRaiseHand) {
							objResult.objManagerWorkspace.lstTeamsRaiseHand = JSON.parse(JSON.stringify(lstSelectedValues));
						} else {
							objResult.objManagerWorkspace.lstTeams = JSON.parse(JSON.stringify(lstSelectedValues));
						}
					}
		
					//Now we save the new changes.
					objParent.objUserPreferences = objResult;
					setUserPreferences({
						objRecord: objParent.objUserPreferences
					}).finally(() => {
						objParent.boolIsUpdatingUserPreferences = false;
						objParent.isSelectTeams = false;
						objParent.isConfigureAllColumns = false;
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

    handleRowAction(event) {
        const action = event.detail.objEvent.detail.action;
        const row = JSON.parse(JSON.stringify(event.detail.objEvent.detail.row));
        switch (action.value) {
            case 'navigate_engineer_workspace':
                this[NavigationMixin.GenerateUrl](
                    {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c__casePrioritizationViewAura' //T03
                        },
                        state: {
                            c__sSelectedUserId: row.userId,
                            c__sSelectedUserName : row.queueName
                        }

                    }
                ).then(url => {
                 this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
                    if (isConsole) {
                        this.invokeWorkspaceAPI('openTab', {
                          id : null,
                          url: url,
                          focus: true
                        }).then(tabId => {
                            this.invokeWorkspaceAPI('setTabLabel', {
                                tabId: tabId,
                                label: "Engineer Workspace"
                              })
                        });
                    }else{
                        window.open(url) 
                    }
                  });
                }); 
            break;
    	}
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
          const apiEvent = new CustomEvent("internalapievent", {
            bubbles: true,
            composed: true,
            cancelable: false,
            detail: {
              category: "workspaceAPI",
              methodName: methodName,
              methodArgs: methodArgs,
              callback: (err, response) => {
                if (err) {
                   
                    return reject(err);
                } else {
                   
                    return resolve(response);
                }
              }
            }
          });
          window.dispatchEvent(apiEvent);
        });
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
	 Method Name : updateTabSelected
	 Description : This method saves the tab selection.
	 Parameters	 : Object, called from updateTabSelected, objEvent Select event.
	 Return Type : None
	 */
	updateTabSelected(objEvent) {
		let objParent = this;
		if(!objParent.boolGlobalSpinnerShown) {
			objParent.strSelectedTab = objEvent.target.value;
			objParent.boolIsUpdatingUserPreferences = true;

			//Now we save the user selection, fetching first the current data.
			getUserPreferences().then(objResult => {
				objResult.objManagerWorkspace.strTeamsSelectedTab = objParent.strSelectedTab;
	
				//Now we save the new changes.
				objParent.objUserPreferences = objResult;
				setUserPreferences({
					objRecord: objParent.objUserPreferences
				}).finally(() => {
					objParent.boolIsUpdatingUserPreferences = false;
				});
			});
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