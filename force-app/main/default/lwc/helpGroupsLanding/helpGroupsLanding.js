/*
 * Name			:	EventDetail
 * Author		:	Narpavi Prabu
 * Created Date	: 	8/02/2022	
 * Description	:	This LWC is used for group landing page.

 Change History
 **********************************************************************************************************
 Modified By			  Date			     Jira No.		          Description							                 Tag
 **********************************************************************************************************
 Narpavi Prabu		  8/02/2022		 	 Initial version.		  N/A
 Prashanth Bhat		  19/10/2023		 I2RT-9228		        Pagination (Removed redundent logic)
 */
import { LightningElement, wire, api, track } from "lwc";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import userId from "@salesforce/user/Id";
import getUserType from "@salesforce/apex/helpIdeasController.getUserType";
import accountUrl from "@salesforce/label/c.IN_account_login";

export default class HelpGroupsLanding extends LightningElement {
    @track isFollowing = false;
    @track isTileView = true;
    @api communityLogo;
    addLogo = IN_StaticResource + "/add.png";
    minusLogo = IN_StaticResource + "/minus.png";
    tile = IN_StaticResource + "/tile-grey-v1.svg";
    color_tile = IN_StaticResource + "/tile-color-v1.svg";
    list = IN_StaticResource + "/list-grey-v1.svg";
    color_list = IN_StaticResource + "/list-color-v1.svg";
    @api resultSet = [];
    @api firstFilter;
    @api secondFilter;
    @api firstplaceholder;
    @api secondplaceholder;
    @api selectedfilters;
    @api productList;
    @api selectedProduct;
    @api nosearchresult = false;
    isGuestUser = false;
    selfilter;
    @api showFilters;

  connectedCallback() {
    this.getUserType();
  }

  @api
  clearAll(){
    this.handleClearAll();
  }

  handlefirstChange(event) {  
    let arr1 = [];
    if (event.detail) {
        arr1 = [...event.detail];
    }
   
    if (this.selectedfilters) {
        for (let item of this.selectedfilters) {
            if (this.selfilter && (item.toLowerCase() != this.selfilter.toLowerCase())  ) {
                let selectFilter = {};
                selectFilter.value = item;
                this.firstFilter.forEach(element => {
                    if (element.value.toLowerCase() == item.toLowerCase()) {
                        arr1.push(item);
                    }

                });
            }
        }
    }
    let uniquearray = [...new Set(arr1)];
    this.dispatchEvent(
        new CustomEvent("firstfilterchange", {
            detail: uniquearray,
            })
        );
    }

  openLoginPage() {
    window.open(accountUrl, "_self");
  }

    handlesecondChange(event) {
        this.dispatchEvent(
            new CustomEvent("secondfilterchange", {
                detail: event.detail,
            })
        );
  }

  getUserType() { 
    if (userId === "undefined" || userId === "undefined" || !userId) {
      this.currentUserType = "Guest";
      this.isGuestUser = true;
    } else {
      getUserType({ userId: userId })
        .then((result) => {
          if (result) {
            this.currentUserType = result;
            if (this.currentUserType == "Guest") this.isGuestUser = true;
          }
        })
        .catch((error) => {
          console.log(error.body);
        });
    }
  }

    handleChange1(event) {
        this.dispatchEvent(
            new CustomEvent("sortbyfilterchange", {
                detail: event.detail,
            })
        );
    }

  handleClearAll() {
    let multiSelectPicklist = [
      ...this.template.querySelectorAll("c-help-multi-pick-list"),
    ];
    if (multiSelectPicklist) {
      for (let item in multiSelectPicklist) {
        multiSelectPicklist[item].clearSelection();
        multiSelectPicklist[item].clear();
      }
        this.dispatchEvent(
            new CustomEvent("clearall", {
                detail: true,
            })
        );
        }
    }

    handleFilterOption(event) {
    this.selfilter = event.currentTarget.dataset.id;
        this.dispatchEvent(
          new CustomEvent("clearselectfilter", {
            detail: event.currentTarget.dataset.id,
          })
        );
        let multiSelectPicklist = this.template.querySelector(
          '[data-id="in-first-filter"]'
        );
        if (multiSelectPicklist) {
      multiSelectPicklist.clearideafilter(event.currentTarget.dataset.id);
        }
        let multiSelectPicklist2 = this.template.querySelector(
          '[data-id="in-second-filter"]'
        );
        if (multiSelectPicklist2) {
      multiSelectPicklist2.clearideafilter(event.currentTarget.dataset.id);
    }
  }

  toggleTileView() {
    this.isTileView = true;
  }
  
  toggleListView() {
    this.isTileView = false;
  }

  handleOnClick(event){
    let name = event.currentTarget.dataset.value;
    /** START-- adobe analytics */
    try {
       util.trackButtonClick('IUG - '+name);
   }
   catch (ex) {
       console.error(ex.message);
   }
   /** END-- adobe analytics*/
}
}