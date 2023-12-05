/*
   @created by       : Sathish R
   @created on       : 26-Jul-2022
   @Purpose          : Provide Article information for the Javascript to be loaded on page load.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  26-Jul-2022      |  Sathish R                |                   |   Initial Version
 |     2      |  24-Oct-2022      |  Sathish R                |    I2RT-7231      |   Chatter Feed Component not be shown on HOW TO KB Articles search view page.
 ****************************************************************************************************
 */

import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import loginURL from '@salesforce/label/c.CustomerSupportLoginURL'

const ARTICLE_FIELDS = [
      'Knowledge__kav.Id',
      'Knowledge__kav.Title',
      'Knowledge__kav.ArticleNumber',
      'Knowledge__kav.Article_Type__c',
	  'Knowledge__kav.Case__c'//<2>
];

export default class KBArticleHeader extends LightningElement {
      @api recordId;
      
      @wire(getRecord, { recordId: '$recordId', fields: ARTICLE_FIELDS })
      article;

      get articledetails() {
            var varTitleValue = '';
            var varRecordTypeValue = '';
		  	var varArticleNumberValue = '';
		  	var varCaseValue = '';//<2>
            try {
                  varTitleValue = this.article.data.fields.Title.value;
                  varRecordTypeValue = this.article.data.fields.Article_Type__c.value;
				  varArticleNumberValue = this.article.data.fields.ArticleNumber.value;
				  varCaseValue = ((typeof this.article.data.fields.Case__c.value != 'undefined') && (this.article.data.fields.Case__c.value != null)) ? this.article.data.fields.Case__c.value : '';//<2>				 
                  fnSetOmniturePageDetails(varRecordTypeValue, varArticleNumberValue, varTitleValue);
                  console.log('KBArticleHeader');
                  console.log(this.recordId);
                  
                  //Added to disable the feedcontroller when no feed is there 			
			function fnCheckTillFeedAvailable(execCount) {
				try {

					var isPresent = false;
					if (document.getElementsByClassName('cINFAKBFeed').length > 0) {
						var varParentFeedElement = document.getElementsByClassName('cINFAKBFeed');
						for (var i = 0; i < varParentFeedElement.length; i++) {
							if (varParentFeedElement[i].innerHTML.indexOf('feeds_placeholding-emptyfeed_emptyfeed') > -1) {
								isPresent = true;
								break;
							}
							else if (document.getElementsByClassName('cuf-feedItemHeader').length > 0) {
								isPresent = true;
								break;
							}
						}
					}
					
					if (isPresent == true) {
						fnToBeCalledOnceFeedAvailable();
					} else if (execCount < 600) {
						execCount = execCount + 1;
						window.setTimeout(function () { fnCheckTillFeedAvailable(execCount); }, 100);
					}
				} catch (ex) {
					console.error('Method : fnCheckTillFeedAvailable :' + ex.message);
				}
			}
	
			function fnToBeCalledOnceFeedAvailable() {
				try {
					try {
						console.log('varRecordTypeValue : ' + varRecordTypeValue);			
						if ((varRecordTypeValue == 'PAM EOL Support Statement') || (varRecordTypeValue == 'Support Guide') || (varRecordTypeValue == 'Product Release') || ((varRecordTypeValue == 'HOW TO') && (varCaseValue.indexOf('DOC:') > -1)) || (varRecordTypeValue == 'RCA')) {//<2>
							fnToCheckFeedAndExecute(0);
						}
						else {
							var varFeedElement = document.getElementsByClassName('cINFAKBFeed');
							for (var i = 0; i < varFeedElement.length; i++) {
								varFeedElement[i].style.display = 'none';
							}
						}
					} catch (exsub) { }
		
				} catch (ex) {
					console.error('Method : fnToBeCalledOnceFeedAvailable :' + ex.message);
				}
			}
					   
			function fnToCheckFeedAndExecute(execCount) {
				var IsCheckRequired = true;
				var varFeedElement = document.getElementsByClassName('cINFAKBFeed');
				for (var i = 0; i < varFeedElement.length; i++) {
					if (varFeedElement[i].innerHTML.indexOf('feeds_placeholding-emptyfeed_emptyfeed') > -1) {
						varFeedElement[i].style.display = 'none';
						IsCheckRequired = false;
					}
					else if (document.getElementsByClassName('cuf-feedItemHeader').length > 0) {
						varFeedElement[i].style.display = 'block';
						IsCheckRequired = false;
					}
					else {
						varFeedElement[i].style.display = 'block';
					}
					if ((execCount < 60) && IsCheckRequired == true) {
						execCount = execCount + 1;
						window.setTimeout(function () { fnCheckTillFeedAvailable(execCount); }, 100);
					}
				}
			}

			fnCheckTillFeedAvailable(0);
			//Added to disable the feedcontroller when no feed is there 

                  //Added to disable to route login page when user opens the PAM EOL Support Statement and Support Guide Article
			function fnCheckTillElementAvailable(execCount) {
				try {
					
					if (document.getElementsByClassName('cINFAKBFeed').length > 0) {
						fnToBeCalledOnceElementAvailable();
					} else if (execCount < 600) {
						execCount = execCount + 1;
						window.setTimeout(function () { fnCheckTillElementAvailable(execCount); }, 100);
					}
				} catch (ex) {
					console.error('Method : fnCheckTillItsAvailable :' + ex.message);
				}
			}
	
			function fnToBeCalledOnceElementAvailable() {
				try {
		  
					var firstName = '';
					var userid = undefined;
					var userType = undefined;
					try {
						userType = document.getElementById('authentication-userType').innerText;
					} catch (exsub) { }

					try {
							
						if ((varRecordTypeValue == 'PAM EOL Support Statement') || (varRecordTypeValue == 'Support Guide') || (varRecordTypeValue == 'Product Release') || ((varRecordTypeValue == 'HOW TO') && (varCaseValue.indexOf('DOC:') > -1))  || (varRecordTypeValue == 'RCA')) {//<2>
							var varFeedElement = document.getElementsByClassName('cINFAKBFeed');
							for (var i = 0; i < varFeedElement.length; i++) {
								varFeedElement[i].style.display = 'block';
							}
						}
						else {
							var varFeedElement = document.getElementsByClassName('cINFAKBFeed');
							for (var i = 0; i < varFeedElement.length; i++) {
								varFeedElement[i].style.display = 'none';
							}
						}
					} catch (exsub) { console.error('Method : fnToBeCalledOnceElementAvailable :' + exsub.message); }
		  
					if ((userType == 'Guest' && varRecordTypeValue == 'PAM EOL Support Statement') || (userType == 'Guest' && varRecordTypeValue == 'RCA')) {
						console.log(varRecordTypeValue);
						var varCurrentURL = document.location.href;
						var loginLink = loginURL;
						loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
						window.location.assign(loginLink);
						//console.log(loginLink);
					  
					}
				} catch (ex) {
					console.error('Method : fnToBeCalledOnceElementAvailable :' + ex.message);
				}
			}

			fnCheckTillElementAvailable(0);
			//Added to disable to route login page when user opens the PAM EOL and Support Guide Article

                 
                  
            }
            catch (ex) {
                  console.error("Method : articledetails; Error :" + ex.description);
            }
            return '';
      }
}