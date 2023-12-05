import { LightningElement, api, track } from 'lwc';
import getLinkItems from '@salesforce/apex/LinkUtilityHandler.getLinkItems';
import getLinkUtilitiesMTD from '@salesforce/apex/LinkUtilityHandler.getLinkUtilitiesMTD';
import Id from '@salesforce/user/Id';

//Core.
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getLinkDeleted from '@salesforce/apex/LinkUtilityHandler.getLinkDeleted';

export default class LinkUtility extends NavigationMixin(LightningElement) {

	//Private variables.
	boolCustomCSSLoaded;
	boolDisableRefreshButton = false;

    @api AppName;
    linkUtilitiesTemp = [];
    @track linkUtilities = [];
    @track linkItems = [];
    UserId = Id;

    connectedCallback() {
		this.loadRecords();
    }

    loadRecords() {
		this.boolDisableRefreshButton = true;
		let objParent = this;
		let boolHasPersonalGroup = false;
		this.linkItems = [];
		this.linkUtilitiesTemp = [];
		this.linkUtilities = [];
		this.boolCustomCSSLoaded = false;

        getLinkUtilitiesMTD()
            .then(result => {
                //Promise for getLinkUtilitiesMTD();
                console.log('link Utilities Temp = ' + JSON.stringify(result));
                result.forEach(item => {
                    this.linkUtilitiesTemp.push({ groupName: item.Group_Name__c, sortOrder: item.Sort_Order__c, icon: item.Icon__c ,linkItems: [] });
                });
				this.linkUtilitiesTemp.push({ groupName: "Personal", sortOrder: 999999, icon: "", linkItems: []});

                return getLinkItems({ appName: this.AppName, userId: this.UserId });
            })
            .then(result => {
                //Promise for getLinkItems();
                console.log('link items = ' + JSON.stringify(result));

                this.linkItems = result;

                result.forEach(linkItem => {
                    this.linkUtilitiesTemp.forEach(linkUtility => {
                        if (linkUtility['groupName'] == linkItem.objLink.Group_Name__c) {
                            if(linkUtility['linkItems'] == undefined){
                               linkUtility['linkItems'] = [linkItem];
                            }
                            else if(linkUtility['linkItems'] != undefined){
                               linkUtility['linkItems'].push(linkItem);
                            }
                        }
                    })
                });

                //console.log('linkUtilitiesTemp = '+JSON.stringify(this.linkUtilitiesTemp));
                //console.log('this.linkUtilitiesTemp.length -> '+this.linkUtilitiesTemp.length);

                for(var i=0;i<this.linkUtilitiesTemp.length;i++){
                    if(this.linkUtilitiesTemp[i]['linkItems'] != undefined && this.linkUtilitiesTemp[i]['linkItems'].length > 0){
                        this.linkUtilitiesTemp[i]['Name_and_Count'] = this.linkUtilitiesTemp[i]['groupName'] +' ('+ this.linkUtilitiesTemp[i]['linkItems'].length +')';
						this.linkUtilitiesTemp[i]['linkItems'].forEach(objLink => {
							objLink.strSearchableValue = objLink.objLink.Name.toLocaleLowerCase();
							if(objUtilities.isNotBlank(objLink.objLink.Link_URL__c)) {
								objLink.strSearchableValue = objLink.strSearchableValue + " " + objLink.objLink.Link_URL__c.toLocaleLowerCase();
							}
						});
                        this.linkUtilities.push(this.linkUtilitiesTemp[i]);
                    }
                }
                
                //Now we check if the groups have "Personal", otherwise, we add it.
				this.linkUtilities.forEach(objGroup => {
					if(objGroup.groupName.toLowerCase() === "personal") {
						objGroup.boolCanAdd = true;
						boolHasPersonalGroup = true;
					}

					//We check the permissions to add them to the Group.
					if(objUtilities.isNotNull(objGroup.linkItems)) {
						objGroup.linkItems.forEach(objLink => {
							if(objLink.boolCanAdd) {
								objGroup.boolCanAdd = true;
							}
						});
					}
				});
				if(!boolHasPersonalGroup) {
					this.linkUtilities.push({
						groupName: "Personal",
						Name_and_Count: "Personal (0)",
						boolCanAdd: true,
						sortOrder: 999999
					});
				}

                if(this.linkUtilities.length == 0){
                    this.linkUtilities = undefined;
                }

            })
            .catch(error => {
                //Promise for getLinkItems();
                console.log('getLinkItems error = ' + JSON.stringify(error));
            })
            .catch(error => {
                //Promise for getLinkUtilitiesMTD();
                console.log('getLinkUtilitiesMTD error = ' + JSON.stringify(error));
            }).finally(() => {
				objParent.boolDisableRefreshButton = false;
			});
    }

/* 
********* When a Link is selected, dispatch event to aura cmp to process URL and open the link ********* 
*/
    handleSelect(event) {
        //console.log('event.detail = ' + JSON.stringify(event.currentTarget.getAttribute('data-name')));
        const selectedId = event.currentTarget.getAttribute('data-name');  
        
        //alert(selectedId);
        
        var linkItemURL = '';
        var targetOpen = '';
        this.linkItems.forEach(item =>{
            if(item.objLink.Id === selectedId){
                linkItemURL = item.objLink.Link_URL__c;
                targetOpen = item.objLink.Target__c;
            }
        });

        console.log('linkItemURL = '+linkItemURL+'\ntargetOpen = '+targetOpen);

        //Dispatch event the Aura Component to process URL and open the Link
        const valueSelectedEvent = new CustomEvent('handleSelection', { detail: { URL: linkItemURL, Target: targetOpen } });
        this.dispatchEvent(valueSelectedEvent);
        
    }

	/* 
	********* Show and hide accordion content on click *********   
	*/
		handleAccordionClick(event){
	
			var rightArrow;
			var leftArrow;
			var showAccContent;
	
			for(var i=0; i<event.currentTarget.children.length; i++){
				if(event.currentTarget.children[i].classList.contains('right-arrow')){
					rightArrow = event.currentTarget.children[i];
				}
				else if(event.currentTarget.children[i].classList.contains('left-arrow')){
					leftArrow = event.currentTarget.children[i];
				}
			}
	
			
			if(!rightArrow.classList.contains('hide')){
				rightArrow.classList.add('hide');
				leftArrow.classList.contains('hide') == true ? leftArrow.classList.remove('hide') : 'do nothing';
			}
			else{
				leftArrow.classList.contains('hide') == false ? leftArrow.classList.add('hide') : 'do nothing';
				rightArrow.classList.contains('hide') == true ? rightArrow.classList.remove('hide') : 'do nothing';
			}
			
			showAccContent = this.template.querySelector("div.c-accordion-content[data-group-child-container='" + event.currentTarget.getAttribute("data-group-child-container") + "']");
			if(showAccContent.classList.contains('hide')){
				showAccContent.classList.remove('hide');
			}
			else if(!showAccContent.classList.contains('hide')){
				showAccContent.classList.add('hide');
			}
		}
	
	/**
	 * This method gets executed on rendered callback.
	 */
	renderedCallback() {
		let objParent = this;

		//We execute this only once.
		if(!objParent.boolCustomCSSLoaded) {

			//We set the dynamic HTML values.
			if(objUtilities.isNotNull(objParent.linkUtilities) && objParent.linkUtilities.length > 0) {

				//We iterate over the links.
				objParent.linkUtilities.forEach(objGroupLink => {

					//We set the Group label.
					objParent.template.querySelector("span[data-group='" + objGroupLink.groupName + "']").innerHTML = objGroupLink.Name_and_Count;

					//We set the Link labels.
					if(objUtilities.isNotNull(objGroupLink.linkItems) && objGroupLink.linkItems.length > 0) {
						objGroupLink.linkItems.forEach(objLink => {
							objParent.template.querySelector("a[data-link='" + objLink.objLink.Id + "']").innerHTML = objLink.objLink.Name;
						});
					}
				});

				//We avoid executing this code again.
				objParent.boolCustomCSSLoaded = true;
			}
		}
	}

	/*
	 Method Name : search
	 Description : This method searches for a given keyword in the list of links.
	 Parameters	 : Object, called from search, objEvent Event.
	 Return Type : None
	 */
	search(objEvent) {
		let boolExpandParent;
		let strSearchTerm = objEvent.target.value;
		let objRegEx;
		let objExpandableParent;
		let objParent = this;
		if(objUtilities.isNotNull(objParent.linkUtilities)) {
			objParent.linkUtilities.forEach(objGroup => {
				boolExpandParent = false;

				//We create the RegEx, if needed.
				if(objUtilities.isNotBlank(strSearchTerm)) {
					objRegEx = new RegExp(strSearchTerm, "i");
				}

				//Now we check Group label.
				if(objUtilities.isBlank(strSearchTerm) || !objGroup.Name_and_Count.toLocaleLowerCase().includes(strSearchTerm.toLocaleLowerCase())) {
					objParent.template.querySelector("span[data-group='" + objGroup.groupName + "']").innerHTML = objGroup.Name_and_Count;
				} else {
					boolExpandParent = true;
					objParent.template.querySelector("span[data-group='" + objGroup.groupName + "']").innerHTML = objParent.highlightValue(objGroup.Name_and_Count, objRegEx);
				}

				//Now we check each link.
				if(objUtilities.isNotNull(objGroup.linkItems)) {
					objGroup.linkItems.forEach(objLink => {
						if(objUtilities.isBlank(strSearchTerm) || !objLink.strSearchableValue.includes(strSearchTerm.toLocaleLowerCase())) {
							objParent.template.querySelector("a[data-link='" + objLink.objLink.Id + "']").innerHTML = objLink.objLink.Name;
						} else {
							boolExpandParent = true;
							objParent.template.querySelector("a[data-link='" + objLink.objLink.Id + "']").innerHTML = objParent.highlightValue(objLink.objLink.Name, objRegEx);
						}
					});
				}

				//Now we expand the parent, if needed.
				if(boolExpandParent) {
					objExpandableParent = objParent.template.querySelector("span[data-group-icon-close='" + objGroup.groupName + "']");
					if(objExpandableParent.classList.contains("hide")) {
						objExpandableParent.classList.remove("hide");
						objParent.template.querySelector("div.c-accordion-content[data-group-child-container='" + objGroup.groupName + "']").classList.remove("hide");
						objParent.template.querySelector("span[data-group-icon-open='" + objGroup.groupName + "']").classList.add("hide");
					}
				}
			});
		}
	}

	/*
	 Method Name : highlightValue
	 Description : This method higlights the given word (regex) of the provided string.
	 Parameters	 : String, called from highlightValue, strNewInnerHTMLValue String to analyze.
	 			   String, called from highlightValue, objRegEx Word.
	 Return Type : String.
	 */
	highlightValue(strNewInnerHTMLValue, objRegEx) {
		let lstResults;
		if(objUtilities.isNotBlank(strNewInnerHTMLValue) && objUtilities.isNotNull(objRegEx)) {
			lstResults = strNewInnerHTMLValue.match(objRegEx);
			if(objUtilities.isNotNull(lstResults) && lstResults.length > 0) {
				lstResults.forEach(strFoundElement => {
					strNewInnerHTMLValue = strNewInnerHTMLValue.replaceAll(strFoundElement, "<mark>" + strFoundElement + "</mark>").replaceAll(" ", "&nbsp;");
				});
			}
		}
		return strNewInnerHTMLValue;
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the selected action.
	 Parameters	 : Object, called from executeAction, objEvent Event.
	 Return Type : None
	 */
	executeAction(objEvent) {
		let strRecordId = objEvent.target.getAttribute("data-id");
		let objParent = this;
		switch(objEvent.detail.value) {
			case "add":
				this[NavigationMixin.Navigate]({
					type:'standard__objectPage',
					attributes: {
						objectApiName: 'Link__c',
						actionName: 'new'
					},
					state: {
						defaultFieldValues: encodeDefaultFieldValues({
							Group_Name__c: objEvent.target.getAttribute("data-group")
						})
					}
				});
        		this.dispatchEvent(new CustomEvent('handleActionExecution', { 
					detail: null
				}));
			break;
			case "edit":
				this[NavigationMixin.Navigate]({
					type:'standard__recordPage',
					attributes: {
						recordId: strRecordId,
						objectApiName: 'Link__c',
						actionName: 'edit'
					}
				});
				this.dispatchEvent(new CustomEvent('handleActionExecution', { 
					detail: null
				}));
			break;
			case "delete":
				if(confirm("Are you sure you like delete the Link " + objEvent.target.getAttribute("data-label") + "?")) {
					getLinkDeleted({
						lstRecords: [{
							Id: strRecordId
						}]
					}).then(() => {
						objParent.dispatchEvent(new CustomEvent('refresh', { 
							detail: null
						}));
					});
				}
			break;
		}
	}
}