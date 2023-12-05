({
	doInit: function (component, event, helper) {
								
		var action = component.get('c.getCurrentUsersDetails');
		var kbSamlUrl = component.get('v.KbSamlUrl');
		var oktaMeApiUrl = component.get('v.oktaMeApiUrl');
		action.setCallback(this, function (response) {
			var result = response.getReturnValue();
			console.log('getCurrentUsersDetails : ' + result);
			
			if (result != undefined) {
				component.set('v.currentUsersDetails', result);
			} else {
				var varDefaultValue = '{"FirstName":"","UserId":"","UserName":"","UserType":"Guest"}';
				component.set('v.currentUsersDetails', JSON.parse(varDefaultValue));
			}
			
			var vardoAfterRecordLoaded = component.get('c.doAfterRecordLoaded');
			$A.enqueueAction(vardoAfterRecordLoaded);

			  
			var varCurrentUserType = component.get('v.currentUsersDetails.UserType');
			if (varCurrentUserType == 'Guest') {
				//Calling auto login
				$.ajax({
					url: oktaMeApiUrl,
					type: "GET",
					cache: false,
					crossDomain: true,
					dataType: "json",
					accept: 'application/json',
					xhrFields: {
						withCredentials: true
					},
					success: function (resp) {
						//window.location.assign(kbSamlUrl + "?RelayState=" + encodeURIComponent(window.location.href));
					},
					error: function (e) {
						console.log('KB : Auto login call error : ' + e);
					}
				});
			}


			 //Added to route to login page onclick of  LoginComment button
			 function fnCheckTillComElementAvailable(execCount) {
				try {
				
					if (document.getElementsByClassName('cuf-feedItemHeader').length > 0) {
						fnToBeCalledOnceComElementAvailable();
					} else if (execCount < 600) {
						execCount = execCount + 1;
						window.setTimeout(function () { fnCheckTillComElementAvailable(execCount); }, 100);
					}
				} catch (ex) {
					console.error('Method : fnCheckTillItsAvailable :' + ex.message);
				}
			}
	
			function fnToBeCalledOnceComElementAvailable() {
				try {
					if (document.getElementsByClassName('cuf-loginLinkContainer').length > 0) {
						$('.cuf-loginLinkContainer').find('button')[0].addEventListener("click", function () {
							var varCurrentURL = document.location.href;
							if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20?language') != -1) {
								var varDataToFind = 's/global-search/%20?language';
								var varDataToReplace = 's/global-search/?language';
								varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
								var loginLink = component.get('v.logInURL');
								loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
								window.location.assign(loginLink);
							}
							else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ ?language') != -1) {
								var varDataToFind = 's/global-search/ ?language';
								var varDataToReplace = 's/global-search/?language';
								varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
								var loginLink = component.get('v.logInURL');
								loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
								window.location.assign(loginLink);
							}
							else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20') != -1) {
								var varDataToFind = 's/global-search/%20';
								var varDataToReplace = 's/global-search/';
								varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
								var loginLink = component.get('v.logInURL');
								loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
								window.location.assign(loginLink);
							}
							else {
								var referrerURL = window.location.href;
								var loginLink = component.get('v.logInURL');
								loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(referrerURL));
								window.location.assign(loginLink);
							}
						});
					}
				} catch (ex) {
					console.error('Method : fnToBeCalledOnceElementAvailable :' + ex.message);
				}
			}

			fnCheckTillComElementAvailable(0);
			//Added to route to login page onclick of  LoginComment button
			
		});
		$A.enqueueAction(action);		
	},

	doLogin: function (component, event, helper) {
		var varCurrentURL = document.location.href;
		if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20?language') != -1) {
			var varDataToFind = 's/global-search/%20?language';
			var varDataToReplace = 's/global-search/?language';
			varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
			var loginLink = component.get('v.logInURL');
			loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
			window.location.assign(loginLink);			
		}
		else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/ ?language') != -1) {
			var varDataToFind = 's/global-search/ ?language';
			var varDataToReplace = 's/global-search/?language';
			varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
			var loginLink = component.get('v.logInURL');
			loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
			window.location.assign(loginLink);		
		}
		else if (varCurrentURL.toString().toLowerCase().trim().indexOf('s/global-search/%20') != -1) {
			var varDataToFind = 's/global-search/%20';
			var varDataToReplace = 's/global-search/';
			varCurrentURL = varCurrentURL.replace(varDataToFind, varDataToReplace);
			var loginLink = component.get('v.logInURL');
			loginLink =loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(varCurrentURL));
			window.location.assign(loginLink);
		}
		else {		
			var referrerURL = window.location.href;
			var loginLink = component.get('v.logInURL');
			loginLink = loginLink + encodeURIComponent('?RelayState=') + encodeURIComponent(encodeURIComponent(referrerURL));			
			window.location.assign(loginLink);
		}
	},

	doLogout: function(component, event, helper) {
		window.location.replace(component.get('v.logOutURL'));
	},

	doSignUp: function(component, event, helper) {
		window.location.assign(component.get('v.signUpURL'));
	},
	doAfterRecordLoaded: function (component, event, helper) {
		
		
		function doInternalLogin() {
			try {
				var varRelativeURL = window.location.href.substring(window.location.href.indexOf('/', ('https://'.length)));
				var varKBCommunityNameInURL = component.get('v.hdnKBCommunityNameInURL');
				varRelativeURL = varRelativeURL.replace(varKBCommunityNameInURL,'');
				var varCurrentURL = encodeURIComponent(varRelativeURL);
				var varNetworkSwitchLogin = component.get('v.internalNetworkSwitchLogInURL');				
				var varFinalURL = varNetworkSwitchLogin + varCurrentURL;
				window.location.assign(varFinalURL);
			} catch (ex) {
				console.error('error Method : doInternalLogin; Error : ' + ex.message + '||' + ex.stack);
			}
		}
		
		var userid = component.get('v.currentUsersDetails.UserId');
		var varCurrentUserType = component.get('v.currentUsersDetails.UserType');
		var varCommunityUserName = component.get('v.currentUsersDetails.UserName');
		if (varCurrentUserType == 'Guest') {
			console.log('Current LoggedIn User Name : ' + varCommunityUserName);
			var varUserProgressIcon = component.find('UserProgressIcon');
                  var varUserLogin = component.find('UserLogin');
                  $A.util.removeClass(varUserProgressIcon, 'user-login-info-show');
                  $A.util.addClass(varUserProgressIcon, 'user-login-info-hide');
                  $A.util.removeClass(varUserLogin, 'user-login-info-hide');
                  $A.util.addClass(varUserLogin, 'user-login-info-show');                 
		} else {
			console.log('Current LoggedIn User Name : ' + varCommunityUserName);
			var varUserProgressIcon = component.find('UserProgressIcon');
                  var varUserName = component.find('UserName');
                  $A.util.removeClass(varUserProgressIcon, 'user-login-info-show');
                  $A.util.addClass(varUserProgressIcon, 'user-login-info-hide');
                  $A.util.removeClass(varUserName, 'user-login-info-hide');
                  $A.util.addClass(varUserName, 'user-login-info-show');   
		}
		if (userid == '') {
			userid = undefined;
		}
		component.set('v.userid', userid);
		let communityUserNameEndWith = '';
		var currentURL = window.location.href;

		var oktaBaseUrl;

		let logOutURL = '';
		if (window.location.hostname.includes('knowledge.informatica.com')) {
			communityUserNameEndWith = '.community';
			logOutURL = '/secur/logout.jsp';
			oktaBaseUrl = 'https://infapassport.okta.com';
		} else {
			communityUserNameEndWith = '.community.uat';
			logOutURL = '/customersupport/secur/logout.jsp';
			oktaBaseUrl = 'https://infportalsb.oktapreview.com';
		}

		let entireLoginURL = component.get('v.internalLogInURL').split('=');
		let internalLoginLink;
		let ssoLink = entireLoginURL[0];
		let articleLink = entireLoginURL[1];
		//*getusername start

		console.log('userid' + userid);
		//In this caondition Guest and Authenticated User will get satisfied
		if (userid != undefined) {
			console.log('userid if' + userid);

			console.log('usernameTest2', varCommunityUserName);
			component.set('v.username', varCommunityUserName);

			if (varCurrentUserType == 'Guest') {
				console.log('guest userid ' + userid);
				//*check user existence
				if (currentURL.includes('internal=1') && currentURL.includes('fid=')) {
					const queryString = window.location.search;
					console.log(queryString);
					const urlParams = new URLSearchParams(queryString);
					const language = urlParams.get('language');
					const fedId = urlParams.get('fid');
					console.log('language', language);
					console.log('fedId', fedId);
					var checkUserAction = component.get('c.checkUserExistence');

					/*var fedIdDetails = currentURL.substring(currentURL.lastIndexOf('&') + 1, currentURL.length);
                              var fedId = fedIdDetails.split('=')[1];*/
					console.log(fedId);
					if (fedId != null && fedId != '') {
						checkUserAction.setParams({ fedId: fedId });
						checkUserAction.setCallback(this, function(response) {
							var state = response.getState();
							if (state === 'SUCCESS') {
								var userPresent = response.getReturnValue();
								if (userPresent) {
									if (
										currentURL.includes('internal=1') &&
										(userid == undefined ||
											(userid != undefined &&
												varCommunityUserName.endsWith(communityUserNameEndWith)) ||
											varCurrentUserType == 'Guest')
									) {
										console.log(component.get('v.internalLogInURL'));

										if (currentURL.includes('articlepreview')) {
											const cNumber = urlParams.get('c__number');
											let temp = currentURL.substring(
												currentURL.lastIndexOf('?') + 1,
												currentURL.indexOf('&')
											);
											/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?c__number=' + temp.substr(temp.lastIndexOf('=')+1);
                                                                  internalLoginLink = internalLoginLink + '&internal=1';*/
											/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?language='+language+'&c__number=' + cNumber;
                                                                  internalLoginLink = internalLoginLink + '&internal=1'; */
											internalLoginLink =
												ssoLink +
												'=' +
												encodeURIComponent(
													articleLink +
														'articlepreview?language=' +
														language +
														'&c__number=' +
														cNumber +
														'&internal=1'
												);
											console.log('internal login Link', internalLoginLink);											
										} else {
											/* internalLoginLink = component.get("v.internalLogInURL") + 'article/' + currentURL.substring(currentURL.lastIndexOf('/') + 1, currentURL.indexOf('?'));
                                                                  internalLoginLink = internalLoginLink + '?language='+language; */
											internalLoginLink =
												ssoLink +
												'=' +
												encodeURIComponent(
													articleLink +
														'article/' +
														currentURL.substring(
															currentURL.lastIndexOf('/') + 1,
															currentURL.indexOf('?')
														) +
														'?language=' +
														language
												);											
											console.log('internal login Link', internalLoginLink);											
										}
										//window.location.assign(internalLoginLink);
										doInternalLogin();
									}
								}
							}
						});
						$A.enqueueAction(checkUserAction);
					}
				} else if (
					userid != undefined &&
					currentURL.includes('type=external') &&
					!varCommunityUserName.endsWith(communityUserNameEndWith) &&
					varCurrentUserType != 'Guest'
				) {
					//Non Community User and Non Guest User.
					let salesforceLogOutURL = 'https://' + window.location.hostname + logOutURL;
					$.ajax({
						url: salesforceLogOutURL,
						success: function(resp) {
							console.log('Header Internal' + resp);
						},
						error: function(e) {
							console.log('Header Internal Error: ' + e);
						}
					});
					window.reload();
				}
			} else {
				if (
					currentURL.includes('internal=1') &&
					(userid == undefined ||
						(userid != undefined && varCommunityUserName.endsWith(communityUserNameEndWith)))
				) {
					console.log(component.get('v.internalLogInURL'));
					const queryString = window.location.search;
					console.log(queryString);
					const urlParams = new URLSearchParams(queryString);
					const language = urlParams.get('language');
					console.log('language', language);

					let internalLoginLink;
					if (currentURL.includes('articlepreview')) {
						const cNumber = urlParams.get('c__number');
						console.log('cNumber', cNumber);
						let temp = currentURL.substring(currentURL.lastIndexOf('?') + 1, currentURL.indexOf('&'));
						/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?c__number=' + temp.substr(temp.lastIndexOf('=')+1);
                                    internalLoginLink = internalLoginLink +'language='+language+ '&internal=1';  */
						/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?language='+language+'&c__number=' + cNumber;
                                    internalLoginLink = internalLoginLink + '&internal=1'; */

						internalLoginLink =
							ssoLink +
							'=' +
							encodeURIComponent(
								articleLink +
									'articlepreview?language=' +
									language +
									'&c__number=' +
									cNumber +
									'&internal=1'
							);
						console.log('internal login Link', internalLoginLink);
					} else {
						/* internalLoginLink = component.get("v.internalLogInURL") + 'article/' + currentURL.substring(currentURL.lastIndexOf('/') + 1, currentURL.indexOf('?'));
                                    internalLoginLink = internalLoginLink + '?language='+language; */
						internalLoginLink =
							ssoLink +
							'=' +
							encodeURIComponent(
								articleLink +
									'article/' +
									currentURL.substring(currentURL.lastIndexOf('/') + 1, currentURL.indexOf('?')) +
									'?language=' +
									language
							);
						console.log('internal login Link', internalLoginLink);						
					}
					//window.location.assign(internalLoginLink);
					doInternalLogin();
				} else if (
					userid != undefined &&
					currentURL.includes('type=external') &&
					!varCommunityUserName.endsWith(communityUserNameEndWith)
				) {
					console.log('redirect to kill session');
					let salesforceLogOutURL = 'https://' + window.location.hostname + logOutURL;

					console.log('salesforceLogOutURL' + salesforceLogOutURL);
					$.ajax({
						url: salesforceLogOutURL,
						success: function(resp) {
							console.log('Header Internal' + resp);
							location.reload();
						},
						error: function(e) {
							console.log('Header Internal Error: ' + e);
						}
					});
				}
			}
		} else {
			console.log('userid else if' + userid);

			//*check user existence
			if (currentURL.includes('internal=1') && currentURL.includes('fid=')) {
				const queryString = window.location.search;
				console.log(queryString);
				const urlParams = new URLSearchParams(queryString);
				const language = urlParams.get('language');
				const fedId = urlParams.get('fid');
				console.log('language', language);
				console.log('fedId', fedId);
				var checkUserAction = component.get('c.checkUserExistence');

				/*var fedIdDetails = currentURL.substring(currentURL.lastIndexOf('&') + 1, currentURL.length);
                        var fedId = fedIdDetails.split('=')[1];*/
				console.log(fedId);
				if (fedId != null && fedId != '') {
					checkUserAction.setParams({ fedId: fedId });
					checkUserAction.setCallback(this, function(response) {
						var state = response.getState();
						if (state === 'SUCCESS') {
							var userPresent = response.getReturnValue();
							if (userPresent) {
								if (
									currentURL.includes('internal=1') &&
									(userid == undefined ||
										(userid != undefined && varCommunityUserName.endsWith(communityUserNameEndWith)))
								) {
									console.log(component.get('v.internalLogInURL'));

									if (currentURL.includes('articlepreview')) {
										const cNumber = urlParams.get('c__number');
										let temp = currentURL.substring(
											currentURL.lastIndexOf('?') + 1,
											currentURL.indexOf('&')
										);
										/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?c__number=' + temp.substr(temp.lastIndexOf('=')+1);
                                                            internalLoginLink = internalLoginLink + '&internal=1';*/
										/* internalLoginLink = component.get("v.internalLogInURL") + 'articlepreview?language='+language+'&c__number=' + cNumber;
                                                            internalLoginLink = internalLoginLink + '&internal=1'; */
										internalLoginLink =
											ssoLink +
											'=' +
											encodeURIComponent(
												articleLink +
													'articlepreview?language=' +
													language +
													'&c__number=' +
													cNumber +
													'&internal=1'
											);
										console.log('internal login Link', internalLoginLink);
									} else {
										/* internalLoginLink = component.get("v.internalLogInURL") + 'article/' + currentURL.substring(currentURL.lastIndexOf('/') + 1, currentURL.indexOf('?'));
                                                            internalLoginLink = internalLoginLink + '?language='+language; */
										internalLoginLink =
											ssoLink +
											'=' +
											encodeURIComponent(
												articleLink +
													'article/' +
													currentURL.substring(
														currentURL.lastIndexOf('/') + 1,
														currentURL.indexOf('?')
													) +
													'?language=' +
													language
											);
										console.log('internal login Link', internalLoginLink);										
									}
									//window.location.assign(internalLoginLink);
									doInternalLogin();
								}
							}
						}
					});
					$A.enqueueAction(checkUserAction);
				}
			} else if (currentURL.includes('type=external') && !varCommunityUserName.endsWith(communityUserNameEndWith)) {
				let salesforceLogOutURL = 'https://' + window.location.hostname + logOutURL;
				$.ajax({
					url: salesforceLogOutURL,
					success: function(resp) {
						console.log('Header Internal' + resp);
					},
					error: function(e) {
						console.log('Header Internal Error: ' + e);
					}
				});
				window.reload();
			}
		}
		console.log('usernameTest', component.get('v.username'));
	}
});