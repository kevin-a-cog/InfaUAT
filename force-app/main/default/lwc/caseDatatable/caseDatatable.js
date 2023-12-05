import LightningDatatable from 'lightning/datatable';
import recordNameColumn from './recordNameColumn.html';

export default class CaseDatatable extends LightningDatatable {
    static customTypes = {
        recordName: {
            template: recordNameColumn,
            typeAttributes: ['recId', 'recordNumber', 'isEscalated', 'showPreview']
        }
    }
}