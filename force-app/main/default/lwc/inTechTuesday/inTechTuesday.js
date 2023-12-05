import { LightningElement, track } from 'lwc';
import help_techTuesday from '@salesforce/label/c.help_techTuesday'; 
import tt_page_url from '@salesforce/label/c.tt_page_url';

export default class InTechTuesday extends LightningElement {
    @track TTURL = help_techTuesday;
	@track pageUrl = tt_page_url;

    renderedCallback(){
		this.iframeValue = this.template.querySelector('.TTClass');
		window.inTechTuesday = this.iframeValue;
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod === "attachEvent" ? "onmessage" : "message";

		eventer(messageEvent, function (e) {
			if (e.data === "reloadPage-XF" || e.message === "reloadPage-XF") {
				window.inTechTuesday.src = help_techTuesday ;
			}
			console.log(e);
		});
    }
}