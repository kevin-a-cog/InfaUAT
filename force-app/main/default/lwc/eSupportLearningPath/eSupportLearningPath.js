/*
 * Name         :   ESupportLearningPath
 * Author       :   Utkarsh Jain
 * Created Date :   15-FEB-2022
 * Description  :   Component used to show Learning Path

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain          15-FEB-2022      I2RT-5420           Initial version.                                          NA
 */
import { LightningElement, track } from 'lwc';
import learningPathURL from '@salesforce/label/c.learning_path_url';
import lp_page_url from '@salesforce/label/c.lp_page_url';

export default class ESupportLearningPath extends LightningElement {
    @track lpURL = learningPathURL;
	@track pageUrl = lp_page_url;

    renderedCallback(){
		this.iframeValue = this.template.querySelector('.es-learning-path');
		window.inLearningPath = this.iframeValue;
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod === "attachEvent" ? "onmessage" : "message";

		eventer(messageEvent, function (e) {
			if (e.data === "reloadPage-XF" || e.message === "reloadPage-XF") {
				console.log('Test in eSupport XF');
				window.inLearningPath.src = learningPathURL ;
			}
			console.log(e);
		});
    }
}