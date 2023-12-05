import { LightningElement } from 'lwc';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import helpGuideLink from '@salesforce/label/c.helpGuideLink';
import helpDocLink from '@salesforce/label/c.helpDocLink';
import CommunityURL from '@salesforce/label/c.IN_CommunityName'; 
import helpSupporttvLink from '@salesforce/label/c.help_searchVideos';
import helpSuccessLink from '@salesforce/label/c.helpSuccessLink';

export default class HelpQuickLinks extends LightningElement {

    successLogo = IN_StaticResource + "/success-portal.png";
    tvLogo = IN_StaticResource + "/support-tv.png";
    guideLogo = IN_StaticResource + "/guide.png";
    documentLogo = IN_StaticResource + "/documents.png";

    guideLink = helpGuideLink;
    docLink = helpDocLink;
    tvLink = CommunityURL + helpSupporttvLink;
    successLink = helpSuccessLink;

    openguideLink(){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('Get Started');
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(this.guideLink);
    }

    opendocLink(){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('Product Documentation');
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(this.docLink);
    }
    
    opentvLink(){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('Support TV');
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(this.tvLink);
    }
    
    opensuccessLink(){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('Success Portal');
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(this.successLink);
    }
}