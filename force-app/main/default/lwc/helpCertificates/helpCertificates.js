/*
 * Name         :   certificatesPathURL
 * Author       :   Utkarsh Jain
 * Created Date :   15-FEB-2022
 * Description  :   Component used to show certificates.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain          15-FEB-2022      I2RT-5416           Initial version.                                          NA
 */
import { LightningElement, track } from 'lwc';
import certificatesPathURL from '@salesforce/label/c.certificates_url';
import certificatesPageURL from '@salesforce/label/c.certificate_page_url';

export default class HelpCertificates extends LightningElement {
    @track certificatesURL = certificatesPathURL;
	@track pageUrl = certificatesPageURL;
	@track iframeValue;

    renderedCallback(){
		this.iframeValue = this.template.querySelector('.help-certificates');
		window.helpCertificate = this.iframeValue;
        var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
		var eventer = window[eventMethod];
		var messageEvent = eventMethod === "attachEvent" ? "onmessage" : "message";

		eventer(messageEvent, function (e) {
			if (e.data === "reloadPage-XF" || e.message === "reloadPage-XF") {
				window.helpCertificate.src = certificatesPathURL ;
			}
			console.log(e);
		});
    }
}