/*
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     applied type attributes for the StartDateTime and EndDateTime columns
Isha Bansal     03/29/2023  I2RT-6727   T02     Added condition to dynamically render sections to use the same component in the change ownership functionailties 
*/

import { LightningElement, api, track } from 'lwc';
import userUpcomingEvents from '@salesforce/apex/UserEventsHandler.userUpcomingEvents';

//Import CSS from static resources
import global_styles from '@salesforce/resourceUrl/eSupportRrc';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class UserUpcomingEvents extends LightningElement {
    @api recordId;
    @track weekendSupportEvents;
    @track holidaySupportEvents;
    @track ftoEvents; 
    allfto;
    booluserupcomingevent=true; // T02 
    @api userid;// T02 
    
    EVENT_FTO_COLUMNS = [
        
        { label: 'Start Date ', fieldName: 'startdate', type: "text", sortable: true },
        { label: 'End Date ', fieldName: 'enddate', type: "text", sortable: true },
        { label: 'User TimeZone', fieldName: 'usrtimezone', type: "text", sortable: true }
    
    ];

    EVENT_COLUMNS = [
        { label: 'Subject', fieldName: 'subject', type: "text",sortable:true,wrapText:true },
        { label: 'Start Date Time', fieldName: 'startdatetime', type: "text", sortable: true },
        { label: 'End Date Time', fieldName: 'enddatetime', type: "text", sortable: true }
    
    ];
    @track section;
    
    connectedCallback(){
        
        this.section = ['WeekendSupport', 'HolidaySupport','fto'];
        if(this.userid==null || this.userid==undefined){ //T02 if-else
            this.userid=this.recordId; //default value to use when not passed from parent component.
        }else{
            this.booluserupcomingevent=false;  
        }        
        userUpcomingEvents({userId: this.userid})
        .then(result =>{
            console.log('result :  ' + JSON.stringify(result));
            this.weekendSupportEvents = (result.weekendSupport != null && result.weekendSupport != '' && result.weekendSupport.length > 0 ) ? result.weekendSupport : false;
            this.holidaySupportEvents = (result.holidaySupport != null && result.holidaySupport != '' && result.holidaySupport.length > 0 ) ? result.holidaySupport : false;
            this.allfto = (result.fto != null && result.fto != '' && result.fto.length > 0 ) ? result.fto : false ;
            console.log('--this.allfto--'+this.allfto);
            if(this.allfto && !this.booluserupcomingevent ){
                this.ftoEvents=(this.allfto.length>3 )? [...this.allfto].splice(0,3) : this.allfto;  //trim to 3 rows for  owner changescreens             
            }else if(this.allfto && this.booluserupcomingevent){ 
                this.ftoEvents= this.allfto;
            } else{
                this.ftoEvents=false;
            }
        }).catch(error => { 
            console.log('error : ' + error);
        });
        
    }

    renderedCallback() {
        Promise.all([
        loadStyle(this, global_styles + '/css/changeowner.css'),
        ])
        .then(() => {
            console.log("CSS loaded.");
            
        })
        .catch(() => {
            console.log("CSS not loaded");
            
        });
      }

}