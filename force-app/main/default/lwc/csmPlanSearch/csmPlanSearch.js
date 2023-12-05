/*
 * Name         :   CsmPlanSearch
 * Author       :   Ankit Saxena
 * Created Date :   24th-May-2023
 * Description  :   LWC component for showing the coveo Search results using Coveo JS framework in a compact view on plan record page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Ankit Saxena           24-May-2023     AR-3147             LWC component for showing the Coveo Search results          1
                                                            using Coveo JS framework in a compact view.                       
 Chaitanya T            24-Oct-2023     AR-3467             Removing the default filter based on stage                 <T02>
 */

import { LightningElement, api, track, wire } from 'lwc';
import CoveoJsFrameworkJsMin from "@salesforce/resourceUrl/CoveoJsFrameworkJsMinOld";
import CoveoJsFrameworkOthers from "@salesforce/resourceUrl/CoveoJsFrameworkOthersOld";
import CSMCoveoSearch from "@salesforce/resourceUrl/CSMCoveoSearch";
import getSearchToken from "@salesforce/apex/KBContentSearch.getSearchToken";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';

const FIELDS = ['Plan__c.Stage__c'];

const ISDEBUGENABLED = true;

//For Loggging in Console
function Log(parType, parMessage) {
   try {
      if (ISDEBUGENABLED == true || parType == 'error') {
         if (parType == 'log') {
            console.log(parMessage);
         }
         else if (parType == 'error') {
            console.error(parMessage);
         }
         else if (parType == 'warn') {
            console.warn(parMessage);
         }
      }
   } catch (err) {
      console.log('Utility Log : ' + err.message);
   } finally {

   }
}
//For Loggging in Console

export default class CsmPlanSearch extends LightningElement {
      searchtoken;
   searchhubname;
   searchorgname;
   varCoveoSearchInterface;
   varCoveoAnalytics;
   recId;
   @track popupiconname = 'utility:new_window';
   @track popupicontitle = 'Full Screen';
   @track isStillLoading = true;
   @track placedin = 'caseconsoleipxsearch';
   @api numResults;
   @api requestActionLabel;
   @api recordId;
   @track openEngagementModal = false;
   @track selectedEC;
   @api ecFilterData;
   @api engagementCategoryFacetLabel;
   @api engagementTypeFacetLabel;
   @api engagementStageFacetLabel;
   @api engagementProductsFacetLabel;
   @api engagementFocusAreaFacetLabel;
   @api engagementUseCaseFacetLabel;
   @api searchBoxPlaceholderText;
   planStage;
   @api hideExpand = false;

   @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
   wiredRecord({ error, data }) {
         if (data) {
            this.planStage = data.fields.Stage__c.value;
            console.log('W Plan stage : ', this.planStage);
         }
   }

   connectedCallback() {
      this.recId = this.recordId;
      if (typeof (Math) != 'undefined' && typeof (Math.floor) != 'undefined' && typeof (Date) != 'undefined') {
         this.hdnComponentGlobalId = Math.floor(Date.now() / 1000).toString();
      }
      
      try {         
         this.fnGetSearchToken(this.recordId, this.openEngagementModal);
      } catch (error) {
         Log('error', 'Method : connectedCallback; Catch Error :' + error.message + " : " + error.stack);
      }

   }

   fnGetSearchToken(recId, openEngagementModal) {
      try {
         getSearchToken({ strSessionId: '', strUserEmail: '', strUserId: '', strCalledFrom: this.placedin })
            .then((result) => {
               try {
                  window.csmPlanSearchTemplate = this;
                  this.searchtoken = JSON.parse(result).APISearchToken;
                  this.searchhubname = JSON.parse(result).APISearchHub;
                  this.searchorgname = JSON.parse(result).SearchOrgName;
                  this.loadComponentResource(recId, openEngagementModal);
               } catch (error) {
                  Log('error', 'Method : getSearchToken; then Catch Error :' + error.message + " : " + error.stack);
               }
            })
            .catch((error) => {
               Log('error', 'Method : getSearchToken; Catch Error :' + error.message + " : " + error.stack);
            });
      } catch (error) {
         Log('error', 'Method : fnGetSearchToken; Catch Error :' + error.message + " : " + error.stack);
      }
   }

   //Script
   loadComponentResource(recId, openEngagementModal) {
      try {
         Promise.all([
            loadStyle(this, CoveoJsFrameworkOthers + "/CoveoJsFrameworkOthers/css/CoveoFullSearch.css"),
            loadStyle(this, CSMCoveoSearch + "/csmPlanCustomSearch.css"),
            loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js")
         ]).then(() => {
            try {
            loadScript(this, CoveoJsFrameworkJsMin + "/CoveoJsFrameworkJsMin/CoveoJsSearch.js"
               ).then(() => {
                     loadScript(this, CSMCoveoSearch + "/csmPlanSearchTemplate.js")
                     .then(result => {
                        this.varCoveoAnalytics = this.template.querySelector(
                           ".CoveoAnalytics"
                        );
                        this.varCoveoAnalytics.setAttribute("data-search-hub", this.searchhubname);
                        this.configureOldSearchEndPoint();
               
                        this.varCoveoSearchInterface = this.template.querySelector(
                           ".CoveoSearchInterface"
                        );
                        window.CustomCoveoCaseDflection = this.template.querySelector(
                           ".CoveoSearchInterface"
                        );
               
                     var currentctrl = this;
                     
                     //<T02> start
                     /*Coveo.$$(this.varCoveoSearchInterface).on("afterInitialization", function() {
                        var stageToSelect = [];
                        console.log('Plan Stage : ', currentctrl.planStage);
                        if (currentctrl.planStage != undefined) {
                           if (currentctrl.planStage == 'Implement') {
                              stageToSelect = ["Implement", "Design"];
                           } else {
                              stageToSelect = [currentctrl.planStage];
                           }
                           Coveo.state(currentctrl.varCoveoSearchInterface, 'f:@engagementinternalstage', stageToSelect);
                        }
                        });*/
                     //</T02> end

                     Coveo.init(this.varCoveoSearchInterface);
               
                     Coveo.$$(this.varCoveoSearchInterface).on('preprocessResults', function(e, data) {
                           for (var i = 0; i < data.results.results.length; ++i) {
                           var appendParams = "";
                           if (recId) {
                              appendParams = appendParams + "planId=" + currentctrl.recId;
                           }
                           
                           if (data.results.results[i].clickUri.includes('?')) {
                              data.results.results[i].clickUri = data.results.results[i].clickUri + "&" + appendParams + "&internal=true";
                           } else {
                              data.results.results[i].clickUri = data.results.results[i].clickUri + "?" + appendParams + "&internal=true";
                           }
                           }
                        });
                        //CReation of a request button 
                        Coveo.$$(this.varCoveoSearchInterface).on('newResultDisplayed', function (e, data) {
                        var buttonElement = document.createElement('button');
                        buttonElement.setAttribute('class', 'data-custom-coveo-field-value');
                        buttonElement.setAttribute('style', 'background-color:#ADD8E6;float:right;margin-right:12px;');
                        buttonElement.innerHTML = currentctrl.requestActionLabel;
                        buttonElement.addEventListener('click', function () { requestCsmButton(currentctrl,data.result.raw); });
                        data.item.querySelectorAll("div.coveo-result-cell").forEach(function(element) {
                           element.appendChild(buttonElement);
                           });
                        });
                     })
                     .catch((error) => {
                        Log('error', 'Method : loadCustomTemplateJs - loadCoveoJs; Error :' + error.message + " : " + error.stack);
                     });
               })
               .catch((error) => {
                  Log('error', 'Method : loadJquery - loadScript; Error :' + error.message + " : " + error.stack);
               });

            } catch (error) {
               Log('error', 'Method : loadCoveoSearch; Error :' + error.message + " : " + error.stack);
            }
      
            function requestCsmButton(obj,data) {
            obj.selectedEC=data;
            obj.openEngagementModal = true;
         }

         }).catch((error) => {
            console.error("Error Occured", error);
         });

      } catch (error) {
         Log('error', 'Method : loadComponentResource; Error :' + error.message + " : " + error.stack);
      }
   }

   configureOldSearchEndPoint() {
      try {
            var token = this.searchtoken;
            var endpointURI = "https://platform.cloud.coveo.com/rest/search";
   
            if (Coveo.SearchEndpoint.endpoints["default"]) {
               Coveo.SearchEndpoint.endpoints["default"].options.accessToken = token;
               Coveo.SearchEndpoint.endpoints["default"].options.renewAccessToken = this.fnReNewSearchToken;
            } else {
               Coveo.SearchEndpoint.endpoints["default"] = new Coveo.SearchEndpoint({
                  restUri: endpointURI,
                  accessToken: token,
                  renewAccessToken: this.fnReNewSearchToken
               });
            }   
      } catch (error) {
            Log('error', 'Method : configureOldSearchEndPoint; Error :' + error.message + " : " + error.stack);
      }
   }
   
   fnReNewSearchToken() {
      console.log('fnReNewSearchToken called');
   }
   //Method to handle popout and popin feature
   handleCsmSearchPopOutIn() {
      if (this.template.querySelector('[data-id="csmplan-wrapper"]').className == 'csmplan-search-normal') {
         this.template.querySelector('[data-id="csmplan-wrapper"]').className = 'csmplan-search-popout';
         this.popupiconname = 'utility:pop_in';
         this.popupicontitle = "PopIn";
         window.dispatchEvent(new Event('resize'));
      }
      else {
         this.template.querySelector('[data-id="csmplan-wrapper"]').className = 'csmplan-search-normal';
         this.popupiconname = 'utility:new_window';
         this.popupicontitle = "Full Screen";
         window.dispatchEvent(new Event('resize'));
      }
   }

   handleCloseModal(e){
      this.openEngagementModal = false;
      let  csmplanDiv = this.template.querySelector('[data-id="csmplan-wrapper"]').className;
      if (e.detail != undefined && e.detail.success && csmplanDiv != undefined && csmplanDiv == 'csmplan-search-popout') {
         this.handleCsmSearchPopOutIn();
      }      
   }

   handleCoveoClose(){
      const closecoveo = new CustomEvent('closecoveoparent');
      this.dispatchEvent(closecoveo);
   }
   
   handleRefresh(e) {
      var stageToSelect = [];
      console.log('Calling refresh : plan Stage : ', this.planStage);
      if (this.planStage != undefined) {
         if (this.planStage == 'Implement') {
            stageToSelect = ["Implement", "Design"];
         } else {
            stageToSelect = [this.planStage];
         }         
         var coveoBreadcrumbClearAllElement = this.template.querySelector('.coveo-breadcrumb-clear-all');
         coveoBreadcrumbClearAllElement.click();
         var currentThis = this;
         setTimeout(function () {
               Coveo.state(currentThis.varCoveoSearchInterface, 'q', "");
               //Coveo.state(currentThis.varCoveoSearchInterface, 'f:@engagementinternalstage', stageToSelect);//<T02>
               Coveo.executeQuery(currentThis.varCoveoSearchInterface);
            }, 1000
         );
      }
   }
}