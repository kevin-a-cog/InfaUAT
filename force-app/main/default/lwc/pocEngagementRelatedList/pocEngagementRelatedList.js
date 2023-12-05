import { LightningElement, api, track,wire } from 'lwc';
import fetchPocEngagements from '@salesforce/apex/PocEngagementRelatedListController.fetchPocEngagements';
import getRecords from '@salesforce/apex/PocEngagementRelatedListController.getRecords';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class PocEngagementRelatedList extends LightningElement {


    @api recordId; // engagementId
    columns;   
    tableData;   
    error;
    boolDisplaySpinner = false;
    objConfiguration = {
		strIconName: "standard:custom",
		strCardTitle: ''	,
		strSearchPlaceholder: 'Search Engagement',
        strTableClass: "pocEngagements",
        boolHideCheckboxColumn : true,
		strTableId: "1",			
			lstActionButtons: []
	}


   
    /*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		let objParent = this;
        objParent.template.querySelector('.' + this.objConfiguration.strTableClass).searchRecord(objEvent);
	}



    @wire(fetchPocEngagements, { 'engagementId': '$recordId'})
    pocEngagements({error,data}){
        if(data){
            console.log('pocEngagements ===> ' + JSON.stringify(data));
            let objStr = JSON.parse(data);  
            let listOfFields= JSON.parse(Object.values(objStr)[1]);
            let listOfRecords = JSON.parse(Object.values(objStr)[0]);

            let items = [];
            listOfFields.map(element=>{
                
                items = [...items ,
                        {
                          label: element.label, 
                          fieldName: element.fieldPath
                        }
                ];

            });
            console.log('set>>> '+JSON.stringify(listOfFields));
            console.log('items>>> '+JSON.stringify(items));
            
            for(var i=0; i < items.length;i++){
                
                if(items[i].fieldName === 'Success_App__c'){
                    items[i].type = 'custom';
                    items[i].typeAttributes = {
						boolisname: true,
						label: {
							fieldName: "Success_App__c"
						},
						subtype: "html"
					};              
                }
            }

            this.columns = items; 
            this.tableData = listOfRecords;
            this.error = undefined; 

                   
        }else{
            console.log('error from pocEngagements====> ' + JSON.stringify(error));
            this.error = error;
           
            this.tableData = undefined;
        }       
    }



    connectedCallback(){
       // alert('recordId ===> ' + this.recordId);        
        let objParent = this;
        getRecords({
			engagementId: this.recordId,			
		}).then((objResult) => {
            console.log('objResult===> ' + JSON.stringify(objResult));
			//We build the tables.
            // if(objUtilities.isNotNull(objResult.lstRecords)){
          //      var updatedRecords=[];
               /* objResult.lstRecords.forEach(record => {
                //Restructered the Json to fetch related phone and Name fields
                let preparedContactRecord = record;
               //let accTypevariable = objUtilities.isNotBlank(record.Account.Type) ? record.Account.Type : '';
              //preparedContactRecord = { ...preparedContactRecord, AccType:accTypevariable};							
              // and so on for other fields
                            updatedRecords.push(preparedContactRecord);
                        });*/
                 //   }	

                    objParent.objConfiguration.lstRecords = objResult.lstRecords;
			        objParent.objConfiguration.lstColumns = objResult.lstColumns;
					if(objUtilities.isNotNull(objParent.objConfiguration) && objUtilities.isNotNull(objParent.objConfiguration.lstColumns)) {
						objParent.objConfiguration.lstColumns.forEach(objColumn => {
							if(objColumn.fieldName === 'Success_App__c'){
								objColumn.type = 'custom';
								objColumn.typeAttributes = {
									boolisname: true,
									label: {
										fieldName: "Success_App__c"
									},
									subtype: "html"
								};              
							}
						});
					}
                    this.boolDisplaySpinner = true;
					//objTab.objParameters.lstRecords = updatedRecords ;
				//	objTab.objParameters.lstColumns = objResult.lstColumns;
					//Now we add inline editing for all the columns.
					/*objTab.objParameters.lstColumns.forEach(objColumn => {
						if(objColumn.strFieldName==="Role__c" && strCurrentTab == "1"){
							objColumn.editable = "true";
						}
						//Rename the Account label for parent 
						if(objColumn.label=="Account ID"){
							objColumn.label='Account';
						}
						if(objColumn.strFieldName=="Phone"){
							objColumn.label='Phone';
						}
					});
				}
			});*/
		}).catch((objError) => {
			//objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			///objParent.boolDisplaySpinner = false;
		});
    }


}