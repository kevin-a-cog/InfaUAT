import { LightningElement, api, track ,wire} from 'lwc';
import getLinkItems from '@salesforce/apex/LinkUtility_Controller.getQuicklinkInfo';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import { truncateText } from 'c/utils';
import AskOurCommunityURL from '@salesforce/label/c.AskOurCommunityURL'; 

export default class EsQuicklinks extends LightningElement {
    caseBanner = ESUPPORT_RESOURCE + '/case.png';
    liveAgent = ESUPPORT_RESOURCE + '/live_agent.png';
    searchKb = ESUPPORT_RESOURCE + '/search_kb.png';
    postQuestions = ESUPPORT_RESOURCE + '/post_questions.png';
@track error;
@track isSupportAcc;
@track data;
@track KnwledgeUrl;
@track PortalURL;
@track askCommunityLink = AskOurCommunityURL;
@api primaryContacts;
@api SuppAccId;
get getsupportAccId(){
    var supAcccid = window.sessionStorage.getItem('supportAccountId');
    console.log('getsupportAccId acc Qlink==>'+supAcccid);
}
connectedCallback() {
   // registerListener('getAccountDetails', this.handleResponse, this);
   //getsupportAccId();
    var supAcccid = window.sessionStorage.getItem('supportAccountId');
    console.log('seelcted acc Qlink==>'+supAcccid);
 
    //getLinkItems({accountId :supAcccid})
    getLinkItems()
        .then(result => {
            this.data = result;
            console.log('data qlink==> '+JSON.stringify(result));
            //this.isSupportAcc=result.isBlnSUpportAcc
            for (var index in this.data) {
                var record = this.data[index];
                for (var key in record) {
                    var value = record[key];
                        if('isBlnSUpportAcc'==key){
                        this.isSupportAcc=value;
                        }                            
                        console.log(value.Id);                           
                        if(value.Name=='PortalLink'){
                            this.PortalURL=value.Link_URL__c;
                        }
                        if(value.Name=='KnowledgeLink'){
                            this.KnwledgeUrl= value.Link_URL__c;
                        }
                    //var value = record[key];
                    console.log(value+' ==> '+key);
                }

            }
            // console.log('handleLoad ==> ',this.data);
        })
        .catch(error => {
            this.error = error;
            console.log('error ==> ',this.error);
        });
}
renderedCallback() {
    var supAcccid = window.sessionStorage.getItem('supportAccountId');
    console.log('renderedCallback acc Qlink==>'+supAcccid);
}
OpenAskCommunity(){
    window.open(this.askCommunityLink, '_blank').focus();
}
OpencommunityPortal(){
    //this.PortalURL='https://search.informatica.com/';
    window.open(this.PortalURL, '_blank').focus();
}
    OpenKnowledgePortal(){
    //this.KnwledgeUrl='https://search.informatica.com/KBHome';
    window.open(this.KnwledgeUrl, '_blank').focus();
    }

handleStartChat(){
    var flatButton = $('.flatButton');
    var helpButton = $('.helpButton');
    console.log('flatButton : ' + flatButton.text());
    console.log('helpButton : ' + helpButton.text());
    if(flatButton !== null && flatButton.text().includes('Chat with an Expert')){
        this.showSpinner = true;
        new Promise(
        (resolve,reject) => {
            flatButton.trigger("click");
            setTimeout(()=> {
                resolve();
            }, 3000);
        }).then(
            () => this.showSpinner = false
        );
        
    }
    if(helpButton !== null && helpButton.text().includes('Chat with an Expert')){
        this.showSpinner = true;
        new Promise(
        (resolve,reject) => {
            setTimeout(()=> {
                helpButton.trigger("click");
                resolve();
            }, 0);
        }).then(
            () => this.showSpinner = false
        );
    }
}


}
// navigate to esCaseCreationCaseInfoTechnical with