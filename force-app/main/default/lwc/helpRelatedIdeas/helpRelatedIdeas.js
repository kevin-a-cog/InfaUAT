import { LightningElement,wire } from 'lwc';
import userId from '@salesforce/user/Id';
import ideasDisplay from '@salesforce/apex/helpIdeasController.ideasDisplay';
import showRelatedIdeas from '@salesforce/apex/helpIdeasController.showRelatedIdeas';
import communityId from '@salesforce/community/Id';
import getmetadatarecords from  '@salesforce/apex/helpIdeasController.getmetadatarecords';

export default class HelpRelatedIdeas extends LightningElement {

    learnMore;
    takeMeThere;
    mainData;
    relatedIdeaslabel;
    IdeaIdOnLoad;
    relatedIdeas;
    showRelatedData;

    constructor() {
        super();
        let url = window.location.href;
        console.log('url=' + url);
        this.IdeaIdOnLoad = window.location.href.toString().split('?id=')[1];
        console.log('this.IdeaIdOnLoad111=' + this.IdeaIdOnLoad);
        if (this.IdeaIdOnLoad) {
            this.helpIdeaDisplay();
        }

    }



    helpIdeaDisplay() {
        ideasDisplay({ IdeaUrlId: this.IdeaIdOnLoad, userId: userId })
            .then((result) => {
                if (result) {
                    this.mainData = result;
                    console.log('ideaData=' + JSON.stringify(this.mainData));
                    this.showRelatedIdea();
                    this.getmetadata();
                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }


    getmetadata(){
        getmetadatarecords()
                .then((result) => {
                    if (result) {
                        console.log('Metadata Result=' + JSON.stringify(result));
                        this.learnMore = result.Learn_More__c;
                        this.takeMeThere = result.TakeMeThere__c;
                        if(this.mainData){
                            this.mainData.forEach(item => {
                                if (item.ideaId == this.IdeaIdOnLoad) {
                                    if (item.Category != 'Change Request') {
                                        this.relatedIdeaslabel = result.Related_Ideas__c;
                                    }
                                    else {
                                        this.relatedIdeaslabel = result.Related_CR__c;
                                    }
                                }
                            })

                        }    
                        
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });

    }


    showRelatedIdea() {
        showRelatedIdeas({ networkId: communityId, Ideaid: this.IdeaIdOnLoad })
            .then((result) => {
                console.log('related Ideas=' + JSON.stringify(result));               
                if(result[0].NoIdeaData == 'nodata'){
                    this.showRelatedData = false;
                }
                else{
                    this.showRelatedData = true;
                    this.relatedIdeas = result;
                }

            })
            .catch((error) => {
                console.log(error.body);
            });
    }
}