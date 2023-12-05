/*
 * Name         :   HelpLearningPathDisplay
 * Author       :   Prashanth Bhat
 * Created Date :   13-SEP-2023
 * Description  :   This component is a used to display learning path in product community detail pages.

 Change History
 ******************************************************************************************************************************
 Modified By            Date            Jira No.        Description                                         Tag
 ******************************************************************************************************************************
 Prashanth Bhat         13-SEP-2023     I2RT-6205       Product Community: Bringing Learning Path in 
                                                        the Product detail Page                             Initial Version
 */


import { LightningElement,api,track} from 'lwc'; 
import getLearningPathURL from "@salesforce/apex/HelpLearningPathDisplay.getLearningPathURL";

export default class HelpLearningPathDisplay extends LightningElement {
   @api recordId;
   @track learningPathUrl;
   @track showLearningPath = false;
   @track iframeValue;

   connectedCallback(){
      getLearningPathURL({ commId: this.recordId})
      .then(result => {
          if(result != null){
            this.showLearningPath = true;
            this.learningPathUrl = result;
            this.error = undefined; 
            console.log('this.learningPathUrl :'+JSON.stringify(this.learningPathUrl));         
          } 
          else{
            this.showLearningPath = false;
          }
       })
      .catch(error => {
          this.error = error;
          this.learningPathUrl = undefined;
       });  
   }

   renderedCallback(){
      this.iframeValue = this.template.querySelector('.help-Learning');
		window.helpLearning = this.iframeValue;
      var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod === "attachEvent" ? "onmessage" : "message";

		eventer(messageEvent, function (e) {
			if (e.data === "reloadPage-XF" || e.message === "reloadPage-XF") {
				window.helpLearning.src = this.learningPathUrl ;
			}
			console.log(e);
		});
   }
}