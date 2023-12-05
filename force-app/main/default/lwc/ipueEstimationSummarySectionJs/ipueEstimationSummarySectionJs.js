import { api } from 'lwc';
import LightningModal from 'lightning/modal';
export default class IpueEstimationSummarySectionJs extends LightningModal {
    @api formData;
    data = [];
    totalIPU = 0;

    connectedCallback(){

        

        this.formData.pages.forEach(page => {
            let pageIPU = 0;
            let selectedSections = false;
            let new_page_item = {
                "Id": page.Id,
                "Section_Total__c": pageIPU,
                "Name": page.name,
                "isPage":true,
                "hasSelectedSections":false
            };
            let new_item = {};
            this.data.push(new_page_item);
            page.frames.forEach(frame => {
                frame.pageSections.forEach(section => {
                    if(section.selectedPageSection && section.showSectionTotal && section.sectionTotal != 0 && section.sectionTotal != null && section.sectionTotal != '') {
                        new_item = {
                            "Id": section.Id,
                            "Section_Total__c": section.sectionTotal,
                            "Name": section.name,
                            "isPage":false
                        };
                        this.totalIPU += section.sectionTotal;
                        pageIPU += section.sectionTotal;
                        this.data.push(new_item);
                        if(selectedSections != true){
                            selectedSections = section.selectedPageSection;
                        }
                    }
                });
            });
            // Find the index of the new_page_item in the this.data array
            const index = this.data.findIndex(item => item.Id === new_page_item.Id);

            if (index !== -1) {
                // Update the Section_Total__c property
                this.data[index].Section_Total__c = pageIPU;
                this.data[index].hasSelectedSections = selectedSections
            } else {
                console.log("Item not found in this.data");
            }
        });

    }
}