/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/* eslint-disable no-console */
/* eslint no-unused-vars: ["error", { "argsIgnorePattern": "^_" }] */

import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

import { readAsBinaryString, readAsDataURL, trimProperties } from './readFile';

import SHEETJS_ZIP from '@salesforce/resourceUrl/sheetjs';
import processFile from '@salesforce/apex/IPUE_FileUploadController.processFile';
import fetchData from '@salesforce/apex/IPUE_FileUploadController.fetchData';
import handleErrors from '@salesforce/apex/IPUE_FileUploadController.handleErrors';

import successToastTitle from '@salesforce/label/c.IPUE_SuccessToastTitle';
import successToastMessage from '@salesforce/label/c.IPUE_SuccessToastMessage';
import readingFile from '@salesforce/label/c.IPUE_ReadingFile';
import modalHeader from '@salesforce/label/c.IPUE_ModalHeader';

// Ask what an appropriate max would be
const MAX_FILE_SIZE = 4500000;

export default class IpueFileUpload extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    /** STATE MANAGEMENT & DISPLAY SPINNERS */
    ready = false;
    error = false;
    errorMessage = '';
    uploading = false;
    uploadStep = 0;
    uploadMessage = '';
    uploadDone = false;
    uploadError = false;
    saveLabel = "Save";

    /** CLASS VARIABLES */
    base64Data;
    uploadedFile;
    uploadedFileName;
    hasFile;

    labels = {
        successToastTitle,
        successToastMessage,
        readingFile,
        modalHeader
    }

    get loading() { return !this.ready && !this.error; }
    get disableSave() { return (this.uploading || !this.hasFile) && !this.uploadDone; }
    get disableClose() { return this.uploading && !this.uploadError; }
    get canUpload() { return this.ready && !this.error; }

    // Fields relating to the parsing metadata
    sObjectBySheetMap = {};
    fieldMappingMap = {};
    parentObjectAPI;
    childRelationshipAPI;

    get showUploadProgress() { return this.uploading || this.uploadDone; }

    @wire(fetchData, { recordId: '$recordId' })
    returnedResults(result) {
        if (result.data) {
            // Store the api names in appropriate variables
            this.parentObjectAPI = result.data.parentObjectAPI;
            this.childRelationshipAPI = result.data.childRelationshipAPI;
            this.fieldMappingMap = result.data.fieldMappingMap;
            this.sObjectBySheetMap = result.data.sObjectBySheetMap;
        } else if (result.error) {
            console.error('error fetching metadata', result.error);
            let message = 'Error fetching IPU Estimator metadata. Please notify your System Admin: ' + result.error;

            if (result.error.body !== undefined) {
                message = result.error.body.message;
            } else {
                message = result.error.message;
            }

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
        }
    }

    // @wire(fetchExistingEstimation, { recordId: '$recordId' })
    existingSummaryId;

    processStartTime;

    constructor() {

        super();

        let self = this;

        loadScript(this, SHEETJS_ZIP + '/xlsx.full.min.js')
            .then(function () {
                if (!window.XLSX) {
                    throw new Error('Error loading SheetJS library (XLSX undefined)');
                }
                self.ready = true;
            })
            .catch(function (error) {
                console.error('error loading sheetsjs', error);
                self.error = error;
                self.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Estimator Upload: Error loading SheetJS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

    }

    updateFile(event) {
        this.uploadedFile = event.target.files[0];
        this.uploadedFileName = event.target.files[0].name;
        this.hasFile = true;
    }

    onSaveClick() {
        if (this.uploadDone) {
            // Navigate to the record
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.existingSummaryId,
                    objectApiName: 'Estimation_Summary__c',
                    actionName: 'view'
                }
            })
        } else {
            this.uploadFile();
        }
    }


    uploadFile() {

        this.processStartTime = Date.now();

        this.uploading = true;
        this.uploadStep = "1";
        this.uploadMessage = readingFile;
        this.uploadDone = false;
        this.uploadError = false;

        // let file = event.target.files[0];
        // let file = this.uploadedFile;

        if (this.uploadedFile.size > MAX_FILE_SIZE) {
            let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + this.uploadedFile.size;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            return;
        }

        let self = this;

        /** 1. Read the File **/
        readAsDataURL(this.uploadedFile).then(function (result) {
            let fileContents = result;
            let base64Mark = 'base64,';
            let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.base64Data = encodeURIComponent(fileContents);
            return readAsBinaryString(self.uploadedFile);
        }).then(function (blob) {
            self.uploadStep = "2";
            self.uploadMessage = 'Extracting Data';
            // Use small timout to update UI
            return new Promise(function (resolve) {
                window.setTimeout(function () {
                    resolve(blob);
                }, 1)
            });
        }).then(function (blob) {
            /** 2. Parse the File **/
            let workbook = window.XLSX.read(blob, { type: 'binary' });

            // Basic error handling
            if (!workbook || !workbook.Workbook) { throw new Error("Cannot read Excel File (incorrect file format?)"); }
            if (workbook.SheetNames.length < 1) { throw new Error("Excel file does not contain any sheets"); }

            // Initialize collections
            const missingSheets = [];
            const formatErrors = [];
            const sheetsToParse = {}; // Variable to hold sheets to parse

            // Find the sheets we need to parse in the workbook
            for (const sheetName in self.fieldMappingMap) {
                if (!workbook.Sheets[sheetName]) {
                    missingSheets.push(sheetName);
                } else {
                    let returnedSheetJSON = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);
                    if (!Object.keys(returnedSheetJSON).length) {
                        formatErrors.push(sheetName);
                    } else {
                        sheetsToParse[sheetName] = trimProperties(returnedSheetJSON);
                    }
                }
            }

            //if (missingSheets.length > 0) { throw new Error('The following sheet(s) cannot be found in the Excel file: ' + missingSheets.join(', ')); }
            if (missingSheets.length > 0) { throw new Error('This is not the most current IPU Calculator. Please ensure latest calculator with summary sheet and summary lines is loaded into SFDC.'); }
            if (formatErrors.length > 0) { throw new Error('The following sheet(s) are improperly formatted: ' + formatErrors.join(', ')); }

            // Initialize the data to pass to apex
            let parentRecord = {
                // Id: self.existingSummaryId
            };
            let childRecordList = [];

            // Loop through each sheet in the file that needs to be parse
            for (const sheet in sheetsToParse) {
                // Use the sheet name to find the matching sObject API name
                let sObjectName = self.sObjectBySheetMap[sheet];
                let isParentRow = (sObjectName === self.parentObjectAPI);
                let rowsToParse = sheetsToParse[sheet];

                // Iterate over the rows in the sheet
                if (rowsToParse && Array.isArray(rowsToParse) && rowsToParse.length) {
                    for (const row of rowsToParse) {
                        // let fieldsToParse = rowsToParse[row];
                        let childRow = isParentRow ? null : {};

                        // For each field, map it to the corresponding API name
                        let hasAnyField = false;
                        for (const field in row) {
                            if (self.fieldMappingMap[sheet][field] !== undefined) {
                                hasAnyField = true;
                                let fieldApiName = self.fieldMappingMap[sheet][field];
                                let fieldValue = row[field];

                                // Update the appropriate record
                                if (isParentRow) {
                                    parentRecord[fieldApiName] = fieldValue;
                                } else {
                                    childRow[fieldApiName] = fieldValue;
                                }
                            }
                        }
                        // Check if the sheet matches the configured columns at all
                        if (!hasAnyField) {
                            throw new Error('Sheet ' + (sheet) + ' is improperly formatted');
                        }

                        // If it's a child object, push it onto the list
                        if (!isParentRow) {
                            childRecordList.push(childRow);
                        }
                    }
                } else {
                    throw new Error('Sheet ' + (sheet) + ' has no rows');
                }

            }

            let params = {
                recordId: self.recordId,
                parentRecord: parentRecord,
                childRecordList: childRecordList,
                base64Data: self.base64Data,
                fileName: self.uploadedFileName
            };
            return Promise.resolve(params);

        }).then(function (params) {
            /** 3. Call the apex controller method */
            self.uploadStep = "3";
            self.uploadMessage = 'Uploading File';
            return processFile(params);
        }).then(function (result) {
            /** 3.5. Update the UI with the new record */
            self.existingSummaryId = result;

            // Unfortunately, the last step won't get a check mark --
            // the base component <lightning-progress-indicator> is missing this functionality
            self.uploadMessage = successToastMessage;
            self.uploadDone = true;
            self.saveLabel = 'Validate';

            self.dispatchEvent(
                new ShowToastEvent({
                    title: successToastTitle,
                    message: successToastMessage,
                    variant: 'success'
                })
            );

            self.uploading = false;
        }).catch(function (err) {
            self.uploadError = true;
            if (err.message) {
                self.uploadMessage = "Error: " + err.message;
            } else if (err.body) {
                self.uploadMessage = "Error: " + err.body.message;
            }
            // Call apex to create persistent error log
            return handleErrors({
                errorCause: 'ipueFileUpload',
                messageAndStackTrace: err.body ? err.body.message + '\n' + err.body.stackTrace : err.message
            });
        }).then(function(res) {
            // console.log('successfully created error logs: ', res);
        }).catch(function(err) {
            console.error(err);
        });
    }

    closeModal() {
        this.uploading = false;
        this.uploadStep = 0;
        this.uploadMessage = '';
        this.uploadDone = false;
        this.uploadError = false;
        this.saveLabel = 'Save';
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}