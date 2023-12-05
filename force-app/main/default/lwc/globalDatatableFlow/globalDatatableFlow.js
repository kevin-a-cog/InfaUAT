/*
 * Name			:	globalDatatableFlow
 * Author		:	Vignesh Divakaran
 * Created Date	: 	26/05/2022
 * Description	:	This is a resuable LWC and will be used in Flow.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		26/05/2022		I2RT-6149		Initial version.					N/A
 */

//Core imports.
import { LightningElement,api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getDatatableDetailsAndRecords from "@salesforce/apex/GlobalDataTableUtilitiesClass.getDatatableDetailsAndRecords";

export default class GlobalDatatableFlow extends LightningElement {

    //API variables.
    @api recordId;
    @api strObjectAPIName;
    @api strFieldsetAPIName;
    @api strQueryFilters;
    @api strNoRecordsMessage = 'No records to display';
    @api lstSelectedRecords;
 
 
    //Private Variables
    lstData;
    lstColumns = [];
    isLoading = true;
    lstCustomFields = [];
 
    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters  : None
     Return Type : None
    */
    connectedCallback() {
        
        //We initialize the components.
        this.initializeComponent();
    }
 
    /*
     Method Name : initializeComponent
     Description : This method gets executed after load.
     Parameters	 : None
     Return Type : None
    */
    initializeComponent() {
        let objParent = this;
        
        getDatatableDetailsAndRecords({
            recordId: objParent.recordId,
            strObjectAPIName: objParent.strObjectAPIName,
            strFieldsetAPIName: objParent.strFieldsetAPIName,
            objQueryFilter: JSON.parse(objParent.strQueryFilters)
        }).then((objResponse) => {
            objParent.parseColumns(objResponse.lstColumns);
            objParent.parseData(objResponse.lstRecords);
            //objParent.lstData = objResponse.lstRecords;

            console.log(objParent.lstData);
            console.log(objParent.lstColumns);
        }).catch((objError) => {
            objUtilities.processException(objError, objParent);
        }).finally(() => {
            objParent.isLoading = false;
        })
    }
 
    /*
     Method Name : parseColumns
     Description : This method parses the object info and constructs the columns for datatable.
     Parameters	 : List, called from initializeComponent, lstColumns
     Return Type : None
    */
    parseColumns(lstColumns){
        let objParent = this;

        if(lstColumns.length > 0){
            objParent.lstColumns = [];   
            lstColumns.forEach(objColumn => {
                let strFieldName;
                let strType;
                let intInitialWidth = objColumn.type.includes('date') ? 130 : 160;
                if(objColumn.type == 'custom'){
                    if(objColumn.subtype == 'picklist'){
                        strFieldName = objColumn.fieldName;
                    }
                    else{
                        //Now, we transform all lookup field names
                        if(objColumn.typeAttributes.label.fieldName.includes('.')){
                            strFieldName = objColumn.typeAttributes.label.fieldName.replaceAll('.','___');
                            objParent.lstCustomFields.push(strFieldName);
                        }
                        else{
                            strFieldName = objColumn.typeAttributes.label.fieldName;
                        }
                    }
                    strType = 'text';
                }
                else{
                    strFieldName = objColumn.fieldName;
                    strType = objColumn.type;
                }
                objParent.lstColumns.push({label: objColumn.label, fieldName: strFieldName, type: strType, initialWidth: intInitialWidth});
            });      
        }
    }

    /*
     Method Name : parseData
     Description : This method parses the list of records and constructs the data for datatable.
     Parameters	 : List, called from initializeComponent, lstRecords
     Return Type : None
    */
    parseData(lstRecords){
        let objParent = this;

        if(lstRecords.length > 0){
            objParent.lstData = undefined;

            lstRecords.forEach(objRecord => {
                for(const strPropertyName in objRecord){
                    if(typeof objRecord[strPropertyName] === 'object'){
                        for(const strLookupPropertyName in objRecord[strPropertyName]){
                            let strCustomLookupFieldName = `${strPropertyName}___${strLookupPropertyName}`;
                            if(objParent.lstCustomFields.includes(strCustomLookupFieldName)){
                                objRecord[strCustomLookupFieldName] = objRecord[strPropertyName][strLookupPropertyName];
                            }
                        }
                    }
                }
            });

            objParent.lstData = lstRecords;
        }
    }
 
    /*
     Method Name : selectRecords
     Description : This method selects records from the table.
     Parameters	 : Object, called from selectRecords, objEvent Select event.
     Return Type : None
    */
    selectRecords(objEvent) {
        let objParent = this;

        if(objEvent.detail.selectedRows.length > 0){
            const lstSelectedRows = objEvent.detail.selectedRows;
            lstSelectedRows.forEach(objRecord => {
                for(const strPropertyName in objRecord){
                    //Now, we remove all transformed lookup field names
                    if(objParent.lstCustomFields.includes(strPropertyName) || strPropertyName.includes('__r')){
                        delete objRecord[strPropertyName];
                    }
                }
            });
            objParent.lstSelectedRecords = lstSelectedRows;
        }
        else{
            objParent.lstSelectedRecords = undefined;
        }
    }
}