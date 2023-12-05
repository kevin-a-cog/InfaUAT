/*
* Name         :   helpGroupChapterLeaders
* Author       :   Saumya Gaikwad
* Created Date :   28/07/2022
* Description  :   LWC JS for chapter leader section on group details page

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                Tag
**********************************************************************************************************
Saumya Gaikwad      28/07/2022         I2RT-6758      Initial version.            T3
*/


import { LightningElement, api, track, wire} from 'lwc';
import getChapterLeader from '@salesforce/apex/helpGroupChapterLeaders.getChapterLeader';
import uId from '@salesforce/user/Id';

export default class HelpGroupChapterLeaders extends LightningElement {

    @api recordId;
    @track userId = uId;
    chapterLeaderResult;
    isComponentVisible;
    error;

    /* T3 - Displaying chapter leaders name in the Group details widget.*/ 
    @wire(getChapterLeader, { collaborationGroupId : '$recordId', UserId :'$userId'})
    chapterLeaderWiring(result) {
        console.log('wire invoked!' , result);
        if (result.data) {
            this.chapterLeaderResult = result.data;
            if(result.data.length > 0){
                this.isComponentVisible = true;
            }
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
            this.error = result.error;
        }
    }
}