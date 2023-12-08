/*
    @Author:        Advanced Technology Group
    @Created Date:  October 2021
    @Description:   This is the LWC for the end user IPU Estimator Page
    Assimilates form data based on admin-configs
    TODO: in apex controller, only query data on an as needed basis based on the current Page__c the user is on

    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                 Tag

    Colton Kloppel        October 2021  IPUE-53         Initial Create
    Kevin Antonioli   `   October 2023  PNP-512         Optimize performance (front end)                            <T01>
                          November 2023 PNP-512         Add table lock functionality                                <T02>
                          November 2023 PNP-515         Optimize performance (back end)                             <T03>
    ********************************************************************************************************************************************
*/
import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import integrationMessage from "@salesforce/label/c.IPUE_Integrations_not_yet_run";
import checkForFeedExist from "@salesforce/apex/IPUE_FormController.checkForFeedItemExist";
import handleInitialSectionToggle from "@salesforce/apex/IPUE_FormController.handleInitialSectionToggle"; // <T01>
import updateSummaryLinesForToggledSection from "@salesforce/apex/IPUE_FormController.updateSummaryLinesForToggledSection"; // <T01>

import {
  publish,
  subscribe,
  MessageContext,
  APPLICATION_SCOPE
} from "lightning/messageService";
import openChatter from "@salesforce/messageChannel/openChatter__c";
export default class IpueEstimatorPage extends LightningElement {
  INTEGRATION_MESSAGE = integrationMessage;

  @api totalEstimation;
  @api apexRunning;
  @api apexRunningMessage;
  @api loadingRows;
  @api estimationSummaryId;
  @api isInternalUser;
  @api pageNumber; // <T01>

  frames = [];
  sectionLoadingMessage = "Loading section..."; // <T01>: cosmetics
  pageInstance;
  showNoteModal = false;
  sDocButtons;
  disableInputs;
  isClosedValue;
  estOutputLayoutSize = 7;

  currentFrameIndex;
  currentSectionIndex;
  currentItemIndex;
  currentNotes;

  progressRingAttrMap = {};

  /**************** Getter/Setter Methods *****************/

  @api get page() {
    this.frames = [...this.pageInstance.frames];
    return this.pageInstance;
  }
  set page(value) {
    this.setAttribute("page", value);
    this.pageInstance = value;
    this.frames = [...this.pageInstance.frames];
  }

  @api get titleClass() {
    return "title";
  }

  @api get isClosed() {
    return this.isClosedValue;
  }
  set isClosed(value) {
    this.disableInputs = value;
  }

  get hasSDocButtons() {
    let buttonGroup = {};
    buttonGroup.mainButtons = [];
    buttonGroup.menuButtons = [];

    if (
      this.pageInstance.sDocButtons !== undefined &&
      this.pageInstance.sDocButtons.length > 0
    ) {
      this.pageInstance.sDocButtons.forEach((button) => {
        if (button.isDefault) {
          buttonGroup.mainButtons.push(button);
        } else {
          buttonGroup.menuButtons.push(button);
        }
      });
    }

    this.sDocButtons = buttonGroup;

    return this.pageInstance.sDocButtons.length > 0 && this.isInternalUser
      ? true
      : false;
  }

  //handle message content for the lms
  @wire(MessageContext)
  messageContext;

  //standard lifecycle hooks used to sub/unsub to message channel
  connectedCallback() {
    if (!this.isInternalUser) {
      this.estOutputLayoutSize = 10;
    }
    this.subsToMessageChannel();

    const inputAligncenter = document.createElement("style");
    inputAligncenter.innerText = `.input-text-align_right input{ text-align: right!important; }`;
    document.body.appendChild(inputAligncenter);
  }

  //Encapsulate logic for LMS subscribe
  subsToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        openChatter,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE }
      );
    }
  }

  // Handler for message received by component
  handleMessage(message) {
    if (message.description == "refreshOutput") {
      var indexObj = this.indexObj;
      if (indexObj) {
        checkForFeedExist({
          recordId: indexObj.recordId,
          objectName: "Estimation_Output__c"
        })
          .then((result) => {
            var frames = JSON.parse(JSON.stringify(this.frames));
            var pageSection = frames[indexObj.frameindex].pageSections;
            var secItems = pageSection[indexObj.secindex].sectionItems;
            //if feed exist then we change the color of icon.
            if (result) {
              secItems[indexObj.secitemindex].schedule.output.chatterIconClass =
                "svgClass";
            } else {
              secItems[indexObj.secitemindex].schedule.output.chatterIconClass =
                "";
            }

            this.frames = frames;
          })
          .catch((error) => {});
      }
    }
  }

  /**************** Handle User Inputs *****************/

  /**
   * Handle User toggling Section checkbox. Updated for <T01> for performance gains and additional functionality
   * @param {event} event   onchange
   * @return void
   */
  handleToggleSection(event) {
    const pageId = this.page.Id;
    const frameIndex = event.target.dataset.frameIndex;
    const sectionIndex = event.target.dataset.sectionIndex;
    const isSectionChecked = event.target.checked;

    let copiedPage = JSON.parse(JSON.stringify(this.page));
    let toggledSection = {
      ...copiedPage.frames[frameIndex].pageSections[sectionIndex]
    };
    const preChecked = toggledSection.preChecked;
    const newlyCheckedOnceBefore = toggledSection.newlyCheckedOnceBefore;
    toggledSection.isChecked = isSectionChecked;

    // if the section loaded unchecked on page load and the user just checked that section:
    if (!preChecked && isSectionChecked && !newlyCheckedOnceBefore) {
      toggledSection.disableCheckbox = isSectionChecked;
      toggledSection.showSectionLoadingSpinner = isSectionChecked;

      this.updateParent(
        pageId,
        frameIndex,
        sectionIndex,
        toggledSection,
        true, // sectionToggled
        false, // performCalculation
        false // tableRelocked
      );

      handleInitialSectionToggle({
        estimationSummaryIdParam: this.estimationSummaryId,
        estimationSummaryParam: {
          ...copiedPage.frames[frameIndex].estimationSummaryRecord
        },
        sectionCheckedParam: isSectionChecked,
        pageRecordIdParam: pageId,
        frameRecordIdParam: toggledSection.parentId,
        pageSectionRecordParam: toggledSection.pageSectionRecord,
        preCheckedParam: toggledSection.preChecked,
        newlyCheckedOnceBeforeParam: toggledSection.newlyCheckedOnceBefore,
        pageNumberParam: toggledSection.pageNumber
      })
        .then((result) => {
          if (result) {
            const sectionWithQueriedData = JSON.parse(JSON.stringify(result));
            let copiedSection = {
              ...sectionWithQueriedData
            };
            copiedSection.index = sectionIndex;
            copiedSection.isChecked = isSectionChecked;
            copiedSection.showSection = true;
            copiedSection.showSectionLoadingSpinner = false;
            copiedSection.disableCheckbox = false;

            this.updateParent(
              this.page.Id,
              frameIndex,
              sectionIndex,
              copiedSection,
              true, // sectionToggled
              false, // performCalculation
              false // tableRelocked
            );
          }
        })
        .catch((error) => {
          console.log("Error toggling section: ", error?.body?.message);
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error toggling section",
              message: error?.body?.message,
              variant: "error"
            })
          );
        });
    } else {
      // if the section loaded checked on page load:
      updateSummaryLinesForToggledSection({
        estimationSummaryId: this.estimationSummaryId,
        sectionChecked: isSectionChecked,
        pageSectionRecordId: toggledSection.pageSectionRecord.Id,
        sectionTotal: toggledSection.sectionTotal
      })
        .then((result) => {
          // no need to do anything with the result for this use case
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error toggling section",
              message: error?.body?.message,
              variant: "error"
            })
          );
        });

      this.setProgressRingBasedOnSectionToggle(
        toggledSection,
        isSectionChecked
      );

      toggledSection.showSection = event.target.checked;
      toggledSection.showSectionLoadingSpinner = false;

      if (isSectionChecked) {
        toggledSection.disableCheckbox = false;
      }

      this.updateParent(
        this.page.Id,
        frameIndex,
        sectionIndex,
        toggledSection,
        true, // sectionToggled
        false, // performCalculation
        false // tableRelocked
      );
    }
  }

  /**
   * <T01>: set the section progress ring based on the section's toggled state
   * @param {pageSection} toggledSection    toggled section
   * @param {Boolean}     isSectionChecked  checked state of toggled section
   * @return void
   */
  setProgressRingBasedOnSectionToggle(toggledSection, isSectionChecked) {
    if (!(toggledSection.Id in this.progressRingAttrMap)) {
      this.progressRingAttrMap[toggledSection.Id] = {};
      this.progressRingAttrMap[toggledSection.Id].numerator =
        toggledSection.numerator;
      this.progressRingAttrMap[toggledSection.Id].denominator =
        toggledSection.denominator;
      this.progressRingAttrMap[toggledSection.Id].progress =
        toggledSection.progress;
    }
    if (!isSectionChecked) {
      toggledSection.numerator = 0;
      toggledSection.denominator = 0;
      toggledSection.progress = 0;
    } else {
      toggledSection.numerator =
        this.progressRingAttrMap[toggledSection.Id].numerator;
      toggledSection.denominator =
        this.progressRingAttrMap[toggledSection.Id].denominator;
      toggledSection.progress =
        this.progressRingAttrMap[toggledSection.Id].progress;
      delete this.progressRingAttrMap[toggledSection.Id];
    }
  }

  /**
   * Handle User opening Note Modal
   * @param {event} event  onclick
   * @return void
   */
  handleOpenNoteModal(event) {
    // Capture Current Place so values can be referenced when child component closes
    this.currentOutputId = event.target.dataset.output;
    this.currentFrameIndex = event.target.dataset.frameIndex;
    this.currentSectionIndex = event.target.dataset.sectionIndex;
    this.currentItemIndex = event.target.dataset.itemIndex;
    this.showNoteModal = true;
  }

  /**
   * Close Quote Modal Popup and refresh variables
   */
  handleCloseNoteModal() {
    this.showNoteModal = false;
  }

  /**
   * Close Quote Modal Popup and refresh variables
   * @param {event} event savemodel event
   * @return void
   */
  handleSaveNoteModal(event) {
    let copiedPage = JSON.parse(JSON.stringify(this.page));
    let updatedNotes = event.detail.notes.value; // Get Notes from Notes Modal
    let existingNotes =
      this.page.frames[this.currentFrameIndex].pageSections[
        this.currentSectionIndex
      ].sectionItems[this.currentItemIndex].schedule.output.notes; // Get existing Notes

    if (updatedNotes != existingNotes) {
      let hasNotes;

      if (this.isEmpty(updatedNotes)) {
        hasNotes = false;
      } else {
        hasNotes = true;
      }

      this.updateParentWithNotes(
        copiedPage.Id,
        this.currentFrameIndex,
        this.currentSectionIndex,
        this.currentItemIndex,
        hasNotes,
        updatedNotes
      );
    }

    this.handleCloseNoteModal();
  }

  /**
   * Handle User Input from Questions on Page
   * @param {event} event  commit event
   * @return void
   */
  handleInput(event) {
    this.getValuesAndUpdateParent(
      event.target.dataset.frameIndex,
      event.target.dataset.sectionIndex,
      event.target.dataset.itemIndex,
      [event.target.value],
      null, // rowIndex
      null, // cellIndexes
      true, // performCalculation
      false // tableRelocked
    );
  }

  /**
   * <T02> refactored method to support table locking functionality
   * @param {event} event   ontableinput
   * @return void
   */
  handleInputFromTable(event) {
    const frameIndex = event.detail.frameIndex;
    const sectionIndex = event.detail.sectionIndex;
    const itemIndex = event.detail.itemIndex;
    const tableLockedFlag = event.detail.tableLockedFlag;

    let copiedPage = JSON.parse(JSON.stringify(this.page));
    let copiedSection = {
      ...copiedPage.frames[frameIndex].pageSections[sectionIndex]
    };
    copiedSection.numerator = event.detail.numerator;
    copiedSection.denominator = event.detail.denominator;
    copiedSection.progress = event.detail.progress;
    copiedSection.tableLockedFlag = tableLockedFlag;
    copiedSection.sectionItems[itemIndex].table.header.cells[0].isChecked =
      tableLockedFlag;

    this.updateParent(
      copiedPage.Id,
      frameIndex,
      sectionIndex,
      copiedSection,
      false, // sectionToggled
      false, // performCalculation
      false // tableRelocked
    );
  }

  /**
   * Handle User Input from updates to Table Cells
   *  for <T02>, now this method will only fire when a user relocks a table after entering values
   *  this contains the logic handleInputFromTable used to have before <T02>
   * @param {event} event  onupdateparent
   * @return void
   */
  processInputsFromTable(event) {
    this.getValuesAndUpdateParent(
      event.detail.frameIndex,
      event.detail.sectionIndex,
      event.detail.itemIndex,
      event.detail.values, // <T02> changed to list type
      event.detail.rowIndexes, // <T02> changed to list type
      event.detail.cellIndexes, // <T02> changed to list type
      event.detail.performCalculation, // <T03>: added param
      true // <T03>: added param (tableRelocked)
    );
  }

  /**
   * Handle User adding a row to elastic table
   * @param {event} event   onaddrow
   * @return void
   */
  handleAddRowToTable(event) {
    this.updateParentWithRowChange(
      this.page.Id, // Page Id
      event.detail.frameIndex, // Frame Index
      event.detail.sectionIndex, // Page Section Index
      event.detail.itemIndex, // Section Item Index
      event.detail.tableId, // Table Id
      event.detail.action, // Action Type (i.e. Add Row)
      event.detail.numRows, // Number of Rows (do not count header)
      event.detail.numColumns, // Number of Columns
      null // Row Index
    );
  }

  /**
   * Handle User removing a row from elastic table
   * @param {event} event  onremoverow
   * @return void
   */
  handleRemoveRowFromTable(event) {
    this.updateParentWithRowChange(
      this.page.Id, // Page Id
      event.detail.frameIndex, // Frame Index
      event.detail.sectionIndex, // Page Section Index
      event.detail.itemIndex, // Section Item Index
      event.detail.tableId, // Table Id
      event.detail.action, // Action Type (i.e. Add Row)
      null, // Number of Rows (do not count header)
      null, // Number of Columns
      event.detail.rowIndex // Row Index
    );
  }

  /**
   * Handle User clicking sDoc Button
   * @param {event} event   onclick
   * @return void
   */
  handleSDocButtonClick(event) {
    let templateId = event.target.value;

    let link =
      "/apex/SDOC__SDCreate1?" +
      "id=" +
      this.estimationSummaryId +
      "&" +
      "docList=" +
      templateId +
      "&" +
      "object=Estimation_Summary__c" +
      "&" +
      "autodownload=True";

    window.open(link);
  }

  /**************** Helper Methods *****************/

  /**
   * get values entered by user and update parent with them
   * @param {integer} frameIndex
   * @param {integer} sectionIndex
   * @param {integer} itemIndex
   * @param {array} values
   * @param {array} rowIndexes
   * @param {array} cellIndexes
   * @param {Boolean} performCalculation
   * @return void
   */
  getValuesAndUpdateParent(
    frameIndex,
    sectionIndex,
    itemIndex,
    values, // <T02> changed to list type
    rowIndexes, // <T02> changed to list type
    cellIndexes, // <T02> changed to list type
    performCalculation, // <T03>: added param,
    tableRelocked // <T03>: new param
  ) {
    console.log("ipueEstimatorPage getValuesAndUpdateParent");
    let copiedPage = JSON.parse(JSON.stringify(this.page));
    let item =
      copiedPage.frames[frameIndex].pageSections[sectionIndex].sectionItems[
        itemIndex
      ];

    if (item.isSchedule || item.isTable) {
      let copiedSection = {
        ...copiedPage.frames[frameIndex].pageSections[sectionIndex]
      };

      if (item.isSchedule) {
        const value = values[0]; // <T02>: added
        this.updateSchedule(item, copiedSection, value);
      } else if (item.isTable) {
        this.updateTableCell(
          item,
          copiedSection,
          values,
          rowIndexes,
          cellIndexes
        );
      }

      copiedSection.sectionItems[itemIndex] = item;
      this.updateParent(
        copiedPage.Id,
        frameIndex,
        sectionIndex,
        copiedSection,
        false, // sectionToggled
        performCalculation, // <T03>: added param
        tableRelocked // <T03>: added param
      );
    }
  }

  /**
   * update section containing the schedule/question the user answered
   * @param {*} item
   * @param {*} copiedSection
   * @param {*} value
   * @return void
   */
  updateSchedule(item, copiedSection, value) {
    let oldValue = item.schedule.output.value;
    switch (item.schedule.type) {
      case "Number":
        item.schedule.output.value = value > 0 ? value : 0;
        break;
      case "Picklist":
        item.schedule.output.value = item.schedule.picklistValues.find(
          (option) => option.value === value
        ).label;
        item.schedule.output.picklistValue = value;
        break;
      default:
        item.schedule.output.value = value;
        break;
    }

    let scheduleCount = 0;
    let inputCount = 0;

    if (!item.schedule.isCalculated) {
      scheduleCount++;

      // If the field has a value populated, increate input count
      if (
        (item.schedule.type == "Number" && item.schedule.output.value >= 0) ||
        item.schedule.output.value
      ) {
        inputCount++;
      }
    }
    if (oldValue === undefined) {
      copiedSection.numerator += 1;
    }
    copiedSection.progress =
      inputCount > 0
        ? (copiedSection.numerator / copiedSection.denominator) * 100
        : 0;
    copiedSection.inputMissing = inputCount != scheduleCount ? true : false;
    copiedSection.showSectionSpinner = !copiedSection.inputMissing
      ? true
      : false;
  }

  /**
   * method to update table cells for fixed/elastic tables
   *   <T02>: method refactored to support table locking functionality
   * @param {*} item            section item
   * @param {*} copiedSection   page section to update parent with
   * @param {*} values          values to update page section with
   * @param {*} rowIndexes      table row indexes containing values to update
   * @param {*} cellIndexes     table cell indexes for inputs containing values the user entered
   * @return void
   */
  updateTableCell(item, copiedSection, values, rowIndexes, cellIndexes) {
    // <TO2>: loop through= row indexes and cell indexes to accommodate if user changed more than 1 table cell value before calculating
    for (let i = 0; i < rowIndexes.length; i++) {
      const rowIndex = rowIndexes[i];
      // wrapped logic in loop for <T02>
      for (let j = 0; j < cellIndexes.length; j++) {
        const value = values[j];
        const cellIndex = cellIndexes[j];
        let tempCell = item.table.rows[rowIndex].cells[cellIndex];

        switch (tempCell.datatype) {
          case "Number":
            tempCell.output.value = value > 0 ? value : 0;
            break;
          case "Picklist":
            tempCell.output.value = tempCell.picklistValues.find(
              (option) => option.value === value
            ).label;
            tempCell.output.picklistValue = value;
            break;
          default:
            tempCell.output.value = value;
            break;
        }

        item.table.rows[rowIndex].cells[cellIndex] = tempCell;
      }
    }

    let tableLockCell = item.table.header.cells[0];
    tableLockCell.isChecked = true;
    tableLockCell.value = true;

    copiedSection.inputMissing = false;
    copiedSection.showSectionSpinner = true;
  }

  isEmpty(str) {
    return !str || str.length === 0;
  }

  /**************** Dispatch Events (Send to Parent) *****************/

  /**
   * method to update parent (ipueEstimatorHost) using user-entered values
   * @param {*} pageId              id of page that the section to update belongs to
   * @param {*} frameIndex          index of frame the section to update belongs to
   * @param {*} sectionIndex        index of section to update
   * @param {*} copiedSection       section containing new values entered by user, update parent with this
   * @param {*} performCalculation  whether to perform calculation or not
   * @return void
   */
  updateParent(
    pageId,
    frameIndex,
    sectionIndex,
    copiedSection,
    sectionToggled,
    performCalculation, // <T03>: added param
    tableRelocked // <T03>: added param
  ) {
    // Update Parent with new values
    const updateEvent = new CustomEvent("update", {
      detail: {
        pageId: pageId,
        frameIndex: frameIndex,
        sectionIndex: sectionIndex,
        section: copiedSection,
        sectionToggled: sectionToggled,
        performCalculation: performCalculation, // <T03>: added property
        tableRelocked: tableRelocked // <T04>: added property
      }
    });

    this.dispatchEvent(updateEvent);
  }

  /**
   * update parent with notes entered by user
   * @param {*} pageId
   * @param {*} frameIndex
   * @param {*} sectionIndex
   * @param {*} itemIndex
   * @param {*} hasNotes
   * @param {*} notes
   * @return void
   */
  updateParentWithNotes(
    pageId,
    frameIndex,
    sectionIndex,
    itemIndex,
    hasNotes,
    notes
  ) {
    // Update Parent with new values
    const updateEvent = new CustomEvent("updatenotes", {
      detail: {
        pageId: pageId,
        frameIndex: frameIndex,
        sectionIndex: sectionIndex,
        itemIndex: itemIndex,
        hasNotes: hasNotes,
        notes: notes
      }
    });

    this.dispatchEvent(updateEvent);
  }

  /**
   * update parent with row change
   * @param {*} pageId
   * @param {*} frameIndex
   * @param {*} sectionIndex
   * @param {*} itemIndex
   * @param {*} tableId
   * @param {*} action
   * @param {*} numRows
   * @param {*} numColumns
   * @param {*} rowIndex
   * @return void
   */
  updateParentWithRowChange(
    pageId,
    frameIndex,
    sectionIndex,
    itemIndex,
    tableId,
    action,
    numRows,
    numColumns,
    rowIndex
  ) {
    // Update Parent with new values
    const updateEvent = new CustomEvent("updaterow", {
      detail: {
        pageId: pageId,
        frameIndex: frameIndex,
        sectionIndex: sectionIndex,
        itemIndex: itemIndex,
        tableId: tableId,
        action: action,
        numRows: numRows,
        numColumns: numColumns,
        rowIndex: rowIndex
      }
    });

    this.dispatchEvent(updateEvent);
  }

  /**
   * handle chatter click
   * @param {event} event  onclick
   * @return void
   */
  handleChatterClick(event) {
    var recordId = event.target.dataset.id;
    var indexObj = {};
    indexObj.recordId = recordId;
    indexObj.frameindex = parseInt(event.target.dataset.frameindex);
    indexObj.secindex = parseInt(event.target.dataset.secindex);
    indexObj.secitemindex = parseInt(event.target.dataset.secitemindex);
    this.indexObj = indexObj;
    //sending message to open chatter via message channel
    const payload = {
      recordId: recordId,
      publisherContext: "RECORD",
      feedType: "Record",
      description: "OpenChatter",
      isFeedEnabled: true,
      calledFrom: "Output"
    };
    publish(this.messageContext, openChatter, payload);
  }

  /**
   * <T02>: handle when user locks a table
   * @param {event} event   ontablelocktoggle
   * @return void
   */
  handleTableLockToggle(event) {
    const parentPageSectionId = event.detail.parentPageSectionId;
    const progressRingElement = this.template.querySelector(
      // TODO: move to method
      '[data-progress-ring-id="' + parentPageSectionId + '"]'
    );
    if (!event.detail.locked) {
      if (progressRingElement) {
        this.template.querySelector(
          '[data-progress-ring-id="' + parentPageSectionId + '"]'
        ).className = "progress-ring-z-index";
      }
    } else {
      if (progressRingElement) {
        this.template.querySelector(
          '[data-progress-ring-id="' + parentPageSectionId + '"]'
        ).className = "";
      }
    }

    // apply or remove overlay:
    const tableLockToggleEvent = new CustomEvent("tablelocktogglehost", {
      detail: {
        applyOverlay: event.detail.applyOverlay,
        performCalculation: event.detail.performCalculation,
        parentPageSectionId: event.detail.parentPageSectionId,
        tableIsLockedFlag: event.detail.islocked
      }
    });

    this.dispatchEvent(tableLockToggleEvent);
    console.log("emitted tablelocktogglehost event");
  }

  /**
   * <T02> reset properties on child tables when calculation completed
   * @param null
   * @return void
   */
  @api
  resetPropertiesOnTable() {
    console.log("ipue-table resetPropertiesOnTable");

    const childTableComps = this.template.querySelectorAll("c-ipue-table");

    for (let i = 0; i < childTableComps.length; i++) {
      childTableComps[i].resetPropertiesOnTable();
    }
  }
}