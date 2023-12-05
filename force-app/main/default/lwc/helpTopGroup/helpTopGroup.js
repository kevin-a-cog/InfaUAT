import { LightningElement, api, track, wire } from "lwc";

import getGroupName from "@salesforce/apex/helpGroupsController.getGroupName";
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";

export default class HelpTopGroup extends LightningElement {
  @api recordId;
  @track groupName = "";
  @track communityId;
  @track imgNumber;
  @track groupList = {
    "Test Public Group1": 1,
    "Test Public Group2": 2,
    "Test Public Group3": 3,
    "Test Private Group1": 4,
    "Test Private Group2": 5,
    "Test Public Group1 March 24": 6,
    "Test Public Group2 March 24": 7,
    "Test Public Group3 March 24": 8,
    "Test Private Group1 March 24": 9,
    "Test Private Group2 March 24": 10,
    "test UG creation - 8718": 11,
    "Test User Group - Bangalore": 12,
    "test private UG": 13,
    "Test Group": 14,
    "Rev": 15,
    "PIM User Group": 16,
    "Informatica Procurement User Group": 17,
    "Informatica University": 18,
    "France IUG Chapter": 19,
    "Austin User Group": 20,
    "Atlanta User Group": 21,
    "Charlotte User Group": 22,
    "Columbus User Group": 23,
    "Dallas/Fort Worth User Group": 24,
    "Denver User Group": 25,
    "User Group Template": 26,
    "Washington DC User Group": 27,
    "Des Moines User Group": 28,
    "Houston User Group": 29,
    "Iowa User Group": 30,
    "New England User Group": 31,
    "New York Metro User Group": 32,
    "Philadelphia User Group": 33,
    "Arizona User Group": 34,
    "Pittsburgh User Group": 35,
    "Portland User Group": 36,
    "South Florida User Group": 37,
    "Southern California User Group": 38,
    "Bay Area User Group": 39,
    "San Diego User Group": 40,
    "Seattle User Group": 41,
    "St Louis User Group": 42,
    "Southwest Ohio": 43,
    "Toronto User Group": 44,
    "Twin Cities User Group": 45,
    "Wisconsin User Group": 46,
    "Chicago User Group": 1,
    "London User Group": 2,
    "MDM Benelux": 3,
    "Germany User Group": 4,
    "Pune User Group": 5,
    "Florence": 6,
    "Japan User Group": 7,
    "IICS Preview": 8,
    "East Coast Higher Education": 9,
    "Raleigh User Group": 10,
    "Detroit User Group": 11,
    "Customer On-boarding": 12,
    "France User Group": 13,
    "Arkansas User Group": 14,
    "UK User Group": 15,
    "Sweden User Group": 16,
    "Denmark User Group": 17,
    "Australian User Group": 18,
    "Dayton User Group": 19,
    "Finland User Group": 20,
    "Norway User Group": 21,
    "Kansas City User Group": 22,
    "Germany Data Governance & Privacy User G": 23,
    "Japan Partner": 24,
    "snowflake-iics-users": 25,
    "Nebraska User Group": 26,
    "IICS-Assure": 27,
    "AIDE Health User Group": 28,
    "Central Strategic MDM/360 User Group": 29,
    "Pharma & Life Sciences DG User Group": 30,
    "INFA认证专攻小组答疑": 31,
    "France Master Data Management User Group": 32,
    "France Data Governance Quality & Privacy": 33,
    "France Data Warehouse Lake & App Moderni": 34,
    "Informatica技术超群": 35,
    "Informatica User Group Chennai": 36,
    "Korea User Group": 37,
  };

  @wire(getGroupName, { commId: "$communityId" })
  GetGroup(result) {
    if (result.data) {
      this.groupName = result.data;
      console.log('called ug name', this.groupName);
      this.imgNumber = this.groupList[this.groupName];
      if(this.imgNumber == undefined){
          this.imgNumber = 1;
      }
      let imgPath = IN_StaticResource3 + "/inf_header_banner_" + this.imgNumber + "_1440x173.jpg";
      this.backgroundImg = "background-image:url(" + imgPath + ")";
    }
    if (result.error) {
      console.log("Inside" + Error);
    }
  }

  constructor() {
    super();
    if (window.location.pathname.includes("/informaticaNetwork/s/")) {
      this.communityId = window.location.pathname.toString().split("/")[4];
    } else {
      this.communityId = window.location.pathname.toString().split("/")[3];
    }
    }
}