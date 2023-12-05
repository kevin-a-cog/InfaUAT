import { LightningElement,track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import updateAccountContactRel from '@salesforce/apex/CaseController.updateAccountContactRel';
import allSupportAccounts from '@salesforce/apex/CaseController.allSupportAccountswrp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc'; 

export default class EsSupportAccDetails extends LightningElement {

    supportAccountLogo = ESUPPORT_RESOURCE + '/support_account.svg';

    @track supportAllAccounts = [];
    @track supportAccounts = [];
    @track isMultipleSupportAccount = false;
    @track favSupportAccounts = [];
    @track selectedFavAcc=[];
    @track favnewSupportAccounts = [];
    @track selectedSupportAccount;
    @track selectedSupportAccountLabel;
    @track showSpinner = false;
    @track showMakeFavSpinner = false;
    @track acrIdMap= new Map();
    @wire(CurrentPageReference) pageRef;
    @track isPinned = false;
    @track manageSupportAccount = CommunityURL + 'supportaccountdetails';
    @track selectDropdown = "col-md-4 es-pin-inline";

    @wire(allSupportAccounts, {})
    supportAccountOptions({data, error}){
      //  this.showSpinner = true;
        document.body.setAttribute('style', 'overflow: hidden;');
        
        console.log('Accountoptions= '+JSON.stringify(data));

        if(data != null) {
            let supportAccountOptions = [];
            let myFavSupportAccounts=[];
            let makefavnewSupportAccounts=[];
            this.supportAllAccounts=data;
            let acrid=new Map();
            for(var i in data){
                
                var record = data[i]; 
               
               // alert(JSON.stringify(this.supportAllAccounts));
                for (var key in record) {
                    var value = record[key];
                   // console.log('suppo    cc==> ',value +' key '+key);
                    if('isBlnSUpportAccFav'==key){
                        if(value){
                            this.selectedFavAcc.push(record['AccConRel'].Id);
                            //this.isPinned = true;
                            myFavSupportAccounts.push(record['AccConRel'].AccountId+'-'+record['AccConRel'].Id);
                        }
                      //  console.log('suppo fav  cc==> ',record['AccConRel'].AccountId +' key '+key);
                        }else{                          
                            makefavnewSupportAccounts.push(value.AccountId+'-'+value.Id);
                            supportAccountOptions.push({label: value.Account.Name , value : value.AccountId});  
                        }  
                   // console.log('suppo cc==> ',value);
               // supportAccountOptions.push({label: data[i].label , value : data[i].value}); favnewSupportAccounts
                }
            }
            //this.acrIdMap=acrid;
            this.favSupportAccounts=myFavSupportAccounts;//already added to fav
           this.favnewSupportAccounts =makefavnewSupportAccounts;
            this.supportAccounts = supportAccountOptions;
            this.getAccountInfo(this.supportAccounts[0].value);
           // console.log('suppor cc==>');
            this.isPinnedSupportAcc(this.supportAccounts[0].value);
           // console.log( ' fav cc==> '+JSON.stringify(this.favSupportAccounts));
            //console.log('this.acrIdMap+supportAccountOptions cc==> '+JSON.stringify(this.supportAccounts));
            document.body.removeAttribute('style', 'overflow: hidden;');
            this.showSpinner = false;
        } else {
            document.body.removeAttribute('style', 'overflow: hidden;');
            this.showSpinner = false;
            console.log('Support Account Error= '+JSON.stringify(error));
        }        
    }

    connectedCallback(){
        var width = (window.innerWidth > 0) ? window.innerWidth : screen.width;
        if (width < 420){
            this.selectDropdown = "col-md-4";
        }
    }

    handleAccountSelect(event){
        this.getAccountInfo(event.detail.value);
        this.isPinnedSupportAcc(event.detail.value);
    }

    markFav(event){
      // alert('parent '+event.detail);
        this.showMakeFavSpinner = true;
        var accid=event.detail;
        var isInsert=false;
        for(var key in this.selectedFavAcc){
            var ACRID=this.selectedFavAcc[key];
            if(accid==ACRID){
                isInsert=  true;
            } 
        }
        this.selectedFavAcc=[];
        this.selectedFavAcc.push(accid);
        
        /** START-- adobe analytics */
        try {
            util.trackFavAccount();
        }
        catch(ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        updateAccountContactRel({acrID: accid}).then(()=>{
            this.showMakeFavSpinner = false;
            var msg ;
            if(!isInsert){
                msg="Selected support account record has been successfully marked as favorite.";
                
            }else{
                msg="Selected support account record has been successfully unmarked as favorite.";
               
               // this.favSupportAccounts=[];
            }
            const evt = new ShowToastEvent({
                title: "Success!",
                message: msg,
                variant: "success",
            });
            this.dispatchEvent(evt);
        });
    }
    //Mark favorite to support Acc
    makefav(){
        this.showMakeFavSpinner = true;
        var ACridtoUpdate;
        for( var key in this.favnewSupportAccounts){
            var Acc_acrid=this.favnewSupportAccounts[key];
            var acrid=Acc_acrid.split('-');            
            if(acrid.length>0){
                var accid=acrid[0];
               // console.log( this.selectedSupportAccount+'  acr compa fav cc==>'+acrid[0]);
                if(this.selectedSupportAccount==accid){
               // console.log( '  acr fav cc==>'+acrid[1]);
                ACridtoUpdate=acrid[1];
                }
            }
            console.log(this.selectedSupportAccount+' fav cc==>'+ACridtoUpdate +' all acc '+this.favnewSupportAccounts);
        }
        this.isPinnedSupportAcc(this.selectedSupportAccount);
        var isInsert=true;
        if(!this.isPinned){
            isInsert=true;
            this.favSupportAccounts=[];
            this.favSupportAccounts.push(this.selectedSupportAccount+'-'+ACridtoUpdate);
           // alert('false ==>'+this.isPinned);
        }else{
            var removeitem=this.selectedSupportAccount+'-'+ACridtoUpdate;
            const index = this.favSupportAccounts.indexOf(5);
            if (index > -1) {
                this.favSupportAccounts.splice(index, 1);
              }
            isInsert=false;
           // alert(JSON.stringify(this.favSupportAccounts)+' true ==>'+this.isPinned);
        }
        //update ACR object
        updateAccountContactRel({acrID: ACridtoUpdate}).then(()=>{
            this.showMakeFavSpinner = false;
            var msg;
            if(isInsert){
                msg="Selected support account record has been successfully marked as favorite.";
                this.isPinned = true;
            }else{
                msg="Selected support account record has been successfully unmarked as favorite.";
                this.isPinned = false;
                this.favSupportAccounts=[];
            }
            const evt = new ShowToastEvent({
                title: "Success!",
                message: msg,
                variant: "success",
            });
            this.dispatchEvent(evt);
            
            console.log('Refresh Apex called');
        });
      //  console.log(this.favSupportAccounts+'fav cc==>'+this.selectedSupportAccount+' == make new'+JSON.stringify(this.acrIdMap));
    }

    //check for Favorite Support Acc
    isPinnedSupportAcc(supportAccountId){
        console.log('pinned cc==>'+this.favSupportAccounts);
        this.isPinned = false;
        for(var key in this.favSupportAccounts){
            var Acc_acrid=this.favSupportAccounts[key];
            var acrid=Acc_acrid.split('-'); 
            if(acrid.length>0){
                var accid=acrid[0];
                if(supportAccountId==accid){
                    this.isPinned = true;
                } 
            }
        }
        console.log('pinnedend  cc==>');
    }
    getAccountInfo(supportAccountId){
        this.selectedSupportAccount = supportAccountId;
        let accountId= supportAccountId;
        let accountName = '';
        let supportAccounts = [];
        supportAccounts = this.supportAccounts;
        if (supportAccounts.length == 1){
            this.isMultipleSupportAccount = false;
        }else{
            this.isMultipleSupportAccount = true;
        }
        console.log('supportAccounts== '+JSON.stringify(supportAccounts));
        console.log(' acc accountId== '+accountId);
        for(var i in supportAccounts){
            if(supportAccounts[i].value == accountId){
                accountName = supportAccounts[i].label;
            }
        }
        
        console.log(this.selectedSupportAccount+' accountName= '+accountName);
        this.selectedSupportAccountLabel = accountName;
        sessionStorage.setItem("supportAccountId",supportAccountId);
        fireEvent(this.pageRef, 'getAccountDetails', accountId);
    }

}