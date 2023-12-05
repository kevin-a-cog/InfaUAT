import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccountId from "@salesforce/apex/CSMAccountIPUSummaryCtrlr.getAccountId";
import getEstimation from "@salesforce/apex/CSMAccountIPUSummaryCtrlr.getEstimation";
import getTotalUsage from "@salesforce/apex/CSMAccountIPUSummaryCtrlr.getTotalUsage";
import getTotalGoals from "@salesforce/apex/CSMAccountIPUSummaryCtrlr.getTotalGoals";
import getEntitled from "@salesforce/apex/CSMAccountIPUSummaryCtrlr.getEntitled";

import IPUSummaryTitle from '@salesforce/label/c.IPUSummaryTitle';
import EntitledIPU from '@salesforce/label/c.EntitledIPU';
import EstimatedIPUs from '@salesforce/label/c.EstimatedIPUs';
import Usage from '@salesforce/label/c.Usage';
import ExpectedIPUs from '@salesforce/label/c.ExpectedIPUs';
import IPUType from '@salesforce/label/c.IPUType';

export default class CsmAccountipuSummary extends LightningElement {
    @api recordId;
    @api hideHeader;
    @api fieldName; //fieldName of the AccountId field on respective SObject

    accountId;
    error;

    label = {
      IPUSummaryTitle,
      EntitledIPU,
      EstimatedIPUs,
      Usage,
      ExpectedIPUs,
      IPUType
  };

    intEntitled = 0;
    intEstimated = 0;
    intUsed = 0;
    intExpected = 0;
    type='';

    estData;
    usageData;
    goalsData;
    entitledData;
    
    get spinner(){

    }

    @wire(getAccountId, { idRecord: "$recordId", fieldName : "$fieldName"})
    wiredAccount({ error, data }) {
        if (data) {
          this.accountId = data;
          this.error = undefined;
        } else if (error) {
          this.error = error;
          console.error(error);
          this.record = undefined;
        }
    }

    @wire(getEstimation, { idAccount: "$accountId"})
    getEstimates(value) {
        this.estData = value;
        const { data, error } = value;
        if (data) {
          this.intEstimated = data;
          this.error = undefined;
        } else if (error) {
          this.error = error;
          console.error(error);
          this.record = undefined;
        }
    }

    @wire(getTotalUsage, { idAccount: "$accountId"})
    getUsage(value) {
        this.usageData = value;
        const { data, error } = value;
        if (data) {
          this.intUsed = data;
          this.error = undefined;
        } else if (error) {
          this.error = error;
          console.error(error);
          this.record = undefined;
        }
    }

    @wire(getTotalGoals, { idAccount: "$accountId"})
    getGoals(value) {
      this.goalsData = value;
      const { data, error } = value;
        if (data) {
          this.intExpected = data;
          this.error = undefined;
        } else if (error) {
          this.error = error;
          console.error(error);
          this.record = undefined;
        }
    }

    @wire(getEntitled, { idAccount: "$accountId"})
    getEntitledvals(value) {
      this.entitledData = value;
      const { data, error } = value;
        if (data) {
          this.intEntitled = data.entitled;
          this.type = data.type;
          this.error = undefined;
        } else if (error) {
          this.error = error;
          console.error(error);
          this.record = undefined;
        }
    }

    @api
    refresh(){
      refreshApex(this.estData);
      refreshApex(this.usageData);
      refreshApex(this.goalsData);
      refreshApex(this.entitledData);
    }
}