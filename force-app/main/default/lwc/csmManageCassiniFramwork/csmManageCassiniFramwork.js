import { LightningElement,api} from "lwc";
import CassiniPlanPAF from '@salesforce/label/c.Cassini_Plan_PAF_Component';

export default class CsmManageCassiniFramwork extends LightningElement {
 
 @api recordId;
  cassiniURL = CassiniPlanPAF;
  connectedCallback() {
    if(this.recordId != null && this.recordId !=undefined){
     this.cassiniURL += this.recordId;
    }
  }
  }