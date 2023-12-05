/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh Divakaran      29-Jun-2022     I2RT-6153           Show Hypercare icon and replace Strategic icon            T01          
 Shashikanth            23-Aug-2023     I2RT-8959           Preferred icon to be added in queue assignment widget     T02
 Isha Bansal            20-Oct-2023     I2RT-9408           AAE icon URL correction                                   T03
 */

import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    loadScript,
    loadStyle
} from 'lightning/platformResourceLoader';
import {
    refreshApex
} from '@salesforce/apex';
import jQuery from '@salesforce/resourceUrl/jqueryMin';
import Console_Button_Icons from '@salesforce/resourceUrl/Console_Button_Icons';
import CaseBCSPIcon from '@salesforce/resourceUrl/CaseBCSPIcon';
import CaseStrategicIcon from '@salesforce/resourceUrl/StrategicIcon'; //<T01>
import CasePreferredIcon from '@salesforce/resourceUrl/PreferredIcon'; //<T02>
import CaseCriticalIcon from '@salesforce/resourceUrl/Project_Significance_Critical_Icon';
import NotificationAudio from '@salesforce/resourceUrl/Console_Notification_Audio2';
import CaseHypercareIcon from '@salesforce/resourceUrl/HypercareIcon'; //<T01>

import updateMuteInfo from '@salesforce/apex/consoleNotificationControllerLWC.updateMuteInfo';
import updateCaseOwner from '@salesforce/apex/consoleNotificationControllerLWC.updateCaseOwner';
import getCustomNotifsList from '@salesforce/apex/consoleNotificationControllerLWC.getCustomNotifsList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled
} from 'lightning/empApi';

export default class GcsQueueAssignNotification extends LightningElement {

    takeOwnershipIcon = Console_Button_Icons + '/TakeOwnership.png';
    muteIcon = Console_Button_Icons + '/muted.png';
    unmuteIcon = Console_Button_Icons + '/unmuted.png';
    collapseIcon = Console_Button_Icons + '/dropdown_minimized.svg';
    expandIcon = Console_Button_Icons + '/dropdown.svg';
    refreshIcon = Console_Button_Icons + '/refresh.svg';
    timezoneIcon = Console_Button_Icons + '/timezone.svg';
    settingIcon = Console_Button_Icons + '/settings.svg';
    p1Icon = Console_Button_Icons + '/P1.svg';
    p2Icon = Console_Button_Icons + '/P2.svg';
    p3Icon = Console_Button_Icons + '/P3.svg';
    aaeIcon = Console_Button_Icons + '/expert.png'; //T03
    standardIcon = Console_Button_Icons + '/infa_maint_level_std.gif';
    enterpriseIcon = Console_Button_Icons + '/infa_maint_level_ent.gif';
    missionCriticalIcon = Console_Button_Icons + '/infa_maint_level_mc.gif';
    premierIcon = Console_Button_Icons + '/infa_maint_level_cp.gif';
    basicSuccessIcon = Console_Button_Icons + '/license_icons_16px_Basic.png';
    premiumSuccessIcon = Console_Button_Icons + '/license_icons_16px_Premium.png';
    signatureSuccessIcon = Console_Button_Icons + '/license_icons_16px_Signature.png';
    bcspIcon = CaseBCSPIcon;
    hypercareIcon = CaseHypercareIcon; //<T01>
    strategicIcon = CaseStrategicIcon;
    preferredIcon =  CasePreferredIcon;  //<T02>
    criticalIcon = CaseCriticalIcon;
    notifyListResult;
    notifySound = NotificationAudio;
    @track isMuted = false;
    @track showSettings = false;
    @track customNotifs;
    @track counter = 0;
    jqueryInitialized = false;
    @track isDone = false;
    @track onLoadCalled = false;

    channelName = '/topic/GCSQueueAssignments';
    @track isSubscribeDisabled = false;
    @track isUnsubscribeDisabled = !this.isSubscribeDisabled;
    @track strResponse = '';
    subscription = {};
    queryStringValue;
    registerErrorListener() {
        // Invoke onError empApi method  
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
    @api
    get userDetail() {
        return this.queryStringValue;
    }

    set userDetail(value) {
        this.queryStringValue = value.queryString;
        this.isMuted = value.isMute;
        this.showSettings = value.showSettings;
        this.channelName = '/topic/GCSQueueAssignments'+value.queryString;
        this.handleChannelSubscribe(this.channelName);
    }

    callNotifySound(){
        var playSound = new Audio(this.notifySound);
        playSound.play();
    }

    handleChannelSubscribe(channelName) {
        const messageCallback = (response) => {
            refreshApex(this.notifyListResult);
        };

        subscribe(channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }

    renderedCallback() {
        if (this.jqueryInitialized) {
            return;
        }
        this.jqueryInitialized = true;
        loadScript(this, jQuery)
            .then(() => {
                console.log("All scripts and CSS are loaded.");
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }

    slideIt(event) {
        let targetId = event.currentTarget.dataset.id;
        let target = this.template.querySelector(`[data-pid="${targetId}"]`);
        $(target).slideToggle("slow");
        let targetIcon = this.template.querySelector(`[data-id="${targetId}"]`);
        if ($(targetIcon).attr("src").includes('dropdown.svg')) {
            $(targetIcon).attr("src", this.collapseIcon);
        } else {
            $(targetIcon).attr("src", this.expandIcon);
        }
    }

    openCase(event) {
        let recordId = event.currentTarget.dataset.id;
        const openCaseEvent = new CustomEvent('opencase', {
            detail: {
                recordId
            },
        });
        // Fire the custom event
        this.dispatchEvent(openCaseEvent);
    }

    openSettings(event) {
        this.dispatchEvent(new CustomEvent('opensettings'));
    }

    mute(event) {
        $(this.template.querySelector('.muted')).show();
        $(this.template.querySelector('.unmuted')).hide();
        this.callUpdateMuteInfo('Mute');
    }
    unmute(event) {
        $(this.template.querySelector('.unmuted')).show();
        $(this.template.querySelector('.muted')).hide();
        this.callUpdateMuteInfo('Unmute');
        this.callNotifySound();
    }
    collapseIcon(event) {
        e.preventDefault();
    }

    callUpdateMuteInfo(message) {
        this.isMuted = !this.isMuted;
        updateMuteInfo({
                Message: message
            })
            .then((result) => {})
            .catch((error) => {
                console.log('Error occured ' + error);
            });
    }

    @wire(getCustomNotifsList)
    getCustomNotifsList(result) {
        this.notifyListResult = result;
        if (result.error) {
            console.log('Error occured getCustomNotifsList ----- ', JSON.stringify(error));
        } else if (result.data) {
            this.processData();
        }
    }
    handleRefresh() {
        refreshApex(this.notifyListResult);
    }

    processData() {
        let count = 0;
        let result = JSON.parse(JSON.stringify(this.notifyListResult.data));
        result.forEach(function (item) {
            count++;
        });
        
        if(this.onLoadCalled && !this.isMuted && this.counter < count ){
            this.callNotifySound();
        }
        if(this.onLoadCalled && this.counter < count){
            this.dispatchEvent(new CustomEvent('highlight'));
        }
        this.counter = count;
        this.customNotifs = result;
        this.isDone = true;
        this.onLoadCalled = true;
    }
    handleTakeOwnerShip(event){
        let recordId = event.currentTarget.dataset.id;
        let owner = event.currentTarget.dataset.owner;
        updateCaseOwner({
            Message: recordId+';'+owner
        })
        .then((result) => {
            if(result == 'Success'){
                this.showToast('Success','success','You have accepted the Case from the queue and are now its owner');
            } else if(result.includes('Already assigned to')){
                this.showToast('Warning','warning',result);
            } else {
                this.showToast('Error','error','Could not assign record.');
            }
            this.handleRefresh();
        })
        .catch((error) => {
            this.showToast('Error','error','Error occured ' + error);
        });
    }

    showToast(title,variant,message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}