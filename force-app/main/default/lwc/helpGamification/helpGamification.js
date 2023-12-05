/*
* Name : HelpGamification
* Author : Deeksha Shetty
* Created Date : March 25, 2022
* Description : This Component displays Badge Recognition points in user profile page
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/


import { LightningElement,api } from 'lwc';
import userId from '@salesforce/user/Id';
import informaticaNetwork2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import communityId from '@salesforce/community/Id';
import getGamificationPoints from '@salesforce/apex/helpUserProfileController.getGamificationPoints';

export default class HelpGamification extends LightningElement {
    @api recordId;
    onestarimg = informaticaNetwork2 + "/new-user.png";
    twostarimg = informaticaNetwork2 + "/active-user.png";
    threestarimg = informaticaNetwork2 + "/seasoned-user.png";
    fourstarimg = informaticaNetwork2 + "/guru.png";
    userpoint;
    showBadges;
    starimg;
   

    connectedCallback(){
        this.getGamificationScore();
    }


    getGamificationScore(){
        console.log('record id='+this.recordId);
        getGamificationPoints({ userId: this.recordId, networkId: communityId})
            .then((data) => {
                if (data) {
                    this.userpoint = data.Userpoint;
                    console.log('userpoints='+JSON.stringify(this.userpoint));
                    if(this.userpoint){
                        this.showBadges = true;
                    }
                    let onestarpoint = data.GamPoints.Gam_One_Star_Point__c;
                    let twostarpoint = data.GamPoints.GamTwo_Star_Point__c;
                    let threestarpoint = data.GamPoints.Gam_Three_Star_Point__c;
                    
                    if(this.userpoint <= onestarpoint){
                        this.onestar = true;
                    }
                    else if(this.userpoint > onestarpoint && this.userpoint<=twostarpoint){
                        this.onestar = true;
                        this.twostar = true;
                    }
                    else if(this.userpoint > twostarpoint && this.userpoint<=threestarpoint){
                        this.onestar = true;
                        this.twostar = true;
                        this.threestar = true;
                    }
                    else if(this.userpoint > threestarpoint){
                        this.onestar = true;
                        this.twostar = true;
                        this.threestar = true;
                        this.fourstar = true;

                    }                   
                }


            })
            .catch((error) => {
                console.log("Ideas Error => " + JSON.stringify(error.body));
            });

    }
    


}