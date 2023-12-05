import { api, LightningElement } from 'lwc';

export default class CollapsibleSectionWithAction extends LightningElement {
    @api action;
    @api menu;
    @api recordId;
    @api isParent = false;

    get headerStyle() {
        return 'padding-right:0 !important;' + (this.isParent ? 'background: rgb(234, 245, 254)' : 'background: rgb(235, 247, 230)');
    }

    connectedCallback() {
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
		.green svg {
            fill : rgb(46, 132, 74);
        }

        .blue svg {
            fill : rgb(27, 150, 255);
        }

        .yellow svg {
            fill : rgb(254, 147, 57);
        }

        .yellow:active svg, .yellow:hover svg, .yellow:focus svg {
            fill : rgb(254, 147, 57);
        }

        .smaller-icon svg {
            width: 10px;
        }
                                        `;
        document.head.appendChild(globalStyle);
    }

    handleClick(event) {
        const _detail = {
            name: event.target.dataset.name,
            recordId: this.recordId
        };

        if (event.target.dataset.name == 'additionalInfoMilestone' || event.target.dataset.name == 'additionalInfoObjective') {
            event.target.classList.toggle("yellow");
            _detail.additionalInfo = {
                showAdditionalInfo: Array.from(event.target.classList).indexOf('yellow') != -1
            }
        }
        this.dispatchEvent(new CustomEvent('action', {
            detail: _detail
        }));
    }

    handleSectionClick(event) {
        switch (event.currentTarget.dataset.name) {
            case 'accordionHeader':
                if (!event.target.dataset.name) {
                    const accordionSection = this.template.querySelector('[data-name="accordionSection"]');
                    accordionSection.classList.toggle('slds-is-open');

                    const accordionIcon = this.template.querySelector('[data-name="accordion-icon"]');
                    accordionIcon.iconName = accordionSection.classList.value.includes('slds-is-open') ? 'utility:switch' : 'utility:chevronright';
                }
                event.stopPropagation();
                break;

            default:
                break;
        }
    }

}