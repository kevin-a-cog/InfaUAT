import { api, LightningElement } from 'lwc';

export default class FloatingIcon extends LightningElement {
    @api
    action;

    handleClick(event) {
        switch (event.currentTarget.dataset.name) {
            case 'fab':
                this.template.querySelector('.widget').classList.toggle('active');
                break;
            case 'fab-action':
                //this.template.querySelector('.widget').classList.toggle('active');
                this.dispatchEvent(new CustomEvent('fabclick', {
                    detail: event.currentTarget.dataset.action
                }));
                break;
            default:
                break;
        }

    }
}