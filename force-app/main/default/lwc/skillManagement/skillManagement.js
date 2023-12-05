/* eslint-disable no-console */
import {LightningElement, api, track} from 'lwc';
import getskills from '@salesforce/apex/KBLWCHandler.getskills';
import USER_ID from '@salesforce/user/Id'; //venky 

export default class SkillManagement extends LightningElement {

    @api actorId;
    //@api contextObjectType; //venky
    //@api fieldNames; //venky //field names provided by called to be rendered as columns
    @api disableReassignment;
    totalitems;
    
    rowData;       
    
    fieldNameSubmitterURL;
    fieldNameSubmitter;
    

    /*columns = [
        {
            label: "Skill Name",
            fieldName: this.fieldNameSubmitterURL,
            type: "url",
            sortable: true,
            typeAttributes: {label: {fieldName: this.fieldNameSubmitter}, target: "_self"}
        }
        
    ];*/
    columns = [
        {
            label: 'Skill name',
            fieldName: 'urlvalue',
            type: 'url',
            sortable: true,
            typeAttributes: {label: {fieldName: 'Name'}, target: "_blank"}
        }        
    ];

    
    
    errorApex;
    errorJavascript;
    selectedRows;
    apCount;
    commentVal = '';
    reassignActorId;

    connectedCallback() {
        console.log('connectedcallback');
        var titleelement = document.querySelector('[data-interactive-lib-uid="4"]');

        
        console.log('test parent dom'+titleelement);
        this.getServerData();
    }

    getServerData() {
        getskills().then(result => {           
            console.log('skill results'+result[0].Name); 
            
            this.rowData = this.generateRowData(result);
            this.totalitems = result.length;
            
            console.log('testdata'+this.rowData[0]);
            
        }).catch(error => {
            console.log('error is' + error);
        });
    }

  

   
    showToast(title, message, variant, autoClose) {
        this.template.querySelector('c-toast-message').showCustomNotice({
            detail: {
                title: title, message: message, variant: variant, autoClose: autoClose
            }
        });
    }

    

    getRecordURL(idval) {
       // return '/lightning/setup/ManageUsers/page?address=%2F' + idval;
       return '/' + idval;
    }

    handleRowAction(){

    }

    updateSelectedRows(){

    }

    generateRowData(testdata) {
        console.log('in generate');
        var returnlist = [];
        for (var i = 0; i < testdata.length; i++) {         
          let tempRecord = Object.assign({}, testdata[i]); //cloning object
          tempRecord.urlvalue = this.getRecordURL(testdata[i].Id); 
          returnlist.push(tempRecord);          
        }
        return returnlist;
             
    }

    

    

   
}