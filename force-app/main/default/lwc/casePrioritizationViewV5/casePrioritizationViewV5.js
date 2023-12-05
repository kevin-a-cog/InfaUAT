/*
Change History
************************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
************************************************************************************************************
balajip         11/22/2021  I2RT-4953   T01     added I am On/Off it functionalities
Piyush			12/15/2021	I2RT-4908   T02		Internal and Attention Request milestone violation exempted
balajip         12/22/2021  I2RT-5175   T03     to clear the selectedCases variable once processed
Amit	        08/27/2022  I2RT-6671   T04     Colloborate Queues are not refreshed according to the User selected
balajip	        01/12/2023  I2RT-7282   T05     To include two more fields in the Collaboration table.
balajip	        01/12/2023  I2RT-7673   T06     To prevent multiple clicks on the Save Button in the Feedback Popup
Sandeep Duggi   Oct 17 '23  I2RT-9219   T07     P0 Flag - SALT enhancements

*/

import { LightningElement,wire,api, track } from 'lwc';
import YellowCircle from '@salesforce/resourceUrl/YellowCircle';
import RedCircle from '@salesforce/resourceUrl/RedCircle';
import Case_Owner from '@salesforce/resourceUrl/Case_Owner';
import Customer from '@salesforce/resourceUrl/Customer';
import caseTeam from '@salesforce/resourceUrl/caseTeam';
import TargetIcon from '@salesforce/resourceUrl/TargetIcon';
import engineerWorkspaceIconCRE from '@salesforce/resourceUrl/engineerWorkspaceIconCRE';
import engineerWorkspaceIconPS from '@salesforce/resourceUrl/engineerWorkspaceIconPS';
import engineerWorkspaceIconMP from '@salesforce/resourceUrl/engineerWorkspaceIconMP';
import engineerWorkspaceIconCO from '@salesforce/resourceUrl/engineerWorkspaceIconCO';
import AskAnExpert from '@salesforce/resourceUrl/AskAnExpert';
import Inactive_Case from '@salesforce/resourceUrl/Inactive_Case';
import RatingIcon from '@salesforce/resourceUrl/RatingIcon';
import PreviewIcon from '@salesforce/resourceUrl/PreviewIcon';
import Thumbs_Down_Icon from '@salesforce/resourceUrl/Thumbs_Down_Icon';
import Thumbs_Up_Icon from '@salesforce/resourceUrl/Thumbs_Up_Icon';
import NextIcon from '@salesforce/resourceUrl/NextIcon';
import PreviousIcon from '@salesforce/resourceUrl/PreviousIcon';
import Console_Button_Icons from '@salesforce/resourceUrl/Console_Button_Icons';
import Collab_Icon from '@salesforce/resourceUrl/Collab_Icon';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import Id from '@salesforce/user/Id'; 
import { loadStyle, loadScript } from 'lightning/platformResourceLoader'; //T07
import 	gcsSrc from '@salesforce/resourceUrl/gcsSrc';  //T07

// Import Apex Class
import Caseview from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.Caseview';
import fetchCasesGroupByQueue from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.fetchCasesGroupByQueue';
import updateCaseOwner from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.updateCaseOwner';
import userOnIt from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.userOnIt';
import userOffIt from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.userOffIt';
import insertWeightageRating from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.insertWeightageRating';
import isGCSManagerPermission from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.isGCSManagerPermission';
import buildTimeLine from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.buildTimeLine';
import acceptRaiseHand from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.acceptRaiseHand';
import getURLFromMetadata from '@salesforce/apex/CaseController.getTableauDashboardLinks';
import {getListUi} from 'lightning/uiListApi';
import { getListInfoByName } from 'lightning/uiListsApi';
import Case_OBJECT from '@salesforce/schema/Case';

const ratingCss = "height:60px; margin-top: 25px; padding: 7px; cursor: pointer;";
let SelectRating = false;
let customerRating='';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Controllers.
import getAttentionRecords from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.getAttentionRecords';
import getCaseRecords from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.fetchCasesBasedOnListView';
import getUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.getUserPreferences';
import setUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.setUserPreferences';
import getColorLegend from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.getColorLegend';

//Class body.
export default class CasePrioritizationViewV5 extends NavigationMixin(LightningElement) {

	//User preferences variable.
	objUserPreferences = new Object();

	//Table variables.
	objParameters = {
		strTableId: "1",
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolForceCheckboxes: true,
		lstRecords: new Array(),
		lstColumns: new Array()
	};
	lstCollaborateColumns = [
		{
			label:'Name',
			fieldName:'RecordURL', 
			type:'url',
			sortable:true,
			initialWidth: 180,
			typeAttributes:{
				label:{
					fieldName : 'RecordName'
				},
			   
			}
		},
		{
			label:'Case Number',
			fieldName:'CaseURL', 
			type:'url',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseNumber'
				},
			   
			}
		},
		{
			label:'Case Priority',
			fieldName:'CasePriority', 
			type:'text',
			sortable:true,
			initialWidth: 110,
			typeAttributes:{
				label:{
					fieldName : 'CasePriority'
				},
			   
			}
		},
		{
			label:'Product', 
			fieldName:'Product', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'Product'
				},
			}
		}, 
        {
			label:'Collaborator Team',
			fieldName:'CollaboratorTeam', 
			type:'text',
			sortable:true,
			initialWidth: 150,
			typeAttributes:{
				label:{
					fieldName : 'CollaboratorTeam'
				},
			   
			}
		},
        {
			label:'Case Owner',
			fieldName:'CaseOwner', 
			type:'text',
			sortable:true,
			initialWidth: 150,
			typeAttributes:{
				label:{
					fieldName : 'CaseOwner'
				},
			   
			}
		},
		//T05
        {
			label:'Case Owner Manager',
			fieldName:'CaseOwnerManager', 
			type:'text',
			sortable:true,
			initialWidth: 150,
			typeAttributes:{
				label:{
					fieldName : 'CaseOwnerManager'
				},
			   
			}
		},
		//T05
        {
			label:'Case Owner Team',
			fieldName:'CaseOwnerTeam', 
			type:'text',
			sortable:true,
			initialWidth: 150,
			typeAttributes:{
				label:{
					fieldName : 'CaseOwnerTeam'
				},
			   
			}
		},
        {
			label:'Case Component',
			fieldName:'CaseComponent', 
			type:'text',
			sortable:true,
			initialWidth: 150,
			typeAttributes:{
				label:{
					fieldName : 'CaseComponent'
				},
			   
			}
		},
		{
			label:'Case Timezone',
			fieldName:'CaseTimezoneURL', 
			type:'url',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseTimezone'
				},
			}
		},
		{
			label:'Case Record Type',
			fieldName:'CaseRecordType', 
			type:'text',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseRecordType'
				},
			}
		},
		{
			label:'Created Date',
			fieldName:'CreatedDate', 
			type:'date',
			sortable:true,
			initialWidth: 300,
			typeAttributes:{
				label:{
					fieldName : 'CreatedDate'
				},
				year: "numeric",
				month: "2-digit",
				day: "2-digit",
				hour: "2-digit",
				minute: "2-digit"
			}
		},
		{
			label:'Title',
			fieldName:'Title', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'Title'
				},
			   
			}
		},
		{
			label:'Support Account',
			fieldName:'SupportAccount', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'SupportAccount'
				},
			   
			}
		}
	];
	lstAttentionRequestColumns = [
		{
			label:'Case Number',
			fieldName:'CaseURL', 
			type:'url',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseNumber'
				},
			}
		},
		{
			label:'Case Priority',
			fieldName:'Priority', 
			type:'text',
			sortable:true,
			initialWidth: 110,
			typeAttributes:{
				label:{
					fieldName : 'Priority'
				},
			}
		},
		{
			label:'Case Product',
			fieldName:'Product', 
			type:'text',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'Product'
				}
			}
		},
		{
			label:'Type',
			fieldName:'Type', 
			type:'text',
			sortable:true,
			initialWidth: 100,
			typeAttributes:{
				label:{
					fieldName : 'Type'
				},
			   
			}
		},
		{
			label:'Next Action',
			fieldName:'NextAction', 
			type:'text',
			sortable:true,
			initialWidth: 110,
			typeAttributes:{
				label:{
					fieldName : 'NextAction'
				},
			   
			}
		},
		{
			label:'Case Owner Team',
			fieldName:'CaseOwnerTeam', 
			type:'text',
			sortable:true,
			initialWidth: 110,
			typeAttributes:{
				label:{
					fieldName : 'CaseOwnerTeam'
				},
			   
			}
		},
		{
			label:'Case Owner',
			fieldName:'CaseOwner', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'CaseOwner'
				},
			   
			}
		},
		{
			label:'Component',
			fieldName:'Component', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'Component'
				},
			   
			}
		},
		{
			label:'Case Timezone',
			fieldName:'CaseTimezoneURL', 
			type:'url',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseTimezone'
				},
			}
		},
		{
			label:'Case Record Type',
			fieldName:'CaseRecordType', 
			type:'text',
			sortable:true,
			initialWidth: 140,
			typeAttributes:{
				label:{
					fieldName : 'CaseRecordType'
				}
			}
		},
		{
			label:'Created Date',
			fieldName:'CreatedDate', 
			type:'date',
			sortable:true,
			initialWidth: 350,
			typeAttributes:{
				label:{
					fieldName : 'CreatedDate'
				},
				year: "numeric",
				month: "2-digit",
				day: "2-digit",
				hour: "2-digit",
				minute: "2-digit"
			}
		},
		{
			label:'Comment',
			fieldName:'Comment', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'Comment'
				},
			   
			}
		},
		{
			label:'Support Account',
			fieldName:'SupportAccountName', 
			type:'text',
			sortable:true,
			initialWidth: 200,
			typeAttributes:{
				label:{
					fieldName : 'SupportAccountName'
				},
			   
			}
		}
	];

	//Sorting variables.
	@track objTableConfigurationCase = {
		strSortBy: 'CaseNumber',
		strSortDirection: 'asc'
	};
	@track objTableConfigurationAttention = {
		strSortBy: 'Name',
		strSortDirection: 'asc'
	};

	//Refreshing variables.
	@track strRecordId;
    selectedCases = [];

	//Track variables.
	@track lstCollaborations;

	//Private variables.
	boolInitialSortingAttentionRequest = true;
	boolInitialSortingCases = true;
	boolDisplayLegend = false;
	boolDisplayAttentionRequestSection;
	boolCustomCSSLoaded;
	boolActiveMouseMove;
	boolDisplaySaltViewSpinner;
	boolDisplayAttentionSpinner;
	boolDisplayCaseSpinner;
	boolDisplayCollaborateSpinner;
	boolIsAutorefreshActive = false;
	intCurrentSlippterPosition;
	intLatestSplitterPosition = 438;
	intAutorefreshCounter = 30;
	strLegendButtonVariant = "";
	strSelectedTimeframe = "30";
	strAutorefreshCounterLabel;
	strTableDivStyle = "width: 438px;";
	strOldPinnedValue;
	strPinVariant;
	strPinnedListView;
	objInfiniteLoop;
	lstAttentionRecords = new Array();
	lstCustomCSS = new Array();
	showviewas = false;
	lstTimeframeOptions;

	//T01
	@track showConfirmation = false;
	@track showConfirmationContinue = false;
	@track confirmationModalTitle = '';
	@track confirmationModalContent = '';
	confirmationFor = '';

	//Modal properties.
	boolIsAttentionRequestPoppedOut = false;
	boolIsCasePoppedOut = false;
	boolIsSaltViewPoppedOut = false;
	get objAttentionModalProperties() {
		if(this.boolIsAttentionRequestPoppedOut) {
			return objUtilities.getPopOutCSSOpen();
		} else {
			return objUtilities.getPopOutCSSClosed();
		}
	}
	get objCaseModalProperties() {
		if(this.boolIsCasePoppedOut) {
			return objUtilities.getPopOutCSSOpen();
		} else {
			return objUtilities.getPopOutCSSClosed();
		}
	}
	get objSaltViewModalProperties() {
		if(this.boolIsSaltViewPoppedOut) {
			return objUtilities.getPopOutCSSOpen();
		} else {
			return objUtilities.getPopOutCSSClosed();
		}
	}

	/*
	 Method Name : executeSorting
	 Description : This method executes the table sorting process.
	 Parameters	 : Object, called from executeSorting, objEvent Sorting event.
	 Return Type : None
	 */
	executeSorting(objEvent) {
		let strTableName = objEvent.target.dataset.name;
		let strSortBy = objEvent.detail.fieldName;
		let strSortByOriginal = objEvent.detail.fieldName;
		let strSortDirection = objEvent.detail.sortDirection;
		let objParent = this;

		//Now we save the user selection, fetching first the current data.
		getUserPreferences().then(objResult => {

			//Now we update the sorting.
			objResult.mapDataTablesSorting[strTableName] = {
				strFieldName: strSortBy,
				strSortDirection: strSortDirection
			};

			//Now we save the new changes.
			objParent.objUserPreferences = objResult;
			setUserPreferences({
				objRecord: objParent.objUserPreferences
			});
		});

		//Now we find the table.
		switch(strTableName) {
			case "Attention":
				if(strSortBy === "CaseURL") {
					strSortBy === "CaseNumber"
				} else if(strSortBy === "CaseCommentURL") {
					strSortBy === "CaseCommentName"
				}
				objParent.objTableConfigurationAttention.strSortBy = strSortByOriginal;
				objParent.objTableConfigurationAttention.strSortDirection = strSortDirection;
				objParent.lstAttentionRecords = objParent.sortData(strSortBy, strSortDirection, objParent.lstAttentionRecords);
			break;
			default:
				if(strSortBy === "RecordURL") {
					strSortBy === "RecordName"
				} else if(strSortBy === "CaseURL") {
					strSortBy === "CaseNumber"
				}
				objParent.lstCollaborations.forEach(objCollaborations => {
					if(strTableName === objCollaborations.strType) {
						objCollaborations.objTableConfiguration.strSortBy = strSortByOriginal;
						objCollaborations.objTableConfiguration.strSortDirection = strSortDirection;
						objCollaborations.lstRecords = objParent.sortData(strSortBy, strSortDirection, objCollaborations.lstRecords);
					}
				});
			break;
		}
	}
	
	/*
	 Method Name : sortData
	 Description : This method sorts the data of the giving table.
	 Parameters	 : Object, called from sortData, objEvent Sorting event.
	 Return Type : List
	 */
	sortData(strFieldName, strSortDirection, lstData) {
		let lstDataToBeSorted = Object.assign([], lstData);
		let lstSortedData = lstDataToBeSorted.sort(function(objA, objB) {
			if(objA[strFieldName] < objB[strFieldName]) {
				return strSortDirection === 'asc' ? -1 : 1;
			} else if(objA[strFieldName] > objB[strFieldName]) {
				return strSortDirection === 'asc' ? 1 : -1;
			} else {
				return 0;
			}
		});
		return lstSortedData;
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
				objParent.executeSorting({
					"detail": {
						"fieldName": objResult.strFieldName,
						"sortDirection": objResult.strSortDirection
					},
					"target": {
						"dataset": {
							"name": strTableName
						}
					}
				});
			}
		}
	}
	
	/*
	 Method Name : refreshTable
	 Description : This method refreshes a given table (or all).
	 Parameters	 : Object, called from refreshTable, objEvent click event.
	 Return Type : List
	 */
	refreshTable(objEvent) {
		let strName;
		if(objUtilities.isNotNull(objEvent)) {
			strName = objEvent.target.dataset.name;
		}
		switch(strName) {
			case "Case":
				this.value = this.objTableConfigurationCase.value;
				this.columns = this.objTableConfigurationCase.columns;
				this.loadCaseRecords();
			break;
			case "Attention":
				this.loadAttentionRecords();
			break;
			case "Collaboration":
				this.fetchCases(objEvent.target.dataset.type);
			break;
			default:
				this.boolDisplaySaltViewSpinner = true;

				//We clean up the values first.
				this.value = this.objTableConfigurationCase.value;
				this.columns = this.objTableConfigurationCase.columns;

				//Now we reload the records.
				this.loadCaseRecords();
				this.fetchCases();
				this.loadAttentionRecords();
				this.fetchCaseView();
			break;
		}
	}
	
	/*
	 Method Name : loadAttentionRecords
	 Description : This method loads the Attention records.
	 Parameters	 : None
	 Return Type : None
	 */
	loadAttentionRecords() {
		let objProcessedRecord;
		let objParent = this;

		//Now we set the default variables.
		objParent.boolDisplayAttentionSpinner = true;
		objParent.lstAttentionRecords = new Array();

		//Now we load the data from the backend.
		getAttentionRecords().then(lstRecords => {

			//Now we make sure we received records.
			if(objUtilities.isNotNull(lstRecords) && lstRecords.length > 0) {
				lstRecords.forEach(objRecord => {
					objParent.boolDisplayAttentionRequestSection = true;
					objProcessedRecord = {... objRecord};
					objProcessedRecord.CaseNumber = objProcessedRecord.Case_Number__c;
					objProcessedRecord.CaseURL = '/lightning/r/Case/' + objProcessedRecord.Case__c + '/view';
					objProcessedRecord.CaseCommentName = objProcessedRecord.Name;
					objProcessedRecord.CaseCommentURL = '/lightning/r/Case_Comment__c/' + objProcessedRecord.Id + '/view';
					objProcessedRecord.Priority = objProcessedRecord.Case_Priority__c;
					objProcessedRecord.Status = objProcessedRecord.Case__r.Status;
					objProcessedRecord.Subject = objProcessedRecord.Case__r.Subject;
					objProcessedRecord.Product = objProcessedRecord.Case_Product__c;
					objProcessedRecord.Type = objProcessedRecord.Type__c;
					//objProcessedRecord.NextAction = objProcessedRecord.Case__r.Next_action__c;
					//objProcessedRecord.CaseOwnerTeam = objProcessedRecord.Case__r.Case_Owner_Team__c;
					objProcessedRecord.NextAction = objProcessedRecord.Case_Next_Action__c;
					objProcessedRecord.CaseOwnerTeam = objProcessedRecord.Case_Owner_Team__c;
					objProcessedRecord.CaseOwner = objProcessedRecord.Case_Owner__c;
					objProcessedRecord.Component = objProcessedRecord.Case__r.Component__c;
					if(objUtilities.isNotNull(objProcessedRecord.Case__r) && objUtilities.isNotBlank(objProcessedRecord.Case__r.Case_Timezone__c)) {
						objProcessedRecord.CaseTimezone = objProcessedRecord.Case__r.Case_Timezone__r.Name;
						objProcessedRecord.CaseTimezoneURL = '/lightning/r/Case_Timezone__c/' + objProcessedRecord.Case__r.Case_Timezone__c + '/view';
					}
					objProcessedRecord.CaseRecordType = objProcessedRecord.Case__r.Record_Type_Name__c;
					objProcessedRecord.CreatedDate = objProcessedRecord.CreatedDate;
					objProcessedRecord.Comment = objProcessedRecord.Comment__c;
					objProcessedRecord.Case_Timezone_Name__c = objProcessedRecord.Case__r.Case_Timezone_Name__c;
					objProcessedRecord.Case_Owner_Team__c = objProcessedRecord.Case__r.Case_Owner_Team__c;
					objProcessedRecord.Owner_Name__c = objProcessedRecord.Case__r.Owner_Name__c;
					if(objProcessedRecord.Case__r.Support_Account__r) {
						objProcessedRecord.SupportAccountName = objProcessedRecord.Case__r.Support_Account__r.Name;
					}
					objProcessedRecord.Comment__c = objParent.stripHtml(objProcessedRecord.Comment__c);
					objParent.lstAttentionRecords.push(objProcessedRecord);
				});

				//We run the initial sorting.
				if(objParent.boolInitialSortingAttentionRequest) {
					objParent.boolInitialSortingAttentionRequest = false;
					objParent.initialSort("Attention");
				}
			} else {
				objParent.boolDisplayAttentionRequestSection = false;
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplayAttentionSpinner = false;
		});
	}
	
	/*
	 Method Name : loadCaseRecords
	 Description : This method loads the Case records.
	 Parameters	 : None
	 Return Type : None
	 */
	loadCaseRecords() {
		let objProcessedRecord;
		let objParent = this;

		//T03
		this.selectedCases = [];

		//Now we make sure we received the variables.
		if(objUtilities.isNotBlank(objParent.value) && objUtilities.isNotBlank(objParent.columns)) {

			//Now we set the default variables.
			objParent.boolDisplayCaseSpinner = true;
			objParent.objParameters.lstRecords = new Array();
			objParent.records = new Array();

			//Now we load the data from the backend.
			getCaseRecords({
				ListViewName: objParent.value, 
				columns: objParent.columns
			}).then(lstRecords => {

				//Now we make sure we received records.
				if(objUtilities.isNotNull(lstRecords) && objUtilities.isNotNull(lstRecords.AllCases)) {
					lstRecords.AllCases.forEach(objRecord => {
						objProcessedRecord = new Object();
						objProcessedRecord['Id'] = objRecord['Id'];
						objProcessedRecord['caseURL'] ='/lightning/r/Case/'+ objRecord['Id']+'/view';
						objProcessedRecord['CaseNumber'] = objRecord['CaseNumber'];

						//We execute the old code, as is.
						for(var m=0; m<this.objParameters.lstColumns.length;m++){
							var fieldInfo = this.objParameters.lstColumns[m];
							if(fieldInfo.fieldName != 'Id' && fieldInfo.fieldName != 'caseURL' && fieldInfo.fieldName != 'CaseNumber'){
								var fieldkey = fieldInfo.fieldName;
								var fieldvalue = '';
								if(fieldkey.indexOf('.') == -1){
									fieldvalue = objRecord[fieldkey];
								}else{
									var parentfieldData = fieldkey.split('.');
									var parentObj = objRecord[parentfieldData[0]];
									if( parentObj === undefined){}else{
										fieldvalue =parentObj[parentfieldData[1]];
									}
								}
								objProcessedRecord[fieldkey] = fieldvalue;
							}
						} 
						objParent.objParameters.lstRecords.push({... objProcessedRecord});
					});
					objParent.records = [... objParent.objParameters.lstRecords];

					//We run the initial sorting.
					if(objParent.boolInitialSortingCases) {
						objParent.boolInitialSortingCases = false;
					}
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {

				//Finally, we hide the spinner.
				objParent.boolDisplayCaseSpinner = false;
			});
		}
	}
	
	/*
	 Method Name : forceUniqueValues
	 Description : This method ensures the List View values of the dual box are unique.
	 Parameters	 : None
	 Return Type : None
	 */
	forceUniqueValues() {
		let boolIsIncluded;
		let objParent = this;
		let lstUniqueValuesSelected = new Array();
		let lstUniqueValuesOptions = new Array();

		//First we review Selected values.
		if(objUtilities.isNotNull(objParent.selectedListViews)) {
			objParent.selectedListViews.forEach(strElement => {
				if(!lstUniqueValuesSelected.includes(strElement)) {
					lstUniqueValuesSelected.push(strElement);
				}
			});
			objParent.selectedListViews = [... lstUniqueValuesSelected];
		}

		//Now we review Available values.
		if(objUtilities.isNotNull(objParent.optionstoSelect)) {
			objParent.optionstoSelect.forEach(objElement => {
				boolIsIncluded = false;
				lstUniqueValuesOptions.forEach(objNewElement => {
					if(objNewElement.value === objElement.value) {
						boolIsIncluded = true;
					}
				});
				if(!boolIsIncluded) {
					lstUniqueValuesOptions.push(objElement);
				}
			});
			objParent.optionstoSelect = [... lstUniqueValuesOptions];
		}
	}
	
	/*
	 Method Name : activateDeactivateAutorefresh
	 Description : This method activates / deactivates the autorefresh.
	 Parameters	 : None
	 Return Type : None
	 */
	activateDeactivateAutorefresh() {
		let objParent = this;

		//Now we get the toggle value.
		objParent.boolIsAutorefreshActive = !objParent.boolIsAutorefreshActive;

		//Now we save the user selection, fetching first the current data.
		getUserPreferences().then(objResult => {
			objResult.objEngineerWorkspace.boolAutorefreshActive = objParent.boolIsAutorefreshActive;

			//Now we save the new changes.
			objParent.objUserPreferences = objResult;
			setUserPreferences({
				objRecord: objParent.objUserPreferences
			});
		});
	}

    // for plateform event
    @track metadataRecordURL = '';
    subscription = {};
    @api channelName = '/event/Case__e';

    subscriptionRH = {};
    @api channelNameRaiseHand = '/event/RaiseHand_PE__e';

    subscriptionCC = {};
    @api channelNameCaseComments = '/event/CaseComment_PE__e';

    @track
    stateVariant = {
        queueVariant: '',
        allVariant: 'brand',
        teamsVariant: '',
        dashboardVariant: ''
    }
    @track activeSections = ["A", "C"];
    activeSectionCaseTeam = [];
    currentPreviewId = '';
    headerToggleIcon = 'action:new'; 
    userId = Id;
	ResourceAskAnExpert=AskAnExpert;
    ResourceCustomer = Customer;
    ResourceYellowCircle=YellowCircle;
    ResourceRedCircle = RedCircle;
    ResourceCase_Owner = Case_Owner;
    ResourceCaseTeam = caseTeam;
    ResourceTargetIcon = TargetIcon;
    ResourceInactive_Case=Inactive_Case;
    ResourceRatingIcon = RatingIcon;
    ResourcePreviewIcon = PreviewIcon;
    ResourceThumbs_Down_Icon = Thumbs_Down_Icon;
    ResourceThumbs_Up_Icon = Thumbs_Up_Icon;
    ResourceNextIcon = NextIcon;
    ResourcePreviousIcon = PreviousIcon;
    ResourceConsole_Button_Icons = Console_Button_Icons + '/expert.png';
    ResourceCollab_Icon = Collab_Icon;

	resourceEngineerWorkspaceIconCRE = engineerWorkspaceIconCRE;
	resourceEngineerWorkspaceIconPS = engineerWorkspaceIconPS;
	resourceEngineerWorkspaceIconMP = engineerWorkspaceIconMP;
	resourceEngineerWorkspaceIconCO = engineerWorkspaceIconCO;
    resourceEngineerWorkspaceIconP0 =  gcsSrc + '/RedCircleWithP0.svg';  //T07

    caseNotificationViewSize = 3;
    caseNotificationEngagedViewSize = 3;
    saltViewSize = 6;
    selectUSID;
    bShowCaseNotification = true;
    bShowCaseEngagedNotification = true;
    oWrapperData = {};
    caseNotificationToggleIcon = 'utility:left';
    caseNotificationEngagedToggleIcon = 'utility:right';
    bRatingOverlay = false;
	bDisableSaveReviewBtn = true; //T06
    bShowCasePreview = false;
    bShowSingleCasePreview = false;
    bShowSingleRhPreview = false;
    bShowLookup = true;
    currentPreviewRHId = '';
    mapGrpIdWiseCasesWrapper = [];
    error;
    errorMessage = 'Salt View is loading';
	boolDisplaySaltViewWarningMessage = true;
    wireCaseData;
    wireCaseListView;
    isGCS_Manager;
    myQueueList;
    voteDownRating = ratingCss + 'margin-left: 80px';
    voteUpRating = ratingCss + 'margin-left: 100px';

    ratingCaseObj = {}; // to store current selected case 
    currentPreviewCase = {};// to store current selected case for preview 
    comment = '';
    selectedUser = {};
    sortedBy;
    sortedDirection;
    @api sSelectedUserId = null;
    @api sSelectedUserName = '';
    caseTeamListWrapper = [];
    bDisablePreviousCaseBtn = false;
    bDisableNextCaseBtn = false;
    lstCaseTimeLine = [];

    lstRaiseHandConsolidate=[];

    options;
    optionstoSelect;
	records = [];
	
	selectedCaseListViewLabel = ''; //T01
	value;
    showListView = false;
    showModal = false;
    btnDefaultValue = "all";
    buttonOptions=[
        { label: 'Queue', value: 'queue' },
        { label: 'All', value: 'all' },
        { label: 'Salt View', value: 'saltview'}
    ];
    bFAQoverlay = false;
    isCaseLoading = false;
    ListViewValue = 'RecentlyViewedCases';
    selectedListViews;
    columns;

    @wire(getListInfoByName, {
        objectApiName: Case_OBJECT.objectApiName,
        listViewApiName: '$value'
    })listInfo({ error, data }) {
        if (data) {
            var col = [];
            this.columns = '';
			this.selectedCaseListViewLabel = data.label;//T01
			//console.log('wire.. getListInfoByName >> ', this.selectedCaseListViewLabel);

            for(var i=0;i<data.displayColumns.length;i++){
				var fieldAPIName = data.displayColumns[i].fieldApiName;
				console.log('wire getListInfoByName,  fieldAPIName >> ', fieldAPIName);
                if(fieldAPIName == 'CaseNumber'){
                    col.push({
                        label:'Case Number',
                        fieldName:'caseURL', 
                        type:'url',
                        sortable:true,
						initialWidth: 140,
                        typeAttributes:{
                            label:{
                                fieldName : 'CaseNumber'
                            },
                           
                        }
                    });
                
                } else if(fieldAPIName === 'Milestone_status__c' || fieldAPIName === 'GCS_Segment__c'){
                    col.push({
						sortable: false, 
						initialWidth: 150,
						label: data.displayColumns[i].label,
						fieldName: fieldAPIName,
                        type: "custom",
						subtype: "html",
                        typeAttributes:{
                            label: {
                                fieldName : fieldAPIName
                            },
							subtype: "html"
                        }
                    });
                } else if(fieldAPIName == 'CreatedDate') {
					col.push({
                        label:'Date/Time Opened',
						fieldName:'CreatedDate', 
						type:'date',
						sortable:true,
						initialWidth: 200,
						typeAttributes:{
							label:{
								fieldName : 'CreatedDate'
							},
							year: "numeric",
							month: "2-digit",
							day: "2-digit",
							hour: "2-digit",
            				minute: "2-digit"
						}
                    });
				} else if(fieldAPIName == 'LastModifiedDate') {
					col.push({
                        label:'Last Modified Date',
						fieldName:'LastModifiedDate', 
						type:'date',
						sortable:true,
						initialWidth: 200,
						typeAttributes:{
							label:{
								fieldName : 'LastModifiedDate'
							},
							year: "numeric",
							month: "2-digit",
							day: "2-digit",
							hour: "2-digit",
            				minute: "2-digit"
						}
                    });
				} else if(fieldAPIName == 'Account.Name' || fieldAPIName == 'Contact.Name' || 
						fieldAPIName == 'Owner.NameOrAlias') {
                    col.push({
						sortable:true, 
						initialWidth: 200,
						'label':data.displayColumns[i].label,
						'fieldName':fieldAPIName});
				//T01
				}else if(fieldAPIName == 'Is_case_claimed_weekend_holiday__c' && this.selectedCaseListViewLabel == 'Weekend/Holiday Support'){
					//ignore the column.
				}else if(fieldAPIName == 'Case_claimed_by_user_weekend_holiday__r.Name' && this.selectedCaseListViewLabel == 'Weekend/Holiday Support'){
                    col.push({
						sortable:true, 
						initialWidth: 150,
						'label':'Proxy Engineer',
						'fieldName':fieldAPIName
					});
				}else{
                    col.push({
						sortable:true, 
						initialWidth: 150,
						'label':data.displayColumns[i].label,
						'fieldName':fieldAPIName
					});
                }
                if(this.columns == undefined || this.columns == ''){
                    this.columns =  '' + fieldAPIName + ',';
                }else{
                    this.columns = this.columns + fieldAPIName + ',';
                }
            }
            this.objParameters.lstColumns = col;
			this.objTableConfigurationCase.value = this.value;
			this.objTableConfigurationCase.columns = this.columns;
            this.loadCaseRecords();
        } else if (error) {
            console.log('@@-error->>'+error);
        }
    }
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
           var ref = JSON.parse(JSON.stringify(currentPageReference));     

           if(ref.state.c__sSelectedUserId){
            this.sSelectedUserId = ref.state.c__sSelectedUserId;
			//----------------------------------Sticky User                
			this.sSelectedUserId = ref.state.c__sSelectedUserId;
			this.strRecordId = ref.state.c__sSelectedUserId;
			this.showviewas = true;
			//-----------------------------------End
            this.connectedCallback();
            if(this.sSelectedUserId != this.userId){
                var userName = ref.state.c__sSelectedUserName; 
				
                this.showToastpester('Success!' , 'View As ' + userName , 'warning'); 
            }
           }
       }
    }
 
    handledashboardclick(event) {
		let strSection = event.currentTarget.name;
		let objParent = this;

		//First we save the selection.
		getUserPreferences().then(objResult => {
			objResult.objEngineerWorkspace.strView = strSection;

			//Now we save the new changes.
			objParent.objUserPreferences = objResult;
			setUserPreferences({
				objRecord: objParent.objUserPreferences
			});
		});
		this.strTableDivStyle = "width: " + (this.intLatestSplitterPosition - 65) + "px";

		//Now we switch the view.
        switch (strSection) {
            case "queues":
                this.stateVariant.queueVariant = "brand";
                this.stateVariant.allVariant = "";
                this.stateVariant.teamsVariant = "";
                this.stateVariant.dashboardVariant = "";
                this.template.querySelector('.saltView').style.display = 'none';
                this.template.querySelector('.splitViewCls2').style.display = 'none';
                this.template.querySelector('.dashboard').style.display = 'none';
                this.template.querySelector('.queueView').style.display = '';
				this.strTableDivStyle = "width: 95vw;";
                break;
            case "all":
                this.stateVariant.queueVariant = "";
                this.stateVariant.allVariant = "brand";
                this.stateVariant.teamsVariant = "";
                this.stateVariant.dashboardVariant = "";
                this.template.querySelector('.queueView').style.display = '';
                this.template.querySelector('.accordianClass').style.display = '';
                this.template.querySelector('.accordianClass1').style.display = '';
                this.template.querySelector('.saltView').style.display = '';
                this.template.querySelector('.splitViewCls2').style.display = '';
                this.template.querySelector('.dashboard').style.display = 'none';
                break;
            case "saltview":
                this.stateVariant.queueVariant = "";
                this.stateVariant.allVariant = "";
                this.stateVariant.teamsVariant = "brand";
                this.stateVariant.dashboardVariant = "";
                this.template.querySelector('.queueView').style.display = 'none';
                this.template.querySelector('.dashboard').style.display = 'none';
                this.template.querySelector('.accordianClass').style.display = '';
                this.template.querySelector('.accordianClass1').style.display = '';
                this.template.querySelector('.saltView').style.display = '';
                this.template.querySelector('.splitViewCls2').style.display = '';
                break;
            case "dashboard":
                this.stateVariant.queueVariant = "";
                this.stateVariant.allVariant = "";
                this.stateVariant.teamsVariant = "";
                this.stateVariant.dashboardVariant = "brand";
                this.template.querySelector('.queueView').style.display = 'none';
                this.template.querySelector('.dashboard').style.display = '';
                this.template.querySelector('.accordianClass').style.display = 'none';
                this.template.querySelector('.accordianClass1').style.display = 'none';
                this.template.querySelector('.saltView').style.display = '';
                this.template.querySelector('.splitViewCls2').style.display = 'none';
                break;
            default:
                break;
        }
    }
  
    toggleSections(event){
        let whichBtn = event.target.name;
        let currentAccrodion = this.template.querySelectorAll('[data-uid="' +whichBtn+ '"]')[0];
        let currentIconDivDown = this.template.querySelectorAll('[data-icondivdown="' +whichBtn+ '"]')[0];
        let currentIconDivRight = this.template.querySelectorAll('[data-icondivright="' +whichBtn+ '"]')[0];
        
        if(currentAccrodion.classList.contains('slds-is-open')){
            currentAccrodion.classList.remove('slds-is-open');
        }else{
            currentAccrodion.classList.add('slds-is-open');
        }     
        currentIconDivDown.classList.toggle('slds-hide');
            currentIconDivRight.classList.toggle('slds-hide');
    }

    connectedCallback(){
		let objParent = this;

		//First we get the subscription record.
		getUserPreferences().then(objResult => {

			//We store the user preferences.
			objParent.objUserPreferences = objResult;

			//First we get the picklist values.
			objParent.lstTimeframeOptions = objResult.lstTimeframes;

			//Now we set the selections.
			objParent.boolIsAutorefreshActive = objResult.objEngineerWorkspace.boolAutorefreshActive;
			objParent.intAutorefreshCounter = objResult.objEngineerWorkspace.intAutorefreshSeconds;
			objParent.strSelectedTimeframe = "" + objParent.intAutorefreshCounter;

			//Now we set a loop that will refresh everything every 30 seconds.
			objParent.objInfiniteLoop = setInterval(function() {
				if(objParent.boolIsAutorefreshActive) {
					if(objParent.intAutorefreshCounter === 1) {
						objParent.refreshTable();
						objParent.intAutorefreshCounter = objParent.objUserPreferences.objEngineerWorkspace.intAutorefreshSeconds;
					} else {
						objParent.intAutorefreshCounter--;
					}
					objParent.strAutorefreshCounterLabel = "Autorefresh in " + objParent.intAutorefreshCounter + " second(s)";
				} else {
					objParent.intAutorefreshCounter = objParent.objUserPreferences.objEngineerWorkspace.intAutorefreshSeconds;
					objParent.strAutorefreshCounterLabel = "No autorefresh";
				}
			}, 1000);
	
			//Now, we set the splitter position.
			if(objUtilities.isNotNull(objParent.objUserPreferences.objEngineerWorkspace.intSplitterPosition)) {
				objParent.intLatestSplitterPosition = objParent.objUserPreferences.objEngineerWorkspace.intSplitterPosition;
				objParent.updatePanelsPositions(objParent.intLatestSplitterPosition);
			}

			//Now we set the latest view.
			if(objUtilities.isNotBlank(objParent.objUserPreferences.objEngineerWorkspace.strView)) {
				objParent.handledashboardclick({
					"currentTarget": {
						"name": objParent.objUserPreferences.objEngineerWorkspace.strView
					}
				});
			}

			//We set the List Views.
			objParent.optionstoSelect = objParent.objUserPreferences.mapListViews["Case"];

			//We set the selected List Views.
			objParent.selectedListViews = objParent.objUserPreferences.objEngineerWorkspace.lstListViews;

			//We set the pinned List View.
			objParent.strPinnedListView = objParent.objUserPreferences.objEngineerWorkspace.strPinnedListView;

			//Now we set the available List Views.
			objParent.setAvailableListViews();
		});

        // Register error listener  
        if(this.selectUSID == null){   
            this.selectUSID = this.sSelectedUserId;
        }
        
        if(this.sSelectedUserName != ''){
			this.showviewas = true;
            this.showToastpester('Success!' , 'View As ' + this.sSelectedUserName , 'warning'); 
        }

        let url = new URL(window.location.href);
        let params = new URLSearchParams(url.search);
        if(params.get('c__sSelectedUserId') != undefined){
            this.sSelectedUserId = params.get('c__sSelectedUserId');
        }else{
            this.sSelectedUserId = this.selectUSID;
        }

        this[NavigationMixin.GenerateUrl](this.showPanelPageReference)
            .then(url => this.showPanelUrl = url);
        if(this.sselectedUserId === null || this.sselectedUserId == null || this.sselectedUserId =='null'){
            this.sselectedUserId = this.selectUSID;
        }
        this.fetchCaseView();
        isGCSManagerPermission().then( hasPermissionSet => {
            console.log('hasPermissionSet==> ' + hasPermissionSet);
            this.isGCS_Manager = hasPermissionSet;
        }).catch( ErrorPermissionSet => {
            console.log('ErrorPermissionSet==> ' + ErrorPermissionSet);
        });

		//Now we fetch the records.
		this.strRecordId = this.sSelectedUserId;
		this.refreshTable();

		//Now we track the mouse movement, for the draggable button.
		document.onmousemove = function(objEvent) {
			if(objParent.boolActiveMouseMove) {
				let dblPercentage = (objEvent.pageX * 100) / window.innerWidth;
				
				//If the current position is too close to the left side, we switch to show only the Salt View.
				if(objEvent.pageX < 438) {
					objParent.handledashboardclick({
						"currentTarget": {
							"name": "saltview"
						}
					});
				} else if(dblPercentage >= 80) {
					objParent.handledashboardclick({
						"currentTarget": {
							"name": "queues"
						}
					});
				} else {
					objParent.intLatestSplitterPosition = objEvent.pageX;
					objParent.updatePanelsPositions(objParent.intLatestSplitterPosition);
				}
			}
		}

		//We release the mouse draggable function.
		document.onmouseup = function() {
			if(objParent.boolActiveMouseMove) {

				//We save the latest position.
				getUserPreferences().then(objResult => {
					objResult.objEngineerWorkspace.intSplitterPosition = objParent.intLatestSplitterPosition;
		
					//Now we save the new changes.
					objParent.objUserPreferences = objResult;
					setUserPreferences({
						objRecord: objParent.objUserPreferences
					});
				});

				//Now we deactivate the action.
				objParent.boolActiveMouseMove = false;
			}
		}
    }

	/*
	 Method Name : setAvailableListViews
	 Description : This method sets the available List Views.
	 Parameters	 : None
	 Return Type : None
	 */
	setAvailableListViews() {
		let boolContainsRecentViewedCases = false;
		let strPinnedListView;
		let strCurrentListView;
		let strFallbackOption;
		let objParent = this;

		//We set the data.
		objParent.options = new Array();
		objParent.optionstoSelect.forEach(objListView => {
			objParent.selectedListViews.forEach(strSelectedListView => {
				if(objListView.value === strSelectedListView) {
					objParent.options.push({
						label: objListView.label,
						value: objListView.value
					});
					if(strSelectedListView === objParent.strPinnedListView) {
						strPinnedListView = strSelectedListView;
					}
					if(objUtilities.isNotBlank(objParent.value) && objParent.value === strSelectedListView) {
						strCurrentListView = strSelectedListView;
					}
					if(objUtilities.isBlank(strFallbackOption)) {
						strFallbackOption = strSelectedListView;
					}
					if(strSelectedListView === "RecentlyViewedCases") {
						boolContainsRecentViewedCases = true;
					}
				}
			});
		});

		//Now we define the selected value.
		if(objUtilities.isNotBlank(strPinnedListView)) {
			objParent.value = strPinnedListView;
		} else if(boolContainsRecentViewedCases) {
			objParent.value = "RecentlyViewedCases";
		}else if(objUtilities.isNotBlank(strCurrentListView)) {
			objParent.value = strCurrentListView;
		} else {
			objParent.value = strFallbackOption;
		}

		//We clean up the table if nothing has been selected.
		if(objParent.options.length == 0) {
			objParent.objParameters.lstRecords = new Array();
		}

		//Now we update the Pinned List View icon.
		objParent.updatePinnedListViewIconColor();
	}

	/*
	 Method Name : updatePinnedListViewIconColor
	 Description : This method updates the color of the Pinned List View button.
	 Parameters	 : None
	 Return Type : None
	 */
	updatePinnedListViewIconColor() {
		if(this.value === this.strPinnedListView) {
			this.strPinVariant = "brand";
		} else {
			this.strPinVariant = "neutral";
		}
	}

	/*
	 Method Name : changeTimeframe
	 Description : This method updates the selected timeframe.
	 Parameters	 : Object, called from changeTimeframe, objEvent Change event.
	 Return Type : None
	 */
	changeTimeframe(objEvent) {
		let intSelection = parseInt(objEvent.currentTarget.value);
		let objParent = this;

		//We get the user selection.
		objParent.intAutorefreshCounter = intSelection;

		//Now we save the user selection, fetching first the current data.
		getUserPreferences().then(objResult => {
			objResult.objEngineerWorkspace.intAutorefreshSeconds = intSelection;

			//Now we save the new changes.
			objParent.objUserPreferences = objResult;
			setUserPreferences({
				objRecord: objParent.objUserPreferences
			});
		});
	}

	/*
	 Method Name : updatePanelsPositions
	 Description : This method updates the panels widths and spliiter.
	 Parameters	 : Integer, called from updatePanelsPositions, intX X position
	 Return Type : None
	 */
	updatePanelsPositions(intX) {
		this.template.querySelector('.splitViewCls2').style.left = (intX - 38) + "px";
		this.template.querySelector('.splitViewCls1').style.minWidth = (intX - 38) + "px";
		this.strTableDivStyle = "width: " + (intX - 65) + "px";
	}

	/*
	 Method Name : draggableButton
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : Object, called from draggableButton, objEvent On Mouse down event.
	 Return Type : None
	 */
	draggableButton(objEvent) {
		objEvent = objEvent || window.event;
		objEvent.preventDefault();
		this.boolActiveMouseMove = true;

		//We capture the initial state.
		if(objUtilities.isNull(this.intCurrentSlippterPosition)) {
			this.intCurrentSlippterPosition = objEvent.clientX;
		}
	}

    /*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
    disconnectedCallback() {

        //We remove the infinite loop that refreshes the tables.
        clearInterval(this.objInfiniteLoop);
    }
    
	/*
	 Method Name : stripHtml
	 Description : This method removes the HTML tags from a given string.
	 Parameters	 : String, called from stripHtml, strTextWithHTMLTags String with HTML tags.
	 Return Type : String
	 */
	stripHtml(strTextWithHTMLTags) {
		let strResult = strTextWithHTMLTags;
		let objTemporaryDiv;

		//We make sure we received data.
		if(objUtilities.isNotBlank(strTextWithHTMLTags)) {
			objTemporaryDiv = document.createElement("DIV");
			objTemporaryDiv.innerHTML = strTextWithHTMLTags;
			strResult = objTemporaryDiv.textContent || objTemporaryDiv.innerText || "";
		}
		return strResult;
	}

    renderedCallback(){
		let strFullCustomCSS = "";
		let objParent = this;
        var sideBarDiv = this.template.querySelectorAll('.splitViewCls1')[0];
        sideBarDiv.style.minHeight = window.innerHeight + 'px;';
        sideBarDiv.style.height = window.innerHeight + 'px;';
        
		//Now we render custom CSS to force all the tables to display max 10 rows, and always show scrollbars.
		if(!this.boolCustomCSSLoaded) {

			//We set the custom CSS.
			this.lstCustomCSS.push("lightning-datatable .dt-outer-container .slds-scrollable_x { overflow-x: scroll !important; max-height: 320px; }");
			this.lstCustomCSS.push("lightning-datatable .dt-outer-container .slds-scrollable_y { overflow-y: scroll !important; max-height: 265px; }");
			this.lstCustomCSS.push(".modalSection lightning-datatable .dt-outer-container .slds-scrollable_y { min-height: 82vh !important; }");
			this.lstCustomCSS.push(".modalSection lightning-datatable .dt-outer-container .slds-scrollable_x { min-height: 100vh !important; }");
			this.lstCustomCSS.push(".modalSection .minHeightDivTable { width: 100% !important; }");
			this.lstCustomCSS.push(".modalSection .styleContentSaltView, .modalSection .slds-modal__container > div { overflow-y: scroll !important; }");
			this.lstCustomCSS.push(".autorefreshToggle .slds-checkbox_on, .autorefreshToggle .slds-checkbox_off { display: none !important; }");
			this.lstCustomCSS.push(".splitViewCls2, .splitViewCls2.slds-button:hover, .splitViewCls2.slds-button:focus { background-color: darkgray; }");
			this.lstCustomCSS.push(".splitViewCls2 svg { fill: white; }");
			this.lstCustomCSS.push(".timeframePicklist label { display: none; }");
			this.lstCustomCSS.push(".timeframePicklist .slds-listbox { z-index: 9999999999999; }");
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				objParent.lstCustomCSS.forEach(strCustomCSS => {
					strFullCustomCSS += " c-case-prioritization-view-v5 " + strCustomCSS + " ";
				});
				objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			});
			this.boolCustomCSSLoaded = true;

			//Now we set the Legend HTML.
			getColorLegend().then(strHTMLCode => {
				objParent.strLegendHTML = strHTMLCode;
				objParent.template.querySelector('.legendHTML').innerHTML = objParent.strLegendHTML;
			});
		}
    }

	fetchCases(strCollaborateTable) {
		this.boolDisplayCollaborateSpinner = false;
		fetchCasesGroupByQueue({
			sUserId: this.strRecordId
		}).then(objResult => {
			this.processCases({
				data: objResult
			}, strCollaborateTable);
		});
	}

	processCases(provisionedValue, strCollaborateTable) {
		let objParent = this;
		let strType;
		let objModifiedType;
		let boolExisting;
		this.wireCaseData = provisionedValue;
        const { error, data } = provisionedValue;
        if (data) {
			 this.strRecordId = data.strUserId;
             var tempMap = new Map(Object.entries(data.mapGrpIdWiseRecordsData));
            
             if(tempMap.size == 0){ 
                 this.mapGrpIdWiseCasesWrapper = []; 
                 this.lstRaiseHandConsolidate = [];
                 this.mapGrpIdWiseCasesWrapper =  {};
                 this.errorMessage = 'You do not own any cases. Please take a case ownership to use this view';
                 return; 
              }
			 this.lstCollaborations = new Array();//<T04>
             let mapGrpIdWiseCasesWrapper = [];
             var lstConsolidateRH = [];
             for(let [key, value] of tempMap){
                 var qName = '' ;                 
                 for(var x=0; x < value.lstQueueRaiseHand.length;x++){
                    var showCheckbox = value.lstQueueRaiseHand[x].Type__c === 'Get Help' ? false : true;
                    lstConsolidateRH.push(
                        {
                            'hasSelected' : false,
                             'obj' : value.lstQueueRaiseHand[x],
                             showCheckbox : showCheckbox
                        }
                    );     
                 }  

                 if(value.lstQueueCase.length > 0){
                    qName = value.lstQueueCase[0].Owner.Name;
                 }

                 else if(value.lstQueueRaiseHand.length > 0){                    
                    qName = value.lstQueueRaiseHand[0].Owner.Name;
                }

                else if(value.lstCaseComments.length > 0){                    
                    qName = value.lstCaseComments[0].Owner.Name;
                }
                 if(qName != ''){
                 let tempObj = { 
                       queueName :qName ,
                       lstCase : value.lstQueueCase ,
                       lstCaseWithoutFilter : value.lstQueueCaseWithoutFilter,
                       hasCases : value.lstQueueCase.length > 0 ? true : false,
                       lstRaiseHand : value.lstQueueRaiseHand,
                       hasRaiseHand : value.lstQueueRaiseHand.length > 0 ? true : false,
                       lstCaseComments : value.lstCaseComments,
                       hasCaseComments : value.lstCaseComments.length > 0 ? true : false
                    };
                  mapGrpIdWiseCasesWrapper.push( tempObj);

                }
             }
             lstConsolidateRH.sort((a,b) => (a.obj.Name > b.obj.Name) ? 1 : ((b.obj.Name > a.obj.Name) ? -1 : 0));
             this.lstRaiseHandConsolidate = lstConsolidateRH;
             this.mapGrpIdWiseCasesWrapper = JSON.parse(JSON.stringify(mapGrpIdWiseCasesWrapper));
            this.error = undefined;
        
			//Now we create the Collaboration tables.
			if(objUtilities.isBlank(strCollaborateTable)) {
				objParent.activeSections = new Array();
				objParent.activeSections = ["A", "C"];
				objParent.lstCollaborations = new Array();
			} else {

				//We delete only the specified table, to reload it.
				objParent.lstCollaborations.forEach(objTable => {
					objTable.lstRecords = new Array();
	
					//If we already have a type, we add the record.
					if(strCollaborateTable === objTable.strType) {
						objTable.boolDisplaySpinner = true;
					}
				});
			}
			
			this.lstRaiseHandConsolidate.forEach(objType => {
				if(typeof objType !== "undefined" && objType !== null && typeof objType.obj !== "undefined" && objType.obj !== null && typeof objType.obj.Type__c !== "undefined" && 
						objType.obj.Type__c !== null) {
					boolExisting = false;
					objModifiedType = {... objType};
					objModifiedType.obj.CaseNumber = objModifiedType.obj.Case__r.CaseNumber;
					objModifiedType.obj.CaseURL = '/lightning/r/Case/' + objModifiedType.obj.Case__c + '/view';
					objModifiedType.obj.RecordName = objModifiedType.obj.Name;
					objModifiedType.obj.RecordURL = '/lightning/r/Raise_Hand__c/' + objModifiedType.obj.Id + '/view';
					objModifiedType.obj.Priority = objModifiedType.obj.Case__r.Priority;
					objModifiedType.obj.Component = objModifiedType.obj.Case__r.Component__c;
					objModifiedType.obj.Case_Timezone_Name__c = objModifiedType.obj.Case__r.Case_Timezone_Name__c;
					objModifiedType.obj.Case_Owner_Team__c = objModifiedType.obj.Case__r.Case_Owner_Team__c;
					objModifiedType.obj.Owner_Name__c = objModifiedType.obj.Case__r.Owner_Name__c;
					objModifiedType.obj.CasePriority = objModifiedType.obj.Case_Priority__c;
					objModifiedType.obj.Product = objModifiedType.obj.Product__c;
					objModifiedType.obj.CollaboratorTeam = objModifiedType.obj.Collaborator_Team__c;
					objModifiedType.obj.CaseOwner = objModifiedType.obj.Case_Owner__c;
					objModifiedType.obj.CaseComponent = objModifiedType.obj.Case_Component__c;
					if(objUtilities.isNotNull(objModifiedType.obj) && objUtilities.isNotNull(objModifiedType.obj.Case__r) && 
							objUtilities.isNotBlank(objModifiedType.obj.Case__r.Case_Timezone__c)) {
						objModifiedType.obj.CaseTimezone = objModifiedType.obj.Case__r.Case_Timezone__r.Name;
						objModifiedType.obj.CaseTimezoneURL = '/lightning/r/Case_Timezone__c/' + objModifiedType.obj.Case__r.Case_Timezone__c + '/view';
					}
					objModifiedType.obj.CaseRecordType = objModifiedType.obj.Case__r.Record_Type_Name__c;
					objModifiedType.obj.CreatedDate = objModifiedType.obj.CreatedDate;
					objModifiedType.obj.Title = objModifiedType.obj.Title__c;
					if(objModifiedType.obj.Case__r.Support_Account__r) {
						objModifiedType.obj.SupportAccount = objModifiedType.obj.Case__r.Support_Account__r.Name;
					}
					//T05 set the value for the fields Case Owner Manager and Team.
					objModifiedType.obj.CaseOwnerManager = objModifiedType.obj.Case_Owner_Manager__c;
					objModifiedType.obj.CaseOwnerTeam = objModifiedType.obj.Case__r.Case_Owner_Team__c;
					strType = objModifiedType.obj.Type__c;

					//Now we check if the current type is "CoOwn", and if so, we split the subtypes as new tables.
					if(strType.toLowerCase() === "co-own") {
						strType = strType + " - " + objModifiedType.obj.Subtype__c;
					}

					//Now we insert the record.
					objParent.lstCollaborations.forEach(objTable => {
	
						//If we already have a type, we add the record.
						if(strType === objTable.strType) {
							objTable.lstRecords.push(objModifiedType.obj);
							boolExisting = true;
						}
					});
					if(!boolExisting) {
						objParent.lstCollaborations.push({
							strType: strType,
							strLabel: "Collaborate - " + strType,
							lstRecords: [objModifiedType.obj],
							isgethelp: objModifiedType.obj.Type__c == 'Get Help' ? true: false,
							keyField: objModifiedType.obj.Type__c == 'Get Help' ? "Name" : "Id",
							objTableConfiguration: {
								strSortBy: 'Name',
								strSortDirection: 'asc' 
							},
							objModalProperties: objUtilities.getPopOutCSSClosed()
						});
					}
				}
			});
			setTimeout(function() {

				//Now we hide specific spinners.
				if(objUtilities.isBlank(strCollaborateTable)) {
					objParent.activeSections = new Array();
					objParent.activeSections = ["A", "C"];
					objParent.lstCollaborations.forEach(objType => {
						objParent.activeSections.push(objType.strType);

						//We run the initial sorting.
						objParent.initialSort(objType.strType);
					});
					objParent.boolDisplayCollaborateSpinner = false;
				} else {
	
					//We delete only the specified table, to reload it.
					objParent.lstCollaborations.forEach(objTable => {
		
						//If we already have a type, we add the record.
						if(strCollaborateTable === objTable.strType) {
							objTable.boolDisplaySpinner = false;
						}
					});
				}
			}, 1000);
        } else if (error) {
            this.error = error;
            this.contacts = [];
			objParent.boolDisplayCollaborateSpinner = false;
        }
	}

    @wire(getURLFromMetadata, { strFilter: "Engineer" })
    metadataRecordForDB({ error, data }) {
        if (data) {
            this.metadataRecordURL = data;
        }
    }
    
    @wire(getListUi, {
		objectApiName: Case_OBJECT,
		listViewApiName: '$ListViewValue',
        optionalFields : ['Case_Weightage_Calc__c','Contact.Name','Forecast_Product__c'],
        pageSize: 2000

	}) listView(provisionedValue) {
        const { error, data } = provisionedValue;   
        this.wireCaseListView = provisionedValue;

		if (data) {

			let caseData = data.records.records;
			if (caseData.length > 0) {
				this.noRecords = true;
			} else {
				this.noRecords = false;
                this.records = [];
                return;
			}
            
            let lstCaseDataTemp = JSON.parse(JSON.stringify( caseData));
            for(var x = 0; x < lstCaseDataTemp.length ; x++){
                lstCaseDataTemp[x].hasSelected = false;
            }
            lstCaseDataTemp.sort(function(a, b){
                var x = a.fields.Case_Weightage_Calc__c.value != null ? a.fields.Case_Weightage_Calc__c.value.toLowerCase() : '';
                var y = b.fields.Case_Weightage_Calc__c.value != null ? b.fields.Case_Weightage_Calc__c.value.toLowerCase() : '';
                if (x < y) {return -1;}
                if (x > y) {return 1;}
                return 0;
              });
            this.records = lstCaseDataTemp;
			this.error = undefined;

		} else if (error) {
			this.error = error;
            this.records = [];
            console.log('error==> ' + JSON.stringify(error));
		}
	}
    handleMenuSelect(event){
        this.showModal = true;
    }
    handleClick(event){
		let objParent = this;
        if(event.currentTarget.name == 'save'){
            objParent.selectedListViews = objParent.template.querySelector('lightning-dual-listbox').value;

			//Now we make sure we have unique values for the dual-box.
			objParent.forceUniqueValues();

			//Now we save the user selection, fetching first the current data.
			getUserPreferences().then(objResult => {
	
				//Now we update the sorting.
				objResult.objEngineerWorkspace.lstListViews = objParent.selectedListViews;
	
				//Now we save the new changes.
				objParent.objUserPreferences = objResult;
				setUserPreferences({
					objRecord: objParent.objUserPreferences
				});
			});

			//Now we set the available List Views.
			objParent.setAvailableListViews();
        }
        this.showModal = false;
    }
    pintheview(){
		let objParent = this;

		//First we set the value.
		if(this.strPinnedListView === this.value) {
			this.strPinnedListView = "";
		} else {
			this.strPinnedListView = this.value;
		}

		//We update the color.
		objParent.updatePinnedListViewIconColor();

		//Now we save the selection.
		getUserPreferences().then(objResult => {

			//Now we update the sorting.
			objResult.objEngineerWorkspace.strPinnedListView = objParent.strPinnedListView;

			//Now we save the new changes.
			objParent.objUserPreferences = objResult;
			setUserPreferences({
				objRecord: objParent.objUserPreferences
			});
		});
    }
    handleChange(event) {
		let value = event.target.value;
		this.value = value;
		console.log('handleChange.. this.value >> ', this.value);

		//We update the color.
		this.updatePinnedListViewIconColor();
    }
    handleChangeToSavePreferences(event){
        let valueCheckbox = this.template.querySelector('lightning-dual-listbox').value;
    } 
    toggleUserLookup(){
      this.bShowLookup = !this.bShowLookup;
      this.headerToggleIcon = this.headerToggleIcon == 'action:new' ? 'action:remove' : 'action:new';
    }

    handelLookupRecordUpdate(event){
        if(event.detail.selectedRecord != undefined){
            this.selectedUser = event.detail.selectedRecord;
            this.sSelectedUserId = this.selectedUser.Id;
			this.strRecordId = this.sSelectedUserId;
			this.sSelectedUserName = this.selectedUser;
            this.refreshTable();
            this.fetchCaseView();
        }else{
            this.selectedUser = {};
			this.showviewas = false;
			this.sSelectedUserName = ' ';
            this.sSelectedUserId = this.userId;
			this.refreshTable();//<T04>
            this.fetchCaseView();

        }
    }

    updateUserRating(event){
        var rating = event.target.title;  
        SelectRating = true;              
        if(rating == 'Vote Down'){
            customerRating = 'Down';
               this.voteDownRating = ratingCss + 'margin-left: 80px;border:thick solid black'; 
               this.voteUpRating =ratingCss + 'margin-left: 100px';
            }
            else if(rating == 'Vote Up'){
                customerRating = 'Up';
                this.voteDownRating = ratingCss + 'margin-left: 80px';
                this.voteUpRating = ratingCss + 'margin-left: 100px;border:thick solid black'; 
            }
       
    }

    getComments(event){
        this.comment = event.target.value;
    }

    saveReview(){
        if(SelectRating == false){
             alert('Please choose a rating');
             return;
        }
        if(this.comment == '' ){
            alert('Please enter comments');
            return;
        }
		this.bDisableSaveReviewBtn = true;//T06
    	this.insertWR();
    }
    
    insertWR(){
        insertWeightageRating({
            sComment : this.comment,
            cw : this.ratingCaseObj.Case_Weightage__c == undefined ? null : this.ratingCaseObj.Case_Weightage__c,
            rating : customerRating,
            weightage : this.ratingCaseObj.Case_Weightage__c == undefined ? null : this.ratingCaseObj.Case_Weightage__r.Weightage__c,
            ocase : this.ratingCaseObj.cs != undefined ? this.ratingCaseObj.cs.Id : null
        }).then( result => {
            this.cancelReview();
            console.log('result==> ' + JSON.stringify(result));
            this.showToast('Success!' , 'Thank you for submitting feedback.' , 'success');
            //location.reload();
        }).catch( error => {
            console.log('error==> ' + JSON.stringify(error));
        });
        
    }


    overlayOn(event) {
        this.bRatingOverlay = true;
		//T06
		this.bDisableSaveReviewBtn = false;
		this.comment = '';
		SelectRating = false;
        
		var caseId = event.target.getAttribute('data-caseid');
        this.ratingCaseObj = this.oWrapperData.caseWrapper.find(data => data.cs.Id === caseId);
    }

    openPreviewModal(event) {
        this.bShowCasePreview = true;
        var caseId = event.target.getAttribute('data-caseid');
        this.currentPreviewId = caseId;
        this.currentPreviewCase = this.oWrapperData.caseWrapper.find(data => data.cs.Id === caseId);
        
        this.buildTimeLineHelper(caseId);

        for(var i = 0; i < this.oWrapperData.caseWrapper.length; i++){
            var cw = this.oWrapperData.caseWrapper;
           if(cw[i].cs.Id == caseId){
               if(i == 0){
                  this.bDisablePreviousCaseBtn = true; 
               }else{
                  this.bDisablePreviousCaseBtn = false; 
               }
               
               if(i == (this.oWrapperData.caseWrapper.length - 1)){
                this.bDisableNextCaseBtn = true; 
                
               }else{
                this.bDisableNextCaseBtn = false; 
               }
               break;
           }
       }
    }


    buildTimeLineHelper(caseId){
        
        buildTimeLine({
            'caseId' :caseId,
            'blflag' : 'true'
           
        }).then( result => {
            console.log('buildTimeLine result==> ' + JSON.stringify(result));    
           
            var lstResult = JSON.parse(JSON.stringify(result));

            for(var i =0; i < lstResult.data1.length;i++){
                var tl = lstResult.data1[i];
              if(tl.feed != undefined){
               
                if(tl.type == 'Feed Activity'){
                    
                    if(tl.feed.Body != undefined && tl.feed.Body != ''){
                    
                        console.log('decodeURIComponent(encodeURIComponent(tl.feed.Body)) -- > ' + decodeURIComponent(encodeURIComponent(tl.feed.Body)));
                        tl.feed.Body = decodeURIComponent(encodeURIComponent(tl.feed.Body));
                    }
                }                     
            }
            }

            this.lstCaseTimeLine = lstResult;

        }).catch( error => {
            console.log('error==> ' + JSON.stringify(error));
        });
    }

    openSinglePreviewRHModal(event){
        this.bShowSingleRhPreview = true;  
        var rhId = event.target.getAttribute('data-rhid');
        this.currentPreviewRHId = rhId;   

    }

    openSinglePreviewModal(event){
        this.bShowSingleCasePreview = true;
        var caseId = event.target.getAttribute('data-caseid');
        this.buildTimeLineHelper(caseId);
        this.currentPreviewId = caseId;
        var grpWiseCaseWrapper = this.mapGrpIdWiseCasesWrapper; 
        var bRecordFind = false;
        for(var i=0; i < grpWiseCaseWrapper.length; i++){
            if(bRecordFind){break;}
            if(grpWiseCaseWrapper[i].lstCase != undefined){
                if(grpWiseCaseWrapper[i].lstCase.length > 0){
                    for(var x = 0; x < grpWiseCaseWrapper[i].lstCase.length ; x++){
                        if(grpWiseCaseWrapper[i].lstCase[x].Id == caseId){
                            this.currentPreviewCase =  grpWiseCaseWrapper[i].lstCase[x];
                            bRecordFind = true;
                            break;
                        }     
                    }
                }                
            }
            
        }
    }

    showNextCase(){
        this.isCaseLoading = true;
        let currentCaseId = this.currentPreviewId; 
        this.bDisablePreviousCaseBtn = false;
        for(var i = 0; i < this.oWrapperData.caseWrapper.length; i++){
             var cw = this.oWrapperData.caseWrapper;
            if(cw[i].cs.Id == currentCaseId){
                if(i == (this.oWrapperData.caseWrapper.length-2)){
                    this.bDisableNextCaseBtn = true; 
                   }else{
                    this.bDisableNextCaseBtn = false; 
                }
              this.currentPreviewCase = cw[i + 1];
              var self = this;
              setTimeout(function(){ 
                 self.currentPreviewId = cw[i + 1].cs.Id; 
                 self.buildTimeLineHelper(self.currentPreviewId); 
                 self.isCaseLoading = false;
             }, 500);
                break;
            }
           
        }
            
    }

    showPreviousCase(){
        this.isCaseLoading = true;
        this.bDisableNextCaseBtn = false; 
        let currentCaseId = this.currentPreviewId; 
        for(var i = 0; i < this.oWrapperData.caseWrapper.length; i++){
             var cw = this.oWrapperData.caseWrapper;
            if(cw[i].cs.Id == currentCaseId){
                if(i == 1){
                    this.bDisablePreviousCaseBtn = true; 
                   }else{
                    this.bDisablePreviousCaseBtn = false; 
                }
              this.currentPreviewCase = cw[i - 1];

              var self = this;
              setTimeout(function(){ 
                self.currentPreviewId = cw[i - 1].cs.Id;
                self.buildTimeLineHelper(cw[i - 1].cs.Id);
                 self.isCaseLoading = false;
             }, 500);
                break;
            }
        }       
    }

    

    cancelPreview(){
        this.bShowCasePreview = false; 
        this.bShowSingleCasePreview = false;
        this.bShowSingleRhPreview = false;
          
    }
    cancelReview(){
        this.bRatingOverlay = false;
        this.voteDownRating = ratingCss + 'margin-left: 80px';
        this.voteUpRating =ratingCss + 'margin-left: 100px';
        this.ratingCaseObj = {};
    }

    showFAQ(){
        this.bFAQoverlay = true;
    }

    closeFAQoverlay(){
        this.bFAQoverlay = false;
    }

    toggleCaseEngagedNotification(){

        const findsplitViewCls3 = this.template.querySelector('.splitViewCls3');
        const findsplitViewCls4 = this.template.querySelector('.splitViewCls4');

        this.bShowCaseEngagedNotification = !this.bShowCaseEngagedNotification;
        if(this.bShowCaseEngagedNotification){
              this.caseNotificationEngagedToggleIcon = 'utility:right';
              findsplitViewCls3.classList.add('slds-is-open');
              findsplitViewCls3.classList.add('min-Width-r-Style');
              findsplitViewCls3.classList.remove('slds-is-closed');            

              findsplitViewCls4.classList.add('slds-is-open');
              findsplitViewCls4.classList.remove('min-Width-r-Style');
              findsplitViewCls4.classList.remove('slds-is-closed');

        }else{
           // this.caseNotificationViewSize = 0;
           // this.saltViewSize = 9;
           this.caseNotificationEngagedToggleIcon = 'utility:left';
           findsplitViewCls3.classList.remove('slds-is-open');
           findsplitViewCls3.classList.remove('min-Width-r-Style');
           findsplitViewCls3.classList.add('slds-is-closed');

           findsplitViewCls4.classList.remove('slds-is-open');
           findsplitViewCls4.classList.remove('min-Width-r-Style');
           findsplitViewCls4.classList.add('slds-is-closed');
        }


    }


   

    fetchCaseView(){
		let objParent = this;
        Caseview({sUserId : this.sSelectedUserId}).then(result => {
            let oWrapperData =  JSON.parse(JSON.stringify(result));

            let caseTeamListWrapper = [];


            for(var i =0; i < oWrapperData.egList.length; i++){
                oWrapperData.egList[i].idx = i;
                oWrapperData.egList[i].egStyle1 = 'background-color:' +  oWrapperData.egList[i].CurrentColor + '; width:' +  oWrapperData.egList[i].width + '%;height: 100%;display: block';
                oWrapperData.egList[i].egStyle2 = 'background-image: linear-gradient(-90deg, ' + oWrapperData.egList[i].NextColor + ',' + oWrapperData.egList[i].CurrentColor + ');width:' + oWrapperData.bandChangeWidth + '%; height: 100%;display: block;';
            }


            for(var i =0; i < oWrapperData.caseWrapper.length; i++){
				console.log('***oWrapperData.caseWrapper[i].lastGradientColor===> ' + oWrapperData.caseWrapper[i].cs.Next_Action__c); 
                console.log('***oWrapperData.caseWrapper[i].lastGradientColor===> ' + oWrapperData.caseWrapper[i].lastGradientColor); 
                oWrapperData.caseWrapper[i].technicalBlockStyle = 'display:block; margin-top: 15px; width: 19%;margin-left: 5px;margin-right: 5px; background-color: transparent; border: 0px;box-shadow:;'
                oWrapperData.caseWrapper[i].technicalCWStyle1 =  'background-color:' +  oWrapperData.caseWrapper[i].lastGradientColor + ';width:' +  oWrapperData.caseWrapper[i].lastGradientWidth + '%; height: 100%;display: block;'; 
				
				console.log('***oWrapperData.caseWrapper[i].technicalCWStyle1===> ' + oWrapperData.caseWrapper[i].technicalCWStyle1);               
             
				// <T02>
                console.log('oWrapperData.caseWrapper[i].Is_Internal_Or_External_Case__c===> ' + oWrapperData.caseWrapper[i].cs.Is_Internal_Or_External_Case__c != 'Internal' );
                //oWrapperData.caseWrapper[i].technicalCWMileStoneTrueStyle = 'display:' +  (oWrapperData.caseWrapper[i].activeMilestone ? "contents":"none") + '; padding: 0px';
				oWrapperData.caseWrapper[i].technicalCWMileStoneTrueStyle = 'display:' +  ( (oWrapperData.caseWrapper[i].activeMilestone && oWrapperData.caseWrapper[i].RType != 'Ask An Expert' && oWrapperData.caseWrapper[i].cs.Is_Internal_Or_External_Case__c != 'Internal' )  ? "contents":"none") + '; padding: 0px';
				// </T02>
                if(oWrapperData.caseWrapper[i].activeMilestone == false){
                    oWrapperData.caseWrapper[i].isTechnicalCWMileStoneTrueStyleNone = true;
                }
				
                oWrapperData.caseWrapper[i].technicalCWmilestoneViolatedTrueStyle =  'display:' +  (oWrapperData.caseWrapper[i].milestoneViolated ? "none":"block") + '; padding: 0px;font-weight:bold';

                oWrapperData.caseWrapper[i].technicalCWMileStoneFalseStyle = 'display:'  + (oWrapperData.caseWrapper[i].activeMilestone ? "contents":"contents") + '; padding: 0px';
                oWrapperData.caseWrapper[i].technicalCWmilestoneViolatedFalseStyle =  'display:' +  (oWrapperData.caseWrapper[i].milestoneViolated ? "block":"none") + '; padding: 0px;font-weight:bold';
                oWrapperData.caseWrapper[i].MilestoneTimeRemainingTitle = 'Milestone Time Remaining:' + oWrapperData.caseWrapper[i].timeRemaining;
                var tempAlertColor = oWrapperData.caseWrapper[i].alertcolor == true ? "red": "black";
                oWrapperData.caseWrapper[i].technicalAlertColorStyle  = 'padding: 0px; font-family: initial; padding: 0px; color:' + tempAlertColor;
                console.log('Watch here ====> ' + oWrapperData.caseWrapper[i].technicalAlertColorStyle);
                oWrapperData.caseWrapper[i].technicalLastActivityDateTimeTitle  = 'Last activity on this case was ' +  oWrapperData.caseWrapper[i].LastActivityDateTime;
                oWrapperData.caseWrapper[i].technicalNextActionTitle = 'Next Action: ' +  oWrapperData.caseWrapper[i].cs.Next_Action__c;

                oWrapperData.caseWrapper[i].techincalNextActionForCaseOwnerStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Case Owner' ? "block" : "none");
                oWrapperData.caseWrapper[i].techincalNextActionForCustomerStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Customer' ?"block":"none");
                oWrapperData.caseWrapper[i].techincalNextActionForINFARDStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'INFA R&D' ?"block":"none" );
                oWrapperData.caseWrapper[i].techincalNextActionForCaseTeamStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Case Team' ?"block":"none");
                oWrapperData.caseWrapper[i].techincalNextActionForConsultantStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Consultant' ?"none":"none");
                oWrapperData.caseWrapper[i].techincalNextActionForReviewerStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Reviewer' ?"none":"none");
                oWrapperData.caseWrapper[i].techincalNextActionForCaseOwnerThirdPartyStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Third Party' ? "none":"none");

				oWrapperData.caseWrapper[i].techincalNextActionForCREStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Operations Team' ? "block":"none");
				oWrapperData.caseWrapper[i].techincalNextActionForPSStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'PS Team' ? "block":"none");
				oWrapperData.caseWrapper[i].techincalNextActionForMPStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Multi Team' ? "block":"none");
				oWrapperData.caseWrapper[i].techincalNextActionForCOStyle =  'display : ' + (oWrapperData.caseWrapper[i].NextAction == 'Collaborator' ? "block":"none");
				console.log('Here oWrapperData.caseWrapper[i].TargetCloseDate===> ' + oWrapperData.caseWrapper[i].techincalNextActionForINFARDStyle);

                oWrapperData.caseWrapper[i].techincalisInactiveStyle =  'display :' +  (oWrapperData.caseWrapper[i].isInactive ? "inline-block": "none");
                // 24 may 2021
                console.log('oWrapperData.caseWrapper[i].TargetCloseDate===> ' + oWrapperData.caseWrapper[i].TargetCloseDate);
                oWrapperData.caseWrapper[i].TargetCloseDateStyle =  'display : ' + (oWrapperData.caseWrapper[i].TargetCloseDate == '' ? "none":"block");
                

              if(oWrapperData.caseWrapper[i].RType == 'Technical'){
                oWrapperData.caseWrapper[i].isTechnicalCase = true;
              }
              if(oWrapperData.caseWrapper[i].RType == 'Administrative'){
                oWrapperData.caseWrapper[i].isAdministrativeCase = true;
              }

              if(oWrapperData.caseWrapper[i].RType == 'Operations'){
                oWrapperData.caseWrapper[i].isOperationsCase = true;
              }

              if(oWrapperData.caseWrapper[i].RType == 'Shipping Request'){
                oWrapperData.caseWrapper[i].isShipping_RequestCase = true;
              }

			  if(oWrapperData.caseWrapper[i].RType == 'Ask An Expert'){
                oWrapperData.caseWrapper[i].isaae = true;
              }

              

                for(var x = 0 ; x < oWrapperData.caseWrapper[i].egList.length; x++){
                    let egObj = oWrapperData.caseWrapper[i].egList[x];
                    egObj.egIdx = x;
                    egObj.csEgStyle1 = 'background-color:' +  egObj.CurrentColor +'; width:' +  egObj.width + '%;height: 100%; display: block';
                    egObj.csEgStyle2 = 'background-image: linear-gradient(-90deg,' + egObj.NextColor + ',' + egObj.CurrentColor + ');width:' +  oWrapperData.caseWrapper[i].bandChangeWidth  + '%; height: 100%;display: block';
                }                
            }
            



            oWrapperData.wrapperStyle1 = 'background-color:' +  oWrapperData.lastGradientColor + ';width:' + oWrapperData.lastGradientWidth + '%;height: 30px;display: block';
            oWrapperData.hasCasesStyle = 'display: ' + (oWrapperData.hasCases == true ? "flex" : "none")  + ';flex-wrap: wrap; margin-top: -10px;margin-left: 10px';
            console.log('oWrapperData==> ' + JSON.stringify(oWrapperData));
           
           this.oWrapperData = oWrapperData;




           var mapGroupedData = oWrapperData.caseWrapper.reduce(function (r, a) {
            r[a.caseTeamMemberRole] = r[a.caseTeamMemberRole] || [];
            r[a.caseTeamMemberRole].push(a);
            return r;
        }, Object.create(null));
        
        console.log('#### mapGroupedData===>' + JSON.stringify(mapGroupedData));

        delete mapGroupedData[''];
        var tempActiveSectionCaseTeam = [];
        for (var key in mapGroupedData) {
               caseTeamListWrapper.push({'sRole' : key , 'groupedTeamCaseList' : mapGroupedData[key]});
               tempActiveSectionCaseTeam.push(key);             
        }
        this.activeSectionCaseTeam = tempActiveSectionCaseTeam;
        console.log( '====> �� ' + JSON.stringify(caseTeamListWrapper));
        
        this.caseTeamListWrapper = caseTeamListWrapper;

        

		this.boolDisplaySaltViewSpinner = false;

		//Now we display the correct salt view message, depending on the owned cases.
		let intOwnedCases = 0;
		let intCaseTeamCases = 0;
		if(objUtilities.isNotNull(objParent.caseTeamListWrapper)) {
			intCaseTeamCases = objParent.caseTeamListWrapper.length;
		}
		if(objUtilities.isNotNull(objParent.oWrapperData) && objUtilities.isNotNull(objParent.oWrapperData.caseWrapper)) {
			intOwnedCases = objParent.oWrapperData.caseWrapper.length;
		}
		if(intOwnedCases === 0 && intCaseTeamCases === 0) {
			objParent.errorMessage = 'You do not own any cases. Please take a case ownership to use this view';
		} else {
			objParent.errorMessage = '';
			objParent.boolDisplaySaltViewWarningMessage = false;
		}
        }).catch( error => {
            this.boolDisplaySaltViewSpinner = false;
        });
    }

    onCaseSelection(event){
     var recId = event.target.value;
     var hasChecked = event.target.checked;
     var caseRecords = JSON.parse(JSON.stringify(this.records));
     for(var i = 0; i < caseRecords.length; i++){
            if(caseRecords[i].id == recId ){
                caseRecords[i].hasSelected = hasChecked;   
                break;
            }        
     }

     this.records = caseRecords;
    }

    onRHSelection(event){
		let objParent = this;
		if(typeof event !== "undefined" && event !== null && typeof event.detail !== "undefined" && event.detail !== null) {
            for(var i = 0; i < objParent.lstRaiseHandConsolidate.length; i++) {
				objParent.lstRaiseHandConsolidate[i].hasSelected = false;
				if(typeof event.detail.selectedRows !== "undefined" && event.detail.selectedRows !== null) {
					event.detail.selectedRows.forEach(objRow => {
						if(objParent.lstRaiseHandConsolidate[i].obj.Id === objRow.Id){
							objParent.lstRaiseHandConsolidate[i].hasSelected = true;
							console.log('selected in it');
						}
					});
				}
			}
		}
       }

executeAction(event){
    this.selectedCases = this.template.querySelector("c-global-data-table").getSelectedRecords();
}

//T01
get disableIamOnItButton(){
	//console.log('disableIamOnItButton, selectedCaseListViewLabel >>', this.selectedCaseListViewLabel);
	return this.selectedCaseListViewLabel && this.selectedCaseListViewLabel != 'Weekend/Holiday Support';
}

//T01
iamOnIt(event){
	//console.log('this.selectedCases >> ', JSON.stringify(this.selectedCases));
	this.showConfirmation = true;
	this.confirmationFor = 'userOnIt';
	this.confirmationModalTitle = 'Accept Proxy';
    if (this.selectedCases.length > 0) {
		this.confirmationModalContent = 'You will be marked as Proxy Engineer on the selected Case(s). Do you want to continue?';
		this.showConfirmationContinue = true;
	}else{
		this.confirmationModalContent = 'Please select atleast one of the Cases!';
		this.showConfirmationContinue = false;
	}
}

//T01
iamOffIt(event){
	this.showConfirmation = true;
	this.confirmationFor = 'userOffIt';
	this.confirmationModalTitle = 'Remove Proxy';
    if (this.selectedCases.length > 0) {
		this.confirmationModalContent = 'Proxy Engineer will be removed from the selected Case(s). Do you want to continue?';
		this.showConfirmationContinue = true;
	}else{
		this.confirmationModalContent = 'Please select atleast one of the Cases!';
		this.showConfirmationContinue = false;
	}
}

//T01
cancelConfirmation(event){
	this.showConfirmation = false;
}

//T01
continueConfirmation(event){
	let lstCaseIdToUpdate = [];
	this.selectedCases.forEach(element => {
		lstCaseIdToUpdate.push(element.Id);
	});
	
	this.showConfirmation = false;
	if(this.confirmationFor == 'userOnIt'){
		this.boolDisplayCaseSpinner = true; 
        userOnIt({
			lstCaseId: lstCaseIdToUpdate,
			sUserId : this.sSelectedUserId 
		}).then(result => {
			this.showToast('Success!' , 'You are now the Proxy Engineer on the seleted Cases!' , 'success');
            this.loadCaseRecords();
        }).catch(error => {
            console.log('error==> ' + error);
        });
	}else if(this.confirmationFor == 'userOffIt'){
		this.boolDisplayCaseSpinner = true; 
		userOffIt({
			lstCaseId: lstCaseIdToUpdate,
			sUserId : this.sSelectedUserId 
		}).then(result => {
			this.showToast('Success!' , 'The Proxy Engineer is now off the seleted Cases!' , 'success');
			this.loadCaseRecords();
		}).catch(error => {
			console.log('error==> ' + error);
		});
	}
}

acceptCase(event){   
	this.boolDisplayCaseSpinner = true; 
    var caseRecords = JSON.parse(JSON.stringify(this.records));
    if (caseRecords.length > 0) {
        let firstCaseId = caseRecords[0].Id;
        let caseIdToUpdate = [];
        for(let x=0;x<this.selectedCases.length;x++){
            caseIdToUpdate.push(this.selectedCases[x].Id);
        }
       const lstFinalCaseId = caseIdToUpdate.length > 0 ? caseIdToUpdate : [firstCaseId];
        updateCaseOwner({ lstCaseId: lstFinalCaseId ,sUserId : this.sSelectedUserId }).then(result => {
			this.showToast('Success!' , 'You have accepted the Case(s) from the queue and are now its owner.' , 'success');
            this.loadCaseRecords();
        }).catch(error => {
            console.log('error==> ' + error);
        });
    }
}

    acceptRaiseHandCase(event){
		let objParent = this;
        let firstCaseId;       
        let firstRGId;
        var lstRaiseHandConsolidate = this.lstRaiseHandConsolidate;

		//First we display the spinner.
		objParent.lstCollaborations.forEach(objTable => {
			if(objTable.strType === event.currentTarget.dataset.table) {
				objTable.boolDisplaySpinner = true;
			}
		});

		//Now we continue the process.
        if (lstRaiseHandConsolidate.length > 0) {
            firstCaseId = lstRaiseHandConsolidate[0].obj.Case__c;
            firstRGId = lstRaiseHandConsolidate[0].obj.Id;
            
            let caseIdToUpdate = [];
            let RHIdToUpdate = [];
            for(let i=0; i < lstRaiseHandConsolidate.length;i++){
              if(lstRaiseHandConsolidate[i].hasSelected){
                RHIdToUpdate.push(lstRaiseHandConsolidate[i].obj.Id);
                caseIdToUpdate.push(lstRaiseHandConsolidate[i].obj.Case__c);
              }
        }
           const lstFinalCaseId = caseIdToUpdate.length > 0 ? caseIdToUpdate : [firstCaseId];
           const lstFinalRHId = RHIdToUpdate.length > 0 ? RHIdToUpdate : [firstRGId];
           acceptRaiseHand({ lstCaseId: lstFinalCaseId ,lstRHId: lstFinalRHId , sUserId : this.sSelectedUserId }).then(result => {
				objParent.strRecordId = this.sSelectedUserId;
                objParent.fetchCases();
                this.fetchCaseView();
                if(lstFinalCaseId.length == 1){
                    this.openRecordPage(lstFinalRHId[0]);
                }else{
                    this.showToast('Success!' , 'You have accepted the Collaboration Request(s). Please traverse to the request(s) to view the details.' , 'success');
                }
				this.loadCaseRecords();
            }).catch(error => {
				objParent.boolDisplayCaseSpinner = false;
                var stError=JSON.stringify( error);
                if(stError.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    this.showToast('Error!' , 'This request has been accepted by another user.' , 'Error');
               
                }
                console.log('error==> ' , error);
            });
        }
       
        
    }

    openPrimaryRecordTab(event){
     var navRecordId = event.target.getAttribute('data-navid');
     this.openRecordPage(navRecordId);
    }

    openRecordPage(navRecordId){
     this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: navRecordId,
            actionName: 'view'
        }
    }).then(url => {     
     this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
     
        if (isConsole) {
          
            this.invokeWorkspaceAPI('openTab', {
              id : null,
              url: url,
              focus: true
            }).then(tabId => {
              console.log("Solution #2 - SubTab ID: ", tabId);
            });
          
        }else{
            window.open(url) 
        }
      });

    
    });    
  
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


    showToast(sTitle, sMsg, sVariant) {
        const event = new ShowToastEvent({
            title: sTitle,
            message: sMsg,
            variant : sVariant
        });
        this.dispatchEvent(event);
    }

	showToastpester(sTitle, sMsg, sVariant) {
        const event = new ShowToastEvent({
			mode: 'sticky',
            title: sTitle,
            message: sMsg,
            variant : sVariant,
			
        });
        this.dispatchEvent(event);
    }

	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Object, called from popOut, objEvent Event.
	 Return Type : None
	 */
	popOut(objEvent) {
		switch(objEvent.currentTarget.dataset.component) {
			case "Attention":
				this.boolIsAttentionRequestPoppedOut = !this.boolIsAttentionRequestPoppedOut;
			break;
			case "Cases":
				this.boolIsCasePoppedOut = !this.boolIsCasePoppedOut;
			break;
			case "Salt":
				this.boolIsSaltViewPoppedOut = !this.boolIsSaltViewPoppedOut;
			break;
			case "Collaboration":
				this.lstCollaborations.forEach(objCollaborations => {
					if(objEvent.currentTarget.dataset.type === objCollaborations.strType) {
						objCollaborations.boolIsPoppedOut = !objCollaborations.boolIsPoppedOut;
						if(objCollaborations.boolIsPoppedOut) {
							objCollaborations.objModalProperties = objUtilities.getPopOutCSSOpen();
						} else {
							objCollaborations.objModalProperties = objUtilities.getPopOutCSSClosed();
						}
					}
				});
			break;
			case "Legend":

				//First we hide the pop over.
				this.displayLegend();

				//Now we open a new window.
				window.open("/apex/EngineerWorkspaceLegendPopUp", "Legend", "width=520,height=300");
			break;
		}
    }

	/*
	 Method Name : displayLegend
	 Description : This method displays the color legend.
	 Parameters	 : None
	 Return Type : None
	 */
	displayLegend() {
		let objParent = this;

		//We update the visibility.
		this.boolDisplayLegend = !this.boolDisplayLegend;
		if(this.boolDisplayLegend) {
			objParent.template.querySelector('.popoverLegend').classList.remove("slds-hide");
			this.strLegendButtonVariant = "brand";
			if(objUtilities.isBlank(objParent.template.querySelector('.legendHTML').innerHTML)) {
				objParent.template.querySelector('.legendHTML').innerHTML = objParent.strLegendHTML;
			}
		} else {
			objParent.template.querySelector('.popoverLegend').classList.add("slds-hide");
			this.strLegendButtonVariant = "";
		}
	}
}