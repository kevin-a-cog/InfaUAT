import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import KBOktawindowtimer from '@salesforce/label/c.KBOktawindowtimer';
import OKtaInternalCommunity from '@salesforce/label/c.OKtaInternalCommunity';

export default class KbInternalOktaLoad extends LightningElement {

    @wire(CurrentPageReference) currentPageReference;

    label = {
        KBOktawindowtimer,
        OKtaInternalCommunity
    };
    isStillLoading;
   

    connectedCallback() {
        const param = 'internal';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        console.log('paramvalue'+paramValue);
        if(paramValue == '1'){
            this.isStillLoading = true;
            //this.template.querySelector('[data-id="feedbacksec"]').className = 'slds-align_absolute-center';
            var TheNewWin = window.open(OKtaInternalCommunity, "ForceLogin", "menubar=no,location=no,resizable=no,scrollbars=no,status=no,width=100,height=100");                
            let div = document.createElement('div');
            div.id = 'content';
            div.className = 'overlay';
            div.innerHTML = '<p style="display:none;">Loading</p>';
            document.body.appendChild(div);

                console.log('okta timer'+KBOktawindowtimer);                
                setTimeout(function () { 
                    TheNewWin.close();
                    this.isStillLoading =false;
                   // this.template.querySelector('[data-id="feedbacksec"]').className='slds-hidden';
                    var urlv = window.location.href;
                    console.log('url'+urlv);
                    if (urlv.indexOf("?")>-1){    
                        console.log('index exists'+urlv);                                        
                                              
                        //var newUrl = this.removeParams('internal');

                        var sParam = 'internal';
                        var url2 = window.location.href.split('?')[0]+'?';
                        console.log('url'+url2);
                        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                            sURLVariables = sPageURL.split('&'),
                            sParameterName,
                            i;
                        console.log('sPageURL'+sPageURL);
                        for (i = 0; i < sURLVariables.length; i++) {
                            sParameterName = sURLVariables[i].split('=');
                            if (sParameterName[0] != sParam) {
                                url2 = url2 + sParameterName[0] + '=' + sParameterName[1] + '&';
                            }
                        }
                        console.log('newUrl'+newUrl);    
                        var newUrl = url2.substring(0,url2.length-1);
                        window.location.href = newUrl;
                    }
                
                }, KBOktawindowtimer);             
                
        }        
    }
    
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    getUrlwithoutParamValue(url) {
        console.log('withourparam'+url.substr(0,url.indexOf("?")));
        return url.substr(0,url.indexOf("?"));
    }   
    
}