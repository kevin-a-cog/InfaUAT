/*
* Name : HelpChangeRequestFilter
* Author : Deeksha Shetty
* Created Date : September 20 2023
* Description : This Component is the linking component for helpMultiPicklist and helpChangeRequestLanding.
Change History
**************************************************************************************************************************************************************
Modified By          Date           Jira No.                           Description                                                              Tag
Deeksha Shetty      20/09/2023      I2RT- Initial version.                                                                                       N/A
Chetan Shetty       24/10/2023      I2RT-9269                          CR enhancement on list/tile view 
                                                                       - Introducing Product/Reported version/Fixed version/Current status       Html file
Prashanth Bhat      26/10/2023      I2RT-9228                          Pagination - Removed redundent code                                                                       
****************************************************************************************************************************************************************

*/

import { LightningElement, api, track } from 'lwc';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";


export default class HelpChangeRequestFilter extends LightningElement {
    @track isFollowing = false;
    @track isTileView = false;
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
    selfilter;
    firstfilterselected;
    secondfilterselected;
    @track hasRendered = false;
    @api showFilters;
    keyvalpair;
    newSelectedFilters;


    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
        }
    }

    @api
    clearAll() {
        this.hasRendered = false;
        this.handleClearAll();
    }


    handlefirstChange(event) {
        this.firstfilterselected = event.detail;
        console.log('FirstFilterSelected>'+JSON.stringify(this.firstfilterselected));
        let arr1 = [];

        if (event.detail) {
            arr1 = [...event.detail];
        }

        if (this.selectedfilters) {
            for (let item of this.selectedfilters) {
                if (this.selfilter && (item.toLowerCase() != this.selfilter.toLowerCase())) {
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


    handlesecondChange(event) {
        this.secondfilterselected = event.detail;
        console.log('Secondfilterselected>'+JSON.stringify(this.secondfilterselected));
        let arr1 = [];

        if (event.detail) {
            arr1 = [...event.detail];
        }

        if (this.selectedfilters) {
            for (let item of this.selectedfilters) {
                if (this.selfilter && (item.toLowerCase() != this.selfilter.toLowerCase())) {
                    let selectFilter = {};
                    selectFilter.value = item;
                    this.secondFilter.forEach(element => {
                        if (element.value.toLowerCase() == item.toLowerCase()) {
                            arr1.push(item);
                        }

                    });
                }
            }
        }

        let uniquearray = [...new Set(arr1)];

        this.dispatchEvent(
            new CustomEvent("secondfilterchange", {
                detail: uniquearray,
            })
        );

    }


    handleChange1(event) {
        this.dispatchEvent(
            new CustomEvent("sortbyfilterchange", {
                detail: event.detail,
            })
        );
    }



    handleClearAll() {
        this.dispatchEvent(
            new CustomEvent("clearall", {
                detail: true,
            })
        );
        let multiSelectPicklist = [
            ...this.template.querySelectorAll("c-help-multi-pick-list"),
        ];
        if (multiSelectPicklist) {
            for (let item in multiSelectPicklist) {
                multiSelectPicklist[item].clearSelection();
            }
            multiSelectPicklist[0].clear();
            if (multiSelectPicklist.length > 1) {
                multiSelectPicklist[1].clear();
            }
        }
    }

    handleFilterOption(event) {
        this.selfilter = event.currentTarget.dataset.id;
        console.log('selfileter+>'+JSON.stringify(this.selfilter))

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

    handleSelectFilters(evt) {
        for (let item of this.selectedfilters) {
            if (item.toLowerCase() != evt.toLowerCase()) {
                let selectFilter = {};
                selectFilter.value = item;
                this.dispatchEvent(
                    new CustomEvent("handleselectfilter", {
                        detail: selectFilter,
                    })
                );

            }
        }
    }


    toggleTileView() {
        this.isTileView = true;
    }
    toggleListView() {
        this.isTileView = false;
    }

    handleOnClick(event) {
        let name = event.currentTarget.dataset.value;
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Learn More - Ideas name - ' + name);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
    }
}