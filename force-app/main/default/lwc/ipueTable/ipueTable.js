import { api, LightningElement } from 'lwc';
export default class IpueTable extends LightningElement {

    updatedTable = {};
    tableHeader = {};
    tableRows = [];
    isLoaded = false;
    numRows;
    numColumns;

    @api currentSectionIndex;
    @api currentFrameIndex;
    @api currentItemIndex;
    @api loadingRows = false;
    @api disableInputs;

    /**************** Getter/Setter Methods ****************/

    @api
    get table() {
        return this.updatedTable;
    }
    set table(value) {
        this.loadingRows = false;

        if (value != null) {
            this.updatedTable = JSON.parse(JSON.stringify(value));
            this.header = this.updatedTable.header;
            this.rows = this.updatedTable.rows;
        }
    }

    @api
    get header() {
        return this.tableHeader;
    }
    set header(value) {
        if (value != null) {
            this.tableHeader = value;
            this.tableHeader.cells.forEach(cell => {
                this.setCellAttributes(cell);
            });
        }
    }

    @api
    get rows() {
        return this.tableRows;
    }
    set rows(value) {
        if (value != null) {

            this.tableRows = value;
            this.numRows = this.tableRows.length; // Number of rows (minus header)

            this.tableRows.forEach((row, index) => {

                this.numColumns = row.cells.length; // Number of columns
                this.setRowAttributes(row, index, this.tableRows.length);

                row.cells.forEach(cell => {
                    this.setCellAttributes(cell);
                });
            });
            this.isLoaded = true;
        }
    }

    connectedCallback() {
        const inputAligncenter = document.createElement('style');
        inputAligncenter.innerText = `.input-text-align_right input{ text-align: right!important; }`;
        document.body.appendChild(inputAligncenter);
    }


    /**************** Handle User Actions ****************/

    handleInput(event) {

        // Update Parent with new values
        const updateEvent = new CustomEvent("updateparent", {
            detail: {
                frameIndex: this.currentFrameIndex,
                sectionIndex: this.currentSectionIndex,
                itemIndex: this.currentItemIndex,
                value: event.target.value,
                rowIndex: event.target.dataset.rowIndex,
                cellIndex: event.target.dataset.cellIndex
            }
        });

        this.dispatchEvent(updateEvent);

    }

    handleAddRow(event) {

        this.loadingRows = true;

        // Update Parent with new values
        const updateEvent = new CustomEvent("addrow", {
            detail: {
                frameIndex: this.currentFrameIndex,
                sectionIndex: this.currentSectionIndex,
                itemIndex: this.currentItemIndex,
                tableId: this.table.parentEstimationId,
                action: "Add Row",
                numRows: this.numRows,
                numColumns: this.numColumns
            }
        });

        this.dispatchEvent(updateEvent);

    }

    openModal;
    rowToDeleteIndex;

    openSpinner = false;
    handleOpenSpinner() {
        this.openSpinner = true;
    }

    handleOpenRemoveRowModal(event) {
        this.openModal = true;
        this.rowToDeleteIndex = event.target.dataset.rowIndex;
    }

    handleCloseRemoveRowModal(event) {
        this.openModal = false;
    }

    onConfirmRowDelete() {

        this.loadingRows = true;
        this.openModal = false;

        // Update Parent with new values
        const updateEvent = new CustomEvent("removerow", {
            detail: {
                frameIndex: this.currentFrameIndex,
                sectionIndex: this.currentSectionIndex,
                itemIndex: this.currentItemIndex,
                tableId: this.table.parentEstimationId,
                action: "Remove Row",
                rowIndex: this.rowToDeleteIndex,
            }
        });

        this.dispatchEvent(updateEvent);

    }

    /**************** Helper Methods ****************/

    setRowAttributes(row, index, size) {

        row.isLastRow = index == (size - 1) ? true : false;

    }

    setCellAttributes(cell) {

        cell.isReadOnly = this.getReadOnly(cell);
        cell.value = this.getValue(cell);
        cell.outputId = this.getOutputId(cell);
        cell.inputType = this.getInputType(cell);
        this.setClassStyles(cell);

    }

    getReadOnly(cell) {

        if (cell.dataType == 'Static Text' || cell.dataType == 'Calculated' || this.disableInputs) {
            return true;
        } else {
            return false;
        }

    }

    getValue(cell) {

        // If Static Text, return the Description Field
        if (cell.dataType == 'Static Text') {
            return cell.description == undefined ? '' : cell.description;

            // Otherwise, return the existing value on the Output record, if available
        } else {

            if (cell.output == undefined) {
                return '';
            } else if (!cell.output.value) {
                return '';
            } else {
                return cell.output.value;
            }
        }

    }

    getOutputId(cell) {

        if (cell.output == undefined) {
            return '';
        } else {
            return cell.output.Id;
        }

    }

    getInputType(cell) {

        if (cell.dataType == 'Number') {
            return 'number';
        } else if (cell.dataType == 'Picklist') {
            return 'picklist';
        } else {
            return 'text';
        }

    }

    setClassStyles(cell) {

        // Set common css styles
        let inputStyle = 'input-field slds-input';
        let cellStyle = 'table-cell';

        // Row 0 is always header
        if (cell.rowNumber == 0) {
            cell.inputStyle = inputStyle + ' header';
            cell.cellStyle = cellStyle + ' header';

            // All Estimation Schedules with Static Text or Calculated should be read only
        } else if (cell.dataType == 'Static Text' || cell.dataType == 'Calculated') {
            cell.inputStyle = inputStyle + ' read-only';
            cell.cellStyle = cellStyle + ' read-only';

            // Otherwise the field should be editable
        } else {
            cell.inputStyle = inputStyle + ' editable';
            cell.cellStyle = cellStyle + ' editable';
        }

    }

}