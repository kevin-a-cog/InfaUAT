/*
 * Name         :   HelpHeroBanner
 * Author       :   Utkarsh Jain
 * Created Date :   18-FEB-2022
 * Description  :   Component used to show hero banner on home page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain          18-FEB-2022      I2RT-5421           Initial version.                                          NA
 Utkarsh Jain          16-JUN-2022      I2RT-6422           Bringing Announcements on Community Page                  NA
 */
import { LightningElement, wire, track, api } from "lwc";
import getAnnouncementTileList from "@salesforce/apex/InAnnouncementBanner.getAnnouncementTileList";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';

export default class HelpHeroBanner extends LightningElement {

    @api bannerHeight = '324px';
    @track announcementTiles = [];
    @track mobileBanner = IN_StaticResource + '/banner-mobile.jpeg';
    @track isMobileView = false;
    @track bannerHeightStyle;

    renderedCallback() {
        this.bannerHeightStyle = 'height: ' + this.bannerHeight;
        if(window.screen.width < 769){
            this.isMobileView = true;
        }else{
            this.isMobileView = false;
        }
    }

    @wire(getAnnouncementTileList, { type: 'HeroBanner'})
    AnnouncementList({ error, data }) {
        if (data) {
            this.announcementTiles = data.filter(this.isHeroCarousel);
            this.announcementTiles = this.announcementTiles.map(this.setColor);
            setTimeout(() => {
                this.setItemsForCarousel();
            }, 1500);
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }

    setColor(announcement){
        let _announcement = {
            isCarousel: announcement.Hero_Carousel__c,
            title : announcement.Name,
            desc : announcement.hero_description__c,
            img : announcement.Image_URL__c,
            cta : announcement.Description__c,
            link: announcement.Highlight_link__c
        }
        if(announcement.Select_Font_Color__c == 'Black'){
            _announcement.colorTitle = "banner-title banner-text-color-black";
            _announcement.colorDesc = "banner-desc banner-text-color-black";
        }else{
            _announcement.colorTitle = "banner-title banner-text-color-white";
            _announcement.colorDesc = "banner-desc banner-text-color-white";
        }
        return _announcement;
    }

    isHeroCarousel(announcement) {
        if (announcement.Hero_Carousel__c) {
            return true;
        }
        return false;
    }

    setItemsForCarousel() {
        Promise.all([
            loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.theme.default.min.css"),
            loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
        ])
            .then(() => {
                const carousel = this.template.querySelector('div[class="owl-carousel owl-theme"]');
                window.$(carousel).owlCarousel({
                    items: 1,
                    loop: true,
                    margin: 10,
                    autoplay: true,
                    autoplayTimeout: 3000,
                    autoplayHoverPause: true,
                    responsiveClass: true,
                    navText: ['<div class="hero-carousel-left"></div>', '<div class="hero-carousel-right"></div>'],
                    responsive: {
                        0: {
                            items: 1,
                            nav: false
                        },
                        600: {
                            items: 1,
                            nav: true
                        },
                        1000: {
                            items: 1,
                            nav: true
                        }
                    }
                });
            })
            .catch((error) => {
                console.error(error);
            });

    }

    handleOnClick(event){
        let name = event.currentTarget.dataset.value;
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('hero banner - ' + name);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
    }
}