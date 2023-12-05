/*
 * Name			:	GlobalDataTable
 * Author		:	Gabriel Coronel
 * Created Date	: 	9/2/2021
 * Description	:	This LWC exposes the generic Data Table component created for Global.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Gabriel Coronel		9/2/2021		N/A				Initial version.					N/A
 Amit Garg				30/11/2021		IR2T-4832		To display parent objet fields		T01
 Alex Cajica		    11/01/2022		N/A				COPADO Sync							N/A
 Vignesh Divakaran		27/07/2022		I2RT-6687		Replace queue column name while		T02
 														sorting in Manager Workspace
 Anusha Akella          11/23/2022		AR-3036         Adding Logic for Nested & unhide save button without Payload<T03>												
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import No_Records_Found from '@salesforce/label/c.No_Records_Found';
import Save_Changes from '@salesforce/label/c.Save_Changes';

//Class body.
export default class GlobalDataTable extends LightningElement {

	//API variables.
	@api objParameters;
	@api loadInLineButtons;
	@api boolExcludedScenario = false;
	@api displayvalue;
	@api booldisplaycopy;
	@api enableEditing;
	@api sliderMinRange;
	@api sliderMaxRange;
	@api sliderStepRange;
	@api boolShowPreviewIcon;
	@api boolEnableEditFrmParent;
	@api hasNestedChilds;
	@api viewMode = false;
	@api boolEnhancedCollapseSystem;
	@api boolShowStripes = false;

	//Track variables.
	@track lstRecords;

	//Private variables.
	boolEnableTreeView;
	boolIsTreeView;
	boolForceRefreshOnSorting;
	boolIsLoadingTable = false;
	boolCustomCSSLoaded = false;
	boolForceCheckboxes;
	boolDisplayNoRecordsFound;
	boolPreselectedRowsLoaded;
	boolEnablePopOver;
	boolHideTableHeader;
	boolHideCheckboxColumn;
	boolHasRecords;
	boolDisplayPaginator;
	boolSuppressBottomBar;
	boolDisplayActions;
	boolDisplayTableActions;
	boolDisplayTableActionsCustom;
	boolDisplayPopOver;
	boolDisplayLayoutTable;
	boolAddTotalRow;
	intMousePositionX;
	intMousePositionY;
	intColspan;
	intLayoutType;
	intMaximumRowSelection;
	intRowNumberOffsetRecords;
	strPaginatorComponent = '.globalDataTableIdentifier';
	strGlobalTableId;
	strKeyField
	strLinkCellId;
	strLinkCellObjectName;
	strSortedBy;
	strTableStyleClasses;
	strPaginatorStyleClasses;
	objColumns;
	objConfiguration;
	objCountRow;
	objMouseListener;
	lstOriginalRecords;
	lstColumns;
	lstPreSelectedRows;
	lstDraftValues;
	lstSelectedRecords;
	nestedParentIds;
	mapParentChildRelationship;

	//Labels.
	label = {
		No_Records_Found,
		Save_Changes
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	
	connectedCallback() {
		let intCounter = 0;
		let intCounterInternal = 0;
		let objParent = this;

		//First we generation the table Id.
		this.strGlobalTableId = "" + (new Date()).getTime();

		//We define the configuration parameters.
		this.boolHasRecords = false;
		this.boolDisplayPopOver = false;
		this.boolDisplayTableActions = false;
		this.boolDisplayTableActionsCustom = false;
		this.boolDisplayTableActionsSaveInline = false;
		this.boolPreselectedRowsLoaded = false;
		
		if(this.loadInLineButtons) {
			this.boolDisplayTableActionsSaveInline = true;
			this.boolDisplayTableActions = true;
		}
	
		//If we received data.
		if(objUtilities.isNotNull(this.objParameters)) {
			this.boolEnableTreeView = this.objParameters.boolEnableTreeView;
			this.boolIsTreeView = this.objParameters.boolIsTreeView;
			this.boolForceRefreshOnSorting = this.objParameters.boolForceRefreshOnSorting;
			this.boolAddTotalRow = this.objParameters.boolAddTotalRow;
			this.boolForceCheckboxes = this.objParameters.boolForceCheckboxes;
			this.boolDisplayNoRecordsFound = this.objParameters.boolDisplayNoRecordsFound;
			this.boolEnablePopOver = this.objParameters.boolEnablePopOver;
			this.boolPreSelectAllCheckboxes = this.objParameters.boolPreSelectAllCheckboxes;
			this.boolDisplayActions = this.objParameters.boolDisplayActions;
			this.boolHideTableHeader = this.objParameters.boolHideTableHeader;
			this.boolHideCheckboxColumn = this.objParameters.boolHideCheckboxColumn;
			this.boolDisplayPaginator = this.objParameters.boolDisplayPaginator;
			this.boolSuppressBottomBar = this.objParameters.boolSuppressBottomBar;
			this.intLayoutType = this.objParameters.intLayoutType;
			this.intMaximumRowSelection = this.objParameters.intMaximumRowSelection;
			this.strKeyField = this.objParameters.strKeyField;
			this.mapParentChildRelationship = this.objParameters.mapParentChildRelationship;

			this.objConfiguration = {
				strDefaultSortDirection: this.objParameters.strDefaultSortDirection,
				strSortDirection: this.objParameters.strSortDirection
			}
			if(this.objParameters.objTable) {
				this.strTableStyleClasses = this.objParameters.objTable.strStyleClasses;
			}
			if(this.objParameters.objPaginator) {
				this.strPaginatorStyleClasses = this.objParameters.objPaginator.strStyleClasses;
			}
	
			//Now we preselect rows, if any.
			this.lstPreSelectedRows = this.objParameters.lstPreSelectedRows;
			if(objUtilities.isNull(this.lstPreSelectedRows)) {
				this.lstPreSelectedRows = new Array();
			}

			//We default values.
			if(objUtilities.isNotNull(this.objParameters.objCountRow)) {
				this.objCountRow = {... this.objParameters.objCountRow};
			}
			if(objUtilities.isNull(this.objParameters.lstRecords)) {
				this.lstRecords = new Array();
			} else {
				this.lstRecords = JSON.parse(JSON.stringify(this.objParameters.lstRecords));
			}

			//If we received a table with no collapsible child rows, we prepare the table.
			if(this.objParameters.boolHasCollapsibleRows) {
				this.objColumns = JSON.parse(JSON.stringify(this.objParameters.objColumns));
			} else if(objUtilities.isNotNull(this.objParameters.lstColumns)) {
				this.lstColumns = JSON.parse(JSON.stringify(this.objParameters.lstColumns));
			}
		} else {
			this.objConfiguration = new Object();
			this.lstRecords = new Array();
			this.lstColumns = new Array();
		}

		//Now, we review we have received valid parameters, otherwise we set the default ones.
		if(objUtilities.isNull(this.boolEnableTreeView)) {
			this.boolEnableTreeView = false;
		}
		if(objUtilities.isNull(this.boolIsTreeView)) {
			this.boolIsTreeView = true;
		}
		if(objUtilities.isNull(this.boolAddTotalRow)) {
			this.boolAddTotalRow = false;
		}
		if(objUtilities.isNull(this.boolDisplayNoRecordsFound)) {
			this.boolDisplayNoRecordsFound = true;
		}
		if(objUtilities.isNull(this.boolEnablePopOver)) {
			this.boolEnablePopOver = true;
		}
		if(objUtilities.isNull(this.boolPreSelectAllCheckboxes)) {
			this.boolPreSelectAllCheckboxes = false;
		}
		if(objUtilities.isNull(this.boolDisplayActions)) {
			this.boolDisplayActions = true;
		}
		if(objUtilities.isNull(this.boolDisplayPaginator)) {
			this.boolDisplayPaginator = true;
		}
		if(objUtilities.isNull(this.boolSuppressBottomBar)) {
			this.boolSuppressBottomBar = true;
		}
		if(objUtilities.isNull(this.boolHideTableHeader)) {
			this.boolHideTableHeader = false;
		}
		if(objUtilities.isNull(this.boolHideCheckboxColumn)) {
			this.boolHideCheckboxColumn = false;
		}
		if(objUtilities.isNull(this.intLayoutType)) {
			this.intLayoutType = 1;
		}
		if(objUtilities.isNull(this.lstRecords)) {
			this.lstRecords = new Array();
		}
		if(objUtilities.isNull(this.intMaximumRowSelection)) {
			this.intMaximumRowSelection = this.lstRecords.length;
		}
		if(objUtilities.isBlank(this.objConfiguration.strDefaultSortDirection)) {
			this.objConfiguration.strDefaultSortDirection = "asc";
		}
		if(objUtilities.isBlank(this.objConfiguration.strSortDirection)) {
			this.objConfiguration.strSortDirection = "asc";
		}
		if(objUtilities.isBlank(this.strTableStyleClasses)) {
			this.strTableStyleClasses = "";
		}
		if(objUtilities.isBlank(this.strPaginatorStyleClasses)) {
			this.strPaginatorStyleClasses = "";
		}
		if(objUtilities.isBlank(this.strKeyField)) {
			this.strKeyField = "Id";
		}
		if(objUtilities.isNotBlank(this.objParameters.strSortedBy)) {
			this.strSortedBy = this.objParameters.strSortedBy;
		}
		if(objUtilities.isNull(this.objColumns)) {
			this.objColumns = new Object();
			this.objColumns.objHeaders = new Object();
		}
		if(objUtilities.isNull(this.lstColumns)) {
			this.lstColumns = new Array();
		}
		if(objUtilities.isNull(this.mapParentChildRelationship)) {
			this.mapParentChildRelationship = new Array();
		}
		
		//If we have collapsible rows.
		if(this.objParameters.boolHasCollapsibleRows) {
			//First we add the collapsible icon column.
			if(objUtilities.isNotNull(this.objColumns) && objUtilities.isNotNull(this.objColumns.lstColumns)) {
				this.objColumns.lstColumns.unshift({
					strLabel: "",
					strStyle: "width: 5px;"
				});
			}
			if(objUtilities.isNotNull(this.lstRecords)) {
				this.lstRecords.forEach(objRecord => {
					if(objUtilities.isNotNull(objRecord.lstParentData)) {
						intCounterInternal++;
						objRecord.lstParentData.unshift({
							boolIsIcon: true,
							intAction: 1,
							strLocalId: "" + intCounterInternal,
							strTDStyle: "cursor: pointer;",
							strIconName: "utility:chevronright"
						});
						objRecord.intTotalColumns = objRecord.lstParentData.length;
						objRecord.intNumberOfColumns = objRecord.lstParentData.length - 1;
					}
				});
			}

			//Now we check if we need to display the columns' headers or not.
			if(objUtilities.isNotNull(this.objColumns)) {
				if(objUtilities.isNull(this.objColumns.objHeaders)) {
					this.objColumns.objHeaders = new Object();
				}
				if(objUtilities.isNull(this.objColumns.objHeaders.boolDisplayChildRecords)) {
					this.objColumns.objHeaders.boolDisplayChildRecords = true;
				}
	
				//Now we look for specific column types and take proper actions.
				intCounterInternal = 0;
				if(objUtilities.isNotNull(this.objColumns.lstColumns)) {
					this.objColumns.lstColumns.forEach(objColumn => {
						switch(objColumn.intType) {
							case 1:
								objParent.lstRecords.forEach(objRecord => {
									if(objUtilities.isNotNull(objRecord.lstParentData)) {
										intCounterInternal++;
										objRecord.lstParentData.push({
											boolIsButtonMenu: true,
											intAction: 2,
											strLocalId: "" + intCounterInternal,
											strIconName: objColumn.strIconName,
											lstItems: objColumn.lstItems
										});
									}
								});
							break;
							case 2:
								objParent.lstRecords.forEach(objRecord => {
									if(objUtilities.isNotNull(objRecord.lstParentData)) {
										intCounterInternal++;
										objRecord.lstParentData.push({
											boolIsIcon: true,
											intAction: 7,
											strLocalId: "" + intCounterInternal,
											strIconName: objColumn.strIconName,
											strClasses: objColumn.strClasses
										});
									}
								});
							break;
							case 3:
								objParent.lstRecords.forEach(objRecord => {
									if(objUtilities.isNotNull(objRecord.lstParentData)) {
										intCounterInternal++;
										objRecord.lstParentData.push({
											boolIsIcon: true,
											intAction: 11,
											strLocalId: "" + intCounterInternal,
											strIconName: objColumn.strIconName,
											strClasses: objColumn.strClasses
										});
									}
								});
							break;
						}
					});
				}

				//Now we check child records.
				intCounterInternal = 0;
				if(objUtilities.isNotNull(this.objColumns.lstChildRecordsColumns)) {
					this.objColumns.lstChildRecordsColumns.forEach(objColumn => {
						switch(objColumn.intType) {
							case 1:
								objParent.lstRecords.forEach(objRecord => {
									if(objUtilities.isNotNull(objRecord.lstChildRecords)) {
										objRecord.lstChildRecords.forEach(objChild => {
											if(objUtilities.isNotNull(objChild.lstData)) {
												intCounterInternal++;
												objChild.lstData.push({
													boolIsButtonMenu: true,
													intAction: 3,
													strLocalId: "" + intCounterInternal,
													strIconName: objColumn.strIconName,
													lstItems: objColumn.lstItems
												});
											}
										});
									}
								});
							break;
							case 2:
								objParent.lstRecords.forEach(objRecord => {
									if(objUtilities.isNotNull(objRecord.lstChildRecords)) {
										objRecord.lstChildRecords.forEach(objChild => {
											if(objUtilities.isNotNull(objChild.lstData)) {
												intCounterInternal++;
												objChild.lstData.push({
													boolIsIcon: true,
													intAction: 8,
													strLocalId: "" + intCounterInternal,
													strIconName: objColumn.strIconName,
													strClasses: objColumn.strClasses
												});
											}
										});
									}
								});
							break;
						} 
					});
				}
			}

			//Now we define the number of columns.
			if(objUtilities.isNotNull(this.lstRecords)) {
				this.lstRecords.forEach(objRecord => {
					if(objUtilities.isNotNull(objRecord.lstParentData)) {
						objRecord.intTotalColumns = objRecord.lstParentData.length;
						if(objRecord.boolAddMarginTD) {
							objRecord.intNumberOfColumns = objRecord.lstParentData.length - 1;
						} else {
							objRecord.intNumberOfColumns = objRecord.lstParentData.length;
						}
					}
				});

				//Now we check cells types and take proper actions.
				this.lstRecords.forEach(objRecord => {
	
					//First we review the parent data.
					if(objUtilities.isNotNull(objRecord.lstParentData)) {
						objRecord.lstParentData.forEach(objParentRecord => {
							objParentRecord = objParent.defineCellValue(objParentRecord);
						});
					}

					//Now we review the child table record.
					if(objUtilities.isNotNull(objRecord.lstChildRecords)) {
						objRecord.lstChildRecords.forEach(objUpperParentRecord => {
							if(objUtilities.isNotNull(objUpperParentRecord.lstData)) {
								objUpperParentRecord.lstData.forEach(objParentRecord => {
									objParentRecord = objParent.defineCellValue(objParentRecord);
								});
							}
						});
					}
				});

				//Now we check each record and set the boolean variables to display or hide the child and child records.
				this.lstRecords.forEach(objRecord => {
					//Card.
					if(objUtilities.isNotNull(objRecord.lstChildData)) {
						objRecord.boolDisplayChildCard = true;
					}

					//Table.
					if(objUtilities.isNotNull(objRecord.lstChildRecords)) {
						objRecord.boolDisplayChildTable = true;
					}
				});
	
				//Now we set unique ids for the received parent records.
				this.lstRecords.forEach(objRecord => {
					intCounter++;
					objRecord.strLocalId = "" + intCounter;
				});
			}
		}

		//If we need to display checkboxes, even if the length is 1 or less.
		if(this.boolForceCheckboxes) {
			this.intMaximumRowSelection = this.lstRecords.length;
			if(this.intMaximumRowSelection === 1) {
				this.intMaximumRowSelection = 2;
			}
		}

		//We add the identifier for the paginator.
		this.strPaginatorStyleClasses = this.strPaginatorStyleClasses + " globalDataTableIdentifier";

		//We add a column for the expandable icon, if the table will have a tree layout.
		if(this.boolEnableTreeView) {
			this.lstColumns.unshift({
				label: "",
				fieldName: "Expandable",
				fixedWidth: 30,
				sortable: false,
				hideDefaultActions: "true",
				type: "custom",
				typeAttributes: {
					label: {
						fieldName: 'Expandable'
					},
					subtype: "expandable",
				},
				objAdditionalAttributes: {
					boolDisplayCheckbox: !objParent.boolHideCheckboxColumn
				}
			});
		}

		//Now, we include the columns that point to lookups.
		this.lstColumns.forEach(objColumn => {
			objParent.updateColumn(objColumn);
		});

		//Now we display the "No records found" message, if needed.
		if(this.lstRecords.length > 0) {
			this.boolHasRecords = true;
		}

		//If the developer wants to hide the table header.
		if(this.boolHideTableHeader) {
			let objCustomStyle = document.createElement("style");
			objCustomStyle.innerHTML += "div[data-id='" + this.strGlobalTableId + "'] .slds-table_header-fixed_container { padding-top: 0px; }";
			objCustomStyle.innerHTML += "div[data-id='" + this.strGlobalTableId + "'] thead { visibility: hidden; }";
			document.body.appendChild(objCustomStyle);
		}

		//If the developer wants to hide the checkboxes.
		if(this.boolHideCheckboxColumn) {
			let objCustomStyle = document.createElement("style");
			objCustomStyle.innerHTML += "div[data-id='" + this.strGlobalTableId + "'] lightning-primitive-cell-checkbox { display: none }";
			document.body.appendChild(objCustomStyle);
		}

		//If the developer wants to preselect all the checkboxes.
		if(this.boolPreSelectAllCheckboxes) {
			this.lstRecords.forEach(objRecord => {
				if(!objParent.objParameters.boolHasCollapsibleRows) {
					objParent.lstPreSelectedRows.push(objRecord.Id);
				}
			});
		}

		//Now we select the layout type.
		switch(this.intLayoutType) {
			case 1:
				this.boolDisplayLayoutTable = true;
			break;
		}

		//We define the global colspan.
		this.intColspan = this.lstColumns.length;

		//Now, we clone the provided data for the paginator component.
		this.lstOriginalRecords = [...this.lstRecords];
		
		//Now we hide the child records and group them, if requested.
		if(this.boolEnableTreeView) {

			//First we update the records.
			this.prepareChildRecords();

			//Now we disable some features.
			this.boolDisplayPaginator = false;
		} else {

			//If we received a sorting field, we sort the received data.
			if(objUtilities.isNotBlank(this.strSortedBy)) {
				this.sortTable({
					detail: {
						sortDirection: this.objConfiguration.strSortDirection,
						fieldName: this.strSortedBy
					}
				});
				if(this.boolAddTotalRow) {
					this.lstRecords.pop();
				}
			}
	
			//Now we add a count row, if requested.
			if(this.boolAddTotalRow) {
				this.addCountRow();
			}
		}
		
		//Now we remove the records to make the first load process faster.
		if(this.boolDisplayPaginator) {
			this.lstRecords = new Array();
		}
	}

	/*
	 Method Name : updateColumn
	 Description : This method prepares the given column.
	 Parameters	 : Object, called from updateColumn, objColumn Column to be updated.
	 Return Type : Object
	 */
	updateColumn(objColumn) {
		let strValue;
		let objParent = this;

		//We disable the sorting, if the Tree View has been requested.
		if(objParent.boolEnableTreeView) {
			objColumn.sortable = false;

			//Now we add the class reference, to manipulate the child rows.
			if(objUtilities.isNull(objColumn.cellAttributes)) {
				objColumn.cellAttributes = new Object();
			}
			if(objUtilities.isNull(objColumn.cellAttributes.class)) {
				objColumn.cellAttributes.class = new Object();
			}
			objColumn.cellAttributes.class.fieldName = "strClasses";
		}


		//Code added by Utopia team.
		var fld = 0;
		if(objColumn.fieldName != undefined){
			fld = objColumn.fieldName.split('.').length;
		}

		//We process link cells.
		if(objColumn.subtype === 'link' || fld == 2) {

			//First we check if this is coming from a Name.
			if(objColumn.typeAttributes && objColumn.typeAttributes.boolisname) {
				objColumn.typeAttributes.mapids = new Array();
			}

			//Now we iterate over the records.
			if(!objParent.objParameters.boolHasCollapsibleRows) {
				objParent.lstRecords.forEach(objRecord => {

					//If Name.
					if(objColumn.typeAttributes && objColumn.typeAttributes.boolisname) {
						objColumn.typeAttributes.mapids[objRecord.Name] = objRecord.Id;
					}

					//First we extract the Id.
					strValue = objColumn.fieldName.split('.').reduce(function(lstAvailableFields, objFieldToCheck) {
						return lstAvailableFields && lstAvailableFields[objFieldToCheck];
					}, objRecord);
					if(typeof strValue !== "undefined" && strValue !== null && strValue !== "") {
						objRecord[objColumn.fieldName] = strValue;

						//Now we extract the name.
						if(fld > 2 || objColumn.subtype === 'link') {
							objRecord[objColumn.typeAttributes.label.fieldName] = objColumn.typeAttributes.label.fieldName.split('.').reduce(function(lstAvailableFields, objFieldToCheck) {
								return lstAvailableFields && lstAvailableFields[objFieldToCheck];
							}, objRecord);
						}
					}
				});
			}
		}

		//We process formulas.
		if((objColumn.boolIsFormula && objColumn.editable) || (objUtilities.isNotNull(objColumn.editable) && objColumn.editable !== "true")) {
			delete objColumn.editable;
		}

		//Now we add additional attributes.
		if(typeof objColumn.typeAttributes !== "undefined" && objColumn.typeAttributes !== null) {
			objColumn.typeAttributes.tableid = objParent.strGlobalTableId;
			objColumn.typeAttributes.columnlabel = objColumn.label;
			if(typeof objColumn.editable !== "undefined" && objColumn.editable !== null) {
				objColumn.typeAttributes.editable = objColumn.editable;
			}
			if(typeof objColumn.strFieldName !== "undefined" && objColumn.strFieldName !== null && objColumn.strFieldName !== "") {
				objColumn.typeAttributes.fieldapiname = objColumn.strFieldName;
			}
			if(typeof objColumn.strParentObject !== "undefined" && objColumn.strParentObject !== null && objColumn.strParentObject !== "") {
				objColumn.typeAttributes.parentobjectapiname = objColumn.strParentObject;
			}
		}
	}

	
	/*
	 Method Name : prepareChildRecords
	 Description : This method prepares the child records to follow a tree view structure.
	 Parameters	 : None
	 Return Type : None
	 */
	 prepareChildRecords() {
		let boolHasChild;
		let intAdditionalInformationIndex = 0;
		let objParent = this;
		let lstRecords = new Array();
		let mapRecords = new Array();
		objParent.nestedParentIds = [];
		//let getParentValue = []; 

		//get all nested parents with childs<T03>
		Object.keys(objParent.mapParentChildRelationship).forEach(item=>{
			Object.values(objParent.mapParentChildRelationship).forEach(parent=>{
				if(item === parent){
					objParent.nestedParentIds.push(parent);
				}
			})
		})
		
		//to get all the nested parents with and without Childs
		/* objParent.lstRecords.forEach((objRecord) => {
			if(objRecord.isSecondLevelParent) {
				getParentValue.push(objRecord.Id);
			}
		}); */

		//If we have records.
		if(objParent.boolHasRecords && objUtilities.isNotNull(objParent.mapParentChildRelationship)) {
			//First we extract the parents.
			objParent.lstRecords.forEach((objRecord) => {
				if(!(objUtilities.isNotBlank(objRecord.Id) && objUtilities.isNotBlank(objParent.mapParentChildRelationship[objRecord.Id]))) {
					mapRecords[objRecord.Id] = new Array();

					//Now we mark the records that don't have any child records.
					boolHasChild = false;
					Object.values(objParent.mapParentChildRelationship).forEach((strIdParent) => {
						if(strIdParent === objRecord.Id) {
							boolHasChild = true;
						}
					});
					if(!boolHasChild) {
						objRecord.Expandable = objRecord.Id;
					}
				}
			});

			//Now we get the childs.
			objParent.lstRecords.forEach((objRecord) => {
				if(objUtilities.isNotBlank(objRecord.Id) && objUtilities.isNotBlank(objParent.mapParentChildRelationship[objRecord.Id])) {
					objRecord.strParentId = objParent.mapParentChildRelationship[objRecord.Id];
					if(objUtilities.isNull(mapRecords[objRecord.strParentId])) {
						mapRecords[objRecord.strParentId] = new Array();
					}
					objRecord.Expandable = objRecord.strParentId;
					mapRecords[objRecord.strParentId].push(objRecord.Id);
				}
			});
			
			//Now we order the records, based on their parents.

			Object.entries(mapRecords).forEach(([strIdParent, lstChildRecordIds]) => {
				//to check if nested Parents have childs <T03>
				if(!objParent.nestedParentIds.includes(strIdParent)){
					//First we add the parent.
					objParent.lstRecords.forEach(objRecord => {
						if(strIdParent === objRecord.Id ) {
							//Level1
							if(this.hasNestedChilds){
								if(!objParent.nestedParentIds.includes(strIdParent)){
									lstRecords.push(objRecord);							
								}
							} else {
						//Now we create a new row if we have additional information.
								if(objUtilities.isNotNull(objRecord.objAdditionalInformation)) {
									lstRecords.push({
										...objRecord,
										objAdditionalInformation: {
											strAdditionalInformationParentId: objRecord.Id,
											intAdditionalInformationIndex: intAdditionalInformationIndex
										}
									});
										lstRecords.push({
										...objRecord.objAdditionalInformation, 
										boolIsAdditionalInformation: true,
										intAdditionalInformationIndex: intAdditionalInformationIndex,
										strAdditionalInformationParentId: objRecord.Id,
										strAdditionalInformationGrandParentId: objRecord.strParentId,
									}); 
									intAdditionalInformationIndex++;
									
								} else {
									//We add a normal record.
									lstRecords.push(objRecord);	
								}
							}
						}
					});


					lstChildRecordIds.forEach(strIdChild => {
						objParent.lstRecords.forEach(objRecord => {
							if(strIdChild === objRecord.Id ) {
								//Level 2<T03>
								if(this.hasNestedChilds){
									if(objParent.nestedParentIds.includes(strIdChild)){
										if(mapRecords[strIdChild]){
											delete objRecord.Expandable;
										}
										lstRecords.push(objRecord);
										//Level 3
										let grandChildRecords = [];
										
										grandChildRecords = mapRecords[strIdChild];
										if(grandChildRecords) {
											grandChildRecords.forEach((item4)=>{
												objParent.lstRecords.forEach((itemRecord)=>{
													if(item4 === itemRecord.Id){
					
														lstRecords.push({
															...itemRecord,
															objAdditionalInformation: {
																strAdditionalInformationParentId: itemRecord.Id,
																intAdditionalInformationIndex: intAdditionalInformationIndex,
																strAdditionalInformationGrandParentId: objRecord.strParentId,
															}
														});
														if(objUtilities.isNull(objParent.boolEnhancedCollapseSystem) || !objParent.boolEnhancedCollapseSystem || 
																(objUtilities.isNotNull(objParent.boolEnhancedCollapseSystem) && objParent.boolEnhancedCollapseSystem && 
																objUtilities.isNotNull(objRecord.objAdditionalInformation))) {
															lstRecords.push({
																...itemRecord.objAdditionalInformation,
																boolIsAdditionalInformation: true,
																intAdditionalInformationIndex: intAdditionalInformationIndex,
																strAdditionalInformationParentId: itemRecord.Id,
																strAdditionalInformationGrandParentId: itemRecord.strParentId,
															});
															intAdditionalInformationIndex++;
														}
													}
												});
											});
										}
										
									}else{
										if(!objParent.nestedParentIds.includes(objRecord.strParentId)){
											lstRecords.push(objRecord);
										}
									}
								}
								else{
								//Now we create a new row if we have additional information.
									if(objUtilities.isNotNull(objRecord.objAdditionalInformation)) {
										
										lstRecords.push({
											...objRecord,
											objAdditionalInformation: {
												strAdditionalInformationParentId: objRecord.Id,
												intAdditionalInformationIndex: intAdditionalInformationIndex,
												//strAdditionalInformationGrandParentId: objRecord.strParentId,
											}
										});
										lstRecords.push({
											...objRecord.objAdditionalInformation,
											boolIsAdditionalInformation: true,
											intAdditionalInformationIndex: intAdditionalInformationIndex,
											strAdditionalInformationParentId: objRecord.Id,
											strAdditionalInformationGrandParentId: objRecord.strParentId,
										});
										intAdditionalInformationIndex++;
									
									} else {
										lstRecords.push(objRecord);
									} 
								}
							} 
						});
					}); 
					
				}
			});

			//Now we set the style classes.
			objParent.lstRecords = new Array();
			lstRecords.forEach((objRecord) => {

				//We return the record with the corresponding classes.
				objParent.lstRecords.push(objParent.processRecord(objRecord));
			});
		}
	}

	/*
	 Method Name : defineCellValue
	 Description : This method updates the data, depending on the field type.
	 Parameters	 : Object, called from defineCellValue, objParentRecord Record.
	 Return Type : None
	 */
	defineCellValue(objParentRecord) {

		//If we have multiple values.
		if(objParentRecord.boolMultipleValues) {

			//If we want to display the values as badges.
			if(objParentRecord.boolIsBadge && objUtilities.isNotBlank(objParentRecord.strValue)) {

				//If a separator was provided.
				if(objUtilities.isNotBlank(objParentRecord.strSeparator)) {
					objParentRecord.lstValues = objParentRecord.strValue.split(objParentRecord.strSeparator);
				} else {

					//We use the default separator.
					objParentRecord.lstValues = objParentRecord.strValue.split(strSeparator);
				}

				//If a limit was provided, we remove records, if needed.
				if(objUtilities.isNotNull(objParentRecord.intRecordLimit)) {

					//First we check if the size goes beyond the limit, so we display the provided icon, if any.
					if(objUtilities.isNotBlank(objParentRecord.strIconName) && objParentRecord.lstValues.length > objParentRecord.intRecordLimit) {
						objParentRecord.boolDisplayMoreIcon = true;
					}

					//Now we remove the unnecessary records.
					objParentRecord.lstValues.splice(objParentRecord.intRecordLimit);
				}
			}
		}
		return objParentRecord;
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strCSS = "";
		let strComponentName = "c-global-data-table div[data-global-id='" + this.strGlobalTableId + "'] ";
		let objParent = this;
		let objTableForSelection;

		//Now we preselect rows.
		if((this.boolPreSelectAllCheckboxes || (objUtilities.isNotNull(this.lstPreSelectedRows) && this.lstPreSelectedRows.length > 0)) && 
				!this.boolPreselectedRowsLoaded) {
			objTableForSelection = this.template.querySelector("c-global-lightning-datatable");
			if(objUtilities.isNotNull(objTableForSelection)) {
				objTableForSelection.selectedRows = this.lstPreSelectedRows;

				//We display the action buttons, as part of the preselection for specific ids.
				if(objUtilities.isNotNull(this.lstPreSelectedRows) && this.lstPreSelectedRows.length > 0) {
					this.selectRecords({
						detail: {
							selectedRows: this.lstPreSelectedRows
						}
					});
				}

				//We avoid recursive calls.
				this.boolPreselectedRowsLoaded = true;
			}
		}

		//Now we load the CSS.
		if(!this.boolCustomCSSLoaded) {

			//Inner CSS.
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				strCSS += strComponentName + ".collapsibleRowElement article {" + 
				"	background-color: var(--lwc-colorBackgroundRowHover,rgb(243, 242, 242));" + 
				"}";

				//We add Total row css, if needed.
				if(objParent.boolAddTotalRow) {
					strCSS += strComponentName + " tr:last-child {" + 
					"	background-color: aliceblue;" + 
					"} " + strComponentName + " tr:last-child th:first-of-type .slds-truncate {" + 
					"	width: 100%;" + 
					"	text-align: right;" + 
					"} " + strComponentName + " tbody tr:last-child lightning-primitive-icon {" + 
					"	display: none;" + 
					"} " + strComponentName + " tr:last-child th:first-of-type a:hover, " + strComponentName + " tr:last-child th:first-of-type a:focus {" + 
					"	text-decoration: none;" + 
					"} " + strComponentName + " tr:last-child th:first-of-type a {" + 
					"	color: black;" + 
					"	cursor: default;" + 
					"}";
				}

				//Now we add the style.
				objElement.innerHTML = "<style> " + strCSS + " </style>";
			});

			//Custom CSS provided by the developer.
			if(objUtilities.isNotNull(this.objParameters.lstCustomCSS)) {
				strCSS = "";
				this.objParameters.lstCustomCSS.forEach(objCSS => {
					strCSS += strComponentName + objCSS.strSelector.replace(",", ", " + strComponentName) + " { " + objCSS.strCSS + " } ";
				});
				this.template.querySelectorAll('.customSpecificCSS').forEach(objElement => {
					objElement.innerHTML = "<style> " + strCSS + " </style>";
				});
			}

			//We avoid recursion.
			this.boolCustomCSSLoaded = true;
		}
	}

	/*
	 Method Name : sortTable
	 Description : This method sorts the records on the current table.
	 Parameters	 : Object, called from sortTable, objEvent Sort event.
	 Return Type : None
	 */
	sortTable(objEvent) {
		let strDirection = objEvent.detail.sortDirection;
		let strFieldName = objEvent.detail.fieldName;
		let strActualFieldName = objEvent.detail.fieldName;
		let objParent = this;
		let objPaginator = this.template.querySelector(this.strPaginatorComponent);
		let lstClonedRecords;

		//Now we set the flag to refresh of the table, if requested.
		if(this.boolForceRefreshOnSorting) {
			this.boolIsLoadingTable = true;
		}

		//Now we decide which table we are trying to sort.
		lstClonedRecords = [...this.lstOriginalRecords];

		//Now we check if the table is a link cell, so we adjust the sort based on Name.
		if(objUtilities.isNotBlank(strFieldName) && strFieldName.endsWith('.Id')) {
			strActualFieldName = strActualFieldName.replace('.Id', '.Name');
		}
		else if(objUtilities.isNotBlank(strFieldName) && strFieldName === 'queueLink') { //<T02>
			strActualFieldName = 'queueName';
		}

		//Now we resort the data.
		lstClonedRecords.sort(this.sortBy(strActualFieldName, strDirection === "asc" ? 1 : -1));

		//Now we set the new values.
		this.lstRecords = lstClonedRecords;
		this.objConfiguration.strSortDirection = strDirection;
		this.strSortedBy = strFieldName;

		//We update the paginator.
		if(this.boolDisplayPaginator) {
			objPaginator.resetTheData(this.lstRecords);
		}

		//Now we add a count row, if requested.
		if(this.boolAddTotalRow) {
			this.addCountRow();
		}

		//Now we send the action event to the parent.
		this.executeAction(100, {
			strFieldName: strFieldName,
			strSortDirection: strDirection
		});

		//Now we force the refresh of the table, if requested.
		if(this.boolForceRefreshOnSorting) {
			setTimeout(function() {
				objParent.boolIsLoadingTable = false;
			}, 1);
		}
	}

	/*
	 Method Name : sortBy
	 Description : This method executes the sorting mechanism.
	 Parameters	 : Object, called from sortBy, strFieldName Field to be used on sorting. 
	 			   Object, called from sortBy, objReverse Direction.  
	 			   Object, called from sortBy, objPrimer Custom function.
	 Return Type : None
	 */
	sortBy(strFieldName, objReverse, objPrimer) {
		let objParent = this;

		//First we define the sorting function.
		const objFunction = objPrimer ? function (lstArray) {
			let objResultFieldName = objParent.nameFieldExist(strFieldName, lstArray);
			if(objResultFieldName.boolFieldDoesntExist) {
				return primer("");
			}
			return primer(lstArray[objResultFieldName.strFieldName]);
		} : function (lstArray) {
			let objResult = "";
			let objResultFieldName = objParent.nameFieldExist(strFieldName, lstArray);
			if(objResultFieldName.boolFieldDoesntExist) {
				return "";
			}
			objResult = lstArray[objResultFieldName.strFieldName];
			if(objUtilities.isJson(objResult)) {
				objResult = JSON.parse(objResult);
				if(objUtilities.isNotNull(objResult)) {
					objResult = objResult.strValue;
				} else {
					objResult = "";
				}
			}
			return objResult;
		};

		//Now we return the result.
		return function (objOne, objTwo) {
			objOne = objFunction(objOne);
			objTwo = objFunction(objTwo);
			return objReverse * ((objOne > objTwo) - (objTwo > objOne));
		};
	}

	/*
	 Method Name : nameFieldExist
	 Description : This method checks if the field exists in the record.
	 Parameters	 : Object, called from sortBy, strFieldName Field to look for
	 			   Object, called from sortBy, lstArray Record properties.
	 Return Type : Object
	 */
	nameFieldExist(strFieldName, lstArray) {
		let boolFieldDoesntExist = false;
		let strAlternateName = strFieldName;
		let lstAlternateNames = ['ContractNumber'];

		//First we confirm the field doesn't exist in the record.
		if(objUtilities.isBlank(strFieldName) || objUtilities.isNull(lstArray[strFieldName])) {
			boolFieldDoesntExist = true;

			//Now we make sure there's no alternate field name.
			if(objUtilities.isNotBlank(strFieldName) && strFieldName.endsWith('.Name')) {

				//We check each alternate name.
				lstAlternateNames.forEach(strAlternateFieldName => {

					//If we haven't found yet a field that exist in the record and the current alternate field does exist, we let the parent know.
					if(boolFieldDoesntExist && objUtilities.isNotNull(lstArray[strFieldName.replace('.Name', '.' + strAlternateFieldName)])) {
						boolFieldDoesntExist = false;
						strAlternateName = strFieldName.replace('.Name', '.' + strAlternateFieldName);
					}
				});
			}
		}
		return {
			boolFieldDoesntExist: boolFieldDoesntExist,
			strFieldName: strAlternateName
		};
	}

	/*
	 Method Name : changeTablePage
	 Description : This method changes the page on the Table.
	 Parameters	 : Object, called from sortBy, objEvent Change event.
	 Return Type : None
	 */
	changeTablePage(objEvent) {
		this.lstRecords = objEvent.detail;
		if(typeof this.lstRecords[0] !== "undefined") {
			this.intRowNumberOffsetRecords = this.lstRecords[0].rowNumber;
		}
	}

	/*
	 Method Name : linkCellMouseOver
	 Description : This method catches the Mouse Over event on Link Cells.
	 Parameters	 : Object, called from linkCellMouseOver, objEvent Select event.
	 Return Type : None
	 */
	linkCellMouseOver(objEvent) {
		const { strLinkCellId, strLinkCellObjectName, objCoordinates, objCustomStructure } = objEvent.detail;
		let objParentReference;
		if(this.boolEnablePopOver) {
			this.strLinkCellId = strLinkCellId;
			this.strLinkCellObjectName = strLinkCellObjectName;
			this.boolDisplayPopOver = true;
	
			//Now we adapt the pop over to the right position.
			objParentReference = this.template.querySelector(".customGeneralCSS").getBoundingClientRect();
			this.template.querySelector(".compactLayout").style = "top: " + (objCoordinates.y + 30) + "px; left: " + objCoordinates.x + 
					"px; position: fixed; z-index: 9999999; transform: translate(-" + (objParentReference.left - 30) + "px, 0px);";
		}
    }

	/*
	 Method Name : linkCellMouseOut
	 Description : This method catches the Mouse Out event on Link Cells.
	 Parameters	 : None.
	 Return Type : None
	 */
	linkCellMouseOut() {
		this.boolDisplayPopOver = false;
    }

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
	selectRecords(objEvent) {
		this.lstSelectedRecords = objEvent.detail.selectedRows;
        if(objEvent.detail.selectedRows.length > 0) {
			this.boolDisplayTableActions = true;
			this.boolDisplayTableActionsCustom = true;
        } else {
			//We hide the panel only if there are no changes pending.
			if(!this.boolDisplayTableActionsSaveInline) {
				this.boolDisplayTableActions = false;
			}
			this.boolDisplayTableActionsCustom = false;
		}
		if(objUtilities.isNull(objEvent.boolAvoidThrowingToParent)) {
			this.executeAction(1, objEvent);
		}
    }

    /*
	 Method Name : actionButton
	 Description : This method executes an Action Button.
	 Parameters	 : Object, called from actionButton, objEvent Select event.
	 Return Type : None
	 */
	actionButton(objEvent) {
		this.executeAction(2, objEvent);
    }

    /*
	 Method Name : inlineEditing
	 Description : This method shows the footer with the Save button.
	 Parameters	 : Object, called from inlineEditing, objEvent Select event.
	 Return Type : None
	 */
	inlineEditing(objEvent) {
		let boolAlreadyIncluded;
		let objParent = this;

		//We initialize the draft values, if needed.
		if(objUtilities.isNull(this.lstDraftValues)) {
			this.lstDraftValues = new Array();
		}

		//Now we iterate over the values, to include the new one, if needed.
		if(objUtilities.isNotNull(objEvent.detail) && objUtilities.isNotNull(objEvent.detail.draftValues)) {
			objEvent.detail.draftValues.forEach(objDraftValue => {
				boolAlreadyIncluded = false;

				//We review existing values.
				objParent.lstDraftValues.forEach(objItem => {
					if(objItem.Id === objDraftValue.Id) {
						boolAlreadyIncluded = true;
						Object.entries(objDraftValue).map(objProperty => {
							objItem[objProperty[0]] = objProperty[1];
						});
					}
				});

				//If the value is new.
				if(!boolAlreadyIncluded) {
					objParent.lstDraftValues.push(objDraftValue);
				}
			});
		}

		//Now we show the buttons.
		this.boolDisplayTableActions = true;
		this.boolDisplayTableActionsSaveInline = true;
    }

    /*
	 Method Name : inlineEditing
	 Description : This method executes a Save action (inline).
	 Parameters	 : None
	 Return Type : None
	 */
	saveInlineChanges() {

		//Now we send the data to the parent component.
		if(this.boolExcludedScenario && !this.lstDraftValues) {//AA Changes
			this.executeAction(3, null);
		} else if(this.lstDraftValues.length > 0) {
			this.executeAction(3, this.lstDraftValues);
		}
    }

    /*
	 Method Name : updateDraftValuesManually
	 Description : This method updates the draft values coming from custom cells.
	 Parameters	 : Object, called from updateDraftValuesManually, objEvent Event.
	 Return Type : None
	 */
	updateDraftValuesManually(objEvent) {
		const { strRecordId, strFieldName, strValue } = objEvent.detail;
		let boolAlreadyIncluded = false;
		let objNewRecord = new Object();

		//We initialize the draft values, if needed.
		if(objUtilities.isNull(this.lstDraftValues)) {
			this.lstDraftValues = new Array();
		}

		//Now we iterate over the values, to include the new one, if needed.
		this.lstDraftValues.forEach(objItem => {
			if(objItem.Id === strRecordId) {
				boolAlreadyIncluded = true;
				objItem[strFieldName] = strValue;
			}
		});

		//If the value is new.
		if(!boolAlreadyIncluded) {
			objNewRecord.Id = strRecordId;
			objNewRecord[strFieldName] = strValue;
			this.lstDraftValues.push(objNewRecord);
		}

		//Now we activate the bottom bar.
		this.boolDisplayTableActions = true;
		this.boolDisplayTableActionsSaveInline = true;
    }

	/*
	 Method Name : customCellFiredEvent
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from customCellFiredEvent, objEvent Event fired by the custom cell.
	 Return Type : None
	 */
	customCellFiredEvent(objEvent) {
		this.executeAction(101, objEvent.detail);
	}

	/*
	 Method Name : executeAction
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Integer, called from executeAction, intAction Action type.
	 			   Object, called from executeAction, objPayload Message payload.
	 Return Type : None
	 */
	executeAction(intAction, objPayload) {
		this.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				intAction: intAction,
				strTableId: this.objParameters.strTableId,
				objPayload: objPayload,
				objAdditionalData: this.objParameters.objAdditionalData
			}
		}));
	}

	/*
	 Method Name : fireRowAction
	 Description : This method sends the row action back to the parent.
	 Parameters	 : Object, called from fireRowAction, objEvent Event.
	 Return Type : None
	 */
	fireRowAction(objEvent) {
		this.dispatchEvent(new CustomEvent('rowaction', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				objEvent: objEvent
			}
		}));
	}

	/*
	 Method Name : executeLocalAction
	 Description : This method executes a local action.
	 Parameters	 : Object, called from executeLocalAction, objEvent Event.
	 Return Type : None
	 */
	executeLocalAction(objEvent) {
		let boolShouldExpand;
		let strCSS = "";
		let strAction;
		let strTarget;
		let strOrigin;
		let objParent = this;
		let objDataSet = objEvent.detail.objEvent.target.dataset;

		//We extract the data.
		strAction = objDataSet.action;
		strTarget = objDataSet.target;
		strOrigin = objDataSet.origin;
		boolShouldExpand = objDataSet.expanded;

		//Now we check which action we need to take.
		switch(strAction) {
			case "1":
				
				//This action will open and close collapsible child rows.
				this.template.querySelectorAll("tbody.childTable[data-parent-id='" + strTarget + "']").forEach(objElement => {
					if(objElement.classList.contains("slds-hide")) {
						objElement.classList.remove("slds-hide");
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objAdditionalElement => {
							if(objAdditionalElement.classList.contains("wasOpen")) {
								objAdditionalElement.classList.remove("slds-hide");
							}
						});
					} else {
						objElement.classList.add("slds-hide");
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objAdditionalElement => {
							if(!objAdditionalElement.classList.contains("slds-hide")) {
								if(!objAdditionalElement.classList.contains("wasOpen")) {
									objAdditionalElement.classList.add("wasOpen");
								}
							} else {
								objAdditionalElement.classList.remove("wasOpen");
							}
							objAdditionalElement.classList.add("slds-hide");
						});
					}
				});

				//Now we change the icon.
				this.lstRecords.forEach(objRecord => {
					objRecord.lstParentData.forEach(objParentRecord => {
						if(strOrigin === objParentRecord.strLocalId && objParentRecord.intAction === 1) {
							if(objParentRecord.strIconName === "utility:chevronright") {
								objParentRecord.strIconName = "utility:chevrondown";
							} else {
								objParentRecord.strIconName = "utility:chevronright";
							}
						}
					});
				});
			break;
			case "7":
				
				//This action will open and close additional details.
				this.template.querySelectorAll("tbody.childTable[data-parent-id='" + strTarget + "']").forEach(objChildTableElement => {
					if(objChildTableElement.classList.contains("slds-hide")) {
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objElement => {
							if(objElement.classList.contains("wasOpen")) {
								objElement.classList.remove("wasOpen");
							} else {
								objElement.classList.add("wasOpen");
							}
						});
					} else {
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objElement => {
							if(objElement.classList.contains("slds-hide")) {
								objElement.classList.remove("slds-hide");
							} else {
								objElement.classList.add("slds-hide");
							}
						});
					}
				});
			break;
			case "11":
				
				//This action will open and close additional details.
				this.template.querySelectorAll("tbody.childTable[data-parent-id='" + strTarget + "']").forEach(objChildTableElement => {
					if(objChildTableElement.classList.contains("slds-hide")) {

						//First we display the table.
						objChildTableElement.classList.remove("slds-hide");

						//Now we display the additional information.
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objElement => {
							if(objElement.classList.contains("slds-hide")) {
								objElement.classList.remove("slds-hide");
							}
						});
					} else {

						//First we hide the table.
						objChildTableElement.classList.add("slds-hide");

						//Now we hide the additional information.
						objParent.template.querySelectorAll("tbody.additionalInformation[data-parent-id='" + strTarget + "']").forEach(objElement => {
							if(!objElement.classList.contains("slds-hide")) {
								objElement.classList.add("slds-hide");
							}
						});
					}
				});

				//Now we change the icon.
				this.lstRecords.forEach(objRecord => {
					objRecord.lstParentData.forEach(objParentRecord => {
						if(strOrigin === objParentRecord.strLocalId && objParentRecord.intAction === 1) {
							if(objParentRecord.strIconName === "utility:chevronright") {
								objParentRecord.strIconName = "utility:chevrondown";
							} else {
								objParentRecord.strIconName = "utility:chevronright";
							}
						}
					});
				});
			break;
			case "12":

				//Now we look for the child records.
				if(objUtilities.isNotNull(objParent.boolEnhancedCollapseSystem) && objParent.boolEnhancedCollapseSystem) {
					objParent.toggleRow(strTarget, boolShouldExpand);
				} else {
					objParent.template.querySelectorAll('.customTreeCSS').forEach(objElement => {
						strCSS = "div[data-id='" + objParent.strGlobalTableId + "'] tr.child-row > td:nth-of-type(2) { padding-left: 25px !important; }";
						objParent.lstRecords.forEach(objRecord => {
							
							if(objUtilities.isNotNull(objRecord) && objUtilities.isNotBlank(objRecord.strClasses) && objRecord.strClasses.includes("child-row")) {
								strCSS += "div[data-id='" + objParent.strGlobalTableId + "'] .child-row.parent-id-" + objParent.mapParentChildRelationship[objRecord.Id] + " {";
								
								//We update the child records of the selected parent.
								if(objRecord.strClasses.includes("parent-id-" + strTarget)) {
									
									//We show the child.
									if((objUtilities.isNotNull(boolShouldExpand) && boolShouldExpand) || objRecord.strClasses.includes("slds-hide")) {
										strCSS += "	display: revert !important;";
										objRecord.strClasses = "child-row parent-id-" + strTarget;
										//<T03>
										if(objRecord.grandParentId){
											objRecord.parentOpen = true;
										}
									} else if((objUtilities.isNotNull(boolShouldExpand) && !boolShouldExpand) || !objRecord.strClasses.includes("slds-hide")) {
	
										//We hide the child.
										strCSS += "	display: none !important;";
										objRecord.strClasses = "child-row slds-hide parent-id-" + strTarget;
	
										if(objRecord.grandParentId){
											objRecord.parentOpen = false;
										}
										//We also hide Additional Information sections, if any.
										objParent.template.querySelectorAll(".additional-information.additional-information-parent-id-" + strTarget + 
												", .additional-information.additional-information-grand-parent-id-" + strTarget).forEach(objCell => {
											objCell.classList.add("slds-hide");
										})
									}
								} else {
	
									if(objRecord.grandParentId === strTarget ){
										if(!boolShouldExpand){
											if(!objRecord.strClasses.includes("slds-hide")){
												strCSS += "	display: none !important;";
												objRecord.strClasses = "child-row slds-hide parent-id-" + objRecord.grandChildRecords;
												objRecord.parentOpen = false;
											}
											/* if(objRecord.parentOpen){
												objRecord.strClasses = "child-row slds-hide parent-id-" + objRecord.strParentId;
											} */
										} else {
											if(objRecord.parentOpen){
												
												strCSS += "	display: revert !important;";
												objRecord.strClasses = "child-row parent-id-" + objRecord.strParentId;
	
											}else{
												
												strCSS += "	display: none !important;";
												objRecord.strClasses = "child-row slds-hide parent-id-" + objRecord.strParentId;
											}
										}
									} else {
	
									//But also, we create the CSS of the already updated child records.
										if(objRecord.strClasses.includes("slds-hide")) {
											strCSS += "	display: none !important;";
										} else {
											strCSS += "	display: revert !important;";
										}
									}
								}
								strCSS += "} ";
							}
						});					
	
						//Now we add the style.
						objElement.innerHTML = "<style> " + strCSS + " </style>";
					});
				}
			break;
			default:
				objParent.executeAction(parseInt(strAction), {
					objPayload: objDataSet
				});
			break;
		}
	}

	/*
	 Method Name : cancelInlineChanges
	 Description : This method cleans up the Draft values and cancels the inline editing.
	 Parameters	 : None
	 Return Type : None
	 */
	cancelInlineChanges() {
		let objParent = this;
		this.lstDraftValues = new Array();

		//We send the instruction to all the components.
		window.postMessage({
            strTableId: objParent.strGlobalTableId,
            intOperation: 1
        }, window.location.href);

		//Now we update the footer.
		if(!this.boolDisplayTableActionsCustom) {
			this.boolDisplayTableActions = false;
		}
		this.boolDisplayTableActionsSaveInline = false;
	}
	
	/*
	 Method Name : addCountRow
	 Description : This method adds the count row to the given data.
	 Parameters	 : None
	 Return Type : None
	 */
	addCountRow() {
		let boolEntered = false;
		let objJSONValue;
		let objParent = this;
		let objCountRow;

		//Now we count the data.
		if(objUtilities.isNotNull(this.objCountRow)) {
			objCountRow = {... this.objCountRow};
			objParent.lstRecords.forEach(objRow => {
				Object.entries(objRow).map(objProperty => {
					
					//If the cell value is a number.
					if(!isNaN(objProperty[1])) {
	
						//First we check if the column has already a value.
						if(typeof objCountRow[objProperty[0]] === "undefined" || objCountRow[objProperty[0]] === null) {
							objCountRow[objProperty[0]] = 0;
						}
	
						//Now we add the count.
						objCountRow[objProperty[0]] += objProperty[1];
						boolEntered = true;
					} else if(objUtilities.isNotBlank(objProperty[1])) {
						try {
							objJSONValue = JSON.parse(objProperty[1]);

							//If the cell value is a number.
							if(!isNaN(objJSONValue.strValue)) {
	
								//First we check if the column has already a value.
								if(typeof objCountRow[objProperty[0]] === "undefined" || objCountRow[objProperty[0]] === null) {
									objCountRow[objProperty[0]] = 0;
								}
			
								//Now we add the count.
								objCountRow[objProperty[0]] += Number(objJSONValue.strValue);
								boolEntered = true;
							}
						} catch(objException) {}
					}
				})
			});
	
			//If no records were found, we set the default.
			if(!boolEntered && objUtilities.isNotNull(objParent.lstColumns)) {
				objParent.lstColumns.forEach(objColumn => {
					objCountRow[objColumn.label] = 0;
				});
			}
	
			//Now we add the data.
			objParent.lstRecords.push(objCountRow);
		}
	}

	/*
	 Method Name : sendEventToParent
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from sendEventToParent, objEvent Event.
	 Return Type : None
	 */
	sendEventToParent(objEvent) {
		this.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: objEvent
		}));
	}

	/*
	 Method Name : customRowSelection
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from customRowSelection, objEvent Event fired by the custom cell.
	 Return Type : None
	 */
	customRowSelection(objEvent) {
		let objRow;
		objEvent.detail.selectedRows = new Array();
		this.template.querySelectorAll("c-global-custom-cell").forEach(objCell => {
			objRow = objCell.isChecked();
			if(objRow.boolIsSelected) {
				objEvent.detail.selectedRows.push(objRow.strRecordId);
			}
		});
		this.selectRecords(objEvent);
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
		let lstDependenciesToShow = new Array();

		//If we have a Tree structure.
		if(objUtilities.isNotNull(objParent.boolEnableTreeView) && objParent.boolEnableTreeView) {
			objParent.boolHasRecords = false;
			//If the keyword is blank, we restore the data.
			if(objUtilities.isBlank(strKeyword)) {
				if(objUtilities.isNotNull(objParent.lstRecords) && objParent.lstRecords.length > 0) {
					//We display all the records.
					objParent.lstRecords.forEach(objRecord => {
						objRecord.boolIsVisible = true;
						objParent.boolHasRecords = true;
					});

					//Now we collapse the parents.
					setTimeout(function() {
						objParent.lstRecords.forEach(objRecord => {
							if(objUtilities.isBlank(objRecord.Expandable)) {
								objParent.getRowExpandedCollapsed(objRecord.Id, false);
							}
						});
					}, 10);
				}
			} else if(objUtilities.isNotNull(objParent.lstRecords) && objParent.lstRecords.length > 0) {
				strKeyword = strKeyword.toLowerCase();

				//First we check the matches.
				objParent.lstRecords.forEach(objRecord => {
					if(JSON.stringify(objRecord).toLowerCase().includes(strKeyword)) {
						objRecord.boolIsVisible = true;
						objParent.boolHasRecords = true;
	
						//If the current record is a child, we add the Expandable Id to include its parent.
						if(objUtilities.isNotBlank(objRecord.Expandable)) {
							lstDependenciesToShow.push(objRecord.Expandable);
						} else {
	
							//The current record is a Parent, so we add the Id to include its childs.
							lstDependenciesToShow.push(objRecord.Id);
							objParent.getRowExpandedCollapsed(objRecord.Id, true);
						}
					} else {
						objRecord.boolIsVisible = false;
					}
				});
	
				//Now we display also the dependencies.
				if(lstDependenciesToShow.length > 0) {
					objParent.lstRecords.forEach(objRecord => {
						if(lstDependenciesToShow.includes(objRecord.Id) || (objUtilities.isNotBlank(objRecord.Expandable) && lstDependenciesToShow.includes(objRecord.Expandable))) {
							objRecord.boolIsVisible = true;

							//If the current record is a parent, we expand it.
							if(objUtilities.isBlank(objRecord.Expandable)) {
								objParent.getRowExpandedCollapsed(objRecord.Id, true);
							}
						}
					});
				}
			}
		} else {

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
	 Method Name : hideActions
	 Description : This method hides the Actions section.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	hideActions() {

		//We hide the panel only if there are no changes pending.
		if(!this.boolDisplayTableActionsSaveInline) {
			this.boolDisplayTableActions = false;
		}
		this.boolDisplayTableActionsCustom = false;
		this.getAllRecordsUnselected();

		//We also uncheck custom checkboxes.
		this.template.querySelectorAll("c-global-custom-cell").forEach(objCell => {
			objCell.updateCheckboxSelection(false);
		});
	}

	/*
	 Method Name : hideButtons
	 Description : This method hides the button Actions section.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	hideButtons() {

		//We hide the panel only if there are no changes pending.
		if(!this.boolDisplayTableActionsSaveInline) {
			this.boolDisplayTableActions = false;
		}
		this.boolDisplayTableActionsCustom = false;
	}

	/*
	 Method Name : getAllRecordsUnselected
	 Description : This method unselects all the rows currently selected.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	getAllRecordsUnselected() {
		let objTable = this.template.querySelector("c-global-lightning-datatable");
		if(objUtilities.isNotNull(objTable)) {
			objTable.selectedRows = new Array();
		}
	}

	/*
	 Method Name : getSelectedRows
	 Description : This method returns the current selected rows.
	 Parameters	 : None
	 Return Type : List of row ids.
	 */
	@api
	getSelectedRows() {
		let lstSelectedRows = new Array();
		let objTableForSelection = this.template.querySelector("c-global-lightning-datatable");
		if(objUtilities.isNotNull(objTableForSelection)) {
			objTableForSelection.selectedRows.forEach(objSelectedRow => {
				lstSelectedRows.push(objSelectedRow);
			});
		}
		return lstSelectedRows;
	}

	/*
	 Method Name : getSelectedRecords
	 Description : This method returns the current selected records.
	 Parameters	 : None
	 Return Type : List of records
	 */
	@api
	getSelectedRecords() {
		let lstSelectedRecords = new Array();
		if(objUtilities.isNotNull(this.lstSelectedRecords)) {
			lstSelectedRecords = this.lstSelectedRecords;
		}
		return lstSelectedRecords;
	}

	/*
	 Method Name : getRowExpandedCollapsed
	 Description : This method expandes or collapses rows on a tree-view layout.
	 Parameters	 : String, called from getRowExpandedCollapsed, strTarget Row Id to be expanded / collapsed.
	 			   Boolean, called from getRowExpandedCollapsed, boolShouldExpand If TRUE, the rows gets expanded, if FALSE, the row gets collapsed, if NULL, the rows toggles.
	 Return Type : None
	 */
	@api
	getRowExpandedCollapsed(strTarget, boolShouldExpand) {
		this.template.querySelectorAll("c-global-custom-cell[data-id='" + strTarget + "']").forEach(objCell => {
			objCell.getRowExpandedCollapsed(boolShouldExpand);
		});
	}

	/*
	 Method Name : getAdditionalInformationExpandedCollapsed
	 Description : This method expandes or collapses additional information on a tree-view layout.
	 Parameters	 : Object, called from getRowExpandedCollapsed, objAdditionalAttributes Additional Information details.
	 Return Type : None
	 */
	@api
	getAdditionalInformationExpandedCollapsed(objAdditionalAttributes) {
		let objParent = this;
		this.template.querySelectorAll(".additional-information-id-" + objAdditionalAttributes.intAdditionalInformationIndex).forEach(objCell => {
			if(objCell.classList.contains("slds-hide")) {
				objParent.getRowExpandedCollapsed(objAdditionalAttributes.strAdditionalInformationParentId, true);
				objCell.classList.remove("slds-hide");
			} else {
				objCell.classList.add("slds-hide");
			}
		});
	}

	/*
	 Method Name : getAllRowsExpandedCollapsed
	 Description : This method expandes or collapses all additional information rows on a tree-view layout.
	 Parameters	 : Object, called from getAllRowsExpandedCollapsed, boolShouldExpand TRUE to expand, FALSE to collapse.
	 Return Type : None
	 */
	@api
	getAllRowsExpandedCollapsed(boolShouldExpand) {
		//First we expand the rows and change icons.
		this.template.querySelectorAll("c-global-custom-cell[data-id]").forEach(objCell => {
			objCell.getRowExpandedCollapsed(boolShouldExpand);
			objCell.updateToggleIcons(!boolShouldExpand);
		});

		//Now we display additional information.
		this.template.querySelectorAll(".additional-information").forEach(objCell => {
			if(boolShouldExpand && objCell.classList.contains("slds-hide")) {
				objCell.classList.remove("slds-hide");
			} else if(!boolShouldExpand && !objCell.classList.contains("slds-hide")) {
				objCell.classList.add("slds-hide");
			}
		});
	}

	/*
	 Method Name : toggleRows
	 Description : This method expandes or collapses all rows on a tree-view layout, considering the order.
	 Parameters	 : Object, called from toggleRows, boolShouldExpand TRUE to expand, FALSE to collapse.
	 Return Type : None
	 */
	@api
	toggleRows(boolShouldExpand) {
		this.template.querySelectorAll("c-global-custom-cell[data-field-type='expandable']").forEach(objRecord => {
			if(boolShouldExpand) {
				objRecord.expandParentRow();
			} else {
				objRecord.collapseParentRow();
			}
		});
	}

	/*
	 Method Name : toggleRows
	 Description : This method expandes or collapses all rows on a tree-view layout, considering the order.
	 Parameters	 : Object, called from toggleRows, boolShouldExpand TRUE to expand, FALSE to collapse.
	 Return Type : None
	 */
	toggleRow(idRecord, boolShouldExpand) {
		let objParent = this;

		//First, we look for the row.
		objParent.template.querySelectorAll("tr[data-parent-id='" + idRecord + "']").forEach(objTargetRow => {
			if(boolShouldExpand) {
				objTargetRow.classList.remove("slds-hide");
			} else {
				objTargetRow.classList.add("slds-hide");
				objTargetRow.querySelector("c-global-custom-cell[data-field-type='expandable']").setIsExpanded(boolShouldExpand);

				//Now we look for child rows.
				objParent.toggleRow(objTargetRow.getAttribute("data-id"), boolShouldExpand);
			}
		});
	}

	/*
	 Method Name : processRecord
	 Description : This method processes the given record to add it to the global list.
	 Parameters	 : Object, called from processRecord, objRecord Record.
	 Return Type : None
	 */
	processRecord(objRecord) {
		let intIndex = 0;
		let strClasses = "slds-hint-parent ";
		let strStyle;
		let objRow;
		let objLocalColumn;
		let lstRows = new Array();
		let lstColumns = new Array();
		let objParent = this;
				
		//If the current record is a detail record.
		if(objRecord.boolIsAdditionalInformation) {
			strClasses = "additional-information slds-hide additional-information-id-" + objRecord.intAdditionalInformationIndex + 
					" additional-information-parent-id-" + objRecord.strAdditionalInformationParentId + 
					" additional-information-grand-parent-id-" + objRecord.strAdditionalInformationGrandParentId;
		}else if(objUtilities.isNotBlank(objRecord.strParentId)) {
			//If the current record is a child row, we save the parent id.
			strClasses += "child-row slds-hide parent-id-" + objRecord.strParentId;
			
			//Now we check if we have another parent.
			objParent.lstRecords.map((objParentRecord) => {
				if(objRecord.strParentId === objParentRecord.Id && objUtilities.isNotBlank(objParentRecord.strParentId)) {
					objRecord.grandParentId = objParentRecord.strParentId;
					objRecord.parentOpen = false;
					strClasses += "child-row slds-hide grand-parent-id-" + undefined;
				}
			});
		}

		//If the record follows specific columns.
		if(objUtilities.isNotNull(objRecord.boolCustomLayout) && objRecord.boolCustomLayout && objUtilities.isNotNull(objRecord.intColumnsConfiguration) && 
				objUtilities.isNotNull(objParent.objParameters.lstColumnsSpecificConfigurations) && 
				objUtilities.isNotNull(objParent.objParameters.lstColumnsSpecificConfigurations[objRecord.intColumnsConfiguration])) {

			//We set the default values.
			objRecord.boolHasItsOwnStructure = true;
			lstColumns = JSON.parse(JSON.stringify(objParent.objParameters.lstColumnsSpecificConfigurations[objRecord.intColumnsConfiguration]));
			lstColumns.forEach(objColumn => {
				objColumn = objParent.updateColumn(objColumn);
			});
			objRecord.lstColumns = lstColumns;

			//Now we select the layout type.
			switch(objRecord.intRecordLayoutType) {

				//Vertical layout.
				case 1:
					if(objUtilities.isNotNull(objRecord.intMapLabelContentPairsNumberOfColumns) && objUtilities.isNotNull(objRecord.mapLabelContentPairs)) {
						objRecord.boolIsLayoutVertical = true;

						//Now we iterate over the map, to generate the list of values.
						intIndex = 0;
						lstRows = new Array();
						objRecord.lstMapRows = new Array();
						Object.entries(objRecord.mapLabelContentPairs).map(objData => {
							objRow = new Object();
							objRow.strColumnLabel = objData[0];
							if(objUtilities.isNotNull(objData[1]) && typeof objData[1] === "object") {
								objRow.strValue = objData[1].strValue;
								objRow.strStyle = objData[1].strStyle;
							} else {
								objRow.strValue = objData[1];
							}
							lstRows.push(objRow);
							intIndex++;
							if(intIndex === objRecord.intMapLabelContentPairsNumberOfColumns) {
								objRecord.lstMapRows.push(lstRows);
								lstRows = new Array();
								intIndex = 0;
							}
						});
						if(intIndex !== 0) {
							objRecord.lstMapRows.push(lstRows);
						}
					}
				break;

				//Horizontal layout.
				case 2:
					objRecord.boolIsLayoutHorizontal = true;
				break;
			}
		} else {
			objRecord.boolHasItsOwnStructure = false;
			objRecord.boolIsVisible = true;

			//The record follows the general columns.
			lstColumns = [... objParent.lstColumns];
		}

		//Now we order the field values in a list, to render them in the plain table.
		if(!objRecord.boolHasItsOwnStructure || objRecord.boolIsLayoutHorizontal) {
			objRecord.lstValues = new Array();
			lstColumns.forEach(objColumn => {
				if(objUtilities.isBlank(objColumn.strHelpText)) {
					objColumn.strHelpText = objColumn.label;
				}
				if(objUtilities.isNull(objColumn.typeAttributes)) {
					objColumn.typeAttributes = new Object();
				}
				if(objUtilities.isNull(objColumn.typeAttributes.label)) {
					objColumn.typeAttributes.label = new Object();
				}
				strStyle = "";
				if(objUtilities.isNotNull(objRecord.mapStyles)) {
					Object.entries(objRecord.mapStyles).map(objStyle => {
						if(objStyle[0] === objColumn.fieldName) {
							strStyle = objStyle[1];
						}
					});
				}
				// to stop editing Parent Records, this contain nestedParents
				let boolIsChildAParent = false;
				if (objParent.nestedParentIds.includes(objRecord.Id)) {
					boolIsChildAParent = true;
				}

				//If we have individual attributes (per record), we use them.
				objLocalColumn = objColumn;
				if(objUtilities.isNotNull(objRecord.objColumn)) {
					if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes)) {
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.boolisname)) {
							objLocalColumn.boolisname = objRecord.objColumn.typeAttributes.boolisname;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.editable)) {
							objLocalColumn.editable = objRecord.objColumn.typeAttributes.editable;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.columnlabel)) {
							objLocalColumn.columnlabel = objRecord.objColumn.typeAttributes.columnlabel;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.tableid)) {
							objLocalColumn.tableid = objRecord.objColumn.typeAttributes.tableid;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.subtype)) {
							objLocalColumn.subtype = objRecord.objColumn.typeAttributes.subtype;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.objectapiname)) {
							objLocalColumn.objectapiname = objRecord.objColumn.typeAttributes.objectapiname;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.fieldapiname)) {
							objLocalColumn.fieldapiname = objRecord.objColumn.typeAttributes.fieldapiname;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.parentobjectapiname)) {
							objLocalColumn.parentobjectapiname = objRecord.objColumn.typeAttributes.parentobjectapiname;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.mapids)) {
							objLocalColumn.mapids = objRecord.objColumn.typeAttributes.mapids;
						}
						if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.label)) {
							if(objUtilities.isNotNull(objRecord.objColumn.typeAttributes.label.fieldName)) {
								objLocalColumn.label.fieldName = objRecord.objColumn.typeAttributes.label.fieldName;
							}
						}
					}
					if(objUtilities.isNotNull(objRecord.objColumn.fixedWidth)) {
						objLocalColumn.fixedWidth = objRecord.objColumn.fixedWidth;
					}
					if(objUtilities.isNotNull(objRecord.objColumn.fieldName)) {
						objLocalColumn.fieldName = objRecord.objColumn.fieldName;
					}
					if(objUtilities.isNotNull(objRecord.objColumn.objAdditionalAttributes)) {
						objLocalColumn.objAdditionalAttributes = objRecord.objColumn.objAdditionalAttributes;
					}
				}

				//We now set the values.
				objRecord.lstValues.push({
					boolIsVisible: true,
					boolIsName: objLocalColumn.typeAttributes.boolisname,
					boolIsEditable: objLocalColumn.typeAttributes.editable,
					intWidth: objLocalColumn.fixedWidth,
					strColumnLabel: objLocalColumn.typeAttributes.columnlabel,
					strTableId: objLocalColumn.typeAttributes.tableid,
					strFieldType: objLocalColumn.typeAttributes.subtype,
					strValue: objRecord[objLocalColumn.fieldName],
					strRowId: objRecord.Id,
					strRecordLabel: objRecord[objLocalColumn.typeAttributes.label.fieldName],
					strRecordObjectAPIName: objLocalColumn.typeAttributes.objectapiname,
					strRecordFieldAPIName: objLocalColumn.typeAttributes.fieldapiname,
					strRecordParentObjectAPIName: objLocalColumn.typeAttributes.parentobjectapiname,
					strStyle: strStyle,
					objAdditionalAttributes: {
						... objLocalColumn.objAdditionalAttributes,
						... objRecord.objAdditionalInformation,
						boolIsTreeView: objParent.boolIsTreeView,
						strParentId: objRecord.strParentId,
						boolIsChildAParent: boolIsChildAParent
					},
					mapIds: objLocalColumn.typeAttributes.mapids
				});

				//If we need to set individual values per cell.
				if(objUtilities.isNotNull(objRecord.lstOverridenValues)) {
					objRecord.lstOverridenValues.forEach(objOverridenValue => {
						objRecord.lstValues.forEach(objValue => {
							if(objOverridenValue.strRecordObjectAPIName === objValue.strRecordObjectAPIName && objOverridenValue.strRecordFieldAPIName === objValue.strRecordFieldAPIName) {
								if(objUtilities.isNotNull(objOverridenValue.boolIsName)) {
									objValue.boolIsName = objOverridenValue.boolIsName;
								}
								if(objUtilities.isNotNull(objOverridenValue.boolIsEditable)) {
									objValue.boolIsEditable = objOverridenValue.boolIsEditable;
								}
								if(objUtilities.isNotNull(objOverridenValue.intWidth)) {
									objValue.intWidth = objOverridenValue.intWidth;
								}
								if(objUtilities.isNotNull(objOverridenValue.strColumnLabel)) {
									objValue.strColumnLabel = objOverridenValue.strColumnLabel;
								}
								if(objUtilities.isNotNull(objOverridenValue.strTableId)) {
									objValue.strTableId = objOverridenValue.strTableId;
								}
								if(objUtilities.isNotNull(objOverridenValue.strFieldType)) {
									objValue.strFieldType = objOverridenValue.strFieldType;
								}
								if(objUtilities.isNotNull(objOverridenValue.strValue)) {
									objValue.strValue = objOverridenValue.strValue;
								}
								if(objUtilities.isNotNull(objOverridenValue.strRowId)) {
									objValue.strRowId = objOverridenValue.strRowId;
								}
								if(objUtilities.isNotNull(objOverridenValue.strRecordLabel)) {
									objValue.strRecordLabel = objOverridenValue.strRecordLabel;
								}
								if(objUtilities.isNotNull(objOverridenValue.strRecordParentObjectAPIName)) {
									objValue.strRecordParentObjectAPIName = objOverridenValue.strRecordParentObjectAPIName;
								}
								if(objUtilities.isNotNull(objOverridenValue.strStyle)) {
									objValue.strStyle = objOverridenValue.strStyle;
								}
								if(objUtilities.isNotNull(objOverridenValue.objAdditionalAttributes)) {
									objValue.objAdditionalAttributes = {
										...objValue.objAdditionalAttributes,
										...objOverridenValue.objAdditionalAttributes
									};
								}
								if(objUtilities.isNotNull(objOverridenValue.mapIds)) {
									objValue.mapIds = objOverridenValue.mapIds;
								}
								if(objUtilities.isNotNull(objOverridenValue.strNewRecordObjectAPIName)) {
									objValue.strRecordObjectAPIName = objOverridenValue.strNewRecordObjectAPIName;
								}
								if(objUtilities.isNotNull(objOverridenValue.strNewRecordFieldAPIName)) {
									objValue.strRecordFieldAPIName = objOverridenValue.strNewRecordFieldAPIName;
								}
							}
						});
					});
				}
			});
		}
		return {
			...objRecord, 
			strClasses: strClasses
		};
	}

	/*
	 Method Name : addChildRow
	 Description : This method adds a child row under an specific parent.
	 Parameters	 : String, called from addChildRow, strParentId Parent row id.
	 			   Object, called from addChildRow, objRecord New record.
	 Return Type : None
	 */
	@api
	addChildRow(strParentId, objRecord) {
		let boolHasChildren = false;
		let boolFound = false;
		let intPosition;
		let intIndex;
		let objInnerRecord;
		let objParentRecord;
		let objParent = this;

		//Now we look for the right position.
		for(intIndex = 0; intIndex < objParent.lstRecords.length; intIndex++) {
			intPosition = intIndex;

			//If the current record is the parent.
			if(objParent.lstRecords[intIndex].Id === strParentId) {
				intPosition++;
				objParentRecord = objParent.lstRecords[intIndex];

				//We look for the last child
				while(intPosition < objParent.lstRecords.length && !boolFound) {
					if(objParent.lstRecords[intPosition].strParentId === strParentId) {
						if((objUtilities.isNull(objParent.lstRecords[intPosition].boolIsDeleted) || !objParent.lstRecords[intPosition].boolIsDeleted)) {
							boolHasChildren = true;
						}
						intPosition++;
					} else {
						boolFound = true;
					}
				}

				//We stop the FOR LOOP.
				break;
			}
		}
		if(objUtilities.isNull(objRecord.objAdditionalInformation)) {
			objRecord.objAdditionalInformation = new Object();
		}
		objRecord.objAdditionalInformation.intPosition = intPosition;
		objRecord.intPosition = intPosition;

		//We generate the new record / row.
		objInnerRecord = objParent.processRecord({
			...objRecord,
			boolIsNewRecord: true,
			strParentId: strParentId
		});
		objInnerRecord.strClasses = objInnerRecord.strClasses.replace("slds-hide", "");
		objParent.lstRecords.splice(intPosition, 0, objInnerRecord);

		//If the parent has children, we expand the parent.
		if(boolHasChildren) {
			objParent.getRowExpandedCollapsed(strParentId, true);
		} else {

			//We convert the row into a parent.
			objParentRecord.lstValues[0].boolIsVisible = false;
			delete objParentRecord.Expandable;
			delete objParentRecord.lstValues[0].strRecordLabel;
			delete objParentRecord.lstValues[0].strValue;

			//We display the chevron and expand it.
			setTimeout(() => {
				objParentRecord.lstValues[0].boolIsVisible = true;
				setTimeout(() => {
					objParent.template.querySelectorAll("c-global-custom-cell[data-field-type='expandable'][data-id='" + strParentId + "']").forEach(objCell => {
						objCell.expandParentRow();
					});
				}, 10);
			}, 10);
		}
	}

	/*
	 Method Name : removeChildRow
	 Description : This method removes the given row, based on its index.
	 Parameters	 : Integer, called from removeChildRow, intIndex Row index.
	 Return Type : None
	 */
	@api
	removeChildRow(intIndex) {
		let boolHasChildRecords = false;
		let intPosition = -1;
		let strParentId;
		let objParentRecord;
		let objParent = this;

		//First we get the Parent Id.
		strParentId = objParent.lstRecords[intIndex].strParentId;

		//We delete the row.
		objParent.lstRecords.forEach(objRecord => {
			intPosition++;
			if(intPosition === intIndex) {
				objRecord.lstValues = null;
				objRecord.boolIsDeleted = true;
				objRecord.boolIsNewRecord = false;
			}
		});

		//We check if there are any children left.
		intPosition = -1;
		objParent.lstRecords.forEach(objRecord => {
			if(objRecord.Id === strParentId) {
				objParentRecord = objRecord;
			} else if(objRecord.strParentId === strParentId && (objUtilities.isNull(objRecord.boolIsDeleted) || !objRecord.boolIsDeleted)) {
				boolHasChildRecords = true;
			}

			//We reset the positions.
			objParent.template.querySelectorAll("tr[data-id='" + objRecord.Id + "']").forEach(objInnerRow => {
				intPosition++;
				objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
					objCell.updatePosition(intPosition + 1);
				});
			});
		});

		//If the parent doesn't have any child records left, we remove the chevron.
		if(!boolHasChildRecords) {
			objParentRecord.Expandable = objParentRecord.Id;
			objParentRecord.lstValues[0].boolIsVisible = false;
			objParentRecord.lstValues[0].strRecordLabel = objParentRecord.Id;
			objParentRecord.lstValues[0].strValue = objParentRecord.Id;

			//We display the chevron and expand it.
			setTimeout(() => {
				objParentRecord.lstValues[0].boolIsVisible = true;
			}, 10);
		}
	}

	/*
	 Method Name : addRow
	 Description : This method adds a row to the table.
	 Parameters	 : Object, called from addRow, objRecord New record.
	 Return Type : None
	 */
	@api
	addRow(objRecord) {
		let intPosition;
		let objInnerRecord;
		let objParent = this;

		//Now we look for the right position.
		intPosition = objParent.lstRecords.length;
		if(objUtilities.isNull(objRecord.objAdditionalInformation)) {
			objRecord.objAdditionalInformation = new Object();
		}
		objRecord.objAdditionalInformation.intPosition = intPosition;
		objRecord.intPosition = intPosition;

		//We generate the new record / row.
		objInnerRecord = objParent.processRecord({
			...objRecord,
			boolIsNewRecord: true
		});
		objInnerRecord.strClasses = objInnerRecord.strClasses.replace("slds-hide", "");
		objParent.lstRecords.splice(intPosition, 0, objInnerRecord);
		if(typeof this.lstRecords !== "undefined" && this.lstRecords !== null && this.lstRecords.length > 0) {
			this.boolHasRecords = true;
		}

	}

	/*
	 Method Name : removeRow
	 Description : This method removes the given row, based on its index.
	 Parameters	 : Integer, called from removeRow, intIndex Row index.
	 Return Type : None
	 */
	@api
	removeRow(intIndex) {
		let intPosition = -1;
		let objParent = this;

		//We delete the row.
		objParent.lstRecords.forEach(objRecord => {
			intPosition++;
			if(intPosition === intIndex) {
				objRecord.lstValues = null;
				objRecord.boolIsDeleted = true;
				objRecord.boolIsNewRecord = false;
			}
		});

		//We reset the positions.
		intPosition = -1;
		this.boolHasRecords = false;
		objParent.lstRecords.forEach(objRecord => {
			if(!objRecord.boolIsDeleted){
				this.boolHasRecords = true;
			}
			objParent.template.querySelectorAll("tr[data-id='" + objRecord.Id + "']").forEach(objInnerRow => {
				intPosition++;
				objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
					objCell.updatePosition(intPosition + 1);
				});
			});
		});

	}

	/*
	 Method Name : validateAllRowsAllFields
	 Description : This method validates all the rows and their fields.
	 Parameters	 : None
	 Return Type : Boolean
	 */
	@api
	validateAllRowsAllFields() {
		let boolResult = true;
		this.template.querySelectorAll("c-global-custom-cell").forEach(objCell => {
			if(boolResult && !objCell.validate()) {
				boolResult = false;
			}
		});
		return boolResult;
	}

	/*
	 Method Name : getNewRecords
	 Description : This method retreives all the new records and their values.
	 Parameters	 : None
	 Return Type : List
	 */
	@api
	getNewRecords() {
		let objRecord;
		let lstResults = new Array();
		let objParent = this;

		//We get all the rows.
		objParent.template.querySelectorAll("tr[data-is-new-record='true']").forEach(objRow => {
			objRecord = {
				strParentId: objRow.getAttribute("data-parent-id")
			};

			//We get all the cells of the current row.
			objRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				objRecord = {
					...objRecord,
					...objCell.getValueNewRecord(),
					intRowNumber: parseInt(objRow.getAttribute("data-row-number"))
				};
			});
			lstResults.push(objRecord);
		});
		return lstResults;
	}

	/*
	 Method Name : getUpdatedRecords
	 Description : This method retreives all the inline updated records and their values.
	 Parameters	 : None
	 Return Type : List
	 */
	@api
	getUpdatedRecords() {
		let objRecord;
		let lstResults = new Array();
		let objParent = this;

		//We get all the rows.
		if(objUtilities.isNotNull(objParent.lstDraftValues)) {
			objParent.lstDraftValues.forEach(objRow => {
				objParent.template.querySelectorAll("tr[data-id='" + objRow.Id + "']").forEach(objInnerRow => {
					objRecord = {
						... objRow,
						strParentId: objInnerRow.getAttribute("data-parent-id")
					};
		
					//We get all the cells of the current row.
					objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
						objRecord = {
							...objRecord,
							...objCell.getValueInlineUpdatedRecord(),
						};
					});
					lstResults.push(objRecord);
				});
			});
		}
		return lstResults;
	}	

	/*
	 Method Name : focusRecordField
	 Description : This method sets the focus to the specified record and field.
	 Parameters	 : Integer, called from focusRecordField, intRowNumber Row Number.
	 			   String, called from focusRecordField, strRowId Row Id.
	 			   String, called from focusRecordField, strFieldAPIName Field API Name.
	 Return Type : None.
	 */
	@api
	focusRecordField(intRowNumber, strRowId, strFieldAPIName) {
		this.template.querySelectorAll("tr[data-row-number='" + intRowNumber + "'],tr[data-id='" + strRowId + "']").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objCell.getFieldAPIName() === strFieldAPIName) {
					objCell.setFocus();
				}
			});
		});
	}

	/*
	 Method Name : setFieldValue
	 Description : This method sets the value to the specified record and field.
	 Parameters	 : Integer, called from setFieldValue, intRowNumber Row Number.
	 			   String, called from setFieldValue, strRowId Row Id.
	 			   String, called from setFieldValue, strFieldAPIName Field API Name.
				   Object, called from setFieldValue, objValue Value.
	 Return Type : None.
	 */
	@api
	setFieldValue(intRowNumber, strRowId, strFieldAPIName, objValue) {
		this.template.querySelectorAll("tr[data-row-number='" + intRowNumber + "'],tr[data-id='" + strRowId + "']").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objCell.getFieldAPIName() === strFieldAPIName) {
					objCell.setFieldValue(objValue);
				}
			});
		});
	}

	/*
	 Method Name : setFieldError
	 Description : This method indicates a field has an error.
	 Parameters	 : Integer, called from setFieldError, intRowNumber Row Number.
	 			   String, called from setFieldError, strRowId Row Id.
	 			   String, called from setFieldError, strFieldAPIName Field API Name.
				   Object, called from setFieldError, boolValue Value.
	 Return Type : None.
	 */
	@api
	setFieldError(intRowNumber, strRowId, strFieldAPIName, boolValue) {
		this.template.querySelectorAll("tr[data-row-number='" + intRowNumber + "'],tr[data-id='" + strRowId + "']").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objCell.getFieldAPIName() === strFieldAPIName) {
					objCell.setFieldError(boolValue);
				}
			});
		});
	}

	/*
	 Method Name : clearAllErrors
	 Description : This method clears all the rrors.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	clearAllErrors() {
		this.template.querySelectorAll("c-global-custom-cell").forEach(objCell => {
			objCell.setFieldError(false);
		});
	}

	/*
	 Method Name : getAllCellsValues
	 Description : This method returns all the cell values.
	 Parameters	 : None
	 Return Type : List
	 */
	@api
	getAllCellsValues() {
		let objValue;
		let objParent = this;
		let lstValues = new Array();

		//We get all the rows.
		objParent.template.querySelectorAll("tr[data-row-number],tr[data-id]").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objInnerRow.getAttribute("data-is-new-record") === "true") {
					objValue = objCell.getValueNewRecord()[objCell.getFieldAPIName()];
				} else {
					objValue = objCell.getValue();
				}
				lstValues.push({
					intRowNumber: objInnerRow.getAttribute("data-row-number"),
					strRowId: objInnerRow.getAttribute("data-id"),
					strFieldAPIName: objCell.getFieldAPIName(),
					objValue: objValue
				});
			});
		});
		return lstValues;
	}

	/*
	 Method Name : setFieldDisabled
	 Description : This method Enables / Disabled the specified record and field.
	 Parameters	 : Integer, called from setFieldDisabled, intRowNumber Row Number.
	 			   String, called from setFieldDisabled, strRowId Row Id.
	 			   String, called from setFieldDisabled, strFieldAPIName Field API Name.
				   Object, called from setFieldDisabled, boolSetDisabled If TRUE, the field will be disabled.
	 Return Type : None.
	 */
	@api
	setFieldDisabled(intRowNumber, strRowId, strFieldAPIName, boolSetDisabled) {
		this.template.querySelectorAll("tr[data-row-number='" + intRowNumber + "'],tr[data-id='" + strRowId + "']").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objCell.getFieldAPIName() === strFieldAPIName) {
					objCell.setFieldDisabled(boolSetDisabled);
				}
			});
		});
	}

	/*
	 Method Name : keyDown
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from keyDown, objEvent Event.
	 Return Type : None
	 */
	keyDown(objEvent) {
		this.dispatchEvent(new CustomEvent('keydown', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: objEvent
		}));
	}

	/*
	 Method Name : changed
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from changed, objEvent Event.
	 Return Type : None
	 */
	changed(objEvent) {
		this.dispatchEvent(new CustomEvent('changed', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: objEvent
		}));
	}

	/*
	 Method Name : startInlineEditingAllCells
	 Description : This method starts the inline editing feature for all the cells.
	 Parameters	 : None
	 Return Type : None.
	 */
	@api
	startInlineEditingAllCells() {
		this.template.querySelectorAll("c-global-custom-cell").forEach(objCell => {
			objCell.startEditing();
		});
	}

	/*
	 Method Name : getFieldValue
	 Description : This method gets the value to the specified record and field.
	 Parameters	 : Integer, called from getFieldValue, intRowNumber Row Number.
	 			   String, called from getFieldValue, strRowId Row Id.
	 			   String, called from getFieldValue, strFieldAPIName Field API Name.
				   Object, called from getFieldValue, objValue Value.
	 Return Type : None.
	 */
	@api
	getFieldValue(intRowNumber, strRowId, strFieldAPIName) {
		let objResult;
		this.template.querySelectorAll("tr[data-row-number='" + intRowNumber + "'],tr[data-id='" + strRowId + "']").forEach(objInnerRow => {
			objInnerRow.querySelectorAll("c-global-custom-cell").forEach(objCell => {
				if(objCell.getFieldAPIName() === strFieldAPIName) {
					if(objCell.isNewRecord()) {
						objResult = objCell.getValueNewRecord();
					} else {
						objResult = objCell.getValue();
					}
				}
			});
		});
		return objResult;
	}
}