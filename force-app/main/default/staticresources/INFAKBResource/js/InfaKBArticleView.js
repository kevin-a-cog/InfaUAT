/**************************************************************************
JS file Name: InfaKBArticleView.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 20-February-2020
Purpose: Holds all the function required  for KB Article View.
Version: 1.0

Modificaiton History

Date       |  Modified by    |  Jira reference      |       ChangesMade                               |     Tag
     
***************************************************************************/

/**
 * 
 * @param {*} parResourceURL 
 */
function getLogoutURL(parResourceURL) {
    var uri = document.location;
    window.location.assign(parResourceURL + '/login/signout?fromURI=' + encodeURIComponent(uri));
}

/**
 * 
 * @param {*} parResourceURL 
 */
function getLoginURl(parResourceURL) {
    var uri = document.location;
    window.location.assign(parResourceURL + "?referer=" + encodeURIComponent(uri));
}
