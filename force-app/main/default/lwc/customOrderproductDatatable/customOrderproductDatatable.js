import LightningDatatable from 'lightning/datatable'
import customNavigationTemplate from './customNavigationType.html'

export default class CustomOrderproductDatatable extends LightningDatatable {
    static customTypes = {
        navigation: {
            template: customNavigationTemplate,
            // Provide template data here if needed
            typeAttributes: ['label','rowid'],
        }
       //more custom types here
    };
}