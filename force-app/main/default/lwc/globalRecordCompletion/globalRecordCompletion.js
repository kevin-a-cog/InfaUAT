/*
 * Name			:	GlobalRecordCompletion
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/10/2021
 * Description	:	This LWC allows developers to display record completion on a linear gauge chart.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/10/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { loadScript } from 'lightning/platformResourceLoader';
import { objUtilities } from 'c/globalUtilities';
import GlobalRecordCompletionStaticResource from '@salesforce/resourceUrl/GlobalRecordCompletionStaticResource';

//Apex Controllers.
import getRecordScoring from "@salesforce/apex/GlobalRecordCompletionController.getRecordScoring";

//Custom Labels.
import No_Evaluations_Found from '@salesforce/label/c.No_Evaluations_Found';

//Class body.
export default class GlobalRecordCompletion extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api boolOutputPercentage;
	@api boolProgressBarMode;
	@api strMinimumColor;
	@api strMidpointColor;
	@api strMaximumColor;
	@api strHeader;
	@api strProgressBarColor;
	@api strNextStepName;//<SALESRT-17407>
	//Track variables.
	@track lstEvaluations;

	@track lstEvaluationsInComplete;//<SALESRT-17407>

	//Private variables.
	boolWasPreloaded = false;
	boolAlreadyLoaded = false;
	boolDisplayHeader = false;
	boolDisplaySpinner = true;
	boolDisplayDetails = false;
	boolHasEvaluations = false;
	progressPathTitle='';
	intAdjustment = 20;
	intTimestamp = "" + (new Date()).getTime() + (Math.floor(Math.random() * 1000) + 1);
	dblPercentage;
	strResult;
	strChartClasses;
	strSerializedResponse;
	hideIncompleteList = true; //<SALESRT-17407>
	//Labels.
	label = {
		No_Evaluations_Found
	}

	//Chart configuration.
	objChartParameters = {
		boolOutputPercentage: true,
		strMinimumColor: "#c00",
		strMidpointColor: "orange",
		strMaximumColor: "#0c0",
		objContainer: {
			intHeight: 30,
			strId: ".linear-gauge"
		},
		objPositionIndicator: {
			intLineWidth: 3,
			intSymbolMargin: 10,
			intSymboleSize: 250,
			strLineId: "line-position",
			strSymbolId: "symbol-triangle",
			strColor: "black"
		},
		objSeparators: {
			intNumberOfLines: 4,
			intLineWidth: 1,
			intMargin: 5,
			strBaseId: "marker",
			strColor: "#E5E8E8"
		}
	};

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objParent = this;

		//Only load it once.
		if(!this.boolAlreadyLoaded) {
			this.boolAlreadyLoaded = true;

			//First we load the D3.
			loadScript(objParent, GlobalRecordCompletionStaticResource).then(() => {

				//First we define the default values.
				if(objUtilities.isNotNull(objParent.boolOutputPercentage)) {
					objParent.objChartParameters.boolOutputPercentage = objParent.boolOutputPercentage;
				}
				if(objUtilities.isNotBlank(objParent.strMinimumColor)) {
					objParent.objChartParameters.strMinimumColor = objParent.strMinimumColor;
				}
				if(objUtilities.isNotBlank(objParent.strMidpointColor)) {
					objParent.objChartParameters.strMidpointColor = objParent.strMidpointColor;
				}
				if(objUtilities.isNotBlank(objParent.strMaximumColor)) {
					objParent.objChartParameters.strMaximumColor = objParent.strMaximumColor;
				}

				//We set the responsive code for the chart.
				objParent.responsiveChart();

				//Now we load the chart.
				objParent.boolDisplaySpinner = true;
				objParent.loadChart(true);
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}

	/*
	 Method Name : reload
	 Description : This method reloads the URL.
	 Parameters	 : None
	 Return Type : None
	 */
	responsiveChart() {
		let dblChartWidth;
		let dblIndicatorPosition;
		let objParent = this;

		//We attach the custom function.
		window.onresize = function () {

			//First we get the container and calculate the new indicator position.
			dblChartWidth = parseFloat(d3.select(objParent.template.querySelector(objParent.objChartParameters.objContainer.strId)).style("width"));
			dblIndicatorPosition = dblChartWidth * objParent.dblPercentage;
			
			//Now we update the positions.
			d3.select(objParent.template.querySelector("#" + "indicatorLine" + objParent.objChartParameters.objPositionIndicator.strLineId + objParent.intTimestamp)).attr("x1", 
					dblIndicatorPosition).attr("x2", dblIndicatorPosition);
			d3.select(objParent.template.querySelector("#" + "indicatorPath" + objParent.objChartParameters.objPositionIndicator.strSymbolId + objParent.intTimestamp)).attr("transform", function() { 
				return "translate(" + dblIndicatorPosition + "," + (objParent.objChartParameters.objContainer.intHeight + objParent.objChartParameters.objPositionIndicator.intSymbolMargin) + ")"; 
			});

			//We also move the separators.
			for(let intIndex = 1; intIndex <= objParent.objChartParameters.objSeparators.intNumberOfLines; intIndex++) {
				d3.select(objParent.template.querySelector("#" + "separator" + objParent.objChartParameters.objSeparators.strBaseId + intIndex + objParent.intTimestamp)).attr("x1", 
						(dblChartWidth / (objParent.objChartParameters.objSeparators.intNumberOfLines + 1)) * intIndex)
						.attr("x2", (dblChartWidth / (objParent.objChartParameters.objSeparators.intNumberOfLines + 1)) * intIndex);
			}
		}
	}

	/*
	 Method Name : loadChart
	 Description : This method reloads the URL.
	 Parameters	 : Boolean, called from reload, boolKeepRefreshing Indicates if the method needs to do a recursive action.
	 Return Type : None
	 */
	loadChart(boolKeepRefreshing) {
		let boolIsWidthValid = false;
		let boolContinueExecution = true;
		let intDelay = 100;
		let dblChartWidth;
		let dblIndicatorPosition;
		let strNewSerializedResponse;
		let objContainer = this.template.querySelector(this.objChartParameters.objContainer.strId);
		let objSVGContainer;
		let objGradient;
		let objPositionIndicator;
		let objSeparator;
		let objParent = this;

		//We show the spinner only if this is not a recursive call.
		if(!boolKeepRefreshing) {

			//We set the default parameters.
			objParent.boolDisplaySpinner = true;
			intDelay = 100;

			//Now we clean up the container.
			if(objUtilities.isNotNull(objContainer)) {
				objContainer.innerHTML = "";
			}
		}

		//Now we load the chart.
		setTimeout(function() {
			//First, we calculate the completeness.
			getRecordScoring({
				strRecordId: objParent.recordId,
				strNextStepName : objParent.strNextStepName
			}).then((objResult) => {
				this.progressPathTitle = 'Required Fields for moving to '+ objResult.strSubStageName;
				//First we check if we got a percentage.
				if(objUtilities.isNotNull(objResult.dblPercentage)) {
					objParent.strChartClasses = "slds-grid slds-gutters chart";

					//Now we save the percentage completion.
					objParent.boolHasEvaluations = true;
					objParent.dblPercentage = objResult.dblPercentage;
					if(objParent.objChartParameters.boolOutputPercentage) {
						objParent.strResult = Math.ceil(objParent.dblPercentage * 100) + "%";
					} else {
						objParent.strResult = objResult.intNumerator + "/" + objResult.intDenominator;
					}
					objParent.lstEvaluations = objResult.lstEvaluations;
					//added for SALESRT-16900	- Starts
					objParent.lstEvaluationsInComplete = objResult.lstEvaluationsInComplete; 
					if(objResult.lstEvaluationsInComplete == null || objResult.lstEvaluationsInComplete.length == undefined || objResult.lstEvaluationsInComplete.length == 0)
						objParent.hideIncompleteList = false;//SALESRT-16900 Ends
					//Now we render the chart container.
					dblChartWidth = parseFloat(d3.select(objContainer).style("width")) + objParent.intAdjustment;

					//Now we make sure we have a width, otherwise we change the flag to reload the component at a later point.
					if(isNaN(dblChartWidth)) {
						objParent.boolWasPreloaded = true;
					} else {

						//If the component was preloaded without being visible.
						if(objParent.boolWasPreloaded) {
							dblChartWidth -= objParent.intAdjustment;
						}

						//Now we load the component.
						boolIsWidthValid = true;

						//Now we make sure we are either not in a recursive execution, or this new iteration has different results from the previous iteration.
						if(boolKeepRefreshing) {
							boolContinueExecution = false;
							strNewSerializedResponse = JSON.stringify(objResult);
							if(strNewSerializedResponse !== objParent.strSerializedResponse) {
								objParent.strSerializedResponse = strNewSerializedResponse;
								boolContinueExecution = true;

								//Now we clean up the container.
								if(objUtilities.isNotNull(objContainer)) {
									objContainer.innerHTML = "";
								}
							}
						}
						
						//Now we decide if we continue the execution or not.
						if(boolContinueExecution) {
							dblIndicatorPosition = (dblChartWidth * objParent.dblPercentage);
							objSVGContainer = d3.select(objContainer).append("svg").attr("width", '100%').attr("height", (objParent.objChartParameters.objContainer.intHeight + 
									objParent.objChartParameters.objPositionIndicator.intSymbolMargin) + 'px');
				
							//Now we prepare the gradient color.
							objGradient = objSVGContainer.append("svg:defs").attr("id", "parentGradient" + objParent.intTimestamp).append("svg:linearGradient").attr("id", "gradient" + 
									objParent.intTimestamp).attr("x2", "100%").attr("spreadMethod", "pad");
	
							//Now we check if the component most load as a progress bar or heathmap.
							if(objParent.boolProgressBarMode) {
								objGradient.append("svg:stop").attr("id", "stop1" + objParent.intTimestamp).attr("offset", (objParent.dblPercentage * 100) + "%").attr("stop-color", 
										objParent.strProgressBarColor).attr("stop-opacity", 1);
								objGradient.append("svg:stop").attr("id", "stop2" + objParent.intTimestamp).attr("offset", (objParent.dblPercentage * 100) + ".001%").attr("stop-color", 
										"white").attr("stop-opacity", 1);
								objGradient.append("svg:stop").attr("id", "stop3" + objParent.intTimestamp).attr("offset", "100%").attr("stop-color", "white").attr("stop-opacity", 1);
							} else {
								objGradient.append("svg:stop").attr("id", "stop4" + objParent.intTimestamp).attr("offset", "0%").attr("stop-color", 
										objParent.objChartParameters.strMinimumColor).attr("stop-opacity", 1);
								objGradient.append("svg:stop").attr("id", "stop5" + objParent.intTimestamp).attr("offset", "50%").attr("stop-color", 
										objParent.objChartParameters.strMidpointColor).attr("stop-opacity", 1);
								objGradient.append("svg:stop").attr("id", "stop6" + objParent.intTimestamp).attr("offset", "100%").attr("stop-color", 
										objParent.objChartParameters.strMaximumColor).attr("stop-opacity", 1);
							}
							objSVGContainer.append("g").attr("id", "container" + objParent.intTimestamp).append("rect").attr("id", "innerContainer" + objParent.intTimestamp).attr("rx", 6).attr("ry", 
									6).attr("width", "100%" ).attr("height", objParent.objChartParameters.objContainer.intHeight).style("fill", "url(#gradient" + objParent.intTimestamp + 
									")").style("stroke-width", "1").style("stroke", "rgb(0,0,0)");
				
							//Now we render the position indicator.
							objPositionIndicator = objSVGContainer.append("g").attr("id", "indicator" + objParent.objChartParameters.objPositionIndicator.strLineId + objParent.intTimestamp);
							objPositionIndicator.append("line").attr("id", "indicatorLine" + objParent.objChartParameters.objPositionIndicator.strLineId + objParent.intTimestamp).attr("x1", 
									dblIndicatorPosition).attr("x2", dblIndicatorPosition).attr("y2", objParent.objChartParameters.objContainer.intHeight).attr("stroke-width", 
									objParent.objChartParameters.objPositionIndicator.intLineWidth).attr("stroke", objParent.objChartParameters.objPositionIndicator.strColor);
							objPositionIndicator.append("path").attr("id", "indicatorPath" + objParent.objChartParameters.objPositionIndicator.strSymbolId + objParent.intTimestamp).attr("transform", function() { 
								return "translate(" + dblIndicatorPosition + "," + (objParent.objChartParameters.objContainer.intHeight + objParent.objChartParameters.objPositionIndicator.intSymbolMargin) + ")";
							}).attr("d", d3.symbol().type(d3.symbolTriangle).size(objParent.objChartParameters.objPositionIndicator.intSymboleSize)).style("fill", 
									objParent.objChartParameters.objPositionIndicator.strColor);
				
							//Now we render the separators.
							for(let intIndex = 1; intIndex <= objParent.objChartParameters.objSeparators.intNumberOfLines; intIndex++) {
								objSeparator = objSVGContainer.append("g").attr("id", "separatorContainer" + objParent.objChartParameters.objSeparators.strBaseId + intIndex + objParent.intTimestamp);
								objSeparator.append("line").attr("id", "separator" + objParent.objChartParameters.objSeparators.strBaseId + intIndex + objParent.intTimestamp)
										.attr("x1", (dblChartWidth / (objParent.objChartParameters.objSeparators.intNumberOfLines + 1)) * intIndex)
										.attr("y1", objParent.objChartParameters.objSeparators.intMargin)
										.attr("x2", (dblChartWidth / (objParent.objChartParameters.objSeparators.intNumberOfLines + 1)) * intIndex)
										.attr("y2", objParent.objChartParameters.objContainer.intHeight - objParent.objChartParameters.objSeparators.intMargin)
										.attr("stroke-width", objParent.objChartParameters.objSeparators.intLineWidth).attr("stroke", objParent.objChartParameters.objSeparators.strColor);
							}
							objParent.intAdjustment = 0;
						}
					}
				} else {

					//We didn't receive a percentage.
					objParent.strChartClasses = "slds-hidden";
					objParent.boolHasEvaluations = false;
					boolIsWidthValid = true;
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {

				//Finally, we hide the spinner.
				if(boolIsWidthValid) {
					objParent.boolDisplaySpinner = false;

					//Now we start the infitine refreshing, if requested.
					if(boolKeepRefreshing) {
						objParent.loadChart(true);
					}
				} else {
					objParent.loadChart(false);
				}
			});
		}, intDelay);
	}

	/*
	 Method Name : executeActionSelected
	 Description : This method executes the corresponding action.
	 Parameters	 : Object, called from executeActionSelected, objEvent Event.
	 Return Type : None
	 */
	executeActionSelected(objEvent) {
		let objData;
		let objParent = this;
		//First we look for the element.
		let evaluations;
		if(objEvent.target.dataset.key == 'approvalIcon')
			evaluations = objParent.lstEvaluations;
		else
			evaluations = objParent.lstEvaluationsInComplete;//<SALESRT-17407>
		evaluations.forEach(objAction => {
			if(objAction.strId === objEvent.target.dataset.id) {

				//Now we transform the data into object, if possible.
				try {
					objData = JSON.parse(objAction.strActionData);
				} catch(objException) {
					objData = new Object();
				}

				//Now we decide the operation.
				switch(objAction.strActionType) {
					case "Launch Component":
					case "Launch Component In Modal":
						objParent.dispatchEvent(
							new CustomEvent("executeaction", {
								detail: {
									strActionTarget: objAction.strActionTarget,
									strActionData: objAction.strActionData,
									strActionType: objAction.strActionType
								},
								bubbles: true,
								composed: true
							})
						);
					break;
					case "Navigate":

						//Now we check if we received default parameters.
						if(objUtilities.isNotNull(objData.state) && objUtilities.isNotNull(objData.state.defaultFieldValues)) {
							objData.state.defaultFieldValues = encodeDefaultFieldValues(objData.state.defaultFieldValues);
						}

						//Now we navigate to the target.
						objParent[NavigationMixin.Navigate](objData);
					break;
				}
			}
		});
	}

	/*
	 Method Name : reload
	 Description : This method reloads the component.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	reload() {
		this.loadChart(false);
	}

	async refresh() {
        await refreshApex(this.loadChart(false));
    }
	/*
	 Method Name : toggleDetails
	 Description : This method toggles the details view.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	toggleDetails() {
		this.boolDisplayDetails = !this.boolDisplayDetails;
	}
}