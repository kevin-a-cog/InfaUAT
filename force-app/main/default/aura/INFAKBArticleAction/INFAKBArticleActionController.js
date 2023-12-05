/*
  @description       : 
  @author            : Sathish Rajalingam
  @group             : 
  @last modified on  : 02-01-2021
  @last modified by  : Sathish Rajalingam
  Modifications Log 
  
  Tag       |  Date           |  Modified by                |  Jira reference   |   ChangesMade    
   1        |  24-Dec-2020    |  Sathish Rajalingam		    |    I2RT-550       |   Removed Unnecessaery referecen of Empty Field Text removal js.
   2        |  29-Jan-2021    |  Sathish Rajalingam		    |    I2RT-678       |   PDF download is not working on the community page.  
   3        |  18-Jan-2022     |  Sathish Rajalingam         |      I2RT-3137	|   Content on PDF Render for non-English articles is distorted and the language continues to be English 

*/
({
    doInit: function (component, event, helper) {
        console.log('init');
        var action = component.get("c.getloggedinprofile");

        action.setCallback(this, function (response) {
            console.log('beforecall');
            var res = response.getReturnValue();
            console.log('response' + res);
            var varKBArticleInternalURL = $A.get("$Label.c.KB_Article_Internal_URL")/*<2>*/
            var varKBArticleExternalURL = $A.get("$Label.c.KB_Article_External_URL")/*<2>*/
            
            if (res) {
                console.log('response becomes true');
                $A.util.addClass(component.find('viewArticle'), 'slds-hide');
                component.set('v.ArticleURL', varKBArticleExternalURL)/*<2>*/
            } else {
                console.log('response becomes false');
                $A.util.removeClass(component.find('viewArticle'), 'slds-hide');
                component.set('v.ArticleURL', varKBArticleInternalURL)/*<2>*/
            }

        });
        $A.enqueueAction(action);
        helper.getKnowledgeArticleId(component, event, helper);
        console.log('aftercall');
    },
    doArticleOpen: function (component, event, helper) {
        var source = event.getSource();
        var resourceUrl = component.get("v.ArticleId");
        var uri = document.location;
        var recordurl = $A.get("$Label.c.KB_URL") + '/' + resourceUrl + "/view";
        window.location.assign(recordurl);
    },
    articleEmail: function (component, event, helper) {
        try {
            util.trackEmail();
        }
        catch (ex) {
            console.log(ex.message);
        }
        let articleTitle = document.title;
        let mailBody = "The following article(s) have been sent to you. To access an article, click on a link below.%0D%0A%0D%0A" + window.location.href;
        window.location.href = "mailto:" + '?subject=' + articleTitle + '&body=' + mailBody;

    },
    articlePrint: function (component, event, helper) {
        try {
            util.trackPrint();
        }
        catch (ex) {
            console.log(ex.message);
        }
        window.print();
    },
    articleBookmark: function (component, event, helper) {
        try {
            util.trackBookmark();
        }
        catch (ex) {
            console.log(ex.message);
        }
        alert('Press Ctrl+D to bookmark this page');
    },
    articleExportToPDF: function (component, event, helper) {
        try {
            util.trackExportToPdf();
        }
        catch (ex) {
            console.log(ex.message);
        }
        var varArticleURL = component.get("v.ArticleURL");/*<2>*/
        var knowledgeArticleId = component.get('v.knowledgeArticleId');
        var knowledgeLanguage = component.get('v.knowledgeLanguage'); /*<3>*/
        var urlEvent = $A.get("e.force:navigateToURL");
        var url = varArticleURL + "/apex/KnowledgeRenderPDF?Id=" + knowledgeArticleId +"&Language=" + knowledgeLanguage;/*<2>*/ /*<3>*/
        // var url = 'https://kbdev-article.cs1.force.com/article/apex/KnowledgeRenderPDF?Id='+knowledgeArticleId;
        urlEvent.setParams({
            "url": url
        });
        if (varArticleURL != 'none')/*<2>*/
            urlEvent.fire();

        // window.open("https://infa--kbdev--c.visualforce.com/apex/KnowledgeRenderPDF?Id=kA0S00000004wquKAA", 'TheNewpop', 'toolbar=1,location=1,directories=1,status=1,menubar=1,scrollbars=1,resizable=1');

    },
    articleCopyURL: function (component, event, helper) {
        try {
            util.trackCopyURL();
        }
        catch (ex) {
            console.log(ex.message);
        }
        let temporaryElement = document.createElement('input');
        document.body.appendChild(temporaryElement);
        temporaryElement.value = window.location.href;
        console.log('current URL', window.location.href);
        /* if(window.location.href.includes('fid=')){
             console.log('inside fid check');
             temporaryElement.value = window.location.href.substring(0, window.location.href.lastIndexOf('&'));
             console.log('after that',temporaryElement.value);
         } */
        let url = window.location.href.substring(0, window.location.href.lastIndexOf('?'));
        if (url == '') {
            temporaryElement.value = window.location.href;
            console.log('after that', temporaryElement.value);
            temporaryElement.select();
            document.execCommand('copy');
            document.body.removeChild(temporaryElement);
            $("#articleCopyURL").attr('title', 'URL Copied');
        }
        else {
            const queryString = window.location.search;
            console.log(queryString);
            const urlParams = new URLSearchParams(queryString);
            const language = urlParams.get('language');
            console.log('language', language);
            temporaryElement.value = url + '?language=' + language;
            console.log('after that', temporaryElement.value);
            temporaryElement.select();
            document.execCommand('copy');
            document.body.removeChild(temporaryElement);
            $("#articleCopyURL").attr('title', 'URL Copied');
        }
    }
    /* followArticle : function (component,event,helper){
         component.find('knowledgeFollow').followArticle(event);
     } */

})