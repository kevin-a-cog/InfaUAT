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

    function fnModifyKBUURLBasedOnEnvironment(data) {
        try {
              
            for (var i = 0; i < data.results.results.length; ++i) {
                var r = data.results.results[i];

                var infa_docType = r.raw.infadocumenttype ? r.raw.infadocumenttype : '';
                var infa_permissionType = r.raw.infapermissiontype ? r.raw.infapermissiontype.toLowerCase() : '';
                var infa_moderationStatus = r.raw.infamoderationstatus ? r.raw.infamoderationstatus : '';
                var isInternalSearchEnv = false;
                var varSearchUserFedID = '';
                if (InfaKBSearchJs.varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier') != undefined) {
                    varSearchUserFedID = InfaKBSearchJs.varINFAKBContentSearchControllerComponent.get('v.currentUserFedId.FederationIdentifier');
                }
                var infa_validationstatus = r.raw.infavalidationstatus ? r.raw.infavalidationstatus.toLowerCase() : '';
                var infa_publishstatus = r.raw.infapublishstatus ? r.raw.infapublishstatus.toLowerCase() : '';
                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'KB') {
                    var internalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&internal=1&fid=%%FLD%%'
                    var internaldrafturlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&type=external'
                    var externaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&type=external'
                    var inernaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                    var inernaltdraftechnicalreviewurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.KBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
  
                    //IsUserAuthenticated == true means the logged user is not a guest user thus we are on Internal KB page                                    
                    // isInternalSearchEnv = InfaKBSearchJs.IsUserAuthenticated == 'true' && InfaKBSearchJs.UserType == 'Standard' ?
                    //       true : ((infa_permissionType == 'internal' || (infa_permissionType == 'public' && infa_moderationStatus != 0)) ? true : false);
                    isInternalSearchEnv = InfaKBSearchJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
  
                    if (isInternalSearchEnv == true && infa_validationstatus == 'pending technical review') {
                        r.clickUri = inernaltechnicalreviewurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                    }
                    else if (isInternalSearchEnv == false && infa_validationstatus == 'pending technical review') {
                        r.clickUri = externaltechnicalreviewurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                    }
                    else if (isInternalSearchEnv == true && infa_publishstatus == 'draft') {
                        r.clickUri = internaldrafturlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                    }
                    else if (isInternalSearchEnv == true) {
                        r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                    }
                    else if (isInternalSearchEnv == false) {
                        r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                    }
  
                    r.ClickUri = r.clickUri;
                    r.PrintableUri = r.printableUri = r.clickUri;
  
                }

                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceCase') {

                    isInternalSearchEnv = InfaKBSearchJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
                    
                    var internalurlformat = '/lightning/r/Case/%%CASEID$$/view'
                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.eSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'

                    if (isInternalSearchEnv == true) {
                        r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                    }
                    else if (isInternalSearchEnv == false) {
                        r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                    }

                    r.ClickUri = r.clickUri;
                    r.PrintableUri = r.printableUri = r.clickUri;
                }

                if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceAccount') {

                    isInternalSearchEnv = InfaKBSearchJs.varSearchHub == 'AthenaKBSearchInternal' || InfaKBSearchJs.varSearchHub == 'AthenaPanelForCases' ? true : false;
                    
                    var internalurlformat = '/lightning/r/Account/%%ACCOUNTID$$/view'
                    var externalurlformat = 'https://%%DOMAIN$$' + InfaKBSearchJs.eSupportCommunityNameInURL + '/s/supportaccountdetails?accountid=%%ACCOUNTID$$'

                    if (isInternalSearchEnv == true) {
                        r.clickUri = internalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                    }
                    else if (isInternalSearchEnv == false) {
                        r.clickUri = externalurlformat.replace('%%DOMAIN$$', InfaKBSearchJs.SFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                    }

                    r.ClickUri = r.clickUri;
                    r.PrintableUri = r.printableUri = r.clickUri;
                }
            }
       
        } catch (e) {
            InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnModifyKBUURLBasedOnEnvironment Message : ' + e.message);
        }
    }

    function fnProcessParentCmpData()
    {
        try {
            
            
            var varCaseDetailsGlobalName = "caseLightiningCoveoAgentPanel";
            var varSearchInterfaceGlobalName = "SearchInterfaceForAgentPanel";
            var varParentCmpId = '';
            if(window.location.hash.indexOf('#tcmp=') != -1)
            {                
                varParentCmpId = window.location.hash.split('#tcmp=')[1];
                var noHashURL = window.location.href.replace(/#.*$/, '');
                window.history.replaceState('', document.title, noHashURL) 
            }
            else if (window.location.hash.indexOf('tcmp=') != -1)
            {
                window.location.hash = window.location.hash.split('tcmp=')[0];
                varParentCmpId = window.location.hash.split('tcmp=')[1];
            }
                                        
            
        } catch (error) {
            console.error('error' + 'Method : preprocessResults; Error :' + error.message + " : " + error.stack);
        }
    }
   // fnProcessParentCmpData();
   
    
    var root = component.getElements().map(function (element) {
        return element.querySelector('.CoveoSearchInterface');
    }).find(function (element) {
        return element != null;
    });
    var varId = fnGetCaseRecordId();
    var vardiv = document.getElementById(varId);

    Coveo.$$(root).on('preprocessResults', function (evt, args) {
        try {
            console.log('preprocessResults');
            var varSearchInterfaceGlobalName = "SearchInterfaceForAgentPanel";
            var varId = fnGetCaseRecordId();
            //console.log(Coveo[varSearchInterfaceGlobalName + varId].get('v.currentUserFedId.FederationIdentifier'));
            //fnModifyKBUURLBasedOnEnvironment(data);
        } catch (error) {
            console.error('error' + 'Method : preprocessResults; Error :' + error.message + " : " + error.stack);
        }
    });




    // Coveo.$$(root).on('buildingQuery', function (evt, args) {
    //     console.log('buildingQuery');
    // });
  
    // Coveo.$$(root).on('buildingQuery', function (evt, args) {
    //     try {
    //         console.log('log' + 'Method : buildingQuery');
    //         var varCurrentCaseId = fnGetCaseRecordId();
    //         var varAdvancedQuery = fnBuildAdvancedQuery(varCurrentCaseId);

    //         if (varAdvancedQuery.length > 0 && varAdvancedQuery !== '') {
    //             args.queryBuilder.advancedExpression.parts.push(varAdvancedQuery);
    //         }

    //         //args.queryBuilder.advancedExpression.parts.push("Subject"); //This is a dummy, where its respective query will be build in Agent Service Console Search pipeline

    //     } catch (error) {
    //         console.error('error' + 'Method : buildingQuery; Error :' + error.message + " : " + error.stack);
    //     }
    // });

    // Coveo.$$(root).on('duringQuery ', function (evt, args) {
    //     try {
    //         console.log('log' + 'Method : duringQuery ');
    //         var varCurrentCaseId = fnGetCaseRecordId();

    //         var varCaseDataId = varCaseDetailsGlobalName + varCurrentCaseId;
                       
    //         if (Coveo[varCaseDataId] == undefined && args.queryBuilder.context.Case_Id != undefined && args.queryBuilder.context.Case_Id != '') {
    //             var varCaseDetails = {};
    //             varCaseDetails.Id = args.queryBuilder.context.Case_Id;
    //             varCaseDetails.Subject = args.queryBuilder.context.Case_Subject;
    //             varCaseDetails.Description = args.queryBuilder.context.Case_Description;
    //             varCaseDetails.Product = args.queryBuilder.context.Case_Forecast_Product__c;
    //             varCaseDetails.Error = args.queryBuilder.context.Case_Error_Message__c;
    //             Coveo[varCaseDataId] = varCaseDetails
    //             //evt.preventDefault();  
    //             Coveo.executeQuery(this);
    //         }
    //         else if (Coveo[varCaseDataId] != undefined && args.queryBuilder.context.Case_Id != undefined && args.queryBuilder.context.Case_Id != '') {
    //             var varCaseDetails = Coveo[varCaseDataId];
    //             var varIsDataToBeReTaken = false;
    //             if (varCaseDetails.Id != args.queryBuilder.context.Case_Id)
    //                 varIsDataToBeReTaken = true;
    //             if (varCaseDetails.Subject != args.queryBuilder.context.Case_Subject)
    //                 varIsDataToBeReTaken = true;
    //             if (varCaseDetails.Description != args.queryBuilder.context.Case_Description)
    //                 varIsDataToBeReTaken = true;
    //             if (varCaseDetails.Product != args.queryBuilder.context.Case_Forecast_Product__c)
    //                 varIsDataToBeReTaken = true;
    //             if (varCaseDetails.Error != args.queryBuilder.context.Case_Error_Message__c)
    //                 varIsDataToBeReTaken = true;

    //             if (varIsDataToBeReTaken) {
    //                 var varCaseDetails = {};
    //                 varCaseDetails.Id = args.queryBuilder.context.Case_Id;
    //                 varCaseDetails.Subject = args.queryBuilder.context.Case_Subject;
    //                 varCaseDetails.Description = args.queryBuilder.context.Case_Description;
    //                 varCaseDetails.Product = args.queryBuilder.context.Case_Forecast_Product__c;
    //                 varCaseDetails.Error = args.queryBuilder.context.Case_Error_Message__c;
    //                 Coveo[varCaseDataId] = varCaseDetails
    //                 Coveo.executeQuery(this);
    //             }
    //         }
    //     } catch (error) {
    //         console.error('error' + 'Method : duringQuery; Error :' + error.message + " : " + error.stack);
    //     }        
    // });
}
