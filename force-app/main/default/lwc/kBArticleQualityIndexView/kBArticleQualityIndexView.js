import { LightningElement, track, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import getKBArticleQualityIndexScore from '@salesforce/apex/KBLWCHandler.getKBArticleQualityIndexScore';
import { getRecord } from 'lightning/uiRecordApi';

const ARTICLE_FIELDS = [
	'Knowledge__kav.Id',
	'Knowledge__kav.KnowledgeArticleId',
	'Knowledge__kav.is_Current_User_the_Author__c'
];

export default class KBArticleQualityIndexView extends LightningElement {
	@api recordId;

	varIsCurrentUserAuthor;
	varArticleQualityIndexScore;
	@track boolVisible = false;

	@wire(getRecord, { recordId: '$recordId', fields: ARTICLE_FIELDS })
	article({ error, data }) {
		if (error) {
			console.log('KBArticleQualityIndexView : error - ' + JSON.stringify(error));
		} else if (data) {
			this.varIsCurrentUserAuthor = data.fields.is_Current_User_the_Author__c.value;
			console.log('kbAArticleQualityIndexView varIsCurrentUserAuthor : ' + this.varIsCurrentUserAuthor);
			if (this.varIsCurrentUserAuthor) {
				getKBArticleQualityIndexScore({ articleId: this.recordId })
					.then((result) => {
						if (result) {
							console.log('kbAArticleQualityIndexView getKBArticleQualityIndexScore : ' + result);
							this.varArticleQualityIndexScore = result;
							this.boolVisible = true;

							//     this.kbFollow = result;
							//     this.isFollowed=this.kbFollow.Is_Followed__c;
							//     this.kbFollowExists=true;
							//     this.rerenderFollowButton();
						}
					})
					.catch((error) => {
						console.log('error - ' + JSON.stringify(error));
					});
			}
		}
	}

	connectedCallback() {
		console.log('kbAArticleQualityIndexView recordId : ' + this.recordId);
		console.log('kbAArticleQualityIndexView userid : ' + Id);
	}
}