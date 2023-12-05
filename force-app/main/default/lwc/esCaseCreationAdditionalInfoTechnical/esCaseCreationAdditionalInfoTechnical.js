import { LightningElement } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';

export default class EsCaseCreationTechnicalAdditionalInfo extends LightningElement {
    maximize = ESUPPORT_RESOURCE + '/maximize.png';
    get optionsTemp() {
        return [
            { label: 'Option One', value: 'optionOne' },
            { label: 'Option Two', value: 'optionTwo' },
            { label: 'Option Three', value: 'optionThree' },
        ];
    }
}