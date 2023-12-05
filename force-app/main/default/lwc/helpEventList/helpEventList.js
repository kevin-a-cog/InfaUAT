/*
 * Name			:	helpEventList
 * Author		:	Saumya Gaikwad 
 * Created Date	: 	12/05/2022
 * Description	:	This LWC is used to filter events.

 Change History
 ***********************************************************************************************************************
 Modified By			Date			    Jira No.		 Description							                Tag
 ***********************************************************************************************************************
                            12/05/2022			 N/A	          Initial version.					                 N/A
 Saumya Gaikwad         29/08/2022          I2RT-6601         Years shown in the Filter should be dynamic             1
 Prashanth Bhat         04/11/2023          I2RT-9228         Pagination - Code Clean-up                             N/A
 Deeksha Shetty         04-NOV-2023         I2RT-9229         PROD - IN Community - Events - Last filter is not       2
                                                              getting removed
 */

import { api, LightningElement, track, wire } from "lwc";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";

export default class HelpEventList extends LightningElement {
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
    @api allEvents = []; //Tag 1
    @api firstFilter;
    @api secondFilter;
    @api thirdFilter;
    @api firstplaceholder;
    @api secondplaceholder;
    @api thirdplaceholder;
    @api selectedfilters;
    @api nosearchresult = false;
    @api selectedProduct = "DESC";
    eventtilepic = IN_StaticResource2 + "/eventlanding.png";
    eventsquarepic = IN_StaticResource2 + "/eventlandingsquare.png";

    selfilter;
    eventYearList; //Tag 1
    firstfilterselected;
    secondfilterselected;
    thirdfilterselected;
    @track hasRendered = false;
    @track isCloudReleaseEvent = false;
    MONTHS_LST = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    YEARS_LST = ['2020', '2021', '2022', '2023', '2024'];
    @track selectedMonth;
    @track selectedYear;
    @track currentCalendarSelection;
    @api showFilters;

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

    get months() {
        return [
            { label: 'Jan', value: '1' },
            { label: 'Feb', value: '2' },
            { label: 'Mar', value: '3' },
            { label: 'Apr', value: '4' },
            { label: 'May', value: '5' },
            { label: 'Jun', value: '6' },
            { label: 'Jul', value: '7' },
            { label: 'Aug', value: '8' },
            { label: 'Sep', value: '9' },
            { label: 'Oct', value: '10' },
            { label: 'Nov', value: '11' },
            { label: 'Dec', value: '12' },
        ];
    }


    get years() {
        /* Tag 1 Starts */
        let year = [];
        let yearlist = [];
        this.allEvents.forEach(function (result) {
            var activityDate = new Date(result.ActivityDate);
            if (!yearlist.includes(activityDate.getFullYear().toString())) {
                yearlist.push(activityDate.getFullYear().toString());
                year.push({ label: activityDate.getFullYear().toString(), value: activityDate.getFullYear().toString(), });
            }
        });
        this.eventYearList = yearlist;
        return year;
        /* Tag 1 Ends */
    }


    get sortByOption() {
        return [
            {
                label: "Ascending",
                value: "ASC",
            },
            {
                label: "Descending",
                value: "DESC",
            },
        ];
    }


    handlefirstChange(event) {
        let includesValueFirst = this.firstFilter.some(item => item.value == this.selfilter);
        let arr1 = [];
        if (event.detail) {
            arr1 = [...event.detail];
        }

        if (this.selectedfilters && includesValueFirst) {
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
        let includesValueSec = this.secondFilter.some(item => item.value == this.selfilter);
        let arr1 = [];
        if (event.detail) {
            arr1 = [...event.detail];
        }
        this.isCloudReleaseEvent = event.detail.includes('Cloud Release');
        if (!this.isCloudReleaseEvent) {
            this.selectedMonth = undefined;
            this.selectedYear = undefined;
            this.dispatchMonthYearSelection();
        }
        if (this.selectedfilters && includesValueSec) {
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

    handlethirdChange(event) {
        let includesValueThir = this.thirdFilter.some(item => item.value == this.selfilter);
        let arr1 = [];
        if (event.detail) {
            arr1 = [...event.detail];
        }

        if (this.selectedfilters && includesValueThir) {
            for (let item of this.selectedfilters) {
                if (this.selfilter && (item.toLowerCase() != this.selfilter.toLowerCase())) {
                    let selectFilter = {};
                    selectFilter.value = item;
                    this.thirdFilter.forEach(element => {
                        if (element.value.toLowerCase() == item.toLowerCase()) {
                            arr1.push(item);
                        }

                    });
                }
            }
        }
        let uniquearray = [...new Set(arr1)];
        this.dispatchEvent(
            new CustomEvent("thirdfilterchange", {
                detail: uniquearray,
            })
        );

    }



    handleUnfollow(event) {
        this.dispatchEvent(
            new CustomEvent("unfollow", {
                detail: event.currentTarget.dataset.value,
            })
        );
    }

    handleFollow(event) {
        this.dispatchEvent(
            new CustomEvent("follow", {
                detail: event.currentTarget.dataset.value,
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
        }

        this.isCloudReleaseEvent = false;
        this.selectedMonth = undefined;
        this.selectedYear = undefined;
        this.currentCalendarSelection = undefined;

        this.dispatchEvent(
            new CustomEvent("clearall", {
                detail: true,
            })
        );
    }


    handleFilterOption(event) {
        this.selfilter = event.currentTarget.dataset.id;

        //Tag 2 starts - Compare the closed filters against the selected filters
        let includesValueFirst = this.firstFilter.some(item => item.value == this.selfilter);
        let includesValueSec = this.secondFilter.some(item => item.value == this.selfilter);
        let includesValueThir = this.thirdFilter.some(item => item.value == this.selfilter);


        if (includesValueFirst || includesValueSec || includesValueThir) {

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

            let multiSelectPicklist3 = this.template.querySelector(
                '[data-id="in-third-filter"]'
            );
            if (multiSelectPicklist3) {
                multiSelectPicklist3.clearideafilter(event.currentTarget.dataset.id);
            }

            this.dispatchEvent(
                new CustomEvent("clearselectfilter", {
                    detail: event.currentTarget.dataset.id,
                })
            );
            this.selfilter = undefined;

        }
        //Tag 2 ends

        let monthStr = this.selfilter.substring(0, 3);
        let removeCalendarFilter = false;

        if (this.selfilter.includes('Cloud Release')) {
            this.isCloudReleaseEvent = false;
            this.selectedMonth = undefined;
            this.selectedYear = undefined;
            removeCalendarFilter = true;
        } else if (this.MONTHS_LST.includes(monthStr)) {
            this.selectedMonth = undefined;
            this.selectedYear = undefined;
            removeCalendarFilter = true;
        }
        /* Tag 1 Starts */
        else if (this.eventYearList.includes(this.selfilter.substring(0, 4))) {
            this.selectedMonth = undefined;
            this.selectedYear = undefined;
            removeCalendarFilter = true;
        }
        /* Tag 1 Ends */
        if (removeCalendarFilter) {
            this.dispatchEvent(
                new CustomEvent("monthyearselect", {
                    detail: {
                        value: undefined,
                        previousValue: this.currentCalendarSelection
                    }
                })
            );
            this.currentCalendarSelection = undefined;
            this.selfilter = undefined;
        }
    }

    toggleTileView() {
        this.isTileView = true;
    }

    toggleListView() {
        this.isTileView = false;
    }

    joinEvent(event) {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Join event - ' + event.currentTarget.dataset.value);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        this.dispatchEvent(
            new CustomEvent("joinevent", {
                detail: event.currentTarget.dataset.id,
            })
        );
    }

    handleSortBy(event) {
        this.dispatchEvent(
            new CustomEvent("sortby", {
                detail: event.detail.value,
            })
        );
    }

    handleMonthSelection(event) {
        this.selectedMonth = event.detail.value;
        if (this.selectedMonth != null && this.selectedMonth != undefined || this.selectedYear != null && this.selectedYear != undefined) {

            this.dispatchMonthYearSelection();
        }
    }

    handleYearSelection(event) {
        this.selectedYear = event.detail.value;
        if (this.selectedMonth != null && this.selectedMonth != undefined || this.selectedYear != null && this.selectedYear != undefined) {

            this.dispatchMonthYearSelection();
        }
    }

    dispatchMonthYearSelection() {
        let value;
        let previousValue;
        if (this.currentCalendarSelection != undefined) {
            previousValue = this.currentCalendarSelection;
        }
        if (this.selectedMonth == undefined || this.selectedYear == undefined) {
            /* Tag 1 Starts */
            if (this.selectedYear == undefined) {
                value = this.selectedMonth;
                let monthName = this.MONTHS_LST[this.selectedMonth - 1];
                this.currentCalendarSelection = monthName;
                this.dispatchEvent(
                    new CustomEvent("monthyearselect", {
                        detail: {
                            value: value,
                            filterName: this.currentCalendarSelection,
                            previousValue: previousValue
                        },
                    })
                );
            } else if (this.selectedMonth == undefined) {
                value = this.selectedYear;
                this.currentCalendarSelection = this.selectedYear;
                this.dispatchEvent(
                    new CustomEvent("monthyearselect", {
                        detail: {
                            value: value,
                            filterName: this.currentCalendarSelection,
                            previousValue: previousValue
                        },
                    })
                );
            }
            /* Tag 1 Ends */
        } else {
            value = this.selectedMonth + '' + this.selectedYear;
            let monthName = this.MONTHS_LST[this.selectedMonth - 1];
            this.currentCalendarSelection = monthName + ' ' + this.selectedYear;
            this.dispatchEvent(
                new CustomEvent("monthyearselect", {
                    detail: {
                        value: value,
                        filterName: this.currentCalendarSelection,
                        previousValue: previousValue
                    },
                })
            );
        }


    }

    handleOnClick(event) {
        let name = event.currentTarget.dataset.value;
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Learn More - Events name - ' + name);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
    }
}