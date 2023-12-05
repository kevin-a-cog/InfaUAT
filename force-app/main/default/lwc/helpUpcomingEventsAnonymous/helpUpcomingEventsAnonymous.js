import { api, LightningElement, wire } from "lwc";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import addUserToEvent from "@salesforce/apex/helpEventsController.addUserToEvent";
import getUpcomingEvents from "@salesforce/apex/helpEventsController.getUpcomingEvents";
import userId from "@salesforce/user/Id";
import getUserType from "@salesforce/apex/helpGroupsController.getUserType";
import IN_account_login from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';

export default class helpUpcomingEventsAnonymous extends LightningElement {
  eventtilepic = IN_StaticResource2 + "/eventlanding.png";
  resultSet;
  recId;
  disablebutton = false;
  isGuestUser = false;
  eventLanding = 'event-landing';
  currentUserType;

  constructor() {
    super();
    this.showUpcomingEvents();
    this.getUserType();
  }

  showUpcomingEvents() {
    getUpcomingEvents()
      .then((result) => {
        this.resultSet = result;
        console.log('Resultset='+JSON.stringify(this.resultSet))
      })
      .catch((error) => {
        console.log(error.body);
      });
  }

  getUserType() {
    if (userId == undefined ) {
      this.currentUserType = "Guest";
      this.isGuestUser = true;
    } 
  }

  joinEvent(event) {
     /** START-- adobe analytics */
     try {
      util.trackButtonClick("Homepage || Upcoming events || join event || "+event.currentTarget.dataset.value);
      }
      catch (ex) {
          console.error(ex.message);
      }
      /** END-- adobe analytics*/
    let eventId = event.currentTarget.dataset.id;
    console.log("event Id from event action=" + JSON.stringify(eventId));
    let statusmsg;
    if (userId == undefined) {
        var redirectURI = IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href) + 'eventdetails?id=' + eventId;
        window.location.assign(redirectURI);
    } else {
      addUserToEvent({
        eventId: eventId,
        userId: userId,
      })
        .then((result) => {
          console.log("handleJoinEvent, result = ", JSON.stringify(result));
          statusmsg = result.statusMessage;
          if (result.returnMessage == "User Added") {
            sendMail({ userId: userId, eventId: eventId })
              .then((result1) => {
                if (result1) {
                  let res = JSON.stringify(result1);
                }
              })
              .catch((error) => {
                console.log(error.body.message);
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
          console.log("handleJoinEvent Error => " + JSON.stringify(error));
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
  }
}