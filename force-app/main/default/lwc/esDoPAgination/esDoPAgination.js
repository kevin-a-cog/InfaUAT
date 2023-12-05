import { LightningElement } from 'lwc';

export default class EsDoPAgination extends LightningElement {
    previousHandler() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        this.dispatchEvent(new CustomEvent('next'));
    }

   firstHandler() {
      // alert('do pag ');
        this.dispatchEvent(new CustomEvent('first'));
    }

    lastHandler() {
        this.dispatchEvent(new CustomEvent('last'));
    }

}