({
    doInit: function (component, event, helper) {
        try {
            component.set('v.hdnCssForAnimation', 'display: block;');
            console.log('doInit');
            var varSubject = '';
            var varDescription = '';
            var varProduct = '';
            var varErrorMessage = '';
            var varId = '';

            function fnModifyKBUURLBasedOnEnvironment(data, component) {
                try {
                      
                    for (var i = 0; i < data.results.results.length; ++i) {
                        var r = data.results.results[i];
        
                        var infa_docType = r.raw.infadocumenttype ? r.raw.infadocumenttype : '';
                        var infa_permissionType = r.raw.infapermissiontype ? r.raw.infapermissiontype.toLowerCase() : '';
                        var infa_moderationStatus = r.raw.infamoderationstatus ? r.raw.infamoderationstatus : '';
                        var isInternalSearchEnv = false;
                        var varSearchUserFedID = '';
                        var varhdnKBCommunityNameInURL = component.get('v.hdnKBCommunityNameInURL') == 'none' ? '' : component.get('v.hdnKBCommunityNameInURL');
                        var varhdnSFDCKBExternalHost = component.get('v.hdnSFDCKBExternalHost');
                        var varhdnSFDCKBInternalHost = component.get('v.hdnSFDCKBInternalHost');
                        var varSearchHub = component.get('v.searchHub');
                        var varhdneSupportCommunityNameInURL = component.get('v.hdneSupportCommunityNameInURL') == 'none' ? '' : component.get('v.hdneSupportCommunityNameInURL');
                        var varhdnSFDCEsupportHost = component.get('v.hdnSFDCEsupportHost');

                        if (component.get('v.currentUserFedId.FederationIdentifier') != undefined) {
                            varSearchUserFedID = component.get('v.currentUserFedId.FederationIdentifier');
                        }
                        var infa_validationstatus = r.raw.infavalidationstatus ? r.raw.infavalidationstatus.toLowerCase() : '';
                        var infa_publishstatus = r.raw.infapublishstatus ? r.raw.infapublishstatus.toLowerCase() : '';
                        if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'KB') {
                            var internalurlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&internal=1&fid=%%FLD%%'
                            var internaldrafturlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                            var externalurlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/article/%%KBURLNAME$$?language=%%LANG%%&type=external'
                            var externaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&type=external'
                            var inernaltechnicalreviewurlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
                            var inernaltdraftechnicalreviewurlformat = 'https://%%DOMAIN$$' + varhdnKBCommunityNameInURL + '/s/articlepreview?c__number=%%KBURLNAME$$&language=%%LANG%%&internal=1&fid=%%FLD%%'
          
                        
                            isInternalSearchEnv = varSearchHub == 'AthenaKBSearchInternal' || varSearchHub == 'AthenaPanelForCases' ? true : false;
          
                            if (isInternalSearchEnv == true && infa_validationstatus == 'pending technical review') {
                                r.clickUri = inernaltechnicalreviewurlformat.replace('%%DOMAIN$$', varhdnSFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                            }
                            else if (isInternalSearchEnv == false && infa_validationstatus == 'pending technical review') {
                                r.clickUri = externaltechnicalreviewurlformat.replace('%%DOMAIN$$', varhdnSFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                            }
                            else if (isInternalSearchEnv == true && infa_publishstatus == 'draft') {
                                r.clickUri = internaldrafturlformat.replace('%%DOMAIN$$', varhdnSFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                            }
                            else if (isInternalSearchEnv == true) {
                                r.clickUri = internalurlformat.replace('%%DOMAIN$$', varhdnSFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%FLD%%', varSearchUserFedID).replace('%%LANG%%', r.raw.infalanguage);
                            }
                            else if (isInternalSearchEnv == false) {
                                r.clickUri = externalurlformat.replace('%%DOMAIN$$', varhdnSFDCKBExternalHost).replace('%%KBURLNAME$$', r.raw.infaurlname).replace('%%LANG%%', r.raw.infalanguage);
                            }
          
                            r.ClickUri = r.clickUri;
                            r.PrintableUri = r.printableUri = r.clickUri;
          
                        }
        
                        if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceCase') {
        
                            isInternalSearchEnv = varSearchHub == 'AthenaKBSearchInternal' || varSearchHub == 'AthenaPanelForCases' ? true : false;
                            
                            var internalurlformat = '/lightning/r/Case/%%CASEID$$/view'
                            var externalurlformat = 'https://%%DOMAIN$$' + varhdneSupportCommunityNameInURL + '/s/casedetails?caseId=%%CASEID$$'
        
                            if (isInternalSearchEnv == true) {
                                r.clickUri = internalurlformat.replace('%%DOMAIN$$', varhdnSFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                            }
                            else if (isInternalSearchEnv == false) {
                                r.clickUri = externalurlformat.replace('%%DOMAIN$$', varhdnSFDCEsupportHost).replace('%%CASEID$$', r.raw.sfid)
                            }
        
                            r.ClickUri = r.clickUri;
                            r.PrintableUri = r.printableUri = r.clickUri;
                        }
        
                        if (r.raw.connectortype == 'Salesforce2' && infa_docType == 'SalesforceAccount') {
        
                            isInternalSearchEnv = varSearchHub == 'AthenaKBSearchInternal' || varSearchHub == 'AthenaPanelForCases' ? true : false;
                            
                            var internalurlformat = '/lightning/r/Account/%%ACCOUNTID$$/view'
                            var externalurlformat = 'https://%%DOMAIN$$' + varhdneSupportCommunityNameInURL + '/s/supportaccountdetails?accountid=%%ACCOUNTID$$'
        
                            if (isInternalSearchEnv == true) {
                                r.clickUri = internalurlformat.replace('%%DOMAIN$$', varhdnSFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                            }
                            else if (isInternalSearchEnv == false) {
                                r.clickUri = externalurlformat.replace('%%DOMAIN$$', varhdnSFDCEsupportHost).replace('%%ACCOUNTID$$', r.raw.sfid)
                            }
        
                            r.ClickUri = r.clickUri;
                            r.PrintableUri = r.printableUri = r.clickUri;
                        }
                    }
               
                } catch (e) {
                    InfaKBCommonUtilityJs.Log('error', 'SearchPage : Error Occured in Method fnModifyKBUURLBasedOnEnvironment Message : ' + e.message);
                }
            }

            function fnLoginToKBCommunity(component) {
                try {
                    
                    var varNetworkSwitchLogin = component.get('v.hdnKBInternalNetworkSwitchLoginURL');
                    var varagentsearchinfakbcsdummywin = component.find('agentsearchinfakbcsdummywin');
                    varagentsearchinfakbcsdummywin.src = varNetworkSwitchLogin;
                    setTimeout(function () { varagentsearchinfakbcsdummywin.remove(); }, 10000);
                    
                } catch (ex) {
                    console.error('error' + 'SearchPage : Error Occured in Method fnLoginToKBCommunity Message : ' + ex.message);
                }
            }

            function fnBuildAdvancedQuery(data, component) {
                data.queryBuilder.fieldsToInclude = ['infalanguage', 'infaurlname', 'infapublicurl', 'infapublishstatus', 'infavalidationstatus'];
                var varRemoveContextEnabled = component.get('v.hdnRemoveContextEnabled');
                if (varRemoveContextEnabled == 'false') {
                   
                    var varAdvancedQuery = '(NOT @syssfid==' + varId + ') \n (NOT @syssfcaseid==' + varId + ') \n $some(keywords: <@-' + varSubject + ' ' + varDescription + ' ' + varErrorMessage + '-@> best: 20, match: 3, removeStopWords: true, maximum: 300)  \n $qre(expression:@athenaProduct=="' + varProduct + '", modifier:\'100\')';
                    data.queryBuilder.advancedExpression.parts.push(varAdvancedQuery);
                }
                
            }
                     
            //fnLoginToKBCommunity(component);
           
            // Get the Coveo Insight Panel Lightning Component
            var coveoAgentPanel = component.find('AgentInsightPanel');
            // Get the Coveo SearchUI base component
            var coveoSearchUI = coveoAgentPanel.get('v.searchUI');
            // Apply the customization
            coveoSearchUI.proxyAddEventListener('preprocessResults', function (e, args) {
                fnModifyKBUURLBasedOnEnvironment(args, component);
            });

            coveoSearchUI.proxyAddEventListener('buildingQuery', function (e, args) {
                // console.log('buildingQuery');
                fnBuildAdvancedQuery(args, component);                
            });

            coveoSearchUI.proxyAddEventListener('changeAnalyticsCustomData', function (e, args) {
                // console.log('changeAnalyticsCustomData');               
            });

            coveoSearchUI.proxyAddEventListener('deferredQuerySuccess', function (e, args) {
                // console.log('deferredQuerySuccess');               
            });

            coveoSearchUI.proxyAddEventListener('afterInitialization', function (e, args) {
                try {
                    //this.CoveoQueryController.usageAnalytics.setOriginContext("CaseCreation");
                    varSubject = component.get('v.currentCaseData.Subject') == undefined ? '' : component.get('v.currentCaseData.Subject');
                    varDescription = component.get('v.currentCaseData.Description') == undefined ? '' : component.get('v.currentCaseData.Description');
                    varProduct = component.get('v.currentCaseData.Forecast_Product__c') == undefined ? '' : component.get('v.currentCaseData.Forecast_Product__c');
                    varErrorMessage = component.get('v.currentCaseData.Error_Message__c') == undefined ? '' : component.get('v.currentCaseData.Error_Message__c');
                    varId = component.get('v.currentCaseData.Id') == undefined ? '' : component.get('v.currentCaseData.Id');                                      
                } catch (error) {
                    console.error('error' + 'Method : doInit; Error :' + error.message + " : " + error.stack);
                }
                finally {
                    component.set('v.hdnCssForAnimation', 'display: none;');
                }
            });
                      
                        
        } catch (error) {
            console.error('error' + 'Method : doInit; Error :' + error.message + " : " + error.stack);
        }
    },
    selectChange: function (component, event, helper) {
        try {
            // Get the Coveo Insight Panel Lightning Component
            var coveoAgentPanel = component.find('AgentInsightPanel');
            // Get the Coveo SearchUI base component
            var coveoSearchUI = coveoAgentPanel.get('v.searchUI');
            if (event.getSource().get("v.value")) {
                component.set('v.hdnRemoveContextEnabled', 'true');
                var searchEventCause = { name: 'casecontextRemove', type: 'casecontext' };
                coveoSearchUI.logSearchEvent(searchEventCause);
                coveoSearchUI.executeQuery();
            }
            else {
                component.set('v.hdnRemoveContextEnabled', 'false');
                var searchEventCause = { name: 'casecontextAdd', type: 'casecontext' };
                coveoSearchUI.logSearchEvent(searchEventCause);              
                coveoSearchUI.executeQuery();
            }
                      
            // console.log('selectChange');
                                  
        } catch (error) {
            console.error('error' + 'Method : selectChange; Error :' + error.message + " : " + error.stack);
        }
    }
        
});