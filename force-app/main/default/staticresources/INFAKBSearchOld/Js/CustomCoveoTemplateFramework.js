/**************************************************************************
JS file Name: InfaKBSearchTemplateUtility.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 24-April-2021
Purpose: Holds all the function required  for Coveo Search Template Customization.
Version: 1.0

Modificaiton History

Date       |  Modified by    |  Jira reference      |       ChangesMade                               |     Tag
        
***************************************************************************/


(function (w) {

   
    jQuery.support.cors = true;


    function fnGetFieldAndValueFromString(parFieldString) {
        var varmatchresult = [];
        var valocalresult = [];
        try {
            var varCustomreg = new RegExp('data-custom-coveo-condition-field-(?:equal-|not-equal-)(?:(raw)\\-|)?([a-z0-9_]+)="([a-z0-9_,]+)"', 'gi');
            while ((valocalresult = varCustomreg.exec(parFieldString)) !== null) {
                varmatchresult.push(valocalresult);
            };
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnDefaultGetBadge; Error : ' + ex.message + '||' + ex.stack);
        }
        return varmatchresult;
    }

    function fnGetFieldNameFromString(parFieldString) {
        var varmatchresult = [];
        var valocalresult = [];
        try {
            var varCustomreg = new RegExp('(\\[\\[=(?:(raw)\\.|)([a-z0-9_]+)]])', 'gi');
            while ((valocalresult = varCustomreg.exec(parFieldString)) !== null) {
                varmatchresult.push(valocalresult);
            };
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnGetFieldNameFromString; Error : ' + ex.message + '||' + ex.stack);
        }
        return varmatchresult;
    }

    function fnSetFieldValueInString(parMatchingFieldAndValues, parLocalResult, parLocalCurrentItem) {
        try {
            for (var i = 0; i < parMatchingFieldAndValues.length; ++i) {
                if (parMatchingFieldAndValues[i].input.indexOf('fnCustomCoveoEvaluvateTheHtmlTag') != -1) {
                    var varMetaDataContent = parLocalResult.result.raw;
                    if ((parMatchingFieldAndValues[i][2] != undefined) && (parMatchingFieldAndValues[i][2].toString().trim().toLowerCase() == 'raw')) {
                        varMetaDataContent = parLocalResult.result.raw;
                    }
                    else {
                        varMetaDataContent = parLocalResult.result;
                    }
                
                    if (varMetaDataContent[parMatchingFieldAndValues[i][3]] != undefined) {
                        // var varOuterHTML = parLocalCurrentItem.outerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                        // parLocalCurrentItem.outerHTML = varOuterHTML;
                        // if (parLocalCurrentItem.outerHTML.indexOf(parMatchingFieldAndValues[i][1]) != -1) {
                        //     var varOuterHTML = parLocalCurrentItem.outerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                        //     parLocalCurrentItem.OuterHTML = varOuterHTML;
                        // }

                        if (parLocalCurrentItem.innerHTML.indexOf(parMatchingFieldAndValues[i][1]) != -1) {
                            var varInnerHTML = parLocalCurrentItem.innerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                            parLocalCurrentItem.innerHTML = varInnerHTML;
                        }
                        else {
                            var varAttributeName = fnGetAttributeNameWhichHasFieldNameAsValue(parMatchingFieldAndValues[i][1], parLocalCurrentItem);
                            if (varAttributeName != '') {
                                var varAttributeValue = parLocalCurrentItem.getAttribute(varAttributeName).replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                                parLocalCurrentItem.setAttribute(varAttributeName, varAttributeValue);
                            }                            
                        }
                    }
                    else {
                        var varInnerHTML = parLocalCurrentItem.innerHTML.replace(parMatchingFieldAndValues[i][1], '');
                        parLocalCurrentItem.innerHTML = varInnerHTML;
                    }
                }
            }
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnSetFieldValueInString; Error : ' + ex.message + '||' + ex.stack);
        }
    }

    function fnSetFieldValueInStringForSpecificTag(parMatchingFieldAndValues, parLocalResult, parLocalCurrentItem) {
        try {
            for (var i = 0; i < parMatchingFieldAndValues.length; ++i) {
              
                var varMetaDataContent = parLocalResult.result.raw;
                if ((parMatchingFieldAndValues[i][2] != undefined) && (parMatchingFieldAndValues[i][2].toString().trim().toLowerCase() == 'raw')) {
                    varMetaDataContent = parLocalResult.result.raw;
                }
                else {
                    varMetaDataContent = parLocalResult.result;
                }
                
                if (varMetaDataContent[parMatchingFieldAndValues[i][3]] != undefined) {
                    // var varOuterHTML = parLocalCurrentItem.outerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                    // parLocalCurrentItem.outerHTML = varOuterHTML;
                    // if (parLocalCurrentItem.outerHTML.indexOf(parMatchingFieldAndValues[i][1]) != -1) {
                    //     var varOuterHTML = parLocalCurrentItem.outerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                    //     parLocalCurrentItem.OuterHTML = varOuterHTML;
                    // }

                    if (parLocalCurrentItem.innerHTML.indexOf(parMatchingFieldAndValues[i][1]) != -1) {
                        var varInnerHTML = parLocalCurrentItem.innerHTML.replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                        parLocalCurrentItem.innerHTML = varInnerHTML;
                    }
                    else {
                        var varAttributeName = fnGetAttributeNameWhichHasFieldNameAsValue(parMatchingFieldAndValues[i][1], parLocalCurrentItem);
                        if (varAttributeName != '') {
                            var varAttributeValue = parLocalCurrentItem.getAttribute(varAttributeName).replace(parMatchingFieldAndValues[i][1], varMetaDataContent[parMatchingFieldAndValues[i][3]]);
                            parLocalCurrentItem.setAttribute(varAttributeName, varAttributeValue);
                        }
                    }
                }
                else {
                    var innerHTML = parLocalCurrentItem.innerHTML.replace(parMatchingFieldAndValues[i][1], '');
                    parLocalCurrentItem.innerHTML = innerHTML;
                }
                
            }
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnSetFieldValueInString; Error : ' + ex.message + '||' + ex.stack);
        }
    }

    function fnGetAttributeNameWhichHasFieldNameAsValue(parFieldNameCode, parLocalCurrentItem) {
        try {
            if (parLocalCurrentItem.hasAttributes()) {
                var attrs = parLocalCurrentItem.attributes
                for (var i = attrs.length - 1; i >= 0; i--) {
                    if (attrs[i].value.indexOf(parFieldNameCode) != -1) {
                        return attrs[i].name;
                    }
                }
            }
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnGetAttributeNameWhichHasFieldNameAsValue; Error : ' + ex.message + '||' + ex.stack);
        }
        return '';
    }

    function fnEvaluvateCustomCondition(parMatchingFieldAndValues, parLocalResult) {
        var varReturnResult = false;
        try {
            for (var i = 0; i < parMatchingFieldAndValues.length; ++i) {
                if (parMatchingFieldAndValues[i][0].indexOf('data-custom-coveo-condition-field-equal-') != -1) {
                    varReturnResult = fnEvaluvateEqualToCondition(parMatchingFieldAndValues[i], parLocalResult)
                    if (varReturnResult == false) {
                        return varReturnResult;
                    }
                }
                else if (parMatchingFieldAndValues[i][0].indexOf('data-custom-coveo-condition-field-not-equal-') != -1) {
                    varReturnResult = fnEvaluvateNotEqualToCondition(parMatchingFieldAndValues[i], parLocalResult)
                    if (varReturnResult == false) {
                        return varReturnResult;
                    }
                }
            }
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnDefaultGetBadge; Error : ' + ex.message + '||' + ex.stack);
        }
        return varReturnResult;
    }

    function fnEvaluvateEqualToCondition(parrMatchingFieldAndValue, parLclResult) {
        var varReturnResultForEqual = false;
        try {
            var varLclResult = parLclResult;
            var varFieldValue = parrMatchingFieldAndValue[3];
            var varFieldName = parrMatchingFieldAndValue[2];
            var varRawField = parrMatchingFieldAndValue[1];
            var varFieldValueSplitted = varFieldValue.split(',');
            var varConditionTypeKeyword = 'equal-to';
            var varMetaDataContent = varLclResult.result.raw;

            if (varRawField != undefined && varRawField.toString().trim().toLowerCase() == 'raw') {
                varMetaDataContent = varLclResult.result.raw;
            }
            else {
                varMetaDataContent = varLclResult.result;
            }
                
            for (var i = 0; i < varFieldValueSplitted.length; ++i) {
                            
                if (typeof (varMetaDataContent[varFieldName]) == 'undefined') {
                    varReturnResultForNotEqual = false
                    return varReturnResultForNotEqual;
                            
                }
                else if ((typeof (varMetaDataContent[varFieldName]) == 'object') && (Array.isArray(varMetaDataContent[varFieldName]) == true)) {
                            
                    for (var j = 0; j < varMetaDataContent[varFieldName].length; ++j) {
                        varReturnResultForEqual = fnCheckFieldValueWithCondition(varMetaDataContent[varFieldName][j], varFieldValueSplitted[i], varConditionTypeKeyword);
                        if (varReturnResultForEqual == true) {
                            return varReturnResultForEqual;
                        }
                    }
                }
                else if ((typeof (varMetaDataContent[varFieldName]) == 'string') && (varMetaDataContent[varFieldName].indexOf(';') != -1)) {
                    var varFieldMultiValueSplitted = varMetaDataContent[varFieldName].split(';');
                    for (var j = 0; j < varFieldMultiValueSplitted.length; ++j) {
                        varReturnResultForEqual = fnCheckFieldValueWithCondition(varFieldMultiValueSplitted[j], varFieldValueSplitted[i], varConditionTypeKeyword);
                        if (varReturnResultForEqual == true) {
                            return varReturnResultForEqual;
                        }
                    }
                }
                else {
                    varReturnResultForEqual = fnCheckFieldValueWithCondition(varMetaDataContent[varFieldName], varFieldValueSplitted[i], varConditionTypeKeyword);
                    if (varReturnResultForEqual == true) {
                        return varReturnResultForEqual;
                    }
                }
            }
                
                              
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnDefaultGetBadge; Error : ' + ex.message + '||' + ex.stack);
        }
        return varReturnResultForEqual;
    }

    function fnEvaluvateNotEqualToCondition(parrMatchingFieldAndValue, parLclResult) {
        var varReturnResultForNotEqual = true;
        try {
            var varLclResult = parLclResult;
            var varFieldValue = parrMatchingFieldAndValue[3];
            var varFieldName = parrMatchingFieldAndValue[2];
            var varRawField = parrMatchingFieldAndValue[1];
            var varFieldValueSplitted = varFieldValue.split(',');
            var varConditionTypeKeyword = 'not-equal-to';

            var varMetaDataContent = varLclResult.result.raw;

            if (varRawField != undefined && varRawField.toString().trim().toLowerCase() == 'raw') {
                varMetaDataContent = varLclResult.result.raw;
            }
            else {
                varMetaDataContent = varLclResult.result;
            }
                
                
            for (var i = 0; i < varFieldValueSplitted.length; ++i) {

                if (typeof (varMetaDataContent[varFieldName]) == 'undefined') {
                    varReturnResultForNotEqual = false
                    return varReturnResultForNotEqual;
                            
                }
                else if ((typeof (varMetaDataContent[varFieldName]) == 'object') && (Array.isArray(varMetaDataContent[varFieldName]) == true)) {
                    for (var j = 0; j < varMetaDataContent[varFieldName].length; ++j) {
                                      
                        if (typeof (varMetaDataContent[varFieldName][j]) == 'undefined') {
                            varReturnResultForNotEqual = false
                        }
                        else {
                            varReturnResultForNotEqual = fnCheckFieldValueWithCondition(varMetaDataContent[varFieldName][j], varFieldValueSplitted[i], varConditionTypeKeyword);
                            
                            if (varReturnResultForNotEqual == false) {
                                return varReturnResultForNotEqual;
                            }
                        }
                                                                      
                    }
                }
                else if ((typeof (varMetaDataContent[varFieldName]) == 'string') && (varMetaDataContent[varFieldName].indexOf(';') != -1)) {
                    var varFieldMultiValueSplitted = varMetaDataContent[varFieldName].split(';');
                    for (var j = 0; j < varFieldMultiValueSplitted.length; ++j) {

                        varReturnResultForNotEqual = fnCheckFieldValueWithCondition(varFieldMultiValueSplitted[j], varFieldValueSplitted[i], varConditionTypeKeyword);
                            
                        if (varReturnResultForNotEqual == false) {
                            return varReturnResultForNotEqual;
                        }

                    }
                }
                else {
                            
                    varReturnResultForNotEqual = fnCheckFieldValueWithCondition(varMetaDataContent[varFieldName], varFieldValueSplitted[i], varConditionTypeKeyword);
                            
                    if (varReturnResultForNotEqual == false) {
                        return varReturnResultForNotEqual;
                    }
                }
            }
                                                                     
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnDefaultGetBadge; Error : ' + ex.message + '||' + ex.stack);
        }
        return varReturnResultForNotEqual;
    }

    function fnCheckFieldValueWithCondition(parFieldValue, parConditiontFieldValue, parConditiontype) {
        var varReturnValue = false;
        try {
            if (parConditiontype == 'not-equal-to') {
                varReturnValue = false;
                if ((parConditiontFieldValue.toString().trim().toLowerCase() == 'blank') && (parFieldValue.toString().trim().toLowerCase() != '')) {
                    varReturnValue = true;
                          
                }
                else if (parFieldValue.toString().trim().toLowerCase() != parConditiontFieldValue.toString().trim().toLowerCase()) {
                    varReturnValue = true;
                }
                else {
                    varReturnValue = false;
                }
                      
            }
            else if (parConditiontype == 'equal-to') {
                varReturnValue = true;
                if ((parConditiontFieldValue.toString().trim().toLowerCase() == 'blank') && (parFieldValue.toString().trim().toLowerCase() == '')) {
                    varReturnValue = true;
                          
                }
                else if (parFieldValue.toString().trim().toLowerCase() == parConditiontFieldValue.toString().trim().toLowerCase()) {
                    varReturnValue = true;
                }
                else {
                    varReturnValue = false;
                }
            }
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCheckFieldValueWithCondition; Error : ' + ex.message + '||' + ex.stack);
        }
        return varReturnValue;
    }

    function fnLoadKBInternalSearchTemplate() {
          
        try {
                

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnLoadKBInternalSearchTemplate; Error : ' + ex.message + '||' + ex.stack);
        }
    }

    //Specific Function - Start//

    function fnCustomCoveoEvaluvateRecommendationGetHtml(parResult, parCurrentItem) {
        var varResult = false;
        try {
               
            // var varCustomCondition = parCurrentItem.getAttribute('data-custom-coveo-condition-field-not-athenatabname');

            if (parResult.result.isRecommendation == true) {
                varResult = true;
            }
                
            if (varResult == true) {
                parCurrentItem.setAttribute('style', parCurrentItem.getAttribute('style').toString().replace('display:none', '').replace('display: none', ''));
            }

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateRecommendationGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }

    function fnCustomCoveoEvaluvateShowMoreGetHtml(parResult, parCurrentItem) {
        var varResult = false;
        try {
               
            // var varCustomCondition = parCurrentItem.getAttribute('data-custom-coveo-condition-field-not-athenatabname');

            if ((parResult.result.raw['athenatemplate'] != undefined) && ((parResult.result.raw['athenatemplate'].toString() == 'Solution') || (parResult.result.raw['athenatemplate'].toString() == 'FAQ') || (parResult.result.raw['athenatemplate'].toString() == 'How To'))) {
                varResult = true;
            }
                
            if (varResult == false) {
                parCurrentItem.outerHTML = '';
            }

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateShowMoreGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }

    function fnCustomCoveoEvaluvateDocPortalAnchorLinkGetHtml(parResult, parCurrentItem) {
        try {
            var varInnerHTML = '';
            if ((typeof (parResult.result.raw.athenaproduct) === 'undefined') &&
                (typeof (parResult.result.raw.athenaproductversion) === 'undefined') &&
                (typeof (parResult.result.raw.hotfix) === 'undefined')) {
                varInnerHTML += parResult.result.raw.title
            } else {

                if (typeof (parResult.result.raw.athenaproduct) === 'undefined') {

                } else {
                    varInnerHTML += '<span class="in-athenaproduct">' + parResult.result.raw.athenaproduct + '</span>'
                }

                if (typeof (parResult.result.raw.athenaproductversion) === 'undefined') {

                } else {
                    varInnerHTML += '<span> > ' + parResult.result.raw.athenaproductversion + '</span>'
                }

                if (typeof (parResult.result.raw.hotfix) === 'undefined') {

                } else {
                    varInnerHTML += '<span> > ' + parResult.result.raw.hotfix + '</span>';
                }


            }

            parCurrentItem.innerHTML = varInnerHTML;

            fnCustomCoveoEvaluvateSpecificTagFieldNameSetFieldValue(parResult, parCurrentItem);
            
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateDocPortalAnchorLinkGetHtml; Error : ' + ex.message + '||' + ex.stack);
            parCurrentItem.innerHTML = '';
        }
         
    }

    function fnCustomCoveoEvaluvateJiveCoveoIconGetHtml(parResult, parCurrentItem) {
        try {
            var varClassName = parCurrentItem.getAttribute('class');

            var question = '';
            var discussionCssClass = '';
            var iconCssClass = '';
    
            if ((typeof (parResult.result.raw.jivequestion) != 'undefined'))
            {
                question = parResult.result.raw.jivequestion ? parResult.result.raw.jivequestion.toLowerCase() : '';
            }

            if ((typeof (parResult.result.raw.jivequestion) != 'undefined'))
            {
                discussionCssClass = parResult.result.raw.syscsitemtype == 'Discussion' ? 'discussion' : '';
                discussionCssClass = (question === 'true' && parResult.result.raw.jiveanswer ? 'answered' : (question === 'true' && !parResult.result.raw.jiveanswer ? 'question' : discussionCssClass));
            }
            if ((typeof (parResult.result.raw.inisanswered) != 'undefined'))
            {
                //discussionCssClass = parResult.result.raw.sftype == 'QuestionPost' ? 'discussion' : '';
                discussionCssClass = parResult.result.raw.inisanswered === 'True' ? 'answered' : discussionCssClass;
            }
            if ((typeof (parResult.result.raw.incontenttype) != 'undefined') && parResult.result.raw.incontenttype == 'Poll')
            {
                discussionCssClass =  'cspoll';
            }
            if ((typeof (parResult.result.raw.jivequestion) != 'undefined')) {

                // iconCssClass = raw.syscsitemtype === 'Announcement' ? 'fa-bullhorn' : iconCssClass;
                // iconCssClass = raw.syscsitemtype === 'Discussion' ? (question === 'true' ? 'fa-question-circle' : 'fa-comments-o') : iconCssClass;
                // iconCssClass = raw.syscsitemtype === 'Message' ? 'fa-commenting' : iconCssClass;
                // iconCssClass = raw.syscsitemtype === 'Comment' ? 'fa-comment-o' : iconCssClass;
                // iconCssClass = raw.syscsitemtype === 'Idea' ? 'fa-lightbulb-o' : iconCssClass;
                // iconCssClass = raw.syscsitemtype === 'Document' ? 'fa-file-o' : iconCssClass;
                iconCssClass =  parResult.result.raw.syscsitemtype === 'Social Group' ? 'fa-users' : iconCssClass;
                iconCssClass =  parResult.result.raw.syscsitemtype === 'Community' ? 'fa-users' : iconCssClass;
                iconCssClass =  parResult.result.raw.syscsitemtype === 'User' ? 'fa-user' : iconCssClass;

            }

            if (iconCssClass != '') {
                varClassName += ' coveo-jive-icon fa ' + iconCssClass ;
            }
            else {
                varClassName += ' ' + discussionCssClass;
            }

            if (varClassName != '') {
                parCurrentItem.setAttribute('class', varClassName);
            }
            
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateJiveCoveoIconGetHtml; Error : ' + ex.message + '||' + ex.stack);            
        }
         
    }

    function fnCustomCoveoEvaluvateJiveChildCoveoIconGetHtml(parResult, parCurrentItem) {
        try {
         
            var answer = '';
            var helpful = '';
            
            if ((typeof (parResult.result.childResults[0]) != 'undefined') && (typeof (parResult.result.childResults[0].raw.jiveanswer) != 'undefined'))
            {
                answer = parResult.result.childResults[0].raw.jiveanswer.toLowerCase();               
            }

            if ((typeof (parResult.result.childResults[0]) != 'undefined') && (typeof (parResult.result.childResults[0].raw.jivehelpful) != 'undefined'))
            {
                helpful = parResult.result.childResults[0].raw.jivehelpful.toLowerCase();               
            }

            if (answer === 'true') { 
                parCurrentItem.setAttribute('class', 'jive-badge jive-status jive-status-green');
                parCurrentItem.innerHTML = 'Correct Answer';
                parCurrentItem.style.display = 'block';
            }

            if (helpful === 'true') { 
                parCurrentItem.setAttribute('class', 'jive-badge jive-status');
                parCurrentItem.innerHTML = 'Helpful';
                parCurrentItem.style.display = 'block';
            }

           

            
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateJiveChildCoveoIconGetHtml; Error : ' + ex.message + '||' + ex.stack);            
        }
         
    }
    

    function fnCustomCoveoEvaluvateOnChildResultNotPresentGetHtml(parResult, parCurrentItem) {
        try {
            if (parResult.result.childResults.length == 0)
                parCurrentItem.setAttribute('style', parCurrentItem.getAttribute('style').toString().replace('display:none', '').replace('display: none', ''));
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateOnChildResultNotPresentGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
    }

    function fnCustomCoveoEvaluvateOnChildResultPresentGetHtml(parResult, parCurrentItem) {
        try {
            if (parResult.result.childResults.length != 0)
                parCurrentItem.setAttribute('style', parCurrentItem.getAttribute('style').toString().replace('display:none', '').replace('display: none', ''));
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateOnChildResultPresentGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
    }

    function fnCustomCoveoEvaluvateNoResultGetHtml(parResult) {
        try {
            var varInnerHTML = '';
            if (typeof (parResult.result.state.q) === 'undefined') {
                varInnerHTML += '';
            } else {
                varInnerHTML += parResult.result.state.q;
            }

            parResult.item.innerHTML = varInnerHTML;
                        
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateNoResultGetHtml; Error : ' + ex.message + '||' + ex.stack);
            parResult.item.innerHTML = 'No Result';
        }
         
    }

    function fnCustomCoveoEvaluvateIndexGetHtml(parResult, parCurrentItem) {
        try {
            parCurrentItem.setAttribute('data-result-position', parResult.result.index + 1);
            
        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateIndexGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }
    
    //Specific Function - End//

    //Common Function
    function fnCustomCoveoEvaluvateFieldNameSetFieldValue(parResult, parCurrentItem) {
        try {
               
            var varMatchingFieldAndValue = fnGetFieldNameFromString(parCurrentItem.outerHTML);
            fnSetFieldValueInString(varMatchingFieldAndValue, parResult, parCurrentItem);

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateFieldNameSetFieldValue; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }

     //Common Function
     function fnCustomCoveoEvaluvateSpecificTagFieldNameSetFieldValue(parResult, parCurrentItem) {
        try {
               
            var varMatchingFieldAndValue = fnGetFieldNameFromString(parCurrentItem.outerHTML);
            fnSetFieldValueInStringForSpecificTag(varMatchingFieldAndValue, parResult, parCurrentItem);

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateSpecificTagFieldNameSetFieldValue; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }


    function fnCustomCoveoEvaluvateConditionGetHtml(parResult, parCurrentItem) {
        var varSelfDisplayType = 'self-display';
        var varSelfReplaceType = 'self-replace';
        try {
               
            var varMatchingFieldAndValue = fnGetFieldAndValueFromString(parCurrentItem.outerHTML);
            var varResult = fnEvaluvateCustomCondition(varMatchingFieldAndValue, parResult);
                
                
            var varDisplayType = parCurrentItem.getAttribute('data-custom-coveo-function-type');
            if (varDisplayType == varSelfDisplayType) {
                if (varResult == true) {
                    parCurrentItem.setAttribute('style', parCurrentItem.getAttribute('style').toString().replace('display:none', '').replace('display: none', ''));
                }
                else {
                    parCurrentItem.outerHTML = '';
                }
            }
            else if (varDisplayType == varSelfReplaceType) {
                if (varResult == true) {
                    parCurrentItem.outerHTML = parCurrentItem.innerHTML;
                } else {
                    parCurrentItem.outerHTML = '';
                }
            }
            // else {
            //     if (varResult == true) {
            //         parCurrentItem.setAttribute('style', parCurrentItem.getAttribute('style').toString().replace('display:none', '').replace('display: none', ''));
            //     }
            //     else {
            //         parCurrentItem.outerHTML = '';
            //     }
            // }
                
               

        } catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateConditionGetHtml; Error : ' + ex.message + '||' + ex.stack);
        }
         
    }

    function fnCustomCoveoEvaluvateTheHtmlTag(parResult, parCurrentItem) {
        try {
        
            fnCustomCoveoEvaluvateConditionGetHtml(parResult, parCurrentItem);
            fnCustomCoveoEvaluvateFieldNameSetFieldValue(parResult, parCurrentItem);
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoEvaluvateTheHtmlTag; Error : ' + ex.message + '||' + ex.stack);
        }
    }
    function fnCustomCoveoSetAnsweredText(parResult, parCurrentItem) {
        try {
            return '<span style="color:#999;">This question has been <span class="text-success">Answered</span></span>';
        }
        catch (ex) {
            InfaKBCommonUtilityJs.Log('error','Method : fnCustomCoveoSetAnsweredText : Error : ' + ex.message + '||' + ex.stack);
        }
    }
    //Common Function

    function fnBuildHtmlBasedOnMetaData(parResult) {
        try {
            if (Coveo.$(parResult.item).find('[data-custom-coveo-function]').length != 0) {
                var varCustomCoveoFunctionToCall = Coveo.$(parResult.item).find('[data-custom-coveo-function]');
                for (var i = 0; i < varCustomCoveoFunctionToCall.length; i++) {
                    var varFunctionName = varCustomCoveoFunctionToCall[i].getAttribute('data-custom-coveo-function');
                    CustomCoveoTemplateFrameworkJs[varFunctionName](parResult, varCustomCoveoFunctionToCall[i]);
                }
            }
        }
        catch (e) {
            console.error('Error Occured in Method fnBuildHtmlBasedOnMetaData : ' + e.message);
        }
    }

    function fnBuildChildHtmlBasedOnMetaData(parResult) {
        try {
            if (Coveo.$(parResult.item).find('[data-custom-coveo-child-function]').length != 0) {
                var varCustomCoveoFunctionToCall = Coveo.$(parResult.item).find('[data-custom-coveo-child-function]');
                for (var i = 0; i < varCustomCoveoFunctionToCall.length; i++) {
                    var varFunctionName = varCustomCoveoFunctionToCall[i].getAttribute('data-custom-coveo-child-function');
                    CustomCoveoTemplateFrameworkJs[varFunctionName](parResult, varCustomCoveoFunctionToCall[i]);
                }
            }
        }
        catch (e) {
            console.error('Error Occured in Method fnBuildChildHtmlBasedOnMetaData : ' + e.message);
        }
    }

    /** */

    var CustomCoveoTemplateFrameworkJs = {
        'fnCustomCoveoEvaluvateTheHtmlTag': fnCustomCoveoEvaluvateTheHtmlTag,
        'fnCustomCoveoEvaluvateRecommendationGetHtml': fnCustomCoveoEvaluvateRecommendationGetHtml,
        'fnCustomCoveoEvaluvateShowMoreGetHtml': fnCustomCoveoEvaluvateShowMoreGetHtml,
        'fnCustomCoveoEvaluvateDocPortalAnchorLinkGetHtml': fnCustomCoveoEvaluvateDocPortalAnchorLinkGetHtml,
        'fnCustomCoveoEvaluvateJiveCoveoIconGetHtml': fnCustomCoveoEvaluvateJiveCoveoIconGetHtml,
        'fnCustomCoveoEvaluvateJiveChildCoveoIconGetHtml': fnCustomCoveoEvaluvateJiveChildCoveoIconGetHtml,  
        'fnCustomCoveoEvaluvateOnChildResultPresentGetHtml': fnCustomCoveoEvaluvateOnChildResultPresentGetHtml,
        'fnCustomCoveoEvaluvateOnChildResultNotPresentGetHtml': fnCustomCoveoEvaluvateOnChildResultNotPresentGetHtml,
        'fnCustomCoveoEvaluvateNoResultGetHtml': fnCustomCoveoEvaluvateNoResultGetHtml,
        'fnBuildHtmlBasedOnMetaData': fnBuildHtmlBasedOnMetaData,
        'fnBuildChildHtmlBasedOnMetaData': fnBuildChildHtmlBasedOnMetaData,
        'fnCustomCoveoEvaluvateIndexGetHtml':fnCustomCoveoEvaluvateIndexGetHtml
    };
    
    //fnLoadKBInternalSearchTemplate();

    w.CustomCoveoTemplateFrameworkJs = CustomCoveoTemplateFrameworkJs;

})(window);