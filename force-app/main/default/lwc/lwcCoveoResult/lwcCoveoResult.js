/*
   @created by       : 
   @created on       : 
   @Purpose          : 
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  06-Nov-2023      |                           |                   |   Initial Version
 |     2      |  07-Nov-2023      |   Sathish R               |                   |   Coveo Chat Bot customization
 ****************************************************************************************************
 */

import { LightningElement, api, track } from 'lwc';

export default class LwcCoveoResult extends LightningElement {
  @api result;
  @api rank;
  @track resultType;
  excerptHighlights = '';
  coveoLoaded = false;

  connectedCallback() {
    if(this.result) {
      this.content = this.result.title;
      if (this.isYoutube) {
        this.content = 'https://www.youtube.com/embed/' + this.result.raw.ytvideoid;
      }
    }
  }

  handleClick() {
    this.dispatchEvent(new CustomEvent('resultclick', { detail: this.rank }));
  }

  get isYoutube() {
    return this.result && this.result.raw && this.result.raw.filetype === 'YouTubeVideo';
  }

  get isAnswer() {
    return this.result && this.result.raw && this.result.raw.objecttype === 'QuestionAnswer';
  }

  get isAnythingElse() {
    return this.result && !this.isYoutube && !this.isAnswer && !this.isProductDoc && !this.isDiscussionBlog && !this.isFeedComment;//T02//
  }

    //T02 - Start//
  get hasChildResult() {
    return  this.result && this.result.childResults && (this.result.childResults.length > 0);
  }

  get childResultsToDisplay() {
    if (this.hasChildResult) {
      return this.result.childResults.map((resultchild, idx) => ({ ...resultchild, rank: idx })).slice(0, 1);
    }
    return [];
  }

  get isProductDoc()
  {
    return this.result && this.result.raw && this.result.raw.infadocumenttype && this.result.raw.infadocumenttype == 'DocPortal';
  }

  get isDiscussionBlog()
  {
    return this.result && this.result.raw && this.result.raw.infadocumenttype && (this.result.raw.infadocumenttype == 'UserFeed' || this.result.raw.infadocumenttype == 'CollaborationGroupFeed' || this.result.raw.infadocumenttype == 'Event' || this.result.raw.infadocumenttype == 'Idea');
  }

  get isFeedComment()
  {
    return this.result && this.result.raw && this.result.raw.infadocumenttype && this.result.raw.infadocumenttype == 'FeedComment';
  }

  //T02 - End//
}