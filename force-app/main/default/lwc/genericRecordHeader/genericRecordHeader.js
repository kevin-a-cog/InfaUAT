import { LightningElement,api,track } from 'lwc';
import fetchRecordConfig from '@salesforce/apex/GenericRecordHeaderController.fetchRecordConfig';
import followRecord from '@salesforce/apex/GenericRecordHeaderController.followRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePath from '@salesforce/community/basePath';
export default class GenericRecordHeader extends LightningElement {
    items=[1,2,3,4,5,1,2,3,4,3,2];
    buttonLabel='Follow';
    buttonIcon='utility:add';
    @track dataWrapper;
    @api recordId;
    @api customMetaName;
    communityBasePath;
    //calls upon component initialization.
    connectedCallback(){

        this.communityBasePath=basePath;  
        this.fetchData();
        this.applyStyleSheet();
    }

    //applying custiom css
    applyStyleSheet(){
        document.styleSheets[0].insertRule(`.headerIcon svg{
            fill:#0a32c6;
        }`);
    }

    //calls server side method to fetch data based upon metadata configuration.
    fetchData(){

        fetchRecordConfig({ recordId: this.recordId, customMetadataConfigName: this.customMetaName })
        .then((result) => {
            
            if(result.Status=='Success'){
                console.log('data',JSON.parse(result.Data));
                this.dataWrapper=JSON.parse(result.Data);
                if(this.dataWrapper.isRecordFollowed){
                    this.buttonLabel='Following';
                    this.buttonIcon='utility:check';
                }
            }
            else if(result.Status=='Error'){
                this.showToastNotification('error','Error!',result.Message);
            }
        })
        .catch((error) => {
            this.showToastNotification('error','Error!',error);
        });
    }

    //handle record follow/unfollow functionality.
    handleFollowButton(){
        var isFollow;
       
        if(this.buttonLabel=='Follow'){
            isFollow=true;
            this.buttonLabel='Following';
            this.buttonIcon='utility:check';
        }
        else if(this.buttonLabel=='Unfollow'){
            isFollow=false;
            this.buttonLabel='Follow';
            this.buttonIcon='utility:add';
        }
        this.handleFollowButtonHelper(isFollow);
    }

    handleFollowButtonHelper(isFollow){
        console.log('isFollow',isFollow);
        //calling server side method to follow or unfollow record.
        followRecord({ recordId: this.recordId, isFollow: isFollow })
        .then((result) => {
            
            if(result.Status=='Success'){
                console.log('success');
            }
            else if(result.Status=='Error'){
                this.showToastNotification('error','Error!',result.Message);
            }
        })
        .catch((error) => {
            this.showToastNotification('error','Error!',error);
        });

    }
    //handler for mouse hover hover in
    handleButtonHover(){
        if(this.buttonLabel=='Following'){
            this.buttonLabel='Unfollow';
            this.buttonIcon='utility:close';
        }
       
    }
    //handler for mouse hover hover out
    handleButtonHoverOut(){
           if(this.buttonLabel=='Unfollow'){
            this.buttonLabel='Following';
            this.buttonIcon='utility:check';
          }
    }
    //show toast message notification.
    showToastNotification(variant,title,message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    //handler for redirect to list view
    recordHeaderRedirectHandler(){
        console.log(this.dataWrapper.recordHeader.headerURL);
        var baseUrl='';
        if(this.communityBasePath){
            baseUrl+=this.communityBasePath;
        }
        window.location.href=baseUrl+this.dataWrapper.recordHeader.headerURL;
    }
}