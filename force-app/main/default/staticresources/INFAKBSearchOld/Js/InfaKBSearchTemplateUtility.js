/**************************************************************************
JS file Name: InfaKBSearchTemplateUtility.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 24-April-2021
Purpose: Holds all the function required  for Coveo Search Template Customization.
Version: 1.0

Modificaiton History

Date       |  Modified by    |  Jira reference      |       ChangesMade                               |     Tag

13-05-2020        Sathish.R         KB-145            Added new function to capture Coveo Analytics         01
13-05-2020        Sathish.R         KB-135            Internal Search > Labels for Deflected case           02
                                                      and Most viewed        
***************************************************************************/


(function (w) {

   
      jQuery.support.cors = true;


      /** */

      function fnCustomCoveoCopyURL(parResult, parCurrentItem) {
            var varHtmlContent = "";
            try {
                 
            } catch (ex) {
                  console.error("Method : fnDefaultGetBadge; Error :" + ex.message);
            }
            parCurrentItem.outerHTML = varHtmlContent;
      }

      function fnCustomContentVisited(parResult, parCurrentItem) {
            var varHtmlContent = "";
            try {
                  varHtmlContent = "<span style=\"display: none\" class=\"CustomContentVisited\" style=\"color:#BCC3CA;\" data-isChildContent=\"false\" data-customContentURL=\"" + parResult.result.raw.sysclickableuri + "\" title=\"This information is browser specific\"></span>"
            } catch (ex) {
                  console.error("Method : fnCustomContentVisited; Error :" + ex.message);
            }
            parCurrentItem.outerHTML = varHtmlContent;
      }
   

      /** */

      var InfaKBSearchTemplateUtilityJs = {           
            'fnCustomCoveoCopyURL': fnCustomCoveoCopyURL,
            'fnCustomContentVisited': fnCustomContentVisited
      };
      
      //fnLoadKBInternalSearchTemplate();

      w.InfaKBSearchTemplateUtilityJs = InfaKBSearchTemplateUtilityJs;

})(window);