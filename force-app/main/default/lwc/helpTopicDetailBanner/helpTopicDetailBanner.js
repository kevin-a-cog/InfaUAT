/*
 * Name         :   HelpTopicDetailBanner
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used to display banner on topic detail pages.

 Change History
 *********************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                    Tag
 *********************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5236           Initial version.                                               NA
 Utkarsh Jain           14-SEPT-2022    I2RT-6886           Revolving hero banners for all the product community            1 
 Deeksha Shetty         19-OCT-2023     I2RT-7150           User Group: Revolving Hero banner for User group detail page    2
 */

import { api, LightningElement, track, wire } from "lwc";
import getHeroBannerForCommunity from "@salesforce/apex/InAnnouncementBanner.getHeroBannerForCommunity";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import getCommunityName from "@salesforce/apex/helpUserRelatedList.getCommunityName";
import getHeroBannerForUserGroup from "@salesforce/apex/InAnnouncementBanner.getHeroBannerForUserGroup";
import getGroupName from "@salesforce/apex/helpGroupsController.getGroupName";


export default class HelpTopicDetailBanner extends LightningElement {
  @api recordId;
  @track announcementTiles = [];
  @track mobileBanner = IN_StaticResource + '/banner-mobile.jpeg';
  @track isMobileView = false;
  @track isOnlyPrimaryBanner = false;
  @track carouselLoop = true;
  isUserGroup = false;
  contentSpecificName;
  communityId;

  constructor() {
    super();
    if (window.location.pathname.includes("/informaticaNetwork/s/")) {
      this.communityId = window.location.pathname.toString().split("/")[4];
    } else {
      this.communityId = window.location.pathname.toString().split("/")[3];
    }
    
    console.log('this.communityId =>'+JSON.stringify(this.communityId))
    /*  Tag 2 starts - To check if its a user group detail page or topic detail page */
    if (window.location.pathname.includes("/group")) this.isUserGroup = true;
    this.handleBannerforContent();
    /*  Tag 2 ends  */
  }



  @wire(getCommunityName, {commId: "$communityId" })
  GetCommunity(result) {
    if (result.data) {
      this.contentSpecificName = result.data;
    }else{
      console.error('error in getcommunity ', result.error)
    }
  }

/*  Tag 2 starts - Fetching the user Group Name */
  @wire(getGroupName, {commId: "$communityId" })
  GetGroupName(result) {
    if (result.data) {
      this.contentSpecificName = result.data;
    }else{
      console.error('error in getusergroup ', result.error)
    }
  }
  /*  Tag 2 ends  */

  renderedCallback() {
    if (window.screen.width < 769) {
      this.isMobileView = true;
    } else {
      this.isMobileView = false;
    }
  }

/*  Tag 2 starts -method handles conditional rendering of revolving banner  */
  handleBannerforContent() {

    if(this.isUserGroup){
      getHeroBannerForUserGroup({ grpId: this.communityId })
        .then((data) => {
            this.announcementTiles = data.map(this.setColor);
            this.announcementTiles = this.announcementTiles.sort((a, b) => {
                return (Number(b.isPrimaryBanner) - Number(a.isPrimaryBanner));
            });
            this.announcementTiles = this.announcementTiles.map(this.isCarouselWithText);
            this.announcementTiles = this.announcementTiles.slice(0, 4);
            if (this.announcementTiles.length == 1) {
                this.isOnlyPrimaryBanner = true;
                this.carouselLoop = false;
            }
            setTimeout(() => {
                this.setItemsForCarousel();
            }, 1500);
        })
        .catch((error) => {
            console.log('Error UG Announcement=' + JSON.stringify(error));
        });

    }
    else{

      getHeroBannerForCommunity({ id: this.communityId })
        .then((data) => {
            this.announcementTiles = data.map(this.setColor);
            this.announcementTiles = this.announcementTiles.sort((a, b) => {
                return (Number(b.isPrimaryBanner) - Number(a.isPrimaryBanner));
            });
            this.announcementTiles = this.announcementTiles.map(this.isCarouselWithText);
            this.announcementTiles = this.announcementTiles.slice(0, 4);
            if (this.announcementTiles.length == 1) {
                this.isOnlyPrimaryBanner = true;
                this.carouselLoop = false;
            }
            setTimeout(() => {
                this.setItemsForCarousel();
            }, 1500);
        })
        .catch((error) => {
            console.log('Error Topic Announcement=' + JSON.stringify(error));
        });

    }
    /*  Tag 2 ends  */

    
}


  setColor(announcement) {
    let _announcement = {
      isCarousel: true,
      title: announcement.Name,
      desc: announcement.hero_description__c,
      img: "background-image:url(" + announcement.Image_URL__c + ")",
      cta: announcement.Description__c,
      link: announcement.Highlight_link__c,
      isPrimaryBanner: announcement.Primary_Banner__c
    }
    if (announcement.Select_Font_Color__c == 'Black') {
      _announcement.colorTitle = "banner-title banner-text-color-black";
      _announcement.colorDesc = "banner-desc banner-text-color-black";
      _announcement.colorName = "product-heading img-background-size d-flex banner-text-color-black";
    } else {
      _announcement.colorTitle = "banner-title banner-text-color-white";
      _announcement.colorDesc = "banner-desc banner-text-color-white";
      _announcement.colorName = "product-heading img-background-size d-flex banner-text-color-white";
    }
    return _announcement;
  }

  isCarouselWithText(announcement) {
      if (announcement.cta == '' && !announcement.isPrimaryBanner) {
        announcement.isPrimaryBanner = true;
        announcement.cta = true;
      }
      return announcement;
  }

  setItemsForCarousel() {
    Promise.all([
      loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
      loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
      loadStyle(this, IN_StaticResource + "/carousel/owl.theme.default.min.css"),
      loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
    ])
      .then(() => {
        var owl = this.template.querySelector(".owl-carousel");
        window.$(owl).owlCarousel({
          items: 1,
          loop: false,
          rewind: this.carouselLoop,
          margin: 10,
          autoplay: true,
          autoplayTimeout: 7000,
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
          },
          onChanged: function(e) {
            if(e.item.index + 1 == e.item.count){                    
              setTimeout(function(){
                window.$(owl).trigger("stop.owl.autoplay"); 
              }, 7000)
            }
          }
        });
      })
      .catch((error) => {
        console.error(error);
      });

  }

  handleOnClick(event) {
    let name = event.currentTarget.dataset.value;
    this.trackCTAButtonClick(name);
  }

  handleBannerOnclick(event) {
    let name = event.currentTarget.dataset.value;
    this.trackCTAButtonClick(name);
    window.location.assign(name);
  }

  trackCTAButtonClick(name) {
    /** START-- adobe analytics */
    try {
      util.trackButtonClick('hero banner community details page - ' + name);
    }
    catch (ex) {
      console.error(ex.message);
    }
    /** END-- adobe analytics*/
  }

}