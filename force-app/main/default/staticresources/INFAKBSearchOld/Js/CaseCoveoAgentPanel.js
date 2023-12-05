/**************************************************************************
JS file Name: CaseCoveoAgentPanel.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 01-September-2021
Purpose: Hold the CoveoInsightPanel Component Customization.
Version: 1.0

Modificaiton History

Date       |  Modified by    |  Jira reference      |       ChangesMade                               |     Tag
      
***************************************************************************/

/* */

window.coveoCustomScripts['default'] = function (promise, component) {

    function fnBuildAdvancedQuery(parCurrentCaseId) {
        var varResult = '';
        try {

            var varCaseDataId = varCaseDetailsGlobalName + parCurrentCaseId;
           
            if (Coveo[varCaseDataId] != undefined) {

                var varCaseDetails = Coveo[varCaseDataId];

                // var varQueryRemoveCurrentCase = '(NOT @syssfid=={!>id}) (NOT @syssfcaseid=={!>id})';
                // var varQueryAddCaseDetails = '$some(keywords: {!>Subject} {!>Error_Code__c} {!>Description}, best: 20, match: 3, removeStopWords: true, maximum: 300)';
                // var varQueryAddCaseProductDetails = '$qre(expression:@athenaProduct=="{!>Forecast_Product__c}", modifier:\'100\')';
                           
                var varQueryAddCaseDetails = '';
                var varFinalQueryAddCaseDetails = '';
                if (varCaseDetails.Subject != undefined && varCaseDetails.Subject != '') {
                    if (varFinalQueryAddCaseDetails == '') {
                        varFinalQueryAddCaseDetails = varCaseDetails.Subject;
                    }
                    else {
                        varFinalQueryAddCaseDetails = varFinalQueryAddCaseDetails + ' ' + varCaseDetails.Subject;
                    }
                }

                if (varCaseDetails.Error != undefined && varCaseDetails.Error != '') {
                    if (varFinalQueryAddCaseDetails == '') {
                        varFinalQueryAddCaseDetails = varCaseDetails.Error;
                    }
                    else {
                        varFinalQueryAddCaseDetails = varFinalQueryAddCaseDetails + ' ' + varCaseDetails.Error;
                    }
                }

                if (varCaseDetails.Description != undefined && varCaseDetails.Description != '') {
                    if (varFinalQueryAddCaseDetails == '') {
                        varFinalQueryAddCaseDetails = varCaseDetails.Description;
                    }
                    else {
                        varFinalQueryAddCaseDetails = varFinalQueryAddCaseDetails + ' ' + varCaseDetails.Description;
                    }
                }

                if (varFinalQueryAddCaseDetails != '') {
                    varQueryAddCaseDetails = '$some(keywords: ' + varFinalQueryAddCaseDetails + ', best: 20, match: 3, removeStopWords: true, maximum: 300)';
                }
                
                var varQueryRemoveCurrentCase = '';
                if (varCaseDetails.Id != undefined && varCaseDetails.Id != '') {
                    varQueryRemoveCurrentCase = '(NOT @syssfid==' + varCaseDetails.Id + ') (NOT @syssfcaseid==' + varCaseDetails.Id + ')';
                }

                var varQueryAddCaseProductDetails = '';
                if (varCaseDetails.Product != undefined && varCaseDetails.Product != '') {
                    varQueryAddCaseProductDetails = '$qre(expression:@athenaProduct=="' + varCaseDetails.Product + '", modifier:\'100\')'
                }

                varResult = varQueryRemoveCurrentCase + ' ' + varQueryAddCaseDetails + ' ' + ' ' + varQueryAddCaseProductDetails;
                
            }
        } catch (error) {
            Log('error', 'Method : fnBuildAdvancedQuery; Error :' + error.message + " : " + error.stack);
        }
        return varResult;
    }

    function fnGetCaseRecordId() {
        var varReturn = '';
        try {
            var varmatchresult = null;
            var varCurrentURL = document.location.href;
            varmatchresult = varCurrentURL.match(/case\/+[a-z,A-Z,0-9]+\/view/gi);
            if (varmatchresult != null && varmatchresult.length > 0) {
                var varSplitedString = varmatchresult[0].split('/');
                varReturn = varSplitedString[1];
                // varReturn =  varReturn.toLowerCase();
            }
        } catch (error) {
            console.error('error' + 'Method : fnGetCaseRecordId; Error :' + error.message + " : " + error.stack);
        }
        return varReturn;
    }

    var varCaseDetailsGlobalName = "CaseDetailsForAgentPanel";
    var varSearchInterfaceGlobalName = "SearchInterfaceForAgentPanel";
    var varId = fnGetCaseRecordId();

    
    Coveo[varSearchInterfaceGlobalName + varId] = component;

    var root = component.getElements().map(function (element) {
        return element.querySelector('.CoveoSearchInterface');
    }).find(function (element) {
        return element != null;
    });
  
    Coveo.$$(root).on('buildingQuery', function (evt, args) {
        try {
            console.log('log' + 'Method : buildingQuery');
            var varCurrentCaseId = fnGetCaseRecordId();
            var varAdvancedQuery = fnBuildAdvancedQuery(varCurrentCaseId);

            if (varAdvancedQuery.length > 0 && varAdvancedQuery !== '') {
                args.queryBuilder.advancedExpression.parts.push(varAdvancedQuery);
            }

            //args.queryBuilder.advancedExpression.parts.push("Subject"); //This is a dummy, where its respective query will be build in Agent Service Console Search pipeline

        } catch (error) {
            console.error('error' + 'Method : buildingQuery; Error :' + error.message + " : " + error.stack);
        }
    });

    Coveo.$$(root).on('duringQuery ', function (evt, args) {
        try {
            console.log('log' + 'Method : duringQuery ');
            var varCurrentCaseId = fnGetCaseRecordId();

            var varCaseDataId = varCaseDetailsGlobalName + varCurrentCaseId;
                       
            if (Coveo[varCaseDataId] == undefined && args.queryBuilder.context.Case_Id != undefined && args.queryBuilder.context.Case_Id != '') {
                var varCaseDetails = {};
                varCaseDetails.Id = args.queryBuilder.context.Case_Id;
                varCaseDetails.Subject = args.queryBuilder.context.Case_Subject;
                varCaseDetails.Description = args.queryBuilder.context.Case_Description;
                varCaseDetails.Product = args.queryBuilder.context.Case_Forecast_Product__c;
                varCaseDetails.Error = args.queryBuilder.context.Case_Error_Message__c;
                Coveo[varCaseDataId] = varCaseDetails
                //evt.preventDefault();  
                Coveo.executeQuery(this);
            }
            else if (Coveo[varCaseDataId] != undefined && args.queryBuilder.context.Case_Id != undefined && args.queryBuilder.context.Case_Id != '') {
                var varCaseDetails = Coveo[varCaseDataId];
                var varIsDataToBeReTaken = false;
                if (varCaseDetails.Id != args.queryBuilder.context.Case_Id)
                    varIsDataToBeReTaken = true;
                if (varCaseDetails.Subject != args.queryBuilder.context.Case_Subject)
                    varIsDataToBeReTaken = true;
                if (varCaseDetails.Description != args.queryBuilder.context.Case_Description)
                    varIsDataToBeReTaken = true;
                if (varCaseDetails.Product != args.queryBuilder.context.Case_Forecast_Product__c)
                    varIsDataToBeReTaken = true;
                if (varCaseDetails.Error != args.queryBuilder.context.Case_Error_Message__c)
                    varIsDataToBeReTaken = true;

                if (varIsDataToBeReTaken) {
                    var varCaseDetails = {};
                    varCaseDetails.Id = args.queryBuilder.context.Case_Id;
                    varCaseDetails.Subject = args.queryBuilder.context.Case_Subject;
                    varCaseDetails.Description = args.queryBuilder.context.Case_Description;
                    varCaseDetails.Product = args.queryBuilder.context.Case_Forecast_Product__c;
                    varCaseDetails.Error = args.queryBuilder.context.Case_Error_Message__c;
                    Coveo[varCaseDataId] = varCaseDetails
                    Coveo.executeQuery(this);
                }
            }
        } catch (error) {
            console.error('error' + 'Method : duringQuery; Error :' + error.message + " : " + error.stack);
        }        
    });
}