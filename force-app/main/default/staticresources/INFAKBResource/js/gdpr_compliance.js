/**************************************************************************
JS file Name: gdpr_compliance.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 09-July-2018
Purpose: Holds all the function required across the application for GDPR Compliance.
Version: NA
***************************************************************************/

(function (w) {
    

    /** 
    Global variable used across the application
  
  **/
    
    /** 
    **/
    
    //        var varToShowComplianceWizard = false;
    var varToShowComplianceWizardOnLoad = false;
    var varCopyEventHappened = false;
    var varComplianceAllMatchResult = [];

    //call to  set digitaldata varialbe not to tracked
    function fnCheckContentForEmail(parContent) {
        var varmatchresult = null;
        try {

            varmatchresult = parContent.match(/[^\s]+@[.,a-z,A-Z][^\s]+/igm);
            if (varmatchresult != null) {
                for (var i = 0; i < varmatchresult.length; ++i) {
                    varmatchresult[i] = varmatchresult[i].toLowerCase().trim();
                    varmatchresult[i] = fnTrimZeroSpaceContent(varmatchresult[i]);
                }
            }
            return varmatchresult;

        } catch (ex) {
            console.log("Method : fnCheckContentForEmail; Error :" + ex.description);
        }

        return varmatchresult;

    }

    //call to  set digitaldata varialbe not to tracked
    function fnCheckContentForIpAddress(parContent) {
        var varmatchresult = null;
        try {

            varmatchresult = parContent.match(/\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/igm);
            if (varmatchresult != null) {
                for (var i = 0; i < varmatchresult.length; ++i) {
                    varmatchresult[i] = varmatchresult[i].toLowerCase().trim();
                    varmatchresult[i] = fnTrimZeroSpaceContent(varmatchresult[i]);
                }
            }
            return varmatchresult;

        } catch (ex) {
            console.log("Method : fnCheckContentForIpAddress; Error :" + ex.description);
        }

        return varmatchresult;

    }

    function fnCheckContentForDomain(parContent) {
        var varmatchresult = null;
        try {

            //var varmatchresult = parContent.match(/(?!:\/\/)([a-zA-Z0-9-_]+\.)*[a-zA-Z0-9][a-zA-Z0-9-_]+\.[a-zA-Z]{2,11}?$/igm);
            //var varmatchresult = parContent.match(/([a-z0-9]+\.)*[a-z0-9]+\.[a-z]+/igm);
            //varmatchresult = parContent.match(/^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/igm);
            //varmatchresult = parContent.match(/\b([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}\b/igm);
            varmatchresult = parContent.match(/(([a-zA-Z]{1})|([a-zA-Z]{1}[a-zA-Z]{1})|([a-zA-Z]{1}[0-9]{1})|([0-9]{1}[a-zA-Z]{1})|([a-zA-Z0-9][-_\.a-zA-Z0-9]{1,61}[a-zA-Z0-9]))\.([a-zA-Z]{2,13}|[a-zA-Z0-9-]{2,30}\.[a-zA-Z]{2,3})$/igm);
            if (varmatchresult != null) {
                for (var i = 0; i < varmatchresult.length; ++i) {
                    varmatchresult[i] = varmatchresult[i].toLowerCase().trim();
                    varmatchresult[i] = fnTrimZeroSpaceContent(varmatchresult[i]);
                }
            }
            return varmatchresult;

        } catch (ex) {
            console.log("Method : fnCheckContentForDomain; Error :" + ex.description);
        }
        return varmatchresult;
    }

    function fnCheckContentForURL(parContent) {
        var varmatchresult = null;
        try {
            varmatchresult = parContent.match(/(((http|ftp|https):\/{2})+(([0-9a-z_-]+\.)+(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mn|mo|mp|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|nom|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ra|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw|arpa)(:[0-9]+)?((\/([~0-9a-zA-Z\#\+\%@\.\/_-]+))?(\?[0-9a-zA-Z\+\%@\/&\[\];=_-]+)?)?))\b/igm);
            if (varmatchresult != null) {
                for (var i = 0; i < varmatchresult.length; ++i) {
                    varmatchresult[i] = varmatchresult[i].toLowerCase().trim();
                    varmatchresult[i] = fnTrimZeroSpaceContent(varmatchresult[i]);
                }
            }
            return varmatchresult;

        } catch (ex) {
            console.log("Method : fnCheckContentForURL; Error :" + ex.description);
        }
        return varmatchresult;
    }



    function fnCheckContentForPhoneNumber(parContent) {
        var varmatchresult = null;
        try {
            varmatchresult = parContent.match(/[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}/igm);
            if (varmatchresult != null) {
                for (var i = 0; i < varmatchresult.length; ++i) {
                    varmatchresult[i] = varmatchresult[i].toLowerCase().trim();
                    varmatchresult[i] = fnTrimZeroSpaceContent(varmatchresult[i]);
                }
            }
            return varmatchresult;

        } catch (ex) {
            console.log("Method : fnCheckContentForPhoneNumber; Error :" + ex.description);
        }
        return varmatchresult;
    }




    //GDPR Compliance Function - Start//




    /// <summary>
    ///  Get KB Field Value
    /// </summary>
    /// <param name="parFieldControl">identifier for the field</param>
    /// <param name="parType">type of field control</param>
    function fnGetKBFieldvalueDisplayMode(parFieldControl, parType) {
        var varFieldValue = '';
        try {
            switch (parType.toLowerCase()) {
                case "div":
                    var vardivElement = $(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]');
                    if (vardivElement.length > 0) {

                        if (vardivElement[0].innerText != undefined) {
                            if (vardivElement[0].innerText.length > 0) {
                                varFieldValue = vardivElement[0].innerText.trim();
                                varFieldValue = fnTrimZeroSpaceContent(varFieldValue);
                            }
                        } else if (vardivElement.text().trim().length > 0) {
                            varFieldValue = vardivElement[0].innerText.trim();
                            varFieldValue = fnTrimZeroSpaceContent(varFieldValue);
                        } else {
                            console.log('Value not retrived as field value is not available : ' + parFieldControl);
                        }
                    } else {
                        console.log('Value not retrived as field value is not available : ' + parFieldControl);
                    }
                    break;
                case "td":
                    var vartdElement = $(parFieldControl);
                    if (vartdElement.length > 0) {
                        if (vartdElement[0].innerText != undefined) {
                            if (vartdElement[0].innerText.length > 0) {
                                varFieldValue = vartdElement[0].innerText.trim();
                                varFieldValue = fnTrimZeroSpaceContent(varFieldValue);
                            }
                        } else if (vartdElement.text().trim().length > 0) {
                            varFieldValue = vartdElement[0].innerText.trim();
                            varFieldValue = fnTrimZeroSpaceContent(varFieldValue);
                        } else {
                            console.log('Value not retrived as field value is not available : ' + parFieldControl);
                        }

                    } else {
                        console.log('Value not retrived as field value is not available : ' + parFieldControl);
                    }
                    break;
            }

        } catch (e) {
            console.log('Error Occured in Method fnGetKBFieldvalueDisplayMode : ' + e.message);
        }
        return varFieldValue;
    }


    function fnHighlightKBFieldvalueDisplayMode(parFieldControl, parType, parContent) {
        try {
            switch (parType.toLowerCase()) {
                case "div":
                    if ($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]').text().trim().length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {
                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedHighlight)) {
                            $($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedHighlight(parContent);

                            //document.getElementById($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]'))[0].id).scrollIntoView(true);
                        }
                    }
                    else {
                        console.log('Not highlighted as field value is not available : ' + parFieldControl);
                    }
                    break;

                case "td":
                    if ($(parFieldControl).length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {

                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($(parFieldControl).optimizedHighlight)) {
                            $(parFieldControl).optimizedHighlight(parContent);

                            // document.getElementById($(parFieldControl)[0].id).scrollIntoView(true);
                        }

                    }
                    else {
                        console.log('Not highlighted as field value is not available : ' + parFieldControl);
                    }
                    break;
            }

        } catch (e) {
            console.log('Error Occured in Method fnHighlightKBFieldvalueDisplayMode : ' + e.message);
        }
    }

    function fnRemoveHighlightKBFieldvalueDisplayMode(parFieldControl, parType) {
        try {
            switch (parType.toLowerCase()) {
                case "div":
                    if ($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]').text().trim().length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {
                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedRemoveHighlight)) {
                            $($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedRemoveHighlight();

                            //document.getElementById($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]'))[0].id).scrollIntoView(true);
                        }
                    }
                    else {
                        console.log('No optimizedHighlight removed as field value is not available : ' + parFieldControl);
                    }
                    break;

                case "td":
                    if ($(parFieldControl).length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {

                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($(parFieldControl).optimizedRemoveHighlight)) {
                            $(parFieldControl).optimizedRemoveHighlight();

                            // document.getElementById($(parFieldControl)[0].id).scrollIntoView(true);
                        }

                    }
                    else {
                        console.log('No optimizedHighlight removed as field value is not available : ' + parFieldControl);
                    }
                    break;
            }

        } catch (e) {
            console.log('Error Occured in Method fnRemoveHighlightKBFieldvalueDisplayMode : ' + e.message);
        }
    }


    function fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection(parFieldControl, parType) {
        try {
            switch (parType.toLowerCase()) {
                case "div":
                    if ($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]').text().trim().length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {
                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedRemoveHighlightRestoreWindowsSelection)) {
                            $($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]')).optimizedRemoveHighlightRestoreWindowsSelection();

                            //document.getElementById($($(parFieldControl).find('[id*=ControlWrapper_RichHtmlField]'))[0].id).scrollIntoView(true);
                        }
                    }
                    else {
                        console.log('No optimizedRemoveHighlightRestoreWindowsSelection removed as field value is not available : ' + parFieldControl);
                    }
                    break;

                case "td":
                    if ($(parFieldControl).length > 0 && $('#ctl00_MSO_ContentDiv').length > 0) {

                        //                    if ($.isFunction($('#ctl00_MSO_ContentDiv').removeHighlight))
                        //                        $('#ctl00_MSO_ContentDiv').removeHighlight();

                        if ($.isFunction($(parFieldControl).optimizedRemoveHighlightRestoreWindowsSelection)) {
                            $(parFieldControl).optimizedRemoveHighlightRestoreWindowsSelection();

                            // document.getElementById($(parFieldControl)[0].id).scrollIntoView(true);
                        }

                    }
                    else {
                        console.log('No optimizedRemoveHighlightRestoreWindowsSelection removed as field value is not available : ' + parFieldControl);
                    }
                    break;
            }

        } catch (e) {
            console.log('Error Occured in Method fnRemoveHighlightKBFieldvalueDisplayMode : ' + e.message);
        }
    }


    function fnAllSetComplianceDetailToCtrl(parControlIDs, parFieldControl, parType, parFieldName, parExclusionData) {

        try {
            var varFieldContent = '';


            varFieldContent = fnGetKBFieldvalueDisplayMode(parFieldControl, parType);

            //varFieldContent = fnReplaceForComplianceRegEx(varFieldContent);

            varFieldContent = fnReplaceForComplianceRegExOnEncoding(varFieldContent);

            if (varFieldContent.trim().length > 0) {

                fnSetcomplianceDetailToCtrl(varFieldContent, parControlIDs, parFieldName, parFieldControl, parType, parExclusionData);
            }

        } catch (e) {
            console.log('Error Occured in Method fnAllSetComplianceDetailToCtrl : ' + e.message);
        }
    }


    function fnComplianceWizardDecideToShow(parComplianceActionToolTipTextDiv, parcompliancewizardparentdiv) {
        try {
            var varToShowComplianceWizard = false;
            if ($('.' + parComplianceActionToolTipTextDiv).length == 0) {
                varToShowComplianceWizard = false;
            }
            else {
                varToShowComplianceWizard = true;
            }


            if (varToShowComplianceWizard) {
                document.getElementById(parcompliancewizardparentdiv).style.display = "block";

            } else {
                document.getElementById(parcompliancewizardparentdiv).style.display = "none";
            }
        }
        catch (e) {
            console.log('Error Occured in Method fnComplianceWizardDecideToShow : ' + e.message);
        }

    }

    function fnSwitchOnComplianceData(parCurrentElement) {
        try {
            //if condition for - on click to collapse the content
            var iconElement = $(parCurrentElement)[0];
            if ($(iconElement.parentNode).find('#chkbkComplianceHighlightSwitch').length > 0) {
                $('#chkbkComplianceHighlightSwitch')[0].checked = true;
                $(iconElement).attr('data-ishighlited', 'true');
                fnShowComplianceData();
                // $('.compliance-wizard-header').css('border-bottom', '0px solid #BCC3CA');
            }
        } catch (e) {
            console.log('Error Occured in Method fnSwitchOnComplianceData : ' + e.message);
        }
    }

    function fnToggleComplianceData(parCurrentElement) {
        try {
            //if condition for - on click to collapse the content
            var iconElement = $(parCurrentElement)[0];
            if ($(iconElement.parentNode).find('#chkbkComplianceHighlightSwitch').length > 0) {
                if ($('#chkbkComplianceHighlightSwitch')[0].checked == false) {
                    $(iconElement).attr('data-ishighlited', 'true');
                    fnShowComplianceData();
                    // $('.compliance-wizard-header').css('border-bottom', '0px solid #BCC3CA');
                }
                //if condition for - on click to expand the content
                else if ($('#chkbkComplianceHighlightSwitch')[0].checked == true) {
                    $(iconElement).attr('data-ishighlited', 'false');
                    if (varCopyEventHappened) {
                        fnRemoveAllHighlightFromFieldRestoreWindowsSelection();
                    } else {
                        fnRemoveAllHighlightFromField();
                    }
                    varCopyEventHappened = false;
                }
            }
        } catch (e) {
            console.log('Error Occured in Method fnToggleComplianceData : ' + e.message);
        }
    }

    function fnSetcomplianceDetailToCtrl(parFieldContent, parWizrdOrPopUpControlIDs, parFieldName, parFieldControl, parType, parExclusionData) {

        try {

            var varmatchresult = null;
            var varAllmatchresult = null;

            for (var i = 0; i < parWizrdOrPopUpControlIDs.length; i++) {

                switch (parWizrdOrPopUpControlIDs[i].Name) {
                    case "EMAIL":
                        varmatchresult = fnCheckContentForEmail(parFieldContent);
                        break;
                    case "IPADDRESS":
                        varmatchresult = fnCheckContentForIpAddress(parFieldContent);
                        break;
                    case "DOMAIN":
                        varmatchresult = fnCheckContentForDomain(parFieldContent);
                        break;
                    case "URL":
                        varmatchresult = fnCheckContentForURL(parFieldContent);
                        break;
                    case "PHONENO":
                        varmatchresult = fnCheckContentForPhoneNumber(parFieldContent);
                        break;
                    default:
                }

                if (varmatchresult != null) {
                    if (varmatchresult.length > 0) {
                        if (varAllmatchresult == null) {
                            varAllmatchresult = [];
                        }
                        Array.prototype.push.apply(varAllmatchresult, varmatchresult);
                    }
                }
            }

            if (varAllmatchresult != null) {
                if (varAllmatchresult.length > 0) {
                    //var varNoDuplicatesmatchresult = fnComplianceRemoveDuplicateMatch(varAllmatchresult,parFieldContent,parFieldControl);
                    var varNoDuplicatesmatchresult = varAllmatchresult;
                    varNoDuplicatesmatchresult = fnComplianceRemoveExclusionMatch(varAllmatchresult, parFieldContent, parFieldControl, parExclusionData);
                    if (varNoDuplicatesmatchresult.length > 0) {
                        varToShowComplianceWizard = true;
                        $(varNoDuplicatesmatchresult).each(function (index, item) {
                            fnHighlightKBFieldvalueDisplayMode(parFieldControl, parType, item.trim());
                        });
                    }
                }
            }

        } catch (e) {
            console.log('Error Occured in Method fnSetcomplianceDetailToCtrl : ' + e.message);
        }

    }

    function fnGetAllComplianceDetailsAsJSON(parFieldContent) {

        var objGDPRData = new Object();
        objGDPRData.Is_Violated = "0";
        objGDPRData.Email = "0";
        objGDPRData.IP = "0";
        objGDPRData.Domain = "0";
        objGDPRData.URL = "0";
        objGDPRData.Phone_Number = "0";
        
        try {

            var varmatchresult = null;
               
           
                    
            varmatchresult = fnCheckContentForEmail(parFieldContent);
            if (varmatchresult == null)
                objGDPRData.Email = "";
            else
            { objGDPRData.Email = varmatchresult;
                objGDPRData.Is_Violated = "1";
                }
               
         
            
         
            varmatchresult = fnCheckContentForIpAddress(parFieldContent);
            if (varmatchresult == null)
                objGDPRData.IP = "";
            else
                {
                objGDPRData.IP = varmatchresult;
                objGDPRData.Is_Violated = "1";
            }
          
                              
            varmatchresult = fnCheckContentForDomain(parFieldContent);
            if (varmatchresult == null)
                objGDPRData.Domain = "";
            else
                {
                objGDPRData.Domain = varmatchresult;
                objGDPRData.Is_Violated = "1";
            }
    
                     
       
            varmatchresult = fnCheckContentForURL(parFieldContent);
            if (varmatchresult == null)
                objGDPRData.URL = "";
            else {
                objGDPRData.URL = varmatchresult;
                objGDPRData.Is_Violated = "1";            
            }
         
                     
       
            varmatchresult = fnCheckContentForPhoneNumber(parFieldContent);
            if (varmatchresult == null)
                objGDPRData.Phone_Number = "";
            else
                {
                objGDPRData.Phone_Number = varmatchresult;
                objGDPRData.Is_Violated = "1";            
            }
       

           
                
        } catch (e) {
            console.log('Error Occured in Method fnGetAllComplianceDetailsAsJSON : ' + e.message);
        }
        return  JSON.stringify(objGDPRData);
    }

    function fnGetEncodedComplianceTermsFromKeyword(parFieldContent, parWizrdOrPopUpControlIDs) {

        var varAllMatchEncodedString = parFieldContent;

        try {
            var varFilteredMatchResult = [];
            var varAllmatchresult = null;
            var varmatchresult = null;

            for (var i = 0; i < parWizrdOrPopUpControlIDs.length; i++) {

                switch (parWizrdOrPopUpControlIDs[i].Name) {
                    case "EMAIL":
                        varmatchresult = fnCheckContentForEmail(parFieldContent);
                        break;
                    case "IPADDRESS":
                        varmatchresult = fnCheckContentForIpAddress(parFieldContent);
                        break;
                    case "DOMAIN":
                        varmatchresult = fnCheckContentForDomain(parFieldContent);
                        break;
                    case "URL":
                        varmatchresult = fnCheckContentForURL(parFieldContent);
                        break;
                    case "PHONENO":
                        varmatchresult = fnCheckContentForPhoneNumber(parFieldContent);
                        break;
                    default:
                }

                if (varmatchresult != null) {
                    if (varmatchresult.length > 0) {
                        if (varAllmatchresult == null) {
                            varAllmatchresult = [];
                        }
                        Array.prototype.push.apply(varAllmatchresult, varmatchresult);
                    }
                }
            }

            if (varAllmatchresult != null) {
                if (varAllmatchresult.length > 0) {
                    varFilteredMatchResult = fnComplianceRemoveDuplicateMatch(varAllmatchresult);
                }
            }

            for (var j = 0; j < varFilteredMatchResult.length; j++) {

                if (j == 0) {
                    varAllMatchEncodedString = encodeURIComponent(varFilteredMatchResult[j]);
                }
                else {
                    varAllMatchEncodedString += '{17D73B06-C09A-44BB-A14B-93A90D8733BA}' + encodeURIComponent(varFilteredMatchResult[j]);
                }
            }

            if (varFilteredMatchResult.length == 0) {
                varAllMatchEncodedString = encodeURIComponent(varAllMatchEncodedString);
            }

            return varAllMatchEncodedString;

        }
        catch
        (e) {
            console.log('Error Occured in Method fnSetcomplianceDetailToCtrl : ' + e.message);
        }
        return varAllMatchEncodedString;
    }

    function fnComplianceRemoveExclusionMatch(parMatchResult, parFieldContent, parFieldControl, parExclusionData) {
        var parFilteredMatchResult = [];
        try {

            if (parMatchResult != null && $(parMatchResult).length > 0) {
                for (var i = 0; i < $(parMatchResult).length; ++i) {


                    if (parExclusionData == null) {
                        parExclusionData = [];
                    }
                    //parFilteredMatchResult.push(item.trim());
                    var varDataPresent = false;
                    //var varStartitem = parFieldContent.indexOf(item);
                    //var varEnditem = parFieldContent.indexOf(item);


                    for (var j = 0; j < $(parExclusionData).length; ++j) {
                        var varMatchResultHTMLData = fnGetComplianceHTMLData($(parMatchResult)[i]);
                        if ($(parExclusionData)[j] == $(parMatchResult)[i] || $(parExclusionData)[j] == varMatchResultHTMLData) {
                            varDataPresent = true;
                        }

                        /*var regex1 = RegExp($(parMatchResult)[i] + '*');
                        if (regex1.test($(parFilteredMatchResult)[j])) {
                        varDataPresent = true;
                        }*/

                    }

                    if (!varDataPresent) {
                        parFilteredMatchResult.push($(parMatchResult)[i]);
                    }

                }
            }
        } catch (e) {
            console.log('Error Occured in Method fnComplianceRemoveExclusionMatch : ' + e.message);
        }

        return parFilteredMatchResult;
    }


    function fnComplianceRemoveDuplicateMatch(parMatchResult) {
        var parFilteredMatchResult = [];
        try {

            if (parMatchResult != null && $(parMatchResult).length > 0) {
                for (var i = 0; i < $(parMatchResult).length; ++i) {


                    if (parFilteredMatchResult == null) {
                        parFilteredMatchResult = [];
                    }
                    //parFilteredMatchResult.push(item.trim());
                    var varDataPresent = false;
                    //var varStartitem = parFieldContent.indexOf(item);
                    //var varEnditem = parFieldContent.indexOf(item);


                    for (var j = 0; j < $(parFilteredMatchResult).length; ++j) {

                        if ($(parFilteredMatchResult)[j] == $(parMatchResult)[i]) {
                            varDataPresent = true;
                        }

                        //                    var regex1 = RegExp($(parMatchResult)[i] + '*');
                        //                    if (regex1.test($(parFilteredMatchResult)[j])) {
                        //                        varDataPresent = true;
                        //                    }

                    }

                    if (!varDataPresent) {
                        parFilteredMatchResult.push($(parMatchResult)[i]);
                    }

                }
            }
        } catch (e) {
            console.log('Error Occured in Method fnComplianceRemoveDuplicateMatch : ' + e.message);
        }

        return parFilteredMatchResult;
    }


    function fnDecideToShowComplianceWizard() {

        try {
            var varDisplayPopUp = false;

            varDisplayPopUp = true;


            return varDisplayPopUp;
        } catch (e) {
            console.log('Error Occured in Method funDecideToShowcompliancePopUp : ' + e.message);
        }
        return false;

    }






    function fnProcessContentForCompliance(parControlIDs, parExclusionData) {
        try {

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#KBTitleID', 'td', 'Title', parExclusionData);

            fnAllSetComplianceDetailToCtrl(parControlIDs, '.slds-grid slds-gutters_small full cols-1 forcePageBlockSectionRow', 'div', 'Problem Description', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_x0020_Cause', 'div', 'Cause', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_x0020_Solution', 'div', 'Solution', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_Content', 'div', 'Content', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_More_Information', 'div', 'More Information', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_References', 'div', 'Reference', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_Related_Docs', 'div', 'Related Documents', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_Attachments', 'div', 'Attachments', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#td_INFA_Keywords', 'td', 'Keywords', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_Internal_Notes', 'div', 'Internal Notes', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_ANSWERS_Mapped_Field_XML_Answers', 'div', 'Answer', parExclusionData);

            // fnAllSetComplianceDetailToCtrl(parControlIDs, '#tr3_td_INFA_Answers', 'div', 'Answer', parExclusionData);


        } catch (e) {
            console.log('Error Occured in Method fnProcessContentForCompliance : ' + e.message);
        }
    }

    function fnRemoveAllHighlightFromField() {

        try {

            fnRemoveHighlightKBFieldvalueDisplayMode('#KBTitleID', 'td');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_x0020_Problem_x0020_Description', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_x0020_Cause', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_x0020_Solution', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_Content', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_More_Information', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_References', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_Related_Docs', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_Attachments', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#td_INFA_Keywords', 'td', 'Keywords');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_Internal_Notes', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_ANSWERS_Mapped_Field_XML_Answers', 'div');

            fnRemoveHighlightKBFieldvalueDisplayMode('#tr3_td_INFA_Answers', 'div');


        } catch (e) {
            console.log('Error Occured in Method fnRemoveAllHighlightFromField : ' + e.message);
        }

    }


    function fnRemoveAllHighlightFromFieldRestoreWindowsSelection() {

        try {

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#KBTitleID', 'td');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_x0020_Problem_x0020_Description', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_x0020_Cause', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_x0020_Solution', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_Content', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_More_Information', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_References', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_Related_Docs', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_Attachments', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#td_INFA_Keywords', 'td', 'Keywords');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_Internal_Notes', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_ANSWERS_Mapped_Field_XML_Answers', 'div');

            fnRemoveHighlightKBFieldvalueDisplayModeRestoreWindowsSelection('#tr3_td_INFA_Answers', 'div');

        } catch (e) {
            console.log('Error Occured in Method fnRemoveAllHighlightFromField : ' + e.message);
        }

    }


    /* Character that affect regex replaced */
    function fnReplaceForComplianceRegEx(parFieldContent) {
        try {
            var eVal;
            eVal = parFieldContent;
            // eVal = eVal.replace(/\u200B/g, '');
            eVal.replace(/(\r\n\t|\n|\r\t)/gm, ' ');
            eVal.replace(/(\r\n\t|\n|\r\t)/gm, ' ');
            //        eVal = eVal.replace(/\~/g, ' ');
            //        eVal = eVal.replace(/\!/g, ' ');
            //        eVal = eVal.replace(/\@/g, ' ');
            //        eVal = eVal.replace(/\#/g, ' ');
            //        eVal = eVal.replace(/\$/g, ' ');
            //        eVal = eVal.replace(/\&/g, ' ');
            //        eVal = eVal.replace(/\*/g, ' ');
            //        eVal = eVal.replace(/\(/g, ' ');
            //        eVal = eVal.replace(/\)/g, ' ');
            //        eVal = eVal.replace(/\=/g, ' ');
            //        eVal = eVal.replace(/\+/g, ' ');
            //        eVal = eVal.replace(/\;/g, ' ');
            //        eVal = eVal.replace(/\:/g, ' ');
            //        eVal = eVal.replace(/\'/g, ' ');
            //        eVal = eVal.replace(/\,/g, ' ');
            //        eVal = eVal.replace(/\"/g, ' ');
            //        eVal = eVal.replace(/\//g, ' ');
            //        eVal = eVal.replace(/\?/g, ' ');
            //        eVal = eVal.replace(/\`/g, ' ');
            //        eVal = eVal.replace(/\>/g, ' ');
            //        eVal = eVal.replace(/\</g, ' ');        
            return eVal;

        } catch (err) {
            console.log('Error Occured in Method fnReplaceForComplianceRegEx : ' + e.message);
            return '';
        }
    }


    /* Character that affect regex replaced */
    function fnReplaceForComplianceRegExOnEncoding(parFieldContent) {
        try {
            var eVal = parFieldContent;
            var encodedCharac = encodeURIComponent(eVal);
            /*****************************************************/
            //var regexForReplaceAll = /%C2%A0|%E2%86%B/igm;

            //var regexForReplaceAll = /%0A|%09|%0D/igm;

            // encodedCharac = encodedCharac.replace(regexForReplaceAll, ' ');        
            /*****************************************************/

            var decodedChnarc = decodeURIComponent(encodedCharac);

            decodedChnarc = decodedChnarc.trim();

            return decodedChnarc;

        } catch (err) {
            console.log('Error Occured in Method fnReplaceForComplianceRegExOnEncoding : ' + e.message);
            return '';
        }
    }


    function fnTrimForComplianceRegExOnEncoding(parFieldContent) {
        try {
            var eVal = parFieldContent;
            var encodedCharac = encodeURIComponent(eVal);
            var regexForEnd = /%C2%A0$/igm;
            var regexForStart = /^%C2%A0/igm;

            encodedCharac = encodedCharac.replace(regexForStart, '');
            encodedCharac = encodedCharac.replace(regexForEnd, '');

            var decodedChnarc = decodeURIComponent(encodedCharac);

            decodedChnarc = decodedChnarc.trim();

            return decodedChnarc;
        } catch (e) {
            console.log('Error Occured in Method fnTrimForComplianceRegExOnEncoding : ' + e.message);
            return '';
        }
    }


    function fnToggleComplianceWizard(parCurrentElement) {
        try {

        } catch (e) {
            console.log('Error Occured in Method fnToggleComplianceWizard : ' + e.message);
        }
    }


    function fnTrimZeroSpaceContent(parContent) {
        var varContent = parContent;
        try {
            varContent = varContent.replace(/(^[\s\u200b]*|[\s\u200b]*$)/g, '');
        } catch (e) {

            console.log('Error Occured in Method fnTrimZeroSpaceContent : ' + e.message);
        }
        return varContent;
    }


    function fnComplianceHTMLEncode(value) {
        try {
            //create a in-memory div, set it's inner text(which jQuery automatically encodes)
            //then grab the encoded contents back out.  The div never exists on the page.
            return $('<div/>').text(value).html();

        } catch (e) {
            console.log('Error Occured in Method fncompliancehtmlEncode : ' + e.message);
        }
        return value;
    }

    function fnComplianceHTMLDecode(value) {
        try {
            return $('<div/>').html(value).text();

        } catch (e) {
            console.log('Error Occured in Method fncompliancehtmlDecode : ' + e.message);
        }
        return value;
    }

    function fnGetComplianceHTMLData(value) {
        try {
            return $('<div/>').text(value)[0].innerHTML;

        } catch (e) {
            console.log('Error Occured in Method fnGetComplianceHTMLData : ' + e.message);
        }
        return value;
    }

    function fnShowComplianceData() {
        try {
            if (varToShowComplianceWizardOnLoad) {

                var varControlIDs = [{ ID: 'ID', Name: 'URL' }, { ID: 'ID', Name: 'EMAIL' }, { ID: 'ID', Name: 'IPADDRESS' }, { ID: 'ID', Name: 'DOMAIN' }, { ID: 'ID', Name: 'PHONENO' }];

                var varExclusionData = fnGetMetaDataComplianceData(varControlIDs);

            }
        } catch (e) {
            console.log('Error Occured in Method fnShowComplianceData : ' + e.message);
        }
    }

    function fnGetMetaDataComplianceData(parControlIDs) {
        try {
            var varCurrentArticleID = $("[id*='hdnMetaDataCompDocID']").val();
            var varActionTaken = 'exclusion';
            var varAllComplianceData = [];

            $.ajax({
                url: '/_layouts/ArticleMetaDataCompliance/WebService/DataService.asmx/GetAllComplianceItemDetails',
                method: 'post',
                dataType: 'json',
                data: { strDocID: varCurrentArticleID, strActionTaken: varActionTaken },
                context: parControlIDs,
                success: function (data) {
                    try {
                        console.log('Compliance - fnGetMetaDataComplianceData Method - Response Status: ' + data.APIResponseStatus);
                        console.log('Compliance - fnGetMetaDataComplianceData Method - Error Message: ' + data.ErrorMessage);
                        if (data.APIResponseStatus == "OK") {

                            var varContent = jQuery.parseJSON(data.APIResponseData);
                            if (varContent != null && varContent != undefined && varContent != "null") {
                                $(varContent).each(function (index, topitem) {
                                    var varActContent = topitem.ComplianceItemDetails;
                                    if (varActContent != null && varActContent != undefined && varActContent != "null") {
                                        $(varActContent).each(function (index, item) {
                                            if (item.Keyword != null) {
                                                var varprocessedkeyword = decodeURIComponent(item.Keyword.toString().trim());
                                                varAllComplianceData.push(varprocessedkeyword);
                                            }
                                        });
                                    }
                                });
                            } else {

                            }

                            fnRemoveAllHighlightFromField();

                        

                            //fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
                            fnComplianceProcessAndShowDelayedCall(this, varAllComplianceData);
                        }
                        else if (data.APIResponseStatus == "ERROR" || data.APIResponseStatus == "UNAUTHORIZED") {
                            fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
                        }

                    } catch (e) {
                        console.log('Compliance : Error Occured in Method fnGetMetaDataComplianceData successCallback : ' + e.message);
                        fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
                    }

                },
                error: function (err) {
                    console.log('Compliance : Error Occured in Method fnGetMetaDataComplianceData errorCallback : ' + err.message);
                    fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
                }
            });
        } catch (e) {
            console.log('Compliance : Error Occured in Method fnGetMetaDataComplianceData ||' + e.message + "||" + e.stack);
            fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
        }
    }

    function fnComplianceRemoveHighlight(parCurrentElement) {
        try {
            var varSpanHighlightElement = parCurrentElement.parentNode;
            varSpanHighlightElement.children[0].remove();
            varSpanHighlightElement.parentNode.innerHTML = varSpanHighlightElement.parentNode.innerHTML.replace(varSpanHighlightElement.outerHTML, varSpanHighlightElement.innerHTML);

        } catch (e) {

        }
    }

    function fnComplianceProcessAndShowDelayedCall(parControlIDs, parAllComplianceData) {
        try {
            var delayInMilliseconds = 100;

            setTimeout(function () {
                fnProcessContentForCompliance(parControlIDs, parAllComplianceData);
                fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);
            }, delayInMilliseconds);
        
        } catch (e) {

        }
    }

    function fnRestoreComplianceToolTip(parCurrentItem) {
        try {
            parCurrentItem.setAttribute('onclick', 'fnInsertOrUpdateComplianceData(this);');
            var varTooltiptextImageElement = $(parCurrentItem.parentNode).find('.compliance-action-tooltiptext-img')[0];
            varTooltiptextImageElement.src = '/_LAYOUTS/InformaticaKBMasterPage/Images/icon-ignore-mark.png';

        } catch (e) {
            console.log('Compliance : Error Occured in Method fnRestoreComplianceToolTip ||' + e.message + "||" + e.stack);
        }
    }

    function fnGetKeywordFromHighlight(parCurrentItem) {
        try {
            var varCloneSpanHighlight = $(parCurrentItem.parentNode).clone();
            var varCloneSpanHighlightElement = varCloneSpanHighlight[0];
            //varCloneSpanHighlightElement.children[0].remove();
            $(varCloneSpanHighlightElement.children[0]).remove();
            var varKeyword = varCloneSpanHighlightElement.innerHTML;
            varKeyword = varKeyword.trim().toLowerCase();
            varKeyword = fnTrimZeroSpaceContent(varKeyword);
            return varKeyword;
        } catch (e) {
            console.log('Compliance : Error Occured in Method fnGetKeywordFromHighlight ||' + e.message + "||" + e.stack);
        }
        return "";
    }


    function fnInsertOrUpdateComplianceData(parCurrentItem) {
        try {
            var varCurrentArticleID = $("[id*='hdnMetaDataCompDocID']").val();
            var varActionTaken = 'exclusion';
            var varUserEmailID = $("[id*='hdnMetaDataCompUserEmail']").val();;
            var varDocumentURL = [location.protocol, '//', location.host, location.pathname].join('');
            var varControlIDs = [{ ID: 'ID', Name: 'URL' }, { ID: 'ID', Name: 'EMAIL' }, { ID: 'ID', Name: 'IPADDRESS' }, { ID: 'ID', Name: 'DOMAIN' }, { ID: 'ID', Name: 'PHONENO' }];
            var varKeyWord = fnGetKeywordFromHighlight(parCurrentItem);
            varKeyWord = fnGetEncodedComplianceTermsFromKeyword(varKeyWord, varControlIDs);
            var varCurrentItemContent = { Keyword: varKeyWord, CurrentElement: parCurrentItem };
            var varProducts = $("[id*='hdnMetaDataCompProducts']").val();
            var varPermissionType = $("[id*='hdnMetaDataCompPermissionType']").val();
            parCurrentItem.removeAttribute('onclick');
            var varTooltiptextImageElement = $(parCurrentItem.parentNode).find('.compliance-action-tooltiptext-img')[0];
            varTooltiptextImageElement.src = "/_LAYOUTS/InformaticaKBMasterPage/Images/icon_loading_two.gif";

            $.ajax({
                url: '/_layouts/ArticleMetaDataCompliance/WebService/DataService.asmx/InsertOrUpdateComplianceItemDetails',
                method: 'post',
                dataType: 'json',
                data: { strDocID: varCurrentArticleID, strUserEmailID: varUserEmailID, strDocUrl: varDocumentURL, strKeyWord: varKeyWord, strActionTaken: varActionTaken, strProducts: varProducts, strPermissionType: varPermissionType },
                context: varCurrentItemContent,
                success: function (data) {
                    try {
                        console.log('Compliance - fnInsertOrUpdateComplianceData Method - Response Status: ' + data.APIResponseStatus);
                        console.log('Compliance - fnInsertOrUpdateComplianceData Method - Error Message: ' + data.ErrorMessage);
                        if (data.APIResponseStatus == "OK") {
                            //fnComplianceRemoveHighlight(this.CurrentElement);
                            //fnRemoveSameKeywordHighlightUI(this.Keyword);
                            //fnRemoveAllHighlightFromField();
                            fnShowComplianceData();
                        }
                        else if (data.APIResponseStatus == "ERROR" || data.APIResponseStatus == "UNAUTHORIZED") {
                            fnRestoreComplianceToolTip(this.CurrentElement);
                        }
                    } catch (e) {
                        console.log('Compliance : Error Occured in Method fnInsertOrUpdateComplianceData successCallback : ' + e.message);
                        fnRestoreComplianceToolTip(this.CurrentElement);
                    }
                },
                error: function (err) {
                    console.log('Compliance : Error Occured in Method fnInsertOrUpdateComplianceData errorCallback : ' + err.message);
                    fnRestoreComplianceToolTip(this.CurrentElement);
                }
            });
        } catch (e) {
            console.log('Compliance : Error Occured in Method fnInsertOrUpdateComplianceData ||' + e.message + '||' + e.stack);
            fnRestoreComplianceToolTip(this.CurrentElement);
        }
    }

    function fnRemoveSameKeywordHighlightUI(parKeyword) {
        try {
            //var varToolTipImageCss = 'compliance-action-tooltiptext-img';
            var varToolTipTextCss = 'compliance-action-tooltiptext';
            for (var i = $('.' + varToolTipTextCss).length - 1; i >= 0; i--) {
                if (fnGetKeywordFromHighlight($('.' + varToolTipTextCss)[i]) == parKeyword) {
                    fnComplianceRemoveHighlight($('.' + varToolTipTextCss)[i]);
                }
            }

            fnComplianceWizardDecideToShow('compliance-action-tooltiptext', $("[id*='compliancewizardparentdiv']")[0].id);

        } catch (e) {
            console.log('Compliance : Error Occured in Method fnRemoveSameKeywordHighlightUI ||' + e.message + '||' + e.stack);
        }
    }

    function fnBuildGDPROutputAsHtml(parJSONGDPROutputString) {
        var varFinalOutputHTML = '<table style="width:100%;line-height:14px;" data-custom-nogdprviolations="true"><tr><td style="color:red;font-weight:900;text-align: center;">No GDPR data available</td></tr></table>';
        try {
            var NoGDPRComplianceHTML = '<table style="width:100%;line-height:14px;" data-custom-nogdprviolations="true""><tr><td style="color:green;font-weight:900;text-align: center;">No violations detected within the KB article. Please proceed.</td></tr></table>';
            var NoGDPRComplianceDataHTML = '<table style="width:100%;line-height:14px;" data-custom-nogdprviolations="true"" ><tr><td style="color:red;font-weight:900;text-align: center;">No GDPR data available</td></tr></table>';                        
            var varHeadingHtml = '<span style="color:red; font-weight:900; text-decoration-line: underline;width:100%;">Warning: GDPR Compliance Violations detected</span>'
            var varIsViolated = 'Is_Violated';
            var varJSONGDPROutput = JSON.parse(parJSONGDPROutputString);
            if ((varJSONGDPROutput == undefined) || (Object.keys(varJSONGDPROutput).length == 0)) {
                //varFinalOutputHTML = NoGDPRComplianceDataHTML;
                varFinalOutputHTML = '';
            }
            else if (varJSONGDPROutput[varIsViolated].toString() == "0")
            {
                varFinalOutputHTML = '';
            }
            else if (varJSONGDPROutput[varIsViolated].toString() == "1") {
                var varTable = '';
                //varTable.innerHTML = '<tr><td>Is Violated</td><td>Customer Name</td><td>Email</td><td>IP Address</td><td>Phone Number</td></tr>';
           
                //var varTotalRowForOutput = fnGetGDPROutputTotalRow(varJSONGDPROutput);
               
                varTable = '<table style="width:100%;line-height:14px;width: 100%;line-height:14px;-webkit-border-radius: 8px;-moz-border-radius: 8px;overflow:hidden;border-radius: 9px;-pie-background: linear-gradient(#ece9d8, #E5ECD8);box-shadow: #666 0px 2px 3px;behavior: url(Include/PIE.htc);border-color: white !important;overflow: hidden;">';

                var varJSONGDPROutputKeys = Object.keys(varJSONGDPROutput);

                //this is for header
                // varTable += '<tr>';
                // for (var i = 0; i < varJSONGDPROutputKeys.length; ++i) {
                //     var varGDPRPropName = varJSONGDPROutputKeys[i];
                //     if (varIsViolated != varGDPRPropName)
                //         varTable += '<td style="border: 1px solid #919191; font-weight:900; min-width:10%; ">' + varGDPRPropName + '</td>';
                // }
                // varTable += '</tr>';

                //this is for data row
                
                // for (var j = 0; j < varTotalRowForOutput; ++j) {
                //     varTable += '<tr>';
                //     for (var k = 0; k < varJSONGDPROutputKeys.length; ++k) {
                //         var varGDPRPropName = varJSONGDPROutputKeys[k];
                //         if (varIsViolated != varGDPRPropName) {
                            
                        
                //             if (Array.isArray(varJSONGDPROutput[varGDPRPropName]) == true) {
                //                 if ((varJSONGDPROutput[varGDPRPropName] != undefined) && (varJSONGDPROutput[varGDPRPropName][j] != undefined)) {
                //                     varTable += '<td style="border: 1px solid #919191;">' + varJSONGDPROutput[varGDPRPropName][j].toString() + '</td>';
                //                 }
                //                 else {
                //                     varTable += '<td style="border: 1px solid #919191;"></td>';
                //                 }
                //             }
                //             else {
                //                 if ((j == 0) && (varJSONGDPROutput[varGDPRPropName] != undefined)) {
                //                     varTable += '<td style="border: 1px solid #919191;">' + varJSONGDPROutput[varGDPRPropName].toString() + '</td>';
                //                 }
                //                 else {
                //                     varTable += '<td style="border: 1px solid #919191;"></td>';
                //                 }
                //             }
                //         }
                    
                //     }
                //     varTable += '</tr>';
                // }

                 //this is for header
                varTable += '<tr>';
                varTable += '<td style="border: 0px solid #919191; background: var(--lwc-colorBackgroundButtonDefaultActive,rgb(243, 242, 242)); font-weight:600; font-size-14px;">Field Names</td>';
                varTable += '<td style="border: 0px solid #919191; background: var(--lwc-colorBackgroundButtonDefaultActive,rgb(243, 242, 242)); font-weight:600; font-size-14px;">Data Violations</td>';
                varTable += '<td style="border: 0px solid #919191; background: var(--lwc-colorBackgroundButtonDefaultActive,rgb(243, 242, 242)); font-weight:600; font-size-14px;">Violations Detected In</td>';
                varTable += '<td style="border: 0px solid #919191; background: var(--lwc-colorBackgroundButtonDefaultActive,rgb(243, 242, 242)); font-weight:600; font-size-14px;">Recommendations</td>';
                varTable += '</tr>';

                for (var k = 0; k < varJSONGDPROutputKeys.length; ++k) {
                    if (k == 0) {
                        varTable += '<tr>';
                        if (varIsViolated != varJSONGDPROutputKeys[k]) {
                            varTable += '<td style="border: 0px solid #919191;"> ' + varJSONGDPROutputKeys[k] + '</td>';
                            varTable += '<td style="border: 0px solid #919191;">' + fnGetArrayAsString(varJSONGDPROutput[varJSONGDPROutputKeys[k]].Keywords) + '</td>';
                            varTable += '<td style="border: 0px solid #919191;">' + varJSONGDPROutput[varJSONGDPROutputKeys[k]].Violations + '</td>';
                            varTable += '<td style="border: 0px solid #919191;">' + varJSONGDPROutput[varJSONGDPROutputKeys[k]].Recommendation + '</td>';
                        }
                        varTable += '</tr>';
                    }
                    else {
                        varTable += '<tr>';
                        if (varIsViolated != varJSONGDPROutputKeys[k]) {
                            varTable += '<td style="border: 0px solid #919191; border-top:1px solid #dddbda;">' + varJSONGDPROutputKeys[k] + '</td>';
                            varTable += '<td style="border: 0px solid #919191; border-top:1px solid #dddbda;">' + fnGetArrayAsString(varJSONGDPROutput[varJSONGDPROutputKeys[k]].Keywords) + '</td>';
                            varTable += '<td style="border: 0px solid #919191; border-top:1px solid #dddbda;">' + varJSONGDPROutput[varJSONGDPROutputKeys[k]].Violations + '</td>';
                            varTable += '<td style="border: 0px solid #919191; border-top:1px solid #dddbda;">' + varJSONGDPROutput[varJSONGDPROutputKeys[k]].Recommendation + '</td>';
                        }
                        varTable += '</tr>';
                    }
                    
                    
                }

                varTable += '</table>';

                varFinalOutputHTML = varTable;
            }
            else {
                
                //varFinalOutputHTML = NoGDPRComplianceHTML;
                varFinalOutputHTML = '';
            }

        } catch (e) {
            console.log('Compliance : Error Occured in Method fnBuildGDPROutputAsHtml ||' + e.message + '||' + e.stack);
        }
        return varFinalOutputHTML;
    }

    function fnBuildGDPRJSONOutput(parJSONGDPROutputString) {
        var varFinalOutputJSON = [];
        try {
            var varJSONGDPROutput = JSON.parse(parJSONGDPROutputString);

            if (varJSONGDPROutput.Data != undefined) {
                var varDataArray = varJSONGDPROutput.Data;
                for (var i = 0; i < varDataArray.length; i++) {
                    if (varDataArray[i].Type == 'GDPRCompliance') {
                        var varGDRPOutputJSON = varDataArray[i].Output.JSON_Output;
                        var varGDRPOutputHTML = fnBuildGDPROutputAsHtml(JSON.stringify(varGDRPOutputJSON));
                        varDataArray[i].Output.HTML_Output = encodeURIComponent(varGDRPOutputHTML);
                        varDataArray[i].Is_Violated = varGDRPOutputJSON.Is_Violated;
                        break;
                    }                    
                }
                varFinalOutputJSON = varDataArray;
            }
                               
        } catch (e) {
            console.log('Compliance : Error Occured in Method fnBuildGDPRJSONOutput ||' + e.message + '||' + e.stack);
        }
        return varFinalOutputJSON;
    }

    function fnGetArrayAsString(parArrayObj) {
        var varOutPut = parArrayObj.toString();
        try {
            varOutPut = '';
            for (var i = 0; i < parArrayObj.length; i++) {
                if (i == 0) {
                    varOutPut = parArrayObj[i];
                }
                else {
                    varOutPut += ', ' + parArrayObj[i];
                }
            }
        }
        catch (e) {
            console.log('Compliance : Error Occured in Method fnGetValuesFromArray ||' + e.message + '||' + e.stack);
            varOutPut = parArrayObj.toString();
        }
        return varOutPut;
    }


    function fnGetGDPROutputTotalRow(parJSONGDPROutput) {
        var varTotalRow = 0;
        try {
           
            if (Array.isArray(parJSONGDPROutput.Is_Violated) == true) {
                varTotalRow = parJSONGDPROutput.Is_Violated.length;
            }
            else {
                varTotalRow = 1;
            }

            if (Array.isArray(parJSONGDPROutput.Customer_Name) == true) {
                if (varTotalRow < parJSONGDPROutput.Customer_Name.length) {
                    varTotalRow = parJSONGDPROutput.Customer_Name.length;
                }
            }
            else {
                if (varTotalRow == 0)
                    varTotalRow = 1;
            }

            if (Array.isArray(parJSONGDPROutput.Email) == true) {
                if (varTotalRow < parJSONGDPROutput.Email.length) {
                    varTotalRow = parJSONGDPROutput.Email.length;
                }
            }
            else {
                if (varTotalRow == 0)
                    varTotalRow = 1;
            }

            if (Array.isArray(parJSONGDPROutput.IP) == true) {
                if (varTotalRow < parJSONGDPROutput.IP.length) {
                    varTotalRow = parJSONGDPROutput.IP.length;
                }
            }
            else {
                if (varTotalRow == 0)
                    varTotalRow = 1;
            }

            if (Array.isArray(parJSONGDPROutput.Phone_Number) == true) {
                if (varTotalRow < parJSONGDPROutput.Phone_Number.length) {
                    varTotalRow = parJSONGDPROutput.Phone_Number.length;
                }
            }
            else {
                if (varTotalRow == 0)
                    varTotalRow = 1;
            }
        } catch (e) {
            console.log('Compliance : Error Occured in Method fnGetGDPROutputTotalRow ||' + e.message + '||' + e.stack);
        }
        return varTotalRow;
    }

    function fnGetAlert(parCurrentItem)
    {
        alert(parCurrentItem);
    }

    var gdprComplianceMethods = {
          
        'fnShowComplianceData': fnShowComplianceData,
        'fnProcessContentForCompliance': fnProcessContentForCompliance,
        'fnCheckContentForEmail': fnCheckContentForEmail,
        'fnCheckContentForIpAddress': fnCheckContentForIpAddress,
        'fnCheckContentForDomain': fnCheckContentForDomain,
        'fnCheckContentForURL': fnCheckContentForURL,
        'fnCheckContentForPhoneNumber': fnCheckContentForPhoneNumber,
        'fnBuildGDPROutputAsHtml': fnBuildGDPROutputAsHtml,
        'fnBuildGDPRJSONOutput': fnBuildGDPRJSONOutput,
        'fnGetAllComplianceDetailsAsJSON': fnGetAllComplianceDetailsAsJSON,
        'fnGetAlert': fnGetAlert
    
    };

    w.gdprComplianceMethods = gdprComplianceMethods;

    //function to show or hide the alert for compliance popup- end    

    //if(typeof jQuery === "function") {

    //    jQuery.fn.optimizedHighlight = function (pat) {

    //        function innerOptimizedHighlight(node, pat) {

    //            var skip = 0;
    //            if (node.nodeType == 3) {
    //                var pos = node.data.toUpperCase().indexOf(pat);

    //                if (pos >= 0) {

    //                    var middlebit = node.splitText(pos);
    //                    var endbit = middlebit.splitText(pat.length);
    //                    var middleclone = middlebit.cloneNode(true);
    //                    if ((middlebit.parentNode.className != 'highlight') && (middlebit.data.indexOf("class=\"highlight\"") == -1)) {
    //                        var spannode = document.createElement('span');
    //                        spannode.className = 'highlight';
    //                        spannode.className += ' compliance-action-tooltip';
    //                        spannode.appendChild(middleclone);

    //                        var tooltipspannode = document.createElement('span');
    //                        tooltipspannode.className = 'compliance-action-tooltiptext';
    //                        tooltipspannode.appendChild(document.createTextNode("Compliance Action"));
    //                        spannode.appendChild(tooltipspannode);

    //                        middlebit.parentNode.replaceChild(spannode, middlebit);
    //                    }
    //                    skip = 1;

    //                }
    //            } else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
    //                for (var i = 0; i < node.childNodes.length; ++i) {
    //                    i += innerOptimizedHighlight(node.childNodes[i], pat);
    //                }
    //            }
    //            return skip;
    //        }

    //        return this.length && pat && pat.length ? this.each(function () {
    //            innerOptimizedHighlight(this, pat.toUpperCase());
    //        }) : this;
    //    };


    //    jQuery.fn.optimizedRemoveHighlight = function() {

    //        while (this.find("span.highlight").length > 0) {
    //            var varFirstFoundNode = this.find("span.highlight")[0];
    //            varFirstFoundNode.parentNode.innerHTML = varFirstFoundNode.parentNode.innerHTML.replace(varFirstFoundNode.outerHTML, varFirstFoundNode.innerHTML);
    //        }
    //        return;
    //    };
    //}


    //GDPR Compliance Function - End//



})(window);

  