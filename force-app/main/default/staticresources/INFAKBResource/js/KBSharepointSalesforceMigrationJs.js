/**************************************************************************
JS file Name: KBSharepointSalesforceMigrationJs.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 15-October-2020
Purpose: Holds all the function required KB Migration.
Version: 1.0


Modificaiton History


  Tag       |  Date             |  Modified by              |  Jira reference   |   ChangesMade
   1        |  15-Oct-2020      |  Sathish Rajalingam       |                   |   Initial Version
   2        |  24-Dec-2020      |  Sathish Rajalingam       |   I2RT-550        |   Progress Image added for onload
   3        |  11-Jan-2021      |  Sathish Rajalingam       |   I2RT-725        |   Removal of description field for RecordType FAQ,How To and Whitepaper

***************************************************************************/


/*Global variable used across the application
 
*/


//call to  set digitaldata varialbe not to tracked
function fnCustomRedirctBasedOnEnv(currentElement) {

    try {

        //console.log("Method : fnCustomRedirctBasedOnEnvError : Called");

    } catch (ex) {
        console.log("Method : fnCustomRedirctBasedOnEnvError :" + ex.message);
    }

}




function fnCheckUserNameAvailable(execCount) {
    try {
        //console.log("Method : fnCheckUserNameAvailable " + execCount.toString());
        if ($(".userdetailssection").length > 0 && $(".userdetailssection").find("span")[0].innerText.length > 0) {
            $(".loginsection")[0].style.display = "none";
            $(".userdetailssection")[0].style.display = "block";

        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnCheckUserNameAvailable(execCount); }, 100);
        }
    } catch (ex) {
        console.log("Method : fnCheckUserNameAvailable :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

 //Start : I2RT-553 : Article Views, Likes, Case Deflection labels on Search Results page    

function fnChecCaseDefViewsLikesAvailable(execCount,parArtNumberMsg) {
    try {
        //console.log("Method : fnCheckUserNameAvailable " + execCount.toString());
        if (($(".ArticleMetaDataIsInternalUser").length > 0 && $(".ArticleMetaDataIsInternalUser")[0].innerText == 'NO') || (($(".ArticleMetaDataCaseDefViewLikeIsComplete").length > 0 && $(".ArticleMetaDataCaseDefViewLikeIsComplete")[0].innerText == 'YES') && $(".ArticleMetaDataIsInternalUser")[0].innerText == 'YES')) {
            if (($(".ArticleMetaDataIsInternalUser").length > 0 && $(".ArticleMetaDataIsInternalUser")[0].innerText == 'YES')) {
                fnShowCaseDefViewsLikesData(parArtNumberMsg);
            }
            else {
                if ($(".article-type").length > 0) {
                    $(".article-type")[0].innerHTML = $(".article-type")[0].innerHTML + parArtNumberMsg;
                }
            }
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnChecCaseDefViewsLikesAvailable(execCount,parArtNumberMsg); }, 100);
        }
    } catch (ex) {
        console.log("Method : fnCheckUserNameAvailable :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}


function fnShowCaseDefViewsLikesData(parArtNumber) {
    try {
        var varFinalInnertHtml = parArtNumber;

        if (($(".ArticleMetaDataCaseDef").length > 0 && $(".ArticleMetaDataCaseDef")[0].innerText != '0')) {
            varFinalInnertHtml = varFinalInnertHtml + " <span style=\"background-color: #6e6e70;padding: 3px;border-radius: 5px;color: #FFF;\">Deflected Case</span>";
        }
        if (($(".ArticleMetaDataLike").length > 0 && $(".ArticleMetaDataLike")[0].innerText != '0')) {
            varFinalInnertHtml = varFinalInnertHtml + " <span style=\"background-color: #6e6e70;padding: 3px;border-radius: 5px;color: #FFF;\">Likes " + $(".ArticleMetaDataLike")[0].innerText.trim() + "</span>";
        }
        
        if (($(".ArticleMetaDataView").length > 0 && $(".ArticleMetaDataView")[0].innerText != '0')) {
            varFinalInnertHtml = varFinalInnertHtml + " <span style=\"background-color: #6e6e70;padding: 3px;border-radius: 5px;color: #FFF;\">Views " + $(".ArticleMetaDataView")[0].innerText.trim() + "</span>";
        }

        if ($(".article-type").length > 0)
        {
            $(".article-type")[0].innerHTML = $(".article-type")[0].innerHTML + varFinalInnertHtml;
        }

    } catch (ex) {
        console.log("Method : fnShowCaseDefViewsLikesData :" + ex.message);        
    }
}

//End : I2RT-553 : Article Views, Likes, Case Deflection labels on Search Results page    

function fnHideFieldsWithNoText() {
    try {

        //console.log("fnHideFieldsWithNoText");
        var varAllValueElements = $(".slds-col").find("[class^=\"test-id__field-value\"]");
        var varAllFieldElements = $(".slds-col");
        var isTitleHidden = false;
        var isUrlNameHidden = false;
        var isArticleNumberHidden = false;
        var isRecordTypeHidden = false;
        var isDescriptionElementFound = false;
        var varDescriptionElement = undefined;
        var varRecordTypeName = "";
        for (var s = 0; s < varAllFieldElements.length; s++) {
            var varSingleValueElement = $(varAllFieldElements[s]).find("[class^=\"test-id__field-value\"]");
            if (varSingleValueElement.length > 0 && $(varSingleValueElement[0]).text().trim() == "") {
                varAllFieldElements[s].style.display = "none";
            }

            if (isTitleHidden == false) {
                if ($(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0] != undefined) {
                    var varFieldLabel = $(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0].innerText.trim();
                    if (varFieldLabel == "Title" || varFieldLabel == "Titel" || varFieldLabel == "タイトル" || varFieldLabel == "标题" || varFieldLabel == "標題") {
                        varAllFieldElements[s].style.display = "none";
                        isTitleHidden = true;
                    }
                }
            }

            if (isArticleNumberHidden == false) {
                if ($(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0] != undefined) {
                    var varFieldLabel = $(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0].innerText.trim();
                    if (varFieldLabel == "Article Number" || varFieldLabel == "Artikelnummer" || varFieldLabel == "記事番号" || varFieldLabel == "文章編號" || varFieldLabel == "文章编号") {
                        if ($(".article-type").length > 0) {
                            var varArtNumber = " <span style=\"background-color: #6e6e70;padding: 3px;border-radius: 5px;color: #FFF;\">" + $(varAllFieldElements[s]).find("[class*=\"uiOutputText\"]")[0].innerText.trim() + "</span>";//I2RT-553 
                            fnChecCaseDefViewsLikesAvailable(0, varArtNumber);//I2RT-553 
                        }                                                
                        varAllFieldElements[s].style.display = "none";
                        isArticleNumberHidden = true;                       
                    }
                }
            }
            /*<3>*/
            if (isRecordTypeHidden == false) {
                if ($(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0] != undefined) {
                    var varFieldLabel = $(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0].innerText.trim();
                    if (varFieldLabel == "Article Record Type" || varFieldLabel == "Artikeldatensatztyp" || varFieldLabel == "記事レコードタイプ" || varFieldLabel == "文章记录类型" || varFieldLabel == "文章記錄類型") {
                        varAllFieldElements[s].style.display = "none";
                        if (varSingleValueElement.length > 0 && $(varSingleValueElement[0]).text().trim() != "") {
                            varRecordTypeName = $(varSingleValueElement[0]).text().trim();
                        }
                        isRecordTypeHidden = true;
                    }
                }
            }

            if (isDescriptionElementFound == false) {
                if ($(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0] != undefined) {
                    var varFieldLabel = $(varAllFieldElements[s]).find("[class*=\"slds-form-element__label\"]")[0].innerText.trim();
                    if (varFieldLabel == "Description") {
                        varDescriptionElement = varAllFieldElements[s];
                        isDescriptionElementFound = true;
                    }
                }
            }

            if (isRecordTypeHidden == true && isDescriptionElementFound == true) {
                if (varRecordTypeName.trim().toString().toLowerCase() == "faq" || varRecordTypeName.trim().toString().toLowerCase() == "how to" || varRecordTypeName.trim().toString().toLowerCase() == "whitepaper") {
                    varDescriptionElement.remove();
                }
            }
            /*</3>*/

        }





    } catch (ex) {
        console.log("Method : fnHideFieldsWithNoText :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }

}

function fnCheckFieldAvailable(execCount) {
    try {
        //console.log("Method : fnCheckFieldAvailable " + execCount.toString());
        if ($(".slds-section").length > 0) {
            fnExpandSectionInArticleLayout();
            fnHideFieldsWithNoText();
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnCheckFieldAvailable(execCount); }, 100);
        }
    } catch (ex) {
        console.log("Method : fnCheckFieldAvailable :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnCheckUserNameAfterEditLinkAvailable(execCount) {
    /*  try {
          if (document.getElementsByClassName("userdetailssection").length > 0 && document.getElementsByClassName("articlelinksection").length > 0 && document.getElementsByClassName("userdetailssection")[0].style.display == "block") {
              document.getElementsByClassName("articlelinksection")[0].style.display = "block";
          }
          else if (execCount < 600) {
              execCount = execCount + 1;
              window.setTimeout(function () { fnCheckUserNameAfterEditLinkAvailable(execCount); }, 100);
          }

      } catch (ex) {
          console.log("Method : fnHideFieldsWithNoText :" + ex.message);
      }*/
}

function fnExecuteOnDisplayMode() {

    try {
        if ($($(".forcePageBlockSectionRow").find("span[class=\"test-id__field-label\"]:contains(\"Solution\")").parent().parent()).find(".forceOutputRichText").text().indexOf("<div id=\"eaembedcodecontentcustom\">") >= 0) {
            var varRichTextHtmlElement = $($(".forcePageBlockSectionRow").find("span[class=\"test-id__field-label\"]:contains(\"Solution\")").parent().parent()).find(".forceOutputRichText");
            varRichTextHtmlElement[0].innerHTML = varRichTextHtmlElement.text();
        }
    } catch (ex) {
        console.log("Method : fnExecuteOnDisplayMode :" + ex.message);
    }

}

function fnRichTextFieldAvailable(execCount) {
    try {

        if ($(".forcePageBlockSectionRow").find("span[class=\"test-id__field-label\"]:contains(\"Solution\")").length > 0) {
            fnExecuteOnDisplayMode();
            if ($(".article-column")[0].classList.contains("zoom") == false)
                $(".article-column")[0].classList.add("zoom");
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnRichTextFieldAvailable(execCount); }, 100);
        }
    } catch (ex) {
        console.log("Method : fnRichTextFieldAvailable :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnHeadTitleFieldOnVisible() {

    try {
        if ($(".meta.selfServiceArticleHeaderDetail").length > 0) {
            $(".meta.selfServiceArticleHeaderDetail").hide();
        }
    } catch (ex) {
        console.log("Method : fnHeadTitleFieldOnVisible :" + ex.message);
    }

}

function fnHeadTitleFieldIsVisibleCheckForSomeTime(execCount) {
    try {
        if ($(".meta.selfServiceArticleHeaderDetail").length > 0) {
            fnHeadTitleFieldOnVisible();
        }

        if (execCount < 300) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnHeadTitleFieldIsVisibleCheckForSomeTime(execCount); }, 10);
        }
    } catch (ex) {
        console.log("Method : fnHeadTitleFieldIsVisible :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnHeadTitleFieldIsVisible(execCount) {
    try {
        if ($(".meta.selfServiceArticleHeaderDetail").length > 0) {
            fnHeadTitleFieldOnVisible();
            fnHeadTitleFieldIsVisibleCheckForSomeTime(0);
        }
        else if (execCount < 6000) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnHeadTitleFieldIsVisible(execCount); }, 10);
        }
    } catch (ex) {
        console.log("Method : fnHeadTitleFieldIsVisible :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnGetKBHtmlContentFile(currentElement) {
    try {
        var varKBArticleUrlName = location.pathname.substring(location.pathname.lastIndexOf("/") + 1);
        var varHtmlContentFileUrl = "/resource/INFAKBContentResource/KBContent/kb_encoded_html_content_" + varKBArticleUrlName + "_donot_delete.txt?ver=" + Math.random();

        $.get(varHtmlContentFileUrl, function (response) {


            if ($($(".forcePageBlockSectionRow").find("span[class=\"test-id__field-label\"]:contains(\"Solution\")").parent().parent()).find(".forceOutputRichText").length >= 0) {
                var varRichTextHtmlElement = $($(".forcePageBlockSectionRow").find("span[class=\"test-id__field-label\"]:contains(\"Solution\")").parent().parent()).find(".forceOutputRichText");

                var dummydiv = document.createElement("div");
                var att = document.createAttribute("style");
                att.value = "display:none";
                dummydiv.innerHTML = response;

                varRichTextHtmlElement[0].innerHTML = $(dummydiv).text();

                dummydiv.remove();

            }


        });

    } catch (ex) {
        console.log("Method : fnGetKBHtmlContentFile :" + ex.message);
    }
}

function fnDoKBCssRefresh(currentElement) {
    try {
        currentElement.onload = "";
        currentElement.href = "/resource/INFAKBResource/css/bootstrap-ea.css?ver=" + Math.random();
    } catch (ex) {
        console.log("Method : fnDoKBCssRefresh :" + ex.message);
    }
}

function fnArticleLayoutIsVisible(execCount) {
    try {


        if ($("divmaskArticleContent").length > 0) {
            fnArticleLayoutOnVisible();
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnArticleLayoutIsVisible(execCount); }, 100);
        }
        else {
            fnHideArticleLayoutInProgressPanel();
        }
    } catch (ex) {
        console.log("Method : fnArticleLayoutIsVisible :" + ex.message);
    }
}

/*<1>*/
function fnArticleLayoutOnVisible() {

    try {
        fnShowArticleLayoutInProgressPanel();
    } catch (ex) {
        console.log("Method : fnArticleLayoutOnVisible :" + ex.message);
    }

}

function fnArticleHeaderIsVisible(execCount) {
    try {


        if (document.getElementsByClassName("divmaskArticleContent").length > 0) {
            fnArticleHeaderOnVisible();
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnArticleHeaderIsVisible(execCount); }, 100);
        }
        else {
            fnHideArticleLayoutInProgressPanel();
        }
    } catch (ex) {
        console.log("Method : fnArticleHeaderIsVisible :" + ex.message);
    }
}

function fnArticleHeaderOnVisible() {

    try {
        fnHideArticleLayoutInProgressPanel();
    } catch (ex) {
        console.log("Method : fnArticleHeaderOnVisible :" + ex.message);
    }

}

function fnArticlePreviewLayoutIsVisible(execCount) {
    try {


        if ($("c-knowledge-unpublished").find("span").length > 0) {
            fnArticlePreviewLayoutOnVisible();
        }
        else if (execCount < 600) {
            execCount = execCount + 1;
            window.setTimeout(function () { fnArticlePreviewLayoutIsVisible(execCount); }, 100);
        }
        else {
            fnHideArticleLayoutInProgressPanel();
        }
    } catch (ex) {
        console.log("Method : fnArticlePreviewLayoutIsVisible :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnArticlePreviewLayoutOnVisible() {

    try {
        fnHideArticleLayoutInProgressPanel();
    } catch (ex) {
        console.log("Method : fnArticlePreviewLayoutOnVisible :" + ex.message);
    }

}

function fnHideArticleLayoutInProgressPanel() {
    try {
        if (document.getElementsByClassName("divmaskArticleContent").length > 0)
            document.getElementsByClassName("divmaskArticleContent")[0].style.display = "none";
    } catch (ex) {
        console.log("Method : fnHideArticleLayoutInProgressPanel :" + ex.message);
    }
}

function fnShowArticleLayoutInProgressPanel() {
    try {
        if (document.getElementsByClassName("divmaskArticleContent").length > 0)
            document.getElementsByClassName("divmaskArticleContent")[0].style.display = "block";
    } catch (ex) {
        console.log("Method : fnShowArticleLayoutInProgressPanel :" + ex.message);
    }
}

function fnHideArticleLayoutInProgressPanelAlways() {
    try {
        setTimeout(function () { fnHideArticleLayoutInProgressPanel(); }, 5000);
    } catch (ex) {
        console.log("Method : fnArticlePreviewLayoutOnVisible :" + ex.message);
    }

}

function fnFunctionToBeCalledOnLoad() {
    try {
        fnArticleHeaderIsVisible(0);
        fnCheckUserNameAvailable(0);
        fnHeadTitleFieldIsVisible(0);
        fnCheckFieldAvailable(0);
        fnRichTextFieldAvailable(0);
        fnArticlePreviewLayoutIsVisible(0);
        fnHideArticleLayoutInProgressPanelAlways();
    } catch (ex) {
        console.log("Method : fnFunctionToBeCalledOnLoad :" + ex.message);
        fnHideArticleLayoutInProgressPanel();
    }
}

function fnExpandSectionInArticleLayout() {
    try {
        var varSectionAsCollapsed = $(".test-id__section.slds-section").find("button[aria-expanded=\"false\"]");
        for (var g = 0; g < varSectionAsCollapsed.length; g++) {
            varSectionAsCollapsed[g].click();
        }
    } catch (ex) {
        console.log("Method : fnExpandSectionInArticleLayout :" + ex.message);
    }
}

// window.onload = function () {

// }

/*</1>*/
