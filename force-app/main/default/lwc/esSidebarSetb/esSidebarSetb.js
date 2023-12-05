/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                           NA
 Sathish Rajalingam     01-02-2023      I2RT-7585           Make the KB Search recommendation widget 
                                                            floatable on eSupport portal.                               01
 */


import { LightningElement, api, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsSidebarSetb extends LightningElement {

    quickView = ESUPPORT_RESOURCE + '/quickview.svg';
    @api showLastValues = false;
     //For Case Deflection Search - Start
    @track triggerforsearch;
    @track placedin;
    
    
    @api get essidebarsetbsearch() {        
        return this.triggerforsearch;
    }
    set essidebarsetbsearch(value) {        
        this.triggerforsearch = value;                
    }

    @api get essidebarsetbplacedin() {        
        return this.placedin;
    }
    set essidebarsetbplacedin(value) {        
        this.placedin = value;                
    }
     //For Case Deflection Search - End

  

    handleSearchTitleSubjectDescriptionChange(event)
    {
        console.log('handleSearchTitleSubjectDescriptionChange Called  : ');
    }

    
}