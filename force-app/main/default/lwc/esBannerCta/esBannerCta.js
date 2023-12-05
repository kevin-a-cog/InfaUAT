import { LightningElement } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsBannerCta extends LightningElement {
    caseCreation = ESUPPORT_RESOURCE + '/create_case.svg';
    askExpert = ESUPPORT_RESOURCE + '/ask_exp.svg';
    askCommunity = ESUPPORT_RESOURCE + '/ask_community.svg';
}