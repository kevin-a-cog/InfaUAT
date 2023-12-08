/*
    @Author:        Advanced Technology Group
    @Created Date:  October 2021
    @Description:   This is the LWC for Estimator Summary Page Section progress rings

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                 Tag

    Colton Kloppel        October 2021  IPUE-53         Initial Create
    Kevin Antonioli   `   October 2023  PNP-512         Optimize performance/UX                                     <T01>
    ********************************************************************************************************************************************
*/

import { LightningElement, api } from "lwc";

export default class ProgressRing extends LightningElement {
  @api numerator;
  @api denominator;
  @api progress;
  progressComplete = false; // added for <T01>

  get completeness() {
    // added for <T01> to be able to switch ring color to green when all fields have been filled out in a section
    this.progressComplete = this.progress === 100 ? true : false;

    let fillPercent = this.progress > 0 ? (this.progress / 100) * -1 : 0; // Make negative so that progress ring drains
    let isLong = this.progress > 50 ? 1 : 0;
    let arcX = Math.cos(2 * Math.PI * fillPercent);
    let arcY = Math.sin(2 * Math.PI * fillPercent);
    var value =
      "M 1 0 A 1 1 0 " + isLong + " 0 " + arcX + " " + arcY + " L 0 0";
    return value;
  }
}