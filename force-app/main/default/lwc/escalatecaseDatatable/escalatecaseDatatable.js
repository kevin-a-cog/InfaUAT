import LightningDatatable from 'lightning/datatable';
import caseNumberColumn from './caseNumberColumn.html';

export default class EscalatecaseDatatable extends LightningDatatable {
    static customTypes = {
        recordName: {
            template: caseNumberColumn,
            typeAttributes: ['recId', 'recordNumber', 'isEscalated', 'showPreview']
        }
    }
}