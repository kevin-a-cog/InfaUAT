import { LightningElement, api, track } from 'lwc';
import getDirectPublishedArticles from '@salesforce/apex/KBArticleHandler.getDirectPublishedArticles';
import KB_Language from '@salesforce/label/c.KB_Language'; 

export default class KbArticleDirectPublishedListView extends LightningElement {

    @track sortBy;
    @track sortDirection;
    @track AllLanguages = KB_Language.toString().split(';')

    totalitems;
    
    rowData;
    columns;
    fieldNames =
        "Title,ArticleNumber,Primary_Product__c,ValidationStatus,PublishStatus,Article_Type__c,Created_by_Formula__c,CreatedDate,LastPublishedDate,Contributed_KB__c,AQI_Score__c,Language";
    fieldNamesFirst =
            "Title,ArticleNumber,Primary_Product__c,ValidationStatus";
    fieldNamesSecond =
            "Article_Type__c,Created_by_Formula__c,CreatedDate,LastPublishedDate,Contributed_KB__c,AQI_Score__c,Language";
 
    contextObjectType = 'Knowledge__kav';
    spinnerload = false;
    settings = {
        defaultDateAttributes: { weekday: "long", year: "numeric", month: "long", day: "2-digit" },
        defaultDateTimeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit" },
        fieldNameRecordURL: '__RecordURL',
        fieldNameLanguage: '__Language_Name',
        fieldNameCustomPublicationStatus : '__PublicationStatus'
    };

    TitleColumnDescriptors = [
        {
            label: "Article Title",
            fieldName: this.settings.fieldNameRecordURL,
            type: "url",
            sortable: true,
            typeAttributes: { label: { fieldName: "Title" }, target: "_self" }
        }
    ];

    LanguageColumnDescriptors = [
        {
            label: "Language",
            fieldName: this.settings.fieldNameLanguage,
            type: "string",
            sortable: true
        }
    ];

    PublishStatusColumnDescriptors = [
        {
            label: "Publication Status",
            fieldName: this.settings.fieldNameCustomPublicationStatus,
            type: "string",
            sortable: true
        }
    ];


    
    fieldDescribes = {
        "Knowledge__kav": [
            {
                "label": "Article Number",
                "name": "ArticleNumber",
                "type": "string"
            },
            {
                "label": "Primary Product",
                "name": "Primary_Product__c",
                "type": "string"
            },
            {
                "label": "Validation Status",
                "name": "ValidationStatus",
                "type": "string"
            },            
            {
                "label": "Article Type",
                "name": "Article_Type__c",
                "type": "string"
            },
            {
                "label": "Contributed By",
                "name": "Created_by_Formula__c",
                "type": "string"
            },
            {
                "label": "Created Date",
                "name": "CreatedDate",
                "type": "datetime"
            },
            {
                "label": "Published Date",
                "name": "LastPublishedDate",
                "type": "datetime"
            },
            {
                "label": "Contributed KB",
                "name": "Contributed_KB__c",
                "type": "boolean"
            },
            {
                "label": "AQI Score",
                "name": "AQI_Score__c",
                "type": "string"
            }
        ]
    }
   
    connectedCallback() {
        this.getKBData();
    }
    
    createColumns() {
        this.columns = [
            ...this.TitleColumnDescriptors,
            ...this.getCustomFieldColumns(this.fieldNamesFirst),
            ...this.PublishStatusColumnDescriptors,
            ...this.getCustomFieldColumns(this.fieldNamesSecond),
            ...this.LanguageColumnDescriptors,
        ];
        
        for (var i = 0; i < this.columns.length; i++) {
            console.log('each col' + this.columns[i].fieldName);
        }
    }
    
    getCustomFieldColumns(fieldNames) {
        let resultFields = [];
        if (fieldNames) {
            fieldNames.replace(/\s+/g, '').split(',').forEach(curFieldName => {
                console.log('current field' + curFieldName);
                let fieldDescribe = this.getFieldDescribe(this.contextObjectType, curFieldName);
                console.log('fieldlabel' + fieldDescribe);
                if (fieldDescribe) {
                    resultFields.push({
                        ...{
                            label: fieldDescribe.label,
                            fieldName: curFieldName,
                            sortable: true
                        }, ...this.getDefaultTypeAttributes(fieldDescribe.type)
                    }
                    );
                }
            });
        }
        return resultFields;
    }
    
    getDefaultTypeAttributes(type) {
        if (type.includes('date')) {
            return {
                type: "date",
                typeAttributes: this.settings.defaultDateTimeAttributes
            };
        }
        else if (type.includes('boolean')) {
            return {
                type: "boolean"
            };
        } else {
            return { type: 'text' };
        }
    }
    
    getFieldDescribe(objectName, fieldName) {
        console.log('objectname' + objectName);
        console.log('obj name' + this.fieldDescribes[objectName]);
        if (this.fieldDescribes && this.fieldDescribes[objectName]) {
            let fieldDescribe = this.fieldDescribes[objectName].find(curFieldDescribe => curFieldDescribe.name.toLowerCase() === fieldName.toLowerCase());
            console.log('field value' + fieldDescribe);
            return fieldDescribe;
        }
    }

    getRecordURL(sObject) {
        return '/lightning/r/' + this.contextObjectType + '/' + sObject.Id + '/view';
    }

    getPublicationStatus(sObject) {
        var strResult = 'Published';
        if (sObject.PublishStatus == 'Online') {
            strResult = 'Published';
        }
        else if (sObject.PublishStatus == 'Draft') {
            strResult = 'Draft';
        }
        else if (sObject.PublishStatus == 'Archived') {
            strResult = 'Archived';
        }
        return strResult;
    }

    getKBData() {
        getDirectPublishedArticles().then(result => {
            let kbData = result;
            this.createColumns();
            console.log('result' + this.columns);
            this.rowData = this.generateRowData(kbData);
            this.totalitems = this.rowData.length;
        }).catch(error => {
            console.log('error is: ' + JSON.stringify(error));
        });
    }

    generateRowData(rowData) {
        return rowData.map(curRow => {
            console.log('row data - ' + JSON.stringify(curRow));
            let resultData = {
                ...curRow
            };
            resultData[this.settings.fieldNameRecordURL] = this.getRecordURL(curRow);
            resultData[this.settings.fieldNameCustomPublicationStatus] = this.getPublicationStatus(curRow);
            resultData[this.settings.fieldNameLanguage] = this.getKBLanguageFieldValue(curRow);
            return resultData;
        });
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.rowData));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.rowData = parseData;

    }
  
    getKBLanguageFieldValue(sObject) {
        var varLanguage = sObject.Language;
        try {
            var varFieldValue = sObject.Language.trim();
            if (varFieldValue == '') {
                varLanguage = '';
            }
            else {
                varFieldValue = varFieldValue.toLowerCase();
                var len = this.AllLanguages.length;
                while (len--) {
                    if (len != 0) {
                        var varLangDetails = this.AllLanguages[len - 1].split('$$');
                        if (varLangDetails.length > 0) {
                            if (varLangDetails[1].toLowerCase() == varFieldValue) {
                                varLanguage = varLangDetails[0];
                            }
                        }
                    }
                }
            }
    
        } catch (error) {
            log('case getKBLanguageFieldValue error --> ' + JSON.stringify(error));
        }
        return varLanguage;
    }
}