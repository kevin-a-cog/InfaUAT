import {api, LightningElement } from 'lwc';


export default class UnescapeHtmlLwc extends LightningElement {
    @api text = '';

renderedCallback(){
        let strCustomCSS = "c-unescape-html-lwc td { border-top: none !important; white-space: normal !important; } " + "c-unescape-html-lwc th { white-space: normal !important; }";
        this.template.querySelector('.textCls').innerHTML = decodeURIComponent(encodeURIComponent(this.text));
        this.template.querySelector('.customCSS').innerHTML = "<style> " + strCustomCSS + " </style>";
    }

}