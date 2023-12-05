/*
@created by       : Sathish R
@created on       : 17-Aug-2023
@Purpose          : Provides feature that connects with IN Community from KB.
@Testclass        :
@JIRA             :


Change History
 ****************************************************************************************************
|    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
|     1      |  17-Aug-2023      |  Sathish R                |    I2RT-8631      |   Provide 'Join the Community' option on Knowledge Article detail page.
 ****************************************************************************************************
 */

import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import getProductsTopic from "@salesforce/apex/KBArticleHandler.getProductsTopic";
import KB_StaticResource from "@salesforce/resourceUrl/INFAKBResource";
import KB_Network_Host from '@salesforce/label/c.KB_Network_Host';
import getloggedinprofile from '@salesforce/apex/KBLWCHandler.getloggedinprofile';

const ARTICLE_FIELDS = [
    "Knowledge__kav.Id",
    "Knowledge__kav.Title",
    "Knowledge__kav.Article_Type__c",
    "Knowledge__kav.ArticleNumber",
    "Knowledge__kav.PublishStatus",
    "Knowledge__kav.KnowledgeArticleId",
    "Knowledge__kav.Primary_Product__c"
];

//For Loggging in Console
const ISDEBUGENABLED = true;
function Log(parType, parMessage) {
    try {
        if (ISDEBUGENABLED == true || parType == 'error') {
            if (parType == 'log') {
                console.log(parMessage);
            } else if (parType == 'error') {
                console.error(parMessage);
            } else if (parType == 'warn') {
                console.warn(parMessage);
            }
        }
    } catch (err) {
        console.log('Utility Log : ' + err.message);
    } finally {}
}
//For Loggging in Console

export default class KbConnectCommunity extends LightningElement {
     @ api recordId;
     @ track communityLogo = KB_StaticResource + "/images/community.png";
     @ track communityURL = '';
     @ track isDataAvailableOnLoad = false;
     @ track isKBDataAvailableOnLoad = false;
     @ track isContentViewable = false;
     @ track currentPrimaryProduct = '';
     @ track currentProductsTopicName = '';
     @ track currentProductsTopicId = '';
     @ track currentRecordType = '';
     @ track currentArticleNumber = '';
     @ track currentNavigatedTopicName = '';
     @ track isCommunityUser = null;
     @ track isProductTopicAvailable = null;

    INTOPICURL = 'https://HOSTNAME/s/topic/RECORDID/RECORDNAME';
    INTOPICCATALOGURL = 'https://HOSTNAME/s/topiccatalog';
    TOPICCATALOGTITLE = 'TopicCatalog';

    @wire(getRecord, { recordId: "$recordId", fields: ARTICLE_FIELDS })
    article({ error, data }) {
        try {
            if (error) {
                Log("log", "KbConnectCommunity : error - " + JSON.stringify(error));
            } else if (data) {
                Log("log", "KbConnectCommunity : log - " + JSON.stringify(data));
                this.currentPrimaryProduct = data.fields.Primary_Product__c.value;
                this.currentRecordType = data.fields.Article_Type__c.value;
                this.currentArticleNumber = data.fields.ArticleNumber.value;
                if ((this.currentRecordType == 'Solution') || (this.currentRecordType == 'FAQ') || (this.currentRecordType == 'Parameter') || (this.currentRecordType == 'Whitepaper') || (this.currentRecordType == 'HOW TO') || (this.currentRecordType == 'PAM EOL Support Statement') || (this.currentRecordType == 'Support Guide') || (this.currentRecordType == 'Product Release')) {
                    this.isContentViewable = true;
                    this.isKBDataAvailableOnLoad = true;
                } else {
                    this.isContentViewable = false;
                }
            }
        } catch (error) {
            Log('error', 'kb getRecord KbConnectCommunity error --> ' + JSON.stringify(error));
        }
    }

    getTopicLink() {

        function fnCheckTillKBAvailable(execCount, thislcl) {
            try {

                if (thislcl.isKBDataAvailableOnLoad == true && thislcl.isCommunityUser != null && thislcl.isCommunityUser != undefined) {
                    fnToBeCalledOnceKBAvailable(thislcl);
                } else if (execCount < 600) {
                    execCount = execCount + 1;
                    window.setTimeout(function () {
                        fnCheckTillKBAvailable(execCount, thislcl);
                    }, 100);
                }
            } catch (ex) {
                console.error('Method : fnCheckTillKBAvailable - kbrcm:' + ex.message);
            }
        }

        function fnToBeCalledOnceKBAvailable(thislcl) {
            try {
                Log('log', 'kb getProductsTopic');
                if (thislcl.currentPrimaryProduct != undefined && thislcl.currentPrimaryProduct != null) {
                    getProductsTopic({ strKBProduct: thislcl.currentPrimaryProduct }).then((result) => {
                        try {
                            if (result !== null) {
                                var actualdata = result.split("$$##$$");
                                if (actualdata.length > 1) {
                                    thislcl.currentProductsTopicId = actualdata[0];
                                    thislcl.currentProductsTopicName = actualdata[1];
                                    thislcl.currentNavigatedTopicName = actualdata[1];
                                    thislcl.isProductTopicAvailable = true;
                                    thislcl.communityURL = thislcl.INTOPICURL.replace(
                                            "HOSTNAME",
                                            KB_Network_Host
                                        )
                                        .replace("RECORDID", thislcl.currentProductsTopicId)
                                        .replace(
                                            "RECORDNAME",
                                            thislcl.currentProductsTopicName
                                        );
                                } else {
                                    thislcl.isProductTopicAvailable = false;
                                    thislcl.currentNavigatedTopicName =
                                        thislcl.TOPICCATALOGTITLE;
                                    thislcl.communityURL =
                                        thislcl.INTOPICCATALOGURL.replace(
                                            "HOSTNAME",
                                            KB_Network_Host
                                        );
                                }
                            } else {
                                thislcl.isProductTopicAvailable = false;
                                thislcl.currentNavigatedTopicName =
                                    thislcl.TOPICCATALOGTITLE;
                                thislcl.communityURL =
                                    thislcl.INTOPICCATALOGURL.replace(
                                        "HOSTNAME",
                                        KB_Network_Host
                                    );
                            }

                            thislcl.isDataAvailableOnLoad = true;
                        } catch (error) {Log( "error", "kb getProductsTopic error --> " + JSON.stringify(error));
                            thislcl.isProductTopicAvailable = false;
                            thislcl.currentNavigatedTopicName = thislcl.TOPICCATALOGTITLE;
                            thislcl.communityURL = thislcl.INTOPICCATALOGURL.replace('HOSTNAME', KB_Network_Host);
                            thislcl.isDataAvailableOnLoad = true;
                        }
                    })
                    .catch((error) => {
                        Log("error", "getProductsTopic" + JSON.stringify(error));
                        thislcl.isProductTopicAvailable = false;
                        thislcl.currentNavigatedTopicName = thislcl.TOPICCATALOGTITLE;
                        thislcl.communityURL = thislcl.INTOPICCATALOGURL.replace('HOSTNAME', KB_Network_Host);
                        thislcl.isDataAvailableOnLoad = true;
                    });
                }
                else {
                    thislcl.isProductTopicAvailable = false;
                    thislcl.currentNavigatedTopicName = thislcl.TOPICCATALOGTITLE;
                    thislcl.communityURL = thislcl.INTOPICCATALOGURL.replace('HOSTNAME', KB_Network_Host);
                    thislcl.isDataAvailableOnLoad = true;
                }
            } catch (ex) {
                console.error('Method : fnToBeCalledOnceKBAvailable  - kbrcm:' + ex.message);
            }
        }

        fnCheckTillKBAvailable(0, this);
    }

    connectedCallback() {
        try {
            Log('log', 'thislcl.KbConnectCommunity  --> connectedCallback');
            getloggedinprofile()
            .then(result => {
                console.log('External User : ', result);
                if (result) {
                    this.isCommunityUser = true;
                } else {
                    this.isCommunityUser = false;
                }

            })
            .catch(error => {
                this.error = error;
                console.log('error while performing Profile Id check' + this.error);
                this.isCommunityUser = true;
            });
            this.getTopicLink();``  
        } catch (ex) {
            console.error(ex.message);
            this.isCommunityUser = true;
        }
    }

    handleAskQuestionExternal() {
        try {
            fnAskACommunityOmnitureDTM('Ask the Community - Article Details Page - From Started - KB External - ' + this.currentArticleNumber + ' - ' + this.currentNavigatedTopicName);
        } catch (ex) {
            console.error(ex.message);
        }

        window.open(this.communityURL, '_blank');
    }

    handleAskQuestionInternal() {
        try {
            fnAskACommunityOmnitureDTM('Engage the Community - Article Details Page - From Started - KB Internal - ' + this.currentArticleNumber + ' - ' + this.currentNavigatedTopicName);
        } catch (ex) {
            console.error(ex.message);
        }

        window.open(this.communityURL, '_blank');
    }
}