/*
* Name         :   helpUpcomingEvents
* Author       :   Saumya Gaikwad
* Created Date :   21/09/2022
* Description  :   JS for event component in authenticated landing page.

Change History
*********************************************************************************************************************
Modified By            Date            Jira No.        Description                                                Tag
*********************************************************************************************************************
Saumya Gaikwad      21/09/2022      I2RT-7048       Events component changes in authenticated landing page         1
Prashanth Bhat      22/08/2023      I2RT-8834       Added logic to handle timezone offset.                         2
*/
import { LightningElement, track } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import USER_ID from "@salesforce/user/Id";
import getUpcomingEventsByUser from '@salesforce/apex/helpEventsController.getUpcomingEventsByUser';
import fetchJoinedEvents from '@salesforce/apex/helpEventsController.fetchJoinedEvents';
import joinEvent from '@salesforce/apex/helpEventsController.addUserToEvent';
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import getMetadataRecord from '@salesforce/apex/helpUserRelatedList.getMetadataRecordFromCustomLabel';
import getUpcomingEventsByTitle from '@salesforce/apex/helpEventsController.getUpcomingEventsByTitle';

export default class HelpUpcomingEvents extends LightningElement {

  @track upcomingEvents = [];
  @track userEvents = [];
  @track selectedDate;
  @track showEventsSpinner = false;
  @track communityUrl;
  @track eventsLandingPage;
  @track joinEvents = [];
  @track userAcceptedEvents = [];
  @track eventTitles = [];
  error;
  timeZone = TIME_ZONE;
  @track fullCalendarJsInitialised = false;
  eventCalendar = IN_StaticResource2 + "/calendar.png";
  eventTime = IN_StaticResource2 + "/clock.png";
  eventLocation = IN_StaticResource2 + "/location.png";


  get showNoEvents() {
    return (this.userEvents.length <= 0) && !this.showEventsSpinner;
  }

  get showNoUpcomingEvents() {
    return (this.upcomingEvents.length <= 0) && !this.showEventsSpinner;
  }

  connectedCallback() {

    this.selectedDate = this.getDate(new Date());
    this.getEvents(this.selectedDate,false);

    getMetadataRecord({ metadataName: 'community_url' })
      .then(result => {
        this.communityUrl = result.community_url__c;
        this.eventsLandingPage = this.communityUrl + 'event-landing?active=1';
      })
      .catch(error => {
        console.error(' community_url Metadata error ==> ' + JSON.stringify(error));
      });

    //JOined events
    fetchJoinedEvents({ userId: USER_ID })
      .then(result => {
        console.log('called result ->', result);
        this.joinEvents = result;
        for (let i = 0; i < this.joinEvents.length; i++) {
          let event = {
            title: this.joinEvents[i].subject,
            start: this.joinEvents[i].startDateTime,
            end: this.joinEvents[i].startDateTime,
            allDay: false,
            editable : false
          };
          this.userAcceptedEvents.push(event);
        }

        // Performs this operation only on first render
        if (!this.fullCalendarJsInitialised || this.fullCalendarJsInitialised == null || this.fullCalendarJsInitialised == '' || this.fullCalendarJsInitialised == undefined) {
          this.fullCalendarJsInitialised = true;
          Promise.all([
            loadScript(this, FullCalendarJS + '/FullCalendarJS/jquery.min.js'),
            loadScript(this, FullCalendarJS + '/FullCalendarJS/moment.min.js'),
            loadScript(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.js'),
            loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.min.css'), ,
            //  loadStyle(this, FullCalendarJS + '/FullCalendarJS/fullcalendar.print.min.css')
          ])
            .then(() => {
              // Initialise the calendar configuration
              setTimeout(() => {
                this.initialiseFullCalendarJs();                
              }, 2000);
            })
            .catch(error => {
              console.error("error", error);
            });
        } else {
          return;
        }
        this.error = undefined;
      })
      .catch(error => {
        console.error('error - ' + error);
        this.error = error;
        this.joinEvents = undefined;
      });


  }

  initialiseFullCalendarJs() {
    const ele = this.template.querySelector('div.fullcalendarjs');
    //var YM = todayDate.format('YYYY-MM');
    // eslint-disable-next-line no-undef
    let self = this;
    $(ele).fullCalendar({
      header: { left: 'prev', center: 'title', right: 'next' },
      // defaultDate: '2020-03-12', 
      //timeZone: this.timeZone, 
      defaultDate: new Date(), // default day is today
      navLinks: false, // can click day/week names to navigate views
      editable: true,
      selectable: true,
      eventLimit: 5, // allow "more" link when too many events
      events: this.userAcceptedEvents,
      eventAfterRender: function (event, element, view) {
        // Enable for the 'month' view only.
        if ('month' !== view.name) {
          return;
        }
        var eventEnd = event.end == undefined ? moment(event.start, 'YYYY-MM-DD') : moment(event.end, 'YYYY-MM-DD');
        var eventStart = moment(event.start, 'YYYY-MM-DD'),
          duration = moment.duration(eventEnd.diff(eventStart)),
          row = element.closest('.fc-row'),
          eventStartClone = eventStart.clone(), i, c;

        var title = event.title;

        if (eventEnd.isValid()) {
          title += ' (' + $.fullCalendar.formatRange(eventStart, eventEnd, 'MMM D YYYY') + ')';
        }

        var today = new Date();
        var dd = String(today.getUTCDate()).padStart(2, '0');
        var mm = String(today.getUTCMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getUTCFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        // Add the event's "dot", styled with the appropriate background color.
        for (i = 0; i <= duration._data.days; i++) {
          if (i === 0) {
            c = eventStart;
          } else {
            //eventStartClone.add(1, 'days');
            //c = eventStartClone;
          }


          if (row.find('.fc-day-top[data-date="' + c.format('YYYY-MM-DD') + '"]').has('div').length === 0) {
            row.find('.fc-day-top[data-date="' + c.format('YYYY-MM-DD') + '"]').append('<div class="fc-event-collection"></div>');
          }

          if (row.find('.fc-day-top[data-date="' + c.format('YYYY-MM-DD') + '"] .fc-event-collection').children('a').length < 5) {
            if (today == c.format('YYYY-MM-DD')) {
              row.find('.fc-day-top[data-date="' + c.format('YYYY-MM-DD') + '"] .fc-event-collection')
                .append(
                  '<a href="#" class="fc-event-dot" onclick="return false;"' +
                  ' style="background-color:#FFFFFF;"' +
                  'title="' + title + '"></a>'
                );
            } else {
              row.find('.fc-day-top[data-date="' + c.format('YYYY-MM-DD') + '"] .fc-event-collection')
                .append(
                  '<a href="#" class="fc-event-dot" onclick="return false;" ' +
                  'style="background-color:#FF0000;"' +
                  'title="' + title + '"></a>'
                );
            }
          }

        }
        element.remove();
      },
      dayClick: function (date, jsEvent, view) {
        // jsEvent.preventDefault();
        try {
          let selectedDate = self.getDate(date);
          //self.getEvents(selectedDate);
          let eventTitles = [];
          
          $(ele).fullCalendar('clientEvents', function (event) {
            if (self.getDate(event.start) >= selectedDate) {
              eventTitles.push(event.title);
            }
          });

          self.getUpcomingEventsByTitle(eventTitles, selectedDate);
          self.getEvents(selectedDate,false); 
        }
        catch (error) {
          console.error('error :: ' + error);
        }
      },
      /*Tag-1 Starts*/
      viewRender: function(view, element) {
        var today = new Date();
        if(view.intervalStart._d.getUTCMonth() != today.getUTCMonth()){ //Tag 2
        self.getEvents(view.intervalStart._d,true);
        }
        else{
        self.getEvents(today,true);
        }
      }
      /*Tag-1 Ends*/
    });
    
  }

  getDate(date) {
    let d = new Date(date),
      month = '' + (d.getUTCMonth() + 1),
      day = '' + d.getUTCDate(),
      year = d.getUTCFullYear();

    if (month.length < 2)
      month = '0' + month;
    if (day.length < 2)
      day = '0' + day;

    let selectedDate = [year, month, day].join('-');
    return selectedDate;
  }

  getUpcomingEventsByTitle(eventTitles, selectedDate) {
    this.showEventsSpinner = true;
    getUpcomingEventsByTitle({ eventTitles: JSON.stringify(eventTitles), selectedDate : selectedDate, userId: USER_ID })
      .then(result => {
        //this.upcomingEvents = JSON.parse(JSON.stringify(result.upcomingEvents));
        this.userEvents = JSON.parse(JSON.stringify(result.userEvents));
        this.showEventsSpinner = false;
      }).catch(error => {
        console.error('getUpcomingEventsByTitle Errror :  ' + JSON.stringify(error));
        this.showEventsSpinner = false;
      });
  }

  getEvents(startDate,onLoad) {
    var endDate = new Date(); //Tag-1
    this.showEventsSpinner = true;
    var activityDate = new Date(startDate); //Tag-1
    endDate.setFullYear(activityDate.getUTCFullYear(),activityDate.getUTCMonth()+1,0); //Tag-1
    getUpcomingEventsByUser({ userId: USER_ID, sortOrder: 'ASC', startDate: startDate, endDate:  endDate,onLoad: onLoad}) //Tag-1
      .then(result => {
        this.upcomingEvents = JSON.parse(JSON.stringify(result.upcomingEvents));
        this.userEvents = JSON.parse(JSON.stringify(result.userEvents));
        this.showEventsSpinner = false;
      }).catch(error => {
        console.error('getUpcomingEventsByUser Errror :  ' + JSON.stringify(error));
        this.showEventsSpinner = false;
      });
      this.upcomingEvents.forEach(element => {
        
    });
  }

  handleJoinEvent(event) {

    let eventName = event.currentTarget.dataset.value;
    /** START-- adobe analytics */
    try {
      util.trackButtonClick('Join Event from home page- ' + eventName);
    }
    catch (ex) {
      console.error(ex.message);
    }
    /** END-- adobe analytics*/

    let eventId = event.currentTarget.dataset.id;
    joinEvent({ eventId: eventId, userId: USER_ID }).then(result => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success ',
          message: result.statusMessage,
          variant: 'success',
          mode: 'dismissable',
        }),
      );
      this.getEvents(this.selectedDate,false);
    }).catch(error => {
      console.error('handleJoinEvent Errror :  ' + JSON.stringify(error));
    })
  }

  handleRedirect(event) {
    let eventName = event.currentTarget.dataset.name;
    let eventId = event.currentTarget.dataset.id;
    let navUrl = '';
    if (eventName == 'events') {
      navUrl = this.communityUrl + 'event-landing';
    }
    if (eventName == 'eventdetail') {
      navUrl = this.communityUrl + 'eventdetails?id=' + eventId;
    }

    window.open(navUrl, '_blank');

  }
}