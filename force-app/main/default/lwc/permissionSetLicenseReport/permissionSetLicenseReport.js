import { LightningElement } from 'lwc';
import getPermissionSetLicenseReport from '@salesforce/apex/UserProvisioningHandler.getPermissionSetLicenseReport';
import getManagedPackageLicenseReport from '@salesforce/apex/UserProvisioningHandler.getManagedPackageLicenseReport';

const pslColumns = [
    { label: 'Permission Set License Name ', fieldName: 'MasterLabel', type: 'text' },
    { label: 'Total Licenses', fieldName: 'TotalLicenses', type: 'text' },
    { label: 'Used Licenses', fieldName: 'UsedLicenses', type: 'text' },
];

const mplColumns = [
    { label: 'Managed Package License Name ', fieldName: 'Name', type: 'text' },
    { label: 'Total Licenses', fieldName: 'AllowedLicenses', type: 'text' },
    { label: 'Used Licenses', fieldName: 'UsedLicenses', type: 'text' },
];

export default class PermissionSetLicenseReport extends LightningElement {
    data = [];
    pslColumns = pslColumns;
    searchKey = ''
    temp = [];
    data2 = [];
    mplColumns = mplColumns;
    searchKey2 = ''
    temp2 = [];

    // eslint-disable-next-line @lwc/lwc/no-async-await
    async connectedCallback() {
        this.data = await getPermissionSetLicenseReport({});
        this.temp = this.data;
        let responseData = await getManagedPackageLicenseReport({});
        let reports = [];
        responseData.map((d) => {
            let arr = d.split(',');
            reports.push({
                Name: arr[0],
                AllowedLicenses: arr[1],
                UsedLicenses: arr[2]
            })
        })
        this.data2 = reports;
        this.temp2 = reports;
    }
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        let filteredData = this.temp.filter(function (e) {
            return e.MasterLabel.toLowerCase().includes(event.target.value.toLowerCase());
        });
        this.data = filteredData;
    }
    handleKeyChange2( event ) {
        this.searchKey2 = event.target.value;
        let filteredData = this.temp2.filter(function (e) {
            return e.Name.toLowerCase().includes(event.target.value.toLowerCase());
        });
        this.data2 = filteredData;
    }

}