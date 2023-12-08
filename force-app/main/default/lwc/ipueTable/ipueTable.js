/*
    @Author:        Advanced Technology Group
    @Created Date:  October 2021
    @Description:   This is the LWC for for the Page Section tables belonging to an IPUE Esitmator instance

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date            JIRA No.       Description                                                 Tag

    Colton Kloppel        October 2021    PUE-53         Initial Create
    Kevin Antonioli   `   November 2023   PNP-512        Add table locking/unlocking functionality                   <T01>
    ********************************************************************************************************************************************
*/
import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import tableLockMessage from "@salesforce/label/c.Table_Lock_Message"; // <T01>, table lock functionality
import updateEstimationOutputsForLockedTable from "@salesforce/apex/IPUE_FormController.updateEstimationOutputsForLockedTable"; // added for <T01>

export default class IpueTable extends LightningElement {
  @api currentSectionIndex;
  @api currentFrameIndex;
  @api currentItemIndex;
  @api loadingRows = false;
  @api sectionJustChecked = false; // <T01> if the section was just checked, ensure that the table inputs are read only
  @api numerator; // <T01>: show dynamic progress as user fills out table
  @api denominator; // <T01>: show dynamic progress as user fills out table
  @api progress; // <T01>: show dynamic progress as user fills out table
  @api tableLockedFlag = false; // <T01>

  hasRendered = false; // <T01>

  updatedTable = {};
  tableHeader = {};
  tableRows = []; // non-header rows

  defaultEditableCellIndexesByRowIndex = {}; // <T01> gather default editable input cell indexes
  isLoaded = false;
  tableRenderedFlag = false; // <T01>, track if a field within a table has changed

  calculationCompleteFlag = false; // <T01>, track status of calculation
  fieldChangedFlag = false; // <T01>: track if a table field is changed
  showTableLockSpinner = false; // <T01>, show a spinner over the locked table when it is relocked to trigger calculation
  tableLockMessage = tableLockMessage; // <T01>, show a message above the table during calculation
  showTableLockMessage = false; // <T01>, show a message above the table during calculation
  numRows;
  numColumns;

  inputRowIndexes = []; // <T01>
  inputValueByCellIndex = {}; // <T01>
  inputValueByOutputId = {}; // <T01>
  prevInputValue; // <T01>
  prevInputValueByCellIndex = {}; // <T01>
  prepopInputFocusedFlag = false; // <T01>

  firstHeaderCellIndex; // <T01>
  firstRowIndex; // <T01>

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
      //this.header.cells[0].isChecked = true;
      //this.header = { ...this.header };

      this.rows = this.updatedTable.rows; // non-header rows
    }
  }

  @api
  get header() {
    return this.tableHeader;
  }
  set header(value) {
    if (value != null) {
      this.tableHeader = value;
      // <T01>: converted forEach to index iterator
      for (let i = 0; i < this.tableHeader.cells.length; i++) {
        let cell = this.tableHeader.cells[i];
        this.setCellAttributes(cell, i, 0, true /*isHeaderCell*/);
      }
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

      this.tableRows.forEach((row, rowIndex) => {
        this.numColumns = row.cells.length; // Number of columns
        this.setRowAttributes(row, rowIndex, this.tableRows.length);
        // <T01>: converted forEach to index iterator
        for (let i = 0; i < row.cells.length; i++) {
          let cell = row.cells[i];
          //if (!this.tableRenderedFlag) {
          this.gatherDefaultEditableCellIndexes(cell, i, rowIndex); // <T01>, table locking functionality

          //}
          this.setCellAttributes(cell, i, rowIndex, false /* isHeaderCell*/);
        }
      });
      this.isLoaded = true;
    }
  }

  connectedCallback() {
    this.tableRenderedFlag = true; // <T01>
    const inputAligncenter = document.createElement("style");
    inputAligncenter.innerText = `.input-text-align_right input{ text-align: right!important; }`;
    document.body.appendChild(inputAligncenter);
  }

  renderedCallback() {
    if (this.hasRendered) {
      return;
    }
    this.hasRendered = true;
  }

  /**************** Handle User Actions ****************/

  /**
   * <T01> new method for table progress ring accuracy
   * @param {*} event focus event
   * @return void
   */
  handleInputFocus(event) {
    const rowIndex = event.target.dataset.rowIndex;
    const inputCellIndex = event.target.dataset.cellIndex;
    let inputValue = event.target.value;

    const originalValue =
      this.tableRows[rowIndex].cells[inputCellIndex].output.value;

    // on focus of input, see if the input has both an original and current value
    if (originalValue && inputValue) {
      this.prepopInputFocusedFlag = true;
    }
  }

  /**
   * <T01> refactor/rename method and move updateparent event emission to handleTableLockChange
   * @param {*} event focusout event
   * @return void
   */
  handleInputFocusOut(event) {
    this.sectionJustChecked = false;
    const rowIndex = event.target.dataset.rowIndex;
    const inputCellIndex = event.target.dataset.cellIndex;
    let inputValue = event.target.value;

    const cell = this.tableRows[rowIndex].cells[inputCellIndex];
    const originalValue = cell.output.value;

    this.animateProgressRing(inputValue, originalValue, inputCellIndex);

    if (inputValue !== originalValue) {
      this.fieldChangedFlag = true;
    }

    if (this.inputRowIndexes.indexOf(rowIndex) === -1) {
      this.inputRowIndexes.push(rowIndex);
    }

    this.inputValueByCellIndex[inputCellIndex] = inputValue; // TODO: accommodate for multple editable rows in a table
    this.prepopInputFocusedFlag = false;
    this.inputValueByOutputId[cell.outputId] = inputValue; // TODO: accommodate for multple editable rows in a table

    const tableInputEvent = new CustomEvent("tableinput", {
      detail: {
        frameIndex: this.currentFrameIndex,
        sectionIndex: this.currentSectionIndex,
        itemIndex: this.currentItemIndex,
        rowIndex: rowIndex,
        cellIndex: inputCellIndex,
        numerator: this.numerator,
        denominator: this.denominator,
        progress: this.progress,
        tableLockedFlag: this.tableLockedFlag
      }
    });
    this.dispatchEvent(tableInputEvent);
  }

  /**
   * <T01> animate table progress ring for tables reactively as user enters values into table
   * @param {string} inputValue      value user entered into table cell
   * @param {string} originalValue   original value of table cell user made edit to
   * @param {integer} inputCellIndex  index of table cell user made edit to
   * @return void
   */
  animateProgressRing(inputValue, originalValue, inputCellIndex) {
    if (
      inputValue &&
      this.numerator !== this.denominator &&
      inputValue !== this.prevInputValueByCellIndex[inputCellIndex] &&
      inputValue !== originalValue &&
      !this.prepopInputFocusedFlag
    ) {
      this.numerator += 1;
    } else if (
      !inputValue &&
      inputValue !== this.prevInputValueByCellIndex[inputCellIndex]
    ) {
      if (this.numerator > 0) {
        this.numerator -= 1;
      }
    }

    if (!inputValue) {
      this.prevInputValueByCellIndex[inputCellIndex] = "";
    } else {
      this.prevInputValueByCellIndex[inputCellIndex] = inputValue;
    }
    if (inputValue && this.prevInputValueByCellIndex[inputCellIndex] == "") {
      this.prevInputValueByCellIndex[inputCellIndex] = undefined;
    }

    if (this.numerator > this.denominator) {
      this.numerator -= 1;
    }

    this.progress = (this.numerator / this.denominator) * 100;
  }

  /**
   * handle add row to table
   * @param {*} event onaddrow custom event
   * @return void
   */
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

  /**
   * handle remove row modal
   * @param {*} event onclick event
   */
  handleOpenRemoveRowModal(event) {
    this.openModal = true;
    this.rowToDeleteIndex = event.target.dataset.rowIndex;
  }

  /**
   * handle close remove row modal
   * @param {*} event onclick event
   */
  handleCloseRemoveRowModal(event) {
    this.openModal = false;
  }

  /**
   * handle close remove row modal (happens onclick)
   * @param null
   * return void
   */
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
        rowIndex: this.rowToDeleteIndex
      }
    });

    this.dispatchEvent(updateEvent);
  }

  /**************** Helper Methods ****************/

  /**
   * set attributes for row
   * @param {row} row
   * @param {integer} index
   * @param {integer} size
   */
  setRowAttributes(row, index, size) {
    row.isLastRow = index == size - 1 ? true : false;
  }

  /**
   * set attributes for cell
   * @param {cell} cell
   * @param {integer} cellIndex     //<T01>; added
   * @param {boolean} isHeaderCell  //<T01>: added
   */
  setCellAttributes(cell, cellIndex, rowIndex, isHeaderCell) {
    const cellValue = this.getValue(cell);

    // <T01>: add condition and editable lock icon to first header cell of a table, unless that cell has a description
    if (isHeaderCell && cellIndex === 0 && !cellValue.length) {
      this.firstHeaderCellIndex = cellIndex;
      cell.isLockToggle = true;
      cell.isReadOnly = false;
      if (!this.tableRenderedFlag) {
        cell.value = true;
        cell.isChecked = true;
      } else {
        cell.value = cell.isChecked;
      }
    } else {
      cell.isLockToggle = false;

      // pre-existing logic that existed before <T01>:
      cell.isReadOnly = this.getReadOnly(cell);
      cell.inputType = this.getInputType(cell);
      cell.value = this.getValue(cell);
    }

    cell.outputId = this.getOutputId(cell);
    this.setClassStyles(cell);
  }

  /**
   * <T01> new method for table locking functionality
   * @param {cell} cell         default editable cell
   * @param {integer} cellIndex default editable cell index
   * @param {integer} rowIndex  default editable cell's row index
   * @return void
   */
  gatherDefaultEditableCellIndexes(cell, cellIndex, rowIndex) {
    if (
      cell.dataType != "Calculated" &&
      cell.dataType != "StaticText" &&
      !this.disableInputs &&
      (cell.dataType == "Number" || cell.dataType == "Picklist")
    ) {
      if (!this.defaultEditableCellIndexesByRowIndex.hasOwnProperty(rowIndex)) {
        this.defaultEditableCellIndexesByRowIndex[rowIndex] = [];
      }
      if (
        this.defaultEditableCellIndexesByRowIndex[rowIndex].indexOf(
          cellIndex
        ) === -1
      ) {
        this.defaultEditableCellIndexesByRowIndex[rowIndex].push(cellIndex);
      }
    }
  }

  /**
   * get read only property for cell
   *  <T01>: modify this method to support table locking functionality
   * @param {*} cell   cell to get read only property for
   * @return {boolean} whether cell is to be read only or not
   */
  getReadOnly(cell) {
    let returnVal = false;
    if (
      cell.dataType == "Static Text" ||
      cell.dataType == "Calculated" ||
      this.disableInputs ||
      this.sectionJustChecked ||
      !this.hasRendered ||
      this.tableLockedFlag
    ) {
      returnVal = true;
    }

    return returnVal;
  }

  /**
   * get value for cell
   * @param {*} cell
   * @return void
   */
  getValue(cell) {
    // If Static Text, return the Description Field
    if (cell.dataType == "Static Text") {
      return cell.description == undefined ? "" : cell.description;

      // Otherwise, return the existing value on the Output record, if available
    }

    if (cell.output == undefined) {
      return "";
    } else if (!cell.output.value) {
      return "";
    }
    return cell.output.value;
  }

  /**
   * get output id for cell
   * @param {*} cell
   * @return void
   */
  getOutputId(cell) {
    if (cell.output == undefined) {
      return "";
    }
    return cell.output.Id;
  }

  /**
   * get input type for cell
   * @param {*} cell
   * @return void
   */
  getInputType(cell) {
    if (cell.dataType == "Number") {
      return "number";
    } else if (cell.dataType == "Picklist") {
      return "picklist";
    }
    return "text";
  }

  /**
   * set class styles for cell
   * @param {*} cell
   * @return void
   */
  setClassStyles(cell) {
    // Set common css styles
    let inputStyle = "input-field slds-input";
    let cellStyle = "table-cell";

    // Row 0 is always header
    if (cell.rowNumber == 0) {
      cell.inputStyle = inputStyle + " header table-lock";
      cell.cellStyle = cellStyle + " header";

      // All Estimation Schedules with Static Text or Calculated should be read only
    } else if (
      cell.dataType == "Static Text" ||
      cell.dataType == "Calculated"
    ) {
      cell.inputStyle = inputStyle + " read-only";
      cell.cellStyle = cellStyle + " read-only";

      // Otherwise the field should be editable
    } else {
      cell.inputStyle = inputStyle + " editable";
      cell.cellStyle = cellStyle + " editable";
    }
  }

  /**
   * <T01>: new method, handle when user unlocks/locks a fixed or elastic table
   * @param {*} event
   * @return void
   */
  handleTableLockChange(event) {
    const firstHeaderCellIndex = event.target.dataset.cellIndex;
    const parentPageSectionId = event.target.dataset.parentPageSectionId;
    const applyOverlay = !event.target.checked;

    this.header.cells[firstHeaderCellIndex].isChecked = event.target.checked; // consider removing
    this.header = { ...this.header }; // consider removing
    this.tableLockedFlag = event.target.checked;

    let performCalculation = false;
    if (this.fieldChangedFlag && event.target.checked) {
      performCalculation = true;
      this.showTableLockSpinner = true;
      this.tableLockMessage = "Calculating Estimates...";
    }

    const tableElement = this.template.querySelector(
      '[data-id="' + parentPageSectionId + '"]'
    );
    if (tableElement) {
      if (!event.target.checked) {
        this.focusTable(parentPageSectionId);
      } else if (!performCalculation) {
        this.unfocusTable(parentPageSectionId);
      }
    }
    this.showTableLockMessage = event.target.checked ? false : true;
    this.reactivelyToggleReadOnly(event.target.checked);

    const tableLockToggleEvent = new CustomEvent("tablelocktoggle", {
      detail: {
        applyOverlay: applyOverlay,
        performCalculation: performCalculation,
        parentPageSectionId: parentPageSectionId,
        isLocked: event.target.checked
      }
    });
    this.dispatchEvent(tableLockToggleEvent);
    console.log("ipueTable tableLockToggleEvent event emitted");

    if (performCalculation) {
      this.showTableLockMessage = true;

      updateEstimationOutputsForLockedTable({
        inputValueByOutputId: this.inputValueByOutputId
      })
        .then((result) => {
          // Update Parent with new values
          const updateEvent = new CustomEvent("updateparent", {
            detail: {
              frameIndex: this.currentFrameIndex,
              sectionIndex: this.currentSectionIndex,
              itemIndex: this.currentItemIndex,
              rowIndexes: this.inputRowIndexes,
              values: Object.values(this.inputValueByCellIndex),
              cellIndexes: Object.keys(this.inputValueByCellIndex),
              performCalculation: performCalculation
            }
          });
          this.dispatchEvent(updateEvent);
        })
        .catch((error) => {
          console.log("Error toggling table lock: ", error?.body?.message);
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error toggling table lock",
              message: error?.body?.message,
              variant: "error"
            })
          );
        });
    }
  }

  //
  /**
   * <T01> new method, reactively toggle the read only property of cells based on whether table is locked/unlocked
   * @param {boolean} tableLocked
   * @return void
   */
  reactivelyToggleReadOnly(tableLocked) {
    // reactively make the section table's applicable cells editable
    for (let key in this.defaultEditableCellIndexesByRowIndex) {
      // loop through indexes of cells that are supposed to be editable by default
      for (
        let i = 0;
        i < this.defaultEditableCellIndexesByRowIndex[key].length;
        i++
      ) {
        this.rows[key].cells[i + 1].isReadOnly = tableLocked;
      }
    }
  }

  /**
   * <T01>: new method, use dynamic z-indexes to focus a table that was unlocked
   * @param {Id} parentPageSectionId
   * @return void
   */
  focusTable(parentPageSectionId) {
    this.template.querySelector(
      '[data-id="' + parentPageSectionId + '"]'
    ).className = "table-z-index";
  }

  /**
   * <T01>: new method, use dynamic z-indexes unfocus a table that was locked
   * @param {Id} parentPageSectionId
   * @return void
   */
  unfocusTable(parentPageSectionId) {
    this.template.querySelector(
      '[data-id="' + parentPageSectionId + '"]'
    ).className = "";
  }

  /**
   * T01>: new method: after calculation of table complete, reset properties on table
   * @param null
   * @return void
   */
  @api
  resetPropertiesOnTable() {
    console.log("ipue-table resetPropertiesOnTable");
    this.template.querySelectorAll(".table-z-index").forEach((objElement) => {
      objElement.className = "";
    });
    this.showTableLockSpinner = false;
    this.fieldChangedFlag = false;
    this.showTableLockMessage = false;
    this.tableLockMessage = tableLockMessage;
    this.calculationCompleteFlag = true;
    this.prevInputValueByCellIndex = {};
    this.prepopInputFocusedFlag = false;
    this.sectionJustChecked = false;
    this.hasRendered = false;
  }
}
