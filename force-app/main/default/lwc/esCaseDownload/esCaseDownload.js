/*
* Name			:	esCaseDownload
* Author		:	Vignesh Divakaran
* Created Date	: 	9/27/2022
* Description	:	This provides a UI with filters to download cases in a excel file.

Change History
****************************************************************************************************************
Modified By			Date			Jira No.		Description					                        Tag
****************************************************************************************************************
Vignesh Divakaran      9/27/2022		I2RT-6880		Initial version.			                        N/A
Vignesh Divakaran      10/20/2022		I2RT-7320		Pre-select record type when there is only one       T01
Vignesh Divakaran		10/20/2022		I2RT-7295		Replace	Case Lite record type name with custom      T02
                                                label name on all cases
Isha Bansal           06/13/2023       I2RT-8503       Download button enhancement                         T03
Isha Bansal           07/31/2023       I2RT-8764       Fixed Focus and display issues with the status field T04
*/

//Core imports.
import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues,getObjectInfo  } from 'lightning/uiObjectInfoApi'; //T03 - added getObjectInfo

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Schema
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_OBJECT from '@salesforce/schema/Case'; //T03

//Custom labels
import No_Data_Matching_Message from '@salesforce/label/c.ServiceCloud_Download_Case_Message';
import Case_Lite_RecordType_Name from '@salesforce/label/c.Case_Lite_RecordType_Name'; //<T02>

//Apex Controllers.
import getFilters from "@salesforce/apex/CaseDownloadController.getFilters";
import getRecords from "@salesforce/apex/CaseDownloadController.getRecords";

export default class EsCaseDownload extends LightningElement {

@api strLabel = 'Export Cases';
@api strMessage = 'Please fill the detail and click Export';
@api boolShowSupportAccount;


//Track variables
@track objFilter = {
lstOrgs: undefined,
lstStatus:[],
lstPriority: undefined,
lstCaseTypes: undefined,
lstSupportAccounts: undefined
};
@track allValues=[]; //T04 -> status selected values 
@track optionsMaster=[]; //T04 -> status original list 
//Private variables
strOrgId;
strSupportAccountId;
strProduct;
strPriority;
strStatus;
strCaseNumber;
strCaseRecordTypeId;
dtFrom;
dtTo;
boolDisplaySpinner;
objExportColumns = {
labels: ['Case Number','Case Primary Contact','Subject','Description','Product','Product Version','Last Updated','Priority','Status','Name','Created Date','Closed Date','Next Action','Closing Notes'],
fieldNames: ['CaseNumber','Contact.Name','Subject','Description','Forecast_Product__c','Version__c','LastModifiedDate','Priority','Status','Record_Type_Name__c','CreatedDate','ClosedDate','Next_Action__c','Closing_Notes__c']
};    
label ={
No_Data_Matching_Message,
Case_Lite_RecordType_Name //<T02>
};

/*
Method Name : connectedCallback
Description : This method gets executed on load.
Parameters	 : None
Return Type : None
*/
connectedCallback() {
let objParent = this;
objParent.boolDisplaySpinner = true;

//We load the filter values.
getFilters({ boolShowSupportAccount: objParent.boolShowSupportAccount }).then(objResponse => {
    
    if(objUtilities.isEmpty(objResponse.lstSupportAccounts) && objUtilities.isEmpty(objResponse.lstOrgs)){
        return;
    }
    else{
        objParent.objFilter.lstOrgs = objParent.processFilter(objResponse?.lstOrgs);
        objParent.objFilter.lstSupportAccounts = objParent.processFilter(objResponse?.lstSupportAccounts);
        objParent.objFilter.lstProducts = objParent.processFilter(objResponse?.lstProducts);
        objParent.objFilter.lstCaseTypes = objParent.processFilter(objResponse?.lstCaseTypes);
        objParent.objFilter.lstPriority = objParent.processFilter(objResponse?.lstPriority);

        //Now, we select the favorite support account of the user by default
        if(objUtilities.isNotBlank(objResponse?.favoriteSupportAccountId)){
            objParent.strSupportAccountId = objResponse.favoriteSupportAccountId;
        }
        //Now, we select the support account by default when there's only one
        if(!objUtilities.isEmpty(objParent.objFilter.lstSupportAccounts) && objParent?.objFilter?.lstSupportAccounts?.length === 1){
            objParent.strSupportAccountId = objParent.objFilter.lstSupportAccounts[0].value;
        }
        //Now, we select the org id by default when there's only one
        if(!objUtilities.isEmpty(objParent.objFilter.lstOrgs) && objParent?.objFilter?.lstOrgs?.length === 1){
            objParent.strOrgId = objParent.objFilter.lstOrgs[0].value;
        }
        //Now, we select the record type by default when there's only one
        if(!objUtilities.isEmpty(objParent.objFilter.lstCaseTypes) && objParent?.objFilter?.lstCaseTypes?.length === 1){ //<T01>
            objParent.strCaseRecordTypeId = objParent.objFilter.lstCaseTypes[0].value;
        }

    }
    
}).catch((objError) => {
    objUtilities.processException(objError, objParent);
}).finally(() => {
    objParent.boolDisplaySpinner = false;
});
}

/*
Method Name : select
Description : This method updates the selected filter option.
Parameters	 : Object, called from select, objEvent On change event.
Return Type : None
*/
select(objEvent){
let objParent = this;
let value = objEvent.target.value;
console.log('--value--'+value);

switch (objEvent.target.name) {
    case 'ORG ID':
        objParent.strOrgId = value;
        break;
    case 'Support Account':
        objParent.strSupportAccountId = value;
        break;
    case 'Case Number':
        objParent.strCaseNumber = value;
        break;
    case 'Product':
        objParent.strProduct = value;
        break;
    case 'Case Type':
        objParent.strCaseRecordTypeId = value;
        break;
    case 'Priority':
        objParent.strPriority = value;
        break;
    /*  case 'Status': T03 -> commented out since status changed to multiselect
        objParent.strStatus = value;
        break;*/
    case 'Date From':
        objParent.dtFrom = value;
        break;
    case 'Date To':
        objParent.dtTo = value;
        break;
    default:
        //Do nothing
        break;
}


}

/*
Method Name : processFilter
Description : This method returns processed filters options as an array of objects.
Parameters	 : Array, called from processFilter, lstOptions.
Return Type : Array
*/
processFilter(lstOptions){
let lstOptionsFormatted = [];
if(!objUtilities.isEmpty(lstOptions)){
    lstOptions.forEach(objOption => lstOptionsFormatted.push({label: objOption.strLabel, value: objOption.strValue}))
};
return lstOptionsFormatted;
}

/*
Method Name : exportFile
Description : This method downloads list of cases as a CSV file.
Parameters	 : None
Return Type : None
*/
exportFile(){
let objParent = this;
let objRequest;

//Now, we throw an error if the mandatory field is not selected
if(objParent.boolShowSupportAccount && objUtilities.isBlank(objParent.strSupportAccountId)){
    objUtilities.showToast('Error', 'Please select a support account.', 'error', objParent);
    return;
}
else if(!objParent.boolShowSupportAccount && objUtilities.isBlank(objParent.strOrgId)){
    objUtilities.showToast('Error', 'Please select an ORG ID.', 'error', objParent);
    return;
}

objParent.boolDisplaySpinner = true;
objRequest = {
    objRequest: {
        strOrgId: objParent.strOrgId,
        strSupportAccountId: objParent.strSupportAccountId,
        strStatus: objParent.allValues,//T04 . allValues will hold selected statuses list e.g: Booked,New
        strProduct: objParent.strProduct,
        strPriority: objParent.strPriority,
        strCaseRecordTypeId: objParent.strCaseRecordTypeId,
        dtFrom: objParent.dtFrom,
        dtTo: objParent.dtTo,
        strCaseNumber: objParent.strCaseNumber,
        boolShowSupportAccount : objParent.boolShowSupportAccount
    }
};

//Now, we query the data
getRecords(objRequest).then(lstRecords => {

    if(!objUtilities.isEmpty(lstRecords)){
        //Now, we replace Case Lite record type name with custom label name
        lstRecords.forEach(objRecord => { //<T02>
            if(objRecord.Record_Type_Name__c === 'Case Lite'){
                objRecord.Record_Type_Name__c = objParent.label.Case_Lite_RecordType_Name;
            }
        });
        let strParsedData = objParent.parseDataToCSV(lstRecords);
        objParent.download(strParsedData);
    }
    else{
        //Show no records to download message
        objUtilities.showToast('Download Cases', objParent.label.No_Data_Matching_Message, 'warning', objParent);
    }

}).catch((objError) => {
    objUtilities.processException(objError, objParent);
}).finally(() => {
    objParent.boolDisplaySpinner = false;
});
}

/*
Method Name : parseData
Description : This method parses the data for CSV.
Parameters	 : Array, called from exportFile, lstRecords
Return Type : String
*/
parseDataToCSV(lstRecords){
let strData = '';
let columnSeparator = ',';
let rowSeparator = '\n';

strData += this.objExportColumns.labels.join(columnSeparator);
strData += rowSeparator;    
lstRecords.forEach(objCase => {
    let lstColumnValues = [];
    this.objExportColumns.fieldNames.forEach(strFieldName => {
        let strFieldValue;
        if(strFieldName?.includes('.')){
            let objFlatten = this.flattenObject(objCase);
            strFieldValue = objFlatten[strFieldName];
        }
        else{
            strFieldValue = objCase[strFieldName]?objCase[strFieldName]:''; //T03 -> handled blank value
        }                          
        //Now, we remove all paragraph tags and then replace break tags with new line
        strFieldValue =  strFieldValue?.replace(/(<p[^>]+?>|<p>|<\/p>)/g, "")?.replace(/(<br[^>]+?>|<br>|<\/br>)/g, '\r\n');
        //Now, we append string column value with double quotes
        strFieldValue = typeof strFieldValue === 'string' ? `\"${strFieldValue.replace(/"/g,'""')}\"` : strFieldValue;
        lstColumnValues.push(strFieldValue);                
    });
    strData += lstColumnValues.join(columnSeparator);
    strData += rowSeparator;
});

return strData;
}

/*
Method Name : download
Description : This method download the CSV file.
Parameters	 : String, called from exportFile, strDate
Return Type : None
*/
download(strData){
var hiddenElement = document.createElement('a');
    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent("\uFEFF" + strData);
    hiddenElement.target = '_self';
    hiddenElement.download = 'AllCases.csv';
    document.body.appendChild(hiddenElement);
    hiddenElement.click();
    document.body.removeChild(hiddenElement);
}

/*
Method Name : flattenObject
Description : This method flattens the object.
Parameters	 : Object, called from parseDataToCSV, obj
            String, called from parseDataToCSV, prefix
Return Type : Object
*/
flattenObject(obj, prefix = ''){
return Object.keys(obj).reduce((acc, k) => {
    const pre = prefix.length ? prefix + '.' : '';
    if (typeof obj[k] === 'object') Object.assign(acc, this.flattenObject(obj[k], pre + k));
    else acc[pre + k] = obj[k];
    return acc;
}, {});
}

/*
Method Name : cancel
Description : This method fires an event to parent to close the modal.
Parameters	 : None
Return Type : None
*/
cancel(){
//Now, we fire the event to parent
this.dispatchEvent(new CustomEvent('close', {} ));
}

@wire( getObjectInfo, { objectApiName: CASE_OBJECT } )
objectInfo; //T03 -> to use defaultrecord type for fetching status picklist value

//Get Case status picklist values based on record type
@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CASE_STATUS })
getStatusValues({ data, error }){
if(data){
    let lstStatus = [];
    this.strStatus = undefined;          
    data.values.forEach(objPicklist => {
        lstStatus.push({label: objPicklist.label, value: objPicklist.value}); //T03 . Using strLabel for globalCommunityFilterPickList child component parsing.
    })
    this.objFilter.lstStatus = lstStatus;
    this.optionsMaster=lstStatus; //T04
}
else if(error){
    objUtilities.processException(error, this);
}
};

/* Getter Methods */
get disableActions(){
return this.boolDisplaySpinner;
}

get exportClass(){
return this.boolDisplaySpinner ? 'es-button es-button--secondary mr-2 buttonincmp' : 'es-button es-button--primary mr-2 buttonincmp';
}



handleStatusChange(event){
this.strStatus=event.target.value;
if(!this.allValues.includes(this.value))
    this.allValues.push(this.strStatus);
this.modifyStatusOptions();        
}

modifyStatusOptions()
{
this.objFilter.lstStatus=this.optionsMaster.filter(elem=>{
if(!this.allValues.includes(elem.value))
return elem;
})
}

handleStatusRemove(event)
{
this.strStatus='';
const valueRemoved=event.target.name;
this.allValues.splice(this.allValues.indexOf(valueRemoved),1);
this.modifyStatusOptions();    
}

}