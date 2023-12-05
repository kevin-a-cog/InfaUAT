import { LightningElement, api, wire, track } from 'lwc';
import getSearchToken  from '@salesforce/apex/CoveoKBSearch.getSearchToken'; 
import getSearchResultRecenttData  from '@salesforce/apex/CoveoKBSearch.getSearchResultRecenttData';
import getSimilararticles from '@salesforce/apex/CoveoKBSearch.getSimilararticles'; 


export default class KBUtilitybar extends LightningElement {

@api comptitle;
@track payload = '';
@track error = '';
@track bool = true;
@track kbrecords;
@api recordId;
@api numOfArticles;
@api viewFilter;
@track internalView =false;
@track externalView=false;
sessiontoken;
showmessage = false;

        connectedCallback() {
           // super();
           if(this.viewFilter==='Internal'){
               this.internalView=true;
               console.log('inside internal view')
               
           }else if(this.viewFilter==='External'){
            this.externalView=true;
            console.log('inside external view')
               
           }
            getSearchToken()
            .then(result => {                
                this.sessiontoken = JSON.parse(result).APISearchToken;
                console.log(this.sessiontoken);
                console.log('recordId',this.recordId);
                if(this.sessiontoken != null){
                  getSimilararticles({
                            strSessionToken: this.sessiontoken,  
                            recid: this.recordId,
                            numOfArticles:this.numOfArticles,
                            viewFilter:this.viewFilter        
                        })
                        .then(result => {
                            
                            if(JSON.parse(result).APIResponseStatus==='SUCCESS'){
                                this.kbrecords = JSON.parse(result).searchDataList;
                                if(this.kbrecords.length == 0){
                                    this.showmessage = true;
                                    this.error = 'No Similar Articles Found';
                                }
                            }else{
                               
                                this.error = JSON.parse(result).ErrorMessage;
                            }
                            
                            
                        })
                        .catch(error => {
                            this.error = error;
                            console.log('error'+JSON.stringify(error));
                        });
                }
                
            })
            .catch(error => {
                this.error = error;
                console.log(this.error);
            });
            
        }         

}