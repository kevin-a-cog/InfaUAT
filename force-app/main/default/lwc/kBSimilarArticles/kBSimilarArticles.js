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
              
               
           }else if(this.viewFilter==='External'){
            this.externalView=true;
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
                            console.log('The result obtained is',result)
                            if(JSON.parse(result).APIResponseStatus==='SUCCESS'){
                                this.kbrecords = JSON.parse(result).searchDataList;
                                if(this.kbrecords.length == 0){
                                    this.showmessage = true;
                                    this.error = 'No Similar Articles Found';
                                    document.querySelector('c-k-b-similar-articles').style.display='none';

                                    console.log('after hiding  similar articles')
                                    
                                }
                            }else{
                                this.error = 'An error occured, please try again later';
                                console.log('Similar Articles Error occured: Please check with your system administrator');
                                document.querySelector('c-k-b-similar-articles').style.display='none';

                                console.log('after hiding  similar articles')
                               /* try{
                                    console.log('before try')
                                    $('c-k-b-similar-articles').hide();
                                    console.log('after try')
                            }catch{
                                console.log('in catch try')
                                } */
                            }
                            
                            
                        })
                        .catch(error => {
                            console.log('error'+JSON.stringify(error));
                            // this.error = 'Error occured: Please check with your system administrator';
                        });
                }
                
            })
            .catch(error => {
                console.log('error'+JSON.stringify(error));
                this.error = 'Error occured: Please check with your system administrator';
            });
            
        }         

}