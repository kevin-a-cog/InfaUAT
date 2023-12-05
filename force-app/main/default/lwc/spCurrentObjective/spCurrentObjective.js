import { LightningElement,api,wire,track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import fetchNextObjective from "@salesforce/apex/SpCurrentObjectiveCtrl.fetchNextObjective";

export default class SpCurrentObjective extends LightningElement {

	//Private variables.
	boolDisplayBusinessGoal = false;
	boolDisplayTechnicalGoal = false;
	boolDisplayTargetKPI = false;
    noCurrentObjective = false;

 
    @api recordId ;
    @track nextBusinessGoal = '';
    @track nextTechnicalGoal = '';
    @track nextTargetKpi = '';
    @track objectiveName = '';



    @wire(fetchNextObjective, { 'strRecordId': '$recordId'})
    objectiveDetails({error,data}){
		let objParent = this;
        if(data){
            this.nextBusinessGoal =  '';
            this.nextTechnicalGoal =  '';
            this.nextTargetKpi =  '';
            this.objectiveName = '';
            console.log('objResult.fetchNextObjective' + JSON.stringify(data));			
            
            if(data != undefined && data != null){
                if(data.length > 0){
                   this.noCurrentObjective = false;
                   var obj = data[0];
                   this.nextBusinessGoal = obj.Business_Goal__c != undefined ? obj.Business_Goal__c : '';
                   this.nextTechnicalGoal = obj.Technical_Goal__c != undefined ? obj.Technical_Goal__c : '';
                   this.nextTargetKpi = obj.Target_KPI__c != undefined ? obj.Target_KPI__c : '';
                   this.objectiveName = obj.Name != undefined ? obj.Name : '';
					
				   	//Now we define if we need to display the boxes or not.
				  	if(objUtilities.isNotBlank(objParent.nextBusinessGoal)) {
						objParent.boolDisplayBusinessGoal = true;
				   	}
					if(objUtilities.isNotBlank(objParent.nextTechnicalGoal)) {
						objParent.boolDisplayTechnicalGoal = true;
					}
					if(objUtilities.isNotBlank(objParent.nextTargetKpi)) {
						objParent.boolDisplayTargetKPI = true;
					}
                }
                else {
                    this.noCurrentObjective = true;
                }
            }

        }else{
            console.log('error from fetchNextObjective====> ' + JSON.stringify(error));
        }       
    }

    // renderedCallback() {        
    //     if (this.data == undefined && this.data == null){
    //         if(data.length == 0){
    //             this.noCurrentObjective = false;
    //         }
    //     }
    // }
    /*connectedCallback(){
        //Now we fetch the data.
		fetchNextObjective({
			strRecordId: this.recordId
		}).then((objResult) => { 
            console.log('objResult.lstRecordsCustomStructure' + JSON.stringify(objResult));			
            
            if(objResult != undefined && objResult != null){
                if(objResult.length > 0){
                   var obj = objResult[0];
                   this.nextBusinessGoal = obj.Business_Goal__c != undefined ? obj.Business_Goal__c : '';
                   this.nextTechnicalGoal = obj.Technical_Goal__c != undefined ? obj.Technical_Goal__c : '';
                   this.nextTargetKpi = obj.Target_KPI__c != undefined ? obj.Target_KPI__c : '';
                     
                }
            }

            
		}).catch((objError) => {
            console.log('objError' + JSON.stringify(objError));	
		}).finally(() => {
          
		});
    }*/

}