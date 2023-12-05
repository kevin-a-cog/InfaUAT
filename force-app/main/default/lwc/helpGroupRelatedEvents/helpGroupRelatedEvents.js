/*
 * Name         :   HelpGroupRelatedEvents
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component will be used to show related events on a User group landing page specific to that UG.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     Initial             Initial version.                                          NA
 Utkarsh Jain           19-JULY-2021    I2RT-6756           Related events under user group should be Ascending.      1
 */
import { api, LightningElement } from "lwc";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import getGroupRelatedEvents from "@salesforce/apex/helpEventsController.getGroupRelatedEvents";
import addUserToEvent from "@salesforce/apex/helpEventsController.addUserToEvent";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import userId from "@salesforce/user/Id";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import returnUsersWhoJoinedEvents from "@salesforce/apex/helpEventsController.returnUsersWhoJoinedEvents";
import sendMail from "@salesforce/apex/helpEventsController.sendMail";

export default class HelpGroupRelatedEvents extends LightningElement {
    eventtilepic = IN_StaticResource2 + "/eventlanding.png";
    resultSet;
    @api recordId;
    disablebutton = false;
    prfName;
    recId;
    showRelatedEvents = false;

    connectedCallback() {
        this.showRelatedGroupEvents();
    }

    showRelatedGroupEvents() {
        if (userId == undefined) this.disablebutton = true;
        getGroupRelatedEvents({ recordId: this.recordId })
            .then((result) => {
                if (result[0].NoEventsData) {
                    this.showRelatedEvents = false;
                } else {
                    this.resultSet = result;
                    this.helpUsersEvent();
                }
            })
            .catch((error) => {
                console.error(error.body);
            });
    }

    helpUsersEvent() {
        returnUsersWhoJoinedEvents({ userId: userId })
            .then((result) => {
                if (result) {
                    let disable = JSON.parse(JSON.stringify(this.resultSet));
                    this.joinedeventusers = result;
                    disable.forEach((item) => {
                        this.joinedeventusers.forEach((element) => {
                            if (element.EventId == item.Id) {
                                item.disablebutton = true;
                            }
                        });
                    });
                    setTimeout(() => {
                        this.showRelatedEvents = true;
                        this.resultSet = disable;
                        this.setItemsForCarousel();
                    }, 3000);
                }
            })
            .catch((error) => {
                console.error(error.body);
            });
    }

    joinEvent(event) {
        let eventId = event.currentTarget.dataset.id;
        let statusmsg;
        addUserToEvent({
            eventId: eventId,
            userId: userId,
        })
            .then((result) => {
                statusmsg = result.statusMessage;
                if (result.returnMessage == "User Added") {
                    sendMail({ userId: userId, eventId: eventId })
                        .then((result1) => {
                            if (result1) {
                                let res = JSON.stringify(result1);
                                let disable = JSON.parse(JSON.stringify(this.resultSet));
                                disable.forEach((item) => {
                                    if (eventId == item.Id) {
                                        item.disablebutton = true;
                                    }
                                });
                                this.resultSet = disable;
                            }
                        })
                        .catch((error) => {
                            console.error(error.body.message);
                        });
                    // Show toast message
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success : ",
                            message: statusmsg,
                            variant: "success",
                        })
                    );
                } else if (result.returnMessage == "Past Event") {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error : ",
                            message: statusmsg,
                            variant: "Error",
                        })
                    );
                }
            })
            .catch((error) => {
                console.error("handleJoinEvent Error => " + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error : ",
                        message:
                            "Error occurred, please contact system administrator. Error Message: " +
                            error.body.message,
                        variant: "error",
                    })
                );
            });
    }

    setItemsForCarousel() {
        Promise.all([
            loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
            loadStyle(
                this,
                IN_StaticResource + "/carousel/owl.theme.default.min.css"
            ),
            loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
        ])
            .then(() => {
                this.loadCarousel();
            })
            .catch((error) => {
                console.error("Error Occured", error);
            });
    }

    loadCarousel() {
        const carousel = this.template.querySelector(
            'div[class="owl-carousel owl-theme"]'
        );
        window.$(carousel).owlCarousel({
            items: 3,
            loop: false,
            margin: 30,
            dots: false,
            autoplayHoverPause: true,
            responsiveClass: true,
            navText: [
                '<div class="carousel-left-arrow"></div>',
                '<div class="carousel-right-arrow"></div>',
            ],
            responsive: {
                0: {
                    items: 1,
                    nav: false,
                    dots: true,
                },
                600: {
                    items: 3,
                    nav: true,
                    slideBy: 3,
                },
                1000: {
                    items: 3,
                    nav: true,
                    slideBy: 3,
                },
            },
        });
    }
}