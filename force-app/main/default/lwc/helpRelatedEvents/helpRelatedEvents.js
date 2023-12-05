import { api, LightningElement, wire } from 'lwc';
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import getRelatedEvents from '@salesforce/apex/helpEventsController.getRelatedEvents';
import getGroupRelatedEvents from '@salesforce/apex/helpEventsController.getGroupRelatedEvents';
import addUserToEvent from "@salesforce/apex/helpEventsController.addUserToEvent";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from "@salesforce/user/Id";
import returnUsersWhoJoinedEvents from "@salesforce/apex/helpEventsController.returnUsersWhoJoinedEvents";
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import sendMail from "@salesforce/apex/helpEventsController.sendMail";

export default class HelpRelatedEvents extends LightningElement {
    eventtilepic = IN_StaticResource2 + "/eventlanding.png";
    resultSet;
    recId;
    disablebutton = false;
    @api grouprecord;
    prfName;




    constructor() {
        super();
        if (userId == undefined) {
            this.recId = window.location.href.toString().split('?id=')[1];
            console.log('Block 1 this.recId in UserId Absent1111=' + JSON.stringify(this.recId));
        }
        else if (window.location.href.includes('id')) {
            this.recId = window.location.href.toString().split('?id=')[1];
            console.log('Block 2 this.recId in UserId Absent=' + JSON.stringify(this.recId));
        }
        console.log('BLOCK 4 ID=' + JSON.stringify(this.recId));

    }

    connectedCallback() {
        if (this.grouprecord) {
            this.showRelatedGroupEvents();
        } else {
            this.showRelatedEvents();
        }
    }



    // @wire(getRecord, {recordId: userId, fields: [PROFILE_NAME_FIELD]})
    // wireuser({ error, data }) {
    //     if (error) {
    //         console.log('Error='+error.body);
    //     } else if (data) {
    //         this.prfName = data.fields.Profile.value.fields.Name.value;
    //         console.log('Profile Name='+this.prfName);
    //     }
    // }


    showRelatedEvents() {
        console.log('entered show related events=' + JSON.stringify(this.recId))
        if (userId == undefined) this.disablebutton = true;
        getRelatedEvents({ recordId: this.recId })
            .then((result) => {
                this.resultSet = result;
                console.log('this.resultSet=' + JSON.stringify(this.resultSet));
                if (this.resultSet) {
                    this.helpUsersEvent();
                }

            })
            .catch((error) => {
                console.log(error.body);
            });
    }

    showRelatedGroupEvents() {
        console.log('GROUPRECORD=' + this.grouprecord)
        console.log('RECORD-ID=' + this.recId)
        if (userId == undefined) this.disablebutton = true;
        getGroupRelatedEvents({ recordId: this.recId })
            .then((result) => {
                this.resultSet = result;
                console.log('this.resultSet=' + JSON.stringify(this.resultSet));
                if (this.resultSet) {
                    //this.helpUsersEvent();
                    console.log('Sucess');
                }

            })
            .catch((error) => {
                console.log(error.body);
            });
    }


    helpUsersEvent() {
        returnUsersWhoJoinedEvents({ userId: userId })
            .then((result) => {
                if (result) {
                    let disable = JSON.parse(JSON.stringify(this.resultSet));
                    this.joinedeventusers = result;
                    console.log('Joined event users=' + JSON.stringify(this.joinedeventusers))
                    disable.forEach(item => {
                        this.joinedeventusers.forEach(element => {
                            if (element.EventId == item.Id) {
                                item.disablebutton = true;
                            }
                        });
                    });

                    this.resultSet = disable;
                }
            })
            .catch((error) => {
                console.log(error.body);
            });
    }


    joinEvent(event) {
        let eventId = event.currentTarget.dataset.id;
        console.log('event Id from event action=' + JSON.stringify(eventId));
        let statusmsg;
        addUserToEvent({
            eventId: eventId,
            userId: userId
        })
            .then((result) => {
                console.log('handleJoinEvent, result = ', JSON.stringify(result));
                statusmsg = result.statusMessage;
                if (result.returnMessage == 'User Added') {
                    sendMail({ userId: userId, eventId: eventId })
                        .then(result1 => {
                            if (result1) {
                                let res = JSON.stringify(result1);
                                let disable = JSON.parse(JSON.stringify(this.resultSet));
                                disable.forEach(item => {
                                    if (eventId == item.Id) {
                                        item.disablebutton = true;
                                    }
                                });
                                this.resultSet = disable;
                            }
                        })
                        .catch(error => {
                            console.log(error.body.message);
                        })
                    // Show toast message 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: statusmsg,
                            variant: 'success',
                        }),
                    );

                }
                else if (result.returnMessage == 'Past Event') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: statusmsg,
                            variant: 'Error',
                        }),
                    );


                }

            })
            .catch((error) => {
                console.log("handleJoinEvent Error => " + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error : ',
                        message: 'Error occurred, please contact system administrator. Error Message: ' + error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }
}