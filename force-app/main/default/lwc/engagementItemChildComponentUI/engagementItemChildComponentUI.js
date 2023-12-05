import { LightningElement,api,track,wire } from 'lwc';
import getMilestones from '@salesforce/apex/EngagementCatalogueController.getMilestones';
import deleteFile from '@salesforce/apex/EngagementCatalogueController.deleteFile';


export default class EngagementItemChildComponentUI extends LightningElement {
    isLoading = false;
    //properties related to questions which needs to be displayed in the form
    questionType = '';
    questionLabel = '';
    questionPlaceHolder = '';
    questionToolTip = '';
    questionName = '';
    questionSortOrder = '';
    questionIsRequired;
    fieldApiName='';

    //properties related to Text Area
    boolIsTextArea = false;
    textAreaValue = '';

    //properties related to Combo Box
    boolIsPicklist = false;
    comboBoxValue = '';
    @track 
    comboBoxOpts = [];

    //properties related to Radio button
    boolIsRadioButton = false;
    radioButtonValue = '';
    @track
    radioButtonOptions = [];

    //properties related to input Text
    boolIsText = false;
    textValue = '';

    //properties related to checkbox
    boolIsCheckBox = false;
    checkBoxValue = '';
    @track
    checkBoxOptions = [];

    //properties related to datetime
    boolIsDateTime = false;
    dateTimeValue;

    //properties related to date
    boolIsDate = false;
    dateValue = '';

    //properties related to output text
    boolIsOutputText = false;
    outputTextValue = '';

    //properties related to file upload
    boolIsFileUpload = false;
    @api
    myRecordId;
    uploadedDocIds = [];
    @track uploadedFiles = [];

    //properties related to contactId/planId from parent for milestone
    @api 
    sobjectFromParent;
    @api
    contactIdFromParent;
    @api
    planIdFromParent;
    @api
    mileStoneFromParent;

    //properties related to Combo Box
    boolIsCustomPicklist = false;
    customComboBoxValue = '';
    @track 
    customComboBoxOptions = [];


    //method related to Text Area
    //this is called when the text area value is changed
    handleTextAreaChange(event){
        this.textAreaValue = event.detail.value;
    }

    //methods related to Combo Box
    //this will set the combo box values dynamically which are set from the set question method
    get comboBoxOptions() {
        return this.comboBoxOpts;
    }

    //this is called from combo box value is changed
    handleComboBoxChange(event) {
        this.comboBoxValue = event.detail.value;
    }

    //methods related to Radio button
    //this will set the radio button values dynamically which are set from the set question method
    get radioButtonOptions() {
        return this.radioButtonOptions;
    }

    //this is called when Radio button value is changed
    handleRadioButtonChange(event){
        this.radioButtonValue = event.detail.value;
    }

    //method related to input Text
    //this is called when the input text value is changed
    handleTextChange(event){
        this.textValue = event.detail.value;
    }

    //methods related to checkbox
    //this will set the checkbox values dynamically which are set from the set question method
    get checkBoxOptions() {
        return this.checkBoxOptions;
    }

    checkBoxValue = '';
    //this is called when check box value is changed
    handleCheckBoxChange(event){
        this.checkBoxValue = event.detail.value;
    }

    //method related to datetime
    //this is called when the datetime value is changed
    handleDateTimeChange(event){
        this.dateTimeValue = event.detail.value;
    }

    //method related to date
    //this is called when the date value is changed
    handleDateChange(event){
        this.dateValue = event.detail.value;
    }

    //method related to file upload
    //this is called when the file is uploaded
    handleUploadFinished(event){
        // Get the list of uploaded files
        //const uploadedFiles = event.detail.files;
        this.uploadedDocIds = [];
        if(this.uploadedFiles.length > 0){
            for(var i=0;i<event.detail.files.length;i++){
                this.uploadedFiles.push(event.detail.files[i]); 
            }
        }else{
            this.uploadedFiles = event.detail.files;
        }
        this.uploadedFiles.forEach(uploadFile =>{
            this.uploadedDocIds.push(uploadFile.documentId);
        });
        this.dispatchEvent(new CustomEvent('uploadfiledocs', {
            detail: {
                message: this.uploadedDocIds
            }
        }));
    }

    /*
	 Method Name : handleFileRemove
	 Description : This method will delete the file which has been clicked on remove
	 Parameters	 : event
	 Return Type : None
	*/
    handleFileRemove(event) {
        let allFilesBeforeDelete = [...this.uploadedFiles];
        let deleteDocumentId = event.target.name;
        this.uploadedFiles = this.uploadedFiles.filter(item => item.name !== deleteDocumentId);
        let difference = allFilesBeforeDelete.filter(x => !this.uploadedFiles.includes(x));
        this.isLoading = true;
        deleteFile({'fileIdToDelete': difference[0].documentId})
            .then(() => {
                console.log('file has been successfully deleted');
            }).catch((error) => {
                console.log('file cannot be deleted ' , error);
            }).finally(() => {
                this.isLoading = false;
            });
        this.uploadedDocIds = [];
        this.uploadedFiles.forEach(uploadFile =>{
            this.uploadedDocIds.push(uploadFile.documentId);
        });
        this.dispatchEvent(new CustomEvent('uploadfiledocs', {
            detail: {
                message: this.uploadedDocIds
            }
        }));
    }


    /*
	 Method Name : acceptedFormats
	 Description : This method will get the accepted file formats
	 Parameters	 : None
	 Return Type : String
	*/
    get acceptedFormats() {
        /*let acceptedFileFormats = [];
        getAcceptedFileFormats({})
            .then(result => {
                acceptedFileFormats = result;
            });
        return acceptedFileFormats;*/
        return ['.pdf', '.jpg', '.png','.xlsx','.xls','.csv','.doc','.docx','.txt','.jpeg']; //csmPlanCommunicationEditForm
    }

    //methods related to Combo Box
    //this will set the combo box values dynamically which are set from the set question method
    get customComboBoxOptions() {
        return this.customComboBoxOptions;
    }

    //this is called from combo box value is changed
    handleCustomComboBoxChange(event) {
        this.customComboBoxValue = event.detail.value;
    }

    
    @api 
    get question(){
        return "";
    }
    
    // this is called from parent component which sets each question by calling a loop
    set question(val){
        this.questionType = val.Type;
        this.questionLabel = val.Label;
        this.questionPlaceHolder = val.Placeholder;
        this.questionToolTip = val.Tooltip;
        this.questionName = val.Name;
        this.questionSortOrder = val.Sort_Order;
        this.questionIsRequired = val.Is_Required;
        this.fieldApiName = val.FieldApiName;
        this.selectQuestionTypeAndOptions(val.Type_Option);
    }

    // this method sets the boolean value so that only one question will be shown at a time
    selectQuestionTypeAndOptions(Type_Option){
        let lstOption = [];
        let allQuestionOptions = '';
        switch  (this.questionType){
            case 'TextArea':
                this.boolIsTextArea = true;
                break;
            case 'Picklist':
                this.boolIsPicklist = true;
                lstOption = [];
                allQuestionOptions = Type_Option.split(";");
                allQuestionOptions.forEach(eachQuestionOption =>{
                    lstOption.push({value: eachQuestionOption,label: eachQuestionOption});
                });
                this.comboBoxOpts = lstOption;
                allQuestionOptions = '';//reset to blank
                break;
            case 'Radio':
                this.boolIsRadioButton = true;                
                lstOption = [];
                allQuestionOptions = Type_Option.split(";");
                allQuestionOptions.forEach(eachQuestionOption =>{
                    lstOption.push({value: eachQuestionOption,label: eachQuestionOption});
                });
                this.radioButtonOptions = lstOption;
                break;
            case 'Text':
                this.boolIsText = true;
                break;
            case 'Checkbox':
                this.boolIsCheckBox = true;                
                lstOption = [];
                allQuestionOptions = Type_Option.split(";");
                allQuestionOptions.forEach(eachQuestionOption =>{
                    lstOption.push({value: eachQuestionOption,label: eachQuestionOption});
                });
                this.checkBoxOptions = lstOption;
                break;
            case 'Datetime':
                this.boolIsDateTime = true;
                break;
            case 'Date':
                this.boolIsDate = true;
                break;
            case 'Text-Readonly':
                this.boolIsOutputText = true;
                this.outputTextValue = Type_Option;
                break;
            case 'File':
                this.boolIsFileUpload = true;
                break;
            case 'Custom'://notification subscritpion refer this module for dynamic
                if(this.sobjectFromParent == 'Engagement'){
                    this.populateCustomPicklist();
                }
                break;
            default:
                console.log('default case');    
        }
    }

    //this method will set the combo box values
    populateCustomPicklist(){
        this.isLoading = true;
        this.boolIsCustomPicklist = true;
        getMilestones({contactId: this.contactIdFromParent, planId:this.planIdFromParent})
            .then(result => {
                if(result){
                    let lstOption = [];
                    let allQuestionOptions = '';
                    allQuestionOptions = result;
                    lstOption.push({value: '',label: '--None--'});//since milestone selection is not mandaory, we are giving None option
                    if(this.planIdFromParent){
                        allQuestionOptions.forEach(eachQuestionOption =>{
                            lstOption.push({value: eachQuestionOption.Id,label:eachQuestionOption.Name});
                        });
                    }else{
                        allQuestionOptions.forEach(eachQuestionOption =>{
                            lstOption.push({value: eachQuestionOption.Id,label: eachQuestionOption.Objective__r.Plan__r.Name + ' - ' + eachQuestionOption.Name});
                        });
                    }
                    
                    this.customComboBoxOptions = lstOption;
                    if(this.mileStoneFromParent){
                        this.customComboBoxValue = this.mileStoneFromParent;
                    }
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('result getMilestones error ' , error);
            });
    }


    // this method is called from parent in order to get the value of each answer selected
    @api
    getAnswer(){
        var ans = {"Name":"","Answer":"","Type":""};
        switch  (this.questionType){
            case 'TextArea':
                ans.Name = this.fieldApiName;
                ans.Answer = this.textAreaValue;
                ans.Type = this.questionType;
                break;
            case 'Picklist':
                ans.Name = this.fieldApiName;
                ans.Answer = this.comboBoxValue;
                ans.Type = this.questionType;
                break;
            case 'Radio':
                ans.Name = this.fieldApiName;
                ans.Answer = this.radioButtonValue;
                ans.Type = this.questionType;
                break;
            case 'Text':
                ans.Name = this.fieldApiName;
                ans.Answer = this.textValue;
                ans.Type = this.questionType;
                break;
            case 'Checkbox':
                ans.Name = this.fieldApiName;
                if(this.checkBoxValue !=''){
                    ans.Answer = this.checkBoxValue.join(',');
                }
                ans.Type = this.questionType;
                break;
            case 'Datetime':
                ans.Name = this.fieldApiName;
                ans.Answer = this.dateTimeValue;
                ans.Type = this.questionType;
                break;
            case 'Date':
                ans.Name = this.fieldApiName;
                ans.Answer = this.dateValue;
                ans.Type = this.questionType;
                break;
            case 'Text-Readonly':
                ans.Name = this.questionType;
                ans.Type = this.questionType;
                break;
            case 'Custom':
                ans.Name = this.fieldApiName;
                ans.Answer = this.customComboBoxValue;
                ans.Type = this.questionType;
                break;
            case 'File':
                ans.Name = this.questionType;
                ans.Type = this.questionType;
                break;
            default:
                console.log('default case');
        }
        return ans;
    }

    //this method is called from the parent to validate all the input fields which are mandatory
    @api
    validateInputFields(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

}